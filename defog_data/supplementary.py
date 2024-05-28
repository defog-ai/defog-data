from defog_data.metadata import dbs
import logging
import os
import pickle
from sentence_transformers import SentenceTransformer
import re

# get package root directory
root_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))


def generate_embeddings(emb_path: str, save_emb: bool = True) -> tuple[dict, dict]:
    """
    For each db, generate embeddings for all of the column names and descriptions
    """
    encoder = SentenceTransformer(
        "sentence-transformers/all-MiniLM-L6-v2", device="cpu"
    )
    emb = {}
    csv_descriptions = {}
    glossary_emb = {}
    for db_name, db in dbs.items():
        metadata = db["table_metadata"]
        glossary = clean_glossary(db["glossary"])
        column_descriptions = []
        column_descriptions_typed = []
        for table in metadata:
            for column in metadata[table]:
                col_str = (
                    table
                    + "."
                    + column["column_name"]
                    + ": "
                    + column["column_description"]
                )
                col_str_typed = (
                    table
                    + "."
                    + column["column_name"]
                    + ","
                    + column["data_type"]
                    + ","
                    + column["column_description"]
                )
                column_descriptions.append(col_str)
                column_descriptions_typed.append(col_str_typed)
        column_emb = encoder.encode(column_descriptions, convert_to_tensor=True)
        emb[db_name] = column_emb
        csv_descriptions[db_name] = column_descriptions_typed
        logging.info(f"Finished embedding {db_name} {len(column_descriptions)} columns")
        if len(glossary) > 0:
            glossary_embeddings = encoder.encode(glossary, convert_to_tensor=True)
        else:
            glossary_embeddings = []
        glossary_emb[db_name] = glossary_embeddings
    if save_emb:
        # get directory of emb_path and create if it doesn't exist
        emb_dir = os.path.dirname(emb_path)
        if not os.path.exists(emb_dir):
            os.makedirs(emb_dir)
        with open(emb_path, "wb") as f:
            pickle.dump((emb, csv_descriptions, glossary_emb), f)
            logging.info(f"Saved embeddings to file {emb_path}")
    return emb, csv_descriptions, glossary_emb


def clean_glossary(glossary: str) -> list[str]:
    """
    Clean glossary by removing number bullets and periods, and making sure every line starts with a dash bullet.
    """
    if glossary == "":
        return []
    glossary = glossary.split("\n")
    # remove empty strings
    glossary = list(filter(None, glossary))
    cleaned = []
    for line in glossary:
        # remove number bullets and periods
        line = re.sub(r"^\d+\.?\s?", "", line)
        # make sure every line starts with a dash bullet if it does not already
        line = re.sub(r"^(?!-)", "- ", line)
        cleaned.append(line)
    glossary = cleaned
    return glossary


def load_embeddings(emb_path: str) -> tuple[dict, dict]:
    """
    Load embeddings from file if they exist, otherwise generate them and save them.
    """
    if os.path.isfile(emb_path):
        logging.info(f"Loading embeddings from file {emb_path}")
        with open(emb_path, "rb") as f:
            emb, csv_descriptions, glossary_emb = pickle.load(f)
        return emb, csv_descriptions, glossary_emb
    else:
        logging.info(f"Embeddings file {emb_path} does not exist.")
        emb, csv_descriptions, glossary_emb = generate_embeddings(emb_path)
        return emb, csv_descriptions, glossary_emb


