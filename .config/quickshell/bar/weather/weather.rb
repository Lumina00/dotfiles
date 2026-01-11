#!/usr/bin/env ruby

require 'open-uri'
require 'json'

CITY    = ""
API_KEY = ""
CACHE   = "/tmp/weather_full.json"
TTL     = 900 # 15분 캐시

ICONS = {
  "01d" => " ", "01n" => " ",
  "02d" => " ", "02n" => " ",
  "03d" => " ", "03n" => " ",
  "04d" => " ", "04n" => " ",
  "09d" => " ", "09n" => " ",
  "10d" => " ", "10n" => " ",
  "11d" => " ",  "11n" => " ",
  "13d" => " ", "13n" => " ",
  "50d" => " ", "50n" => " ",
}

def icon_for(code)
  ICONS[code] || " "
end

def day_name(ts)
  t = Time.at(ts)
  %w[Sun Mon Tue Wed Thu Fri Sat][t.wday]
end

def fetch_data
  current_raw = URI.open(
    "https://api.openweathermap.org/data/2.5/weather?q=#{CITY}&appid=#{API_KEY}&units=metric"
  ).read
  cur = JSON.parse(current_raw)

  current = {
    "desc"  => cur['weather'][0]['description'],
    "icon"  => icon_for(cur['weather'][0]['icon']),
    "temp"  => cur['main']['temp'].round(1),
    "feels" => cur['main']['feels_like'].round(1),
    "humidity" => cur['main']['humidity'],
    "wind"  => cur['wind']['speed'].round(1),
  }

  forecast_raw = URI.open(
    "https://api.openweathermap.org/data/2.5/forecast?q=#{CITY}&appid=#{API_KEY}&units=metric&lang=kr"
  ).read
  fc = JSON.parse(forecast_raw)

  hourly = fc['list'].first(8).map do |h|
    t = Time.at(h['dt'])
    {
      "time" => t.strftime("%H:%M"),
      "icon" => icon_for(h['weather'][0]['icon']),
      "temp" => h['main']['temp'].round(1),
      "desc" => h['weather'][0]['description'],
      "pop"  => (h['pop'] * 100).round,
    }
  end

  by_date = {}
  fc['list'].each do |h|
    date = Time.at(h['dt']).strftime("%m/%d")
    by_date[date] ||= { "temps" => [], "icons" => [], "pops" => [], "descs" => [], "dt" => h['dt'] }
    by_date[date]["temps"] << h['main']['temp']
    by_date[date]["icons"] << h['weather'][0]['icon']
    by_date[date]["pops"]  << h['pop']
    by_date[date]["descs"] << h['weather'][0]['description']
  end

  daily = by_date.map do |date, v|
    day_icons = v["icons"].select { |i| i.end_with?("d") }
    rep_icon = (day_icons.empty? ? v["icons"] : day_icons)
                 .group_by(&:itself).max_by { |_, g| g.size }[0]
    rep_desc = v["descs"].group_by(&:itself).max_by { |_, g| g.size }[0]
    {
      "date"    => date,
      "day"     => day_name(v["dt"]),
      "icon"    => icon_for(rep_icon),
      "tempMin" => v["temps"].min.round(1),
      "tempMax" => v["temps"].max.round(1),
      "pop"     => (v["pops"].max * 100).round,
      "desc"    => rep_desc,
    }
  end

  result = {
    "current" => current,
    "hourly"  => hourly,
    "daily"   => daily,
  }

  File.write(CACHE, JSON.generate(result))
  result
end

def run
  if File.exist?(CACHE) && (Time.now - File.stat(CACHE).mtime) < TTL
    puts File.read(CACHE)
  else
    begin
      data = fetch_data
      puts JSON.generate(data)
    rescue => e
      if File.exist?(CACHE)
        puts File.read(CACHE)
      else
        fallback = {
          "current" => { "desc" => "N/A", "icon" => " ", "temp" => 0, "feels" => 0, "humidity" => 0, "wind" => 0 },
          "hourly"  => [],
          "daily"   => [],
        }
        puts JSON.generate(fallback)
      end
      $stderr.puts "Weather error: #{e.message}"
    end
  end
end

run
