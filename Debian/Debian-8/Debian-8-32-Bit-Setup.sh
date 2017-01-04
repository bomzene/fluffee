read -p "What would you like your user account to be named? Must be lowercase " name
read -p "What port would you like to use to ssh to your server? " sshport
read -p "What port would you like to use to vnc to your server? " vncport
read -p "What would you like your ssh password to be? " sshpassword
read -p "What would you like your vnc password to be? " vncpassword
apt-get update
apt-get -y upgrade
apt-get -y install sudo wget nano locales debconf-utils
wget --no-check-cert 'https://raw.githubusercontent.com/iFluffee/Fluffees-Server-Setup/master/Debian/Debian-8/Keyboard_settings.conf'
debconf-set-selections < Keyboard_settings.conf
apt-get install -y keyboard-configuration
dpkg-reconfigure keyboard-configuration -f noninteractive
sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
echo 'LANG="en_US.UTF-8"'>/etc/default/locale
echo "export LC_ALL=en_US.UTF-8" >> /root/.bashrc
echo "export LANG=en_US.UTF-8" >> /root/.bashrc
echo "export LANGUAGE=en_US.UTF-8" >> /root/.bashrc
source ~/.bashrc
dpkg-reconfigure --frontend=noninteractive locales
update-locale LANG=en_US.UTF-8
sed -i "s/Port 22/Port $sshport/g" /etc/ssh/sshd_config
echo "AllowUsers $name root" >> /etc/ssh/sshd_config
sed -i "s/PermitRootLogin yes/PermitRootLogin no/g" /etc/ssh/sshd_config
chmod 600 /etc/ssh/sshd_config
service ssh restart
apt-get -y install xorg lxde
sudo adduser $name --gecos "First Last,RoomNumber,WorkPhone,HomePhone" --disabled-password
echo "$name:$sshpassword" | sudo chpasswd
sudo gpasswd -a $name sudo
sudo gpasswd -a $name netdev
sudo apt-get install -y xorg-dev libjpeg62-turbo-dev zlib1g-dev build-essential xutils-dev
wget http://www.tightvnc.com/download/1.3.10/tightvnc-1.3.10_unixsrc.tar.gz
tar xzf tightvnc-1.3.10_unixsrc.tar.gz
cd vnc_unixsrc
xmkmf
make World
cd Xvnc
./configure
make
cd ..
./vncinstall /usr/local/bin /usr/local/man
sed -i -r '/unix\/:7100";/a $fontPath = join ',',qw(' /usr/local/bin/vncserver
sed -i "s/join ,,qw/join ',,qw/g" /usr/local/bin/vncserver
sed -i "s/join ',,qw/join ',',qw/g" /usr/local/bin/vncserver
sed -i /',qw(/a /usr/share/fonts/X11/misc' /usr/local/bin/vncserver
sed -i '/\/X11\/misc/a /usr/share/fonts/X11/100dp2i/:unscaled' /usr/local/bin/vncserver
sed -i '/\/usr\/share\/fonts\/X11\/100dp2i\/\:unscaled/a /usr/share/fonts/X11/75dp2i/:unscaled' /usr/local/bin/vncserver
sed -i '/\/usr\/share\/fonts\/X11\/75dp2i\/\:unscaled/a /usr/share/fonts/X11/Type1' /usr/local/bin/vncserver
sed -i '/\/usr\/share\/fonts\/X11\/Type1/a /usr/share/fonts/X11/100dpi' /usr/local/bin/vncserver
sed -i '/\/usr\/share\/fonts\/X11\/100dpi/a /usr/share/fonts/X11/75dpi' /usr/local/bin/vncserver
sed -i '/\/usr\/share\/fonts\/X11\/75dpi/a );' /usr/local/bin/vncserver
sed -i "s/75dp2i/75dpi/g" /usr/local/bin/vncserver
sed -i "s/100dp2i/100dpi/g" /usr/local/bin/vncserver
mkdir /home/$name/.vnc
echo $vncpassword >/home/$name/.vnc/file
vncpasswd -f </home/$name/.vnc/file >/home/$name/.vnc/passwd
chown $name /home/$name/.vnc
chown $name /home/$name/.vnc/passwd
chgrp $name /home/$name/.vnc
chgrp $name /home/$name/.vnc/passwd
chmod 600 /home/$name/.vnc/passwd
su  - $name -c "vncserver"
su  - $name -c "vncserver -kill :1"
sed -i "s/twm/startlxde/g" /home/$name/.vnc/xstartup
su  - $name -c "vncserver"
su  - $name -c "vncserver -kill :1"
cd /usr/local/bin/
wget --no-check-cert 'https://dl.dropboxusercontent.com/u/81527571/Debian%208%20(32%20Bit)/myvncserver'
sudo chown $name myvncserver
sudo chmod +x /usr/local/bin/myvncserver
cd /lib/systemd/system/
wget --no-check-cert 'https://dl.dropboxusercontent.com/u/81527571/Debian%208%20(32%20Bit)/myvncserver.service'
sed -i "s/User=vnc/User=$name/g" /lib/systemd/system/myvncserver.service
sudo systemctl daemon-reload
sudo systemctl enable myvncserver.service
sudo update-rc.d tightvncserver defaults
sudo apt-get -y install curl lxtask
sudo mkdir /home/$name/Desktop/
sudo mkdir /home/$name/Desktop/Bots/
cd /home/$name/Desktop/
sudo chown $name Bots
curl -k -o /home/$name/Desktop/Bots/OSBot.jar https://osbot.org/mvc/get
wget -O /home/$name/Desktop/Bots/TRiBot_Loader.jar https://tribot.org/bin/TRiBot_Loader.jar
wget -O /home/$name/Desktop/Bots/TopBot.jar http://topbot.org/resources/topbot.jar
wget -O /home/$name/Desktop/Bots/EpicBot.jar http://loft1.epicbot.com/epicbot.jar
wget -O /home/$name/Desktop/Bots/OSBuddy.jar http://cdn.rsbuddy.com/live/f/loader/OSBuddy.jar?x=10
cd /home/$name/Desktop
sudo chown $name Bots
sudo chmod 777 Bots
echo "deb http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main" | tee /etc/apt/sources.list.d/webupd8team-java.list
echo "deb-src http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main" | tee -a /etc/apt/sources.list.d/webupd8team-java.list
apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys EEA14886
apt-get update
echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | sudo /usr/bin/debconf-set-selections
apt-get -y install oracle-java8-installer
sudo apt-get -y install oracle-java8-set-default
chmod 777 /usr/lib/jvm/java-8-oracle/jre/lib/security/java.policy
cd /usr/local
wget -O firefox.tar.bz2 "https://download.mozilla.org/?product=firefox-latest&os=linux&lang=en-US"
tar xvjf firefox.tar.bz2
ln -s /usr/local/firefox/firefox /usr/bin/firefox
update-alternatives --install /usr/bin/x-www-browser x-www-browser /usr/local/firefox/firefox 100
apt-get remove -y xscreensaver
mkdir /home/$name/.local/
mkdir /home/$name/.local/share/
mkdir /home/$name/.local/share/applications/
echo "[Added Associations]" >> /home/$name/.local/share/applications/mimeapps.list
echo "application/zip=JB-java-jdk8.desktop;" >> /home/$name/.local/share/applications/mimeapps.list
echo "" >> /home/$name/.local/share/applications/mimeapps.list
echo "[Default Applications]" >> /home/$name/.local/share/applications/mimeapps.list
echo "application/zip=JB-java-jdk8.desktop" >> /home/$name/.local/share/applications/mimeapps.list
chmod 644 /home/$name/.local/share/applications/mimeapps.list
sed -i "s/NoDisplay=true/NoDisplay=false/g" /usr/share/applications/JB-java-jdk8.desktop
sed -i "s/$vncPort = 5900/$vncPort = $vncport - 1/g" /usr/local/bin/vncserver
sed -i "s/sockaddr_in(5900/sockaddr_in($vncport - 1/g" /usr/local/bin/vncserver
sudo systemctl start myvncserver.service
