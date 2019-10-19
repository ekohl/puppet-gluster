# @summary enable the upstream Gluster Apt repo
# @api private
#
# @param version The version to use when building the repo URL
# @param release The release to use when building the repo URL
# @param priority Apt pin priority to set for the Gluster repo
#
# @note Currently only released versions are supported.
#
# @example Enable the LATEST Apt repo for release 4.1
#   class { gluster::repo::apt:
#     version => 'LATEST',
#     release => '4.1',
#   }
#
# @example Enable the version 4.1.10 Apt repo for release 4.1
#   class { gluster::repo::apt:
#     version => '4.1.10',
#     release => '4.1',
#   }
#
# @author Drew Gibson <dgibson@rlsolutions.com>
# @note Copyright 2015 RL Solutions, unless otherwise noted
#
class gluster::repo::apt (
  String $version = $gluster::params::version,
  String $release = $gluster::params::release,
  $priority = $gluster::params::repo_priority,
) inherits gluster::params {
  if $facts['os']['name'] != 'Debian' {
    fail('gluster::repo::apt currently only works on Debian')
  }

  # the Gluster repo only supports x86_64 (amd64) and arm64.
  unless $facts['architecture'] in ['amd64', 'arm64'] {
    fail("Architecture ${facts['architecture']} not yet supported for ${facts['os']['name']}.")
  }

  $repo_key_name = $release ? {
    '4.1'   => 'EED3351AFD72E5437C050F0388F6CDEE78FA6D97',
    default => 'F9C958A3AEE0D2184FAD1CBD43607F0DC2F8238C',
  }

  $repo_key_source = "https://download.gluster.org/pub/gluster/glusterfs/${release}/rsa.pub"
  $repo_url = "https://download.gluster.org/pub/gluster/glusterfs/${release}/${version}/Debian/${facts['lsbdistcodename']}/${facts['architecture']}/apt/"

  apt::source { "glusterfs-${release}-${version}":
    ensure       => present,
    location     => $repo_url,
    repos        => 'main',
    key          => {
      id         => $repo_key_name,
      key_source => $repo_key_source,
    },
    pin          => $priority,
    architecture => $facts['architecture'],
  }

  Apt::Source["glusterfs-${release}-${version}"] -> Package<| tag == 'gluster-packages' |>

}
