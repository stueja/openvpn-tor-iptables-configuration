Startup a new (Arch) Linux host

Contents

<span id="anchor"></span><span id="anchor-1"></span><span id="anchor"></span>General
====================================================================================

<span id="anchor-2"></span><span id="anchor-3"></span><span id="anchor-2"></span>Change root password
-----------------------------------------------------------------------------------------------------

passwd root

<span id="anchor-4"></span><span id="anchor-5"></span><span id="anchor-4"></span>Update the system
--------------------------------------------------------------------------------------------------

pacman -Syu

if you want to install everything right away from here, use

```
pacman -Syu at knockd openvpn easy-rsa tor privoxy obfsproxy git

sync

systemctl reboot
```

<span id="anchor-6"></span><span id="anchor-7"></span><span id="anchor-6"></span>iptables (v4)
==============================================================================================

<span id="anchor-8"></span><span id="anchor-9"></span><span id="anchor-8"></span>Install at 
--------------------------------------------------------------------------------------------

```
pacman -S at

systemctl start atd

systemctl enable atd
```

<span id="anchor-10"></span><span id="anchor-11"></span><span id="anchor-10"></span>Set up nano
-----------------------------------------------------------------------------------------------

`nano ~/.nanorc`
```

set nowrap

set rebindkeypad
```

<span id="anchor-12"></span><span id="anchor-13"></span><span id="anchor-12"></span>Set up iptable revoke script
----------------------------------------------------------------------------------------------------------------

Put the following into a script, e. g. `/root/iptables-revoke.sh`

Make the script executable, `chmod u+x /root/iptables-revoke.sh`
```
#!/bin/bash

iptables -F

iptables -X

iptables -t nat -F

iptables -t nat -X

iptables -t mangle -F

iptables -t mangle -X

iptables -t raw -F

iptables -t raw -X

iptables -P INPUT ACCEPT

iptables -P FORWARD ACCEPT

iptables -P OUTPUT ACCEPT
```

`chmod +x iptables-revoke.sh`

<span id="anchor-14"></span><span id="anchor-15"></span><span id="anchor-14"></span>Test the revoke script
----------------------------------------------------------------------------------------------------------

```
iptables -S

iptables -P FORWARD DROP

iptables -S

./iptables-revoke.sh

iptables -S
```

<span id="anchor-16"></span><span id="anchor-17"></span><span id="anchor-16"></span>Set up (basic) iptables (v4)
----------------------------------------------------------------------------------------------------------------

Put the following into a script, e. g. `/root/iptables-install.sh`.

Make the script executable, `chmod u+x /root/iptables-install.sh`
```
#!/bin/bash

# set policies to accept

iptables -P INPUT ACCEPT

iptables -P FORWARD ACCEPT

iptables -P OUTPUT ACCEPT

# clean iptables

iptables -F

iptables -t nat -F

iptables -X

iptables -t nat -X

# allow localhost

iptables -A INPUT -i lo -j ACCEPT

iptables -A INPUT ! -i lo -s 127.0.0.0/8 -j REJECT

iptables -A OUTPUT -o lo -j ACCEPT

# allow SSH

iptables -A INPUT -i eth0 -p tcp -m state --state NEW,ESTABLISHED --dport 1022 -j ACCEPT

iptables -A OUTPUT -o eth0 -p tcp -m state --state NEW,ESTABLISHED --sport 1022 -j ACCEPT

# if you are now connected via port 22

iptables -A INPUT -i eth0 -p tcp -m state --state NEW,ESTABLISHED --dport 22 -j ACCEPT

iptables -A OUTPUT -o eth0 -p tcp -m state --state NEW,ESTABLISHED --sport 22 -j ACCEPT

# block everything else

iptables -P INPUT DROP

iptables -P FORWARD DROP

iptables -P OUTPUT DROP

chmod +x iptables-install.sh
```

<span id="anchor-18"></span><span id="anchor-19"></span><span id="anchor-18"></span>Test at
-------------------------------------------------------------------------------------------
```
iptables -S

iptables -P FORWARD DROP

iptables -S

at now +1 min

/root/iptables-revoke.sh
```
*&lt;ctrl-d&gt;*

wait 1 minute

`iptables -S`

<span id="anchor-20"></span><span id="anchor-21"></span><span id="anchor-20"></span>Set up iptables and let at have your ass
----------------------------------------------------------------------------------------------------------------------------
```
at now +3 min

/root/iptables-revoke.sh
```
*&lt;ctrl-d&gt;*
```
/root/iptables-install.sh
```
If SSH still reacts, you have a first green light. From a second terminal, try to login to the same server via SSH. If it works, you have a second green lights. Upon two green lights:

`atq`

note the job number

`atrm <job number>`

If it the shell does not react and you cannot login from a second terminal, wait for 3 minutes. atd will run the iptables-revoke script, and you should be able to login again.

<span id="anchor-22"></span><span id="anchor-23"></span><span id="anchor-22"></span>Start and enable iptables (v4) service
--------------------------------------------------------------------------------------------------------------------------
```
iptables-save > /etc/iptables/iptables.rules

systemctl start iptables.service

systemctl enable.iptables.service
```
<span id="anchor-24"></span><span id="anchor-25"></span><span id="anchor-24"></span>Disable ipv6
================================================================================================

Attention. I was using IPv4 while connecting to my server. If you use IPv6, then watch out to turn around the procedures and swap the iptables with the ip6tables. In other words, if you are using or want to use IPv6, create basic iptables for IPv6, test and start the ip6tables.service, and after that disable IPv4.

<span id="anchor-26"></span><span id="anchor-27"></span><span id="anchor-26"></span>iptables (v6)
-------------------------------------------------------------------------------------------------

ip***6***tables -P INPUT DROP

ip***6***tables -P FORWARD DROP

ip***6***tables -P OUTPUT DROP

ip***6***tables-save &gt; /etc/iptables/ip***6***tables.rules

systemctl start ip***6***tables.service

systemctl enable ip***6***tables.service

<span id="anchor-28"></span><span id="anchor-29"></span><span id="anchor-28"></span>/etc/hosts
----------------------------------------------------------------------------------------------

nano /etc/hosts

comment out ::1 line

\# ::1 localhost…

<span id="anchor-30"></span><span id="anchor-31"></span><span id="anchor-30"></span>disable IPv6 in kernel
----------------------------------------------------------------------------------------------------------

nano /etc/sysctl.d/40-ipv6.conf

net.ipv6.conf.all.disable\_ipv6=1

net.ipv6.conf.default.disable\_ipv6=1

net.ipv6.conf.lo.disable\_ipv6=1

net.ipv6.conf.eth0.disable\_ipv6=1

then

sysctl --system

<span id="anchor-32"></span><span id="anchor-33"></span><span id="anchor-32"></span>Add users
=============================================================================================

useradd -d /home/user1 -m -s /bin/bash user1

passwd user1

useradd -d /home/l0g1nb4ck00p -m -s /bin/bash l0g1nb4ck00p

passwd l0g1nb4ck00p

useradd --system --shell /usr/sbin/nologin --no-create-home openvpn\_server

useradd --system --shell /usr/sbin/nologin --no-create-home obfsproxy

<span id="anchor-34"></span><span id="anchor-35"></span><span id="anchor-34"></span>Configure SSH
=================================================================================================

<span id="anchor-36"></span><span id="anchor-37"></span><span id="anchor-36"></span>Generate host keys
------------------------------------------------------------------------------------------------------

ssh-keygen -t rsa -b 8192 -a 23 -C “root@myhostname” -f /etc/ssh/ssh\_host\_rsa\_key -N ‘’

ssh-keygen -t ed25519 -b 521 -a 64 -C “root@myhostname” -f /etc/ssh/ssh\_host\_ed25519\_key -N ‘’

<span id="anchor-38"></span><span id="anchor-39"></span><span id="anchor-38"></span>Set up nano
-----------------------------------------------------------------------------------------------

su user1

cd ~

nano ~/.nanorc

set nowrap

set rebindkeypad

<span id="anchor-40"></span><span id="anchor-41"></span><span id="anchor-40"></span>Generate client keys
--------------------------------------------------------------------------------------------------------

