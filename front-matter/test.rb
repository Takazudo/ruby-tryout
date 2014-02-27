require 'front_matter'
require 'yaml'

fm = FrontMatter.new(:unindent => true, :as_yaml => true)
file = "md/foo.md"

front_matters = fm.extract_file(file)
res = front_matters
p YAML.load front_matters[0]

