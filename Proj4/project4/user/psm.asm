
user/_psm:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <print_proc>:
    }

    exit(0);
}

void print_proc(struct ps_proc* pr) {
   0:	1141                	addi	sp,sp,-16
   2:	e406                	sd	ra,8(sp)
   4:	e022                	sd	s0,0(sp)
   6:	0800                	addi	s0,sp,16
   8:	87aa                	mv	a5,a0
    char* state;
    switch (pr->state) {
   a:	4914                	lw	a3,16(a0)
   c:	4715                	li	a4,5
   e:	04d76f63          	bltu	a4,a3,6c <print_proc+0x6c>
  12:	01056703          	lwu	a4,16(a0)
  16:	070a                	slli	a4,a4,0x2
  18:	00001697          	auipc	a3,0x1
  1c:	9a468693          	addi	a3,a3,-1628 # 9bc <malloc+0x1e8>
  20:	9736                	add	a4,a4,a3
  22:	4318                	lw	a4,0(a4)
  24:	9736                	add	a4,a4,a3
  26:	8702                	jr	a4
  28:	00001617          	auipc	a2,0x1
  2c:	8d860613          	addi	a2,a2,-1832 # 900 <malloc+0x12c>
        default:
            state = "ERROR";
            break;
    }

    printf("%d       %s%d     %d   %s", pr->pid, state, pr->priority, pr->memory, pr->name);
  30:	7398                	ld	a4,32(a5)
  32:	4f94                	lw	a3,24(a5)
  34:	4bcc                	lw	a1,20(a5)
  36:	00001517          	auipc	a0,0x1
  3a:	8da50513          	addi	a0,a0,-1830 # 910 <malloc+0x13c>
  3e:	00000097          	auipc	ra,0x0
  42:	6d8080e7          	jalr	1752(ra) # 716 <printf>
}
  46:	60a2                	ld	ra,8(sp)
  48:	6402                	ld	s0,0(sp)
  4a:	0141                	addi	sp,sp,16
  4c:	8082                	ret
            state = "RUNANBLE  ";
  4e:	00001617          	auipc	a2,0x1
  52:	88260613          	addi	a2,a2,-1918 # 8d0 <malloc+0xfc>
            break;
  56:	bfe9                	j	30 <print_proc+0x30>
            state = "RUNNING   ";
  58:	00001617          	auipc	a2,0x1
  5c:	88860613          	addi	a2,a2,-1912 # 8e0 <malloc+0x10c>
            break;
  60:	bfc1                	j	30 <print_proc+0x30>
            state = "ZOMBIE    ";
  62:	00001617          	auipc	a2,0x1
  66:	88e60613          	addi	a2,a2,-1906 # 8f0 <malloc+0x11c>
            break;
  6a:	b7d9                	j	30 <print_proc+0x30>
            state = "ERROR";
  6c:	00001617          	auipc	a2,0x1
  70:	84c60613          	addi	a2,a2,-1972 # 8b8 <malloc+0xe4>
            break;
  74:	bf75                	j	30 <print_proc+0x30>
            state = "USED      ";
  76:	00001617          	auipc	a2,0x1
  7a:	84a60613          	addi	a2,a2,-1974 # 8c0 <malloc+0xec>
  7e:	bf4d                	j	30 <print_proc+0x30>

