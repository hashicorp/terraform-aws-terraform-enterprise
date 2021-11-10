Host default
    HostName ${instance.id}
    User ${user}
    Port 22
    UserKnownHostsFile /dev/null
    StrictHostKeyChecking no
    PasswordAuthentication no
    IdentityFile ${identity_file}
    IdentitiesOnly yes
    LogLevel FATAL
    ProxyCommand aws ssm start-session --target %h --document-name AWS-StartSSHSession --parameters "portNumber=%p"
