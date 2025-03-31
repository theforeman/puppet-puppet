#!/usr/bin/env bash

set -e

#####
# Install openvox-agent as a task
#

# Error if non-root
if [ $(id -u) -ne 0 ]; then
  echo "puppet::install_agent task must be run as root"
  exit 1
fi

#####
# Helper: logging
#

# Timestamp
now () {
    date +'%H:%M:%S %z'
}

# Logging functions instead of echo
log () {
    echo "$(now) ${1}"
}

info () {
  if [[ $PT__noop != true ]]; then
    log "INFO: ${1}"
  fi
}

warn () {
    log "WARN: ${1}"
}

critical () {
    log "CRIT: ${1}"
}

#####
# Helper: commands
#

# Check whether a command exists - returns 0 if it does, 1 if it does not
exists() {
  if command -v $1 >/dev/null 2>&1
  then
    return 0
  else
    return 1
  fi
}

# Run command and retry on failure
# run_cmd CMD
if [ -n "$PT_retry" ]; then
  retry=$PT_retry
else
  retry=5
fi

run_cmd() {
  eval $1
  rc=$?

  if test $rc -ne 0; then
    attempt_number=0
    while test $attempt_number -lt $retry; do
      info "Retrying... [$((attempt_number + 1))/$retry]"
      eval $1
      rc=$?

      if test $rc -eq 0; then
        break
      fi

      info "Return code: $rc"
      sleep 1s
      ((attempt_number=attempt_number+1))
    done
  fi

  return $rc
}

#####
# Helper: check for further download helpers
#

# Check whether apt-helper is available
exists_apt_helper() {
  test -x /usr/lib/apt/apt-helper
}

# Check whether python3 and urllib.request are available
exists_python3_urllib() {
  python3 -c 'import urllib.request' >/dev/null 2>&1
}

# Check whether perl and LWP::Simple module are installed
exists_perl_lwp() {
  if perl -e 'use LWP::Simple;' >/dev/null 2>&1 ; then
    return 0
  fi
  return 1
}

# Check whether perl and File::Fetch module are installed
exists_perl_ff() {
  if perl -e 'use File::Fetch;' >/dev/null 2>&1 ; then
    return 0
  fi
  return 1
}

#####
# Create tmp_dir, stderr
#

random_hexdump () {
  hexdump -n 2 -e '/2 "%u"' /dev/urandom
}

if [ -z "$TMPDIR" ]; then
  tmp="/tmp"
