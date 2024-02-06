require 'pg'

class Database
  def initialize(logger)
    @db = PG.connect(dbname: 'apartments_rental_management', user: 'postgres', password: 'postgres')
    @logger = logger # Logger for developing purposes
  end

  def all_apartments(building_id)
    sql = <<~SQL
    SELECT a.number AS apartment_number, a.rent, t.name AS tenant_name
    FROM apartments AS a
    LEFT OUTER JOIN tenants AS t ON t.id = a.tenant_id
    WHERE a.building_id = $1
    ORDER BY a.rent DESC
    SQL

    result = query(sql, building_id)

    format_sql_result_to_list_of_hashes(result)
  end

  def add_apartment(building_id, apartment_number, rent, tenant_name)
    # If new apartment will include tenant, execute if statement
    if !tenant_name.empty?
      tenant_hsh = find_tenant_by_name(tenant_name)
      
      # If tenant does not exist, add new tenant
      if !tenant_hsh
        add_tenant(tenant_name)
        tenant_hsh = find_tenant_by_name(tenant_name)
      end

      tenant_id = tenant_hsh[:id]
    end

    sql = <<~SQL
    INSERT INTO apartments (building_id, number, rent, tenant_id)
                    VALUES ($1, $2, CAST($3 AS NUMERIC(6, 2)), $4)
    SQL

    query(sql, building_id, apartment_number, rent, tenant_id)
  end

  def all_buildings
    sql = <<~SQL
    SELECT id, name
    FROM buildings
    ORDER BY name ASC
    SQL

    result = query(sql)

    format_sql_result_to_list_of_hashes(result)
  end

  def find_building(id)
    sql = <<~SQL
    SELECT id, name
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

  def all_tenants
    sql = <<~SQL
    SELECT *
    FROM tenants
    SQL

    result = query(sql)
    
    format_sql_result_to_list_of_hashes(result)
  end

  def find_credentials(username, password)
    sql = <<~SQL
    SELECT id
    FROM credentials
    WHERE username = $1
    AND password = $2
    SQL

    result = query(sql, username, password)

    format_sql_result_to_list_of_hashes(result)
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

  def find_tenant_by_name(name)
    sql = <<~SQL
    SELECT *
    FROM tenants
    WHERE name = $1
    SQL

    result = query(sql, name)

    format_sql_result_to_list_of_hashes(result).first
  end

  def add_tenant(name)
    sql = <<~SQL
    INSERT INTO tenants (name)
                  VALUES ($1)
    SQL

    query(sql, name)
  end
end