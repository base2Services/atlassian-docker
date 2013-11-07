sudo docker pull zaiste/postgresql
sudo docker run -d -name postgres -p=5432:5432 zaiste/postgresql
sudo apt-get install -q -y postgresql-client

cd /vagrant
./initialise_db.sh

cd /vagrant/stash
sudo docker build -t durdn/stash-2.8.2 .

sudo docker run -d -name stash -link postgres:db -p 7990:7990 durdn/stash-2.8.2

cd /vagrant/jira
sudo docker build -t durdn/jira-6.1.1 .

sudo docker run -d -name jira -link postgres:db -link stash:stash -p 8080:8080 durdn/jira-6.1.1

echo "Containers running..."
sudo docker ps

echo "IP Addresses of containers:"
paste <(sudo docker ps | tail -n +2 | awk {'printf "%s\t%s\n", $1, $2 '}) <(sudo docker ps  -q | xargs sudo docker inspect | tail -n +2 | grep IPAddress | awk '{ print $2 }' | tr -d ',"')

