class Course
  include Mongoid::Document

  field :semestr, type: String
  field :code, type: String
  field :date, type: Date
  field :title, type: String
  field :ds, type: String
  field :role, type: String
  field :credits, type: String
  field :termination, type: String
  field :finished, type: Boolean
  field :zapocet, type: Boolean
  field :zapocet_on, type: Date
  field :zapocet_by, type: String
  field :grade, type: String
  field :grade_by, type: String
  field :grade_on, type: Date
  field :last_change, type: String

  def self.parse_html(html)
    course = {}
    parsed = html.css("td")
    course[:semestr] = parsed[0].inner_html.strip
    course[:date] = parsed[1].inner_html.strip
    course[:code] = parsed[2].css("a").inner_html.strip
    course[:title] = parsed[3].css("a").inner_html.strip
    course[:ds] = parsed[4].inner_html.strip
    course[:role] = parsed[5].inner_html.strip
    course[:credits] = parsed[6].inner_html.strip
    course[:termination] = parsed[7].inner_html.strip
    course[:finished] = parsed[8].inner_html.strip == "A" ? true : false
    course[:zapocet] = parsed[9].inner_html.strip == "Z" ? true : false
    course[:zapocet_by] = parsed[9].attribute("title").value == "" ? "" : parsed[9].attribute("title").value.split("] [")[1].gsub("]","")
    course[:zapocet_on] = parsed[9].attribute("title").value == "" ? "" : parsed[9].attribute("title").value.split("] [")[0].gsub("[","")
    course[:grade] = parsed[10].inner_html.strip
    course[:grade_by] = parsed[10].attribute("title").value == "" ? "" : parsed[10].attribute("title").value.split("] [")[1].gsub("]","")
    course[:grade_on] = parsed[10].attribute("title").value == "" ? "" : parsed[10].attribute("title").value.split("] [")[0].gsub("[","")
    course[:last_change] = parsed[11].attribute("title").value
    return course
  end
end