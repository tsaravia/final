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
  foreign_key :user_id
  Boolean :local
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
reviews_table = DB.from(:reviews)

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

reviews_table.insert(destinations_id: 1,
                    user_id: 0,
                    local: true,
                    summary: "Amazing place!",
                    rating: "4.6",
                    comments: "Bariloche is a great place for outdoorsy and nature-driven people. When there, go to a hike in the Frey mountain, and for dinner don't leave without going to El Boliche de Alberto.",
                    student_name: "Martin Saravia",
                    student_year: "2021",
                    student_email: "martin@example.com.ar")

reviews_table.insert(destinations_id: 1,
                    user_id: 1,
                    local: false,
                    summary: "Bariloche has great skiing in winter, awesome rafting in summer",
                    rating: "4.8",
                    comments: "No matter what time of year you’re there, Bariloche’s got something to offer. During winter months, Mount Cathedral offers some of the best skiing in the nation, while during the warmer seasons the area’s many lakes and rivers offer numerous rafting and other outdoor activities, including horseback riding, paragliding, zip-lining, kayaking, and more.",
                    student_name: "John Doe",
                    student_year: "2020",
                    student_email: "john@example.com")

reviews_table.insert(destinations_id: 2,
                    user_id: 1,
                    local: false,
                    summary: "Bariloche has great skiing in winter, awesome rafting in summer",
                    rating: "4.8",
                    comments: "No matter what time of year you’re there, Bariloche’s got something to offer. During winter months, Mount Cathedral offers some of the best skiing in the nation, while during the warmer seasons the area’s many lakes and rivers offer numerous rafting and other outdoor activities, including horseback riding, paragliding, zip-lining, kayaking, and more.",
                    student_name: "John Doe",
                    student_year: "2020",
                    student_email: "john@example.com")

puts "Success!"
