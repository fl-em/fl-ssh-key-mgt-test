#!/bin/bash
# This script looks for a user named 'support'. If it doesn't (as expected), it will create a user named 'support', create a homedir, and sets it to use bash by default. It will also configure SSH access
# and sudo privileges to 'support'. Furthermore, it also sets up a cron job to dynamically update keys from a GitHub repository for easier user provisioning and deprovisioning.
# Long comments will come first before the actual command. Short comments appear after the command.

# Looks for user named 'support'
id support 

# Checks exit code of previous command. Exit code 1 means ERROR since id did not find a user named support.
if [ $? == 1 ]; then 

# Creates a user named support, -m flag automatically creates a /home directory for the user, and -s flag sets the path to the user's login shell, which is /bin/bash. New user is named "support."
useradd -m -s /bin/bash "support" 

mkdir /home/support/.ssh # Creates SSH directory for user 'support'

# Sends a GET request to the key repository using cURL, then outputs it to 'authorized_keys' file in SSH directory. Now we have public keys of authorized users that can SSH as 'support' user.
curl https://raw.githubusercontent.com/fl-em/fl-ssh-key-mgt-test/refs/heads/main/authorized_keys -o /home/support/.ssh/authorized_keys 

echo 'export PS1="\u@\h:\w\$ "' >> "/home/$username/.bashrc" # Sets the $PS1 variable to display username, hostname, and working directory in the prompt.

chown -R "support:support" "/home/support" # Sets ownership of home direcctory to 'support' recursively.

echo "support ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers # Grants sudo privileges and disables sudo password authentication to 'support'.

# Cron job to update SSH key store. Runs every minute, but if we hit GitHub's API limits, we can set it to 5-15 minutes later on.
echo "* * * * * support curl https://raw.githubusercontent.com/fl-em/fl-ssh-key-mgt-test/refs/heads/main/authorized_keys -o /home/support/.ssh/authorized_keys" >> /etc/crontab 

else # If exit code of 'id support' returns a value other than 1, it still provisions SSH access and sudo privileges for 'support' user

mkdir /home/support/.ssh # See line 15
curl https://raw.githubusercontent.com/fl-em/fl-ssh-key-mgt-test/refs/heads/main/authorized_keys -o /home/support/.ssh/authorized_keys # See line 18
chown -R "support:support" "/home/support" # See line 22
echo "support ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers # See line 24
echo "* * * * * support curl https://raw.githubusercontent.com/fl-em/fl-ssh-key-mgt-test/refs/heads/main/authorized_keys -o /home/support/.ssh/authorized_keys" >> /etc/crontab # See line 27
fi # Closes IF statement
