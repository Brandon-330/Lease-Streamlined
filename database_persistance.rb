require 'pg'

class Database
  def initialize
    @db = PG.connect(dbname: 'rental_management', user: 'postgres', password: 'postgres')
  end

  def all_properties
    sql = <<~SQL
    SELECT p.id, p.rent, a.house_number || ' ' || a.street AS number_and_street, t.name
    FROM properties AS p
    LEFT OUTER JOIN tenants AS t
    ON t.id = p.tenant_id
    JOIN addresses AS a
    ON a.id = p.address_id
    SQL

    result = query(sql)

    result.map do |tuple|
      {
        id: tuple['id'].to_i,
        address: tuple['number_and_street'],
        rent: tuple['rent'].to_f,
        tenant: tuple['name']
      }
    end
  end

  private

  def query(statement, *args)
    @db.exec_params(statement, args)
  end
end