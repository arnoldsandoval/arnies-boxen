require boxen::environment
require homebrew
require gcc

Exec {
  group       => 'staff',
  logoutput   => on_failure,
  user        => $boxen_user,

  path => [
    "${boxen::config::home}/rbenv/shims",
    "${boxen::config::home}/rbenv/bin",
    "${boxen::config::home}/rbenv/plugins/ruby-build/bin",
    "${boxen::config::homebrewdir}/bin",
    '/usr/bin',
    '/bin',
    '/usr/sbin',
    '/sbin'
  ],

  environment => [
    "HOMEBREW_CACHE=${homebrew::config::cachedir}",
    "HOME=/Users/${::boxen_user}"
  ]
}

File {
  group => 'staff',
  owner => $boxen_user
}

Package {
  provider => homebrew,
  require  => Class['homebrew']
}

Repository {
  provider => git,
  extra    => [
    '--recurse-submodules'
  ],
  require  => File["${boxen::config::bindir}/boxen-git-credential"],
  config   => {
    'credential.helper' => "${boxen::config::bindir}/boxen-git-credential"
  }
}

Service {
  provider => ghlaunchd
}

Homebrew::Formula <| |> -> Package <| |>

node default {
  # core modules, needed for most things
  include dnsmasq
  include git
  include hub
  include nginx

  # fail if FDE is not enabled
  if $::root_encrypted == 'no' {
    fail('Please enable full disk encryption and try again')
  }

  # Node JS
  class { 'nodejs::global':
    version => '0.12'
  }

  # default ruby versions
  ruby::version { '1.9.3': }
  ruby::version { '2.0.0': }
  ruby::version { '2.1.7': }
  ruby::version { '2.2.3': }

  # common, useful packages
  package {
    [
      'ack',
      'findutils',
      'gnu-tar'
    ]:
  }

  file { "${boxen::config::srcdir}/our-boxen":
    ensure => link,
    target => $boxen::config::repodir
  }
}

# ohmyzsh
include ohmyzsh

# Sketch
include sketch

# Adobe Creative Cloud
include adobe_creative_cloud

# Mongo
include mongodb

# Python

# Install Python versions
python::version { '2.7.10': }
python::version { '3.5.0': }

# Set the global version of Python
class { 'python::global':
  version => '3.5.0'
}

# ensure a certain python version is used in a dir
# python::local { '/path/to/some/project':
#   version => '3.4.1'
# }

# Install the latest version of virtualenv
$version = '3.4.1'
python::package { "virtualenv for ${version}":
  package => 'virtualenv',
  python  => $version,
}

# Install Django 1.6.x
python::package { "django for 2.7.7":
  package => 'django',
  python  => '2.7.7',
  version => '>=1.6,<1.7',
}

# Installing a pyenv plugin
python::plugin { 'pyenv-virtualenvwrapper':
  ensure => 'v20140122',
  source => 'yyuu/pyenv-virtualenvwrapper',
}

# Running a package script
# pyenv-installed gems cannot be run in the boxen installation environment which uses the system
# python. The environment must be cleared (env -i) so an installed python (and packages) can be used in a new shell.
# exec { "env -i bash -c 'source /opt/boxen/env.sh && PYENV_VERSION=${version} virtualenv venv'":
#   provider => 'shell',
#   cwd => "~/Sites/jeopardpy",
#   require => Python::Package["virtualenv for ${version}"],
# }


# Install Atom
include atom

# install the linter package
atom::package { 'linter': }

# install the linter package
atom::package { 'set-syntax': }

atom::package { 'auto-detect-indentation': }
atom::package { 'atom-beautify': }
atom::package { 'emmet': }

# install the monokai theme
atom::theme { 'monokai': }

# Install Chrome
include chrome
include chrome::canary

# Install Caffeine
include caffeine

# Install Virtualbox
# include virtualbox

# Install Vagrant
class { 'vagrant': }

# Enable tap-to-click
include osx::global::tap_to_click

# Show mounter volumes on desktop
include osx::finder::show_mounted_servers_on_desktop

# Enable Safari Developer Mode
include osx::safari::enable_developer_mode

# Make the bottom right corner show the desktop
class { 'osx::dock::hot_corners':
  top_right => "Put Display to Sleep",
  top_left => "Put Display to Sleep"
}

# Plex
include plex
