require "mysql2"
client = Mysql2::Client.new(:host =>"localhost", 
                        :username => "root",
                        :database => "students")


def select_method(client)
  res = client.query("SELECT * FROM people_safira;").to_a
  res.each do |row|
    lastname = (row['lastname'] + " edited").gsub(/( edited)\1*/,'\1')
    email  = row['email'].downcase
    email2 = row['email2'].downcase
    profession = row['profession'].strip
    client.query("UPDATE people_safira SET lastname = \"#{lastname}\", email = \"#{email}\", email2 = \"#{email2}\", profession = \"#{profession}\" WHERE id = #{row['id']};" )
  end
end
select_method(client)

client.close
