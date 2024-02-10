-- Determine the username and password for each admin
CREATE TABLE credentials (
  id serial PRIMARY KEY,
  username text NOT NULL UNIQUE,
  password text NOT NULL
);

-- Determine name of tenants
CREATE TABLE tenants (
  id serial PRIMARY KEY,
  name text NOT NULL
);

CREATE TABLE buildings (
  id serial PRIMARY KEY,
  name text NOT NULL
);

-- Establish a 1:1 relationship with renters. If renter is deleted, building may stay
-- Establish a M:1 relationship with buildings. If building is deleted, so should its apartments
CREATE TABLE apartments (
  id serial PRIMARY KEY,
  number int NOT NULL,
  rent NUMERIC(6, 2) NOT NULL,
  building_id int REFERENCES buildings(id) ON DELETE CASCADE NOT NULL,
  tenant_id int REFERENCES tenants(id)
);