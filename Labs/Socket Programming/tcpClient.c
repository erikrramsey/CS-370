// CS 370
// Example socket client

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/socket.h>
#include <sys/types.h>
#include <netinet/in.h>
#include <arpa/inet.h>

#define PORT 10000

int main(){

	int	clientSocket, ret;
	struct	sockaddr_in serverAddr;
	char	buffer[1024];
	char	dashes[62];

	memset(dashes, '-', 60);
	dashes[60] = '\n';
	dashes[61] = 0;

	clientSocket = socket(AF_INET, SOCK_STREAM, 0);
	if(clientSocket < 0) {
		printf("[-]Error in connection (1).\n");
		exit(1);
	}

	printf("[+]Client Socket is created.\n");
	printf("[+]Type ':exit' to terminate client.\n");

	memset(&serverAddr, '\0', sizeof(serverAddr));
	serverAddr.sin_family = AF_INET;
	serverAddr.sin_port = htons(PORT);
	serverAddr.sin_addr.s_addr = inet_addr("127.0.0.1");

	ret = connect(clientSocket, (struct sockaddr*)&serverAddr, sizeof(serverAddr));
	if(ret < 0) {
		printf("[-]Error in connection (2).\n");
		exit(1);
	}
	printf("[+]Connected to Server.\n\n");

	while(1) {
		printf("%s", dashes);
		printf("Client Message (':exit' to terminate):  ");
		bzero(buffer, sizeof(buffer));

		fgets(buffer, sizeof(buffer), stdin);
		strtok(buffer,"\n");

		send(clientSocket, buffer, strlen(buffer), 0);

		if (strcmp(buffer, ":exit") == 0) {
			close(clientSocket);
			printf("[-]Disconnected from server.\n");
			break;
		}

		if (recv(clientSocket, buffer, 1224, 0) < 0) {
			printf("[-]Error in receiving data.\n");
		} else {
			printf("\nFrom Server: \t%s\n", buffer);
		}
	}

	return 0;
}

