# Set up for the application and database. DO NOT CHANGE. #############################
require "sinatra"                                                                     #
require "sinatra/reloader" if development?                                            #
require "sequel"                                                                      #
require "logger"                                                                      #
require "twilio-ruby"                                                                 #
require "bcrypt"
require "geocoder"                                                                      #
connection_string = ENV['DATABASE_URL'] || "sqlite://#{Dir.pwd}/development.sqlite3"  #
DB ||= Sequel.connect(connection_string)                                              #
DB.loggers << Logger.new($stdout) unless DB.loggers.size > 0                          #
def view(template); erb template.to_sym; end                                          #
use Rack::Session::Cookie, key: 'rack.session', path: '/', secret: 'secret'           #
before { puts; puts "--------------- NEW REQUEST ---------------"; puts }             #
after { puts; }                                                                       #
#######################################################################################

destinations_table = DB.from(:destinations)
reviews_table = DB.from(:reviews)
users_table = DB.from(:users)

before do
    @current_user = users_table.where(id: session["user_id"]).to_a[0]
end

### Destinations summary section ###

# homepage and list of destinations (aka "index")
get "/" do
    puts "params: #{params}"

    @destinations = destinations_table.all.to_a
    pp @destinations

    view "destinations"
end

### Locations detail section ###

# location details (aka "show")
get "/location/:id" do
    puts "params: #{params}"

    @location = destinations_table.where(id: params[:id]).to_a[0]
    pp @location
    @users_table = users_table

    results = Geocoder.search(@location[:title])
    lat_long = results.first.coordinates # => [lat, long]
    @coordinates = lat_long[0], lat_long[1]

    @latitude = lat_long[0]
    @longitude = lat_long[1]

    @reviews = reviews_table.where(destinations_id: @location[:id]).to_a
    @local_count = reviews_table.where(destinations_id: @location[:id], local: true).count
    @tourist_count = reviews_table.where(destinations_id: @location[:id], local: false).count
    @reviews_count = reviews_table.where(destinations_id: @location[:id]).count
    @rating_avg = reviews_table.where(destinations_id: @location[:id]).avg(:rating)

    view "location"

end

# display the reviews form (aka "new")
get "/location/:id/reviews/new" do
    puts "params: #{params}"

    @location = destinations_table.where(id: params[:id]).to_a[0]
    view "new_review"
end

# receive the submitted reviews form (aka "create")
post "/location/:id/reviews/create" do
    puts "params: #{params}"

    # first find the location that you are leaving a comment on
    @location = destinations_table.where(id: params[:id]).to_a[0]

    # next we want to insert a row in the reviews table with the reviews form data
    reviews_table.insert(
        destinations_id: @location[:id],
        user_id: session["user_id"],
        comments: params["comments"],
        local: params["local"],
        rating: params["rating"],
        summary: params["summary"],
        student_name: @current_user[:student_name],
        student_year: @current_user[:student_year],
        student_email: @current_user[:student_email]
    )

    redirect "/location/#{@location[:id]}"
end

### Users logic section ###

# display the signup form (aka "new")
get "/users/new" do
    view "new_user"
end

# receive the submitted signup form (aka "create")
post "/users/create" do
    puts "params: #{params}"

    # if there's already a user with this email, skip!
    existing_user = users_table.where(student_email: params["email"]).to_a[0]
    if existing_user
        view "error"
    else
        users_table.insert(
            student_name: params["name"],
            student_email: params["email"],
            student_year: params["student_year"],
            password: BCrypt::Password.create(params["password"])
        )

        redirect "/logins/new"
    end
end

# display the login form (aka "new")
get "/logins/new" do
    view "new_login"
end

# receive the submitted login form (aka "create")
post "/logins/create" do
    puts "params: #{params}"

    # step 1: user with the params["email"] ?
    @user = users_table.where(student_email: params["email"]).to_a[0]

    if @user
        # step 2: if @user, does the encrypted password match?
        if BCrypt::Password.new(@user[:password]) == params["password"]
            # set encrypted cookie for logged in user
            session["user_id"] = @user[:id]
            redirect "/"
        else
            view "create_login_failed"
        end
    else
        view "create_login_failed"
    end
end

# logout user
get "/logout" do
    # remove encrypted cookie for logged out user
    session["user_id"] = nil
    # redirect "/logins/new"
    view "logout"
end