0000000000000080 <main>:
int main(int argc, char** argv) {
  80:	7179                	addi	sp,sp,-48
  82:	f406                	sd	ra,40(sp)
  84:	f022                	sd	s0,32(sp)
  86:	ec26                	sd	s1,24(sp)
  88:	e84a                	sd	s2,16(sp)
  8a:	e44e                	sd	s3,8(sp)
  8c:	1800                	addi	s0,sp,48
    struct ps_proc* procs = malloc(sizeof(struct ps_proc) * 15);
  8e:	25800513          	li	a0,600
  92:	00000097          	auipc	ra,0x0
  96:	742080e7          	jalr	1858(ra) # 7d4 <malloc>
  9a:	89aa                	mv	s3,a0
    int total = ps(procs);
  9c:	00000097          	auipc	ra,0x0
  a0:	39a080e7          	jalr	922(ra) # 436 <ps>
  a4:	892a                	mv	s2,a0
    printf("Process Status\n");
  a6:	00001517          	auipc	a0,0x1
  aa:	88a50513          	addi	a0,a0,-1910 # 930 <malloc+0x15c>
  ae:	00000097          	auipc	ra,0x0
  b2:	668080e7          	jalr	1640(ra) # 716 <printf>
    printf("%s\n%s\n", header, div);
  b6:	00001617          	auipc	a2,0x1
  ba:	88a60613          	addi	a2,a2,-1910 # 940 <malloc+0x16c>
  be:	00001597          	auipc	a1,0x1
  c2:	8ba58593          	addi	a1,a1,-1862 # 978 <malloc+0x1a4>
  c6:	00001517          	auipc	a0,0x1
  ca:	8ea50513          	addi	a0,a0,-1814 # 9b0 <malloc+0x1dc>
  ce:	00000097          	auipc	ra,0x0
  d2:	648080e7          	jalr	1608(ra) # 716 <printf>
    for (int i = 0; i < total; i++) {
  d6:	05205063          	blez	s2,116 <main+0x96>
  da:	84ce                	mv	s1,s3
  dc:	397d                	addiw	s2,s2,-1
  de:	02091793          	slli	a5,s2,0x20
  e2:	9381                	srli	a5,a5,0x20
  e4:	00279913          	slli	s2,a5,0x2
  e8:	993e                	add	s2,s2,a5
  ea:	090e                	slli	s2,s2,0x3
  ec:	02898993          	addi	s3,s3,40
  f0:	994e                	add	s2,s2,s3
        printf("\n");
  f2:	00001997          	auipc	s3,0x1
  f6:	8c698993          	addi	s3,s3,-1850 # 9b8 <malloc+0x1e4>
        print_proc(&procs[i]);
  fa:	8526                	mv	a0,s1
  fc:	00000097          	auipc	ra,0x0
 100:	f04080e7          	jalr	-252(ra) # 0 <print_proc>
        printf("\n");
 104:	854e                	mv	a0,s3
 106:	00000097          	auipc	ra,0x0
 10a:	610080e7          	jalr	1552(ra) # 716 <printf>
    for (int i = 0; i < total; i++) {
 10e:	02848493          	addi	s1,s1,40
 112:	ff2494e3          	bne	s1,s2,fa <main+0x7a>
    exit(0);
 116:	4501                	li	a0,0
 118:	00000097          	auipc	ra,0x0
 11c:	27e080e7          	jalr	638(ra) # 396 <exit>

0000000000000120 <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
 120:	1141                	addi	sp,sp,-16
 122:	e422                	sd	s0,8(sp)
 124:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 126:	87aa                	mv	a5,a0
 128:	0585                	addi	a1,a1,1
 12a:	0785                	addi	a5,a5,1
 12c:	fff5c703          	lbu	a4,-1(a1)
 130:	fee78fa3          	sb	a4,-1(a5)
 134:	fb75                	bnez	a4,128 <strcpy+0x8>
    ;
  return os;
}
 136:	6422                	ld	s0,8(sp)
 138:	0141                	addi	sp,sp,16
 13a:	8082                	ret

000000000000013c <strcmp>:

int
strcmp(const char *p, const char *q)
{
 13c:	1141                	addi	sp,sp,-16
 13e:	e422                	sd	s0,8(sp)
 140:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 142:	00054783          	lbu	a5,0(a0)
 146:	cb91                	beqz	a5,15a <strcmp+0x1e>
 148:	0005c703          	lbu	a4,0(a1)
 14c:	00f71763          	bne	a4,a5,15a <strcmp+0x1e>
    p++, q++;
 150:	0505                	addi	a0,a0,1
 152:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 154:	00054783          	lbu	a5,0(a0)
 158:	fbe5                	bnez	a5,148 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 15a:	0005c503          	lbu	a0,0(a1)
}
 15e:	40a7853b          	subw	a0,a5,a0
 162:	6422                	ld	s0,8(sp)
 164:	0141                	addi	sp,sp,16
 166:	8082                	ret

0000000000000168 <strlen>:

uint
strlen(const char *s)
{
 168:	1141                	addi	sp,sp,-16
 16a:	e422                	sd	s0,8(sp)
 16c:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 16e:	00054783          	lbu	a5,0(a0)
 172:	cf91                	beqz	a5,18e <strlen+0x26>
 174:	0505                	addi	a0,a0,1
 176:	87aa                	mv	a5,a0
 178:	4685                	li	a3,1
 17a:	9e89                	subw	a3,a3,a0
 17c:	00f6853b          	addw	a0,a3,a5
 180:	0785                	addi	a5,a5,1
 182:	fff7c703          	lbu	a4,-1(a5)
 186:	fb7d                	bnez	a4,17c <strlen+0x14>
    ;
  return n;
}
 188:	6422                	ld	s0,8(sp)
 18a:	0141                	addi	sp,sp,16
 18c:	8082                	ret
  for(n = 0; s[n]; n++)
 18e:	4501                	li	a0,0
 190:	bfe5                	j	188 <strlen+0x20>

0000000000000192 <memset>:

void*
memset(void *dst, int c, uint n)
{
 192:	1141                	addi	sp,sp,-16
 194:	e422                	sd	s0,8(sp)
 196:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 198:	ce09                	beqz	a2,1b2 <memset+0x20>
 19a:	87aa                	mv	a5,a0
 19c:	fff6071b          	addiw	a4,a2,-1
 1a0:	1702                	slli	a4,a4,0x20
 1a2:	9301                	srli	a4,a4,0x20
 1a4:	0705                	addi	a4,a4,1
 1a6:	972a                	add	a4,a4,a0
    cdst[i] = c;
 1a8:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 1ac:	0785                	addi	a5,a5,1
 1ae:	fee79de3          	bne	a5,a4,1a8 <memset+0x16>
  }
  return dst;
}
 1b2:	6422                	ld	s0,8(sp)
 1b4:	0141                	addi	sp,sp,16
 1b6:	8082                	ret

00000000000001b8 <strchr>:

char*
strchr(const char *s, char c)
{
 1b8:	1141                	addi	sp,sp,-16
 1ba:	e422                	sd	s0,8(sp)
 1bc:	0800                	addi	s0,sp,16
  for(; *s; s++)
 1be:	00054783          	lbu	a5,0(a0)
 1c2:	cb99                	beqz	a5,1d8 <strchr+0x20>
    if(*s == c)
 1c4:	00f58763          	beq	a1,a5,1d2 <strchr+0x1a>
  for(; *s; s++)
 1c8:	0505                	addi	a0,a0,1
 1ca:	00054783          	lbu	a5,0(a0)
 1ce:	fbfd                	bnez	a5,1c4 <strchr+0xc>
      return (char*)s;
  return 0;
 1d0:	4501                	li	a0,0
}
 1d2:	6422                	ld	s0,8(sp)
 1d4:	0141                	addi	sp,sp,16
 1d6:	8082                	ret
  return 0;
 1d8:	4501                	li	a0,0
 1da:	bfe5                	j	1d2 <strchr+0x1a>

00000000000001dc <gets>:

char*
gets(char *buf, int max)
{
 1dc:	711d                	addi	sp,sp,-96
 1de:	ec86                	sd	ra,88(sp)
 1e0:	e8a2                	sd	s0,80(sp)
 1e2:	e4a6                	sd	s1,72(sp)
 1e4:	e0ca                	sd	s2,64(sp)
 1e6:	fc4e                	sd	s3,56(sp)
 1e8:	f852                	sd	s4,48(sp)
 1ea:	f456                	sd	s5,40(sp)
 1ec:	f05a                	sd	s6,32(sp)
 1ee:	ec5e                	sd	s7,24(sp)
 1f0:	1080                	addi	s0,sp,96
 1f2:	8baa                	mv	s7,a0
 1f4:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1f6:	892a                	mv	s2,a0
 1f8:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 1fa:	4aa9                	li	s5,10
 1fc:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 1fe:	89a6                	mv	s3,s1
 200:	2485                	addiw	s1,s1,1
 202:	0344d863          	bge	s1,s4,232 <gets+0x56>
    cc = read(0, &c, 1);
 206:	4605                	li	a2,1
 208:	faf40593          	addi	a1,s0,-81
 20c:	4501                	li	a0,0
 20e:	00000097          	auipc	ra,0x0
 212:	1a0080e7          	jalr	416(ra) # 3ae <read>
    if(cc < 1)
 216:	00a05e63          	blez	a0,232 <gets+0x56>
    buf[i++] = c;
 21a:	faf44783          	lbu	a5,-81(s0)
 21e:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 222:	01578763          	beq	a5,s5,230 <gets+0x54>
 226:	0905                	addi	s2,s2,1
 228:	fd679be3          	bne	a5,s6,1fe <gets+0x22>
  for(i=0; i+1 < max; ){
 22c:	89a6                	mv	s3,s1
 22e:	a011                	j	232 <gets+0x56>
 230:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 232:	99de                	add	s3,s3,s7
 234:	00098023          	sb	zero,0(s3)
  return buf;
}
 238:	855e                	mv	a0,s7
 23a:	60e6                	ld	ra,88(sp)
 23c:	6446                	ld	s0,80(sp)
 23e:	64a6                	ld	s1,72(sp)
 240:	6906                	ld	s2,64(sp)
 242:	79e2                	ld	s3,56(sp)
 244:	7a42                	ld	s4,48(sp)
 246:	7aa2                	ld	s5,40(sp)
 248:	7b02                	ld	s6,32(sp)
 24a:	6be2                	ld	s7,24(sp)
 24c:	6125                	addi	sp,sp,96
 24e:	8082                	ret

0000000000000250 <stat>:

int
stat(const char *n, struct stat *st)
{
 250:	1101                	addi	sp,sp,-32
 252:	ec06                	sd	ra,24(sp)
 254:	e822                	sd	s0,16(sp)
 256:	e426                	sd	s1,8(sp)
 258:	e04a                	sd	s2,0(sp)
 25a:	1000                	addi	s0,sp,32
 25c:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 25e:	4581                	li	a1,0
 260:	00000097          	auipc	ra,0x0
 264:	176080e7          	jalr	374(ra) # 3d6 <open>
  if(fd < 0)
 268:	02054563          	bltz	a0,292 <stat+0x42>
 26c:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 26e:	85ca                	mv	a1,s2
 270:	00000097          	auipc	ra,0x0
 274:	17e080e7          	jalr	382(ra) # 3ee <fstat>
 278:	892a                	mv	s2,a0
  close(fd);
 27a:	8526                	mv	a0,s1
 27c:	00000097          	auipc	ra,0x0
 280:	142080e7          	jalr	322(ra) # 3be <close>
  return r;
}
 284:	854a                	mv	a0,s2
 286:	60e2                	ld	ra,24(sp)
 288:	6442                	ld	s0,16(sp)
 28a:	64a2                	ld	s1,8(sp)
 28c:	6902                	ld	s2,0(sp)
 28e:	6105                	addi	sp,sp,32
 290:	8082                	ret
    return -1;
 292:	597d                	li	s2,-1
 294:	bfc5                	j	284 <stat+0x34>

0000000000000296 <atoi>:

int
atoi(const char *s)
{
 296:	1141                	addi	sp,sp,-16
 298:	e422                	sd	s0,8(sp)
 29a:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 29c:	00054603          	lbu	a2,0(a0)
 2a0:	fd06079b          	addiw	a5,a2,-48
 2a4:	0ff7f793          	andi	a5,a5,255
 2a8:	4725                	li	a4,9
 2aa:	02f76963          	bltu	a4,a5,2dc <atoi+0x46>
 2ae:	86aa                	mv	a3,a0
  n = 0;
 2b0:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 2b2:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 2b4:	0685                	addi	a3,a3,1
 2b6:	0025179b          	slliw	a5,a0,0x2
 2ba:	9fa9                	addw	a5,a5,a0
 2bc:	0017979b          	slliw	a5,a5,0x1
 2c0:	9fb1                	addw	a5,a5,a2
 2c2:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 2c6:	0006c603          	lbu	a2,0(a3)
 2ca:	fd06071b          	addiw	a4,a2,-48
 2ce:	0ff77713          	andi	a4,a4,255
 2d2:	fee5f1e3          	bgeu	a1,a4,2b4 <atoi+0x1e>
  return n;
}
 2d6:	6422                	ld	s0,8(sp)
 2d8:	0141                	addi	sp,sp,16
 2da:	8082                	ret
  n = 0;
 2dc:	4501                	li	a0,0
 2de:	bfe5                	j	2d6 <atoi+0x40>

00000000000002e0 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 2e0:	1141                	addi	sp,sp,-16
 2e2:	e422                	sd	s0,8(sp)
 2e4:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 2e6:	02b57663          	bgeu	a0,a1,312 <memmove+0x32>
    while(n-- > 0)
 2ea:	02c05163          	blez	a2,30c <memmove+0x2c>
 2ee:	fff6079b          	addiw	a5,a2,-1
 2f2:	1782                	slli	a5,a5,0x20
 2f4:	9381                	srli	a5,a5,0x20
 2f6:	0785                	addi	a5,a5,1
 2f8:	97aa                	add	a5,a5,a0
  dst = vdst;
 2fa:	872a                	mv	a4,a0
      *dst++ = *src++;
 2fc:	0585                	addi	a1,a1,1
 2fe:	0705                	addi	a4,a4,1
 300:	fff5c683          	lbu	a3,-1(a1)
 304:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 308:	fee79ae3          	bne	a5,a4,2fc <memmove+0x1c>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 30c:	6422                	ld	s0,8(sp)
 30e:	0141                	addi	sp,sp,16
 310:	8082                	ret
    dst += n;
 312:	00c50733          	add	a4,a0,a2
    src += n;
 316:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 318:	fec05ae3          	blez	a2,30c <memmove+0x2c>
 31c:	fff6079b          	addiw	a5,a2,-1
 320:	1782                	slli	a5,a5,0x20
 322:	9381                	srli	a5,a5,0x20
 324:	fff7c793          	not	a5,a5
 328:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 32a:	15fd                	addi	a1,a1,-1
 32c:	177d                	addi	a4,a4,-1
 32e:	0005c683          	lbu	a3,0(a1)
 332:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 336:	fee79ae3          	bne	a5,a4,32a <memmove+0x4a>
 33a:	bfc9                	j	30c <memmove+0x2c>

000000000000033c <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 33c:	1141                	addi	sp,sp,-16
 33e:	e422                	sd	s0,8(sp)
 340:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 342:	ca05                	beqz	a2,372 <memcmp+0x36>
 344:	fff6069b          	addiw	a3,a2,-1
 348:	1682                	slli	a3,a3,0x20
 34a:	9281                	srli	a3,a3,0x20
 34c:	0685                	addi	a3,a3,1
 34e:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 350:	00054783          	lbu	a5,0(a0)
 354:	0005c703          	lbu	a4,0(a1)
 358:	00e79863          	bne	a5,a4,368 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 35c:	0505                	addi	a0,a0,1
    p2++;
 35e:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 360:	fed518e3          	bne	a0,a3,350 <memcmp+0x14>
  }
  return 0;
 364:	4501                	li	a0,0
 366:	a019                	j	36c <memcmp+0x30>
      return *p1 - *p2;
 368:	40e7853b          	subw	a0,a5,a4
}
 36c:	6422                	ld	s0,8(sp)
 36e:	0141                	addi	sp,sp,16
 370:	8082                	ret
  return 0;
 372:	4501                	li	a0,0
 374:	bfe5                	j	36c <memcmp+0x30>

