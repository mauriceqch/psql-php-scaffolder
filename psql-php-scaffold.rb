require 'yaml'
require 'pg'
require 'fileutils'
require 'erb'

db_config = YAML.load_file('config/database.yml')
puts "Load config..."
puts db_config.inspect

puts "Set connection..."
@dbname = ARGV[0]
@conn = PG.connect({dbname: @dbname}.merge db_config)

puts "Print tables..."
def get_tables()
  tables = @conn.exec("SELECT * FROM pg_catalog.pg_tables WHERE schemaname != 'pg_catalog' AND schemaname != 'information_schema'")
  (tables.select {|v| v["tablename"] != "schema_migrations"}).map {|t| t["tablename"]}
end
@tables = get_tables
puts @tables.inspect

puts "Print tables columns..."
@psql_html_data_types = {}
@psql_html_data_types["integer"] = "text"
@psql_html_data_types["boolean"] = "checkbox"
@psql_html_data_types["double precision"] = "text"
@psql_html_data_types["timestamp without time zone"] = "datetime-local"
@psql_html_data_types["date"] = "date"
@psql_html_data_types["character varying"] = "text"
@psql_html_data_types["text"] = "text"
 
def get_columns(table)
  columns = @conn.exec("SELECT *
                       FROM information_schema.columns
                       WHERE table_schema = 'public'
                       AND table_name   = '#{table}'")
  # Supported data types :
  # "integer"
  # "boolean"
  # "double precision"
  # "timestamp without time zone"
  # "date"
  # "character varying"
  # "text"
  columns.map {|c| {"column_name" => c["column_name"], "data_type" => @psql_html_data_types[c["data_type"]]}}
end
schema = {}
@tables.each do |t|
  columns = get_columns(t)
  puts columns.inspect
  schema[t] = columns
end

puts "Print schema..."
puts schema.inspect

puts "Render views..."
@templates = %w{new create edit update index show destroy}
@partials = %w(form)
def read_template(filename)
  File.read("./templates/#{filename}.php.erb")
end
def render(table_name, columns)
  @table_name = table_name
  @columns = columns
  @templates.each do |v|
    @partial = ERB.new(read_template(v)).result()
    @view = ERB.new(read_template('layout')).result()
    folder = "./output"
    filename = "#{folder}/#{table_name}_#{v}.php"
    puts "Render #{filename}"
    FileUtils.mkdir_p folder
    File.write(filename, @view)
  end
  @partials.each do |v|
    @partial = ERB.new(read_template(v)).result()
    folder = "./output"
    filename = "#{folder}/#{table_name}_#{v}.php"
    puts "Render #{filename}"
    FileUtils.mkdir_p folder
    File.write(filename, @partial)
  end
end
FileUtils.rm_rf('./output', secure: true)
schema.each do |table_name, columns|
  puts table_name, columns
  render(table_name, columns)
end

others = %w(menu db-connect)
others.each do |o|
  puts "Rendering #{o}.php.erb"
  @view = ERB.new(read_template(o)).result()
  folder = "./output"
  filename = "#{folder}/#{o}.php"
  FileUtils.mkdir_p folder
  File.write(filename, @view)
end
