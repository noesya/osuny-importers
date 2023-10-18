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

def page_migration_identifier(id)
  "iut.u-bordeaux.fr-page-#{id}"
end

api.pages.each do |page|
  title = Wordpress::Api.clean_string(page['title']['rendered'])
  migration_identifier = page_migration_identifier page['id']
  puts title

  summary = page['excerpt']['rendered']
  summary = Wordpress::Api.clean_html summary
  summary = ActionController::Base.helpers.strip_tags summary
  text = page['content']['rendered']
  text = Wordpress::Api.clean_html text

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

  if page['parent'] != 0
    data[:parent] = {
      migration_identifier: page_migration_identifier(page['parent'])
    }
  end

  website.page.import data
end
