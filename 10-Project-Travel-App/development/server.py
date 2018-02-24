from flask import Flask, request, make_response, jsonify
from flask_restful import Resource, Api
from pymongo import MongoClient
from utils.mongo_json_encoder import JSONEncoder
from bson.objectid import ObjectId
from datetime import datetime
from functools import wraps
import jwt
import bcrypt
import pdb

app = Flask(__name__)
mongo = MongoClient('localhost', 27017)
app.db = mongo.trip_planner_development
app.bcrypt_rounds = 12
api = Api(app)

app.config['SECRET_KEY'] = 'hot-tomalles'

## Write Resources here

def auth_protected(f):
    @wraps(f)
    def auth(*args, **kwargs):
        pass

    return auth


# can return: 400 missing token
# can return: 404 user not found form _id
# can return: 401 invalid token, unmatching id with given token
class Auth(object):
    token = None
    user_id = None
    timeout = None

    @classmethod
    def authorize(cls):
        try:
            token = request.headers["Auth"]
        except KeyError:
            response = jsonify(message="auth token cannot be missing")
            response.status_code = 400

            return response

        try:
            token_dict = jwt.decode(token, app.config['SECRET_KEY'])
            user_id = ObjectId(token_dict["user_id"])
        except (jwt.DecodeError, jwt.InvalidTokenError) as err:
            response = jsonify(message="Unauthorized-Oops")
            response.status_code = 401

            return response

        found_object = app.db.users.find_one({"_id": user_id})

        if found_object is None:
            response = jsonify(message="user not found")
            response.status_code = 404

            return response

        user_for_given_token = app.db.tokens.find_one({"token": token})
        if user_for_given_token is None:
            response = jsonify(message="Unauthorized-1")
            response.status_code = 401

            return response

        if user_for_given_token["user_id"] != user_id:
            response = jsonify(message="Unauthorized-2")
            response.status_code = 401

            return response

        cls.token = token
        cls.user_id = user_id
        # TODO: use a timeout to revoke the token
        cls.timeout = datetime.now()

    @classmethod
    def revoke(cls):
        cls.token = None
        cls.user_id = None


class User(Resource):

    def get(self, user_id):
        user = app.db.users.find_one({"_id": ObjectId(user_id)}, {"_id": 0, "password": 0})

        if user is None:
            response = jsonify(message="resource not found")
            response.status_code = 404

            return response

        if request.args.get("include trips", None) is not None:
            user_trips = app.db.trips.find({"user_id": ObjectId(user_id)})

            trips = list(user_trips)
            for a_trip in trips:
                a_trip["_id"] = str(a_trip["_id"])
                a_trip["user_id"] = str(a_trip["user_id"])

            user["trips"] = trips

        response = jsonify(message="found user", data=user)
        response.status_code = 200

        return response

    def put(self, user_id):
        auth = Auth.authorize()

        if auth is not None:
            return auth

        collection = app.db.users
        is_found = collection.find_one({"_id": ObjectId(user_id)})

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

        collection.update_one({"_id": ObjectId()}, {
            "$set": {
                "password": new_password,
                "username": new_username,
                "email": new_email
            }
        })

        response = jsonify(message="update successful")
        response.status_code = 202

        return response

    def patch(self, user_id):
        auth = Auth.authorize()

        if auth is not None:
            return auth

        # preconditions: _auth checks if user exists

        found_object = app.db.users.find_one({"_id": ObjectId(user_id)})

        new_password = request.json.get("password", found_object["password"])
        new_username = request.json.get("username", found_object["username"])
        new_email = request.json.get("email", found_object["email"])

        app.db.users.update_one({"_id": ObjectId(user_id)}, {
            "$set": {
                "password": new_password,
                "username": new_username,
                "email": new_email
            }
        })

        response = jsonify(message="update successful")
        response.status_code = 202

        return response

    def delete(self, user_id):
        auth = Auth.authorize()

        if auth is not None:
            return auth

        app.db.users.delete_one({"_id": ObjectId(user_id)})
        app.db.tokens.delete_many({"user_id": ObjectId(user_id)})

        response = jsonify(message="delete successful")
        response.status_code = 202

        return response


