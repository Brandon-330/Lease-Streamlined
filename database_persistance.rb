require 'pg'

class Database
  def initialize(logger)
    @db = PG.connect(dbname: 'apartments_rental_management', user: 'postgres', password: 'postgres')
    @logger = logger # Logger for developing purposes
  end

  def all_apartments(building_id)
    sql = <<~SQL
    SELECT a.*, t.name AS tenant_name
    FROM apartments AS a
    LEFT OUTER JOIN tenants AS t ON t.id = a.tenant_id
    WHERE a.building_id = $1
    ORDER BY a.rent DESC
    SQL

    result = query(sql, building_id)

    format_sql_result_to_list_of_hashes(result)
  end

  def find_apartment(building_id, apartment_id)
    sql = <<~SQL
    SELECT a.*, t.id AS tenant_id, t.name AS tenant_name
    FROM apartments AS a
    LEFT OUTER JOIN tenants AS t ON t.id = a.tenant_id
    WHERE a.building_id = $1
    AND a.id = $2
    SQL

    result = query(sql, building_id, apartment_id)

    format_sql_result_to_list_of_hashes(result).first
  end

  def add_apartment(building_id, apartment_number, rent, tenant_name)
    tenant_id = add_tenant(tenant_name)

    sql = <<~SQL
    INSERT INTO apartments (building_id, number, rent, tenant_id)
                    VALUES ($1, $2, CAST($3 AS NUMERIC(6, 2)), $4)
    SQL

    query(sql, building_id, apartment_number, rent, tenant_id)
  end

  def update_apartment(apartment_hsh, apartment_number, rent, tenant_name)
    building_id = apartment_hsh[:building_id]
    apartment_id = apartment_hsh[:id]
    tenant_id = apartment_hsh[:tenant_id]
    
    if tenant_name != apartment_hsh[:tenant_name]
      delete_tenant(tenant_id)
      tenant_id = add_tenant(tenant_name)
    end

    sql = <<~SQL
    UPDATE apartments
    SET number = $1, rent = $2, tenant_id = $3
    WHERE building_id = $4
    AND id = $5
    SQL

    query(sql, apartment_number, rent, tenant_id, building_id, apartment_id)
  end

  def delete_apartment(apartment_hsh)
    building_id = apartment_hsh[:building_id]
    apartment_id = apartment_hsh[:id]
    tenant_id = apartment_hsh[:tenant_id]

    sql = <<~SQL
    DELETE FROM apartments
    WHERE building_id = $1
    AND id = $2
    SQL

    query(sql, building_id, apartment_id)

    delete_tenant(tenant_id)
  end

  def all_buildings
    sql = <<~SQL
    SELECT *
    FROM buildings
    ORDER BY name ASC
    SQL

    result = query(sql)

    format_sql_result_to_list_of_hashes(result)
  end

  def find_building(id)
    sql = <<~SQL
    SELECT *
    FROM buildings 
    WHERE id = $1
    SQL

    result = query(sql, id)

    format_sql_result_to_list_of_hashes(result).first
  end

  def add_building(building_name)
    sql = <<~SQL
    INSERT INTO buildings (name)
                   VALUES ($1)
    SQL

    query(sql, building_name)
  end

  def update_building(id, name)
    sql = <<~SQL
    UPDATE buildings
    SET name = $2
    WHERE id = $1
    SQL

    query(sql, id, name)
  end

  def delete_building(id)
    sql = <<~SQL
    DELETE FROM buildings
    WHERE id = $1
    SQL

    query(sql, id)
  end

  def evict_all_tenants(building_id)
    # ON DELETE SET NULL condition in apartments automatically updates apartments accordingly
    sql = <<~SQL
    DELETE FROM tenants
    WHERE id IN (SELECT tenant_id
                 FROM apartments
                 WHERE building_id = $1)
    SQL

    query(sql, building_id)
  end

  def all_usernames
    sql = <<~SQL
    SELECT username
    FROM credentials
    SQL

    result = query(sql)

    format_sql_result_to_list_of_hashes(result)
  end

  def find_credentials(username)
    sql = <<~SQL
    SELECT *
    FROM credentials
    WHERE username = $1
    SQL

    result = query(sql, username)

    format_sql_result_to_list_of_hashes(result).first
  end

  def add_credentials(username, password)
    sql = <<~SQL
    INSERT INTO credentials (username, password)
                      VALUES($1, $2)
    SQL

    query(sql, username, password)
  end

  private

  def query(statement, *args)
    @logger.info "#{statement}: #{args}"
    @db.exec_params(statement, args)
  end

  def format_sql_result_to_list_of_hashes(sql_result)
    sql_result.map do |tuple|
      tuple_hash = Hash.new
      tuple.each do |key, value|
        tuple_hash[key.to_sym] = value
      end

      tuple_hash
    end
  end

  def find_tenant_by_name_for_building(name, building_id)
    sql = <<~SQL
    SELECT *
    FROM tenants
    WHERE name = $1
    AND id IN (SELECT tenant_id
               FROM apartments
               WHERE building_id = $2)
    SQL

    result = query(sql, name, building_id)

    format_sql_result_to_list_of_hashes(result).first
  end

  def add_tenant(name)
    unless name.empty?
      sql = <<~SQL
      INSERT INTO tenants (name)
                    VALUES ($1)
                    RETURNING id;
      SQL

      result = query(sql, name)

      format_sql_result_to_list_of_hashes(result).first[:id] # Tenant id
    end
  end

  def delete_tenant(tenant_id)
    sql = <<~SQL
    DELETE FROM tenants
    WHERE id = $1
    SQL

    query(sql, tenant_id)
  end
end