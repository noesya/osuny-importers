require 'rubygems'
require 'bundler/setup'
require_relative 'wordpress_api'

Bundler.require(:default)
Dotenv.load

osuny = OsunyApi.new host: ENV['OSUNY_API_HOST'], token: ENV['OSUNY_API_TOKEN']
website = osuny.communication.website ENV['OSUNY_WEBSITE_ID']

url = 'https://www.iut.u-bordeaux.fr/general'
migration_identifier_root = 'iut.u-bordeaux.fr'
api = WordpressApi.new url

def prepare_data(hash, migration_identifier)
  title = hash['title']['rendered']
  summary = hash['excerpt']['rendered']
  text = hash['content']['rendered']
  puts title
  {
    migration_identifier: migration_identifier,
    title: title,
    summary: summary,
    blocks: [
      {
        template_kind: 'chapter',
        migration_identifier: "#{migration_identifier}-chapter",
        data: {
          text: text
        }
      }
    ]
  }
end

# Pages
api.pages.each do |hash|
  migration_identifier = "#{migration_identifier_root}-page-#{hash['id']}"
  data = prepare_data hash, migration_identifier
  if hash['parent'] != 0
    data[:parent] = {
      migration_identifier: "#{migration_identifier_root}-page-#{hash['parent']}"
    }
  end
  website.page.import data
end

# Posts
api.posts.each do |hash|
  migration_identifier = "#{migration_identifier_root}-post-#{hash['id']}"
  data = prepare_data hash, migration_identifier
  data[:published_at] = Time.parse(hash['date_gmt']) if hash['date_gmt']
  website.post.import data
end