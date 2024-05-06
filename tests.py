import os
import unittest
from defog_data.metadata import get_db, dbs
from defog_data.supplementary import columns_ner


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
            "broker",
            "car_dealership",
            "derm_treatment",
            "ewallet",
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
        assert len(dbs) == 11

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
        num_columns = sum([len(db_schema[table]) for table in db_schema])
        self.assertEqual(num_columns, 42)

    def test_advising(self):
        db_name = "advising"
        db_schema = get_db(db_name)["table_metadata"]
        expected_tables = [
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
        num_columns = sum([len(db_schema[table]) for table in db_schema])
        self.assertEqual(num_columns, 109)

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
        num_columns = sum([len(db_schema[table]) for table in db_schema])
        self.assertEqual(num_columns, 127)

    def test_broker(self):
        db_name = "broker"
        db_schema = get_db(db_name)["table_metadata"]
        expected_tables = [
            "sbCustomer",
            "sbTicker",
            "sbDailyPrice",
            "sbTransaction",
        ]
        self.assertEqual(list(db_schema.keys()), expected_tables)
        glossary = get_db(db_name)["glossary"]
        expected_glossary = """- sbTicker can be joined to sbDailyPrice on sbTickerId
- sbCustomer can be joined to sbTransaction on sbCustId
- sbTicker can be joined to sbTransaction on sbTickerId
- ADV (Average Daily Volume) for a ticker = AVG(sbDpVolume) from sbDailyPrice table for that ticker
- ATH (All Time High) price for a ticker = MAX(sbDpHigh) from sbDailyPrice table for that ticker
- ATP (Average Transaction Price) for a customer = SUM(sbTxAmount)/SUM(sbTxShares) from sbTransaction table for that customer
- NCT (Net Commission Total) = SUM(sbTxCommission) from sbTransaction table"""
        self.assertEqual(glossary, expected_glossary)
        num_columns = sum([len(db_schema[table]) for table in db_schema])
        self.assertEqual(num_columns, 43)

    def test_car_dealership(self):
        db_name = "car_dealership"
        db_schema = get_db(db_name)["table_metadata"]
        expected_tables = [
            "cars",
            "salespersons",
            "customers",
            "sales",
            "inventory_snapshots",
            "payments_received",
            "payments_made",
        ]
        self.assertEqual(list(db_schema.keys()), expected_tables)
        num_columns = sum([len(db_schema[table]) for table in db_schema])
        self.assertEqual(num_columns, 55)

    def test_derm_treatment(self):
        db_name = "derm_treatment"
        db_schema = get_db(db_name)["table_metadata"]
        expected_tables = [
            "doctors",
            "patients",
            "drugs",
            "diagnoses",
            "treatments",
            "outcomes",
            "adverse_events",
            "concomitant_meds",
        ]
        self.assertEqual(list(db_schema.keys()), expected_tables)
        num_columns = sum([len(db_schema[table]) for table in db_schema])
        self.assertEqual(num_columns, 81)

    def test_ewallet(self):
        db_name = "ewallet"
        db_schema = get_db(db_name)["table_metadata"]
        expected_tables = [
            "consumer_div.users",
            "consumer_div.merchants",
            "consumer_div.coupons",
            "consumer_div.wallet_transactions_daily",
            "consumer_div.wallet_user_balance_daily",
            "consumer_div.wallet_merchant_balance_daily",
            "consumer_div.notifications",
            "consumer_div.user_sessions",
            "consumer_div.user_setting_snapshot",
        ]
        self.assertEqual(list(db_schema.keys()), expected_tables)
        glossary = get_db(db_name)["glossary"]
        expected_glossary = """- sender_id and receiver_id can be joined with either users.uid or merchants.mid depending on the sender_type/receiver_type
- if a user applied a coupon to a purchase, there will be 2 rows in wallet_transactions_daily:
  - 1st row where coupon_id is NULL, amount = purchase value 
  - 2nd row where coupon_id is NOT NULL, amount = coupon value applied
  - the sender and receiver id will be the same for both rows, but they will have different txid's 
- when using coupons.code, wallet_transactions_daily.gateway_name, filter case insensitively
- Total Transaction Volume (TTV) = SUM(wallet_transactions_daily.amount)
- Total Coupon Discount Redeemed (TCDR) = SUM(wallet_transactions_daily.amount) WHERE coupon_id IS NOT NULL
- Session Density = COUNT(user_sessions.user_id) / COUNT(DISTINCT user_sessions.user_id)
- Active Merchants Percentage (APM) = COUNT(DISTINCT CASE WHEN sender_type = 1 THEN wallet_transactions_daily.sender_id WHEN receiver_type = 1 THEN wallet_transactions_daily.receiver_id ELSE NULL END) / COUNT(DISTINCT merchants.mid)"""
        print(glossary)
        self.assertEqual(glossary, expected_glossary)
        num_columns = sum([len(db_schema[table]) for table in db_schema])
        self.assertEqual(num_columns, 96)

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
        num_columns = sum([len(db_schema[table]) for table in db_schema])
        self.assertEqual(num_columns, 29)

    def test_restaurants(self):
        db_name = "restaurants"
        db_schema = get_db(db_name)["table_metadata"]
        expected_tables = ["location", "geographic", "restaurant"]
        self.assertEqual(list(db_schema.keys()), expected_tables)
        num_columns = sum([len(db_schema[table]) for table in db_schema])
        self.assertEqual(num_columns, 12)

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
        num_columns = sum([len(db_schema[table]) for table in db_schema])
        self.assertEqual(num_columns, 28)

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
        num_columns = sum([len(db_schema[table]) for table in db_schema])
        self.assertEqual(num_columns, 36)

    def test_supplementary_columns_ner(self):
        # for each db, go through each table and add column names to a set and make sure they are not repeated
        for db_name, ner_mapping in columns_ner.items():
            column_names = set()
            for _, column_str_list in ner_mapping.items():
                for column_str in column_str_list:
                    column_name = column_str.split(",")[0]
                    if column_name in column_names:
                        raise Exception(
                            f"Column name {column_name} is repeated in {db_name}"
                        )
                    column_names.add(column_name)


if __name__ == "__main__":
    unittest.main()
