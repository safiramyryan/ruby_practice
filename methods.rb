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