su user1

cd ~

mkdir .ssh

ssh-keygen -t rsa -b 4096 -C “ts-user1-myhostname” -f ~/.ssh/ts-myhostname\_rsa

ssh-keygen -t rsa -b 4096 -C “putty-user1-myhostname” -f ~/.ssh/putty-myhostname\_rsa

ssh-keygen -t ed25519 -b 521 -C “cygwin-user1-myhostname” -f ~/.ssh/cygwin-myhostname\_ed25519

ssh-keygen -t ed25519 -b 521 -C “thor-user1-myhostname” -f ~/.ssh/thor-myhostname\_ed25519

cat ~/.ssh/ts-myhostname\_rsa.pub &gt;&gt; ~/.ssh/authorized\_keys

cat ~/.ssh/putty-myhostname\_rsa &gt;&gt; ~/.ssh/authorized\_keys

cat ~/.ssh/cygwin-myhostname\_ed25519 &gt;&gt; ~/.ssh/authorized\_keys

cat ~/.ssh/thor-myhostname\_ed25519 &gt;&gt; ~/.ssh/authorized\_keys

Copy, or better move (=copy and delete the original) private keys (e. g. ts-myhostname\_rsa without .pub extension) from the server to the clients in a secure manner (e. g. via scp, sftp, or simply copy the contents of the file via the clipboard). Even better, create the keys on the client and only copy the public key into the server user’s authorized\_keys file. After that exit from the su user1 session:

exit

*Alternatively* to su-ing into the user1 account, you could

ssh-keygen -t rsa -b 4096 -C “ts-user1-myhostname” -f ~/.ssh/user1/ts-myhostname\_rsa

ssh-keygen -t rsa -b 4096 -C “putty-user1-myhostname” -f ~/.ssh/user1/putty-myhostname\_rsa

ssh-keygen -t ed25519 -b 521 -C “cygwin-user1-myhostname” -f ~/.ssh/user1/cygwin-myhostname\_ed25519

ssh-keygen -t ed25519 -b 521 -C “thor-user1-myhostname” -f ~/.ssh/user1/thor-myhostname\_ed25519

cat ~/.ssh/user1/ts-myhostname\_rsa.pub &gt;&gt; ~/.ssh/user1/authorized\_keys

cat ~/.ssh/user1/ts-myhostname\_rsa.pub &gt;&gt; ~/.ssh/user1/authorized\_keys

cat ~/.ssh/user1/putty-myhostname\_rsa &gt;&gt; ~/.ssh/user1/authorized\_keys

cat ~/.ssh/user1/cygwin-myhostname\_ed25519 &gt;&gt; ~/.ssh/user1/authorized\_keys

cat ~/.ssh/user1/thor-myhostname\_ed25519 &gt;&gt; ~/.ssh/user1/authorized\_keys

mkdir /home/user1/.ssh/

mv ~/.ssh/user1/\* /home/user1/.ssh/

chown -R user1:user1 /home/user1/

chmod 0600 /home/user1/.ssh/\*

chmod 0644 /home/user1/.ssh/\*.pub

chmod 0644 /home/user1/authorized\_keys

<span id="anchor-42"></span><span id="anchor-43"></span><span id="anchor-42"></span>Configure sshd
--------------------------------------------------------------------------------------------------

### <span id="anchor-44"></span>Backup original config

Prepare a copy of the original configuration file:

cp /etc/ssh/sshd\_config /etc/ssh/sshd\_config.orig

### <span id="anchor-45"></span>Create a revoke script

nano /root/sshdconfig-revoke.sh

\#!/bin/bash

mv /etc/ssh/sshd\_config /etc/ssh/sshd\_config.old

cp /etc/ssh/sshd\_config.orig /etc/ssh/sshd\_config

systemctl restart sshd

### <span id="anchor-46"></span>Change sshd\_config

After that, change */etc/ssh/sshd\_config* according to this:

Port 1022

AddressFamily inet \# ipv4 only

HostKey /etc/ssh/ssh\_host\_rsa\_key

\#HostKey /etc/ssh/ssh\_host\_dsa\_key

\#HostKey /etc/ssh/ssh\_host\_ecdsa\_key

HostKey /etc/ssh/ssh\_host\_ed25519\_key

AllowUsers user1 l0g1nb4ck00p root

PermitRootLogin yes \# because publickey,KEYBOARD-INTERACTIVE

PubkeyAuthentication yes

AuthorizedKeysFile .ssh/authorized\_keys

IgnoreRhosts yes

HostbasedAuthentication no

\#\#\# in order to find the Ciphers, run ssh -Q cipher

Ciphers chacha20-poly1305@openssh.com,aes256-gcm@openssh.com,aes128-gcm@openssh.com,aes256-ctr,aes192-ctr,aes128-ctr

\#\#\# in order to find the MACs, run ssh -Q mac

MACs hmac-sha2-512-etm@openssh.com,[**hmac-sha2-256-etm@openssh.com**](mailto:hmac-sha2-256-etm@openssh.com),hmac-sha2-512,hmac-sha2-256

ChallengeResponseAuthentication yes

AuthenticationMethods publickey,keyboard-interactive

Match User l0g1nb4ck00p

 \# only password

 AuthenticationMethods keyboard-interactive

Match User user1

 \# only SSH certificate

 AuthenticationMethods publickey

Match User root

 \# SSH certificate and password

 AuthenticationMethods publickey,keyboard-interactive

systemctl restart sshd

Logout from one session and try to login again with your ssh identity and correct port number.

Read *journalctl -u sshd* for details.

<span id="anchor-47"></span><span id="anchor-48"></span><span id="anchor-47"></span>Hash the known\_hosts file
--------------------------------------------------------------------------------------------------------------

Once in a while, **on your client(s), **you might hash the file which stores the known hosts (*~/.ssh/known\_hosts*), so that the real host names or IP addresses will be encrypted.

ssh-keygen -H

rm ~/.ssh/known\_hosts.old

If you wanted to do that automatically, **on your client(s)**, you could

nano /etc/ssh/ssh\_config

HashKnownHosts yes

or, in your local *~/.ssh/config* file

nano ~/.ssh/config

HashKnownHosts yes

<span id="anchor-49"></span><span id="anchor-50"></span><span id="anchor-49"></span>Install knockd
--------------------------------------------------------------------------------------------------

pacman -S knockd

<span id="anchor-51"></span><span id="anchor-52"></span><span id="anchor-51"></span>Configure knockd
----------------------------------------------------------------------------------------------------

### <span id="anchor-53"></span><span id="anchor-54"></span><span id="anchor-53"></span>/etc/knockd.conf

\[options\]

 logfile = /var/log/knockd.log

\[opencloseSSH\]

 sequence = 7000,8080,9060,12345

 seq\_timeout = 15

 tcpflags = syn

 start\_command = /root/knockd-open.sh **%IP%**

 cmd\_timeout = 30

 stop\_command = /root/knockd-close.sh **%IP%**

Eventually, you might add a new section to disable iptables, to reboot, …, e. g.

\[revokeiptables\]

sequence=12345,8080,9060,7000

seq\_timeout=15

tcpflags=syn

command=/root/iptables-revoke.sh

\[revokesshdconfig\]

sequence=12321,8181,9050,7001

seq\_timeout=15

tcpflags=syn

command=/root/sshdconfig-revok<span id="anchor-55"></span>command=/root/sshdconfig-revoke.sh

### <span id="anchor-56"></span><span id="anchor-57"></span><span id="anchor-56"></span>/root/knockd-open.sh

correct the port numbers, if your SSHd does not listen to port 1022

\#!/bin/bash

/sbin/iptables -I INPUT -s $1 -p tcp --dport 1022 -j ACCEPT

/sbin/iptables -I OUTPUT -d $1 -p tcp --sport 1022 -j ACCEPT

and make the script executable

chmod +x knockd-open.sh

### <span id="anchor-58"></span><span id="anchor-59"></span><span id="anchor-58"></span>/root/knockd-close.sh

be sure to use the same commands as in */root/knockd-open.sh*, but with ***-D*** instead of -I (e. g. copy the file into a different name (*knockd-close.sh*) and replace -I with -D):

