require 'digest/md5'

def calc_md5(filename)
  Digest::MD5.hexdigest(File.open(filename, 'rb').read)
end

p calc_md5 'foo.txt'
