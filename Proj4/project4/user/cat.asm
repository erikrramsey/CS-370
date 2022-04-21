
user/_cat:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <cat>:

char buf[512];

void
cat(int fd)
{
   0:	7179                	addi	sp,sp,-48
   2:	f406                	sd	ra,40(sp)
   4:	f022                	sd	s0,32(sp)
   6:	ec26                	sd	s1,24(sp)
   8:	e84a                	sd	s2,16(sp)
   a:	e44e                	sd	s3,8(sp)
   c:	1800                	addi	s0,sp,48
   e:	89aa                	mv	s3,a0
  int n;

  while((n = read(fd, buf, sizeof(buf))) > 0) {
  10:	00001917          	auipc	s2,0x1
  14:	91890913          	addi	s2,s2,-1768 # 928 <buf>
  18:	20000613          	li	a2,512
  1c:	85ca                	mv	a1,s2
  1e:	854e                	mv	a0,s3
  20:	00000097          	auipc	ra,0x0
  24:	38c080e7          	jalr	908(ra) # 3ac <read>
  28:	84aa                	mv	s1,a0
  2a:	02a05963          	blez	a0,5c <cat+0x5c>
    if (write(1, buf, n) != n) {
  2e:	8626                	mv	a2,s1
  30:	85ca                	mv	a1,s2
  32:	4505                	li	a0,1
  34:	00000097          	auipc	ra,0x0
  38:	380080e7          	jalr	896(ra) # 3b4 <write>
  3c:	fc950ee3          	beq	a0,s1,18 <cat+0x18>
      fprintf(2, "cat: write error\n");
  40:	00001597          	auipc	a1,0x1
  44:	87858593          	addi	a1,a1,-1928 # 8b8 <malloc+0xe6>
  48:	4509                	li	a0,2
  4a:	00000097          	auipc	ra,0x0
  4e:	69c080e7          	jalr	1692(ra) # 6e6 <fprintf>
      exit(1);
  52:	4505                	li	a0,1
  54:	00000097          	auipc	ra,0x0
  58:	340080e7          	jalr	832(ra) # 394 <exit>
    }
  }
  if(n < 0){
  5c:	00054963          	bltz	a0,6e <cat+0x6e>
    fprintf(2, "cat: read error\n");
    exit(1);
  }
}
  60:	70a2                	ld	ra,40(sp)
  62:	7402                	ld	s0,32(sp)
  64:	64e2                	ld	s1,24(sp)
  66:	6942                	ld	s2,16(sp)
  68:	69a2                	ld	s3,8(sp)
  6a:	6145                	addi	sp,sp,48
  6c:	8082                	ret
    fprintf(2, "cat: read error\n");
  6e:	00001597          	auipc	a1,0x1
  72:	86258593          	addi	a1,a1,-1950 # 8d0 <malloc+0xfe>
  76:	4509                	li	a0,2
  78:	00000097          	auipc	ra,0x0
  7c:	66e080e7          	jalr	1646(ra) # 6e6 <fprintf>
    exit(1);
  80:	4505                	li	a0,1
  82:	00000097          	auipc	ra,0x0
  86:	312080e7          	jalr	786(ra) # 394 <exit>

000000000000008a <main>:

