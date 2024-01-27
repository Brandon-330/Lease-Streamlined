require 'pg'

class Database
  def initialize(logger)
    @db = PG.connect(dbname: 'apartment_rental_management', user: 'postgres', password: 'postgres')
    @logger = logger
  end

  # NOT WORKING
  def find_property(id)
    sql = <<~SQL
    SELECT p.id, p.name, ad.house_number || ' ' || ad.street || ', ' || ad.city || ', ' || ad.state || ' ' || ad.zip_code AS address,
    ap.rent
    FROM properties AS p 
    JOIN apartments AS ap ON ap.property_id = p.id
    JOIN addresses AS ad ON ad.id = p.address_id
    WHERE p.id = $1
    SQL

    result = query(sql, id)

    format_sql_result_to_list_of_hashes(result).first
  end

  def all_properties
    sql = <<~SQL
    SELECT p.id, p.name, a.house_number || ' ' || a.street AS address
    FROM properties AS p JOIN addresses AS a
    ON a.id = p.address_id
    ORDER BY p.name ASC
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