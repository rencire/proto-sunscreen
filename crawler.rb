#!/usr/bin/ruby

require 'nokogiri'
require 'open-uri'
require 'json'

data_hash = {}
url_base = 'https://www.ewg.org/sunscreen/about-the-sunscreens/'
(0...117).each do |i|
  num = i * 12
  url = "https://www.ewg.org/sunscreen/about-the-sunscreens/?order=score%20INC&start=#{num}"

  begin
    html = Nokogiri::HTML.parse(open(url))
  rescue
    return
  end

  html.xpath("//a").each do |elem|
    href = elem.get_attribute('href')
    next unless href

    match = href.match(/#{url_base}\/\/?([0-9]+)/)
    next unless match

    product_id = match[1]

    begin
      product_html = Nokogiri::HTML.parse(open(href))
    rescue
      next
    end

    score_elem = product_html.css("a[href^=\"#score\"] img")[0]
    score_img_src = score_elem.get_attribute('src')

    amazon_link_elem = product_html.css("#buy_left a")[0]
    if amazon_link_elem
      amazon_link = amazon_link_elem.get_attribute('href')
      amazon_link_match = amazon_link.match(/amazon.com\/dp\/([^\/?]+)/)
    end

    product_name_elem = product_html.css("h1.tyty2015_class_truncate_title_specific_product_page")[0]

    health_concerns_elem = product_html.css(".tyty2015_class_gage_2 img[src$=\"_health_concern.png\"]")[0]
    uva_balance_elem = product_html.css(".tyty2015_class_gage_2 img[src$=\"_uva_balance.png\"]")[0]

    data = {
      product_name: product_name_elem.content,
      score_img: score_img_src,
      score: score_img_src.match(/score_([0-9]+)\.gif/)[1],
      purchase_link: amazon_link,
    }

    if amazon_link_match
      data[:amazon_id] = amazon_link_match[1]
    end

    if health_concerns_elem
      data[:health_concerns_img] = health_concerns_elem.get_attribute('src')
      data[:health_concerns] = health_concerns_elem.get_attribute('src').match(/dial_([0-9]+)_health_concern.png/)[1]
    end

    if uva_balance_elem
      data[:uva_balance_img] = uva_balance_elem.get_attribute('src'),
      data[:uva_balance] = uva_balance_elem.get_attribute('src').match(/dial_([0-9]+)_uva_balance.png/)[1]
    end

    data_hash[product_id] = data
  end
end

File.open("data.json","w") do |f|
  f.write(data_hash.to_json)
end
