import os
import cv2
import numpy as np
import tensorflow as tf
from datetime import datetime
from flask import Flask, request, jsonify
from tensorflow.keras.applications.efficientnet import preprocess_input
import requests
from pymongo import MongoClient
from werkzeug.utils import secure_filename
import json
import re
import time

# ===========================================
# CONFIG
# ===========================================
MODEL_PATH = "rice_model_final.h5"
IMG_SIZE = 380
WEATHER_API_KEY = "ceb7f556bffe0cf3497f8425925dfb1b"
GOOGLE_MAPS_API_KEY = "AIzaSyAH8tyWj0Q8sEIAXjXmstUIZqAKMEzfgkg"  # Add your Google Maps API key here

CLASS_NAMES = [
    'Bacterial_leaf_blight',
    'Brown_spot',
    'Healthy',
    'Leaf_blast',
    'Leaf_scald',
    'Sheath_blight',
    'Tungro'
]

# Load disease meta data
with open("data/diseases_data.json", encoding="utf-8") as f:
    DISEASE_DATA = json.load(f)

SEASON_WEIGHTS = {
    "Kharif": {"Leaf_blast": 1.10, "Bacterial_leaf_blight": 1.05, "Sheath_blight": 1.10, "Tungro": 1.05},
    "Rabi": {"Brown_spot": 1.10, "Leaf_scald": 1.05},
    "Zaid": {"Leaf_scald": 1.10, "Brown_spot": 1.05}
}

LANG_MAP = {
    'en': 'english',
    'hi': 'hindi',
    'mr': 'marathi',
    'ka': 'kannada'
}

UPLOAD_FOLDER = "uploads"
os.makedirs(UPLOAD_FOLDER, exist_ok=True)

# ===========================================
# MONGO DB INIT
# ===========================================
mongo = MongoClient("mongodb://localhost:27017/")
db = mongo["rice_disease_db"]
records = db["detections"]

# ===========================================
# FLASK APP
# ===========================================
app = Flask(__name__)
app.config["UPLOAD_FOLDER"] = UPLOAD_FOLDER

# ===========================================
# LOAD MODEL
# ===========================================
print("Loading TensorFlow model...")
try:
    model = tf.keras.models.load_model(MODEL_PATH)
    print("Model Loaded Successfully!")
except Exception as e:
    print(f"Failed to load model from {MODEL_PATH}: {e}")
    model = None

# ===========================================
# HELPERS
# ===========================================
def get_season():
    m = datetime.now().month
    if m in [6, 7, 8, 9]:
        return "Kharif"
    if m in [10, 11, 12, 1]:
        return "Rabi"
    return "Zaid"


def get_weather(lat=None, lon=None, location=None):
    try:
        if lat is not None and lon is not None:
            url = f"http://api.openweathermap.org/data/2.5/weather?lat={lat}&lon={lon}&appid={WEATHER_API_KEY}&units=metric"
        else:
            url = f"http://api.openweathermap.org/data/2.5/weather?q={location}&appid={WEATHER_API_KEY}&units=metric"

        r = requests.get(url, timeout=10).json()
        if r.get("cod") != 200:
            return None

        return {
            "humidity": r["main"]["humidity"],
            "temperature": r["main"]["temp"],
            "rain": 1 if "rain" in r else 0,
            "weather_main": r["weather"][0]["main"] if r.get("weather") else "Unknown",
            "weather_description": r["weather"][0]["description"] if r.get("weather") else "Unknown",
            "pressure": r["main"]["pressure"],
            "wind_speed": r["wind"]["speed"] if "wind" in r else 0,
            "location_name": r.get("name", "Unknown")
        }
    except Exception as e:
        print("get_weather error:", e)
        return None


