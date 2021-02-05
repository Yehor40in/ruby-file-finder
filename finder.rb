class Finder

        @@filesystem = Hash.new
        @@restricted = [".", "..", "Config.Msi", "WindowsApps", "System Volume Information"]
        @@last_matches = []


        def self.init_filesystem_fingerprint(start = nil)
            ["D:/", "C:/"].each do |start|
                @@filesystem[start] = Dir.entries(start)

                loop do
                    did_change = false
                    temp = @@filesystem.clone
                    temp.each do |path, contents|
                        contents.each do |entry|
                            begin
                                dir = File.join(path, entry)
                                if !@@filesystem.key?(dir) && !@@restricted.include?(entry) then
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

        end


        def self.search_for_entries(keyword)
            @@last_matches = []
            unless @@filesystem.empty? then
                @@filesystem.each do |path, entries|
                    entries.each {|entry| @@last_matches << File.join(path, entry) if entry.include?(keyword) || entry.match?(keyword) }
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
            return self.search_for_entries(entry) ? @@last_matches : []
        end



end
