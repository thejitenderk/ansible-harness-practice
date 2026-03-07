#!/bin/bash
set -e

echo "Starting Ansible deployment..."

# Move to repo
cd <+execution.steps.ansible.steps.ansiblerepoclone.spec.repoName>

echo "Repository directory:"
pwd
ls -la

# Install Python dependencies
if [ -f requirements.txt ]; then
  echo "Installing Python dependencies..."
  pip install --upgrade pip
  pip install -r requirements.txt
else
  echo "No requirements.txt found, skipping pip install"
fi

# Install Ansible collections
if [ -f requirements.yml ]; then
  echo "Installing Ansible collections..."
  ansible-galaxy collection install -r requirements.yml
else
  echo "No requirements.yml found, skipping..."
fi

echo "Running inventory validation..."

ansible-inventory \
  -i <+stage.variables.hosts_file> \
  --list

echo "Running sanity connectivity check..."

ANSIBLE_HOST_KEY_CHECKING=False \
ansible-playbook playbooks/sanity.yml -vvv \
  -i <+stage.variables.hosts_file> \
  -l <+stage.variables.hosts_group> \
  -e "ansible_user=<+execution.steps.Set_ENV.output.outputVariables.ansible_user> \
      ansible_password=<+execution.steps.Set_ENV.output.outputVariables.ansible_password> \
      ansible_connection=winrm \
      ansible_winrm_transport=ntlm \
      ansible_winrm_port=5985 \
      ansible_winrm_scheme=http"

echo "Running Ansible Lint..."

if command -v ansible-lint &> /dev/null; then
  ansible-lint playbooks/
else
  echo "ansible-lint not installed, skipping..."
fi

echo "Running playbook in CHECK MODE..."

ANSIBLE_HOST_KEY_CHECKING=False \
ansible-playbook playbooks/<+stage.variables.playbook> -vvv \
  -i <+stage.variables.hosts_file> \
  -l <+stage.variables.hosts_group> \
  -e "ansible_user=<+execution.steps.Set_ENV.output.outputVariables.ansible_user> \
      ansible_password=<+execution.steps.Set_ENV.output.outputVariables.ansible_password> \
      ansible_connection=winrm \
      ansible_winrm_transport=ntlm \
      ansible_winrm_port=5985 \
      ansible_winrm_scheme=http" \
  --check

echo "Running actual deployment..."

ANSIBLE_HOST_KEY_CHECKING=False \
ansible-playbook playbooks/<+stage.variables.playbook> -vvv \
  -i <+stage.variables.hosts_file> \
  -l <+stage.variables.hosts_group> \
  -e "ansible_user=<+execution.steps.Set_ENV.output.outputVariables.ansible_user> \
      ansible_password=<+execution.steps.Set_ENV.output.outputVariables.ansible_password> \
      ansible_connection=winrm \
      ansible_winrm_transport=ntlm \
      ansible_winrm_port=5985 \
      ansible_winrm_scheme=http"

echo "Deployment completed successfully."