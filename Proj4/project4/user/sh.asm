
user/_sh:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <getcmd>:
       0:	1101                	addi	sp,sp,-32
       2:	ec06                	sd	ra,24(sp)
       4:	e822                	sd	s0,16(sp)
       6:	e426                	sd	s1,8(sp)
       8:	e04a                	sd	s2,0(sp)
       a:	1000                	addi	s0,sp,32
       c:	84aa                	mv	s1,a0
       e:	892e                	mv	s2,a1
      10:	00001597          	auipc	a1,0x1
      14:	2e858593          	addi	a1,a1,744 # 12f8 <malloc+0xe8>
      18:	4509                	li	a0,2
      1a:	00001097          	auipc	ra,0x1
<<<<<<< HEAD
      1e:	102080e7          	jalr	258(ra) # 111c <fprintf>
=======
      1e:	10a080e7          	jalr	266(ra) # 1124 <fprintf>
  memset(buf, 0, nbuf);
>>>>>>> 355fddefdb805d91072b3597f4cbd2b4e7481a8e
      22:	864a                	mv	a2,s2
      24:	4581                	li	a1,0
      26:	8526                	mv	a0,s1
      28:	00001097          	auipc	ra,0x1
      2c:	b9e080e7          	jalr	-1122(ra) # bc6 <memset>
      30:	85ca                	mv	a1,s2
      32:	8526                	mv	a0,s1
      34:	00001097          	auipc	ra,0x1
      38:	bdc080e7          	jalr	-1060(ra) # c10 <gets>
      3c:	0004c503          	lbu	a0,0(s1)
      40:	00153513          	seqz	a0,a0
      44:	40a00533          	neg	a0,a0
      48:	60e2                	ld	ra,24(sp)
      4a:	6442                	ld	s0,16(sp)
      4c:	64a2                	ld	s1,8(sp)
      4e:	6902                	ld	s2,0(sp)
      50:	6105                	addi	sp,sp,32
      52:	8082                	ret

0000000000000054 <panic>:
      54:	1141                	addi	sp,sp,-16
      56:	e406                	sd	ra,8(sp)
      58:	e022                	sd	s0,0(sp)
      5a:	0800                	addi	s0,sp,16
      5c:	862a                	mv	a2,a0
      5e:	00001597          	auipc	a1,0x1
      62:	2a258593          	addi	a1,a1,674 # 1300 <malloc+0xf0>
      66:	4509                	li	a0,2
      68:	00001097          	auipc	ra,0x1
<<<<<<< HEAD
      6c:	0b4080e7          	jalr	180(ra) # 111c <fprintf>
=======
      6c:	0bc080e7          	jalr	188(ra) # 1124 <fprintf>
  exit(1);
>>>>>>> 355fddefdb805d91072b3597f4cbd2b4e7481a8e
      70:	4505                	li	a0,1
      72:	00001097          	auipc	ra,0x1
      76:	d58080e7          	jalr	-680(ra) # dca <exit>

000000000000007a <fork1>:
      7a:	1141                	addi	sp,sp,-16
      7c:	e406                	sd	ra,8(sp)
      7e:	e022                	sd	s0,0(sp)
      80:	0800                	addi	s0,sp,16
      82:	00001097          	auipc	ra,0x1
      86:	d40080e7          	jalr	-704(ra) # dc2 <fork>
      8a:	57fd                	li	a5,-1
      8c:	00f50663          	beq	a0,a5,98 <fork1+0x1e>
      90:	60a2                	ld	ra,8(sp)
      92:	6402                	ld	s0,0(sp)
      94:	0141                	addi	sp,sp,16
      96:	8082                	ret
      98:	00001517          	auipc	a0,0x1
      9c:	27050513          	addi	a0,a0,624 # 1308 <malloc+0xf8>
      a0:	00000097          	auipc	ra,0x0
      a4:	fb4080e7          	jalr	-76(ra) # 54 <panic>

00000000000000a8 <runcmd>:
      a8:	7179                	addi	sp,sp,-48
      aa:	f406                	sd	ra,40(sp)
      ac:	f022                	sd	s0,32(sp)
      ae:	ec26                	sd	s1,24(sp)
      b0:	1800                	addi	s0,sp,48
      b2:	c10d                	beqz	a0,d4 <runcmd+0x2c>
      b4:	84aa                	mv	s1,a0
      b6:	4118                	lw	a4,0(a0)
      b8:	4795                	li	a5,5
      ba:	02e7e263          	bltu	a5,a4,de <runcmd+0x36>
      be:	00056783          	lwu	a5,0(a0)
      c2:	078a                	slli	a5,a5,0x2
      c4:	00001717          	auipc	a4,0x1
      c8:	34470713          	addi	a4,a4,836 # 1408 <malloc+0x1f8>
      cc:	97ba                	add	a5,a5,a4
      ce:	439c                	lw	a5,0(a5)
      d0:	97ba                	add	a5,a5,a4
      d2:	8782                	jr	a5
      d4:	4505                	li	a0,1
      d6:	00001097          	auipc	ra,0x1
      da:	cf4080e7          	jalr	-780(ra) # dca <exit>
      de:	00001517          	auipc	a0,0x1
      e2:	23250513          	addi	a0,a0,562 # 1310 <malloc+0x100>
      e6:	00000097          	auipc	ra,0x0
      ea:	f6e080e7          	jalr	-146(ra) # 54 <panic>
      ee:	6508                	ld	a0,8(a0)
      f0:	c515                	beqz	a0,11c <runcmd+0x74>
      f2:	00848593          	addi	a1,s1,8
      f6:	00001097          	auipc	ra,0x1
      fa:	d0c080e7          	jalr	-756(ra) # e02 <exec>
      fe:	6490                	ld	a2,8(s1)
     100:	00001597          	auipc	a1,0x1
     104:	21858593          	addi	a1,a1,536 # 1318 <malloc+0x108>
     108:	4509                	li	a0,2
     10a:	00001097          	auipc	ra,0x1
<<<<<<< HEAD
     10e:	012080e7          	jalr	18(ra) # 111c <fprintf>
=======
     10e:	01a080e7          	jalr	26(ra) # 1124 <fprintf>
  exit(0);
>>>>>>> 355fddefdb805d91072b3597f4cbd2b4e7481a8e
     112:	4501                	li	a0,0
     114:	00001097          	auipc	ra,0x1
     118:	cb6080e7          	jalr	-842(ra) # dca <exit>
     11c:	4505                	li	a0,1
     11e:	00001097          	auipc	ra,0x1
     122:	cac080e7          	jalr	-852(ra) # dca <exit>
     126:	5148                	lw	a0,36(a0)
     128:	00001097          	auipc	ra,0x1
     12c:	cca080e7          	jalr	-822(ra) # df2 <close>
     130:	508c                	lw	a1,32(s1)
     132:	6888                	ld	a0,16(s1)
     134:	00001097          	auipc	ra,0x1
     138:	cd6080e7          	jalr	-810(ra) # e0a <open>
     13c:	00054763          	bltz	a0,14a <runcmd+0xa2>
     140:	6488                	ld	a0,8(s1)
     142:	00000097          	auipc	ra,0x0
     146:	f66080e7          	jalr	-154(ra) # a8 <runcmd>
     14a:	6890                	ld	a2,16(s1)
     14c:	00001597          	auipc	a1,0x1
     150:	1dc58593          	addi	a1,a1,476 # 1328 <malloc+0x118>
     154:	4509                	li	a0,2
     156:	00001097          	auipc	ra,0x1
<<<<<<< HEAD
     15a:	fc6080e7          	jalr	-58(ra) # 111c <fprintf>
=======
     15a:	fce080e7          	jalr	-50(ra) # 1124 <fprintf>
      exit(1);
>>>>>>> 355fddefdb805d91072b3597f4cbd2b4e7481a8e
     15e:	4505                	li	a0,1
     160:	00001097          	auipc	ra,0x1
     164:	c6a080e7          	jalr	-918(ra) # dca <exit>
     168:	00000097          	auipc	ra,0x0
     16c:	f12080e7          	jalr	-238(ra) # 7a <fork1>
     170:	c919                	beqz	a0,186 <runcmd+0xde>
     172:	4501                	li	a0,0
     174:	00001097          	auipc	ra,0x1
     178:	c5e080e7          	jalr	-930(ra) # dd2 <wait>
     17c:	6888                	ld	a0,16(s1)
     17e:	00000097          	auipc	ra,0x0
     182:	f2a080e7          	jalr	-214(ra) # a8 <runcmd>
     186:	6488                	ld	a0,8(s1)
     188:	00000097          	auipc	ra,0x0
     18c:	f20080e7          	jalr	-224(ra) # a8 <runcmd>
     190:	fd840513          	addi	a0,s0,-40
     194:	00001097          	auipc	ra,0x1
     198:	c46080e7          	jalr	-954(ra) # dda <pipe>
     19c:	04054363          	bltz	a0,1e2 <runcmd+0x13a>
     1a0:	00000097          	auipc	ra,0x0
     1a4:	eda080e7          	jalr	-294(ra) # 7a <fork1>
     1a8:	c529                	beqz	a0,1f2 <runcmd+0x14a>
     1aa:	00000097          	auipc	ra,0x0
     1ae:	ed0080e7          	jalr	-304(ra) # 7a <fork1>
     1b2:	cd25                	beqz	a0,22a <runcmd+0x182>
     1b4:	fd842503          	lw	a0,-40(s0)
     1b8:	00001097          	auipc	ra,0x1
     1bc:	c3a080e7          	jalr	-966(ra) # df2 <close>
     1c0:	fdc42503          	lw	a0,-36(s0)
     1c4:	00001097          	auipc	ra,0x1
     1c8:	c2e080e7          	jalr	-978(ra) # df2 <close>
     1cc:	4501                	li	a0,0
     1ce:	00001097          	auipc	ra,0x1
     1d2:	c04080e7          	jalr	-1020(ra) # dd2 <wait>
     1d6:	4501                	li	a0,0
     1d8:	00001097          	auipc	ra,0x1
     1dc:	bfa080e7          	jalr	-1030(ra) # dd2 <wait>
     1e0:	bf0d                	j	112 <runcmd+0x6a>
     1e2:	00001517          	auipc	a0,0x1
     1e6:	15650513          	addi	a0,a0,342 # 1338 <malloc+0x128>
     1ea:	00000097          	auipc	ra,0x0
     1ee:	e6a080e7          	jalr	-406(ra) # 54 <panic>
     1f2:	4505                	li	a0,1
     1f4:	00001097          	auipc	ra,0x1
     1f8:	bfe080e7          	jalr	-1026(ra) # df2 <close>
     1fc:	fdc42503          	lw	a0,-36(s0)
     200:	00001097          	auipc	ra,0x1
     204:	c42080e7          	jalr	-958(ra) # e42 <dup>
     208:	fd842503          	lw	a0,-40(s0)
     20c:	00001097          	auipc	ra,0x1
     210:	be6080e7          	jalr	-1050(ra) # df2 <close>
     214:	fdc42503          	lw	a0,-36(s0)
     218:	00001097          	auipc	ra,0x1
     21c:	bda080e7          	jalr	-1062(ra) # df2 <close>
     220:	6488                	ld	a0,8(s1)
     222:	00000097          	auipc	ra,0x0
     226:	e86080e7          	jalr	-378(ra) # a8 <runcmd>
     22a:	00001097          	auipc	ra,0x1
     22e:	bc8080e7          	jalr	-1080(ra) # df2 <close>
     232:	fd842503          	lw	a0,-40(s0)
     236:	00001097          	auipc	ra,0x1
     23a:	c0c080e7          	jalr	-1012(ra) # e42 <dup>
     23e:	fd842503          	lw	a0,-40(s0)
     242:	00001097          	auipc	ra,0x1
     246:	bb0080e7          	jalr	-1104(ra) # df2 <close>
     24a:	fdc42503          	lw	a0,-36(s0)
     24e:	00001097          	auipc	ra,0x1
     252:	ba4080e7          	jalr	-1116(ra) # df2 <close>
     256:	6888                	ld	a0,16(s1)
     258:	00000097          	auipc	ra,0x0
     25c:	e50080e7          	jalr	-432(ra) # a8 <runcmd>
     260:	00000097          	auipc	ra,0x0
     264:	e1a080e7          	jalr	-486(ra) # 7a <fork1>
     268:	ea0515e3          	bnez	a0,112 <runcmd+0x6a>
     26c:	6488                	ld	a0,8(s1)
     26e:	00000097          	auipc	ra,0x0
     272:	e3a080e7          	jalr	-454(ra) # a8 <runcmd>

0000000000000276 <execcmd>:
     276:	1101                	addi	sp,sp,-32
     278:	ec06                	sd	ra,24(sp)
     27a:	e822                	sd	s0,16(sp)
     27c:	e426                	sd	s1,8(sp)
     27e:	1000                	addi	s0,sp,32
     280:	0a800513          	li	a0,168
     284:	00001097          	auipc	ra,0x1
     288:	f8c080e7          	jalr	-116(ra) # 1210 <malloc>
     28c:	84aa                	mv	s1,a0
     28e:	0a800613          	li	a2,168
     292:	4581                	li	a1,0
     294:	00001097          	auipc	ra,0x1
     298:	932080e7          	jalr	-1742(ra) # bc6 <memset>
     29c:	4785                	li	a5,1
     29e:	c09c                	sw	a5,0(s1)
     2a0:	8526                	mv	a0,s1
     2a2:	60e2                	ld	ra,24(sp)
     2a4:	6442                	ld	s0,16(sp)
     2a6:	64a2                	ld	s1,8(sp)
     2a8:	6105                	addi	sp,sp,32
     2aa:	8082                	ret

