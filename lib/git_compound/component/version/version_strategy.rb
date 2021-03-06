module GitCompound
  class Component
    module Version
      # Abstraction for component versions like
      #   gem version, sha and branch
      #
      class VersionStrategy
        def initialize
          raise NotImplementedError
        end

        # Should return git reference (ex branch, tag or sha)
        # This should not raise exception if unreachable
        #
        def ref
          raise NotImplementedError
        end

        # Should return sha for specified reference
        #   (ex tagged commit sha or head of specified branch)
        #
        def sha
          raise NotImplementedError
        end

        # Should return true if this reference in source repository
        #   is reachable
        #
        def reachable?
          raise NotImplementedError
        end

        # String representation of this version strategy
        #
        def to_s
          raise NotImplementedError
        end

        def ==(other)
          to_s == other.to_s
        end
      end
    end
  end
end
