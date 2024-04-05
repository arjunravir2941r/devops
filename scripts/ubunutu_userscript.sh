#!/bin/bash

# Update the system package list
apt update -y

# Upgrade the installed packages to their latest versions
apt upgrade -y

# Install Java 17 JDK
# Ubuntu might not have Java 17 in its default repositories depending on the version you are using.
# You might need to add a PPA or use a different method to install Java 17.
# For the sake of generality, this script assumes Java 17 can be installed directly.
apt install -y openjdk-17-jdk

# Verify Java installation
java -version

# Create new user t6admin and add to sudo group (Ubuntu uses the sudo group instead of wheel)
useradd -m t6admin -s /bin/bash
usermod -aG sudo t6admin
echo 't6admin ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers.d/t6admin
chmod 0440 /etc/sudoers.d/t6admin

# Ensure SSH directory exists for t6admin
mkdir -p /home/t6admin/.ssh
chmod 700 /home/t6admin/.ssh
chown t6admin:t6admin /home/t6admin/.ssh

# Add authorized_keys for SSH access with the provided keys
cat <<EOF > /home/t6admin/.ssh/authorized_keys
key1
key2
EOF

# Set the correct permissions for the authorized_keys file
chmod 600 /home/t6admin/.ssh/authorized_keys

# Change ownership of the .ssh directory and its contents to t6admin
chown -R t6admin:t6admin /home/t6admin/.ssh
