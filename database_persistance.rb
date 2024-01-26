require 'pg'

class Database
  def initialize
    @db = PG.connect(dbname: 'apartment_rental_management', user: 'postgres', password: 'postgres')
  end

  # NOT WORKING
  def find_property(id)
    sql = <<~SQL
    SELECT p.id, p.rent, pmt.amount, pmt.transaction_date, a.house_number || ' ' || a.street 
    || ', ' || a.city || ', ' || a.state || ' ' || a.zip_code AS address, t.name
    FROM properties AS p
    WHERE p.id = 1
    JOIN tenants AS t
    ON t.id = p.tenant_id
    JOIN addresses AS a
    ON a.id = p.address_id
    JOIN payments AS pmt
    ON p.id = pmt.property_id
    SQL

    result = query(sql, id)

    format_sql_result_to_list_of_hashes(result)
  end

  def all_properties
    sql = <<~SQL
    SELECT p.name, a.house_number || ' ' || a.street AS address
    FROM properties AS p
    JOIN addresses AS a
    ON a.id = p.address_id
    SQL

    result = query(sql)

    format_sql_result_to_list_of_hashes(result)
  end

  private

  def query(statement, *args)
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