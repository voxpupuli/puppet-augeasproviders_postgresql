[![Build Status](https://github.com/voxpupuli/puppet-augeasproviders_postgresql/workflows/CI/badge.svg)](https://github.com/voxpupuli/puppet-augeasproviders_postgresql/actions?query=workflow%3ACI)
[![Release](https://github.com/voxpupuli/puppet-augeasproviders_postgresql/actions/workflows/release.yml/badge.svg)](https://github.com/voxpupuli/puppet-augeasproviders_postgresql/actions/workflows/release.yml)
[![Puppet Forge](https://img.shields.io/puppetforge/v/puppet/augeasproviders_postgresql.svg)](https://forge.puppetlabs.com/puppet/augeasproviders_postgresql)
[![Puppet Forge - downloads](https://img.shields.io/puppetforge/dt/puppet/augeasproviders_postgresql.svg)](https://forge.puppetlabs.com/puppet/augeasproviders_postgresql)
[![Puppet Forge - endorsement](https://img.shields.io/puppetforge/e/puppet/augeasproviders_postgresql.svg)](https://forge.puppetlabs.com/puppet/augeasproviders_postgresql)
[![Puppet Forge - scores](https://img.shields.io/puppetforge/f/puppet/augeasproviders_postgresql.svg)](https://forge.puppetlabs.com/puppet/augeasproviders_postgresql)
[![puppetmodule.info docs](http://www.puppetmodule.info/images/badge.png)](http://www.puppetmodule.info/m/puppet-augeasproviders_postgresql)
[![Coverage Status](https://img.shields.io/coveralls/voxpupuli/puppet-augeasproviders_postgresql.svg)](https://coveralls.io/r/voxpupuli/puppet-augeasproviders_postgresql)
[![Apache-2 License](https://img.shields.io/github/license/voxpupuli/puppet-augeasproviders_postgresql.svg)](LICENSE)
[![Donated by Camptocamp](https://img.shields.io/badge/donated%20by-camptocamp-fb7047.svg)](#transfer-notice)

# postgresql: types/providers for postgresql files for Puppet

This module provides a new type/provider for Puppet to read and modify postgresql
config files using the Augeas configuration library.

The advantage of using Augeas over the default Puppet `parsedfile`
implementations is that Augeas will go to great lengths to preserve file
formatting and comments, while also failing safely when needed.

This provider will hide *all* of the Augeas commands etc., you don't need to
know anything about Augeas to make use of it.

## Requirements

Ensure both Augeas and ruby-augeas 0.3.0+ bindings are installed and working as
normal.

See [Puppet/Augeas pre-requisites](http://docs.puppetlabs.com/guides/augeas.html#pre-requisites).

## Installing

On Puppet 2.7.14+, the module can be installed easily ([documentation](http://docs.puppetlabs.com/puppet/latest/reference/modules_installing.html)):

```
puppet module install puppet/augeasproviders_postgresql
```

You may see an error similar to this on Puppet 2.x ([#13858](http://projects.puppetlabs.com/issues/13858)):

    Error 400 on SERVER: Puppet::Parser::AST::Resource failed with error ArgumentError: Invalid resource type `pg_hba` at ...

Ensure the module is present in your puppetmaster's own environment (it doesn't
have to use it) and that the master has pluginsync enabled.  Run the agent on
the puppetmaster to cause the custom types to be synced to its local libdir
(`puppet master --configprint libdir`) and then restart the puppetmaster so it
loads them.

## Compatibility

### Puppet versions

Minimum of Puppet 2.7.

### Augeas versions

Augeas Versions           | 0.10.0  | 1.0.0   | 1.1.0   | 1.2.0   |
:-------------------------|:-------:|:-------:|:-------:|:-------:|
**PROVIDERS**             |
pg_hba                    | **yes** | **yes** | **yes** | **yes** |

## Documentation and examples

Type documentation can be generated with `puppet doc -r type` or viewed on the
[Puppet Forge page](http://forge.puppetlabs.com/puppet/augeasproviders_postgresql).

### pg_hba provider

#### Composite namevars

This type supports composite namevars in order to easily specify the entry you want to manage. The format for composite namevars is:

    local to <user> on <database> [in <target>]

if defining a local (socket) rule, or:

    <type> to <user> on <database> from <address> [in <target>]

otherwise.

In each form, `in <target>` is optional. You can also use a personalized namevar and specify all parameters manually.


#### manage simple local entry

    pg_hba { 'local to all on all':
      ensure => present,
      method => 'md5',
      target => '/etc/postgresql/9.1/main/pg_hba.conf',
    }

#### manage simple host entry

    pg_hba { 'host to all on all from 192.168.0.1':
      ensure => present,
      method => 'md5',
      target => '/etc/postgresql/9.1/main/pg_hba.conf',
    }

#### multiple users and databases

    pg_hba { 'host to user1,user2 on db1,db2 from 192.168.0.1':
      ensure => present,
      method => 'md5',
      target => '/etc/postgresql/9.1/main/pg_hba.conf',
    }

    pg_hba { 'Allow +foo and @bar to mydb and yourdb':
      ensure   => present,
      user     => ['+foo', '@bar'],
      database => ['mydb', 'yourdb'],
      method   => 'md5',
      target   => '/etc/postgresql/9.1/main/pg_hba.conf',
    }

#### using a personalized namevar

    pg_hba { 'Default entry':
      type     => 'local',
      user     => 'all',
      database => 'all',
      method   => 'md5',
      target   => '/etc/postgresql/9.1/main/pg_hba.conf',
    }

#### pass options for the method

    pg_hba { 'Default entry with option':
      method  => 'ident',
      options => { 'sameuser' => undef },
      target  => '/etc/postgresql/9.1/main/pg_hba.conf',
    }

    pg_hba { 'host to all on all from .dev.example.com in /etc/postgresql/9.1/main/pg_hba.conf':
      method  => 'ldap',
      options => {
        'ldapserver' => 'auth.example.com',
        'ldaptls'    => '1',
        'ldapprefix' => 'uid=',
        'ldapsuffix' => ',ou=people,dc=example,dc=com',
      },
    }

#### insert entry in specific position

    pg_hba { 'local to all on all':
      ensure   => present,
      method   => 'md5',
      position => 'before first entry',
      target   => '/etc/postgresql/9.1/main/pg_hba.conf',
    }

    pg_hba { 'local to all on all':
      ensure   => present,
      method   => 'md5',
      position => 'after last entry',
      target   => '/etc/postgresql/9.1/main/pg_hba.conf',
    }

    pg_hba { 'local to all on all':
      ensure   => present,
      method   => 'md5',
      position => 'before last local',
      target   => '/etc/postgresql/9.1/main/pg_hba.conf',
    }

    pg_hba { 'local to all on all':
      ensure   => present,
      method   => 'md5',
      position => 'after first hostssl',
      target   => '/etc/postgresql/9.1/main/pg_hba.conf',
    }

    pg_hba { 'local to all on all':
      ensure   => present,
      method   => 'md5',
      position => 'after first anyhost', # any type matching host.*
      target   => '/etc/postgresql/9.1/main/pg_hba.conf',
    }

    pg_hba { 'local to all on all':
      ensure   => present,
      method   => 'md5',
      position => 'before 5', # Before the fifth entry
      target   => '/etc/postgresql/9.1/main/pg_hba.conf',
    }

    pg_hba { 'local to all on all':
      ensure   => present,
      method   => 'md5',
      position => '*[database="all" and user="admin"][1]', # First entry for database 'all' and user 'admin'
      target   => '/etc/postgresql/9.1/main/pg_hba.conf',
    }

#### ensure position is correct

    pg_hba { 'local to all on all':
      ensure   => positioned,
      method   => 'md5',
      position => 'before first entry',
      target   => '/etc/postgresql/9.1/main/pg_hba.conf',
    }

#### delete entry

    pg_hba { 'local to all on all':
      ensure => absent,
      target => '/etc/postgresql/9.1/main/pg_hba.conf',
    }

    pg_hba { 'host to all on all from 192.168.0.1':
      ensure    => absent,
      target => '/etc/postgresql/9.1/main/pg_hba.conf',
    }


## Issues

Please file any issues or suggestions [on GitHub](https://github.com/voxpupuli/puppet-augeasproviders_postgresql/issues).

## Transfer Notice

This module was originally authored by [hercules-team](http://augeasproviders.com).
The maintainer preferred that Vox Pupuli take ownership of the module for future improvement and maintenance.
Existing pull requests and issues were transferred over, please fork and continue to contribute here.

Previously: https://github.com/hercules-team/augeasproviders_postgresql
