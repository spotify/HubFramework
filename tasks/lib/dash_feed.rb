
#
# Module for creating Dash feed XML files.
#
module DashFeed

    # Create a Dash feed XML file at the given path for provided module version and DocSet URL.
    def DashFeed.create(feed_path, module_version, docset_url)
        File.open(feed_path, 'w') do |file|
            file.write("<entry>")
            file.write("<version>#{module_version}</version>")
            file.write("<url>#{docset_url}</url>")
            file.write("</entry>")
            file.write("\n")
        end
    end

end