00000000000002ac <redircmd>:
     2ac:	7139                	addi	sp,sp,-64
     2ae:	fc06                	sd	ra,56(sp)
     2b0:	f822                	sd	s0,48(sp)
     2b2:	f426                	sd	s1,40(sp)
     2b4:	f04a                	sd	s2,32(sp)
     2b6:	ec4e                	sd	s3,24(sp)
     2b8:	e852                	sd	s4,16(sp)
     2ba:	e456                	sd	s5,8(sp)
     2bc:	e05a                	sd	s6,0(sp)
     2be:	0080                	addi	s0,sp,64
     2c0:	8b2a                	mv	s6,a0
     2c2:	8aae                	mv	s5,a1
     2c4:	8a32                	mv	s4,a2
     2c6:	89b6                	mv	s3,a3
     2c8:	893a                	mv	s2,a4
     2ca:	02800513          	li	a0,40
     2ce:	00001097          	auipc	ra,0x1
     2d2:	f42080e7          	jalr	-190(ra) # 1210 <malloc>
     2d6:	84aa                	mv	s1,a0
     2d8:	02800613          	li	a2,40
     2dc:	4581                	li	a1,0
     2de:	00001097          	auipc	ra,0x1
     2e2:	8e8080e7          	jalr	-1816(ra) # bc6 <memset>
     2e6:	4789                	li	a5,2
     2e8:	c09c                	sw	a5,0(s1)
     2ea:	0164b423          	sd	s6,8(s1)
     2ee:	0154b823          	sd	s5,16(s1)
     2f2:	0144bc23          	sd	s4,24(s1)
     2f6:	0334a023          	sw	s3,32(s1)
     2fa:	0324a223          	sw	s2,36(s1)
     2fe:	8526                	mv	a0,s1
     300:	70e2                	ld	ra,56(sp)
     302:	7442                	ld	s0,48(sp)
     304:	74a2                	ld	s1,40(sp)
     306:	7902                	ld	s2,32(sp)
     308:	69e2                	ld	s3,24(sp)
     30a:	6a42                	ld	s4,16(sp)
     30c:	6aa2                	ld	s5,8(sp)
     30e:	6b02                	ld	s6,0(sp)
     310:	6121                	addi	sp,sp,64
     312:	8082                	ret

0000000000000314 <pipecmd>:
     314:	7179                	addi	sp,sp,-48
     316:	f406                	sd	ra,40(sp)
     318:	f022                	sd	s0,32(sp)
     31a:	ec26                	sd	s1,24(sp)
     31c:	e84a                	sd	s2,16(sp)
     31e:	e44e                	sd	s3,8(sp)
     320:	1800                	addi	s0,sp,48
     322:	89aa                	mv	s3,a0
     324:	892e                	mv	s2,a1
     326:	4561                	li	a0,24
     328:	00001097          	auipc	ra,0x1
     32c:	ee8080e7          	jalr	-280(ra) # 1210 <malloc>
     330:	84aa                	mv	s1,a0
     332:	4661                	li	a2,24
     334:	4581                	li	a1,0
     336:	00001097          	auipc	ra,0x1
     33a:	890080e7          	jalr	-1904(ra) # bc6 <memset>
     33e:	478d                	li	a5,3
     340:	c09c                	sw	a5,0(s1)
     342:	0134b423          	sd	s3,8(s1)
     346:	0124b823          	sd	s2,16(s1)
     34a:	8526                	mv	a0,s1
     34c:	70a2                	ld	ra,40(sp)
     34e:	7402                	ld	s0,32(sp)
     350:	64e2                	ld	s1,24(sp)
     352:	6942                	ld	s2,16(sp)
     354:	69a2                	ld	s3,8(sp)
     356:	6145                	addi	sp,sp,48
     358:	8082                	ret

000000000000035a <listcmd>:
     35a:	7179                	addi	sp,sp,-48
     35c:	f406                	sd	ra,40(sp)
     35e:	f022                	sd	s0,32(sp)
     360:	ec26                	sd	s1,24(sp)
     362:	e84a                	sd	s2,16(sp)
     364:	e44e                	sd	s3,8(sp)
     366:	1800                	addi	s0,sp,48
     368:	89aa                	mv	s3,a0
     36a:	892e                	mv	s2,a1
     36c:	4561                	li	a0,24
     36e:	00001097          	auipc	ra,0x1
     372:	ea2080e7          	jalr	-350(ra) # 1210 <malloc>
     376:	84aa                	mv	s1,a0
     378:	4661                	li	a2,24
     37a:	4581                	li	a1,0
     37c:	00001097          	auipc	ra,0x1
     380:	84a080e7          	jalr	-1974(ra) # bc6 <memset>
     384:	4791                	li	a5,4
     386:	c09c                	sw	a5,0(s1)
     388:	0134b423          	sd	s3,8(s1)
     38c:	0124b823          	sd	s2,16(s1)
     390:	8526                	mv	a0,s1
     392:	70a2                	ld	ra,40(sp)
     394:	7402                	ld	s0,32(sp)
     396:	64e2                	ld	s1,24(sp)
     398:	6942                	ld	s2,16(sp)
     39a:	69a2                	ld	s3,8(sp)
     39c:	6145                	addi	sp,sp,48
     39e:	8082                	ret

00000000000003a0 <backcmd>:
     3a0:	1101                	addi	sp,sp,-32
     3a2:	ec06                	sd	ra,24(sp)
     3a4:	e822                	sd	s0,16(sp)
     3a6:	e426                	sd	s1,8(sp)
     3a8:	e04a                	sd	s2,0(sp)
     3aa:	1000                	addi	s0,sp,32
     3ac:	892a                	mv	s2,a0
     3ae:	4541                	li	a0,16
     3b0:	00001097          	auipc	ra,0x1
     3b4:	e60080e7          	jalr	-416(ra) # 1210 <malloc>
     3b8:	84aa                	mv	s1,a0
     3ba:	4641                	li	a2,16
     3bc:	4581                	li	a1,0
     3be:	00001097          	auipc	ra,0x1
     3c2:	808080e7          	jalr	-2040(ra) # bc6 <memset>
     3c6:	4795                	li	a5,5
     3c8:	c09c                	sw	a5,0(s1)
     3ca:	0124b423          	sd	s2,8(s1)
     3ce:	8526                	mv	a0,s1
     3d0:	60e2                	ld	ra,24(sp)
     3d2:	6442                	ld	s0,16(sp)
     3d4:	64a2                	ld	s1,8(sp)
     3d6:	6902                	ld	s2,0(sp)
     3d8:	6105                	addi	sp,sp,32
     3da:	8082                	ret

00000000000003dc <gettoken>:
     3dc:	7139                	addi	sp,sp,-64
     3de:	fc06                	sd	ra,56(sp)
     3e0:	f822                	sd	s0,48(sp)
     3e2:	f426                	sd	s1,40(sp)
     3e4:	f04a                	sd	s2,32(sp)
     3e6:	ec4e                	sd	s3,24(sp)
     3e8:	e852                	sd	s4,16(sp)
     3ea:	e456                	sd	s5,8(sp)
     3ec:	e05a                	sd	s6,0(sp)
     3ee:	0080                	addi	s0,sp,64
     3f0:	8a2a                	mv	s4,a0
     3f2:	892e                	mv	s2,a1
     3f4:	8ab2                	mv	s5,a2
     3f6:	8b36                	mv	s6,a3
     3f8:	6104                	ld	s1,0(a0)
     3fa:	00001997          	auipc	s3,0x1
     3fe:	06698993          	addi	s3,s3,102 # 1460 <whitespace>
     402:	00b4fd63          	bgeu	s1,a1,41c <gettoken+0x40>
     406:	0004c583          	lbu	a1,0(s1)
     40a:	854e                	mv	a0,s3
     40c:	00000097          	auipc	ra,0x0
     410:	7e0080e7          	jalr	2016(ra) # bec <strchr>
     414:	c501                	beqz	a0,41c <gettoken+0x40>
     416:	0485                	addi	s1,s1,1
     418:	fe9917e3          	bne	s2,s1,406 <gettoken+0x2a>
     41c:	000a8463          	beqz	s5,424 <gettoken+0x48>
     420:	009ab023          	sd	s1,0(s5)
     424:	0004c783          	lbu	a5,0(s1)
     428:	00078a9b          	sext.w	s5,a5
     42c:	03c00713          	li	a4,60
     430:	06f76563          	bltu	a4,a5,49a <gettoken+0xbe>
     434:	03a00713          	li	a4,58
     438:	00f76e63          	bltu	a4,a5,454 <gettoken+0x78>
     43c:	cf89                	beqz	a5,456 <gettoken+0x7a>
     43e:	02600713          	li	a4,38
     442:	00e78963          	beq	a5,a4,454 <gettoken+0x78>
     446:	fd87879b          	addiw	a5,a5,-40
     44a:	0ff7f793          	andi	a5,a5,255
     44e:	4705                	li	a4,1
     450:	06f76c63          	bltu	a4,a5,4c8 <gettoken+0xec>
     454:	0485                	addi	s1,s1,1
     456:	000b0463          	beqz	s6,45e <gettoken+0x82>
     45a:	009b3023          	sd	s1,0(s6)
     45e:	00001997          	auipc	s3,0x1
     462:	00298993          	addi	s3,s3,2 # 1460 <whitespace>
     466:	0124fd63          	bgeu	s1,s2,480 <gettoken+0xa4>
     46a:	0004c583          	lbu	a1,0(s1)
     46e:	854e                	mv	a0,s3
     470:	00000097          	auipc	ra,0x0
     474:	77c080e7          	jalr	1916(ra) # bec <strchr>
     478:	c501                	beqz	a0,480 <gettoken+0xa4>
     47a:	0485                	addi	s1,s1,1
     47c:	fe9917e3          	bne	s2,s1,46a <gettoken+0x8e>
     480:	009a3023          	sd	s1,0(s4)
     484:	8556                	mv	a0,s5
     486:	70e2                	ld	ra,56(sp)
     488:	7442                	ld	s0,48(sp)
     48a:	74a2                	ld	s1,40(sp)
     48c:	7902                	ld	s2,32(sp)
     48e:	69e2                	ld	s3,24(sp)
     490:	6a42                	ld	s4,16(sp)
     492:	6aa2                	ld	s5,8(sp)
     494:	6b02                	ld	s6,0(sp)
     496:	6121                	addi	sp,sp,64
     498:	8082                	ret
     49a:	03e00713          	li	a4,62
     49e:	02e79163          	bne	a5,a4,4c0 <gettoken+0xe4>
     4a2:	00148693          	addi	a3,s1,1
     4a6:	0014c703          	lbu	a4,1(s1)
     4aa:	03e00793          	li	a5,62
     4ae:	0489                	addi	s1,s1,2
     4b0:	02b00a93          	li	s5,43
     4b4:	faf701e3          	beq	a4,a5,456 <gettoken+0x7a>
     4b8:	84b6                	mv	s1,a3
     4ba:	03e00a93          	li	s5,62
     4be:	bf61                	j	456 <gettoken+0x7a>
     4c0:	07c00713          	li	a4,124
     4c4:	f8e788e3          	beq	a5,a4,454 <gettoken+0x78>
     4c8:	00001997          	auipc	s3,0x1
     4cc:	f9898993          	addi	s3,s3,-104 # 1460 <whitespace>
     4d0:	00001a97          	auipc	s5,0x1
     4d4:	f88a8a93          	addi	s5,s5,-120 # 1458 <symbols>
     4d8:	0324f563          	bgeu	s1,s2,502 <gettoken+0x126>
     4dc:	0004c583          	lbu	a1,0(s1)
     4e0:	854e                	mv	a0,s3
     4e2:	00000097          	auipc	ra,0x0
     4e6:	70a080e7          	jalr	1802(ra) # bec <strchr>
     4ea:	e505                	bnez	a0,512 <gettoken+0x136>
     4ec:	0004c583          	lbu	a1,0(s1)
     4f0:	8556                	mv	a0,s5
     4f2:	00000097          	auipc	ra,0x0
     4f6:	6fa080e7          	jalr	1786(ra) # bec <strchr>
     4fa:	e909                	bnez	a0,50c <gettoken+0x130>
     4fc:	0485                	addi	s1,s1,1
     4fe:	fc991fe3          	bne	s2,s1,4dc <gettoken+0x100>
     502:	06100a93          	li	s5,97
     506:	f40b1ae3          	bnez	s6,45a <gettoken+0x7e>
     50a:	bf9d                	j	480 <gettoken+0xa4>
     50c:	06100a93          	li	s5,97
     510:	b799                	j	456 <gettoken+0x7a>
     512:	06100a93          	li	s5,97
     516:	b781                	j	456 <gettoken+0x7a>

