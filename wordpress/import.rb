require 'rubygems'
require 'bundler/setup'
require_relative 'wordpress/api'
require_relative 'wordpress/clean'
require_relative 'wordpress/download'

Bundler.require(:default)
Dotenv.load

osuny = OsunyApi.new host: ENV['OSUNY_API_HOST'], token: ENV['OSUNY_API_TOKEN']
website = osuny.communication.website ENV['OSUNY_WEBSITE_ID']

require 'wp_api_client'
WpApiClient.configure do |api_client|
  api_client.endpoint = "https://www.iut.u-bordeaux.fr/general/wp-json/wp/v2"
end
@api = WpApiClient.get_client
@api.get('posts/').each do |post|
  puts post.title
end

# url = 'https://www.iut.u-bordeaux.fr/general'
# api = Wordpress::Api.new url

# def data_from_hash(hash, migration_identifier)
#   title = Wordpress::Clean.string hash['title']['rendered']
#   summary = Wordpress::Clean.html_to_string hash['excerpt']['rendered']
#   text = Wordpress::Clean.html hash['content']['rendered']
#   puts title
#   data = {
#     migration_identifier: migration_identifier,
#     title: title,
#     summary: summary,
#     blocks: [
#       {
#         template_kind: 'chapter',
#         migration_identifier: "#{migration_identifier}-chapter",
#         data: {
#           text: text
#         }
#       }
#     ]
#   }
# end

# # Pages
# def page_migration_identifier(id)
#   "iut.u-bordeaux.fr-page-#{id}"
# end

# api.pages.each do |hash|
#   migration_identifier = page_migration_identifier hash['id']
#   data = data_from_hash hash, migration_identifier
#   if hash['parent'] != 0
#     data[:parent] = {
#       migration_identifier: page_migration_identifier(hash['parent'])
#     }
#   end
#   website.page.import data
# end

# # Posts
# api.posts.each do |hash|
#   migration_identifier = "iut.u-bordeaux.fr-post-#{hash['id']}"
#   data = data_from_hash hash, migration_identifier
#   data[:published_at] = Time.parse(hash['date_gmt']) if hash['date_gmt']
#   website.post.import data
# end