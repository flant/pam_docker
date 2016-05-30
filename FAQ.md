# FAQ

## 1. Which distributions are supported?
* Ubuntu 12.04
* Ubuntu 14.04
* Ubuntu 16.04
* Debian 7
* Debian 8
* CentOS 7

You can build your package as well (more details are available in the "Building" section of *README* file).

## 2. Which Docker versions are supported?
It was tested with Docker 1.9, 1.10 and 1.11 for all the Linux distributions supported.

## 3. What will happen if container is not running?
Users assigned to this container won't be able to log in until the container is running. They will get a "container not running" (if it exists and is stopped) or “container not found” error.

## 4. What will happen if Docker is not running?
All users (and users of all groups) assigned to containers according to */etc/security/docker.conf* won't be able to log in. They will get a "failed to connect to docker socket” error.

## 5. Can I install the SSH (cron, FTP, etc…) service into the container instead of the host system? Is it possible for user to enter the neighboring container?

Yes! You need to start container with its own SSH service and some special options. Container should be run:
1. in privileged mode (*--privileged*) to make *setns* system call available (it requires *CAP_SYS_ADMIN* and *CAP_SYS_CHROOT*);
2. with PID space of the host system (*--pid host*) to be able to identify neighboring container's namespace;
3. with */sys/fs/cgroup* available in container (*-v /sys/fs/cgroup:/sys/fs/cgroup*) to be able to assign cgroups.
