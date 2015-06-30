module GitCompound
  # GitCompount command facade
  #
  module Command
    def build(*args)
      manifest(args.first).process(
        Worker::CircularDependencyChecker.new,
        Worker::NameConstraintChecker.new,
        Worker::ConflictingDependencyChecker.new,
        Worker::ComponentBuilder.new,
        Worker::TaskRunner.new)
    end

    def update(*_args)
      raise NotImplementedError
    end

    def check(*args)
      manifest(args.first).process(
        Worker::CircularDependencyChecker.new,
        Worker::NameConstraintChecker.new,
        Worker::ConflictingDependencyChecker.new)
    end

    def show(*args)
      manifest(args.first).process(
        Worker::CircularDependencyChecker.new,
        Worker::PrettyPrint.new)
    end

    def help(*_args)
      print_usage
    end

    def run(command, args)
      public_send(command, *args)
    rescue NoMethodError
      print_usage
    rescue GitCompoundError => e
      abort "[-] Error: #{e.message}"
    end

    private

    def manifest(filename)
      files = filename ? [filename] : ['Compoundfile', '.gitcompound']
      found = files.select { |file| File.exist?(file) }

      raise GitCompoundError,
            "Manifest `#{filename || files.inspect}` not found !" if found.empty?

      contents = File.read(found.first)
      Manifest.new(contents)
    end

    def print_usage
      puts <<-END
Usage:
    gitcompound build [ manifest ]
      -- builds project from manifest

         If manifest is not specified it uses `Compoundfile`
         or `.gitcompound`

    gitcompound update [ manifest ]
      -- updates project

    gitcompound check [ manifest ]
      -- detects circular depenencies, conflicting dependencies
         and checks for name contraints

    gitcompound show [ manifest ]
      -- prints structure of project

    gitcompound help
      -- prints this help
      END
    end
  end
end
