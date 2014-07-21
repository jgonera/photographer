require "oily_png"

module Photographer
  module Comparators
    class MovingFrameComparator
      def initialize(max_difference: 0.1, frame_size: 100)
        @max_difference = max_difference
        @frame_size = frame_size
        @frame_area = frame_size * frame_size
      end

      def compare(path_a, path_b)
        @image_a = ChunkyPNG::Image.from_file path_a
        @image_b = ChunkyPNG::Image.from_file path_b

        x_limit = @image_a.width - @frame_size
        y_limit = @image_a.height - @frame_size

        y_limit.times do |y_offset|
          x_limit.times do |x_offset|
            compare_frame(y_offset, x_offset)
          end
        end
      end

      protected

      def compare_frame(y_offset, x_offset)
        diff_count = 0

        @frame_size.times do |frame_y|
          y = y_offset + frame_y
          @frame_size.times do |frame_x|
            x = x_offset + frame_x
            diff_count += 1 unless @image_a[x, y] == @image_b[x, y]
          end
        end

        raise Photographer::ComparisonError if diff_count.to_f / @frame_area > @max_difference
      end
    end
  end
end
