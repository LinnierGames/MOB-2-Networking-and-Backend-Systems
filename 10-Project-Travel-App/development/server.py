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

class MyObject(Resource):

    def post(self):
        try:
            new_password = request.json["password"]
            new_username = request.json["username"]
            new_email = request.json["email"]
        except KeyError:
            response = jsonify(message="cannot have missing fields")
            response.status_code = 400

            return response

        email_is_found = app.db.myobjects.find_one({"email": new_email})
        if email_is_found is not None:
            response = jsonify(message="email already used")
            response.status_code = 401

            return response

        username_is_found = app.db.myobjects.find_one({"username": new_username})
        if username_is_found is not None:
            response = jsonify(message="username already used")
            response.status_code = 401

            return response

        user = {
            "username": new_username,
            "email": new_email,
            "password": new_password
        }

        result = app.db.myobjects.insert(user)

        response = jsonify(message="successful insert", data=user)
        response.status_code = 201

        # if result.inserted

        return response

    def get(self, myobject_id):
        myobject = app.db.myobjects.find_one({"_id": ObjectId(myobject_id)})

        if myobject is None:
            response = jsonify(message="resource not found")
            response.status_code = 404

            return response
        else:
            return myobject

    def put(self, myobject_id):

        is_found = app.db.myobjects.find_one({"_id": ObjectId(myobject_id)})

        if is_found is None:
            response = jsonify(message="resource not found")
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

        app.db.myobjects.update_one({"_id": ObjectId(myobject_id)}, {
            "$set": {
                "password": new_password,
                "username": new_username,
                "email": new_email
            }
        })

        response = jsonify(message="update successful")
        response.status_code = 202

        return response


    def patch(self, myobject_id):

        found_object = app.db.myobjects.find_one({"_id": ObjectId(myobject_id)})

        if found_object is None:
            response = jsonify(message="resource not found")
            response.status_code = 404

            return response

        new_password = request.json.get("password", found_object["password"])
        new_username = request.json.get("username", found_object["username"])
        new_email = request.json.get("email", found_object["email"])

        app.db.myobjects.update_one({"_id": ObjectId(myobject_id)}, {
            "$set": {
                "password": new_password,
                "username": new_username,
                "email": new_email
            }
        })

        response = jsonify(message="update successful")
        response.status_code = 202

        return response


## Add api routes here

api.add_resource(MyObject, '/myobject/', '/myobject/<string:myobject_id>')

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
