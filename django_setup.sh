





# ********  set up   ******  install the necessaries
apt update
apt install python3-pip python3-dev libpq-dev postgresql postgresql-contrib nginx curl
# ********  

# Enter postgres
su - postgres

database_name=skewt
database_user=jokea
dbuser_password=e£cv23w43brc£4fDF
psql -U postgres -c "CREATE DATABASE ${database_name};"
# ********  set up   ******  assign a new role to jokea
psql -U postgres -d $database_name -c "CREATE USER ${database_user} WITH PASSWORD '${dbuser_password}';"
psql -U postgres -d $database_name -c "ALTER ROLE  ${database_user} SET client_encoding TO 'utf8';"
psql -U postgres -d $database_name -c "ALTER ROLE ${database_user} SET timezone TO 'UTC';"
# ********  
psql -U postgres -d $database_name -c "GRANT ALL PRIVILEGES ON DATABASE ${database_name} TO ${database_user};"


# Go back to jokea
su - jokea


# ********  set up   ******  set up the /var/www folder
sudo rm -rf /var/www/html/
sudo chown jokea /var/www
sudo -H pip3 install --upgrade pip
sudo -H pip3 install virtualenv
# *******


venv_name=propylon
git_repo=https://github.com/johnckealy/propylon.git
cd /var/www/
virtualenv ${venv_name}
cd ${venv_name}
source bin/activate
git clone ${git_repo}


projectname=propylon
pip install -r ${projectname}/requirements.txt

touch ${projectname}/.env
vim ${projectname}/.env

mkdir /var/www/${venv_name}/logs && touch /var/www/${venv_name}/logs/gunicorn_supervisor.log
# make  the config files based on https://gist.github.com/postrational/5747293#file-gunicorn_start-bash

vim bin/gunicorn_start

sudo vim /etc/supervisor/conf.d/${projectname}.conf
sudo vim /etc/nginx/sites-available/${projectname}

sudo chmod u+x bin/gunicorn_start

sudo ln -s /etc/nginx/sites-available/${projectname} /etc/nginx/sites-enabled/${projectname}

sudo ufw allow 'Nginx Full'

sudo supervisorctl reread
# appname: available
sudo supervisorctl update
# appname: added process group
sudo supervisorctl status skewt
sudo supervisorctl restart    # optional?
sudo supervisorctl restart skewt    # optional?



#install SSL
sudo certbot --nginx -d example.com -d www.example.com


# trouble shooting
sudo supervisorctl restart johnkealy
sudo nginx -t && sudo systemctl restart nginx
sudo journalctl -u nginx
sudo less /var/log/nginx/access.log
sudo less /var/log/nginx/error.log
sudo journalctl -u gunicorn
sudo journalctl -u gunicorn.socket



