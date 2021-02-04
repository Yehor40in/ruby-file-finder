class Finder

        @@filesystem = Hash.new
        @@restricted = [".", ".."]
        @@last_matches = []


        def self.init_filesystem_fingerprint(start = "C:/")
            @@filesystem[start] = Dir.entries(start)

            loop do
                did_change = false
                temp = @@filesystem.clone
                temp.each do |path, contents|
                    contents.each do |entry|
                        begin
                            dir = File.join(path, entry)
                            unless @@filesystem.key?(dir) && @@restricted.include?(entry) then
                                if File.directory?(dir) then
                                    @@filesystem[dir] = Dir.entries(dir)[2..-1]
                                    did_change = true
                                end
                            end
                        rescue => exception
                            puts "[!!] could not look into #{dir}"
                        end
                    end
                end
                break unless did_change
            end
        end


        def self.search_for_entries(keyword)
            @@last_matches = []
            unless @@filesystem.empty? then
                @@filesystem.each do |path, entries|
                    @@last_matches << path if path.include?(keyword) || path.match?(keyword)
                end
                return !@@last_matches.empty?
            end

        end


        def self.findall(regexps)
            result = []
            regexps.each do |regexp| 
                result.append( self.find regexp ) unless @@last_matches.empty?
            end
            return result
        end

        def self.find(entry)
            self.init_filesystem_fingerprint
            if self.search_for_entries(entry) then
                return @@last_matches
            end
        end



end
