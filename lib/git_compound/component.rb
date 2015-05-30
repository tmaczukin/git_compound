module GitCompound
  # Component
  #
  class Component
    attr_reader :name
    attr_accessor :version, :sha, :branch
    attr_accessor :source, :destination
    attr_accessor :repository

    def initialize(name, &block)
      @name = name
      Dsl::ComponentDsl.new(self, &block) if block
      raise CompoundSyntaxError, "No block given for component `#{@name}`" unless block
      raise GitCompoundError, "Component `#{@name}` invalid" unless valid?
    end

    def process_dependencies
      @manifest.process_dependencies if manifest
    end

    def manifest
      @manifest ||= load_manifest
    end

    def valid?
      [[@version, @branch, @sha].any?,
       @source, @destination, @repository, @name].all?
    end

    def lastest_matching_ref
      return lastest_matching_strict_ref unless @version
      lastest_matching_version
    end

    private

    def load_manifest
      valid_manifests = ['Compoundfile', '.gitcompound']
      contents = repository.first_file_contents(valid_manifests,
                                                lastest_matching_ref)
      Manifest.new(contents)
    rescue FileNotFoundError
      nil
    end

    def lastest_matching_strict_ref
      ref = @sha || @branch
      raise DependencyError,
            "Ref #{ref} not available in #{@source} for component `#{@name}`" unless
        repository.ref_exists?(ref)
      ref
    end

    def lastest_matching_version
      versions = @repository.versions.map { |k, _| Gem::Version.new(k) }
      versions.sort.reverse_each do |repository_version|
        dependency = Gem::Dependency.new('component', @version)
        return "v#{repository_version}" if
          dependency.match?('component', repository_version, false)
      end
      raise DependencyError, "No maching version available for `#{@name}` component"
    end
  end
end