int
main(int argc, char *argv[])
{
  8a:	7179                	addi	sp,sp,-48
  8c:	f406                	sd	ra,40(sp)
  8e:	f022                	sd	s0,32(sp)
  90:	ec26                	sd	s1,24(sp)
  92:	e84a                	sd	s2,16(sp)
  94:	e44e                	sd	s3,8(sp)
  96:	e052                	sd	s4,0(sp)
  98:	1800                	addi	s0,sp,48
  int fd, i;

  if(argc <= 1){
  9a:	4785                	li	a5,1
  9c:	04a7d763          	bge	a5,a0,ea <main+0x60>
  a0:	00858913          	addi	s2,a1,8
  a4:	ffe5099b          	addiw	s3,a0,-2
  a8:	1982                	slli	s3,s3,0x20
  aa:	0209d993          	srli	s3,s3,0x20
  ae:	098e                	slli	s3,s3,0x3
  b0:	05c1                	addi	a1,a1,16
  b2:	99ae                	add	s3,s3,a1
    cat(0);
    exit(0);
  }

  for(i = 1; i < argc; i++){
    if((fd = open(argv[i], 0)) < 0){
  b4:	4581                	li	a1,0
  b6:	00093503          	ld	a0,0(s2)
  ba:	00000097          	auipc	ra,0x0
  be:	31a080e7          	jalr	794(ra) # 3d4 <open>
  c2:	84aa                	mv	s1,a0
  c4:	02054d63          	bltz	a0,fe <main+0x74>
      fprintf(2, "cat: cannot open %s\n", argv[i]);
      exit(1);
    }
    cat(fd);
  c8:	00000097          	auipc	ra,0x0
  cc:	f38080e7          	jalr	-200(ra) # 0 <cat>
    close(fd);
  d0:	8526                	mv	a0,s1
  d2:	00000097          	auipc	ra,0x0
  d6:	2ea080e7          	jalr	746(ra) # 3bc <close>
  for(i = 1; i < argc; i++){
  da:	0921                	addi	s2,s2,8
  dc:	fd391ce3          	bne	s2,s3,b4 <main+0x2a>
  }
  exit(0);
  e0:	4501                	li	a0,0
  e2:	00000097          	auipc	ra,0x0
  e6:	2b2080e7          	jalr	690(ra) # 394 <exit>
    cat(0);
  ea:	4501                	li	a0,0
  ec:	00000097          	auipc	ra,0x0
  f0:	f14080e7          	jalr	-236(ra) # 0 <cat>
    exit(0);
  f4:	4501                	li	a0,0
  f6:	00000097          	auipc	ra,0x0
  fa:	29e080e7          	jalr	670(ra) # 394 <exit>
      fprintf(2, "cat: cannot open %s\n", argv[i]);
  fe:	00093603          	ld	a2,0(s2)
 102:	00000597          	auipc	a1,0x0
 106:	7e658593          	addi	a1,a1,2022 # 8e8 <malloc+0x116>
 10a:	4509                	li	a0,2
 10c:	00000097          	auipc	ra,0x0
 110:	5da080e7          	jalr	1498(ra) # 6e6 <fprintf>
      exit(1);
 114:	4505                	li	a0,1
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

000000000000043c <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 43c:	1101                	addi	sp,sp,-32
 43e:	ec06                	sd	ra,24(sp)
 440:	e822                	sd	s0,16(sp)
 442:	1000                	addi	s0,sp,32
 444:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 448:	4605                	li	a2,1
 44a:	fef40593          	addi	a1,s0,-17
 44e:	00000097          	auipc	ra,0x0
 452:	f66080e7          	jalr	-154(ra) # 3b4 <write>
}
 456:	60e2                	ld	ra,24(sp)
 458:	6442                	ld	s0,16(sp)
 45a:	6105                	addi	sp,sp,32
 45c:	8082                	ret

000000000000045e <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 45e:	7139                	addi	sp,sp,-64
 460:	fc06                	sd	ra,56(sp)
 462:	f822                	sd	s0,48(sp)
 464:	f426                	sd	s1,40(sp)
 466:	f04a                	sd	s2,32(sp)
 468:	ec4e                	sd	s3,24(sp)
 46a:	0080                	addi	s0,sp,64
 46c:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 46e:	c299                	beqz	a3,474 <printint+0x16>
 470:	0805c863          	bltz	a1,500 <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 474:	2581                	sext.w	a1,a1
  neg = 0;
 476:	4881                	li	a7,0
 478:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 47c:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 47e:	2601                	sext.w	a2,a2
 480:	00000517          	auipc	a0,0x0
 484:	48850513          	addi	a0,a0,1160 # 908 <digits>
 488:	883a                	mv	a6,a4
 48a:	2705                	addiw	a4,a4,1
 48c:	02c5f7bb          	remuw	a5,a1,a2
 490:	1782                	slli	a5,a5,0x20
 492:	9381                	srli	a5,a5,0x20
 494:	97aa                	add	a5,a5,a0
 496:	0007c783          	lbu	a5,0(a5)
 49a:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 49e:	0005879b          	sext.w	a5,a1
 4a2:	02c5d5bb          	divuw	a1,a1,a2
 4a6:	0685                	addi	a3,a3,1
 4a8:	fec7f0e3          	bgeu	a5,a2,488 <printint+0x2a>
  if(neg)
 4ac:	00088b63          	beqz	a7,4c2 <printint+0x64>
    buf[i++] = '-';
 4b0:	fd040793          	addi	a5,s0,-48
 4b4:	973e                	add	a4,a4,a5
 4b6:	02d00793          	li	a5,45
 4ba:	fef70823          	sb	a5,-16(a4)
 4be:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 4c2:	02e05863          	blez	a4,4f2 <printint+0x94>
 4c6:	fc040793          	addi	a5,s0,-64
 4ca:	00e78933          	add	s2,a5,a4
 4ce:	fff78993          	addi	s3,a5,-1
 4d2:	99ba                	add	s3,s3,a4
 4d4:	377d                	addiw	a4,a4,-1
 4d6:	1702                	slli	a4,a4,0x20
 4d8:	9301                	srli	a4,a4,0x20
 4da:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 4de:	fff94583          	lbu	a1,-1(s2)
 4e2:	8526                	mv	a0,s1
 4e4:	00000097          	auipc	ra,0x0
 4e8:	f58080e7          	jalr	-168(ra) # 43c <putc>
  while(--i >= 0)
 4ec:	197d                	addi	s2,s2,-1
 4ee:	ff3918e3          	bne	s2,s3,4de <printint+0x80>
}
 4f2:	70e2                	ld	ra,56(sp)
 4f4:	7442                	ld	s0,48(sp)
 4f6:	74a2                	ld	s1,40(sp)
 4f8:	7902                	ld	s2,32(sp)
 4fa:	69e2                	ld	s3,24(sp)
 4fc:	6121                	addi	sp,sp,64
 4fe:	8082                	ret
    x = -xx;
 500:	40b005bb          	negw	a1,a1
    neg = 1;
 504:	4885                	li	a7,1
    x = -xx;
 506:	bf8d                	j	478 <printint+0x1a>

