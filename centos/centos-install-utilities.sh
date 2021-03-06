#!/bin/bash

TIGERVNC_LINK="https://dl.bintray.com/tigervnc/stable/"

# @param $1 - String where command output will be sent
# @param $2 - Number indicating the bit type to download, either 32 or 64
# @return String containing the download link for the nux repo
function get_nox_download_link() {
  output=$1

  if [[ $2 -eq 32 ]] ; then
    bit_type="i386"
  else
    bit_type="x86_64"
  fi

  echo "http://li.nux.ro/download/nux/dextop/el6/${bit_type}/nux-dextop-release-0-2.el6.nux.noarch.rpm"
}

# Parses the dyn.su packages page to find the raven-release repo rpm and returns the link
# @param $1 - String determining where the output will be sent
# @return String containing the download link for the raven repo
function get_raven_repo_download_link() {
  output=$1
  raven_link="https://pkgs.dyn.su/el8/base/x86_64/"

  safe_download ${output} "raven.txt" ${raven_link}
  sed -i '/raven-release/!d' raven.txt
  raven_link=${raven_link}$(cat raven.txt | sed -e "s/.*href=\"\(.*\)\"\ title.*/\1/")

  rm -f raven.txt
  echo ${raven_link}
}

# Parses the fedora download site to determine the latest version
# @param $1 - String where command output will be sent
# @param $2 - The base fedora download site to parse from
# @return Number indicating the latest fedora release
function get_fedora_version() {
  output=$1
  fedora_base=$2

  safe_download ${output} "package-temp.txt" ${fedora_base}
  sed -i '/\[DIR\]/!d' package-temp.txt
  sed -i "s/.*href=\"\(.*\)\/\">.*/\1/" package-temp.txt
  echo $(cat package-temp.txt | sed '/.*[0-9].*/!d' | sort -n | awk -F: '$1<=1000000' | tail -1 && rm -f package-temp.txt)
}

# Gets the lxtask rpm download link from the fedora packages host
# @param $1 - String where command output will be sent
# @param $2 - Number indicating the bit type to download, either 32 or 64
# @param $3 - Package name to get link for
# @return The download link of the lxtask rpm from the fedora site
function get_fedora_download_link() {
  output=$1
  package_name=$3
  package_letter=$(echo $package_name | head -c 1)
  if [ $2 == 32 ] ; then
    fedora_base="https://dl.fedoraproject.org/pub/fedora-secondary/releases/"
    bit_type="i386"
  else
    fedora_base="https://dl.fedoraproject.org/pub/fedora/linux/releases/"
    bit_type="x86_64"
  fi

  packages_page=${fedora_base}
  packages_page+=$(get_fedora_version ${output} ${fedora_base})
  packages_page+="/Everything/${bit_type}/os/Packages/${package_letter}/"
  safe_download ${output} "package-temp.txt" ${packages_page}
  sed -i '/'"${package_name}"'/!d' package-temp.txt
  sed -i '/doc/d' package-temp.txt
  sed -i "s/.*href=\"\(.*\)\">.*/\1/" package-temp.txt
  echo ${packages_page}$(cat package-temp.txt && rm -f package-temp.txt)
}

# Installs lxtask by downloading from the Fedora repo
# @param $1 - Boolean flag indicating verbostiy of the procedure
# @param $2 - Number indicating the bit type to download, either 32 or 64
# @return None
function install_lxtask() {
  output=$(determine_output $1)
  bit_type=$2

  download_link=$(get_fedora_download_link ${output} ${bit_type} lxtask)
  safe_download ${output} "lxtask.rpm" ${download_link}
  yum -y localinstall lxtask.rpm
  rm -f lxtask.rpm
}

# Installs leafpad by downloading from the Fedora repo
# @param $1 - Boolean flag indicating verbostiy of the procedure
# @param $2 - Number indicating the bit type to download, either 32 or 64
# @return None
function install_leafpad() {
  output=$(determine_output $1)
  bit_type=$2

  download_link=$(get_fedora_download_link ${output} ${bit_type} leafpad)
  safe_download ${output} "leafpad.rpm" ${download_link}
  yum -y localinstall leafpad.rpm
  rm -f leafpad.rpm
}

