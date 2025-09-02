from flask import Flask, request, jsonify
import sqlite3

app = Flask(__name__)

users = {"merunka@test.com": "4321"}

@app.route("/api/login", methods=["POST"])
def login():
    data = request.json
    email = data.get("email")
    password = data.get("password")

    if email in users and users[email] == password: return jsonify({"success": True,"message":"Welcome back"})
    else: return jsonify({"success": False,"message":"Invalid login or password"}), 401

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