def extract_leaf_roi(img):
    try:
        hsv = cv2.cvtColor(img, cv2.COLOR_BGR2HSV)
        lower = np.array([25, 40, 40])
        upper = np.array([95, 255, 255])
        mask = cv2.inRange(hsv, lower, upper)

        kernel = np.ones((7,7), np.uint8)
        mask = cv2.morphologyEx(mask, cv2.MORPH_CLOSE, kernel)
        mask = cv2.morphologyEx(mask, cv2.MORPH_OPEN, kernel)

        contours,_ = cv2.findContours(mask, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)

        if not contours:
            return img

        c = max(contours, key=cv2.contourArea)
        x,y,w,h = cv2.boundingRect(c)
        roi = img[y:y+h, x:x+w]

        if roi.shape[0] < 50 or roi.shape[1] < 50:
            return img

        return roi
    except Exception as e:
        print("extract_leaf_roi error:", e)
        return img


def predict(image_path):
    if model is None:
        raise RuntimeError("Model not loaded")

    img = cv2.imread(image_path)
    if img is None:
        raise ValueError("Unable to read image or image is invalid")

    roi = extract_leaf_roi(img)

    rgb = cv2.cvtColor(roi, cv2.COLOR_BGR2RGB)
    resized = cv2.resize(rgb, (IMG_SIZE, IMG_SIZE))
    arr = preprocess_input(resized)
    arr = np.expand_dims(arr, axis=0)

    preds = model.predict(arr, verbose=0)[0]
    return preds


def adjust_weather(preds, w):
    preds = preds.copy()
    healthy_idx = CLASS_NAMES.index("Healthy")

    if not w:
        return preds

    hum, temp, rain = w["humidity"], w["temperature"], w["rain"]
    risky = (hum > 75 or rain == 1 or (22 <= temp <= 30))

    healthy_prob = preds[healthy_idx]

    if healthy_prob > 0.55:
        return preds

    if 0.35 <= healthy_prob <= 0.55:
        if risky:
            preds *= 1.10
            preds[healthy_idx] *= 0.80
    else:
        if risky:
            preds *= 1.20
            preds[healthy_idx] *= 0.75

    return preds / preds.sum()


def adjust_season(preds, season):
    preds = preds.copy()

    if season in SEASON_WEIGHTS:
        for d, w in SEASON_WEIGHTS[season].items():
            if d in CLASS_NAMES:
                preds[CLASS_NAMES.index(d)] *= w

    preds[CLASS_NAMES.index("Healthy")] *= 0.98
    return preds / preds.sum()


