from flask import Flask, request, make_response, url_for, redirect, abort, render_template, jsonify
import pdb
from flask_restful import Resource, Api
from pymongo import MongoClient
from utils.mongo_json_encoder import JSONEncoder
from bson.objectid import ObjectId
import bcrypt


app = Flask(__name__)
mongo = MongoClient('localhost', 27017)
app.db = mongo.trip_planner_development
app.bcrypt_rounds = 12
api = Api(app)


## Write Resources here

list_users = [
    {
        "username": "ErickES7",
        "name": "Erick Sanchez",
        "email": "e@d.com"
    },
    {
        "username": "SilvaEmrik",
        "name": "Joshua Sanchez",
        "email": "j@d.com"
    }
]

## Add api routes here

@app.route('/')
def home():
    return (jsonify(message="index route not supported"))

@app.route('/register', methods=['POST'])
def register():
    try:
        username = request.form["username"]
        email = request.form["email"]
        name = request.form["name"]
    except KeyError:
        return (jsonify(message="Cannot have any missing fields"), 403, None)

    list_users.append({username: username, email: email, name: name})

    return (jsonify(message="Successfully registered {}".format(username)), 201, None)

@app.route('/users')
def users():
    return (jsonify(list_users),200, {"Content-Type": "application/json"})

@app.route('/users/<string:username>')
def profile(username):
    user = next(x for x in list_users if lambda item: item["username"] == username)

    return (jsonify(user),200, {"Content-Type": "application/json"})

@app.errorhandler(404)
def page_not_found(error):
    return (render_template('page_not_found.html', error=error), 404, None)

#  Custom JSON serializer for flask_restful
@api.representation('application/json')
def output_json(data, code, headers=None):
    resp = make_response(JSONEncoder().encode(data), code)
    resp.headers.extend(headers or {})
    return resp

if __name__ == '__main__':
    # Turn this on in debug mode to get detailled information about request
    # related exceptions: http://flask.pocoo.org/docs/0.10/config/
    app.config['TRAP_BAD_REQUEST_ERRORS'] = True
    app.run(debug=True)