0000000000000376 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 376:	1141                	addi	sp,sp,-16
 378:	e406                	sd	ra,8(sp)
 37a:	e022                	sd	s0,0(sp)
 37c:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 37e:	00000097          	auipc	ra,0x0
 382:	f62080e7          	jalr	-158(ra) # 2e0 <memmove>
}
 386:	60a2                	ld	ra,8(sp)
 388:	6402                	ld	s0,0(sp)
 38a:	0141                	addi	sp,sp,16
 38c:	8082                	ret

000000000000038e <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 38e:	4885                	li	a7,1
 ecall
 390:	00000073          	ecall
 ret
 394:	8082                	ret

0000000000000396 <exit>:
.global exit
exit:
 li a7, SYS_exit
 396:	4889                	li	a7,2
 ecall
 398:	00000073          	ecall
 ret
 39c:	8082                	ret

000000000000039e <wait>:
.global wait
wait:
 li a7, SYS_wait
 39e:	488d                	li	a7,3
 ecall
 3a0:	00000073          	ecall
 ret
 3a4:	8082                	ret

00000000000003a6 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 3a6:	4891                	li	a7,4
 ecall
 3a8:	00000073          	ecall
 ret
 3ac:	8082                	ret

00000000000003ae <read>:
.global read
read:
 li a7, SYS_read
 3ae:	4895                	li	a7,5
 ecall
 3b0:	00000073          	ecall
 ret
 3b4:	8082                	ret

