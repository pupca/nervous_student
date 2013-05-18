# encoding: UTF-8
require 'awesome_print'
require 'rubygems'
require 'mechanize'
require 'nokogiri'
require 'net/http'

module Net
  class HTTP < Protocol
    def HTTP.new(address, port = nil, p_addr = nil, p_port = nil, p_user = nil, p_pass = nil)
      socket = Proxy(p_addr, p_port, p_user, p_pass).newobj(address, port)
      socket.ssl_version = "SSLv3"
      socket
    end
  end
end

class Course
  def initialize(raw_html)
    parse_html(raw_html)
  end
  def parse_html(html)
    parsed = html.css("td")
    @semestr = parsed[0].inner_html.strip
    @datum = parsed[1].inner_html.strip
    @code = parsed[2].css("a").inner_html.strip
    @title = parsed[3].css("a").inner_html.strip
    @ds = parsed[4].inner_html.strip
    @role = parsed[5].inner_html.strip
    @credits = parsed[6].inner_html.strip
    @termination = parsed[7].inner_html.strip
    @finished = parsed[8].inner_html.strip
    @zapocet = parsed[9].inner_html.strip == "Z" ? true : false
    @zapocet_by = parsed[9].attribute("title").value == "" ? "" : parsed[9].attribute("title").value.split("] [")[1].gsub("]","")
    @zapocet_on = parsed[9].attribute("title").value == "" ? "" : parsed[9].attribute("title").value.split("] [")[0].gsub("[","")
    @grade = parsed[10].inner_html.strip
    @grade_by = parsed[10].attribute("title").value == "" ? "" : parsed[10].attribute("title").value.split("] [")[1].gsub("]","")
    @grade_on = parsed[10].attribute("title").value == "" ? "" : parsed[10].attribute("title").value.split("] [")[0].gsub("[","")
    @last_change = parsed[11].attribute("title").value
  end
end

agent = Mechanize.new { |a|
  a.follow_meta_refresh = true
}

page = agent.get('https://kos.cvut.cz/kos/login.do')
form = page.form('login')
form.userName = ARGV[0]
form.password = ARGV[1]
page = agent.submit(form)
page_code = page.content.scan(/var pageCode=\'(\w*)';/).first.first
page =  agent.get("https://kos.cvut.cz/kos/results.do?page=#{page_code}")
doc = Nokogiri::HTML(page.content)
table = doc.at("table tr:nth-child(3) table table tr:nth-child(7) table")
courses = []
table.css("tr.tableRow1, tr.tableRow2").each {|course| courses << Course.new(course)}