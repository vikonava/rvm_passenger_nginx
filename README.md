rvm_passenger_nginx Cookbook
=================

Installs, configures and deploys multiple Ruby on Rails applications with different versions of ruby and rails. The system stack is formed by RVM for the version manager, Phusion Passenger for the app server and Nginx for the web server.

Everytime this cookbook is ran, it checks on the application attributes to update configurations, certificates and pull the latest code from your git server.

This Cookbook is meant to be used continuously, meaning that you can run its default recipe every X amount of minutes on your node or client to always have the latest code from the branch you pick deployed on your server, deploy new applications or remove applications from being accesed on the server. It is especially useful when you want to easily manage multiple applications in one webserver, you are continuously changing the branches as part of test or new deployments, and when you want to ensure to always have the latest code on your server. 

Requirements
------------
**RVM 0.9.4** is required. This is because our cookbook uses chef-rvm to automatically install ruby versions and required gems specified for each application. Special thanks to Aaron Kalin for this cookbook which is awesome and has a lot of features for us to manage RVM (http://martinisoft.github.com/chef-rvm/).

### Supported Platforms
* Ubuntu >=12
* Debian =8

Tested on:
* Ubuntu 12.04
* Ubuntu 14.04
* Ubuntu 15.04
* Debian 8.1

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
All the attributes should be inside a hash named "rvm_passenger_nginx". At the end is an example of the configuration used for an application that includes all the possible values even the non-required ones and an example with the minimal required attributes.

### Default Attributes
This attributes are not needed but could be helpful in case of some extra configuration might be needed.

```json
"nginx": {
	"user": "www-data",
	"workers": 4,
	"connections": 768,
	"log_dir": "/var/log/nginx"
},
"passenger": {
	"user": "webserver",
	"group": "deploy",
	"site": {
		"min_instances": 2,
		"max_body_size": "8M"
	}
},
"default_git_user": "git",
"secret_file": "/root/my_secret_file"
```

#### node["rvm_passenger_nginx"]["nginx"]["user"]
This value defines user credentials used by an nginx worker processes. This attribute has a default value of **"www-data"**

#### node["rvm_passenger_nginx"]["nginx"]["workers"]
Defines the number of worker processes used by nginx. The default value is **4**.

#### node["rvm_passenger_nginx"]["nginx"]["connections"]
Sets the maximum number of simultaneous connections that can be opened by an nginx worker process. The default value is **768**

#### node["rvm_passenger_nginx"]["nginx"]["log_dir"]
This attribute specifies the directory where nginx logs and each of our application logs are going to be stored. The default value is **"/var/log/nginx"**

#### node["rvm_passenger_nginx"]["passenger"]["user"]
Defines the user that is going to be used as the deployer, its very important that the user exists before this cookbook's execution. The default value is **"webserver"**

#### node["rvm_passenger_nginx"]["passenger"]["group"]
Defines the group of the user that is going to be used as the deployer, it should match your deployer's group to avoid any issues. The default value is **"deploy"**

#### node["rvm_passenger_nginx"]["passenger"]["site"]["min_instances"]
This specifies the minimum number of application processes that should exist for a given application. The default value is **2**

#### node["rvm_passenger_nginx"]["passenger"]["site"]["max_body"size"]
Sets the maximum allowed size of the client request body, specified in the “Content-Length” request header field. Setting size to 0 disables checking of client request body size. The default value is **"8M"**

#### node["rvm_passenger_nginx"]["default_git_user"]
This attribute is the default user that is used for the connection with the git server repositories in case it is not specified on the node["rvm_passenger_nginx"]["certificates"] list. The default value is **"git"**

#### node["rvm_passenger_nginx"]["secret_file"]
This attribute defines the full path to the secret file that is going to be used to decrypt the certificates on the data bag. Default is **"/root/chef_secret"**

### Application Attributes
Each application's attributes should be configured inside an Array place on node["rvm_passenger_nginx"]["applications"]. Here is the list of all the attributes that might be used.

```json
"applications": [
	{
		"name": "blog",
		"repo": "https://github.com/github_user/blog.git",
		"branch": "master",
		"ruby": "2.2.3",
		"rails": "4.2.4",
		"server": "example.com",
		"environment": "production",
		"secret_key_base": "4950c380f2b....."
	}
]
```

#### name
Defines the name of the application that is going to be setup as well as the directory where the code is going to be stored. This is a required attribute.

#### repo
This attribute is the address of the repository where the code is stored. An example of this would be "https://github.com/user/repo.git" or in case of a private git server it can also be a "git@example.com:repo.git". This is a required attribute.

#### branch
This string is the branch that is going to be deployed for your application. The default value is **"master"**

#### ruby
Defines the ruby version that is going to be used for this application. The version could be something like "2.2.2" or "1.9.3-p0". This is a required attribute.

#### rails
This value specifies the version of rails that this particulas application needs for example "4.2.4". This is a required attribute.

#### server
Server names are defined using this attribute and determine which server block is used for a given request. Example values would be "example.com", "sub.example.com", "*.example.com" or "sub1.example.com sub2.example.com". This is a required attribute.

#### environment
Defines the environment that is going to be used for the application which exists on your rails app, tipical values you could use are "development" or "production". The default value is **"production"**

#### secret_key_base
This is the secret_key_base that is going to be installed for this application for use on the config/settings.yml file of the rails app. It is a required value when node["rvm_passenger_nginx"]["applications"]["environment"] has been set to "production".

### Certificate Attributes
The node["rvm_passenger_nginx"]["certificates"] attribute should contain an array of the certificates that are going to be used to into a source code repository to download the files.

```json
"certificates": [
	{
		"name": "github_cert",
		"host": "github.com",
		"user": "git"
	}
]
```

#### name
Defines the name of the certificate id on the encrypted data bag. This is a required attribute.

#### host
This is the host where the certificate is going to be used. This is a required attribute.

#### user
This defines the remote user that owns that certificate. This is not a required attribute but its in there in case you have different users for two applications under one host. The default value is **"git"**

### Example with all attributes
```json
"rvm_passenger_nginx": {
	"nginx": {
		"user": "www-data",
		"workers": 4,
		"connections": 768,
		"log_dir": "/var/log/nginx"
	},
	"passenger": {
		"user": "webserver",
		"group": "deploy",
		"site": {
			"min_instances": 2,
			"max_body_size": "8M"
		}
	},
	"default_git_user": "git",
	"secret_file": "/root/my_secret_file",
	"applications": [
		{
			"name": "blog",
			"repo": "https://github.com/github_user/blog.git",
			"branch": "master",
			"ruby": "2.2.3",
			"rails": "4.2.4",
			"server": "example.com",
			"environment": "production",
			"secret_key_base": "4950c380f2b....."
		}
	],
	"certificates": [
		{
			"name": "github_cert",
			"host": "github.com",
			"user": "git"
		}
	]
}
```

### Example with minimal required attributes
```json
"rvm_passenger_nginx": {
	"applications": [
		{
			"name": "blog",
			"repo": "https://github.com/github_user/blog.git",
			"ruby": "2.2.3",
			"rails": "4.2.4",
			"server": "example.com",
			"secret_key_base": "4950c380f2b....."
		}
	],
	"certificates": [
		{
			"name": "github_cert",
			"host": "github.com",
		}
	]
}
```

License  & Authors
------------
- Author:: Victor D Nava (<admin@vikonava.com>)

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