00000000000003b6 <write>:
.global write
write:
 li a7, SYS_write
 3b6:	48c1                	li	a7,16
 ecall
 3b8:	00000073          	ecall
 ret
 3bc:	8082                	ret

00000000000003be <close>:
.global close
close:
 li a7, SYS_close
 3be:	48d5                	li	a7,21
 ecall
 3c0:	00000073          	ecall
 ret
 3c4:	8082                	ret

00000000000003c6 <kill>:
.global kill
kill:
 li a7, SYS_kill
 3c6:	4899                	li	a7,6
 ecall
 3c8:	00000073          	ecall
 ret
 3cc:	8082                	ret

00000000000003ce <exec>:
.global exec
exec:
 li a7, SYS_exec
 3ce:	489d                	li	a7,7
 ecall
 3d0:	00000073          	ecall
 ret
 3d4:	8082                	ret

00000000000003d6 <open>:
.global open
open:
 li a7, SYS_open
 3d6:	48bd                	li	a7,15
 ecall
 3d8:	00000073          	ecall
 ret
 3dc:	8082                	ret

00000000000003de <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 3de:	48c5                	li	a7,17
 ecall
 3e0:	00000073          	ecall
 ret
 3e4:	8082                	ret

00000000000003e6 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 3e6:	48c9                	li	a7,18
 ecall
 3e8:	00000073          	ecall
 ret
 3ec:	8082                	ret

00000000000003ee <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 3ee:	48a1                	li	a7,8
 ecall
 3f0:	00000073          	ecall
 ret
 3f4:	8082                	ret

00000000000003f6 <link>:
.global link
link:
 li a7, SYS_link
 3f6:	48cd                	li	a7,19
 ecall
 3f8:	00000073          	ecall
 ret
 3fc:	8082                	ret

00000000000003fe <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 3fe:	48d1                	li	a7,20
 ecall
 400:	00000073          	ecall
 ret
 404:	8082                	ret

0000000000000406 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 406:	48a5                	li	a7,9
 ecall
 408:	00000073          	ecall
 ret
 40c:	8082                	ret

