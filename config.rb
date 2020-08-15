require 'dotenv'
require 'yaml'
require 'fileutils'
require 'colored'

Dotenv.load

### Change load paths for application
#######################################
### all .rb directory files importable, as long as their sub directory name starts with lib
libs=(Dir.glob ('lib*/'))<<(File.absolute_path('.'))
libs.each  {|lib| $LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)}
