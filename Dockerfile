# Errbit
#
# VERSION 1.0

# Use the ubuntu base image provided by dotColud
FROM ubuntu

MAINTAINER Keiji Yoshida, yoshida.keiji.84@gmail.com

# Install packages for building ruby
RUN apt-get update
RUN apt-get install -y --force-yes build-essential curl git
RUN apt-get install -y --force-yes zlib1g-dev libssl-dev libreadline-dev libyaml-dev libxml2 libxml2-dev libxslt-dev libcurl4-openssl-dev
RUN apt-get clean

# Add Brightbox ruby mirror
RUN apt-get install -y python-software-properties
RUN apt-add-repository ppa:brightbox/ruby-ng
RUN apt-get update

# Install Ruby 2.1.0
RUN apt-get install -y ruby2.1 ruby2.1-dev

# Install MongoDB
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 7F0CEB10
RUN echo 'deb http://downloads-distro.mongodb.org/repo/ubuntu-upstart dist 10gen' | tee /etc/apt/sources.list.d/mongodb.list
RUN apt-get update
RUN apt-get install -y --force-yes mongodb-10gen
RUN mkdir -p /mongodb/data
RUN mkdir /mongodb/log

# Install Bundler
RUN bash -l -c 'gem install bundler'

# Install Errbit
RUN git clone https://github.com/errbit/errbit.git /errbit
RUN bash -l -c 'cd /errbit; bundle install'

# Bootstrap Errbit (needs running mongodb)
RUN bash -l -c 'mongod --dbpath /mongodb/data --logpath /mongodb/log/mongo.log &'; bash -l -c 'cd /errbit; rake errbit:bootstrap';

# Install and configure supervisord (process control)
RUN apt-get install -y supervisor
RUN mkdir -p /var/log/supervisor
ADD ./supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Expose rails server port
EXPOSE 3000

CMD ["supervisord", "-n"]
