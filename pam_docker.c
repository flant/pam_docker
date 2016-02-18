/* vim: set sts=4 ts=4 sw=4: */

#define PAM_SM_SESSION

#include <stdlib.h>
#include <unistd.h>
#include <syslog.h>
#include <stdio.h>
#include <string.h>
#include <sys/socket.h>
#include <sys/un.h>
#include <security/pam_modules.h>
#include <security/pam_ext.h>

#ifndef PAM_DOCKER_SOCK
#define PAM_DOCKER_SOCK "/var/run/docker.sock"
#endif

#ifndef PAM_DOCKER_SECURITY_CONF
#define PAM_DOCKER_SECURITY_CONF "/etc/security/docker.conf"
#endif

#define PAM_DOCKER_STRINGIZE(x) #x
#define PAM_DOCKER_NAME_MAX_SIZE 256
#define PAM_DOCKER_ID_SIZE 64

static int docker_container_of_user(pam_handle_t* pamh, const char* username,
                                    char* docker_container, size_t docker_container_size) {
    (void)pamh;
    (void)username;

    snprintf(docker_container, docker_container_size, "mycontainer");

    return 0;
}

static int pid_and_id_of_docker_container(pam_handle_t* pamh, const char* docker_container,
                                          pid_t* docker_pid_p, char* docker_id) {
    int rc;
    int sock;
    struct sockaddr_un server;
    static const char* docker_sock = PAM_DOCKER_SOCK;
    char message[256];
    char* response = NULL;

    sock = socket(AF_UNIX, SOCK_STREAM, 0);
    if(sock < 0) {
        pam_syslog(pamh, LOG_ERR, "failed to create AF_UNIX socket");
        goto error;
    }

    server.sun_family = AF_UNIX;
    strncpy(server.sun_path, docker_sock, sizeof(server.sun_path));
    rc = connect(sock, (struct sockaddr *) &server, sizeof(struct sockaddr_un));
    if(rc < 0) {
        pam_syslog(pamh, LOG_ERR, "failed to connect to docker socket %s", docker_sock);
        goto request_error;
    }

    snprintf(message, sizeof(message), "GET /containers/%s/json HTTP/1.0\r\n\r\n", docker_container);
    rc = write(sock, message, strlen(message));
    if(rc < 0) {
        pam_syslog(pamh, LOG_ERR, "failed to send message to docker socket %s", docker_sock);
        goto request_error;
    }

    {
        size_t response_read_size = 0;
        int n;
        char* match;
        char fmt[32];
        static const size_t response_read_chunk = 4096;
        static const char* http_404_search = "HTTP/1.0 404";
        static const char* http_ok_search = "HTTP/1.0 200";
        static const char* pid_search = "\"Pid\":";
        static const char* id_search = "\"Id\":\"";

        do {
            response = realloc(response, response_read_size + response_read_chunk);
            if(!response) {goto request_error;}

            n = read(sock, response + response_read_size, response_read_chunk);
            if(n < 0) {goto response_error;}

            response_read_size += n;
        } while(n != 0);
        response[response_read_size + 1] = 0;

        if(strstr(response, http_404_search) == response) {
            pam_syslog(pamh, LOG_ERR, "docker container '%s' not found", docker_container);
            goto response_error;
        } else if (strstr(response, http_ok_search) != response) {
            pam_syslog(pamh, LOG_ERR, "non 200 docker api http answer");
            goto response_error;
        }

        match = strstr(response, pid_search);
        if(!match || (sscanf(match + strlen(pid_search), "%d", docker_pid_p) != 1)) {
            pam_syslog(pamh, LOG_ERR, "failed to parse State.Pid from answer");
            goto response_error;
        } else if(*docker_pid_p == 0) {
            pam_syslog(pamh, LOG_ERR, "container '%s' not running", docker_container);
            goto response_error;
        }

        match = strstr(response, id_search);
        snprintf(fmt, sizeof(fmt), "%%%ds", PAM_DOCKER_ID_SIZE);
        if(!match || sscanf(match + strlen(id_search), fmt, docker_id) != 1) {
            pam_syslog(pamh, LOG_ERR, "failed to parse Id from answer");
            goto response_error;
        }
    }

    free(response);
    close(sock);
    return 0;

response_error:
    free(response);
request_error:
    close(sock);
error:
    return 1;
}

PAM_EXTERN int pam_sm_open_session(pam_handle_t* pamh, int flags, int argc, const char** argv) {
    (void)pamh;
    (void)flags;
    (void)argc;
    (void)argv;

    char * username;
    char docker_container[PAM_DOCKER_NAME_MAX_SIZE];
    char docker_id[PAM_DOCKER_ID_SIZE + 1];
    pid_t docker_pid;
    int rc;

    rc = pam_get_user(pamh, (const char **)(&username), NULL);
    if(rc != PAM_SUCCESS) {
        pam_syslog(pamh, LOG_ERR, "cannot fetch user name");
        return PAM_SESSION_ERR;
    }

    rc = docker_container_of_user(pamh, username, docker_container, sizeof(docker_container));
    if(rc != 0) {
        pam_syslog(pamh, LOG_ERR, "cannot determine docker container of user '%s'", username);
        return PAM_SESSION_ERR;
    }

    rc = pid_and_id_of_docker_container(pamh, docker_container, &docker_pid, docker_id);
    if(rc != 0) {
        pam_syslog(pamh, LOG_ERR, "cannot determine pid and id of docker container '%s'", docker_container);
        return PAM_SESSION_ERR;
    }

    pam_syslog(
        pamh, LOG_DEBUG, "open docker session for user '%s' in container '%s' (pid: %ld, id: %s)",
        username, docker_container, (long)docker_pid, docker_id
    );

    return PAM_SUCCESS;
}

PAM_EXTERN int pam_sm_close_session(pam_handle_t* pamh, int flags, int argc, const char** argv) {
    (void)pamh;
    (void)flags;
    (void)argc;
    (void)argv;

    char * username;
    pam_get_user(pamh, (const char **)(&username), NULL);
    pam_syslog(pamh, LOG_DEBUG, "close session for user '%s'", username);

    return PAM_SUCCESS;
}
