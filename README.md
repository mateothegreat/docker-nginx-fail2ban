# nginx + fail2ban

## Starting
```bash
docker-compose up
```

which will output:

```bash
$ docker-compose up

Starting fail2ban ... done
Attaching to fail2ban
fail2ban    | Server ready
```

### Testing

Run apache benchmark to generate requests:

```bash
$ ab -k -c 5 -n 100 http://localhost:8080/
```

which will output:

```bash
This is ApacheBench, Version 2.3 <$Revision: 1879490 $>
Copyright 1996 Adam Twiss, Zeus Technology Ltd, http://www.zeustech.net/
Licensed to The Apache Software Foundation, http://www.apache.org/

Benchmarking localhost (be patient)...apr_pollset_poll: The timeout specified has expired (70007)
Total of 10 requests completed
```

(notice the timeout line -- this means we've effectively blocked ourselves!)

Check the status of the jail:

```bash
$ docker exec -it fail2ban fail2ban-client status nginx-req-limit    
                 
Status for the jail: nginx-req-limit
|- Filter
|  |- Currently failed: 0
|  |- Total failed:     9
|  `- File list:        /var/log/nginx/access.log /var/log/nginx/error.log
`- Actions
   |- Currently banned: 1
   |- Total banned:     1
   `- Banned IP list:   172.18.0.1
```

Now verify the firewall shun:

```bash
$ docker exec -it fail2ban iptables -nL
                          
Chain INPUT (policy ACCEPT)
target     prot opt source               destination         
f2b-nginx-req-limit  tcp  --  0.0.0.0/0            0.0.0.0/0            multiport dports 0:65535

Chain FORWARD (policy ACCEPT)
target     prot opt source               destination         

Chain OUTPUT (policy ACCEPT)
target     prot opt source               destination         

Chain f2b-nginx-req-limit (1 references)
target     prot opt source               destination         
REJECT     all  --  172.18.0.1           0.0.0.0/0            reject-with icmp-port-unreachable
RETURN     all  --  0.0.0.0/0            0.0.0.0/0  
```

(notice the REJECT line at the bottom!)
