require "google/cloud/datastore"
require "icalendar"

$datastore = Google::Cloud::Datastore.new

class Contest
  attr_accessor :title, :url, :start_date, :end_date, :rating

  def initialize
    @title = ""
    @url = ""
    @start_date = nil
    @end_date = nil
    @rating = ""
  end

  def self.find(params)
    params = {
      "type" => ["abc", "agc", "unknown"],
      "rating" => nil,
    }.merge(params)

    query = $datastore.query("Contest")

    $datastore.run(query)
      .map { |e| self::from_entity(e) }
      .select { |c| params["type"].empty? || params["type"].include?(c.type) }
      .select { |c| params["rating"] == nil || c.rate_range&.include?(params["rating"].to_i)}
  end

  def self.exists?(url)
    query = $datastore.query("Contest").
      where("url", "=", url)
    $datastore.run(query).size >= 1
  end

  def self.from_entity(entity)
    contest = Contest.new

    contest.url = entity["url"]
    contest.title = entity["title"]
    contest.start_date = entity["start_date"]
    contest.end_date = entity["end_date"]
    contest.rating = entity["rating"]

    contest
  end

  def self.from_doc(doc, url)
    contest = Contest.new

    duration = doc.css(".contest-duration time")

    contest.url = url
    contest.title = doc.css(".contest-title").text
    contest.start_date = DateTime.parse(duration[0].text)
    contest.end_date = DateTime.parse(duration[1].text)
    contest.rating = doc.css(".col-sm-12 .mr-2")[1].text.split(":")[1]

    contest
  end

  def save
    task = $datastore.entity "Contest" do |t|
      t["url"] = @url
      t["title"] = @title
      t["start_date"] = @start_date
      t["end_date"] = @end_date
      t["rating"] = @rating
    end

    $datastore.save task
  end

  def to_event
    event = Icalendar::Event.new
    event.dtstart = @start_date
    event.dtend = @end_date
    event.summary = @title
    event.description = @url

    event
  end

  def type
    case @title
    when /AtCoder Beginner Contest/i then
      "abc"
    when /AtCoder Grand Contest/i then
      "agc"
    else
      "unknown"
    end
  end

  def rate_range
    if not (@rating =~ /(\d*)\s*~\s*(\d+)/) then
      return nil
    end

    lower = ($1 || 0).to_i
    upper = $2.to_i
    (lower..upper)
  end
end