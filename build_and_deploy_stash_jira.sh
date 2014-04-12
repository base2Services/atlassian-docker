sudo docker pull zaiste/postgresql
sudo docker run -d --name postgres -p=5432:5432 zaiste/postgresql

cd /vagrant
cat initialise_db.sh | sudo docker run --rm -i --link postgres:db zaiste/postgresql bash -

cd /vagrant/stash
sudo docker build -t durdn/stash-2.9.1 .

sudo docker run -d --name stash --link postgres:db -p 7990:7990 durdn/stash-2.9.1

cd /vagrant/jira
sudo docker build -t durdn/jira-6.1.1 .

sudo docker run -d --name jira --link postgres:db --link stash:stash -p 8080:8080 durdn/jira-6.1.1

echo "Containers running..."
sudo docker ps

echo "IP Addresses of containers:"
paste <(sudo docker ps | tail -n +2 | awk {'printf "%s\t%s\n", $1, $2 '}) <(sudo docker ps  -q | xargs sudo docker inspect | tail -n +2 | grep IPAddress | awk '{ print $2 }' | tr -d ',"')

