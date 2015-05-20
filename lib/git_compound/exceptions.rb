module GitCompound
  class GitCompoundError < StandardError; end

  class CompoundLoadError < GitCompoundError; end
  class CompoundSyntaxError < GitCompoundError; end
end
