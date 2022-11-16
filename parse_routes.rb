require 'pry-byebug'
require 'active_support/inflector'

##
# Input: text file that was populated through the `rails routes` command.
# Output: a CSV
# Steps:
# - Populate file with `rails routes -E` with whatever conditions you want
#   - Example: `rails routes -E -g "assignments" -c "AssignmentsController" > some_file.txt
# - Pass that file as input to this method
#   - Example: ./parse_routes.rb some_file.txt

puts "Args: #{ARGV}"

def parse_routes(file_name)
  puts "filename: #{file_name}"

  lines = File.readlines(file_name).reject do |line|
    line.start_with?('---') || line.start_with?('Creating')
  end

  # Basically a bad way of doing recursion
  lines.reduce([]) do |accum, line|
    if line.start_with?('--[')
      accum.push({})
      accum
    else
      current = accum.pop
      key, value = line.split('|')
      current[key.strip] = value.strip

      accum.push(current)
    end
  end
rescue StandardError => e
  puts e
  binding.pry
end

# if running from command line
if __FILE__ == $PROGRAM_NAME
  parse_routes(ARGV.first)
end
