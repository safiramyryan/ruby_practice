require 'mysql2'
require 'dotenv/load'
require 'digest'
require_relative 'methods.rb'
client = Mysql2::Client.new(host: "db09.blockshopper.com", username: ENV['DB09_LGN'], password: ENV['DB09_PWD'], database: "applicant_tests")

#get_teacher(1, client)
#get_subject(3,client)
#get_class(1, client)
get_teachers_list_by_letter("a",client)
client.close