module Gutenberg
  # @abstact Exceptions raised by Gutenberg inherit from Error
  class Error < StandardError; end

  # Exception raised when Input file missing
  class InputArgumentError < Error; end

  # Exception raised when not all mergefields replaced
  class MergefieldNotReplacedError < Error 
    def initialize mergefields
      message = "Following mergefields not replaced: #{mergefields.join(", ")}"
      super(message)
    end
  end
end