from flask import Flask, request, jsonify
import sqlite3
import bcrypt

app = Flask(__name__)

conn = sqlite3.connect("pocketdreams.db") # connection to the databse
cursor = conn.cursor() # we need this one for our SQL commands


#cursor.execute("DROP TABLE IF EXISTS Tags;")
cursor.execute("DROP TABLE IF EXISTS Users;")
#cursor.execute("DROP TABLE IF EXISTS Dreams;")
#cursor.execute("DROP TABLE IF EXISTS Likes;")
#cursor.execute("DROP TABLE IF EXISTS Emotions;")
#cursor.execute("DROP TABLE IF EXISTS Comments;")
#cursor.execute("DROP TABLE IF EXISTS Reports;")
#cursor.execute("DROP TABLE IF EXISTS Friendship;")
#cursor.execute("DROP TABLE IF EXISTS DreamReports;")
#cursor.execute("DROP TABLE IF EXISTS DreamTags;")
#cursor.execute("DROP TABLE IF EXISTS DreamEmotions;")
#cursor.execute("DROP TABLE IF EXISTS UserTags;")



cursor.execute("CREATE TABLE IF NOT EXISTS Tags (ID INTEGER PRIMARY KEY, Name TEXT)")
#cursor.execute("INSERT INTO Tags (Name) VALUES ('Nightmare'), ('Future'), ('Family'), ('Fantasy'), ('Unreal'), ('Love'), ('Traveling'), ('Nostalgia'),('Nature');")

cursor.execute("CREATE TABLE IF NOT EXISTS Users (ID INTEGER PRIMARY KEY, Username TEXT, HashPassword TEXT)")
cursor.execute("CREATE TABLE IF NOT EXISTS Emotions (ID INTEGER PRIMARY KEY, Name TEXT)")


cursor.execute("CREATE TABLE IF NOT EXISTS Dreams (ID INTEGER PRIMARY KEY, Name TEXT, Description TEXT, Date INTEGER, IsPrivate INTEGER, User INTEGER, FOREIGN KEY (User) REFERENCES Users(ID));")


cursor.execute("CREATE TABLE IF NOT EXISTS Comments (ID INTEGER PRIMARY KEY, CommentedText TEXT, CreatedAt INTEGER, CommentedBy INTEGER, CommentedDream INTEGER, FOREIGN KEY (CommentedBy) REFERENCES Users(ID), FOREIGN KEY (CommentedDream) REFERENCES Dreams(ID))")
cursor.execute("CREATE TABLE IF NOT EXISTS Reports (ID INTEGER PRIMARY KEY, Type TEXT, CreatedBy INTEGER, FOREIGN KEY (CreatedBy) REFERENCES Users(ID))")
cursor.execute("CREATE TABLE IF NOT EXISTS Likes (ID INTEGER PRIMARY KEY, LikedBy INTEGER, LikedDream INTEGER, FOREIGN KEY (LikedDream) REFERENCES Dreams(ID), FOREIGN KEY (LikedBy) REFERENCES Users(ID))")
cursor.execute("CREATE TABLE IF NOT EXISTS Friendship (ID INTEGER PRIMARY KEY, UserID INTEGER, FriendID INTEGER, FOREIGN KEY (UserID) REFERENCES Users(ID), FOREIGN KEY (FriendID) REFERENCES Users(ID))")


cursor.execute("CREATE TABLE IF NOT EXISTS DreamReports (DreamID INTEGER, ReportID INTEGER, FOREIGN KEY (DreamID) REFERENCES Dreams(ID), FOREIGN KEY (ReportID) REFERENCES Reports(ID));")
cursor.execute("CREATE TABLE IF NOT EXISTS DreamTags (DreamID INTEGER, TagID INTEGER, FOREIGN KEY (DreamID) REFERENCES Dreams(ID), FOREIGN KEY (TagID) REFERENCES Tags(ID));")
cursor.execute("CREATE TABLE IF NOT EXISTS DreamEmotions (DreamID INTEGER, EmotionID INTEGER, FOREIGN KEY (DreamID) REFERENCES Dreams(ID), FOREIGN KEY (EmotionID) REFERENCES Emotions(ID));")
cursor.execute("CREATE TABLE IF NOT EXISTS UserTags (UserID INTEGER, TagID INTEGER, FOREIGN KEY (UserID) REFERENCES Users(ID), FOREIGN KEY (TagID) REFERENCES Tags(ID));")






#making a table if it does not exist



conn.commit() # saving changes in our database
conn.close() # ending our connection



@app.route("/api/register", methods=["POST"])
def register():
    data = request.json
    Username = data.get("Username")
    password = data.get("password").encode("utf-8")

    # if a nick or a password is empty
    if not Username or not password:
        return jsonify({"success": False, "message": "Username and password required"}), 400

    hashPassword = bcrypt.hashpw(password, bcrypt.gensalt())

    conn = sqlite3.connect("pocketdreams.db")
    cursor = conn.cursor()

    # if user is alredy exist
    cursor.execute("SELECT ID FROM Users WHERE Username = ?", (Username,))
    if cursor.fetchone():
        conn.close()
        return jsonify({"success": False, "message": "User is already exist"}), 400

    # and now we can add a new user
    cursor.execute("INSERT INTO Users (Username, HashPassword) VALUES (?, ?)", (Username, hashPassword))
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

    
    conn.commit()
    conn.close()

    if row and row[0] == password:
        return jsonify({"success":True, "message": "Welcome back"})
    else:
        return jsonify({"success":False, "message": "Invalid login or password"}), 401

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
