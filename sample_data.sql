INSERT INTO credentials (username, password)
                 VALUES ('Edd1e', '12345'),
                        ('Jezz', '11111'),
                        ('Dav3', '44444');

INSERT INTO tenants (name, status, credential_id)
             VALUES ('Eddie', DEFAULT, 1),
                    ('David', 'false', 3),
                    ('Jessica', DEFAULT, 2);

INSERT INTO addresses (building_number, street, city, state, zip_code)
               VALUES (1774, 'Sedgewick Street', 'Wayne', 'PA', 14765),
                      (7941, 'Traveler Drive', 'Baltimore', 'MD', 19886),
                      (6479, 'Elmore Street', 'San Francisco', 'CA', 97612);

INSERT INTO buildings (name, address_id)
                VALUES ('Oakridge', 1),
                       ('4 Seasons', 2),
                       ('Dual Point', 3);

INSERT INTO apartments (number, rent, building_id, tenant_id)
                VALUES (203, 1500.00, 1, 1),
                       (102, 2200.00, 2, DEFAULT),
                       (505, 3999.99, 3, 3);             

-- INSERT INTO payments (amount, transaction_date, apartment_id, tenant_id)
--               VALUES (1000, 'Jan-20-2024', 1, 1),
--                      (500, 'Jan-20-2024', 1, 1),
--                      (3999.99, 'Jan-12-2024', 3, 3),
--                      (1000, 'Dec-10-2023', 2, 2);