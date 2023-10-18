require 'rubygems'
require 'bundler/setup'

Bundler.require(:default)
Dotenv.load

osuny = OsunyApi.new host: ENV['OSUNY_API_HOST'], token: ENV['OSUNY_API_TOKEN']
website = osuny.communication.website ENV['OSUNY_WEBSITE_ID']

url = 'https://sheetdb.io/api/v1/7it5jspo2ssq7'
response = HTTParty.get url
books = JSON.parse response.body
books.each do |book|
  puts book['titre']
  migration_identifier = "labiblio.tech-post-#{book['id']}"
  post = {
    migration_identifier: migration_identifier,
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
        name: book['catégorie']
      }
    ]
  }
  website.post.import(post)
end