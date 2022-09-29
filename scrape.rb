require 'nokogiri'
require 'open-uri'
require 'dotenv/load'
require 'mysql2'
require 'byebug'

def scrape
	begin
	client = Mysql2::Client.new(host: "db09.blockshopper.com", username: ENV['DB09_LGN'], password: ENV['DB09_PWD'], database: "applicant_tests")
	client.query("CREATE TABLE covid_data_safira(
      id INT PRIMARY KEY AUTO_INCREMENT,
      week INT,
      total_spec_test INT,
      total_pos DECIMAL (10, 1),
      0_four_spec_tested INT,
      0_four_pos DECIMAL (10, 1),
      five_17_spec_tested INT,
      five_17_pos DECIMAL (10, 1),
      18_forty9_spec_tested INT,
      18_forty9_pos DECIMAL (10, 1),
      fifty_64_spec_tested INT,
      fifty_64_pos DECIMAL (10, 1),
      over_65_spec_tested INT,
      over_65_pos DECIMAL (10, 1),
      UNIQUE key distinct_key (week));")
	rescue Mysql2::Error
		puts "Table's been created already."
	end

 html = Nokogiri::HTML(URI.open("https://www.cdc.gov/coronavirus/2019-ncov/covid-data/covidview/01152021/specimens-tested.html"))
 table = html.css('tbody tr').map{|el| el.text.split("\n")[1..-1].map{|el| el.gsub(',','')}}
 insert = "INSERT IGNORE INTO covid_data_safira(week, total_spec_test, total_pos, 0_four_spec_tested, 0_four_pos, five_17_spec_tested, five_17_pos, 18_forty9_spec_tested, 18_forty9_pos, fifty_64_spec_tested, fifty_64_pos, over_65_spec_tested, over_65_pos) VALUES "
 table.each do |row|
      insert += "(#{row[0]}, #{row[1]}, #{row[2]}, #{row[3]}, #{row[4]}, #{row[5]}, #{row[6]}, #{row[7]}, #{row[8]}, #{row[9]}, #{row[10]}, #{row[11]}, #{row[12]}),"
end
    client.query(insert.chop!)
  client.close
end
scrape


