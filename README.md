# Capistrano deployment
  Before start reading this documentation please have a look at following links as i really use all the steps written there and installed all the basic softwares like rvm,nginx etc.
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
     - RAILS_ENV=production rake secret 
       The above command will generate a secret key which we will use in the next command.
     - cap production config:set SECRET_KEY_BASE=51651651651651651aaxasxa16sx51a651sx6sa51x6as51x 
       With this command we actually create a .env file and put the SECRET_KEY_BASE variable in it 
       and copied this file on remote machine.
     - Then create a database.yml file with production environment variables which will be used 
       to copy on remote machine.
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
      which will a copy of secret_key.yml and database.yml file to shared directory on remote server.
      and on deployment it will automatically symlinked to appropriate files in config folder.
    - Then run `cap production deploy` which will run all the deployment task on remote machine.
      like cloning the application,run the migration run the asset compilation etc. and start a 
      application in production mode. 
###  Details of deployment.
     Please first go through all the readme files of following gems.
     [capistrano rvm](https://github.com/capistrano/rvm) 
     [capistrano puma](https://github.com/seuros/capistrano-puma)
     [capistrano database.yml](https://github.com/potsbo/capistrano-database-yml)
     [capistrano-dotenv-tasks](https://github.com/glyph-fr/capistrano-dotenv-tasks)
     [capistrano3-nginx](https://github.com/platanus/capistrano3-nginx)
     [capistrano-resque](https://github.com/sshingler/capistrano-resque). 