# entity types: list of (column, type, description) tuples
# note that these are spacy types https://spacy.io/usage/linguistic-features#named-entities
# we can add more types if we want, but PERSON, GPE, ORG should be
# sufficient for most use cases.
# also note that DATE and TIME are not included because they are usually
# retrievable from the top k embedding search due to the limited list of nouns
columns_ner = {
    "academic": {
        "PERSON": [
            "author.name,text,Name of the author",
        ],
        "ORG": [
            "conference.name,text,The name of the conference",
            "journal.name,text,The name of the journal",
            "organization.name,text,Name of the organization",
        ],
    },
    "advising": {
        "PERSON": [
            "instructor.name,text,Name of the instructor",
            "student.firstname,text,First name of the student",
            "student.lastname,text,Last name of the student",
        ],
        "ORG": [
            "program.college,text,Name of the college offering the program",
            "program.name,text,Name of the program",
        ],
    },
    "atis": {
        "GPE": [
            "airport_service.city_code,text,The code of the city where the airport is located",
            "airport.airport_location,text,The location of the airport, eg 'Las Vegas', 'Chicago'",
            "airport.country_name,text,The name of the country where the airport is located.",
            "airport.state_code,text,The code assigned to the state where the airport is located.",
            "city.city_code,text,The code assigned to the city",
            "city.city_name,text,The name of the city",
            "city.country_name,text,The name of the country where the city is located",
            "city.state_code,text,The 2-letter code assigned to the state where the city is located. E.g. 'NY', 'CA', etc.",
            "ground_service.city_code,text,The code for the city where the ground service is provided",
            "state.country_name,text,The name of the country the state belongs to",
            "state.state_code,text,The 2-letter code assigned to the state. E.g. 'NY', 'CA', etc.",
            "state.state_name,text,The name of the state",
        ],
        "ORG": [
            "airline.airline_code,text,The code assigned to the airline",
            "airline.airline_name,text,The name of the airline",
            "airport_service.airport_code,text,The code of the airport",
            "airport.airport_code,text,The code assigned to the airport.",
            "airport.airport_name,text,The name of the airport",
            "dual_carrier.main_airline,text,The name of the main airline operating the flight",
            "fare.fare_airline,text,The airline code associated with this fare",
            "fare.from_airport,text,The 3-letter airport code for the departure location",
            "fare.to_airport,text,The 3-letter airport code for the arrival location",
            "flight.airline_code,text,Code assigned to the airline",
            "flight.from_airport,text,Code assigned to the departure airport",
            "flight.to_airport,text,Code assigned to the arrival airport",
            "ground_service.airport_code,text,The 3-letter code for the airport where the ground service is provided",
        ],
    },
    "yelp": {
        "GPE": [
            "business.city,text,The city where the business is located",
            "business.state,text,The US state where the business is located, represented by two-letter abbreviations (eg. 'CA', 'NV', 'NY', etc.)",
            "business.full_address,text,The full address of the business",
        ],
        "ORG": [
            "business.name,text,The name of the business. All apostrophes use ’ instead of ' to avoid SQL errors.",
            "neighbourhood.neighbourhood_name,text,Name of the neighbourhood where the business is located",
        ],
        "PER": [
            "users.name,text,Name of the user",
        ],
    },
    "restaurants": {
        "GPE": [
            "location.city_name,text,The name of the city where the restaurant is located",
            "location.street_name,text,The name of the street where the restaurant is located",
            "geographic.city_name,text,The name of the city",
            "geographic.county,text,The name of the county",
            "geographic.region,text,The name of the region",
            "restaurant.city_name,text,The city where the restaurant is located",
        ],
        "ORG": [
            "restaurant.name,text,The name of the restaurant",
            "restaurant.id,bigint,Unique identifier for each restaurant",
        ],
        "PER": [],
    },
    "geography": {
        "GPE": [
            "city.city_name,text,The name of the city",
            "city.country_name,text,The name of the country where the city is located",
            "city.state_name,text,The name of the state where the city is located",
            "lake.country_name,text,The name of the country where the lake is located",
            "lake.state_name,text,The name of the state where the lake is located (if applicable)",
            "river.country_name,text,The name of the country the river flows through",
            "river.traverse,text,The cities or landmarks the river passes through. Comma delimited and in title case, eg `New York,Albany,Boston`",
            "state.state_name,text,The name of the state",
            "state.country_name,text,The name of the country the state belongs to",
            "state.capital,text,The name of the capital city of the state",
            "highlow.state_name,text,The name of the state",
            "mountain.country_name,text,The name of the country where the mountain is located",
            "mountain.state_name,text,The name of the state or province where the mountain is located (if applicable)",
            "border_info.state_name,text,The name of the state that shares a border with another state or country.",
            "border_info.border,text,The name of the state that shares a border with the state specified in the state_name column.",
        ],
        "LOC": [
            "lake.lake_name,text,The name of the lake",
            "river.river_name,text,The name of the river. Names exclude the word 'river' e.g. 'Mississippi' instead of 'Mississippi River'",
            "mountain.mountain_name,text,The name of the mountain",
        ],
        "ORG": [],
        "PER": [],
    },
    "scholar": {
        "GPE": [],
        "EVENT": [
            "venue.venuename,text,Name of the venue",
        ],
        "ORG": [],
        "PER": [
            "author.authorname,text,Name of the author",
        ],
        "WORK_OF_ART": [
            "paper.title,text,The title of the paper, enclosed in double quotes if it contains commas.",
            "dataset.datasetname,text,Name of the dataset",
            "journal.journalname,text,Name or title of the journal",
        ],
    },
    "broker": {
        "GPE": []
    },
    "car_dealership": {
        "GPE": []
    },
    "derm_treatment": {
        "GPE": []
    },
    "ewallet": {
        "GPE": []

    },
}