# ===========================================
# GET DISEASE INFO FROM JSON WITH ALL DATA
# ===========================================
def get_disease_info(disease_id, lang, lat=None, lon=None):
    lang_key = LANG_MAP.get(lang, "english")
    
    for d in DISEASE_DATA["diseases"]:
        if d["id"] == disease_id:
            # Get language-specific data
            lang_data = d["languages"].get(lang_key, d["languages"]["english"])
            
            # Get nearby agro stores API with dynamic lat/lng
            agro_api = d.get("nearby_agro_stores_api", "")
            if agro_api and lat is not None and lon is not None:
                # Replace {{LAT}} and {{LNG}} with actual values
                agro_api = agro_api.replace("{{LAT}}", str(lat))
                agro_api = agro_api.replace("{{LNG}}", str(lon))
                
                # Also add the API key if present in config
                if "YOUR_API_KEY" in agro_api and GOOGLE_MAPS_API_KEY != "YOUR_GOOGLE_MAPS_API_KEY":
                    agro_api = agro_api.replace("YOUR_API_KEY", GOOGLE_MAPS_API_KEY)
            
            # Build complete disease info
            disease_info = {
                "id": d["id"],
                "image_url": d.get("image_url", ""),
                "local_name": lang_data.get("local_name", ""),
                "cause": lang_data.get("cause", ""),
                "solutions": lang_data.get("solutions", lang_data.get("solutions", [])),
                "pesticides": lang_data.get("pesticides", lang_data.get("pesticicides", [])),
                # Additional data from JSON
                "cure_steps": d.get("cure_steps", []),
                "recommended_pesticides": d.get("recommended_pesticides", []),
                "eligible_schemes": d.get("eligible_schemes", []),
                "nearby_agro_stores_api": agro_api,
                "coordinates_used": {"lat": lat, "lon": lon} if lat and lon else None,
                # All language data
                "all_languages": {
                    "english": d["languages"].get("english", {}),
                    "hindi": d["languages"].get("hindi", {}),
                    "kannada": d["languages"].get("kannada", {}),
                    "marathi": d["languages"].get("marathi", {})
                }
            }
            
            # Add missing fields for compatibility
            if "name" not in disease_info:
                disease_info["name"] = lang_data.get("name", disease_id)
            
            return disease_info
    
    # If disease not found in JSON, return default structure
    agro_api_default = ""
    if lat is not None and lon is not None:
        agro_api_default = f"https://maps.googleapis.com/maps/api/place/nearbysearch/json?location={lat},{lon}&radius=5000&keyword=agro%20store|pesticide%20shop|fertilizer|krishi%20kendra&key={GOOGLE_MAPS_API_KEY}"
    
    return {
        "id": disease_id,
        "name": disease_id,
        "local_name": disease_id,
        "cause": "Information not available",
        "solutions": [],
        "pesticides": [],
        "cure_steps": [],
        "recommended_pesticides": [],
        "eligible_schemes": [],
        "nearby_agro_stores_api": agro_api_default,
        "coordinates_used": {"lat": lat, "lon": lon} if lat and lon else None,
        "image_url": "",
        "all_languages": {}
    }


# ===========================================
# FETCH ACTUAL AGRO STORES (OPTIONAL)
# ===========================================
def fetch_nearby_agro_stores(lat, lon, radius=5000):
    """Fetch actual agro stores from Google Places API"""
    try:
        if GOOGLE_MAPS_API_KEY == "YOUR_GOOGLE_MAPS_API_KEY":
            return {"error": "Google Maps API key not configured"}
        
        url = f"https://maps.googleapis.com/maps/api/place/nearbysearch/json"
        params = {
            "location": f"{lat},{lon}",
            "radius": radius,
            "keyword": "agro store|pesticide shop|fertilizer|krishi kendra|agricultural store",
            "key": GOOGLE_MAPS_API_KEY
        }
        
        response = requests.get(url, params=params, timeout=10)
        data = response.json()
        
        if data.get("status") == "OK":
            stores = []
            for place in data.get("results", [])[:10]:  # Limit to 10 stores
                store = {
                    "name": place.get("name"),
                    "address": place.get("vicinity"),
                    "rating": place.get("rating"),
                    "open_now": place.get("opening_hours", {}).get("open_now") if "opening_hours" in place else None,
                    "types": place.get("types", []),
                    "place_id": place.get("place_id")
                }
                stores.append(store)
            
            return {
                "status": "success",
                "count": len(stores),
                "stores": stores,
                "location": {"lat": lat, "lon": lon},
                "radius": radius
            }
        else:
            return {
                "status": "error",
                "message": data.get("error_message", "Failed to fetch stores"),
                "api_status": data.get("status")
            }
    except Exception as e:
        return {"status": "error", "message": str(e)}


# ===========================================
# GET ALL DISEASES FOR REFERENCE
# ===========================================
def get_all_diseases_summary():
    summary = []
    for disease in DISEASE_DATA["diseases"]:
        summary.append({
            "id": disease["id"],
            "name": disease["languages"]["english"].get("name", disease["id"]),
            "local_name": disease["languages"]["english"].get("local_name", ""),
            "image_url": disease.get("image_url", "")
        })
    return summary


