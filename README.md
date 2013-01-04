Sql2Graphite
============

Windows service that can run SQL  Oracle and WMI Queries and post results to Graphite

Licence
=======
All Original Software is licensed under the MIT Licence and does not apply to any other 3rd party tools, utilities or code which may be used to develop this application.

Overview 
========

SqlToGraphite is a windows service that supports a framework for getting centralised configuration and running configured plugins with the configuration. 

Each plugin polls for metrics , e.g. by running a wmi or sql query, and sends the metric to a graphite server. 


Installation 
============

It uses a slient install , running the setup multiple times, will uninstall and reinstall automatically.

The application configuration settings can be passed in via the setup.exe 

These are the following configuration setting paramiters 

hostname       - dns name of the graphite server [default "metrics"]
username       - Optional http basic authentication username [default empty]
password       - Optional http basic authentication password [default empty]
configupdate   - configuration update time in mintues [default 15]
configRetry    - configuration retry time in mintues if there is an error [default 15]
cachelength    - time to cache a configuration [default 15]
configuri      - uri which hosts the configuration [default "http://metrics/svn/config.xml"]

example usage 

sqltographite-setup.exe /username=someuser /password=somepass /hostname=somehost


Application configuration settings. 
===================================
 


 User interface
 ==============





Configuration information. 
==========================
Hostname uses Regular expressions to match against. 

Type is the .Net type of the plugin required. This is loaded at runtime 

Wmi connections strings. 

If the connection string is passed in then it will be used, otherwise it will use the local credentials on the local host. 
The wmi connection string is of the format "Username=someUser;Password=abcd1234;hostname=somehost;

if the hostname is not passed in there will be an expection thrown because it will try and user the credentails on local host which is not allowed. 


Plugins
=======


Oracle 
SqlServer
Wmi 


