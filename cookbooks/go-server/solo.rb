root = File.absolute_path(File.dirname(__FILE__))

file_cache_path root
cookbook_path root + '/../'
environment_path root + '/environments/'
log_level :debug