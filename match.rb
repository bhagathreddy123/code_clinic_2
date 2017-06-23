require_relative('image_matcher/image_matcher.rb')
 
this_dir = File.expand_path(File.dirname(_FILE_))
image_dir = File.join(this_dir,'images')
 
 
image_tests = [
 
[ 'app1.png', 'apple.png'],
 
]
image_tests.each_with_index do |test_set,i|
  puts
  puts "----Image Set #{i+1} -----"
  puts "Does '#{test_set[0]}' contain '#{test_set[1]}'?"
 
search_image_path = File.join(image_dir,test_set[0])
template_image_path = File.join(image_dir,test_set[1])
 
im = ImageMatcher.new
im.search_image = search_image_path
im.template_image = template_image_path
im.verbose = true
im.strategy = 'full'
im.fuzz = 0.0
im.highlight_match = true
im.match!
 
if im.has_match?
     puts "\n Yes Matches at : " + im.match_result.join("/")
else
       puts "\n No match"
end
puts "\n Search time using '#{im.strategy}': #{im.benchmark.total} seconds \n"
puts "_" * 24
puts
end
