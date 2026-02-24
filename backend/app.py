from flask import Flask, request, jsonify
import sqlite3
import bcrypt

app = Flask(__name__)

conn = sqlite3.connect("pocketdreams.db") # connection to the databse
cursor = conn.cursor() # we need this one for our SQL commands

# making from [(1,), (2,)] this [1,2]
def fetchallBuilder(result):
    return [row[0] for row in result]

#cursor.execute("DROP TABLE IF EXISTS Tags;")
#cursor.execute("DROP TABLE IF EXISTS Users;")
#cursor.execute("DROP TABLE IF EXISTS Dreams;")
#cursor.execute("DROP TABLE IF EXISTS Likes;")
#cursor.execute("DROP TABLE IF EXISTS Emotions;")
#cursor.execute("DROP TABLE IF EXISTS Comments;")
#cursor.execute("DROP TABLE IF EXISTS Reports;")
#cursor.execute("DROP TABLE IF EXISTS Friendships;")
#cursor.execute("DROP TABLE IF EXISTS DreamReports;")
#cursor.execute("DROP TABLE IF EXISTS DreamTags;")
#cursor.execute("DROP TABLE IF EXISTS DreamEmotions;")
#cursor.execute("DROP TABLE IF EXISTS UserTags;")



#cursor.execute("CREATE TABLE IF NOT EXISTS Tags (ID INTEGER PRIMARY KEY, Name TEXT)")
#cursor.execute("INSERT INTO Tags (Name) VALUES ('Nightmare'), ('Future'), ('Family'), ('Fantasy'), ('Unreal'), ('Love'), ('Traveling'), ('Nostalgia'),('Nature');")

#cursor.execute("CREATE TABLE IF NOT EXISTS Users (ID INTEGER PRIMARY KEY, Username TEXT, HashPassword TEXT)")
#cursor.execute("CREATE TABLE IF NOT EXISTS Emotions (ID INTEGER PRIMARY KEY, Name TEXT)")
#cursor.execute("INSERT INTO Emotions (Name) VALUES ('Happiness'), ('Love'), ('Calm'), ('Harmony'), ('Freedom'), ('Creativity'), ('Purity'), ('Depth'),('Warmth'),('Fear'), ('Sadness'), ('Anger'), ('Shame') ;")


#cursor.execute("CREATE TABLE IF NOT EXISTS Dreams (ID INTEGER PRIMARY KEY, Name TEXT, Description TEXT, Date INTEGER, IsPrivate INTEGER, PublicationDate INTEGER, User INTEGER, FOREIGN KEY (User) REFERENCES Users(ID));")


#cursor.execute("CREATE TABLE IF NOT EXISTS Comments (ID INTEGER PRIMARY KEY, CommentedText TEXT, CreatedAt INTEGER, CommentedBy INTEGER, CommentedDream INTEGER, FOREIGN KEY (CommentedBy) REFERENCES Users(ID), FOREIGN KEY (CommentedDream) REFERENCES Dreams(ID))")
#cursor.execute("CREATE TABLE IF NOT EXISTS Reports (ID INTEGER PRIMARY KEY, Type TEXT, CreatedBy INTEGER, FOREIGN KEY (CreatedBy) REFERENCES Users(ID))")
#cursor.execute("CREATE TABLE IF NOT EXISTS Likes ( LikedBy INTEGER, LikedDream INTEGER, FOREIGN KEY (LikedDream) REFERENCES Dreams(ID), FOREIGN KEY (LikedBy) REFERENCES Users(ID))")
#cursor.execute("CREATE TABLE IF NOT EXISTS Friendships (UserID INTEGER, FriendID INTEGER, FOREIGN KEY (UserID) REFERENCES Users(ID), FOREIGN KEY (FriendID) REFERENCES Users(ID))")


#cursor.execute("CREATE TABLE IF NOT EXISTS DreamReports (DreamID INTEGER, ReportID INTEGER, FOREIGN KEY (DreamID) REFERENCES Dreams(ID), FOREIGN KEY (ReportID) REFERENCES Reports(ID));")
#cursor.execute("CREATE TABLE IF NOT EXISTS DreamTags (DreamID INTEGER, TagID INTEGER, FOREIGN KEY (DreamID) REFERENCES Dreams(ID), FOREIGN KEY (TagID) REFERENCES Tags(ID));")
#cursor.execute("CREATE TABLE IF NOT EXISTS DreamEmotions (DreamID INTEGER, EmotionID INTEGER, FOREIGN KEY (DreamID) REFERENCES Dreams(ID), FOREIGN KEY (EmotionID) REFERENCES Emotions(ID));")
#cursor.execute("CREATE TABLE IF NOT EXISTS UserTags (UserID INTEGER, TagID INTEGER, FOREIGN KEY (UserID) REFERENCES Users(ID), FOREIGN KEY (TagID) REFERENCES Tags(ID));")


