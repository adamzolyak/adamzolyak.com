#!/usr/bin/env ruby
# Rewrites Ghost CDN image URLs in post/page files to local /assets/images/ paths
# Run after import-ghost.rb and download-images.rb
#
# Usage: ruby scripts/fix-image-paths.rb

POST_DIRS = ['_posts', '_pages']

files_changed = 0
replacements  = 0

POST_DIRS.each do |dir|
  Dir.glob("#{dir}/**/*.{html,md}").each do |file|
    content = File.read(file)
    new_content = content
      .gsub(
        %r{https?://adamzolyak\.com/content/images/(\d{4}/\d{2}/)?([^"'\s)>]+)},
        '/assets/images/\2'
      )
      .gsub(
        %r{__GHOST_URL__/content/images/(\d{4}/\d{2}/)?([^"'\s)>]+)},
        '/assets/images/\2'
      )
    if new_content != content
      File.write(file, new_content)
      count = content.scan(%r{(?:https?://adamzolyak\.com|__GHOST_URL__)/content/images}).length
      puts "Fixed #{count} image(s) in #{file}"
      files_changed += 1
      replacements += count
    end
  end
end

puts ""
puts "Done. Fixed #{replacements} image references across #{files_changed} files."
