# Capistrano deployment
  Please have a look at [Capistrano puma nginx](https://www.digitalocean.com/community/tutorials/deploying-a-rails-app-on-ubuntu-14-04-with-capistrano-nginx-and-puma).

  This document is assuming that you have a working copy of iris app. And this copy is the latest version of iris app means p4 sync is performed in the application directory.
  
  This document also assumes that you have rvm installed on the local machine and postgresql is installed and the iris app is running in development mode locally.Or the iris app using the database from server machine.

   I already run the command `cap install` from root of application so there is no need to run this command again.it creates files and folders. Please have a look at [Capistrano gem](https://github.com/capistrano/capistrano/). in the config/deploy.rb you can see variables are set like deploy directory path,user name which is used to login to the remote machine etc. i already installed my public ssh key on remote machine, therefore it will not ask me the password while deploying.

## Deployment Steps

   - bundle exec cap production setup
   - cap production config:set
   - cap production config:set SECRET_KEY_BASE=51651651651651651aaxasxa16sx51a651sx6sa51x6as51x
   - cap production copy:deploy

  1. Add following to your database.yml file locally
     ```  
     production:
      adapter: postgresql
      encoding: unicode
      database: iris_development
      pool: 5
      username: postgres
      password: postgres
      host: irisdev.corp.ooma.com
      port: 5432
     ```
     

 
  2. second create a secret key with rake task from root of application run the following command 
     `RAILS_ENV=production rake secret`  
      then copy this key in the `.env` file in the root of iris folder(first time you have to create it manually) as
      follows      

     `SECRET_KEY_BASE=51651651651651651aaxasxa16sx51a651sx6sa51x6as51x`

      Then run the following command
      `cap production config:set SECRET_KEY_BASE=51651651651651651aaxasxa16sx51a651sx6sa51x6as51x`  

      which will create a .env file on remote machine and set its value.

      Then run following command from root of iris app 
      `bundle exec cap production setup`.
      which will a copy of secret_key.yml and database.yml file to shared directory on remote server.
      and on deployment it will automatically symlinked to appropriate files in config folder.

  3. Then run the following command
    `bundle exec cap production copy:deploy`

     which will copy the code to server with specified path that is deploy_to variable defined in deploy.rb. Then it will run the tasks migration,compile the assets,and start puma web server  

### Deploy with git

    When deployed with git the above 2 steps are same but in 3rd step instead of copy:deploy it is `cap production deploy`. which will pull the code from git repository instead of copying from machine.

### Deploy with nginx

    I just included the puma nginx configuration file through capistrano.Therefore we can run the following command `cap production puma:nginx_config`. By this command the puma nginx file is copied to remote machine's /etc/nginx/sites-availabe directory.  

    The nginx file which is copied to server is from config/deploy/templates/nginx_conf.erb. just keep in mind if you are using a centos then after nginx installation it will not create sites-enabled and sites-available folder. Please check this site. [nginx missing sites available](https://stackoverflow.com/questions/17413526/nginx-missing-sites-available-directory)
    
    in the config/depoy/templates/nginx_conf.erb file put all the configuration which is requied to run the puma app with socket which nginx can use for web access. I copied there right now the configuration of iris app which is get deployed on graphite.corp.ooma.com machine. after we run the command `cap production puma:nginx_config` 
    the file copied into a /etc/nginx/sites-availabe folder and make a symlink to sites-enabled folder. Then run the command `cap production nginx:restart` which will restart nginx on server.

     The Puma configuration file can be found in a shared directory on the server(/export/iris/apps_test/superapp/shared).

    Mostly there is no much change in an nginx configuration file so this is just for reference.

 ## steps for nginx installation
 
    1. sudo yum install epel-release
    2. sudo yum install nginx
    3. sudo systemctl start nginx
    4. sudo systemctl stop nginx
    5. sudo systemctl status nginx

      If you are running a firewall, run the following commands to allow HTTP and HTTPS traffic:

        sudo firewall-cmd --permanent --zone=public --add-service=http 
        sudo firewall-cmd --permanent --zone=public --add-service=https
        sudo firewall-cmd --reload
 
      if there is a firewall is running just make sure it allow port 80
 
      check http://IPADDRESS 

      copy this into the /etc/nginx/nginx.conf
      ```
      
       upstream puma {
        server unix:///home/deploy/apps/appname/shared/tmp/sockets/appname-puma.sock;
      }

      server {
        listen 80 default_server deferred;
        # server_name example.com;

        root /home/deploy/apps/appname/current/public;
        access_log /home/deploy/apps/appname/current/log/nginx.access.log;
        error_log /home/deploy/apps/appname/current/log/nginx.error.log info;

        location ^~ /assets/ {
          gzip_static on;
          expires max;
          add_header Cache-Control public;
        }

        try_files $uri/index.html $uri @puma;
        location @puma {
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_set_header Host $http_host;
          proxy_redirect off;

          proxy_pass http://puma;
        }

        error_page 500 502 503 504 /500.html;
        client_max_body_size 10M;
        keepalive_timeout 10;
      }
      ```

    change the appname and change a directory structer for log files path and root and socket file path 
    with appropriate app name given in deploy.rb 


    if you get a permission denied error for accessing a log file try following command and restart a nginx  
    `setenforce permissive`
### Resque configuration
Following command to start resque background processing
```
rails s -e production ( which will load scheduled job from configuration file)
RAILS_ENV=production  QUEUE=iris_data rake resque:work (which will actually executes worker by only starting a schedular dosent start work processing.)
RAILS_ENV=production rake resque:scheduler (which will just schedule a job in schedular dynamically. if the name is same then just check last enqued at time stamp it will be changed in /resque/schedule)
```

### 
just pasting here all the commands we can use for reference . you can see it through cap -T
```
cap bundler:clean                  # Remove unused gems intalled by bundler
cap bundler:install                # Install the current Bundler environment
cap bundler:map_bins               # Maps all binaries to use `bundle exec` by default
cap config:remove                  # Removes an environment variable from the .env config file
cap config:set                     # Set an environment variable in .env config file
cap config:show                    # fetch existing environments variables from .env config file
cap database_yml:check             # database.yml file checks
cap database_yml:setup             # Setup `database.yml` file on the server(s)
cap deploy                         # Deploy a new release
cap deploy:check                   # Check required files and directories exist
cap deploy:check:directories       # Check shared and release directories exist
cap deploy:check:linked_dirs       # Check directories to be linked exist in shared
cap deploy:check:linked_files      # Check files to be linked exist in shared
cap deploy:check:make_linked_dirs  # Check directories of files to be linked exist in shared
cap deploy:cleanup                 # Clean up old releases
cap deploy:cleanup_assets          # Cleanup expired assets
cap deploy:cleanup_rollback        # Remove and archive rolled-back release
cap deploy:clobber_assets          # Clobber assets
cap deploy:compile_assets          # Compile assets
cap deploy:finished                # Finished
cap deploy:finishing               # Finish the deployment, clean up server(s)
cap deploy:finishing_rollback      # Finish the rollback, clean up server(s)
cap deploy:log_revision            # Log details of the deploy
cap deploy:migrate                 # Runs rake db:migrate if migrations are set
cap deploy:migrating               # Runs rake db:migrate
cap deploy:normalize_assets        # Normalize asset timestamps
cap deploy:published               # Published
cap deploy:publishing              # Publish the release
cap deploy:revert_release          # Revert to previous release timestamp
cap deploy:reverted                # Reverted
cap deploy:reverting               # Revert server(s) to previous release
cap deploy:rollback                # Rollback to previous release
cap deploy:rollback_assets         # Rollback assets
cap deploy:set_current_revision    # Place a REVISION file with the current revision SHA in the current release path
cap deploy:started                 # Started
cap deploy:starting                # Start a deployment, make sure server(s) ready
cap deploy:symlink:linked_dirs     # Symlink linked directories
cap deploy:symlink:linked_files    # Symlink linked files
cap deploy:symlink:release         # Symlink release to current
cap deploy:symlink:shared          # Symlink files and directories from shared to release
cap deploy:updated                 # Updated
cap deploy:updating                # Update server(s) by setting up a new release
cap doctor                         # Display a Capistrano troubleshooting report (all doctor: tasks)
cap doctor:environment             # Display Ruby environment details
cap doctor:gems                    # Display Capistrano gem versions
cap doctor:servers                 # Display the effective servers configuration
cap doctor:variables               # Display the values of all Capistrano variables
cap dotenv:touch                   # create the .env in shared directory
cap git:check                      # Check that the repository is reachable
cap git:clone                      # Clone the repo to the cache
cap git:create_release             # Copy repo to releases
cap git:set_current_revision       # Determine the revision that will be deployed
cap git:update                     # Update the repo mirror to reflect the origin state
cap git:wrapper                    # Upload the git wrapper script, this script guarantees that we can script git without getting an interactive ...
cap install                        # Install Capistrano, cap install STAGES=staging,production
cap nginx:configtest               # Configtest nginx service
cap nginx:gzip_static              # Compress JS and CSS with gzip
cap nginx:reload                   # Reload nginx service
cap nginx:restart                  # Restart nginx service
cap nginx:site:add                 # Creates the site configuration and upload it to the available folder
cap nginx:site:disable             # Disables the site removing the symbolic link located in the enabled folder
cap nginx:site:enable              # Enables the site creating a symbolic link into the enabled folder
cap nginx:site:remove              # Removes the site by removing the configuration file from the available folder
cap nginx:start                    # Start nginx service
cap nginx:stop                     # Stop nginx service
cap puma:config                    # Setup Puma config file
cap puma:halt                      # halt puma
cap puma:nginx_config              # Setup nginx configuration
cap puma:phased-restart            # phased-restart puma
cap puma:restart                   # restart puma
cap puma:start                     # Start puma
cap puma:status                    # status puma
cap puma:stop                      # stop puma
cap resque:restart                 # Restart running Resque workers
cap resque:scheduler:restart       # Restart resque scheduler
cap resque:scheduler:start         # Starts resque scheduler with default configs
cap resque:scheduler:status        # See current scheduler status
cap resque:scheduler:stop          # Stops resque scheduler
cap resque:start                   # Start Resque workers
cap resque:status                  # See current worker status
cap resque:stop                    # Quit running Resque workers
cap rvm:check                      # Prints the RVM and Ruby version on the target host
cap secrets_yml:check              # secrets.yml file checks
cap secrets_yml:setup              # Setup `secrets.yml` file on the server(s)
cap setup                          # Server setup tasks

```

