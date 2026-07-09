import json
from flask import Flask

app = Flask(__name__)

@app.route("/")
def get_my_info():
    value = {
        "name": "Diego",
        "last_name": "Villegas",
        "social_media": {
            "github": "diegolonio",
            "linkedin": "diegolonio",
            "twitter": "diegolonio",
            "instagram": "diegolonio",
            "facebook": "diegolonio",
            "tiktok": "diegolonio",
            "youtube": "diegolonio"
        },
        "email": "diego.apoloniov@gmail.com",
        "website": "https://diegolonio.com"
    }
    return json.dumps(value)
