set :application, "crm.liquidmedia.ca"
set :repository,  "git@github.com:liquidmedia/fat_free_crm.git"

set :scm, "git"
# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`
default_run_options[:pty] = true
set :git_shallow_clone, 1
set :runner, "liquidmedia"
set :user, "liquidmedia"
set :use_sudo, false

task :production do
  set :rails_env, 'production'
  set :deploy_to, "/home/#{user}/applications/shindig_crm/#{rails_env}"
  role :app, "69.164.210.244"
  role :web, "69.164.210.244"
  role :db, "69.164.210.244", :primary => true
  set :branch, rails_env
  set :stage, rails_env
end

namespace :deploy do
  task :copy_shared_configs, :roles => :web do
    invoke_command "cp #{shared_path}/config/database.yml #{release_path}/config/"
    cleanup
  end
  task :restart do
    run "cd #{release_path} && touch tmp/restart.txt"
  end
end

task :install_gems do
  run "cd #{release_path} && RAILS_ENV=#{rails_env} rake gems:install"
end

after 'deploy:update_code', 'deploy:copy_shared_configs'
after 'deploy:update_code', 'deploy:migrate'
after 'deploy:update_code', :install_gems

# If you are using Passenger mod_rails uncomment this:
# if you're still using the script/reapear helper you will need
# these http://github.com/rails/irs_process_scripts

# namespace :deploy do
#   task :start do ; end
#   task :stop do ; end
#   task :restart, :roles => :app, :except => { :no_release => true } do
#     run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
#   end
# end
