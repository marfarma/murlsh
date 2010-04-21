%w{
hpricot
}.each { |m| require m }

module Murlsh

  # Hpricot:Doc mixin.
  module Doc

    # Get the character set of the document.
    def charset
      %w{content-type Content-Type}.each do |ct|
        content_type = at("meta[@http-equiv='#{ct}']")
        unless content_type.nil?
          content = content_type['content']
          unless content.nil?
            charset = content[/charset=([\w_.:-]+)/, 1]
            return charset if charset
          end
        end
      end
      nil
    end

    # Check a list of xpaths in order and return the inner html of the first
    # one that is not nil.
    def xpath_search(xpaths)
      [*xpaths].each do |xpath|
        selection = (self/xpath).first
        if selection; return (yield selection); end
      end
      nil
    end

    # Get the title of the document.
    def title
      xpath_search(%w{
        //html/head/title
        //head/title
        //html/title
        //title
        }) { |node| node.inner_html }
    end

    # Get the meta description of the document.
    def description
      xpath_search(
        "//html/head/meta[@name='description']"
        ) { |node| node['content'] }
    end

  end

end
