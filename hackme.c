

#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#define SECRET "admin"

void unreachable_function(int amount) {
  printf("sending %d dollar to your bank account, congratz!", amount);
}

int main(int argc, char ** argv) {

  if (argc != 2) {
    fprintf(stderr, "usage: ./hackme <password>\n");
    exit(EXIT_FAILURE);
  }

  if (!strcmp(argv[1], SECRET)) {
    puts("welcome admin!");
  } else {
    puts("fuck off");
  }

  return 0;
}