#making a table if it does not exist



conn.commit() # saving changes in our database
conn.close() # ending our connection


# Register function
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


# Login function
@app.route("/api/login", methods=["POST"])
def login():
    data = request.json
    Username = data.get("Username")
    Password = data.get("Password")

    conn = sqlite3.connect("pocketdreams.db")
    cursor = conn.cursor()

    # "nickname = ?", (nickname) 
    # means that nickname would change on (nickname) and ? is just a placeholder

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

# Tag Screen Function
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

# function for adding our dream to the database
@app.route("/api/addDream", methods=["POST"])
def addDream():
    #here we have all variables what we would upload to our database 
    data = request.json
    DreamName = data.get("Name")
    Description = data.get("Description")
    Date = data.get("Date")
    IsPrivate = data.get("IsPrivate")
    Tags = data.get("Tags") or []
    User = data.get("User")
    PublicationDate = data.get("PublicationDate")
    Emotions = data.get("Emotions") or []

    conn = sqlite3.connect("pocketdreams.db")
    cursor = conn.cursor()
    
    # now we know users id
    cursor.execute("SELECT ID FROM Users WHERE Username = ?", (User,))
    user_result = cursor.fetchone()
    if not user_result:
        conn.close()
        return jsonify({"seccuess": False, "message": "User not found"}),404
    UserID = user_result[0]

    cursor.execute("SELECT ID FROM Dreams WHERE Date = ? AND User = ?",(Date,UserID,))
    # checking if we already had a dream for this day
    if cursor.fetchall():   
        conn.commit()
        conn.close()
        return jsonify({"success": False, "message": "You had already wrote a dream for this day"}), 403 
    
    # checking if we already had a dream with this name
    cursor.execute("SELECT ID FROM Dreams WHERE Name = ? AND User = ?",(DreamName, UserID,))
    print(cursor.fetchall())
    if cursor.fetchall():   
        conn.commit()
        conn.close()
        return jsonify({"success": False, "message": "You had already wrote a dream with this name"}), 403 
    
    # now we can add a dream
    cursor.execute("INSERT INTO Dreams (Name, Description, Date, IsPrivate, PublicationDate, User) VALUES (?, ?, ?, ?, ?, ?)", (DreamName, Description,Date,IsPrivate,PublicationDate,UserID))
    cursor.execute("SELECT ID FROM Dreams WHERE Name = ?", (DreamName,))
    dreamID = cursor.fetchone()[0]
    for i in range(len(Tags)):
        cursor.execute("SELECT ID FROM Tags WHERE Name = ?", (Tags[i],))
        tagID = cursor.fetchone()[0]
        cursor.execute("INSERT INTO DreamTags (DreamID, TagID) VALUES (?,?)", (dreamID,tagID))
    for e in range(len(Emotions)):
        cursor.execute("SELECT ID FROM Emotions WHERE Name = ?", (Emotions[e],))
        emotionID = cursor.fetchone()[0]
        cursor.execute("INSERT INTO DreamEmotions (DreamID, EmotionID) VALUES (?,?)", (dreamID,emotionID))
    conn.commit()
    conn.close()

    return jsonify({"success": True, "message": "Your dream was added"})

