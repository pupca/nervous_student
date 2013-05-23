class User
  include Mongoid::Document
  embeds_many :courses

  field :email, type: String
  field :login, type: String
  field :password, type: String
  field :phone, type: String
  field :phone_notification, type: Boolean, default: true
  field :email_notification, type: Boolean, default: true
  field :setup, type: Boolean, default: false
  field :last_update, type: DateTime, default: Time.now

  validates_uniqueness_of :login

  def self.login(login, password)
    user = User.find_by(:login => login)
    if user
      if user.password == password
        return user
      else
        return "password"
      end
    else
      kos = Kos.new
      courses = kos.get_courses(login, password)
      if courses.empty?
        return "no_courses"
      else
        user = User.new(:login => login, :password => password)
        user.courses = courses
        user.save
        return user
      end
    end
  end

  def update_and_notify_course(old_course, new_course)
    old_course.last_change = "bbb"
    old_course.save

  end

  def create_and_notify_courses(new_courses)
    new_courses.each do |course|
      self.courses << course
    end
    self.safe
    #send email
  end

  def update_courses
    new_courses = []
    kos_courses = Kos.new.get_courses(self.login, self.password)

    kos_courses.last[:last_change] = "Popelak"
    kos_courses.last[:grade] = "D"

    if kos_courses.empty?
      #login failed or no courses found
    else
      kos_courses.each do |new_course|
        match = self.courses.to_a.find{|course| course.code == new_course[:code] && course.semestr == new_course[:semestr] }
        if match
          unless match.last_change == new_course[:last_change]
            #change in course
            ap "change in course"
            update_and_notify_course(match, new_course)
          end
        else
          new_courses << new_course
        end
      end
      self.create_and_notify_courses(new_courses) unless new_courses.empty?
      self.update_attribute(:last_update, Time.now)
    end
  end
end