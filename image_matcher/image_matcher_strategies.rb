module ImageMatcherStrategies
	# add matching strategies 
	#less lower resoltions png imagesfiles
	#need to copy images in image folder
	@@strategies = { 
		'full' => :match_position_by_full_string,
		'rows' => :match_position_by_pixel_rows,
		'pixels' => :match_position_by_pixel_string,
	}

	private

	def match_position_by_full_string
		t_width = template_image.columns
		t_height = template_image.rows
		t_pixels = template_image.export_pixels_to_str(0,0,t_width,t_height)
		catch :found_match do
			search_rows.times do |y|
				search_cols.times do |x|
					puts "Checking search image at #{x},#{y}" if @verbose
					s_pixels = search_image.export_pixels_to_str(x,y,t_width,t_height)
					if s_pixels = t_pixels
						self.match_result = x,y
						throw :found_match
					end
				end
			end

		end	
	end

	def match_position_by_pixel_rows
		
	end

	def match_position_by_pixel_strings
		
	end


end