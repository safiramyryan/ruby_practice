def get_teacher(id,client)
	v = <<~SQL 
	select first_name, middle_name, last_name, birth_date
	from teachers_safira
	where ID = #{id}
SQL

r = client.query(v).to_a
if r.count.zero?
	puts "Teacher with ID #{id} was not found"
else
	puts "Teacher #{r[0]['first_name']} #{r[0]['middle_name']} #{r[0]['last_name']} was born on #{(r[0]['birth_date']).strftime("%d %b %Y (%A)")}"
	end
end
  
 def get_subject(id, client)

 v = <<~SQL
 	SELECT s.name, t.first_name, t.middle_name, t.last_name
 	FROM subjects_safira s
 	 JOIN teachers_safira t ON s.id=t.subject_id
 	 where s.id = #{id};
SQL

r = client.query(v).to_a
if r.count.zero?
	"Not found subject"
else
	rs = "Subject: #{r[0]['name']}\nTeacher(s):"
	r.each do |row|
		rs+="\n#{row['first_name']} #{row['middle_name']} #{row['last_name']}"
	end
end
puts rs if rs
end 

def get_class(id,client)
	v = <<~SQL
	 SELECT c.name Class, s.name subject, t.first_name, t.middle_name, t.last_name
	 from subjects_safira s 
	 join teachers_safira t ON t.subject_id= s.id
     JOIN teachers_classes_safira tc ON tc.teacher_id = t.id
     JOIN classes_safira c ON tc.class_id = c.id where c.id =#{id}
SQL
 
r = client.query(v).to_a
if r.count.zero?
	puts"Not found class"
else
	rs = "Class: #{r[0]['class']}\nSubjects:"
	r.each do |row| 
	rs+="\n#{row['subject']}(#{row['first_name']} (#{row['middle_name'][0]}" + "." +" #{row['last_name']}"
   end
end
puts rs if rs
end

def get_teachers_list_by_letter(letter,client)
v = <<~SQL
	SELECT s.name subject, t.first_name, t.middle_name, t.last_name
FROM subjects_safira s 
JOIN teachers_safira t ON t.subject_id=s.id
	WHERE (t.first_name like "%#{letter}%" or t.last_name like "%#{letter}%")
SQL

r = client.query(v).to_a

if r.count.zero?
 puts "Match not found"
else 
	rs = ""
	r.each do |row|
	rs+= "#{row['first_name'][0]}. #{row['middle_name'][0]}.#{row['last_name']} (#{row['subject']})\n"
  end

end
puts rs.strip if rs
end

#=============#

def set_md5 (client)
 	v = <<~SQL 
 	SELECT id,first_name,middle_name,last_name,subject_id
 	FROM teachers_safira
SQL

source = client.query(v)

source.each do |row|
	 x = Digest::MD5.hexdigest "#{row['first_name']}#{row['middle_name']}#{row['last_name']} #{row['birth_date']} #{row['subject_id']}"
 	j = <<~SQL
	UPDATE teachers_safira SET md5 = "#(x)" where id = #{row['id']}
SQL
client.query(j)
 end
end 

def get_class_info(id,client)
v = <<~SQL
SELECT c.name CLass, t.first_name , t.middle_name , t.last_name, c.responsible_id
FROM subjects_safira s 
JOIN teachers_safira t ON t.subject_id = s.id
  join teachers_classes_safira tc ON tc.teacher_id = t.id 
  join classes_safira c ON tc.class_id = c.id where c.id = #{id};
SQL

results = client.query(v).to_a

if results.count.zero?
	puts "Not found"
else 
 res = "Class name: #{results[0]['class']}\nResponsible.teacher:"
 responsible_teacher = results.find { |el| el['id'] ==el['r_id'] }
 res += " #{responsible_teacher['first_name']} #{responsible_teacher['middle_name']}"
 results.each do |row|
 	res += "#{row['first_name']} #{row['middle_name']} #{row['last_name']},"
  end 
  puts res.strip.chop!
 end
end

def get_teachers_by_year(year, client)
t = <<~SQL
SELECT first_name, middle_name, last_name FROM teachers_safira WHERE year(birth_date) = #{year}
SQL

results = client.query(t).to_a

if results.count.zero?
	puts "Not found"
else 
res = "Teachers born in #{year}:"
results.each do |row| 
res += " #{row['first_name']} #{row['middle_name']} #{row['last_name']},"
     end
puts res.chop! + "."
   end
end
def random_date(date_begin, date_end)
 rand(Date.parse(date_begin) ..Date.parse(date_end))
end 
#random last names

def random_last_names(n,client)

rl = <<~SQL
SELECT last_name FROM last_name;
SQL

@last_name = @last_names ? @last_names : client.query(rl).to_a.map { |el| el['last_name']}
result = []
n.times do 
 result << @last_names.sample
   end
result
end

def random_first_name(n,client)
 rf = <<~SQL
 SELECT FirstName FROM male_names;
 SQL

 rf2 = <<~SQL
 SELECT names FROM female_names;
SQL

@names = @names ? @names : (client.query(rf).to_a.map { |el| el['FirstName']} + client.query(rf2).to_a.map { |el| el['names']})
result = []
n. times do 
 result << @names.sample
 end 
results
end

#Combination of first names, last names and birth dates generator, given argument.

def people_gen(n, client)
  first_names = random_last_names(n, client)
  last_names  = random_last_names(n, client)
  birth_dates = []
  n.times do
    birth_dates << random_date("1910-01-01","2022-01-01")
  end
  people = []
  first_names.each_with_index do |f_name, i|
    people << {"f_name"=>f_name,"l_name"=>last_names[i],"birth_date"=>birth_dates[i]}
  end
  people.each_slice(20000) do |people_|
    insert = "INSERT INTO random_people_safira (first_name, last_name, birth_date) VALUES ")
    people_.each do |person|
      insert += "(\"#{person['f_name']}\",\"#{person['l_name']}\",\"#{person['birth_date']}\"),"
    end
    client.query(insert.chop!)
  end
  puts "#{people.count} person/people created!"
end