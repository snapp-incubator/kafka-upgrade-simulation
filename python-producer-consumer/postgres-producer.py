import argparse
import psycopg2
import time
import random
from faker import Faker

def insert_record(conn, cursor):
    fake = Faker()
    product_name = fake.word()
    description = fake.text(5)
    weight = random.uniform(0.1, 10.0)

    cursor.execute(
        "INSERT INTO inventory.products (name, description, weight) VALUES (%s, %s, %s)",
        (product_name, description, weight)
    )
    conn.commit()

def main(host, port, database, user, password):
    connection_params = f"host={host} port={port} dbname={database} user={user} password={password}"
    conn = psycopg2.connect(connection_params)
    cursor = conn.cursor()

    for _ in range(100000):
        try:
            insert_record(conn, cursor)
            time.sleep(0.1)
            print(f"{_} record inserted out of 100000")

        except psycopg2.OperationalError as e:
            print(f"Operational error: {e}")
            time.sleep(2)
            conn = psycopg2.connect(connection_params)
            cursor = conn.cursor()
    
        except KeyboardInterrupt:
            pass

    conn.close()

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Insert records into PostgreSQL table.")
    parser.add_argument("--host", required=True, help="PostgreSQL host")
    parser.add_argument("--port", required=True, help="PostgreSQL port")
    parser.add_argument("--database", required=True, help="PostgreSQL database name")
    parser.add_argument("--user", required=True, help="PostgreSQL user")
    parser.add_argument("--password", required=True, help="PostgreSQL password")

    args = parser.parse_args()
    main(args.host, args.port, args.database, args.user, args.password)
