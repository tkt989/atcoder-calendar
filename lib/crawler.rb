
require "nokogiri"
require "open-uri"
require "./lib/models.rb"

class Crawler
  def initialize
    @base = "https://atcoder.jp"
  end

  def get_doc(url)
    html = open(url)
    Nokogiri::HTML.parse(html)
  end

  def start
    url = "#{@base}/home?lang=ja"

    doc = self.get_doc(url)

    doc.css("#contest-table-upcoming tr:has(td)").each do |tr|
      td = tr.css("td a")

      url = "#{@base}#{td[1]["href"]}?lang=ja"

      if Contest::exists?(url) then
        Contest::get_by_url(url).map do |c|
          c.update
        end
        next
      end

      Contest::from_doc(self.get_doc(url), url).save
      sleep(1)
    end
  end
end