
user/_zombie:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
   0:	1141                	addi	sp,sp,-16
   2:	e406                	sd	ra,8(sp)
   4:	e022                	sd	s0,0(sp)
   6:	0800                	addi	s0,sp,16
   8:	00000097          	auipc	ra,0x0
   c:	290080e7          	jalr	656(ra) # 298 <fork>
  10:	00a04763          	bgtz	a0,1e <main+0x1e>
  14:	4501                	li	a0,0
  16:	00000097          	auipc	ra,0x0
  1a:	28a080e7          	jalr	650(ra) # 2a0 <exit>
  1e:	4515                	li	a0,5
  20:	00000097          	auipc	ra,0x0
  24:	310080e7          	jalr	784(ra) # 330 <sleep>
  28:	b7f5                	j	14 <main+0x14>

000000000000002a <strcpy>:
  2a:	1141                	addi	sp,sp,-16
  2c:	e422                	sd	s0,8(sp)
  2e:	0800                	addi	s0,sp,16
  30:	87aa                	mv	a5,a0
  32:	0585                	addi	a1,a1,1
  34:	0785                	addi	a5,a5,1
  36:	fff5c703          	lbu	a4,-1(a1)
  3a:	fee78fa3          	sb	a4,-1(a5)
  3e:	fb75                	bnez	a4,32 <strcpy+0x8>
  40:	6422                	ld	s0,8(sp)
  42:	0141                	addi	sp,sp,16
  44:	8082                	ret

0000000000000046 <strcmp>:
  46:	1141                	addi	sp,sp,-16
  48:	e422                	sd	s0,8(sp)
  4a:	0800                	addi	s0,sp,16
  4c:	00054783          	lbu	a5,0(a0)
  50:	cb91                	beqz	a5,64 <strcmp+0x1e>
  52:	0005c703          	lbu	a4,0(a1)
  56:	00f71763          	bne	a4,a5,64 <strcmp+0x1e>
  5a:	0505                	addi	a0,a0,1
  5c:	0585                	addi	a1,a1,1
  5e:	00054783          	lbu	a5,0(a0)
  62:	fbe5                	bnez	a5,52 <strcmp+0xc>
  64:	0005c503          	lbu	a0,0(a1)
  68:	40a7853b          	subw	a0,a5,a0
  6c:	6422                	ld	s0,8(sp)
  6e:	0141                	addi	sp,sp,16
  70:	8082                	ret

0000000000000072 <strlen>:
  72:	1141                	addi	sp,sp,-16
  74:	e422                	sd	s0,8(sp)
  76:	0800                	addi	s0,sp,16
  78:	00054783          	lbu	a5,0(a0)
  7c:	cf91                	beqz	a5,98 <strlen+0x26>
  7e:	0505                	addi	a0,a0,1
  80:	87aa                	mv	a5,a0
  82:	4685                	li	a3,1
  84:	9e89                	subw	a3,a3,a0
  86:	00f6853b          	addw	a0,a3,a5
  8a:	0785                	addi	a5,a5,1
  8c:	fff7c703          	lbu	a4,-1(a5)
  90:	fb7d                	bnez	a4,86 <strlen+0x14>
  92:	6422                	ld	s0,8(sp)
  94:	0141                	addi	sp,sp,16
  96:	8082                	ret
  98:	4501                	li	a0,0
  9a:	bfe5                	j	92 <strlen+0x20>

000000000000009c <memset>:
  9c:	1141                	addi	sp,sp,-16
  9e:	e422                	sd	s0,8(sp)
  a0:	0800                	addi	s0,sp,16
  a2:	ce09                	beqz	a2,bc <memset+0x20>
  a4:	87aa                	mv	a5,a0
  a6:	fff6071b          	addiw	a4,a2,-1
  aa:	1702                	slli	a4,a4,0x20
  ac:	9301                	srli	a4,a4,0x20
  ae:	0705                	addi	a4,a4,1
  b0:	972a                	add	a4,a4,a0
  b2:	00b78023          	sb	a1,0(a5)
  b6:	0785                	addi	a5,a5,1
  b8:	fee79de3          	bne	a5,a4,b2 <memset+0x16>
  bc:	6422                	ld	s0,8(sp)
  be:	0141                	addi	sp,sp,16
  c0:	8082                	ret

00000000000000c2 <strchr>:
  c2:	1141                	addi	sp,sp,-16
  c4:	e422                	sd	s0,8(sp)
  c6:	0800                	addi	s0,sp,16
  c8:	00054783          	lbu	a5,0(a0)
  cc:	cb99                	beqz	a5,e2 <strchr+0x20>
  ce:	00f58763          	beq	a1,a5,dc <strchr+0x1a>
  d2:	0505                	addi	a0,a0,1
  d4:	00054783          	lbu	a5,0(a0)
  d8:	fbfd                	bnez	a5,ce <strchr+0xc>
  da:	4501                	li	a0,0
  dc:	6422                	ld	s0,8(sp)
  de:	0141                	addi	sp,sp,16
  e0:	8082                	ret
  e2:	4501                	li	a0,0
  e4:	bfe5                	j	dc <strchr+0x1a>

