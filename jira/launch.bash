#!/bin/bash
set -o errexit

. /usr/local/share/atlassian/common.bash

sudo own-volume
rm -f /opt/atlassian-home/.jira-home.lock

if [ "$CONTEXT_PATH" == "ROOT" -o -z "$CONTEXT_PATH" ]; then
  CONTEXT_PATH=
else
  CONTEXT_PATH="/$CONTEXT_PATH"
fi

xmlstarlet ed -u '//Context/@path' -v "$CONTEXT_PATH" conf/server-backup.xml > conf/server.xml

if [ -n "$DATABASE_URL" ]; then
  extract_database_url "$DATABASE_URL" DB /opt/jira/lib
  DB_JDBC_URL="$(xmlstarlet esc "$DB_JDBC_URL")"
  SCHEMA=''
  if [ "$DB_TYPE" != "mysql" ]; then
    SCHEMA='<schema-name>public</schema-name>'
  fi

  cat <<END > /opt/jira/conf/server.xml
<Server port="8005" shutdown="SHUTDOWN">

  <Service name="Catalina">

    <Connector port="8080"
      maxHttpHeaderSize="8192" maxThreads="150" minSpareThreads="25" maxSpareThreads="75"
      enableLookups="false" redirectPort="8443" acceptCount="100" 
      connectionTimeout="20000" disableUploadTimeout="true" />

    <Engine name="Catalina" defaultHost="localhost">
      <Host name="localhost" appBase="webapps" unpackWARs="true" autoDeploy="true">

        <Context path="" docBase="\${catalina.home}/atlassian-jira" reloadable="false">
          <Resource name="jdbc/JiraDS" auth="Container" type="javax.sql.DataSource"
            username="$DB_USER"
            password="$DB_PASSWORD"
            driverClassName="com.mysql.jdbc.Driver"
            url="jdbc:$DB_JDBC_URL?autoReconnect=true&amp;useUnicode=true&amp;characterEncoding=UTF8"
            />

          <Resource name="UserTransaction" auth="Container" type="javax.transaction.UserTransaction"
            factory="org.objectweb.jotm.UserTransactionFactory" jotm.timeout="60"/>
          <Manager className="org.apache.catalina.session.PersistentManager" saveOnRestart="false"/>
        </Context>

      </Host>
    </Engine>
  </Service>
</Server>
END
  cat <<END > /opt/jira/atlassian-jira/WEB-INF/classes/entityengine.xml
<?xml version="1.0" encoding="UTF-8" ?>
<!DOCTYPE entity-config PUBLIC "-//OFBiz//DTD Entity Engine Config//EN" "http://www.ofbiz.org/dtds/entity-config.dtd">
<entity-config>
    <resource-loader name="maincp" class="org.ofbiz.core.config.ClasspathLoader"/>

    <transaction-factory class="org.ofbiz.core.entity.transaction.JNDIFactory">
      <user-transaction-jndi jndi-server-name="default" jndi-name="java:comp/env/UserTransaction"/>
      <transaction-manager-jndi jndi-server-name="default" jndi-name="java:comp/env/UserTransaction"/>
    </transaction-factory>

    <delegator name="default" entity-model-reader="main" entity-group-reader="main">
        <group-map group-name="default" datasource-name="defaultDS"/>
    </delegator>

    <entity-model-reader name="main">
        <resource loader="maincp" location="entitydefs/entitymodel.xml"/>
    </entity-model-reader>

    <entity-group-reader name="main" loader="maincp" location="entitydefs/entitygroup.xml"/>

    <field-type name="cloudscape" loader="maincp" location="entitydefs/fieldtype-cloudscape.xml"/>
    <field-type name="firebird" loader="maincp" location="entitydefs/fieldtype-firebird.xml"/>
    <field-type name="hsql" loader="maincp" location="entitydefs/fieldtype-hsql18.xml"/>
    <field-type name="mckoidb" loader="maincp" location="entitydefs/fieldtype-mckoidb.xml"/>
    <field-type name="mysql" loader="maincp" location="entitydefs/fieldtype-mysql.xml"/>
    <field-type name="mssql" loader="maincp" location="entitydefs/fieldtype-mssql.xml"/>
    <field-type name="oracle" loader="maincp" location="entitydefs/fieldtype-oracle.xml"/>
    <field-type name="oracle10g" loader="maincp" location="entitydefs/fieldtype-oracle10g.xml"/>
    <field-type name="postgres" loader="maincp" location="entitydefs/fieldtype-postgres.xml"/>
    <field-type name="postgres72" loader="maincp" location="entitydefs/fieldtype-postgres72.xml"/> <!-- use for postgres 7.2 and above -->
    <field-type name="sapdb" loader="maincp" location="entitydefs/fieldtype-sapdb.xml"/>
    <field-type name="sybase" loader="maincp" location="entitydefs/fieldtype-sybase.xml"/>
    <field-type name="db2" loader="maincp" location="entitydefs/fieldtype-db2.xml"/>
    <field-type name="frontbase" loader="maincp" location="entitydefs/fieldtype-frontbase.xml"/>

    <datasource name="defaultDS" field-type-name="$DB_TYPE"
      helper-class="org.ofbiz.core.entity.GenericHelperDAO"
      check-on-start="true"
      use-foreign-keys="false"
      use-foreign-key-indices="false"
      check-fks-on-start="false"
      check-fk-indices-on-start="false"
      add-missing-on-start="true"
      check-indices-on-start="true">
        <jndi-jdbc jndi-server-name="default" jndi-name="java:comp/env/jdbc/JiraDS"/>
    </datasource>
</entity-config>

END
fi

export JRE_HOME=/usr/lib/jvm/java-7-oracle/

/opt/jira/bin/catalina.sh run
