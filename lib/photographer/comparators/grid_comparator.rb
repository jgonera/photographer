require "oily_png"

module Photographer
  module Comparators
    class GridComparator
      def initialize(max_difference: 0.1, cell_size: 100)
        @max_difference = max_difference
        @cell_size = cell_size
        @cell_area = cell_size * cell_size
      end

      def compare(path_a, path_b)
        @image_a = ChunkyPNG::Image.from_file path_a
        @image_b = ChunkyPNG::Image.from_file path_b

        x_limit = @image_a.width / @cell_size + 1
        y_limit = @image_a.height / @cell_size + 1

        y_limit.times do |y_offset|
          x_limit.times do |x_offset|
            compare_cell(y_offset, x_offset)
          end
        end
      end

      protected

      def compare_cell(y_offset, x_offset)
        diff_count = 0

        @cell_size.times do |cell_y|
          y = @cell_size * y_offset + cell_y
          break if y >= @image_a.height
          @cell_size.times do |cell_x|
            x = @cell_size * x_offset + cell_x
            break if x >= @image_a.width
            diff_count += 1 unless @image_a[x, y] == @image_b[x, y]
          end
        end

        raise Photographer::ComparisonError if diff_count.to_f / @cell_area > @max_difference
      end
    end
  end
end
