# == Class: jmeter
#
# This class installs the latest stable version of JMeter.
#
# === Examples
#
#   class { 'jmeter': }
#
class jmeter (
  $jmeter_version         = '2.13',
  $jmeter_plugins_install = false,
  $jmeter_plugins_version = '1.2.1',
  $jmeter_plugins_set     = ['Standard'],
  $java_version           = $::jmeter::params::java_version,
) inherits ::jmeter::params {

  Exec { path => '/bin:/usr/bin:/usr/sbin' }

  $jdk_pkg = $::jmeter::params::jdk_pkg

  ensure_resource('package', [$jdk_pkg, 'unzip', 'wget'], {'ensure' => 'present'})

  exec { 'download-jmeter':
    command => "wget -P /root http://archive.apache.org/dist/jmeter/binaries/apache-jmeter-${jmeter_version}.tgz",
    creates => "/root/apache-jmeter-${jmeter_version}.tgz"
  }

  exec { 'install-jmeter':
    command => "tar xzf /root/apache-jmeter-${jmeter_version}.tgz && mv apache-jmeter-${jmeter_version} jmeter",
    cwd     => '/usr/share',
    creates => '/usr/share/jmeter',
    require => Exec['download-jmeter'],
  }

  if $jmeter_plugins_install == true {
    jmeter::plugins_install { $jmeter_plugins_set:
      plugins_version => $jmeter_plugins_version,
      require         => [Package['wget'], Package['unzip'], Exec['install-jmeter']],
    }
  }
}
