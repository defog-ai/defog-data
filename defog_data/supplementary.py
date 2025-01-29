import os
import re

# get package root directory
root_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

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
    "broker": {
        ("sbCustomer", "sbTransaction"): [
            ("sbCustomer.sbCustId", "sbTransaction.sbTxCustId")
        ],
        ("sbTicker", "sbDailyPrice"): [
            ("sbTicker.sbTickerId", "sbDailyPrice.sbDpTickerId")
        ],
        ("sbTicker", "sbTransaction"): [
            ("sbTicker.sbTickerId", "sbTransaction.sbTxTickerId")
        ],
    },
    "car_dealership": {
        ("cars", "sales"): [("cars.id", "sales.car_id")],
        ("salespersons", "sales"): [("salespersons.id", "sales.salesperson_id")],
        ("customers", "sales"): [("customers.id", "sales.customer_id")],
        ("cars", "inventory_snapshots"): [("cars.id", "inventory_snapshots.car_id")],
        ("sales", "payments_received"): [("sales.id", "payments_received.sale_id")],
    },
    "derm_treatment": {
        ("patients", "treatments"): [("patients.patient_id", "treatments.patient_id")],
        ("doctors", "treatments"): [("doctors.doc_id", "treatments.doc_id")],
        ("drugs", "treatments"): [("drugs.drug_id", "treatments.drug_id")],
        ("diagnoses", "treatments"): [("diagnoses.diag_id", "treatments.diag_id")],
        ("treatments", "outcomes"): [
            ("treatments.treatment_id", "outcomes.treatment_id")
        ],
        ("treatments", "adverse_events"): [
            ("treatments.treatment_id", "adverse_events.treatment_id")
        ],
        ("treatments", "concomitant_meds"): [
            ("treatments.treatment_id", "concomitant_meds.treatment_id")
        ],
    },
    "ewallet": {
        ("consumer_div.users", "consumer_div.notifications"): [
            ("consumer_div.users.uid", "consumer_div.notifications.user_id")
        ],
        ("consumer_div.users", "consumer_div.user_sessions"): [
            ("consumer_div.users.uid", "consumer_div.user_sessions.user_id")
        ],
        ("consumer_div.users", "consumer_div.user_setting_snapshot"): [
            ("consumer_div.users.uid", "consumer_div.user_setting_snapshot.user_id")
        ],
        ("consumer_div.users", "consumer_div.wallet_user_balance_daily"): [
            ("consumer_div.users.uid", "consumer_div.wallet_user_balance_daily.user_id")
        ],
        ("consumer_div.users", "consumer_div.wallet_transactions_daily"): [
            (
                "consumer_div.users.uid",
                "consumer_div.wallet_transactions_daily.sender_id",
            ),
            (
                "consumer_div.users.uid",
                "consumer_div.wallet_transactions_daily.receiver_id",
            ),
        ],
        ("consumer_div.merchants", "consumer_div.wallet_transactions_daily"): [
            (
                "consumer_div.merchants.mid",
                "consumer_div.wallet_transactions_daily.sender_id",
            ),
            (
                "consumer_div.merchants.mid",
                "consumer_div.wallet_transactions_daily.receiver_id",
            ),
        ],
        ("consumer_div.merchants", "consumer_div.coupons"): [
            ("consumer_div.merchants.mid", "consumer_div.coupons.merchant_id")
        ],
        ("consumer_div.merchants", "consumer_div.wallet_merchant_balance_daily"): [
            (
                "consumer_div.merchants.mid",
                "consumer_div.wallet_merchant_balance_daily.merchant_id",
            )
        ],
        ("consumer_div.coupons", "consumer_div.wallet_transactions_daily"): [
            (
                "consumer_div.coupons.cid",
                "consumer_div.wallet_transactions_daily.coupon_id",
            ),
            (
                "consumer_div.coupons.merchant_id",
                "consumer_div.wallet_transactions_daily.sender_id",
            ),
            (
                "consumer_div.coupons.merchant_id",
                "consumer_div.wallet_transactions_daily.receiver_id",
            ),
        ],
    },
}
