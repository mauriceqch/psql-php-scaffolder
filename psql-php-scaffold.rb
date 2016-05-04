require 'yaml'
require 'pg'

db_config = YAML.load_file('config/database.yml')
puts "Load config..."
puts db_config.inspect

puts "Set connection..."
@conn = PG.connect({dbname: ARGV[0]}.merge db_config)

puts "Print tables..."
def get_tables()
  tables = @conn.exec("SELECT * FROM pg_catalog.pg_tables WHERE schemaname != 'pg_catalog' AND schemaname != 'information_schema'")
  tables.map {|t| t["tablename"]}
end
tables = get_tables
puts tables.inspect

puts "Print tables columns..."
def get_columns(table)
  columns = @conn.exec("SELECT *
                       FROM information_schema.columns
                       WHERE table_schema = 'public'
                       AND table_name   = '#{table}'")
  columns.map {|c| c["column_name"]}
end
schema = {}
tables.each do |t|
  columns = get_columns(t)
  puts columns.inspect
  schema[t] = columns
end

puts "Print schema..."
puts schema.inspect

