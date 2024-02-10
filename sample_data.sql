INSERT INTO tenants (name)
             VALUES ('Eddie'),
                    ('David'),
                    ('Jessica');

INSERT INTO buildings (name)
                VALUES ('Oakridge'),
                       ('4 Seasons'),
                       ('Dual Point');

INSERT INTO apartments (number, rent, building_id, tenant_id)
                VALUES (203, 1500.00, 1, 1),
                       (102, 2200.00, 2, DEFAULT),
                       (505, 3999.99, 3, 3),
                       (205, 2500.00, 2, DEFAULT),
                       (301, 2600.00, 2, DEFAULT);             