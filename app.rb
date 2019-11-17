require "sinatra"
require "sinatra/reloader" if development?
require "icalendar"
require "./lib/models.rb"
require "./lib/crawler.rb"

get "/" do
  send_file "views/index.html"
end

get "/crawl" do
  crawler = Crawler.new
  crawler.start
  return
end

get "/calendar" do
  params["type"] = (params["type"] || "").split(",")
  contests = Contest::find(params)

  cal = Icalendar::Calendar.new

  contests.each do |c|
    cal.add_event(c.to_event)
  end

  content_type "text/calendar"
  return cal.to_ical
end