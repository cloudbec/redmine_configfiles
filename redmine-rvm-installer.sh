

# This script configure a redmine on ubuntu 13.10 with a remote mariadb database

luser = luser
dbuser = redmine
dbpwd = password
dbhost = hostname


# System up-to-date
sudo apt-get -y install sudo
sudo apt-get -y install software-properties-common
sudo apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xcbcb082a1bb943db
sudo add-apt-repository -y 'deb http://mirror.weathercity.com/mariadb/repo/10.0/ubuntu saucy main'
sudo apt-get update



# Install all packages we need (nginx will be installed later... see :156)
sudo apt-get install -y \
			gcc \
			build-essential \
			zlib1g \
			zlib1g-dev \
			zlibc \
			libapr1-dev \
			mariadb-client \
			libmariadbclient-dev \
			git \
			git-man \
			liberror-perl \
			libxslt1.1 
			openssl \
			libcurl4-openssl-dev \
			libreadline6 \
			libreadline6-dev \
			curl  \
			git-core \
			zlib1g \
			zlib1g-dev \
			libssl-dev \
			libyaml-dev \
			libxml2-dev \
			libxslt-dev \
			autoconf \
			libc6-dev \
			ncurses-dev  \
			automake \
			libtool \
			bison \
			pkg-config \
			imagemagick \
			libmagickcore-dev \
			libmagickwand-dev


# Install RVM to manage the ruby versions

cd /home/%LUSER/

\curl -L https://get.rvm.io | bash -s stable

source ~/.rvm/scripts/rvm
rvm requirements


# The latest ruby is now installed. However, since we accessed it through a program that has a variety of Ruby versions, we need to tell the system to use the version we just installed by default.


rvm use ruby --default

# The next step makes sure that we have all the required components of Ruby on Rails.

rvm rubygems current

#create the directory to install redmine


mkdir -p ~/apps/redmine

git clone git://github.com/redmine/redmine.git ~/apps/redmine


# copy configuration files

curl -o   ~/apps/redmine/config/database.yml  https://raw.github.com/cloudbec/redmine_configfiles/master/database.yml 

curl -o   ~/apps/redmine/config/configuration.yml  https://raw.github.com/cloudbec/redmine_configfiles/master/configuration.yml

# update configuration files with host and password

sed 's/redmineuserpassword/$dbpwd/' ~/apps/redmine/config/database.yml 1> ~/apps/redmine/config/database.yml

sed 's/databasehost/$dbhost/' ~/apps/redmine/config/database.yml 1> ~/apps/redmine/config/database.yml

sed 's/reduser/$dbuser/' ~/apps/redmine/config/database.yml 1> ~/apps/redmine/config/database.yml


# install bundler and bundle it

gem install bundler

bundle install --without development test



# Create the database structure  

RAILS_ENV=production rake db:migrate


# install unicorn gem file

curl -o   ~/apps/redmine/Gemfile.local  https://raw.github.com/cloudbec/redmine_configfiles/master/gemfile.local



bundle install --without development test


# make directories to hold files

mkdir -p ~/shared/{config/redmine,log/redmine,pid/redmine,socket/redmine}

# install configuration file for unicorn

curl -o ~/shared/config/redmine/unicorn.rb https://raw.github.com/cloudbec/redmine_configfiles/master/unicorn.rb


# init scripts

sudo curl -o /etc/init.d/redmine https://raw.github.com/cloudbec/redmine_configfiles/master/redmine-script


sudo sed 's/david/$LUSER/' /etc/init.d/redmine 1> /etc/init.d/redmine


sudo chmod +x /etc/init.d/redmine

sudo update-rc.d -f redmine defaults

rake generate_secret_token

echo 'now you can play with configuration files'

