rvm_passenger_nginx Cookbook
=================

Installs, configures and deploys multiple Ruby on Rails applications with different versions of ruby and rails. The system stack is formed by RVM for the version manager, Phusion Passenger for the app server and Nginx for the web server.

Requirements
------------
**RVM 0.9.4** is required. This is because our cookbook uses chef-rvm to automatically install ruby versions and required gems specified for each application. Special thanks to Aaron Kalin for this cookbook which is awesome and has a lot of features for us to manage RVM (http://martinisoft.github.com/chef-rvm/).

### Supported Platforms
* Ubuntu

Tested on:
* Ubuntu 14.04

Recipes
------------
### Default
This is the only recipe that should be used to perform a complete installation of the version manager, app and web servers, repo certificates and application repo installation and configurations.

### rvm
This recipe performs the installation of the rvm default system and gem packages from the chef-rvm cookbook from Aaron Kalin.

### passenger_nginx
The recipe performs the installation of both Phusion Passenger and Nginx using the official Phusion repo. It also performs configuration of the nginx.conf file and all required environment variables used by the application.

### certificate_install
This recipe decrypts the 'certificates' data bags and performs its installation on the user that is going to be performing deployments.

### applications
This recipe creates the directory that will be used for the rails application, pulls the source code from the appropiate branch of the repo on every run to have the latest code from the branch, configures the SECRET_KEY_BASE from the config/settings.yml file, performs bundle install and migrates the DB, and creates nginx configuration for the site.

Attributes
------------

License  & Authors
------------
- Author:: Victor D Nava (<viko.nava@gmail.com>)

```text
Copyright:: 2011-2015, Chef Software, Inc

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```