else
  tmp=${TMPDIR}
  # TMPDIR has trailing file sep for macOS test box
  penultimate=$((${#tmp}-1))
  if test "${tmp:$penultimate:1}" = "/"; then
    tmp="${tmp:0:$penultimate}"
  fi
fi

# Random function since not all shells have $RANDOM
if exists hexdump; then
  random_number=$(random_hexdump)
else
  random_number="$(date +%N)"
fi

tmp_dir="$tmp/install.sh.$$.$random_number"
(umask 077 && mkdir $tmp_dir) || exit 1

tmp_stderr="$tmp/stderr.$$.$random_number"

capture_tmp_stderr() {
  # spool up tmp_stderr from all the commands we called
  if [ -f "$tmp_stderr" ]; then
    output=$(cat ${tmp_stderr})
    stderr_results="${stderr_results}\nSTDERR from $1:\n\n$output\n"
  fi
}

trap "rm -f $tmp_stderr; rm -rf $tmp_dir; exit $1" 1 2 15

# Cleanup
cleanup() {
  if [ -n "$tmp_dir" ]; then
    rm -rf "$tmp_dir"
  fi
  exit $1
}

#####
# Helper: download
#

unable_to_retrieve_package() {
  critical "Unable to retrieve a valid package!"
  cleanup 1
}

# do_wget URL FILENAME
do_wget() {
  info "Trying wget..."
  run_cmd "wget -O '$2' '$1' 2>$tmp_stderr"
  rc=$?

  # check for 404
  grep "ERROR 404" $tmp_stderr 2>&1 >/dev/null
  if test $? -eq 0; then
    critical "ERROR 404"
    unable_to_retrieve_package
  fi

  # check for bad return status or empty output
  if test $rc -ne 0 || test ! -s "$2"; then
    capture_tmp_stderr "wget"
    return 1
  fi

  return 0
}

# do_curl URL FILENAME
do_curl() {
  info "Trying curl..."
  run_cmd "curl -1 -sL -D $tmp_stderr '$1' > '$2'"
  rc=$?

  # check for 404
  grep "404 Not Found" $tmp_stderr 2>&1 >/dev/null
  if test $? -eq 0; then
    critical "ERROR 404"
    unable_to_retrieve_package
  fi

  # check for bad return status or empty output
  if test $rc -ne 0 || test ! -s "$2"; then
    capture_tmp_stderr "curl"
    return 1
  fi

  return 0
}

# do_fetch URL FILENAME
do_fetch() {
  info "Trying fetch..."
  run_cmd "fetch -o '$2' '$1' 2>$tmp_stderr"
  rc=$?

  # check for 404
  grep "404 Not Found" $tmp_stderr 2>&1 >/dev/null
  if test $? -eq 0; then
    critical "ERROR 404"
    unable_to_retrieve_package
  fi

  # check for bad return status or empty output
  if test $rc -ne 0 || test ! -s "$2"; then
    capture_tmp_stderr "fetch"
    return 1
  fi

  return 0
}

do_apt_helper() {
  info "Trying apt-helper..."
  run_cmd "/usr/lib/apt/apt-helper download-file '$1' '$2'" 2>$tmp_stderr
  rc=$?

  # check for 404
  grep "E: Failed to fetch .* 404 " $tmp_stderr 2>&1 >/dev/null
  if test $? -eq 0; then
    critical "ERROR 404"
    unable_to_retrieve_package
  fi

  # check for bad return status or empty output
  if test $rc -ne 0 && test ! -s "$2" ; then
    capture_tmp_stderr "apthelper"
    return 1
  fi

  return 0
}

do_python3_urllib() {
  info "Trying python3 (urllib.request)..."
  run_cmd "python3 -c 'import urllib.request ; urllib.request.urlretrieve(\"$1\", \"$2\")'" 2>$tmp_stderr
  rc=$?

  # check for 404
  if grep "404: Not Found" $tmp_stderr 2>&1 >/dev/null ; then
    critical "ERROR 404"
    unable_to_retrieve_package
  fi

  if test $rc -eq 0 && test -s "$2" ; then
    return 0
  fi

  capture_tmp_stderr "perl"
  return 1
}

# do_perl_lwp URL FILENAME
do_perl_lwp() {
  info "Trying perl (LWP::Simple)..."
  run_cmd "perl -e 'use LWP::Simple; getprint(\$ARGV[0]);' '$1' > '$2' 2>$tmp_stderr"
  rc=$?

  # check for 404
  grep "404 Not Found" $tmp_stderr 2>&1 >/dev/null
  if test $? -eq 0; then
    critical "ERROR 404"
    unable_to_retrieve_package
  fi

  if test $rc -eq 0 && test -s "$2" ; then
    return 0
  fi

  capture_tmp_stderr "perl"
  return 1
}

# do_perl_ff URL FILENAME
do_perl_ff() {
  info "Trying perl (File::Fetch)..."
  run_cmd "perl -e 'use File::Fetch; use File::Copy; my \$ff = File::Fetch->new(uri => \$ARGV[0]); my \$outfile = \$ff->fetch() or die \$ff->server; copy(\$outfile, \$ARGV[1]) or die \"copy failed: \$!\"; unlink(\$outfile) or die \"delete failed: \$!\";' '$1' '$2' 2>>$tmp_stderr"
  rc=$?

  # check for 404
  grep "HTTP response: 404" $tmp_stderr 2>&1 >/dev/null
  if test $? -eq 0 ; then
    critical "ERROR 404"
    unable_to_retrieve_package
  fi

  if test $rc -eq 0 && test -s "$2" ; then
    return 0
  fi

  capture_tmp_stderr "perl"
  return 1
}

# do_download URL FILENAME
do_download() {
  info "Downloading $1"
  info "  to file $2"

  # we try all of these until we get success.
  # perl, in particular may be present but LWP::Simple may not be installed

  if exists wget; then
    do_wget $1 $2 && return 0
  fi

  if exists curl; then
    do_curl $1 $2 && return 0
  fi

  if exists fetch; then
    do_fetch $1 $2 && return 0
  fi

  if exists_perl_lwp; then
    do_perl_lwp $1 $2 && return 0
  fi

  if exists_perl_ff; then
    do_perl_ff $1 $2 && return 0
  fi

  if exists_python3_urllib; then
    do_python3_urllib $1 $2 && return 0
  fi

  if exists_apt_helper; then
    do_apt_helper $1 $2 && return 0
  fi

  critical "Cannot download package as none of wget/curl/fetch/perl-LWP-Simple/perl-File-Fetch/python3/apt-helper is found"
  unable_to_retrieve_package
}

#####
# Source options
#

if [ -n "$PT_yum_source" ]; then
  yum_source=$PT_yum_source
else
  if [ "$nightly" = true ]; then
    yum_source='http://nightlies.voxpupuli.org/yum'
  else
    yum_source='http://yum.voxpupuli.org'
  fi
fi

if [ -n "$PT_apt_source" ]; then
  apt_source=$PT_apt_source
else
  if [ "$nightly" = true ]; then
    apt_source='http://nightlies.voxpupuli.org/apt'
  else
    apt_source='http://apt.voxpupuli.org'
  fi
fi

if [ -n "$PT_mac_source" ]; then
  mac_source=$PT_mac_source
else
  if [ "$nightly" = true ]; then
    mac_source='http://nightlies.voxpupuli.org/downloads'
  else
    mac_source='http://downloads.voxpupuli.org'
  fi
fi

#####
# Get OS and platform facts
#

# Retrieve Platform and Platform Version for Collection (Repository) file
# Utilize facts implementation when available
if [ -f "$PT__installdir/facts/tasks/bash.sh" ]; then
  # Use facts module bash.sh implementation
  os=$(bash $PT__installdir/facts/tasks/bash.sh "platform")
  os_version=$(bash $PT__installdir/facts/tasks/bash.sh "release")

  case $os in
    "RedHat"|"Almalinux"|"Rocky"|"OracleLinux"|"CentOS")
      info "${os} platform! Lets get you a RPM..."
      pkg_type=rpm
      platform=el
      ;;
    "Fedora")
      info "Fedora platform! Lets get you a RPM..."
      pkg_type=rpm
      platform=fedora
      ;;
    "Darwin")
      info "MacOS platform! Lets get you a DMG..."
      os_version=$(sw_vers | awk '/^ProductVersion:/ { print $2 }')
      pkg_type=dmg
      platform=osx
      ;;
    "SLES"|"Opensuse-leap")
      info "SUSE platform! Lets get you a RPM..."
      pkg_type="rpm"
      platform=sles
      ;;
    "Debian"|"Ubuntu")
      info "${os} platform! Lets get you a DEB..."
      pkg_type=deb
      platform=$(echo $os | tr '[:upper:]' '[:lower:]')
      ;;
    "Linuxmint"|"LinuxMint")
      info "Mint platform! Lets get you a DEB..."
      pkg_type=deb
      case $os_version in
        "4")  platform="debian"; platform_version="10";;
        "5")  platform="debian"; platform_version="11";;
        "6")  platform="debian"; platform_version="12";;
        "19") platform="ubuntu"; platform_version="18.04";;
        "20") platform="ubuntu"; platform_version="20.04";;
        "21") platform="ubuntu"; platform_version="22.04";;
      esac
      ;;
    *)
      critical "Unable to determine platform version!"
      cleanup 1
      ;;
  esac

  # Major OS Release
  platform_version=$(echo $os_version | cut -d. -f1)
