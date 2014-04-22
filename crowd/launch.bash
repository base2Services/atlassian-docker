#!/bin/bash
set -o errexit

sudo own-volume
cd apache-tomcat/conf/Catalina/localhost
for k in $(ls) ; do
  unlink $k
done

if [ -n "$DEMO_CONTEXT" ]; then
  echo "Installing demo at $DEMO_CONTEXT"
  ln -s /opt/crowd/webapps/demo.xml ${DEMO_CONTEXT}.xml
fi

if [ -n "$SPLASH_CONTEXT" ]; then
  echo "Installing splash as $SPLASH_CONTEXT"
  ln -s /opt/crowd/webapps/splash.xml ${SPLASH_CONTEXT}.xml
fi

if [ -n "$OPENID_CLIENT_CONTEXT" ]; then
  echo "Installing OpenID client at $OPENID_CLIENT_CONTEXT"
  ln -s /opt/crowd/webapps/openidclient.xml ${OPENID_CLIENT_CONTEXT}.xml
fi

if [ -n "$CROWDID_CONTEXT" ]; then
  echo "Installing OpenID server at $CROWDID_CONTEXT"
  ln -s /opt/crowd/webapps/openidserver.xml ${CROWDID_CONTEXT}.xml
fi

if [ -n "$CROWD_CONTEXT" ]; then
  echo "Installing Crowd at $CROWD_CONTEXT"
  ln -s /opt/crowd/webapps/crowd.xml ${CROWD_CONTEXT}.xml
fi
cd /opt/crowd

if [ -z "$DEMO_LOGIN_URL" ]; then
  if [ "$DEMO_CONTEXT" == "ROOT" ]; then
    DEMO_LOGIN_URL="$LOGIN_BASE_URL/"
  else
    DEMO_LOGIN_URL="$LOGIN_BASE_URL/$DEMO_CONTEXT"
  fi
fi

if [ -z "$CROWDID_LOGIN_URL" ]; then
  if [ "$CROWDID_CONTEXT" == "ROOT" ]; then
    CROWDID_LOGIN_URL="$LOGIN_BASE_URL/"
  else
    CROWDID_LOGIN_URL="$LOGIN_BASE_URL/$CROWDID_CONTEXT"
  fi
fi

urldecode() {
    local data=${1//+/ }
    printf '%b' "${data//%/\x}"
}

parse_url() {
  local prefix=DATABASE
  [ -n "$2" ] && prefix=$2
  # extract the protocol
  local proto="`echo $1 | grep '://' | sed -e's,^\(.*://\).*,\1,g'`"
  local scheme="`echo $proto | sed -e 's,^\(.*\)://,\1,g'`"
  # remove the protocol
  local url=`echo $1 | sed -e s,$proto,,g`

  # extract the user and password (if any)
  local userpass="`echo $url | grep @ | cut -d@ -f1`"
  local pass=`echo $userpass | grep : | cut -d: -f2`
  if [ -n "$pass" ]; then
    local user=`echo $userpass | grep : | cut -d: -f1`
  else
    local user=$userpass
  fi

  # extract the host -- updated
  local hostport=`echo $url | sed -e s,$userpass@,,g | cut -d/ -f1`
  local port=`echo $hostport | grep : | cut -d: -f2`
  if [ -n "$port" ]; then
    local host=`echo $hostport | grep : | cut -d: -f1`
  else
    local host=$hostport
  fi

  # extract the path (if any)
  local full_path="`echo $url | grep / | cut -d/ -f2-`"
  local path="`echo $full_path | cut -d? -f1`"
  local query="`echo $full_path | grep ? | cut -d? -f2`"
  local -i rc=0
  
  [ -n "$proto" ] && eval "export ${prefix}_SCHEME=\"$scheme\"" || rc=$?
  [ -n "$user" ] && eval "export ${prefix}_USER=\"`urldecode $user`\"" || rc=$?
  [ -n "$pass" ] && eval "export ${prefix}_PASSWORD=\"`urldecode $pass`\"" || rc=$?
  [ -n "$host" ] && eval "export ${prefix}_HOST=\"`urldecode $host`\"" || rc=$?
  [ -n "$port" ] && eval "export ${prefix}_PORT=\"`urldecode $port`\"" || rc=$?
  [ -n "$path" ] && eval "export ${prefix}_NAME=\"`urldecode $path`\"" || rc=$?
  [ -n "$query" ] && eval "export ${prefix}_QUERY=\"$query\"" || rc=$?
}

config_line() {
    local key="$(echo $2 | sed -e 's/[]\/()$*.^|[]/\\&/g')"
    if [ -n "$3" ]; then
      local value="$(echo $3 | sed -e 's/[\/&]/\\&/g')"
      sed -i -e "s/^$key\s*=\s*.*/$key=$value/" $1
    else
      sed -n -e "s/^$key\s*=\s*//p" $1
    fi
}

download_mysql_driver() {
  local driver="mysql-connector-java-5.1.30"
  if [ ! -f "/opt/crowd/apache-tomcat/lib/$driver-bin.jar" ]; then
    echo "Downloading MySQL JDBC Driver..."
    curl -L http://dev.mysql.com/get/Downloads/Connector-J/$driver.tar.gz | tar zxv -C /tmp
    cp /tmp/$driver/$driver-bin.jar /opt/crowd/apache-tomcat/lib/$driver-bin.jar
  fi
}

if [ -n "$CROWD_CONTEXT" ]; then
  if [ -z "$CROWDDB_URL" -a -n "$DATABASE_URL" ]; then
    used_database_url=1
    CROWDDB_URL="$DATABASE_URL"
  fi
  if [ -n "$CROWDDB_URL" ]; then
    unset CROWDDB_PORT
    parse_url "$CROWDDB_URL" CROWDDB
    case "$CROWDDB_SCHEME" in
      postgres|postgresql)
        if [ -z "$CROWDDB_PORT" ]; then
          CROWDDB_PORT=5432
        fi
        CROWDDB_JDBC_DRIVER="org.postgresql.Driver"
        CROWDDB_JDBC_URL="jdbc:postgresql://$CROWDDB_HOST:$CROWDDB_PORT/$CROWDDB_NAME"
        ;;
      mysql|mysql2)
        download_mysql_driver
        if [ -z "$CROWDDB_PORT" ]; then
          CROWDDB_PORT=3306
        fi
        CROWDDB_JDBC_DRIVER="com.mysql.jdbc.Driver"
        CROWDDB_JDBC_URL="jdbc:mysql://$CROWDDB_HOST:$CROWDDB_PORT/$CROWDDB_NAME?autoReconnect=true&amp;useUnicode=true&amp;characterEncoding=utf8"
        ;;
      *)
        echo "Unsupported database url scheme: $CROWDDB_SCHEME"
        exit 1
        ;;
    esac
    cat << EOF > webapps/crowd.xml
    <Context docBase="../../crowd-webapp" useHttpOnly="true">
      <Resource name="jdbc/CrowdDS" auth="Container" type="javax.sql.DataSource"
                username="$CROWDDB_USER"
                password="$CROWDDB_PASSWORD"
                driverClassName="$CROWDDB_JDBC_DRIVER"
                url="$CROWDDB_JDBC_URL"
              />
    </Context>