# ===========================================
# FIND 3 SHOPS HELPERS (FULL ORIGINAL LOGIC)
# ===========================================
def get_place_details_full(place_id, api_key):
    url = "https://maps.googleapis.com/maps/api/place/details/json"
    params = {
        "place_id": place_id,
        "fields": "formatted_phone_number,international_phone_number,formatted_address",
        "key": api_key
    }
    r = requests.get(url, params=params, timeout=10).json()
    result = r.get("result", {})

    phone = (
        result.get("international_phone_number")
        or result.get("formatted_phone_number")
        or "Not available"
    )
    address = result.get("formatted_address", "Not available")

    return phone, address


def search_places_full(lat, lng, radius, api_key, keyword=None):
    url = "https://maps.googleapis.com/maps/api/place/nearbysearch/json"
    params = {
        "location": f"{lat},{lng}",
        "radius": radius,
        "type": "store",
        "key": api_key
    }
    if keyword:
        params["keyword"] = keyword

    r = requests.get(url, params=params, timeout=10)
    return r.json()


def find_three_shops(lat, lng, api_key):
    agro_keywords = (
        "pesticide shop agro agency agro shop fertilizer shop fertiliser shop "
        "krushi kendra krishi kendra seed shop agro chemicals agri inputs "
        "pesticides fertilizers insecticide agro traders"
    )

    expanding_radii = [500, 1000, 2000, 5000, 10000, 20000, 30000]
    final = []
    seen = set()

    # STEP 1: SEARCH AGRO SHOPS
    for radius in expanding_radii:
        print(f"Searching AGRO shops at {radius}m...")
        data = search_places_full(lat, lng, radius, api_key, agro_keywords)

        for place in data.get("results", []):
            pid = place.get("place_id")
            if not pid or pid in seen:
                continue
            seen.add(pid)

            name = place.get("name", "Unknown")
            loc = place.get("geometry", {}).get("location", {})
            if not loc:
                continue
            phone, address = get_place_details_full(pid, api_key)

            maps_link = f"https://www.google.com/maps/search/?api=1&query={loc.get('lat')},{loc.get('lng')}"

            final.append({
                "name": name,
                "address": address,
                "phone": phone,
                "lat": loc.get("lat"),
                "lng": loc.get("lng"),
                "maps_link": maps_link,
                "radius_found": radius
            })

            if len(final) == 3:
                return final

        time.sleep(0.3)

    # STEP 2: LESS THAN 3 → SEARCH ANY SHOPS
    print("⚠️ Less than 3 agro shops found → searching ANY shops...")

    for radius in expanding_radii:
        data = search_places_full(lat, lng, radius, api_key)

        for place in data.get("results", []):
            pid = place.get("place_id")
            if not pid or pid in seen:
                continue
            seen.add(pid)

            name = place.get("name", "Unknown")
            loc = place.get("geometry", {}).get("location", {})
            if not loc:
                continue
            phone, address = get_place_details_full(pid, api_key)

            maps_link = f"https://www.google.com/maps/search/?api=1&query={loc.get('lat')},{loc.get('lng')}"

            final.append({
                "name": name,
                "address": address,
                "phone": phone,
                "lat": loc.get("lat"),
                "lng": loc.get("lng"),
                "maps_link": maps_link,
                "radius_found": radius
            })

            if len(final) == 3:
                return final

        time.sleep(0.3)

    return final