0000000000000508 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 508:	7119                	addi	sp,sp,-128
 50a:	fc86                	sd	ra,120(sp)
 50c:	f8a2                	sd	s0,112(sp)
 50e:	f4a6                	sd	s1,104(sp)
 510:	f0ca                	sd	s2,96(sp)
 512:	ecce                	sd	s3,88(sp)
 514:	e8d2                	sd	s4,80(sp)
 516:	e4d6                	sd	s5,72(sp)
 518:	e0da                	sd	s6,64(sp)
 51a:	fc5e                	sd	s7,56(sp)
 51c:	f862                	sd	s8,48(sp)
 51e:	f466                	sd	s9,40(sp)
 520:	f06a                	sd	s10,32(sp)
 522:	ec6e                	sd	s11,24(sp)
 524:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 526:	0005c903          	lbu	s2,0(a1)
 52a:	18090f63          	beqz	s2,6c8 <vprintf+0x1c0>
 52e:	8aaa                	mv	s5,a0
 530:	8b32                	mv	s6,a2
 532:	00158493          	addi	s1,a1,1
  state = 0;
 536:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 538:	02500a13          	li	s4,37
      if(c == 'd'){
 53c:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 540:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 544:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 548:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 54c:	00000b97          	auipc	s7,0x0
 550:	3bcb8b93          	addi	s7,s7,956 # 908 <digits>
 554:	a839                	j	572 <vprintf+0x6a>
        putc(fd, c);
 556:	85ca                	mv	a1,s2
 558:	8556                	mv	a0,s5
 55a:	00000097          	auipc	ra,0x0
 55e:	ee2080e7          	jalr	-286(ra) # 43c <putc>
 562:	a019                	j	568 <vprintf+0x60>
    } else if(state == '%'){
 564:	01498f63          	beq	s3,s4,582 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 568:	0485                	addi	s1,s1,1
 56a:	fff4c903          	lbu	s2,-1(s1)
 56e:	14090d63          	beqz	s2,6c8 <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 572:	0009079b          	sext.w	a5,s2
    if(state == 0){
 576:	fe0997e3          	bnez	s3,564 <vprintf+0x5c>
      if(c == '%'){
 57a:	fd479ee3          	bne	a5,s4,556 <vprintf+0x4e>
        state = '%';
 57e:	89be                	mv	s3,a5
 580:	b7e5                	j	568 <vprintf+0x60>
      if(c == 'd'){
 582:	05878063          	beq	a5,s8,5c2 <vprintf+0xba>
      } else if(c == 'l') {
 586:	05978c63          	beq	a5,s9,5de <vprintf+0xd6>
      } else if(c == 'x') {
 58a:	07a78863          	beq	a5,s10,5fa <vprintf+0xf2>
      } else if(c == 'p') {
 58e:	09b78463          	beq	a5,s11,616 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 592:	07300713          	li	a4,115
 596:	0ce78663          	beq	a5,a4,662 <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 59a:	06300713          	li	a4,99
 59e:	0ee78e63          	beq	a5,a4,69a <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 5a2:	11478863          	beq	a5,s4,6b2 <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 5a6:	85d2                	mv	a1,s4
 5a8:	8556                	mv	a0,s5
 5aa:	00000097          	auipc	ra,0x0
 5ae:	e92080e7          	jalr	-366(ra) # 43c <putc>
        putc(fd, c);
 5b2:	85ca                	mv	a1,s2
 5b4:	8556                	mv	a0,s5
 5b6:	00000097          	auipc	ra,0x0
 5ba:	e86080e7          	jalr	-378(ra) # 43c <putc>
      }
      state = 0;
 5be:	4981                	li	s3,0
 5c0:	b765                	j	568 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 5c2:	008b0913          	addi	s2,s6,8
 5c6:	4685                	li	a3,1
 5c8:	4629                	li	a2,10
 5ca:	000b2583          	lw	a1,0(s6)
 5ce:	8556                	mv	a0,s5
 5d0:	00000097          	auipc	ra,0x0
 5d4:	e8e080e7          	jalr	-370(ra) # 45e <printint>
 5d8:	8b4a                	mv	s6,s2
      state = 0;
 5da:	4981                	li	s3,0
 5dc:	b771                	j	568 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 5de:	008b0913          	addi	s2,s6,8
 5e2:	4681                	li	a3,0
 5e4:	4629                	li	a2,10
 5e6:	000b2583          	lw	a1,0(s6)
 5ea:	8556                	mv	a0,s5
 5ec:	00000097          	auipc	ra,0x0
 5f0:	e72080e7          	jalr	-398(ra) # 45e <printint>
 5f4:	8b4a                	mv	s6,s2
      state = 0;
 5f6:	4981                	li	s3,0
 5f8:	bf85                	j	568 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 5fa:	008b0913          	addi	s2,s6,8
 5fe:	4681                	li	a3,0
 600:	4641                	li	a2,16
 602:	000b2583          	lw	a1,0(s6)
 606:	8556                	mv	a0,s5
 608:	00000097          	auipc	ra,0x0
 60c:	e56080e7          	jalr	-426(ra) # 45e <printint>
 610:	8b4a                	mv	s6,s2
      state = 0;
 612:	4981                	li	s3,0
 614:	bf91                	j	568 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 616:	008b0793          	addi	a5,s6,8
 61a:	f8f43423          	sd	a5,-120(s0)
 61e:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 622:	03000593          	li	a1,48
 626:	8556                	mv	a0,s5
 628:	00000097          	auipc	ra,0x0
 62c:	e14080e7          	jalr	-492(ra) # 43c <putc>
  putc(fd, 'x');
 630:	85ea                	mv	a1,s10
 632:	8556                	mv	a0,s5
 634:	00000097          	auipc	ra,0x0
 638:	e08080e7          	jalr	-504(ra) # 43c <putc>
 63c:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 63e:	03c9d793          	srli	a5,s3,0x3c
 642:	97de                	add	a5,a5,s7
 644:	0007c583          	lbu	a1,0(a5)
 648:	8556                	mv	a0,s5
 64a:	00000097          	auipc	ra,0x0
 64e:	df2080e7          	jalr	-526(ra) # 43c <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 652:	0992                	slli	s3,s3,0x4
 654:	397d                	addiw	s2,s2,-1
 656:	fe0914e3          	bnez	s2,63e <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 65a:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 65e:	4981                	li	s3,0
 660:	b721                	j	568 <vprintf+0x60>
        s = va_arg(ap, char*);
 662:	008b0993          	addi	s3,s6,8
 666:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 66a:	02090163          	beqz	s2,68c <vprintf+0x184>
        while(*s != 0){
 66e:	00094583          	lbu	a1,0(s2)
 672:	c9a1                	beqz	a1,6c2 <vprintf+0x1ba>
          putc(fd, *s);
 674:	8556                	mv	a0,s5
 676:	00000097          	auipc	ra,0x0
 67a:	dc6080e7          	jalr	-570(ra) # 43c <putc>
          s++;
 67e:	0905                	addi	s2,s2,1
        while(*s != 0){
 680:	00094583          	lbu	a1,0(s2)
 684:	f9e5                	bnez	a1,674 <vprintf+0x16c>
        s = va_arg(ap, char*);
 686:	8b4e                	mv	s6,s3
      state = 0;
 688:	4981                	li	s3,0
 68a:	bdf9                	j	568 <vprintf+0x60>
          s = "(null)";
 68c:	00000917          	auipc	s2,0x0
 690:	27490913          	addi	s2,s2,628 # 900 <malloc+0x12e>
        while(*s != 0){
 694:	02800593          	li	a1,40
 698:	bff1                	j	674 <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 69a:	008b0913          	addi	s2,s6,8
 69e:	000b4583          	lbu	a1,0(s6)
 6a2:	8556                	mv	a0,s5
 6a4:	00000097          	auipc	ra,0x0
 6a8:	d98080e7          	jalr	-616(ra) # 43c <putc>
 6ac:	8b4a                	mv	s6,s2
      state = 0;
 6ae:	4981                	li	s3,0
 6b0:	bd65                	j	568 <vprintf+0x60>
        putc(fd, c);
 6b2:	85d2                	mv	a1,s4
 6b4:	8556                	mv	a0,s5
 6b6:	00000097          	auipc	ra,0x0
 6ba:	d86080e7          	jalr	-634(ra) # 43c <putc>
      state = 0;
 6be:	4981                	li	s3,0
 6c0:	b565                	j	568 <vprintf+0x60>
        s = va_arg(ap, char*);
 6c2:	8b4e                	mv	s6,s3
      state = 0;
 6c4:	4981                	li	s3,0
 6c6:	b54d                	j	568 <vprintf+0x60>
    }
  }
}
 6c8:	70e6                	ld	ra,120(sp)
 6ca:	7446                	ld	s0,112(sp)
 6cc:	74a6                	ld	s1,104(sp)
 6ce:	7906                	ld	s2,96(sp)
 6d0:	69e6                	ld	s3,88(sp)
 6d2:	6a46                	ld	s4,80(sp)
 6d4:	6aa6                	ld	s5,72(sp)
 6d6:	6b06                	ld	s6,64(sp)
 6d8:	7be2                	ld	s7,56(sp)
 6da:	7c42                	ld	s8,48(sp)
 6dc:	7ca2                	ld	s9,40(sp)
 6de:	7d02                	ld	s10,32(sp)
 6e0:	6de2                	ld	s11,24(sp)
 6e2:	6109                	addi	sp,sp,128
 6e4:	8082                	ret

00000000000006e6 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 6e6:	715d                	addi	sp,sp,-80
 6e8:	ec06                	sd	ra,24(sp)
 6ea:	e822                	sd	s0,16(sp)
 6ec:	1000                	addi	s0,sp,32
 6ee:	e010                	sd	a2,0(s0)
 6f0:	e414                	sd	a3,8(s0)
 6f2:	e818                	sd	a4,16(s0)
 6f4:	ec1c                	sd	a5,24(s0)
 6f6:	03043023          	sd	a6,32(s0)
 6fa:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 6fe:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 702:	8622                	mv	a2,s0
 704:	00000097          	auipc	ra,0x0
 708:	e04080e7          	jalr	-508(ra) # 508 <vprintf>
}
 70c:	60e2                	ld	ra,24(sp)
 70e:	6442                	ld	s0,16(sp)
 710:	6161                	addi	sp,sp,80
 712:	8082                	ret

0000000000000714 <printf>:

void
printf(const char *fmt, ...)
{
 714:	711d                	addi	sp,sp,-96
 716:	ec06                	sd	ra,24(sp)
 718:	e822                	sd	s0,16(sp)
 71a:	1000                	addi	s0,sp,32
 71c:	e40c                	sd	a1,8(s0)
 71e:	e810                	sd	a2,16(s0)
 720:	ec14                	sd	a3,24(s0)
 722:	f018                	sd	a4,32(s0)
 724:	f41c                	sd	a5,40(s0)
 726:	03043823          	sd	a6,48(s0)
 72a:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 72e:	00840613          	addi	a2,s0,8
 732:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 736:	85aa                	mv	a1,a0
 738:	4505                	li	a0,1
 73a:	00000097          	auipc	ra,0x0
 73e:	dce080e7          	jalr	-562(ra) # 508 <vprintf>
}
 742:	60e2                	ld	ra,24(sp)
 744:	6442                	ld	s0,16(sp)
 746:	6125                	addi	sp,sp,96
 748:	8082                	ret

000000000000074a <free>:
 74a:	1141                	addi	sp,sp,-16
 74c:	e422                	sd	s0,8(sp)
 74e:	0800                	addi	s0,sp,16
 750:	ff050693          	addi	a3,a0,-16
 754:	00000797          	auipc	a5,0x0
 758:	1cc7b783          	ld	a5,460(a5) # 920 <freep>
 75c:	a805                	j	78c <free+0x42>
 75e:	4618                	lw	a4,8(a2)
 760:	9db9                	addw	a1,a1,a4
 762:	feb52c23          	sw	a1,-8(a0)
 766:	6398                	ld	a4,0(a5)
 768:	6318                	ld	a4,0(a4)
 76a:	fee53823          	sd	a4,-16(a0)
 76e:	a091                	j	7b2 <free+0x68>
 770:	ff852703          	lw	a4,-8(a0)
 774:	9e39                	addw	a2,a2,a4
 776:	c790                	sw	a2,8(a5)
 778:	ff053703          	ld	a4,-16(a0)
 77c:	e398                	sd	a4,0(a5)
 77e:	a099                	j	7c4 <free+0x7a>
 780:	6398                	ld	a4,0(a5)
 782:	00e7e463          	bltu	a5,a4,78a <free+0x40>
 786:	00e6ea63          	bltu	a3,a4,79a <free+0x50>
 78a:	87ba                	mv	a5,a4
 78c:	fed7fae3          	bgeu	a5,a3,780 <free+0x36>
 790:	6398                	ld	a4,0(a5)
 792:	00e6e463          	bltu	a3,a4,79a <free+0x50>
 796:	fee7eae3          	bltu	a5,a4,78a <free+0x40>
 79a:	ff852583          	lw	a1,-8(a0)
 79e:	6390                	ld	a2,0(a5)
 7a0:	02059713          	slli	a4,a1,0x20
 7a4:	9301                	srli	a4,a4,0x20
 7a6:	0712                	slli	a4,a4,0x4
 7a8:	9736                	add	a4,a4,a3
 7aa:	fae60ae3          	beq	a2,a4,75e <free+0x14>
 7ae:	fec53823          	sd	a2,-16(a0)
 7b2:	4790                	lw	a2,8(a5)
 7b4:	02061713          	slli	a4,a2,0x20
 7b8:	9301                	srli	a4,a4,0x20
 7ba:	0712                	slli	a4,a4,0x4
 7bc:	973e                	add	a4,a4,a5
 7be:	fae689e3          	beq	a3,a4,770 <free+0x26>
 7c2:	e394                	sd	a3,0(a5)
 7c4:	00000717          	auipc	a4,0x0
 7c8:	14f73e23          	sd	a5,348(a4) # 920 <freep>
 7cc:	6422                	ld	s0,8(sp)
 7ce:	0141                	addi	sp,sp,16
 7d0:	8082                	ret

00000000000007d2 <malloc>:
 7d2:	7139                	addi	sp,sp,-64
 7d4:	fc06                	sd	ra,56(sp)
 7d6:	f822                	sd	s0,48(sp)
 7d8:	f426                	sd	s1,40(sp)
 7da:	f04a                	sd	s2,32(sp)
 7dc:	ec4e                	sd	s3,24(sp)
 7de:	e852                	sd	s4,16(sp)
 7e0:	e456                	sd	s5,8(sp)
 7e2:	e05a                	sd	s6,0(sp)
 7e4:	0080                	addi	s0,sp,64
 7e6:	02051493          	slli	s1,a0,0x20
 7ea:	9081                	srli	s1,s1,0x20
 7ec:	04bd                	addi	s1,s1,15
 7ee:	8091                	srli	s1,s1,0x4
 7f0:	0014899b          	addiw	s3,s1,1
 7f4:	0485                	addi	s1,s1,1
 7f6:	00000517          	auipc	a0,0x0
 7fa:	12a53503          	ld	a0,298(a0) # 920 <freep>
 7fe:	c515                	beqz	a0,82a <malloc+0x58>
 800:	611c                	ld	a5,0(a0)
 802:	4798                	lw	a4,8(a5)
 804:	02977f63          	bgeu	a4,s1,842 <malloc+0x70>
 808:	8a4e                	mv	s4,s3
 80a:	0009871b          	sext.w	a4,s3
 80e:	6685                	lui	a3,0x1
 810:	00d77363          	bgeu	a4,a3,816 <malloc+0x44>
 814:	6a05                	lui	s4,0x1
 816:	000a0b1b          	sext.w	s6,s4
 81a:	004a1a1b          	slliw	s4,s4,0x4
 81e:	00000917          	auipc	s2,0x0
 822:	10290913          	addi	s2,s2,258 # 920 <freep>
 826:	5afd                	li	s5,-1
 828:	a88d                	j	89a <malloc+0xc8>
 82a:	00000797          	auipc	a5,0x0
 82e:	2fe78793          	addi	a5,a5,766 # b28 <base>
 832:	00000717          	auipc	a4,0x0
 836:	0ef73723          	sd	a5,238(a4) # 920 <freep>
 83a:	e39c                	sd	a5,0(a5)
 83c:	0007a423          	sw	zero,8(a5)
 840:	b7e1                	j	808 <malloc+0x36>
 842:	02e48b63          	beq	s1,a4,878 <malloc+0xa6>
 846:	4137073b          	subw	a4,a4,s3
 84a:	c798                	sw	a4,8(a5)
 84c:	1702                	slli	a4,a4,0x20
 84e:	9301                	srli	a4,a4,0x20
 850:	0712                	slli	a4,a4,0x4
 852:	97ba                	add	a5,a5,a4
 854:	0137a423          	sw	s3,8(a5)
 858:	00000717          	auipc	a4,0x0
 85c:	0ca73423          	sd	a0,200(a4) # 920 <freep>
 860:	01078513          	addi	a0,a5,16
 864:	70e2                	ld	ra,56(sp)
 866:	7442                	ld	s0,48(sp)
 868:	74a2                	ld	s1,40(sp)
 86a:	7902                	ld	s2,32(sp)
 86c:	69e2                	ld	s3,24(sp)
 86e:	6a42                	ld	s4,16(sp)
 870:	6aa2                	ld	s5,8(sp)
 872:	6b02                	ld	s6,0(sp)
 874:	6121                	addi	sp,sp,64
 876:	8082                	ret
 878:	6398                	ld	a4,0(a5)
 87a:	e118                	sd	a4,0(a0)
 87c:	bff1                	j	858 <malloc+0x86>
 87e:	01652423          	sw	s6,8(a0)
 882:	0541                	addi	a0,a0,16
 884:	00000097          	auipc	ra,0x0
 888:	ec6080e7          	jalr	-314(ra) # 74a <free>
 88c:	00093503          	ld	a0,0(s2)
 890:	d971                	beqz	a0,864 <malloc+0x92>
 892:	611c                	ld	a5,0(a0)
 894:	4798                	lw	a4,8(a5)
 896:	fa9776e3          	bgeu	a4,s1,842 <malloc+0x70>
 89a:	00093703          	ld	a4,0(s2)
 89e:	853e                	mv	a0,a5
 8a0:	fef719e3          	bne	a4,a5,892 <malloc+0xc0>
 8a4:	8552                	mv	a0,s4
 8a6:	00000097          	auipc	ra,0x0
 8aa:	b76080e7          	jalr	-1162(ra) # 41c <sbrk>
 8ae:	fd5518e3          	bne	a0,s5,87e <malloc+0xac>
 8b2:	4501                	li	a0,0
 8b4:	bf45                	j	864 <malloc+0x92>
