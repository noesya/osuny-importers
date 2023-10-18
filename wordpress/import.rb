require 'action_view'
require 'action_controller'
require 'sanitize'
require 'rubygems'
require 'bundler/setup'
require_relative 'wordpress/api'
require_relative 'wordpress/download'

Bundler.require(:default)
Dotenv.load

osuny = OsunyApi.new host: ENV['OSUNY_API_HOST'], token: ENV['OSUNY_API_TOKEN']
website = osuny.communication.website ENV['OSUNY_WEBSITE_ID']

url = 'https://www.iut.u-bordeaux.fr/general'
api = Wordpress::Api.new url

def data_from_hash(hash, migration_identifier)
  title = hash['title']['rendered']
  title = Wordpress::Api.clean_string title
  summary = hash['excerpt']['rendered']
  summary = Wordpress::Api.clean_html summary
  summary = ActionController::Base.helpers.strip_tags summary
  text = hash['content']['rendered']
  text = Wordpress::Api.clean_html text
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
def page_migration_identifier(id)
  "iut.u-bordeaux.fr-page-#{id}"
end

api.pages.each do |hash|
  migration_identifier = page_migration_identifier hash['id']
  data = data_from_hash hash, migration_identifier
  if hash['parent'] != 0
    data[:parent] = {
      migration_identifier: page_migration_identifier(hash['parent'])
    }
  end
  website.page.import data
end

# Posts
api.posts.each do |hash|
  migration_identifier = "iut.u-bordeaux.fr-post-#{hash['id']}"
  data = data_from_hash hash, migration_identifier
  website.post.import data
end