else
  echo "This module depends on the puppetlabs-facts module"
  cleanup 1
fi

#####
# Get installed OpenVox or Puppet (incl. version)
#

# Find which version of openvox or puppet is currently installed if any
if [ -f /opt/puppetlabs/puppet/VERSION ]; then
  installed_version=$(cat /opt/puppetlabs/puppet/VERSION)
elif type -p puppet >/dev/null; then
  installed_version=$(puppet --version)
else
  installed_version=uninstalled
fi

# Search for an installed Puppet package
puppet_installed=no

case $pkg_type in
  "rpm")
    if $(rpm -q puppet-agent >/dev/null 2>&1); then
      puppet_installed=yes
    fi
    ;;
  "deb")
    if [ -n "$(dpkg-query --show puppet-agent |cut -f2)" ]; then
      puppet_installed=yes
    fi
    ;;
esac

#####
# Choose Collection
#

# Determine the Collection
if [ -n "$PT_collection" ]; then
  # Check whether collection is nightly
  if [[ "$PT_collection" == *"nightly"* ]]; then
    nightly=true
  else
    nightly=false
  fi

  collection=$PT_collection
else
  collection='openvox8'
fi

# Rewriting the collection to previous version version, if puppet was detected
if  [ "$puppet_installed" == "yes" ]; then
  info "Detect puppet agent. Will be replaced with the openvox agent."

  if [ -z "$PT_collection" ]; then
    major=$(echo $installed_version | cut -d. -f1)
    collection="openvox${major}"
  fi