000000000000040e <dup>:
.global dup
dup:
 li a7, SYS_dup
 40e:	48a9                	li	a7,10
 ecall
 410:	00000073          	ecall
 ret
 414:	8082                	ret

0000000000000416 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 416:	48ad                	li	a7,11
 ecall
 418:	00000073          	ecall
 ret
 41c:	8082                	ret

000000000000041e <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 41e:	48b1                	li	a7,12
 ecall
 420:	00000073          	ecall
 ret
 424:	8082                	ret

0000000000000426 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 426:	48b5                	li	a7,13
 ecall
 428:	00000073          	ecall
 ret
 42c:	8082                	ret

000000000000042e <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 42e:	48b9                	li	a7,14
 ecall
 430:	00000073          	ecall
 ret
 434:	8082                	ret

0000000000000436 <ps>:
.global ps
ps:
 li a7, SYS_ps
 436:	48d9                	li	a7,22
 ecall
 438:	00000073          	ecall
 ret
 43c:	8082                	ret

000000000000043e <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 43e:	1101                	addi	sp,sp,-32
 440:	ec06                	sd	ra,24(sp)
 442:	e822                	sd	s0,16(sp)
 444:	1000                	addi	s0,sp,32
 446:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 44a:	4605                	li	a2,1
 44c:	fef40593          	addi	a1,s0,-17
 450:	00000097          	auipc	ra,0x0
 454:	f66080e7          	jalr	-154(ra) # 3b6 <write>
}
 458:	60e2                	ld	ra,24(sp)
 45a:	6442                	ld	s0,16(sp)
 45c:	6105                	addi	sp,sp,32
 45e:	8082                	ret

0000000000000460 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 460:	7139                	addi	sp,sp,-64
 462:	fc06                	sd	ra,56(sp)
 464:	f822                	sd	s0,48(sp)
 466:	f426                	sd	s1,40(sp)
 468:	f04a                	sd	s2,32(sp)
 46a:	ec4e                	sd	s3,24(sp)
 46c:	0080                	addi	s0,sp,64
 46e:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 470:	c299                	beqz	a3,476 <printint+0x16>
 472:	0805c863          	bltz	a1,502 <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 476:	2581                	sext.w	a1,a1
  neg = 0;
 478:	4881                	li	a7,0
 47a:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 47e:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 480:	2601                	sext.w	a2,a2
 482:	00000517          	auipc	a0,0x0
 486:	55e50513          	addi	a0,a0,1374 # 9e0 <digits>
 48a:	883a                	mv	a6,a4
 48c:	2705                	addiw	a4,a4,1
 48e:	02c5f7bb          	remuw	a5,a1,a2
 492:	1782                	slli	a5,a5,0x20
 494:	9381                	srli	a5,a5,0x20
 496:	97aa                	add	a5,a5,a0
 498:	0007c783          	lbu	a5,0(a5)
 49c:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 4a0:	0005879b          	sext.w	a5,a1
 4a4:	02c5d5bb          	divuw	a1,a1,a2
 4a8:	0685                	addi	a3,a3,1
 4aa:	fec7f0e3          	bgeu	a5,a2,48a <printint+0x2a>
  if(neg)
 4ae:	00088b63          	beqz	a7,4c4 <printint+0x64>
    buf[i++] = '-';
 4b2:	fd040793          	addi	a5,s0,-48
 4b6:	973e                	add	a4,a4,a5
 4b8:	02d00793          	li	a5,45
 4bc:	fef70823          	sb	a5,-16(a4)
 4c0:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 4c4:	02e05863          	blez	a4,4f4 <printint+0x94>
 4c8:	fc040793          	addi	a5,s0,-64
 4cc:	00e78933          	add	s2,a5,a4
 4d0:	fff78993          	addi	s3,a5,-1
 4d4:	99ba                	add	s3,s3,a4
 4d6:	377d                	addiw	a4,a4,-1
 4d8:	1702                	slli	a4,a4,0x20
 4da:	9301                	srli	a4,a4,0x20
 4dc:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 4e0:	fff94583          	lbu	a1,-1(s2)
 4e4:	8526                	mv	a0,s1
 4e6:	00000097          	auipc	ra,0x0
 4ea:	f58080e7          	jalr	-168(ra) # 43e <putc>
  while(--i >= 0)
 4ee:	197d                	addi	s2,s2,-1
 4f0:	ff3918e3          	bne	s2,s3,4e0 <printint+0x80>
}
 4f4:	70e2                	ld	ra,56(sp)
 4f6:	7442                	ld	s0,48(sp)
 4f8:	74a2                	ld	s1,40(sp)
 4fa:	7902                	ld	s2,32(sp)
 4fc:	69e2                	ld	s3,24(sp)
 4fe:	6121                	addi	sp,sp,64
 500:	8082                	ret
    x = -xx;
 502:	40b005bb          	negw	a1,a1
    neg = 1;
 506:	4885                	li	a7,1
    x = -xx;
 508:	bf8d                	j	47a <printint+0x1a>

