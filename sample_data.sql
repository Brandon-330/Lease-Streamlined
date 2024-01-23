INSERT INTO tenants (name, status)
             VALUES ('Eddie', DEFAULT),
                    ('David', 'false'),
                    ('Jessica', DEFAULT);

INSERT INTO addresses (house_number, street, city, state, zip_code)
               VALUES (1774, 'Sedgewick Street', 'Wayne', 'PA', 14765),
                      (7941, 'Traveler Drive', 'Baltimore', 'MD', 19886),
                      (6479, 'Elmore Street', 'San Francisco', 'CA', 97612);

INSERT INTO properties (rent, tenant_id, address_id)
                VALUES (1500.00, 1, 1),
                       (2200.00, DEFAULT, 2),
                       (3999.99, 3, 3);

INSERT INTO payments (amount, transaction_date, property_id, tenant_id)
              VALUES (1000, 'Jan-20-2024', 1, 1),
                     (500, 'Jan-20-2024', 1, 1),
                     (3999.99, 'Jan-12-2024', 3, 3),
                     (1000, 'Dec-10-2023', 2, 2);