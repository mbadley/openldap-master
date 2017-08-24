class openldap-master {
	package {'openldap-servers':
		ensure => installed,
	} ->
	package {'openldap-clients':
		ensure => installed,
	} ->
	file {'/etc/openldap/slapd.d':
		ensure => absent,
		force => yes,
		notify => service['slapd'],
	} ->
	file {"/etc/openldap/":
		source => "puppet:///modules/openldap-master/",
		recurse => true,
		ensure => present,
		notify => service['slapd'],
	} ->
	file_line {'Enable SSL':
		path => '/etc/sysconfig/ldap',
		line => 'SLAPD_LDAPS=yes',
		match => 'SLAPD_LDAPS=no',
		notify => service['slapd'],
	} ->
	service {'slapd':
		ensure => running,
		enable => true,
	}
 	openldap::server::access {
 		'to * by dn="cn=admin,dc=XXXX" on dc=XXXX':
 		ensure => present,
 		access => 'write';
 		
		'to * by dn="cn=mbadley,ou=users,dc=XXXX" on dc=XXXX':
 		access => 'write';
 		'to * by dn="cn=admins,ou=groups,dc=XXXX"':
 		access => 'write';
 		
 	} 
 	openldap::server::access {
 		'to * by group/groupOfUniqueNames/uniqueMember.exact="cn=admins,ou=groups,dc=XXXX"':
 
 		'to * by dn="cn=mbadley,ou=users,dc=XXXX"':
 		ensure => present,
 		suffix => 'dc=XXXX',
 		access => 'manage';
 		control => 'write';
 	} 
 	file {'/etc/openldap':
 		ensure => "directory",
 		owner  => "root",
 		group  => "root",
 		mode   => "755",
 	}
 	file {'/etc/openldap/schema':
 		ensure => "directory",
 		owner  => "root",
 		group  => "root",
 		mode   => "755",
 	}
 	file {"/etc/openldap/schema/puppet":
 		source => "puppet:///modules/openldap-master/schema/",
 		recurse => true,
 		ensure => present,
 	} ->
 	openldap::server::schema { 'inetorgperson':
 		ensure  => present,
 		path    => '/etc/openldap/schema/puppet/inetorgperson.schema',
 	} ->
 	openldap::server::schema { 'ppolicy':
 		ensure  => present,
 		path    => '/etc/openldap/schema/puppet/ppolicy.schema',
 	} ->
 	openldap::server::schema { 'sudo':
 		ensure  => present,
 		path    => '/etc/openldap/schema/puppet/sudo.schema',
 	} ->
 	openldap::server::schema { 'pwm':
 		ensure  => present,
 		path    => '/etc/openldap/schema/puppet/pwm.schema',
 	} ->
 	openldap::server::schema { 'sshpublickey':
 		ensure  => present,
 		path    => '/etc/openldap/schema/puppet/sshpublickey.ldif',
 	} ->
 	openldap::server::schema { 'ldapns':
 		ensure  => present,
 		path    => '/etc/openldap/schema/puppet/ldapns.schema',
 	} ->
 	openldap::server::schema { 'accounts':
 		ensure  => present,
 		path    => '/etc/openldap/schema/puppet/accounts.ldif',
 	} ->
 	openldap::server::module { 'memberof':
 		ensure => present,
 	} ->
 
 	openldap::server::module { 'refint':
 		ensure => present,
 	} ->
 
 	openldap::server::overlay { 'memberof on dc=XXXX':
 		suffix => 'dc=XXXX',
 		ensure => present,
 	} ->
 	openldap::server::overlay { 'refint on dc=XXXX':
 		ensure => present,
 	} 
 
 	
 	openldap::server::database { 'dc=XXXX':
 		ensure => present,
 		rootdn => 'cn=admin,dc=XXXX',
 		rootpw => 'admin',
 	}
 	file {"/etc/openldap/certs/server.pem":
 		source => "puppet:///modules/openldap-master/certs/server.pem",
 		owner => "ldap",
 		group => "ldap",
 		mode => 400,
 		ensure => present,
 	} ->
 	class {"openldap::server":
 		ldaps_ifs => ['/'],
 		ldap_ifs  => ['/'],
 		ssl_cert => "/etc/openldap/certs/server.pem",
 		ssl_key  => "/etc/openldap/certs/server.pem",
 	} 
}

