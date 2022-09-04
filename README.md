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


## flag
```
user:
root:
```