0000000000000518 <peek>:
     518:	7139                	addi	sp,sp,-64
     51a:	fc06                	sd	ra,56(sp)
     51c:	f822                	sd	s0,48(sp)
     51e:	f426                	sd	s1,40(sp)
     520:	f04a                	sd	s2,32(sp)
     522:	ec4e                	sd	s3,24(sp)
     524:	e852                	sd	s4,16(sp)
     526:	e456                	sd	s5,8(sp)
     528:	0080                	addi	s0,sp,64
     52a:	8a2a                	mv	s4,a0
     52c:	892e                	mv	s2,a1
     52e:	8ab2                	mv	s5,a2
     530:	6104                	ld	s1,0(a0)
     532:	00001997          	auipc	s3,0x1
     536:	f2e98993          	addi	s3,s3,-210 # 1460 <whitespace>
     53a:	00b4fd63          	bgeu	s1,a1,554 <peek+0x3c>
     53e:	0004c583          	lbu	a1,0(s1)
     542:	854e                	mv	a0,s3
     544:	00000097          	auipc	ra,0x0
     548:	6a8080e7          	jalr	1704(ra) # bec <strchr>
     54c:	c501                	beqz	a0,554 <peek+0x3c>
     54e:	0485                	addi	s1,s1,1
     550:	fe9917e3          	bne	s2,s1,53e <peek+0x26>
     554:	009a3023          	sd	s1,0(s4)
     558:	0004c583          	lbu	a1,0(s1)
     55c:	4501                	li	a0,0
     55e:	e991                	bnez	a1,572 <peek+0x5a>
     560:	70e2                	ld	ra,56(sp)
     562:	7442                	ld	s0,48(sp)
     564:	74a2                	ld	s1,40(sp)
     566:	7902                	ld	s2,32(sp)
     568:	69e2                	ld	s3,24(sp)
     56a:	6a42                	ld	s4,16(sp)
     56c:	6aa2                	ld	s5,8(sp)
     56e:	6121                	addi	sp,sp,64
     570:	8082                	ret
     572:	8556                	mv	a0,s5
     574:	00000097          	auipc	ra,0x0
     578:	678080e7          	jalr	1656(ra) # bec <strchr>
     57c:	00a03533          	snez	a0,a0
     580:	b7c5                	j	560 <peek+0x48>

0000000000000582 <parseredirs>:
     582:	7159                	addi	sp,sp,-112
     584:	f486                	sd	ra,104(sp)
     586:	f0a2                	sd	s0,96(sp)
     588:	eca6                	sd	s1,88(sp)
     58a:	e8ca                	sd	s2,80(sp)
     58c:	e4ce                	sd	s3,72(sp)
     58e:	e0d2                	sd	s4,64(sp)
     590:	fc56                	sd	s5,56(sp)
     592:	f85a                	sd	s6,48(sp)
     594:	f45e                	sd	s7,40(sp)
     596:	f062                	sd	s8,32(sp)
     598:	ec66                	sd	s9,24(sp)
     59a:	1880                	addi	s0,sp,112
     59c:	8a2a                	mv	s4,a0
     59e:	89ae                	mv	s3,a1
     5a0:	8932                	mv	s2,a2
     5a2:	00001b97          	auipc	s7,0x1
<<<<<<< HEAD
     5a6:	db6b8b93          	addi	s7,s7,-586 # 1358 <malloc+0x150>
=======
     5a6:	dbeb8b93          	addi	s7,s7,-578 # 1360 <malloc+0x150>
    tok = gettoken(ps, es, 0, 0);
    if(gettoken(ps, es, &q, &eq) != 'a')
>>>>>>> 355fddefdb805d91072b3597f4cbd2b4e7481a8e
     5aa:	06100c13          	li	s8,97
     5ae:	03c00c93          	li	s9,60
     5b2:	a02d                	j	5dc <parseredirs+0x5a>
     5b4:	00001517          	auipc	a0,0x1
     5b8:	d8c50513          	addi	a0,a0,-628 # 1340 <malloc+0x130>
     5bc:	00000097          	auipc	ra,0x0
     5c0:	a98080e7          	jalr	-1384(ra) # 54 <panic>
     5c4:	4701                	li	a4,0
     5c6:	4681                	li	a3,0
     5c8:	f9043603          	ld	a2,-112(s0)
     5cc:	f9843583          	ld	a1,-104(s0)
     5d0:	8552                	mv	a0,s4
     5d2:	00000097          	auipc	ra,0x0
     5d6:	cda080e7          	jalr	-806(ra) # 2ac <redircmd>
     5da:	8a2a                	mv	s4,a0
     5dc:	03e00b13          	li	s6,62
     5e0:	02b00a93          	li	s5,43
     5e4:	865e                	mv	a2,s7
     5e6:	85ca                	mv	a1,s2
     5e8:	854e                	mv	a0,s3
     5ea:	00000097          	auipc	ra,0x0
     5ee:	f2e080e7          	jalr	-210(ra) # 518 <peek>
     5f2:	c925                	beqz	a0,662 <parseredirs+0xe0>
     5f4:	4681                	li	a3,0
     5f6:	4601                	li	a2,0
     5f8:	85ca                	mv	a1,s2
     5fa:	854e                	mv	a0,s3
     5fc:	00000097          	auipc	ra,0x0
     600:	de0080e7          	jalr	-544(ra) # 3dc <gettoken>
     604:	84aa                	mv	s1,a0
     606:	f9040693          	addi	a3,s0,-112
     60a:	f9840613          	addi	a2,s0,-104
     60e:	85ca                	mv	a1,s2
     610:	854e                	mv	a0,s3
     612:	00000097          	auipc	ra,0x0
     616:	dca080e7          	jalr	-566(ra) # 3dc <gettoken>
     61a:	f9851de3          	bne	a0,s8,5b4 <parseredirs+0x32>
     61e:	fb9483e3          	beq	s1,s9,5c4 <parseredirs+0x42>
     622:	03648263          	beq	s1,s6,646 <parseredirs+0xc4>
     626:	fb549fe3          	bne	s1,s5,5e4 <parseredirs+0x62>
     62a:	4705                	li	a4,1
     62c:	20100693          	li	a3,513
     630:	f9043603          	ld	a2,-112(s0)
     634:	f9843583          	ld	a1,-104(s0)
     638:	8552                	mv	a0,s4
     63a:	00000097          	auipc	ra,0x0
     63e:	c72080e7          	jalr	-910(ra) # 2ac <redircmd>
     642:	8a2a                	mv	s4,a0
     644:	bf61                	j	5dc <parseredirs+0x5a>
     646:	4705                	li	a4,1
     648:	60100693          	li	a3,1537
     64c:	f9043603          	ld	a2,-112(s0)
     650:	f9843583          	ld	a1,-104(s0)
     654:	8552                	mv	a0,s4
     656:	00000097          	auipc	ra,0x0
     65a:	c56080e7          	jalr	-938(ra) # 2ac <redircmd>
     65e:	8a2a                	mv	s4,a0
     660:	bfb5                	j	5dc <parseredirs+0x5a>
     662:	8552                	mv	a0,s4
     664:	70a6                	ld	ra,104(sp)
     666:	7406                	ld	s0,96(sp)
     668:	64e6                	ld	s1,88(sp)
     66a:	6946                	ld	s2,80(sp)
     66c:	69a6                	ld	s3,72(sp)
     66e:	6a06                	ld	s4,64(sp)
     670:	7ae2                	ld	s5,56(sp)
     672:	7b42                	ld	s6,48(sp)
     674:	7ba2                	ld	s7,40(sp)
     676:	7c02                	ld	s8,32(sp)
     678:	6ce2                	ld	s9,24(sp)
     67a:	6165                	addi	sp,sp,112
     67c:	8082                	ret

000000000000067e <parseexec>:
     67e:	7159                	addi	sp,sp,-112
     680:	f486                	sd	ra,104(sp)
     682:	f0a2                	sd	s0,96(sp)
     684:	eca6                	sd	s1,88(sp)
     686:	e8ca                	sd	s2,80(sp)
     688:	e4ce                	sd	s3,72(sp)
     68a:	e0d2                	sd	s4,64(sp)
     68c:	fc56                	sd	s5,56(sp)
     68e:	f85a                	sd	s6,48(sp)
     690:	f45e                	sd	s7,40(sp)
     692:	f062                	sd	s8,32(sp)
     694:	ec66                	sd	s9,24(sp)
     696:	1880                	addi	s0,sp,112
     698:	8a2a                	mv	s4,a0
     69a:	8aae                	mv	s5,a1
     69c:	00001617          	auipc	a2,0x1
     6a0:	ccc60613          	addi	a2,a2,-820 # 1368 <malloc+0x158>
     6a4:	00000097          	auipc	ra,0x0
     6a8:	e74080e7          	jalr	-396(ra) # 518 <peek>
     6ac:	e905                	bnez	a0,6dc <parseexec+0x5e>
     6ae:	89aa                	mv	s3,a0
     6b0:	00000097          	auipc	ra,0x0
     6b4:	bc6080e7          	jalr	-1082(ra) # 276 <execcmd>
     6b8:	8c2a                	mv	s8,a0
     6ba:	8656                	mv	a2,s5
     6bc:	85d2                	mv	a1,s4
     6be:	00000097          	auipc	ra,0x0
     6c2:	ec4080e7          	jalr	-316(ra) # 582 <parseredirs>
     6c6:	84aa                	mv	s1,a0
     6c8:	008c0913          	addi	s2,s8,8
     6cc:	00001b17          	auipc	s6,0x1
<<<<<<< HEAD
     6d0:	cb4b0b13          	addi	s6,s6,-844 # 1380 <malloc+0x178>
=======
     6d0:	cbcb0b13          	addi	s6,s6,-836 # 1388 <malloc+0x178>
    if((tok=gettoken(ps, es, &q, &eq)) == 0)
      break;
    if(tok != 'a')
>>>>>>> 355fddefdb805d91072b3597f4cbd2b4e7481a8e
     6d4:	06100c93          	li	s9,97
     6d8:	4ba9                	li	s7,10
     6da:	a0b1                	j	726 <parseexec+0xa8>
     6dc:	85d6                	mv	a1,s5
     6de:	8552                	mv	a0,s4
     6e0:	00000097          	auipc	ra,0x0
     6e4:	1bc080e7          	jalr	444(ra) # 89c <parseblock>
     6e8:	84aa                	mv	s1,a0
     6ea:	8526                	mv	a0,s1
     6ec:	70a6                	ld	ra,104(sp)
     6ee:	7406                	ld	s0,96(sp)
     6f0:	64e6                	ld	s1,88(sp)
     6f2:	6946                	ld	s2,80(sp)
     6f4:	69a6                	ld	s3,72(sp)
     6f6:	6a06                	ld	s4,64(sp)
     6f8:	7ae2                	ld	s5,56(sp)
     6fa:	7b42                	ld	s6,48(sp)
     6fc:	7ba2                	ld	s7,40(sp)
     6fe:	7c02                	ld	s8,32(sp)
     700:	6ce2                	ld	s9,24(sp)
     702:	6165                	addi	sp,sp,112
     704:	8082                	ret
     706:	00001517          	auipc	a0,0x1
     70a:	c6a50513          	addi	a0,a0,-918 # 1370 <malloc+0x160>
     70e:	00000097          	auipc	ra,0x0
     712:	946080e7          	jalr	-1722(ra) # 54 <panic>
     716:	8656                	mv	a2,s5
     718:	85d2                	mv	a1,s4
     71a:	8526                	mv	a0,s1
     71c:	00000097          	auipc	ra,0x0
     720:	e66080e7          	jalr	-410(ra) # 582 <parseredirs>
     724:	84aa                	mv	s1,a0
     726:	865a                	mv	a2,s6
     728:	85d6                	mv	a1,s5
     72a:	8552                	mv	a0,s4
     72c:	00000097          	auipc	ra,0x0
     730:	dec080e7          	jalr	-532(ra) # 518 <peek>
     734:	e131                	bnez	a0,778 <parseexec+0xfa>
     736:	f9040693          	addi	a3,s0,-112
     73a:	f9840613          	addi	a2,s0,-104
     73e:	85d6                	mv	a1,s5
     740:	8552                	mv	a0,s4
     742:	00000097          	auipc	ra,0x0
     746:	c9a080e7          	jalr	-870(ra) # 3dc <gettoken>
     74a:	c51d                	beqz	a0,778 <parseexec+0xfa>
     74c:	fb951de3          	bne	a0,s9,706 <parseexec+0x88>
     750:	f9843783          	ld	a5,-104(s0)
     754:	00f93023          	sd	a5,0(s2)
     758:	f9043783          	ld	a5,-112(s0)
     75c:	04f93823          	sd	a5,80(s2)
     760:	2985                	addiw	s3,s3,1
     762:	0921                	addi	s2,s2,8
     764:	fb7999e3          	bne	s3,s7,716 <parseexec+0x98>
     768:	00001517          	auipc	a0,0x1
     76c:	c1050513          	addi	a0,a0,-1008 # 1378 <malloc+0x168>
     770:	00000097          	auipc	ra,0x0
     774:	8e4080e7          	jalr	-1820(ra) # 54 <panic>
     778:	098e                	slli	s3,s3,0x3
     77a:	99e2                	add	s3,s3,s8
     77c:	0009b423          	sd	zero,8(s3)
     780:	0409bc23          	sd	zero,88(s3)
     784:	b79d                	j	6ea <parseexec+0x6c>

