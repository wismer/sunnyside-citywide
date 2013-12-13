module Edi
  include Sunnyside
  def new_files
    puts "checking for new files..."
    return Dir["835/*.txt"].select { |file| file if Filelib.where(filename: file).count == 0 }
  end
end 