\#!/bin/bash

/sbin/iptables -D INPUT -s $1 -p tcp --dport 1022 -j ACCEPT

/sbin/iptables -D OUTPUT -d $1 -p tcp --sport 1022 -j ACCEPT

and make the script executable

chmod +x knockd-close.sh

### <span id="anchor-60"></span><span id="anchor-61"></span><span id="anchor-60"></span>Test knockd

Keep logged in to at least one SSH session. Start *knockd* with

systemctl start knockd

View the logfile with

tail -f /var/log/knockd.log

Knock on your system from outside and observe the log.

Stop the log view with *&lt;ctrl-c&gt;* and, within 30 seconds (cmd\_timeout), have a look at iptables with

iptables -S

Do your find the entries?

After that, still logged in to SSH, tailor iptables in a way that you only can login after knocking, e. g.

at now + 5 minutes

/root/iptables-revoke.sh

&lt;ctrl-d&gt;

iptables -P INPUT ACCEPT

iptables -P OUTPUT ACCEPT

iptables -I INPUT -p tcp -m state --state RELATED,ESTABLISHED -m tcp --dport 1022 -j ACCEPT

iptables -I OUTPUT -p tcp -m state --state RELATED,ESTABLISHED -m tcp --sport 1022 -j ACCEPT

iptables -D OUTPUT -o eth0 -p tcp -m state --state NEW,ESTABLISHED -m tcp --sport 22 -j ACCEPT

iptables -D INPUT -i eth0 -p tcp -m state --state NEW,ESTABLISHED -m tcp --dport 22 -j ACCEPT

iptables -D INPUT -i eth0 -p tcp -m state --state NEW,ESTABLISHED -m tcp --dport 1022 -j ACCEPT

iptables -D OUTPUT -o eth0 -p tcp -m state --state NEW,ESTABLISHED -m tcp --sport 1022 -j ACCEPT

iptables -P OUTPUT DROP

iptables -P INPUT DROP

iptables -S, “unknocked”:

-P INPUT DROP

-P FORWARD DROP

-P OUTPUT DROP

-A INPUT -p tcp -m state --state RELATED,ESTABLISHED -m tcp --dport 1022 -j ACCEPT

-A INPUT -i lo -j ACCEPT

-A INPUT -s 127.0.0.0/8 ! -i lo -j REJECT --reject-with icmp-port-unreachable

-A OUTPUT -p tcp -m state --state RELATED,ESTABLISHED -m tcp --sport 1022 -j ACCEPT

-A OUTPUT -o lo -j ACCEPT

Now try to login via SSH. It should not work. Knock, and try to login via SSH again.

Iptables -S, “knocked open”:

-P INPUT DROP

-P FORWARD DROP

-P OUTPUT DROP

-A INPUT -s 12.34.56.78/32 -p tcp -m tcp --dport 1022 -j ACCEPT

-A INPUT -p tcp -m state --state RELATED,ESTABLISHED -m tcp --dport 1022 -j ACCEPT

-A INPUT -i lo -j ACCEPT

-A INPUT -s 127.0.0.0/8 ! -i lo -j REJECT --reject-with icmp-port-unreachable

-A OUTPUT -d 12.34.56.78/32 -p tcp -m tcp --sport 1022 -j ACCEPT

-A OUTPUT -p tcp -m state --state RELATED,ESTABLISHED -m tcp --sport 1022 -j ACCEPT

-A OUTPUT -o lo -j ACCEPT

Wait until knock has deleted the iptables after 30 seconds again, and save the iptables:

iptables-save &gt; /etc/iptables/iptables.rules

<span id="anchor-62"></span><span id="anchor-63"></span><span id="anchor-62"></span>openvpn
===========================================================================================

<span id="anchor-64"></span><span id="anchor-65"></span><span id="anchor-64"></span>Install openvpn and easy-rsa
----------------------------------------------------------------------------------------------------------------

pacman -S openvpn easy-rsa

cp -r /usr/share/easy-rsa/ /etc/openvpn/easy-rsa

<span id="anchor-66"></span><span id="anchor-67"></span><span id="anchor-66"></span>Generate keys, certificates and parameters
------------------------------------------------------------------------------------------------------------------------------

