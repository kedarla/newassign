# Capistrano deployment
  Before start reading this documentation please have a look at following links as i really use all the steps written there and installed all the basic softwares like rvm,nginx etc.
   
   [Capistrano puma nginx](https://www.digitalocean.com/community/tutorials/deploying-a-rails-app-on-ubuntu-14-04-with-capistrano-nginx-and-puma).

   [Capistrano gem](https://github.com/capistrano/capistrano/).

   [nginx missing sites available](https://stackoverflow.com/questions/17413526/nginx-missing-sites-available-directory).

#Steps to start with
  First clone the iris app from [Gitswarm](http://gitswarm.corp.ooma.com/Jeff.Kirk/iris) website.

  `git clone http://gitswarm.corp.ooma.com/Jeff.Kirk/iris`

  Then run the rvm commands to select the ruby version.

  `rvm use 2.3.1` and `rvm gemset use iris` and bundle install and `rails s`

  This will run the application on local machine.

  http://localhost:3000/.

###   




