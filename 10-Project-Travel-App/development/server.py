from flask import Flask, request, make_response, url_for, redirect, abort, render_template, jsonify
import pdb
from flask_restful import Resource, Api
import hashlib
import uuid
uuid.uuid4()
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

token_table = []

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
        return (jsonify(message="Cannot have any missing fields"), 400, None)
    new_user = {
        "username": username,
        "email": email,
        "name": name
    }

    if new_user in list_users:
        return (jsonify(message="User already exists"), 403, None)

    list_users.append(new_user)

    token = (username).encode('hex')
    token_table.append({
        "token": token,
        "username": username
    })

    return (jsonify(message="Successfully registered {}".format(username), auth_token=token), 201, None)

@app.route('/users')
def users():
    return (jsonify(list_users),200, {"Content-Type": "application/json"})

@app.route('/users/<string:username>')
def profile(username):
    user = None
    for a_user in list_users:
        if a_user["username"] == username:
            user = a_user

    if user == None:
        return page_not_found(error="user not found")

    return (jsonify(user),200, {"Content-Type": "application/json"})

@app.route('/users/<string:username>/delete', methods=['DELETE'])
def delete_profile(username):
    auth_token = None
    try:
        auth_token = request.form["Token"]
    except KeyError:
        return bad_request(error="user auth token required for this action")
    decoded_username = None
    try:
        decoded_username = auth_token.decode('hex')
    except KeyError:
        return bad_request(error="Naw")

    if decoded_username == username:
        isDeleted = False
        for index, a_user in enumerate(list_users):
            if a_user["username"] == username:
                del list_users[index]
                isDeleted = True

        if isDeleted:
            return (jsonify(message="{} was deleted".format(username)), 202, None)
        else:
            return bad_request(error="{} was not found".format(username))
    else:
        return (jsonify(message="Unauthorized request"), 401, None)

@app.errorhandler(404)
def page_not_found(error):
    return (render_template('page_not_found.html', error=error), 404, None)

@app.errorhandler(400)
def bad_request(error):
    return (render_template('page_not_found.html', error=error), 400, None)


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
