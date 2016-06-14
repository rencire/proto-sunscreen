require 'amazon/ecs'

Amazon::Ecs.configure do |options|
  options[:AWS_access_key_id] = ENV['AWS_ACCESS_KEY_ID']
  options[:AWS_secret_key] = ENV['AWS_SECRET_ACCESS_KEY']
  options[:associate_tag] = 'tag'
end


resp = Amazon::Ecs.item_lookup("B00FBEYLDW")
item = resp.get_element("Item")

puts resp.marshal_dump
puts item
