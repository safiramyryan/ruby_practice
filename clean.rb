def new_clean_table(client)
	begin
	 	client.query("CREATE TABLE montana_public_district_report_card__uniq_dist_safira (
	       id INT PRIMARY KEY AUTO_INCREMENT,
	       name VARCHAR(255),
	       clean_name VARCHAR(255),
	       address VARCHAR(255),
	       city VARCHAR(255),
	       state VARCHAR(255),
	       zip VARCHAR(20),
	       UNIQUE key distinct_key (name, city, address, state, zip));")
	
	rescue Mysql2::Error
		puts "Table's been created already."
  end
 insertion = <<~SQL
 	insert IGNORE into montana_public_district_report_card__uniq_dist_safira
 		(name, city, address, state, zip)
 		select distinct school_name, city, address, state, zip
 		  from montana_public_district_report_card;
 		 SQL
     client.query(insertion)
    clean = <<~SQL
    SELECT id,name
    from montana_public_district_report_card__uniq_dist_safira
    SQL
    new_clean = client.query(clean).to_a
    new_clean.each do |row|
      clean_name = row['name'].gsub("Elem", "Elementary"
        ).gsub(/H S/, "High School"
        ).gsub(/K-12( Schools)?/, "Public School").gsub(/\b(\w+) \1/i, '\1') + " District"
      client.query("UPDATE montana_public_district_report_card__uniq_dist_safira
                SET clean_name = \"#{clean_name}\" where id = #{row['id']}")
    end
end