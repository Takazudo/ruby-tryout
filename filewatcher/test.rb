require 'filewatcher'

FileWatcher.new(["files/"]).watch do |filename|
  p filename
end
