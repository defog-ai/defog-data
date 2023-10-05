import os
import unittest
from defog_data.metadata import get_db, dbs


class TestDB(unittest.TestCase):
    def test_load_all_in_diff_dir(self):
        # get current directory
        test_dir = os.getcwd()
        # cd to /tmp and attempt to load a db
        os.chdir("/tmp")
        all_db_names = [
            "academic",
            "advising",
            "atis",
            "geography",
            "restaurants",
            "scholar",
            "yelp",
        ]
        for db_name in all_db_names:
            db = get_db(db_name)
            db_schema = db["table_metadata"]
            assert len(db_schema) > 0
            assert "glossary" in db
        os.chdir(test_dir)

    def dbs_exist(self):
        assert len(dbs) == 7

    # check that all the tables exist in each db
    def test_academic(self):
        db_name = "academic"
        db_schema = get_db(db_name)["table_metadata"]
        expected_tables = [
            "cite",
            "author",
            "domain",
            "writes",
            "journal",
            "keyword",
            "conference",
            "publication",
            "organization",
            "domain_author",
            "domain_journal",
            "domain_keyword",
            "domain_conference",
            "domain_publication",
            "publication_keyword",
        ]
        self.assertEqual(list(db_schema.keys()), expected_tables)

    def test_advising(self):
        db_name = "advising"
        db_schema = get_db(db_name)["table_metadata"]
        expected_tables = [
            "gsi",
            "area",
            "course",
            "program",
            "student",
            "semester",
            "instructor",
            "program_course",
            "student_record",
            "course_offering",
            "course_tags_count",
            "comment_instructor",
            "course_prerequisite",
            "offering_instructor",
            "program_requirement",
        ]
        self.assertEqual(list(db_schema.keys()), expected_tables)

    def test_atis(self):
        db_name = "atis"
        db_schema = get_db(db_name)["table_metadata"]
        expected_tables = [
            "city",
            "days",
            "fare",
            "month",
            "state",
            "flight",
            "airline",
            "airport",
            "aircraft",
            "time_zone",
            "fare_basis",
            "flight_leg",
            "flight_fare",
            "flight_stop",
            "restriction",
            "dual_carrier",
            "food_service",
            "time_interval",
            "ground_service",
            "airport_service",
            "class_of_service",
            "code_description",
            "compartment_class",
            "equipment_sequence",
        ]
        self.assertEqual(list(db_schema.keys()), expected_tables)

    def test_geography(self):
        db_name = "geography"
        db_schema = get_db(db_name)["table_metadata"]
        expected_tables = [
            "city",
            "lake",
            "river",
            "state",
            "highlow",
            "mountain",
            "border_info",
        ]
        self.assertEqual(list(db_schema.keys()), expected_tables)

    def test_restaurants(self):
        db_name = "restaurants"
        db_schema = get_db(db_name)["table_metadata"]
        expected_tables = ["location", "geographic", "restaurant"]
        self.assertEqual(list(db_schema.keys()), expected_tables)

    def test_scholar(self):
        db_name = "scholar"
        db_schema = get_db(db_name)["table_metadata"]
        expected_tables = [
            "cite",
            "field",
            "paper",
            "venue",
            "author",
            "writes",
            "dataset",
            "journal",
            "keyphrase",
            "paperfield",
            "paperdataset",
            "paperkeyphrase",
        ]
        self.assertEqual(list(db_schema.keys()), expected_tables)

    def test_yelp(self):
        db_name = "yelp"
        db_schema = get_db(db_name)["table_metadata"]
        expected_tables = [
            "tip",
            "users",
            "review",
            "checkin",
            "business",
            "category",
            "neighbourhood",
        ]
        self.assertEqual(list(db_schema.keys()), expected_tables)


if __name__ == "__main__":
    unittest.main()
