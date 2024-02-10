INSERT INTO tenants (name)
             VALUES ('Eddie'),
                    ('David'),
                    ('Jessica'),
                    ('Rick'),
                    ('Pamela'),
                    ('Richard'),
                    ('Jen'),
                    ('Trevor'),
                    ('Daniel');

INSERT INTO buildings (name)
                VALUES ('Oakridge'),
                       ('4 Seasons'),
                       ('Dual Point'),
                       ('Three Rivers'),
                       ('4 Maidens'),
                       ('Motel 6');

INSERT INTO apartments (number, rent, building_id, tenant_id)
                VALUES (203, 1500.00, 1, 1),
                       (102, 2200.00, 2, DEFAULT),
                       (505, 3999.99, 3, 3),
                       (205, 2500.00, 2, DEFAULT),
                       (301, 2600.00, 2, DEFAULT),
                       (205, 1000.00, 1, 2),
                       (206, 1000.00, 1, 3),
                       (207, 2000.00, 1, 4),
                       (208, 3500.00, 1, 5),
                       (209, 4000.00, 1, DEFAULT);             