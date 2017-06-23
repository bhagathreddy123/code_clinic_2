module ImageMatcherStrategies
	# add matching strategies 
	#less lower resoltions png imagesfiles
	#need to copy images in image folder
	#im.verbose = true   checking in match.rb 23 line
	#im.verbose = false   checking in match.rb 23 line need to run see the difference variation b/w each time run the test
	# matching result testing chenaging im.strategy = 'row'  it is false
	# matching result testing chenaging im.strategy = 'row'  it is true
	# matching result testing chenaging im.strategy = 'row'  to pixels

	@@strategies = { 
		'full' => :match_position_by_full_string,
		'rows' => :match_position_by_pixel_rows,
		'pixels' => :match_position_by_pixel_strings,
		'fuzzy' => :match_position_by_pixel_objects,
		'sad' => :match_position_by_sad,

	}

	private
	#compare images by converting all image pixel to a string.
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
		catch :found_match do
			search_rows.times do |y|
				search_cols.times do |x|
					catch :try_next_position do
						puts "Checking search image at #{x},#{y}" if @verbose
						template_image.rows.times do |j|
							t_width = template_image.columns
							# just checking first row not full string
							t_row = template_image.export_pixels_to_str(0,j,t_width,1)
							s_row = search_image.export_pixels_to_str(x,y+j,t_width,1)

							if s_row != t_row
								# if any row does not match then move on 
								throw :try_next_position
							end
						end
						self.match_result = x,y
						throw :found_match
					end     # catch :try_next_position
				end
			end
		end # catch found_match
			return match_result
		
	end

	def match_position_by_pixel_strings
		catch :found_match do
			search_rows.times do |y|
				search_cols.times do |x|
					catch :try_next_position do
						puts "Checking search image at #{x},#{y}" if @verbose
						template_image.rows.times do |j|
							template_image.columns.times do |i|
								t_pixel = template_image.export_pixels_to_str(i,j,i,1)
								s_pixel = search_image.export_pixels_to_str(x+i,y+j,1,1)
								if s_pixel != t_pixel
									throw :try_next_position
								end

							end
						end
							return match_result
					end
				end
			end
		end
	end

	def match_position_by_pixel_objects
		qfuzz = QuantumRange * fuzz
		catch :found_match do
			search_rows.times do |y|
				search_cols do |x|
					catch :try_next_position do
						puts "Checking search image at #{x},#{y}" if @verbose
						template_image.rows.times do |j|
							template_image.columns.times do |i|
								t_pixel = template_image.pixel_color(i,j)
								s_pixel = search_image.pixel_color(x+i,y+j)
								if !s_pixel.fcmp(t_pixel,qfuzz)
									throw :try_next_position
								end
							end
						end

						self.match_result = x,y
						through :found_match
					end
				end
			end
		end
	end

	def match_position_by_sad
		best_sad =1_000_000
		search_rows.times do |y|
			search_cols.times do |x|
				puts "checking search image at #{x}, #{y}" if @verbose
				sad = 0.0
				template_image.rows.times do |j|
					template_image.columns.times do |i|
						s_pixel = search_image.pixel_color(x+i,y+j)
						t_pixel = template_image.pixel_color(i,j)
						sad += (s_pixel.intensity - t_pixel.intensity).abs
					end
				end

				if sad < best_sad
					puts " New best at #{x},#{y}: #{sad} " if @verbose
					best_sad = sad
					self.match_result = x,y
				end
			end
		end
		return match_result
	end
end