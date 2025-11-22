from flask import Flask, request, jsonify
import sqlite3
import bcrypt

app = Flask(__name__)

conn = sqlite3.connect("pocketdreams.db") # connection to the databse
cursor = conn.cursor() # we need this one for our SQL commands


#cursor.execute("DROP TABLE IF EXISTS Tags;")
#cursor.execute("DROP TABLE IF EXISTS Users;")
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



#cursor.execute("CREATE TABLE IF NOT EXISTS Tags (ID INTEGER PRIMARY KEY, Name TEXT)")
#cursor.execute("INSERT INTO Tags (Name) VALUES ('Nightmare'), ('Future'), ('Family'), ('Fantasy'), ('Unreal'), ('Love'), ('Traveling'), ('Nostalgia'),('Nature');")

#cursor.execute("CREATE TABLE IF NOT EXISTS Users (ID INTEGER PRIMARY KEY, Username TEXT, HashPassword TEXT)")
#cursor.execute("CREATE TABLE IF NOT EXISTS Emotions (ID INTEGER PRIMARY KEY, Name TEXT)")


#cursor.execute("CREATE TABLE IF NOT EXISTS Dreams (ID INTEGER PRIMARY KEY, Name TEXT, Description TEXT, Date INTEGER, IsPrivate INTEGER, User INTEGER, FOREIGN KEY (User) REFERENCES Users(ID));")


#cursor.execute("CREATE TABLE IF NOT EXISTS Comments (ID INTEGER PRIMARY KEY, CommentedText TEXT, CreatedAt INTEGER, CommentedBy INTEGER, CommentedDream INTEGER, FOREIGN KEY (CommentedBy) REFERENCES Users(ID), FOREIGN KEY (CommentedDream) REFERENCES Dreams(ID))")
#cursor.execute("CREATE TABLE IF NOT EXISTS Reports (ID INTEGER PRIMARY KEY, Type TEXT, CreatedBy INTEGER, FOREIGN KEY (CreatedBy) REFERENCES Users(ID))")
#cursor.execute("CREATE TABLE IF NOT EXISTS Likes (ID INTEGER PRIMARY KEY, LikedBy INTEGER, LikedDream INTEGER, FOREIGN KEY (LikedDream) REFERENCES Dreams(ID), FOREIGN KEY (LikedBy) REFERENCES Users(ID))")
#cursor.execute("CREATE TABLE IF NOT EXISTS Friendship (ID INTEGER PRIMARY KEY, UserID INTEGER, FriendID INTEGER, FOREIGN KEY (UserID) REFERENCES Users(ID), FOREIGN KEY (FriendID) REFERENCES Users(ID))")


#cursor.execute("CREATE TABLE IF NOT EXISTS DreamReports (DreamID INTEGER, ReportID INTEGER, FOREIGN KEY (DreamID) REFERENCES Dreams(ID), FOREIGN KEY (ReportID) REFERENCES Reports(ID));")
#cursor.execute("CREATE TABLE IF NOT EXISTS DreamTags (DreamID INTEGER, TagID INTEGER, FOREIGN KEY (DreamID) REFERENCES Dreams(ID), FOREIGN KEY (TagID) REFERENCES Tags(ID));")
#cursor.execute("CREATE TABLE IF NOT EXISTS DreamEmotions (DreamID INTEGER, EmotionID INTEGER, FOREIGN KEY (DreamID) REFERENCES Dreams(ID), FOREIGN KEY (EmotionID) REFERENCES Emotions(ID));")
#cursor.execute("CREATE TABLE IF NOT EXISTS UserTags (UserID INTEGER, TagID INTEGER, FOREIGN KEY (UserID) REFERENCES Users(ID), FOREIGN KEY (TagID) REFERENCES Tags(ID));")






#making a table if it does not exist



conn.commit() # saving changes in our database
conn.close() # ending our connection



@app.route("/api/register", methods=["POST"])
def register():
    data = request.json
    Username = data.get("Username")
    Password = data.get("Password")

    # if a nick or a password is empty
    if not Username and not Password:
        return jsonify({"success": False, "message": "A username and a password are required"}), 400
    elif not Username:
        return jsonify({"success": False, "message": "A username is required"}), 400
    elif not Password:
        return jsonify({"success": False, "message": "A password is required"}), 400


    hashPassword = bcrypt.hashpw(Password.encode("utf-8"), bcrypt.gensalt()).decode("utf-8")

    conn = sqlite3.connect("pocketdreams.db")
    cursor = conn.cursor()

    # if user is alredy exist
    cursor.execute("SELECT ID FROM Users WHERE Username = ?", (Username,))
    if cursor.fetchone():
        conn.close()
        return jsonify({"success": False, "message": "The username is alredy taken"}), 400

    # and now we can add a new user
    cursor.execute("INSERT INTO Users (Username, HashPassword) VALUES (?, ?)", (Username, hashPassword))
    conn.commit()
    conn.close()

    return jsonify({"success": True, "message": "The user has been registered"}), 200



@app.route("/api/login", methods=["POST"])
def login():
    data = request.json
    Username = data.get("Username")
    Password = data.get("Password")

    conn = sqlite3.connect("pocketdreams.db")
    cursor = conn.cursor()

    # "nickname = ?", (nickname) 
    # means that nickname would change on (nickname) and ? is just placeholder

    cursor.execute("SELECT HashPassword FROM Users WHERE Username = ?", (Username,))

    # fetchone means chose first in our cursor or return None 
    result = cursor.fetchone()
    conn.close()

    if not result:
        return jsonify({"success": False, "message": "User not found"}), 400

    stored_hash = result[0].encode("utf-8")

    if bcrypt.checkpw(Password.encode("utf-8"), stored_hash):
        return jsonify({"success": True, "message": "Login successful"})
    else:
        return jsonify({"success": False, "message": "Invalid password"}), 401


@app.route("/api/chooseTags", methods=["POST", "DELETE"])
def chooseTags():
    data = request.json
    Username = data.get("Username")
    Tags = data.get("Tags")

    conn = sqlite3.connect("pocketdreams.db")
    cursor = conn.cursor()
    
    # now we know users id
    cursor.execute("SELECT ID FROM Users WHERE Username = ?", (Username,))
    resultUser = cursor.fetchone()
    UserID = resultUser[0]

    # clearing the UserTags table 
    cursor.execute("DELETE FROM UserTags WHERE UserID = ?", (UserID,))

    # adding a all tags ID to the same user ID in the UserTags
    for i in range(len(Tags)):
        cursor.execute("SELECT ID FROM Tags WHERE Name = ?", (Tags[i],))
        resultTag = cursor.fetchone()
        TagID = resultTag[0]
        cursor.execute("INSERT INTO UserTags (UserID, TagID) VALUES (?, ?)", (UserID, TagID))
    
    conn.commit()
    conn.close()

    return jsonify({"success": True, "message": "Confirmed"})


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
