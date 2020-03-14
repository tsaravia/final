# Set up for the application and database. DO NOT CHANGE. #############################
require "sequel"                                                                      #
connection_string = ENV['DATABASE_URL'] || "sqlite://#{Dir.pwd}/development.sqlite3"  #
DB = Sequel.connect(connection_string)                                                #
#######################################################################################

# Database schema - this should reflect your domain model
DB.create_table! :destinations do
  primary_key :id
  String :title
  String :description, text: true
  String :type
  String :rating
  String :budget
end
DB.create_table! :reviews do
  primary_key :id
  foreign_key :destinations_id
  Boolean :visited
  String :summary
  String :rating
  String :comments, text: true
  String :student_name
  String :student_year
  String :student_email
end
DB.create_table! :users do
  primary_key :id
  String :student_name
  String :student_email
  String :student_year
  String :password
end

# Insert initial (seed) data
destinations_table = DB.from(:destinations)

destinations_table.insert(title: "Bariloche", 
                    description: "Beautiful scenery in the Northern Patagonia with activities for every interest!",
                    type: "Adventure",
                    rating: "4.5/5",
                    budget: "$150 per day")

destinations_table.insert(title: "Mendoza", 
                    description: "Explore the best wine and amazing Argentinean food on the gorgeus valley home of Malbec grapes!",
                    type: "Wine",
                    rating: "3.8/5",
                    budget: "$250 per day")

destinations_table.insert(title: "Buenos Aires", 
                    description: "Inmerse yourself in this vibrant city home of tango, all-night clubs and world-class restaurants",
                    type: "City",
                    rating: "4.9/5",
                    budget: "$100 per day")

puts "Success!"