000000000000050a <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 50a:	7119                	addi	sp,sp,-128
 50c:	fc86                	sd	ra,120(sp)
 50e:	f8a2                	sd	s0,112(sp)
 510:	f4a6                	sd	s1,104(sp)
 512:	f0ca                	sd	s2,96(sp)
 514:	ecce                	sd	s3,88(sp)
 516:	e8d2                	sd	s4,80(sp)
 518:	e4d6                	sd	s5,72(sp)
 51a:	e0da                	sd	s6,64(sp)
 51c:	fc5e                	sd	s7,56(sp)
 51e:	f862                	sd	s8,48(sp)
 520:	f466                	sd	s9,40(sp)
 522:	f06a                	sd	s10,32(sp)
 524:	ec6e                	sd	s11,24(sp)
 526:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 528:	0005c903          	lbu	s2,0(a1)
 52c:	18090f63          	beqz	s2,6ca <vprintf+0x1c0>
 530:	8aaa                	mv	s5,a0
 532:	8b32                	mv	s6,a2
 534:	00158493          	addi	s1,a1,1
  state = 0;
 538:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 53a:	02500a13          	li	s4,37
      if(c == 'd'){
 53e:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 542:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 546:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 54a:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 54e:	00000b97          	auipc	s7,0x0
 552:	492b8b93          	addi	s7,s7,1170 # 9e0 <digits>
 556:	a839                	j	574 <vprintf+0x6a>
        putc(fd, c);
 558:	85ca                	mv	a1,s2
 55a:	8556                	mv	a0,s5
 55c:	00000097          	auipc	ra,0x0
 560:	ee2080e7          	jalr	-286(ra) # 43e <putc>
 564:	a019                	j	56a <vprintf+0x60>
    } else if(state == '%'){
 566:	01498f63          	beq	s3,s4,584 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 56a:	0485                	addi	s1,s1,1
 56c:	fff4c903          	lbu	s2,-1(s1)
 570:	14090d63          	beqz	s2,6ca <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 574:	0009079b          	sext.w	a5,s2
    if(state == 0){
 578:	fe0997e3          	bnez	s3,566 <vprintf+0x5c>
      if(c == '%'){
 57c:	fd479ee3          	bne	a5,s4,558 <vprintf+0x4e>
        state = '%';
 580:	89be                	mv	s3,a5
 582:	b7e5                	j	56a <vprintf+0x60>
      if(c == 'd'){
 584:	05878063          	beq	a5,s8,5c4 <vprintf+0xba>
      } else if(c == 'l') {
 588:	05978c63          	beq	a5,s9,5e0 <vprintf+0xd6>
      } else if(c == 'x') {
 58c:	07a78863          	beq	a5,s10,5fc <vprintf+0xf2>
      } else if(c == 'p') {
 590:	09b78463          	beq	a5,s11,618 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 594:	07300713          	li	a4,115
 598:	0ce78663          	beq	a5,a4,664 <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 59c:	06300713          	li	a4,99
 5a0:	0ee78e63          	beq	a5,a4,69c <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 5a4:	11478863          	beq	a5,s4,6b4 <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 5a8:	85d2                	mv	a1,s4
 5aa:	8556                	mv	a0,s5
 5ac:	00000097          	auipc	ra,0x0
 5b0:	e92080e7          	jalr	-366(ra) # 43e <putc>
        putc(fd, c);
 5b4:	85ca                	mv	a1,s2
 5b6:	8556                	mv	a0,s5
 5b8:	00000097          	auipc	ra,0x0
 5bc:	e86080e7          	jalr	-378(ra) # 43e <putc>
      }
      state = 0;
 5c0:	4981                	li	s3,0
 5c2:	b765                	j	56a <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 5c4:	008b0913          	addi	s2,s6,8
 5c8:	4685                	li	a3,1
 5ca:	4629                	li	a2,10
 5cc:	000b2583          	lw	a1,0(s6)
 5d0:	8556                	mv	a0,s5
 5d2:	00000097          	auipc	ra,0x0
 5d6:	e8e080e7          	jalr	-370(ra) # 460 <printint>
 5da:	8b4a                	mv	s6,s2
      state = 0;
 5dc:	4981                	li	s3,0
 5de:	b771                	j	56a <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 5e0:	008b0913          	addi	s2,s6,8
 5e4:	4681                	li	a3,0
 5e6:	4629                	li	a2,10
 5e8:	000b2583          	lw	a1,0(s6)
 5ec:	8556                	mv	a0,s5
 5ee:	00000097          	auipc	ra,0x0
 5f2:	e72080e7          	jalr	-398(ra) # 460 <printint>
 5f6:	8b4a                	mv	s6,s2
      state = 0;
 5f8:	4981                	li	s3,0
 5fa:	bf85                	j	56a <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 5fc:	008b0913          	addi	s2,s6,8
 600:	4681                	li	a3,0
 602:	4641                	li	a2,16
 604:	000b2583          	lw	a1,0(s6)
 608:	8556                	mv	a0,s5
 60a:	00000097          	auipc	ra,0x0
 60e:	e56080e7          	jalr	-426(ra) # 460 <printint>
 612:	8b4a                	mv	s6,s2
      state = 0;
 614:	4981                	li	s3,0
 616:	bf91                	j	56a <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 618:	008b0793          	addi	a5,s6,8
 61c:	f8f43423          	sd	a5,-120(s0)
 620:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 624:	03000593          	li	a1,48
 628:	8556                	mv	a0,s5
 62a:	00000097          	auipc	ra,0x0
 62e:	e14080e7          	jalr	-492(ra) # 43e <putc>
  putc(fd, 'x');
 632:	85ea                	mv	a1,s10
 634:	8556                	mv	a0,s5
 636:	00000097          	auipc	ra,0x0
 63a:	e08080e7          	jalr	-504(ra) # 43e <putc>
 63e:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 640:	03c9d793          	srli	a5,s3,0x3c
 644:	97de                	add	a5,a5,s7
 646:	0007c583          	lbu	a1,0(a5)
 64a:	8556                	mv	a0,s5
 64c:	00000097          	auipc	ra,0x0
 650:	df2080e7          	jalr	-526(ra) # 43e <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 654:	0992                	slli	s3,s3,0x4
 656:	397d                	addiw	s2,s2,-1
 658:	fe0914e3          	bnez	s2,640 <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 65c:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 660:	4981                	li	s3,0
 662:	b721                	j	56a <vprintf+0x60>
        s = va_arg(ap, char*);
 664:	008b0993          	addi	s3,s6,8
 668:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 66c:	02090163          	beqz	s2,68e <vprintf+0x184>
        while(*s != 0){
 670:	00094583          	lbu	a1,0(s2)
 674:	c9a1                	beqz	a1,6c4 <vprintf+0x1ba>
          putc(fd, *s);
 676:	8556                	mv	a0,s5
 678:	00000097          	auipc	ra,0x0
 67c:	dc6080e7          	jalr	-570(ra) # 43e <putc>
          s++;
 680:	0905                	addi	s2,s2,1
        while(*s != 0){
 682:	00094583          	lbu	a1,0(s2)
 686:	f9e5                	bnez	a1,676 <vprintf+0x16c>
        s = va_arg(ap, char*);
 688:	8b4e                	mv	s6,s3
      state = 0;
 68a:	4981                	li	s3,0
 68c:	bdf9                	j	56a <vprintf+0x60>
          s = "(null)";
 68e:	00000917          	auipc	s2,0x0
 692:	34a90913          	addi	s2,s2,842 # 9d8 <malloc+0x204>
        while(*s != 0){
 696:	02800593          	li	a1,40
 69a:	bff1                	j	676 <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 69c:	008b0913          	addi	s2,s6,8
 6a0:	000b4583          	lbu	a1,0(s6)
 6a4:	8556                	mv	a0,s5
 6a6:	00000097          	auipc	ra,0x0
 6aa:	d98080e7          	jalr	-616(ra) # 43e <putc>
 6ae:	8b4a                	mv	s6,s2
      state = 0;
 6b0:	4981                	li	s3,0
 6b2:	bd65                	j	56a <vprintf+0x60>
        putc(fd, c);
 6b4:	85d2                	mv	a1,s4
 6b6:	8556                	mv	a0,s5
 6b8:	00000097          	auipc	ra,0x0
 6bc:	d86080e7          	jalr	-634(ra) # 43e <putc>
      state = 0;
 6c0:	4981                	li	s3,0
 6c2:	b565                	j	56a <vprintf+0x60>
        s = va_arg(ap, char*);
 6c4:	8b4e                	mv	s6,s3
      state = 0;
 6c6:	4981                	li	s3,0
 6c8:	b54d                	j	56a <vprintf+0x60>
    }
  }
}
 6ca:	70e6                	ld	ra,120(sp)
 6cc:	7446                	ld	s0,112(sp)
 6ce:	74a6                	ld	s1,104(sp)
 6d0:	7906                	ld	s2,96(sp)
 6d2:	69e6                	ld	s3,88(sp)
 6d4:	6a46                	ld	s4,80(sp)
 6d6:	6aa6                	ld	s5,72(sp)
 6d8:	6b06                	ld	s6,64(sp)
 6da:	7be2                	ld	s7,56(sp)
 6dc:	7c42                	ld	s8,48(sp)
 6de:	7ca2                	ld	s9,40(sp)
 6e0:	7d02                	ld	s10,32(sp)
 6e2:	6de2                	ld	s11,24(sp)
 6e4:	6109                	addi	sp,sp,128
 6e6:	8082                	ret

00000000000006e8 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 6e8:	715d                	addi	sp,sp,-80
 6ea:	ec06                	sd	ra,24(sp)
 6ec:	e822                	sd	s0,16(sp)
 6ee:	1000                	addi	s0,sp,32
 6f0:	e010                	sd	a2,0(s0)
 6f2:	e414                	sd	a3,8(s0)
 6f4:	e818                	sd	a4,16(s0)
 6f6:	ec1c                	sd	a5,24(s0)
 6f8:	03043023          	sd	a6,32(s0)
 6fc:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 700:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 704:	8622                	mv	a2,s0
 706:	00000097          	auipc	ra,0x0
 70a:	e04080e7          	jalr	-508(ra) # 50a <vprintf>
}
 70e:	60e2                	ld	ra,24(sp)
 710:	6442                	ld	s0,16(sp)
 712:	6161                	addi	sp,sp,80
 714:	8082                	ret

0000000000000716 <printf>:

void
printf(const char *fmt, ...)
{
 716:	711d                	addi	sp,sp,-96
 718:	ec06                	sd	ra,24(sp)
 71a:	e822                	sd	s0,16(sp)
 71c:	1000                	addi	s0,sp,32
 71e:	e40c                	sd	a1,8(s0)
 720:	e810                	sd	a2,16(s0)
 722:	ec14                	sd	a3,24(s0)
 724:	f018                	sd	a4,32(s0)
 726:	f41c                	sd	a5,40(s0)
 728:	03043823          	sd	a6,48(s0)
 72c:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 730:	00840613          	addi	a2,s0,8
 734:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 738:	85aa                	mv	a1,a0
 73a:	4505                	li	a0,1
 73c:	00000097          	auipc	ra,0x0
 740:	dce080e7          	jalr	-562(ra) # 50a <vprintf>
}
 744:	60e2                	ld	ra,24(sp)
 746:	6442                	ld	s0,16(sp)
 748:	6125                	addi	sp,sp,96
 74a:	8082                	ret

000000000000074c <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 74c:	1141                	addi	sp,sp,-16
 74e:	e422                	sd	s0,8(sp)
 750:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 752:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 756:	00000797          	auipc	a5,0x0
 75a:	2a27b783          	ld	a5,674(a5) # 9f8 <freep>
 75e:	a805                	j	78e <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 760:	4618                	lw	a4,8(a2)
 762:	9db9                	addw	a1,a1,a4
 764:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 768:	6398                	ld	a4,0(a5)
 76a:	6318                	ld	a4,0(a4)
 76c:	fee53823          	sd	a4,-16(a0)
 770:	a091                	j	7b4 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 772:	ff852703          	lw	a4,-8(a0)
 776:	9e39                	addw	a2,a2,a4
 778:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 77a:	ff053703          	ld	a4,-16(a0)
 77e:	e398                	sd	a4,0(a5)
 780:	a099                	j	7c6 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 782:	6398                	ld	a4,0(a5)
 784:	00e7e463          	bltu	a5,a4,78c <free+0x40>
 788:	00e6ea63          	bltu	a3,a4,79c <free+0x50>
{
 78c:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 78e:	fed7fae3          	bgeu	a5,a3,782 <free+0x36>
 792:	6398                	ld	a4,0(a5)
 794:	00e6e463          	bltu	a3,a4,79c <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 798:	fee7eae3          	bltu	a5,a4,78c <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 79c:	ff852583          	lw	a1,-8(a0)
 7a0:	6390                	ld	a2,0(a5)
 7a2:	02059713          	slli	a4,a1,0x20
 7a6:	9301                	srli	a4,a4,0x20
 7a8:	0712                	slli	a4,a4,0x4
 7aa:	9736                	add	a4,a4,a3
 7ac:	fae60ae3          	beq	a2,a4,760 <free+0x14>
    bp->s.ptr = p->s.ptr;
 7b0:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 7b4:	4790                	lw	a2,8(a5)
 7b6:	02061713          	slli	a4,a2,0x20
 7ba:	9301                	srli	a4,a4,0x20
 7bc:	0712                	slli	a4,a4,0x4
 7be:	973e                	add	a4,a4,a5
 7c0:	fae689e3          	beq	a3,a4,772 <free+0x26>
  } else
    p->s.ptr = bp;
 7c4:	e394                	sd	a3,0(a5)
  freep = p;
 7c6:	00000717          	auipc	a4,0x0
 7ca:	22f73923          	sd	a5,562(a4) # 9f8 <freep>
}
 7ce:	6422                	ld	s0,8(sp)
 7d0:	0141                	addi	sp,sp,16
 7d2:	8082                	ret

00000000000007d4 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 7d4:	7139                	addi	sp,sp,-64
 7d6:	fc06                	sd	ra,56(sp)
 7d8:	f822                	sd	s0,48(sp)
 7da:	f426                	sd	s1,40(sp)
 7dc:	f04a                	sd	s2,32(sp)
 7de:	ec4e                	sd	s3,24(sp)
 7e0:	e852                	sd	s4,16(sp)
 7e2:	e456                	sd	s5,8(sp)
 7e4:	e05a                	sd	s6,0(sp)
 7e6:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 7e8:	02051493          	slli	s1,a0,0x20
 7ec:	9081                	srli	s1,s1,0x20
 7ee:	04bd                	addi	s1,s1,15
 7f0:	8091                	srli	s1,s1,0x4
 7f2:	0014899b          	addiw	s3,s1,1
 7f6:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 7f8:	00000517          	auipc	a0,0x0
 7fc:	20053503          	ld	a0,512(a0) # 9f8 <freep>
 800:	c515                	beqz	a0,82c <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 802:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 804:	4798                	lw	a4,8(a5)
 806:	02977f63          	bgeu	a4,s1,844 <malloc+0x70>
 80a:	8a4e                	mv	s4,s3
 80c:	0009871b          	sext.w	a4,s3
 810:	6685                	lui	a3,0x1
 812:	00d77363          	bgeu	a4,a3,818 <malloc+0x44>
 816:	6a05                	lui	s4,0x1
 818:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 81c:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 820:	00000917          	auipc	s2,0x0
 824:	1d890913          	addi	s2,s2,472 # 9f8 <freep>
  if(p == (char*)-1)
 828:	5afd                	li	s5,-1
 82a:	a88d                	j	89c <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
 82c:	00000797          	auipc	a5,0x0
 830:	1d478793          	addi	a5,a5,468 # a00 <base>
 834:	00000717          	auipc	a4,0x0
 838:	1cf73223          	sd	a5,452(a4) # 9f8 <freep>
 83c:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 83e:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 842:	b7e1                	j	80a <malloc+0x36>
      if(p->s.size == nunits)
 844:	02e48b63          	beq	s1,a4,87a <malloc+0xa6>
        p->s.size -= nunits;
 848:	4137073b          	subw	a4,a4,s3
 84c:	c798                	sw	a4,8(a5)
        p += p->s.size;
 84e:	1702                	slli	a4,a4,0x20
 850:	9301                	srli	a4,a4,0x20
 852:	0712                	slli	a4,a4,0x4
 854:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 856:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 85a:	00000717          	auipc	a4,0x0
 85e:	18a73f23          	sd	a0,414(a4) # 9f8 <freep>
      return (void*)(p + 1);
 862:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 866:	70e2                	ld	ra,56(sp)
 868:	7442                	ld	s0,48(sp)
 86a:	74a2                	ld	s1,40(sp)
 86c:	7902                	ld	s2,32(sp)
 86e:	69e2                	ld	s3,24(sp)
 870:	6a42                	ld	s4,16(sp)
 872:	6aa2                	ld	s5,8(sp)
 874:	6b02                	ld	s6,0(sp)
 876:	6121                	addi	sp,sp,64
 878:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 87a:	6398                	ld	a4,0(a5)
 87c:	e118                	sd	a4,0(a0)
 87e:	bff1                	j	85a <malloc+0x86>
  hp->s.size = nu;
 880:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 884:	0541                	addi	a0,a0,16
 886:	00000097          	auipc	ra,0x0
 88a:	ec6080e7          	jalr	-314(ra) # 74c <free>
  return freep;
 88e:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 892:	d971                	beqz	a0,866 <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 894:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 896:	4798                	lw	a4,8(a5)
 898:	fa9776e3          	bgeu	a4,s1,844 <malloc+0x70>
    if(p == freep)
 89c:	00093703          	ld	a4,0(s2)
 8a0:	853e                	mv	a0,a5
 8a2:	fef719e3          	bne	a4,a5,894 <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
 8a6:	8552                	mv	a0,s4
 8a8:	00000097          	auipc	ra,0x0
 8ac:	b76080e7          	jalr	-1162(ra) # 41e <sbrk>
  if(p == (char*)-1)
 8b0:	fd5518e3          	bne	a0,s5,880 <malloc+0xac>
        return 0;
 8b4:	4501                	li	a0,0
 8b6:	bf45                	j	866 <malloc+0x92>
