#!/bin/bash
# first of all, add our users
cat <<EOF >> /home/ec2-user/.ssh/authorized_keys
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC6xNacdxR8B4XNjkU/8de/2AjUsjWp1Blo5kVAqNT6pIROJyFlkzHwfqoaStYuyM+RLKaIPaajMG9ZtoOFUQwRvSBJbjjeggrxwKhg31KS/AjGy4I5GPITj35r823yPYo+MSwoN5FG1YD7u3lxWT1E1jU+zGxIjRr5FHKSqgBaz/kgCLzfljX0OBeL/+ZutLltLkE8Otl2ZjMdE04AkTs+QNvIMlJPAxnAMHmyDZ6Djtam0BIpk4wJAgCUc4Wb3yru6GZg3/dev9IB/XyEXE6pBjQNbimMGILzrv5AoBafXhK7L6JDLHxkANmEOBy9R0gTe55fFG2VvWY4HuuNgVO3 devteam@devteam-t470p
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC9jIQlRQ81z1Sjs6hBCS87CsMajkcTMur+uEIFKMocK0XLGLJK+lTLcXalQhPnef4mDBa8xtXDF6yf8mS1aJbWrIejRdbudk/QD24dKPuMTl3BnCf8UjOJgCK/UWWuJC90NI2v759jkFDtIJeqljtfgeEy0bqymdA07BgSANyiBhLSf1hCsoQRXMkeU1COKzT+cKSCG0nTnkoAT5yovAY0BoY/yauiPM+toqZ0fK6lsLaHivgoQzbns7CwUV7VrFqbB1vH/eoE3J1VS6zm0hJE95/+kqBIQjSnOgrSKb2uz6S6msc8633rCWI8k00jImOXDPtHWaWP76+V4zyAeUcL john.paul.retumban
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC3FZwexEsgI7LShGVWPLIvctr89tNvtN+9ndUkXop/PiTao9Fu8ZBJWjDTu6Pmw6rXf4HEy3U0ABbUfwwT8LXZVIrfI/aewt47n3Yjr0jZx1nYDz7wcaochNIiskyj1NdPsja9+obtPZri9Yzv6Ii/gSvMVZXlVDQmZh4uk7qRgi3opRl/l0tr79YGGFBRGKeIezWFgpn7S+bWTMyXiQqifmOmoUbGdJ/nYg/VFy67flsv2Ss9gPmN6hy0GJE6Z+i9/ISyCtELaAP8s+6EOgZ/8ryObFteIeRuUq7e9UbNa2OQhtdp7TKUhvLhMw8oSOXn/qS0zeXlKDUJ3zuU6j6h martin.giess
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDPDbwSPyZEYbBQo+wYJ029Eg2vS3Idg0fxrHhrtaQ+V66VIXO/rUvHuDzE16+85o6gaXAaQp8/afOUmMVs+Vxcev/ssdSPQTxm1lOxkPUUxOwHZSBYeq89zCQ6wTvmhRXNk7iuoQ/QhQrGEjZxkQVdkbObJ16zL6V5PYr/bj4TtrlpkG6IjGUFHVfPG2hzpPMUKcBY/hhpEKV20T3XhbUHK4jn2w/LLMTZIUXHzIQZnhG25nIL7rTWD3BNG+/Vlts5wXQkwrTUIE4B4cMhdLHpbdQ04Q92fjbx6HcHzxD3xbRhyL2K9EUH/N2/UB6pr39YTu7O++sZ3BhNsJPeEaEp michael.garing
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDLmOK0QQQWyv0FjwyxD2oD4A1l7U3mZVkzzHKnDkKH2+jaWn2eTIBEMZSaExZ764cTkz6GLPz1jcw5U0sakN4zcHihWW6f2hwrKHZ6IzNto9n1O88garyErXghgaREPbPV17K4HeX+25jd3hFPX+W7vOY9EnVY6BIDBLmXz+zF1c2eZqAZN8HINsnPltYiVtTrROVYMgqE3drvBU8V/enwvEDP1q0YurWbBqgBKA55y0z9lggF/MBRnUdBK9xlGAWZ60zJpWvffl2rFrvTFKXd+6QeOTnqhufBJxFrh6U8M2/Zz7aDghqU2Qcp7cpX1XoU2cxLzerT1IAxAf5utZF5 michael.lutz
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCXl9geVod65ScW3dfs18Uhnb9Vird36GpPuLmdL2fpVrw5GCfhWU6q+RQktZhFW4IhYMex61d5B1FCmhwoC3jtReFoYySYx1gBKoO86JoPWuLX9dZbVId00HQ/cHEPe1pGhMvQu7Ql3njbntQLGWPmrHJ8+oQmKHkLCtatAY+cNvvaYa6irMFZPNHapY9wGENL7Px3b9zsjHMSNmwPYCvfuZWBWI5NQ3fKKRpn+jWX5lJSj7OjAOs6fKFpnh34Keeg/KEiEy+reCGJU1+aX/+OqOaMmClmEfqggn8UlYOTzXuOR03mNADKfCavNDmXJ7KmSYEE058CHLgfksiwqQxh nikos.loutas
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDyU9ItowY8kg4Y+0vm7g0O7X6LL3AMZI4EVU5O/uUJpYP2J6+UbJS37YLqvsbxqtWAFvCKthJoRSYa/K/YRpUlWvZAbqJkeuvt/gs23TsS9GzwTZME7kDsvVcrJ0L6UmzKyvLGs7Mj+YTXrqTAQePBDmvmsNbwCT3zKHhq31VKL7Ro89NrA7n4kBWA9vVCgg24Vcfg7hA29PmvohkYpEW7lZBUkxTs28/H+1044tvUr20xsj0DXP82WLOhfiIk9nmc5/r6woDl95bfsTKjtJt92osYVqGLe3betb+M67/y7uAVi2Q7PV7Vryhda1TsKlxkL8PsUBGDp8r9tc36/TZ9xD3X3KBttCpdVF+3UIog40JAyHJ67CuLcdHDcQF16y3liXHhYdsC2dyQ58IK3f5O5nAtzI5fjMBo9m2WzhMukDHLMBX1+hCOZBTYCB4rPjOa/IvoJF4FYlkgtBh+BT4uTq/wEl87oh31EoVpuqFpaJJhLvPe6rhL4uxHB2saRXB67RHA66NhMcP8RtN/Z+BeOjOQi/4A0F6ifP5p03DHvgOS1TO66yuHxGQHQTqwKzIgcKLWSu8uuaISLfmtYQhVajdIbClw5hTELHrQ0HjAZCj8+ScQbENWbUmjXOjv++qxfFggvLwloRV+iJNHGGuqoULdxehw2QXhd76npqjkRw== ralph.schaefer
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCvnCH0TXfbF+bRckqITBOEn7n1o/lJSCvMCjP0ov/Xsatf46RiyLHOqihYm98SnjKpBz+RRll/ak9ocFGrBKNol/zEvuC4QLBT1QzuaRrBgdowUYdkJ6qAb00bt6jexoF4WHOy5uYypnsaRYj3Gjr7Q9GZcmP4B7fQ21mflAXWuMt0IRm6v52hmmEykLupJ+Dj+6A9hwrsvR859agGDr0/ZpvPcrmwTYYC3kroXeYEI/pkImrTDfh+rLzlk33PvzFOVvFrh7UXcQR5g4mJHB+aTZOeXMoEB86AtqLprWCfRW3/SN6lQAuDjKPU1fvzEsoQSk28l0iYG/G9OIe5y9wb rolando.hilvano
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDUMVUToVTcxrb1wkF+oMaqWBpmJDZ3xheOt6DsrIVIuniYAJ2md+rPCFlx2TyFFFHigizxFPjUqUs7hbtetjulYNVn0BI4RzwbevW8tud6zLeB/0pG22iLvvmqtXdm2peJRkxN2MqYAM0jG5HREPkNDsMJYrHAuopT66XvZEkcgpP35yxPRtIT5RYnazLNCGBcFeLEJGQyj3QDlZ+KNribfY6XJZX6oj4EEHkMmFbW6PTRvcEpGnOAe/jR9QLRBIcYKVmn0pceQ1BMfk8vYSwwxzz8k8Bzhrma7T+tRZIvz+RJ6Jc4IrxLsir14T2hWNXPuKo3IAdMsAyoVfelpwnN sebastian.schmittssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDdBlq2rvm0x1//77bweCRr63UnCe/EPVkWGjq3fI4Vk steffen.gebert
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDJGZd5gtA5x+Bt3BKU98qEhbN5VrWz5BkGGqIFtCAYDg9IVuJil9SuR2rS26sifLnU2M4g+SMpNpfpAv88oypQCayilDSZ/SOwwHvfKPlg9sTf+wSI+bomMHeen4/Ixcmp2WlVJw/4ws175+0p31XuxhfEa8z9dq7VXD4wFS79RcMOisrNGjHsvi4FVVzXqKWdERSsqhWiQe6eqBlgEw/Ryt27AdNK3pYk+bfR//fb/dwG5YqMye5GpjzG5tutqfhiuwc+iWohYyQWKdrpViZXh+hMUdQV5tmZnEVKd039VuRZOahyG26EE5yIccObkdKwNyYtxYynXDWTWZL0ikUH wolfgang.bauer
EOF

