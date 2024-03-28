from setuptools import find_packages, setup

setup(
    name="defog-data",
    version="0.1.2",
    description="Static SQL and JSON files containing the data we use for evaluations",
    author="Defog",
    author_email="support@defog.ai",
    packages=find_packages(),
    package_data={
        "": [
            "academic/*",
            "advising/*",
            "atis/*",
            "geography/*",
            "restaurants/*",
            "scholar/*",
            "yelp/*",
        ]
    },
    include_package_data=True,
)
