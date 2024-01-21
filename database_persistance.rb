require 'pg'

class Database
  def initialize
    @db = PG.connect(dbname: 'rental_management', user: 'postgres', password: 'postgres')
  end

  def all_apartments
  end

  private

  def query(statement, *args)
    @db.exec_params(statement, args)
  end
end