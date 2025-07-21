from flask import Flask, request, jsonify

app = Flask(__name__)

@app.route('/api/data', methods=['GET'])
def get_data():
    data = {"message":"backend"}
    return jsonify(data)

if __name__ == '__main__':
    app.run(debug=True)
