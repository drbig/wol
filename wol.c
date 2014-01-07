/* WakeOnLan in C.
 * 2014-01-07
 * dRbiG
 */

char *mackeys[] = {
  "bebop.l", "gamer.l", "lore.l",
  "nox.l", "rpi.l" };

char *macvals[] = {
  "70:5A:B6:94:8F:59", "00:25:22:f4:0b:0e", "00:40:ca:6d:16:07",
  "00:40:63:D5:8B:65", "B8:27:EB:0D:EB:01" };

const char *brdip = "192.168.0.255";

#include <arpa/inet.h>
#include <netinet/in.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/socket.h>

const int maclen = sizeof(mackeys) / sizeof(char*);
unsigned char *payload;

int getidx(char *key) {
  int i;

  for (i = 0; i < maclen; i++)
    if (strcmp(mackeys[i], key) == 0)
      return i;

  return -1;
}

int makepayload(char *mac) {
  int i, c, x;

  if (strlen(mac) != 17)
    return -1;

  for (i = 0; i < 6; i++)
    if (sscanf(mac+3*i, "%2X", &x) != 1)
      return -1;
    for (c = 0; c < 16; c++)
      payload[6*c+6+i] = (unsigned char)x;

  return 0;
}

int main(int argc, char *argv[]) {
  struct sockaddr_in target;
  char *addr;
  int i, c, sock;

  payload = malloc(sizeof(unsigned char) * 102);
  memset(payload, 255, 6);

  sock = socket(AF_INET, SOCK_DGRAM, 0);
  i = 1;
  setsockopt(sock, SOL_SOCKET, SO_BROADCAST, &i, sizeof(int));

  bzero(&target, sizeof(target));
  target.sin_family = AF_INET;
  target.sin_addr.s_addr = inet_addr(brdip);
  target.sin_port = htons(9);

  for (i = 1; i < argc; i++) {
    if ((c = getidx(argv[i])) != -1)
      addr = macvals[c];
    else
      addr = argv[i];

    if (makepayload(addr) != 0)
      printf("%s: parse error!\n", argv[i]);
    else
      for (c = 0; c < 3; c++)
        sendto(sock, payload, 102, 0, (struct sockaddr *)&target, sizeof(target));
  }

  free(payload);

  return 0;
}
