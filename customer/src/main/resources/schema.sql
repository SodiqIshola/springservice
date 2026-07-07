-- Create Sequences for ID generation
CREATE SEQUENCE IF NOT EXISTS customer_id_sequence START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE IF NOT EXISTS sequence_user START WITH 1 INCREMENT BY 1;

-- Create Customer Table
CREATE TABLE IF NOT EXISTS customer (
    id INTEGER PRIMARY KEY DEFAULT nextval('customer_id_sequence'),
    first_name VARCHAR(255),
    last_name VARCHAR(255),
    email VARCHAR(255),
    phone_number VARCHAR(255),
    message VARCHAR(255)
);

-- Create UserLogin Table (mapped to "user_details_login")
CREATE TABLE IF NOT EXISTS user_details_login (
    id BIGINT PRIMARY KEY DEFAULT nextval('sequence_user'),
    username VARCHAR(255) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    userrole VARCHAR(255)
);

