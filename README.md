# Capistrano deployment
  Please follow the links below to install all the required software and pre-requisites e.g. rvm, Nginx etc.
   [Capistrano puma nginx](https://www.digitalocean.com/community/tutorials/deploying-a-rails-app-on-ubuntu-14-04-with-capistrano-nginx-and-puma).
   [Capistrano gem](https://github.com/capistrano/capistrano/).
   [nginx missing sites available](https://stackoverflow.com/questions/17413526/nginx-missing-sites-available-directory).

# Deployment Steps:
  1. Clone the iris app from repository [Gitswarm](http://gitswarm.corp.ooma.com/Jeff.Kirk/iris).
  `git clone http://gitswarm.corp.ooma.com/Jeff.Kirk/iris`
  Run the rvm commands to select the ruby version.
  `rvm use 2.3.1` and `rvm gemset use iris` and `bundle install` and `rails s`
  This will run the application on local machine.
  http://localhost:3000/

  2. Follow the deployment steps below
     - `RAILS_ENV=production rake secret`
       The above command will generate a secret key which will be used in the next command.
     - `cap production config:set SECRET_KEY_BASE=51651651651651651aaxasxa16sx51a651sx6sa51x6as51x`
       This command creates a .env file and puts the SECRET_KEY_BASE variable in it and copies this file on the remote machine.
     - Then create a database.yml file with production environment variables which will be used to copy on the remote machine.
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
      Run following command from root of iris app
      `bundle exec cap production setup`.
      which will copy secret_key.yml and database.yml files to a shared directory on the remote server.
      and after the deployment, it will automatically be symlinked to appropriate files in the config folder.
    - Then run `cap production deploy` which will run all the deployment tasks on the remote machine, like cloning the application, running the migration, asset compilation etc. and start an application in production mode.

## Details of deployment.
Please go through all the readme files of following gems.
[capistrano rvm](https://github.com/capistrano/rvm),
[capistrano puma](https://github.com/seuros/capistrano-puma),
[capistrano database.yml](https://github.com/potsbo/capistrano-database-yml),
[capistrano-dotenv-tasks](https://github.com/glyph-fr/capistrano-dotenv-tasks),
[capistrano3-nginx](https://github.com/platanus/capistrano3-nginx),
[capistrano-resque](https://github.com/sshingler/capistrano-resque).

### Capistrano with Puma
    All the puma default configuration like puma workers, puma socket file path etc are set in
    config/deploy.rb. It can be changed as per requirements. The workers count depends on CPU cores count.

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
    When we run `cap puma:config` it will create and upload a puma configuration file on remote machine and when puma gets started  at the end of deployment task it will use this file to get configuration and start a server.

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
  
  Resque is a redis based background job processor. The resque default configuration in can be checked in config/initializer/resque.rb  (it uses 2 databases of redis cluster without conflicting with the database used by iriscollector.)
  
 Resque scheduler is used to run recurring jobs. For that, a cron style yml file is used to declare the jobs
 (config/resque_schedule.yml). When rails server is started, it will load this task into resque. The schedule can be seen at http://localhost:3000/resque/schedule.
  
  Then start a scheduler to load this job in a queue.
  `cap production  resque:scheduler:start`

  Then start workers to run these queued jobs.
  `cap production  resque:start`    
  
  The queue and workers count are defined in config/deploy/production.rb  

   
All the rake tasks are transferred into a resque worker (check app/workers folder) and these workers are getting called via scheduler with the help of config/resque_schedule.yml. 

## Capistrano with previous release.

The scenario when there is issue in current release in capistrano and we want to go back to a particular git release do the following steps.

1. git checkout '654656546'(a long sha of commit id)
2. Take the last migration number because we want to revert to that particular migration.
3. git checkout iris-p4 (checkout to master branch )
4. In the config/deploy.rb put this code
   ```
namespace :deploy do

     task :set_current_revision do
        on release_roles :all do
          within repo_path do
            with fetch(:git_environmental_variables) do
              set :current_revision,  "6740ee253237c3841b136a05b5107c9001996ecc"
  
            end
          end
        end
      end
end       
   ```

Just replace with the current_revision we want to change.

5. cap production deploy
6. cap production  deploy:migrate VERSION=20170612113105(the last migration id we captured in checkout command)
if this command never gives any output then manually login to server and run this command.

now we wanted to release again to a latest release after problem gets solved
1. comment that set :current_revision,  "6740ee253237c3841b136a05b5107c9001996ecc"
  line.
1. cap production config:setup
2. cap production deploy