# function for getting our dreams from the database to the frontend when we are opening calendar 
@app.route("/api/askAboutDreams", methods=["GET"])
def askAboutDreams():
    Username = request.args.get("username")

    conn = sqlite3.connect("pocketdreams.db")
    cursor = conn.cursor()

    # now we have a user id
    cursor.execute("SELECT ID FROM Users WHERE Username = ?", (Username,))
    UserID = cursor.fetchone()[0]

    # now we have an id of ours users dreams
    cursor.execute("SELECT ID FROM Dreams WHERE User = ?", (UserID,))
    UserDreamsID = cursor.fetchall()

    # all id list
    allId = [d[0] for d in UserDreamsID]  
    # now we have a ? foe eatch id in allId
    placeholders = ','.join(['?'] * len(allId)) 
    cursor.execute(f"SELECT Name, Description, Date, IsPrivate, PublicationDate FROM Dreams WHERE ID IN ({placeholders})", allId)
    dreamsList = cursor.fetchall()

    dreamsListJSON = []
    for i,dream in enumerate(dreamsList):
        dreamID = UserDreamsID[i][0]

        Tags = []
        Emotions = []

        cursor.execute("SELECT TagID FROM DreamTags WHERE DreamID = ?", (dreamID,))
        dreamTags = cursor.fetchall()

        cursor.execute("SELECT EmotionID FROM DreamEmotions WHERE DreamID = ?", (dreamID,))
        dreamEmotions = cursor.fetchall()

        for tag in dreamTags:
            cursor.execute("SELECT Name FROM Tags WHERE ID = ?", (tag[0],))
            Tags.append(cursor.fetchone()[0])

        for emotion in dreamEmotions:
            cursor.execute("SELECT Name FROM Emotions WHERE ID = ?", (emotion[0],))
            Emotions.append(cursor.fetchone()[0])
        
        cursor.execute("SELECT COUNT(LikedBy) FROM Likes WHERE LikedDream = ?", (dreamID,))
        Likes = cursor.fetchone()[0]
        
        dreamsListJSON.append({
            "ID": dreamID,
            "Name": dream[0],
            "Description": dream[1],
            "Date": dream[2],
            "IsPrivate": dream[3],
            "PublicationDate": dream[4],
            "User": Username,
            "Tags": Tags,
            "Emotions": Emotions,
            "Likes": Likes
            })
    
    return jsonify({"success": True, "dreamsList": dreamsListJSON, "message": "You are here"})  

# deleting a dream from database
@app.route("/api/deleteThisDream", methods=["DELETE"])
def deleteThisDream():
    dreamID = request.args.get("dream")

    conn = sqlite3.connect("pocketdreams.db")
    cursor = conn.cursor()
    
    cursor.execute("DELETE FROM DreamEmotions WHERE DreamID = ?", (dreamID,))
    cursor.execute("DELETE FROM DreamTags WHERE DreamID = ?", (dreamID,))
    cursor.execute("DELETE FROM Reports WHERE ID = ?", (dreamID,))
    cursor.execute("DELETE FROM Dreams WHERE ID = ?", (dreamID,))

    conn.commit()
    conn.close()


    return jsonify({"success": True, "message": "Dream was deleted successfully"})  


# saving our changes that user made in the database
@app.route("/api/saveTheChanges", methods=["PUT"])
def saveTheChanges():
    data = request.get_json()

    dream_id = data["id"]
    name = data["name"]
    description = data["description"]
    is_private = data["isPrivate"]
    date = data["date"]

    emotions = data["emotions"]
    tags = data["tags"]

    conn = sqlite3.connect("pocketdreams.db")
    cursor = conn.cursor()

    cursor.execute("UPDATE Dreams SET Name = ?, Description = ?, IsPrivate = ?, Date = ? WHERE ID = ? ", (name, description, is_private, date, dream_id))
    cursor.execute("DELETE FROM DreamEmotions WHERE DreamID = ?",(dream_id,))
    for emotion in emotions:
        cursor.execute("SELECT ID FROM Emotions WHERE Name = ?", (emotion,))
        emotionid = cursor.fetchall()[0][0]
        cursor.execute("INSERT INTO DreamEmotions (DreamID, EmotionID) VALUES (?, ?)",(dream_id, emotionid,))
    cursor.execute("DELETE FROM DreamTags WHERE DreamID = ?",(dream_id,))
    for tag in tags:
        cursor.execute("SELECT ID FROM Tags WHERE Name = ?", (tag,))
        tagid = cursor.fetchall()[0][0]
        cursor.execute("INSERT INTO DreamTags (DreamID, TagID) VALUES (?, ?)",(dream_id, tagid,))

    conn.commit()
    conn.close()

    return jsonify({
        "success": True,
        "message": "Dream was edited successfully"
    })

