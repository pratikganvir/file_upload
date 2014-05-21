# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  name                   :string(255)
#  created_at             :datetime
#  updated_at             :datetime
#  email                  :string(255)      default("")
#  encrypted_password     :string(255)      default(""), not null
#  reset_password_token   :string(255)
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0)
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string(255)
#  last_sign_in_ip        :string(255)
#  confirmation_token     :string(255)
#  confirmed_at           :datetime
#  confirmation_sent_at   :datetime
#  unconfirmed_email      :string(255)
#  authentication_token   :string(255)
#  age_range              :string(255)
#  status                 :string(255)      default("Inactive")
#

class User < ActiveRecord::Base
 

  devise :database_authenticatable, :registerable,:confirmable,:validatable,
    :recoverable, :rememberable, :trackable, :validatable, :omniauthable

  validates_presence_of :email
  validate :password_complexity
  validate :name_valid_format , :if => :new_record?
  validates_presence_of :name

  has_many :authorizations, :dependent=>:destroy
  has_one :role, :dependent=>:destroy


  after_save :create_role
  
  acts_as_token_authenticatable

  AGE_OPTIONS = {
    "Below 18"=>"Below 18",
    "19-24"=>"19-24",
    "25+"=>"25+"
  }

  SELECTED_AGE_OPTION= {
    "Below 18"=>"Below 18"
  }


  EXISTING_ACCOUNT = 'This account is already registered with another user.'


  before_save :ensure_authentication_token!
  before_save :set_age_range_if_25



 
  #--
  # Created By: Chaitali Khangar
  # Purpose: To set age range if 25 came from api
  # Created On: 07/05/2014
  #++
  def set_age_range_if_25
    self.age_range = self.age_range == 25.to_s ? "25+" : self.age_range
  end

  #--
  # Created By: Chaitali Khangar
  # Purpose: To generate secure token string
  # Created On: 05/05/2014
  #++
  def generate_secure_token_string
    SecureRandom.urlsafe_base64(25).tr('lIO0', 'sxyz')
  end

  #--
  # Created By: Chaitali Khangar
  # Purpose: To ensure authentication token
  # Created On: 05/05/2014
  #++
  def ensure_authentication_token!
    if authentication_token.blank?
      self.authentication_token = generate_authentication_token
    end
  end


  #--
  # Created By: Chaitali Khangar
  # Purpose: To generate authentication token
  # Created On: 05/05/2014
  #++

  def generate_authentication_token
    loop do
      token = generate_secure_token_string
      break token unless User.where(:authentication_token=>token).first
    end
  end

  #--
  # Created By: Chaitali Khangar
  # Purpose: To reset authentication token
  # Created On: 05/05/2014
  #++

  def reset_authentication_token!
    self.authentication_token = generate_authentication_token
    self.save!
  end

  #--
  # Created By: Chaitali Khangar
  # Purpose: To check validation for name
  # Created On: 18/04/2014
  #++

  def name_valid_format
    if name.present? and not name.match(/[\w]+([\s]+[\w]+){1}+/)
      errors.add :name , "must be seperated by space and should not contain any special characters."
    end
  end


  #--
  # Created By: Chaitali Khangar
  # Purpose: To check password complexity
  # Created On: 18/04/2014
  #++
  def password_complexity
    if password.present? and not password.match(/(?=.*\d)(?=.*[a-z])(?=.*[A-Z])/)
      errors.add :password, "must include at least one lowercase letter, one uppercase letter, and one digit"
    end
  end


  #--
  # Created By: Chaitali Khangar
  # Purpose: To create new session
  # Created On: 22/04/2014
  #++

  def self.new_with_session(params,session)
    if session["devise.user_attributes"]
      new(session["devise.user_attributes"],without_protection: true) do |user|
        user.attributes = params
        user.valid?
      end
    else
      super
    end
  end


  def create_role
    role = Role.where(:user_id=>self.id)
    role = role.first || (self.build_role && self.save)
  end

  #--
  # Created By: Chaitali Khangar
  # Purpose: To create authorization by provider
  # Created On: 22/04/2014
  #++

  def self.from_omniauth(auth, current_user)
    authorization = Authorization.where(:provider => auth.provider, :uid => auth.uid.to_s)
    if authorization.first.present? && current_user
      message = EXISTING_ACCOUNT if authorization.first.user_id != current_user.id
      return message
    end
    unless authorization.first.present?
      authorization = Authorization.new(:provider => auth.provider, :uid => auth.uid.to_s,:token=>auth.credentials.token)
      if authorization.user.blank?
        user = current_user.nil? ? User.where('email = ?', auth["info"]["email"]).first : current_user
        if user.blank?
          user = User.new
          user.password = Devise.friendly_token[0,10]
          user.name = auth.info.name
          user.email = auth.info.email
          auth.provider == "twitter" ?  user.save(:validate => false) :  user.skip_confirmation! && user.save
        end
        user.age_range =  (auth.provider== "facebook" && auth.extra.raw_info && auth.extra.raw_info.birthday.present?  ?  User.calculate_age_range(Date.strptime(auth.extra.raw_info.birthday,'%m/%d/%Y')) : nil)
        user.skip_confirmation!
        user.save!
     
        authorization.user_id = user.id
        authorization.secret = auth.credentials.secret
        authorization.save
      end
    else
      authorization = authorization.first
      authorization.token = auth.credentials.token
      authorization.secret = auth.credentials.secret
      authorization.save
    end
    authorization
  end


  #--
  # Created By: Chaitali Khangar
  # Purpose: To calculate age range
  # Created On: 22/04/2014
  #++
  def self.calculate_age_range(user_age)
    current_year = Date.today.strftime("%Y")
    user_year = user_age.strftime("%Y")
    age = current_year.to_i - user_year.to_i
    return "Below 18" if age.between?(0,18)
    return "19-24" if age.between?(19,24)
    return "25+" if age > 24
  end
  
  #--
  # Created By: Chaitali Khangar
  # Purpose: To save email
  # Created On: 29/04/2014
  #++
  def self.save_email_address(params)
    user = User.find(params[:user][:id])
    user.email = params[:user][:email]
    user
  end


  #--
  # Created By: Chaitali Khangar
  # Purpose: To generate password randomely
  # Created On: 5/5/2014
  #++

  def generate_password
    password = [('a'..'z'), ('A'..'Z'),(0..9)].map { |i| i.to_a }.flatten
    (8...32).map { password[rand(password.length)] }.join
  end

  #--
  # Created By: Chaitali Khangar
  # Purpose: To check token
  # Created On: 5/5/2014
  #++
  def self.confirm_by_token(confirmation_token)
    original_token     = confirmation_token
    confirmation_token = confirmation_token #Devise.token_generator.digest(self, :confirmation_token, confirmation_token)
    
    confirmable = find_or_initialize_with_error_by(:confirmation_token, confirmation_token)
    confirmable.confirm! if confirmable.persisted?
    confirmable.confirmation_token = original_token
    confirmable

  end

    #--
  # Created By: Chaitali Khangar
  # Purpose: To check user is admin or not
  # Created On: 5/5/2014
  #++
  def is_admin?
   self.role.role_name == "Admin"
  end

    #--
  # Created By: Chaitali Khangar
  # Purpose: To get normal users
  # Created On: 5/5/2014
  #++
  def self.get_normal_user
    includes(:role).where("roles.role_name=?", "User")
  end


      #--
  # Created By: Chaitali Khangar
  # Purpose: To get admin users
  # Created On: 5/5/2014
  #++
  def self.get_admin_user
    includes(:role).where("roles.role_name=?", "Admin")
  end

      #--
  # Created By: Chaitali Khangar
  # Purpose: To check inactivge user
  # Created On: 5/5/2014
  #++
  def inactive_user?
    self.status == "Inactive"
  end

  def set_admin_role
    self.build_role(:role_name => "Admin")
    self.save
  end

  def set_normal_user_role
    self.build_role(:role_name => "User")
    self.save
  end
end
