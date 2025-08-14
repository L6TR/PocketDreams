from flask import Flask, request, jsonify
import mysql.connector

app = Flask(__name__)
# helps Flask

db = mysql.connector.connect(
    host="localhost",
    user="root",      
    password="DefinitelyNotAMerunka", 
    database="pocketdreams"
)

cursor = db.cursor()

# main page idk
@app.route("/")
def index():
    return"<h1>Main page</h1>"

@app.route("/register", methods=["POST"])
def register():
    data = request.json
    username = data.get("username")
    password = data.get("password")

    try:
        cursor.execute("INSERT INTO users (username, password) VALUES (%s, %s)", (username, password))
        db.commit()
        return jsonify({"message": "User registered successfully!"}), 201
    except mysql.connector.Error as err:
        return jsonify({"error": str(err)}), 400

if __name__ == "__main__":
    app.run(debug=True)
