# Stash Docker image

This folder contains the Dockerfile and associated files for the ```durdn/stash``` docker image which aims to make it a breeze getting an Atlassian Stash instance up and running.

## Database connection

The connection to the database can be specified with an URL of the format:
```
[database type]://[username]:[password]@[host]:[port]/[database name]
```
Where ```database type``` is either ```mysql``` or ```postgresql``` and the full URL might look like this:
```
postgresql://stash:jellyfish@172.17.0.2/stashdb
```

When a database url is specified Stash will skip the database configuration step in the setup.

## Configuration

Configuration options are set by setting environment variables when running the image. What follows it a table of the supported variables:

Variable     | Function
-------------|------------------------------
CONTEXT_PATH | Context path of the stash webapp. You can set this to add a path prefix to the url used to access the webapp. i.e. setting this to ```stash``` will change the url to http://localhost:7990/stash/. The value ```ROOT``` is reserved to mean that you don't want a context path prefix. Defaults to ```ROOT```
DATABASE_URL | Connection URL specifying where and how to connect to a database dedicated to stash. This variable is optional and if specified will cause the Jira setup wizard to skip the database setup set.