see [**https://wiki.archlinux.org/index.php/OpenVPN\_Checklist\_Guide**](https://wiki.archlinux.org/index.php/OpenVPN_Checklist_Guide) for general procedure.

cd /etc/openvpn/easy-rsa

nano vars

export KEYSIZE=4096

source ./vars

./clean-all

./build-ca

./build-key-server servername

./build-dh

./build-key-pass client1

For additional security, use *./build-key-**pass** &lt;client1&gt;* instead of *./build-key &lt;client1&gt;*

Also, create a TLS-Authentication key:

cd /etc/openvpn/easy-rsa/keys

openvpn --genkey --secret ta.key

<span id="anchor-68"></span><span id="anchor-69"></span><span id="anchor-68"></span>Configure openvpn server
------------------------------------------------------------------------------------------------------------

Save the below configuration e. g. as */etc/openvpn/server.conf*. Remember the name, you will need it later to start openvpn.

Why proto tcp? Because, if you want to access openvpn via tor, you must use tcp, because tor does not support udp.

\# hardened openvpn-config

\# server

\# useradd --system --shell /usr/sbin/nologin --no-create-home openvpn\_server

;user openvpn\_server

;group nogroup

cipher AES-256-CBC

auth SHA512

tls-cipher TLS-DHE-RSA-WITH-AES-256-GCM-SHA384:TLS-DHE-RSA-WITH-AES-128-GCM-SHA256:TLS-DHE-RSA-WITH-AES-256-CBC-SHA:TLS-DHE-RSA-WITH-CAMELLIA-256-CBC-SHA:TLS-DHE-RSA-WITH-AES-128-CBC-SHA:TLS-DHE-RSA-WITH-CAMELLIA-128-CBC-SHA

tls-version-min 1.2

remote-cert-tls client

tls-server

mode server

float

dev tun

proto tcp-server

port 443

comp-lzo

ca /etc/openvpn/easy-rsa/keys/ca.crt

cert /etc/openvpn/easy-rsa/keys/myhostname.crt

key /etc/openvpn/easy-rsa/keys/myhostname.key

dh /etc/openvpn/easy-rsa/keys/dh4096.pem

tls-auth /etc/openvpn/easy-rsa/keys/ta.key 0

server 10.8.0.0 255.255.255.0

topology subnet

push "redirect-gateway def1"

keepalive 10 120

persist-key

persist-tun

log /var/log/openvpn.log

status openvpn-status.log

verb 4

<span id="anchor-70"></span><span id="anchor-71"></span><span id="anchor-70"></span>Distribute Certificates and Keys
--------------------------------------------------------------------------------------------------------------------

Distribute *ca.crt, client1.key, client1.crt, ta.key* to the clients in a secure manner (encrypted).

<span id="anchor-72"></span><span id="anchor-73"></span><span id="anchor-72"></span>Configure the Clients
---------------------------------------------------------------------------------------------------------

### <span id="anchor-74"></span><span id="anchor-75"></span><span id="anchor-74"></span>Configure a linux client

\# hardened openvpn-config

\# client (linux)

client

dev tun

nobind

persist-key

persist-tun

\# route from openvpn-client to its local network

route 192.168.1.0 255.255.255.0 192.168.1.1

remote 12.34.56.78 443

proto tcp-client

comp-lzo

ca /root/ovpn/banana/ca.crt

cert /root/ovpn/banana/banana.crt

key /root/ovpn/banana/banana.key

tls-auth /root/ovpn/banana/ta.key 1

cipher AES-256-CBC

auth SHA512

tls-cipher TLS-DHE-RSA-WITH-AES-256-GCM-SHA384:TLS-DHE-RSA-WITH-AES-128-GCM-SHA256:TLS-DHE-RSA-WITH-AES-256-CBC-SHA:TLS-DHE-RSA-WITH-CAMELLIA-256-CBC-SHA:TLS-DHE-RSA-WITH-AES-128-CBC-SHA:TLS-DHE-RSA-WITH-CAMELLIA-128-CBC-SHA

tls-version-min 1.2

remote-cert-tls server

verify-x509-name myhostname name

tls-client

log /var/log/openvpn.log

status openvpn-status.log

verb 4

### <span id="anchor-76"></span><span id="anchor-77"></span><span id="anchor-76"></span>Configure an iphone

\# hardened openvpn-config

\# client (iphone)

client

dev tun

nobind

persist-key

persist-tun

\# route from openvpn-client to its local network

route 192.168.1.0 255.255.255.0 192.168.1.1

remote 12.34.56.78 443

proto tcp-client

comp-lzo

cipher AES-256-CBC

auth SHA512

tls-cipher TLS-DHE-RSA-WITH-AES-256-GCM-SHA384:TLS-DHE-RSA-WITH-AES-128-GCM-SHA256:TLS-DHE-RSA-WITH-AES-256-CBC-SHA:TLS-DHE-RSA-WITH-CAMELLIA-256-CBC-SHA:TLS-DHE-RSA-WITH-AES-128-CBC-SHA:TLS-DHE-RSA-WITH-CAMELLIA-128-CBC-SHA

tls-version-min 1.2

remote-cert-tls server

verify-x509-name myhostname name

tls-client

log /var/log/openvpn.log

status openvpn-status.log

verb 4

&lt;ca&gt;

-----BEGIN CERTIFICATE-----

MIIHEjCCBPqgAwIBAgIJAOkutoI/9N7RMA0GCSqGSIb3DQEBCwUAMIG2MQswCQYD

...

DX5xP1/7GS9cBQNwCpLUsUQfNXGvIJ4uMWY0Bw5BVqAmCoOnlpU=

-----END CERTIFICATE-----

&lt;/ca&gt;

&lt;cert&gt;

-----BEGIN CERTIFICATE-----

MIIHTzCCBTegAwIBAgIBATANBgkqhkiG9w0BAQsFADCBtjELMAkGA1UEBhMCVVMx

...

o0eWDQRY5vste6wkvYFuACrGYelO1YcBgcEVdmm7JifBk0JvqCfSPnAE6Ie72SZ0

TrAX

-----END CERTIFICATE-----

&lt;/cert&gt;

&lt;key&gt;

-----BEGIN PRIVATE KEY-----

MIIJQwIBADANBgkqhkiG9w0BAQEFAASCCS0wggkpAgEAAoICAQDHvvQKA4DPx3Tr

...

3McVmM7UT+Qz4u47zkFflwKSp+VV47Q=

-----END PRIVATE KEY-----

&lt;/key&gt;

key-direction 1

&lt;tls-auth&gt;

-----BEGIN OpenVPN Static key V1-----

...

-----END OpenVPN Static key V1-----

&lt;/tls-auth&gt;

In case this iphone configuration does not work with your password-protected, private key, do

openssl rsa -in Client1.key -des3 -out Client1.3des.key

and paste the contents of the *Client1.3des.key* into the *&lt;key&gt;* section:

&lt;key&gt;

-----BEGIN RSA PRIVATE KEY-----

Proc-Type: 4,ENCRYPTED

DEK-Info: DES-EDE3-CBC,6E60B389814847F8

NV69Nbk+tvvLcmVasdfRJZ+RFrmnWKmwPasdfkXY3k4asdf8YD3asdfYasdfVaso

...

R0T13Om/N3Y6TJSBdd1d62asdfvn1SN5lnh54cr+ix5GasdfasdFK5+z8m2UZ1sI

-----END RSA PRIVATE KEY-----

&lt;/key&gt;

(*https://forums.openvpn.net/viewtopic.php?t=18170\#p49855*)

<span id="anchor-78"></span><span id="anchor-79"></span><span id="anchor-78"></span>Adjust iptables for openvpn
---------------------------------------------------------------------------------------------------------------

iptables -A INPUT -i eth0 -p tcp -m state --state NEW,ESTABLISHED --dport 443 -j ACCEPT

iptables -A OUTPUT -o eth0 -p tcp -m state --state ESTABLISHED --sport 443 -j ACCEPT

iptables -A INPUT -i tun+ -j ACCEPT

iptables -A OUTPUT -o tun+ -j ACCEPT

iptables -A FORWARD -o eth0 -i tun+ -s 10.8.0.0/24 -m conntrack --ctstate NEW -j ACCEPT

iptables -A FORWARD -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -o eth0 -j MASQUERADE

Altogether iptables should look like that now:

iptables -S

-P INPUT DROP

-P FORWARD DROP

-P OUTPUT DROP

-A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT

-A INPUT -p tcp -m state --state RELATED,ESTABLISHED -m tcp --dport 1022 -j ACCEPT

-A INPUT -i lo -j ACCEPT

-A INPUT -i eth0 -p tcp -m state --state NEW,ESTABLISHED -m tcp --dport 443 -j ACCEPT

-A INPUT -i tun+ -j ACCEPT

-A INPUT -s 127.0.0.0/8 ! -i lo -j REJECT --reject-with icmp-port-unreachable

-A FORWARD -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT

-A FORWARD -s 10.8.0.0/24 -i tun+ -o eth0 -j ACCEPT

-A OUTPUT -p tcp -m state --state RELATED,ESTABLISHED -m tcp --sport 1022 -j ACCEPT

-A OUTPUT -o lo -j ACCEPT

-A OUTPUT -o eth0 -p tcp -m state --state ESTABLISHED -m tcp --sport 443 -j ACCEPT

-A OUTPUT -o tun+ -j ACCEPT

-A OUTPUT -o eth0 -m state --state NEW,ESTABLISHED -j ACCEPT

iptables -t nat -S

-P PREROUTING ACCEPT

-P INPUT ACCEPT

-P OUTPUT ACCEPT

-P POSTROUTING ACCEPT

-A POSTROUTING -s 10.8.0.0/24 -o eth0 -j MASQUERADE

<span id="anchor-80"></span>Enable ipv4 forwarding
--------------------------------------------------

sysctl -w net.ipv4.ip\_forward=1

nano /etc/sysctl.d/30-ipforward.conf

net.ipv4.ip\_forward=1

<span id="anchor-81"></span><span id="anchor-82"></span><span id="anchor-81"></span>Start openvpn on the server
---------------------------------------------------------------------------------------------------------------

The name of the configuration for the server goes after the *@* sign. If your configuration file is */etc/openvpn/server.conf*, then:

systemctl start openvpn@server

systemctl status openvpn@server

systemctl enable openvpn@server

<span id="anchor-83"></span>Connect via openvpn from the client
---------------------------------------------------------------

openvpn client.conf

<span id="anchor-84"></span>Save iptables on the server
-------------------------------------------------------

if it works, save iptables on the server

iptables-save &gt; /etc/iptables/iptables.rules

<span id="anchor-85"></span>Obfsproxy
=====================================

<span id="anchor-86"></span>Install obfsproxy on server and client(s)
---------------------------------------------------------------------

pacman -Syu obfsproxy

<span id="anchor-87"></span>Configure second openvpn server for obfsproxy on the server
---------------------------------------------------------------------------------------

Why? For those devices (e. g. iphones) which cannot use a local proxy. Name the file e. g. */etc/openvpn/openvpn-with-obfsproxy.conf*

\# hardened openvpn-config

\# server

\# useradd --system --shell /usr/sbin/nologin --no-create-home openvpn\_server

;user openvpn\_server

;group nogroup

cipher AES-256-CBC

auth SHA512

tls-cipher TLS-DHE-RSA-WITH-AES-256-GCM-SHA384:TLS-DHE-RSA-WITH-AES-128-GCM-SHA256:TLS-DHE-RSA-WITH-AES-256-CBC-SHA:TLS-DHE-RSA-WITH-CAMELLIA-256-CBC-SHA:TLS-DHE-RSA-WITH-AES-128-CBC-SHA:TLS-DHE-RSA-WITH-CAMELLIA-128-CBC-SHA

tls-version-min 1.2

remote-cert-tls client

tls-server

mode server

float

dev tun***1***

proto tcp-server

**port 443*****0***

comp-lzo

ca /etc/openvpn/easy-rsa/keys/ca.crt

cert /etc/openvpn/easy-rsa/keys/myhostname.crt

key /etc/openvpn/easy-rsa/keys/myhostname.key

dh /etc/openvpn/easy-rsa/keys/dh4096.pem

tls-auth /etc/openvpn/easy-rsa/keys/ta.key 0

server 10.***10***.0.0 255.255.255.0

topology subnet

push "redirect-gateway ***local***"

\# replace 12.34.56.78 with the public internet IP address of your server

**push "route 12.34.56.78 255.255.255.255 net\_gateway"**

keepalive 10 120

persist-key

persist-tun

log /var/log/openvpn-obfsproxy.log

status openvpn-status-obfsproxy.log

verb 4

<span id="anchor-88"></span>Configure iptables for obfsproxy and openvpn on the server
--------------------------------------------------------------------------------------

We will \_not\_ use 4430 here, for reasons stated below.

iptables -A INPUT -i eth0 -p tcp -m state --state NEW,ESTABLISHED -m tcp --dport *21194* -j ACCEPT

iptables -A INPUT -i tun+ -j ACCEPT

iptables -A OUTPUT -o tun+ -j ACCEPT

iptables -A FORWARD -s 10.***10***.0.0/24 -i tun+ -o eth0 -j ACCEPT

iptables -t nat -A POSTROUTING -s 10.***10***.0.0/24 -o eth0 -j MASQUERADE

so iptables should look like that now:

iptables -S

-P INPUT DROP

-P FORWARD DROP

-P OUTPUT DROP

-A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT

-A INPUT -p tcp -m state --state RELATED,ESTABLISHED -m tcp --dport 1022 -j ACCEPT

-A INPUT -i lo -j ACCEPT

-A INPUT -i eth0 -p tcp -m state --state NEW,ESTABLISHED -m tcp --dport 443 -j ACCEPT

-A INPUT -s 127.0.0.0/8 ! -i lo -j REJECT --reject-with icmp-port-unreachable

-A INPUT -i eth0 -p tcp -m state --state NEW,ESTABLISHED -m tcp --dport 21194 -j ACCEPT

-A INPUT -i tun+ -j ACCEPT

-A FORWARD -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT

-A FORWARD -s 10.8.0.0/24 -i tun+ -o eth0 -j ACCEPT

-A FORWARD -s 10.10.0.0/24 -i tun+ -o eth0 -j ACCEPT

-A OUTPUT -p tcp -m state --state RELATED,ESTABLISHED -m tcp --sport 1022 -j ACCEPT

-A OUTPUT -o lo -j ACCEPT

-A OUTPUT -o eth0 -p tcp -m state --state ESTABLISHED -m tcp --sport 443 -j ACCEPT

-A OUTPUT -o eth0 -m state --state NEW,ESTABLISHED -j ACCEPT

-A OUTPUT -o tun+ -j ACCEPT

iptables -t nat -S

-P PREROUTING ACCEPT

-P INPUT ACCEPT

-P OUTPUT ACCEPT

-P POSTROUTING ACCEPT

-A POSTROUTING -s 10.8.0.0/24 -o eth0 -j MASQUERADE

-A POSTROUTING -s 10.10.0.0/24 -o eth0 -j MASQUERADE

<span id="anchor-89"></span>Create a .service unit for obfsproxy on the server
------------------------------------------------------------------------------

So that it starts automatically with the server, we need a service unit file. It will call obfsproxy, awaiting connections on port 21194, forwarding them to 4430.

nano */etc/systemd/system/*obfsproxy.service

\[Unit\]

Description=obfuscating proxy server

After=network.target

\[Service\]

User=obfsproxy

Type=simple

ExecStart=/usr/bin/python2 /usr/bin/obfsproxy --log-file=/var/log/obfsproxy.log --log-min-severity=info obfs3 --dest=127.0.0.1:***4430*** server 0.0.0.0:*21194*

ExecReload=/usr/bin/kill -HUP $MAINPID

KillSignal=SIGINT

\[Install\]

WantedBy=multi-user.target

We want a logfile writeable to the user "obfsproxy", so

touch /var/log/obfsproxy.log

chown obfsproxy:obfsproxy /var/log/obfsproxy.log

<span id="anchor-90"></span>Start obfsproxy on the server
---------------------------------------------------------

systemctl start obfsproxy

systemctl status obfsproxy

systemctl enable obfsproxy

<span id="anchor-91"></span>Start openvpn on the server
-------------------------------------------------------

systemctl start openvpn@openvpn-with-obfsproxy

<span id="anchor-92"></span>Create a client configuration for openvpn on the client
-----------------------------------------------------------------------------------

name it *ovpn-obfsproxy.conf*

**socks-proxy-retry**

**socks-proxy 127.0.0.1 10194**

client

dev ***tun***

nobind

persist-key

persist-tun

route 192.168.1.0 255.255.255.0 192.168.1.1

remote 12.34.56.78 *21194*

proto tcp-client

comp-lzo

ca /root/ovpn/banana/ca.crt

cert /root/ovpn/banana/banana.crt

key /root/ovpn/banana/banana.key

tls-auth /root/ovpn/banana/ta.key 1

cipher AES-256-CBC

auth SHA512

tls-cipher TLS-DHE-RSA-WITH-AES-256-GCM-SHA384:TLS-DHE-RSA-WITH-AES-128-GCM-SHA256:TLS-DHE-RSA-WITH-AES-256-CBC-SHA:TLS-DHE-RSA-WITH-CAMELLIA-256-CBC-SHA:TLS-DHE-RSA-WITH-AES-128-CBC-SHA:TLS-DHE-RSA-WITH-CAMELLIA-128-CBC-SHA

tls-version-min 1.2

remote-cert-tls server

verify-x509-name myhostname name

tls-client

log /var/log/openvpn-obfsproxy.log

status openvpn-status-obfsproxy.log

verb 4

<span id="anchor-93"></span>Start obfsproxy on the client
---------------------------------------------------------

obfsproxy --log-file=/var/log/obfsproxy.log --log-min-severity=info obfs3 socks 127.0.0.1:10194

Alternatively, create a service unit file:

nano */etc/systemd/system/*obfsproxy.service

\[Unit\]

Description=obfuscating proxy client

After=network.target

\[Service\]

\# leave the User directive out here in the client service file

Type=simple

ExecStart=/usr/bin/python2 /usr/bin/obfsproxy --log-file=/var/log/obfsproxy.log --log-min-severity=info obfs3 socks 127.0.0.1:10194

ExecReload=/usr/bin/kill -HUP $MAINPID

KillSignal=SIGINT

\[Install\]

WantedBy=multi-user.target

Then start/enable it

systemctl start obfsproxy.service

systemctl status obfsproxy.service

systemctl enable obfsproxy.service

<span id="anchor-94"></span>Start openvpn on the client
-------------------------------------------------------

This can take a little longer than normal. It might also not work at all. Proxy timing will be solved in openvpn 2.3.12, according to *https://community.openvpn.net/openvpn/ticket/328*

openvpn ovpn-obfsproxy.conf

From another SSH session, ping the server or try to reach the internet

ping 10.10.0.1

curl icanhazip.com

<span id="anchor-95"></span>Save iptables
-----------------------------------------

If it works, save the iptables on the server

iptables-save &gt; /etc/iptables/iptables.rules

<span id="anchor-96"></span><span id="anchor-97"></span><span id="anchor-96"></span>Tor
=======================================================================================

<span id="anchor-98"></span><span id="anchor-99"></span><span id="anchor-98"></span>Install tor on the server
-------------------------------------------------------------------------------------------------------------

pacman -Syu tor

<span id="anchor-100"></span><span id="anchor-101"></span><span id="anchor-100"></span>Install tor in a chroot environment
--------------------------------------------------------------------------------------------------------------------------

nano ~/torchroot-setup.sh

\#!/bin/bash

export TORCHROOT=/opt/torchroot

mkdir -p $TORCHROOT

mkdir -p $TORCHROOT/etc/tor

mkdir -p $TORCHROOT/dev

mkdir -p $TORCHROOT/usr/bin

mkdir -p $TORCHROOT/usr/lib

mkdir -p $TORCHROOT/usr/share/tor

mkdir -p $TORCHROOT/var/lib

ln -s /usr/lib $TORCHROOT/lib

cp /etc/hosts $TORCHROOT/etc/

cp /etc/host.conf $TORCHROOT/etc/

cp /etc/localtime $TORCHROOT/etc/

cp /etc/nsswitch.conf $TORCHROOT/etc/

cp /etc/resolv.conf $TORCHROOT/etc/

cp /etc/tor/torrc $TORCHROOT/etc/tor/

cp /usr/bin/tor $TORCHROOT/usr/bin/

cp /usr/share/tor/geoip\* $TORCHROOT/usr/share/tor/

cp /lib/libnss\* /lib/libnsl\* /lib/ld-linux-\*.so\* /lib/libresolv\* /lib/libgcc\_s.so\* $TORCHROOT/usr/lib/

cp $(ldd /usr/bin/tor | awk '{print $3}'|grep --color=never "^/") $TORCHROOT/usr/lib/

cp -r /var/lib/tor $TORCHROOT/var/lib/

chown -R tor:tor $TORCHROOT/var/lib/tor

sh -c "grep --color=never ^tor /etc/passwd &gt; $TORCHROOT/etc/passwd"

sh -c "grep --color=never ^tor /etc/group &gt; $TORCHROOT/etc/group"

mknod -m 644 $TORCHROOT/dev/random c 1 8

mknod -m 644 $TORCHROOT/dev/urandom c 1 9

mknod -m 666 $TORCHROOT/dev/null c 1 3

if \[\[ "$(uname -m)" == "x86\_64" \]\]; then

 cp /usr/lib/ld-linux-x86-64.so\* $TORCHROOT/usr/lib/.

 ln -sr /usr/lib64 $TORCHROOT/lib64

 ln -s $TORCHROOT/usr/lib ${TORCHROOT}/usr/lib64

<span id="anchor-102"></span>fi

Make executable

chmod +x torchroot-setup.sh

and run

./torchroot-setup.sh

<span id="anchor-103"></span><span id="anchor-104"></span><span id="anchor-103"></span>Configure tor
----------------------------------------------------------------------------------------------------

### <span id="anchor-105"></span><span id="anchor-106"></span><span id="anchor-105"></span>/opt/torchroot/etc/tor/torrc

nano /opt/torchroot/etc/tor/torrc

VirtualAddrNetworkIPv4 10.192.0.0/10

AutomapHostsOnResolve 1

TransPort 10.8.0.1:9040

DNSPort 10.8.0.1:***5353***

TransPort 10.**10**.0.1:9040

DNSPort 10.**10**.0.1:***5353***

\# for local DNS resolution:

DNSPort 127.0.0.1:5353

### <span id="anchor-107"></span><span id="anchor-108"></span><span id="anchor-107"></span>Configure /etc/resolv.conf

nano /etc/resolv.conf.tor

nameserver 127.0.0.1

then

cp /etc/resolv.conf /etc/resolv.conf.orig

rm -rf /etc/resolv.conf

ln -s /etc/resolv.conf.tor /etc/resolv.conf

### <span id="anchor-109"></span><span id="anchor-110"></span><span id="anchor-109"></span>Configure iptables for tor

iptables -I OUTPUT -m conntrack --ctstate INVALID -j DROP

iptables -I OUTPUT -m state --state INVALID -j DROP

iptables -I OUTPUT ! -o lo ! -d 127.0.0.1 ! -s 127.0.0.1 -p tcp -m tcp --tcp-flags ACK,FIN ACK,FIN -j DROP

iptables -I OUTPUT ! -o lo ! -d 127.0.0.1 ! -s 127.0.0.1 -p tcp -m tcp --tcp-flags ACK,RST ACK,RST -j DROP

\# for local DNS resolution:

iptables -t nat -A OUTPUT -p udp --dport 53 -j REDIRECT --to-ports 5353

iptables -t nat -A PREROUTING -i tun+ -p udp --dport 53 -j REDIRECT --to-ports ***5353***

iptables -t nat -A PREROUTING -i tun+ -p tcp --syn -j REDIRECT --to-ports 9040

So, until now, your iptables should look like that:

 iptables -S

-P INPUT DROP

-P FORWARD DROP

-P OUTPUT DROP

-A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT

-A INPUT -p tcp -m state --state RELATED,ESTABLISHED -m tcp --dport 1022 -j ACCEPT

-A INPUT -i lo -j ACCEPT

-A INPUT -i eth0 -p tcp -m state --state NEW,ESTABLISHED -m tcp --dport 443 -j ACCEPT

-A INPUT -s 127.0.0.0/8 ! -i lo -j REJECT --reject-with icmp-port-unreachable

-A INPUT -i eth0 -p tcp -m state --state NEW,ESTABLISHED -m tcp --dport 21194 -j ACCEPT

-A INPUT -i tun+ -j ACCEPT

-A FORWARD -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT

-A FORWARD -s 10.8.0.0/24 -i tun+ -o eth0 -j ACCEPT

-A FORWARD -s 10.10.0.0/24 -i tun+ -o eth0 -j ACCEPT

-A OUTPUT ! -s 127.0.0.1/32 ! -d 127.0.0.1/32 ! -o lo -p tcp -m tcp --tcp-flags RST,ACK RST,ACK -j DROP

-A OUTPUT ! -s 127.0.0.1/32 ! -d 127.0.0.1/32 ! -o lo -p tcp -m tcp --tcp-flags FIN,ACK FIN,ACK -j DROP

-A OUTPUT -m state --state INVALID -j DROP

-A OUTPUT -m conntrack --ctstate INVALID -j DROP

-A OUTPUT -p tcp -m state --state RELATED,ESTABLISHED -m tcp --sport 1022 -j ACCEPT

-A OUTPUT -o lo -j ACCEPT

-A OUTPUT -o eth0 -p tcp -m state --state ESTABLISHED -m tcp --sport 443 -j ACCEPT

-A OUTPUT -o eth0 -m state --state NEW,ESTABLISHED -j ACCEPT

-A OUTPUT -o tun+ -j ACCEPT

iptables -t nat -S

-P PREROUTING ACCEPT

-P INPUT ACCEPT

-P OUTPUT ACCEPT

-P POSTROUTING ACCEPT

-A PREROUTING -i tun+ -p udp -m udp --dport 53 -j REDIRECT --to-ports 5353

-A PREROUTING -i tun+ -p tcp -m tcp --tcp-flags FIN,SYN,RST,ACK SYN -j REDIRECT --to-ports 9040

-A OUTPUT -p udp -m udp --dport 53 -j REDIRECT --to-ports 5353

-A POSTROUTING -s 10.8.0.0/24 -o eth0 -j MASQUERADE

-A POSTROUTING -s 10.10.0.0/24 -o eth0 -j MASQUERADE

Note: your VPS will now resolve DNS names via tor, and the connection itself to the resolved host will be run via clearnet. Example:

pacman -Syu dnsutils \# to install dig

dig icanhazip.com

; &lt;&lt;&gt;&gt; DiG 9.10.4 &lt;&lt;&gt;&gt; icanhazip.com

;; global options: +cmd

;; Got answer:

;; -&gt;&gt;HEADER&lt;&lt;- opcode: QUERY, status: NOERROR, id: 49727

;; flags: qr rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 0

;; QUESTION SECTION:

;icanhazip.com. IN A

;; ANSWER SECTION:

icanhazip.com. 60 IN A 64.182.208.181

;; Query time: 38 msec

;; ***SERVER: 127.0.0.1\#53(127.0.0.1)***

;; WHEN: Sat May 14 10:23:11 UTC 2016

;; MSG SIZE rcvd: 47

will be run via tor

curl icanhazip.com

12.34.56.78

will be run via clearnet. This behavior is disputed. (*https://webcache.googleusercontent.com/search?q=cache:R2\_Y3-4a7t0J:https://trac.torproject.org/projects/tor/wiki/doc/TransparentProxy* states "Warning: While this sounds great there is one disadvantage: ALL your dns request will be made through Tor. You anonymous ones and your non-anonymous ones. Not sure how safe it is to make first an anonymous DNS request and to non-anonymously view a target afterwards. ")

An alternative for that would be to install a DNS server/forwarder on your VPS and have it resolve hostnames via an upstream DNS, e. g. from opennicproject.org

Example, *not tested, not done yet during this tutorial, only from my memory of earlier projects:*

iptables -t nat ***-D*** OUTPUT -p udp --dport 53 -j REDIRECT --to-ports 5353

pacman -Syu dnsmasq

nano /etc/dnsmasq.conf

listen-address 127.0.0.1:53

server <span id="anchor-111"></span>server 95.85.9.86

systemctl start dnsmasq

systemctl status dnsmasq

systemctl enable dnsmasq

### <span id="anchor-112"></span><span id="anchor-113"></span><span id="anchor-112"></span>Overload and start the tor service

mkdir /etc/systemd/system/tor.service.d/

nano /etc/systemd/system/tor.service.d/chroot.conf

\[Service\]

User=root

ExecStart=

ExecStart=/usr/bin/sh -c "chroot --userspec=tor:tor /opt/torchroot /usr/bin/tor -f /etc/tor/torrc"

KillSignal=SIGINT

then start tor

systemctl start tor

systemctl status tor

systemctl enable tor

<span id="anchor-114"></span>Enable pushing DNS server from openvpn server to client
------------------------------------------------------------------------------------

In order to use the openvpn server as DNS server, and not use the openvpn *client's* server (DNS leak!), perform the following steps:

### <span id="anchor-115"></span>Push DNS server

add the following line to your openvpn configuration on the server

push "dhcp-option DNS 10.8.0.1"

so that the server configuration file looks like that:

\# hardened openvpn-config

\# server

\# useradd --system --shell /usr/sbin/nologin --no-create-home openvpn\_server

;user openvpn\_server

;group nogroup

cipher AES-256-CBC

auth SHA512

tls-cipher TLS-DHE-RSA-WITH-AES-256-GCM-SHA384:TLS-DHE-RSA-WITH-AES-128-GCM-SHA256:TLS-DHE-RSA-WITH-AES-256-CBC-SHA:TLS-DHE-RSA-WITH-CAMELLIA-256-CBC-SHA:TLS-DHE-RSA-WITH-AES-128-CBC-SHA:TLS-DHE-RSA-WITH-CAMELLIA-128-CBC-SHA

tls-version-min 1.2

remote-cert-tls client

tls-server

mode server

float

dev tun

proto tcp-server

port 443

comp-lzo

ca /etc/openvpn/easy-rsa/keys/ca.crt

cert /etc/openvpn/easy-rsa/keys/myhostname.crt

key /etc/openvpn/easy-rsa/keys/myhostname.key

dh /etc/openvpn/easy-rsa/keys/dh4096.pem

tls-auth /etc/openvpn/easy-rsa/keys/ta.key 0

server 10.8.0.0 255.255.255.0

topology subnet

push "redirect-gateway def1"

push "dhcp-option DNS 10.8.0.1"

keepalive 10 120

persist-key

persist-tun

log /var/log/openvpn.log

status openvpn-status.log

verb 4

Restart the openvpn server

systemctl restart openvpn@yourconfigfile.conf

systemctl status openvpn@yourconfigfile.conf

### <span id="anchor-116"></span>Allow the openvpn client to change its DNS settings (/etc/resolv.conf)

Add the following lines to your openvpn configuration on the client:

script-security 2

up /etc/openvpn/update-resolv-conf.sh

down /etc/openvpn/update-resolv-conf.sh

so that the openvpn client configuration looks like that:

client

dev tun0

nobind

persist-key

persist-tun

route 192.168.1.0 255.255.255.0 192.168.1.1

remote 12.34.56.78 443

proto tcp-client

comp-lzo

ca /root/ovpn/banana/ca.crt

cert /root/ovpn/banana/banana.crt

key /root/ovpn/banana/banana.key

tls-auth /root/ovpn/banana/ta.key 1

cipher AES-256-CBC

auth SHA512

tls-cipher TLS-DHE-RSA-WITH-AES-256-GCM-SHA384:TLS-DHE-RSA-WITH-AES-128-GCM-SHA256:TLS-DHE-RSA-WITH-AES-256-CBC-SHA:TLS-DHE-RSA-WITH-CAMELLIA-256-CBC-SHA:TLS-DHE-RSA-WITH-AES-128-CBC-SHA:TLS-DHE-RSA-WITH-CAMELLIA-128-CBC-SHA

tls-version-min 1.2

remote-cert-tls server

verify-x509-name myhostname name

tls-client

log /var/log/openvpn.log

status openvpn-status.log

verb 4

script-security 2

up /etc/openvpn/update-resolv-conf.sh

down /etc/openvpn/update-resolv-conf.sh

And create the following script in */etc/openvpn/update-resolv-conf.sh*

\#!/bin/bash

\#

\# Parses DHCP options from openvpn to update resolv.conf

\# To use set as 'up' and 'down' script in your openvpn \*.conf:

\# up /etc/openvpn/update-resolv-conf

\# down /etc/openvpn/update-resolv-conf

\#

\# Used snippets of resolvconf script by Thomas Hood &lt;jdthood@yahoo.co.uk&gt;

\# and Chris Hanson

\# Licensed under the GNU GPL. See /usr/share/common-licenses/GPL.

\# 07/2013 colin@daedrum.net Fixed intet name

\# 05/2006 chlauber@bnc.ch

\#

\# Example envs set from openvpn:

\# foreign\_option\_1='dhcp-option DNS 193.43.27.132'

\# foreign\_option\_2='dhcp-option DNS 193.43.27.133'

\# foreign\_option\_3='dhcp-option DOMAIN be.bnc.ch'

\# foreign\_option\_4='dhcp-option DOMAIN-SEARCH bnc.local'

\#\# You might need to set the path manually here, i.e.

RESOLVCONF=$(which resolvconf)

case $script\_type in

up)

 for optionname in ${!foreign\_option\_\*} ; do

 option="${!optionname}"

 echo $option

 part1=$(echo "$option" | cut -d " " -f 1)

 if \[ "$part1" == "dhcp-option" \] ; then

 part2=$(echo "$option" | cut -d " " -f 2)

 part3=$(echo "$option" | cut -d " " -f 3)

 if \[ "$part2" == "DNS" \] ; then

 IF\_DNS\_NAMESERVERS="$IF\_DNS\_NAMESERVERS $part3"

 fi

 if \[\[ "$part2" == "DOMAIN" || "$part2" == "DOMAIN-SEARCH" \]\] ; then

 IF\_DNS\_SEARCH="$IF\_DNS\_SEARCH $part3"

 fi

 fi

 done

 R=""

 if \[ "$IF\_DNS\_SEARCH" \]; then

 R="search "

 for DS in $IF\_DNS\_SEARCH ; do

 R="${R} $DS"

 done

 R="${R}

"

 fi

 for NS in $IF\_DNS\_NAMESERVERS ; do

 R="${R}nameserver $NS

"

 done

 \#echo -n "$R" | $RESOLVCONF -x -p -a "${dev}"

 echo -n "$R" | $RESOLVCONF -x -a "${dev}.inet"

 ;;

down)

 $RESOLVCONF -d "${dev}.inet"

 ;;

