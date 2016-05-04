CFLAGS=-Wall -Wextra -fPIC
LDFLAGS=-lpam

all: $(CURDIR)/pam_docker.so $(CURDIR)/stamp

$(CURDIR)/pam_docker.so: $(CURDIR)/pam_docker.o
	gcc -shared -o $(CURDIR)/pam_docker.so $(CURDIR)/pam_docker.o $(LDFLAGS)

$(CURDIR)/pam_docker.o: $(CURDIR)/pam_docker.c
	gcc -c $(CURDIR)/pam_docker.c $(CFLAGS) -o $(CURDIR)/pam_docker.o

$(CURDIR)/stamp:
	touch $(CURDIR)/stamp

clean:
	rm -rf $(CURDIR)/stamp $(CURDIR)/pam_docker.o $(CURDIR)/pam_docker.so

install: $(CURDIR)/pam_docker.so
	install -d $(DESTDIR)
	install -m 644 $(CURDIR)/pam_docker.so $(DESTDIR)

pam-auth-update:
	install -d $(DESTDIR)/usr/share/pam-configs/
	install -m 644 $(CURDIR)/config/pam_auth_update.conf $(DESTDIR)/usr/share/pam-configs/docker
	pam-auth-update --package

.PHONY: all clean install uninstall
