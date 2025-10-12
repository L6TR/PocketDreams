from flask import Flask, request, jsonify
import sqlite3

app = Flask(__name__)

conn = sqlite3.connect("pocketdreams.db") # connection to the databse
cursor = conn.cursor() # we need this one for our SQL commands
cursor.execute("CREATE TABLE IF NOT EXISTS users (id INTEGER PRIMARY KEY, nickname TEXT, password TEXT)")
#making a table if it doesnt exist


conn.commit() # saving changes in our database
conn.close() # ending our connection


@app.route("/api/register", methods=["POST"])
def register():
    conn = sqlite3.connect("pocketdreams.db")
    cursor = conn.cursor()

    nickname = "merunka"
    password = "4321"

    cursor.execute("INSERT INTO users (nickname, password) VALUES (?, ?)", (nickname,password))
    
    conn.commit()
    conn.close()

    return jsonify({"success": True, "message": "User registered"})


@app.route("/api/login", methods=["POST"])
def login():
    data = request.json
    nickname = data.get("nickname")
    password = data.get("password")

    conn = sqlite3.connect("pocketdreams.db")
    cursor = conn.cursor()

    # "nickname = ?", (nickname) 
    # means that nickname would change on (nickname) and ? is just placeholder
    cursor.execute("SELECT password FROM users WHERE nickname = ?", (nickname,))

    # fetchone means chose first in our cursor or return None 
    row = cursor.fetchone()


    conn.close()

    if row and row[0] == password:
        return jsonify({"success":True, "message": "Welcome back"})
    else:
        return jsonify({"success":False, "message": "Invalid login or password"}), 401

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
