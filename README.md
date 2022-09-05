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

## flag
```
user:
root:
```
