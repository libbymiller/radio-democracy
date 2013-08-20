# Provides access to application configuration settings, which by default
# are obtained from the file config/config.yml.

require 'settingslogic'

class LocalConfig < Settingslogic
   source File.expand_path(File.join(File.dirname(__FILE__), '..', 'config', 'config.yml'))
end

