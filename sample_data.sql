INSERT INTO credentials (username, password)
                 VALUES ('Edd1e', '12345'),
                        ('Jezz', '11111'),
                        ('Dav3', '44444');

INSERT INTO tenants (name, status)
             VALUES ('Eddie', DEFAULT),
                    ('David', 'false'),
                    ('Jessica', DEFAULT);

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