# Installs fbpanel by downloading from the Fedora repo
# @param $1 - Boolean flag indicating verbostiy of the procedure
# @param $2 - Number indicating the bit type to download, either 32 or 64
# @param $3 - Number indicating the centos version, either 6 or 7
# @return None
function install_fbpanel() {
  output=$(determine_output $1)
  bit_type=$2
  centos_version=$3
  
  if [[ ${centos_version} -ge 7 ]] ; then
    if [[ ${bit_type} -eq 64 ]] ; then
      download_link="https://download-ib01.fedoraproject.org/pub/epel/6/x86_64/Packages/f/fbpanel-6.1-4.el6.x86_64.rpm"
    else
      download_link="https://download-ib01.fedoraproject.org/pub/epel/6/i386/Packages/f/fbpanel-6.1-4.el6.i686.rpm"
    fi
    safe_download ${output} "fbpanel.rpm" ${download_link}
    yum -y install fbpanel.rpm
    rm -f fbpanell.rpm
  else
    yum -y install fbpanel
  fi
}

# Installs all files in a directory, and then removes the directory
# @param $1 - String where command output will be sent
# @param $2 - Path where the files to install lie
# @return None
function install_all() {
  output=$1
  path=$2

  for filename in ${path}; do
    yum -y --nogpgcheck install ${filename} &> $output
  done
  rm -f ${path}
}

# Runs an initial package update, then installs all base required packages
# @param $1 - boolean flag to indicate whether or not to run the function in verbose mode
# @param $2 - Number indicating the bit type of the system, either 32 or 64
# @param $3 - Number indicating the CentOS version, either 6 or 7
# @return - None
function initial_setup() {
  output=$(determine_output $1)
  bit_type=$2
  centos_version=$3

  yum -y update &> $output
  if [[ ${centos_version} -eq 8 ]] ; then
    yum -y install $(get_raven_repo_download_link $output) &> ${output}
  fi

  yum -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-${3}.noarch.rpm &> $output
  yum -y install $(get_nox_download_link $output $bit_type) &> $output
  yum -y update &> $output
  yum -y history sync &> $output
  yum -y install perl sudo xorg-x11-xinit wget bzip2 xterm xorg-x11-drivers xorg-x11-xinit xorg-x11-xauth &> $output
  yum -y groupinstall fonts
  yum -y install firefox openbox pcmanfm unzip &> ${output}
  yum -y install gtk2-engines gnome-icon-theme.noarch &> ${output}
}

# Sets the SSH port, blocks root login and allows the new user
# @param $1 - boolean flag to indicate whether or not to run the function in verbose mode
# @param $2 - Name of user to allow to access SSH
# @param $3 - Port number to permit SSH on
# @return - None
function setup_ssh() {
  output=$(determine_output $1)
  name=$2
  port=$3

  sed -i "s/#Port 22/Port $port/g" /etc/ssh/sshd_config
  sed -ie 's/\(.*\)PermitRootLogin yes/PermitRootLogin no/g' /etc/ssh/sshd_config
  echo -e "\nAllowUsers $name root" >> /etc/ssh/sshd_config

  add_tcp_firewall_rule ${output} "centos" ${port} "ssh_port_t"
  service sshd restart &> $output
}

# Creates new user account using provided username and password. Gives user sudo permissions
# @param $1 - boolean flag to indicate whether or not to run the function in verbose mode
# @param $2 - Name of the user to create (in all lowercase)
# @param $3 - Password of the user to create
# @return - None
function create_user() {
  output=$(determine_output $1)
  name=$2
  password=$3

  adduser $name &> $output
  echo "$name:$password" | chpasswd
  usermod -aG wheel $name &> $output
  sed -i "s/# %wheel/%wheel/g" /etc/sudoers
}

source shared-utilities.sh