api.add_resource(User, '/user/', '/user/<string:user_id>')


class Trip(Resource):
    def post(self):
        auth = Auth.authorize()

        if auth is not None:
            return auth

        try:
            title = request.json["title"]
        except KeyError:
            response = jsonify(message="Cannot have missing fields")
            response.status_code = 400

            return response

        new_trip = {
            "user_id": Auth.user_id,
            "title": title
        }

        result = app.db.trips.insert_one(new_trip)

        trip = new_trip
        trip["_id"] = str(result.inserted_id)
        trip["user_id"] = str(trip["user_id"])

        response = jsonify(message="added trip successfully", data=trip)
        response.status_code = 201

        return response

    def get(self, trip_id):
        auth = Auth.authorize()

        if auth is not None:
            return auth

        found_trip = app.db.trips.find_one({"_id": ObjectId(trip_id)}, {"_id": 0})

        if found_trip is None:
            response = jsonify(message="Could not find trip")
            response.status_code = 404

            return response

        trip_user = app.db.users.find_one({"_id": ObjectId(found_trip["user_id"])})
        trip_user["_id"] = str(trip_user["_id"])

        found_trip["user"] = trip_user
        del found_trip["user_id"]

        response = jsonify(message="found a trip", data=found_trip)
        response.status_code = 202

        return response

    def patch(self, trip_id):
        auth = Auth.authorize()

        if auth is not None:
            return auth

        # preconditions: _auth checks if user exists

        # TODO: Dry
        found_trip = app.db.trips.find_one({"_id": ObjectId(trip_id)})

        if found_trip is None:
            response = jsonify(message="Trip not found")
            response.status_code = 404

            return response

        if found_trip["user_id"] != Auth.user_id:
            response = jsonify(message="Unauthorized")
            response.status_code = 401

            return response

        # authorized: token and user_id has permission

        new_title = request.json.get("title", found_trip["title"])

        app.db.trips.update_one({"_id": ObjectId(trip_id)}, {
            "$set": {
                "title": new_title,
            }
        })

        response = jsonify(message="update successful")
        response.status_code = 202

        return response

    def delete(self, trip_id):
        auth = Auth.authorize()

        if auth is not None:
            return auth

        # TODO: Dry
        found_trip = app.db.trips.find_one({"_id": ObjectId(trip_id)})

        if found_trip is None:
            response = jsonify(message="Trip not found")
            response.status_code = 404

            return response

        if found_trip["user_id"] != Auth.user_id:
            response = jsonify(message="Unauthorized")
            response.status_code = 401

            return response

        app.db.trips.delete_one({"_id": ObjectId(trip_id)})

        response = jsonify(message="delete successful")
        response.status_code = 202

        return response


api.add_resource(Trip, '/trip/', '/trip/<string:trip_id>', endpoint='a_trip')


class UserTrip(Resource):

    def get(self, user_id):
        auth = Auth.authorize()

        if auth is not None:
            return auth

        user = app.db.users.find_one({"_id": ObjectId(user_id)}, {"password": 0})

        if user is None:
            response = jsonify(message="resource not found")
            response.status_code = 404

            return response

        user_trips = app.db.trips.find({"user_id": ObjectId(user_id)})

        trips = list(user_trips)
        for a_trip in trips:
            a_trip["_id"] = str(a_trip["_id"])
            a_trip["user_id"] = str(a_trip["user_id"])

        response = jsonify(message="success", data=trips)
        response.status_code = 202

        return response


api.add_resource(UserTrip, '/user/<string:user_id>/trips', endpoint='user_trips')

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

            del user["password"]
            user_id_str = str(user["_id"])

            token = jwt.encode({'user_id': user_id_str}, app.config['SECRET_KEY'])
            token_string = token.decode('UTF-8')
            app.db.tokens.insert_one({
                "token": token_string,
                "username": username,
                "user_id": user["_id"]
            })
            user["_id"] = user_id_str

            return jsonify(message="Successfully logged in {}".format(username), auth_token=token_string, data=user), 202, None
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

    # FIXME: store passwords elsewhere
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

    result = users_collection.insert_one(new_user)

    response = jsonify(message="Successfully registered {}".format(username))
    response.status_code = 201

    return response

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
