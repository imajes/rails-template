# My version of an app template, modified by James Cox (imajes)
# SUPER DARING APP TEMPLATE 1.0 - By Peter Cooper

# Link to local copy of edge rails
  inside('vendor') { run 'ln -s ~/src/git/rails rails' }

# Delete unnecessary files
  run "rm README"
  run "rm public/index.html"
  run "rm public/favicon.ico"
  run "rm public/robots.txt"
  run "rm -f public/javascripts/*"

# Download JQuery
  run "curl -L http://jqueryjs.googlecode.com/files/jquery-1.2.6.min.js > public/javascripts/jquery.js"
  run "curl -L http://jqueryjs.googlecode.com/svn/trunk/plugins/form/jquery.form.js > public/javascripts/jquery.form.js"

# Set up git repository
  git :init
  git :add => '.'
  
# Copy database.yml for distribution use
  run "cp config/database.yml config/database.yml.example"
  
# Set up .gitignore files
  run "touch tmp/.gitignore log/.gitignore vendor/.gitignore"
  run %{find . -type d -empty | grep -v "vendor" | grep -v ".git" | grep -v "tmp" | xargs -I xxx touch xxx/.gitignore}
  file '.gitignore', <<-END
.DS_Store
log/*.log
tmp/**/*
config/database.yml
db/*.sqlite3
END

# Install submoduled plugins
## Those that relate to testing
plugin 'rspec', :git => 'git://github.com/dchelimsky/rspec.git', :submodule => true
plugin 'rspec-rails', :git => 'git://github.com/dchelimsky/rspec-rails.git', :submodule => true
plugin 'machinist', :git => 'git://github.com/notahat/machinist.git', :submodule => true
generate("rspec")
gem 'faker'
## setup for the win
inside ('spec') { run "mkdir blueprints" }
inside ('spec') { run "rm -rf fixtures" }


## Potentially Useful 
plugin 'asset_packager', :git => 'git://github.com/sbecker/asset_packager.git', :submodule => true
plugin 'exception_notifier', :git => 'git://github.com/rails/exception_notification.git', :submodule => true

## user related
if ask("Will this app have authenticated users?")
  plugin 'open_id_authentication', :git => 'git://github.com/rails/open_id_authentication.git', :submodule => true
  plugin 'role_requirement', :git => 'git://github.com/timcharper/role_requirement.git', :submodule => true
  plugin 'restful-authentication', :git => 'git://github.com/technoweenie/restful-authentication.git', :submodule => true
  plugin 'aasm', :git => 'git://github.com/rubyist/aasm.git', :submodule => true
  gem 'ruby-openid', :lib => 'openid'  
  generate("authenticated", "user session")
  generate("roles", "Role User")
  rake('open_id_authentication:db:create')
end

# tags
if ask("Do you want tags with that?")
  plugin 'acts_as_taggable_redux', :git => 'git://github.com/monki/acts_as_taggable_redux.git', :submodule => true
  rake('acts_as_taggable:db:create')
end

# require some gems
if ask("Want to require a bunch of useful gems?")
  gem 'hpricot', :source => 'http://code.whytheluckystiff.net'
  gem 'RedCloth', :lib => 'redcloth'
end

# Final install steps
rake('gems:install', :sudo => true)
rake('db:sessions:create')
rake('db:migrate')

# Set up session store initializer
  initializer 'session_store.rb', <<-END
ActionController::Base.session = { :session_key => '_#{(1..6).map { |x| (65 + rand(26)).chr }.join}_session', :secret => '#{(1..40).map { |x| (65 + rand(26)).chr }.join}' }
ActionController::Base.session_store = :active_record_store
  END
 
# Initialize submodules
  git :submodule => "init"

# Commit all work so far to the repository
  git :add => '.'
  git :commit => "-a -m 'Initial commit'"

# Success!
  puts "SUCCESS!"
