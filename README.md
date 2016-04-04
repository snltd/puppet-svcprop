# smf-svcprop

This module started out as a fork of
[https://forge.puppetlabs.com/ppbrown/svcprop](Philip Brown's
`svcprop` module).

The original code could not deal with, among other things, multiple
`:net_address` properties, and Philip declined my PR which fixed the
problem.

So, I've rewritten everything. There may be a line or two which has
escaped, and the filenames are probably the same but it's pretty
much a complete rewrite. Smaller, cleaner, better documented, and
more functional. Thanks to Philip for the original starting point.

## Usage

### Installation

Copy/clone/link/whatever this directory somewhere in your module
path. I use a masterless Puppet setup, and haven't tested it with a
Puppet master.

### Types

The name of the resource is not important. It doesn't really make
sense to have any of the following fields as the named parameter.
Just make it something meaningful.

* **`fmri`**: an FMRI which uniquely identifies the service whose
  properties you wish to manage. Follows the same pattern as the
  `svc*` commands, so you can provide something as longs as
  'svc:/application/database/mysql:version_56' or as short as
  `mysql`, depending on your SMF schema. Bear in mind that some
  properties belong to the service, and some belong to the instance
  of the service. (This is a bit of SMF complexity which catches a
  lot of people out, me included.)
* **`property`**: the name of the property you want to set.
* **`type`**: the datatype of the property. Defaults to `astring`.
  Sometimes, for instance when setting DNS servers, you will have to
  change this.
* **`value`**: the value(s) you wish to enforce. Can be a string or an
  array. When existing and requested array values are compared by
  Puppet they are NOT sorted, so changing the order but keeping the
  elements identical WILL trigger a change. I previously wrote it so
  just shuffling the array wouldn't cause a change, but decided that
  was the wrong thing to do.

### Example

Setting the MySQL data directory. This is a property of the
`version_56` instance of the `database/mysql` service. We want the
service to restart if there is a change.

```puppet
svcprop { 'mysql_data_dir':
  fmri     => 'svc:/application/database/mysql:version_56',
  property => 'mysql/data',
  type     => 'astring',
  value    => '/data/mysql',
  notify   => Service['mysql'],
}
```

This example configures DNS on Solaris 11 using data from Hiera. The
module will take care of correctly quoting and bracketing everything
if there are more than one `dns_servers`.

```puppet
svcprop { 'dns-nameservers':
  fmri     => 'dns/client',
  property => 'config/nameserver',
  type     => 'net_address',
  value    => $basenode::dns_servers,
}

svcprop { 'dns-search':
  fmri     => 'dns/client',
  property => 'config/search',
  value    => $basenode::dns_domain,
}

svcprop { 'dns-domain':
  fmri     => 'dns/client',
  property => 'config/domain',
  value    => $basenode::dns_domain,
}
```

## Bugs and Stuff

There's no `metadata.json`, `Modulefile` or whatever. I'm [not much
of a believer in the
Forge](http://sysdef.xyz/post/2015-11-16-do-it-yourself).

If you use this and you find you have problems, please raise an
issue on Github, or better still, fix it and send me a PR.

## License

This software is issued under a BSD license.