esac

\# Workaround / jm@epiclabs.io

\# force exit with no errors. Due to an apparent conflict with the Network Manager

\# $RESOLVCONF sometimes exits with error code 6 even though it has performed the

\# action correctly and OpenVPN shuts down.

exit 0

Make the script executable

chmod +x /etc/openvpn/update-resolv-conf.sh

<span id="anchor-117"></span>Connect from the client via openvpn to the server
------------------------------------------------------------------------------

openvpn yourclientconfig.conf

ping 10.8.0.1

curl icanhazip.com \# (can take a while)

curl -k https://check.torproject.org | grep Congratulations

dig 3g2upl4pq6kufc4m.onion

and last but not least, check which DNS server is being used:

cat /etc/resolv.conf

should read

nameserver 10.8.0.1

If it does, perform a DNS check:

dig AAAA check.torproject.org

it should return

; &lt;&lt;&gt;&gt; DiG 9.8.1-P1 &lt;&lt;&gt;&gt; AAAA check.torproject.org

;; global options: +cmd

;; Got answer:

;; -&gt;&gt;HEADER&lt;&lt;- opcode: QUERY, status: NOTIMP, id: 42383

;; flags: qr rd ra; QUERY: 1, ANSWER: 0, AUTHORITY: 0, ADDITIONAL: 0

