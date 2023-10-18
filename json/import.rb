require 'rubygems'
require 'bundler/setup'

Bundler.require(:default)
Dotenv.load

# Osuny
osuny = OsunyApi.new  host: ENV['OSUNY_API_HOST'], 
                      token: ENV['OSUNY_API_TOKEN']
website = osuny.communication.website ENV['OSUNY_WEBSITE_ID']

# Data
url = 'https://sheetdb.io/api/v1/7it5jspo2ssq7'
response = HTTParty.get url
books = JSON.parse response.body

books.each do |book|
  puts book['titre']
  migration_identifier = "labiblio.tech-#{book['id']}"
  post = {
    title: book['titre'],
    summary: book['auteur'],
    blocks: [
      {
        template_kind: 'chapter',
        migration_identifier: "#{migration_identifier}-chapter",
        data: {
          text: "<p>#{book['contenu']}</p>",
          notes: "<p><a href=\"#{book['link']}\" target=\"_blank\">#{book['link']}</a></p>"
        }
      }
    ],
    categories: [
      {
        title: book['catégorie']
      }
    ]
  }
  website.post.import(migration_identifier, post)
end