0000000000000786 <parsepipe>:
     786:	7179                	addi	sp,sp,-48
     788:	f406                	sd	ra,40(sp)
     78a:	f022                	sd	s0,32(sp)
     78c:	ec26                	sd	s1,24(sp)
     78e:	e84a                	sd	s2,16(sp)
     790:	e44e                	sd	s3,8(sp)
     792:	1800                	addi	s0,sp,48
     794:	892a                	mv	s2,a0
     796:	89ae                	mv	s3,a1
     798:	00000097          	auipc	ra,0x0
     79c:	ee6080e7          	jalr	-282(ra) # 67e <parseexec>
     7a0:	84aa                	mv	s1,a0
     7a2:	00001617          	auipc	a2,0x1
     7a6:	bee60613          	addi	a2,a2,-1042 # 1390 <malloc+0x180>
     7aa:	85ce                	mv	a1,s3
     7ac:	854a                	mv	a0,s2
     7ae:	00000097          	auipc	ra,0x0
     7b2:	d6a080e7          	jalr	-662(ra) # 518 <peek>
     7b6:	e909                	bnez	a0,7c8 <parsepipe+0x42>
     7b8:	8526                	mv	a0,s1
     7ba:	70a2                	ld	ra,40(sp)
     7bc:	7402                	ld	s0,32(sp)
     7be:	64e2                	ld	s1,24(sp)
     7c0:	6942                	ld	s2,16(sp)
     7c2:	69a2                	ld	s3,8(sp)
     7c4:	6145                	addi	sp,sp,48
     7c6:	8082                	ret
     7c8:	4681                	li	a3,0
     7ca:	4601                	li	a2,0
     7cc:	85ce                	mv	a1,s3
     7ce:	854a                	mv	a0,s2
     7d0:	00000097          	auipc	ra,0x0
     7d4:	c0c080e7          	jalr	-1012(ra) # 3dc <gettoken>
     7d8:	85ce                	mv	a1,s3
     7da:	854a                	mv	a0,s2
     7dc:	00000097          	auipc	ra,0x0
     7e0:	faa080e7          	jalr	-86(ra) # 786 <parsepipe>
     7e4:	85aa                	mv	a1,a0
     7e6:	8526                	mv	a0,s1
     7e8:	00000097          	auipc	ra,0x0
     7ec:	b2c080e7          	jalr	-1236(ra) # 314 <pipecmd>
     7f0:	84aa                	mv	s1,a0
     7f2:	b7d9                	j	7b8 <parsepipe+0x32>

00000000000007f4 <parseline>:
     7f4:	7179                	addi	sp,sp,-48
     7f6:	f406                	sd	ra,40(sp)
     7f8:	f022                	sd	s0,32(sp)
     7fa:	ec26                	sd	s1,24(sp)
     7fc:	e84a                	sd	s2,16(sp)
     7fe:	e44e                	sd	s3,8(sp)
     800:	e052                	sd	s4,0(sp)
     802:	1800                	addi	s0,sp,48
     804:	892a                	mv	s2,a0
     806:	89ae                	mv	s3,a1
     808:	00000097          	auipc	ra,0x0
     80c:	f7e080e7          	jalr	-130(ra) # 786 <parsepipe>
     810:	84aa                	mv	s1,a0
     812:	00001a17          	auipc	s4,0x1
     816:	b86a0a13          	addi	s4,s4,-1146 # 1398 <malloc+0x188>
     81a:	8652                	mv	a2,s4
     81c:	85ce                	mv	a1,s3
     81e:	854a                	mv	a0,s2
     820:	00000097          	auipc	ra,0x0
     824:	cf8080e7          	jalr	-776(ra) # 518 <peek>
     828:	c105                	beqz	a0,848 <parseline+0x54>
     82a:	4681                	li	a3,0
     82c:	4601                	li	a2,0
     82e:	85ce                	mv	a1,s3
     830:	854a                	mv	a0,s2
     832:	00000097          	auipc	ra,0x0
     836:	baa080e7          	jalr	-1110(ra) # 3dc <gettoken>
     83a:	8526                	mv	a0,s1
     83c:	00000097          	auipc	ra,0x0
     840:	b64080e7          	jalr	-1180(ra) # 3a0 <backcmd>
     844:	84aa                	mv	s1,a0
     846:	bfd1                	j	81a <parseline+0x26>
     848:	00001617          	auipc	a2,0x1
     84c:	b5860613          	addi	a2,a2,-1192 # 13a0 <malloc+0x190>
     850:	85ce                	mv	a1,s3
     852:	854a                	mv	a0,s2
     854:	00000097          	auipc	ra,0x0
     858:	cc4080e7          	jalr	-828(ra) # 518 <peek>
     85c:	e911                	bnez	a0,870 <parseline+0x7c>
     85e:	8526                	mv	a0,s1
     860:	70a2                	ld	ra,40(sp)
     862:	7402                	ld	s0,32(sp)
     864:	64e2                	ld	s1,24(sp)
     866:	6942                	ld	s2,16(sp)
     868:	69a2                	ld	s3,8(sp)
     86a:	6a02                	ld	s4,0(sp)
     86c:	6145                	addi	sp,sp,48
     86e:	8082                	ret
     870:	4681                	li	a3,0
     872:	4601                	li	a2,0
     874:	85ce                	mv	a1,s3
     876:	854a                	mv	a0,s2
     878:	00000097          	auipc	ra,0x0
     87c:	b64080e7          	jalr	-1180(ra) # 3dc <gettoken>
     880:	85ce                	mv	a1,s3
     882:	854a                	mv	a0,s2
     884:	00000097          	auipc	ra,0x0
     888:	f70080e7          	jalr	-144(ra) # 7f4 <parseline>
     88c:	85aa                	mv	a1,a0
     88e:	8526                	mv	a0,s1
     890:	00000097          	auipc	ra,0x0
     894:	aca080e7          	jalr	-1334(ra) # 35a <listcmd>
     898:	84aa                	mv	s1,a0
     89a:	b7d1                	j	85e <parseline+0x6a>

000000000000089c <parseblock>:
     89c:	7179                	addi	sp,sp,-48
     89e:	f406                	sd	ra,40(sp)
     8a0:	f022                	sd	s0,32(sp)
     8a2:	ec26                	sd	s1,24(sp)
     8a4:	e84a                	sd	s2,16(sp)
     8a6:	e44e                	sd	s3,8(sp)
     8a8:	1800                	addi	s0,sp,48
     8aa:	84aa                	mv	s1,a0
     8ac:	892e                	mv	s2,a1
     8ae:	00001617          	auipc	a2,0x1
     8b2:	aba60613          	addi	a2,a2,-1350 # 1368 <malloc+0x158>
     8b6:	00000097          	auipc	ra,0x0
     8ba:	c62080e7          	jalr	-926(ra) # 518 <peek>
     8be:	c12d                	beqz	a0,920 <parseblock+0x84>
     8c0:	4681                	li	a3,0
     8c2:	4601                	li	a2,0
     8c4:	85ca                	mv	a1,s2
     8c6:	8526                	mv	a0,s1
     8c8:	00000097          	auipc	ra,0x0
     8cc:	b14080e7          	jalr	-1260(ra) # 3dc <gettoken>
     8d0:	85ca                	mv	a1,s2
     8d2:	8526                	mv	a0,s1
     8d4:	00000097          	auipc	ra,0x0
     8d8:	f20080e7          	jalr	-224(ra) # 7f4 <parseline>
     8dc:	89aa                	mv	s3,a0
     8de:	00001617          	auipc	a2,0x1
     8e2:	ada60613          	addi	a2,a2,-1318 # 13b8 <malloc+0x1a8>
     8e6:	85ca                	mv	a1,s2
     8e8:	8526                	mv	a0,s1
     8ea:	00000097          	auipc	ra,0x0
     8ee:	c2e080e7          	jalr	-978(ra) # 518 <peek>
     8f2:	cd1d                	beqz	a0,930 <parseblock+0x94>
     8f4:	4681                	li	a3,0
     8f6:	4601                	li	a2,0
     8f8:	85ca                	mv	a1,s2
     8fa:	8526                	mv	a0,s1
     8fc:	00000097          	auipc	ra,0x0
     900:	ae0080e7          	jalr	-1312(ra) # 3dc <gettoken>
     904:	864a                	mv	a2,s2
     906:	85a6                	mv	a1,s1
     908:	854e                	mv	a0,s3
     90a:	00000097          	auipc	ra,0x0
     90e:	c78080e7          	jalr	-904(ra) # 582 <parseredirs>
     912:	70a2                	ld	ra,40(sp)
     914:	7402                	ld	s0,32(sp)
     916:	64e2                	ld	s1,24(sp)
     918:	6942                	ld	s2,16(sp)
     91a:	69a2                	ld	s3,8(sp)
     91c:	6145                	addi	sp,sp,48
     91e:	8082                	ret
     920:	00001517          	auipc	a0,0x1
     924:	a8850513          	addi	a0,a0,-1400 # 13a8 <malloc+0x198>
     928:	fffff097          	auipc	ra,0xfffff
     92c:	72c080e7          	jalr	1836(ra) # 54 <panic>
     930:	00001517          	auipc	a0,0x1
     934:	a9050513          	addi	a0,a0,-1392 # 13c0 <malloc+0x1b0>
     938:	fffff097          	auipc	ra,0xfffff
     93c:	71c080e7          	jalr	1820(ra) # 54 <panic>

0000000000000940 <nulterminate>:
     940:	1101                	addi	sp,sp,-32
     942:	ec06                	sd	ra,24(sp)
     944:	e822                	sd	s0,16(sp)
     946:	e426                	sd	s1,8(sp)
     948:	1000                	addi	s0,sp,32
     94a:	84aa                	mv	s1,a0
     94c:	c521                	beqz	a0,994 <nulterminate+0x54>
     94e:	4118                	lw	a4,0(a0)
     950:	4795                	li	a5,5
     952:	04e7e163          	bltu	a5,a4,994 <nulterminate+0x54>
     956:	00056783          	lwu	a5,0(a0)
     95a:	078a                	slli	a5,a5,0x2
     95c:	00001717          	auipc	a4,0x1
     960:	ac470713          	addi	a4,a4,-1340 # 1420 <malloc+0x210>
     964:	97ba                	add	a5,a5,a4
     966:	439c                	lw	a5,0(a5)
     968:	97ba                	add	a5,a5,a4
     96a:	8782                	jr	a5
     96c:	651c                	ld	a5,8(a0)
     96e:	c39d                	beqz	a5,994 <nulterminate+0x54>
     970:	01050793          	addi	a5,a0,16
     974:	67b8                	ld	a4,72(a5)
     976:	00070023          	sb	zero,0(a4)
     97a:	07a1                	addi	a5,a5,8
     97c:	ff87b703          	ld	a4,-8(a5)
     980:	fb75                	bnez	a4,974 <nulterminate+0x34>
     982:	a809                	j	994 <nulterminate+0x54>
     984:	6508                	ld	a0,8(a0)
     986:	00000097          	auipc	ra,0x0
     98a:	fba080e7          	jalr	-70(ra) # 940 <nulterminate>
     98e:	6c9c                	ld	a5,24(s1)
     990:	00078023          	sb	zero,0(a5)
     994:	8526                	mv	a0,s1
     996:	60e2                	ld	ra,24(sp)
     998:	6442                	ld	s0,16(sp)
     99a:	64a2                	ld	s1,8(sp)
     99c:	6105                	addi	sp,sp,32
     99e:	8082                	ret
     9a0:	6508                	ld	a0,8(a0)
     9a2:	00000097          	auipc	ra,0x0
     9a6:	f9e080e7          	jalr	-98(ra) # 940 <nulterminate>
     9aa:	6888                	ld	a0,16(s1)
     9ac:	00000097          	auipc	ra,0x0
     9b0:	f94080e7          	jalr	-108(ra) # 940 <nulterminate>
     9b4:	b7c5                	j	994 <nulterminate+0x54>
     9b6:	6508                	ld	a0,8(a0)
     9b8:	00000097          	auipc	ra,0x0
     9bc:	f88080e7          	jalr	-120(ra) # 940 <nulterminate>
     9c0:	6888                	ld	a0,16(s1)
     9c2:	00000097          	auipc	ra,0x0
     9c6:	f7e080e7          	jalr	-130(ra) # 940 <nulterminate>
     9ca:	b7e9                	j	994 <nulterminate+0x54>
     9cc:	6508                	ld	a0,8(a0)
     9ce:	00000097          	auipc	ra,0x0
     9d2:	f72080e7          	jalr	-142(ra) # 940 <nulterminate>
     9d6:	bf7d                	j	994 <nulterminate+0x54>

00000000000009d8 <parsecmd>:
     9d8:	7179                	addi	sp,sp,-48
     9da:	f406                	sd	ra,40(sp)
     9dc:	f022                	sd	s0,32(sp)
     9de:	ec26                	sd	s1,24(sp)
     9e0:	e84a                	sd	s2,16(sp)
     9e2:	1800                	addi	s0,sp,48
     9e4:	fca43c23          	sd	a0,-40(s0)
     9e8:	84aa                	mv	s1,a0
     9ea:	00000097          	auipc	ra,0x0
     9ee:	1b2080e7          	jalr	434(ra) # b9c <strlen>
     9f2:	1502                	slli	a0,a0,0x20
     9f4:	9101                	srli	a0,a0,0x20
     9f6:	94aa                	add	s1,s1,a0
     9f8:	85a6                	mv	a1,s1
     9fa:	fd840513          	addi	a0,s0,-40
     9fe:	00000097          	auipc	ra,0x0
     a02:	df6080e7          	jalr	-522(ra) # 7f4 <parseline>
     a06:	892a                	mv	s2,a0
     a08:	00001617          	auipc	a2,0x1
     a0c:	9d060613          	addi	a2,a2,-1584 # 13d8 <malloc+0x1c8>
     a10:	85a6                	mv	a1,s1
     a12:	fd840513          	addi	a0,s0,-40
     a16:	00000097          	auipc	ra,0x0
     a1a:	b02080e7          	jalr	-1278(ra) # 518 <peek>
     a1e:	fd843603          	ld	a2,-40(s0)
     a22:	00961e63          	bne	a2,s1,a3e <parsecmd+0x66>
     a26:	854a                	mv	a0,s2
     a28:	00000097          	auipc	ra,0x0
     a2c:	f18080e7          	jalr	-232(ra) # 940 <nulterminate>
     a30:	854a                	mv	a0,s2
     a32:	70a2                	ld	ra,40(sp)
     a34:	7402                	ld	s0,32(sp)
     a36:	64e2                	ld	s1,24(sp)
     a38:	6942                	ld	s2,16(sp)
     a3a:	6145                	addi	sp,sp,48
     a3c:	8082                	ret
     a3e:	00001597          	auipc	a1,0x1
     a42:	9a258593          	addi	a1,a1,-1630 # 13e0 <malloc+0x1d0>
     a46:	4509                	li	a0,2
     a48:	00000097          	auipc	ra,0x0
