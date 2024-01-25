-- Determine the username and password for each renter and/or admin
CREATE TABLE credentials (
  id serial PRIMARY KEY,
  username text NOT NULL UNIQUE,
  password text NOT NULL
);

-- Determine name of renters and if they are active or past renters
CREATE TABLE tenants (
  id serial PRIMARY KEY,
  name text NOT NULL,
  status boolean DEFAULT true,
  credential_id int REFERENCES credentials(id) ON DELETE CASCADE UNIQUE NOT NULL
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
CREATE TABLE properties (
  id serial PRIMARY KEY,
  name text NOT NULL,
  address_id int REFERENCES addresses(id) ON DELETE CASCADE UNIQUE NOT NULL
);

-- Establish a 1:1 relationship with renters. If renter is deleted, property may stay
-- Establish a M:1 relationship with properties. If property is deleted, so should all apartments
CREATE TABLE apartments (
  id serial PRIMARY KEY,
  number int NOT NULL,
  rent NUMERIC(6, 2) NOT NULL,
  property_id int REFERENCES properties(id) NOT NULL,
  tenant_id int REFERENCES tenants(id) UNIQUE
);

-- Establish a 1:M relationship with apartments. There can be many payments linking to a single property
  -- If apartment is deleted, so is the payments for the property
  -- Past renters should still have access to their payment history
-- Establish a 1:1 relationship with renters, to identify the renter
CREATE TABLE payments (
  id serial PRIMARY KEY,
  amount NUMERIC(6, 2) NOT NULL,
  transaction_date date DEFAULT NOW() NOT NULL,
  apartment_id int REFERENCES apartments(id) ON DELETE CASCADE NOT NULL,
  tenant_id int REFERENCES tenants(id) NOT NULL
);