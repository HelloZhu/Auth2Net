
#!/usr/local/Cellar/expect
set timeout 30
spawn ssh -p 28695 root@67.216.221.80
expect "password:"
send "pfiTWq8lH4tH"
interact