00000000000000e6 <gets>:
  e6:	711d                	addi	sp,sp,-96
  e8:	ec86                	sd	ra,88(sp)
  ea:	e8a2                	sd	s0,80(sp)
  ec:	e4a6                	sd	s1,72(sp)
  ee:	e0ca                	sd	s2,64(sp)
  f0:	fc4e                	sd	s3,56(sp)
  f2:	f852                	sd	s4,48(sp)
  f4:	f456                	sd	s5,40(sp)
  f6:	f05a                	sd	s6,32(sp)
  f8:	ec5e                	sd	s7,24(sp)
  fa:	1080                	addi	s0,sp,96
  fc:	8baa                	mv	s7,a0
  fe:	8a2e                	mv	s4,a1
 100:	892a                	mv	s2,a0
 102:	4481                	li	s1,0
 104:	4aa9                	li	s5,10
 106:	4b35                	li	s6,13
 108:	89a6                	mv	s3,s1
 10a:	2485                	addiw	s1,s1,1
 10c:	0344d863          	bge	s1,s4,13c <gets+0x56>
 110:	4605                	li	a2,1
 112:	faf40593          	addi	a1,s0,-81
 116:	4501                	li	a0,0
 118:	00000097          	auipc	ra,0x0
 11c:	1a0080e7          	jalr	416(ra) # 2b8 <read>
 120:	00a05e63          	blez	a0,13c <gets+0x56>
 124:	faf44783          	lbu	a5,-81(s0)
 128:	00f90023          	sb	a5,0(s2)
 12c:	01578763          	beq	a5,s5,13a <gets+0x54>
 130:	0905                	addi	s2,s2,1
 132:	fd679be3          	bne	a5,s6,108 <gets+0x22>
 136:	89a6                	mv	s3,s1
 138:	a011                	j	13c <gets+0x56>
 13a:	89a6                	mv	s3,s1
 13c:	99de                	add	s3,s3,s7
 13e:	00098023          	sb	zero,0(s3)
 142:	855e                	mv	a0,s7
 144:	60e6                	ld	ra,88(sp)
 146:	6446                	ld	s0,80(sp)
 148:	64a6                	ld	s1,72(sp)
 14a:	6906                	ld	s2,64(sp)
 14c:	79e2                	ld	s3,56(sp)
 14e:	7a42                	ld	s4,48(sp)
 150:	7aa2                	ld	s5,40(sp)
 152:	7b02                	ld	s6,32(sp)
 154:	6be2                	ld	s7,24(sp)
 156:	6125                	addi	sp,sp,96
 158:	8082                	ret

000000000000015a <stat>:
 15a:	1101                	addi	sp,sp,-32
 15c:	ec06                	sd	ra,24(sp)
 15e:	e822                	sd	s0,16(sp)
 160:	e426                	sd	s1,8(sp)
 162:	e04a                	sd	s2,0(sp)
 164:	1000                	addi	s0,sp,32
 166:	892e                	mv	s2,a1
 168:	4581                	li	a1,0
 16a:	00000097          	auipc	ra,0x0
 16e:	176080e7          	jalr	374(ra) # 2e0 <open>
 172:	02054563          	bltz	a0,19c <stat+0x42>
 176:	84aa                	mv	s1,a0
 178:	85ca                	mv	a1,s2
 17a:	00000097          	auipc	ra,0x0
 17e:	17e080e7          	jalr	382(ra) # 2f8 <fstat>
 182:	892a                	mv	s2,a0
 184:	8526                	mv	a0,s1
 186:	00000097          	auipc	ra,0x0
 18a:	142080e7          	jalr	322(ra) # 2c8 <close>
 18e:	854a                	mv	a0,s2
 190:	60e2                	ld	ra,24(sp)
 192:	6442                	ld	s0,16(sp)
 194:	64a2                	ld	s1,8(sp)
 196:	6902                	ld	s2,0(sp)
 198:	6105                	addi	sp,sp,32
 19a:	8082                	ret
 19c:	597d                	li	s2,-1
 19e:	bfc5                	j	18e <stat+0x34>

00000000000001a0 <atoi>:
 1a0:	1141                	addi	sp,sp,-16
 1a2:	e422                	sd	s0,8(sp)
 1a4:	0800                	addi	s0,sp,16
 1a6:	00054603          	lbu	a2,0(a0)
 1aa:	fd06079b          	addiw	a5,a2,-48
 1ae:	0ff7f793          	andi	a5,a5,255
 1b2:	4725                	li	a4,9
 1b4:	02f76963          	bltu	a4,a5,1e6 <atoi+0x46>
 1b8:	86aa                	mv	a3,a0
 1ba:	4501                	li	a0,0
 1bc:	45a5                	li	a1,9
 1be:	0685                	addi	a3,a3,1
 1c0:	0025179b          	slliw	a5,a0,0x2
 1c4:	9fa9                	addw	a5,a5,a0
 1c6:	0017979b          	slliw	a5,a5,0x1
 1ca:	9fb1                	addw	a5,a5,a2
 1cc:	fd07851b          	addiw	a0,a5,-48
 1d0:	0006c603          	lbu	a2,0(a3)
 1d4:	fd06071b          	addiw	a4,a2,-48
 1d8:	0ff77713          	andi	a4,a4,255
 1dc:	fee5f1e3          	bgeu	a1,a4,1be <atoi+0x1e>
 1e0:	6422                	ld	s0,8(sp)
 1e2:	0141                	addi	sp,sp,16
 1e4:	8082                	ret
 1e6:	4501                	li	a0,0
 1e8:	bfe5                	j	1e0 <atoi+0x40>

00000000000001ea <memmove>:
 1ea:	1141                	addi	sp,sp,-16
 1ec:	e422                	sd	s0,8(sp)
 1ee:	0800                	addi	s0,sp,16
 1f0:	02b57663          	bgeu	a0,a1,21c <memmove+0x32>
 1f4:	02c05163          	blez	a2,216 <memmove+0x2c>
 1f8:	fff6079b          	addiw	a5,a2,-1
 1fc:	1782                	slli	a5,a5,0x20
 1fe:	9381                	srli	a5,a5,0x20
 200:	0785                	addi	a5,a5,1
 202:	97aa                	add	a5,a5,a0
 204:	872a                	mv	a4,a0
 206:	0585                	addi	a1,a1,1
 208:	0705                	addi	a4,a4,1
 20a:	fff5c683          	lbu	a3,-1(a1)
 20e:	fed70fa3          	sb	a3,-1(a4)
 212:	fee79ae3          	bne	a5,a4,206 <memmove+0x1c>
 216:	6422                	ld	s0,8(sp)
 218:	0141                	addi	sp,sp,16
 21a:	8082                	ret
 21c:	00c50733          	add	a4,a0,a2
 220:	95b2                	add	a1,a1,a2
 222:	fec05ae3          	blez	a2,216 <memmove+0x2c>
 226:	fff6079b          	addiw	a5,a2,-1
 22a:	1782                	slli	a5,a5,0x20
 22c:	9381                	srli	a5,a5,0x20
 22e:	fff7c793          	not	a5,a5
 232:	97ba                	add	a5,a5,a4
 234:	15fd                	addi	a1,a1,-1
 236:	177d                	addi	a4,a4,-1
 238:	0005c683          	lbu	a3,0(a1)
 23c:	00d70023          	sb	a3,0(a4)
 240:	fee79ae3          	bne	a5,a4,234 <memmove+0x4a>
 244:	bfc9                	j	216 <memmove+0x2c>

