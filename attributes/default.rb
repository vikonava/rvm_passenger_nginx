default['rvm']['default_ruby'] = 'system'

default['firewall']['allow_ssh'] = true

default['rvm_passenger_nginx'] = {
	'nginx' => {
		'user' => 'www-data',
		'workers' => 4,
		'connections' => 768,
		'log_dir' => '/var/log/nginx'
	},
	'passenger' => {
		'user' => 'webserver',
		'group' => 'deploy',
		'site' => {
			'min_instances' => 2,
			'max_body_size' => "8M"
		}
	},
	'default_git_user' => 'git',
	'applications' => [],
	'certificates' => [],
	'secret_file' => '/root/chef_secret'
}
