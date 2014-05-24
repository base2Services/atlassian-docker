if [ "$(docker run busybox echo 'test')" != "test" ]; then
  SUDO=sudo
  if [ "$($SUDO docker run busybox echo 'test')" != "test" ]; then
    echo "Could not run docker"
    exit 1
  fi
fi
$SUDO docker pull zaiste/postgresql
$SUDO docker run -d --name postgres -p=5432:5432 zaiste/postgresql

$SUDO docker build -t durdn/atlassian-base base

cd "$(dirname $0)"
cat initialise_db.sh | $SUDO docker run --rm -i --link postgres:db zaiste/postgresql bash -

$SUDO docker build -t durdn/stash stash
STASH_VERSION="$($SUDO docker run --rm durdn/stash sh -c 'echo $STASH_VERSION')"
$SUDO docker tag durdn/stash durdn/stash:$STASH_VERSION

$SUDO docker run -d --name stash --link postgres:db -p 7990:7990 -p 7999:7999 durdn/stash

$SUDO docker build -t durdn/jira jira
JIRA_VERSION="$($SUDO docker run --rm durdn/jira sh -c 'echo $JIRA_VERSION')"
$SUDO docker tag durdn/jira durdn/jira:$JIRA_VERSION

$SUDO docker run -d --name jira --link postgres:db --link stash:stash -p 8080:8080 durdn/jira

echo "Containers running..."
$SUDO docker ps

echo "IP Addresses of containers:"
$SUDO docker inspect -f '{{ .Config.Hostname }} {{ .Config.Image }} {{ .NetworkSettings.IPAddress }}' postgres stash jira
