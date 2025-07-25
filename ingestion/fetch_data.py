import requests
import psycopg2
import logging

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(message)s",
    handlers=[logging.FileHandler("ingestion.log"), logging.StreamHandler()],
)


class ImfDataFetcher:

    def __init__(self, start_date=None, end_date=None, columns=None):
        self.start_date = start_date
        self.end_date = end_date
        self.base_url = "https://www.imf.org/external/datamapper/api/v1/"
        self.__make_url_time_suffix()
        self.__get_columns(columns)
        # logging.info(f"Columns: {self.columns}")

    def __make_url_time_suffix(self):
        url_time_suffix = "?periods=" + "".join(
            [f"{str(i)}," for i in range(self.start_date, self.end_date + 1)]
        )
        self.url_time_suffix = url_time_suffix[:-1]

    def __get_columns(self, columns):
        if columns is None:
            self.columns = self.fetch_indicators().keys()
        elif isinstance(columns, list):
            self.columns = columns
        elif isinstance(columns, str):
            self.columns = [columns]
        else:
            raise ValueError("columns must be a list of strings or a string")

    def fetch_indicators(self):
        url = self.base_url + "indicators"
        response = requests.get(url)
        indicators_dict = response.json()["indicators"]
        return indicators_dict

    def fetch_identifiers(self, identifier_type):
        url = self.base_url + identifier_type
        response = requests.get(url)
        identifiers_dict = response.json()
        return identifiers_dict

    def fetch_data(self):
        data = {}
        for column in self.columns:
            url = self.base_url + column + self.url_time_suffix
            response = requests.get(url)
            values = response.json().get("values", {})
            data.update(values)
        return data

    def insert_codes_to_postgres(self, table, data):
        identifier = list(data.keys())[0]
        data = data[identifier]

        logging.info(f"Inserting {identifier} to postgres")
        conn = psycopg2.connect(
            host="localhost", database="imf_data", user="xiaolong", password="xiaolong"
        )
        cursor = conn.cursor()
        for code, value in data.items():
            cursor.execute(
                f"INSERT INTO {table} (code, label) VALUES (%s, %s) ON CONFLICT (code) DO NOTHING",
                (code, value["label"]),
            )
        conn.commit()
        cursor.close()
        conn.close()

    def insert_indicators_to_postgres(self, indicators):
        logging.info("Inserting all indicators to postgres")
        conn = psycopg2.connect(
            host="localhost", database="imf_data", user="xiaolong", password="xiaolong"
        )
        cursor = conn.cursor()
        for indicator, value in indicators.items():
            cursor.execute(
                "INSERT INTO imf_indicators (indicator, label, description, source, unit, dataset) VALUES (%s, %s, %s, %s, %s, %s) ON CONFLICT (indicator) DO NOTHING",
                (
                    indicator,
                    value["label"],
                    value["description"],
                    value["source"],
                    value["unit"],
                    value["dataset"],
                ),
            )
        conn.commit()
        cursor.close()
        conn.close()

    def insert_data_to_postgres(self, data):
        logging.info("Inserting selected indicator data to postgres")
        conn = psycopg2.connect(
            host="localhost", database="imf_data", user="xiaolong", password="xiaolong"
        )
        cursor = conn.cursor()
        for indicator, country_data in data.items():
            for country, year_data in country_data.items():
                for year, value in year_data.items():
                    cursor.execute(
                        "INSERT INTO imf_data (indicator, code, year, value) VALUES (%s, %s, %s, %s) ON CONFLICT (indicator, code, year) DO NOTHING",
                        (indicator, country, year, value),
                    )
        conn.commit()
        cursor.close()
        conn.close()


if __name__ == "__main__":
    fetcher = ImfDataFetcher(
        start_date=2000, end_date=2024, columns=["NGDP_RPCH", "NGDPD", "LUR", "PCPIPCH"]
    )
    indicators = fetcher.fetch_indicators()
    fetcher.insert_indicators_to_postgres(indicators)

    for identifier_type in ["countries", "regions", "groups"]:
        identifiers = fetcher.fetch_identifiers(identifier_type)
        fetcher.insert_codes_to_postgres(f"imf_{identifier_type}", identifiers)

    data = fetcher.fetch_data()
    fetcher.insert_data_to_postgres(data)