;; QUESTION SECTION:

;check.torproject.org. IN AAAA

;; Query time: 0 msec

***;; SERVER: 10.8.0.1\#53(10.8.0.1)***

;; WHEN: \[date\]

;; MSG SIZE rcvd: 38

Check whether DNS and routes will be reverted
---------------------------------------------

Break the connection on the client with *ctrl-c*, then

cat /etc/resolv.conf

should show your DNS you got via DHCP or a fixed one, and

ip route

should show no routes to 10.8.0.1

<span id="anchor-118"></span>Save iptables on the server
--------------------------------------------------------

if everything works as expected, save the iptables on the server.

iptables-save &gt; /etc/iptables/iptables.rules

Tor on the client
=================

For even more anonymity, yuo can install tor on the client, so that the client will build up an openvpn connection to the VPS via tor.

Install tor on the client
-------------------------

pacman -Syu tor

Configure tor on the client for local redirection
-------------------------------------------------

nano /etc/tor/torrc

VirtualAddrNetworkIPv4 10.192.0.0/10

AutomapHostsOnResolve 1

TransPort 9040

DNSPort 53

Configure /etc/resolv.conf on the client
----------------------------------------

nano /etc/resolv.conf.tor

nameserver 127.0.0.1

then

cp /etc/resolv.conf /etc/resolv.conf.orig

