#define PAM_SM_SESSION

#include <stdlib.h>
#include <unistd.h>
#include <syslog.h>
#include <stdio.h>
#include <string.h>

#include <security/pam_modules.h>
#include <security/pam_ext.h>

#ifndef PAM_DOCKER_SOCK
#define PAM_DOCKER_SOCK "/var/run/docker.sock"
#endif

PAM_EXTERN int pam_sm_open_session(pam_handle_t * pamh, int flags, int argc, const char ** argv) {
    (void)pamh;
    (void)flags;
    (void)argc;
    (void)argv;

    char * username;
    pam_get_user(pamh, (const char **)(&username), NULL);
    pam_syslog(pamh, LOG_DEBUG, "open session for user '%s'", username);

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
