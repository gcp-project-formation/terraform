ansible-galaxy install -r requirements.yml
ansible-playbook -i $1, --private-key ../.ssh/redis_ssh tasks.yaml -e "redis_bind_interface=0.0.0.0 user_hostname=$2"