<<<<<<< HEAD
     a4c:	6d4080e7          	jalr	1748(ra) # 111c <fprintf>
=======
     a4c:	6dc080e7          	jalr	1756(ra) # 1124 <fprintf>
    panic("syntax");
>>>>>>> 355fddefdb805d91072b3597f4cbd2b4e7481a8e
     a50:	00001517          	auipc	a0,0x1
     a54:	92050513          	addi	a0,a0,-1760 # 1370 <malloc+0x160>
     a58:	fffff097          	auipc	ra,0xfffff
     a5c:	5fc080e7          	jalr	1532(ra) # 54 <panic>

0000000000000a60 <main>:
     a60:	7139                	addi	sp,sp,-64
     a62:	fc06                	sd	ra,56(sp)
     a64:	f822                	sd	s0,48(sp)
     a66:	f426                	sd	s1,40(sp)
     a68:	f04a                	sd	s2,32(sp)
     a6a:	ec4e                	sd	s3,24(sp)
     a6c:	e852                	sd	s4,16(sp)
     a6e:	e456                	sd	s5,8(sp)
     a70:	0080                	addi	s0,sp,64
     a72:	00001497          	auipc	s1,0x1
     a76:	97e48493          	addi	s1,s1,-1666 # 13f0 <malloc+0x1e0>
     a7a:	4589                	li	a1,2
     a7c:	8526                	mv	a0,s1
     a7e:	00000097          	auipc	ra,0x0
     a82:	38c080e7          	jalr	908(ra) # e0a <open>
     a86:	00054963          	bltz	a0,a98 <main+0x38>
     a8a:	4789                	li	a5,2
     a8c:	fea7d7e3          	bge	a5,a0,a7a <main+0x1a>
     a90:	00000097          	auipc	ra,0x0
     a94:	362080e7          	jalr	866(ra) # df2 <close>
     a98:	00001497          	auipc	s1,0x1
<<<<<<< HEAD
     a9c:	9d048493          	addi	s1,s1,-1584 # 1468 <buf.1136>
=======
     a9c:	9d848493          	addi	s1,s1,-1576 # 1470 <buf.1138>
    if(buf[0] == 'c' && buf[1] == 'd' && buf[2] == ' '){
>>>>>>> 355fddefdb805d91072b3597f4cbd2b4e7481a8e
     aa0:	06300913          	li	s2,99
     aa4:	02000993          	li	s3,32
     aa8:	00001a17          	auipc	s4,0x1
<<<<<<< HEAD
     aac:	9c3a0a13          	addi	s4,s4,-1597 # 146b <buf.1136+0x3>
=======
     aac:	9cba0a13          	addi	s4,s4,-1589 # 1473 <buf.1138+0x3>
        fprintf(2, "cannot cd %s\n", buf+3);
>>>>>>> 355fddefdb805d91072b3597f4cbd2b4e7481a8e
     ab0:	00001a97          	auipc	s5,0x1
     ab4:	948a8a93          	addi	s5,s5,-1720 # 13f8 <malloc+0x1e8>
     ab8:	a819                	j	ace <main+0x6e>
     aba:	fffff097          	auipc	ra,0xfffff
     abe:	5c0080e7          	jalr	1472(ra) # 7a <fork1>
     ac2:	c925                	beqz	a0,b32 <main+0xd2>
     ac4:	4501                	li	a0,0
     ac6:	00000097          	auipc	ra,0x0
     aca:	30c080e7          	jalr	780(ra) # dd2 <wait>
     ace:	06400593          	li	a1,100
     ad2:	8526                	mv	a0,s1
     ad4:	fffff097          	auipc	ra,0xfffff
     ad8:	52c080e7          	jalr	1324(ra) # 0 <getcmd>
     adc:	06054763          	bltz	a0,b4a <main+0xea>
     ae0:	0004c783          	lbu	a5,0(s1)
     ae4:	fd279be3          	bne	a5,s2,aba <main+0x5a>
     ae8:	0014c703          	lbu	a4,1(s1)
     aec:	06400793          	li	a5,100
     af0:	fcf715e3          	bne	a4,a5,aba <main+0x5a>
     af4:	0024c783          	lbu	a5,2(s1)
     af8:	fd3791e3          	bne	a5,s3,aba <main+0x5a>
     afc:	8526                	mv	a0,s1
     afe:	00000097          	auipc	ra,0x0
     b02:	09e080e7          	jalr	158(ra) # b9c <strlen>
     b06:	fff5079b          	addiw	a5,a0,-1
     b0a:	1782                	slli	a5,a5,0x20
     b0c:	9381                	srli	a5,a5,0x20
     b0e:	97a6                	add	a5,a5,s1
     b10:	00078023          	sb	zero,0(a5)
     b14:	8552                	mv	a0,s4
     b16:	00000097          	auipc	ra,0x0
     b1a:	324080e7          	jalr	804(ra) # e3a <chdir>
     b1e:	fa0558e3          	bgez	a0,ace <main+0x6e>
     b22:	8652                	mv	a2,s4
     b24:	85d6                	mv	a1,s5
     b26:	4509                	li	a0,2
     b28:	00000097          	auipc	ra,0x0
     b2c:	5fc080e7          	jalr	1532(ra) # 1124 <fprintf>
     b30:	bf79                	j	ace <main+0x6e>
     b32:	00001517          	auipc	a0,0x1
     b36:	93e50513          	addi	a0,a0,-1730 # 1470 <buf.1138>
     b3a:	00000097          	auipc	ra,0x0
     b3e:	e9e080e7          	jalr	-354(ra) # 9d8 <parsecmd>
     b42:	fffff097          	auipc	ra,0xfffff
     b46:	566080e7          	jalr	1382(ra) # a8 <runcmd>
     b4a:	4501                	li	a0,0
     b4c:	00000097          	auipc	ra,0x0
     b50:	27e080e7          	jalr	638(ra) # dca <exit>

0000000000000b54 <strcpy>:
     b54:	1141                	addi	sp,sp,-16
     b56:	e422                	sd	s0,8(sp)
     b58:	0800                	addi	s0,sp,16
     b5a:	87aa                	mv	a5,a0
     b5c:	0585                	addi	a1,a1,1
     b5e:	0785                	addi	a5,a5,1
     b60:	fff5c703          	lbu	a4,-1(a1)
     b64:	fee78fa3          	sb	a4,-1(a5)
     b68:	fb75                	bnez	a4,b5c <strcpy+0x8>
     b6a:	6422                	ld	s0,8(sp)
     b6c:	0141                	addi	sp,sp,16
     b6e:	8082                	ret

0000000000000b70 <strcmp>:
     b70:	1141                	addi	sp,sp,-16
     b72:	e422                	sd	s0,8(sp)
     b74:	0800                	addi	s0,sp,16
     b76:	00054783          	lbu	a5,0(a0)
     b7a:	cb91                	beqz	a5,b8e <strcmp+0x1e>
     b7c:	0005c703          	lbu	a4,0(a1)
     b80:	00f71763          	bne	a4,a5,b8e <strcmp+0x1e>
     b84:	0505                	addi	a0,a0,1
     b86:	0585                	addi	a1,a1,1
     b88:	00054783          	lbu	a5,0(a0)
     b8c:	fbe5                	bnez	a5,b7c <strcmp+0xc>
     b8e:	0005c503          	lbu	a0,0(a1)
     b92:	40a7853b          	subw	a0,a5,a0
     b96:	6422                	ld	s0,8(sp)
     b98:	0141                	addi	sp,sp,16
     b9a:	8082                	ret

0000000000000b9c <strlen>:
     b9c:	1141                	addi	sp,sp,-16
     b9e:	e422                	sd	s0,8(sp)
     ba0:	0800                	addi	s0,sp,16
     ba2:	00054783          	lbu	a5,0(a0)
     ba6:	cf91                	beqz	a5,bc2 <strlen+0x26>
     ba8:	0505                	addi	a0,a0,1
     baa:	87aa                	mv	a5,a0
     bac:	4685                	li	a3,1
     bae:	9e89                	subw	a3,a3,a0
     bb0:	00f6853b          	addw	a0,a3,a5
     bb4:	0785                	addi	a5,a5,1
     bb6:	fff7c703          	lbu	a4,-1(a5)
     bba:	fb7d                	bnez	a4,bb0 <strlen+0x14>
     bbc:	6422                	ld	s0,8(sp)
     bbe:	0141                	addi	sp,sp,16
     bc0:	8082                	ret
     bc2:	4501                	li	a0,0
     bc4:	bfe5                	j	bbc <strlen+0x20>

0000000000000bc6 <memset>:
     bc6:	1141                	addi	sp,sp,-16
     bc8:	e422                	sd	s0,8(sp)
     bca:	0800                	addi	s0,sp,16
     bcc:	ce09                	beqz	a2,be6 <memset+0x20>
     bce:	87aa                	mv	a5,a0
     bd0:	fff6071b          	addiw	a4,a2,-1
     bd4:	1702                	slli	a4,a4,0x20
     bd6:	9301                	srli	a4,a4,0x20
     bd8:	0705                	addi	a4,a4,1
     bda:	972a                	add	a4,a4,a0
     bdc:	00b78023          	sb	a1,0(a5)
     be0:	0785                	addi	a5,a5,1
     be2:	fee79de3          	bne	a5,a4,bdc <memset+0x16>
     be6:	6422                	ld	s0,8(sp)
     be8:	0141                	addi	sp,sp,16
     bea:	8082                	ret

0000000000000bec <strchr>:
     bec:	1141                	addi	sp,sp,-16
     bee:	e422                	sd	s0,8(sp)
     bf0:	0800                	addi	s0,sp,16
     bf2:	00054783          	lbu	a5,0(a0)
     bf6:	cb99                	beqz	a5,c0c <strchr+0x20>
     bf8:	00f58763          	beq	a1,a5,c06 <strchr+0x1a>
     bfc:	0505                	addi	a0,a0,1
     bfe:	00054783          	lbu	a5,0(a0)
     c02:	fbfd                	bnez	a5,bf8 <strchr+0xc>
     c04:	4501                	li	a0,0
     c06:	6422                	ld	s0,8(sp)
     c08:	0141                	addi	sp,sp,16
     c0a:	8082                	ret
     c0c:	4501                	li	a0,0
     c0e:	bfe5                	j	c06 <strchr+0x1a>

0000000000000c10 <gets>:
     c10:	711d                	addi	sp,sp,-96
     c12:	ec86                	sd	ra,88(sp)
     c14:	e8a2                	sd	s0,80(sp)
     c16:	e4a6                	sd	s1,72(sp)
     c18:	e0ca                	sd	s2,64(sp)
     c1a:	fc4e                	sd	s3,56(sp)
     c1c:	f852                	sd	s4,48(sp)
     c1e:	f456                	sd	s5,40(sp)
     c20:	f05a                	sd	s6,32(sp)
     c22:	ec5e                	sd	s7,24(sp)
     c24:	1080                	addi	s0,sp,96
     c26:	8baa                	mv	s7,a0
     c28:	8a2e                	mv	s4,a1
     c2a:	892a                	mv	s2,a0
     c2c:	4481                	li	s1,0
     c2e:	4aa9                	li	s5,10
     c30:	4b35                	li	s6,13
     c32:	89a6                	mv	s3,s1
     c34:	2485                	addiw	s1,s1,1
     c36:	0344d863          	bge	s1,s4,c66 <gets+0x56>
     c3a:	4605                	li	a2,1
     c3c:	faf40593          	addi	a1,s0,-81
     c40:	4501                	li	a0,0
     c42:	00000097          	auipc	ra,0x0
     c46:	1a0080e7          	jalr	416(ra) # de2 <read>
     c4a:	00a05e63          	blez	a0,c66 <gets+0x56>
     c4e:	faf44783          	lbu	a5,-81(s0)
     c52:	00f90023          	sb	a5,0(s2)
     c56:	01578763          	beq	a5,s5,c64 <gets+0x54>
     c5a:	0905                	addi	s2,s2,1
     c5c:	fd679be3          	bne	a5,s6,c32 <gets+0x22>
     c60:	89a6                	mv	s3,s1
     c62:	a011                	j	c66 <gets+0x56>
     c64:	89a6                	mv	s3,s1
     c66:	99de                	add	s3,s3,s7
     c68:	00098023          	sb	zero,0(s3)
     c6c:	855e                	mv	a0,s7
     c6e:	60e6                	ld	ra,88(sp)
     c70:	6446                	ld	s0,80(sp)
     c72:	64a6                	ld	s1,72(sp)
     c74:	6906                	ld	s2,64(sp)
     c76:	79e2                	ld	s3,56(sp)
     c78:	7a42                	ld	s4,48(sp)
     c7a:	7aa2                	ld	s5,40(sp)
     c7c:	7b02                	ld	s6,32(sp)
     c7e:	6be2                	ld	s7,24(sp)
     c80:	6125                	addi	sp,sp,96
     c82:	8082                	ret

0000000000000c84 <stat>:
     c84:	1101                	addi	sp,sp,-32
     c86:	ec06                	sd	ra,24(sp)
     c88:	e822                	sd	s0,16(sp)
     c8a:	e426                	sd	s1,8(sp)
     c8c:	e04a                	sd	s2,0(sp)
     c8e:	1000                	addi	s0,sp,32
     c90:	892e                	mv	s2,a1
     c92:	4581                	li	a1,0
     c94:	00000097          	auipc	ra,0x0
     c98:	176080e7          	jalr	374(ra) # e0a <open>
     c9c:	02054563          	bltz	a0,cc6 <stat+0x42>
     ca0:	84aa                	mv	s1,a0
     ca2:	85ca                	mv	a1,s2
     ca4:	00000097          	auipc	ra,0x0
     ca8:	17e080e7          	jalr	382(ra) # e22 <fstat>
     cac:	892a                	mv	s2,a0
     cae:	8526                	mv	a0,s1
     cb0:	00000097          	auipc	ra,0x0
     cb4:	142080e7          	jalr	322(ra) # df2 <close>
     cb8:	854a                	mv	a0,s2
     cba:	60e2                	ld	ra,24(sp)
     cbc:	6442                	ld	s0,16(sp)
     cbe:	64a2                	ld	s1,8(sp)
     cc0:	6902                	ld	s2,0(sp)
     cc2:	6105                	addi	sp,sp,32
     cc4:	8082                	ret
     cc6:	597d                	li	s2,-1
     cc8:	bfc5                	j	cb8 <stat+0x34>

0000000000000cca <atoi>:
     cca:	1141                	addi	sp,sp,-16
     ccc:	e422                	sd	s0,8(sp)
     cce:	0800                	addi	s0,sp,16
     cd0:	00054603          	lbu	a2,0(a0)
     cd4:	fd06079b          	addiw	a5,a2,-48
     cd8:	0ff7f793          	andi	a5,a5,255
     cdc:	4725                	li	a4,9
     cde:	02f76963          	bltu	a4,a5,d10 <atoi+0x46>
     ce2:	86aa                	mv	a3,a0
     ce4:	4501                	li	a0,0
     ce6:	45a5                	li	a1,9
     ce8:	0685                	addi	a3,a3,1
     cea:	0025179b          	slliw	a5,a0,0x2
     cee:	9fa9                	addw	a5,a5,a0
     cf0:	0017979b          	slliw	a5,a5,0x1
     cf4:	9fb1                	addw	a5,a5,a2
     cf6:	fd07851b          	addiw	a0,a5,-48
     cfa:	0006c603          	lbu	a2,0(a3)
     cfe:	fd06071b          	addiw	a4,a2,-48
     d02:	0ff77713          	andi	a4,a4,255
     d06:	fee5f1e3          	bgeu	a1,a4,ce8 <atoi+0x1e>
     d0a:	6422                	ld	s0,8(sp)
     d0c:	0141                	addi	sp,sp,16
     d0e:	8082                	ret
     d10:	4501                	li	a0,0
     d12:	bfe5                	j	d0a <atoi+0x40>

0000000000000d14 <memmove>:
     d14:	1141                	addi	sp,sp,-16
     d16:	e422                	sd	s0,8(sp)
     d18:	0800                	addi	s0,sp,16
     d1a:	02b57663          	bgeu	a0,a1,d46 <memmove+0x32>
     d1e:	02c05163          	blez	a2,d40 <memmove+0x2c>
     d22:	fff6079b          	addiw	a5,a2,-1
     d26:	1782                	slli	a5,a5,0x20
     d28:	9381                	srli	a5,a5,0x20
     d2a:	0785                	addi	a5,a5,1
     d2c:	97aa                	add	a5,a5,a0
     d2e:	872a                	mv	a4,a0
     d30:	0585                	addi	a1,a1,1
     d32:	0705                	addi	a4,a4,1
     d34:	fff5c683          	lbu	a3,-1(a1)
     d38:	fed70fa3          	sb	a3,-1(a4)
     d3c:	fee79ae3          	bne	a5,a4,d30 <memmove+0x1c>
     d40:	6422                	ld	s0,8(sp)
     d42:	0141                	addi	sp,sp,16
     d44:	8082                	ret
     d46:	00c50733          	add	a4,a0,a2
     d4a:	95b2                	add	a1,a1,a2
     d4c:	fec05ae3          	blez	a2,d40 <memmove+0x2c>
     d50:	fff6079b          	addiw	a5,a2,-1
     d54:	1782                	slli	a5,a5,0x20
     d56:	9381                	srli	a5,a5,0x20
     d58:	fff7c793          	not	a5,a5
     d5c:	97ba                	add	a5,a5,a4
     d5e:	15fd                	addi	a1,a1,-1
     d60:	177d                	addi	a4,a4,-1
     d62:	0005c683          	lbu	a3,0(a1)
     d66:	00d70023          	sb	a3,0(a4)
     d6a:	fee79ae3          	bne	a5,a4,d5e <memmove+0x4a>
     d6e:	bfc9                	j	d40 <memmove+0x2c>

0000000000000d70 <memcmp>:
     d70:	1141                	addi	sp,sp,-16
     d72:	e422                	sd	s0,8(sp)
     d74:	0800                	addi	s0,sp,16
     d76:	ca05                	beqz	a2,da6 <memcmp+0x36>
     d78:	fff6069b          	addiw	a3,a2,-1
     d7c:	1682                	slli	a3,a3,0x20
     d7e:	9281                	srli	a3,a3,0x20
     d80:	0685                	addi	a3,a3,1
     d82:	96aa                	add	a3,a3,a0
     d84:	00054783          	lbu	a5,0(a0)
     d88:	0005c703          	lbu	a4,0(a1)
     d8c:	00e79863          	bne	a5,a4,d9c <memcmp+0x2c>
     d90:	0505                	addi	a0,a0,1
     d92:	0585                	addi	a1,a1,1
     d94:	fed518e3          	bne	a0,a3,d84 <memcmp+0x14>
     d98:	4501                	li	a0,0
     d9a:	a019                	j	da0 <memcmp+0x30>
     d9c:	40e7853b          	subw	a0,a5,a4
     da0:	6422                	ld	s0,8(sp)
     da2:	0141                	addi	sp,sp,16
     da4:	8082                	ret
     da6:	4501                	li	a0,0
     da8:	bfe5                	j	da0 <memcmp+0x30>

0000000000000daa <memcpy>:
     daa:	1141                	addi	sp,sp,-16
     dac:	e406                	sd	ra,8(sp)
     dae:	e022                	sd	s0,0(sp)
     db0:	0800                	addi	s0,sp,16
     db2:	00000097          	auipc	ra,0x0
     db6:	f62080e7          	jalr	-158(ra) # d14 <memmove>
     dba:	60a2                	ld	ra,8(sp)
     dbc:	6402                	ld	s0,0(sp)
     dbe:	0141                	addi	sp,sp,16
     dc0:	8082                	ret

0000000000000dc2 <fork>:
     dc2:	4885                	li	a7,1
     dc4:	00000073          	ecall
     dc8:	8082                	ret

0000000000000dca <exit>:
     dca:	4889                	li	a7,2
     dcc:	00000073          	ecall
     dd0:	8082                	ret

0000000000000dd2 <wait>:
     dd2:	488d                	li	a7,3
     dd4:	00000073          	ecall
     dd8:	8082                	ret

0000000000000dda <pipe>:
     dda:	4891                	li	a7,4
     ddc:	00000073          	ecall
     de0:	8082                	ret

0000000000000de2 <read>:
     de2:	4895                	li	a7,5
     de4:	00000073          	ecall
     de8:	8082                	ret

0000000000000dea <write>:
     dea:	48c1                	li	a7,16
     dec:	00000073          	ecall
     df0:	8082                	ret

0000000000000df2 <close>:
     df2:	48d5                	li	a7,21
     df4:	00000073          	ecall
     df8:	8082                	ret

0000000000000dfa <kill>:
     dfa:	4899                	li	a7,6
     dfc:	00000073          	ecall
     e00:	8082                	ret

0000000000000e02 <exec>:
     e02:	489d                	li	a7,7
     e04:	00000073          	ecall
     e08:	8082                	ret

0000000000000e0a <open>:
     e0a:	48bd                	li	a7,15
     e0c:	00000073          	ecall
     e10:	8082                	ret

0000000000000e12 <mknod>:
     e12:	48c5                	li	a7,17
     e14:	00000073          	ecall
     e18:	8082                	ret

0000000000000e1a <unlink>:
     e1a:	48c9                	li	a7,18
     e1c:	00000073          	ecall
     e20:	8082                	ret

0000000000000e22 <fstat>:
     e22:	48a1                	li	a7,8
     e24:	00000073          	ecall
     e28:	8082                	ret

0000000000000e2a <link>:
     e2a:	48cd                	li	a7,19
     e2c:	00000073          	ecall
     e30:	8082                	ret

0000000000000e32 <mkdir>:
     e32:	48d1                	li	a7,20
     e34:	00000073          	ecall
     e38:	8082                	ret

0000000000000e3a <chdir>:
     e3a:	48a5                	li	a7,9
     e3c:	00000073          	ecall
     e40:	8082                	ret

0000000000000e42 <dup>:
     e42:	48a9                	li	a7,10
     e44:	00000073          	ecall
     e48:	8082                	ret

0000000000000e4a <getpid>:
     e4a:	48ad                	li	a7,11
     e4c:	00000073          	ecall
     e50:	8082                	ret

0000000000000e52 <sbrk>:
     e52:	48b1                	li	a7,12
     e54:	00000073          	ecall
     e58:	8082                	ret

0000000000000e5a <sleep>:
     e5a:	48b5                	li	a7,13
     e5c:	00000073          	ecall
     e60:	8082                	ret

0000000000000e62 <uptime>:
     e62:	48b9                	li	a7,14
     e64:	00000073          	ecall
     e68:	8082                	ret

0000000000000e6a <ps>:
     e6a:	48d9                	li	a7,22
     e6c:	00000073          	ecall
     e70:	8082                	ret

0000000000000e72 <setbkg>:
.global setbkg
setbkg:
 li a7, SYS_setbkg
     e72:	48dd                	li	a7,23
 ecall
     e74:	00000073          	ecall
 ret
     e78:	8082                	ret

0000000000000e7a <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
     e7a:	1101                	addi	sp,sp,-32
     e7c:	ec06                	sd	ra,24(sp)
     e7e:	e822                	sd	s0,16(sp)
     e80:	1000                	addi	s0,sp,32
     e82:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
     e86:	4605                	li	a2,1
     e88:	fef40593          	addi	a1,s0,-17
     e8c:	00000097          	auipc	ra,0x0
     e90:	f5e080e7          	jalr	-162(ra) # dea <write>
}
     e94:	60e2                	ld	ra,24(sp)
     e96:	6442                	ld	s0,16(sp)
     e98:	6105                	addi	sp,sp,32
     e9a:	8082                	ret