#
# function that get dreams from backend by chosen tags by user
# dream is id, name, description, date, publication date, emotions, tags, owner, likes and we had given a like 
#
@app.route("/api/getBackendDreams", methods=["GET"])
def getBackendDreams():
    Username = request.args.get("username")
    Option = request.args.get("chooseOption")
    if (not Username or not Option):
        return jsonify({
        "success": False,
        "message": "Wrong Data",
    }), 400

    conn = sqlite3.connect("pocketdreams.db")
    cursor = conn.cursor()

    print(Option)
            # userID
    cursor.execute("SELECT ID FROM Users WHERE Username = ?",(Username,))
    UserId = cursor.fetchone()[0]


    if (Option == "userTags"):

        Limit = 2
        Offset = 2

        # list of tags 
        cursor.execute("SELECT TagID FROM UserTags WHERE UserID = (SELECT ID FROM Users WHERE Username = ?)",(Username,))

        # We need dreams id, name, description, date, publication date, all emotions, all tags, owner username, count of likes, count of our likes   
        cursor.execute("""
        SELECT 
        d.ID, d.Name, d.Description, d.Date, d.PublicationDate, 
        (SELECT GROUP_CONCAT(DISTINCT EmotionID) FROM DreamEmotions WHERE DreamID = d.ID) as EmotionIDs, 
        (SELECT GROUP_CONCAT(DISTINCT TagID) FROM DreamTags WHERE DreamID = d.ID) as TagIDs, 
        u.Username,
        (SELECT COUNT(*) FROM Likes WHERE LikedDream = d.ID) as TotalLikes,
        (SELECT COUNT(*) FROM Likes WHERE LikedDream = d.ID AND LikedBy = ?)
        FROM Dreams d
        JOIN Users u ON u.ID = d.User
        JOIN UserTags ut ON ut.UserID = ?
        JOIN DreamTags dt ON dt.DreamID = d.ID
        WHERE dt.TagID = ut.tagID AND d.User != ? AND d.IsPrivate = 0
        GROUP BY d.ID
        """, (UserId, UserId, UserId,))

        #LIMIT ? OFFSET ?
        #, Limit, Offset

        dreams = cursor.fetchall()

        
        print(dreams)

        cursor.execute("""
        SELECT t.Name
        FROM UserTags ut
        JOIN Tags t ON t.ID = ut.TagID 
        WHERE ut.UserID = (SELECT ID FROM Users WHERE Username = ?)
        """, (Username,))

        userTags = cursor.fetchall()

        conn.close()

        return jsonify({
            "success": True,
            "message": "You got dreams succesfully",
            "dreamsList": dreams,
            "userTags": userTags 
        })
    
    if (Option == "userLikes"):
        cursor.execute("""
        SELECT 
        d.ID, d.Name, d.Description, d.Date, d.PublicationDate, 
        (SELECT GROUP_CONCAT(EmotionID) FROM DreamEmotions WHERE DreamID = d.ID) as EmotionIDs,
        (SELECT GROUP_CONCAT(TagID) FROM DreamTags WHERE DreamID = d.ID) as TagIDs,
        (SELECT Username FROM Users WHERE ID = d.User) as AuthorName,
        (SELECT COUNT(*) FROM Likes WHERE LikedDream = d.ID) as TotalLikes,
        1 as IsLikedByMe
        FROM Dreams d
        WHERE d.ID IN (SELECT LikedDream FROM Likes WHERE LikedBy = ?)
        """, (UserId,))
        
        dreams = cursor.fetchall()
        conn.close()

        print(dreams)

        return jsonify({
            "success": True,
            "message": "You got dreams succesfully",
            "dreamsList": dreams,
        })

    if (Option == "userFriends"):
        cursor.execute("""
        SELECT 
        d.ID, d.Name, d.Description, d.Date, d.PublicationDate, 
        (SELECT GROUP_CONCAT(DISTINCT EmotionID) FROM DreamEmotions WHERE DreamID = d.ID) as EmotionIDs, 
        (SELECT GROUP_CONCAT(DISTINCT TagID) FROM DreamTags WHERE DreamID = d.ID) as TagIDs, 
        (SELECT Username FROM Users WHERE ID = d.user),
        (SELECT COUNT(LikedBy) FROM Likes WHERE LikedDream = d.ID),
        (SELECT COUNT(LikedBy) FROM Likes WHERE LikedDream = d.ID AND LikedBy = ?)
        FROM Dreams d
        WHERE d.User IN (SELECT FriendID FROM Friendships WHERE UserID = ?) 
        AND d.IsPrivate = 0
        GROUP BY d.ID
        """, (UserId, UserId,))


        dreams = cursor.fetchall()
        conn.close()
        
        print(dreams)
        
        return jsonify({
            "success": True,
            "message": "You got dreams succesfully",
            "dreamsList": dreams,
        })  
       
    return jsonify({
        "success": False,
        "message": "Wrong Data",
    }), 400

