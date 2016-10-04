# Description
pam_docker is a module for putting host's users inside Docker containers via PAM. It is an easy way of providing SSH access to containers' users and simplifying a lot of other things.

Here you can find a brief documentation for its features and limitations as well as instructions on how to use it, install it (we have packages for Ubuntu/Debian & CentOS), build it from sources or try with minimal efforts (using Vagrant image). Enjoy!

# Usage with OpenSSH and other services
pam_docker is a PAM (Pluggable Authentication Modules for UNIX-like systems) module that allows you to assign system users (or groups) to Docker containers. As a user is assigned to container, (s)he will enter the corresponding container just after logging in to the system. Other important thing is that all of user's processes will start inside this container.

Using PAM system makes a lot of things easy:
* **SSH / login**. Thanks to OpenSSH supporting PAM by default (check *UsePAM* in *man sshd_config* for details), assigning user to container will bring this user into container's isolated environment by means of regular SSH login.
* **su / sudo**. These services work with PAM, so using them will also bring user inside appropriate container.
* **cron**. Vixie cron supports PAM, so user's crontab tasks (from the host system) will be executed inside appropriate container.
* **FTP**. ProfFTPD (as well as other FTP servers) also supports PAM (it is enabled by default, check *AuthPAM* in *proftpd.conf* for details). User's FTP connections will start inside container as well.

# Install
All you need in Ubuntu / Debian or CentOS is to add a repository and install the *pam_docker* package. Other Linux distributions lovers are very welcome to build it from sources (look for the "Building" section below) and/or to make their own packages.

## 1. Ubuntu & Debian
```
curl -s https://packagecloud.io/install/repositories/flant/pam_docker/script.deb.sh | sudo bash
sudo apt-get install pam-docker
```

## 2. CentOS
```
curl -s https://packagecloud.io/install/repositories/flant/pam_docker/script.rpm.sh | sudo bash
sudo yum install pam_docker
```

# Configuration
## 1. Setup your PAM
### 1.1. Ubuntu и Debian
Do nothing and enjoy: PAM module will be enabled automatically when the package is installed. Of course, it will be disabled when the package is uninstalled.

### 1.2. CentOS
Please edit your */etc/pam.d/system-auth* by adding to its end (just after the ```session     required      pam_unix.so``` line):
```
session    required    pam_docker.so
```
#### Enable for sudo
Add this line to the end of */etc/pam.d/sudo* (sudo in CentOS 7 doesn't use system-auth by default):
```
session     include     system-auth
```
#### Enable for ssh
Add this line to the end of */etc/pam.d/sshd* (ssh in CentOS 7 doesn't use system-auth by default):
```
session     include     system-auth
```

## 2. Add system user
System user and all of user's groups should be added **both to host and container**. UIDs and GIDs should be the same (at the host and the container).

## 3. Assign users to containers
To assign user *username* or group *groupname* to container *docker_container_name* just add a line into your */etc/security/docker.conf* file:
* Assigning user:
```
username docker_container_name
```
* Assigning group:
```
@groupname docker_container_name
```
**Warning!** *pam_docker* will parse this file from top to the bottom until it finds the first matching user/group. Each user/group can be assigned to one container only.

# Building
If you use another distribution or don't want to use our repository, you are welcome to build *pam_docker* on your own. Here are brief instructions for different systems:

## 1. Ubuntu / Debian
```
sudo apt-get install build-essential libpam0g-dev
make
DESTDIR=/lib/security/ sudo make install
sudo make pam-auth-update
```

## 2. CentOS
```
sudo yum install make gcc pam-devel
make
DESTDIR=/lib64/security/ sudo make install
```

# Try it using Vagrant
To catch a glimpse of *pam_docker*, you can simply use Vagrant:
```
git clone https://github.com/flant/pam_docker.git
vagrant up
vagrant ssh
sudo -i
```

This virtual machine is configured and ready for tests: it has some containers, users & groups. More details are available in *Vagrantfile*.

# Technical limitations
1. Currently, *pam_docker* doesn't use *runc* (previously it was known as *libcontainer*) to enter Docker containers. The actions required for that are done "manually": adding process to cgroups with following *setns* system calls. That's why it can be broken (i.e. should be modified) if Docker changes the steps required to enter container.
2. To get Docker container's ID and its root process' PID, *pam_docker* uses Docker's UNIX socket in the *PAM_DOCKER_SOCK* path (this constant is defined at the compilation stage). Changing the socket's path (after pam_docker is compiled) and working with Docker via TCP (HTTP) is not supported.
3. Docker's API uses JSON. However, our effort to make pam_docker's dependencies minimal led to its own, very simple JSON parser used to find *Id* and *Pid* keywords in the JSON data returned by Docker.

# Contacts & feedback
*pam_docker* was originally made by [Dmitry Stolyarov](https://github.com/distol) & [Timofey Kirillov](https://github.com/distorhead) from [Flant](http://flant.com/).

We encourage and welcome any feedback via issues and/or pull requests to pam_docker's upstream at https://github.com/flant/pam_docker