# (pair of tables): list of (column1, column2) tuples that can be joined
# pairs should be lexically ordered, ie (table1 < table2) and (column1 < column2)
columns_join = {
    "academic": {
        ("author", "domain_author"): [("author.aid", "domain_author.aid")],
        ("author", "organization"): [("author.oid", "organization.oid")],
        ("author", "writes"): [("author.aid", "writes.aid")],
        ("cite", "publication"): [
            ("cite.cited", "publication.pid"),
            ("cite.citing", "publication.pid"),
        ],
        ("conference", "domain_conference"): [
            ("conference.cid", "domain_conference.cid")
        ],
        ("conference", "publication"): [("conference.cid", "publication.cid")],
        ("domain", "domain_author"): [("domain.did", "domain_author.did")],
        ("domain", "domain_conference"): [("domain.did", "domain_conference.did")],
        ("domain", "domain_journal"): [("domain.did", "domain_journal.did")],
        ("domain", "domain_keyword"): [("domain.did", "domain_keyword.did")],
        ("domain_journal", "journal"): [("domain_journal.jid", "journal.jid")],
        ("domain_keyword", "keyword"): [("domain_keyword.kid", "keyword.kid")],
        ("domain_publication", "publication"): [
            ("domain_publication.pid", "publication.pid")
        ],
        ("journal", "publication"): [("journal.jid", "publication.jid")],
        ("keyword", "publication_keyword"): [
            ("keyword.kid", "publication_keyword.kid")
        ],
        ("publication", "publication_keyword"): [
            ("publication.pid", "publication_keyword.pid")
        ],
        ("publication", "writes"): [("publication.pid", "writes.pid")],
    },
    "advising": {
        ("area", "course"): [("area.course_id", "course.course_id")],
        ("comment_instructor", "instructor"): [
            ("comment_instructor.instructor_id", "instructor.instructor_id")
        ],
        ("comment_instructor", "student"): [
            ("comment_instructor.student_id", "student.student_id")
        ],
        ("course", "course_offering"): [
            ("course.course_id", "course_offering.course_id")
        ],
        ("course", "course_prerequisite"): [
            ("course.course_id", "course_prerequisite.course_id"),
            ("course.course_id", "course_prerequisite.pre_course_id"),
        ],
        ("course", "course_tags_count"): [
            ("course.course_id", "course_tags_count.course_id")
        ],
        ("course", "program_course"): [
            ("course.course_id", "program_course.course_id")
        ],
        ("course", "student_record"): [
            ("course.course_id", "student_record.course_id")
        ],
        ("course_offering", "offering_instructor"): [
            ("course_offering.offering_id", "offering_instructor.offering_id")
        ],
        ("course_offering", "student_record"): [
            ("course_offering.offering_id", "student_record.offering_id"),
            ("course_offering.course_id", "student_record.course_id"),
        ],
        ("instructor", "offering_instructor"): [
            ("instructor.instructor_id", "offering_instructor.instructor_id")
        ],
        ("program", "program_course"): [
            ("program.program_id", "program_course.program_id")
        ],
        ("program", "program_requirement"): [
            ("program.program_id", "program_requirement.program_id")
        ],
        ("program", "student"): [("program.program_id", "student.program_id")],
        ("student", "student_record"): [
            ("student.student_id", "student_record.student_id")
        ],
    },
    "atis": {
        ("airline", "flight"): [("airline.airline_code", "flight.airline_code")],
        ("airline", "flight_stop"): [
            ("airline.airline_code", "flight_stop.departure_airline"),
            ("airline.airline_code", "flight_stop.arrival_airline"),
        ],
        ("airport", "fare"): [
            ("airport.airport_code", "fare.from_airport"),
            ("airport.airport_code", "fare.to_airport"),
        ],
        ("airport", "flight_stop"): [
            ("airport.airport_code", "flight_stop.stop_airport")
        ],
        ("airport_service", "ground_service"): [
            ("airport_service.city_code", "ground_service.city_code"),
            ("airport_service.airport_code", "ground_service.airport_code"),
        ],
        ("airport", "city"): [
            ("airport.state_code", "city.state_code"),
            ("airport.country_name", "city.country_name"),
            ("airport.time_zone_code", "city.time_zone_code"),
        ],
        ("airport", "state"): [
            ("airport.state_code", "state.state_code"),
        ],
        ("city", "state"): [
            ("city.state_code", "state.state_code"),
        ],
        ("airport_service", "city"): [
            ("airport_service.city_code", "city.city_code"),
        ],
        ("ground_service", "city"): [
            ("ground_service.city_code", "city.city_code"),
        ],
        ("airport", "time_zone"): [
            ("airport.time_zone_code", "time_zone.time_zone_code"),
        ],
        ("city", "time_zone"): [
            ("city.time_zone_code", "time_zone.time_zone_code"),
        ],
        ("flight", "flight_fare"): [
            ("flight.flight_id", "flight_fare.flight_id"),
        ],
        ("flight", "flight_leg"): [
            ("flight.flight_id", "flight_leg.flight_id"),
        ],
        ("flight", "flight_stop"): [
            ("flight.flight_id", "flight_stop.flight_id"),
        ],
        ("flight_fare", "flight_leg"): [
            ("flight_fare.flight_id", "flight_leg.flight_id"),
        ],
        ("flight_fare", "flight_stop"): [
            ("flight_fare.flight_id", "flight_stop.flight_id"),
        ],
        ("flight_leg", "flight_stop"): [
            ("flight_leg.flight_id", "flight_stop.flight_id"),
        ],
        ("aircraft", "equipment_sequence"): [
            ("aircraft.aircraft_code", "equipment_sequence.aircraft_code"),
        ],
        ("flight", "equipment_sequence"): [
            (
                "flight.aircraft_code_sequence",
                "equipment_sequence.aircraft_code_sequence",
            ),
        ],
        ("flight", "food_service"): [
            ("flight.meal_code", "food_service.meal_code"),
        ],
    },
    "yelp": {
        ("business", "tip"): [("business.business_id", "tip.business_id")],
        ("business", "review"): [("business.business_id", "review.business_id")],
        ("business", "checkin"): [("business.business_id", "checkin.business_id")],
        ("business", "neighbourhood"): [
            ("business.business_id", "neighbourhood.business_id")
        ],
        ("business", "category"): [("business.business_id", "category.business_id")],
        ("tip", "users"): [("tip.user_id", "users.user_id")],
        ("review", "users"): [("review.user_id", "users.user_id")],
    },
    "restaurants": {
        ("geographic", "location"): [
            ("geographic.city_name", "location.city_name"),
        ],
        ("geographic", "restaurant"): [
            ("geographic.city_name", "restaurant.city_name"),
        ],
        ("location", "restaurant"): [
            ("location.restaurant_id", "restaurant.id"),
        ],
    },
    "geography": {
        ("border_info", "city"): [
            ("border_info.state_name", "city.state_name"),
            ("border_info.border", "city.state_name"),
        ],
        ("border_info", "lake"): [
            ("border_info.state_name", "lake.state_name"),
            ("border_info.border", "lake.state_name"),
        ],
        ("border_info", "state"): [
            ("border_info.state_name", "state.state_name"),
            ("border_info.border", "state.state_name"),
        ],
        ("border_info", "highlow"): [
            ("border_info.state_name", "highlow.state_name"),
            ("border_info.border", "highlow.state_name"),
        ],
        ("border_info", "mountain"): [
            ("border_info.state_name", "mountain.state_name"),
            ("border_info.border", "mountain.state_name"),
        ],
        ("city", "lake"): [
            ("city.country_name", "lake.country_name"),
            ("city.state_name", "lake.state_name"),
        ],
        ("city", "river"): [
            ("city.country_name", "river.country_name"),
        ],
        ("city", "state"): [
            ("city.country_name", "state.country_name"),
            ("city.state_name", "state.state_name"),
        ],
        ("city", "mountain"): [
            ("city.country_name", "mountain.country_name"),
            ("city.state_name", "mountain.state_name"),
        ],
        ("city", "highlow"): [
            ("city.state_name", "highlow.state_name"),
        ],
        ("highlow", "lake"): [
            ("highlow.state_name", "lake.state_name"),
        ],
        ("highlow", "state"): [
            ("highlow.state_name", "state.state_name"),
        ],
        ("highlow", "mountain"): [
            ("highlow.state_name", "mountain.state_name"),
        ],
        ("lake", "river"): [
            ("lake.country_name", "river.country_name"),
        ],
        ("lake", "state"): [
            ("lake.country_name", "state.country_name"),
            ("lake.state_name", "state.state_name"),
        ],
        ("lake", "mountain"): [
            ("lake.country_name", "mountain.country_name"),
            ("lake.state_name", "mountain.state_name"),
        ],
        ("river", "state"): [
            ("river.country_name", "state.country_name"),
        ],
        ("river", "mountain"): [
            ("river.country_name", "mountain.country_name"),
        ],
        ("state", "mountain"): [
            ("state.country_name", "mountain.country_name"),
            ("state.state_name", "mountain.state_nem"),
        ],
    },
    "scholar": {
        ("author", "writes"): [
            ("author.authorid", "writes.authorid"),
        ],
        ("cite", "paper"): [
            ("cite.citingpaperid", "paper.paperid"),
            ("cite.citedpaperid", "paper.paperid"),
        ],
        ("cite", "paperdataset"): [
            ("cite.citingpaperid", "paperdataset.paperid"),
            ("cite.citedpaperid", "paperdataset.paperid"),
        ],
        ("cite", "paperfield"): [
            ("cite.citingpaperid", "paperfield.paperid"),
            ("cite.citedpaperid", "paperfield.paperid"),
        ],
        ("cite", "paperkeyphrase"): [
            ("cite.citingpaperid", "paperkeyphrase.paperid"),
            ("cite.citedpaperid", "paperkeyphrase.paperid"),
        ],
        ("cite", "writes"): [
            ("cite.citingpaperid", "writes.paperid"),
            ("cite.citedpaperid", "writes.paperid"),
        ],
        ("dataset", "paperdataset"): [
            ("dataset.datasetid", "paperdataset.datasetid"),
        ],
        ("field", "paperfield"): [
            ("field.fieldid", "paperfield.fieldid"),
        ],
        ("journal", "paper"): [
            ("journal.journalid", "paper.journalid"),
        ],
        ("keyphrase", "paperkeyphrase"): [
            ("keyphrase.keyphraseid", "paperkeyphrase.keyphraseid"),
        ],
        ("paper", "paperdataset"): [
            ("paper.paperid", "paperdataset.paperid"),
        ],
        ("paper", "paperfield"): [
            ("paper.paperid", "paperfield.paperid"),
        ],
        ("paper", "paperkeyphrase"): [
            ("paper.paperid", "paperkeyphrase.paperid"),
        ],
        ("paper", "writes"): [
            ("paper.paperid", "writes.paperid"),
        ],
        ("paper", "venue"): [
            ("paper.venueid", "venue.venueid"),
        ],
        ("paperfield", "paperkeyphrase"): [
            ("paperfield.paperid", "paperkeyphrase.paperid"),
        ],
        ("paperfield", "writes"): [
            ("paperfield.paperid", "writes.paperid"),
        ],
        ("paperkeyphrase", "writes"): [
            ("paperkeyphrase.paperid", "writes.paperid"),
        ],
    },
    "broker": {},
    "car_dealership": {},
    "derm_treatment": {},
    "ewallet": {},
}