rm -rf /etc/resolv.conf

ln -s /etc/resolv.conf.tor /etc/resolv.conf

Add iptables on the client
--------------------------

cat /etc/passwd

and note down the UID for tor. In the below example, tor's uid is 43:

tor:x:***43***:43::/var/lib/tor:/bin/false

then

nano iptables-tor.sh

\#!/bin/sh

\#\#\# set variables

\#destinations you don't want routed through Tor

\_non\_tor="192.168.1.0/24 192.168.0.0/24"

\#the UID that Tor runs as (varies from system to system)

\_tor\_uid="***43***"

\#Tor's TransPort

\_trans\_port="9040"

\#\#\# flush iptables

iptables -F

iptables -t nat -F

\#\#\# set iptables \*nat

iptables -t nat -A OUTPUT -m owner --uid-owner $\_tor\_uid -j RETURN

iptables -t nat -A OUTPUT -p udp --dport 53 -j REDIRECT --to-ports 5353

\#allow clearnet access for hosts in $\_non\_tor

for \_clearnet in $\_non\_tor 127.0.0.0/9 127.128.0.0/10; do

 iptables -t nat -A OUTPUT -d $\_clearnet -j RETURN

done

\#redirect all other output to Tor's TransPort

iptables -t nat -A OUTPUT -p tcp --syn -j REDIRECT --to-ports $\_trans\_port

