require "photographer/version"
require "oily_png"

module Photographer
  class PhotographerError < StandardError; end

  class << self
    attr_accessor :max_difference

    def initialize
      @max_difference = 0.1
    end

    def configure
      yield self
    end

    def dir=(path)
      @dir = File.join path, "snaps"
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
      elsif compare(path, path_new) > @max_difference
        raise PhotographerError, "New snap too different! Run test with PHOTOGRAPHER=update to update."
      end
    end

    protected

    def compare(path, path_new)
      # based on http://jeffkreeftmeijer.com/2011/comparing-images-and-creating-image-diffs/
      image = ChunkyPNG::Image.from_file path
      image_new = ChunkyPNG::Image.from_file path_new

      diff_count = 0

      image.height.times do |y|
        image.row(y).each_with_index do |pixel, x|
          diff_count += 1 unless pixel == image_new[x, y]
        end
      end

      diff_count.to_f / image.pixels.length
    end
  end

  module DSL
    def snap(name)
      Photographer.snap name
    end
  end
end
