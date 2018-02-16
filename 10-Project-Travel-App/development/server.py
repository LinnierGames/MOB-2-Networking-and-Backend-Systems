from flask import Flask, request, make_response, jsonify
from flask_restful import Resource, Api
from pymongo import MongoClient
from utils.mongo_json_encoder import JSONEncoder
from bson.objectid import ObjectId
import bcrypt
import pdb

app = Flask(__name__)
mongo = MongoClient('localhost', 27017)
app.db = mongo.trip_planner_development
app.bcrypt_rounds = 12
api = Api(app)


## Write Resources here

class User(Resource):
    # def post(self):
    #     collection = app.db.users
    #     try:
    #         new_password = request.json["password"]
    #         new_username = request.json["username"]
    #         new_email = request.json["email"]
    #     except KeyError:
    #         response = jsonify(message="cannot have missing fields")
    #         response.status_code = 400
    #
    #         return response
    #
    #     # unique email
    #     email_is_found = collection.find_one({"email": new_email})
    #     if email_is_found is not None:
    #         response = jsonify(message="email already used")
    #         response.status_code = 401
    #
    #         return response
    #
    #     # unique username
    #     username_is_found = collection.find_one({"username": new_username})
    #     if username_is_found is not None:
    #         response = jsonify(message="username already used")
    #         response.status_code = 401
    #
    #         return response
    #
    #     user = {
    #         "username": new_username,
    #         "email": new_email,
    #         "password": new_password
    #     }
    #
    #     app.db.myobjects.insert(user)
    #
    #     user = collection.find_one({"_id", ObjectId(user["_id"])}, {"_id": 0})
    #
    #     response = jsonify(message="successful insert", data=user)
    #     response.status_code = 201
    #
    #     return response

    def get(self, id):
        collection = app.db.users
        user = collection.find_one({"_id": ObjectId(id)}, {"_id": 0})

        if user is None:
            response = jsonify(message="resource not found")
            response.status_code = 404

            return response
        else:
            return user

    def put(self, id):
        auth = self._auth(id)

        if auth is not None:
            return auth

        collection = app.db.users
        is_found = collection.find_one({"_id": ObjectId(id)})

        if is_found is None:
            response = jsonify(message="user not found")
            response.status_code = 404

            return response

        try:
            new_password = request.json["password"]
            new_username = request.json["username"]
            new_email = request.json["email"]
        except KeyError:
            response = jsonify(message="cannot have missing fields")
            response.status_code = 400

            return response

        collection.update_one({"_id": ObjectId(id)}, {
            "$set": {
                "password": new_password,
                "username": new_username,
                "email": new_email
            }
        })

        response = jsonify(message="update successful")
        response.status_code = 202

        return response

    def patch(self, id):
        auth = self._auth(id)

        if auth is not None:
            return auth

        found_object = app.db.users.find_one({"_id": ObjectId(id)})

        new_password = request.json.get("password", found_object["password"])
        new_username = request.json.get("username", found_object["username"])
        new_email = request.json.get("email", found_object["email"])

        app.db.users.update_one({"_id": ObjectId(id)}, {
            "$set": {
                "password": new_password,
                "username": new_username,
                "email": new_email
            }
        })

        response = jsonify(message="update successful")
        response.status_code = 202

        return response

    def delete(self, id):
        auth = self._auth(id)

        if auth is not None:
            return auth

        app.db.users.delete_one({"_id": ObjectId(id)})
        app.db.tokens.delete_many({"user_id": ObjectId(id)})

        response = jsonify(message="delete successful")
        response.status_code = 202

        return response

    def _auth(self, id):
        try:
            token = request.headers["Auth"]
        except KeyError:
            response = jsonify(message="auth token cannot be missing")
            response.status_code = 400

            return response

        found_object = app.db.users.find_one({"_id": ObjectId(id)})

        if found_object is None:
            response = jsonify(message="user not found")
            response.status_code = 404

            return response

        user_for_given_token = app.db.tokens.find_one({"token": token})
        if user_for_given_token is None:
            response = jsonify(message="Unauthorized")
            response.status_code = 401

            return response

        if str(user_for_given_token["user_id"]) != id:
            response = jsonify(message="Unauthorized")
            response.status_code = 401

            return response

        return None


api.add_resource(User, '/user/', '/user/<string:id>')

# Add api routes here


@app.route('/auth/login', methods=['POST'])
def login():
    try:
        email = request.json["email"]
        password = request.json["password"]
    except KeyError:
        return jsonify(message="Cannot have any missing fields"), 400, None

    user = app.db.users.find_one({"email": email})

    if user is not None:
        if password == user["password"]:
            username = user["username"]
            # FIXME: use better token generator
            token = username.encode('hex')
            app.db.tokens.insert_one({
                "token": token,
                "username": username,
                "user_id": user["_id"]
            })

            del user["password"]
            del user["_id"]

            return jsonify(message="Successfully logged in {}".format(username), auth_token=token, data=user), 202, None
        else:
            return jsonify(message="Wrong email/password"), 401, None
    else:
        return jsonify(message="Email not found"), 404, None


@app.route('/register', methods=['POST'])
def register():
    try:
        username = request.json["username"]
        email = request.json["email"]
        password = request.json["password"]
    except KeyError:
        return jsonify(message="Cannot have any missing fields"), 400, None

    new_user = {
        "username": username,
        "email": email,
        "password": password,
        "thumbnail": "http://placehold.it/150/92c952"
    }

    users_collection = app.db.users

    if users_collection.find_one({"email": email}) is not None:
        return jsonify(message="Email already exists"), 403, None
    elif users_collection.find_one({"username": username}) is not None:
        return jsonify(message="Username already exists"), 403, None

    users_collection.insert_one(new_user)

    return jsonify(message="Successfully registered {}".format(username)), 201, None

#  Custom JSON serializer for flask_restful


@api.representation('application/json')
def output_json(data, code, headers=None):
    resp = make_response(JSONEncoder().encode(data), code)
    resp.headers.extend(headers or {})
    return resp


if __name__ == '__main__':
    # Turn this on in debug mode to get detailled information about request
    # related exceptions: http://flask.pocoo.org/docs/0.10/config/
    app.config['TRAP_BAD_REQUEST_ERRORS'] = False
    app.run(debug=True)
