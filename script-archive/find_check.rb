
Dir.entries('./eco-files/').each do |file|
  if file =~ /EC0/
    data  = File.open('./eco-files/'+file)
    # check = data.read.match(/^\S+\s+([A-Z,\.\- ]+)/).captures
    print " #{file}\n" if data.read.include?("#{ARGV[0]}")
  end
end