0000000000000246 <memcmp>:
 246:	1141                	addi	sp,sp,-16
 248:	e422                	sd	s0,8(sp)
 24a:	0800                	addi	s0,sp,16
 24c:	ca05                	beqz	a2,27c <memcmp+0x36>
 24e:	fff6069b          	addiw	a3,a2,-1
 252:	1682                	slli	a3,a3,0x20
 254:	9281                	srli	a3,a3,0x20
 256:	0685                	addi	a3,a3,1
 258:	96aa                	add	a3,a3,a0
 25a:	00054783          	lbu	a5,0(a0)
 25e:	0005c703          	lbu	a4,0(a1)
 262:	00e79863          	bne	a5,a4,272 <memcmp+0x2c>
 266:	0505                	addi	a0,a0,1
 268:	0585                	addi	a1,a1,1
 26a:	fed518e3          	bne	a0,a3,25a <memcmp+0x14>
 26e:	4501                	li	a0,0
 270:	a019                	j	276 <memcmp+0x30>
 272:	40e7853b          	subw	a0,a5,a4
 276:	6422                	ld	s0,8(sp)
 278:	0141                	addi	sp,sp,16
 27a:	8082                	ret
 27c:	4501                	li	a0,0
 27e:	bfe5                	j	276 <memcmp+0x30>

0000000000000280 <memcpy>:
 280:	1141                	addi	sp,sp,-16
 282:	e406                	sd	ra,8(sp)
 284:	e022                	sd	s0,0(sp)
 286:	0800                	addi	s0,sp,16
 288:	00000097          	auipc	ra,0x0
 28c:	f62080e7          	jalr	-158(ra) # 1ea <memmove>
 290:	60a2                	ld	ra,8(sp)
 292:	6402                	ld	s0,0(sp)
 294:	0141                	addi	sp,sp,16
 296:	8082                	ret

0000000000000298 <fork>:
 298:	4885                	li	a7,1
 29a:	00000073          	ecall
 29e:	8082                	ret

00000000000002a0 <exit>:
 2a0:	4889                	li	a7,2
 2a2:	00000073          	ecall
 2a6:	8082                	ret

00000000000002a8 <wait>:
 2a8:	488d                	li	a7,3
 2aa:	00000073          	ecall
 2ae:	8082                	ret

00000000000002b0 <pipe>:
 2b0:	4891                	li	a7,4
 2b2:	00000073          	ecall
 2b6:	8082                	ret

00000000000002b8 <read>:
 2b8:	4895                	li	a7,5
 2ba:	00000073          	ecall
 2be:	8082                	ret

00000000000002c0 <write>:
 2c0:	48c1                	li	a7,16
 2c2:	00000073          	ecall
 2c6:	8082                	ret

00000000000002c8 <close>:
 2c8:	48d5                	li	a7,21
 2ca:	00000073          	ecall
 2ce:	8082                	ret

00000000000002d0 <kill>:
 2d0:	4899                	li	a7,6
 2d2:	00000073          	ecall
 2d6:	8082                	ret

00000000000002d8 <exec>:
 2d8:	489d                	li	a7,7
 2da:	00000073          	ecall
 2de:	8082                	ret

00000000000002e0 <open>:
 2e0:	48bd                	li	a7,15
 2e2:	00000073          	ecall
 2e6:	8082                	ret

00000000000002e8 <mknod>:
 2e8:	48c5                	li	a7,17
 2ea:	00000073          	ecall
 2ee:	8082                	ret

00000000000002f0 <unlink>:
 2f0:	48c9                	li	a7,18
 2f2:	00000073          	ecall
 2f6:	8082                	ret

00000000000002f8 <fstat>:
 2f8:	48a1                	li	a7,8
 2fa:	00000073          	ecall
 2fe:	8082                	ret

0000000000000300 <link>:
 300:	48cd                	li	a7,19
 302:	00000073          	ecall
 306:	8082                	ret

0000000000000308 <mkdir>:
 308:	48d1                	li	a7,20
 30a:	00000073          	ecall
 30e:	8082                	ret

0000000000000310 <chdir>:
 310:	48a5                	li	a7,9
 312:	00000073          	ecall
 316:	8082                	ret

0000000000000318 <dup>:
 318:	48a9                	li	a7,10
 31a:	00000073          	ecall
 31e:	8082                	ret

0000000000000320 <getpid>:
 320:	48ad                	li	a7,11
 322:	00000073          	ecall
 326:	8082                	ret

0000000000000328 <sbrk>:
 328:	48b1                	li	a7,12
 32a:	00000073          	ecall
 32e:	8082                	ret

0000000000000330 <sleep>:
 330:	48b5                	li	a7,13
 332:	00000073          	ecall
 336:	8082                	ret

0000000000000338 <uptime>:
 338:	48b9                	li	a7,14
 33a:	00000073          	ecall
 33e:	8082                	ret

0000000000000340 <ps>:
 340:	48d9                	li	a7,22
 342:	00000073          	ecall
 346:	8082                	ret

0000000000000348 <setbkg>:
.global setbkg
setbkg:
 li a7, SYS_setbkg
 348:	48dd                	li	a7,23
 ecall
 34a:	00000073          	ecall
 ret
 34e:	8082                	ret

