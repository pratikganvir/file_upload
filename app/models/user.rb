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
#

class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable

  devise :database_authenticatable, :registerable,
    :recoverable, :rememberable, :trackable, :validatable, :omniauthable

  validates_presence_of :email
  validate :password_complexity
  validate :name_valid_format
  #  validates_format_of :name , :with=>/[\w]+([\s]+[\w]+){1}+/, :if =>  Proc.new { |model| !model.name.blank? }
  validates_presence_of :name

  has_many :authorizations



  AGE_OPTIONS = {
    "Below 18"=>"Below 18",
    "19-24"=>"19-24",
    "25+"=>"25+"
  }

  SELECTED_AGE_OPTION= {
    "Below 18"=>"Below 18"
  }


  #--
  # Created By: Chaitali Khangar
  # Purpose: To check validation for name
  # Created On: 14=8/04/2014
  #++

  def name_valid_format
    if name.present? and not name.match(/[\w]+([\s]+[\w]+){1}+/)
      errors.add :name , "must be seperated by space."
    end
  end


  #--
  # Created By: Chaitali Khangar
  # Purpose: To check password complexity
  # Created On: 14=8/04/2014
  #++
  def password_complexity
    if password.present? and not password.match(/(?=.*\d)(?=.*[a-z])(?=.*[A-Z])/)
      errors.add :password, "must include at least one lowercase letter, one uppercase letter, and one digit"
    end
  end


#  #--
#  # Created By: Chaitali Khangar
#  # Purpose: To create new session
#  # Created On: 22/04/2014
#  #++
#
#  def self.new_with_session(params,session)
#    if session["devise.user_attributes"]
#      new(session["devise.user_attributes"],without_protection: true) do |user|
#        user.attributes = params
#        user.valid?
#      end
#    else
#      super
#    end
#  end


  #--
  # Created By: Chaitali Khangar
  # Purpose: To create authorization by provider
  # Created On: 22/04/2014
  #++

  def self.from_omniauth(auth, current_user)
    authorization = Authorization.where(:provider => auth.provider, :uid => auth.uid.to_s, :token => auth.credentials.token, :secret => auth.credentials.secret).first_or_initialize
    if authorization.user.blank?
      user = current_user.nil? ? User.where('email = ?', auth["info"]["email"]).first : current_user
      if user.blank?
        user = User.new
        user.password = Devise.friendly_token[0,10]
        user.name = auth.info.name
        user.email = auth.info.email        
        auth.provider == "twitter" ?  user.save(:validate => false) :  user.save
      end
      user.age_range =  (auth.provider== "facebook" && auth.extra.raw_info && auth.extra.raw_info.birthday.present?  ?  calculate_age_range(Date.strptime(auth.extra.raw_info.birthday,'%m/%d/%Y')) : nil)
      user.save
      authorization.user_id = user.id
      authorization.save
    end
    authorization.user
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
  
end