# function for liking
@app.route("/api/changeBackendLikeStatus", methods=["GET"])
def changeBackendLikeStatus():
    conn = sqlite3.connect("pocketdreams.db")
    cursor = conn.cursor()

    Username = request.args.get("username")
    DreamID = request.args.get("dream")
    if not Username or not DreamID:
        conn.close()
        return jsonify({"success": False, "error": "Missing parameters"}), 400

    print(Username)
    cursor.execute("SELECT 1 FROM Likes WHERE LikedBy = (SELECT ID FROM Users WHERE Username = ?) AND LikedDream = ?",(Username, DreamID,))
    
    if (not cursor.fetchone()):
        cursor.execute("""
    INSERT INTO Likes (LikedBy, LikedDream) 
    VALUES ((SELECT ID FROM Users WHERE Username = ?), ?)
    """, (Username, DreamID,))
        conn.commit()
        conn.close()
        return jsonify({
        "success": True,
        "message": "Like status had changed",
        "likeStatus": "created"
    })
    else:
        cursor.execute("""
                        DELETE FROM Likes 
                        WHERE LikedBy = (SELECT ID FROM Users WHERE Username = ?)
                        AND LikedDream = ?
        """, (Username, DreamID))
        conn.commit()
        conn.close()
        return jsonify({
        "success": True,
        "message": "Like status had changed",
        "likeStatus": "deleted",
    })  

# sending to the front end all comments what we have (if we have something)
@app.route("/api/getComments")
def getComments():
    DreamID = request.args.get("dream")
    if not DreamID:
        return jsonify({
            "success": False,
            "message": "Dream does not exist",
        }), 400

    conn = sqlite3.connect("pocketdreams.db")
    cursor = conn.cursor()

    cursor.execute("""
        SELECT 
            c.ID,
            c.CommentedText, 
            c.CreatedAt, 
            u.Username,
            c.CommentedDream
        FROM Comments c
        JOIN Users u ON u.ID = c.CommentedBy
        WHERE c.CommentedDream = ?
    """, (DreamID,))

    rows = cursor.fetchall()

    if not rows:
        conn.close()
        return jsonify({
            "success": True,
            "message": "This dream has no comments yet",
            "noComments": True,
            "comments": [],
        })

    # for every comment
    comments = [
        {
            "CommentID": c[0],
            "Description": c[1],
            "Date": c[2],
            "CommentedBy": c[3],
            "DreamID": c[4]
        }
        for c in rows
    ]

    conn.close()
    return jsonify({
        "success": True,
        "message": "Here you have your comments",
        "noComments": False,
        "comments": comments,
    })


# function for adding our comments
@app.route("/api/sendYourComment", methods=["POST"])
def sendYourComment():
    data = request.json
    comment = data.get("comment")
    user = data.get("user")
    dreamID = data.get("dreamID")
    date = data.get("date")

    if (not comment or not user or not dreamID or not date):
        return jsonify({
        "success": False,
        "message": "Wrong data",
    }), 400

    conn = sqlite3.connect("pocketdreams.db")
    cursor = conn.cursor()

    cursor.execute("""INSERT INTO Comments 
                   (CommentedText, 
                   CreatedAt, 
                   CommentedBy, 
                   CommentedDream) 
                   VALUES 
                   (?,
                   ?,
                   (SELECT ID FROM Users WHERE Username = ?),
                   ?)
                   """, (comment,date,user,dreamID))

    conn.commit()
    conn.close()

    return jsonify({
        "success": True,
        "message": "Your comment was added",
    })

# function that returns a array of users that liked dream with this id
@app.route("/api/getDreamLikesOwners")
def getDreamLikesOwners():
    id = request.args.get("dreamId")
    if (not id):
        conn.close()
        return jsonify({
        "success": False,
        "message": "Wrong Data",
    }), 400

    conn = sqlite3.connect("pocketdreams.db")
    cursor = conn.cursor()

    cursor.execute("""
        SELECT l.LikedBy,
                u.Username
        FROM Likes l 
        JOIN Users u 
                ON u.ID = l.LikedBy 
        WHERE LikedDream = ?
    """, (id,))
    
    userList = []
    for user in cursor.fetchall():
        userList.append({"id": user[0], "username": user[1]}) 
    
    conn.close()
    return jsonify({
        "success": True,
        "message": "Here are users that gived you a like",
        "likeOwners": userList
    })

