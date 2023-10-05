import json


def get_db(db_name):
    with open(f"{db_name}/{db_name}.json", "r") as f:
        db_schema = json.load(f)
    return db_schema


academic = get_db("academic")
advising = get_db("advising")
atis = get_db("atis")
geography = get_db("geography")
restaurants = get_db("restaurants")
scholar = get_db("scholar")
yelp = get_db("yelp")