0000000000000e9c <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
     e9c:	7139                	addi	sp,sp,-64
     e9e:	fc06                	sd	ra,56(sp)
     ea0:	f822                	sd	s0,48(sp)
     ea2:	f426                	sd	s1,40(sp)
     ea4:	f04a                	sd	s2,32(sp)
     ea6:	ec4e                	sd	s3,24(sp)
     ea8:	0080                	addi	s0,sp,64
     eaa:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
     eac:	c299                	beqz	a3,eb2 <printint+0x16>
     eae:	0805c863          	bltz	a1,f3e <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
     eb2:	2581                	sext.w	a1,a1
  neg = 0;
     eb4:	4881                	li	a7,0
     eb6:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
     eba:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
     ebc:	2601                	sext.w	a2,a2
     ebe:	00000517          	auipc	a0,0x0
     ec2:	58250513          	addi	a0,a0,1410 # 1440 <digits>
     ec6:	883a                	mv	a6,a4
     ec8:	2705                	addiw	a4,a4,1
     eca:	02c5f7bb          	remuw	a5,a1,a2
     ece:	1782                	slli	a5,a5,0x20
     ed0:	9381                	srli	a5,a5,0x20
     ed2:	97aa                	add	a5,a5,a0
     ed4:	0007c783          	lbu	a5,0(a5)
     ed8:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
     edc:	0005879b          	sext.w	a5,a1
     ee0:	02c5d5bb          	divuw	a1,a1,a2
     ee4:	0685                	addi	a3,a3,1
     ee6:	fec7f0e3          	bgeu	a5,a2,ec6 <printint+0x2a>
  if(neg)
     eea:	00088b63          	beqz	a7,f00 <printint+0x64>
    buf[i++] = '-';
     eee:	fd040793          	addi	a5,s0,-48
     ef2:	973e                	add	a4,a4,a5
     ef4:	02d00793          	li	a5,45
     ef8:	fef70823          	sb	a5,-16(a4)
     efc:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
     f00:	02e05863          	blez	a4,f30 <printint+0x94>
     f04:	fc040793          	addi	a5,s0,-64
     f08:	00e78933          	add	s2,a5,a4
     f0c:	fff78993          	addi	s3,a5,-1
     f10:	99ba                	add	s3,s3,a4
     f12:	377d                	addiw	a4,a4,-1
     f14:	1702                	slli	a4,a4,0x20
     f16:	9301                	srli	a4,a4,0x20
     f18:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
     f1c:	fff94583          	lbu	a1,-1(s2)
     f20:	8526                	mv	a0,s1
     f22:	00000097          	auipc	ra,0x0
     f26:	f58080e7          	jalr	-168(ra) # e7a <putc>
  while(--i >= 0)
     f2a:	197d                	addi	s2,s2,-1
     f2c:	ff3918e3          	bne	s2,s3,f1c <printint+0x80>
}
     f30:	70e2                	ld	ra,56(sp)
     f32:	7442                	ld	s0,48(sp)
     f34:	74a2                	ld	s1,40(sp)
     f36:	7902                	ld	s2,32(sp)
     f38:	69e2                	ld	s3,24(sp)
     f3a:	6121                	addi	sp,sp,64
     f3c:	8082                	ret
    x = -xx;
     f3e:	40b005bb          	negw	a1,a1
    neg = 1;
     f42:	4885                	li	a7,1
    x = -xx;
     f44:	bf8d                	j	eb6 <printint+0x1a>