fi

#####
# Choose Version
#

# Get command line arguments
# Only install openvox agent if it is not installed yet, selected version is higher or a puppet agent was detected.
# If a puppet agent was detected, it will be replaced by openvox from the same major release (if no version is given, assume latest).
if [ -n "$PT_version" ]; then
  version="$PT_version"
  info "Version parameter defined: ${version}"

  if [ "$version" == "$installed_version" && "$puppet_installed" == "no" ] ; then
    info "Version parameter defined: ${version}. OpenVox Agent ${version} detected. Nothing to do."
    cleanup 0
  elif [ "$version" != "latest" ]; then
    puppet_agent_version="$version"
  fi
else
  if [ "$installed_version" == "uninstalled" ]; then
    info "Version parameter not defined and no agent detected. Assuming latest in collection ${collection}."
    version=latest
  else
    if [ "$puppet_installed" == "no" ]; then
      info "Version parameter not defined and agent detected. Nothing to do."
      cleanup 0
    else
      info "Version parameter not defined. Assuming latest in collection ${collection}."
      version=latest
    fi
  fi
fi

#####
# Determine URL for downloading the collection repo file
#

case $pkg_type in
  "rpm")
    filename="${collection}-release-${platform}-${platform_version}.noarch.rpm"
    download_url="${yum_source}/${filename}"
    ;;
  "deb")
    filename="${collection}-release-${platform}${platform_version}.deb"
    download_url="${apt_source}/${filename}"
    ;;
  "dmg")
    filename="openvox-agent-${version}-1.${platform}${platform_version}.dmg"
    download_url="${mac_source}/mac/${collection}/${platform_version}/arm64/${filename}"
    ;;
  *)
    critical "Download for ${pkg_type} is not implemented, yet."
    cleanup 1
esac

if [ -n "$PT_absolute_source" ]; then
  download_url=$PT_absolute_source
fi

#####
# Installation
#