# getting information is user A and user B are friends
# return true or false
@app.route("/api/isHeMyFriend")
def isHeMyFriend():
    userA = request.args.get("myName")
    userB = request.args.get("protentialFriend")
    if (not userA or not userB):
        return jsonify({
        "success": False,
        "message": "Wrong Data",
    }), 400

    conn = sqlite3.connect("pocketdreams.db")
    cursor = conn.cursor()

    cursor.execute("SELECT ID FROM Users WHERE Username = ?",(userA,))
    userA = cursor.fetchone()[0]

    cursor.execute("SELECT ID FROM Users WHERE Username = ?",(userB,))
    userB = cursor.fetchone()[0]

    cursor.execute("""SELECT 1 
                   FROM Friendships 
                   WHERE 
                   (UserID = ? AND FriendID = ?) 
                   OR (UserID = ? AND FriendID = ?) 
                   LIMIT 1
                   """, (userA,userB,userB,userA))
    
    # if friendship exists
    if (cursor.fetchone() != None):
        conn.close()
        return jsonify({
            "success": True,
            "message": "Now you know this friendship status",
            "friendship": True
        })
    conn.close()
    # if friendship is not exists yet
    return jsonify({
            "success": True,
            "message": "Now you know this friendship status",
            "friendship": False
        })

# changing friendship status
# if userA and userB are now friends we adding their friendship into the database
# if they already are friends we end their friendship by deleting it from the database
@app.route("/api/changeFriendshipStatus", methods=["POST", "DELETE"])
def changeFriendshipStatus():
    data = request.json
    userA = data.get("user")
    userB = data.get("friend")
    if (not userA or not userB):
        return jsonify({
        "success": False,
        "message": "Wrong Data",
    }), 400

    conn = sqlite3.connect("pocketdreams.db")
    cursor = conn.cursor()

    cursor.execute("SELECT ID FROM Users Where Username = ?",(userA,))
    userA = cursor.fetchone()[0]

    cursor.execute("SELECT ID FROM Users Where Username = ?",(userB,))
    userB = cursor.fetchone()[0]

    cursor.execute("""SELECT 1 
                   FROM Friendships 
                   WHERE 
                   (UserID = ? AND FriendID = ?) 
                   OR (UserID = ? AND FriendID = ?) 
                   LIMIT 1
                   """, (userA,userB,userB,userA))

    # if friendship exists
    if (cursor.fetchone() != None):
        cursor.execute("""DELETE 
                       FROM Friendships 
                       WHERE (UserID = ? AND FriendID = ?) 
                       OR (UserID = ? AND FriendID = ?)
                """, (userA,userB,userB,userA))
        conn.commit()
        conn.close()
        return jsonify({
            "success": True,
            "message": "Friendship was ended",
        })
    cursor.execute("""INSERT 
                   INTO Friendships 
                   (UserID, FriendID) 
                   VALUES (?,?)
    """, (userA,userB,))

    conn.commit()
    conn.close()
    # if friendship is not exists yet
    return jsonify({
            "success": True,
            "message": "User has new friend now",
        })

# deleting comment from the database by his id
@app.route("/api/deleteComment", methods=["DELETE"])
def deleteComment():
    data = request.json
    ID = data["comment"]

    if (not ID):
        return jsonify({
        "success": False,
        "message": "Wrong Data",
    }), 400

    conn = sqlite3.connect("pocketdreams.db")
    cursor = conn.cursor()
    
    cursor.execute("DELETE FROM Comments Where ID = ?",(ID,))

    conn.commit()
    conn.close()

    return jsonify({
            "success": True,
            "message": "User has new friend now",
        })

# deleting comment from the database by his id
@app.route("/api/getFriendsList")
def getFriendsList():
    username = request.args.get("user")
    if (not username):
        return jsonify({
        "success": False,
        "message": "Wrong Data",
    }), 400

    conn = sqlite3.connect("pocketdreams.db")
    cursor = conn.cursor()
    
    cursor.execute("SELECT ID FROM Users WHERE Username = ?",(username,))
    userID = cursor.fetchone()[0]

    cursor.execute("""
    SELECT u.Username
    FROM Users u
    JOIN Friendships f 
        ON (f.UserID = ? AND f.FriendID = u.ID)
        OR (f.FriendID = ? AND f.UserID = u.ID)
    """, (userID, userID))
    result = cursor.fetchall()
    conn.close()

    friendsMap = fetchallBuilder(result)

    return jsonify({
            "success": True,
            "message": "Here you have friends of this user",
            "friendsMap": friendsMap
        })


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
