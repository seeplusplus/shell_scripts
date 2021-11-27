#!/usr/bin/env sh

instance_id=
hosted_id=
domain_name=

function get_status {
    aws ec2 describe-instances --instance-id $instance_id --query 'Reservations[*].Instances[*].State.Name' --output text
}

echo "starting instance: " $instance_id
aws ec2 start-instances --instance-ids $instance_id

status=$(get_status)

while [ $status != 'running' ]; do
    echo 'status: ' $status '... waiting'
    sleep 3
    status=$(get_status)
done

echo "fetching ip"
ip=`aws ec2 describe-instances --instance-id $instance_id --query 'Reservations[*].Instances[*].{Instance:PublicIpAddress}' --output text`
echo "ip fetched: " $ip
# echo "updating route53"
# aws route53 change-resource-record-sets --hosted-zone-id $hosted_id --change-batch '{"Changes": [{"Action": "UPSERT", "'$domain_name'": { "Name": "t.codingthemsoftly.com.", "Type": "A", "TTL": 300, "ResourceRecords": [{"Value": "'$ip'"}]}}]}'