\#\#\# set iptables \*filter

iptables -A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

\#allow clearnet access for hosts in $\_non\_tor

for \_clearnet in $\_non\_tor 127.0.0.0/8; do

 iptables -A OUTPUT -d $\_clearnet -j ACCEPT

done

\#allow only Tor output

iptables -A OUTPUT -m owner --uid-owner $\_tor\_uid -j ACCEPT

iptables -A OUTPUT -j REJECT

make the script executable

chmod +x iptables-tor.sh

and run it

./iptables-tor.sh

and add the fix against DNS leaks

iptables -I OUTPUT -m conntrack --ctstate INVALID -j DROP

iptables -I OUTPUT -m state --state INVALID -j DROP

iptables -I OUTPUT ! -o lo ! -d 127.0.0.1 ! -s 127.0.0.1 -p tcp -m tcp --tcp-flags ACK,FIN ACK,FIN -j DROP

iptables -I OUTPUT ! -o lo ! -d 127.0.0.1 ! -s 127.0.0.1 -p tcp -m tcp --tcp-flags ACK,RST ACK,RST -j DROP

so your iptables should look like that

iptables -S

-P INPUT ACCEPT

-P FORWARD ACCEPT

-P OUTPUT ACCEPT

-A OUTPUT ! -s 127.0.0.1/32 ! -d 127.0.0.1/32 ! -o lo -p tcp -m tcp --tcp-flags RST,ACK RST,ACK -j DROP

-A OUTPUT ! -s 127.0.0.1/32 ! -d 127.0.0.1/32 ! -o lo -p tcp -m tcp --tcp-flags FIN,ACK FIN,ACK -j DROP

-A OUTPUT -m state --state INVALID -j DROP

-A OUTPUT -m conntrack --ctstate INVALID -j DROP

-A OUTPUT -m state --state RELATED,ESTABLISHED -j ACCEPT

-A OUTPUT -d 192.168.1.0/24 -j ACCEPT

-A OUTPUT -d 127.0.0.0/8 -j ACCEPT

-A OUTPUT -m owner --uid-owner 43 -j ACCEPT

-A OUTPUT -j REJECT --reject-with icmp-port-unreachable

iptables -t nat -S

-P PREROUTING ACCEPT

-P INPUT ACCEPT

-P OUTPUT ACCEPT

-P POSTROUTING ACCEPT

-A OUTPUT -m owner --uid-owner 43 -j RETURN

-A OUTPUT -p udp -m udp --dport 53 -j REDIRECT --to-ports 5353

-A OUTPUT -d 192.168.1.0/24 -j RETURN

-A OUTPUT -d 127.0.0.0/9 -j RETURN

-A OUTPUT -d 127.128.0.0/10 -j RETURN

-A OUTPUT -p tcp -m tcp --tcp-flags FIN,SYN,RST,ACK SYN -j REDIRECT --to-ports 9040

and save iptables with

iptables-save &gt; /etc/iptables/iptables.rules

Start tor on the client
-----------------------

systemctl start tor

systemctl status tor

if you see that the service did not start, issue

sudo -u tor tor

and watch the output.

If tor cannot open circuits, control the system date and time and set it to the correct value.

Test tor
--------

curl icanhazip.com \# (can take a while)

curl -k https://check.torproject.org | grep Congratulations

dig 3g2upl4pq6kufc4m.onion

Configure openvpn to use with tor
---------------------------------

nano openvpn-tor.conf

client

dev tun0

nobind

persist-key

persist-tun

**socks-proxy localhost 9050**

**socks-proxy-retry**

\# allow connections in local network, e. g. this ssh session

route 192.168.1.0 255.255.255.0 192.168.1.1

remote 12.34.56.78 443

proto tcp-client

comp-lzo

ca /root/ovpn/thor/ca.crt

cert /root/ovpn/thor/thor.crt

key /root/ovpn/thor/thor.key

tls-auth /root/ovpn/thor/ta.key 1

cipher AES-256-CBC

auth SHA512

tls-cipher TLS-DHE-RSA-WITH-AES-256-GCM-SHA384:TLS-DHE-RSA-WITH-AES-128-GCM-SHA256:TLS-DHE-RSA-WITH-AES-256-CBC-SHA:TLS-DHE-RSA-WITH-CAMELLIA-256-CBC-SHA:TLS-DHE-RSA-WITH-AES-128-CBC-SHA:TLS-DHE-RSA-WITH-CAMELLIA-128-CBC-SHA

tls-version-min 1.2

\# expect a server type certificate from remote site

remote-cert-tls server

verify-x509-name myhostname name

tls-client

log /var/log/openvpn-tor.log

status openvpn-status.log

verb 4

\# allow and perform dns changes via

\# the server directive push "dhcp-option DNS 10.8.0.1"

script-security 2

up /etc/openvpn/update-resolv-conf.sh

down /etc/openvpn/update-resolv-conf.sh

<span id="anchor-119"></span><span id="anchor-120"></span><span id="anchor-119"></span>Turn off logging
=======================================================================================================

nano /etc/systemd/journald.conf

Storage=none

obfsproxy

openvpn

tor

privoxy


