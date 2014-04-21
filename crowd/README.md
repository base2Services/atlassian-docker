# Crowd Docker image

This folder contains the Dockerfile and associated files for the ```griff/crowd``` docker image which aims to make it a breeze getting an Atlassian Crowd instance up and running.

If you just want a test setup to try out Crowd just do:
```
docker run -p 8095:8095 griff/crowd
```
And point your browser to [http://localhost:8095](http://localhost:8095) for the welcome screen.


## Database connection

The connection to the database can be specified with an URL of the format:
```
[database type]://[username]:[password]@[host]:[port]/[database name]
```
Where ```database type``` is either ```mysql``` or ```postgresql``` and the full URL might look like this:
```
postgresql://crowd:jellyfish@172.17.0.2/crowddb
```

The URL can be used to fully configure the database for CrowdID but for Crowd you still have to manually go through the database setup step and specify the following:

* For type select: JNDI Datasource
* Select either PostgreSQL or MySQL depending on your configuration as the Database preconfiguration in the dropdown
* Specify ```java:comp/env/jdbc/CrowdDS``` as the JNDI Name
* Leave the other fields to their defaults.


## Configuration & Components

The docker image is based on the standalone install of Crowd and as such consists of several independent components that each have several configurable options and that can also be entirely disabled. The configuration options themselves are set by setting environment variables when running the image

What follows is a short description of each component and the configuration options that affect that component. For all other aspects about configuring, using and administering Crowd please see [The Official Crowd Documentation](https://confluence.atlassian.com/display/CROWD/Crowd+Documentation)


### Crowd

The main component included and really the only component that you truly need. This component needs a database but can use an embedded HSQLDB for testing purposes and so the database related variables are not mandatory. 

Variable      | Function
--------------|------------------------------
CROWD_URL     | URL used by the console to talk to itself. 
CROWD_CONTEXT | Context path of the crowd webapp. Set this to ```ROOT``` to make this component have no context path. Set to blank string to not load the Crowd component. Please note that the context path for each component must be unique. Defaults to ```crowd```
CROWDDB_URL   | Connection URL specifying where and how to connect to a database dedicated to crowd.
DATABASE_URL  | If only Crowd and not CrowdID is set to load you can use this variable as an alternative to the ```CROWDDB_URL``` variable.


### CrowdID

The bundled OpenID server. Like the Crowd component this also needs a database and it is imperative that this be independent of the Crowd database. 

Variable          | Function
------------------|------------------------------
CROWD_URL         | URL of the crowd server that the webapp talks to. This need not be on the same machine that is running the CrowdID component.
CROWDID_CONTEXT   | Context path of the CrowdID webapp. Defaults to ```openidserver```
CROWDIDDB_URL     | Connection URL specifying where and how to connect to a database dedicated to CrowdID. This database must be separate from the one used by Crowd
DATABASE_URL      | If only CrowdID and not Crowd is set to load you can use this variable as an alternative to the ```CROWDIDDB_URL``` variable.
LOGIN_BASE_URL    | Combined with ```CROWDID_CONTEXT``` to set the ```CROWDID_LOGIN_URL``` value if that variable is unset.
CROWDID_LOGIN_URL | The URL that crowd will redirect the user to this URL if their authentication token expires or is invalid due to security restrictions.


### OpenID client

An OpenID client that can be used to test the CrowdID integration.

Variable              | Function
----------------------|------------------------------
OPENID_CLIENT_CONTEXT | Context path of the client. Defaults to ```openidclient```.


### Demo webapp

A demonstration webapp that shows how Crowd integration works.

Variable       | Function
---------------|------------------------------
CROWD_URL      | URL of the crowd server that the webapp talks to.
DEMO_CONTEXT   | Context path of the crowd webapp. Set to blank string to not load the Crowd component. Please note that the context path for each component must be unique. Defaults to ```demo```
LOGIN_BASE_URL | Combined with ```DEMO_CONTEXT``` to set the ```DEMO_LOGIN_URL``` value if that variable is unset.
DEMO_LOGIN_URL | The URL that crowd will redirect the user to this URL if their authentication token expires or is invalid due to security restrictions.


### Default welcome splash pages

This component serves just as a welcome page and since it is by default loaded as the root context will be the first thing you see when going to http://localhost:8095. As such it has links to the other components but keep in mind that these links will not be updated should you change the context path of any of the components.

For anything but a default install it is recommended that you disable this component by setting its context path to the empty string. 

Variable       | Function
---------------|------------------------------
SPLASH_CONTEXT | Context path of the splash pages. Defaults to ```ROOT``` as this webapp serves as a welcome page and you will usually just want to set this to blank to not load this component.


## Examples

To start Crowd with the context path removed. Basically having the startup script perform the steps from the [Crowd FAQ](https://confluence.atlassian.com/display/CROWD/Removing+the+'crowd'+Context+from+the+Application+URL). Simply run:

```
docker run -e CROWD_CONTEXT=ROOT -e CROWD_URL=http://localhost:8095 -e SPLASH_CONTEXT= -p 8095:8095 griff/crowd
```

To only run CrowdID, pointing it at a Crowd at http://crowd.example.local:8095/crowd and with a postgresql database at db.example.local:
```
docker run -e CROWD_URL=http://crowd.example.local:8095/crowd -e DATABASE_URL=postgresql://crowdid:jellyfish@db.example.local/crowdiddb -e CROWDID_CONTEXT=ROOT -e CROWD_CONTEXT= -e SPLASH_CONTEXT= -e DEMO_CONTEXT= -e OPENID_CLIENT_CONTEXT= -p 8095:8095 griff/crowd
```
