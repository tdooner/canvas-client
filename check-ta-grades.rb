#!/usr/bin/env ruby
# This script will iterate through all sections and automatically download &
# extract [n] assignments while displaying their comments to the console.
#
# How to use:
# 1) Make sure you have Ruby 1.9.2 (or greater) installed.
#    You will also need the commands `wget` and `unzip`
# 2) Insert your API key in for API_KEY below.
# 3) Create a directory "out" in the same place as this file.
# 4) Run this file: `ruby check-ta-grades.rb`.
# 5) Navigate to the "out" directory in MATLAB -- the current files will be
# extracted there.
require './canvas.rb'

def choose_from_list(list, prompt_text = 'Please choose one: ')
  input = -1
  while input < 1 || input > list.length do
    list.each_with_index do |l,i|
      puts "  #{i+1}. #{l}"
    end
    print prompt_text
    input = gets.to_i
  end
  return list[input - 1]
end

API_KEY = '<INSERT_API_KEY_HERE>'
c = Canvas::Client.new(API_KEY)
onethirtyone = c.courses.first
assignments = onethirtyone.assignments

# Ask how many students' files to sample.
num = 0
while num <= 0
  puts "Sample How Many Students..."
  num = gets.to_i
end

continue = true
puts "Choose an Assignment to Verify..."
a = choose_from_list(assignments)

sections = onethirtyone.sections
sections.each do |section|
  puts "===================================================="
  puts "===================================================="
  puts "===================================================="
  puts "Section: #{section}"
  a.submissions(section: section, with: ['submission_comments']).sample(5).each do |s|
    puts "User ID: #{s.user_id}"
    puts "Grade: #{s.score}"
    s.attachments.each do |a|
      puts "| - Downloading... #{a.filename}"
      `wget "#{a.url}" -O outfile --quiet`
      `unzip -q outfile -d out`
      puts "| - Extracted file... #{a.filename}"
      puts "| - Comments:\n------------------"
      s.submission_comments.each do |c|
        puts "#{c.comment}\n-----"
      end
      gets
      `rm -rf out/*`
    end
    puts "------------------------------------------------"
  end
end

