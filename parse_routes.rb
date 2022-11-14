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

  lines = File.read(file_name).split("\n")

  # Basically a bad way of doing recursion
  lines.reduce([]) do |accum, line|
    if line.start_with?('--[')
      accum.push({})
      accum
    else
      current = accum.pop
      key, value = line.split('|')
      current[key.strip] = value.strip

      puts "Setting array[#{accum.count}][#{key.strip}] = #{value.strip}"
      accum.push(current)
    end
  end
rescue => e
  binding.pry
end

parse_routes(ARGV.first)
