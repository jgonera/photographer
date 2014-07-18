require "photographer/version"
require "photographer/comparators/basic_comparator"
require "photographer/comparators/grid_comparator"

module Photographer
  class PhotographerError < StandardError; end
  class ComparisonError < PhotographerError; end

  @comparator = Comparators::BasicComparator.new

  class << self
    attr_accessor :comparator

    def configure
      yield self
    end

    def dir=(path)
      @dir = path
      FileUtils.mkpath @dir
    end

    def camera(&block)
      @camera = block
    end

    def update?
      ENV["PHOTOGRAPHER"] == "update"
    end

    def snap(name)
      if !@camera
        raise PhotographerError, "Camera not defined, use Photographer.configure!"
      end

      path = File.join @dir, name + ".png"
      unless File.exists?(path) || update?
        raise PhotographerError, "Snap missing. Run test with PHOTOGRAPHER=update to update."
      end

      path_new = File.join @dir, name + ".new.png"
      @camera.call path_new

      if update?
        File.delete path if File.exists? path
        File.rename path_new, path
      else
        @comparator.compare(path, path_new)
      end
    end
  end

  module DSL
    def snap(name)
      Photographer.snap name
    end
  end
end
