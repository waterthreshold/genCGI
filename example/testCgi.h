#ifndef _TEST_CGI_H
#define _TEST_CGI_H

#include "shared_lib_httpd.h"
int getTestCgiMain(char *value, int bufSize);
STATUS setTestCgiMain(char *content, int out);
#endif
