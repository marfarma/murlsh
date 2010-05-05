%w{
rss/maker

murlsh
}.each { |m| require m }

module Murlsh

  # Regenerate RSS feed after a new url has been added.
  class AddPost50UpdateRss < Plugin

    @hook = 'add_post'

    def self.run(config)
      output_file = 'rss.xml'

      feed = RSS::Maker.make('2.0') do |f|
        f.channel.title = f.channel.description = config.fetch('page_title', '')
        f.channel.link = URI.join(config.fetch('root_url'), output_file)
        f.items.do_sort = true
  
        Murlsh::Url.all(:order => 'id DESC',
          :limit => config.fetch('num_posts_feed', 25)).each do |mu|
          i = f.items.new_item
          i.title = mu.title_stripped
          i.link = mu.url
          i.date = mu.time
        end

      end

      Murlsh::openlock(output_file, 'w') { |f| f.write(feed) }
    end

  end

end