0000000000000f46 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
     f46:	7119                	addi	sp,sp,-128
     f48:	fc86                	sd	ra,120(sp)
     f4a:	f8a2                	sd	s0,112(sp)
     f4c:	f4a6                	sd	s1,104(sp)
     f4e:	f0ca                	sd	s2,96(sp)
     f50:	ecce                	sd	s3,88(sp)
     f52:	e8d2                	sd	s4,80(sp)
     f54:	e4d6                	sd	s5,72(sp)
     f56:	e0da                	sd	s6,64(sp)
     f58:	fc5e                	sd	s7,56(sp)
     f5a:	f862                	sd	s8,48(sp)
     f5c:	f466                	sd	s9,40(sp)
     f5e:	f06a                	sd	s10,32(sp)
     f60:	ec6e                	sd	s11,24(sp)
     f62:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
     f64:	0005c903          	lbu	s2,0(a1)
     f68:	18090f63          	beqz	s2,1106 <vprintf+0x1c0>
     f6c:	8aaa                	mv	s5,a0
     f6e:	8b32                	mv	s6,a2
     f70:	00158493          	addi	s1,a1,1
  state = 0;
     f74:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
     f76:	02500a13          	li	s4,37
      if(c == 'd'){
     f7a:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
     f7e:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
     f82:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
     f86:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
     f8a:	00000b97          	auipc	s7,0x0
     f8e:	4b6b8b93          	addi	s7,s7,1206 # 1440 <digits>
     f92:	a839                	j	fb0 <vprintf+0x6a>
        putc(fd, c);
     f94:	85ca                	mv	a1,s2
     f96:	8556                	mv	a0,s5
     f98:	00000097          	auipc	ra,0x0
     f9c:	ee2080e7          	jalr	-286(ra) # e7a <putc>
     fa0:	a019                	j	fa6 <vprintf+0x60>
    } else if(state == '%'){
     fa2:	01498f63          	beq	s3,s4,fc0 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
     fa6:	0485                	addi	s1,s1,1
     fa8:	fff4c903          	lbu	s2,-1(s1)
     fac:	14090d63          	beqz	s2,1106 <vprintf+0x1c0>
    c = fmt[i] & 0xff;
     fb0:	0009079b          	sext.w	a5,s2
    if(state == 0){
     fb4:	fe0997e3          	bnez	s3,fa2 <vprintf+0x5c>
      if(c == '%'){
     fb8:	fd479ee3          	bne	a5,s4,f94 <vprintf+0x4e>
        state = '%';
     fbc:	89be                	mv	s3,a5
     fbe:	b7e5                	j	fa6 <vprintf+0x60>
      if(c == 'd'){
     fc0:	05878063          	beq	a5,s8,1000 <vprintf+0xba>
      } else if(c == 'l') {
     fc4:	05978c63          	beq	a5,s9,101c <vprintf+0xd6>
      } else if(c == 'x') {
     fc8:	07a78863          	beq	a5,s10,1038 <vprintf+0xf2>
      } else if(c == 'p') {
     fcc:	09b78463          	beq	a5,s11,1054 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
     fd0:	07300713          	li	a4,115
     fd4:	0ce78663          	beq	a5,a4,10a0 <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
     fd8:	06300713          	li	a4,99
     fdc:	0ee78e63          	beq	a5,a4,10d8 <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
     fe0:	11478863          	beq	a5,s4,10f0 <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
     fe4:	85d2                	mv	a1,s4
     fe6:	8556                	mv	a0,s5
     fe8:	00000097          	auipc	ra,0x0
     fec:	e92080e7          	jalr	-366(ra) # e7a <putc>
        putc(fd, c);
     ff0:	85ca                	mv	a1,s2
     ff2:	8556                	mv	a0,s5
     ff4:	00000097          	auipc	ra,0x0
     ff8:	e86080e7          	jalr	-378(ra) # e7a <putc>
      }
      state = 0;
     ffc:	4981                	li	s3,0
     ffe:	b765                	j	fa6 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
    1000:	008b0913          	addi	s2,s6,8
    1004:	4685                	li	a3,1
    1006:	4629                	li	a2,10
    1008:	000b2583          	lw	a1,0(s6)
    100c:	8556                	mv	a0,s5
    100e:	00000097          	auipc	ra,0x0
    1012:	e8e080e7          	jalr	-370(ra) # e9c <printint>
    1016:	8b4a                	mv	s6,s2
      state = 0;
    1018:	4981                	li	s3,0
    101a:	b771                	j	fa6 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
    101c:	008b0913          	addi	s2,s6,8
    1020:	4681                	li	a3,0
    1022:	4629                	li	a2,10
    1024:	000b2583          	lw	a1,0(s6)
    1028:	8556                	mv	a0,s5
    102a:	00000097          	auipc	ra,0x0
    102e:	e72080e7          	jalr	-398(ra) # e9c <printint>
    1032:	8b4a                	mv	s6,s2
      state = 0;
    1034:	4981                	li	s3,0
    1036:	bf85                	j	fa6 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
    1038:	008b0913          	addi	s2,s6,8
    103c:	4681                	li	a3,0
    103e:	4641                	li	a2,16
    1040:	000b2583          	lw	a1,0(s6)
    1044:	8556                	mv	a0,s5
    1046:	00000097          	auipc	ra,0x0
    104a:	e56080e7          	jalr	-426(ra) # e9c <printint>
    104e:	8b4a                	mv	s6,s2
      state = 0;
    1050:	4981                	li	s3,0
    1052:	bf91                	j	fa6 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
    1054:	008b0793          	addi	a5,s6,8
    1058:	f8f43423          	sd	a5,-120(s0)
    105c:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
    1060:	03000593          	li	a1,48
    1064:	8556                	mv	a0,s5
    1066:	00000097          	auipc	ra,0x0
    106a:	e14080e7          	jalr	-492(ra) # e7a <putc>
  putc(fd, 'x');
    106e:	85ea                	mv	a1,s10
    1070:	8556                	mv	a0,s5
    1072:	00000097          	auipc	ra,0x0
    1076:	e08080e7          	jalr	-504(ra) # e7a <putc>
    107a:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
    107c:	03c9d793          	srli	a5,s3,0x3c
    1080:	97de                	add	a5,a5,s7
    1082:	0007c583          	lbu	a1,0(a5)
    1086:	8556                	mv	a0,s5
    1088:	00000097          	auipc	ra,0x0
    108c:	df2080e7          	jalr	-526(ra) # e7a <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    1090:	0992                	slli	s3,s3,0x4
    1092:	397d                	addiw	s2,s2,-1
    1094:	fe0914e3          	bnez	s2,107c <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
    1098:	f8843b03          	ld	s6,-120(s0)
      state = 0;
    109c:	4981                	li	s3,0
    109e:	b721                	j	fa6 <vprintf+0x60>
        s = va_arg(ap, char*);
    10a0:	008b0993          	addi	s3,s6,8
    10a4:	000b3903          	ld	s2,0(s6)
        if(s == 0)
    10a8:	02090163          	beqz	s2,10ca <vprintf+0x184>
        while(*s != 0){
    10ac:	00094583          	lbu	a1,0(s2)
    10b0:	c9a1                	beqz	a1,1100 <vprintf+0x1ba>
          putc(fd, *s);
    10b2:	8556                	mv	a0,s5
    10b4:	00000097          	auipc	ra,0x0
    10b8:	dc6080e7          	jalr	-570(ra) # e7a <putc>
          s++;
    10bc:	0905                	addi	s2,s2,1
        while(*s != 0){
    10be:	00094583          	lbu	a1,0(s2)
    10c2:	f9e5                	bnez	a1,10b2 <vprintf+0x16c>
        s = va_arg(ap, char*);
    10c4:	8b4e                	mv	s6,s3
      state = 0;
    10c6:	4981                	li	s3,0
    10c8:	bdf9                	j	fa6 <vprintf+0x60>
          s = "(null)";
    10ca:	00000917          	auipc	s2,0x0
    10ce:	36e90913          	addi	s2,s2,878 # 1438 <malloc+0x228>
        while(*s != 0){
    10d2:	02800593          	li	a1,40
    10d6:	bff1                	j	10b2 <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
    10d8:	008b0913          	addi	s2,s6,8
    10dc:	000b4583          	lbu	a1,0(s6)
    10e0:	8556                	mv	a0,s5
    10e2:	00000097          	auipc	ra,0x0
    10e6:	d98080e7          	jalr	-616(ra) # e7a <putc>
    10ea:	8b4a                	mv	s6,s2
      state = 0;
    10ec:	4981                	li	s3,0
    10ee:	bd65                	j	fa6 <vprintf+0x60>
        putc(fd, c);
    10f0:	85d2                	mv	a1,s4
    10f2:	8556                	mv	a0,s5
    10f4:	00000097          	auipc	ra,0x0
    10f8:	d86080e7          	jalr	-634(ra) # e7a <putc>
      state = 0;
    10fc:	4981                	li	s3,0
    10fe:	b565                	j	fa6 <vprintf+0x60>
        s = va_arg(ap, char*);
    1100:	8b4e                	mv	s6,s3
      state = 0;
    1102:	4981                	li	s3,0
    1104:	b54d                	j	fa6 <vprintf+0x60>
    }
  }
}
    1106:	70e6                	ld	ra,120(sp)
    1108:	7446                	ld	s0,112(sp)
    110a:	74a6                	ld	s1,104(sp)
    110c:	7906                	ld	s2,96(sp)
    110e:	69e6                	ld	s3,88(sp)
    1110:	6a46                	ld	s4,80(sp)
    1112:	6aa6                	ld	s5,72(sp)
    1114:	6b06                	ld	s6,64(sp)
    1116:	7be2                	ld	s7,56(sp)
    1118:	7c42                	ld	s8,48(sp)
    111a:	7ca2                	ld	s9,40(sp)
    111c:	7d02                	ld	s10,32(sp)
    111e:	6de2                	ld	s11,24(sp)
    1120:	6109                	addi	sp,sp,128
    1122:	8082                	ret

0000000000001124 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
    1124:	715d                	addi	sp,sp,-80
    1126:	ec06                	sd	ra,24(sp)
    1128:	e822                	sd	s0,16(sp)
    112a:	1000                	addi	s0,sp,32
    112c:	e010                	sd	a2,0(s0)
    112e:	e414                	sd	a3,8(s0)
    1130:	e818                	sd	a4,16(s0)
    1132:	ec1c                	sd	a5,24(s0)
    1134:	03043023          	sd	a6,32(s0)
    1138:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
    113c:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
    1140:	8622                	mv	a2,s0
    1142:	00000097          	auipc	ra,0x0
    1146:	e04080e7          	jalr	-508(ra) # f46 <vprintf>
}
    114a:	60e2                	ld	ra,24(sp)
    114c:	6442                	ld	s0,16(sp)
    114e:	6161                	addi	sp,sp,80
    1150:	8082                	ret

0000000000001152 <printf>:

void
printf(const char *fmt, ...)
{
    1152:	711d                	addi	sp,sp,-96
    1154:	ec06                	sd	ra,24(sp)
    1156:	e822                	sd	s0,16(sp)
    1158:	1000                	addi	s0,sp,32
    115a:	e40c                	sd	a1,8(s0)
    115c:	e810                	sd	a2,16(s0)
    115e:	ec14                	sd	a3,24(s0)
    1160:	f018                	sd	a4,32(s0)
    1162:	f41c                	sd	a5,40(s0)
    1164:	03043823          	sd	a6,48(s0)
    1168:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
    116c:	00840613          	addi	a2,s0,8
    1170:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
    1174:	85aa                	mv	a1,a0
    1176:	4505                	li	a0,1
    1178:	00000097          	auipc	ra,0x0
    117c:	dce080e7          	jalr	-562(ra) # f46 <vprintf>
}
    1180:	60e2                	ld	ra,24(sp)
    1182:	6442                	ld	s0,16(sp)
    1184:	6125                	addi	sp,sp,96
    1186:	8082                	ret

<<<<<<< HEAD
0000000000001180 <free>:
    1180:	1141                	addi	sp,sp,-16
    1182:	e422                	sd	s0,8(sp)
    1184:	0800                	addi	s0,sp,16
    1186:	ff050693          	addi	a3,a0,-16
    118a:	00000797          	auipc	a5,0x0
    118e:	2d67b783          	ld	a5,726(a5) # 1460 <freep>
    1192:	a805                	j	11c2 <free+0x42>
    1194:	4618                	lw	a4,8(a2)
    1196:	9db9                	addw	a1,a1,a4
    1198:	feb52c23          	sw	a1,-8(a0)
    119c:	6398                	ld	a4,0(a5)
    119e:	6318                	ld	a4,0(a4)
    11a0:	fee53823          	sd	a4,-16(a0)
    11a4:	a091                	j	11e8 <free+0x68>
    11a6:	ff852703          	lw	a4,-8(a0)
    11aa:	9e39                	addw	a2,a2,a4
    11ac:	c790                	sw	a2,8(a5)
    11ae:	ff053703          	ld	a4,-16(a0)
    11b2:	e398                	sd	a4,0(a5)
    11b4:	a099                	j	11fa <free+0x7a>
    11b6:	6398                	ld	a4,0(a5)
    11b8:	00e7e463          	bltu	a5,a4,11c0 <free+0x40>
    11bc:	00e6ea63          	bltu	a3,a4,11d0 <free+0x50>
    11c0:	87ba                	mv	a5,a4
    11c2:	fed7fae3          	bgeu	a5,a3,11b6 <free+0x36>
    11c6:	6398                	ld	a4,0(a5)
    11c8:	00e6e463          	bltu	a3,a4,11d0 <free+0x50>
    11cc:	fee7eae3          	bltu	a5,a4,11c0 <free+0x40>
    11d0:	ff852583          	lw	a1,-8(a0)
    11d4:	6390                	ld	a2,0(a5)
    11d6:	02059713          	slli	a4,a1,0x20
    11da:	9301                	srli	a4,a4,0x20
    11dc:	0712                	slli	a4,a4,0x4
    11de:	9736                	add	a4,a4,a3
    11e0:	fae60ae3          	beq	a2,a4,1194 <free+0x14>
    11e4:	fec53823          	sd	a2,-16(a0)
    11e8:	4790                	lw	a2,8(a5)
    11ea:	02061713          	slli	a4,a2,0x20
    11ee:	9301                	srli	a4,a4,0x20
    11f0:	0712                	slli	a4,a4,0x4
    11f2:	973e                	add	a4,a4,a5
    11f4:	fae689e3          	beq	a3,a4,11a6 <free+0x26>
    11f8:	e394                	sd	a3,0(a5)
    11fa:	00000717          	auipc	a4,0x0
    11fe:	26f73323          	sd	a5,614(a4) # 1460 <freep>
    1202:	6422                	ld	s0,8(sp)
    1204:	0141                	addi	sp,sp,16
    1206:	8082                	ret

0000000000001208 <malloc>:
    1208:	7139                	addi	sp,sp,-64
    120a:	fc06                	sd	ra,56(sp)
    120c:	f822                	sd	s0,48(sp)
    120e:	f426                	sd	s1,40(sp)
    1210:	f04a                	sd	s2,32(sp)
    1212:	ec4e                	sd	s3,24(sp)
    1214:	e852                	sd	s4,16(sp)
    1216:	e456                	sd	s5,8(sp)
    1218:	e05a                	sd	s6,0(sp)
    121a:	0080                	addi	s0,sp,64
    121c:	02051493          	slli	s1,a0,0x20
    1220:	9081                	srli	s1,s1,0x20
    1222:	04bd                	addi	s1,s1,15
    1224:	8091                	srli	s1,s1,0x4
    1226:	0014899b          	addiw	s3,s1,1
    122a:	0485                	addi	s1,s1,1
    122c:	00000517          	auipc	a0,0x0
    1230:	23453503          	ld	a0,564(a0) # 1460 <freep>
    1234:	c515                	beqz	a0,1260 <malloc+0x58>
    1236:	611c                	ld	a5,0(a0)
    1238:	4798                	lw	a4,8(a5)
    123a:	02977f63          	bgeu	a4,s1,1278 <malloc+0x70>
    123e:	8a4e                	mv	s4,s3
    1240:	0009871b          	sext.w	a4,s3
    1244:	6685                	lui	a3,0x1
    1246:	00d77363          	bgeu	a4,a3,124c <malloc+0x44>
    124a:	6a05                	lui	s4,0x1
    124c:	000a0b1b          	sext.w	s6,s4
    1250:	004a1a1b          	slliw	s4,s4,0x4
    1254:	00000917          	auipc	s2,0x0
    1258:	20c90913          	addi	s2,s2,524 # 1460 <freep>
    125c:	5afd                	li	s5,-1
    125e:	a88d                	j	12d0 <malloc+0xc8>
    1260:	00000797          	auipc	a5,0x0
    1264:	27078793          	addi	a5,a5,624 # 14d0 <base>
    1268:	00000717          	auipc	a4,0x0
    126c:	1ef73c23          	sd	a5,504(a4) # 1460 <freep>
    1270:	e39c                	sd	a5,0(a5)
    1272:	0007a423          	sw	zero,8(a5)
    1276:	b7e1                	j	123e <malloc+0x36>
    1278:	02e48b63          	beq	s1,a4,12ae <malloc+0xa6>
    127c:	4137073b          	subw	a4,a4,s3
    1280:	c798                	sw	a4,8(a5)
    1282:	1702                	slli	a4,a4,0x20
    1284:	9301                	srli	a4,a4,0x20
    1286:	0712                	slli	a4,a4,0x4
    1288:	97ba                	add	a5,a5,a4
    128a:	0137a423          	sw	s3,8(a5)
    128e:	00000717          	auipc	a4,0x0
    1292:	1ca73923          	sd	a0,466(a4) # 1460 <freep>
    1296:	01078513          	addi	a0,a5,16
    129a:	70e2                	ld	ra,56(sp)
    129c:	7442                	ld	s0,48(sp)
    129e:	74a2                	ld	s1,40(sp)
    12a0:	7902                	ld	s2,32(sp)
    12a2:	69e2                	ld	s3,24(sp)
    12a4:	6a42                	ld	s4,16(sp)
    12a6:	6aa2                	ld	s5,8(sp)
    12a8:	6b02                	ld	s6,0(sp)
    12aa:	6121                	addi	sp,sp,64
    12ac:	8082                	ret
    12ae:	6398                	ld	a4,0(a5)
    12b0:	e118                	sd	a4,0(a0)
    12b2:	bff1                	j	128e <malloc+0x86>
    12b4:	01652423          	sw	s6,8(a0)
    12b8:	0541                	addi	a0,a0,16
    12ba:	00000097          	auipc	ra,0x0
    12be:	ec6080e7          	jalr	-314(ra) # 1180 <free>
    12c2:	00093503          	ld	a0,0(s2)
    12c6:	d971                	beqz	a0,129a <malloc+0x92>
    12c8:	611c                	ld	a5,0(a0)
    12ca:	4798                	lw	a4,8(a5)
    12cc:	fa9776e3          	bgeu	a4,s1,1278 <malloc+0x70>
    12d0:	00093703          	ld	a4,0(s2)
    12d4:	853e                	mv	a0,a5
    12d6:	fef719e3          	bne	a4,a5,12c8 <malloc+0xc0>
    12da:	8552                	mv	a0,s4
    12dc:	00000097          	auipc	ra,0x0
    12e0:	b76080e7          	jalr	-1162(ra) # e52 <sbrk>
    12e4:	fd5518e3          	bne	a0,s5,12b4 <malloc+0xac>
    12e8:	4501                	li	a0,0
    12ea:	bf45                	j	129a <malloc+0x92>
=======
0000000000001188 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
    1188:	1141                	addi	sp,sp,-16
    118a:	e422                	sd	s0,8(sp)
    118c:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
    118e:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    1192:	00000797          	auipc	a5,0x0
    1196:	2d67b783          	ld	a5,726(a5) # 1468 <freep>
    119a:	a805                	j	11ca <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
    119c:	4618                	lw	a4,8(a2)
    119e:	9db9                	addw	a1,a1,a4
    11a0:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
    11a4:	6398                	ld	a4,0(a5)
    11a6:	6318                	ld	a4,0(a4)
    11a8:	fee53823          	sd	a4,-16(a0)
    11ac:	a091                	j	11f0 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
    11ae:	ff852703          	lw	a4,-8(a0)
    11b2:	9e39                	addw	a2,a2,a4
    11b4:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
    11b6:	ff053703          	ld	a4,-16(a0)
    11ba:	e398                	sd	a4,0(a5)
    11bc:	a099                	j	1202 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    11be:	6398                	ld	a4,0(a5)
    11c0:	00e7e463          	bltu	a5,a4,11c8 <free+0x40>
    11c4:	00e6ea63          	bltu	a3,a4,11d8 <free+0x50>
{
    11c8:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    11ca:	fed7fae3          	bgeu	a5,a3,11be <free+0x36>
    11ce:	6398                	ld	a4,0(a5)
    11d0:	00e6e463          	bltu	a3,a4,11d8 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    11d4:	fee7eae3          	bltu	a5,a4,11c8 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
    11d8:	ff852583          	lw	a1,-8(a0)
    11dc:	6390                	ld	a2,0(a5)
    11de:	02059713          	slli	a4,a1,0x20
    11e2:	9301                	srli	a4,a4,0x20
    11e4:	0712                	slli	a4,a4,0x4
    11e6:	9736                	add	a4,a4,a3
    11e8:	fae60ae3          	beq	a2,a4,119c <free+0x14>
    bp->s.ptr = p->s.ptr;
    11ec:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
    11f0:	4790                	lw	a2,8(a5)
    11f2:	02061713          	slli	a4,a2,0x20
    11f6:	9301                	srli	a4,a4,0x20
    11f8:	0712                	slli	a4,a4,0x4
    11fa:	973e                	add	a4,a4,a5
    11fc:	fae689e3          	beq	a3,a4,11ae <free+0x26>
  } else
    p->s.ptr = bp;
    1200:	e394                	sd	a3,0(a5)
  freep = p;
    1202:	00000717          	auipc	a4,0x0
    1206:	26f73323          	sd	a5,614(a4) # 1468 <freep>
}
    120a:	6422                	ld	s0,8(sp)
    120c:	0141                	addi	sp,sp,16
    120e:	8082                	ret

0000000000001210 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
    1210:	7139                	addi	sp,sp,-64
    1212:	fc06                	sd	ra,56(sp)
    1214:	f822                	sd	s0,48(sp)
    1216:	f426                	sd	s1,40(sp)
    1218:	f04a                	sd	s2,32(sp)
    121a:	ec4e                	sd	s3,24(sp)
    121c:	e852                	sd	s4,16(sp)
    121e:	e456                	sd	s5,8(sp)
    1220:	e05a                	sd	s6,0(sp)
    1222:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
    1224:	02051493          	slli	s1,a0,0x20
    1228:	9081                	srli	s1,s1,0x20
    122a:	04bd                	addi	s1,s1,15
    122c:	8091                	srli	s1,s1,0x4
    122e:	0014899b          	addiw	s3,s1,1
    1232:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
    1234:	00000517          	auipc	a0,0x0
    1238:	23453503          	ld	a0,564(a0) # 1468 <freep>
    123c:	c515                	beqz	a0,1268 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    123e:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    1240:	4798                	lw	a4,8(a5)
    1242:	02977f63          	bgeu	a4,s1,1280 <malloc+0x70>
    1246:	8a4e                	mv	s4,s3
    1248:	0009871b          	sext.w	a4,s3
    124c:	6685                	lui	a3,0x1
    124e:	00d77363          	bgeu	a4,a3,1254 <malloc+0x44>
    1252:	6a05                	lui	s4,0x1
    1254:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
    1258:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
    125c:	00000917          	auipc	s2,0x0
    1260:	20c90913          	addi	s2,s2,524 # 1468 <freep>
  if(p == (char*)-1)
    1264:	5afd                	li	s5,-1
    1266:	a88d                	j	12d8 <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
    1268:	00000797          	auipc	a5,0x0
    126c:	27078793          	addi	a5,a5,624 # 14d8 <base>
    1270:	00000717          	auipc	a4,0x0
    1274:	1ef73c23          	sd	a5,504(a4) # 1468 <freep>
    1278:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
    127a:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
    127e:	b7e1                	j	1246 <malloc+0x36>
      if(p->s.size == nunits)
    1280:	02e48b63          	beq	s1,a4,12b6 <malloc+0xa6>
        p->s.size -= nunits;
    1284:	4137073b          	subw	a4,a4,s3
    1288:	c798                	sw	a4,8(a5)
        p += p->s.size;
    128a:	1702                	slli	a4,a4,0x20
    128c:	9301                	srli	a4,a4,0x20
    128e:	0712                	slli	a4,a4,0x4
    1290:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
    1292:	0137a423          	sw	s3,8(a5)
      freep = prevp;
    1296:	00000717          	auipc	a4,0x0
    129a:	1ca73923          	sd	a0,466(a4) # 1468 <freep>
      return (void*)(p + 1);
    129e:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
    12a2:	70e2                	ld	ra,56(sp)
    12a4:	7442                	ld	s0,48(sp)
    12a6:	74a2                	ld	s1,40(sp)
    12a8:	7902                	ld	s2,32(sp)
    12aa:	69e2                	ld	s3,24(sp)
    12ac:	6a42                	ld	s4,16(sp)
    12ae:	6aa2                	ld	s5,8(sp)
    12b0:	6b02                	ld	s6,0(sp)
    12b2:	6121                	addi	sp,sp,64
    12b4:	8082                	ret
        prevp->s.ptr = p->s.ptr;
    12b6:	6398                	ld	a4,0(a5)
    12b8:	e118                	sd	a4,0(a0)
    12ba:	bff1                	j	1296 <malloc+0x86>
  hp->s.size = nu;
    12bc:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
    12c0:	0541                	addi	a0,a0,16
    12c2:	00000097          	auipc	ra,0x0
    12c6:	ec6080e7          	jalr	-314(ra) # 1188 <free>
  return freep;
    12ca:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
    12ce:	d971                	beqz	a0,12a2 <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    12d0:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    12d2:	4798                	lw	a4,8(a5)
    12d4:	fa9776e3          	bgeu	a4,s1,1280 <malloc+0x70>
    if(p == freep)
    12d8:	00093703          	ld	a4,0(s2)
    12dc:	853e                	mv	a0,a5
    12de:	fef719e3          	bne	a4,a5,12d0 <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
    12e2:	8552                	mv	a0,s4
    12e4:	00000097          	auipc	ra,0x0
    12e8:	b6e080e7          	jalr	-1170(ra) # e52 <sbrk>
  if(p == (char*)-1)
    12ec:	fd5518e3          	bne	a0,s5,12bc <malloc+0xac>
        return 0;
    12f0:	4501                	li	a0,0
    12f2:	bf45                	j	12a2 <malloc+0x92>
>>>>>>> 355fddefdb805d91072b3597f4cbd2b4e7481a8e