# ===========================================
# API ENDPOINTS
# ===========================================
@app.route("/predict", methods=["POST"])
def api_predict():
    try:
        file = request.files.get("image")
        lang = request.form.get("lang", "en")
        location = request.form.get("location")
        lat = request.form.get("lat")
        lon = request.form.get("lon")
        
        # Parse lat/lon if provided
        user_lat = None
        user_lon = None
        if lat and lon:
            try:
                user_lat = float(lat)
                user_lon = float(lon)
            except ValueError:
                return jsonify({"error": "Invalid latitude/longitude format"}), 400

        if not file:
            return jsonify({"error": "Image is required"}), 400

        filename = secure_filename(file.filename)
        image_path = os.path.join(app.config["UPLOAD_FOLDER"], filename)
        file.save(image_path)

        # Get weather data
        if user_lat is not None and user_lon is not None:
            weather = get_weather(lat=user_lat, lon=user_lon)
        else:
            weather = get_weather(location=location)

        season = get_season()
        raw_preds = predict(image_path)
        
        # Get all probabilities
        all_probabilities = {CLASS_NAMES[i]: float(raw_preds[i]) for i in range(len(CLASS_NAMES))}
        
        # Apply adjustments
        preds_weather = adjust_weather(raw_preds, weather)
        preds_final = adjust_season(preds_weather, season)

        final_idx = int(np.argmax(preds_final))
        final_label = CLASS_NAMES[final_idx]
        final_confidence = float(preds_final[final_idx])

        # Get detailed disease info with ALL data (including dynamic agro API)
        disease_info = get_disease_info(final_label, lang, user_lat, user_lon)
        
        # Fetch actual agro stores if coordinates provided
        agro_stores_data = None
        if user_lat is not None and user_lon is not None:
            agro_stores_data = fetch_nearby_agro_stores(user_lat, user_lon)
        
        # Get top 3 predictions
        sorted_indices = np.argsort(preds_final)[::-1]
        top_predictions = []
        for i in range(min(3, len(CLASS_NAMES))):
            idx = int(sorted_indices[i])
            top_predictions.append({
                "disease": CLASS_NAMES[idx],
                "confidence": float(preds_final[idx])
            })

        # Build comprehensive response
        result = {
            "status": "success",
            "prediction": {
                "final_disease": final_label,
                "confidence": final_confidence,
                "top_predictions": top_predictions,
                "all_probabilities": all_probabilities,
                "adjusted_probabilities": {CLASS_NAMES[i]: float(preds_final[i]) for i in range(len(CLASS_NAMES))}
            },
            "disease_details": disease_info,
            "context": {
                "season": season,
                "weather": weather if weather else "Unavailable",
                "location": {
                    "coordinates": {"lat": user_lat, "lon": user_lon} if user_lat and user_lon else None,
                    "place": location
                },
                "timestamp": datetime.now().isoformat(),
                "image_filename": filename,
                "language": lang
            },
            "recommendations": {
                "immediate_actions": disease_info.get("cure_steps", []),
                "pesticides": disease_info.get("recommended_pesticides", []),
                "government_schemes": disease_info.get("eligible_schemes", []),
                "agro_stores": {
                    "api_endpoint": disease_info.get("nearby_agro_stores_api", ""),
                    "nearby_stores": agro_stores_data if agro_stores_data else "Coordinates required for store lookup"
                }
            },
            "metadata": {
                "model_used": "EfficientNet",
                "image_size": IMG_SIZE,
                "total_diseases_tracked": len(CLASS_NAMES)
            }
        }

        # Save to MongoDB
        try:
            mongo_record = {
                "image": filename,
                "prediction": final_label,
                "confidence": final_confidence,
                "probabilities": all_probabilities,
                "weather": weather,
                "season": season,
                "location": {
                    "coordinates": {"lat": user_lat, "lon": user_lon} if user_lat and user_lon else None,
                    "place": location
                },
                "timestamp": datetime.now(),
                "language": lang
            }
            records.insert_one(mongo_record)
        except Exception as e:
            print("Mongo insert error:", e)

        # Clean up uploaded file
        try:
            os.remove(image_path)
        except Exception:
            pass

        return jsonify(result)

    except Exception as e:
        # Log error
        print(f"Error in prediction: {str(e)}")
        return jsonify({
            "status": "error",
            "error": str(e),
            "timestamp": datetime.now().isoformat()
        }), 500


# ===========================================
# ADDITIONAL API ENDPOINTS
# ===========================================
@app.route("/diseases", methods=["GET"])
def get_diseases():
    """Get summary of all diseases"""
    try:
        summary = get_all_diseases_summary()
        return jsonify({
            "status": "success",
            "count": len(summary),
            "diseases": summary
        })
    except Exception as e:
        return jsonify({"error": str(e)}), 500