0000000000000350 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 350:	1101                	addi	sp,sp,-32
 352:	ec06                	sd	ra,24(sp)
 354:	e822                	sd	s0,16(sp)
 356:	1000                	addi	s0,sp,32
 358:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 35c:	4605                	li	a2,1
 35e:	fef40593          	addi	a1,s0,-17
 362:	00000097          	auipc	ra,0x0
 366:	f5e080e7          	jalr	-162(ra) # 2c0 <write>
}
 36a:	60e2                	ld	ra,24(sp)
 36c:	6442                	ld	s0,16(sp)
 36e:	6105                	addi	sp,sp,32
 370:	8082                	ret

0000000000000372 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 372:	7139                	addi	sp,sp,-64
 374:	fc06                	sd	ra,56(sp)
 376:	f822                	sd	s0,48(sp)
 378:	f426                	sd	s1,40(sp)
 37a:	f04a                	sd	s2,32(sp)
 37c:	ec4e                	sd	s3,24(sp)
 37e:	0080                	addi	s0,sp,64
 380:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 382:	c299                	beqz	a3,388 <printint+0x16>
 384:	0805c863          	bltz	a1,414 <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 388:	2581                	sext.w	a1,a1
  neg = 0;
 38a:	4881                	li	a7,0
 38c:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 390:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 392:	2601                	sext.w	a2,a2
 394:	00000517          	auipc	a0,0x0
 398:	44450513          	addi	a0,a0,1092 # 7d8 <digits>
 39c:	883a                	mv	a6,a4
 39e:	2705                	addiw	a4,a4,1
 3a0:	02c5f7bb          	remuw	a5,a1,a2
 3a4:	1782                	slli	a5,a5,0x20
 3a6:	9381                	srli	a5,a5,0x20
 3a8:	97aa                	add	a5,a5,a0
 3aa:	0007c783          	lbu	a5,0(a5)
 3ae:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 3b2:	0005879b          	sext.w	a5,a1
 3b6:	02c5d5bb          	divuw	a1,a1,a2
 3ba:	0685                	addi	a3,a3,1
 3bc:	fec7f0e3          	bgeu	a5,a2,39c <printint+0x2a>
  if(neg)
 3c0:	00088b63          	beqz	a7,3d6 <printint+0x64>
    buf[i++] = '-';
 3c4:	fd040793          	addi	a5,s0,-48
 3c8:	973e                	add	a4,a4,a5
 3ca:	02d00793          	li	a5,45
 3ce:	fef70823          	sb	a5,-16(a4)
 3d2:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 3d6:	02e05863          	blez	a4,406 <printint+0x94>
 3da:	fc040793          	addi	a5,s0,-64
 3de:	00e78933          	add	s2,a5,a4
 3e2:	fff78993          	addi	s3,a5,-1
 3e6:	99ba                	add	s3,s3,a4
 3e8:	377d                	addiw	a4,a4,-1
 3ea:	1702                	slli	a4,a4,0x20
 3ec:	9301                	srli	a4,a4,0x20
 3ee:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 3f2:	fff94583          	lbu	a1,-1(s2)
 3f6:	8526                	mv	a0,s1
 3f8:	00000097          	auipc	ra,0x0
 3fc:	f58080e7          	jalr	-168(ra) # 350 <putc>
  while(--i >= 0)
 400:	197d                	addi	s2,s2,-1
 402:	ff3918e3          	bne	s2,s3,3f2 <printint+0x80>
}
 406:	70e2                	ld	ra,56(sp)
 408:	7442                	ld	s0,48(sp)
 40a:	74a2                	ld	s1,40(sp)
 40c:	7902                	ld	s2,32(sp)
 40e:	69e2                	ld	s3,24(sp)
 410:	6121                	addi	sp,sp,64
 412:	8082                	ret
    x = -xx;
 414:	40b005bb          	negw	a1,a1
    neg = 1;
 418:	4885                	li	a7,1
    x = -xx;
 41a:	bf8d                	j	38c <printint+0x1a>

