class Kos
  def get_courses(login, password)
    courses = []
    agent = Mechanize.new

    page = agent.get('https://kos.cvut.cz/kos/login.do')
    form = page.form('login')
    form.userName = login
    form.password = password
    page = agent.submit(form)
    page_code = page.content.scan(/var pageCode=\'(\w*)';/).first.first
    page =  agent.get("https://kos.cvut.cz/kos/results.do?page=#{page_code}")
    doc = Nokogiri::HTML(page.content)
    table = doc.at("table tr:nth-child(3) table table tr:nth-child(7) table")
    courses = []
    user = User.first
    table.css("tr.tableRow1, tr.tableRow2").each do |course|
      courses << Course.parse_html(course)
    end
    return courses
  end


end