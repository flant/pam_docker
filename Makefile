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
	@rm -rf $(CURDIR)/stamp $(CURDIR)/pam_docker.o $(CURDIR)/pam_docker.so

install: $(CURDIR)/pam_docker.so
	install -d $(DESTDIR)/lib/security
	install -d $(DESTDIR)/usr/share/pam-configs/
	install -o root -g root -m 644 $(CURDIR)/pam_docker.so $(DESTDIR)/lib/security
	install -o root -g root $(CURDIR)/config/docker $(DESTDIR)/usr/share/pam-configs/

uninstall:
	rm $(DESTDIR)/lib/security/pam_docker.so
	rm $(DESTDIR)/usr/share/pam-configs/docker

.PHONY: all clean install uninstall
