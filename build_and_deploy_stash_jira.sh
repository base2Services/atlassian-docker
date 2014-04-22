if [ "$(docker run busybox echo 'test')" != "test" ]; then
  SUDO=sudo
  if [ "$($SUDO docker run busybox echo 'test')" != "test" ]; then
    echo "Could not run docker"
    exit 1
  fi
fi
$SUDO docker pull zaiste/postgresql
$SUDO docker run -d --name postgres -p=5432:5432 zaiste/postgresql

cd "$(dirname $0)"
cat initialise_db.sh | $SUDO docker run --rm -i --link postgres:db zaiste/postgresql bash -

$SUDO docker build -t durdn/stash-2.9.1 stash

$SUDO docker run -d --name stash --link postgres:db -p 7990:7990 durdn/stash-2.9.1

$SUDO docker build -t durdn/jira-6.2.3 jira

$SUDO docker run -d --name jira --link postgres:db --link stash:stash -p 8080:8080 durdn/jira-6.2.3

echo "Containers running..."
$SUDO docker ps

echo "IP Addresses of containers:"
$SUDO docker inspect -f '{{ .Config.Hostname }} {{ .Config.Image }} {{ .NetworkSettings.IPAddress }}' postgres stash jira