# setup TYPE FILENAME
# TYPE is "rpm", "deb" or "dmg"
setup() {
  if [ "$installed_version" != "uninstalled" ]; then
    info "Version ${installed_version} detected..."

    major=$(echo $installed_version | cut -d. -f1)
    pkg_puppet="puppet-release puppet${major}-release"
    pkg_openvox="openvox${major}-release"

    if echo $2 | grep $pkg_openvox >/dev/null && [ "$puppet_installed" == "no" ]; then
      info "No collection upgrade detected"
    elif [ "$puppet_installed" == "yes" ]; then
      pkg_remove="$pkg_puppet"
    else
      pkg_remove="$pkg_openvox"
    fi
  fi

  case "$1" in
    "rpm")
      for pkg in $pkg_remove; do
        if $(rpm -q openvox-agent >/dev/null 2>&1); then
          info "Collection upgrade detected, replacing $pkg."
          rpm -e $pkg
        fi
      done

      run_cmd "rpm -Uvh --oldpackage --replacepkgs ${2}"

      case $platform in
        "el")
          exists dnf && PKGCMD=dnf || PKGCMD=yum
          if [ "$version" == "latest" ]; then
            run_cmd "${PKGCMD} install -y openvox-agent && ${PKGCMD} upgrade -y openvox-agent"
          else
            run_cmd "${PKGCMD} install -y 'openvox-agent-${puppet_agent_version}'"
          fi
          ;;
        "sles")
          for key in "openvox.pub"; do
            gpg_key="${tmp_dir}/GPG-KEY-${key}"
            do_download "https://yum.voxpupuli.org/GPG-KEY-${key}" "$gpg_key"
            rpm --import "$gpg_key"
          done

          run_cmd "zypper install --no-confirm '${2}'"
          if [ "$version" == "latest" ]; then
            run_cmd "zypper install --no-confirm 'openvox-agent'"
          else
            run_cmd "zypper install --no-confirm --oldpackage --no-recommends --no-confirm 'openvox-agent-${puppet_agent_version}'"
          fi
          ;;
         *)
          critical "RPM platform ${platform} is not implemented, yet."
          cleanup 1
          ;;
      esac
      ;;
    "deb")
      for pkg in $pkg_remove; do
        if [ -f "/etc/apt/sources.list.d/${pkg}.list" ]; then
          info "Collection upgrade detected, replacing $pkg."
          dpkg --purge $pkg || rm -f "/etc/apt/sources.list.d/${pkg}.list"         
        fi
      done

      #assert_unmodified_apt_config

      run_cmd "dpkg -i --force-confmiss ${2}"
      run_cmd "apt-get update -y >/dev/null 2>&1"

      frontend="DEBIAN_FRONTEND=noninteractive"

      if [ "$version" == "latest" ]; then
        run_cmd "${frontend} apt-get install -y --allow-downgrades openvox-agent"
      else
        if [ -n "$platform" ]; then
          run_cmd "${frontend} apt-get install -y --allow-downgrades 'openvox-agent=${puppet_agent_version}-1+${platform}${platform_version}'"
        else
          run_cmd "${frontend} apt-get install -y --allow-downgrades 'openvox-agent=${puppet_agent_version}'"
        fi
      fi
      ;;
    "dmg")
      mountpoint="$(mktemp -d -t $(random_hexdump))"
      /usr/bin/hdiutil attach "${2?}" -nobrowse -readonly -mountpoint "${mountpoint?}"
      /usr/sbin/installer -pkg ${mountpoint?}/openvox-agent-*-installer.pkg -target /
      /usr/bin/hdiutil detach "${mountpoint?}"
      rm -f $download_filename
      ;;
  esac
}

#####
# Main program
#

if [[ $PT__noop != true ]]; then
  download_filename="${tmp_dir}/${filename}"

  do_download "$download_url" "$download_filename"
  setup $pkg_type "$download_filename"

  if [[ $PT_stop_service = true ]]; then
    /opt/puppetlabs/bin/puppet resource service puppet ensure=stopped enable=false
  fi
fi

cleanup 0
