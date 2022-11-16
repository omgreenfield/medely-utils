# frozen_string_literal: true

require_relative 'parse_routes'
require 'pry-byebug'

ROOT_PATH = '/home/omgreenfield/workspace/medely-roles'

CLIENTS = %w[admin-client pro-client medely-client].freeze

# Iterate through CLIENT_PATHS
# Search through all .ts/.tsx files for 'v3/.*', and collect them
# Transform the strings into routes
# Grab URI from running `parse_routes`
# Make sure each v3 route exists

def find_all_v3_routes_in_clients
  paths = CLIENTS.flat_map do |path|
    dir = File.join(ROOT_PATH, path, 'src')
    Dir["#{dir}/**/*.ts"] + Dir["#{dir}/**/*.tsx"]
  end

  route_refs = []

  paths.each do |path|
    contents = File.read(path)

    route_refs += contents.scan(%r{v3/.*?(?=[,'`])})
  end

  route_refs.map! do |route|
    route.gsub(/\${.*?}/, ':id')
  end

  v3_routes = parse_routes('v3_routes.txt').map do |r|
    # grab just the route and remove the first character, which is '/'
    r['URI'][1..].gsub('(.:format)', '').gsub(/:\w+id/, ':id')
  end.reject { |route| !route.start_with?('v3') }

  missing_routes = route_refs.filter { |route| !v3_routes.include?(route) }

  File.write("parsed_v3_routes.txt", v3_routes.join("\n"))
  File.write("routes_in_clients", route_refs.join("\n"))
  File.write("missing_routes.txt", missing_routes.join("\n"))

  puts "Missing routes:"
  puts missing_routes
end

if __FILE__ == $PROGRAM_NAME
  puts 'Running'
  find_all_v3_routes_in_clients
end
