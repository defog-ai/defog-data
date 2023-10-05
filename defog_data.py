import json
import os

def get_db(db_name):
    script_dir = os.path.dirname(os.path.abspath(__file__))
    file_path = os.path.join(script_dir, f"{db_name}/{db_name}.json")
    with open(file_path, "r") as f:

        db_schema = json.load(f)
    return db_schema


academic = get_db("academic")
advising = get_db("advising")
atis = get_db("atis")
geography = get_db("geography")
restaurants = get_db("restaurants")
scholar = get_db("scholar")
yelp = get_db("yelp")

dbs = {
    "academic": academic,
    "advising": advising,
    "atis": atis,
    "geography": geography,
    "restaurants": restaurants,
    "scholar": scholar,
    "yelp": yelp
}