module Jim
  class Installer
    attr_reader :fetch_path, :install_path, :options, 
                :name, :version
    
    def initialize(fetch_path, install_path, options = {})
      @fetch_path   = Pathname.new(fetch_path)
      @install_path = Pathname.new(install_path)
      @options      = options
    end
    
    def fetch
      logger.info "fetching #{fetch_path}"
      Downlow.fetch(fetch_path, :destination => tmp_path)
    end
    
    def install
      fetch
      determine_name if !name
      determine_version if !version
      logger.info "installing #{name} #{version}"
      logger.debug "tmp_path #{tmp_path}"
      if options[:shallow]
        final_path = install_path + "#{name}-#{version}#{tmp_path.extname}"
      else
        final_dir = install_path + 'lib' + name + version
        final_path = (tmp_path.to_s =~ /\.js$/) ? 
          final_dir + "#{name}.js" : 
          final_dir
      end
      logger.debug "installing to #{final_path}"
      if final_path.exist? 
        options[:force] ? FileUtils.rm_rf(final_path) : raise(Jim::FileExists.new(final_path))
      end
      Downlow.extract(tmp_path, :destination => final_path)
    ensure
      FileUtils.rm_rf(tmp_path) if tmp_path.exist?
      final_path
    end
    
    def determine_name
      return @name = options[:name] if options[:name]
      if tmp_path.file?
        # try to read and determine name
        tmp_path.each_line do |line|
          if /(\*|\/\/)\s+name:\s+([\d\w\.\-]+)/i.match line
            return @name = $2
          end
        end
      end
      @name = tmp_path.stem.gsub(/(\-[\d\w\.]+)$/, '')
    end
    
    def determine_version
      return @version = options[:version] if options[:version]
      if tmp_path.file?
        # try to read and determine version
        tmp_path.each_line do |line|
          if /(\*|\/\/)\s+version:\s+([\d\w\.\-]+)/i.match line
            return @version = $2
          end
        end
      end
      @version = tmp_path.version || '0'
    end
            
    private
    def tmp_root
      install_path + 'tmp'
    end
    
    def tmp_dir
      dir = Pathname.new(File.join(tmp_root, fetch_path.stem))
      dir.mkpath
      dir
    end
    
    def tmp_path
      Pathname.new(tmp_dir) + fetch_path.basename
    end
      
    def logger
      Jim.logger
    end
  end
end