# Capistrano deployment
  Before start reading this documentation, please have a look at following links as I really use all the steps written there and installed all the basic softwares like rvm, Nginx etc.
   [Capistrano puma nginx](https://www.digitalocean.com/community/tutorials/deploying-a-rails-app-on-ubuntu-14-04-with-capistrano-nginx-and-puma).
   [Capistrano gem](https://github.com/capistrano/capistrano/).
   [nginx missing sites available](https://stackoverflow.com/questions/17413526/nginx-missing-sites-available-directory).

# Steps to start with
  1. First clone the iris app from [Gitswarm](http://gitswarm.corp.ooma.com/Jeff.Kirk/iris) website.
  `git clone http://gitswarm.corp.ooma.com/Jeff.Kirk/iris`
  Then run the rvm commands to select the ruby version.
  `rvm use 2.3.1` and `rvm gemset use iris` and `bundle install` and `rails s`
  This will run the application on local machine.
  http://localhost:3000/.

  2. Now we can see the deployment steps 
     - `RAILS_ENV=production rake secret` 
       The above command will generate a secret key which we will use in the next command.
     - `cap production config:set SECRET_KEY_BASE=51651651651651651aaxasxa16sx51a651sx6sa51x6as51x` 
       With this command, we actually create a .env file and put the SECRET_KEY_BASE variable in it and copied this file on the remote machine.
     - Then create a database.yml file with production environment variables which will be used 
       to copy on the remote machine.
       Add following to your database.yml file locally
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
      Then run following command from root of iris app 
      `bundle exec cap production setup`.
      which will a copy of secret_key.yml and database.yml file to a shared directory on the remote server.
      and on deployment, it will automatically be symlinked to appropriate files in config folder.
    - Then run `cap production deploy` which will run all the deployment task on the remote machine.
      like cloning the application, run the migration run the asset compilation etc. and start an application in production mode. 

##  Details of deployment.
Please first go through all the readme files of following gems.
[capistrano rvm](https://github.com/capistrano/rvm),
[capistrano puma](https://github.com/seuros/capistrano-puma),
[capistrano database.yml](https://github.com/potsbo/capistrano-database-yml),
[capistrano-dotenv-tasks](https://github.com/glyph-fr/capistrano-dotenv-tasks),
[capistrano3-nginx](https://github.com/platanus/capistrano3-nginx),
[capistrano-resque](https://github.com/sshingler/capistrano-resque). 

### Capistrano with Puma
    I have set all the puma default configuration like puma workers, puma socket file path etc in
    config/deploy.rb.It can be changed from there.As workers count depends on CPU cores count.

    ```    
    cap puma:config                    # Setup Puma config file
    cap puma:halt                      # halt puma
    cap puma:nginx_config              # Setup nginx configuration
    cap puma:phased-restart            # phased-restart puma
    cap puma:restart                   # restart puma
    cap puma:start                     # Start puma
    cap puma:status                    # status puma
    cap puma:stop                      # stop puma
    ```
    When we run `cap puma:config` it will create and upload a puma configuration file on remote machine and when puma gets
    started  at the end of deployment task it will use this file to get configuration and start a server.

### Nginx with puma
    - We can start and restart nginx from local machine.
     ```
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

     ```
# How to use Resque 
  Please go through a readme file of resque gem.
  [resque](https://github.com/resque/resque)
  [resque scheduler](https://github.com/resque/resque-scheduler)
  
  Resque is a redis based background job processor. You can see the resque default configuration in 
  config/initializer/resque.rb  as i m using 2 database of redis so no conflict with the database used by iriscollector.
  
  I'm using resque scheduler to run recurring jobs. For that, i am using a cron style yml file to declare the jobs
  Have a look at config/resque_schedule.yml. So when rails server started it will load this task into resque. You can see this in http://localhost:3000/resque/schedule.
  
  Then we have to start a scheduler to load this job in a queue.
  `cap production  resque:scheduler:start` 

  Then we have to start workers to run this queued jobs.
  `cap production  resque:start`    
  
  The queue and workers count I defined in config/deploy/production.rb  

   
  For using this I have transferred all the rake task into a resque worker.you can check-in app/workers folder.
  and all these workers are getting called via scheduler with the help of config/resque_schedule.yml.
        


 
