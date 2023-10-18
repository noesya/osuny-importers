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

url = 'https://www.iut.u-bordeaux.fr/general/'
api = Wordpress::Api.new url

api.pages.each do |page|
  title = Wordpress::Api.clean_string(page['title']['rendered'])
  puts title
  data = {
    migration_identifier: "iut.u-bordeaux.fr-page-#{page['id']}",
    title: title,
    slug: page['slug'],
    summary: ActionController::Base.helpers.strip_tags(Wordpress::Api.clean_html(page['excerpt']['rendered'])),
    content: Wordpress::Api.clean_html(page['content']['rendered'])
  }
  website.page.import data
end
