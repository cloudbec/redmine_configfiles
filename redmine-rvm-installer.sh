

# This script configure a redmine on ubuntu 13.10 with a remote mariadb database

user = 



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

cd /home/%USER/

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


# Add Gitlab user
adduser --disabled-login --gecos 'GitLab' git


# Create Database
mysql -u root -p

    CREATE USER 'gitlab'@'localhost' IDENTIFIED BY 'YOUR GITLAB PASSWORD';
    CREATE DATABASE IF NOT EXISTS `gitlabhq_production` DEFAULT CHARACTER SET `utf8` COLLATE `utf8_unicode_ci`;
    GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, INDEX, ALTER ON `gitlabhq_production`.* TO 'gitlab'@'localhost';
    \q


# Test SQL (need to enter YOUR GITLAB PASSWORD)
mysql -u gitlab -p -D gitlabhq_production


su git
    # Set git username and email
    git config --global user.name  "GitLab"
    git config --global user.email "gitlab@localhost"

    # Install Ruby RVM with ruby1.9.3
    \curl -L https://get.rvm.io | bash -s stable

    echo "source /home/git/.rvm/scripts/rvm" >> .bashrc

    source /home/git/.rvm/scripts/rvm
    source ~/.profile

    rvm get head
    rvm reload
    rvm install 1.9.3
    rvm --default use 1.9.3
    echo "source /home/git/.rvm/scripts/rvm" >> .bashrc
    source /home/git/.rvm/scripts/rvm

    # Install bundler
    gem install bundler

    # Clone & Install GitlabShell
    git clone https://github.com/gitlabhq/gitlab-shell.git
    cd gitlab-shell
    cp config.yml.example config.yml
    vim config.yml
    ./bin/install

    # Adjust the shebang for RVM
    # After fresh checkout: #!/usr/bin/env ruby
    # Change it to: #!/usr/bin/env /home/git/.rvm/bin/ruby
    vim bin/gitlab-shell


    cd /home/git

    # Clone gitlab
    git clone https://github.com/gitlabhq/gitlabhq.git gitlab
    cd /home/git/gitlab
    cp config/gitlab.yml.example config/gitlab.yml
    vim config/gitlab.yml


    chmod -R u+rwX  log/
    chmod -R u+rwX  tmp/

    # Create directory for satellites
    mkdir /home/git/gitlab-satellites

    # Create temp and make sure its wirtable
    mkdir tmp/pids/
    chmod -R u+rwX  tmp/pids/

    # Copy config templates
    cp config/unicorn.rb.example config/unicorn.rb
    cp config/database.yml.mysql config/database.yml

    # Configure database
    vim config/database.yml

    # Setup gitlab dependencies and database
    gem install charlock_holmes --version '0.6.9'
    bundle install --deployment --without development test postgres

    bundle exec rake db:setup RAILS_ENV=production
    bundle exec rake db:seed_fu RAILS_ENV=production
    bundle exec rake gitlab:setup RAILS_ENV=production

    # Check configuration
    bundle exec rake gitlab:env:info RAILS_ENV=production

    exit

# Install init.d-script and run gitlab's sidekiq and unicorn
curl --output /etc/init.d/gitlab https://raw.github.com/gitlabhq/gitlab-recipes/master/init.d/gitlab
chmod +x /etc/init.d/gitlab
/etc/init.d/gitlab start
update-rc.d gitlab defaults 21

# Install nginx and install gitlab site-config
apt-get install nginx
curl --output /etc/nginx/sites-available/gitlab https://raw.github.com/gitlabhq/gitlab-recipes/master/nginx/gitlab
ln -s /etc/nginx/sites-available/gitlab /etc/nginx/sites-enabled/gitlab
vim /etc/nginx/sites-available/gitlab
service nginx restart

# Check if everything works
su git
cd /home/git/gitlab
bundle exec rake gitlab:check RAILS_ENV=production


