module Wordpress
  class Api
    attr_reader :url

    PER_BATCH = 100

    def initialize(url)
      @url = url
    end

    def authors
      load "#{url}/wp-json/wp/v2/users"
    end

    def categories
      load "#{url}/wp-json/wp/v2/categories"
    end

    def posts
      load "#{url}/wp-json/wp/v2/posts"
    end

    def pages
      load "#{url}/wp-json/wp/v2/pages"
    end

    def media
      load "#{url}/wp-json/wp/v2/media"
    end

    protected

    def load(url)
      page = 1
      objects = []
      loop do
        batch = load_paged url, page
        break if batch.is_a?(Hash) || batch.empty?
        objects += batch
        page += 1
      end
      objects
    end

    def load_paged(url, page)
      puts "Load #{url } on page #{page}"
      load_url "#{url}?page=#{page}&per_page=#{PER_BATCH}"
    end

    def load_url(url)
      download_service = Download.download(url)
      JSON.parse(download_service.response.body)
    end
  end
end
