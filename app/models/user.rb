class User < ApplicationRecord
    validates :username, presence: :true, uniqueness: :true, length: { in: 3..20 }
    validates :email, presence: :true, uniqueness: :true, format: { with: URI::MailTo::EMAIL_REGEXP } 
    has_many :dreams, dependent: :destroy
    has_many :dream_symbolisms, through: :dreams
    has_many :symbolisms, through: :dream_symbolisms
    validates :password_confirmation, presence: true
    validate :password_complexity
    has_secure_password
  
    def password_complexity
      # Regexp extracted from https://stackoverflow.com/questions/19605150/regex-for-password-must-contain-at-least-eight-characters-at-least-one-number-a
      return if password.blank? || password =~ /^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[#?!@$%^&*-]).{8,70}$/
  
      errors.add :password, 'Complexity requirement not met. Length should be 8-70 characters and include: 1 uppercase, 1 lowercase, 1 digit and 1 special character'
    end

    def self.find_or_create_by_auth_hash(auth_hash)
        #If the user is already in the db
        if self.find_by(email: auth_hash['info']['email']) 
            #return the user
            self.find_by(email: auth_hash['info']['email'])
        else 
            #creating a username to assign to new user
            username = self.find_unique_username(auth_hash['info']['name'])
            #create and return new user
            pass = SecureRandom.hex
            self.create(email: auth_hash['info']['email'], username: username, password: pass, password_confirmation: pass )
        end
    end

    # https://alexcastano.com/generate-unique-usernames-for-ruby-on-rails/
    # ^^^ Link to where I found inspiration for this method ^^^
    def self.find_unique_username(name)
        username = name.parameterize(separator: '_')
        #An array of usernames similar to the parameterized version of the name 
        # e.g; name = "John Doe", this might return ["john_doe", "john_doe_1", "john_doe44"] <-usernames in db
        taken_usernames = User.where("username LIKE ?", "#{username}%").pluck(:username)
  
        count = 1
        #If the username is identical to one of the names in the database loop until a unique name is found
        while taken_usernames.include?(username)
            #reseting the username because I only want to add _#{count} to the end, without this username
            #would start to look like "user_1_2" "user_1_2_3" ect...
            username = name.parameterize(separator: '_')
            username = "#{username}_#{count}"
            count += 1
        end 
        username
      end

end
