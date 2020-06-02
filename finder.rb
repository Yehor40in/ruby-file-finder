module SF

    class Finder

        @@filesystem = Hash.new

        def self.init_filesystem_fingerprint(start = "/")

            @@filesystem[start] = Dir.entries(start)
            loop do
                temp = @@filesystem.clone
                temp.each do |path, contents|
                    contents.each do |entry|
                        begin
                            dir = File.join(path, entry)
                            unless @@filesystem.key? dir then
                                if File.directory?(dir) then
                                    @@filesystem[dir] = Dir.entries(dir)[2..-1]
                                end
                            end
                        rescue => exception
                            puts "[!!] could not look into #{dir}"
                        end
                    end
                end
                break if @@filesystem.size > 3000 #this is dumb, but good for now
            end
        end


        def self.search_for_entries(keyword)
            
            matches = []
            unless @@filesystem.empty? then
                @@filesystem.each do |path, entries|
                    matches << path if path.include? keyword
                end
                return matches unless matches.empty?
            end
            return false

        end

    end

    
end

SF::Finder.init_filesystem_fingerprint
if matches = SF::Finder.search_for_entries(ARGV[0]) then
    puts matches
else
    puts "No matches found"
end
