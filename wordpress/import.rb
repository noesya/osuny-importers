require 'rubygems'
require 'bundler/setup'
require_relative 'wordpress/api'
require_relative 'wordpress/clean'
require_relative 'wordpress/download'

Bundler.require(:default)
Dotenv.load

osuny = OsunyApi.new host: ENV['OSUNY_API_HOST'], token: ENV['OSUNY_API_TOKEN']
website = osuny.communication.website ENV['OSUNY_WEBSITE_ID']

url = 'https://www.iut.u-bordeaux.fr/general'
migration_identifier_root = 'iut.u-bordeaux.fr'
api = Wordpress::Api.new url

def data_from_hash(hash, migration_identifier)
  title = Wordpress::Clean.string hash['title']['rendered']
  summary = Wordpress::Clean.html_to_string hash['excerpt']['rendered']
  text = Wordpress::Clean.html hash['content']['rendered']
  puts title
  data = {
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
  data = data_from_hash hash, migration_identifier
  if hash['parent'] != 0
    data[:parent] = {
      migration_identifier: "#{migration_identifier_root}-page-#{hash['parent']}"
    }
  end
  # website.page.import data
end

# Posts
api.posts.each do |hash|
  migration_identifier = "#{migration_identifier_root}-post-#{hash['id']}"
  data = data_from_hash hash, migration_identifier
  website.post.import data
end