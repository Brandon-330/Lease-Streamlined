require 'pg'

class Database
  def initialize(logger)
    @db = PG.connect(dbname: 'apartments_rental_management', user: 'postgres', password: 'postgres')
    @logger = logger
  end

  def find_apartments(building_id)
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

  def find_building(id)
    sql = <<~SQL
    SELECT b.id, b.name, a.building_number || ' ' || a.street || ', ' || a.city || ', ' || a.state || ' ' || a.zip_code AS address
    FROM buildings AS b 
    JOIN addresses AS a ON a.id = b.address_id
    WHERE b.id = $1
    SQL

    result = query(sql, id)

    format_sql_result_to_list_of_hashes(result).first
  end

  def all_buildings
    sql = <<~SQL
    SELECT b.id, b.name, a.building_number || ' ' || a.street AS address
    FROM buildings AS b
    JOIN addresses AS a ON a.id = b.address_id
    ORDER BY b.name ASC
    SQL

    result = query(sql)

    format_sql_result_to_list_of_hashes(result)
  end

  def find_credentials(username, password)
    sql = <<~SQL
    SELECT c.id
    FROM credentials AS c
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
end