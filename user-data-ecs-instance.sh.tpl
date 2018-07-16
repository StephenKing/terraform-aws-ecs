#!/bin/bash

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