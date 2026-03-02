#!/usr/bin/env ruby
# Downloads all images referenced in _posts/ and _pages/ from adamzolyak.com
# Saves them to assets/images/ and updates paths in files
#
# Usage: ruby scripts/download-images.rb
# Requires: curl (built-in on macOS)

require 'fileutils'

SITE_BASE   = 'https://adamzolyak.com'
IMAGES_DIR  = 'assets/images'
POST_DIRS   = ['_posts', '_pages']

FileUtils.mkdir_p(IMAGES_DIR)

# Find all image references in post/page files
image_urls = {}
POST_DIRS.each do |dir|
  Dir.glob("#{dir}/**/*.{html,md}").each do |file|
    content = File.read(file)
    # Match Ghost content image paths
    content.scan(%r{https?://adamzolyak\.com/content/images/[^\s"')]+}) do |url|
      image_urls[url] = true
    end
    # Also match __GHOST_URL__ placeholder (not yet replaced)
    content.scan(%r{__GHOST_URL__/content/images/[^\s"')]+}) do |url|
      real_url = url.sub('__GHOST_URL__', SITE_BASE)
      image_urls[real_url] = true
    end
    # Also match relative /assets/images/ that we've already rewritten
    content.scan(%r{/assets/images/[^\s"')]+}) do |path|
      puts "Already local: #{path}"
    end
  end
end

puts "Found #{image_urls.size} remote images to download"
puts ""

image_urls.each_key do |url|
  filename = File.basename(url.split('?').first)
  dest = "#{IMAGES_DIR}/#{filename}"

  if File.exist?(dest)
    puts "Skip (exists): #{filename}"
    next
  end

  print "Downloading: #{filename}... "
  result = system("curl -s -L -o '#{dest}' '#{url}'")
  puts result ? "ok" : "FAILED"
end

puts ""
puts "Images saved to #{IMAGES_DIR}/"
puts ""
puts "Now update image paths in your posts:"
puts "  ruby scripts/fix-image-paths.rb"