export PATH=/usr/local/bin:$PATH
yum -y --security update

yum -y install jq
easy_install pip
pip install awscli

aws configure set default.region ${aws_region}
echo ECS_CLUSTER=${ecs_cluster} >> /etc/ecs/ecs.config

cat <<EOF > /tmp/awslogs.conf
[general]
state_file = /var/awslogs/state/agent-state

[/var/log/dmesg]
file = /var/log/dmesg
log_group_name = ${cloudwatch_log_group_name}
log_stream_name = %ECS_CLUSTER/%CONTAINER_INSTANCE/var/log/dmesg
initial_position = start_of_file

[/var/log/messages]
file = /var/log/messages
log_group_name = ${cloudwatch_log_group_name}
log_stream_name = %ECS_CLUSTER/%CONTAINER_INSTANCE/var/log/messages
datetime_format = %b %d %H:%M:%S
initial_position = start_of_file

[/var/log/docker]
file = /var/log/docker
log_group_name = ${cloudwatch_log_group_name}
log_stream_name = %ECS_CLUSTER/%CONTAINER_INSTANCE/var/log/docker
datetime_format = %Y-%m-%dT%H:%M:%S.%f
initial_position = start_of_file

[/var/log/ecs/ecs-init.log]
file = /var/log/ecs/ecs-init.log.*
log_group_name = ${cloudwatch_log_group_name}
log_stream_name = %ECS_CLUSTER/%CONTAINER_INSTANCE/var/log/ecs/ecs-init.log
datetime_format = %Y-%m-%dT%H:%M:%SZ
initial_position = start_of_file

