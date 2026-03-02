#!/usr/bin/env ruby
# Ghost JSON → Jekyll Markdown importer
# Usage: ruby scripts/import-ghost.rb ghost-export.json
#
# 1. In Ghost Admin > Settings > Labs > Export your content
# 2. Save the JSON file to this repo root as ghost-export.json
# 3. Run: ruby scripts/import-ghost.rb ghost-export.json

require 'json'
require 'date'
require 'fileutils'

json_file = ARGV[0] || 'ghost-export.json'
posts_dir = '_posts'
pages_dir = '_pages'

unless File.exist?(json_file)
  puts "Error: #{json_file} not found."
  puts "Export your Ghost content from Admin > Settings > Labs > Export your content"
  exit 1
end

FileUtils.mkdir_p(posts_dir)
FileUtils.mkdir_p(pages_dir)

data = JSON.parse(File.read(json_file))
db = data['db'][0]['data']

posts = db['posts'] || []
tags  = db['tags'] || []
posts_tags = db['posts_tags'] || []

# Build tag slug lookup
tag_map = tags.each_with_object({}) { |t, h| h[t['id']] = t['slug'] }

# Build post → tags lookup
post_tags = {}
posts_tags.each do |pt|
  post_tags[pt['post_id']] ||= []
  post_tags[pt['post_id']] << tag_map[pt['tag_id']]
end

imported = 0
skipped  = 0

posts.each do |post|
  next if post['status'] != 'published'

  slug       = post['slug']
  title      = post['title'].to_s.gsub('"', '\\"')
  pub_date   = DateTime.parse(post['published_at']) rescue nil
  next unless pub_date

  date_str   = pub_date.strftime('%Y-%m-%d')
  tags_list  = (post_tags[post['id']] || []).compact.reject { |t| t == 'hash-internal' }

  # Feature image
  image      = post['feature_image']
  if image
    # Strip Ghost storage prefix to get just filename for later download
    image = image.gsub(%r{^https?://[^/]+/content/images/}, '/assets/images/')
  end

  excerpt = post['custom_excerpt'] || post['plaintext'].to_s.split("\n").first(2).join(' ').slice(0, 200)

  # Try mobiledoc → HTML, fall back to html field
  body = post['html'].to_s

  # Determine if this is a page or post
  is_page = post['type'] == 'page'

  front_matter = []
  front_matter << "---"
  front_matter << "layout: #{is_page ? 'page' : 'post'}"
  front_matter << "title: \"#{title}\""
  front_matter << "date: #{date_str}"
  front_matter << "tags: [#{tags_list.map { |t| "\"#{t}\"" }.join(', ')}]" if tags_list.any?
  front_matter << "image: \"#{image}\"" if image
  front_matter << "excerpt: \"#{excerpt.gsub('"', '\\"').gsub("\n", ' ')}\"" if excerpt.length > 0
  front_matter << "---"
  front_matter << ""

  content = front_matter.join("\n") + body

  if is_page
    filename = "#{pages_dir}/#{slug}.html"
  else
    filename = "#{posts_dir}/#{date_str}-#{slug}.html"
  end

  File.write(filename, content)
  puts "#{is_page ? 'Page' : 'Post'}: #{filename}"
  imported += 1
end

puts ""
puts "Done! Imported #{imported} posts/pages. Skipped #{skipped} drafts."
puts ""
puts "Next step: Download images"
puts "  ruby scripts/download-images.rb"
