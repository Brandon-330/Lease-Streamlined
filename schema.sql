-- Determine name of renters and if they are active or past renters
CREATE TABLE renters (
  id serial PRIMARY KEY,
  name text NOT NULL,
  status boolean DEFAULT true
);

-- Establish a 1:1 relationship with properties. If property is deleted, so is its address
CREATE TABLE addresses (
  id serial PRIMARY KEY,
  house_number int NOT NULL, 
  street text NOT NULL,
  city text NOT NULL,
  state char(2) NOT NULL,
  zip_code int NOT NULL
);

-- Establish a 1:1 relationship with address. If address is deleted, so should the property
-- Establish a 1:1 relationship with renters. If renter is deleted, property may stay
CREATE TABLE properties (
  id serial PRIMARY KEY,
  rent NUMERIC(6, 2) NOT NULL,
  renter_id int REFERENCES renters(id) UNIQUE,
  address_id int REFERENCES addresses(id) ON DELETE CASCADE UNIQUE NOT NULL
);

-- Establish a 1:M relationship with properties. There can be many payments linking to a single property
  -- If property is deleted, so is the payments for the property
  -- Past renters should still have access to their payment history
-- Establish a 1:1 relationship with renters, to identify the renter
CREATE TABLE payments (
  id serial PRIMARY KEY,
  amount NUMERIC(6, 2) NOT NULL,
  transaction_date date DEFAULT NOW() NOT NULL,
  property_id int REFERENCES properties(id) ON DELETE CASCADE NOT NULL,
  renter_id int REFERENCES renters(id) NOT NULL
);