require 'filewatcher'

FileWatcher.new(["files/"]).watch() do |filename, event|
  if(event == :changed)
    puts "File updated: " + filename
  end
  if(event == :delete)
    puts "File deleted: " + filename
  end
  if(event == :new)
    puts "New file: " + filename
  end
end
