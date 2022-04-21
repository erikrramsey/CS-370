
user/_forktest:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <print>:

#define N  1000

void
print(const char *s)
{
   0:	1101                	addi	sp,sp,-32
   2:	ec06                	sd	ra,24(sp)
   4:	e822                	sd	s0,16(sp)
   6:	e426                	sd	s1,8(sp)
   8:	1000                	addi	s0,sp,32
   a:	84aa                	mv	s1,a0
  write(1, s, strlen(s));
   c:	00000097          	auipc	ra,0x0
  10:	15a080e7          	jalr	346(ra) # 166 <strlen>
  14:	0005061b          	sext.w	a2,a0
  18:	85a6                	mv	a1,s1
  1a:	4505                	li	a0,1
  1c:	00000097          	auipc	ra,0x0
  20:	398080e7          	jalr	920(ra) # 3b4 <write>
}
  24:	60e2                	ld	ra,24(sp)
  26:	6442                	ld	s0,16(sp)
  28:	64a2                	ld	s1,8(sp)
  2a:	6105                	addi	sp,sp,32
  2c:	8082                	ret

000000000000002e <forktest>:

void
forktest(void)
{
  2e:	1101                	addi	sp,sp,-32
  30:	ec06                	sd	ra,24(sp)
  32:	e822                	sd	s0,16(sp)
  34:	e426                	sd	s1,8(sp)
  36:	e04a                	sd	s2,0(sp)
  38:	1000                	addi	s0,sp,32
  int n, pid;

  print("fork test\n");
  3a:	00000517          	auipc	a0,0x0
  3e:	40650513          	addi	a0,a0,1030 # 440 <ps+0xc>
  42:	00000097          	auipc	ra,0x0
  46:	fbe080e7          	jalr	-66(ra) # 0 <print>

  for(n=0; n<N; n++){
  4a:	4481                	li	s1,0
  4c:	3e800913          	li	s2,1000
    pid = fork();
  50:	00000097          	auipc	ra,0x0
  54:	33c080e7          	jalr	828(ra) # 38c <fork>
    if(pid < 0)
  58:	02054763          	bltz	a0,86 <forktest+0x58>
      break;
    if(pid == 0)
  5c:	c10d                	beqz	a0,7e <forktest+0x50>
  for(n=0; n<N; n++){
  5e:	2485                	addiw	s1,s1,1
  60:	ff2498e3          	bne	s1,s2,50 <forktest+0x22>
      exit(0);
  }

  if(n == N){
    print("fork claimed to work N times!\n");
  64:	00000517          	auipc	a0,0x0
  68:	3ec50513          	addi	a0,a0,1004 # 450 <ps+0x1c>
  6c:	00000097          	auipc	ra,0x0
  70:	f94080e7          	jalr	-108(ra) # 0 <print>
    exit(1);
  74:	4505                	li	a0,1
  76:	00000097          	auipc	ra,0x0
  7a:	31e080e7          	jalr	798(ra) # 394 <exit>
      exit(0);
  7e:	00000097          	auipc	ra,0x0
  82:	316080e7          	jalr	790(ra) # 394 <exit>
  if(n == N){
  86:	3e800793          	li	a5,1000
  8a:	fcf48de3          	beq	s1,a5,64 <forktest+0x36>
  }

  for(; n > 0; n--){
  8e:	00905b63          	blez	s1,a4 <forktest+0x76>
    if(wait(0) < 0){
  92:	4501                	li	a0,0
  94:	00000097          	auipc	ra,0x0
  98:	308080e7          	jalr	776(ra) # 39c <wait>
  9c:	02054a63          	bltz	a0,d0 <forktest+0xa2>
  for(; n > 0; n--){
  a0:	34fd                	addiw	s1,s1,-1
  a2:	f8e5                	bnez	s1,92 <forktest+0x64>
      print("wait stopped early\n");
      exit(1);
    }
  }

  if(wait(0) != -1){
  a4:	4501                	li	a0,0
  a6:	00000097          	auipc	ra,0x0
  aa:	2f6080e7          	jalr	758(ra) # 39c <wait>
  ae:	57fd                	li	a5,-1
  b0:	02f51d63          	bne	a0,a5,ea <forktest+0xbc>
    print("wait got too many\n");
    exit(1);
  }

  print("fork test OK\n");
  b4:	00000517          	auipc	a0,0x0
  b8:	3ec50513          	addi	a0,a0,1004 # 4a0 <ps+0x6c>
  bc:	00000097          	auipc	ra,0x0
  c0:	f44080e7          	jalr	-188(ra) # 0 <print>
}
  c4:	60e2                	ld	ra,24(sp)
  c6:	6442                	ld	s0,16(sp)
  c8:	64a2                	ld	s1,8(sp)
  ca:	6902                	ld	s2,0(sp)
  cc:	6105                	addi	sp,sp,32
  ce:	8082                	ret
      print("wait stopped early\n");
  d0:	00000517          	auipc	a0,0x0
  d4:	3a050513          	addi	a0,a0,928 # 470 <ps+0x3c>
  d8:	00000097          	auipc	ra,0x0
  dc:	f28080e7          	jalr	-216(ra) # 0 <print>
      exit(1);
  e0:	4505                	li	a0,1
  e2:	00000097          	auipc	ra,0x0
  e6:	2b2080e7          	jalr	690(ra) # 394 <exit>
    print("wait got too many\n");
  ea:	00000517          	auipc	a0,0x0
  ee:	39e50513          	addi	a0,a0,926 # 488 <ps+0x54>
  f2:	00000097          	auipc	ra,0x0
  f6:	f0e080e7          	jalr	-242(ra) # 0 <print>
    exit(1);
  fa:	4505                	li	a0,1
  fc:	00000097          	auipc	ra,0x0
 100:	298080e7          	jalr	664(ra) # 394 <exit>

0000000000000104 <main>:

int
main(void)
{
 104:	1141                	addi	sp,sp,-16
 106:	e406                	sd	ra,8(sp)
 108:	e022                	sd	s0,0(sp)
 10a:	0800                	addi	s0,sp,16
  forktest();
 10c:	00000097          	auipc	ra,0x0
 110:	f22080e7          	jalr	-222(ra) # 2e <forktest>
  exit(0);
 114:	4501                	li	a0,0
 116:	00000097          	auipc	ra,0x0
 11a:	27e080e7          	jalr	638(ra) # 394 <exit>

000000000000011e <strcpy>:
 11e:	1141                	addi	sp,sp,-16
 120:	e422                	sd	s0,8(sp)
 122:	0800                	addi	s0,sp,16
 124:	87aa                	mv	a5,a0
 126:	0585                	addi	a1,a1,1
 128:	0785                	addi	a5,a5,1
 12a:	fff5c703          	lbu	a4,-1(a1)
 12e:	fee78fa3          	sb	a4,-1(a5)
 132:	fb75                	bnez	a4,126 <strcpy+0x8>
 134:	6422                	ld	s0,8(sp)
 136:	0141                	addi	sp,sp,16
 138:	8082                	ret

000000000000013a <strcmp>:
 13a:	1141                	addi	sp,sp,-16
 13c:	e422                	sd	s0,8(sp)
 13e:	0800                	addi	s0,sp,16
 140:	00054783          	lbu	a5,0(a0)
 144:	cb91                	beqz	a5,158 <strcmp+0x1e>
 146:	0005c703          	lbu	a4,0(a1)
 14a:	00f71763          	bne	a4,a5,158 <strcmp+0x1e>
 14e:	0505                	addi	a0,a0,1
 150:	0585                	addi	a1,a1,1
 152:	00054783          	lbu	a5,0(a0)
 156:	fbe5                	bnez	a5,146 <strcmp+0xc>
 158:	0005c503          	lbu	a0,0(a1)
 15c:	40a7853b          	subw	a0,a5,a0
 160:	6422                	ld	s0,8(sp)
 162:	0141                	addi	sp,sp,16
 164:	8082                	ret

0000000000000166 <strlen>:
 166:	1141                	addi	sp,sp,-16
 168:	e422                	sd	s0,8(sp)
 16a:	0800                	addi	s0,sp,16
 16c:	00054783          	lbu	a5,0(a0)
 170:	cf91                	beqz	a5,18c <strlen+0x26>
 172:	0505                	addi	a0,a0,1
 174:	87aa                	mv	a5,a0
 176:	4685                	li	a3,1
 178:	9e89                	subw	a3,a3,a0
 17a:	00f6853b          	addw	a0,a3,a5
 17e:	0785                	addi	a5,a5,1
 180:	fff7c703          	lbu	a4,-1(a5)
 184:	fb7d                	bnez	a4,17a <strlen+0x14>
 186:	6422                	ld	s0,8(sp)
 188:	0141                	addi	sp,sp,16
 18a:	8082                	ret
 18c:	4501                	li	a0,0
 18e:	bfe5                	j	186 <strlen+0x20>

0000000000000190 <memset>:
 190:	1141                	addi	sp,sp,-16
 192:	e422                	sd	s0,8(sp)
 194:	0800                	addi	s0,sp,16
 196:	ce09                	beqz	a2,1b0 <memset+0x20>
 198:	87aa                	mv	a5,a0
 19a:	fff6071b          	addiw	a4,a2,-1
 19e:	1702                	slli	a4,a4,0x20
 1a0:	9301                	srli	a4,a4,0x20
 1a2:	0705                	addi	a4,a4,1
 1a4:	972a                	add	a4,a4,a0
 1a6:	00b78023          	sb	a1,0(a5)
 1aa:	0785                	addi	a5,a5,1
 1ac:	fee79de3          	bne	a5,a4,1a6 <memset+0x16>
 1b0:	6422                	ld	s0,8(sp)
 1b2:	0141                	addi	sp,sp,16
 1b4:	8082                	ret

00000000000001b6 <strchr>:
 1b6:	1141                	addi	sp,sp,-16
 1b8:	e422                	sd	s0,8(sp)
 1ba:	0800                	addi	s0,sp,16
 1bc:	00054783          	lbu	a5,0(a0)
 1c0:	cb99                	beqz	a5,1d6 <strchr+0x20>
 1c2:	00f58763          	beq	a1,a5,1d0 <strchr+0x1a>
 1c6:	0505                	addi	a0,a0,1
 1c8:	00054783          	lbu	a5,0(a0)
 1cc:	fbfd                	bnez	a5,1c2 <strchr+0xc>
 1ce:	4501                	li	a0,0
 1d0:	6422                	ld	s0,8(sp)
 1d2:	0141                	addi	sp,sp,16
 1d4:	8082                	ret
 1d6:	4501                	li	a0,0
 1d8:	bfe5                	j	1d0 <strchr+0x1a>

00000000000001da <gets>:
 1da:	711d                	addi	sp,sp,-96
 1dc:	ec86                	sd	ra,88(sp)
 1de:	e8a2                	sd	s0,80(sp)
 1e0:	e4a6                	sd	s1,72(sp)
 1e2:	e0ca                	sd	s2,64(sp)
 1e4:	fc4e                	sd	s3,56(sp)
 1e6:	f852                	sd	s4,48(sp)
 1e8:	f456                	sd	s5,40(sp)
 1ea:	f05a                	sd	s6,32(sp)
 1ec:	ec5e                	sd	s7,24(sp)
 1ee:	1080                	addi	s0,sp,96
 1f0:	8baa                	mv	s7,a0
 1f2:	8a2e                	mv	s4,a1
 1f4:	892a                	mv	s2,a0
 1f6:	4481                	li	s1,0
 1f8:	4aa9                	li	s5,10
 1fa:	4b35                	li	s6,13
 1fc:	89a6                	mv	s3,s1
 1fe:	2485                	addiw	s1,s1,1
 200:	0344d863          	bge	s1,s4,230 <gets+0x56>
 204:	4605                	li	a2,1
 206:	faf40593          	addi	a1,s0,-81
 20a:	4501                	li	a0,0
 20c:	00000097          	auipc	ra,0x0
 210:	1a0080e7          	jalr	416(ra) # 3ac <read>
 214:	00a05e63          	blez	a0,230 <gets+0x56>
 218:	faf44783          	lbu	a5,-81(s0)
 21c:	00f90023          	sb	a5,0(s2)
 220:	01578763          	beq	a5,s5,22e <gets+0x54>
 224:	0905                	addi	s2,s2,1
 226:	fd679be3          	bne	a5,s6,1fc <gets+0x22>
 22a:	89a6                	mv	s3,s1
 22c:	a011                	j	230 <gets+0x56>
 22e:	89a6                	mv	s3,s1
 230:	99de                	add	s3,s3,s7
 232:	00098023          	sb	zero,0(s3)
 236:	855e                	mv	a0,s7
 238:	60e6                	ld	ra,88(sp)
 23a:	6446                	ld	s0,80(sp)
 23c:	64a6                	ld	s1,72(sp)
 23e:	6906                	ld	s2,64(sp)
 240:	79e2                	ld	s3,56(sp)
 242:	7a42                	ld	s4,48(sp)
 244:	7aa2                	ld	s5,40(sp)
 246:	7b02                	ld	s6,32(sp)
 248:	6be2                	ld	s7,24(sp)
 24a:	6125                	addi	sp,sp,96
 24c:	8082                	ret

000000000000024e <stat>:
 24e:	1101                	addi	sp,sp,-32
 250:	ec06                	sd	ra,24(sp)
 252:	e822                	sd	s0,16(sp)
 254:	e426                	sd	s1,8(sp)
 256:	e04a                	sd	s2,0(sp)
 258:	1000                	addi	s0,sp,32
 25a:	892e                	mv	s2,a1
 25c:	4581                	li	a1,0
 25e:	00000097          	auipc	ra,0x0
 262:	176080e7          	jalr	374(ra) # 3d4 <open>
 266:	02054563          	bltz	a0,290 <stat+0x42>
 26a:	84aa                	mv	s1,a0
 26c:	85ca                	mv	a1,s2
 26e:	00000097          	auipc	ra,0x0
 272:	17e080e7          	jalr	382(ra) # 3ec <fstat>
 276:	892a                	mv	s2,a0
 278:	8526                	mv	a0,s1
 27a:	00000097          	auipc	ra,0x0
 27e:	142080e7          	jalr	322(ra) # 3bc <close>
 282:	854a                	mv	a0,s2
 284:	60e2                	ld	ra,24(sp)
 286:	6442                	ld	s0,16(sp)
 288:	64a2                	ld	s1,8(sp)
 28a:	6902                	ld	s2,0(sp)
 28c:	6105                	addi	sp,sp,32
 28e:	8082                	ret
 290:	597d                	li	s2,-1
 292:	bfc5                	j	282 <stat+0x34>

0000000000000294 <atoi>:
 294:	1141                	addi	sp,sp,-16
 296:	e422                	sd	s0,8(sp)
 298:	0800                	addi	s0,sp,16
 29a:	00054603          	lbu	a2,0(a0)
 29e:	fd06079b          	addiw	a5,a2,-48
 2a2:	0ff7f793          	andi	a5,a5,255
 2a6:	4725                	li	a4,9
 2a8:	02f76963          	bltu	a4,a5,2da <atoi+0x46>
 2ac:	86aa                	mv	a3,a0
 2ae:	4501                	li	a0,0
 2b0:	45a5                	li	a1,9
 2b2:	0685                	addi	a3,a3,1
 2b4:	0025179b          	slliw	a5,a0,0x2
 2b8:	9fa9                	addw	a5,a5,a0
 2ba:	0017979b          	slliw	a5,a5,0x1
 2be:	9fb1                	addw	a5,a5,a2
 2c0:	fd07851b          	addiw	a0,a5,-48
 2c4:	0006c603          	lbu	a2,0(a3)
 2c8:	fd06071b          	addiw	a4,a2,-48
 2cc:	0ff77713          	andi	a4,a4,255
 2d0:	fee5f1e3          	bgeu	a1,a4,2b2 <atoi+0x1e>
 2d4:	6422                	ld	s0,8(sp)
 2d6:	0141                	addi	sp,sp,16
 2d8:	8082                	ret
 2da:	4501                	li	a0,0
 2dc:	bfe5                	j	2d4 <atoi+0x40>

00000000000002de <memmove>:
 2de:	1141                	addi	sp,sp,-16
 2e0:	e422                	sd	s0,8(sp)
 2e2:	0800                	addi	s0,sp,16
 2e4:	02b57663          	bgeu	a0,a1,310 <memmove+0x32>
 2e8:	02c05163          	blez	a2,30a <memmove+0x2c>
 2ec:	fff6079b          	addiw	a5,a2,-1
 2f0:	1782                	slli	a5,a5,0x20
 2f2:	9381                	srli	a5,a5,0x20
 2f4:	0785                	addi	a5,a5,1
 2f6:	97aa                	add	a5,a5,a0
 2f8:	872a                	mv	a4,a0
 2fa:	0585                	addi	a1,a1,1
 2fc:	0705                	addi	a4,a4,1
 2fe:	fff5c683          	lbu	a3,-1(a1)
 302:	fed70fa3          	sb	a3,-1(a4)
 306:	fee79ae3          	bne	a5,a4,2fa <memmove+0x1c>
 30a:	6422                	ld	s0,8(sp)
 30c:	0141                	addi	sp,sp,16
 30e:	8082                	ret
 310:	00c50733          	add	a4,a0,a2
 314:	95b2                	add	a1,a1,a2
 316:	fec05ae3          	blez	a2,30a <memmove+0x2c>
 31a:	fff6079b          	addiw	a5,a2,-1
 31e:	1782                	slli	a5,a5,0x20
 320:	9381                	srli	a5,a5,0x20
 322:	fff7c793          	not	a5,a5
 326:	97ba                	add	a5,a5,a4
 328:	15fd                	addi	a1,a1,-1
 32a:	177d                	addi	a4,a4,-1
 32c:	0005c683          	lbu	a3,0(a1)
 330:	00d70023          	sb	a3,0(a4)
 334:	fee79ae3          	bne	a5,a4,328 <memmove+0x4a>
 338:	bfc9                	j	30a <memmove+0x2c>

000000000000033a <memcmp>:
 33a:	1141                	addi	sp,sp,-16
 33c:	e422                	sd	s0,8(sp)
 33e:	0800                	addi	s0,sp,16
 340:	ca05                	beqz	a2,370 <memcmp+0x36>
 342:	fff6069b          	addiw	a3,a2,-1
 346:	1682                	slli	a3,a3,0x20
 348:	9281                	srli	a3,a3,0x20
 34a:	0685                	addi	a3,a3,1
 34c:	96aa                	add	a3,a3,a0
 34e:	00054783          	lbu	a5,0(a0)
 352:	0005c703          	lbu	a4,0(a1)
 356:	00e79863          	bne	a5,a4,366 <memcmp+0x2c>
 35a:	0505                	addi	a0,a0,1
 35c:	0585                	addi	a1,a1,1
 35e:	fed518e3          	bne	a0,a3,34e <memcmp+0x14>
 362:	4501                	li	a0,0
 364:	a019                	j	36a <memcmp+0x30>
 366:	40e7853b          	subw	a0,a5,a4
 36a:	6422                	ld	s0,8(sp)
 36c:	0141                	addi	sp,sp,16
 36e:	8082                	ret
 370:	4501                	li	a0,0
 372:	bfe5                	j	36a <memcmp+0x30>

0000000000000374 <memcpy>:
 374:	1141                	addi	sp,sp,-16
 376:	e406                	sd	ra,8(sp)
 378:	e022                	sd	s0,0(sp)
 37a:	0800                	addi	s0,sp,16
 37c:	00000097          	auipc	ra,0x0
 380:	f62080e7          	jalr	-158(ra) # 2de <memmove>
 384:	60a2                	ld	ra,8(sp)
 386:	6402                	ld	s0,0(sp)
 388:	0141                	addi	sp,sp,16
 38a:	8082                	ret

000000000000038c <fork>:
 38c:	4885                	li	a7,1
 38e:	00000073          	ecall
 392:	8082                	ret

0000000000000394 <exit>:
 394:	4889                	li	a7,2
 396:	00000073          	ecall
 39a:	8082                	ret

000000000000039c <wait>:
 39c:	488d                	li	a7,3
 39e:	00000073          	ecall
 3a2:	8082                	ret

00000000000003a4 <pipe>:
 3a4:	4891                	li	a7,4
 3a6:	00000073          	ecall
 3aa:	8082                	ret

00000000000003ac <read>:
 3ac:	4895                	li	a7,5
 3ae:	00000073          	ecall
 3b2:	8082                	ret

00000000000003b4 <write>:
 3b4:	48c1                	li	a7,16
 3b6:	00000073          	ecall
 3ba:	8082                	ret

00000000000003bc <close>:
 3bc:	48d5                	li	a7,21
 3be:	00000073          	ecall
 3c2:	8082                	ret

00000000000003c4 <kill>:
 3c4:	4899                	li	a7,6
 3c6:	00000073          	ecall
 3ca:	8082                	ret

00000000000003cc <exec>:
 3cc:	489d                	li	a7,7
 3ce:	00000073          	ecall
 3d2:	8082                	ret

00000000000003d4 <open>:
 3d4:	48bd                	li	a7,15
 3d6:	00000073          	ecall
 3da:	8082                	ret

00000000000003dc <mknod>:
 3dc:	48c5                	li	a7,17
 3de:	00000073          	ecall
 3e2:	8082                	ret

00000000000003e4 <unlink>:
 3e4:	48c9                	li	a7,18
 3e6:	00000073          	ecall
 3ea:	8082                	ret

00000000000003ec <fstat>:
 3ec:	48a1                	li	a7,8
 3ee:	00000073          	ecall
 3f2:	8082                	ret

00000000000003f4 <link>:
 3f4:	48cd                	li	a7,19
 3f6:	00000073          	ecall
 3fa:	8082                	ret

00000000000003fc <mkdir>:
 3fc:	48d1                	li	a7,20
 3fe:	00000073          	ecall
 402:	8082                	ret

0000000000000404 <chdir>:
 404:	48a5                	li	a7,9
 406:	00000073          	ecall
 40a:	8082                	ret

000000000000040c <dup>:
 40c:	48a9                	li	a7,10
 40e:	00000073          	ecall
 412:	8082                	ret

0000000000000414 <getpid>:
 414:	48ad                	li	a7,11
 416:	00000073          	ecall
 41a:	8082                	ret

000000000000041c <sbrk>:
 41c:	48b1                	li	a7,12
 41e:	00000073          	ecall
 422:	8082                	ret

0000000000000424 <sleep>:
 424:	48b5                	li	a7,13
 426:	00000073          	ecall
 42a:	8082                	ret

000000000000042c <uptime>:
 42c:	48b9                	li	a7,14
 42e:	00000073          	ecall
 432:	8082                	ret

0000000000000434 <ps>:
 434:	48d9                	li	a7,22
 436:	00000073          	ecall
 43a:	8082                	ret
