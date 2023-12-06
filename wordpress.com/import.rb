require 'rubygems'
require 'bundler/setup'

Bundler.require(:default)
Dotenv.load

osuny = OsunyApi.new host: ENV['OSUNY_API_HOST'], token: ENV['OSUNY_API_TOKEN']
website = osuny.communication.website ENV['OSUNY_WEBSITE_ID']
migration_identifier_root = ENV['OSUNY_IMPORT_IDENTIFIER']
endpoint = ENV['WORDPRESS_ENDPOINT']

uri = URI endpoint
http = Net::HTTP.new(uri.host, uri.port)
http.use_ssl = true
http.verify_mode = OpenSSL::SSL::VERIFY_NONE
request = Net::HTTP::Get.new(uri.request_uri)
response = http.request(request)
response_parsed = JSON.parse(response.body)
response_parsed['posts'].each do |hash|
  migration_identifier = "#{migration_identifier_root}-post-#{hash['ID']}"
  featured_image = nil
  if hash.has_key?('attachments')
    first_attachement = hash['attachments'].values.first
    featured_image = first_attachement&.dig('URL')
  end
  data = {
    title: hash['title'],
    summary: hash['excerpt'],
    published_at: Time.parse(hash['date']),
    migration_identifier: migration_identifier,
    featured_image: featured_image,
    blocks: [
      {
        template_kind: 'chapter',
        migration_identifier: "#{migration_identifier}-chapter",
        data: {
          text: hash['content']
        }
      }
    ]
  }
  website.post.import data
end