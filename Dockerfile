# Spin-docker example dockerfile for a Two Scoops-style Django project
# https://github.com/atbaker/spin-docker | https://github.com/twoscoops/django-twoscoops-project

# Use phusion/baseimage as base image
FROM phusion/baseimage:0.9.8

# Set correct environment variables
ENV HOME /root

# Use the phusion baseimage's insecure key
RUN /usr/sbin/enable_insecure_key

# Install pyScss
RUN apt-get install -y libpcre3-dev
RUN apt-get install -y python-pyscss python-yaml
RUN pip install pyScss

# Add the Django app to the container and install its requirements
#ADD sd_sample_project /var/www/django
ADD horizon-master /var/www/django
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y python-pip
RUN pip install virtualenv
RUN virtualenv /var/www/venv
#RUN /var/www/venv/bin/pip install -r /var/www/django/requirements.txt
RUN /var/www/venv/bin/pip install -r /var/www/django/requirements.txt

# Syncdb (a sqlite3 database for simplicity)
#ENV PYTHONPATH $PYTHONPATH:/var/www/django/sd_sample_project
#ENV DJANGO_SETTINGS_MODULE sd_sample_project.settings.production
#ENV SECRET_KEY no-so-secret # Fix for your own site!
#RUN /var/www/venv/bin/django-admin.py syncdb --migrate --noinput
#RUN /var/www/venv/bin/django-admin.py collectstatic --noinput

# Create gunicorn log files
RUN mkdir /var/log/gunicorn
RUN touch /var/log/gunicorn/access.log
RUN touch /var/log/gunicorn/error.log

# Install gunicorn runit service
RUN mkdir /etc/service/gunicorn
ADD run_gunicorn.sh /etc/service/gunicorn/run
RUN chown root /etc/service/gunicorn/run


# Clean up APT when done
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*


EXPOSE 22 80

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]