000000000000041c <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 41c:	7119                	addi	sp,sp,-128
 41e:	fc86                	sd	ra,120(sp)
 420:	f8a2                	sd	s0,112(sp)
 422:	f4a6                	sd	s1,104(sp)
 424:	f0ca                	sd	s2,96(sp)
 426:	ecce                	sd	s3,88(sp)
 428:	e8d2                	sd	s4,80(sp)
 42a:	e4d6                	sd	s5,72(sp)
 42c:	e0da                	sd	s6,64(sp)
 42e:	fc5e                	sd	s7,56(sp)
 430:	f862                	sd	s8,48(sp)
 432:	f466                	sd	s9,40(sp)
 434:	f06a                	sd	s10,32(sp)
 436:	ec6e                	sd	s11,24(sp)
 438:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 43a:	0005c903          	lbu	s2,0(a1)
 43e:	18090f63          	beqz	s2,5dc <vprintf+0x1c0>
 442:	8aaa                	mv	s5,a0
 444:	8b32                	mv	s6,a2
 446:	00158493          	addi	s1,a1,1
  state = 0;
 44a:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 44c:	02500a13          	li	s4,37
      if(c == 'd'){
 450:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 454:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 458:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 45c:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 460:	00000b97          	auipc	s7,0x0
 464:	378b8b93          	addi	s7,s7,888 # 7d8 <digits>
 468:	a839                	j	486 <vprintf+0x6a>
        putc(fd, c);
 46a:	85ca                	mv	a1,s2
 46c:	8556                	mv	a0,s5
 46e:	00000097          	auipc	ra,0x0
 472:	ee2080e7          	jalr	-286(ra) # 350 <putc>
 476:	a019                	j	47c <vprintf+0x60>
    } else if(state == '%'){
 478:	01498f63          	beq	s3,s4,496 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 47c:	0485                	addi	s1,s1,1
 47e:	fff4c903          	lbu	s2,-1(s1)
 482:	14090d63          	beqz	s2,5dc <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 486:	0009079b          	sext.w	a5,s2
    if(state == 0){
 48a:	fe0997e3          	bnez	s3,478 <vprintf+0x5c>
      if(c == '%'){
 48e:	fd479ee3          	bne	a5,s4,46a <vprintf+0x4e>
        state = '%';
 492:	89be                	mv	s3,a5
 494:	b7e5                	j	47c <vprintf+0x60>
      if(c == 'd'){
 496:	05878063          	beq	a5,s8,4d6 <vprintf+0xba>
      } else if(c == 'l') {
 49a:	05978c63          	beq	a5,s9,4f2 <vprintf+0xd6>
      } else if(c == 'x') {
 49e:	07a78863          	beq	a5,s10,50e <vprintf+0xf2>
      } else if(c == 'p') {
 4a2:	09b78463          	beq	a5,s11,52a <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 4a6:	07300713          	li	a4,115
 4aa:	0ce78663          	beq	a5,a4,576 <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 4ae:	06300713          	li	a4,99
 4b2:	0ee78e63          	beq	a5,a4,5ae <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 4b6:	11478863          	beq	a5,s4,5c6 <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 4ba:	85d2                	mv	a1,s4
 4bc:	8556                	mv	a0,s5
 4be:	00000097          	auipc	ra,0x0
 4c2:	e92080e7          	jalr	-366(ra) # 350 <putc>
        putc(fd, c);
 4c6:	85ca                	mv	a1,s2
 4c8:	8556                	mv	a0,s5
 4ca:	00000097          	auipc	ra,0x0
 4ce:	e86080e7          	jalr	-378(ra) # 350 <putc>
      }
      state = 0;
 4d2:	4981                	li	s3,0
 4d4:	b765                	j	47c <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 4d6:	008b0913          	addi	s2,s6,8
 4da:	4685                	li	a3,1
 4dc:	4629                	li	a2,10
 4de:	000b2583          	lw	a1,0(s6)
 4e2:	8556                	mv	a0,s5
 4e4:	00000097          	auipc	ra,0x0
 4e8:	e8e080e7          	jalr	-370(ra) # 372 <printint>
 4ec:	8b4a                	mv	s6,s2
      state = 0;
 4ee:	4981                	li	s3,0
 4f0:	b771                	j	47c <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 4f2:	008b0913          	addi	s2,s6,8
 4f6:	4681                	li	a3,0
 4f8:	4629                	li	a2,10
 4fa:	000b2583          	lw	a1,0(s6)
 4fe:	8556                	mv	a0,s5
 500:	00000097          	auipc	ra,0x0
 504:	e72080e7          	jalr	-398(ra) # 372 <printint>
 508:	8b4a                	mv	s6,s2
      state = 0;
 50a:	4981                	li	s3,0
 50c:	bf85                	j	47c <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 50e:	008b0913          	addi	s2,s6,8
 512:	4681                	li	a3,0
 514:	4641                	li	a2,16
 516:	000b2583          	lw	a1,0(s6)
 51a:	8556                	mv	a0,s5
 51c:	00000097          	auipc	ra,0x0
 520:	e56080e7          	jalr	-426(ra) # 372 <printint>
 524:	8b4a                	mv	s6,s2
      state = 0;
 526:	4981                	li	s3,0
 528:	bf91                	j	47c <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 52a:	008b0793          	addi	a5,s6,8
 52e:	f8f43423          	sd	a5,-120(s0)
 532:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 536:	03000593          	li	a1,48
 53a:	8556                	mv	a0,s5
 53c:	00000097          	auipc	ra,0x0
 540:	e14080e7          	jalr	-492(ra) # 350 <putc>
  putc(fd, 'x');
 544:	85ea                	mv	a1,s10
 546:	8556                	mv	a0,s5
 548:	00000097          	auipc	ra,0x0
 54c:	e08080e7          	jalr	-504(ra) # 350 <putc>
 550:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 552:	03c9d793          	srli	a5,s3,0x3c
 556:	97de                	add	a5,a5,s7
 558:	0007c583          	lbu	a1,0(a5)
 55c:	8556                	mv	a0,s5
 55e:	00000097          	auipc	ra,0x0
 562:	df2080e7          	jalr	-526(ra) # 350 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 566:	0992                	slli	s3,s3,0x4
 568:	397d                	addiw	s2,s2,-1
 56a:	fe0914e3          	bnez	s2,552 <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 56e:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 572:	4981                	li	s3,0
 574:	b721                	j	47c <vprintf+0x60>
        s = va_arg(ap, char*);
 576:	008b0993          	addi	s3,s6,8
 57a:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 57e:	02090163          	beqz	s2,5a0 <vprintf+0x184>
        while(*s != 0){
 582:	00094583          	lbu	a1,0(s2)
 586:	c9a1                	beqz	a1,5d6 <vprintf+0x1ba>
          putc(fd, *s);
 588:	8556                	mv	a0,s5
 58a:	00000097          	auipc	ra,0x0
 58e:	dc6080e7          	jalr	-570(ra) # 350 <putc>
          s++;
 592:	0905                	addi	s2,s2,1
        while(*s != 0){
 594:	00094583          	lbu	a1,0(s2)
 598:	f9e5                	bnez	a1,588 <vprintf+0x16c>
        s = va_arg(ap, char*);
 59a:	8b4e                	mv	s6,s3
      state = 0;
 59c:	4981                	li	s3,0
 59e:	bdf9                	j	47c <vprintf+0x60>
          s = "(null)";
 5a0:	00000917          	auipc	s2,0x0
 5a4:	23090913          	addi	s2,s2,560 # 7d0 <malloc+0xea>
        while(*s != 0){
 5a8:	02800593          	li	a1,40
 5ac:	bff1                	j	588 <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 5ae:	008b0913          	addi	s2,s6,8
 5b2:	000b4583          	lbu	a1,0(s6)
 5b6:	8556                	mv	a0,s5
 5b8:	00000097          	auipc	ra,0x0
 5bc:	d98080e7          	jalr	-616(ra) # 350 <putc>
 5c0:	8b4a                	mv	s6,s2
      state = 0;
 5c2:	4981                	li	s3,0
 5c4:	bd65                	j	47c <vprintf+0x60>
        putc(fd, c);
 5c6:	85d2                	mv	a1,s4
 5c8:	8556                	mv	a0,s5
 5ca:	00000097          	auipc	ra,0x0
 5ce:	d86080e7          	jalr	-634(ra) # 350 <putc>
      state = 0;
 5d2:	4981                	li	s3,0
 5d4:	b565                	j	47c <vprintf+0x60>
        s = va_arg(ap, char*);
 5d6:	8b4e                	mv	s6,s3
      state = 0;
 5d8:	4981                	li	s3,0
 5da:	b54d                	j	47c <vprintf+0x60>
    }
  }
}
 5dc:	70e6                	ld	ra,120(sp)
 5de:	7446                	ld	s0,112(sp)
 5e0:	74a6                	ld	s1,104(sp)
 5e2:	7906                	ld	s2,96(sp)
 5e4:	69e6                	ld	s3,88(sp)
 5e6:	6a46                	ld	s4,80(sp)
 5e8:	6aa6                	ld	s5,72(sp)
 5ea:	6b06                	ld	s6,64(sp)
 5ec:	7be2                	ld	s7,56(sp)
 5ee:	7c42                	ld	s8,48(sp)
 5f0:	7ca2                	ld	s9,40(sp)
 5f2:	7d02                	ld	s10,32(sp)
 5f4:	6de2                	ld	s11,24(sp)
 5f6:	6109                	addi	sp,sp,128
 5f8:	8082                	ret

00000000000005fa <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 5fa:	715d                	addi	sp,sp,-80
 5fc:	ec06                	sd	ra,24(sp)
 5fe:	e822                	sd	s0,16(sp)
 600:	1000                	addi	s0,sp,32
 602:	e010                	sd	a2,0(s0)
 604:	e414                	sd	a3,8(s0)
 606:	e818                	sd	a4,16(s0)
 608:	ec1c                	sd	a5,24(s0)
 60a:	03043023          	sd	a6,32(s0)
 60e:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 612:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 616:	8622                	mv	a2,s0
 618:	00000097          	auipc	ra,0x0
 61c:	e04080e7          	jalr	-508(ra) # 41c <vprintf>
}
 620:	60e2                	ld	ra,24(sp)
 622:	6442                	ld	s0,16(sp)
 624:	6161                	addi	sp,sp,80
 626:	8082                	ret

0000000000000628 <printf>:

void
printf(const char *fmt, ...)
{
 628:	711d                	addi	sp,sp,-96
 62a:	ec06                	sd	ra,24(sp)
 62c:	e822                	sd	s0,16(sp)
 62e:	1000                	addi	s0,sp,32
 630:	e40c                	sd	a1,8(s0)
 632:	e810                	sd	a2,16(s0)
 634:	ec14                	sd	a3,24(s0)
 636:	f018                	sd	a4,32(s0)
 638:	f41c                	sd	a5,40(s0)
 63a:	03043823          	sd	a6,48(s0)
 63e:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 642:	00840613          	addi	a2,s0,8
 646:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 64a:	85aa                	mv	a1,a0
 64c:	4505                	li	a0,1
 64e:	00000097          	auipc	ra,0x0
 652:	dce080e7          	jalr	-562(ra) # 41c <vprintf>
}
 656:	60e2                	ld	ra,24(sp)
 658:	6442                	ld	s0,16(sp)
 65a:	6125                	addi	sp,sp,96
 65c:	8082                	ret

<<<<<<< HEAD
0000000000000656 <free>:
 656:	1141                	addi	sp,sp,-16
 658:	e422                	sd	s0,8(sp)
 65a:	0800                	addi	s0,sp,16
 65c:	ff050693          	addi	a3,a0,-16
 660:	00000797          	auipc	a5,0x0
 664:	1887b783          	ld	a5,392(a5) # 7e8 <freep>
 668:	a805                	j	698 <free+0x42>
 66a:	4618                	lw	a4,8(a2)
 66c:	9db9                	addw	a1,a1,a4
 66e:	feb52c23          	sw	a1,-8(a0)
 672:	6398                	ld	a4,0(a5)
 674:	6318                	ld	a4,0(a4)
 676:	fee53823          	sd	a4,-16(a0)
 67a:	a091                	j	6be <free+0x68>
 67c:	ff852703          	lw	a4,-8(a0)
 680:	9e39                	addw	a2,a2,a4
 682:	c790                	sw	a2,8(a5)
 684:	ff053703          	ld	a4,-16(a0)
 688:	e398                	sd	a4,0(a5)
 68a:	a099                	j	6d0 <free+0x7a>
 68c:	6398                	ld	a4,0(a5)
 68e:	00e7e463          	bltu	a5,a4,696 <free+0x40>
 692:	00e6ea63          	bltu	a3,a4,6a6 <free+0x50>
 696:	87ba                	mv	a5,a4
 698:	fed7fae3          	bgeu	a5,a3,68c <free+0x36>
 69c:	6398                	ld	a4,0(a5)
 69e:	00e6e463          	bltu	a3,a4,6a6 <free+0x50>
 6a2:	fee7eae3          	bltu	a5,a4,696 <free+0x40>
 6a6:	ff852583          	lw	a1,-8(a0)
 6aa:	6390                	ld	a2,0(a5)
 6ac:	02059713          	slli	a4,a1,0x20
 6b0:	9301                	srli	a4,a4,0x20
 6b2:	0712                	slli	a4,a4,0x4
 6b4:	9736                	add	a4,a4,a3
 6b6:	fae60ae3          	beq	a2,a4,66a <free+0x14>
 6ba:	fec53823          	sd	a2,-16(a0)
 6be:	4790                	lw	a2,8(a5)
 6c0:	02061713          	slli	a4,a2,0x20
 6c4:	9301                	srli	a4,a4,0x20
 6c6:	0712                	slli	a4,a4,0x4
 6c8:	973e                	add	a4,a4,a5
 6ca:	fae689e3          	beq	a3,a4,67c <free+0x26>
 6ce:	e394                	sd	a3,0(a5)
 6d0:	00000717          	auipc	a4,0x0
 6d4:	10f73c23          	sd	a5,280(a4) # 7e8 <freep>
 6d8:	6422                	ld	s0,8(sp)
 6da:	0141                	addi	sp,sp,16
 6dc:	8082                	ret

00000000000006de <malloc>:
 6de:	7139                	addi	sp,sp,-64
 6e0:	fc06                	sd	ra,56(sp)
 6e2:	f822                	sd	s0,48(sp)
 6e4:	f426                	sd	s1,40(sp)
 6e6:	f04a                	sd	s2,32(sp)
 6e8:	ec4e                	sd	s3,24(sp)
 6ea:	e852                	sd	s4,16(sp)
 6ec:	e456                	sd	s5,8(sp)
 6ee:	e05a                	sd	s6,0(sp)
 6f0:	0080                	addi	s0,sp,64
 6f2:	02051493          	slli	s1,a0,0x20
 6f6:	9081                	srli	s1,s1,0x20
 6f8:	04bd                	addi	s1,s1,15
 6fa:	8091                	srli	s1,s1,0x4
 6fc:	0014899b          	addiw	s3,s1,1
 700:	0485                	addi	s1,s1,1
 702:	00000517          	auipc	a0,0x0
 706:	0e653503          	ld	a0,230(a0) # 7e8 <freep>
 70a:	c515                	beqz	a0,736 <malloc+0x58>
 70c:	611c                	ld	a5,0(a0)
 70e:	4798                	lw	a4,8(a5)
 710:	02977f63          	bgeu	a4,s1,74e <malloc+0x70>
 714:	8a4e                	mv	s4,s3
 716:	0009871b          	sext.w	a4,s3
 71a:	6685                	lui	a3,0x1
 71c:	00d77363          	bgeu	a4,a3,722 <malloc+0x44>
 720:	6a05                	lui	s4,0x1
 722:	000a0b1b          	sext.w	s6,s4
 726:	004a1a1b          	slliw	s4,s4,0x4
 72a:	00000917          	auipc	s2,0x0
 72e:	0be90913          	addi	s2,s2,190 # 7e8 <freep>
 732:	5afd                	li	s5,-1
 734:	a88d                	j	7a6 <malloc+0xc8>
 736:	00000797          	auipc	a5,0x0
 73a:	0ba78793          	addi	a5,a5,186 # 7f0 <base>
 73e:	00000717          	auipc	a4,0x0
 742:	0af73523          	sd	a5,170(a4) # 7e8 <freep>
 746:	e39c                	sd	a5,0(a5)
 748:	0007a423          	sw	zero,8(a5)
 74c:	b7e1                	j	714 <malloc+0x36>
 74e:	02e48b63          	beq	s1,a4,784 <malloc+0xa6>
 752:	4137073b          	subw	a4,a4,s3
 756:	c798                	sw	a4,8(a5)
 758:	1702                	slli	a4,a4,0x20
 75a:	9301                	srli	a4,a4,0x20
 75c:	0712                	slli	a4,a4,0x4
 75e:	97ba                	add	a5,a5,a4
 760:	0137a423          	sw	s3,8(a5)
 764:	00000717          	auipc	a4,0x0
 768:	08a73223          	sd	a0,132(a4) # 7e8 <freep>
 76c:	01078513          	addi	a0,a5,16
 770:	70e2                	ld	ra,56(sp)
 772:	7442                	ld	s0,48(sp)
 774:	74a2                	ld	s1,40(sp)
 776:	7902                	ld	s2,32(sp)
 778:	69e2                	ld	s3,24(sp)
 77a:	6a42                	ld	s4,16(sp)
 77c:	6aa2                	ld	s5,8(sp)
 77e:	6b02                	ld	s6,0(sp)
 780:	6121                	addi	sp,sp,64
 782:	8082                	ret
 784:	6398                	ld	a4,0(a5)
 786:	e118                	sd	a4,0(a0)
 788:	bff1                	j	764 <malloc+0x86>
 78a:	01652423          	sw	s6,8(a0)
 78e:	0541                	addi	a0,a0,16
 790:	00000097          	auipc	ra,0x0
 794:	ec6080e7          	jalr	-314(ra) # 656 <free>
 798:	00093503          	ld	a0,0(s2)
 79c:	d971                	beqz	a0,770 <malloc+0x92>
 79e:	611c                	ld	a5,0(a0)
 7a0:	4798                	lw	a4,8(a5)
 7a2:	fa9776e3          	bgeu	a4,s1,74e <malloc+0x70>
 7a6:	00093703          	ld	a4,0(s2)
 7aa:	853e                	mv	a0,a5
 7ac:	fef719e3          	bne	a4,a5,79e <malloc+0xc0>
 7b0:	8552                	mv	a0,s4
 7b2:	00000097          	auipc	ra,0x0
 7b6:	b76080e7          	jalr	-1162(ra) # 328 <sbrk>
 7ba:	fd5518e3          	bne	a0,s5,78a <malloc+0xac>
 7be:	4501                	li	a0,0
 7c0:	bf45                	j	770 <malloc+0x92>
=======
000000000000065e <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 65e:	1141                	addi	sp,sp,-16
 660:	e422                	sd	s0,8(sp)
 662:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 664:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 668:	00000797          	auipc	a5,0x0
 66c:	1887b783          	ld	a5,392(a5) # 7f0 <freep>
 670:	a805                	j	6a0 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 672:	4618                	lw	a4,8(a2)
 674:	9db9                	addw	a1,a1,a4
 676:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 67a:	6398                	ld	a4,0(a5)
 67c:	6318                	ld	a4,0(a4)
 67e:	fee53823          	sd	a4,-16(a0)
 682:	a091                	j	6c6 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 684:	ff852703          	lw	a4,-8(a0)
 688:	9e39                	addw	a2,a2,a4
 68a:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 68c:	ff053703          	ld	a4,-16(a0)
 690:	e398                	sd	a4,0(a5)
 692:	a099                	j	6d8 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 694:	6398                	ld	a4,0(a5)
 696:	00e7e463          	bltu	a5,a4,69e <free+0x40>
 69a:	00e6ea63          	bltu	a3,a4,6ae <free+0x50>
{
 69e:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6a0:	fed7fae3          	bgeu	a5,a3,694 <free+0x36>
 6a4:	6398                	ld	a4,0(a5)
 6a6:	00e6e463          	bltu	a3,a4,6ae <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 6aa:	fee7eae3          	bltu	a5,a4,69e <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 6ae:	ff852583          	lw	a1,-8(a0)
 6b2:	6390                	ld	a2,0(a5)
 6b4:	02059713          	slli	a4,a1,0x20
 6b8:	9301                	srli	a4,a4,0x20
 6ba:	0712                	slli	a4,a4,0x4
 6bc:	9736                	add	a4,a4,a3
 6be:	fae60ae3          	beq	a2,a4,672 <free+0x14>
    bp->s.ptr = p->s.ptr;
 6c2:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 6c6:	4790                	lw	a2,8(a5)
 6c8:	02061713          	slli	a4,a2,0x20
 6cc:	9301                	srli	a4,a4,0x20
 6ce:	0712                	slli	a4,a4,0x4
 6d0:	973e                	add	a4,a4,a5
 6d2:	fae689e3          	beq	a3,a4,684 <free+0x26>
  } else
    p->s.ptr = bp;
 6d6:	e394                	sd	a3,0(a5)
  freep = p;
 6d8:	00000717          	auipc	a4,0x0
 6dc:	10f73c23          	sd	a5,280(a4) # 7f0 <freep>
}
 6e0:	6422                	ld	s0,8(sp)
 6e2:	0141                	addi	sp,sp,16
 6e4:	8082                	ret

00000000000006e6 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 6e6:	7139                	addi	sp,sp,-64
 6e8:	fc06                	sd	ra,56(sp)
 6ea:	f822                	sd	s0,48(sp)
 6ec:	f426                	sd	s1,40(sp)
 6ee:	f04a                	sd	s2,32(sp)
 6f0:	ec4e                	sd	s3,24(sp)
 6f2:	e852                	sd	s4,16(sp)
 6f4:	e456                	sd	s5,8(sp)
 6f6:	e05a                	sd	s6,0(sp)
 6f8:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 6fa:	02051493          	slli	s1,a0,0x20
 6fe:	9081                	srli	s1,s1,0x20
 700:	04bd                	addi	s1,s1,15
 702:	8091                	srli	s1,s1,0x4
 704:	0014899b          	addiw	s3,s1,1
 708:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 70a:	00000517          	auipc	a0,0x0
 70e:	0e653503          	ld	a0,230(a0) # 7f0 <freep>
 712:	c515                	beqz	a0,73e <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 714:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 716:	4798                	lw	a4,8(a5)
 718:	02977f63          	bgeu	a4,s1,756 <malloc+0x70>
 71c:	8a4e                	mv	s4,s3
 71e:	0009871b          	sext.w	a4,s3
 722:	6685                	lui	a3,0x1
 724:	00d77363          	bgeu	a4,a3,72a <malloc+0x44>
 728:	6a05                	lui	s4,0x1
 72a:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 72e:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 732:	00000917          	auipc	s2,0x0
 736:	0be90913          	addi	s2,s2,190 # 7f0 <freep>
  if(p == (char*)-1)
 73a:	5afd                	li	s5,-1
 73c:	a88d                	j	7ae <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
 73e:	00000797          	auipc	a5,0x0
 742:	0ba78793          	addi	a5,a5,186 # 7f8 <base>
 746:	00000717          	auipc	a4,0x0
 74a:	0af73523          	sd	a5,170(a4) # 7f0 <freep>
 74e:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 750:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 754:	b7e1                	j	71c <malloc+0x36>
      if(p->s.size == nunits)
 756:	02e48b63          	beq	s1,a4,78c <malloc+0xa6>
        p->s.size -= nunits;
 75a:	4137073b          	subw	a4,a4,s3
 75e:	c798                	sw	a4,8(a5)
        p += p->s.size;
 760:	1702                	slli	a4,a4,0x20
 762:	9301                	srli	a4,a4,0x20
 764:	0712                	slli	a4,a4,0x4
 766:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 768:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 76c:	00000717          	auipc	a4,0x0
 770:	08a73223          	sd	a0,132(a4) # 7f0 <freep>
      return (void*)(p + 1);
 774:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 778:	70e2                	ld	ra,56(sp)
 77a:	7442                	ld	s0,48(sp)
 77c:	74a2                	ld	s1,40(sp)
 77e:	7902                	ld	s2,32(sp)
 780:	69e2                	ld	s3,24(sp)
 782:	6a42                	ld	s4,16(sp)
 784:	6aa2                	ld	s5,8(sp)
 786:	6b02                	ld	s6,0(sp)
 788:	6121                	addi	sp,sp,64
 78a:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 78c:	6398                	ld	a4,0(a5)
 78e:	e118                	sd	a4,0(a0)
 790:	bff1                	j	76c <malloc+0x86>
  hp->s.size = nu;
 792:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 796:	0541                	addi	a0,a0,16
 798:	00000097          	auipc	ra,0x0
 79c:	ec6080e7          	jalr	-314(ra) # 65e <free>
  return freep;
 7a0:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 7a4:	d971                	beqz	a0,778 <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7a6:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 7a8:	4798                	lw	a4,8(a5)
 7aa:	fa9776e3          	bgeu	a4,s1,756 <malloc+0x70>
    if(p == freep)
 7ae:	00093703          	ld	a4,0(s2)
 7b2:	853e                	mv	a0,a5
 7b4:	fef719e3          	bne	a4,a5,7a6 <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
 7b8:	8552                	mv	a0,s4
 7ba:	00000097          	auipc	ra,0x0
 7be:	b6e080e7          	jalr	-1170(ra) # 328 <sbrk>
  if(p == (char*)-1)
 7c2:	fd5518e3          	bne	a0,s5,792 <malloc+0xac>
        return 0;
 7c6:	4501                	li	a0,0
 7c8:	bf45                	j	778 <malloc+0x92>
>>>>>>> 355fddefdb805d91072b3597f4cbd2b4e7481a8e