[/var/log/ecs/ecs-agent.log]
file = /var/log/ecs/ecs-agent.log.*
log_group_name = ${cloudwatch_log_group_name}
log_stream_name = %ECS_CLUSTER/%CONTAINER_INSTANCE/var/log/ecs/ecs-agent.log
datetime_format = %Y-%m-%dT%H:%M:%SZ
initial_position = start_of_file

[/var/log/ecs/audit.log]
file = /var/log/ecs/audit.log.*
log_group_name = ${cloudwatch_log_group_name}
log_stream_name = %ECS_CLUSTER/%CONTAINER_INSTANCE/var/log/ecs/audit.log
datetime_format = %Y-%m-%dT%H:%M:%SZ
initial_position = start_of_file
EOF

cd /tmp && curl -sO https://s3.amazonaws.com/aws-cloudwatch/downloads/latest/awslogs-agent-setup.py
python /tmp/awslogs-agent-setup.py -n -r ${aws_region} -c /tmp/awslogs.conf

cat <<EOF > /etc/init/cloudwatch-logs-start.conf
description "Configure and start CloudWatch Logs agent on Amazon ECS container instance"
author "Amazon Web Services"
start on started ecs
script
exec 2>>/var/log/cloudwatch-logs-start.log
set -x
until curl -s http://localhost:51678/v1/metadata; do sleep 1; done
ECS_CLUSTER=\$(curl -s http://localhost:51678/v1/metadata | jq .Cluster | tr -d \")
CONTAINER_INSTANCE=\$(curl -s http://localhost:51678/v1/metadata | jq -r ".ContainerInstanceArn" | cut -d/ -f2")
sed -i "s|%ECS_CLUSTER|\$ECS_CLUSTER|g" /var/awslogs/etc/awslogs.conf
sed -i "s|%CONTAINER_INSTANCE|\$CONTAINER_INSTANCE|g" /var/awslogs/etc/awslogs.conf
chkconfig awslogs on
service awslogs start
end script
EOF

cat <<EOF > /etc/init/spot-instance-termination-notice-handler.conf
description "Start spot instance termination handler monitoring script"
author "Amazon Web Services"
start on started ecs
script
echo \$\$ > /var/run/spot-instance-termination-notice-handler.pid
exec /usr/local/bin/spot-instance-termination-notice-handler.sh
end script
pre-start script
logger "[spot-instance-termination-notice-handler.sh]: spot instance termination notice handler started"
end script
EOF

cat <<EOF > /usr/local/bin/spot-instance-termination-notice-handler.sh
#!/bin/bash
while sleep 5; do
if [ -z \$(curl -Isf http://169.254.169.254/latest/meta-data/spot/termination-time)];
then
/bin/false
else
logger "[spot-instance-termination-notice-handler.sh]: spot instance termination notice detected"
STATUS=DRAINING
ECS_CLUSTER=\$(curl -s http://localhost:51678/v1/metadata | jq .Cluster | tr -d \")
CONTAINER_INSTANCE=\$(curl -s http://localhost:51678/v1/metadata | jq .ContainerInstanceArn | tr -d \")
logger "[spot-instance-termination-notice-handler.sh]: putting instance in state \$STATUS"
logger "[spot-instance-termination-notice-handler.sh]: running: /usr/local/bin/aws
ecs update-container-instances-state --cluster \$ECS_CLUSTER --container-instances
\$CONTAINER_INSTANCE --status \$STATUS"
/usr/local/bin/aws ecs update-container-instances-state --cluster \$ECS_CLUSTER
--container-instances \$CONTAINER_INSTANCE --status \$STATUS
logger "[spot-instance-termination-notice-handler.sh]: putting myself to sleep..."
sleep 120
fi
done
EOF

chmod +x /usr/local/bin/spot-instance-termination-notice-handler.sh

yum -y install nfs-utils
cat <<EOF > /usr/local/bin/mount_efs.sh
#!/bin/bash
mkdir -p /mnt/ECSFS
if ! grep "/mnt/ECSFS" /etc/fstab ; then
echo -e "\n${efs_file_system}.efs.${aws_region}.amazonaws.com:/    /mnt/ECSFS   nfs4    defaults,nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2" >> /etc/fstab
mount -a
fi
chown ec2-user:ec2-user /mnt/ECSFS
EOF

chmod +x /usr/local/bin/mount_efs.sh
/usr/local/bin/mount_efs.sh