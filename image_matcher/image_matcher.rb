require 'RMagick'; include Magick
require 'benchmark'
 
require_relative('image_matcher_strategies')
 
class ImageMatcher
	attr_reader :search_image, :template_image
	attr_reader :match_x, :match_y, :benchmark
	attr_reader :search_cols,:search_rows
	attr_accessor :strategy, :verbose,:highlight_match, :fuzz
	 
	@@strategies = {}
	 include ImageMatcherStrategies

	def initialize(options={})
	search_image = options[:search_image]
	template_image = options[:template_image]
	@strategy = options[:strategy]
	@verbose = options[:verbose] === false ? False : true
	@highlight_match = options[:verbose] || false
	@fuzz = options[:fuzz] || 0.0
	end
	 
	def search_image=(filepath)
	@search_image = read_image(filepath)
	@search_cols = search_image.columns
	@search_rows = search_image.rows
		return search_image
	end
	 
	def template_image=(file_path)
	@template_image = read_image(file_path)
	end
 
	def has_match?
		!match_x.nil? && !match_y.nil?
	end
	 
	 
	def match_result
		[match_x,match_y]
	end
	 
	def clear!
		@match_x = nil
		@match_y = nil
	end
	 
	def match!
		clear!
		tighten_search_area
		@benchmark = Benchmark.measure do
			send(strategy_method)
		end
		save_match_file if highlight_match
		return has_match?
	end
 
	private
 
	def read_image(filename)
		if filename
			image = Magick:: Image.read(filename).first
			return image
		end
	end
	 
	def tighten_search_area
		@search_cols = search_image.columns – template_image.columns
		@search_rows = search_image.rows – template_image.rows
	end
	 
	def add_fuzz_to_images
		if fuzz
			fuzz_as_percent = "#{fuzz.round(2)*100}%"
			puts "Setting fuzz at #{fuzz_as_percent}" if @verbose
			search_image.fuzz = fuzz_as_percent
			template_image.fuzz = fuzz_as_percent
		end
	end
 
	def strategy_method
		if @@strategies.size == 0
			puts "no match strategies defined."
			exit
		end
		strategy_method = @@strategies[strategy]
		raise "Invalid match strategy " if strategy_method.nil?
		return strategy_method
	end
	 
	def match_result=(array)
		if array && array.is_a?(Array)
			@match_x,@match_y = array
		end
	end
 
	def save_match_file
		if match_x && match_y
			end_x = match_x + template_image.columns
			end_y = match_y + template_image.rows
	 
			area = Magick::Draw.new
			area.fill('none')
			area.stroke('red')
			area.stroke_width(3)
			area.rectangle(match_x,match_y,end_x,end_y)
			area.draw(search_image)
			search_image.write(matchfile)
	 
		else
			raise "No Match found"
		end
	end
 
 
	def matchfile
		if search_image
			name_parts = search_image.filename.split('.')
			ext = name_parts.pop
			name = name_parts.join('.')
			return "#{name}_match.#{ext}"
		else
			return "no_search_image.png"
		end
	end
 
end
