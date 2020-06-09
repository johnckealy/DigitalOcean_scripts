###################################
######### Ruby build ##############


RUBY_VERSION=2.5.1
RAILS_VERSION=5.2.0


###################################



sudo apt update

sudo apt install curl
curl -sL https://deb.nodesource.com/setup_12.x | sudo -E bash -
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
sudo apt-get update
sudo apt-get install nodejs yarn -y

sudo apt install autoconf bison build-essential libssl-dev libyaml-dev libreadline6-dev zlib1g-dev libncurses5-dev libffi-dev libgdbm5 libgdbm-dev

git clone https://github.com/rbenv/rbenv.git ~/.rbenv


echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
echo 'eval "$(rbenv init -)"' >> ~/.bashrc
source ~/.bashrc

git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build

rbenv install -l


rbenv install $RUBY_VERSION

rbenv global 2.5.1

echo "gem: --no-document" > ~/.gemrc

gem install bundler

gem env home

gem install rails -v $RAILS_VERSION

rbenv rehash

rails -v
