require 'bundler'
Bundler.require

# open
db = SQLite3::Database.new 'test.db'

rows = db.execute <<-SQL
  create table numbers (
    name varchar(30),
    val int
  );
SQL

vals = {
  'one' => 1,
  'two' => 2
}

vals.each do |pair|
  p pair
  #db.execute 'insert into number values (?, ?)', pair
end

db.execute('select * from numbers') do |row|
  p row
end

