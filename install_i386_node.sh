#!/bin/bash
apt-get -y update
apt-get -y upgrade
apt-get -y install build-essential zlib1g-dev libxml2-dev libssl-dev ruby1.8-dev irb1.8 rdoc1.8 libreadline-ruby1.8 sharutils flex bison rubygems git-core

cd /
mkdir pipeline
cd pipeline
mkdir bin
mkdir dbs
cd bin
mkdir tandem

cd /usr/local/src
wget http://www.tildeslash.com/monit/dist/beta/monit-5.0_beta3.tar.gz
tar xvfz monit-5.0_beta3.tar.gz
cd monit-5.0_beta3
./configure
make
make install
cd /etc/

uudecode -o monitrc << EOF
begin-base64 700 monitrc
c2V0IGRhZW1vbiAzMCAjIFBvbGwgYXQgMzAgc2Vjb25kIGludGVydmFscwpz
ZXQgbG9nZmlsZSBzeXNsb2cKCmluY2x1ZGUgL2V0Yy9tb25pdC9ub2RlLm1v
bml0cmMK
====
EOF

chmod 700 monitrc
mkdir monit
cd monit
ln -s /pipeline/bin/config/node.monitrc

cd /usr/local/src
wget ftp://ftp.ncbi.nih.gov/blast/executables/LATEST/blast-2.2.18-ia32-linux.tar.gz
tar xvfz blast-2.2.18-ia32-linux.tar.gz
cd blast-2.2.18
cp bin/formatdb /usr/local/bin/

cd /usr/local/src
wget ftp://ftp.thegpm.org/projects/tandem/source/tandem-linux-08-02-01-3.tar.gz
tar xvfz tandem-linux-08-02-01-3.tar.gz 
ln -s /usr/lib/libexpat.so.1 /usr/lib/libexpat.so.0
cd tandem-linux-08-02-01-3/src
cp Makefile_ubuntu Makefile

uudecode -o patchfile << EOF
begin-base64 644 patch
LS0tIE1ha2VmaWxlX3VidW50dQkyMDA4LTA1LTIyIDE1OjM5OjEyLjAwMDAw
MDAwMCArMDAwMAorKysgTWFrZWZpbGUJMjAwOC0wOS0xMiAxMzoyNjozMy4w
MDAwMDAwMDAgKzAwMDAKQEAgLTE1LDcgKzE1LDcgQEAKICNDWFhGTEFHUyA9
IC1PMiAtREdDQzQgLURQTFVHR0FCTEVfU0NPUklORyAtRFhfUDMNCiAKICN1
YnVudHUgNjQgYml0IHZlcnNpb24NCi1MREZMQUdTID0gIC1scHRocmVhZCAt
TC91c3IvbGliNjQgL3Vzci9saWI2NC9saWJleHBhdC5zby4wDQorTERGTEFH
UyA9ICAtbHB0aHJlYWQgLUwvdXNyL2xpYiAvdXNyL2xpYi9saWJleHBhdC5z
by4wDQogDQogU1JDUyA6PSAkKHdpbGRjYXJkICouY3BwKQ0KIE9CSlMgOj0g
JChwYXRzdWJzdCAlLmNwcCwlLm8sJCh3aWxkY2FyZCAqLmNwcCkpDQo=
====
EOF

patch -p0 < patchfile
make
cp ../bin/* /pipeline/bin/tandem
cd /pipeline/bin/tandem
rm input.xml
rm taxonomy.xml
ln -s /pipeline/bin/config/taxonomy.xml
rm *.css
rm *.xsl
rm p3.exe
rm fasta_pro.exe
rm test_spectra.mgf


cd /usr/local/src
wget ftp://ftp.ncbi.nih.gov/pub/lewisg/omssa/CURRENT/omssa-linux.tar.gz
tar xvfz omssa-linux.tar.gz
mv omssa-2.1.1.linux/ /pipeline/bin/
ln -s /pipeline/bin/omssa-2.1.1.linux /pipeline/bin/omssa
cd /pipeline/bin/omssa
rm MSHHWGYGK.dta
rm omssamerge


gem update --system
gem update --system

mv /usr/bin/gem /usr/bin/gem.OLD
ln -s /usr/bin/gem1.8 /usr/bin/gem
  
gem install right_aws libxml-ruby rubyzip --no-rdoc --no-ri

cd /pipeline/
git clone git://github.com/jgeiger/pipeline-node_worker.git
cp -r pipeline-node_worker/* bin

cd /etc
uudecode -o patchfile << EOF
begin-base64 644 patch.txt
LS0tIHJjLmxvY2FsLmRlZmF1bHQJMjAwOC0wOS0xOSAyMDo1NzoyOS4wMDAw
MDAwMDAgKzAwMDAKKysrIHJjLmxvY2FsCTIwMDgtMDktMTkgMjE6MjE6NTAu
MDAwMDAwMDAwICswMDAwCkBAIC0xMSw0ICsxMSw5IEBACiAjCiAjIEJ5IGRl
ZmF1bHQgdGhpcyBzY3JpcHQgZG9lcyBub3RoaW5nLgogCitjZCAvcGlwZWxp
bmUvYmluCisvcGlwZWxpbmUvYmluL2J1aWxkX21vbml0cmMucmIKK3NsZWVw
IDIKKy91c3IvbG9jYWwvYmluL21vbml0CisKIGV4aXQgMAo=
====
EOF

patch -p0 < patchfile

cd /etc/init.d
ln -s /pipeline/bin/config/init-d-node node

cd /pipeline/bin
/pipeline/bin/database_install.rb

