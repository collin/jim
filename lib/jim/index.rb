module Jim
  class Index
    attr_reader :directories
    
    def initialize(*directories)
      @directories = directories.flatten
    end

    def add(directory)
      @directories.unshift directory
    end
    
    def list
      list = {}
      each_file_in_index('.js') do |filename|
        if version = filename.version
          name = filename.stem.gsub(/(\-[^\-]+)$/, '')
        elsif /lib\/([^\/]+)-([\d\w\.\-]+)\/.+/.match filename
          name    = $1
          version = $2
        else
          name = filename.stem
          version = '0'
        end
        if name && version
          list[name] ||= []
          list[name] << version unless list[name].include?(version)
        end
      end
      list.sort
    end

    def find(name, version = nil)
      name     = Pathname.new(name)
      extname  = name.extname
      stem     = name.stem
      ext      = (extname.nil? || extname.strip == '') ? '.js' : extname
      possible_paths = if version
        [
          /#{stem}-#{version}\/#{name}#{ext}$/,
         /#{name}-#{version}#{ext}$/
        ]
      else
        [
          /#{name}#{ext}/,
          /#{name}-[\d\w\.\-]+#{ext}/
        ]
      end
      final = false
      each_file_in_index(ext) do |filename|
        possible_paths.each do |p|
          if p.match filename
            final = Pathname.new(filename).expand_path
            break
          end
        end
        break if final
      end
      final
    end
    
    def each_file_in_index(ext, &block)
      @directories.each do |dir|
        Dir.glob(Pathname.new(dir) + '**' + "*#{ext}") do |filename|
          yield Pathname.new(filename)
        end
      end
    end

  end
end