EOF
  fi
fi

if [ -n "$CROWDID_CONTEXT" ]; then
  if [ -z "$CROWDIDDB_URL" -a -n "$DATABASE_URL" ]; then
    if [ -n "$used_database_url" ]; then
      echo "DATABASE_URL is ambiguous since both Crowd and CrowdID are enabled."
      echo "Please use CROWDIDDB_URL and CROWDDB_URL instead."
      exit 2
    fi
    CROWDIDDB_URL="$DATABASE_URL"
  fi
  if [ -n "$CROWDIDDB_URL" ]; then
    unset CROWDDB_PORT
    parse_url "$CROWDIDDB_URL" CROWDIDDB
    case "$CROWDIDDB_SCHEME" in
      postgres|postgresql)
        if [ -z "$CROWDDB_PORT" ]; then
          CROWDDB_PORT=5432
        fi
        CROWDIDDB_JDBC_DRIVER="org.postgresql.Driver"
        CROWDIDDB_JDBC_URL="jdbc:postgresql://$CROWDIDDB_HOST:$CROWDIDDB_PORT/$CROWDIDDB_NAME"
        CROWDIDDB_DIALECT="org.hibernate.dialect.PostgreSQLDialect"
        ;;
      mysql|mysql2)
        download_mysql_driver
        if [ -z "$CROWDDB_PORT" ]; then
          CROWDDB_PORT=3306
        fi
        CROWDIDDB_JDBC_DRIVER="com.mysql.jdbc.Driver"
        CROWDIDDB_JDBC_URL="jdbc:mysql://$CROWDIDDB_HOST:$CROWDIDDB_PORT/$CROWDIDDB_NAME?autoReconnect=true&amp;useUnicode=true&amp;characterEncoding=utf8"
        CROWDIDDB_DIALECT="org.hibernate.dialect.MySQLDialect"
        ;;
      *)
        echo "Unsupported database url scheme: $CROWDIDDB_SCHEME"
        exit 1
        ;;
    esac
    cat << EOF > webapps/openidserver.xml
    <Context docBase="../../crowd-openidserver-webapp">
      <Resource name="jdbc/CrowdIDDS" auth="Container" type="javax.sql.DataSource"
                username="$CROWDIDDB_USER"
                password="$CROWDIDDB_PASSWORD"
                driverClassName="$CROWDIDDB_JDBC_DRIVER"
                url="$CROWDIDDB_JDBC_URL"
              />
    </Context>
EOF
    config_line build.properties hibernate.dialect "$CROWDIDDB_DIALECT"
  fi
fi

config_line build.properties demo.url "$DEMO_LOGIN_URL"
config_line build.properties openidserver.url "$CROWDID_LOGIN_URL"
config_line build.properties crowd.url "$CROWD_URL"

./build.sh

if [ -f "/opt/crowd-home/crowd.properties" ]; then
  config_line /opt/crowd-home/crowd.properties crowd.server.url "$(config_line crowd-webapp/WEB-INF/classes/crowd.properties crowd.server.url)"
  config_line /opt/crowd-home/crowd.properties application.login.url "$(config_line crowd-webapp/WEB-INF/classes/crowd.properties application.login.url)"
fi

apache-tomcat/bin/catalina.sh run