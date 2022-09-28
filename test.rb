def escape(str)
  str = str.to_s
  return str if str == ''
  return if str == ''
  str.gsub(/\\/, '\&\&').gsub(/'/, "''")
end
  def test_safira(client)
begin
    client.query("CREATE TABLE hle_dev_safira
    LIKE hle_dev_test_candidates;")
    rescue Mysql2::Error
    puts "Table's been created already."
  else
    alter = <<~SQL
    ALTER TABLE hle_dev_safira
    ADD column clean_name VARCHAR (255),
    add column sentence VARCHAR (400),
    ADD CONSTRAINT name_unique UNIQUE (candidate_office_name);
    SQL
    client.query(alter)
end   
    insertion = <<~SQL
    insert IGNORE INTO hle_dev_safira (candidate_office_name)
      select distinct candidate_office_name from hle_dev_test_candidates
    SQL
    client.query(insertion)
      
  candidates_clean = <<~SQL
  select id, candidate_office_name FROM hle_dev_safira
  -- where clean_name is null
  SQL
  
    new_cands_clean = client.query(candidates_clean).to_a
    if new_cands_clean.count.zero?
  puts "No updates available"
    else
     new_cands_clean.each do |row|
     clean_name = row['candidate_office_name']
     clean_name = clean_name.downcase if clean_name.include?('/')==false && clean_name.include?(',')==false
     clean_name = clean_name.gsub(/\bTwp\b/i, "Township").
     gsub(/\bHwy\b/i, "Highway").gsub('//','/').gsub(/(.+)\/(.+)\/(.+)/) {  "#{$3} #{if $1.
     include?(","); $1.gsub(/(.+), (.+)/) { "#{$1.downcase}#{" (#{$2})"}" }; else; $1.
     downcase; end  } and #{if $2.include?(","); $2.gsub(/(.+), (.+)/,) { "#{$1.
     downcase}#{" (#{$2})"}" }; else; $2.downcase; end  }".gsub(/\b(\w+) \1/i, '\1')  }.
     gsub(/(.+)\/(.+)/) {  "#{$2} #{if $1.include?(",");  $1.gsub(/(.+), (.+)/) { "#{$1.
     downcase}#{" (#{$2})"}" }; else; $1.downcase; end}".gsub(/\b(\w+) \1/i,'\1')}.
     gsub(/(.+), (.+)/) { $1.downcase + " (#{$2})"}.strip.reverse.strip.reverse
     update = "UPDATE hle_dev_safira"\
     " SET clean_name = '#{escape(clean_name)}', sentence = 'The candidate is running for the #{escape(clean_name)} office.' where id = #{row['id']}"
 client.query(update)
end
  end
end

























