from flask import Flask,jsonify
from flask_cors import CORS

app = Flask(__name__)
CORS(app)

@app.route('/getMyInfo')
def getMyInfo():
    value = {
        "name": "Diego",
        "lastname": "Villegas",
        "socialMedia":
        {
            "facebookUser": "diegolonio",
            "instagramUser": "diegolonio",
            "xUser": "diegolonio",
            "linkedin": "diegolonio",
            "githubUser": "diegolonio"
        },
        "blog": "https://diegolonio.com",
        "author": "Diego Villegas"
    }

    return jsonify(value)

if __name__ == '__main__':
    app.run(port=5000)