@app.route("/disease/<disease_id>", methods=["GET"])
def get_disease_by_id(disease_id):
    """Get complete information for a specific disease"""
    try:
        lang = request.args.get("lang", "en")
        lat = request.args.get("lat")
        lon = request.args.get("lon")
        
        user_lat = float(lat) if lat else None
        user_lon = float(lon) if lon else None
        
        disease_info = get_disease_info(disease_id, lang, user_lat, user_lon)
        
        if disease_info.get("name") == disease_id and disease_info.get("cause") == "Information not available":
            return jsonify({
                "status": "error",
                "message": f"Disease '{disease_id}' not found"
            }), 404
        
        return jsonify({
            "status": "success",
            "disease": disease_info
        })
    except Exception as e:
        return jsonify({"error": str(e)}), 500


@app.route("/agro-stores", methods=["GET"])
def get_agro_stores():
    """Get nearby agro stores using Google Places API"""
    try:
        lat = request.args.get("lat")
        lon = request.args.get("lon")
        radius = request.args.get("radius", 5000, type=int)
        
        if not lat or not lon:
            return jsonify({
                "status": "error",
                "message": "Latitude and longitude are required"
            }), 400
        
        user_lat = float(lat)
        user_lon = float(lon)
        
        stores_data = fetch_nearby_agro_stores(user_lat, user_lon, radius)
        return jsonify(stores_data)
        
    except ValueError:
        return jsonify({"error": "Invalid latitude/longitude format"}), 400
    except Exception as e:
        return jsonify({"error": str(e)}), 500


@app.route("/health", methods=["GET"])
def health_check():
    """Health check endpoint"""
    return jsonify({
        "status": "healthy",
        "timestamp": datetime.now().isoformat(),
        "model_loaded": model is not None,
        "diseases_loaded": len(DISEASE_DATA["diseases"]) if DISEASE_DATA else 0,
        "google_maps_configured": GOOGLE_MAPS_API_KEY != "YOUR_GOOGLE_MAPS_API_KEY"
    })


# ===========================================
# NEW ROUTE: /findStores
# ===========================================
@app.route("/findStores", methods=["GET"])
def find_stores_api():
    try:
        lat = request.args.get("lat")
        lon = request.args.get("lon")

        if not lat or not lon:
            return jsonify({
                "status": "error",
                "message": "Latitude and longitude are required"
            }), 400

        try:
            user_lat = float(lat)
            user_lon = float(lon)
        except ValueError:
            return jsonify({"error": "Invalid latitude/longitude format"}), 400

        if GOOGLE_MAPS_API_KEY == "YOUR_GOOGLE_MAPS_API_KEY":
            return jsonify({
                "status": "error",
                "message": "Google Maps API key not configured"
            }), 400

        print("\n=== Finding 3 nearest pesticide/agro stores ===")

        shops = find_three_shops(user_lat, user_lon, GOOGLE_MAPS_API_KEY)

        return jsonify({
            "status": "success",
            "total_found": len(shops),
            "coordinates_used": {
                "lat": user_lat,
                "lon": user_lon
            },
            "shops": shops
        })

    except Exception as e:
        print("Error in /findStores:", str(e))
        return jsonify({
            "status": "error",
            "message": str(e)
        }), 500


# ===========================================
# RUN SERVER
# ===========================================
if __name__ == "__main__":
    print(f"Loaded {len(DISEASE_DATA['diseases'])} diseases from JSON")
    print(f"Tracking {len(CLASS_NAMES)} disease classes")
    if GOOGLE_MAPS_API_KEY == "YOUR_GOOGLE_MAPS_API_KEY":
        print("⚠️  WARNING: Google Maps API key not configured. Agro store features will be limited.")
    app.run(host="0.0.0.0", port=5000, debug=True)
