
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00009117          	auipc	sp,0x9
    80000004:	86013103          	ld	sp,-1952(sp) # 80008860 <_GLOBAL_OFFSET_TABLE_+0x8>
    80000008:	6505                	lui	a0,0x1
    8000000a:	f14025f3          	csrr	a1,mhartid
    8000000e:	0585                	addi	a1,a1,1
    80000010:	02b50533          	mul	a0,a0,a1
    80000014:	912a                	add	sp,sp,a0
    80000016:	078000ef          	jal	ra,8000008e <start>

000000008000001a <spin>:
    8000001a:	a001                	j	8000001a <spin>

000000008000001c <timerinit>:
// which arrive at timervec in kernelvec.S,
// which turns them into software interrupts for
// devintr() in trap.c.
void
timerinit()
{
    8000001c:	1141                	addi	sp,sp,-16
    8000001e:	e422                	sd	s0,8(sp)
    80000020:	0800                	addi	s0,sp,16
// which hart (core) is this?
static inline uint64
r_mhartid()
{
  uint64 x;
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    80000022:	f14027f3          	csrr	a5,mhartid
  // each CPU has a separate source of timer interrupts.
  int id = r_mhartid();
    80000026:	0007869b          	sext.w	a3,a5

  // ask the CLINT for a timer interrupt.
  int interval = 1000000; // cycles; about 1/10th second in qemu.
  *(uint64*)CLINT_MTIMECMP(id) = *(uint64*)CLINT_MTIME + interval;
    8000002a:	0037979b          	slliw	a5,a5,0x3
    8000002e:	02004737          	lui	a4,0x2004
    80000032:	97ba                	add	a5,a5,a4
    80000034:	0200c737          	lui	a4,0x200c
    80000038:	ff873583          	ld	a1,-8(a4) # 200bff8 <_entry-0x7dff4008>
    8000003c:	000f4637          	lui	a2,0xf4
    80000040:	24060613          	addi	a2,a2,576 # f4240 <_entry-0x7ff0bdc0>
    80000044:	95b2                	add	a1,a1,a2
    80000046:	e38c                	sd	a1,0(a5)

  // prepare information in scratch[] for timervec.
  // scratch[0..2] : space for timervec to save registers.
  // scratch[3] : address of CLINT MTIMECMP register.
  // scratch[4] : desired interval (in cycles) between timer interrupts.
  uint64 *scratch = &timer_scratch[id][0];
    80000048:	00269713          	slli	a4,a3,0x2
    8000004c:	9736                	add	a4,a4,a3
    8000004e:	00371693          	slli	a3,a4,0x3
    80000052:	00009717          	auipc	a4,0x9
    80000056:	fee70713          	addi	a4,a4,-18 # 80009040 <timer_scratch>
    8000005a:	9736                	add	a4,a4,a3
  scratch[3] = CLINT_MTIMECMP(id);
    8000005c:	ef1c                	sd	a5,24(a4)
  scratch[4] = interval;
    8000005e:	f310                	sd	a2,32(a4)
}

static inline void 
w_mscratch(uint64 x)
{
  asm volatile("csrw mscratch, %0" : : "r" (x));
    80000060:	34071073          	csrw	mscratch,a4
  asm volatile("csrw mtvec, %0" : : "r" (x));
    80000064:	00006797          	auipc	a5,0x6
    80000068:	c2c78793          	addi	a5,a5,-980 # 80005c90 <timervec>
    8000006c:	30579073          	csrw	mtvec,a5
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000070:	300027f3          	csrr	a5,mstatus

  // set the machine-mode trap handler.
  w_mtvec((uint64)timervec);

  // enable machine-mode interrupts.
  w_mstatus(r_mstatus() | MSTATUS_MIE);
    80000074:	0087e793          	ori	a5,a5,8
  asm volatile("csrw mstatus, %0" : : "r" (x));
    80000078:	30079073          	csrw	mstatus,a5
  asm volatile("csrr %0, mie" : "=r" (x) );
    8000007c:	304027f3          	csrr	a5,mie

  // enable machine-mode timer interrupts.
  w_mie(r_mie() | MIE_MTIE);
    80000080:	0807e793          	ori	a5,a5,128
  asm volatile("csrw mie, %0" : : "r" (x));
    80000084:	30479073          	csrw	mie,a5
}
    80000088:	6422                	ld	s0,8(sp)
    8000008a:	0141                	addi	sp,sp,16
    8000008c:	8082                	ret

000000008000008e <start>:
{
    8000008e:	1141                	addi	sp,sp,-16
    80000090:	e406                	sd	ra,8(sp)
    80000092:	e022                	sd	s0,0(sp)
    80000094:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000096:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    8000009a:	7779                	lui	a4,0xffffe
    8000009c:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffd87ff>
    800000a0:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    800000a2:	6705                	lui	a4,0x1
    800000a4:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    800000a8:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    800000aa:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    800000ae:	00001797          	auipc	a5,0x1
    800000b2:	dd678793          	addi	a5,a5,-554 # 80000e84 <main>
    800000b6:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    800000ba:	4781                	li	a5,0
    800000bc:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    800000c0:	67c1                	lui	a5,0x10
    800000c2:	17fd                	addi	a5,a5,-1
    800000c4:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    800000c8:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    800000cc:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    800000d0:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    800000d4:	10479073          	csrw	sie,a5
  timerinit();
    800000d8:	00000097          	auipc	ra,0x0
    800000dc:	f44080e7          	jalr	-188(ra) # 8000001c <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    800000e0:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800000e4:	2781                	sext.w	a5,a5
}

static inline void 
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r" (x));
    800000e6:	823e                	mv	tp,a5
  asm volatile("mret");
    800000e8:	30200073          	mret
}
    800000ec:	60a2                	ld	ra,8(sp)
    800000ee:	6402                	ld	s0,0(sp)
    800000f0:	0141                	addi	sp,sp,16
    800000f2:	8082                	ret

00000000800000f4 <consolewrite>:
//
// user write()s to the console go here.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    800000f4:	715d                	addi	sp,sp,-80
    800000f6:	e486                	sd	ra,72(sp)
    800000f8:	e0a2                	sd	s0,64(sp)
    800000fa:	fc26                	sd	s1,56(sp)
    800000fc:	f84a                	sd	s2,48(sp)
    800000fe:	f44e                	sd	s3,40(sp)
    80000100:	f052                	sd	s4,32(sp)
    80000102:	ec56                	sd	s5,24(sp)
    80000104:	0880                	addi	s0,sp,80
  int i;

  for(i = 0; i < n; i++){
    80000106:	04c05663          	blez	a2,80000152 <consolewrite+0x5e>
    8000010a:	8a2a                	mv	s4,a0
    8000010c:	84ae                	mv	s1,a1
    8000010e:	89b2                	mv	s3,a2
    80000110:	4901                	li	s2,0
    char c;
    if(either_copyin(&c, user_src, src+i, 1) == -1)
    80000112:	5afd                	li	s5,-1
    80000114:	4685                	li	a3,1
    80000116:	8626                	mv	a2,s1
    80000118:	85d2                	mv	a1,s4
    8000011a:	fbf40513          	addi	a0,s0,-65
    8000011e:	00002097          	auipc	ra,0x2
    80000122:	388080e7          	jalr	904(ra) # 800024a6 <either_copyin>
    80000126:	01550c63          	beq	a0,s5,8000013e <consolewrite+0x4a>
      break;
    uartputc(c);
    8000012a:	fbf44503          	lbu	a0,-65(s0)
    8000012e:	00000097          	auipc	ra,0x0
    80000132:	78e080e7          	jalr	1934(ra) # 800008bc <uartputc>
  for(i = 0; i < n; i++){
    80000136:	2905                	addiw	s2,s2,1
    80000138:	0485                	addi	s1,s1,1
    8000013a:	fd299de3          	bne	s3,s2,80000114 <consolewrite+0x20>
  }

  return i;
}
    8000013e:	854a                	mv	a0,s2
    80000140:	60a6                	ld	ra,72(sp)
    80000142:	6406                	ld	s0,64(sp)
    80000144:	74e2                	ld	s1,56(sp)
    80000146:	7942                	ld	s2,48(sp)
    80000148:	79a2                	ld	s3,40(sp)
    8000014a:	7a02                	ld	s4,32(sp)
    8000014c:	6ae2                	ld	s5,24(sp)
    8000014e:	6161                	addi	sp,sp,80
    80000150:	8082                	ret
  for(i = 0; i < n; i++){
    80000152:	4901                	li	s2,0
    80000154:	b7ed                	j	8000013e <consolewrite+0x4a>

0000000080000156 <consoleread>:
// user_dist indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    80000156:	7119                	addi	sp,sp,-128
    80000158:	fc86                	sd	ra,120(sp)
    8000015a:	f8a2                	sd	s0,112(sp)
    8000015c:	f4a6                	sd	s1,104(sp)
    8000015e:	f0ca                	sd	s2,96(sp)
    80000160:	ecce                	sd	s3,88(sp)
    80000162:	e8d2                	sd	s4,80(sp)
    80000164:	e4d6                	sd	s5,72(sp)
    80000166:	e0da                	sd	s6,64(sp)
    80000168:	fc5e                	sd	s7,56(sp)
    8000016a:	f862                	sd	s8,48(sp)
    8000016c:	f466                	sd	s9,40(sp)
    8000016e:	f06a                	sd	s10,32(sp)
    80000170:	ec6e                	sd	s11,24(sp)
    80000172:	0100                	addi	s0,sp,128
    80000174:	8b2a                	mv	s6,a0
    80000176:	8aae                	mv	s5,a1
    80000178:	8a32                	mv	s4,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    8000017a:	00060b9b          	sext.w	s7,a2
  acquire(&cons.lock);
    8000017e:	00011517          	auipc	a0,0x11
    80000182:	00250513          	addi	a0,a0,2 # 80011180 <cons>
    80000186:	00001097          	auipc	ra,0x1
    8000018a:	a50080e7          	jalr	-1456(ra) # 80000bd6 <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    8000018e:	00011497          	auipc	s1,0x11
    80000192:	ff248493          	addi	s1,s1,-14 # 80011180 <cons>
      if(myproc()->killed){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    80000196:	89a6                	mv	s3,s1
    80000198:	00011917          	auipc	s2,0x11
    8000019c:	08090913          	addi	s2,s2,128 # 80011218 <cons+0x98>
    }

    c = cons.buf[cons.r++ % INPUT_BUF];

    if(c == C('D')){  // end-of-file
    800001a0:	4c91                	li	s9,4
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    800001a2:	5d7d                	li	s10,-1
      break;

    dst++;
    --n;

    if(c == '\n'){
    800001a4:	4da9                	li	s11,10
  while(n > 0){
    800001a6:	07405863          	blez	s4,80000216 <consoleread+0xc0>
    while(cons.r == cons.w){
    800001aa:	0984a783          	lw	a5,152(s1)
    800001ae:	09c4a703          	lw	a4,156(s1)
    800001b2:	02f71463          	bne	a4,a5,800001da <consoleread+0x84>
      if(myproc()->killed){
    800001b6:	00001097          	auipc	ra,0x1
    800001ba:	7de080e7          	jalr	2014(ra) # 80001994 <myproc>
    800001be:	551c                	lw	a5,40(a0)
    800001c0:	e7b5                	bnez	a5,8000022c <consoleread+0xd6>
      sleep(&cons.r, &cons.lock);
    800001c2:	85ce                	mv	a1,s3
    800001c4:	854a                	mv	a0,s2
    800001c6:	00002097          	auipc	ra,0x2
    800001ca:	ee6080e7          	jalr	-282(ra) # 800020ac <sleep>
    while(cons.r == cons.w){
    800001ce:	0984a783          	lw	a5,152(s1)
    800001d2:	09c4a703          	lw	a4,156(s1)
    800001d6:	fef700e3          	beq	a4,a5,800001b6 <consoleread+0x60>
    c = cons.buf[cons.r++ % INPUT_BUF];
    800001da:	0017871b          	addiw	a4,a5,1
    800001de:	08e4ac23          	sw	a4,152(s1)
    800001e2:	07f7f713          	andi	a4,a5,127
    800001e6:	9726                	add	a4,a4,s1
    800001e8:	01874703          	lbu	a4,24(a4)
    800001ec:	00070c1b          	sext.w	s8,a4
    if(c == C('D')){  // end-of-file
    800001f0:	079c0663          	beq	s8,s9,8000025c <consoleread+0x106>
    cbuf = c;
    800001f4:	f8e407a3          	sb	a4,-113(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    800001f8:	4685                	li	a3,1
    800001fa:	f8f40613          	addi	a2,s0,-113
    800001fe:	85d6                	mv	a1,s5
    80000200:	855a                	mv	a0,s6
    80000202:	00002097          	auipc	ra,0x2
    80000206:	24e080e7          	jalr	590(ra) # 80002450 <either_copyout>
    8000020a:	01a50663          	beq	a0,s10,80000216 <consoleread+0xc0>
    dst++;
    8000020e:	0a85                	addi	s5,s5,1
    --n;
    80000210:	3a7d                	addiw	s4,s4,-1
    if(c == '\n'){
    80000212:	f9bc1ae3          	bne	s8,s11,800001a6 <consoleread+0x50>
      // a whole line has arrived, return to
      // the user-level read().
      break;
    }
  }
  release(&cons.lock);
    80000216:	00011517          	auipc	a0,0x11
    8000021a:	f6a50513          	addi	a0,a0,-150 # 80011180 <cons>
    8000021e:	00001097          	auipc	ra,0x1
    80000222:	a6c080e7          	jalr	-1428(ra) # 80000c8a <release>

  return target - n;
    80000226:	414b853b          	subw	a0,s7,s4
    8000022a:	a811                	j	8000023e <consoleread+0xe8>
        release(&cons.lock);
    8000022c:	00011517          	auipc	a0,0x11
    80000230:	f5450513          	addi	a0,a0,-172 # 80011180 <cons>
    80000234:	00001097          	auipc	ra,0x1
    80000238:	a56080e7          	jalr	-1450(ra) # 80000c8a <release>
        return -1;
    8000023c:	557d                	li	a0,-1
}
    8000023e:	70e6                	ld	ra,120(sp)
    80000240:	7446                	ld	s0,112(sp)
    80000242:	74a6                	ld	s1,104(sp)
    80000244:	7906                	ld	s2,96(sp)
    80000246:	69e6                	ld	s3,88(sp)
    80000248:	6a46                	ld	s4,80(sp)
    8000024a:	6aa6                	ld	s5,72(sp)
    8000024c:	6b06                	ld	s6,64(sp)
    8000024e:	7be2                	ld	s7,56(sp)
    80000250:	7c42                	ld	s8,48(sp)
    80000252:	7ca2                	ld	s9,40(sp)
    80000254:	7d02                	ld	s10,32(sp)
    80000256:	6de2                	ld	s11,24(sp)
    80000258:	6109                	addi	sp,sp,128
    8000025a:	8082                	ret
      if(n < target){
    8000025c:	000a071b          	sext.w	a4,s4
    80000260:	fb777be3          	bgeu	a4,s7,80000216 <consoleread+0xc0>
        cons.r--;
    80000264:	00011717          	auipc	a4,0x11
    80000268:	faf72a23          	sw	a5,-76(a4) # 80011218 <cons+0x98>
    8000026c:	b76d                	j	80000216 <consoleread+0xc0>

000000008000026e <consputc>:
{
    8000026e:	1141                	addi	sp,sp,-16
    80000270:	e406                	sd	ra,8(sp)
    80000272:	e022                	sd	s0,0(sp)
    80000274:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    80000276:	10000793          	li	a5,256
    8000027a:	00f50a63          	beq	a0,a5,8000028e <consputc+0x20>
    uartputc_sync(c);
    8000027e:	00000097          	auipc	ra,0x0
    80000282:	564080e7          	jalr	1380(ra) # 800007e2 <uartputc_sync>
}
    80000286:	60a2                	ld	ra,8(sp)
    80000288:	6402                	ld	s0,0(sp)
    8000028a:	0141                	addi	sp,sp,16
    8000028c:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    8000028e:	4521                	li	a0,8
    80000290:	00000097          	auipc	ra,0x0
    80000294:	552080e7          	jalr	1362(ra) # 800007e2 <uartputc_sync>
    80000298:	02000513          	li	a0,32
    8000029c:	00000097          	auipc	ra,0x0
    800002a0:	546080e7          	jalr	1350(ra) # 800007e2 <uartputc_sync>
    800002a4:	4521                	li	a0,8
    800002a6:	00000097          	auipc	ra,0x0
    800002aa:	53c080e7          	jalr	1340(ra) # 800007e2 <uartputc_sync>
    800002ae:	bfe1                	j	80000286 <consputc+0x18>

00000000800002b0 <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    800002b0:	1101                	addi	sp,sp,-32
    800002b2:	ec06                	sd	ra,24(sp)
    800002b4:	e822                	sd	s0,16(sp)
    800002b6:	e426                	sd	s1,8(sp)
    800002b8:	e04a                	sd	s2,0(sp)
    800002ba:	1000                	addi	s0,sp,32
    800002bc:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    800002be:	00011517          	auipc	a0,0x11
    800002c2:	ec250513          	addi	a0,a0,-318 # 80011180 <cons>
    800002c6:	00001097          	auipc	ra,0x1
    800002ca:	910080e7          	jalr	-1776(ra) # 80000bd6 <acquire>

  switch(c){
    800002ce:	47d5                	li	a5,21
    800002d0:	0af48663          	beq	s1,a5,8000037c <consoleintr+0xcc>
    800002d4:	0297ca63          	blt	a5,s1,80000308 <consoleintr+0x58>
    800002d8:	47a1                	li	a5,8
    800002da:	0ef48763          	beq	s1,a5,800003c8 <consoleintr+0x118>
    800002de:	47c1                	li	a5,16
    800002e0:	10f49a63          	bne	s1,a5,800003f4 <consoleintr+0x144>
  case C('P'):  // Print process list.
    procdump();
    800002e4:	00002097          	auipc	ra,0x2
    800002e8:	218080e7          	jalr	536(ra) # 800024fc <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    800002ec:	00011517          	auipc	a0,0x11
    800002f0:	e9450513          	addi	a0,a0,-364 # 80011180 <cons>
    800002f4:	00001097          	auipc	ra,0x1
    800002f8:	996080e7          	jalr	-1642(ra) # 80000c8a <release>
}
    800002fc:	60e2                	ld	ra,24(sp)
    800002fe:	6442                	ld	s0,16(sp)
    80000300:	64a2                	ld	s1,8(sp)
    80000302:	6902                	ld	s2,0(sp)
    80000304:	6105                	addi	sp,sp,32
    80000306:	8082                	ret
  switch(c){
    80000308:	07f00793          	li	a5,127
    8000030c:	0af48e63          	beq	s1,a5,800003c8 <consoleintr+0x118>
    if(c != 0 && cons.e-cons.r < INPUT_BUF){
    80000310:	00011717          	auipc	a4,0x11
    80000314:	e7070713          	addi	a4,a4,-400 # 80011180 <cons>
    80000318:	0a072783          	lw	a5,160(a4)
    8000031c:	09872703          	lw	a4,152(a4)
    80000320:	9f99                	subw	a5,a5,a4
    80000322:	07f00713          	li	a4,127
    80000326:	fcf763e3          	bltu	a4,a5,800002ec <consoleintr+0x3c>
      c = (c == '\r') ? '\n' : c;
    8000032a:	47b5                	li	a5,13
    8000032c:	0cf48763          	beq	s1,a5,800003fa <consoleintr+0x14a>
      consputc(c);
    80000330:	8526                	mv	a0,s1
    80000332:	00000097          	auipc	ra,0x0
    80000336:	f3c080e7          	jalr	-196(ra) # 8000026e <consputc>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    8000033a:	00011797          	auipc	a5,0x11
    8000033e:	e4678793          	addi	a5,a5,-442 # 80011180 <cons>
    80000342:	0a07a703          	lw	a4,160(a5)
    80000346:	0017069b          	addiw	a3,a4,1
    8000034a:	0006861b          	sext.w	a2,a3
    8000034e:	0ad7a023          	sw	a3,160(a5)
    80000352:	07f77713          	andi	a4,a4,127
    80000356:	97ba                	add	a5,a5,a4
    80000358:	00978c23          	sb	s1,24(a5)
      if(c == '\n' || c == C('D') || cons.e == cons.r+INPUT_BUF){
    8000035c:	47a9                	li	a5,10
    8000035e:	0cf48563          	beq	s1,a5,80000428 <consoleintr+0x178>
    80000362:	4791                	li	a5,4
    80000364:	0cf48263          	beq	s1,a5,80000428 <consoleintr+0x178>
    80000368:	00011797          	auipc	a5,0x11
    8000036c:	eb07a783          	lw	a5,-336(a5) # 80011218 <cons+0x98>
    80000370:	0807879b          	addiw	a5,a5,128
    80000374:	f6f61ce3          	bne	a2,a5,800002ec <consoleintr+0x3c>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    80000378:	863e                	mv	a2,a5
    8000037a:	a07d                	j	80000428 <consoleintr+0x178>
    while(cons.e != cons.w &&
    8000037c:	00011717          	auipc	a4,0x11
    80000380:	e0470713          	addi	a4,a4,-508 # 80011180 <cons>
    80000384:	0a072783          	lw	a5,160(a4)
    80000388:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF] != '\n'){
    8000038c:	00011497          	auipc	s1,0x11
    80000390:	df448493          	addi	s1,s1,-524 # 80011180 <cons>
    while(cons.e != cons.w &&
    80000394:	4929                	li	s2,10
    80000396:	f4f70be3          	beq	a4,a5,800002ec <consoleintr+0x3c>
          cons.buf[(cons.e-1) % INPUT_BUF] != '\n'){
    8000039a:	37fd                	addiw	a5,a5,-1
    8000039c:	07f7f713          	andi	a4,a5,127
    800003a0:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    800003a2:	01874703          	lbu	a4,24(a4)
    800003a6:	f52703e3          	beq	a4,s2,800002ec <consoleintr+0x3c>
      cons.e--;
    800003aa:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    800003ae:	10000513          	li	a0,256
    800003b2:	00000097          	auipc	ra,0x0
    800003b6:	ebc080e7          	jalr	-324(ra) # 8000026e <consputc>
    while(cons.e != cons.w &&
    800003ba:	0a04a783          	lw	a5,160(s1)
    800003be:	09c4a703          	lw	a4,156(s1)
    800003c2:	fcf71ce3          	bne	a4,a5,8000039a <consoleintr+0xea>
    800003c6:	b71d                	j	800002ec <consoleintr+0x3c>
    if(cons.e != cons.w){
    800003c8:	00011717          	auipc	a4,0x11
    800003cc:	db870713          	addi	a4,a4,-584 # 80011180 <cons>
    800003d0:	0a072783          	lw	a5,160(a4)
    800003d4:	09c72703          	lw	a4,156(a4)
    800003d8:	f0f70ae3          	beq	a4,a5,800002ec <consoleintr+0x3c>
      cons.e--;
    800003dc:	37fd                	addiw	a5,a5,-1
    800003de:	00011717          	auipc	a4,0x11
    800003e2:	e4f72123          	sw	a5,-446(a4) # 80011220 <cons+0xa0>
      consputc(BACKSPACE);
    800003e6:	10000513          	li	a0,256
    800003ea:	00000097          	auipc	ra,0x0
    800003ee:	e84080e7          	jalr	-380(ra) # 8000026e <consputc>
    800003f2:	bded                	j	800002ec <consoleintr+0x3c>
    if(c != 0 && cons.e-cons.r < INPUT_BUF){
    800003f4:	ee048ce3          	beqz	s1,800002ec <consoleintr+0x3c>
    800003f8:	bf21                	j	80000310 <consoleintr+0x60>
      consputc(c);
    800003fa:	4529                	li	a0,10
    800003fc:	00000097          	auipc	ra,0x0
    80000400:	e72080e7          	jalr	-398(ra) # 8000026e <consputc>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    80000404:	00011797          	auipc	a5,0x11
    80000408:	d7c78793          	addi	a5,a5,-644 # 80011180 <cons>
    8000040c:	0a07a703          	lw	a4,160(a5)
    80000410:	0017069b          	addiw	a3,a4,1
    80000414:	0006861b          	sext.w	a2,a3
    80000418:	0ad7a023          	sw	a3,160(a5)
    8000041c:	07f77713          	andi	a4,a4,127
    80000420:	97ba                	add	a5,a5,a4
    80000422:	4729                	li	a4,10
    80000424:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    80000428:	00011797          	auipc	a5,0x11
    8000042c:	dec7aa23          	sw	a2,-524(a5) # 8001121c <cons+0x9c>
        wakeup(&cons.r);
    80000430:	00011517          	auipc	a0,0x11
    80000434:	de850513          	addi	a0,a0,-536 # 80011218 <cons+0x98>
    80000438:	00002097          	auipc	ra,0x2
    8000043c:	e00080e7          	jalr	-512(ra) # 80002238 <wakeup>
    80000440:	b575                	j	800002ec <consoleintr+0x3c>

0000000080000442 <consoleinit>:

void
consoleinit(void)
{
    80000442:	1141                	addi	sp,sp,-16
    80000444:	e406                	sd	ra,8(sp)
    80000446:	e022                	sd	s0,0(sp)
    80000448:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    8000044a:	00008597          	auipc	a1,0x8
    8000044e:	bc658593          	addi	a1,a1,-1082 # 80008010 <MAX_PROCS+0x8>
    80000452:	00011517          	auipc	a0,0x11
    80000456:	d2e50513          	addi	a0,a0,-722 # 80011180 <cons>
    8000045a:	00000097          	auipc	ra,0x0
    8000045e:	6ec080e7          	jalr	1772(ra) # 80000b46 <initlock>

  uartinit();
    80000462:	00000097          	auipc	ra,0x0
    80000466:	330080e7          	jalr	816(ra) # 80000792 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    8000046a:	00021797          	auipc	a5,0x21
    8000046e:	0ae78793          	addi	a5,a5,174 # 80021518 <devsw>
    80000472:	00000717          	auipc	a4,0x0
    80000476:	ce470713          	addi	a4,a4,-796 # 80000156 <consoleread>
    8000047a:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    8000047c:	00000717          	auipc	a4,0x0
    80000480:	c7870713          	addi	a4,a4,-904 # 800000f4 <consolewrite>
    80000484:	ef98                	sd	a4,24(a5)
}
    80000486:	60a2                	ld	ra,8(sp)
    80000488:	6402                	ld	s0,0(sp)
    8000048a:	0141                	addi	sp,sp,16
    8000048c:	8082                	ret

000000008000048e <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(int xx, int base, int sign)
{
    8000048e:	7179                	addi	sp,sp,-48
    80000490:	f406                	sd	ra,40(sp)
    80000492:	f022                	sd	s0,32(sp)
    80000494:	ec26                	sd	s1,24(sp)
    80000496:	e84a                	sd	s2,16(sp)
    80000498:	1800                	addi	s0,sp,48
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
    8000049a:	c219                	beqz	a2,800004a0 <printint+0x12>
    8000049c:	08054663          	bltz	a0,80000528 <printint+0x9a>
    x = -xx;
  else
    x = xx;
    800004a0:	2501                	sext.w	a0,a0
    800004a2:	4881                	li	a7,0
    800004a4:	fd040693          	addi	a3,s0,-48

  i = 0;
    800004a8:	4701                	li	a4,0
  do {
    buf[i++] = digits[x % base];
    800004aa:	2581                	sext.w	a1,a1
    800004ac:	00008617          	auipc	a2,0x8
    800004b0:	b9460613          	addi	a2,a2,-1132 # 80008040 <digits>
    800004b4:	883a                	mv	a6,a4
    800004b6:	2705                	addiw	a4,a4,1
    800004b8:	02b577bb          	remuw	a5,a0,a1
    800004bc:	1782                	slli	a5,a5,0x20
    800004be:	9381                	srli	a5,a5,0x20
    800004c0:	97b2                	add	a5,a5,a2
    800004c2:	0007c783          	lbu	a5,0(a5)
    800004c6:	00f68023          	sb	a5,0(a3)
  } while((x /= base) != 0);
    800004ca:	0005079b          	sext.w	a5,a0
    800004ce:	02b5553b          	divuw	a0,a0,a1
    800004d2:	0685                	addi	a3,a3,1
    800004d4:	feb7f0e3          	bgeu	a5,a1,800004b4 <printint+0x26>

  if(sign)
    800004d8:	00088b63          	beqz	a7,800004ee <printint+0x60>
    buf[i++] = '-';
    800004dc:	fe040793          	addi	a5,s0,-32
    800004e0:	973e                	add	a4,a4,a5
    800004e2:	02d00793          	li	a5,45
    800004e6:	fef70823          	sb	a5,-16(a4)
    800004ea:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
    800004ee:	02e05763          	blez	a4,8000051c <printint+0x8e>
    800004f2:	fd040793          	addi	a5,s0,-48
    800004f6:	00e784b3          	add	s1,a5,a4
    800004fa:	fff78913          	addi	s2,a5,-1
    800004fe:	993a                	add	s2,s2,a4
    80000500:	377d                	addiw	a4,a4,-1
    80000502:	1702                	slli	a4,a4,0x20
    80000504:	9301                	srli	a4,a4,0x20
    80000506:	40e90933          	sub	s2,s2,a4
    consputc(buf[i]);
    8000050a:	fff4c503          	lbu	a0,-1(s1)
    8000050e:	00000097          	auipc	ra,0x0
    80000512:	d60080e7          	jalr	-672(ra) # 8000026e <consputc>
  while(--i >= 0)
    80000516:	14fd                	addi	s1,s1,-1
    80000518:	ff2499e3          	bne	s1,s2,8000050a <printint+0x7c>
}
    8000051c:	70a2                	ld	ra,40(sp)
    8000051e:	7402                	ld	s0,32(sp)
    80000520:	64e2                	ld	s1,24(sp)
    80000522:	6942                	ld	s2,16(sp)
    80000524:	6145                	addi	sp,sp,48
    80000526:	8082                	ret
    x = -xx;
    80000528:	40a0053b          	negw	a0,a0
  if(sign && (sign = xx < 0))
    8000052c:	4885                	li	a7,1
    x = -xx;
    8000052e:	bf9d                	j	800004a4 <printint+0x16>

0000000080000530 <panic>:
    release(&pr.lock);
}

void
panic(char *s)
{
    80000530:	1101                	addi	sp,sp,-32
    80000532:	ec06                	sd	ra,24(sp)
    80000534:	e822                	sd	s0,16(sp)
    80000536:	e426                	sd	s1,8(sp)
    80000538:	1000                	addi	s0,sp,32
    8000053a:	84aa                	mv	s1,a0
  pr.locking = 0;
    8000053c:	00011797          	auipc	a5,0x11
    80000540:	d007a223          	sw	zero,-764(a5) # 80011240 <pr+0x18>
  printf("panic: ");
    80000544:	00008517          	auipc	a0,0x8
    80000548:	ad450513          	addi	a0,a0,-1324 # 80008018 <MAX_PROCS+0x10>
    8000054c:	00000097          	auipc	ra,0x0
    80000550:	02e080e7          	jalr	46(ra) # 8000057a <printf>
  printf(s);
    80000554:	8526                	mv	a0,s1
    80000556:	00000097          	auipc	ra,0x0
    8000055a:	024080e7          	jalr	36(ra) # 8000057a <printf>
  printf("\n");
    8000055e:	00008517          	auipc	a0,0x8
    80000562:	b6a50513          	addi	a0,a0,-1174 # 800080c8 <digits+0x88>
    80000566:	00000097          	auipc	ra,0x0
    8000056a:	014080e7          	jalr	20(ra) # 8000057a <printf>
  panicked = 1; // freeze uart output from other CPUs
    8000056e:	4785                	li	a5,1
    80000570:	00009717          	auipc	a4,0x9
    80000574:	a8f72823          	sw	a5,-1392(a4) # 80009000 <panicked>
  for(;;)
    80000578:	a001                	j	80000578 <panic+0x48>

000000008000057a <printf>:
{
    8000057a:	7131                	addi	sp,sp,-192
    8000057c:	fc86                	sd	ra,120(sp)
    8000057e:	f8a2                	sd	s0,112(sp)
    80000580:	f4a6                	sd	s1,104(sp)
    80000582:	f0ca                	sd	s2,96(sp)
    80000584:	ecce                	sd	s3,88(sp)
    80000586:	e8d2                	sd	s4,80(sp)
    80000588:	e4d6                	sd	s5,72(sp)
    8000058a:	e0da                	sd	s6,64(sp)
    8000058c:	fc5e                	sd	s7,56(sp)
    8000058e:	f862                	sd	s8,48(sp)
    80000590:	f466                	sd	s9,40(sp)
    80000592:	f06a                	sd	s10,32(sp)
    80000594:	ec6e                	sd	s11,24(sp)
    80000596:	0100                	addi	s0,sp,128
    80000598:	8a2a                	mv	s4,a0
    8000059a:	e40c                	sd	a1,8(s0)
    8000059c:	e810                	sd	a2,16(s0)
    8000059e:	ec14                	sd	a3,24(s0)
    800005a0:	f018                	sd	a4,32(s0)
    800005a2:	f41c                	sd	a5,40(s0)
    800005a4:	03043823          	sd	a6,48(s0)
    800005a8:	03143c23          	sd	a7,56(s0)
  locking = pr.locking;
    800005ac:	00011d97          	auipc	s11,0x11
    800005b0:	c94dad83          	lw	s11,-876(s11) # 80011240 <pr+0x18>
  if(locking)
    800005b4:	020d9b63          	bnez	s11,800005ea <printf+0x70>
  if (fmt == 0)
    800005b8:	040a0263          	beqz	s4,800005fc <printf+0x82>
  va_start(ap, fmt);
    800005bc:	00840793          	addi	a5,s0,8
    800005c0:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    800005c4:	000a4503          	lbu	a0,0(s4)
    800005c8:	16050263          	beqz	a0,8000072c <printf+0x1b2>
    800005cc:	4481                	li	s1,0
    if(c != '%'){
    800005ce:	02500a93          	li	s5,37
    switch(c){
    800005d2:	07000b13          	li	s6,112
  consputc('x');
    800005d6:	4d41                	li	s10,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800005d8:	00008b97          	auipc	s7,0x8
    800005dc:	a68b8b93          	addi	s7,s7,-1432 # 80008040 <digits>
    switch(c){
    800005e0:	07300c93          	li	s9,115
    800005e4:	06400c13          	li	s8,100
    800005e8:	a82d                	j	80000622 <printf+0xa8>
    acquire(&pr.lock);
    800005ea:	00011517          	auipc	a0,0x11
    800005ee:	c3e50513          	addi	a0,a0,-962 # 80011228 <pr>
    800005f2:	00000097          	auipc	ra,0x0
    800005f6:	5e4080e7          	jalr	1508(ra) # 80000bd6 <acquire>
    800005fa:	bf7d                	j	800005b8 <printf+0x3e>
    panic("null fmt");
    800005fc:	00008517          	auipc	a0,0x8
    80000600:	a2c50513          	addi	a0,a0,-1492 # 80008028 <MAX_PROCS+0x20>
    80000604:	00000097          	auipc	ra,0x0
    80000608:	f2c080e7          	jalr	-212(ra) # 80000530 <panic>
      consputc(c);
    8000060c:	00000097          	auipc	ra,0x0
    80000610:	c62080e7          	jalr	-926(ra) # 8000026e <consputc>
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    80000614:	2485                	addiw	s1,s1,1
    80000616:	009a07b3          	add	a5,s4,s1
    8000061a:	0007c503          	lbu	a0,0(a5)
    8000061e:	10050763          	beqz	a0,8000072c <printf+0x1b2>
    if(c != '%'){
    80000622:	ff5515e3          	bne	a0,s5,8000060c <printf+0x92>
    c = fmt[++i] & 0xff;
    80000626:	2485                	addiw	s1,s1,1
    80000628:	009a07b3          	add	a5,s4,s1
    8000062c:	0007c783          	lbu	a5,0(a5)
    80000630:	0007891b          	sext.w	s2,a5
    if(c == 0)
    80000634:	cfe5                	beqz	a5,8000072c <printf+0x1b2>
    switch(c){
    80000636:	05678a63          	beq	a5,s6,8000068a <printf+0x110>
    8000063a:	02fb7663          	bgeu	s6,a5,80000666 <printf+0xec>
    8000063e:	09978963          	beq	a5,s9,800006d0 <printf+0x156>
    80000642:	07800713          	li	a4,120
    80000646:	0ce79863          	bne	a5,a4,80000716 <printf+0x19c>
      printint(va_arg(ap, int), 16, 1);
    8000064a:	f8843783          	ld	a5,-120(s0)
    8000064e:	00878713          	addi	a4,a5,8
    80000652:	f8e43423          	sd	a4,-120(s0)
    80000656:	4605                	li	a2,1
    80000658:	85ea                	mv	a1,s10
    8000065a:	4388                	lw	a0,0(a5)
    8000065c:	00000097          	auipc	ra,0x0
    80000660:	e32080e7          	jalr	-462(ra) # 8000048e <printint>
      break;
    80000664:	bf45                	j	80000614 <printf+0x9a>
    switch(c){
    80000666:	0b578263          	beq	a5,s5,8000070a <printf+0x190>
    8000066a:	0b879663          	bne	a5,s8,80000716 <printf+0x19c>
      printint(va_arg(ap, int), 10, 1);
    8000066e:	f8843783          	ld	a5,-120(s0)
    80000672:	00878713          	addi	a4,a5,8
    80000676:	f8e43423          	sd	a4,-120(s0)
    8000067a:	4605                	li	a2,1
    8000067c:	45a9                	li	a1,10
    8000067e:	4388                	lw	a0,0(a5)
    80000680:	00000097          	auipc	ra,0x0
    80000684:	e0e080e7          	jalr	-498(ra) # 8000048e <printint>
      break;
    80000688:	b771                	j	80000614 <printf+0x9a>
      printptr(va_arg(ap, uint64));
    8000068a:	f8843783          	ld	a5,-120(s0)
    8000068e:	00878713          	addi	a4,a5,8
    80000692:	f8e43423          	sd	a4,-120(s0)
    80000696:	0007b983          	ld	s3,0(a5)
  consputc('0');
    8000069a:	03000513          	li	a0,48
    8000069e:	00000097          	auipc	ra,0x0
    800006a2:	bd0080e7          	jalr	-1072(ra) # 8000026e <consputc>
  consputc('x');
    800006a6:	07800513          	li	a0,120
    800006aa:	00000097          	auipc	ra,0x0
    800006ae:	bc4080e7          	jalr	-1084(ra) # 8000026e <consputc>
    800006b2:	896a                	mv	s2,s10
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800006b4:	03c9d793          	srli	a5,s3,0x3c
    800006b8:	97de                	add	a5,a5,s7
    800006ba:	0007c503          	lbu	a0,0(a5)
    800006be:	00000097          	auipc	ra,0x0
    800006c2:	bb0080e7          	jalr	-1104(ra) # 8000026e <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    800006c6:	0992                	slli	s3,s3,0x4
    800006c8:	397d                	addiw	s2,s2,-1
    800006ca:	fe0915e3          	bnez	s2,800006b4 <printf+0x13a>
    800006ce:	b799                	j	80000614 <printf+0x9a>
      if((s = va_arg(ap, char*)) == 0)
    800006d0:	f8843783          	ld	a5,-120(s0)
    800006d4:	00878713          	addi	a4,a5,8
    800006d8:	f8e43423          	sd	a4,-120(s0)
    800006dc:	0007b903          	ld	s2,0(a5)
    800006e0:	00090e63          	beqz	s2,800006fc <printf+0x182>
      for(; *s; s++)
    800006e4:	00094503          	lbu	a0,0(s2)
    800006e8:	d515                	beqz	a0,80000614 <printf+0x9a>
        consputc(*s);
    800006ea:	00000097          	auipc	ra,0x0
    800006ee:	b84080e7          	jalr	-1148(ra) # 8000026e <consputc>
      for(; *s; s++)
    800006f2:	0905                	addi	s2,s2,1
    800006f4:	00094503          	lbu	a0,0(s2)
    800006f8:	f96d                	bnez	a0,800006ea <printf+0x170>
    800006fa:	bf29                	j	80000614 <printf+0x9a>
        s = "(null)";
    800006fc:	00008917          	auipc	s2,0x8
    80000700:	92490913          	addi	s2,s2,-1756 # 80008020 <MAX_PROCS+0x18>
      for(; *s; s++)
    80000704:	02800513          	li	a0,40
    80000708:	b7cd                	j	800006ea <printf+0x170>
      consputc('%');
    8000070a:	8556                	mv	a0,s5
    8000070c:	00000097          	auipc	ra,0x0
    80000710:	b62080e7          	jalr	-1182(ra) # 8000026e <consputc>
      break;
    80000714:	b701                	j	80000614 <printf+0x9a>
      consputc('%');
    80000716:	8556                	mv	a0,s5
    80000718:	00000097          	auipc	ra,0x0
    8000071c:	b56080e7          	jalr	-1194(ra) # 8000026e <consputc>
      consputc(c);
    80000720:	854a                	mv	a0,s2
    80000722:	00000097          	auipc	ra,0x0
    80000726:	b4c080e7          	jalr	-1204(ra) # 8000026e <consputc>
      break;
    8000072a:	b5ed                	j	80000614 <printf+0x9a>
  if(locking)
    8000072c:	020d9163          	bnez	s11,8000074e <printf+0x1d4>
}
    80000730:	70e6                	ld	ra,120(sp)
    80000732:	7446                	ld	s0,112(sp)
    80000734:	74a6                	ld	s1,104(sp)
    80000736:	7906                	ld	s2,96(sp)
    80000738:	69e6                	ld	s3,88(sp)
    8000073a:	6a46                	ld	s4,80(sp)
    8000073c:	6aa6                	ld	s5,72(sp)
    8000073e:	6b06                	ld	s6,64(sp)
    80000740:	7be2                	ld	s7,56(sp)
    80000742:	7c42                	ld	s8,48(sp)
    80000744:	7ca2                	ld	s9,40(sp)
    80000746:	7d02                	ld	s10,32(sp)
    80000748:	6de2                	ld	s11,24(sp)
    8000074a:	6129                	addi	sp,sp,192
    8000074c:	8082                	ret
    release(&pr.lock);
    8000074e:	00011517          	auipc	a0,0x11
    80000752:	ada50513          	addi	a0,a0,-1318 # 80011228 <pr>
    80000756:	00000097          	auipc	ra,0x0
    8000075a:	534080e7          	jalr	1332(ra) # 80000c8a <release>
}
    8000075e:	bfc9                	j	80000730 <printf+0x1b6>

0000000080000760 <printfinit>:
    ;
}

void
printfinit(void)
{
    80000760:	1101                	addi	sp,sp,-32
    80000762:	ec06                	sd	ra,24(sp)
    80000764:	e822                	sd	s0,16(sp)
    80000766:	e426                	sd	s1,8(sp)
    80000768:	1000                	addi	s0,sp,32
  initlock(&pr.lock, "pr");
    8000076a:	00011497          	auipc	s1,0x11
    8000076e:	abe48493          	addi	s1,s1,-1346 # 80011228 <pr>
    80000772:	00008597          	auipc	a1,0x8
    80000776:	8c658593          	addi	a1,a1,-1850 # 80008038 <MAX_PROCS+0x30>
    8000077a:	8526                	mv	a0,s1
    8000077c:	00000097          	auipc	ra,0x0
    80000780:	3ca080e7          	jalr	970(ra) # 80000b46 <initlock>
  pr.locking = 1;
    80000784:	4785                	li	a5,1
    80000786:	cc9c                	sw	a5,24(s1)
}
    80000788:	60e2                	ld	ra,24(sp)
    8000078a:	6442                	ld	s0,16(sp)
    8000078c:	64a2                	ld	s1,8(sp)
    8000078e:	6105                	addi	sp,sp,32
    80000790:	8082                	ret

0000000080000792 <uartinit>:

void uartstart();

void
uartinit(void)
{
    80000792:	1141                	addi	sp,sp,-16
    80000794:	e406                	sd	ra,8(sp)
    80000796:	e022                	sd	s0,0(sp)
    80000798:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    8000079a:	100007b7          	lui	a5,0x10000
    8000079e:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    800007a2:	f8000713          	li	a4,-128
    800007a6:	00e781a3          	sb	a4,3(a5)

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    800007aa:	470d                	li	a4,3
    800007ac:	00e78023          	sb	a4,0(a5)

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    800007b0:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    800007b4:	00e781a3          	sb	a4,3(a5)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    800007b8:	469d                	li	a3,7
    800007ba:	00d78123          	sb	a3,2(a5)

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    800007be:	00e780a3          	sb	a4,1(a5)

  initlock(&uart_tx_lock, "uart");
    800007c2:	00008597          	auipc	a1,0x8
    800007c6:	89658593          	addi	a1,a1,-1898 # 80008058 <digits+0x18>
    800007ca:	00011517          	auipc	a0,0x11
    800007ce:	a7e50513          	addi	a0,a0,-1410 # 80011248 <uart_tx_lock>
    800007d2:	00000097          	auipc	ra,0x0
    800007d6:	374080e7          	jalr	884(ra) # 80000b46 <initlock>
}
    800007da:	60a2                	ld	ra,8(sp)
    800007dc:	6402                	ld	s0,0(sp)
    800007de:	0141                	addi	sp,sp,16
    800007e0:	8082                	ret

00000000800007e2 <uartputc_sync>:
// use interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    800007e2:	1101                	addi	sp,sp,-32
    800007e4:	ec06                	sd	ra,24(sp)
    800007e6:	e822                	sd	s0,16(sp)
    800007e8:	e426                	sd	s1,8(sp)
    800007ea:	1000                	addi	s0,sp,32
    800007ec:	84aa                	mv	s1,a0
  push_off();
    800007ee:	00000097          	auipc	ra,0x0
    800007f2:	39c080e7          	jalr	924(ra) # 80000b8a <push_off>

  if(panicked){
    800007f6:	00009797          	auipc	a5,0x9
    800007fa:	80a7a783          	lw	a5,-2038(a5) # 80009000 <panicked>
    for(;;)
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    800007fe:	10000737          	lui	a4,0x10000
  if(panicked){
    80000802:	c391                	beqz	a5,80000806 <uartputc_sync+0x24>
    for(;;)
    80000804:	a001                	j	80000804 <uartputc_sync+0x22>
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    80000806:	00574783          	lbu	a5,5(a4) # 10000005 <_entry-0x6ffffffb>
    8000080a:	0ff7f793          	andi	a5,a5,255
    8000080e:	0207f793          	andi	a5,a5,32
    80000812:	dbf5                	beqz	a5,80000806 <uartputc_sync+0x24>
    ;
  WriteReg(THR, c);
    80000814:	0ff4f793          	andi	a5,s1,255
    80000818:	10000737          	lui	a4,0x10000
    8000081c:	00f70023          	sb	a5,0(a4) # 10000000 <_entry-0x70000000>

  pop_off();
    80000820:	00000097          	auipc	ra,0x0
    80000824:	40a080e7          	jalr	1034(ra) # 80000c2a <pop_off>
}
    80000828:	60e2                	ld	ra,24(sp)
    8000082a:	6442                	ld	s0,16(sp)
    8000082c:	64a2                	ld	s1,8(sp)
    8000082e:	6105                	addi	sp,sp,32
    80000830:	8082                	ret

0000000080000832 <uartstart>:
// called from both the top- and bottom-half.
void
uartstart()
{
  while(1){
    if(uart_tx_w == uart_tx_r){
    80000832:	00008717          	auipc	a4,0x8
    80000836:	7d673703          	ld	a4,2006(a4) # 80009008 <uart_tx_r>
    8000083a:	00008797          	auipc	a5,0x8
    8000083e:	7d67b783          	ld	a5,2006(a5) # 80009010 <uart_tx_w>
    80000842:	06e78c63          	beq	a5,a4,800008ba <uartstart+0x88>
{
    80000846:	7139                	addi	sp,sp,-64
    80000848:	fc06                	sd	ra,56(sp)
    8000084a:	f822                	sd	s0,48(sp)
    8000084c:	f426                	sd	s1,40(sp)
    8000084e:	f04a                	sd	s2,32(sp)
    80000850:	ec4e                	sd	s3,24(sp)
    80000852:	e852                	sd	s4,16(sp)
    80000854:	e456                	sd	s5,8(sp)
    80000856:	0080                	addi	s0,sp,64
      // transmit buffer is empty.
      return;
    }
    
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    80000858:	10000937          	lui	s2,0x10000
      // so we cannot give it another byte.
      // it will interrupt when it's ready for a new byte.
      return;
    }
    
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    8000085c:	00011a17          	auipc	s4,0x11
    80000860:	9eca0a13          	addi	s4,s4,-1556 # 80011248 <uart_tx_lock>
    uart_tx_r += 1;
    80000864:	00008497          	auipc	s1,0x8
    80000868:	7a448493          	addi	s1,s1,1956 # 80009008 <uart_tx_r>
    if(uart_tx_w == uart_tx_r){
    8000086c:	00008997          	auipc	s3,0x8
    80000870:	7a498993          	addi	s3,s3,1956 # 80009010 <uart_tx_w>
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    80000874:	00594783          	lbu	a5,5(s2) # 10000005 <_entry-0x6ffffffb>
    80000878:	0ff7f793          	andi	a5,a5,255
    8000087c:	0207f793          	andi	a5,a5,32
    80000880:	c785                	beqz	a5,800008a8 <uartstart+0x76>
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    80000882:	01f77793          	andi	a5,a4,31
    80000886:	97d2                	add	a5,a5,s4
    80000888:	0187ca83          	lbu	s5,24(a5)
    uart_tx_r += 1;
    8000088c:	0705                	addi	a4,a4,1
    8000088e:	e098                	sd	a4,0(s1)
    
    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    80000890:	8526                	mv	a0,s1
    80000892:	00002097          	auipc	ra,0x2
    80000896:	9a6080e7          	jalr	-1626(ra) # 80002238 <wakeup>
    
    WriteReg(THR, c);
    8000089a:	01590023          	sb	s5,0(s2)
    if(uart_tx_w == uart_tx_r){
    8000089e:	6098                	ld	a4,0(s1)
    800008a0:	0009b783          	ld	a5,0(s3)
    800008a4:	fce798e3          	bne	a5,a4,80000874 <uartstart+0x42>
  }
}
    800008a8:	70e2                	ld	ra,56(sp)
    800008aa:	7442                	ld	s0,48(sp)
    800008ac:	74a2                	ld	s1,40(sp)
    800008ae:	7902                	ld	s2,32(sp)
    800008b0:	69e2                	ld	s3,24(sp)
    800008b2:	6a42                	ld	s4,16(sp)
    800008b4:	6aa2                	ld	s5,8(sp)
    800008b6:	6121                	addi	sp,sp,64
    800008b8:	8082                	ret
    800008ba:	8082                	ret

00000000800008bc <uartputc>:
{
    800008bc:	7179                	addi	sp,sp,-48
    800008be:	f406                	sd	ra,40(sp)
    800008c0:	f022                	sd	s0,32(sp)
    800008c2:	ec26                	sd	s1,24(sp)
    800008c4:	e84a                	sd	s2,16(sp)
    800008c6:	e44e                	sd	s3,8(sp)
    800008c8:	e052                	sd	s4,0(sp)
    800008ca:	1800                	addi	s0,sp,48
    800008cc:	89aa                	mv	s3,a0
  acquire(&uart_tx_lock);
    800008ce:	00011517          	auipc	a0,0x11
    800008d2:	97a50513          	addi	a0,a0,-1670 # 80011248 <uart_tx_lock>
    800008d6:	00000097          	auipc	ra,0x0
    800008da:	300080e7          	jalr	768(ra) # 80000bd6 <acquire>
  if(panicked){
    800008de:	00008797          	auipc	a5,0x8
    800008e2:	7227a783          	lw	a5,1826(a5) # 80009000 <panicked>
    800008e6:	c391                	beqz	a5,800008ea <uartputc+0x2e>
    for(;;)
    800008e8:	a001                	j	800008e8 <uartputc+0x2c>
    if(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    800008ea:	00008797          	auipc	a5,0x8
    800008ee:	7267b783          	ld	a5,1830(a5) # 80009010 <uart_tx_w>
    800008f2:	00008717          	auipc	a4,0x8
    800008f6:	71673703          	ld	a4,1814(a4) # 80009008 <uart_tx_r>
    800008fa:	02070713          	addi	a4,a4,32
    800008fe:	02f71b63          	bne	a4,a5,80000934 <uartputc+0x78>
      sleep(&uart_tx_r, &uart_tx_lock);
    80000902:	00011a17          	auipc	s4,0x11
    80000906:	946a0a13          	addi	s4,s4,-1722 # 80011248 <uart_tx_lock>
    8000090a:	00008497          	auipc	s1,0x8
    8000090e:	6fe48493          	addi	s1,s1,1790 # 80009008 <uart_tx_r>
    if(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000912:	00008917          	auipc	s2,0x8
    80000916:	6fe90913          	addi	s2,s2,1790 # 80009010 <uart_tx_w>
      sleep(&uart_tx_r, &uart_tx_lock);
    8000091a:	85d2                	mv	a1,s4
    8000091c:	8526                	mv	a0,s1
    8000091e:	00001097          	auipc	ra,0x1
    80000922:	78e080e7          	jalr	1934(ra) # 800020ac <sleep>
    if(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000926:	00093783          	ld	a5,0(s2)
    8000092a:	6098                	ld	a4,0(s1)
    8000092c:	02070713          	addi	a4,a4,32
    80000930:	fef705e3          	beq	a4,a5,8000091a <uartputc+0x5e>
      uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    80000934:	00011497          	auipc	s1,0x11
    80000938:	91448493          	addi	s1,s1,-1772 # 80011248 <uart_tx_lock>
    8000093c:	01f7f713          	andi	a4,a5,31
    80000940:	9726                	add	a4,a4,s1
    80000942:	01370c23          	sb	s3,24(a4)
      uart_tx_w += 1;
    80000946:	0785                	addi	a5,a5,1
    80000948:	00008717          	auipc	a4,0x8
    8000094c:	6cf73423          	sd	a5,1736(a4) # 80009010 <uart_tx_w>
      uartstart();
    80000950:	00000097          	auipc	ra,0x0
    80000954:	ee2080e7          	jalr	-286(ra) # 80000832 <uartstart>
      release(&uart_tx_lock);
    80000958:	8526                	mv	a0,s1
    8000095a:	00000097          	auipc	ra,0x0
    8000095e:	330080e7          	jalr	816(ra) # 80000c8a <release>
}
    80000962:	70a2                	ld	ra,40(sp)
    80000964:	7402                	ld	s0,32(sp)
    80000966:	64e2                	ld	s1,24(sp)
    80000968:	6942                	ld	s2,16(sp)
    8000096a:	69a2                	ld	s3,8(sp)
    8000096c:	6a02                	ld	s4,0(sp)
    8000096e:	6145                	addi	sp,sp,48
    80000970:	8082                	ret

0000000080000972 <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    80000972:	1141                	addi	sp,sp,-16
    80000974:	e422                	sd	s0,8(sp)
    80000976:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    80000978:	100007b7          	lui	a5,0x10000
    8000097c:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    80000980:	8b85                	andi	a5,a5,1
    80000982:	cb91                	beqz	a5,80000996 <uartgetc+0x24>
    // input data is ready.
    return ReadReg(RHR);
    80000984:	100007b7          	lui	a5,0x10000
    80000988:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
    8000098c:	0ff57513          	andi	a0,a0,255
  } else {
    return -1;
  }
}
    80000990:	6422                	ld	s0,8(sp)
    80000992:	0141                	addi	sp,sp,16
    80000994:	8082                	ret
    return -1;
    80000996:	557d                	li	a0,-1
    80000998:	bfe5                	j	80000990 <uartgetc+0x1e>

000000008000099a <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from trap.c.
void
uartintr(void)
{
    8000099a:	1101                	addi	sp,sp,-32
    8000099c:	ec06                	sd	ra,24(sp)
    8000099e:	e822                	sd	s0,16(sp)
    800009a0:	e426                	sd	s1,8(sp)
    800009a2:	1000                	addi	s0,sp,32
  // read and process incoming characters.
  while(1){
    int c = uartgetc();
    if(c == -1)
    800009a4:	54fd                	li	s1,-1
    int c = uartgetc();
    800009a6:	00000097          	auipc	ra,0x0
    800009aa:	fcc080e7          	jalr	-52(ra) # 80000972 <uartgetc>
    if(c == -1)
    800009ae:	00950763          	beq	a0,s1,800009bc <uartintr+0x22>
      break;
    consoleintr(c);
    800009b2:	00000097          	auipc	ra,0x0
    800009b6:	8fe080e7          	jalr	-1794(ra) # 800002b0 <consoleintr>
  while(1){
    800009ba:	b7f5                	j	800009a6 <uartintr+0xc>
  }

  // send buffered characters.
  acquire(&uart_tx_lock);
    800009bc:	00011497          	auipc	s1,0x11
    800009c0:	88c48493          	addi	s1,s1,-1908 # 80011248 <uart_tx_lock>
    800009c4:	8526                	mv	a0,s1
    800009c6:	00000097          	auipc	ra,0x0
    800009ca:	210080e7          	jalr	528(ra) # 80000bd6 <acquire>
  uartstart();
    800009ce:	00000097          	auipc	ra,0x0
    800009d2:	e64080e7          	jalr	-412(ra) # 80000832 <uartstart>
  release(&uart_tx_lock);
    800009d6:	8526                	mv	a0,s1
    800009d8:	00000097          	auipc	ra,0x0
    800009dc:	2b2080e7          	jalr	690(ra) # 80000c8a <release>
}
    800009e0:	60e2                	ld	ra,24(sp)
    800009e2:	6442                	ld	s0,16(sp)
    800009e4:	64a2                	ld	s1,8(sp)
    800009e6:	6105                	addi	sp,sp,32
    800009e8:	8082                	ret

00000000800009ea <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    800009ea:	1101                	addi	sp,sp,-32
    800009ec:	ec06                	sd	ra,24(sp)
    800009ee:	e822                	sd	s0,16(sp)
    800009f0:	e426                	sd	s1,8(sp)
    800009f2:	e04a                	sd	s2,0(sp)
    800009f4:	1000                	addi	s0,sp,32
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    800009f6:	03451793          	slli	a5,a0,0x34
    800009fa:	ebb9                	bnez	a5,80000a50 <kfree+0x66>
    800009fc:	84aa                	mv	s1,a0
    800009fe:	00025797          	auipc	a5,0x25
    80000a02:	60278793          	addi	a5,a5,1538 # 80026000 <end>
    80000a06:	04f56563          	bltu	a0,a5,80000a50 <kfree+0x66>
    80000a0a:	47c5                	li	a5,17
    80000a0c:	07ee                	slli	a5,a5,0x1b
    80000a0e:	04f57163          	bgeu	a0,a5,80000a50 <kfree+0x66>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    80000a12:	6605                	lui	a2,0x1
    80000a14:	4585                	li	a1,1
    80000a16:	00000097          	auipc	ra,0x0
    80000a1a:	2bc080e7          	jalr	700(ra) # 80000cd2 <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    80000a1e:	00011917          	auipc	s2,0x11
    80000a22:	86290913          	addi	s2,s2,-1950 # 80011280 <kmem>
    80000a26:	854a                	mv	a0,s2
    80000a28:	00000097          	auipc	ra,0x0
    80000a2c:	1ae080e7          	jalr	430(ra) # 80000bd6 <acquire>
  r->next = kmem.freelist;
    80000a30:	01893783          	ld	a5,24(s2)
    80000a34:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000a36:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000a3a:	854a                	mv	a0,s2
    80000a3c:	00000097          	auipc	ra,0x0
    80000a40:	24e080e7          	jalr	590(ra) # 80000c8a <release>
}
    80000a44:	60e2                	ld	ra,24(sp)
    80000a46:	6442                	ld	s0,16(sp)
    80000a48:	64a2                	ld	s1,8(sp)
    80000a4a:	6902                	ld	s2,0(sp)
    80000a4c:	6105                	addi	sp,sp,32
    80000a4e:	8082                	ret
    panic("kfree");
    80000a50:	00007517          	auipc	a0,0x7
    80000a54:	61050513          	addi	a0,a0,1552 # 80008060 <digits+0x20>
    80000a58:	00000097          	auipc	ra,0x0
    80000a5c:	ad8080e7          	jalr	-1320(ra) # 80000530 <panic>

0000000080000a60 <freerange>:
{
    80000a60:	7179                	addi	sp,sp,-48
    80000a62:	f406                	sd	ra,40(sp)
    80000a64:	f022                	sd	s0,32(sp)
    80000a66:	ec26                	sd	s1,24(sp)
    80000a68:	e84a                	sd	s2,16(sp)
    80000a6a:	e44e                	sd	s3,8(sp)
    80000a6c:	e052                	sd	s4,0(sp)
    80000a6e:	1800                	addi	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000a70:	6785                	lui	a5,0x1
    80000a72:	fff78493          	addi	s1,a5,-1 # fff <_entry-0x7ffff001>
    80000a76:	94aa                	add	s1,s1,a0
    80000a78:	757d                	lui	a0,0xfffff
    80000a7a:	8ce9                	and	s1,s1,a0
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a7c:	94be                	add	s1,s1,a5
    80000a7e:	0095ee63          	bltu	a1,s1,80000a9a <freerange+0x3a>
    80000a82:	892e                	mv	s2,a1
    kfree(p);
    80000a84:	7a7d                	lui	s4,0xfffff
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a86:	6985                	lui	s3,0x1
    kfree(p);
    80000a88:	01448533          	add	a0,s1,s4
    80000a8c:	00000097          	auipc	ra,0x0
    80000a90:	f5e080e7          	jalr	-162(ra) # 800009ea <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a94:	94ce                	add	s1,s1,s3
    80000a96:	fe9979e3          	bgeu	s2,s1,80000a88 <freerange+0x28>
}
    80000a9a:	70a2                	ld	ra,40(sp)
    80000a9c:	7402                	ld	s0,32(sp)
    80000a9e:	64e2                	ld	s1,24(sp)
    80000aa0:	6942                	ld	s2,16(sp)
    80000aa2:	69a2                	ld	s3,8(sp)
    80000aa4:	6a02                	ld	s4,0(sp)
    80000aa6:	6145                	addi	sp,sp,48
    80000aa8:	8082                	ret

0000000080000aaa <kinit>:
{
    80000aaa:	1141                	addi	sp,sp,-16
    80000aac:	e406                	sd	ra,8(sp)
    80000aae:	e022                	sd	s0,0(sp)
    80000ab0:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000ab2:	00007597          	auipc	a1,0x7
    80000ab6:	5b658593          	addi	a1,a1,1462 # 80008068 <digits+0x28>
    80000aba:	00010517          	auipc	a0,0x10
    80000abe:	7c650513          	addi	a0,a0,1990 # 80011280 <kmem>
    80000ac2:	00000097          	auipc	ra,0x0
    80000ac6:	084080e7          	jalr	132(ra) # 80000b46 <initlock>
  freerange(end, (void*)PHYSTOP);
    80000aca:	45c5                	li	a1,17
    80000acc:	05ee                	slli	a1,a1,0x1b
    80000ace:	00025517          	auipc	a0,0x25
    80000ad2:	53250513          	addi	a0,a0,1330 # 80026000 <end>
    80000ad6:	00000097          	auipc	ra,0x0
    80000ada:	f8a080e7          	jalr	-118(ra) # 80000a60 <freerange>
}
    80000ade:	60a2                	ld	ra,8(sp)
    80000ae0:	6402                	ld	s0,0(sp)
    80000ae2:	0141                	addi	sp,sp,16
    80000ae4:	8082                	ret

0000000080000ae6 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000ae6:	1101                	addi	sp,sp,-32
    80000ae8:	ec06                	sd	ra,24(sp)
    80000aea:	e822                	sd	s0,16(sp)
    80000aec:	e426                	sd	s1,8(sp)
    80000aee:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000af0:	00010497          	auipc	s1,0x10
    80000af4:	79048493          	addi	s1,s1,1936 # 80011280 <kmem>
    80000af8:	8526                	mv	a0,s1
    80000afa:	00000097          	auipc	ra,0x0
    80000afe:	0dc080e7          	jalr	220(ra) # 80000bd6 <acquire>
  r = kmem.freelist;
    80000b02:	6c84                	ld	s1,24(s1)
  if(r)
    80000b04:	c885                	beqz	s1,80000b34 <kalloc+0x4e>
    kmem.freelist = r->next;
    80000b06:	609c                	ld	a5,0(s1)
    80000b08:	00010517          	auipc	a0,0x10
    80000b0c:	77850513          	addi	a0,a0,1912 # 80011280 <kmem>
    80000b10:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock);
    80000b12:	00000097          	auipc	ra,0x0
    80000b16:	178080e7          	jalr	376(ra) # 80000c8a <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000b1a:	6605                	lui	a2,0x1
    80000b1c:	4595                	li	a1,5
    80000b1e:	8526                	mv	a0,s1
    80000b20:	00000097          	auipc	ra,0x0
    80000b24:	1b2080e7          	jalr	434(ra) # 80000cd2 <memset>
  return (void*)r;
}
    80000b28:	8526                	mv	a0,s1
    80000b2a:	60e2                	ld	ra,24(sp)
    80000b2c:	6442                	ld	s0,16(sp)
    80000b2e:	64a2                	ld	s1,8(sp)
    80000b30:	6105                	addi	sp,sp,32
    80000b32:	8082                	ret
  release(&kmem.lock);
    80000b34:	00010517          	auipc	a0,0x10
    80000b38:	74c50513          	addi	a0,a0,1868 # 80011280 <kmem>
    80000b3c:	00000097          	auipc	ra,0x0
    80000b40:	14e080e7          	jalr	334(ra) # 80000c8a <release>
  if(r)
    80000b44:	b7d5                	j	80000b28 <kalloc+0x42>

0000000080000b46 <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000b46:	1141                	addi	sp,sp,-16
    80000b48:	e422                	sd	s0,8(sp)
    80000b4a:	0800                	addi	s0,sp,16
  lk->name = name;
    80000b4c:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000b4e:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000b52:	00053823          	sd	zero,16(a0)
}
    80000b56:	6422                	ld	s0,8(sp)
    80000b58:	0141                	addi	sp,sp,16
    80000b5a:	8082                	ret

0000000080000b5c <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000b5c:	411c                	lw	a5,0(a0)
    80000b5e:	e399                	bnez	a5,80000b64 <holding+0x8>
    80000b60:	4501                	li	a0,0
  return r;
}
    80000b62:	8082                	ret
{
    80000b64:	1101                	addi	sp,sp,-32
    80000b66:	ec06                	sd	ra,24(sp)
    80000b68:	e822                	sd	s0,16(sp)
    80000b6a:	e426                	sd	s1,8(sp)
    80000b6c:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000b6e:	6904                	ld	s1,16(a0)
    80000b70:	00001097          	auipc	ra,0x1
    80000b74:	e08080e7          	jalr	-504(ra) # 80001978 <mycpu>
    80000b78:	40a48533          	sub	a0,s1,a0
    80000b7c:	00153513          	seqz	a0,a0
}
    80000b80:	60e2                	ld	ra,24(sp)
    80000b82:	6442                	ld	s0,16(sp)
    80000b84:	64a2                	ld	s1,8(sp)
    80000b86:	6105                	addi	sp,sp,32
    80000b88:	8082                	ret

0000000080000b8a <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000b8a:	1101                	addi	sp,sp,-32
    80000b8c:	ec06                	sd	ra,24(sp)
    80000b8e:	e822                	sd	s0,16(sp)
    80000b90:	e426                	sd	s1,8(sp)
    80000b92:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000b94:	100024f3          	csrr	s1,sstatus
    80000b98:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000b9c:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000b9e:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    80000ba2:	00001097          	auipc	ra,0x1
    80000ba6:	dd6080e7          	jalr	-554(ra) # 80001978 <mycpu>
    80000baa:	5d3c                	lw	a5,120(a0)
    80000bac:	cf89                	beqz	a5,80000bc6 <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000bae:	00001097          	auipc	ra,0x1
    80000bb2:	dca080e7          	jalr	-566(ra) # 80001978 <mycpu>
    80000bb6:	5d3c                	lw	a5,120(a0)
    80000bb8:	2785                	addiw	a5,a5,1
    80000bba:	dd3c                	sw	a5,120(a0)
}
    80000bbc:	60e2                	ld	ra,24(sp)
    80000bbe:	6442                	ld	s0,16(sp)
    80000bc0:	64a2                	ld	s1,8(sp)
    80000bc2:	6105                	addi	sp,sp,32
    80000bc4:	8082                	ret
    mycpu()->intena = old;
    80000bc6:	00001097          	auipc	ra,0x1
    80000bca:	db2080e7          	jalr	-590(ra) # 80001978 <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000bce:	8085                	srli	s1,s1,0x1
    80000bd0:	8885                	andi	s1,s1,1
    80000bd2:	dd64                	sw	s1,124(a0)
    80000bd4:	bfe9                	j	80000bae <push_off+0x24>

0000000080000bd6 <acquire>:
{
    80000bd6:	1101                	addi	sp,sp,-32
    80000bd8:	ec06                	sd	ra,24(sp)
    80000bda:	e822                	sd	s0,16(sp)
    80000bdc:	e426                	sd	s1,8(sp)
    80000bde:	1000                	addi	s0,sp,32
    80000be0:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000be2:	00000097          	auipc	ra,0x0
    80000be6:	fa8080e7          	jalr	-88(ra) # 80000b8a <push_off>
  if(holding(lk))
    80000bea:	8526                	mv	a0,s1
    80000bec:	00000097          	auipc	ra,0x0
    80000bf0:	f70080e7          	jalr	-144(ra) # 80000b5c <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000bf4:	4705                	li	a4,1
  if(holding(lk))
    80000bf6:	e115                	bnez	a0,80000c1a <acquire+0x44>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000bf8:	87ba                	mv	a5,a4
    80000bfa:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000bfe:	2781                	sext.w	a5,a5
    80000c00:	ffe5                	bnez	a5,80000bf8 <acquire+0x22>
  __sync_synchronize();
    80000c02:	0ff0000f          	fence
  lk->cpu = mycpu();
    80000c06:	00001097          	auipc	ra,0x1
    80000c0a:	d72080e7          	jalr	-654(ra) # 80001978 <mycpu>
    80000c0e:	e888                	sd	a0,16(s1)
}
    80000c10:	60e2                	ld	ra,24(sp)
    80000c12:	6442                	ld	s0,16(sp)
    80000c14:	64a2                	ld	s1,8(sp)
    80000c16:	6105                	addi	sp,sp,32
    80000c18:	8082                	ret
    panic("acquire");
    80000c1a:	00007517          	auipc	a0,0x7
    80000c1e:	45650513          	addi	a0,a0,1110 # 80008070 <digits+0x30>
    80000c22:	00000097          	auipc	ra,0x0
    80000c26:	90e080e7          	jalr	-1778(ra) # 80000530 <panic>

0000000080000c2a <pop_off>:

void
pop_off(void)
{
    80000c2a:	1141                	addi	sp,sp,-16
    80000c2c:	e406                	sd	ra,8(sp)
    80000c2e:	e022                	sd	s0,0(sp)
    80000c30:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000c32:	00001097          	auipc	ra,0x1
    80000c36:	d46080e7          	jalr	-698(ra) # 80001978 <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c3a:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000c3e:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000c40:	e78d                	bnez	a5,80000c6a <pop_off+0x40>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000c42:	5d3c                	lw	a5,120(a0)
    80000c44:	02f05b63          	blez	a5,80000c7a <pop_off+0x50>
    panic("pop_off");
  c->noff -= 1;
    80000c48:	37fd                	addiw	a5,a5,-1
    80000c4a:	0007871b          	sext.w	a4,a5
    80000c4e:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000c50:	eb09                	bnez	a4,80000c62 <pop_off+0x38>
    80000c52:	5d7c                	lw	a5,124(a0)
    80000c54:	c799                	beqz	a5,80000c62 <pop_off+0x38>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c56:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000c5a:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000c5e:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000c62:	60a2                	ld	ra,8(sp)
    80000c64:	6402                	ld	s0,0(sp)
    80000c66:	0141                	addi	sp,sp,16
    80000c68:	8082                	ret
    panic("pop_off - interruptible");
    80000c6a:	00007517          	auipc	a0,0x7
    80000c6e:	40e50513          	addi	a0,a0,1038 # 80008078 <digits+0x38>
    80000c72:	00000097          	auipc	ra,0x0
    80000c76:	8be080e7          	jalr	-1858(ra) # 80000530 <panic>
    panic("pop_off");
    80000c7a:	00007517          	auipc	a0,0x7
    80000c7e:	41650513          	addi	a0,a0,1046 # 80008090 <digits+0x50>
    80000c82:	00000097          	auipc	ra,0x0
    80000c86:	8ae080e7          	jalr	-1874(ra) # 80000530 <panic>

0000000080000c8a <release>:
{
    80000c8a:	1101                	addi	sp,sp,-32
    80000c8c:	ec06                	sd	ra,24(sp)
    80000c8e:	e822                	sd	s0,16(sp)
    80000c90:	e426                	sd	s1,8(sp)
    80000c92:	1000                	addi	s0,sp,32
    80000c94:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000c96:	00000097          	auipc	ra,0x0
    80000c9a:	ec6080e7          	jalr	-314(ra) # 80000b5c <holding>
    80000c9e:	c115                	beqz	a0,80000cc2 <release+0x38>
  lk->cpu = 0;
    80000ca0:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000ca4:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    80000ca8:	0f50000f          	fence	iorw,ow
    80000cac:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    80000cb0:	00000097          	auipc	ra,0x0
    80000cb4:	f7a080e7          	jalr	-134(ra) # 80000c2a <pop_off>
}
    80000cb8:	60e2                	ld	ra,24(sp)
    80000cba:	6442                	ld	s0,16(sp)
    80000cbc:	64a2                	ld	s1,8(sp)
    80000cbe:	6105                	addi	sp,sp,32
    80000cc0:	8082                	ret
    panic("release");
    80000cc2:	00007517          	auipc	a0,0x7
    80000cc6:	3d650513          	addi	a0,a0,982 # 80008098 <digits+0x58>
    80000cca:	00000097          	auipc	ra,0x0
    80000cce:	866080e7          	jalr	-1946(ra) # 80000530 <panic>

0000000080000cd2 <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000cd2:	1141                	addi	sp,sp,-16
    80000cd4:	e422                	sd	s0,8(sp)
    80000cd6:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000cd8:	ce09                	beqz	a2,80000cf2 <memset+0x20>
    80000cda:	87aa                	mv	a5,a0
    80000cdc:	fff6071b          	addiw	a4,a2,-1
    80000ce0:	1702                	slli	a4,a4,0x20
    80000ce2:	9301                	srli	a4,a4,0x20
    80000ce4:	0705                	addi	a4,a4,1
    80000ce6:	972a                	add	a4,a4,a0
    cdst[i] = c;
    80000ce8:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000cec:	0785                	addi	a5,a5,1
    80000cee:	fee79de3          	bne	a5,a4,80000ce8 <memset+0x16>
  }
  return dst;
}
    80000cf2:	6422                	ld	s0,8(sp)
    80000cf4:	0141                	addi	sp,sp,16
    80000cf6:	8082                	ret

0000000080000cf8 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000cf8:	1141                	addi	sp,sp,-16
    80000cfa:	e422                	sd	s0,8(sp)
    80000cfc:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000cfe:	ca05                	beqz	a2,80000d2e <memcmp+0x36>
    80000d00:	fff6069b          	addiw	a3,a2,-1
    80000d04:	1682                	slli	a3,a3,0x20
    80000d06:	9281                	srli	a3,a3,0x20
    80000d08:	0685                	addi	a3,a3,1
    80000d0a:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000d0c:	00054783          	lbu	a5,0(a0)
    80000d10:	0005c703          	lbu	a4,0(a1)
    80000d14:	00e79863          	bne	a5,a4,80000d24 <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000d18:	0505                	addi	a0,a0,1
    80000d1a:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000d1c:	fed518e3          	bne	a0,a3,80000d0c <memcmp+0x14>
  }

  return 0;
    80000d20:	4501                	li	a0,0
    80000d22:	a019                	j	80000d28 <memcmp+0x30>
      return *s1 - *s2;
    80000d24:	40e7853b          	subw	a0,a5,a4
}
    80000d28:	6422                	ld	s0,8(sp)
    80000d2a:	0141                	addi	sp,sp,16
    80000d2c:	8082                	ret
  return 0;
    80000d2e:	4501                	li	a0,0
    80000d30:	bfe5                	j	80000d28 <memcmp+0x30>

0000000080000d32 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000d32:	1141                	addi	sp,sp,-16
    80000d34:	e422                	sd	s0,8(sp)
    80000d36:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000d38:	00a5f963          	bgeu	a1,a0,80000d4a <memmove+0x18>
    80000d3c:	02061713          	slli	a4,a2,0x20
    80000d40:	9301                	srli	a4,a4,0x20
    80000d42:	00e587b3          	add	a5,a1,a4
    80000d46:	02f56563          	bltu	a0,a5,80000d70 <memmove+0x3e>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000d4a:	fff6069b          	addiw	a3,a2,-1
    80000d4e:	ce11                	beqz	a2,80000d6a <memmove+0x38>
    80000d50:	1682                	slli	a3,a3,0x20
    80000d52:	9281                	srli	a3,a3,0x20
    80000d54:	0685                	addi	a3,a3,1
    80000d56:	96ae                	add	a3,a3,a1
    80000d58:	87aa                	mv	a5,a0
      *d++ = *s++;
    80000d5a:	0585                	addi	a1,a1,1
    80000d5c:	0785                	addi	a5,a5,1
    80000d5e:	fff5c703          	lbu	a4,-1(a1)
    80000d62:	fee78fa3          	sb	a4,-1(a5)
    while(n-- > 0)
    80000d66:	fed59ae3          	bne	a1,a3,80000d5a <memmove+0x28>

  return dst;
}
    80000d6a:	6422                	ld	s0,8(sp)
    80000d6c:	0141                	addi	sp,sp,16
    80000d6e:	8082                	ret
    d += n;
    80000d70:	972a                	add	a4,a4,a0
    while(n-- > 0)
    80000d72:	fff6069b          	addiw	a3,a2,-1
    80000d76:	da75                	beqz	a2,80000d6a <memmove+0x38>
    80000d78:	02069613          	slli	a2,a3,0x20
    80000d7c:	9201                	srli	a2,a2,0x20
    80000d7e:	fff64613          	not	a2,a2
    80000d82:	963e                	add	a2,a2,a5
      *--d = *--s;
    80000d84:	17fd                	addi	a5,a5,-1
    80000d86:	177d                	addi	a4,a4,-1
    80000d88:	0007c683          	lbu	a3,0(a5)
    80000d8c:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
    80000d90:	fec79ae3          	bne	a5,a2,80000d84 <memmove+0x52>
    80000d94:	bfd9                	j	80000d6a <memmove+0x38>

0000000080000d96 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000d96:	1141                	addi	sp,sp,-16
    80000d98:	e406                	sd	ra,8(sp)
    80000d9a:	e022                	sd	s0,0(sp)
    80000d9c:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000d9e:	00000097          	auipc	ra,0x0
    80000da2:	f94080e7          	jalr	-108(ra) # 80000d32 <memmove>
}
    80000da6:	60a2                	ld	ra,8(sp)
    80000da8:	6402                	ld	s0,0(sp)
    80000daa:	0141                	addi	sp,sp,16
    80000dac:	8082                	ret

0000000080000dae <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000dae:	1141                	addi	sp,sp,-16
    80000db0:	e422                	sd	s0,8(sp)
    80000db2:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000db4:	ce11                	beqz	a2,80000dd0 <strncmp+0x22>
    80000db6:	00054783          	lbu	a5,0(a0)
    80000dba:	cf89                	beqz	a5,80000dd4 <strncmp+0x26>
    80000dbc:	0005c703          	lbu	a4,0(a1)
    80000dc0:	00f71a63          	bne	a4,a5,80000dd4 <strncmp+0x26>
    n--, p++, q++;
    80000dc4:	367d                	addiw	a2,a2,-1
    80000dc6:	0505                	addi	a0,a0,1
    80000dc8:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000dca:	f675                	bnez	a2,80000db6 <strncmp+0x8>
  if(n == 0)
    return 0;
    80000dcc:	4501                	li	a0,0
    80000dce:	a809                	j	80000de0 <strncmp+0x32>
    80000dd0:	4501                	li	a0,0
    80000dd2:	a039                	j	80000de0 <strncmp+0x32>
  if(n == 0)
    80000dd4:	ca09                	beqz	a2,80000de6 <strncmp+0x38>
  return (uchar)*p - (uchar)*q;
    80000dd6:	00054503          	lbu	a0,0(a0)
    80000dda:	0005c783          	lbu	a5,0(a1)
    80000dde:	9d1d                	subw	a0,a0,a5
}
    80000de0:	6422                	ld	s0,8(sp)
    80000de2:	0141                	addi	sp,sp,16
    80000de4:	8082                	ret
    return 0;
    80000de6:	4501                	li	a0,0
    80000de8:	bfe5                	j	80000de0 <strncmp+0x32>

0000000080000dea <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000dea:	1141                	addi	sp,sp,-16
    80000dec:	e422                	sd	s0,8(sp)
    80000dee:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000df0:	872a                	mv	a4,a0
    80000df2:	8832                	mv	a6,a2
    80000df4:	367d                	addiw	a2,a2,-1
    80000df6:	01005963          	blez	a6,80000e08 <strncpy+0x1e>
    80000dfa:	0705                	addi	a4,a4,1
    80000dfc:	0005c783          	lbu	a5,0(a1)
    80000e00:	fef70fa3          	sb	a5,-1(a4)
    80000e04:	0585                	addi	a1,a1,1
    80000e06:	f7f5                	bnez	a5,80000df2 <strncpy+0x8>
    ;
  while(n-- > 0)
    80000e08:	00c05d63          	blez	a2,80000e22 <strncpy+0x38>
    80000e0c:	86ba                	mv	a3,a4
    *s++ = 0;
    80000e0e:	0685                	addi	a3,a3,1
    80000e10:	fe068fa3          	sb	zero,-1(a3)
  while(n-- > 0)
    80000e14:	fff6c793          	not	a5,a3
    80000e18:	9fb9                	addw	a5,a5,a4
    80000e1a:	010787bb          	addw	a5,a5,a6
    80000e1e:	fef048e3          	bgtz	a5,80000e0e <strncpy+0x24>
  return os;
}
    80000e22:	6422                	ld	s0,8(sp)
    80000e24:	0141                	addi	sp,sp,16
    80000e26:	8082                	ret

0000000080000e28 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000e28:	1141                	addi	sp,sp,-16
    80000e2a:	e422                	sd	s0,8(sp)
    80000e2c:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000e2e:	02c05363          	blez	a2,80000e54 <safestrcpy+0x2c>
    80000e32:	fff6069b          	addiw	a3,a2,-1
    80000e36:	1682                	slli	a3,a3,0x20
    80000e38:	9281                	srli	a3,a3,0x20
    80000e3a:	96ae                	add	a3,a3,a1
    80000e3c:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000e3e:	00d58963          	beq	a1,a3,80000e50 <safestrcpy+0x28>
    80000e42:	0585                	addi	a1,a1,1
    80000e44:	0785                	addi	a5,a5,1
    80000e46:	fff5c703          	lbu	a4,-1(a1)
    80000e4a:	fee78fa3          	sb	a4,-1(a5)
    80000e4e:	fb65                	bnez	a4,80000e3e <safestrcpy+0x16>
    ;
  *s = 0;
    80000e50:	00078023          	sb	zero,0(a5)
  return os;
}
    80000e54:	6422                	ld	s0,8(sp)
    80000e56:	0141                	addi	sp,sp,16
    80000e58:	8082                	ret

0000000080000e5a <strlen>:

int
strlen(const char *s)
{
    80000e5a:	1141                	addi	sp,sp,-16
    80000e5c:	e422                	sd	s0,8(sp)
    80000e5e:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000e60:	00054783          	lbu	a5,0(a0)
    80000e64:	cf91                	beqz	a5,80000e80 <strlen+0x26>
    80000e66:	0505                	addi	a0,a0,1
    80000e68:	87aa                	mv	a5,a0
    80000e6a:	4685                	li	a3,1
    80000e6c:	9e89                	subw	a3,a3,a0
    80000e6e:	00f6853b          	addw	a0,a3,a5
    80000e72:	0785                	addi	a5,a5,1
    80000e74:	fff7c703          	lbu	a4,-1(a5)
    80000e78:	fb7d                	bnez	a4,80000e6e <strlen+0x14>
    ;
  return n;
}
    80000e7a:	6422                	ld	s0,8(sp)
    80000e7c:	0141                	addi	sp,sp,16
    80000e7e:	8082                	ret
  for(n = 0; s[n]; n++)
    80000e80:	4501                	li	a0,0
    80000e82:	bfe5                	j	80000e7a <strlen+0x20>

0000000080000e84 <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000e84:	1141                	addi	sp,sp,-16
    80000e86:	e406                	sd	ra,8(sp)
    80000e88:	e022                	sd	s0,0(sp)
    80000e8a:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80000e8c:	00001097          	auipc	ra,0x1
    80000e90:	adc080e7          	jalr	-1316(ra) # 80001968 <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000e94:	00008717          	auipc	a4,0x8
    80000e98:	18470713          	addi	a4,a4,388 # 80009018 <started>
  if(cpuid() == 0){
    80000e9c:	c139                	beqz	a0,80000ee2 <main+0x5e>
    while(started == 0)
    80000e9e:	431c                	lw	a5,0(a4)
    80000ea0:	2781                	sext.w	a5,a5
    80000ea2:	dff5                	beqz	a5,80000e9e <main+0x1a>
      ;
    __sync_synchronize();
    80000ea4:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    80000ea8:	00001097          	auipc	ra,0x1
    80000eac:	ac0080e7          	jalr	-1344(ra) # 80001968 <cpuid>
    80000eb0:	85aa                	mv	a1,a0
    80000eb2:	00007517          	auipc	a0,0x7
    80000eb6:	20650513          	addi	a0,a0,518 # 800080b8 <digits+0x78>
    80000eba:	fffff097          	auipc	ra,0xfffff
    80000ebe:	6c0080e7          	jalr	1728(ra) # 8000057a <printf>
    kvminithart();    // turn on paging
    80000ec2:	00000097          	auipc	ra,0x0
    80000ec6:	0d8080e7          	jalr	216(ra) # 80000f9a <kvminithart>
    trapinithart();   // install kernel trap vector
    80000eca:	00002097          	auipc	ra,0x2
    80000ece:	84c080e7          	jalr	-1972(ra) # 80002716 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000ed2:	00005097          	auipc	ra,0x5
    80000ed6:	dfe080e7          	jalr	-514(ra) # 80005cd0 <plicinithart>
  }

  scheduler();        
    80000eda:	00001097          	auipc	ra,0x1
    80000ede:	fca080e7          	jalr	-54(ra) # 80001ea4 <scheduler>
    consoleinit();
    80000ee2:	fffff097          	auipc	ra,0xfffff
    80000ee6:	560080e7          	jalr	1376(ra) # 80000442 <consoleinit>
    printfinit();
    80000eea:	00000097          	auipc	ra,0x0
    80000eee:	876080e7          	jalr	-1930(ra) # 80000760 <printfinit>
    printf("\n");
    80000ef2:	00007517          	auipc	a0,0x7
    80000ef6:	1d650513          	addi	a0,a0,470 # 800080c8 <digits+0x88>
    80000efa:	fffff097          	auipc	ra,0xfffff
    80000efe:	680080e7          	jalr	1664(ra) # 8000057a <printf>
    printf("xv6 kernel is booting\n");
    80000f02:	00007517          	auipc	a0,0x7
    80000f06:	19e50513          	addi	a0,a0,414 # 800080a0 <digits+0x60>
    80000f0a:	fffff097          	auipc	ra,0xfffff
    80000f0e:	670080e7          	jalr	1648(ra) # 8000057a <printf>
    printf("\n");
    80000f12:	00007517          	auipc	a0,0x7
    80000f16:	1b650513          	addi	a0,a0,438 # 800080c8 <digits+0x88>
    80000f1a:	fffff097          	auipc	ra,0xfffff
    80000f1e:	660080e7          	jalr	1632(ra) # 8000057a <printf>
    kinit();         // physical page allocator
    80000f22:	00000097          	auipc	ra,0x0
    80000f26:	b88080e7          	jalr	-1144(ra) # 80000aaa <kinit>
    kvminit();       // create kernel page table
    80000f2a:	00000097          	auipc	ra,0x0
    80000f2e:	310080e7          	jalr	784(ra) # 8000123a <kvminit>
    kvminithart();   // turn on paging
    80000f32:	00000097          	auipc	ra,0x0
    80000f36:	068080e7          	jalr	104(ra) # 80000f9a <kvminithart>
    procinit();      // process table
    80000f3a:	00001097          	auipc	ra,0x1
    80000f3e:	97e080e7          	jalr	-1666(ra) # 800018b8 <procinit>
    trapinit();      // trap vectors
    80000f42:	00001097          	auipc	ra,0x1
    80000f46:	7ac080e7          	jalr	1964(ra) # 800026ee <trapinit>
    trapinithart();  // install kernel trap vector
    80000f4a:	00001097          	auipc	ra,0x1
    80000f4e:	7cc080e7          	jalr	1996(ra) # 80002716 <trapinithart>
    plicinit();      // set up interrupt controller
    80000f52:	00005097          	auipc	ra,0x5
    80000f56:	d68080e7          	jalr	-664(ra) # 80005cba <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000f5a:	00005097          	auipc	ra,0x5
    80000f5e:	d76080e7          	jalr	-650(ra) # 80005cd0 <plicinithart>
    binit();         // buffer cache
    80000f62:	00002097          	auipc	ra,0x2
    80000f66:	f50080e7          	jalr	-176(ra) # 80002eb2 <binit>
    iinit();         // inode cache
    80000f6a:	00002097          	auipc	ra,0x2
    80000f6e:	5e0080e7          	jalr	1504(ra) # 8000354a <iinit>
    fileinit();      // file table
    80000f72:	00003097          	auipc	ra,0x3
    80000f76:	58a080e7          	jalr	1418(ra) # 800044fc <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f7a:	00005097          	auipc	ra,0x5
    80000f7e:	e78080e7          	jalr	-392(ra) # 80005df2 <virtio_disk_init>
    userinit();      // first user process
    80000f82:	00001097          	auipc	ra,0x1
    80000f86:	cea080e7          	jalr	-790(ra) # 80001c6c <userinit>
    __sync_synchronize();
    80000f8a:	0ff0000f          	fence
    started = 1;
    80000f8e:	4785                	li	a5,1
    80000f90:	00008717          	auipc	a4,0x8
    80000f94:	08f72423          	sw	a5,136(a4) # 80009018 <started>
    80000f98:	b789                	j	80000eda <main+0x56>

0000000080000f9a <kvminithart>:

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
    80000f9a:	1141                	addi	sp,sp,-16
    80000f9c:	e422                	sd	s0,8(sp)
    80000f9e:	0800                	addi	s0,sp,16
  w_satp(MAKE_SATP(kernel_pagetable));
    80000fa0:	00008797          	auipc	a5,0x8
    80000fa4:	0807b783          	ld	a5,128(a5) # 80009020 <kernel_pagetable>
    80000fa8:	83b1                	srli	a5,a5,0xc
    80000faa:	577d                	li	a4,-1
    80000fac:	177e                	slli	a4,a4,0x3f
    80000fae:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80000fb0:	18079073          	csrw	satp,a5
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80000fb4:	12000073          	sfence.vma
  sfence_vma();
}
    80000fb8:	6422                	ld	s0,8(sp)
    80000fba:	0141                	addi	sp,sp,16
    80000fbc:	8082                	ret

0000000080000fbe <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80000fbe:	7139                	addi	sp,sp,-64
    80000fc0:	fc06                	sd	ra,56(sp)
    80000fc2:	f822                	sd	s0,48(sp)
    80000fc4:	f426                	sd	s1,40(sp)
    80000fc6:	f04a                	sd	s2,32(sp)
    80000fc8:	ec4e                	sd	s3,24(sp)
    80000fca:	e852                	sd	s4,16(sp)
    80000fcc:	e456                	sd	s5,8(sp)
    80000fce:	e05a                	sd	s6,0(sp)
    80000fd0:	0080                	addi	s0,sp,64
    80000fd2:	84aa                	mv	s1,a0
    80000fd4:	89ae                	mv	s3,a1
    80000fd6:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    80000fd8:	57fd                	li	a5,-1
    80000fda:	83e9                	srli	a5,a5,0x1a
    80000fdc:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    80000fde:	4b31                	li	s6,12
  if(va >= MAXVA)
    80000fe0:	04b7f263          	bgeu	a5,a1,80001024 <walk+0x66>
    panic("walk");
    80000fe4:	00007517          	auipc	a0,0x7
    80000fe8:	0ec50513          	addi	a0,a0,236 # 800080d0 <digits+0x90>
    80000fec:	fffff097          	auipc	ra,0xfffff
    80000ff0:	544080e7          	jalr	1348(ra) # 80000530 <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    80000ff4:	060a8663          	beqz	s5,80001060 <walk+0xa2>
    80000ff8:	00000097          	auipc	ra,0x0
    80000ffc:	aee080e7          	jalr	-1298(ra) # 80000ae6 <kalloc>
    80001000:	84aa                	mv	s1,a0
    80001002:	c529                	beqz	a0,8000104c <walk+0x8e>
        return 0;
      memset(pagetable, 0, PGSIZE);
    80001004:	6605                	lui	a2,0x1
    80001006:	4581                	li	a1,0
    80001008:	00000097          	auipc	ra,0x0
    8000100c:	cca080e7          	jalr	-822(ra) # 80000cd2 <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    80001010:	00c4d793          	srli	a5,s1,0xc
    80001014:	07aa                	slli	a5,a5,0xa
    80001016:	0017e793          	ori	a5,a5,1
    8000101a:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    8000101e:	3a5d                	addiw	s4,s4,-9
    80001020:	036a0063          	beq	s4,s6,80001040 <walk+0x82>
    pte_t *pte = &pagetable[PX(level, va)];
    80001024:	0149d933          	srl	s2,s3,s4
    80001028:	1ff97913          	andi	s2,s2,511
    8000102c:	090e                	slli	s2,s2,0x3
    8000102e:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    80001030:	00093483          	ld	s1,0(s2)
    80001034:	0014f793          	andi	a5,s1,1
    80001038:	dfd5                	beqz	a5,80000ff4 <walk+0x36>
      pagetable = (pagetable_t)PTE2PA(*pte);
    8000103a:	80a9                	srli	s1,s1,0xa
    8000103c:	04b2                	slli	s1,s1,0xc
    8000103e:	b7c5                	j	8000101e <walk+0x60>
    }
  }
  return &pagetable[PX(0, va)];
    80001040:	00c9d513          	srli	a0,s3,0xc
    80001044:	1ff57513          	andi	a0,a0,511
    80001048:	050e                	slli	a0,a0,0x3
    8000104a:	9526                	add	a0,a0,s1
}
    8000104c:	70e2                	ld	ra,56(sp)
    8000104e:	7442                	ld	s0,48(sp)
    80001050:	74a2                	ld	s1,40(sp)
    80001052:	7902                	ld	s2,32(sp)
    80001054:	69e2                	ld	s3,24(sp)
    80001056:	6a42                	ld	s4,16(sp)
    80001058:	6aa2                	ld	s5,8(sp)
    8000105a:	6b02                	ld	s6,0(sp)
    8000105c:	6121                	addi	sp,sp,64
    8000105e:	8082                	ret
        return 0;
    80001060:	4501                	li	a0,0
    80001062:	b7ed                	j	8000104c <walk+0x8e>

0000000080001064 <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    80001064:	57fd                	li	a5,-1
    80001066:	83e9                	srli	a5,a5,0x1a
    80001068:	00b7f463          	bgeu	a5,a1,80001070 <walkaddr+0xc>
    return 0;
    8000106c:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    8000106e:	8082                	ret
{
    80001070:	1141                	addi	sp,sp,-16
    80001072:	e406                	sd	ra,8(sp)
    80001074:	e022                	sd	s0,0(sp)
    80001076:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    80001078:	4601                	li	a2,0
    8000107a:	00000097          	auipc	ra,0x0
    8000107e:	f44080e7          	jalr	-188(ra) # 80000fbe <walk>
  if(pte == 0)
    80001082:	c105                	beqz	a0,800010a2 <walkaddr+0x3e>
  if((*pte & PTE_V) == 0)
    80001084:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    80001086:	0117f693          	andi	a3,a5,17
    8000108a:	4745                	li	a4,17
    return 0;
    8000108c:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    8000108e:	00e68663          	beq	a3,a4,8000109a <walkaddr+0x36>
}
    80001092:	60a2                	ld	ra,8(sp)
    80001094:	6402                	ld	s0,0(sp)
    80001096:	0141                	addi	sp,sp,16
    80001098:	8082                	ret
  pa = PTE2PA(*pte);
    8000109a:	00a7d513          	srli	a0,a5,0xa
    8000109e:	0532                	slli	a0,a0,0xc
  return pa;
    800010a0:	bfcd                	j	80001092 <walkaddr+0x2e>
    return 0;
    800010a2:	4501                	li	a0,0
    800010a4:	b7fd                	j	80001092 <walkaddr+0x2e>

00000000800010a6 <mappages>:
// physical addresses starting at pa. va and size might not
// be page-aligned. Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    800010a6:	715d                	addi	sp,sp,-80
    800010a8:	e486                	sd	ra,72(sp)
    800010aa:	e0a2                	sd	s0,64(sp)
    800010ac:	fc26                	sd	s1,56(sp)
    800010ae:	f84a                	sd	s2,48(sp)
    800010b0:	f44e                	sd	s3,40(sp)
    800010b2:	f052                	sd	s4,32(sp)
    800010b4:	ec56                	sd	s5,24(sp)
    800010b6:	e85a                	sd	s6,16(sp)
    800010b8:	e45e                	sd	s7,8(sp)
    800010ba:	0880                	addi	s0,sp,80
    800010bc:	8aaa                	mv	s5,a0
    800010be:	8b3a                	mv	s6,a4
  uint64 a, last;
  pte_t *pte;

  a = PGROUNDDOWN(va);
    800010c0:	777d                	lui	a4,0xfffff
    800010c2:	00e5f7b3          	and	a5,a1,a4
  last = PGROUNDDOWN(va + size - 1);
    800010c6:	167d                	addi	a2,a2,-1
    800010c8:	00b609b3          	add	s3,a2,a1
    800010cc:	00e9f9b3          	and	s3,s3,a4
  a = PGROUNDDOWN(va);
    800010d0:	893e                	mv	s2,a5
    800010d2:	40f68a33          	sub	s4,a3,a5
    if(*pte & PTE_V)
      panic("remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    800010d6:	6b85                	lui	s7,0x1
    800010d8:	012a04b3          	add	s1,s4,s2
    if((pte = walk(pagetable, a, 1)) == 0)
    800010dc:	4605                	li	a2,1
    800010de:	85ca                	mv	a1,s2
    800010e0:	8556                	mv	a0,s5
    800010e2:	00000097          	auipc	ra,0x0
    800010e6:	edc080e7          	jalr	-292(ra) # 80000fbe <walk>
    800010ea:	c51d                	beqz	a0,80001118 <mappages+0x72>
    if(*pte & PTE_V)
    800010ec:	611c                	ld	a5,0(a0)
    800010ee:	8b85                	andi	a5,a5,1
    800010f0:	ef81                	bnez	a5,80001108 <mappages+0x62>
    *pte = PA2PTE(pa) | perm | PTE_V;
    800010f2:	80b1                	srli	s1,s1,0xc
    800010f4:	04aa                	slli	s1,s1,0xa
    800010f6:	0164e4b3          	or	s1,s1,s6
    800010fa:	0014e493          	ori	s1,s1,1
    800010fe:	e104                	sd	s1,0(a0)
    if(a == last)
    80001100:	03390863          	beq	s2,s3,80001130 <mappages+0x8a>
    a += PGSIZE;
    80001104:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    80001106:	bfc9                	j	800010d8 <mappages+0x32>
      panic("remap");
    80001108:	00007517          	auipc	a0,0x7
    8000110c:	fd050513          	addi	a0,a0,-48 # 800080d8 <digits+0x98>
    80001110:	fffff097          	auipc	ra,0xfffff
    80001114:	420080e7          	jalr	1056(ra) # 80000530 <panic>
      return -1;
    80001118:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    8000111a:	60a6                	ld	ra,72(sp)
    8000111c:	6406                	ld	s0,64(sp)
    8000111e:	74e2                	ld	s1,56(sp)
    80001120:	7942                	ld	s2,48(sp)
    80001122:	79a2                	ld	s3,40(sp)
    80001124:	7a02                	ld	s4,32(sp)
    80001126:	6ae2                	ld	s5,24(sp)
    80001128:	6b42                	ld	s6,16(sp)
    8000112a:	6ba2                	ld	s7,8(sp)
    8000112c:	6161                	addi	sp,sp,80
    8000112e:	8082                	ret
  return 0;
    80001130:	4501                	li	a0,0
    80001132:	b7e5                	j	8000111a <mappages+0x74>

0000000080001134 <kvmmap>:
{
    80001134:	1141                	addi	sp,sp,-16
    80001136:	e406                	sd	ra,8(sp)
    80001138:	e022                	sd	s0,0(sp)
    8000113a:	0800                	addi	s0,sp,16
    8000113c:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    8000113e:	86b2                	mv	a3,a2
    80001140:	863e                	mv	a2,a5
    80001142:	00000097          	auipc	ra,0x0
    80001146:	f64080e7          	jalr	-156(ra) # 800010a6 <mappages>
    8000114a:	e509                	bnez	a0,80001154 <kvmmap+0x20>
}
    8000114c:	60a2                	ld	ra,8(sp)
    8000114e:	6402                	ld	s0,0(sp)
    80001150:	0141                	addi	sp,sp,16
    80001152:	8082                	ret
    panic("kvmmap");
    80001154:	00007517          	auipc	a0,0x7
    80001158:	f8c50513          	addi	a0,a0,-116 # 800080e0 <digits+0xa0>
    8000115c:	fffff097          	auipc	ra,0xfffff
    80001160:	3d4080e7          	jalr	980(ra) # 80000530 <panic>

0000000080001164 <kvmmake>:
{
    80001164:	1101                	addi	sp,sp,-32
    80001166:	ec06                	sd	ra,24(sp)
    80001168:	e822                	sd	s0,16(sp)
    8000116a:	e426                	sd	s1,8(sp)
    8000116c:	e04a                	sd	s2,0(sp)
    8000116e:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    80001170:	00000097          	auipc	ra,0x0
    80001174:	976080e7          	jalr	-1674(ra) # 80000ae6 <kalloc>
    80001178:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    8000117a:	6605                	lui	a2,0x1
    8000117c:	4581                	li	a1,0
    8000117e:	00000097          	auipc	ra,0x0
    80001182:	b54080e7          	jalr	-1196(ra) # 80000cd2 <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    80001186:	4719                	li	a4,6
    80001188:	6685                	lui	a3,0x1
    8000118a:	10000637          	lui	a2,0x10000
    8000118e:	100005b7          	lui	a1,0x10000
    80001192:	8526                	mv	a0,s1
    80001194:	00000097          	auipc	ra,0x0
    80001198:	fa0080e7          	jalr	-96(ra) # 80001134 <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    8000119c:	4719                	li	a4,6
    8000119e:	6685                	lui	a3,0x1
    800011a0:	10001637          	lui	a2,0x10001
    800011a4:	100015b7          	lui	a1,0x10001
    800011a8:	8526                	mv	a0,s1
    800011aa:	00000097          	auipc	ra,0x0
    800011ae:	f8a080e7          	jalr	-118(ra) # 80001134 <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    800011b2:	4719                	li	a4,6
    800011b4:	004006b7          	lui	a3,0x400
    800011b8:	0c000637          	lui	a2,0xc000
    800011bc:	0c0005b7          	lui	a1,0xc000
    800011c0:	8526                	mv	a0,s1
    800011c2:	00000097          	auipc	ra,0x0
    800011c6:	f72080e7          	jalr	-142(ra) # 80001134 <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    800011ca:	00007917          	auipc	s2,0x7
    800011ce:	e3690913          	addi	s2,s2,-458 # 80008000 <etext>
    800011d2:	4729                	li	a4,10
    800011d4:	80007697          	auipc	a3,0x80007
    800011d8:	e2c68693          	addi	a3,a3,-468 # 8000 <_entry-0x7fff8000>
    800011dc:	4605                	li	a2,1
    800011de:	067e                	slli	a2,a2,0x1f
    800011e0:	85b2                	mv	a1,a2
    800011e2:	8526                	mv	a0,s1
    800011e4:	00000097          	auipc	ra,0x0
    800011e8:	f50080e7          	jalr	-176(ra) # 80001134 <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    800011ec:	4719                	li	a4,6
    800011ee:	46c5                	li	a3,17
    800011f0:	06ee                	slli	a3,a3,0x1b
    800011f2:	412686b3          	sub	a3,a3,s2
    800011f6:	864a                	mv	a2,s2
    800011f8:	85ca                	mv	a1,s2
    800011fa:	8526                	mv	a0,s1
    800011fc:	00000097          	auipc	ra,0x0
    80001200:	f38080e7          	jalr	-200(ra) # 80001134 <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    80001204:	4729                	li	a4,10
    80001206:	6685                	lui	a3,0x1
    80001208:	00006617          	auipc	a2,0x6
    8000120c:	df860613          	addi	a2,a2,-520 # 80007000 <_trampoline>
    80001210:	040005b7          	lui	a1,0x4000
    80001214:	15fd                	addi	a1,a1,-1
    80001216:	05b2                	slli	a1,a1,0xc
    80001218:	8526                	mv	a0,s1
    8000121a:	00000097          	auipc	ra,0x0
    8000121e:	f1a080e7          	jalr	-230(ra) # 80001134 <kvmmap>
  proc_mapstacks(kpgtbl);
    80001222:	8526                	mv	a0,s1
    80001224:	00000097          	auipc	ra,0x0
    80001228:	5fe080e7          	jalr	1534(ra) # 80001822 <proc_mapstacks>
}
    8000122c:	8526                	mv	a0,s1
    8000122e:	60e2                	ld	ra,24(sp)
    80001230:	6442                	ld	s0,16(sp)
    80001232:	64a2                	ld	s1,8(sp)
    80001234:	6902                	ld	s2,0(sp)
    80001236:	6105                	addi	sp,sp,32
    80001238:	8082                	ret

000000008000123a <kvminit>:
{
    8000123a:	1141                	addi	sp,sp,-16
    8000123c:	e406                	sd	ra,8(sp)
    8000123e:	e022                	sd	s0,0(sp)
    80001240:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    80001242:	00000097          	auipc	ra,0x0
    80001246:	f22080e7          	jalr	-222(ra) # 80001164 <kvmmake>
    8000124a:	00008797          	auipc	a5,0x8
    8000124e:	dca7bb23          	sd	a0,-554(a5) # 80009020 <kernel_pagetable>
}
    80001252:	60a2                	ld	ra,8(sp)
    80001254:	6402                	ld	s0,0(sp)
    80001256:	0141                	addi	sp,sp,16
    80001258:	8082                	ret

000000008000125a <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    8000125a:	715d                	addi	sp,sp,-80
    8000125c:	e486                	sd	ra,72(sp)
    8000125e:	e0a2                	sd	s0,64(sp)
    80001260:	fc26                	sd	s1,56(sp)
    80001262:	f84a                	sd	s2,48(sp)
    80001264:	f44e                	sd	s3,40(sp)
    80001266:	f052                	sd	s4,32(sp)
    80001268:	ec56                	sd	s5,24(sp)
    8000126a:	e85a                	sd	s6,16(sp)
    8000126c:	e45e                	sd	s7,8(sp)
    8000126e:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    80001270:	03459793          	slli	a5,a1,0x34
    80001274:	e795                	bnez	a5,800012a0 <uvmunmap+0x46>
    80001276:	8a2a                	mv	s4,a0
    80001278:	892e                	mv	s2,a1
    8000127a:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    8000127c:	0632                	slli	a2,a2,0xc
    8000127e:	00b609b3          	add	s3,a2,a1
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    80001282:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001284:	6b05                	lui	s6,0x1
    80001286:	0735e863          	bltu	a1,s3,800012f6 <uvmunmap+0x9c>
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
  }
}
    8000128a:	60a6                	ld	ra,72(sp)
    8000128c:	6406                	ld	s0,64(sp)
    8000128e:	74e2                	ld	s1,56(sp)
    80001290:	7942                	ld	s2,48(sp)
    80001292:	79a2                	ld	s3,40(sp)
    80001294:	7a02                	ld	s4,32(sp)
    80001296:	6ae2                	ld	s5,24(sp)
    80001298:	6b42                	ld	s6,16(sp)
    8000129a:	6ba2                	ld	s7,8(sp)
    8000129c:	6161                	addi	sp,sp,80
    8000129e:	8082                	ret
    panic("uvmunmap: not aligned");
    800012a0:	00007517          	auipc	a0,0x7
    800012a4:	e4850513          	addi	a0,a0,-440 # 800080e8 <digits+0xa8>
    800012a8:	fffff097          	auipc	ra,0xfffff
    800012ac:	288080e7          	jalr	648(ra) # 80000530 <panic>
      panic("uvmunmap: walk");
    800012b0:	00007517          	auipc	a0,0x7
    800012b4:	e5050513          	addi	a0,a0,-432 # 80008100 <digits+0xc0>
    800012b8:	fffff097          	auipc	ra,0xfffff
    800012bc:	278080e7          	jalr	632(ra) # 80000530 <panic>
      panic("uvmunmap: not mapped");
    800012c0:	00007517          	auipc	a0,0x7
    800012c4:	e5050513          	addi	a0,a0,-432 # 80008110 <digits+0xd0>
    800012c8:	fffff097          	auipc	ra,0xfffff
    800012cc:	268080e7          	jalr	616(ra) # 80000530 <panic>
      panic("uvmunmap: not a leaf");
    800012d0:	00007517          	auipc	a0,0x7
    800012d4:	e5850513          	addi	a0,a0,-424 # 80008128 <digits+0xe8>
    800012d8:	fffff097          	auipc	ra,0xfffff
    800012dc:	258080e7          	jalr	600(ra) # 80000530 <panic>
      uint64 pa = PTE2PA(*pte);
    800012e0:	8129                	srli	a0,a0,0xa
      kfree((void*)pa);
    800012e2:	0532                	slli	a0,a0,0xc
    800012e4:	fffff097          	auipc	ra,0xfffff
    800012e8:	706080e7          	jalr	1798(ra) # 800009ea <kfree>
    *pte = 0;
    800012ec:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800012f0:	995a                	add	s2,s2,s6
    800012f2:	f9397ce3          	bgeu	s2,s3,8000128a <uvmunmap+0x30>
    if((pte = walk(pagetable, a, 0)) == 0)
    800012f6:	4601                	li	a2,0
    800012f8:	85ca                	mv	a1,s2
    800012fa:	8552                	mv	a0,s4
    800012fc:	00000097          	auipc	ra,0x0
    80001300:	cc2080e7          	jalr	-830(ra) # 80000fbe <walk>
    80001304:	84aa                	mv	s1,a0
    80001306:	d54d                	beqz	a0,800012b0 <uvmunmap+0x56>
    if((*pte & PTE_V) == 0)
    80001308:	6108                	ld	a0,0(a0)
    8000130a:	00157793          	andi	a5,a0,1
    8000130e:	dbcd                	beqz	a5,800012c0 <uvmunmap+0x66>
    if(PTE_FLAGS(*pte) == PTE_V)
    80001310:	3ff57793          	andi	a5,a0,1023
    80001314:	fb778ee3          	beq	a5,s7,800012d0 <uvmunmap+0x76>
    if(do_free){
    80001318:	fc0a8ae3          	beqz	s5,800012ec <uvmunmap+0x92>
    8000131c:	b7d1                	j	800012e0 <uvmunmap+0x86>

000000008000131e <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    8000131e:	1101                	addi	sp,sp,-32
    80001320:	ec06                	sd	ra,24(sp)
    80001322:	e822                	sd	s0,16(sp)
    80001324:	e426                	sd	s1,8(sp)
    80001326:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    80001328:	fffff097          	auipc	ra,0xfffff
    8000132c:	7be080e7          	jalr	1982(ra) # 80000ae6 <kalloc>
    80001330:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001332:	c519                	beqz	a0,80001340 <uvmcreate+0x22>
    return 0;
  memset(pagetable, 0, PGSIZE);
    80001334:	6605                	lui	a2,0x1
    80001336:	4581                	li	a1,0
    80001338:	00000097          	auipc	ra,0x0
    8000133c:	99a080e7          	jalr	-1638(ra) # 80000cd2 <memset>
  return pagetable;
}
    80001340:	8526                	mv	a0,s1
    80001342:	60e2                	ld	ra,24(sp)
    80001344:	6442                	ld	s0,16(sp)
    80001346:	64a2                	ld	s1,8(sp)
    80001348:	6105                	addi	sp,sp,32
    8000134a:	8082                	ret

000000008000134c <uvminit>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvminit(pagetable_t pagetable, uchar *src, uint sz)
{
    8000134c:	7179                	addi	sp,sp,-48
    8000134e:	f406                	sd	ra,40(sp)
    80001350:	f022                	sd	s0,32(sp)
    80001352:	ec26                	sd	s1,24(sp)
    80001354:	e84a                	sd	s2,16(sp)
    80001356:	e44e                	sd	s3,8(sp)
    80001358:	e052                	sd	s4,0(sp)
    8000135a:	1800                	addi	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    8000135c:	6785                	lui	a5,0x1
    8000135e:	04f67863          	bgeu	a2,a5,800013ae <uvminit+0x62>
    80001362:	8a2a                	mv	s4,a0
    80001364:	89ae                	mv	s3,a1
    80001366:	84b2                	mv	s1,a2
    panic("inituvm: more than a page");
  mem = kalloc();
    80001368:	fffff097          	auipc	ra,0xfffff
    8000136c:	77e080e7          	jalr	1918(ra) # 80000ae6 <kalloc>
    80001370:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    80001372:	6605                	lui	a2,0x1
    80001374:	4581                	li	a1,0
    80001376:	00000097          	auipc	ra,0x0
    8000137a:	95c080e7          	jalr	-1700(ra) # 80000cd2 <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    8000137e:	4779                	li	a4,30
    80001380:	86ca                	mv	a3,s2
    80001382:	6605                	lui	a2,0x1
    80001384:	4581                	li	a1,0
    80001386:	8552                	mv	a0,s4
    80001388:	00000097          	auipc	ra,0x0
    8000138c:	d1e080e7          	jalr	-738(ra) # 800010a6 <mappages>
  memmove(mem, src, sz);
    80001390:	8626                	mv	a2,s1
    80001392:	85ce                	mv	a1,s3
    80001394:	854a                	mv	a0,s2
    80001396:	00000097          	auipc	ra,0x0
    8000139a:	99c080e7          	jalr	-1636(ra) # 80000d32 <memmove>
}
    8000139e:	70a2                	ld	ra,40(sp)
    800013a0:	7402                	ld	s0,32(sp)
    800013a2:	64e2                	ld	s1,24(sp)
    800013a4:	6942                	ld	s2,16(sp)
    800013a6:	69a2                	ld	s3,8(sp)
    800013a8:	6a02                	ld	s4,0(sp)
    800013aa:	6145                	addi	sp,sp,48
    800013ac:	8082                	ret
    panic("inituvm: more than a page");
    800013ae:	00007517          	auipc	a0,0x7
    800013b2:	d9250513          	addi	a0,a0,-622 # 80008140 <digits+0x100>
    800013b6:	fffff097          	auipc	ra,0xfffff
    800013ba:	17a080e7          	jalr	378(ra) # 80000530 <panic>

00000000800013be <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    800013be:	1101                	addi	sp,sp,-32
    800013c0:	ec06                	sd	ra,24(sp)
    800013c2:	e822                	sd	s0,16(sp)
    800013c4:	e426                	sd	s1,8(sp)
    800013c6:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    800013c8:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    800013ca:	00b67d63          	bgeu	a2,a1,800013e4 <uvmdealloc+0x26>
    800013ce:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    800013d0:	6785                	lui	a5,0x1
    800013d2:	17fd                	addi	a5,a5,-1
    800013d4:	00f60733          	add	a4,a2,a5
    800013d8:	767d                	lui	a2,0xfffff
    800013da:	8f71                	and	a4,a4,a2
    800013dc:	97ae                	add	a5,a5,a1
    800013de:	8ff1                	and	a5,a5,a2
    800013e0:	00f76863          	bltu	a4,a5,800013f0 <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    800013e4:	8526                	mv	a0,s1
    800013e6:	60e2                	ld	ra,24(sp)
    800013e8:	6442                	ld	s0,16(sp)
    800013ea:	64a2                	ld	s1,8(sp)
    800013ec:	6105                	addi	sp,sp,32
    800013ee:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    800013f0:	8f99                	sub	a5,a5,a4
    800013f2:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    800013f4:	4685                	li	a3,1
    800013f6:	0007861b          	sext.w	a2,a5
    800013fa:	85ba                	mv	a1,a4
    800013fc:	00000097          	auipc	ra,0x0
    80001400:	e5e080e7          	jalr	-418(ra) # 8000125a <uvmunmap>
    80001404:	b7c5                	j	800013e4 <uvmdealloc+0x26>

0000000080001406 <uvmalloc>:
  if(newsz < oldsz)
    80001406:	0ab66163          	bltu	a2,a1,800014a8 <uvmalloc+0xa2>
{
    8000140a:	7139                	addi	sp,sp,-64
    8000140c:	fc06                	sd	ra,56(sp)
    8000140e:	f822                	sd	s0,48(sp)
    80001410:	f426                	sd	s1,40(sp)
    80001412:	f04a                	sd	s2,32(sp)
    80001414:	ec4e                	sd	s3,24(sp)
    80001416:	e852                	sd	s4,16(sp)
    80001418:	e456                	sd	s5,8(sp)
    8000141a:	0080                	addi	s0,sp,64
    8000141c:	8aaa                	mv	s5,a0
    8000141e:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    80001420:	6985                	lui	s3,0x1
    80001422:	19fd                	addi	s3,s3,-1
    80001424:	95ce                	add	a1,a1,s3
    80001426:	79fd                	lui	s3,0xfffff
    80001428:	0135f9b3          	and	s3,a1,s3
  for(a = oldsz; a < newsz; a += PGSIZE){
    8000142c:	08c9f063          	bgeu	s3,a2,800014ac <uvmalloc+0xa6>
    80001430:	894e                	mv	s2,s3
    mem = kalloc();
    80001432:	fffff097          	auipc	ra,0xfffff
    80001436:	6b4080e7          	jalr	1716(ra) # 80000ae6 <kalloc>
    8000143a:	84aa                	mv	s1,a0
    if(mem == 0){
    8000143c:	c51d                	beqz	a0,8000146a <uvmalloc+0x64>
    memset(mem, 0, PGSIZE);
    8000143e:	6605                	lui	a2,0x1
    80001440:	4581                	li	a1,0
    80001442:	00000097          	auipc	ra,0x0
    80001446:	890080e7          	jalr	-1904(ra) # 80000cd2 <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_W|PTE_X|PTE_R|PTE_U) != 0){
    8000144a:	4779                	li	a4,30
    8000144c:	86a6                	mv	a3,s1
    8000144e:	6605                	lui	a2,0x1
    80001450:	85ca                	mv	a1,s2
    80001452:	8556                	mv	a0,s5
    80001454:	00000097          	auipc	ra,0x0
    80001458:	c52080e7          	jalr	-942(ra) # 800010a6 <mappages>
    8000145c:	e905                	bnez	a0,8000148c <uvmalloc+0x86>
  for(a = oldsz; a < newsz; a += PGSIZE){
    8000145e:	6785                	lui	a5,0x1
    80001460:	993e                	add	s2,s2,a5
    80001462:	fd4968e3          	bltu	s2,s4,80001432 <uvmalloc+0x2c>
  return newsz;
    80001466:	8552                	mv	a0,s4
    80001468:	a809                	j	8000147a <uvmalloc+0x74>
      uvmdealloc(pagetable, a, oldsz);
    8000146a:	864e                	mv	a2,s3
    8000146c:	85ca                	mv	a1,s2
    8000146e:	8556                	mv	a0,s5
    80001470:	00000097          	auipc	ra,0x0
    80001474:	f4e080e7          	jalr	-178(ra) # 800013be <uvmdealloc>
      return 0;
    80001478:	4501                	li	a0,0
}
    8000147a:	70e2                	ld	ra,56(sp)
    8000147c:	7442                	ld	s0,48(sp)
    8000147e:	74a2                	ld	s1,40(sp)
    80001480:	7902                	ld	s2,32(sp)
    80001482:	69e2                	ld	s3,24(sp)
    80001484:	6a42                	ld	s4,16(sp)
    80001486:	6aa2                	ld	s5,8(sp)
    80001488:	6121                	addi	sp,sp,64
    8000148a:	8082                	ret
      kfree(mem);
    8000148c:	8526                	mv	a0,s1
    8000148e:	fffff097          	auipc	ra,0xfffff
    80001492:	55c080e7          	jalr	1372(ra) # 800009ea <kfree>
      uvmdealloc(pagetable, a, oldsz);
    80001496:	864e                	mv	a2,s3
    80001498:	85ca                	mv	a1,s2
    8000149a:	8556                	mv	a0,s5
    8000149c:	00000097          	auipc	ra,0x0
    800014a0:	f22080e7          	jalr	-222(ra) # 800013be <uvmdealloc>
      return 0;
    800014a4:	4501                	li	a0,0
    800014a6:	bfd1                	j	8000147a <uvmalloc+0x74>
    return oldsz;
    800014a8:	852e                	mv	a0,a1
}
    800014aa:	8082                	ret
  return newsz;
    800014ac:	8532                	mv	a0,a2
    800014ae:	b7f1                	j	8000147a <uvmalloc+0x74>

00000000800014b0 <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    800014b0:	7179                	addi	sp,sp,-48
    800014b2:	f406                	sd	ra,40(sp)
    800014b4:	f022                	sd	s0,32(sp)
    800014b6:	ec26                	sd	s1,24(sp)
    800014b8:	e84a                	sd	s2,16(sp)
    800014ba:	e44e                	sd	s3,8(sp)
    800014bc:	e052                	sd	s4,0(sp)
    800014be:	1800                	addi	s0,sp,48
    800014c0:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    800014c2:	84aa                	mv	s1,a0
    800014c4:	6905                	lui	s2,0x1
    800014c6:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800014c8:	4985                	li	s3,1
    800014ca:	a821                	j	800014e2 <freewalk+0x32>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    800014cc:	8129                	srli	a0,a0,0xa
      freewalk((pagetable_t)child);
    800014ce:	0532                	slli	a0,a0,0xc
    800014d0:	00000097          	auipc	ra,0x0
    800014d4:	fe0080e7          	jalr	-32(ra) # 800014b0 <freewalk>
      pagetable[i] = 0;
    800014d8:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    800014dc:	04a1                	addi	s1,s1,8
    800014de:	03248163          	beq	s1,s2,80001500 <freewalk+0x50>
    pte_t pte = pagetable[i];
    800014e2:	6088                	ld	a0,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800014e4:	00f57793          	andi	a5,a0,15
    800014e8:	ff3782e3          	beq	a5,s3,800014cc <freewalk+0x1c>
    } else if(pte & PTE_V){
    800014ec:	8905                	andi	a0,a0,1
    800014ee:	d57d                	beqz	a0,800014dc <freewalk+0x2c>
      panic("freewalk: leaf");
    800014f0:	00007517          	auipc	a0,0x7
    800014f4:	c7050513          	addi	a0,a0,-912 # 80008160 <digits+0x120>
    800014f8:	fffff097          	auipc	ra,0xfffff
    800014fc:	038080e7          	jalr	56(ra) # 80000530 <panic>
    }
  }
  kfree((void*)pagetable);
    80001500:	8552                	mv	a0,s4
    80001502:	fffff097          	auipc	ra,0xfffff
    80001506:	4e8080e7          	jalr	1256(ra) # 800009ea <kfree>
}
    8000150a:	70a2                	ld	ra,40(sp)
    8000150c:	7402                	ld	s0,32(sp)
    8000150e:	64e2                	ld	s1,24(sp)
    80001510:	6942                	ld	s2,16(sp)
    80001512:	69a2                	ld	s3,8(sp)
    80001514:	6a02                	ld	s4,0(sp)
    80001516:	6145                	addi	sp,sp,48
    80001518:	8082                	ret

000000008000151a <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    8000151a:	1101                	addi	sp,sp,-32
    8000151c:	ec06                	sd	ra,24(sp)
    8000151e:	e822                	sd	s0,16(sp)
    80001520:	e426                	sd	s1,8(sp)
    80001522:	1000                	addi	s0,sp,32
    80001524:	84aa                	mv	s1,a0
  if(sz > 0)
    80001526:	e999                	bnez	a1,8000153c <uvmfree+0x22>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    80001528:	8526                	mv	a0,s1
    8000152a:	00000097          	auipc	ra,0x0
    8000152e:	f86080e7          	jalr	-122(ra) # 800014b0 <freewalk>
}
    80001532:	60e2                	ld	ra,24(sp)
    80001534:	6442                	ld	s0,16(sp)
    80001536:	64a2                	ld	s1,8(sp)
    80001538:	6105                	addi	sp,sp,32
    8000153a:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    8000153c:	6605                	lui	a2,0x1
    8000153e:	167d                	addi	a2,a2,-1
    80001540:	962e                	add	a2,a2,a1
    80001542:	4685                	li	a3,1
    80001544:	8231                	srli	a2,a2,0xc
    80001546:	4581                	li	a1,0
    80001548:	00000097          	auipc	ra,0x0
    8000154c:	d12080e7          	jalr	-750(ra) # 8000125a <uvmunmap>
    80001550:	bfe1                	j	80001528 <uvmfree+0xe>

0000000080001552 <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    80001552:	c679                	beqz	a2,80001620 <uvmcopy+0xce>
{
    80001554:	715d                	addi	sp,sp,-80
    80001556:	e486                	sd	ra,72(sp)
    80001558:	e0a2                	sd	s0,64(sp)
    8000155a:	fc26                	sd	s1,56(sp)
    8000155c:	f84a                	sd	s2,48(sp)
    8000155e:	f44e                	sd	s3,40(sp)
    80001560:	f052                	sd	s4,32(sp)
    80001562:	ec56                	sd	s5,24(sp)
    80001564:	e85a                	sd	s6,16(sp)
    80001566:	e45e                	sd	s7,8(sp)
    80001568:	0880                	addi	s0,sp,80
    8000156a:	8b2a                	mv	s6,a0
    8000156c:	8aae                	mv	s5,a1
    8000156e:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    80001570:	4981                	li	s3,0
    if((pte = walk(old, i, 0)) == 0)
    80001572:	4601                	li	a2,0
    80001574:	85ce                	mv	a1,s3
    80001576:	855a                	mv	a0,s6
    80001578:	00000097          	auipc	ra,0x0
    8000157c:	a46080e7          	jalr	-1466(ra) # 80000fbe <walk>
    80001580:	c531                	beqz	a0,800015cc <uvmcopy+0x7a>
      panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    80001582:	6118                	ld	a4,0(a0)
    80001584:	00177793          	andi	a5,a4,1
    80001588:	cbb1                	beqz	a5,800015dc <uvmcopy+0x8a>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    8000158a:	00a75593          	srli	a1,a4,0xa
    8000158e:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    80001592:	3ff77493          	andi	s1,a4,1023
    if((mem = kalloc()) == 0)
    80001596:	fffff097          	auipc	ra,0xfffff
    8000159a:	550080e7          	jalr	1360(ra) # 80000ae6 <kalloc>
    8000159e:	892a                	mv	s2,a0
    800015a0:	c939                	beqz	a0,800015f6 <uvmcopy+0xa4>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    800015a2:	6605                	lui	a2,0x1
    800015a4:	85de                	mv	a1,s7
    800015a6:	fffff097          	auipc	ra,0xfffff
    800015aa:	78c080e7          	jalr	1932(ra) # 80000d32 <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    800015ae:	8726                	mv	a4,s1
    800015b0:	86ca                	mv	a3,s2
    800015b2:	6605                	lui	a2,0x1
    800015b4:	85ce                	mv	a1,s3
    800015b6:	8556                	mv	a0,s5
    800015b8:	00000097          	auipc	ra,0x0
    800015bc:	aee080e7          	jalr	-1298(ra) # 800010a6 <mappages>
    800015c0:	e515                	bnez	a0,800015ec <uvmcopy+0x9a>
  for(i = 0; i < sz; i += PGSIZE){
    800015c2:	6785                	lui	a5,0x1
    800015c4:	99be                	add	s3,s3,a5
    800015c6:	fb49e6e3          	bltu	s3,s4,80001572 <uvmcopy+0x20>
    800015ca:	a081                	j	8000160a <uvmcopy+0xb8>
      panic("uvmcopy: pte should exist");
    800015cc:	00007517          	auipc	a0,0x7
    800015d0:	ba450513          	addi	a0,a0,-1116 # 80008170 <digits+0x130>
    800015d4:	fffff097          	auipc	ra,0xfffff
    800015d8:	f5c080e7          	jalr	-164(ra) # 80000530 <panic>
      panic("uvmcopy: page not present");
    800015dc:	00007517          	auipc	a0,0x7
    800015e0:	bb450513          	addi	a0,a0,-1100 # 80008190 <digits+0x150>
    800015e4:	fffff097          	auipc	ra,0xfffff
    800015e8:	f4c080e7          	jalr	-180(ra) # 80000530 <panic>
      kfree(mem);
    800015ec:	854a                	mv	a0,s2
    800015ee:	fffff097          	auipc	ra,0xfffff
    800015f2:	3fc080e7          	jalr	1020(ra) # 800009ea <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    800015f6:	4685                	li	a3,1
    800015f8:	00c9d613          	srli	a2,s3,0xc
    800015fc:	4581                	li	a1,0
    800015fe:	8556                	mv	a0,s5
    80001600:	00000097          	auipc	ra,0x0
    80001604:	c5a080e7          	jalr	-934(ra) # 8000125a <uvmunmap>
  return -1;
    80001608:	557d                	li	a0,-1
}
    8000160a:	60a6                	ld	ra,72(sp)
    8000160c:	6406                	ld	s0,64(sp)
    8000160e:	74e2                	ld	s1,56(sp)
    80001610:	7942                	ld	s2,48(sp)
    80001612:	79a2                	ld	s3,40(sp)
    80001614:	7a02                	ld	s4,32(sp)
    80001616:	6ae2                	ld	s5,24(sp)
    80001618:	6b42                	ld	s6,16(sp)
    8000161a:	6ba2                	ld	s7,8(sp)
    8000161c:	6161                	addi	sp,sp,80
    8000161e:	8082                	ret
  return 0;
    80001620:	4501                	li	a0,0
}
    80001622:	8082                	ret

0000000080001624 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    80001624:	1141                	addi	sp,sp,-16
    80001626:	e406                	sd	ra,8(sp)
    80001628:	e022                	sd	s0,0(sp)
    8000162a:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    8000162c:	4601                	li	a2,0
    8000162e:	00000097          	auipc	ra,0x0
    80001632:	990080e7          	jalr	-1648(ra) # 80000fbe <walk>
  if(pte == 0)
    80001636:	c901                	beqz	a0,80001646 <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    80001638:	611c                	ld	a5,0(a0)
    8000163a:	9bbd                	andi	a5,a5,-17
    8000163c:	e11c                	sd	a5,0(a0)
}
    8000163e:	60a2                	ld	ra,8(sp)
    80001640:	6402                	ld	s0,0(sp)
    80001642:	0141                	addi	sp,sp,16
    80001644:	8082                	ret
    panic("uvmclear");
    80001646:	00007517          	auipc	a0,0x7
    8000164a:	b6a50513          	addi	a0,a0,-1174 # 800081b0 <digits+0x170>
    8000164e:	fffff097          	auipc	ra,0xfffff
    80001652:	ee2080e7          	jalr	-286(ra) # 80000530 <panic>

0000000080001656 <copyout>:
int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80001656:	c6bd                	beqz	a3,800016c4 <copyout+0x6e>
{
    80001658:	715d                	addi	sp,sp,-80
    8000165a:	e486                	sd	ra,72(sp)
    8000165c:	e0a2                	sd	s0,64(sp)
    8000165e:	fc26                	sd	s1,56(sp)
    80001660:	f84a                	sd	s2,48(sp)
    80001662:	f44e                	sd	s3,40(sp)
    80001664:	f052                	sd	s4,32(sp)
    80001666:	ec56                	sd	s5,24(sp)
    80001668:	e85a                	sd	s6,16(sp)
    8000166a:	e45e                	sd	s7,8(sp)
    8000166c:	e062                	sd	s8,0(sp)
    8000166e:	0880                	addi	s0,sp,80
    80001670:	8b2a                	mv	s6,a0
    80001672:	8c2e                	mv	s8,a1
    80001674:	8a32                	mv	s4,a2
    80001676:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    80001678:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (dstva - va0);
    8000167a:	6a85                	lui	s5,0x1
    8000167c:	a015                	j	800016a0 <copyout+0x4a>
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    8000167e:	9562                	add	a0,a0,s8
    80001680:	0004861b          	sext.w	a2,s1
    80001684:	85d2                	mv	a1,s4
    80001686:	41250533          	sub	a0,a0,s2
    8000168a:	fffff097          	auipc	ra,0xfffff
    8000168e:	6a8080e7          	jalr	1704(ra) # 80000d32 <memmove>

    len -= n;
    80001692:	409989b3          	sub	s3,s3,s1
    src += n;
    80001696:	9a26                	add	s4,s4,s1
    dstva = va0 + PGSIZE;
    80001698:	01590c33          	add	s8,s2,s5
  while(len > 0){
    8000169c:	02098263          	beqz	s3,800016c0 <copyout+0x6a>
    va0 = PGROUNDDOWN(dstva);
    800016a0:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    800016a4:	85ca                	mv	a1,s2
    800016a6:	855a                	mv	a0,s6
    800016a8:	00000097          	auipc	ra,0x0
    800016ac:	9bc080e7          	jalr	-1604(ra) # 80001064 <walkaddr>
    if(pa0 == 0)
    800016b0:	cd01                	beqz	a0,800016c8 <copyout+0x72>
    n = PGSIZE - (dstva - va0);
    800016b2:	418904b3          	sub	s1,s2,s8
    800016b6:	94d6                	add	s1,s1,s5
    if(n > len)
    800016b8:	fc99f3e3          	bgeu	s3,s1,8000167e <copyout+0x28>
    800016bc:	84ce                	mv	s1,s3
    800016be:	b7c1                	j	8000167e <copyout+0x28>
  }
  return 0;
    800016c0:	4501                	li	a0,0
    800016c2:	a021                	j	800016ca <copyout+0x74>
    800016c4:	4501                	li	a0,0
}
    800016c6:	8082                	ret
      return -1;
    800016c8:	557d                	li	a0,-1
}
    800016ca:	60a6                	ld	ra,72(sp)
    800016cc:	6406                	ld	s0,64(sp)
    800016ce:	74e2                	ld	s1,56(sp)
    800016d0:	7942                	ld	s2,48(sp)
    800016d2:	79a2                	ld	s3,40(sp)
    800016d4:	7a02                	ld	s4,32(sp)
    800016d6:	6ae2                	ld	s5,24(sp)
    800016d8:	6b42                	ld	s6,16(sp)
    800016da:	6ba2                	ld	s7,8(sp)
    800016dc:	6c02                	ld	s8,0(sp)
    800016de:	6161                	addi	sp,sp,80
    800016e0:	8082                	ret

00000000800016e2 <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    800016e2:	c6bd                	beqz	a3,80001750 <copyin+0x6e>
{
    800016e4:	715d                	addi	sp,sp,-80
    800016e6:	e486                	sd	ra,72(sp)
    800016e8:	e0a2                	sd	s0,64(sp)
    800016ea:	fc26                	sd	s1,56(sp)
    800016ec:	f84a                	sd	s2,48(sp)
    800016ee:	f44e                	sd	s3,40(sp)
    800016f0:	f052                	sd	s4,32(sp)
    800016f2:	ec56                	sd	s5,24(sp)
    800016f4:	e85a                	sd	s6,16(sp)
    800016f6:	e45e                	sd	s7,8(sp)
    800016f8:	e062                	sd	s8,0(sp)
    800016fa:	0880                	addi	s0,sp,80
    800016fc:	8b2a                	mv	s6,a0
    800016fe:	8a2e                	mv	s4,a1
    80001700:	8c32                	mv	s8,a2
    80001702:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    80001704:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80001706:	6a85                	lui	s5,0x1
    80001708:	a015                	j	8000172c <copyin+0x4a>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    8000170a:	9562                	add	a0,a0,s8
    8000170c:	0004861b          	sext.w	a2,s1
    80001710:	412505b3          	sub	a1,a0,s2
    80001714:	8552                	mv	a0,s4
    80001716:	fffff097          	auipc	ra,0xfffff
    8000171a:	61c080e7          	jalr	1564(ra) # 80000d32 <memmove>

    len -= n;
    8000171e:	409989b3          	sub	s3,s3,s1
    dst += n;
    80001722:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    80001724:	01590c33          	add	s8,s2,s5
  while(len > 0){
    80001728:	02098263          	beqz	s3,8000174c <copyin+0x6a>
    va0 = PGROUNDDOWN(srcva);
    8000172c:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    80001730:	85ca                	mv	a1,s2
    80001732:	855a                	mv	a0,s6
    80001734:	00000097          	auipc	ra,0x0
    80001738:	930080e7          	jalr	-1744(ra) # 80001064 <walkaddr>
    if(pa0 == 0)
    8000173c:	cd01                	beqz	a0,80001754 <copyin+0x72>
    n = PGSIZE - (srcva - va0);
    8000173e:	418904b3          	sub	s1,s2,s8
    80001742:	94d6                	add	s1,s1,s5
    if(n > len)
    80001744:	fc99f3e3          	bgeu	s3,s1,8000170a <copyin+0x28>
    80001748:	84ce                	mv	s1,s3
    8000174a:	b7c1                	j	8000170a <copyin+0x28>
  }
  return 0;
    8000174c:	4501                	li	a0,0
    8000174e:	a021                	j	80001756 <copyin+0x74>
    80001750:	4501                	li	a0,0
}
    80001752:	8082                	ret
      return -1;
    80001754:	557d                	li	a0,-1
}
    80001756:	60a6                	ld	ra,72(sp)
    80001758:	6406                	ld	s0,64(sp)
    8000175a:	74e2                	ld	s1,56(sp)
    8000175c:	7942                	ld	s2,48(sp)
    8000175e:	79a2                	ld	s3,40(sp)
    80001760:	7a02                	ld	s4,32(sp)
    80001762:	6ae2                	ld	s5,24(sp)
    80001764:	6b42                	ld	s6,16(sp)
    80001766:	6ba2                	ld	s7,8(sp)
    80001768:	6c02                	ld	s8,0(sp)
    8000176a:	6161                	addi	sp,sp,80
    8000176c:	8082                	ret

000000008000176e <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    8000176e:	c6c5                	beqz	a3,80001816 <copyinstr+0xa8>
{
    80001770:	715d                	addi	sp,sp,-80
    80001772:	e486                	sd	ra,72(sp)
    80001774:	e0a2                	sd	s0,64(sp)
    80001776:	fc26                	sd	s1,56(sp)
    80001778:	f84a                	sd	s2,48(sp)
    8000177a:	f44e                	sd	s3,40(sp)
    8000177c:	f052                	sd	s4,32(sp)
    8000177e:	ec56                	sd	s5,24(sp)
    80001780:	e85a                	sd	s6,16(sp)
    80001782:	e45e                	sd	s7,8(sp)
    80001784:	0880                	addi	s0,sp,80
    80001786:	8a2a                	mv	s4,a0
    80001788:	8b2e                	mv	s6,a1
    8000178a:	8bb2                	mv	s7,a2
    8000178c:	84b6                	mv	s1,a3
    va0 = PGROUNDDOWN(srcva);
    8000178e:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80001790:	6985                	lui	s3,0x1
    80001792:	a035                	j	800017be <copyinstr+0x50>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    80001794:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    80001798:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    8000179a:	0017b793          	seqz	a5,a5
    8000179e:	40f00533          	neg	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    800017a2:	60a6                	ld	ra,72(sp)
    800017a4:	6406                	ld	s0,64(sp)
    800017a6:	74e2                	ld	s1,56(sp)
    800017a8:	7942                	ld	s2,48(sp)
    800017aa:	79a2                	ld	s3,40(sp)
    800017ac:	7a02                	ld	s4,32(sp)
    800017ae:	6ae2                	ld	s5,24(sp)
    800017b0:	6b42                	ld	s6,16(sp)
    800017b2:	6ba2                	ld	s7,8(sp)
    800017b4:	6161                	addi	sp,sp,80
    800017b6:	8082                	ret
    srcva = va0 + PGSIZE;
    800017b8:	01390bb3          	add	s7,s2,s3
  while(got_null == 0 && max > 0){
    800017bc:	c8a9                	beqz	s1,8000180e <copyinstr+0xa0>
    va0 = PGROUNDDOWN(srcva);
    800017be:	015bf933          	and	s2,s7,s5
    pa0 = walkaddr(pagetable, va0);
    800017c2:	85ca                	mv	a1,s2
    800017c4:	8552                	mv	a0,s4
    800017c6:	00000097          	auipc	ra,0x0
    800017ca:	89e080e7          	jalr	-1890(ra) # 80001064 <walkaddr>
    if(pa0 == 0)
    800017ce:	c131                	beqz	a0,80001812 <copyinstr+0xa4>
    n = PGSIZE - (srcva - va0);
    800017d0:	41790833          	sub	a6,s2,s7
    800017d4:	984e                	add	a6,a6,s3
    if(n > max)
    800017d6:	0104f363          	bgeu	s1,a6,800017dc <copyinstr+0x6e>
    800017da:	8826                	mv	a6,s1
    char *p = (char *) (pa0 + (srcva - va0));
    800017dc:	955e                	add	a0,a0,s7
    800017de:	41250533          	sub	a0,a0,s2
    while(n > 0){
    800017e2:	fc080be3          	beqz	a6,800017b8 <copyinstr+0x4a>
    800017e6:	985a                	add	a6,a6,s6
    800017e8:	87da                	mv	a5,s6
      if(*p == '\0'){
    800017ea:	41650633          	sub	a2,a0,s6
    800017ee:	14fd                	addi	s1,s1,-1
    800017f0:	9b26                	add	s6,s6,s1
    800017f2:	00f60733          	add	a4,a2,a5
    800017f6:	00074703          	lbu	a4,0(a4) # fffffffffffff000 <end+0xffffffff7ffd9000>
    800017fa:	df49                	beqz	a4,80001794 <copyinstr+0x26>
        *dst = *p;
    800017fc:	00e78023          	sb	a4,0(a5)
      --max;
    80001800:	40fb04b3          	sub	s1,s6,a5
      dst++;
    80001804:	0785                	addi	a5,a5,1
    while(n > 0){
    80001806:	ff0796e3          	bne	a5,a6,800017f2 <copyinstr+0x84>
      dst++;
    8000180a:	8b42                	mv	s6,a6
    8000180c:	b775                	j	800017b8 <copyinstr+0x4a>
    8000180e:	4781                	li	a5,0
    80001810:	b769                	j	8000179a <copyinstr+0x2c>
      return -1;
    80001812:	557d                	li	a0,-1
    80001814:	b779                	j	800017a2 <copyinstr+0x34>
  int got_null = 0;
    80001816:	4781                	li	a5,0
  if(got_null){
    80001818:	0017b793          	seqz	a5,a5
    8000181c:	40f00533          	neg	a0,a5
}
    80001820:	8082                	ret

0000000080001822 <proc_mapstacks>:

// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl) {
    80001822:	7139                	addi	sp,sp,-64
    80001824:	fc06                	sd	ra,56(sp)
    80001826:	f822                	sd	s0,48(sp)
    80001828:	f426                	sd	s1,40(sp)
    8000182a:	f04a                	sd	s2,32(sp)
    8000182c:	ec4e                	sd	s3,24(sp)
    8000182e:	e852                	sd	s4,16(sp)
    80001830:	e456                	sd	s5,8(sp)
    80001832:	e05a                	sd	s6,0(sp)
    80001834:	0080                	addi	s0,sp,64
    80001836:	89aa                	mv	s3,a0
  struct proc *p;
  
  for(p = proc; p < &proc[NPROC]; p++) {
    80001838:	00010497          	auipc	s1,0x10
    8000183c:	e9848493          	addi	s1,s1,-360 # 800116d0 <proc>
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    80001840:	8b26                	mv	s6,s1
    80001842:	00006a97          	auipc	s5,0x6
    80001846:	7bea8a93          	addi	s5,s5,1982 # 80008000 <etext>
    8000184a:	04000937          	lui	s2,0x4000
    8000184e:	197d                	addi	s2,s2,-1
    80001850:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001852:	00016a17          	auipc	s4,0x16
    80001856:	a7ea0a13          	addi	s4,s4,-1410 # 800172d0 <tickslock>
    char *pa = kalloc();
    8000185a:	fffff097          	auipc	ra,0xfffff
    8000185e:	28c080e7          	jalr	652(ra) # 80000ae6 <kalloc>
    80001862:	862a                	mv	a2,a0
    if(pa == 0)
    80001864:	c131                	beqz	a0,800018a8 <proc_mapstacks+0x86>
    uint64 va = KSTACK((int) (p - proc));
    80001866:	416485b3          	sub	a1,s1,s6
    8000186a:	8591                	srai	a1,a1,0x4
    8000186c:	000ab783          	ld	a5,0(s5)
    80001870:	02f585b3          	mul	a1,a1,a5
    80001874:	2585                	addiw	a1,a1,1
    80001876:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    8000187a:	4719                	li	a4,6
    8000187c:	6685                	lui	a3,0x1
    8000187e:	40b905b3          	sub	a1,s2,a1
    80001882:	854e                	mv	a0,s3
    80001884:	00000097          	auipc	ra,0x0
    80001888:	8b0080e7          	jalr	-1872(ra) # 80001134 <kvmmap>
  for(p = proc; p < &proc[NPROC]; p++) {
    8000188c:	17048493          	addi	s1,s1,368
    80001890:	fd4495e3          	bne	s1,s4,8000185a <proc_mapstacks+0x38>
  }
}
    80001894:	70e2                	ld	ra,56(sp)
    80001896:	7442                	ld	s0,48(sp)
    80001898:	74a2                	ld	s1,40(sp)
    8000189a:	7902                	ld	s2,32(sp)
    8000189c:	69e2                	ld	s3,24(sp)
    8000189e:	6a42                	ld	s4,16(sp)
    800018a0:	6aa2                	ld	s5,8(sp)
    800018a2:	6b02                	ld	s6,0(sp)
    800018a4:	6121                	addi	sp,sp,64
    800018a6:	8082                	ret
      panic("kalloc");
    800018a8:	00007517          	auipc	a0,0x7
    800018ac:	91850513          	addi	a0,a0,-1768 # 800081c0 <digits+0x180>
    800018b0:	fffff097          	auipc	ra,0xfffff
    800018b4:	c80080e7          	jalr	-896(ra) # 80000530 <panic>

00000000800018b8 <procinit>:

// initialize the proc table at boot time.
void
procinit(void)
{
    800018b8:	7139                	addi	sp,sp,-64
    800018ba:	fc06                	sd	ra,56(sp)
    800018bc:	f822                	sd	s0,48(sp)
    800018be:	f426                	sd	s1,40(sp)
    800018c0:	f04a                	sd	s2,32(sp)
    800018c2:	ec4e                	sd	s3,24(sp)
    800018c4:	e852                	sd	s4,16(sp)
    800018c6:	e456                	sd	s5,8(sp)
    800018c8:	e05a                	sd	s6,0(sp)
    800018ca:	0080                	addi	s0,sp,64
  struct proc *p;
  
  initlock(&pid_lock, "nextpid");
    800018cc:	00007597          	auipc	a1,0x7
    800018d0:	8fc58593          	addi	a1,a1,-1796 # 800081c8 <digits+0x188>
    800018d4:	00010517          	auipc	a0,0x10
    800018d8:	9cc50513          	addi	a0,a0,-1588 # 800112a0 <pid_lock>
    800018dc:	fffff097          	auipc	ra,0xfffff
    800018e0:	26a080e7          	jalr	618(ra) # 80000b46 <initlock>
  initlock(&wait_lock, "wait_lock");
    800018e4:	00007597          	auipc	a1,0x7
    800018e8:	8ec58593          	addi	a1,a1,-1812 # 800081d0 <digits+0x190>
    800018ec:	00010517          	auipc	a0,0x10
    800018f0:	9cc50513          	addi	a0,a0,-1588 # 800112b8 <wait_lock>
    800018f4:	fffff097          	auipc	ra,0xfffff
    800018f8:	252080e7          	jalr	594(ra) # 80000b46 <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    800018fc:	00010497          	auipc	s1,0x10
    80001900:	dd448493          	addi	s1,s1,-556 # 800116d0 <proc>
      initlock(&p->lock, "proc");
    80001904:	00007b17          	auipc	s6,0x7
    80001908:	8dcb0b13          	addi	s6,s6,-1828 # 800081e0 <digits+0x1a0>
      p->kstack = KSTACK((int) (p - proc));
    8000190c:	8aa6                	mv	s5,s1
    8000190e:	00006a17          	auipc	s4,0x6
    80001912:	6f2a0a13          	addi	s4,s4,1778 # 80008000 <etext>
    80001916:	04000937          	lui	s2,0x4000
    8000191a:	197d                	addi	s2,s2,-1
    8000191c:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    8000191e:	00016997          	auipc	s3,0x16
    80001922:	9b298993          	addi	s3,s3,-1614 # 800172d0 <tickslock>
      initlock(&p->lock, "proc");
    80001926:	85da                	mv	a1,s6
    80001928:	8526                	mv	a0,s1
    8000192a:	fffff097          	auipc	ra,0xfffff
    8000192e:	21c080e7          	jalr	540(ra) # 80000b46 <initlock>
      p->kstack = KSTACK((int) (p - proc));
    80001932:	415487b3          	sub	a5,s1,s5
    80001936:	8791                	srai	a5,a5,0x4
    80001938:	000a3703          	ld	a4,0(s4)
    8000193c:	02e787b3          	mul	a5,a5,a4
    80001940:	2785                	addiw	a5,a5,1
    80001942:	00d7979b          	slliw	a5,a5,0xd
    80001946:	40f907b3          	sub	a5,s2,a5
    8000194a:	e0bc                	sd	a5,64(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    8000194c:	17048493          	addi	s1,s1,368
    80001950:	fd349be3          	bne	s1,s3,80001926 <procinit+0x6e>
  }
}
    80001954:	70e2                	ld	ra,56(sp)
    80001956:	7442                	ld	s0,48(sp)
    80001958:	74a2                	ld	s1,40(sp)
    8000195a:	7902                	ld	s2,32(sp)
    8000195c:	69e2                	ld	s3,24(sp)
    8000195e:	6a42                	ld	s4,16(sp)
    80001960:	6aa2                	ld	s5,8(sp)
    80001962:	6b02                	ld	s6,0(sp)
    80001964:	6121                	addi	sp,sp,64
    80001966:	8082                	ret

0000000080001968 <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    80001968:	1141                	addi	sp,sp,-16
    8000196a:	e422                	sd	s0,8(sp)
    8000196c:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    8000196e:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    80001970:	2501                	sext.w	a0,a0
    80001972:	6422                	ld	s0,8(sp)
    80001974:	0141                	addi	sp,sp,16
    80001976:	8082                	ret

0000000080001978 <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void) {
    80001978:	1141                	addi	sp,sp,-16
    8000197a:	e422                	sd	s0,8(sp)
    8000197c:	0800                	addi	s0,sp,16
    8000197e:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    80001980:	2781                	sext.w	a5,a5
    80001982:	079e                	slli	a5,a5,0x7
  return c;
}
    80001984:	00010517          	auipc	a0,0x10
    80001988:	94c50513          	addi	a0,a0,-1716 # 800112d0 <cpus>
    8000198c:	953e                	add	a0,a0,a5
    8000198e:	6422                	ld	s0,8(sp)
    80001990:	0141                	addi	sp,sp,16
    80001992:	8082                	ret

0000000080001994 <myproc>:

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void) {
    80001994:	1101                	addi	sp,sp,-32
    80001996:	ec06                	sd	ra,24(sp)
    80001998:	e822                	sd	s0,16(sp)
    8000199a:	e426                	sd	s1,8(sp)
    8000199c:	1000                	addi	s0,sp,32
  push_off();
    8000199e:	fffff097          	auipc	ra,0xfffff
    800019a2:	1ec080e7          	jalr	492(ra) # 80000b8a <push_off>
    800019a6:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    800019a8:	2781                	sext.w	a5,a5
    800019aa:	079e                	slli	a5,a5,0x7
    800019ac:	00010717          	auipc	a4,0x10
    800019b0:	8f470713          	addi	a4,a4,-1804 # 800112a0 <pid_lock>
    800019b4:	97ba                	add	a5,a5,a4
    800019b6:	7b84                	ld	s1,48(a5)
  pop_off();
    800019b8:	fffff097          	auipc	ra,0xfffff
    800019bc:	272080e7          	jalr	626(ra) # 80000c2a <pop_off>
  return p;
}
    800019c0:	8526                	mv	a0,s1
    800019c2:	60e2                	ld	ra,24(sp)
    800019c4:	6442                	ld	s0,16(sp)
    800019c6:	64a2                	ld	s1,8(sp)
    800019c8:	6105                	addi	sp,sp,32
    800019ca:	8082                	ret

00000000800019cc <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    800019cc:	1141                	addi	sp,sp,-16
    800019ce:	e406                	sd	ra,8(sp)
    800019d0:	e022                	sd	s0,0(sp)
    800019d2:	0800                	addi	s0,sp,16
  static int first = 1;

  // Still holding p->lock from scheduler.
  release(&myproc()->lock);
    800019d4:	00000097          	auipc	ra,0x0
    800019d8:	fc0080e7          	jalr	-64(ra) # 80001994 <myproc>
    800019dc:	fffff097          	auipc	ra,0xfffff
    800019e0:	2ae080e7          	jalr	686(ra) # 80000c8a <release>

  if (first) {
    800019e4:	00007797          	auipc	a5,0x7
    800019e8:	e2c7a783          	lw	a5,-468(a5) # 80008810 <first.1689>
    800019ec:	eb89                	bnez	a5,800019fe <forkret+0x32>
    // be run from main().
    first = 0;
    fsinit(ROOTDEV);
  }

  usertrapret();
    800019ee:	00001097          	auipc	ra,0x1
    800019f2:	d40080e7          	jalr	-704(ra) # 8000272e <usertrapret>
}
    800019f6:	60a2                	ld	ra,8(sp)
    800019f8:	6402                	ld	s0,0(sp)
    800019fa:	0141                	addi	sp,sp,16
    800019fc:	8082                	ret
    first = 0;
    800019fe:	00007797          	auipc	a5,0x7
    80001a02:	e007a923          	sw	zero,-494(a5) # 80008810 <first.1689>
    fsinit(ROOTDEV);
    80001a06:	4505                	li	a0,1
    80001a08:	00002097          	auipc	ra,0x2
    80001a0c:	ac2080e7          	jalr	-1342(ra) # 800034ca <fsinit>
    80001a10:	bff9                	j	800019ee <forkret+0x22>

0000000080001a12 <allocpid>:
allocpid() {
    80001a12:	1101                	addi	sp,sp,-32
    80001a14:	ec06                	sd	ra,24(sp)
    80001a16:	e822                	sd	s0,16(sp)
    80001a18:	e426                	sd	s1,8(sp)
    80001a1a:	e04a                	sd	s2,0(sp)
    80001a1c:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001a1e:	00010917          	auipc	s2,0x10
    80001a22:	88290913          	addi	s2,s2,-1918 # 800112a0 <pid_lock>
    80001a26:	854a                	mv	a0,s2
    80001a28:	fffff097          	auipc	ra,0xfffff
    80001a2c:	1ae080e7          	jalr	430(ra) # 80000bd6 <acquire>
  pid = nextpid;
    80001a30:	00007797          	auipc	a5,0x7
    80001a34:	de478793          	addi	a5,a5,-540 # 80008814 <nextpid>
    80001a38:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001a3a:	0014871b          	addiw	a4,s1,1
    80001a3e:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001a40:	854a                	mv	a0,s2
    80001a42:	fffff097          	auipc	ra,0xfffff
    80001a46:	248080e7          	jalr	584(ra) # 80000c8a <release>
}
    80001a4a:	8526                	mv	a0,s1
    80001a4c:	60e2                	ld	ra,24(sp)
    80001a4e:	6442                	ld	s0,16(sp)
    80001a50:	64a2                	ld	s1,8(sp)
    80001a52:	6902                	ld	s2,0(sp)
    80001a54:	6105                	addi	sp,sp,32
    80001a56:	8082                	ret

0000000080001a58 <proc_pagetable>:
{
    80001a58:	1101                	addi	sp,sp,-32
    80001a5a:	ec06                	sd	ra,24(sp)
    80001a5c:	e822                	sd	s0,16(sp)
    80001a5e:	e426                	sd	s1,8(sp)
    80001a60:	e04a                	sd	s2,0(sp)
    80001a62:	1000                	addi	s0,sp,32
    80001a64:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001a66:	00000097          	auipc	ra,0x0
    80001a6a:	8b8080e7          	jalr	-1864(ra) # 8000131e <uvmcreate>
    80001a6e:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001a70:	c121                	beqz	a0,80001ab0 <proc_pagetable+0x58>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001a72:	4729                	li	a4,10
    80001a74:	00005697          	auipc	a3,0x5
    80001a78:	58c68693          	addi	a3,a3,1420 # 80007000 <_trampoline>
    80001a7c:	6605                	lui	a2,0x1
    80001a7e:	040005b7          	lui	a1,0x4000
    80001a82:	15fd                	addi	a1,a1,-1
    80001a84:	05b2                	slli	a1,a1,0xc
    80001a86:	fffff097          	auipc	ra,0xfffff
    80001a8a:	620080e7          	jalr	1568(ra) # 800010a6 <mappages>
    80001a8e:	02054863          	bltz	a0,80001abe <proc_pagetable+0x66>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80001a92:	4719                	li	a4,6
    80001a94:	05893683          	ld	a3,88(s2)
    80001a98:	6605                	lui	a2,0x1
    80001a9a:	020005b7          	lui	a1,0x2000
    80001a9e:	15fd                	addi	a1,a1,-1
    80001aa0:	05b6                	slli	a1,a1,0xd
    80001aa2:	8526                	mv	a0,s1
    80001aa4:	fffff097          	auipc	ra,0xfffff
    80001aa8:	602080e7          	jalr	1538(ra) # 800010a6 <mappages>
    80001aac:	02054163          	bltz	a0,80001ace <proc_pagetable+0x76>
}
    80001ab0:	8526                	mv	a0,s1
    80001ab2:	60e2                	ld	ra,24(sp)
    80001ab4:	6442                	ld	s0,16(sp)
    80001ab6:	64a2                	ld	s1,8(sp)
    80001ab8:	6902                	ld	s2,0(sp)
    80001aba:	6105                	addi	sp,sp,32
    80001abc:	8082                	ret
    uvmfree(pagetable, 0);
    80001abe:	4581                	li	a1,0
    80001ac0:	8526                	mv	a0,s1
    80001ac2:	00000097          	auipc	ra,0x0
    80001ac6:	a58080e7          	jalr	-1448(ra) # 8000151a <uvmfree>
    return 0;
    80001aca:	4481                	li	s1,0
    80001acc:	b7d5                	j	80001ab0 <proc_pagetable+0x58>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001ace:	4681                	li	a3,0
    80001ad0:	4605                	li	a2,1
    80001ad2:	040005b7          	lui	a1,0x4000
    80001ad6:	15fd                	addi	a1,a1,-1
    80001ad8:	05b2                	slli	a1,a1,0xc
    80001ada:	8526                	mv	a0,s1
    80001adc:	fffff097          	auipc	ra,0xfffff
    80001ae0:	77e080e7          	jalr	1918(ra) # 8000125a <uvmunmap>
    uvmfree(pagetable, 0);
    80001ae4:	4581                	li	a1,0
    80001ae6:	8526                	mv	a0,s1
    80001ae8:	00000097          	auipc	ra,0x0
    80001aec:	a32080e7          	jalr	-1486(ra) # 8000151a <uvmfree>
    return 0;
    80001af0:	4481                	li	s1,0
    80001af2:	bf7d                	j	80001ab0 <proc_pagetable+0x58>

0000000080001af4 <proc_freepagetable>:
{
    80001af4:	1101                	addi	sp,sp,-32
    80001af6:	ec06                	sd	ra,24(sp)
    80001af8:	e822                	sd	s0,16(sp)
    80001afa:	e426                	sd	s1,8(sp)
    80001afc:	e04a                	sd	s2,0(sp)
    80001afe:	1000                	addi	s0,sp,32
    80001b00:	84aa                	mv	s1,a0
    80001b02:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001b04:	4681                	li	a3,0
    80001b06:	4605                	li	a2,1
    80001b08:	040005b7          	lui	a1,0x4000
    80001b0c:	15fd                	addi	a1,a1,-1
    80001b0e:	05b2                	slli	a1,a1,0xc
    80001b10:	fffff097          	auipc	ra,0xfffff
    80001b14:	74a080e7          	jalr	1866(ra) # 8000125a <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001b18:	4681                	li	a3,0
    80001b1a:	4605                	li	a2,1
    80001b1c:	020005b7          	lui	a1,0x2000
    80001b20:	15fd                	addi	a1,a1,-1
    80001b22:	05b6                	slli	a1,a1,0xd
    80001b24:	8526                	mv	a0,s1
    80001b26:	fffff097          	auipc	ra,0xfffff
    80001b2a:	734080e7          	jalr	1844(ra) # 8000125a <uvmunmap>
  uvmfree(pagetable, sz);
    80001b2e:	85ca                	mv	a1,s2
    80001b30:	8526                	mv	a0,s1
    80001b32:	00000097          	auipc	ra,0x0
    80001b36:	9e8080e7          	jalr	-1560(ra) # 8000151a <uvmfree>
}
    80001b3a:	60e2                	ld	ra,24(sp)
    80001b3c:	6442                	ld	s0,16(sp)
    80001b3e:	64a2                	ld	s1,8(sp)
    80001b40:	6902                	ld	s2,0(sp)
    80001b42:	6105                	addi	sp,sp,32
    80001b44:	8082                	ret

0000000080001b46 <freeproc>:
{
    80001b46:	1101                	addi	sp,sp,-32
    80001b48:	ec06                	sd	ra,24(sp)
    80001b4a:	e822                	sd	s0,16(sp)
    80001b4c:	e426                	sd	s1,8(sp)
    80001b4e:	1000                	addi	s0,sp,32
    80001b50:	84aa                	mv	s1,a0
  if(p->trapframe)
    80001b52:	6d28                	ld	a0,88(a0)
    80001b54:	c509                	beqz	a0,80001b5e <freeproc+0x18>
    kfree((void*)p->trapframe);
    80001b56:	fffff097          	auipc	ra,0xfffff
    80001b5a:	e94080e7          	jalr	-364(ra) # 800009ea <kfree>
  p->trapframe = 0;
    80001b5e:	0404bc23          	sd	zero,88(s1)
  if(p->pagetable)
    80001b62:	68a8                	ld	a0,80(s1)
    80001b64:	c511                	beqz	a0,80001b70 <freeproc+0x2a>
    proc_freepagetable(p->pagetable, p->sz);
    80001b66:	64ac                	ld	a1,72(s1)
    80001b68:	00000097          	auipc	ra,0x0
    80001b6c:	f8c080e7          	jalr	-116(ra) # 80001af4 <proc_freepagetable>
  p->pagetable = 0;
    80001b70:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001b74:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001b78:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001b7c:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    80001b80:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001b84:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001b88:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001b8c:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001b90:	0004ac23          	sw	zero,24(s1)
}
    80001b94:	60e2                	ld	ra,24(sp)
    80001b96:	6442                	ld	s0,16(sp)
    80001b98:	64a2                	ld	s1,8(sp)
    80001b9a:	6105                	addi	sp,sp,32
    80001b9c:	8082                	ret

0000000080001b9e <allocproc>:
{
    80001b9e:	1101                	addi	sp,sp,-32
    80001ba0:	ec06                	sd	ra,24(sp)
    80001ba2:	e822                	sd	s0,16(sp)
    80001ba4:	e426                	sd	s1,8(sp)
    80001ba6:	e04a                	sd	s2,0(sp)
    80001ba8:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001baa:	00010497          	auipc	s1,0x10
    80001bae:	b2648493          	addi	s1,s1,-1242 # 800116d0 <proc>
    80001bb2:	00015917          	auipc	s2,0x15
    80001bb6:	71e90913          	addi	s2,s2,1822 # 800172d0 <tickslock>
    acquire(&p->lock);
    80001bba:	8526                	mv	a0,s1
    80001bbc:	fffff097          	auipc	ra,0xfffff
    80001bc0:	01a080e7          	jalr	26(ra) # 80000bd6 <acquire>
    if(p->state == UNUSED) {
    80001bc4:	4c9c                	lw	a5,24(s1)
    80001bc6:	cf81                	beqz	a5,80001bde <allocproc+0x40>
      release(&p->lock);
    80001bc8:	8526                	mv	a0,s1
    80001bca:	fffff097          	auipc	ra,0xfffff
    80001bce:	0c0080e7          	jalr	192(ra) # 80000c8a <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001bd2:	17048493          	addi	s1,s1,368
    80001bd6:	ff2492e3          	bne	s1,s2,80001bba <allocproc+0x1c>
  return 0;
    80001bda:	4481                	li	s1,0
    80001bdc:	a889                	j	80001c2e <allocproc+0x90>
  p->pid = allocpid();
    80001bde:	00000097          	auipc	ra,0x0
    80001be2:	e34080e7          	jalr	-460(ra) # 80001a12 <allocpid>
    80001be6:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001be8:	4785                	li	a5,1
    80001bea:	cc9c                	sw	a5,24(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001bec:	fffff097          	auipc	ra,0xfffff
    80001bf0:	efa080e7          	jalr	-262(ra) # 80000ae6 <kalloc>
    80001bf4:	892a                	mv	s2,a0
    80001bf6:	eca8                	sd	a0,88(s1)
    80001bf8:	c131                	beqz	a0,80001c3c <allocproc+0x9e>
  p->pagetable = proc_pagetable(p);
    80001bfa:	8526                	mv	a0,s1
    80001bfc:	00000097          	auipc	ra,0x0
    80001c00:	e5c080e7          	jalr	-420(ra) # 80001a58 <proc_pagetable>
    80001c04:	892a                	mv	s2,a0
    80001c06:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    80001c08:	c531                	beqz	a0,80001c54 <allocproc+0xb6>
  memset(&p->context, 0, sizeof(p->context));
    80001c0a:	07000613          	li	a2,112
    80001c0e:	4581                	li	a1,0
    80001c10:	06048513          	addi	a0,s1,96
    80001c14:	fffff097          	auipc	ra,0xfffff
    80001c18:	0be080e7          	jalr	190(ra) # 80000cd2 <memset>
  p->context.ra = (uint64)forkret;
    80001c1c:	00000797          	auipc	a5,0x0
    80001c20:	db078793          	addi	a5,a5,-592 # 800019cc <forkret>
    80001c24:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001c26:	60bc                	ld	a5,64(s1)
    80001c28:	6705                	lui	a4,0x1
    80001c2a:	97ba                	add	a5,a5,a4
    80001c2c:	f4bc                	sd	a5,104(s1)
}
    80001c2e:	8526                	mv	a0,s1
    80001c30:	60e2                	ld	ra,24(sp)
    80001c32:	6442                	ld	s0,16(sp)
    80001c34:	64a2                	ld	s1,8(sp)
    80001c36:	6902                	ld	s2,0(sp)
    80001c38:	6105                	addi	sp,sp,32
    80001c3a:	8082                	ret
    freeproc(p);
    80001c3c:	8526                	mv	a0,s1
    80001c3e:	00000097          	auipc	ra,0x0
    80001c42:	f08080e7          	jalr	-248(ra) # 80001b46 <freeproc>
    release(&p->lock);
    80001c46:	8526                	mv	a0,s1
    80001c48:	fffff097          	auipc	ra,0xfffff
    80001c4c:	042080e7          	jalr	66(ra) # 80000c8a <release>
    return 0;
    80001c50:	84ca                	mv	s1,s2
    80001c52:	bff1                	j	80001c2e <allocproc+0x90>
    freeproc(p);
    80001c54:	8526                	mv	a0,s1
    80001c56:	00000097          	auipc	ra,0x0
    80001c5a:	ef0080e7          	jalr	-272(ra) # 80001b46 <freeproc>
    release(&p->lock);
    80001c5e:	8526                	mv	a0,s1
    80001c60:	fffff097          	auipc	ra,0xfffff
    80001c64:	02a080e7          	jalr	42(ra) # 80000c8a <release>
    return 0;
    80001c68:	84ca                	mv	s1,s2
    80001c6a:	b7d1                	j	80001c2e <allocproc+0x90>

0000000080001c6c <userinit>:
{
    80001c6c:	1101                	addi	sp,sp,-32
    80001c6e:	ec06                	sd	ra,24(sp)
    80001c70:	e822                	sd	s0,16(sp)
    80001c72:	e426                	sd	s1,8(sp)
    80001c74:	1000                	addi	s0,sp,32
  p = allocproc();
    80001c76:	00000097          	auipc	ra,0x0
    80001c7a:	f28080e7          	jalr	-216(ra) # 80001b9e <allocproc>
    80001c7e:	84aa                	mv	s1,a0
  initproc = p;
    80001c80:	00007797          	auipc	a5,0x7
    80001c84:	3aa7b423          	sd	a0,936(a5) # 80009028 <initproc>
  uvminit(p->pagetable, initcode, sizeof(initcode));
    80001c88:	03400613          	li	a2,52
    80001c8c:	00007597          	auipc	a1,0x7
    80001c90:	b9458593          	addi	a1,a1,-1132 # 80008820 <initcode>
    80001c94:	6928                	ld	a0,80(a0)
    80001c96:	fffff097          	auipc	ra,0xfffff
    80001c9a:	6b6080e7          	jalr	1718(ra) # 8000134c <uvminit>
  p->sz = PGSIZE;
    80001c9e:	6785                	lui	a5,0x1
    80001ca0:	e4bc                	sd	a5,72(s1)
  p->trapframe->epc = 0;      // user program counter
    80001ca2:	6cb8                	ld	a4,88(s1)
    80001ca4:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE;  // user stack pointer
    80001ca8:	6cb8                	ld	a4,88(s1)
    80001caa:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001cac:	4641                	li	a2,16
    80001cae:	00006597          	auipc	a1,0x6
    80001cb2:	53a58593          	addi	a1,a1,1338 # 800081e8 <digits+0x1a8>
    80001cb6:	15848513          	addi	a0,s1,344
    80001cba:	fffff097          	auipc	ra,0xfffff
    80001cbe:	16e080e7          	jalr	366(ra) # 80000e28 <safestrcpy>
  p->cwd = namei("/");
    80001cc2:	00006517          	auipc	a0,0x6
    80001cc6:	53650513          	addi	a0,a0,1334 # 800081f8 <digits+0x1b8>
    80001cca:	00002097          	auipc	ra,0x2
    80001cce:	22e080e7          	jalr	558(ra) # 80003ef8 <namei>
    80001cd2:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001cd6:	478d                	li	a5,3
    80001cd8:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001cda:	8526                	mv	a0,s1
    80001cdc:	fffff097          	auipc	ra,0xfffff
    80001ce0:	fae080e7          	jalr	-82(ra) # 80000c8a <release>
}
    80001ce4:	60e2                	ld	ra,24(sp)
    80001ce6:	6442                	ld	s0,16(sp)
    80001ce8:	64a2                	ld	s1,8(sp)
    80001cea:	6105                	addi	sp,sp,32
    80001cec:	8082                	ret

0000000080001cee <growproc>:
{
    80001cee:	1101                	addi	sp,sp,-32
    80001cf0:	ec06                	sd	ra,24(sp)
    80001cf2:	e822                	sd	s0,16(sp)
    80001cf4:	e426                	sd	s1,8(sp)
    80001cf6:	e04a                	sd	s2,0(sp)
    80001cf8:	1000                	addi	s0,sp,32
    80001cfa:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001cfc:	00000097          	auipc	ra,0x0
    80001d00:	c98080e7          	jalr	-872(ra) # 80001994 <myproc>
    80001d04:	892a                	mv	s2,a0
  sz = p->sz;
    80001d06:	652c                	ld	a1,72(a0)
    80001d08:	0005861b          	sext.w	a2,a1
  if(n > 0){
    80001d0c:	00904f63          	bgtz	s1,80001d2a <growproc+0x3c>
  } else if(n < 0){
    80001d10:	0204cc63          	bltz	s1,80001d48 <growproc+0x5a>
  p->sz = sz;
    80001d14:	1602                	slli	a2,a2,0x20
    80001d16:	9201                	srli	a2,a2,0x20
    80001d18:	04c93423          	sd	a2,72(s2)
  return 0;
    80001d1c:	4501                	li	a0,0
}
    80001d1e:	60e2                	ld	ra,24(sp)
    80001d20:	6442                	ld	s0,16(sp)
    80001d22:	64a2                	ld	s1,8(sp)
    80001d24:	6902                	ld	s2,0(sp)
    80001d26:	6105                	addi	sp,sp,32
    80001d28:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n)) == 0) {
    80001d2a:	9e25                	addw	a2,a2,s1
    80001d2c:	1602                	slli	a2,a2,0x20
    80001d2e:	9201                	srli	a2,a2,0x20
    80001d30:	1582                	slli	a1,a1,0x20
    80001d32:	9181                	srli	a1,a1,0x20
    80001d34:	6928                	ld	a0,80(a0)
    80001d36:	fffff097          	auipc	ra,0xfffff
    80001d3a:	6d0080e7          	jalr	1744(ra) # 80001406 <uvmalloc>
    80001d3e:	0005061b          	sext.w	a2,a0
    80001d42:	fa69                	bnez	a2,80001d14 <growproc+0x26>
      return -1;
    80001d44:	557d                	li	a0,-1
    80001d46:	bfe1                	j	80001d1e <growproc+0x30>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001d48:	9e25                	addw	a2,a2,s1
    80001d4a:	1602                	slli	a2,a2,0x20
    80001d4c:	9201                	srli	a2,a2,0x20
    80001d4e:	1582                	slli	a1,a1,0x20
    80001d50:	9181                	srli	a1,a1,0x20
    80001d52:	6928                	ld	a0,80(a0)
    80001d54:	fffff097          	auipc	ra,0xfffff
    80001d58:	66a080e7          	jalr	1642(ra) # 800013be <uvmdealloc>
    80001d5c:	0005061b          	sext.w	a2,a0
    80001d60:	bf55                	j	80001d14 <growproc+0x26>

0000000080001d62 <fork>:
{
    80001d62:	7179                	addi	sp,sp,-48
    80001d64:	f406                	sd	ra,40(sp)
    80001d66:	f022                	sd	s0,32(sp)
    80001d68:	ec26                	sd	s1,24(sp)
    80001d6a:	e84a                	sd	s2,16(sp)
    80001d6c:	e44e                	sd	s3,8(sp)
    80001d6e:	e052                	sd	s4,0(sp)
    80001d70:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001d72:	00000097          	auipc	ra,0x0
    80001d76:	c22080e7          	jalr	-990(ra) # 80001994 <myproc>
    80001d7a:	892a                	mv	s2,a0
  if((np = allocproc()) == 0){
    80001d7c:	00000097          	auipc	ra,0x0
    80001d80:	e22080e7          	jalr	-478(ra) # 80001b9e <allocproc>
    80001d84:	10050e63          	beqz	a0,80001ea0 <fork+0x13e>
    80001d88:	89aa                	mv	s3,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001d8a:	04893603          	ld	a2,72(s2)
    80001d8e:	692c                	ld	a1,80(a0)
    80001d90:	05093503          	ld	a0,80(s2)
    80001d94:	fffff097          	auipc	ra,0xfffff
    80001d98:	7be080e7          	jalr	1982(ra) # 80001552 <uvmcopy>
    80001d9c:	04054963          	bltz	a0,80001dee <fork+0x8c>
  np->sz = p->sz;
    80001da0:	04893783          	ld	a5,72(s2)
    80001da4:	04f9b423          	sd	a5,72(s3)
  np->priority = 2;
    80001da8:	4789                	li	a5,2
    80001daa:	16f9a423          	sw	a5,360(s3)
  *(np->trapframe) = *(p->trapframe);
    80001dae:	05893683          	ld	a3,88(s2)
    80001db2:	87b6                	mv	a5,a3
    80001db4:	0589b703          	ld	a4,88(s3)
    80001db8:	12068693          	addi	a3,a3,288
    80001dbc:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80001dc0:	6788                	ld	a0,8(a5)
    80001dc2:	6b8c                	ld	a1,16(a5)
    80001dc4:	6f90                	ld	a2,24(a5)
    80001dc6:	01073023          	sd	a6,0(a4)
    80001dca:	e708                	sd	a0,8(a4)
    80001dcc:	eb0c                	sd	a1,16(a4)
    80001dce:	ef10                	sd	a2,24(a4)
    80001dd0:	02078793          	addi	a5,a5,32
    80001dd4:	02070713          	addi	a4,a4,32
    80001dd8:	fed792e3          	bne	a5,a3,80001dbc <fork+0x5a>
  np->trapframe->a0 = 0;
    80001ddc:	0589b783          	ld	a5,88(s3)
    80001de0:	0607b823          	sd	zero,112(a5)
    80001de4:	0d000493          	li	s1,208
  for(i = 0; i < NOFILE; i++)
    80001de8:	15000a13          	li	s4,336
    80001dec:	a03d                	j	80001e1a <fork+0xb8>
    freeproc(np);
    80001dee:	854e                	mv	a0,s3
    80001df0:	00000097          	auipc	ra,0x0
    80001df4:	d56080e7          	jalr	-682(ra) # 80001b46 <freeproc>
    release(&np->lock);
    80001df8:	854e                	mv	a0,s3
    80001dfa:	fffff097          	auipc	ra,0xfffff
    80001dfe:	e90080e7          	jalr	-368(ra) # 80000c8a <release>
    return -1;
    80001e02:	5a7d                	li	s4,-1
    80001e04:	a069                	j	80001e8e <fork+0x12c>
      np->ofile[i] = filedup(p->ofile[i]);
    80001e06:	00002097          	auipc	ra,0x2
    80001e0a:	788080e7          	jalr	1928(ra) # 8000458e <filedup>
    80001e0e:	009987b3          	add	a5,s3,s1
    80001e12:	e388                	sd	a0,0(a5)
  for(i = 0; i < NOFILE; i++)
    80001e14:	04a1                	addi	s1,s1,8
    80001e16:	01448763          	beq	s1,s4,80001e24 <fork+0xc2>
    if(p->ofile[i])
    80001e1a:	009907b3          	add	a5,s2,s1
    80001e1e:	6388                	ld	a0,0(a5)
    80001e20:	f17d                	bnez	a0,80001e06 <fork+0xa4>
    80001e22:	bfcd                	j	80001e14 <fork+0xb2>
  np->cwd = idup(p->cwd);
    80001e24:	15093503          	ld	a0,336(s2)
    80001e28:	00002097          	auipc	ra,0x2
    80001e2c:	8dc080e7          	jalr	-1828(ra) # 80003704 <idup>
    80001e30:	14a9b823          	sd	a0,336(s3)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001e34:	4641                	li	a2,16
    80001e36:	15890593          	addi	a1,s2,344
    80001e3a:	15898513          	addi	a0,s3,344
    80001e3e:	fffff097          	auipc	ra,0xfffff
    80001e42:	fea080e7          	jalr	-22(ra) # 80000e28 <safestrcpy>
  pid = np->pid;
    80001e46:	0309aa03          	lw	s4,48(s3)
  release(&np->lock);
    80001e4a:	854e                	mv	a0,s3
    80001e4c:	fffff097          	auipc	ra,0xfffff
    80001e50:	e3e080e7          	jalr	-450(ra) # 80000c8a <release>
  acquire(&wait_lock);
    80001e54:	0000f497          	auipc	s1,0xf
    80001e58:	46448493          	addi	s1,s1,1124 # 800112b8 <wait_lock>
    80001e5c:	8526                	mv	a0,s1
    80001e5e:	fffff097          	auipc	ra,0xfffff
    80001e62:	d78080e7          	jalr	-648(ra) # 80000bd6 <acquire>
  np->parent = p;
    80001e66:	0329bc23          	sd	s2,56(s3)
  release(&wait_lock);
    80001e6a:	8526                	mv	a0,s1
    80001e6c:	fffff097          	auipc	ra,0xfffff
    80001e70:	e1e080e7          	jalr	-482(ra) # 80000c8a <release>
  acquire(&np->lock);
    80001e74:	854e                	mv	a0,s3
    80001e76:	fffff097          	auipc	ra,0xfffff
    80001e7a:	d60080e7          	jalr	-672(ra) # 80000bd6 <acquire>
  np->state = RUNNABLE;
    80001e7e:	478d                	li	a5,3
    80001e80:	00f9ac23          	sw	a5,24(s3)
  release(&np->lock);
    80001e84:	854e                	mv	a0,s3
    80001e86:	fffff097          	auipc	ra,0xfffff
    80001e8a:	e04080e7          	jalr	-508(ra) # 80000c8a <release>
}
    80001e8e:	8552                	mv	a0,s4
    80001e90:	70a2                	ld	ra,40(sp)
    80001e92:	7402                	ld	s0,32(sp)
    80001e94:	64e2                	ld	s1,24(sp)
    80001e96:	6942                	ld	s2,16(sp)
    80001e98:	69a2                	ld	s3,8(sp)
    80001e9a:	6a02                	ld	s4,0(sp)
    80001e9c:	6145                	addi	sp,sp,48
    80001e9e:	8082                	ret
    return -1;
    80001ea0:	5a7d                	li	s4,-1
    80001ea2:	b7f5                	j	80001e8e <fork+0x12c>

0000000080001ea4 <scheduler>:
{
    80001ea4:	715d                	addi	sp,sp,-80
    80001ea6:	e486                	sd	ra,72(sp)
    80001ea8:	e0a2                	sd	s0,64(sp)
    80001eaa:	fc26                	sd	s1,56(sp)
    80001eac:	f84a                	sd	s2,48(sp)
    80001eae:	f44e                	sd	s3,40(sp)
    80001eb0:	f052                	sd	s4,32(sp)
    80001eb2:	ec56                	sd	s5,24(sp)
    80001eb4:	e85a                	sd	s6,16(sp)
    80001eb6:	e45e                	sd	s7,8(sp)
    80001eb8:	e062                	sd	s8,0(sp)
    80001eba:	0880                	addi	s0,sp,80
    80001ebc:	8792                	mv	a5,tp
  int id = r_tp();
    80001ebe:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001ec0:	00779b93          	slli	s7,a5,0x7
    80001ec4:	0000f717          	auipc	a4,0xf
    80001ec8:	3dc70713          	addi	a4,a4,988 # 800112a0 <pid_lock>
    80001ecc:	975e                	add	a4,a4,s7
    80001ece:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    80001ed2:	0000f717          	auipc	a4,0xf
    80001ed6:	40670713          	addi	a4,a4,1030 # 800112d8 <cpus+0x8>
    80001eda:	9bba                	add	s7,s7,a4
      if(p->priority == 2 && p->state == RUNNABLE) {
    80001edc:	498d                	li	s3,3
        p->state = RUNNING;
    80001ede:	4c11                	li	s8,4
        c->proc = p;
    80001ee0:	079e                	slli	a5,a5,0x7
    80001ee2:	0000fb17          	auipc	s6,0xf
    80001ee6:	3beb0b13          	addi	s6,s6,958 # 800112a0 <pid_lock>
    80001eea:	9b3e                	add	s6,s6,a5
    for(p = proc; p < &proc[NPROC]; p++) {
    80001eec:	00015917          	auipc	s2,0x15
    80001ef0:	3e490913          	addi	s2,s2,996 # 800172d0 <tickslock>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001ef4:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001ef8:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001efc:	10079073          	csrw	sstatus,a5
    80001f00:	0000f497          	auipc	s1,0xf
    80001f04:	7d048493          	addi	s1,s1,2000 # 800116d0 <proc>
      if(p->priority == 2 && p->state == RUNNABLE) {
    80001f08:	4a89                	li	s5,2
    80001f0a:	a03d                	j	80001f38 <scheduler+0x94>
        p->state = RUNNING;
    80001f0c:	0184ac23          	sw	s8,24(s1)
        c->proc = p;
    80001f10:	029b3823          	sd	s1,48(s6)
        swtch(&c->context, &p->context);
    80001f14:	06048593          	addi	a1,s1,96
    80001f18:	855e                	mv	a0,s7
    80001f1a:	00000097          	auipc	ra,0x0
    80001f1e:	76a080e7          	jalr	1898(ra) # 80002684 <swtch>
        c->proc = 0;
    80001f22:	020b3823          	sd	zero,48(s6)
      release(&p->lock);
    80001f26:	8526                	mv	a0,s1
    80001f28:	fffff097          	auipc	ra,0xfffff
    80001f2c:	d62080e7          	jalr	-670(ra) # 80000c8a <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    80001f30:	17048493          	addi	s1,s1,368
    80001f34:	01248f63          	beq	s1,s2,80001f52 <scheduler+0xae>
      acquire(&p->lock);
    80001f38:	8526                	mv	a0,s1
    80001f3a:	fffff097          	auipc	ra,0xfffff
    80001f3e:	c9c080e7          	jalr	-868(ra) # 80000bd6 <acquire>
      if(p->priority == 2 && p->state == RUNNABLE) {
    80001f42:	1684a783          	lw	a5,360(s1)
    80001f46:	ff5790e3          	bne	a5,s5,80001f26 <scheduler+0x82>
    80001f4a:	4c9c                	lw	a5,24(s1)
    80001f4c:	fd379de3          	bne	a5,s3,80001f26 <scheduler+0x82>
    80001f50:	bf75                	j	80001f0c <scheduler+0x68>
    for(p = proc; p < &proc[NPROC]; p++) {
    80001f52:	0000f497          	auipc	s1,0xf
    80001f56:	77e48493          	addi	s1,s1,1918 # 800116d0 <proc>
    80001f5a:	a03d                	j	80001f88 <scheduler+0xe4>
        p->state = RUNNING;
    80001f5c:	0184ac23          	sw	s8,24(s1)
        c->proc = p;
    80001f60:	029b3823          	sd	s1,48(s6)
        swtch(&c->context, &p->context);
    80001f64:	06048593          	addi	a1,s1,96
    80001f68:	855e                	mv	a0,s7
    80001f6a:	00000097          	auipc	ra,0x0
    80001f6e:	71a080e7          	jalr	1818(ra) # 80002684 <swtch>
        c->proc = 0;
    80001f72:	020b3823          	sd	zero,48(s6)
      release(&p->lock);
    80001f76:	8526                	mv	a0,s1
    80001f78:	fffff097          	auipc	ra,0xfffff
    80001f7c:	d12080e7          	jalr	-750(ra) # 80000c8a <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    80001f80:	17048493          	addi	s1,s1,368
    80001f84:	f72488e3          	beq	s1,s2,80001ef4 <scheduler+0x50>
      acquire(&p->lock);
    80001f88:	8526                	mv	a0,s1
    80001f8a:	fffff097          	auipc	ra,0xfffff
    80001f8e:	c4c080e7          	jalr	-948(ra) # 80000bd6 <acquire>
      if(p->state == RUNNABLE) {
    80001f92:	4c9c                	lw	a5,24(s1)
    80001f94:	ff3791e3          	bne	a5,s3,80001f76 <scheduler+0xd2>
    80001f98:	b7d1                	j	80001f5c <scheduler+0xb8>

0000000080001f9a <sched>:
{
    80001f9a:	7179                	addi	sp,sp,-48
    80001f9c:	f406                	sd	ra,40(sp)
    80001f9e:	f022                	sd	s0,32(sp)
    80001fa0:	ec26                	sd	s1,24(sp)
    80001fa2:	e84a                	sd	s2,16(sp)
    80001fa4:	e44e                	sd	s3,8(sp)
    80001fa6:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001fa8:	00000097          	auipc	ra,0x0
    80001fac:	9ec080e7          	jalr	-1556(ra) # 80001994 <myproc>
    80001fb0:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80001fb2:	fffff097          	auipc	ra,0xfffff
    80001fb6:	baa080e7          	jalr	-1110(ra) # 80000b5c <holding>
    80001fba:	c93d                	beqz	a0,80002030 <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001fbc:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    80001fbe:	2781                	sext.w	a5,a5
    80001fc0:	079e                	slli	a5,a5,0x7
    80001fc2:	0000f717          	auipc	a4,0xf
    80001fc6:	2de70713          	addi	a4,a4,734 # 800112a0 <pid_lock>
    80001fca:	97ba                	add	a5,a5,a4
    80001fcc:	0a87a703          	lw	a4,168(a5)
    80001fd0:	4785                	li	a5,1
    80001fd2:	06f71763          	bne	a4,a5,80002040 <sched+0xa6>
  if(p->state == RUNNING)
    80001fd6:	4c98                	lw	a4,24(s1)
    80001fd8:	4791                	li	a5,4
    80001fda:	06f70b63          	beq	a4,a5,80002050 <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001fde:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80001fe2:	8b89                	andi	a5,a5,2
  if(intr_get())
    80001fe4:	efb5                	bnez	a5,80002060 <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001fe6:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80001fe8:	0000f917          	auipc	s2,0xf
    80001fec:	2b890913          	addi	s2,s2,696 # 800112a0 <pid_lock>
    80001ff0:	2781                	sext.w	a5,a5
    80001ff2:	079e                	slli	a5,a5,0x7
    80001ff4:	97ca                	add	a5,a5,s2
    80001ff6:	0ac7a983          	lw	s3,172(a5)
    80001ffa:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80001ffc:	2781                	sext.w	a5,a5
    80001ffe:	079e                	slli	a5,a5,0x7
    80002000:	0000f597          	auipc	a1,0xf
    80002004:	2d858593          	addi	a1,a1,728 # 800112d8 <cpus+0x8>
    80002008:	95be                	add	a1,a1,a5
    8000200a:	06048513          	addi	a0,s1,96
    8000200e:	00000097          	auipc	ra,0x0
    80002012:	676080e7          	jalr	1654(ra) # 80002684 <swtch>
    80002016:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80002018:	2781                	sext.w	a5,a5
    8000201a:	079e                	slli	a5,a5,0x7
    8000201c:	97ca                	add	a5,a5,s2
    8000201e:	0b37a623          	sw	s3,172(a5)
}
    80002022:	70a2                	ld	ra,40(sp)
    80002024:	7402                	ld	s0,32(sp)
    80002026:	64e2                	ld	s1,24(sp)
    80002028:	6942                	ld	s2,16(sp)
    8000202a:	69a2                	ld	s3,8(sp)
    8000202c:	6145                	addi	sp,sp,48
    8000202e:	8082                	ret
    panic("sched p->lock");
    80002030:	00006517          	auipc	a0,0x6
    80002034:	1d050513          	addi	a0,a0,464 # 80008200 <digits+0x1c0>
    80002038:	ffffe097          	auipc	ra,0xffffe
    8000203c:	4f8080e7          	jalr	1272(ra) # 80000530 <panic>
    panic("sched locks");
    80002040:	00006517          	auipc	a0,0x6
    80002044:	1d050513          	addi	a0,a0,464 # 80008210 <digits+0x1d0>
    80002048:	ffffe097          	auipc	ra,0xffffe
    8000204c:	4e8080e7          	jalr	1256(ra) # 80000530 <panic>
    panic("sched running");
    80002050:	00006517          	auipc	a0,0x6
    80002054:	1d050513          	addi	a0,a0,464 # 80008220 <digits+0x1e0>
    80002058:	ffffe097          	auipc	ra,0xffffe
    8000205c:	4d8080e7          	jalr	1240(ra) # 80000530 <panic>
    panic("sched interruptible");
    80002060:	00006517          	auipc	a0,0x6
    80002064:	1d050513          	addi	a0,a0,464 # 80008230 <digits+0x1f0>
    80002068:	ffffe097          	auipc	ra,0xffffe
    8000206c:	4c8080e7          	jalr	1224(ra) # 80000530 <panic>

0000000080002070 <yield>:
{
    80002070:	1101                	addi	sp,sp,-32
    80002072:	ec06                	sd	ra,24(sp)
    80002074:	e822                	sd	s0,16(sp)
    80002076:	e426                	sd	s1,8(sp)
    80002078:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    8000207a:	00000097          	auipc	ra,0x0
    8000207e:	91a080e7          	jalr	-1766(ra) # 80001994 <myproc>
    80002082:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002084:	fffff097          	auipc	ra,0xfffff
    80002088:	b52080e7          	jalr	-1198(ra) # 80000bd6 <acquire>
  p->state = RUNNABLE;
    8000208c:	478d                	li	a5,3
    8000208e:	cc9c                	sw	a5,24(s1)
  sched();
    80002090:	00000097          	auipc	ra,0x0
    80002094:	f0a080e7          	jalr	-246(ra) # 80001f9a <sched>
  release(&p->lock);
    80002098:	8526                	mv	a0,s1
    8000209a:	fffff097          	auipc	ra,0xfffff
    8000209e:	bf0080e7          	jalr	-1040(ra) # 80000c8a <release>
}
    800020a2:	60e2                	ld	ra,24(sp)
    800020a4:	6442                	ld	s0,16(sp)
    800020a6:	64a2                	ld	s1,8(sp)
    800020a8:	6105                	addi	sp,sp,32
    800020aa:	8082                	ret

00000000800020ac <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    800020ac:	7179                	addi	sp,sp,-48
    800020ae:	f406                	sd	ra,40(sp)
    800020b0:	f022                	sd	s0,32(sp)
    800020b2:	ec26                	sd	s1,24(sp)
    800020b4:	e84a                	sd	s2,16(sp)
    800020b6:	e44e                	sd	s3,8(sp)
    800020b8:	1800                	addi	s0,sp,48
    800020ba:	89aa                	mv	s3,a0
    800020bc:	892e                	mv	s2,a1
  struct proc *p = myproc();
    800020be:	00000097          	auipc	ra,0x0
    800020c2:	8d6080e7          	jalr	-1834(ra) # 80001994 <myproc>
    800020c6:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    800020c8:	fffff097          	auipc	ra,0xfffff
    800020cc:	b0e080e7          	jalr	-1266(ra) # 80000bd6 <acquire>
  release(lk);
    800020d0:	854a                	mv	a0,s2
    800020d2:	fffff097          	auipc	ra,0xfffff
    800020d6:	bb8080e7          	jalr	-1096(ra) # 80000c8a <release>

  // Go to sleep.
  p->chan = chan;
    800020da:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    800020de:	4789                	li	a5,2
    800020e0:	cc9c                	sw	a5,24(s1)

  sched();
    800020e2:	00000097          	auipc	ra,0x0
    800020e6:	eb8080e7          	jalr	-328(ra) # 80001f9a <sched>

  // Tidy up.
  p->chan = 0;
    800020ea:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    800020ee:	8526                	mv	a0,s1
    800020f0:	fffff097          	auipc	ra,0xfffff
    800020f4:	b9a080e7          	jalr	-1126(ra) # 80000c8a <release>
  acquire(lk);
    800020f8:	854a                	mv	a0,s2
    800020fa:	fffff097          	auipc	ra,0xfffff
    800020fe:	adc080e7          	jalr	-1316(ra) # 80000bd6 <acquire>
}
    80002102:	70a2                	ld	ra,40(sp)
    80002104:	7402                	ld	s0,32(sp)
    80002106:	64e2                	ld	s1,24(sp)
    80002108:	6942                	ld	s2,16(sp)
    8000210a:	69a2                	ld	s3,8(sp)
    8000210c:	6145                	addi	sp,sp,48
    8000210e:	8082                	ret

0000000080002110 <wait>:
{
    80002110:	715d                	addi	sp,sp,-80
    80002112:	e486                	sd	ra,72(sp)
    80002114:	e0a2                	sd	s0,64(sp)
    80002116:	fc26                	sd	s1,56(sp)
    80002118:	f84a                	sd	s2,48(sp)
    8000211a:	f44e                	sd	s3,40(sp)
    8000211c:	f052                	sd	s4,32(sp)
    8000211e:	ec56                	sd	s5,24(sp)
    80002120:	e85a                	sd	s6,16(sp)
    80002122:	e45e                	sd	s7,8(sp)
    80002124:	e062                	sd	s8,0(sp)
    80002126:	0880                	addi	s0,sp,80
    80002128:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    8000212a:	00000097          	auipc	ra,0x0
    8000212e:	86a080e7          	jalr	-1942(ra) # 80001994 <myproc>
    80002132:	892a                	mv	s2,a0
  acquire(&wait_lock);
    80002134:	0000f517          	auipc	a0,0xf
    80002138:	18450513          	addi	a0,a0,388 # 800112b8 <wait_lock>
    8000213c:	fffff097          	auipc	ra,0xfffff
    80002140:	a9a080e7          	jalr	-1382(ra) # 80000bd6 <acquire>
    havekids = 0;
    80002144:	4b81                	li	s7,0
        if(np->state == ZOMBIE){
    80002146:	4a15                	li	s4,5
    for(np = proc; np < &proc[NPROC]; np++){
    80002148:	00015997          	auipc	s3,0x15
    8000214c:	18898993          	addi	s3,s3,392 # 800172d0 <tickslock>
        havekids = 1;
    80002150:	4a85                	li	s5,1
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002152:	0000fc17          	auipc	s8,0xf
    80002156:	166c0c13          	addi	s8,s8,358 # 800112b8 <wait_lock>
    havekids = 0;
    8000215a:	875e                	mv	a4,s7
    for(np = proc; np < &proc[NPROC]; np++){
    8000215c:	0000f497          	auipc	s1,0xf
    80002160:	57448493          	addi	s1,s1,1396 # 800116d0 <proc>
    80002164:	a0bd                	j	800021d2 <wait+0xc2>
          pid = np->pid;
    80002166:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    8000216a:	000b0e63          	beqz	s6,80002186 <wait+0x76>
    8000216e:	4691                	li	a3,4
    80002170:	02c48613          	addi	a2,s1,44
    80002174:	85da                	mv	a1,s6
    80002176:	05093503          	ld	a0,80(s2)
    8000217a:	fffff097          	auipc	ra,0xfffff
    8000217e:	4dc080e7          	jalr	1244(ra) # 80001656 <copyout>
    80002182:	02054563          	bltz	a0,800021ac <wait+0x9c>
          freeproc(np);
    80002186:	8526                	mv	a0,s1
    80002188:	00000097          	auipc	ra,0x0
    8000218c:	9be080e7          	jalr	-1602(ra) # 80001b46 <freeproc>
          release(&np->lock);
    80002190:	8526                	mv	a0,s1
    80002192:	fffff097          	auipc	ra,0xfffff
    80002196:	af8080e7          	jalr	-1288(ra) # 80000c8a <release>
          release(&wait_lock);
    8000219a:	0000f517          	auipc	a0,0xf
    8000219e:	11e50513          	addi	a0,a0,286 # 800112b8 <wait_lock>
    800021a2:	fffff097          	auipc	ra,0xfffff
    800021a6:	ae8080e7          	jalr	-1304(ra) # 80000c8a <release>
          return pid;
    800021aa:	a09d                	j	80002210 <wait+0x100>
            release(&np->lock);
    800021ac:	8526                	mv	a0,s1
    800021ae:	fffff097          	auipc	ra,0xfffff
    800021b2:	adc080e7          	jalr	-1316(ra) # 80000c8a <release>
            release(&wait_lock);
    800021b6:	0000f517          	auipc	a0,0xf
    800021ba:	10250513          	addi	a0,a0,258 # 800112b8 <wait_lock>
    800021be:	fffff097          	auipc	ra,0xfffff
    800021c2:	acc080e7          	jalr	-1332(ra) # 80000c8a <release>
            return -1;
    800021c6:	59fd                	li	s3,-1
    800021c8:	a0a1                	j	80002210 <wait+0x100>
    for(np = proc; np < &proc[NPROC]; np++){
    800021ca:	17048493          	addi	s1,s1,368
    800021ce:	03348463          	beq	s1,s3,800021f6 <wait+0xe6>
      if(np->parent == p){
    800021d2:	7c9c                	ld	a5,56(s1)
    800021d4:	ff279be3          	bne	a5,s2,800021ca <wait+0xba>
        acquire(&np->lock);
    800021d8:	8526                	mv	a0,s1
    800021da:	fffff097          	auipc	ra,0xfffff
    800021de:	9fc080e7          	jalr	-1540(ra) # 80000bd6 <acquire>
        if(np->state == ZOMBIE){
    800021e2:	4c9c                	lw	a5,24(s1)
    800021e4:	f94781e3          	beq	a5,s4,80002166 <wait+0x56>
        release(&np->lock);
    800021e8:	8526                	mv	a0,s1
    800021ea:	fffff097          	auipc	ra,0xfffff
    800021ee:	aa0080e7          	jalr	-1376(ra) # 80000c8a <release>
        havekids = 1;
    800021f2:	8756                	mv	a4,s5
    800021f4:	bfd9                	j	800021ca <wait+0xba>
    if(!havekids || p->killed){
    800021f6:	c701                	beqz	a4,800021fe <wait+0xee>
    800021f8:	02892783          	lw	a5,40(s2)
    800021fc:	c79d                	beqz	a5,8000222a <wait+0x11a>
      release(&wait_lock);
    800021fe:	0000f517          	auipc	a0,0xf
    80002202:	0ba50513          	addi	a0,a0,186 # 800112b8 <wait_lock>
    80002206:	fffff097          	auipc	ra,0xfffff
    8000220a:	a84080e7          	jalr	-1404(ra) # 80000c8a <release>
      return -1;
    8000220e:	59fd                	li	s3,-1
}
    80002210:	854e                	mv	a0,s3
    80002212:	60a6                	ld	ra,72(sp)
    80002214:	6406                	ld	s0,64(sp)
    80002216:	74e2                	ld	s1,56(sp)
    80002218:	7942                	ld	s2,48(sp)
    8000221a:	79a2                	ld	s3,40(sp)
    8000221c:	7a02                	ld	s4,32(sp)
    8000221e:	6ae2                	ld	s5,24(sp)
    80002220:	6b42                	ld	s6,16(sp)
    80002222:	6ba2                	ld	s7,8(sp)
    80002224:	6c02                	ld	s8,0(sp)
    80002226:	6161                	addi	sp,sp,80
    80002228:	8082                	ret
    sleep(p, &wait_lock);  //DOC: wait-sleep
    8000222a:	85e2                	mv	a1,s8
    8000222c:	854a                	mv	a0,s2
    8000222e:	00000097          	auipc	ra,0x0
    80002232:	e7e080e7          	jalr	-386(ra) # 800020ac <sleep>
    havekids = 0;
    80002236:	b715                	j	8000215a <wait+0x4a>

0000000080002238 <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void
wakeup(void *chan)
{
    80002238:	7139                	addi	sp,sp,-64
    8000223a:	fc06                	sd	ra,56(sp)
    8000223c:	f822                	sd	s0,48(sp)
    8000223e:	f426                	sd	s1,40(sp)
    80002240:	f04a                	sd	s2,32(sp)
    80002242:	ec4e                	sd	s3,24(sp)
    80002244:	e852                	sd	s4,16(sp)
    80002246:	e456                	sd	s5,8(sp)
    80002248:	0080                	addi	s0,sp,64
    8000224a:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    8000224c:	0000f497          	auipc	s1,0xf
    80002250:	48448493          	addi	s1,s1,1156 # 800116d0 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    80002254:	4989                	li	s3,2
        p->state = RUNNABLE;
    80002256:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    80002258:	00015917          	auipc	s2,0x15
    8000225c:	07890913          	addi	s2,s2,120 # 800172d0 <tickslock>
    80002260:	a821                	j	80002278 <wakeup+0x40>
        p->state = RUNNABLE;
    80002262:	0154ac23          	sw	s5,24(s1)
      }
      release(&p->lock);
    80002266:	8526                	mv	a0,s1
    80002268:	fffff097          	auipc	ra,0xfffff
    8000226c:	a22080e7          	jalr	-1502(ra) # 80000c8a <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80002270:	17048493          	addi	s1,s1,368
    80002274:	03248463          	beq	s1,s2,8000229c <wakeup+0x64>
    if(p != myproc()){
    80002278:	fffff097          	auipc	ra,0xfffff
    8000227c:	71c080e7          	jalr	1820(ra) # 80001994 <myproc>
    80002280:	fea488e3          	beq	s1,a0,80002270 <wakeup+0x38>
      acquire(&p->lock);
    80002284:	8526                	mv	a0,s1
    80002286:	fffff097          	auipc	ra,0xfffff
    8000228a:	950080e7          	jalr	-1712(ra) # 80000bd6 <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    8000228e:	4c9c                	lw	a5,24(s1)
    80002290:	fd379be3          	bne	a5,s3,80002266 <wakeup+0x2e>
    80002294:	709c                	ld	a5,32(s1)
    80002296:	fd4798e3          	bne	a5,s4,80002266 <wakeup+0x2e>
    8000229a:	b7e1                	j	80002262 <wakeup+0x2a>
    }
  }
}
    8000229c:	70e2                	ld	ra,56(sp)
    8000229e:	7442                	ld	s0,48(sp)
    800022a0:	74a2                	ld	s1,40(sp)
    800022a2:	7902                	ld	s2,32(sp)
    800022a4:	69e2                	ld	s3,24(sp)
    800022a6:	6a42                	ld	s4,16(sp)
    800022a8:	6aa2                	ld	s5,8(sp)
    800022aa:	6121                	addi	sp,sp,64
    800022ac:	8082                	ret

00000000800022ae <reparent>:
{
    800022ae:	7179                	addi	sp,sp,-48
    800022b0:	f406                	sd	ra,40(sp)
    800022b2:	f022                	sd	s0,32(sp)
    800022b4:	ec26                	sd	s1,24(sp)
    800022b6:	e84a                	sd	s2,16(sp)
    800022b8:	e44e                	sd	s3,8(sp)
    800022ba:	e052                	sd	s4,0(sp)
    800022bc:	1800                	addi	s0,sp,48
    800022be:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    800022c0:	0000f497          	auipc	s1,0xf
    800022c4:	41048493          	addi	s1,s1,1040 # 800116d0 <proc>
      pp->parent = initproc;
    800022c8:	00007a17          	auipc	s4,0x7
    800022cc:	d60a0a13          	addi	s4,s4,-672 # 80009028 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    800022d0:	00015997          	auipc	s3,0x15
    800022d4:	00098993          	mv	s3,s3
    800022d8:	a029                	j	800022e2 <reparent+0x34>
    800022da:	17048493          	addi	s1,s1,368
    800022de:	01348d63          	beq	s1,s3,800022f8 <reparent+0x4a>
    if(pp->parent == p){
    800022e2:	7c9c                	ld	a5,56(s1)
    800022e4:	ff279be3          	bne	a5,s2,800022da <reparent+0x2c>
      pp->parent = initproc;
    800022e8:	000a3503          	ld	a0,0(s4)
    800022ec:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    800022ee:	00000097          	auipc	ra,0x0
    800022f2:	f4a080e7          	jalr	-182(ra) # 80002238 <wakeup>
    800022f6:	b7d5                	j	800022da <reparent+0x2c>
}
    800022f8:	70a2                	ld	ra,40(sp)
    800022fa:	7402                	ld	s0,32(sp)
    800022fc:	64e2                	ld	s1,24(sp)
    800022fe:	6942                	ld	s2,16(sp)
    80002300:	69a2                	ld	s3,8(sp)
    80002302:	6a02                	ld	s4,0(sp)
    80002304:	6145                	addi	sp,sp,48
    80002306:	8082                	ret

0000000080002308 <exit>:
{
    80002308:	7179                	addi	sp,sp,-48
    8000230a:	f406                	sd	ra,40(sp)
    8000230c:	f022                	sd	s0,32(sp)
    8000230e:	ec26                	sd	s1,24(sp)
    80002310:	e84a                	sd	s2,16(sp)
    80002312:	e44e                	sd	s3,8(sp)
    80002314:	e052                	sd	s4,0(sp)
    80002316:	1800                	addi	s0,sp,48
    80002318:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    8000231a:	fffff097          	auipc	ra,0xfffff
    8000231e:	67a080e7          	jalr	1658(ra) # 80001994 <myproc>
    80002322:	89aa                	mv	s3,a0
  if(p == initproc)
    80002324:	00007797          	auipc	a5,0x7
    80002328:	d047b783          	ld	a5,-764(a5) # 80009028 <initproc>
    8000232c:	0d050493          	addi	s1,a0,208
    80002330:	15050913          	addi	s2,a0,336
    80002334:	02a79363          	bne	a5,a0,8000235a <exit+0x52>
    panic("init exiting");
    80002338:	00006517          	auipc	a0,0x6
    8000233c:	f1050513          	addi	a0,a0,-240 # 80008248 <digits+0x208>
    80002340:	ffffe097          	auipc	ra,0xffffe
    80002344:	1f0080e7          	jalr	496(ra) # 80000530 <panic>
      fileclose(f);
    80002348:	00002097          	auipc	ra,0x2
    8000234c:	298080e7          	jalr	664(ra) # 800045e0 <fileclose>
      p->ofile[fd] = 0;
    80002350:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    80002354:	04a1                	addi	s1,s1,8
    80002356:	01248563          	beq	s1,s2,80002360 <exit+0x58>
    if(p->ofile[fd]){
    8000235a:	6088                	ld	a0,0(s1)
    8000235c:	f575                	bnez	a0,80002348 <exit+0x40>
    8000235e:	bfdd                	j	80002354 <exit+0x4c>
  begin_op();
    80002360:	00002097          	auipc	ra,0x2
    80002364:	db4080e7          	jalr	-588(ra) # 80004114 <begin_op>
  iput(p->cwd);
    80002368:	1509b503          	ld	a0,336(s3) # 80017420 <bcache+0x138>
    8000236c:	00001097          	auipc	ra,0x1
    80002370:	590080e7          	jalr	1424(ra) # 800038fc <iput>
  end_op();
    80002374:	00002097          	auipc	ra,0x2
    80002378:	e20080e7          	jalr	-480(ra) # 80004194 <end_op>
  p->cwd = 0;
    8000237c:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    80002380:	0000f497          	auipc	s1,0xf
    80002384:	f3848493          	addi	s1,s1,-200 # 800112b8 <wait_lock>
    80002388:	8526                	mv	a0,s1
    8000238a:	fffff097          	auipc	ra,0xfffff
    8000238e:	84c080e7          	jalr	-1972(ra) # 80000bd6 <acquire>
  reparent(p);
    80002392:	854e                	mv	a0,s3
    80002394:	00000097          	auipc	ra,0x0
    80002398:	f1a080e7          	jalr	-230(ra) # 800022ae <reparent>
  wakeup(p->parent);
    8000239c:	0389b503          	ld	a0,56(s3)
    800023a0:	00000097          	auipc	ra,0x0
    800023a4:	e98080e7          	jalr	-360(ra) # 80002238 <wakeup>
  acquire(&p->lock);
    800023a8:	854e                	mv	a0,s3
    800023aa:	fffff097          	auipc	ra,0xfffff
    800023ae:	82c080e7          	jalr	-2004(ra) # 80000bd6 <acquire>
  p->xstate = status;
    800023b2:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    800023b6:	4795                	li	a5,5
    800023b8:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    800023bc:	8526                	mv	a0,s1
    800023be:	fffff097          	auipc	ra,0xfffff
    800023c2:	8cc080e7          	jalr	-1844(ra) # 80000c8a <release>
  sched();
    800023c6:	00000097          	auipc	ra,0x0
    800023ca:	bd4080e7          	jalr	-1068(ra) # 80001f9a <sched>
  panic("zombie exit");
    800023ce:	00006517          	auipc	a0,0x6
    800023d2:	e8a50513          	addi	a0,a0,-374 # 80008258 <digits+0x218>
    800023d6:	ffffe097          	auipc	ra,0xffffe
    800023da:	15a080e7          	jalr	346(ra) # 80000530 <panic>

00000000800023de <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    800023de:	7179                	addi	sp,sp,-48
    800023e0:	f406                	sd	ra,40(sp)
    800023e2:	f022                	sd	s0,32(sp)
    800023e4:	ec26                	sd	s1,24(sp)
    800023e6:	e84a                	sd	s2,16(sp)
    800023e8:	e44e                	sd	s3,8(sp)
    800023ea:	1800                	addi	s0,sp,48
    800023ec:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    800023ee:	0000f497          	auipc	s1,0xf
    800023f2:	2e248493          	addi	s1,s1,738 # 800116d0 <proc>
    800023f6:	00015997          	auipc	s3,0x15
    800023fa:	eda98993          	addi	s3,s3,-294 # 800172d0 <tickslock>
    acquire(&p->lock);
    800023fe:	8526                	mv	a0,s1
    80002400:	ffffe097          	auipc	ra,0xffffe
    80002404:	7d6080e7          	jalr	2006(ra) # 80000bd6 <acquire>
    if(p->pid == pid){
    80002408:	589c                	lw	a5,48(s1)
    8000240a:	01278d63          	beq	a5,s2,80002424 <kill+0x46>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    8000240e:	8526                	mv	a0,s1
    80002410:	fffff097          	auipc	ra,0xfffff
    80002414:	87a080e7          	jalr	-1926(ra) # 80000c8a <release>
  for(p = proc; p < &proc[NPROC]; p++){
    80002418:	17048493          	addi	s1,s1,368
    8000241c:	ff3491e3          	bne	s1,s3,800023fe <kill+0x20>
  }
  return -1;
    80002420:	557d                	li	a0,-1
    80002422:	a829                	j	8000243c <kill+0x5e>
      p->killed = 1;
    80002424:	4785                	li	a5,1
    80002426:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    80002428:	4c98                	lw	a4,24(s1)
    8000242a:	4789                	li	a5,2
    8000242c:	00f70f63          	beq	a4,a5,8000244a <kill+0x6c>
      release(&p->lock);
    80002430:	8526                	mv	a0,s1
    80002432:	fffff097          	auipc	ra,0xfffff
    80002436:	858080e7          	jalr	-1960(ra) # 80000c8a <release>
      return 0;
    8000243a:	4501                	li	a0,0
}
    8000243c:	70a2                	ld	ra,40(sp)
    8000243e:	7402                	ld	s0,32(sp)
    80002440:	64e2                	ld	s1,24(sp)
    80002442:	6942                	ld	s2,16(sp)
    80002444:	69a2                	ld	s3,8(sp)
    80002446:	6145                	addi	sp,sp,48
    80002448:	8082                	ret
        p->state = RUNNABLE;
    8000244a:	478d                	li	a5,3
    8000244c:	cc9c                	sw	a5,24(s1)
    8000244e:	b7cd                	j	80002430 <kill+0x52>

0000000080002450 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    80002450:	7179                	addi	sp,sp,-48
    80002452:	f406                	sd	ra,40(sp)
    80002454:	f022                	sd	s0,32(sp)
    80002456:	ec26                	sd	s1,24(sp)
    80002458:	e84a                	sd	s2,16(sp)
    8000245a:	e44e                	sd	s3,8(sp)
    8000245c:	e052                	sd	s4,0(sp)
    8000245e:	1800                	addi	s0,sp,48
    80002460:	84aa                	mv	s1,a0
    80002462:	892e                	mv	s2,a1
    80002464:	89b2                	mv	s3,a2
    80002466:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002468:	fffff097          	auipc	ra,0xfffff
    8000246c:	52c080e7          	jalr	1324(ra) # 80001994 <myproc>
  if(user_dst){
    80002470:	c08d                	beqz	s1,80002492 <either_copyout+0x42>
    return copyout(p->pagetable, dst, src, len);
    80002472:	86d2                	mv	a3,s4
    80002474:	864e                	mv	a2,s3
    80002476:	85ca                	mv	a1,s2
    80002478:	6928                	ld	a0,80(a0)
    8000247a:	fffff097          	auipc	ra,0xfffff
    8000247e:	1dc080e7          	jalr	476(ra) # 80001656 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    80002482:	70a2                	ld	ra,40(sp)
    80002484:	7402                	ld	s0,32(sp)
    80002486:	64e2                	ld	s1,24(sp)
    80002488:	6942                	ld	s2,16(sp)
    8000248a:	69a2                	ld	s3,8(sp)
    8000248c:	6a02                	ld	s4,0(sp)
    8000248e:	6145                	addi	sp,sp,48
    80002490:	8082                	ret
    memmove((char *)dst, src, len);
    80002492:	000a061b          	sext.w	a2,s4
    80002496:	85ce                	mv	a1,s3
    80002498:	854a                	mv	a0,s2
    8000249a:	fffff097          	auipc	ra,0xfffff
    8000249e:	898080e7          	jalr	-1896(ra) # 80000d32 <memmove>
    return 0;
    800024a2:	8526                	mv	a0,s1
    800024a4:	bff9                	j	80002482 <either_copyout+0x32>

00000000800024a6 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    800024a6:	7179                	addi	sp,sp,-48
    800024a8:	f406                	sd	ra,40(sp)
    800024aa:	f022                	sd	s0,32(sp)
    800024ac:	ec26                	sd	s1,24(sp)
    800024ae:	e84a                	sd	s2,16(sp)
    800024b0:	e44e                	sd	s3,8(sp)
    800024b2:	e052                	sd	s4,0(sp)
    800024b4:	1800                	addi	s0,sp,48
    800024b6:	892a                	mv	s2,a0
    800024b8:	84ae                	mv	s1,a1
    800024ba:	89b2                	mv	s3,a2
    800024bc:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800024be:	fffff097          	auipc	ra,0xfffff
    800024c2:	4d6080e7          	jalr	1238(ra) # 80001994 <myproc>
  if(user_src){
    800024c6:	c08d                	beqz	s1,800024e8 <either_copyin+0x42>
    return copyin(p->pagetable, dst, src, len);
    800024c8:	86d2                	mv	a3,s4
    800024ca:	864e                	mv	a2,s3
    800024cc:	85ca                	mv	a1,s2
    800024ce:	6928                	ld	a0,80(a0)
    800024d0:	fffff097          	auipc	ra,0xfffff
    800024d4:	212080e7          	jalr	530(ra) # 800016e2 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    800024d8:	70a2                	ld	ra,40(sp)
    800024da:	7402                	ld	s0,32(sp)
    800024dc:	64e2                	ld	s1,24(sp)
    800024de:	6942                	ld	s2,16(sp)
    800024e0:	69a2                	ld	s3,8(sp)
    800024e2:	6a02                	ld	s4,0(sp)
    800024e4:	6145                	addi	sp,sp,48
    800024e6:	8082                	ret
    memmove(dst, (char*)src, len);
    800024e8:	000a061b          	sext.w	a2,s4
    800024ec:	85ce                	mv	a1,s3
    800024ee:	854a                	mv	a0,s2
    800024f0:	fffff097          	auipc	ra,0xfffff
    800024f4:	842080e7          	jalr	-1982(ra) # 80000d32 <memmove>
    return 0;
    800024f8:	8526                	mv	a0,s1
    800024fa:	bff9                	j	800024d8 <either_copyin+0x32>

00000000800024fc <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    800024fc:	715d                	addi	sp,sp,-80
    800024fe:	e486                	sd	ra,72(sp)
    80002500:	e0a2                	sd	s0,64(sp)
    80002502:	fc26                	sd	s1,56(sp)
    80002504:	f84a                	sd	s2,48(sp)
    80002506:	f44e                	sd	s3,40(sp)
    80002508:	f052                	sd	s4,32(sp)
    8000250a:	ec56                	sd	s5,24(sp)
    8000250c:	e85a                	sd	s6,16(sp)
    8000250e:	e45e                	sd	s7,8(sp)
    80002510:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    80002512:	00006517          	auipc	a0,0x6
    80002516:	bb650513          	addi	a0,a0,-1098 # 800080c8 <digits+0x88>
    8000251a:	ffffe097          	auipc	ra,0xffffe
    8000251e:	060080e7          	jalr	96(ra) # 8000057a <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002522:	0000f497          	auipc	s1,0xf
    80002526:	30648493          	addi	s1,s1,774 # 80011828 <proc+0x158>
    8000252a:	00015917          	auipc	s2,0x15
    8000252e:	efe90913          	addi	s2,s2,-258 # 80017428 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002532:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    80002534:	00006997          	auipc	s3,0x6
    80002538:	d3498993          	addi	s3,s3,-716 # 80008268 <digits+0x228>
    printf("%d %s %s", p->pid, state, p->name);
    8000253c:	00006a97          	auipc	s5,0x6
    80002540:	d34a8a93          	addi	s5,s5,-716 # 80008270 <digits+0x230>
    printf("\n");
    80002544:	00006a17          	auipc	s4,0x6
    80002548:	b84a0a13          	addi	s4,s4,-1148 # 800080c8 <digits+0x88>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000254c:	00006b97          	auipc	s7,0x6
    80002550:	d5cb8b93          	addi	s7,s7,-676 # 800082a8 <states.1726>
    80002554:	a00d                	j	80002576 <procdump+0x7a>
    printf("%d %s %s", p->pid, state, p->name);
    80002556:	ed86a583          	lw	a1,-296(a3)
    8000255a:	8556                	mv	a0,s5
    8000255c:	ffffe097          	auipc	ra,0xffffe
    80002560:	01e080e7          	jalr	30(ra) # 8000057a <printf>
    printf("\n");
    80002564:	8552                	mv	a0,s4
    80002566:	ffffe097          	auipc	ra,0xffffe
    8000256a:	014080e7          	jalr	20(ra) # 8000057a <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    8000256e:	17048493          	addi	s1,s1,368
    80002572:	03248163          	beq	s1,s2,80002594 <procdump+0x98>
    if(p->state == UNUSED)
    80002576:	86a6                	mv	a3,s1
    80002578:	ec04a783          	lw	a5,-320(s1)
    8000257c:	dbed                	beqz	a5,8000256e <procdump+0x72>
      state = "???";
    8000257e:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002580:	fcfb6be3          	bltu	s6,a5,80002556 <procdump+0x5a>
    80002584:	1782                	slli	a5,a5,0x20
    80002586:	9381                	srli	a5,a5,0x20
    80002588:	078e                	slli	a5,a5,0x3
    8000258a:	97de                	add	a5,a5,s7
    8000258c:	6390                	ld	a2,0(a5)
    8000258e:	f661                	bnez	a2,80002556 <procdump+0x5a>
      state = "???";
    80002590:	864e                	mv	a2,s3
    80002592:	b7d1                	j	80002556 <procdump+0x5a>
  }
}
    80002594:	60a6                	ld	ra,72(sp)
    80002596:	6406                	ld	s0,64(sp)
    80002598:	74e2                	ld	s1,56(sp)
    8000259a:	7942                	ld	s2,48(sp)
    8000259c:	79a2                	ld	s3,40(sp)
    8000259e:	7a02                	ld	s4,32(sp)
    800025a0:	6ae2                	ld	s5,24(sp)
    800025a2:	6b42                	ld	s6,16(sp)
    800025a4:	6ba2                	ld	s7,8(sp)
    800025a6:	6161                	addi	sp,sp,80
    800025a8:	8082                	ret

00000000800025aa <ps>:
// Project 4
// Populates a preallocated array of ps_proc with process
// related data. See user/psm.c for use.
// Returns amount of active processes up to MAX_PROCS.
int
ps(struct ps_proc* procs) {
    800025aa:	715d                	addi	sp,sp,-80
    800025ac:	e486                	sd	ra,72(sp)
    800025ae:	e0a2                	sd	s0,64(sp)
    800025b0:	fc26                	sd	s1,56(sp)
    800025b2:	f84a                	sd	s2,48(sp)
    800025b4:	f44e                	sd	s3,40(sp)
    800025b6:	f052                	sd	s4,32(sp)
    800025b8:	ec56                	sd	s5,24(sp)
    800025ba:	e85a                	sd	s6,16(sp)
    800025bc:	e45e                	sd	s7,8(sp)
    800025be:	e062                	sd	s8,0(sp)
    800025c0:	0880                	addi	s0,sp,80
    800025c2:	8c2a                	mv	s8,a0
  struct ps_proc ps_procs[MAX_PROCS];
    800025c4:	da010113          	addi	sp,sp,-608
    800025c8:	8b0a                	mv	s6,sp
  struct proc* p = myproc();
    800025ca:	fffff097          	auipc	ra,0xfffff
    800025ce:	3ca080e7          	jalr	970(ra) # 80001994 <myproc>
    800025d2:	8baa                	mv	s7,a0

  int total_procs = 0;
  for (int i = 0; i < NPROC && total_procs < MAX_PROCS; i++) {
    800025d4:	0000f497          	auipc	s1,0xf
    800025d8:	0fc48493          	addi	s1,s1,252 # 800116d0 <proc>
    800025dc:	00015a17          	auipc	s4,0x15
    800025e0:	b84a0a13          	addi	s4,s4,-1148 # 80017160 <proc+0x5a90>
  int total_procs = 0;
    800025e4:	4981                	li	s3,0
  for (int i = 0; i < NPROC && total_procs < MAX_PROCS; i++) {
    800025e6:	4ab9                	li	s5,14
    800025e8:	a8a1                	j	80002640 <ps+0x96>
    if (proc[i].state != UNUSED) {
      acquire(&proc[i].lock);
    800025ea:	8526                	mv	a0,s1
    800025ec:	ffffe097          	auipc	ra,0xffffe
    800025f0:	5ea080e7          	jalr	1514(ra) # 80000bd6 <acquire>
      strncpy(ps_procs[total_procs].name, proc[i].name, 16);
    800025f4:	00299913          	slli	s2,s3,0x2
    800025f8:	994e                	add	s2,s2,s3
    800025fa:	090e                	slli	s2,s2,0x3
    800025fc:	995a                	add	s2,s2,s6
    800025fe:	4641                	li	a2,16
    80002600:	15848593          	addi	a1,s1,344
    80002604:	854a                	mv	a0,s2
    80002606:	ffffe097          	auipc	ra,0xffffe
    8000260a:	7e4080e7          	jalr	2020(ra) # 80000dea <strncpy>
      ps_procs[total_procs].memory = proc[i].sz;
    8000260e:	64bc                	ld	a5,72(s1)
    80002610:	02f93023          	sd	a5,32(s2)
      ps_procs[total_procs].priority = proc[i].priority;
    80002614:	1684a783          	lw	a5,360(s1)
    80002618:	00f92c23          	sw	a5,24(s2)
      ps_procs[total_procs].state = proc[i].state;
    8000261c:	4c9c                	lw	a5,24(s1)
    8000261e:	00f92823          	sw	a5,16(s2)
      ps_procs[total_procs].pid = proc[i].pid;
    80002622:	589c                	lw	a5,48(s1)
    80002624:	00f92a23          	sw	a5,20(s2)
      release(&proc[i].lock);
    80002628:	8526                	mv	a0,s1
    8000262a:	ffffe097          	auipc	ra,0xffffe
    8000262e:	660080e7          	jalr	1632(ra) # 80000c8a <release>
      
      total_procs++;
    80002632:	2985                	addiw	s3,s3,1
  for (int i = 0; i < NPROC && total_procs < MAX_PROCS; i++) {
    80002634:	01448963          	beq	s1,s4,80002646 <ps+0x9c>
    80002638:	17048493          	addi	s1,s1,368
    8000263c:	013ac563          	blt	s5,s3,80002646 <ps+0x9c>
    if (proc[i].state != UNUSED) {
    80002640:	4c9c                	lw	a5,24(s1)
    80002642:	dbed                	beqz	a5,80002634 <ps+0x8a>
    80002644:	b75d                	j	800025ea <ps+0x40>
    }
  }

  if (copyout(p->pagetable,(uint64)procs, (char*)ps_procs, sizeof(struct ps_proc) * total_procs) < 0) {
    80002646:	00299693          	slli	a3,s3,0x2
    8000264a:	96ce                	add	a3,a3,s3
    8000264c:	068e                	slli	a3,a3,0x3
    8000264e:	865a                	mv	a2,s6
    80002650:	85e2                	mv	a1,s8
    80002652:	050bb503          	ld	a0,80(s7)
    80002656:	fffff097          	auipc	ra,0xfffff
    8000265a:	000080e7          	jalr	ra # 80001656 <copyout>
    8000265e:	02054163          	bltz	a0,80002680 <ps+0xd6>
    return -1;
  }

  return total_procs;
}
    80002662:	854e                	mv	a0,s3
    80002664:	fb040113          	addi	sp,s0,-80
    80002668:	60a6                	ld	ra,72(sp)
    8000266a:	6406                	ld	s0,64(sp)
    8000266c:	74e2                	ld	s1,56(sp)
    8000266e:	7942                	ld	s2,48(sp)
    80002670:	79a2                	ld	s3,40(sp)
    80002672:	7a02                	ld	s4,32(sp)
    80002674:	6ae2                	ld	s5,24(sp)
    80002676:	6b42                	ld	s6,16(sp)
    80002678:	6ba2                	ld	s7,8(sp)
    8000267a:	6c02                	ld	s8,0(sp)
    8000267c:	6161                	addi	sp,sp,80
    8000267e:	8082                	ret
    return -1;
    80002680:	59fd                	li	s3,-1
    80002682:	b7c5                	j	80002662 <ps+0xb8>

0000000080002684 <swtch>:
    80002684:	00153023          	sd	ra,0(a0)
    80002688:	00253423          	sd	sp,8(a0)
    8000268c:	e900                	sd	s0,16(a0)
    8000268e:	ed04                	sd	s1,24(a0)
    80002690:	03253023          	sd	s2,32(a0)
    80002694:	03353423          	sd	s3,40(a0)
    80002698:	03453823          	sd	s4,48(a0)
    8000269c:	03553c23          	sd	s5,56(a0)
    800026a0:	05653023          	sd	s6,64(a0)
    800026a4:	05753423          	sd	s7,72(a0)
    800026a8:	05853823          	sd	s8,80(a0)
    800026ac:	05953c23          	sd	s9,88(a0)
    800026b0:	07a53023          	sd	s10,96(a0)
    800026b4:	07b53423          	sd	s11,104(a0)
    800026b8:	0005b083          	ld	ra,0(a1)
    800026bc:	0085b103          	ld	sp,8(a1)
    800026c0:	6980                	ld	s0,16(a1)
    800026c2:	6d84                	ld	s1,24(a1)
    800026c4:	0205b903          	ld	s2,32(a1)
    800026c8:	0285b983          	ld	s3,40(a1)
    800026cc:	0305ba03          	ld	s4,48(a1)
    800026d0:	0385ba83          	ld	s5,56(a1)
    800026d4:	0405bb03          	ld	s6,64(a1)
    800026d8:	0485bb83          	ld	s7,72(a1)
    800026dc:	0505bc03          	ld	s8,80(a1)
    800026e0:	0585bc83          	ld	s9,88(a1)
    800026e4:	0605bd03          	ld	s10,96(a1)
    800026e8:	0685bd83          	ld	s11,104(a1)
    800026ec:	8082                	ret

00000000800026ee <trapinit>:

extern int devintr();

void
trapinit(void)
{
    800026ee:	1141                	addi	sp,sp,-16
    800026f0:	e406                	sd	ra,8(sp)
    800026f2:	e022                	sd	s0,0(sp)
    800026f4:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    800026f6:	00006597          	auipc	a1,0x6
    800026fa:	be258593          	addi	a1,a1,-1054 # 800082d8 <states.1726+0x30>
    800026fe:	00015517          	auipc	a0,0x15
    80002702:	bd250513          	addi	a0,a0,-1070 # 800172d0 <tickslock>
    80002706:	ffffe097          	auipc	ra,0xffffe
    8000270a:	440080e7          	jalr	1088(ra) # 80000b46 <initlock>
}
    8000270e:	60a2                	ld	ra,8(sp)
    80002710:	6402                	ld	s0,0(sp)
    80002712:	0141                	addi	sp,sp,16
    80002714:	8082                	ret

0000000080002716 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80002716:	1141                	addi	sp,sp,-16
    80002718:	e422                	sd	s0,8(sp)
    8000271a:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    8000271c:	00003797          	auipc	a5,0x3
    80002720:	4e478793          	addi	a5,a5,1252 # 80005c00 <kernelvec>
    80002724:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80002728:	6422                	ld	s0,8(sp)
    8000272a:	0141                	addi	sp,sp,16
    8000272c:	8082                	ret

000000008000272e <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    8000272e:	1141                	addi	sp,sp,-16
    80002730:	e406                	sd	ra,8(sp)
    80002732:	e022                	sd	s0,0(sp)
    80002734:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002736:	fffff097          	auipc	ra,0xfffff
    8000273a:	25e080e7          	jalr	606(ra) # 80001994 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000273e:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002742:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002744:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to trampoline.S
  w_stvec(TRAMPOLINE + (uservec - trampoline));
    80002748:	00005617          	auipc	a2,0x5
    8000274c:	8b860613          	addi	a2,a2,-1864 # 80007000 <_trampoline>
    80002750:	00005697          	auipc	a3,0x5
    80002754:	8b068693          	addi	a3,a3,-1872 # 80007000 <_trampoline>
    80002758:	8e91                	sub	a3,a3,a2
    8000275a:	040007b7          	lui	a5,0x4000
    8000275e:	17fd                	addi	a5,a5,-1
    80002760:	07b2                	slli	a5,a5,0xc
    80002762:	96be                	add	a3,a3,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002764:	10569073          	csrw	stvec,a3

  // set up trapframe values that uservec will need when
  // the process next re-enters the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80002768:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    8000276a:	180026f3          	csrr	a3,satp
    8000276e:	e314                	sd	a3,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002770:	6d38                	ld	a4,88(a0)
    80002772:	6134                	ld	a3,64(a0)
    80002774:	6585                	lui	a1,0x1
    80002776:	96ae                	add	a3,a3,a1
    80002778:	e714                	sd	a3,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    8000277a:	6d38                	ld	a4,88(a0)
    8000277c:	00000697          	auipc	a3,0x0
    80002780:	13868693          	addi	a3,a3,312 # 800028b4 <usertrap>
    80002784:	eb14                	sd	a3,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    80002786:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80002788:	8692                	mv	a3,tp
    8000278a:	f314                	sd	a3,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000278c:	100026f3          	csrr	a3,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002790:	eff6f693          	andi	a3,a3,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002794:	0206e693          	ori	a3,a3,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002798:	10069073          	csrw	sstatus,a3
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    8000279c:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    8000279e:	6f18                	ld	a4,24(a4)
    800027a0:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    800027a4:	692c                	ld	a1,80(a0)
    800027a6:	81b1                	srli	a1,a1,0xc

  // jump to trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 fn = TRAMPOLINE + (userret - trampoline);
    800027a8:	00005717          	auipc	a4,0x5
    800027ac:	8e870713          	addi	a4,a4,-1816 # 80007090 <userret>
    800027b0:	8f11                	sub	a4,a4,a2
    800027b2:	97ba                	add	a5,a5,a4
  ((void (*)(uint64,uint64))fn)(TRAPFRAME, satp);
    800027b4:	577d                	li	a4,-1
    800027b6:	177e                	slli	a4,a4,0x3f
    800027b8:	8dd9                	or	a1,a1,a4
    800027ba:	02000537          	lui	a0,0x2000
    800027be:	157d                	addi	a0,a0,-1
    800027c0:	0536                	slli	a0,a0,0xd
    800027c2:	9782                	jalr	a5
}
    800027c4:	60a2                	ld	ra,8(sp)
    800027c6:	6402                	ld	s0,0(sp)
    800027c8:	0141                	addi	sp,sp,16
    800027ca:	8082                	ret

00000000800027cc <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    800027cc:	1101                	addi	sp,sp,-32
    800027ce:	ec06                	sd	ra,24(sp)
    800027d0:	e822                	sd	s0,16(sp)
    800027d2:	e426                	sd	s1,8(sp)
    800027d4:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    800027d6:	00015497          	auipc	s1,0x15
    800027da:	afa48493          	addi	s1,s1,-1286 # 800172d0 <tickslock>
    800027de:	8526                	mv	a0,s1
    800027e0:	ffffe097          	auipc	ra,0xffffe
    800027e4:	3f6080e7          	jalr	1014(ra) # 80000bd6 <acquire>
  ticks++;
    800027e8:	00007517          	auipc	a0,0x7
    800027ec:	84850513          	addi	a0,a0,-1976 # 80009030 <ticks>
    800027f0:	411c                	lw	a5,0(a0)
    800027f2:	2785                	addiw	a5,a5,1
    800027f4:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    800027f6:	00000097          	auipc	ra,0x0
    800027fa:	a42080e7          	jalr	-1470(ra) # 80002238 <wakeup>
  release(&tickslock);
    800027fe:	8526                	mv	a0,s1
    80002800:	ffffe097          	auipc	ra,0xffffe
    80002804:	48a080e7          	jalr	1162(ra) # 80000c8a <release>
}
    80002808:	60e2                	ld	ra,24(sp)
    8000280a:	6442                	ld	s0,16(sp)
    8000280c:	64a2                	ld	s1,8(sp)
    8000280e:	6105                	addi	sp,sp,32
    80002810:	8082                	ret

0000000080002812 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    80002812:	1101                	addi	sp,sp,-32
    80002814:	ec06                	sd	ra,24(sp)
    80002816:	e822                	sd	s0,16(sp)
    80002818:	e426                	sd	s1,8(sp)
    8000281a:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    8000281c:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if((scause & 0x8000000000000000L) &&
    80002820:	00074d63          	bltz	a4,8000283a <devintr+0x28>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000001L){
    80002824:	57fd                	li	a5,-1
    80002826:	17fe                	slli	a5,a5,0x3f
    80002828:	0785                	addi	a5,a5,1
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    8000282a:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    8000282c:	06f70363          	beq	a4,a5,80002892 <devintr+0x80>
  }
}
    80002830:	60e2                	ld	ra,24(sp)
    80002832:	6442                	ld	s0,16(sp)
    80002834:	64a2                	ld	s1,8(sp)
    80002836:	6105                	addi	sp,sp,32
    80002838:	8082                	ret
     (scause & 0xff) == 9){
    8000283a:	0ff77793          	andi	a5,a4,255
  if((scause & 0x8000000000000000L) &&
    8000283e:	46a5                	li	a3,9
    80002840:	fed792e3          	bne	a5,a3,80002824 <devintr+0x12>
    int irq = plic_claim();
    80002844:	00003097          	auipc	ra,0x3
    80002848:	4c4080e7          	jalr	1220(ra) # 80005d08 <plic_claim>
    8000284c:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    8000284e:	47a9                	li	a5,10
    80002850:	02f50763          	beq	a0,a5,8000287e <devintr+0x6c>
    } else if(irq == VIRTIO0_IRQ){
    80002854:	4785                	li	a5,1
    80002856:	02f50963          	beq	a0,a5,80002888 <devintr+0x76>
    return 1;
    8000285a:	4505                	li	a0,1
    } else if(irq){
    8000285c:	d8f1                	beqz	s1,80002830 <devintr+0x1e>
      printf("unexpected interrupt irq=%d\n", irq);
    8000285e:	85a6                	mv	a1,s1
    80002860:	00006517          	auipc	a0,0x6
    80002864:	a8050513          	addi	a0,a0,-1408 # 800082e0 <states.1726+0x38>
    80002868:	ffffe097          	auipc	ra,0xffffe
    8000286c:	d12080e7          	jalr	-750(ra) # 8000057a <printf>
      plic_complete(irq);
    80002870:	8526                	mv	a0,s1
    80002872:	00003097          	auipc	ra,0x3
    80002876:	4ba080e7          	jalr	1210(ra) # 80005d2c <plic_complete>
    return 1;
    8000287a:	4505                	li	a0,1
    8000287c:	bf55                	j	80002830 <devintr+0x1e>
      uartintr();
    8000287e:	ffffe097          	auipc	ra,0xffffe
    80002882:	11c080e7          	jalr	284(ra) # 8000099a <uartintr>
    80002886:	b7ed                	j	80002870 <devintr+0x5e>
      virtio_disk_intr();
    80002888:	00004097          	auipc	ra,0x4
    8000288c:	984080e7          	jalr	-1660(ra) # 8000620c <virtio_disk_intr>
    80002890:	b7c5                	j	80002870 <devintr+0x5e>
    if(cpuid() == 0){
    80002892:	fffff097          	auipc	ra,0xfffff
    80002896:	0d6080e7          	jalr	214(ra) # 80001968 <cpuid>
    8000289a:	c901                	beqz	a0,800028aa <devintr+0x98>
  asm volatile("csrr %0, sip" : "=r" (x) );
    8000289c:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    800028a0:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    800028a2:	14479073          	csrw	sip,a5
    return 2;
    800028a6:	4509                	li	a0,2
    800028a8:	b761                	j	80002830 <devintr+0x1e>
      clockintr();
    800028aa:	00000097          	auipc	ra,0x0
    800028ae:	f22080e7          	jalr	-222(ra) # 800027cc <clockintr>
    800028b2:	b7ed                	j	8000289c <devintr+0x8a>

00000000800028b4 <usertrap>:
{
    800028b4:	1101                	addi	sp,sp,-32
    800028b6:	ec06                	sd	ra,24(sp)
    800028b8:	e822                	sd	s0,16(sp)
    800028ba:	e426                	sd	s1,8(sp)
    800028bc:	e04a                	sd	s2,0(sp)
    800028be:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800028c0:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    800028c4:	1007f793          	andi	a5,a5,256
    800028c8:	e3ad                	bnez	a5,8000292a <usertrap+0x76>
  asm volatile("csrw stvec, %0" : : "r" (x));
    800028ca:	00003797          	auipc	a5,0x3
    800028ce:	33678793          	addi	a5,a5,822 # 80005c00 <kernelvec>
    800028d2:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    800028d6:	fffff097          	auipc	ra,0xfffff
    800028da:	0be080e7          	jalr	190(ra) # 80001994 <myproc>
    800028de:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    800028e0:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800028e2:	14102773          	csrr	a4,sepc
    800028e6:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    800028e8:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    800028ec:	47a1                	li	a5,8
    800028ee:	04f71c63          	bne	a4,a5,80002946 <usertrap+0x92>
    if(p->killed)
    800028f2:	551c                	lw	a5,40(a0)
    800028f4:	e3b9                	bnez	a5,8000293a <usertrap+0x86>
    p->trapframe->epc += 4;
    800028f6:	6cb8                	ld	a4,88(s1)
    800028f8:	6f1c                	ld	a5,24(a4)
    800028fa:	0791                	addi	a5,a5,4
    800028fc:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800028fe:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002902:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002906:	10079073          	csrw	sstatus,a5
    syscall();
    8000290a:	00000097          	auipc	ra,0x0
    8000290e:	2e0080e7          	jalr	736(ra) # 80002bea <syscall>
  if(p->killed)
    80002912:	549c                	lw	a5,40(s1)
    80002914:	ebc1                	bnez	a5,800029a4 <usertrap+0xf0>
  usertrapret();
    80002916:	00000097          	auipc	ra,0x0
    8000291a:	e18080e7          	jalr	-488(ra) # 8000272e <usertrapret>
}
    8000291e:	60e2                	ld	ra,24(sp)
    80002920:	6442                	ld	s0,16(sp)
    80002922:	64a2                	ld	s1,8(sp)
    80002924:	6902                	ld	s2,0(sp)
    80002926:	6105                	addi	sp,sp,32
    80002928:	8082                	ret
    panic("usertrap: not from user mode");
    8000292a:	00006517          	auipc	a0,0x6
    8000292e:	9d650513          	addi	a0,a0,-1578 # 80008300 <states.1726+0x58>
    80002932:	ffffe097          	auipc	ra,0xffffe
    80002936:	bfe080e7          	jalr	-1026(ra) # 80000530 <panic>
      exit(-1);
    8000293a:	557d                	li	a0,-1
    8000293c:	00000097          	auipc	ra,0x0
    80002940:	9cc080e7          	jalr	-1588(ra) # 80002308 <exit>
    80002944:	bf4d                	j	800028f6 <usertrap+0x42>
  } else if((which_dev = devintr()) != 0){
    80002946:	00000097          	auipc	ra,0x0
    8000294a:	ecc080e7          	jalr	-308(ra) # 80002812 <devintr>
    8000294e:	892a                	mv	s2,a0
    80002950:	c501                	beqz	a0,80002958 <usertrap+0xa4>
  if(p->killed)
    80002952:	549c                	lw	a5,40(s1)
    80002954:	c3a1                	beqz	a5,80002994 <usertrap+0xe0>
    80002956:	a815                	j	8000298a <usertrap+0xd6>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002958:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    8000295c:	5890                	lw	a2,48(s1)
    8000295e:	00006517          	auipc	a0,0x6
    80002962:	9c250513          	addi	a0,a0,-1598 # 80008320 <states.1726+0x78>
    80002966:	ffffe097          	auipc	ra,0xffffe
    8000296a:	c14080e7          	jalr	-1004(ra) # 8000057a <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    8000296e:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002972:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002976:	00006517          	auipc	a0,0x6
    8000297a:	9da50513          	addi	a0,a0,-1574 # 80008350 <states.1726+0xa8>
    8000297e:	ffffe097          	auipc	ra,0xffffe
    80002982:	bfc080e7          	jalr	-1028(ra) # 8000057a <printf>
    p->killed = 1;
    80002986:	4785                	li	a5,1
    80002988:	d49c                	sw	a5,40(s1)
    exit(-1);
    8000298a:	557d                	li	a0,-1
    8000298c:	00000097          	auipc	ra,0x0
    80002990:	97c080e7          	jalr	-1668(ra) # 80002308 <exit>
  if(which_dev == 2)
    80002994:	4789                	li	a5,2
    80002996:	f8f910e3          	bne	s2,a5,80002916 <usertrap+0x62>
    yield();
    8000299a:	fffff097          	auipc	ra,0xfffff
    8000299e:	6d6080e7          	jalr	1750(ra) # 80002070 <yield>
    800029a2:	bf95                	j	80002916 <usertrap+0x62>
  int which_dev = 0;
    800029a4:	4901                	li	s2,0
    800029a6:	b7d5                	j	8000298a <usertrap+0xd6>

00000000800029a8 <kerneltrap>:
{
    800029a8:	7179                	addi	sp,sp,-48
    800029aa:	f406                	sd	ra,40(sp)
    800029ac:	f022                	sd	s0,32(sp)
    800029ae:	ec26                	sd	s1,24(sp)
    800029b0:	e84a                	sd	s2,16(sp)
    800029b2:	e44e                	sd	s3,8(sp)
    800029b4:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800029b6:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800029ba:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    800029be:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    800029c2:	1004f793          	andi	a5,s1,256
    800029c6:	cb85                	beqz	a5,800029f6 <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800029c8:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    800029cc:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    800029ce:	ef85                	bnez	a5,80002a06 <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    800029d0:	00000097          	auipc	ra,0x0
    800029d4:	e42080e7          	jalr	-446(ra) # 80002812 <devintr>
    800029d8:	cd1d                	beqz	a0,80002a16 <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    800029da:	4789                	li	a5,2
    800029dc:	06f50a63          	beq	a0,a5,80002a50 <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    800029e0:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800029e4:	10049073          	csrw	sstatus,s1
}
    800029e8:	70a2                	ld	ra,40(sp)
    800029ea:	7402                	ld	s0,32(sp)
    800029ec:	64e2                	ld	s1,24(sp)
    800029ee:	6942                	ld	s2,16(sp)
    800029f0:	69a2                	ld	s3,8(sp)
    800029f2:	6145                	addi	sp,sp,48
    800029f4:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    800029f6:	00006517          	auipc	a0,0x6
    800029fa:	97a50513          	addi	a0,a0,-1670 # 80008370 <states.1726+0xc8>
    800029fe:	ffffe097          	auipc	ra,0xffffe
    80002a02:	b32080e7          	jalr	-1230(ra) # 80000530 <panic>
    panic("kerneltrap: interrupts enabled");
    80002a06:	00006517          	auipc	a0,0x6
    80002a0a:	99250513          	addi	a0,a0,-1646 # 80008398 <states.1726+0xf0>
    80002a0e:	ffffe097          	auipc	ra,0xffffe
    80002a12:	b22080e7          	jalr	-1246(ra) # 80000530 <panic>
    printf("scause %p\n", scause);
    80002a16:	85ce                	mv	a1,s3
    80002a18:	00006517          	auipc	a0,0x6
    80002a1c:	9a050513          	addi	a0,a0,-1632 # 800083b8 <states.1726+0x110>
    80002a20:	ffffe097          	auipc	ra,0xffffe
    80002a24:	b5a080e7          	jalr	-1190(ra) # 8000057a <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002a28:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002a2c:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002a30:	00006517          	auipc	a0,0x6
    80002a34:	99850513          	addi	a0,a0,-1640 # 800083c8 <states.1726+0x120>
    80002a38:	ffffe097          	auipc	ra,0xffffe
    80002a3c:	b42080e7          	jalr	-1214(ra) # 8000057a <printf>
    panic("kerneltrap");
    80002a40:	00006517          	auipc	a0,0x6
    80002a44:	9a050513          	addi	a0,a0,-1632 # 800083e0 <states.1726+0x138>
    80002a48:	ffffe097          	auipc	ra,0xffffe
    80002a4c:	ae8080e7          	jalr	-1304(ra) # 80000530 <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002a50:	fffff097          	auipc	ra,0xfffff
    80002a54:	f44080e7          	jalr	-188(ra) # 80001994 <myproc>
    80002a58:	d541                	beqz	a0,800029e0 <kerneltrap+0x38>
    80002a5a:	fffff097          	auipc	ra,0xfffff
    80002a5e:	f3a080e7          	jalr	-198(ra) # 80001994 <myproc>
    80002a62:	4d18                	lw	a4,24(a0)
    80002a64:	4791                	li	a5,4
    80002a66:	f6f71de3          	bne	a4,a5,800029e0 <kerneltrap+0x38>
    yield();
    80002a6a:	fffff097          	auipc	ra,0xfffff
    80002a6e:	606080e7          	jalr	1542(ra) # 80002070 <yield>
    80002a72:	b7bd                	j	800029e0 <kerneltrap+0x38>

0000000080002a74 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002a74:	1101                	addi	sp,sp,-32
    80002a76:	ec06                	sd	ra,24(sp)
    80002a78:	e822                	sd	s0,16(sp)
    80002a7a:	e426                	sd	s1,8(sp)
    80002a7c:	1000                	addi	s0,sp,32
    80002a7e:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002a80:	fffff097          	auipc	ra,0xfffff
    80002a84:	f14080e7          	jalr	-236(ra) # 80001994 <myproc>
  switch (n) {
    80002a88:	4795                	li	a5,5
    80002a8a:	0497e163          	bltu	a5,s1,80002acc <argraw+0x58>
    80002a8e:	048a                	slli	s1,s1,0x2
    80002a90:	00006717          	auipc	a4,0x6
    80002a94:	98870713          	addi	a4,a4,-1656 # 80008418 <states.1726+0x170>
    80002a98:	94ba                	add	s1,s1,a4
    80002a9a:	409c                	lw	a5,0(s1)
    80002a9c:	97ba                	add	a5,a5,a4
    80002a9e:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002aa0:	6d3c                	ld	a5,88(a0)
    80002aa2:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002aa4:	60e2                	ld	ra,24(sp)
    80002aa6:	6442                	ld	s0,16(sp)
    80002aa8:	64a2                	ld	s1,8(sp)
    80002aaa:	6105                	addi	sp,sp,32
    80002aac:	8082                	ret
    return p->trapframe->a1;
    80002aae:	6d3c                	ld	a5,88(a0)
    80002ab0:	7fa8                	ld	a0,120(a5)
    80002ab2:	bfcd                	j	80002aa4 <argraw+0x30>
    return p->trapframe->a2;
    80002ab4:	6d3c                	ld	a5,88(a0)
    80002ab6:	63c8                	ld	a0,128(a5)
    80002ab8:	b7f5                	j	80002aa4 <argraw+0x30>
    return p->trapframe->a3;
    80002aba:	6d3c                	ld	a5,88(a0)
    80002abc:	67c8                	ld	a0,136(a5)
    80002abe:	b7dd                	j	80002aa4 <argraw+0x30>
    return p->trapframe->a4;
    80002ac0:	6d3c                	ld	a5,88(a0)
    80002ac2:	6bc8                	ld	a0,144(a5)
    80002ac4:	b7c5                	j	80002aa4 <argraw+0x30>
    return p->trapframe->a5;
    80002ac6:	6d3c                	ld	a5,88(a0)
    80002ac8:	6fc8                	ld	a0,152(a5)
    80002aca:	bfe9                	j	80002aa4 <argraw+0x30>
  panic("argraw");
    80002acc:	00006517          	auipc	a0,0x6
    80002ad0:	92450513          	addi	a0,a0,-1756 # 800083f0 <states.1726+0x148>
    80002ad4:	ffffe097          	auipc	ra,0xffffe
    80002ad8:	a5c080e7          	jalr	-1444(ra) # 80000530 <panic>

0000000080002adc <fetchaddr>:
{
    80002adc:	1101                	addi	sp,sp,-32
    80002ade:	ec06                	sd	ra,24(sp)
    80002ae0:	e822                	sd	s0,16(sp)
    80002ae2:	e426                	sd	s1,8(sp)
    80002ae4:	e04a                	sd	s2,0(sp)
    80002ae6:	1000                	addi	s0,sp,32
    80002ae8:	84aa                	mv	s1,a0
    80002aea:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002aec:	fffff097          	auipc	ra,0xfffff
    80002af0:	ea8080e7          	jalr	-344(ra) # 80001994 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz)
    80002af4:	653c                	ld	a5,72(a0)
    80002af6:	02f4f863          	bgeu	s1,a5,80002b26 <fetchaddr+0x4a>
    80002afa:	00848713          	addi	a4,s1,8
    80002afe:	02e7e663          	bltu	a5,a4,80002b2a <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002b02:	46a1                	li	a3,8
    80002b04:	8626                	mv	a2,s1
    80002b06:	85ca                	mv	a1,s2
    80002b08:	6928                	ld	a0,80(a0)
    80002b0a:	fffff097          	auipc	ra,0xfffff
    80002b0e:	bd8080e7          	jalr	-1064(ra) # 800016e2 <copyin>
    80002b12:	00a03533          	snez	a0,a0
    80002b16:	40a00533          	neg	a0,a0
}
    80002b1a:	60e2                	ld	ra,24(sp)
    80002b1c:	6442                	ld	s0,16(sp)
    80002b1e:	64a2                	ld	s1,8(sp)
    80002b20:	6902                	ld	s2,0(sp)
    80002b22:	6105                	addi	sp,sp,32
    80002b24:	8082                	ret
    return -1;
    80002b26:	557d                	li	a0,-1
    80002b28:	bfcd                	j	80002b1a <fetchaddr+0x3e>
    80002b2a:	557d                	li	a0,-1
    80002b2c:	b7fd                	j	80002b1a <fetchaddr+0x3e>

0000000080002b2e <fetchstr>:
{
    80002b2e:	7179                	addi	sp,sp,-48
    80002b30:	f406                	sd	ra,40(sp)
    80002b32:	f022                	sd	s0,32(sp)
    80002b34:	ec26                	sd	s1,24(sp)
    80002b36:	e84a                	sd	s2,16(sp)
    80002b38:	e44e                	sd	s3,8(sp)
    80002b3a:	1800                	addi	s0,sp,48
    80002b3c:	892a                	mv	s2,a0
    80002b3e:	84ae                	mv	s1,a1
    80002b40:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002b42:	fffff097          	auipc	ra,0xfffff
    80002b46:	e52080e7          	jalr	-430(ra) # 80001994 <myproc>
  int err = copyinstr(p->pagetable, buf, addr, max);
    80002b4a:	86ce                	mv	a3,s3
    80002b4c:	864a                	mv	a2,s2
    80002b4e:	85a6                	mv	a1,s1
    80002b50:	6928                	ld	a0,80(a0)
    80002b52:	fffff097          	auipc	ra,0xfffff
    80002b56:	c1c080e7          	jalr	-996(ra) # 8000176e <copyinstr>
  if(err < 0)
    80002b5a:	00054763          	bltz	a0,80002b68 <fetchstr+0x3a>
  return strlen(buf);
    80002b5e:	8526                	mv	a0,s1
    80002b60:	ffffe097          	auipc	ra,0xffffe
    80002b64:	2fa080e7          	jalr	762(ra) # 80000e5a <strlen>
}
    80002b68:	70a2                	ld	ra,40(sp)
    80002b6a:	7402                	ld	s0,32(sp)
    80002b6c:	64e2                	ld	s1,24(sp)
    80002b6e:	6942                	ld	s2,16(sp)
    80002b70:	69a2                	ld	s3,8(sp)
    80002b72:	6145                	addi	sp,sp,48
    80002b74:	8082                	ret

0000000080002b76 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
    80002b76:	1101                	addi	sp,sp,-32
    80002b78:	ec06                	sd	ra,24(sp)
    80002b7a:	e822                	sd	s0,16(sp)
    80002b7c:	e426                	sd	s1,8(sp)
    80002b7e:	1000                	addi	s0,sp,32
    80002b80:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002b82:	00000097          	auipc	ra,0x0
    80002b86:	ef2080e7          	jalr	-270(ra) # 80002a74 <argraw>
    80002b8a:	c088                	sw	a0,0(s1)
  return 0;
}
    80002b8c:	4501                	li	a0,0
    80002b8e:	60e2                	ld	ra,24(sp)
    80002b90:	6442                	ld	s0,16(sp)
    80002b92:	64a2                	ld	s1,8(sp)
    80002b94:	6105                	addi	sp,sp,32
    80002b96:	8082                	ret

0000000080002b98 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
int
argaddr(int n, uint64 *ip)
{
    80002b98:	1101                	addi	sp,sp,-32
    80002b9a:	ec06                	sd	ra,24(sp)
    80002b9c:	e822                	sd	s0,16(sp)
    80002b9e:	e426                	sd	s1,8(sp)
    80002ba0:	1000                	addi	s0,sp,32
    80002ba2:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002ba4:	00000097          	auipc	ra,0x0
    80002ba8:	ed0080e7          	jalr	-304(ra) # 80002a74 <argraw>
    80002bac:	e088                	sd	a0,0(s1)
  return 0;
}
    80002bae:	4501                	li	a0,0
    80002bb0:	60e2                	ld	ra,24(sp)
    80002bb2:	6442                	ld	s0,16(sp)
    80002bb4:	64a2                	ld	s1,8(sp)
    80002bb6:	6105                	addi	sp,sp,32
    80002bb8:	8082                	ret

0000000080002bba <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002bba:	1101                	addi	sp,sp,-32
    80002bbc:	ec06                	sd	ra,24(sp)
    80002bbe:	e822                	sd	s0,16(sp)
    80002bc0:	e426                	sd	s1,8(sp)
    80002bc2:	e04a                	sd	s2,0(sp)
    80002bc4:	1000                	addi	s0,sp,32
    80002bc6:	84ae                	mv	s1,a1
    80002bc8:	8932                	mv	s2,a2
  *ip = argraw(n);
    80002bca:	00000097          	auipc	ra,0x0
    80002bce:	eaa080e7          	jalr	-342(ra) # 80002a74 <argraw>
  uint64 addr;
  if(argaddr(n, &addr) < 0)
    return -1;
  return fetchstr(addr, buf, max);
    80002bd2:	864a                	mv	a2,s2
    80002bd4:	85a6                	mv	a1,s1
    80002bd6:	00000097          	auipc	ra,0x0
    80002bda:	f58080e7          	jalr	-168(ra) # 80002b2e <fetchstr>
}
    80002bde:	60e2                	ld	ra,24(sp)
    80002be0:	6442                	ld	s0,16(sp)
    80002be2:	64a2                	ld	s1,8(sp)
    80002be4:	6902                	ld	s2,0(sp)
    80002be6:	6105                	addi	sp,sp,32
    80002be8:	8082                	ret

0000000080002bea <syscall>:
[SYS_setbkg]  sys_setbkg,
};

void
syscall(void)
{
    80002bea:	1101                	addi	sp,sp,-32
    80002bec:	ec06                	sd	ra,24(sp)
    80002bee:	e822                	sd	s0,16(sp)
    80002bf0:	e426                	sd	s1,8(sp)
    80002bf2:	e04a                	sd	s2,0(sp)
    80002bf4:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002bf6:	fffff097          	auipc	ra,0xfffff
    80002bfa:	d9e080e7          	jalr	-610(ra) # 80001994 <myproc>
    80002bfe:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002c00:	05853903          	ld	s2,88(a0)
    80002c04:	0a893783          	ld	a5,168(s2)
    80002c08:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002c0c:	37fd                	addiw	a5,a5,-1
    80002c0e:	4759                	li	a4,22
    80002c10:	00f76f63          	bltu	a4,a5,80002c2e <syscall+0x44>
    80002c14:	00369713          	slli	a4,a3,0x3
    80002c18:	00006797          	auipc	a5,0x6
    80002c1c:	81878793          	addi	a5,a5,-2024 # 80008430 <syscalls>
    80002c20:	97ba                	add	a5,a5,a4
    80002c22:	639c                	ld	a5,0(a5)
    80002c24:	c789                	beqz	a5,80002c2e <syscall+0x44>
    p->trapframe->a0 = syscalls[num]();
    80002c26:	9782                	jalr	a5
    80002c28:	06a93823          	sd	a0,112(s2)
    80002c2c:	a839                	j	80002c4a <syscall+0x60>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002c2e:	15848613          	addi	a2,s1,344
    80002c32:	588c                	lw	a1,48(s1)
    80002c34:	00005517          	auipc	a0,0x5
    80002c38:	7c450513          	addi	a0,a0,1988 # 800083f8 <states.1726+0x150>
    80002c3c:	ffffe097          	auipc	ra,0xffffe
    80002c40:	93e080e7          	jalr	-1730(ra) # 8000057a <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002c44:	6cbc                	ld	a5,88(s1)
    80002c46:	577d                	li	a4,-1
    80002c48:	fbb8                	sd	a4,112(a5)
  }
}
    80002c4a:	60e2                	ld	ra,24(sp)
    80002c4c:	6442                	ld	s0,16(sp)
    80002c4e:	64a2                	ld	s1,8(sp)
    80002c50:	6902                	ld	s2,0(sp)
    80002c52:	6105                	addi	sp,sp,32
    80002c54:	8082                	ret

0000000080002c56 <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    80002c56:	1101                	addi	sp,sp,-32
    80002c58:	ec06                	sd	ra,24(sp)
    80002c5a:	e822                	sd	s0,16(sp)
    80002c5c:	1000                	addi	s0,sp,32
  int n;
  if(argint(0, &n) < 0)
    80002c5e:	fec40593          	addi	a1,s0,-20
    80002c62:	4501                	li	a0,0
    80002c64:	00000097          	auipc	ra,0x0
    80002c68:	f12080e7          	jalr	-238(ra) # 80002b76 <argint>
    return -1;
    80002c6c:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80002c6e:	00054963          	bltz	a0,80002c80 <sys_exit+0x2a>
  exit(n);
    80002c72:	fec42503          	lw	a0,-20(s0)
    80002c76:	fffff097          	auipc	ra,0xfffff
    80002c7a:	692080e7          	jalr	1682(ra) # 80002308 <exit>
  return 0;  // not reached
    80002c7e:	4781                	li	a5,0
}
    80002c80:	853e                	mv	a0,a5
    80002c82:	60e2                	ld	ra,24(sp)
    80002c84:	6442                	ld	s0,16(sp)
    80002c86:	6105                	addi	sp,sp,32
    80002c88:	8082                	ret

0000000080002c8a <sys_getpid>:

uint64
sys_getpid(void)
{
    80002c8a:	1141                	addi	sp,sp,-16
    80002c8c:	e406                	sd	ra,8(sp)
    80002c8e:	e022                	sd	s0,0(sp)
    80002c90:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002c92:	fffff097          	auipc	ra,0xfffff
    80002c96:	d02080e7          	jalr	-766(ra) # 80001994 <myproc>
}
    80002c9a:	5908                	lw	a0,48(a0)
    80002c9c:	60a2                	ld	ra,8(sp)
    80002c9e:	6402                	ld	s0,0(sp)
    80002ca0:	0141                	addi	sp,sp,16
    80002ca2:	8082                	ret

0000000080002ca4 <sys_fork>:

uint64
sys_fork(void)
{
    80002ca4:	1141                	addi	sp,sp,-16
    80002ca6:	e406                	sd	ra,8(sp)
    80002ca8:	e022                	sd	s0,0(sp)
    80002caa:	0800                	addi	s0,sp,16
  return fork();
    80002cac:	fffff097          	auipc	ra,0xfffff
    80002cb0:	0b6080e7          	jalr	182(ra) # 80001d62 <fork>
}
    80002cb4:	60a2                	ld	ra,8(sp)
    80002cb6:	6402                	ld	s0,0(sp)
    80002cb8:	0141                	addi	sp,sp,16
    80002cba:	8082                	ret

0000000080002cbc <sys_wait>:

uint64
sys_wait(void)
{
    80002cbc:	1101                	addi	sp,sp,-32
    80002cbe:	ec06                	sd	ra,24(sp)
    80002cc0:	e822                	sd	s0,16(sp)
    80002cc2:	1000                	addi	s0,sp,32
  uint64 p;
  if(argaddr(0, &p) < 0)
    80002cc4:	fe840593          	addi	a1,s0,-24
    80002cc8:	4501                	li	a0,0
    80002cca:	00000097          	auipc	ra,0x0
    80002cce:	ece080e7          	jalr	-306(ra) # 80002b98 <argaddr>
    80002cd2:	87aa                	mv	a5,a0
    return -1;
    80002cd4:	557d                	li	a0,-1
  if(argaddr(0, &p) < 0)
    80002cd6:	0007c863          	bltz	a5,80002ce6 <sys_wait+0x2a>
  return wait(p);
    80002cda:	fe843503          	ld	a0,-24(s0)
    80002cde:	fffff097          	auipc	ra,0xfffff
    80002ce2:	432080e7          	jalr	1074(ra) # 80002110 <wait>
}
    80002ce6:	60e2                	ld	ra,24(sp)
    80002ce8:	6442                	ld	s0,16(sp)
    80002cea:	6105                	addi	sp,sp,32
    80002cec:	8082                	ret

0000000080002cee <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002cee:	7179                	addi	sp,sp,-48
    80002cf0:	f406                	sd	ra,40(sp)
    80002cf2:	f022                	sd	s0,32(sp)
    80002cf4:	ec26                	sd	s1,24(sp)
    80002cf6:	1800                	addi	s0,sp,48
  int addr;
  int n;

  if(argint(0, &n) < 0)
    80002cf8:	fdc40593          	addi	a1,s0,-36
    80002cfc:	4501                	li	a0,0
    80002cfe:	00000097          	auipc	ra,0x0
    80002d02:	e78080e7          	jalr	-392(ra) # 80002b76 <argint>
    80002d06:	87aa                	mv	a5,a0
    return -1;
    80002d08:	557d                	li	a0,-1
  if(argint(0, &n) < 0)
    80002d0a:	0207c063          	bltz	a5,80002d2a <sys_sbrk+0x3c>
  addr = myproc()->sz;
    80002d0e:	fffff097          	auipc	ra,0xfffff
    80002d12:	c86080e7          	jalr	-890(ra) # 80001994 <myproc>
    80002d16:	4524                	lw	s1,72(a0)
  if(growproc(n) < 0)
    80002d18:	fdc42503          	lw	a0,-36(s0)
    80002d1c:	fffff097          	auipc	ra,0xfffff
    80002d20:	fd2080e7          	jalr	-46(ra) # 80001cee <growproc>
    80002d24:	00054863          	bltz	a0,80002d34 <sys_sbrk+0x46>
    return -1;
  return addr;
    80002d28:	8526                	mv	a0,s1
}
    80002d2a:	70a2                	ld	ra,40(sp)
    80002d2c:	7402                	ld	s0,32(sp)
    80002d2e:	64e2                	ld	s1,24(sp)
    80002d30:	6145                	addi	sp,sp,48
    80002d32:	8082                	ret
    return -1;
    80002d34:	557d                	li	a0,-1
    80002d36:	bfd5                	j	80002d2a <sys_sbrk+0x3c>

0000000080002d38 <sys_sleep>:

uint64
sys_sleep(void)
{
    80002d38:	7139                	addi	sp,sp,-64
    80002d3a:	fc06                	sd	ra,56(sp)
    80002d3c:	f822                	sd	s0,48(sp)
    80002d3e:	f426                	sd	s1,40(sp)
    80002d40:	f04a                	sd	s2,32(sp)
    80002d42:	ec4e                	sd	s3,24(sp)
    80002d44:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
    80002d46:	fcc40593          	addi	a1,s0,-52
    80002d4a:	4501                	li	a0,0
    80002d4c:	00000097          	auipc	ra,0x0
    80002d50:	e2a080e7          	jalr	-470(ra) # 80002b76 <argint>
    return -1;
    80002d54:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80002d56:	06054563          	bltz	a0,80002dc0 <sys_sleep+0x88>
  acquire(&tickslock);
    80002d5a:	00014517          	auipc	a0,0x14
    80002d5e:	57650513          	addi	a0,a0,1398 # 800172d0 <tickslock>
    80002d62:	ffffe097          	auipc	ra,0xffffe
    80002d66:	e74080e7          	jalr	-396(ra) # 80000bd6 <acquire>
  ticks0 = ticks;
    80002d6a:	00006917          	auipc	s2,0x6
    80002d6e:	2c692903          	lw	s2,710(s2) # 80009030 <ticks>
  while(ticks - ticks0 < n){
    80002d72:	fcc42783          	lw	a5,-52(s0)
    80002d76:	cf85                	beqz	a5,80002dae <sys_sleep+0x76>
    if(myproc()->killed){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002d78:	00014997          	auipc	s3,0x14
    80002d7c:	55898993          	addi	s3,s3,1368 # 800172d0 <tickslock>
    80002d80:	00006497          	auipc	s1,0x6
    80002d84:	2b048493          	addi	s1,s1,688 # 80009030 <ticks>
    if(myproc()->killed){
    80002d88:	fffff097          	auipc	ra,0xfffff
    80002d8c:	c0c080e7          	jalr	-1012(ra) # 80001994 <myproc>
    80002d90:	551c                	lw	a5,40(a0)
    80002d92:	ef9d                	bnez	a5,80002dd0 <sys_sleep+0x98>
    sleep(&ticks, &tickslock);
    80002d94:	85ce                	mv	a1,s3
    80002d96:	8526                	mv	a0,s1
    80002d98:	fffff097          	auipc	ra,0xfffff
    80002d9c:	314080e7          	jalr	788(ra) # 800020ac <sleep>
  while(ticks - ticks0 < n){
    80002da0:	409c                	lw	a5,0(s1)
    80002da2:	412787bb          	subw	a5,a5,s2
    80002da6:	fcc42703          	lw	a4,-52(s0)
    80002daa:	fce7efe3          	bltu	a5,a4,80002d88 <sys_sleep+0x50>
  }
  release(&tickslock);
    80002dae:	00014517          	auipc	a0,0x14
    80002db2:	52250513          	addi	a0,a0,1314 # 800172d0 <tickslock>
    80002db6:	ffffe097          	auipc	ra,0xffffe
    80002dba:	ed4080e7          	jalr	-300(ra) # 80000c8a <release>
  return 0;
    80002dbe:	4781                	li	a5,0
}
    80002dc0:	853e                	mv	a0,a5
    80002dc2:	70e2                	ld	ra,56(sp)
    80002dc4:	7442                	ld	s0,48(sp)
    80002dc6:	74a2                	ld	s1,40(sp)
    80002dc8:	7902                	ld	s2,32(sp)
    80002dca:	69e2                	ld	s3,24(sp)
    80002dcc:	6121                	addi	sp,sp,64
    80002dce:	8082                	ret
      release(&tickslock);
    80002dd0:	00014517          	auipc	a0,0x14
    80002dd4:	50050513          	addi	a0,a0,1280 # 800172d0 <tickslock>
    80002dd8:	ffffe097          	auipc	ra,0xffffe
    80002ddc:	eb2080e7          	jalr	-334(ra) # 80000c8a <release>
      return -1;
    80002de0:	57fd                	li	a5,-1
    80002de2:	bff9                	j	80002dc0 <sys_sleep+0x88>

0000000080002de4 <sys_kill>:

uint64
sys_kill(void)
{
    80002de4:	1101                	addi	sp,sp,-32
    80002de6:	ec06                	sd	ra,24(sp)
    80002de8:	e822                	sd	s0,16(sp)
    80002dea:	1000                	addi	s0,sp,32
  int pid;

  if(argint(0, &pid) < 0)
    80002dec:	fec40593          	addi	a1,s0,-20
    80002df0:	4501                	li	a0,0
    80002df2:	00000097          	auipc	ra,0x0
    80002df6:	d84080e7          	jalr	-636(ra) # 80002b76 <argint>
    80002dfa:	87aa                	mv	a5,a0
    return -1;
    80002dfc:	557d                	li	a0,-1
  if(argint(0, &pid) < 0)
    80002dfe:	0007c863          	bltz	a5,80002e0e <sys_kill+0x2a>
  return kill(pid);
    80002e02:	fec42503          	lw	a0,-20(s0)
    80002e06:	fffff097          	auipc	ra,0xfffff
    80002e0a:	5d8080e7          	jalr	1496(ra) # 800023de <kill>
}
    80002e0e:	60e2                	ld	ra,24(sp)
    80002e10:	6442                	ld	s0,16(sp)
    80002e12:	6105                	addi	sp,sp,32
    80002e14:	8082                	ret

0000000080002e16 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002e16:	1101                	addi	sp,sp,-32
    80002e18:	ec06                	sd	ra,24(sp)
    80002e1a:	e822                	sd	s0,16(sp)
    80002e1c:	e426                	sd	s1,8(sp)
    80002e1e:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002e20:	00014517          	auipc	a0,0x14
    80002e24:	4b050513          	addi	a0,a0,1200 # 800172d0 <tickslock>
    80002e28:	ffffe097          	auipc	ra,0xffffe
    80002e2c:	dae080e7          	jalr	-594(ra) # 80000bd6 <acquire>
  xticks = ticks;
    80002e30:	00006497          	auipc	s1,0x6
    80002e34:	2004a483          	lw	s1,512(s1) # 80009030 <ticks>
  release(&tickslock);
    80002e38:	00014517          	auipc	a0,0x14
    80002e3c:	49850513          	addi	a0,a0,1176 # 800172d0 <tickslock>
    80002e40:	ffffe097          	auipc	ra,0xffffe
    80002e44:	e4a080e7          	jalr	-438(ra) # 80000c8a <release>
  return xticks;
}
    80002e48:	02049513          	slli	a0,s1,0x20
    80002e4c:	9101                	srli	a0,a0,0x20
    80002e4e:	60e2                	ld	ra,24(sp)
    80002e50:	6442                	ld	s0,16(sp)
    80002e52:	64a2                	ld	s1,8(sp)
    80002e54:	6105                	addi	sp,sp,32
    80002e56:	8082                	ret

0000000080002e58 <sys_ps>:

uint64
sys_ps(void) {
    80002e58:	1101                	addi	sp,sp,-32
    80002e5a:	ec06                	sd	ra,24(sp)
    80002e5c:	e822                	sd	s0,16(sp)
    80002e5e:	1000                	addi	s0,sp,32
  uint64 p;
  if (argaddr(0, &p) < 0)
    80002e60:	fe840593          	addi	a1,s0,-24
    80002e64:	4501                	li	a0,0
    80002e66:	00000097          	auipc	ra,0x0
    80002e6a:	d32080e7          	jalr	-718(ra) # 80002b98 <argaddr>
    80002e6e:	87aa                	mv	a5,a0
    return -1;
    80002e70:	557d                	li	a0,-1
  if (argaddr(0, &p) < 0)
    80002e72:	0007c863          	bltz	a5,80002e82 <sys_ps+0x2a>
  return ps((struct ps_proc*)p);
    80002e76:	fe843503          	ld	a0,-24(s0)
    80002e7a:	fffff097          	auipc	ra,0xfffff
    80002e7e:	730080e7          	jalr	1840(ra) # 800025aa <ps>
}
    80002e82:	60e2                	ld	ra,24(sp)
    80002e84:	6442                	ld	s0,16(sp)
    80002e86:	6105                	addi	sp,sp,32
    80002e88:	8082                	ret

0000000080002e8a <sys_setbkg>:

uint64
sys_setbkg(void)
{
    80002e8a:	1141                	addi	sp,sp,-16
    80002e8c:	e406                	sd	ra,8(sp)
    80002e8e:	e022                	sd	s0,0(sp)
    80002e90:	0800                	addi	s0,sp,16
  struct proc* p = myproc();
    80002e92:	fffff097          	auipc	ra,0xfffff
    80002e96:	b02080e7          	jalr	-1278(ra) # 80001994 <myproc>
  p->priority = 3;
    80002e9a:	478d                	li	a5,3
    80002e9c:	16f52423          	sw	a5,360(a0)
  yield();
    80002ea0:	fffff097          	auipc	ra,0xfffff
    80002ea4:	1d0080e7          	jalr	464(ra) # 80002070 <yield>
  return 0;
    80002ea8:	4501                	li	a0,0
    80002eaa:	60a2                	ld	ra,8(sp)
    80002eac:	6402                	ld	s0,0(sp)
    80002eae:	0141                	addi	sp,sp,16
    80002eb0:	8082                	ret

0000000080002eb2 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002eb2:	7179                	addi	sp,sp,-48
    80002eb4:	f406                	sd	ra,40(sp)
    80002eb6:	f022                	sd	s0,32(sp)
    80002eb8:	ec26                	sd	s1,24(sp)
    80002eba:	e84a                	sd	s2,16(sp)
    80002ebc:	e44e                	sd	s3,8(sp)
    80002ebe:	e052                	sd	s4,0(sp)
    80002ec0:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80002ec2:	00005597          	auipc	a1,0x5
    80002ec6:	62e58593          	addi	a1,a1,1582 # 800084f0 <syscalls+0xc0>
    80002eca:	00014517          	auipc	a0,0x14
    80002ece:	41e50513          	addi	a0,a0,1054 # 800172e8 <bcache>
    80002ed2:	ffffe097          	auipc	ra,0xffffe
    80002ed6:	c74080e7          	jalr	-908(ra) # 80000b46 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80002eda:	0001c797          	auipc	a5,0x1c
    80002ede:	40e78793          	addi	a5,a5,1038 # 8001f2e8 <bcache+0x8000>
    80002ee2:	0001c717          	auipc	a4,0x1c
    80002ee6:	66e70713          	addi	a4,a4,1646 # 8001f550 <bcache+0x8268>
    80002eea:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80002eee:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002ef2:	00014497          	auipc	s1,0x14
    80002ef6:	40e48493          	addi	s1,s1,1038 # 80017300 <bcache+0x18>
    b->next = bcache.head.next;
    80002efa:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80002efc:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80002efe:	00005a17          	auipc	s4,0x5
    80002f02:	5faa0a13          	addi	s4,s4,1530 # 800084f8 <syscalls+0xc8>
    b->next = bcache.head.next;
    80002f06:	2b893783          	ld	a5,696(s2)
    80002f0a:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80002f0c:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80002f10:	85d2                	mv	a1,s4
    80002f12:	01048513          	addi	a0,s1,16
    80002f16:	00001097          	auipc	ra,0x1
    80002f1a:	4bc080e7          	jalr	1212(ra) # 800043d2 <initsleeplock>
    bcache.head.next->prev = b;
    80002f1e:	2b893783          	ld	a5,696(s2)
    80002f22:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80002f24:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002f28:	45848493          	addi	s1,s1,1112
    80002f2c:	fd349de3          	bne	s1,s3,80002f06 <binit+0x54>
  }
}
    80002f30:	70a2                	ld	ra,40(sp)
    80002f32:	7402                	ld	s0,32(sp)
    80002f34:	64e2                	ld	s1,24(sp)
    80002f36:	6942                	ld	s2,16(sp)
    80002f38:	69a2                	ld	s3,8(sp)
    80002f3a:	6a02                	ld	s4,0(sp)
    80002f3c:	6145                	addi	sp,sp,48
    80002f3e:	8082                	ret

0000000080002f40 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80002f40:	7179                	addi	sp,sp,-48
    80002f42:	f406                	sd	ra,40(sp)
    80002f44:	f022                	sd	s0,32(sp)
    80002f46:	ec26                	sd	s1,24(sp)
    80002f48:	e84a                	sd	s2,16(sp)
    80002f4a:	e44e                	sd	s3,8(sp)
    80002f4c:	1800                	addi	s0,sp,48
    80002f4e:	89aa                	mv	s3,a0
    80002f50:	892e                	mv	s2,a1
  acquire(&bcache.lock);
    80002f52:	00014517          	auipc	a0,0x14
    80002f56:	39650513          	addi	a0,a0,918 # 800172e8 <bcache>
    80002f5a:	ffffe097          	auipc	ra,0xffffe
    80002f5e:	c7c080e7          	jalr	-900(ra) # 80000bd6 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80002f62:	0001c497          	auipc	s1,0x1c
    80002f66:	63e4b483          	ld	s1,1598(s1) # 8001f5a0 <bcache+0x82b8>
    80002f6a:	0001c797          	auipc	a5,0x1c
    80002f6e:	5e678793          	addi	a5,a5,1510 # 8001f550 <bcache+0x8268>
    80002f72:	02f48f63          	beq	s1,a5,80002fb0 <bread+0x70>
    80002f76:	873e                	mv	a4,a5
    80002f78:	a021                	j	80002f80 <bread+0x40>
    80002f7a:	68a4                	ld	s1,80(s1)
    80002f7c:	02e48a63          	beq	s1,a4,80002fb0 <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    80002f80:	449c                	lw	a5,8(s1)
    80002f82:	ff379ce3          	bne	a5,s3,80002f7a <bread+0x3a>
    80002f86:	44dc                	lw	a5,12(s1)
    80002f88:	ff2799e3          	bne	a5,s2,80002f7a <bread+0x3a>
      b->refcnt++;
    80002f8c:	40bc                	lw	a5,64(s1)
    80002f8e:	2785                	addiw	a5,a5,1
    80002f90:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002f92:	00014517          	auipc	a0,0x14
    80002f96:	35650513          	addi	a0,a0,854 # 800172e8 <bcache>
    80002f9a:	ffffe097          	auipc	ra,0xffffe
    80002f9e:	cf0080e7          	jalr	-784(ra) # 80000c8a <release>
      acquiresleep(&b->lock);
    80002fa2:	01048513          	addi	a0,s1,16
    80002fa6:	00001097          	auipc	ra,0x1
    80002faa:	466080e7          	jalr	1126(ra) # 8000440c <acquiresleep>
      return b;
    80002fae:	a8b9                	j	8000300c <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002fb0:	0001c497          	auipc	s1,0x1c
    80002fb4:	5e84b483          	ld	s1,1512(s1) # 8001f598 <bcache+0x82b0>
    80002fb8:	0001c797          	auipc	a5,0x1c
    80002fbc:	59878793          	addi	a5,a5,1432 # 8001f550 <bcache+0x8268>
    80002fc0:	00f48863          	beq	s1,a5,80002fd0 <bread+0x90>
    80002fc4:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80002fc6:	40bc                	lw	a5,64(s1)
    80002fc8:	cf81                	beqz	a5,80002fe0 <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002fca:	64a4                	ld	s1,72(s1)
    80002fcc:	fee49de3          	bne	s1,a4,80002fc6 <bread+0x86>
  panic("bget: no buffers");
    80002fd0:	00005517          	auipc	a0,0x5
    80002fd4:	53050513          	addi	a0,a0,1328 # 80008500 <syscalls+0xd0>
    80002fd8:	ffffd097          	auipc	ra,0xffffd
    80002fdc:	558080e7          	jalr	1368(ra) # 80000530 <panic>
      b->dev = dev;
    80002fe0:	0134a423          	sw	s3,8(s1)
      b->blockno = blockno;
    80002fe4:	0124a623          	sw	s2,12(s1)
      b->valid = 0;
    80002fe8:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80002fec:	4785                	li	a5,1
    80002fee:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002ff0:	00014517          	auipc	a0,0x14
    80002ff4:	2f850513          	addi	a0,a0,760 # 800172e8 <bcache>
    80002ff8:	ffffe097          	auipc	ra,0xffffe
    80002ffc:	c92080e7          	jalr	-878(ra) # 80000c8a <release>
      acquiresleep(&b->lock);
    80003000:	01048513          	addi	a0,s1,16
    80003004:	00001097          	auipc	ra,0x1
    80003008:	408080e7          	jalr	1032(ra) # 8000440c <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    8000300c:	409c                	lw	a5,0(s1)
    8000300e:	cb89                	beqz	a5,80003020 <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80003010:	8526                	mv	a0,s1
    80003012:	70a2                	ld	ra,40(sp)
    80003014:	7402                	ld	s0,32(sp)
    80003016:	64e2                	ld	s1,24(sp)
    80003018:	6942                	ld	s2,16(sp)
    8000301a:	69a2                	ld	s3,8(sp)
    8000301c:	6145                	addi	sp,sp,48
    8000301e:	8082                	ret
    virtio_disk_rw(b, 0);
    80003020:	4581                	li	a1,0
    80003022:	8526                	mv	a0,s1
    80003024:	00003097          	auipc	ra,0x3
    80003028:	f12080e7          	jalr	-238(ra) # 80005f36 <virtio_disk_rw>
    b->valid = 1;
    8000302c:	4785                	li	a5,1
    8000302e:	c09c                	sw	a5,0(s1)
  return b;
    80003030:	b7c5                	j	80003010 <bread+0xd0>

0000000080003032 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80003032:	1101                	addi	sp,sp,-32
    80003034:	ec06                	sd	ra,24(sp)
    80003036:	e822                	sd	s0,16(sp)
    80003038:	e426                	sd	s1,8(sp)
    8000303a:	1000                	addi	s0,sp,32
    8000303c:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    8000303e:	0541                	addi	a0,a0,16
    80003040:	00001097          	auipc	ra,0x1
    80003044:	466080e7          	jalr	1126(ra) # 800044a6 <holdingsleep>
    80003048:	cd01                	beqz	a0,80003060 <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    8000304a:	4585                	li	a1,1
    8000304c:	8526                	mv	a0,s1
    8000304e:	00003097          	auipc	ra,0x3
    80003052:	ee8080e7          	jalr	-280(ra) # 80005f36 <virtio_disk_rw>
}
    80003056:	60e2                	ld	ra,24(sp)
    80003058:	6442                	ld	s0,16(sp)
    8000305a:	64a2                	ld	s1,8(sp)
    8000305c:	6105                	addi	sp,sp,32
    8000305e:	8082                	ret
    panic("bwrite");
    80003060:	00005517          	auipc	a0,0x5
    80003064:	4b850513          	addi	a0,a0,1208 # 80008518 <syscalls+0xe8>
    80003068:	ffffd097          	auipc	ra,0xffffd
    8000306c:	4c8080e7          	jalr	1224(ra) # 80000530 <panic>

0000000080003070 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80003070:	1101                	addi	sp,sp,-32
    80003072:	ec06                	sd	ra,24(sp)
    80003074:	e822                	sd	s0,16(sp)
    80003076:	e426                	sd	s1,8(sp)
    80003078:	e04a                	sd	s2,0(sp)
    8000307a:	1000                	addi	s0,sp,32
    8000307c:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    8000307e:	01050913          	addi	s2,a0,16
    80003082:	854a                	mv	a0,s2
    80003084:	00001097          	auipc	ra,0x1
    80003088:	422080e7          	jalr	1058(ra) # 800044a6 <holdingsleep>
    8000308c:	c92d                	beqz	a0,800030fe <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    8000308e:	854a                	mv	a0,s2
    80003090:	00001097          	auipc	ra,0x1
    80003094:	3d2080e7          	jalr	978(ra) # 80004462 <releasesleep>

  acquire(&bcache.lock);
    80003098:	00014517          	auipc	a0,0x14
    8000309c:	25050513          	addi	a0,a0,592 # 800172e8 <bcache>
    800030a0:	ffffe097          	auipc	ra,0xffffe
    800030a4:	b36080e7          	jalr	-1226(ra) # 80000bd6 <acquire>
  b->refcnt--;
    800030a8:	40bc                	lw	a5,64(s1)
    800030aa:	37fd                	addiw	a5,a5,-1
    800030ac:	0007871b          	sext.w	a4,a5
    800030b0:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    800030b2:	eb05                	bnez	a4,800030e2 <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    800030b4:	68bc                	ld	a5,80(s1)
    800030b6:	64b8                	ld	a4,72(s1)
    800030b8:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    800030ba:	64bc                	ld	a5,72(s1)
    800030bc:	68b8                	ld	a4,80(s1)
    800030be:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    800030c0:	0001c797          	auipc	a5,0x1c
    800030c4:	22878793          	addi	a5,a5,552 # 8001f2e8 <bcache+0x8000>
    800030c8:	2b87b703          	ld	a4,696(a5)
    800030cc:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    800030ce:	0001c717          	auipc	a4,0x1c
    800030d2:	48270713          	addi	a4,a4,1154 # 8001f550 <bcache+0x8268>
    800030d6:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    800030d8:	2b87b703          	ld	a4,696(a5)
    800030dc:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    800030de:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    800030e2:	00014517          	auipc	a0,0x14
    800030e6:	20650513          	addi	a0,a0,518 # 800172e8 <bcache>
    800030ea:	ffffe097          	auipc	ra,0xffffe
    800030ee:	ba0080e7          	jalr	-1120(ra) # 80000c8a <release>
}
    800030f2:	60e2                	ld	ra,24(sp)
    800030f4:	6442                	ld	s0,16(sp)
    800030f6:	64a2                	ld	s1,8(sp)
    800030f8:	6902                	ld	s2,0(sp)
    800030fa:	6105                	addi	sp,sp,32
    800030fc:	8082                	ret
    panic("brelse");
    800030fe:	00005517          	auipc	a0,0x5
    80003102:	42250513          	addi	a0,a0,1058 # 80008520 <syscalls+0xf0>
    80003106:	ffffd097          	auipc	ra,0xffffd
    8000310a:	42a080e7          	jalr	1066(ra) # 80000530 <panic>

000000008000310e <bpin>:

void
bpin(struct buf *b) {
    8000310e:	1101                	addi	sp,sp,-32
    80003110:	ec06                	sd	ra,24(sp)
    80003112:	e822                	sd	s0,16(sp)
    80003114:	e426                	sd	s1,8(sp)
    80003116:	1000                	addi	s0,sp,32
    80003118:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    8000311a:	00014517          	auipc	a0,0x14
    8000311e:	1ce50513          	addi	a0,a0,462 # 800172e8 <bcache>
    80003122:	ffffe097          	auipc	ra,0xffffe
    80003126:	ab4080e7          	jalr	-1356(ra) # 80000bd6 <acquire>
  b->refcnt++;
    8000312a:	40bc                	lw	a5,64(s1)
    8000312c:	2785                	addiw	a5,a5,1
    8000312e:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003130:	00014517          	auipc	a0,0x14
    80003134:	1b850513          	addi	a0,a0,440 # 800172e8 <bcache>
    80003138:	ffffe097          	auipc	ra,0xffffe
    8000313c:	b52080e7          	jalr	-1198(ra) # 80000c8a <release>
}
    80003140:	60e2                	ld	ra,24(sp)
    80003142:	6442                	ld	s0,16(sp)
    80003144:	64a2                	ld	s1,8(sp)
    80003146:	6105                	addi	sp,sp,32
    80003148:	8082                	ret

000000008000314a <bunpin>:

void
bunpin(struct buf *b) {
    8000314a:	1101                	addi	sp,sp,-32
    8000314c:	ec06                	sd	ra,24(sp)
    8000314e:	e822                	sd	s0,16(sp)
    80003150:	e426                	sd	s1,8(sp)
    80003152:	1000                	addi	s0,sp,32
    80003154:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003156:	00014517          	auipc	a0,0x14
    8000315a:	19250513          	addi	a0,a0,402 # 800172e8 <bcache>
    8000315e:	ffffe097          	auipc	ra,0xffffe
    80003162:	a78080e7          	jalr	-1416(ra) # 80000bd6 <acquire>
  b->refcnt--;
    80003166:	40bc                	lw	a5,64(s1)
    80003168:	37fd                	addiw	a5,a5,-1
    8000316a:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    8000316c:	00014517          	auipc	a0,0x14
    80003170:	17c50513          	addi	a0,a0,380 # 800172e8 <bcache>
    80003174:	ffffe097          	auipc	ra,0xffffe
    80003178:	b16080e7          	jalr	-1258(ra) # 80000c8a <release>
}
    8000317c:	60e2                	ld	ra,24(sp)
    8000317e:	6442                	ld	s0,16(sp)
    80003180:	64a2                	ld	s1,8(sp)
    80003182:	6105                	addi	sp,sp,32
    80003184:	8082                	ret

0000000080003186 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80003186:	1101                	addi	sp,sp,-32
    80003188:	ec06                	sd	ra,24(sp)
    8000318a:	e822                	sd	s0,16(sp)
    8000318c:	e426                	sd	s1,8(sp)
    8000318e:	e04a                	sd	s2,0(sp)
    80003190:	1000                	addi	s0,sp,32
    80003192:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80003194:	00d5d59b          	srliw	a1,a1,0xd
    80003198:	0001d797          	auipc	a5,0x1d
    8000319c:	82c7a783          	lw	a5,-2004(a5) # 8001f9c4 <sb+0x1c>
    800031a0:	9dbd                	addw	a1,a1,a5
    800031a2:	00000097          	auipc	ra,0x0
    800031a6:	d9e080e7          	jalr	-610(ra) # 80002f40 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    800031aa:	0074f713          	andi	a4,s1,7
    800031ae:	4785                	li	a5,1
    800031b0:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    800031b4:	14ce                	slli	s1,s1,0x33
    800031b6:	90d9                	srli	s1,s1,0x36
    800031b8:	00950733          	add	a4,a0,s1
    800031bc:	05874703          	lbu	a4,88(a4)
    800031c0:	00e7f6b3          	and	a3,a5,a4
    800031c4:	c69d                	beqz	a3,800031f2 <bfree+0x6c>
    800031c6:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    800031c8:	94aa                	add	s1,s1,a0
    800031ca:	fff7c793          	not	a5,a5
    800031ce:	8ff9                	and	a5,a5,a4
    800031d0:	04f48c23          	sb	a5,88(s1)
  log_write(bp);
    800031d4:	00001097          	auipc	ra,0x1
    800031d8:	118080e7          	jalr	280(ra) # 800042ec <log_write>
  brelse(bp);
    800031dc:	854a                	mv	a0,s2
    800031de:	00000097          	auipc	ra,0x0
    800031e2:	e92080e7          	jalr	-366(ra) # 80003070 <brelse>
}
    800031e6:	60e2                	ld	ra,24(sp)
    800031e8:	6442                	ld	s0,16(sp)
    800031ea:	64a2                	ld	s1,8(sp)
    800031ec:	6902                	ld	s2,0(sp)
    800031ee:	6105                	addi	sp,sp,32
    800031f0:	8082                	ret
    panic("freeing free block");
    800031f2:	00005517          	auipc	a0,0x5
    800031f6:	33650513          	addi	a0,a0,822 # 80008528 <syscalls+0xf8>
    800031fa:	ffffd097          	auipc	ra,0xffffd
    800031fe:	336080e7          	jalr	822(ra) # 80000530 <panic>

0000000080003202 <balloc>:
{
    80003202:	711d                	addi	sp,sp,-96
    80003204:	ec86                	sd	ra,88(sp)
    80003206:	e8a2                	sd	s0,80(sp)
    80003208:	e4a6                	sd	s1,72(sp)
    8000320a:	e0ca                	sd	s2,64(sp)
    8000320c:	fc4e                	sd	s3,56(sp)
    8000320e:	f852                	sd	s4,48(sp)
    80003210:	f456                	sd	s5,40(sp)
    80003212:	f05a                	sd	s6,32(sp)
    80003214:	ec5e                	sd	s7,24(sp)
    80003216:	e862                	sd	s8,16(sp)
    80003218:	e466                	sd	s9,8(sp)
    8000321a:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    8000321c:	0001c797          	auipc	a5,0x1c
    80003220:	7907a783          	lw	a5,1936(a5) # 8001f9ac <sb+0x4>
    80003224:	cbd1                	beqz	a5,800032b8 <balloc+0xb6>
    80003226:	8baa                	mv	s7,a0
    80003228:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    8000322a:	0001cb17          	auipc	s6,0x1c
    8000322e:	77eb0b13          	addi	s6,s6,1918 # 8001f9a8 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003232:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    80003234:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003236:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80003238:	6c89                	lui	s9,0x2
    8000323a:	a831                	j	80003256 <balloc+0x54>
    brelse(bp);
    8000323c:	854a                	mv	a0,s2
    8000323e:	00000097          	auipc	ra,0x0
    80003242:	e32080e7          	jalr	-462(ra) # 80003070 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80003246:	015c87bb          	addw	a5,s9,s5
    8000324a:	00078a9b          	sext.w	s5,a5
    8000324e:	004b2703          	lw	a4,4(s6)
    80003252:	06eaf363          	bgeu	s5,a4,800032b8 <balloc+0xb6>
    bp = bread(dev, BBLOCK(b, sb));
    80003256:	41fad79b          	sraiw	a5,s5,0x1f
    8000325a:	0137d79b          	srliw	a5,a5,0x13
    8000325e:	015787bb          	addw	a5,a5,s5
    80003262:	40d7d79b          	sraiw	a5,a5,0xd
    80003266:	01cb2583          	lw	a1,28(s6)
    8000326a:	9dbd                	addw	a1,a1,a5
    8000326c:	855e                	mv	a0,s7
    8000326e:	00000097          	auipc	ra,0x0
    80003272:	cd2080e7          	jalr	-814(ra) # 80002f40 <bread>
    80003276:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003278:	004b2503          	lw	a0,4(s6)
    8000327c:	000a849b          	sext.w	s1,s5
    80003280:	8662                	mv	a2,s8
    80003282:	faa4fde3          	bgeu	s1,a0,8000323c <balloc+0x3a>
      m = 1 << (bi % 8);
    80003286:	41f6579b          	sraiw	a5,a2,0x1f
    8000328a:	01d7d69b          	srliw	a3,a5,0x1d
    8000328e:	00c6873b          	addw	a4,a3,a2
    80003292:	00777793          	andi	a5,a4,7
    80003296:	9f95                	subw	a5,a5,a3
    80003298:	00f997bb          	sllw	a5,s3,a5
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    8000329c:	4037571b          	sraiw	a4,a4,0x3
    800032a0:	00e906b3          	add	a3,s2,a4
    800032a4:	0586c683          	lbu	a3,88(a3)
    800032a8:	00d7f5b3          	and	a1,a5,a3
    800032ac:	cd91                	beqz	a1,800032c8 <balloc+0xc6>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800032ae:	2605                	addiw	a2,a2,1
    800032b0:	2485                	addiw	s1,s1,1
    800032b2:	fd4618e3          	bne	a2,s4,80003282 <balloc+0x80>
    800032b6:	b759                	j	8000323c <balloc+0x3a>
  panic("balloc: out of blocks");
    800032b8:	00005517          	auipc	a0,0x5
    800032bc:	28850513          	addi	a0,a0,648 # 80008540 <syscalls+0x110>
    800032c0:	ffffd097          	auipc	ra,0xffffd
    800032c4:	270080e7          	jalr	624(ra) # 80000530 <panic>
        bp->data[bi/8] |= m;  // Mark block in use.
    800032c8:	974a                	add	a4,a4,s2
    800032ca:	8fd5                	or	a5,a5,a3
    800032cc:	04f70c23          	sb	a5,88(a4)
        log_write(bp);
    800032d0:	854a                	mv	a0,s2
    800032d2:	00001097          	auipc	ra,0x1
    800032d6:	01a080e7          	jalr	26(ra) # 800042ec <log_write>
        brelse(bp);
    800032da:	854a                	mv	a0,s2
    800032dc:	00000097          	auipc	ra,0x0
    800032e0:	d94080e7          	jalr	-620(ra) # 80003070 <brelse>
  bp = bread(dev, bno);
    800032e4:	85a6                	mv	a1,s1
    800032e6:	855e                	mv	a0,s7
    800032e8:	00000097          	auipc	ra,0x0
    800032ec:	c58080e7          	jalr	-936(ra) # 80002f40 <bread>
    800032f0:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    800032f2:	40000613          	li	a2,1024
    800032f6:	4581                	li	a1,0
    800032f8:	05850513          	addi	a0,a0,88
    800032fc:	ffffe097          	auipc	ra,0xffffe
    80003300:	9d6080e7          	jalr	-1578(ra) # 80000cd2 <memset>
  log_write(bp);
    80003304:	854a                	mv	a0,s2
    80003306:	00001097          	auipc	ra,0x1
    8000330a:	fe6080e7          	jalr	-26(ra) # 800042ec <log_write>
  brelse(bp);
    8000330e:	854a                	mv	a0,s2
    80003310:	00000097          	auipc	ra,0x0
    80003314:	d60080e7          	jalr	-672(ra) # 80003070 <brelse>
}
    80003318:	8526                	mv	a0,s1
    8000331a:	60e6                	ld	ra,88(sp)
    8000331c:	6446                	ld	s0,80(sp)
    8000331e:	64a6                	ld	s1,72(sp)
    80003320:	6906                	ld	s2,64(sp)
    80003322:	79e2                	ld	s3,56(sp)
    80003324:	7a42                	ld	s4,48(sp)
    80003326:	7aa2                	ld	s5,40(sp)
    80003328:	7b02                	ld	s6,32(sp)
    8000332a:	6be2                	ld	s7,24(sp)
    8000332c:	6c42                	ld	s8,16(sp)
    8000332e:	6ca2                	ld	s9,8(sp)
    80003330:	6125                	addi	sp,sp,96
    80003332:	8082                	ret

0000000080003334 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
    80003334:	7179                	addi	sp,sp,-48
    80003336:	f406                	sd	ra,40(sp)
    80003338:	f022                	sd	s0,32(sp)
    8000333a:	ec26                	sd	s1,24(sp)
    8000333c:	e84a                	sd	s2,16(sp)
    8000333e:	e44e                	sd	s3,8(sp)
    80003340:	e052                	sd	s4,0(sp)
    80003342:	1800                	addi	s0,sp,48
    80003344:	892a                	mv	s2,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80003346:	47ad                	li	a5,11
    80003348:	04b7fe63          	bgeu	a5,a1,800033a4 <bmap+0x70>
    if((addr = ip->addrs[bn]) == 0)
      ip->addrs[bn] = addr = balloc(ip->dev);
    return addr;
  }
  bn -= NDIRECT;
    8000334c:	ff45849b          	addiw	s1,a1,-12
    80003350:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    80003354:	0ff00793          	li	a5,255
    80003358:	0ae7e363          	bltu	a5,a4,800033fe <bmap+0xca>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
    8000335c:	08052583          	lw	a1,128(a0)
    80003360:	c5ad                	beqz	a1,800033ca <bmap+0x96>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    bp = bread(ip->dev, addr);
    80003362:	00092503          	lw	a0,0(s2)
    80003366:	00000097          	auipc	ra,0x0
    8000336a:	bda080e7          	jalr	-1062(ra) # 80002f40 <bread>
    8000336e:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80003370:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    80003374:	02049593          	slli	a1,s1,0x20
    80003378:	9181                	srli	a1,a1,0x20
    8000337a:	058a                	slli	a1,a1,0x2
    8000337c:	00b784b3          	add	s1,a5,a1
    80003380:	0004a983          	lw	s3,0(s1)
    80003384:	04098d63          	beqz	s3,800033de <bmap+0xaa>
      a[bn] = addr = balloc(ip->dev);
      log_write(bp);
    }
    brelse(bp);
    80003388:	8552                	mv	a0,s4
    8000338a:	00000097          	auipc	ra,0x0
    8000338e:	ce6080e7          	jalr	-794(ra) # 80003070 <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    80003392:	854e                	mv	a0,s3
    80003394:	70a2                	ld	ra,40(sp)
    80003396:	7402                	ld	s0,32(sp)
    80003398:	64e2                	ld	s1,24(sp)
    8000339a:	6942                	ld	s2,16(sp)
    8000339c:	69a2                	ld	s3,8(sp)
    8000339e:	6a02                	ld	s4,0(sp)
    800033a0:	6145                	addi	sp,sp,48
    800033a2:	8082                	ret
    if((addr = ip->addrs[bn]) == 0)
    800033a4:	02059493          	slli	s1,a1,0x20
    800033a8:	9081                	srli	s1,s1,0x20
    800033aa:	048a                	slli	s1,s1,0x2
    800033ac:	94aa                	add	s1,s1,a0
    800033ae:	0504a983          	lw	s3,80(s1)
    800033b2:	fe0990e3          	bnez	s3,80003392 <bmap+0x5e>
      ip->addrs[bn] = addr = balloc(ip->dev);
    800033b6:	4108                	lw	a0,0(a0)
    800033b8:	00000097          	auipc	ra,0x0
    800033bc:	e4a080e7          	jalr	-438(ra) # 80003202 <balloc>
    800033c0:	0005099b          	sext.w	s3,a0
    800033c4:	0534a823          	sw	s3,80(s1)
    800033c8:	b7e9                	j	80003392 <bmap+0x5e>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    800033ca:	4108                	lw	a0,0(a0)
    800033cc:	00000097          	auipc	ra,0x0
    800033d0:	e36080e7          	jalr	-458(ra) # 80003202 <balloc>
    800033d4:	0005059b          	sext.w	a1,a0
    800033d8:	08b92023          	sw	a1,128(s2)
    800033dc:	b759                	j	80003362 <bmap+0x2e>
      a[bn] = addr = balloc(ip->dev);
    800033de:	00092503          	lw	a0,0(s2)
    800033e2:	00000097          	auipc	ra,0x0
    800033e6:	e20080e7          	jalr	-480(ra) # 80003202 <balloc>
    800033ea:	0005099b          	sext.w	s3,a0
    800033ee:	0134a023          	sw	s3,0(s1)
      log_write(bp);
    800033f2:	8552                	mv	a0,s4
    800033f4:	00001097          	auipc	ra,0x1
    800033f8:	ef8080e7          	jalr	-264(ra) # 800042ec <log_write>
    800033fc:	b771                	j	80003388 <bmap+0x54>
  panic("bmap: out of range");
    800033fe:	00005517          	auipc	a0,0x5
    80003402:	15a50513          	addi	a0,a0,346 # 80008558 <syscalls+0x128>
    80003406:	ffffd097          	auipc	ra,0xffffd
    8000340a:	12a080e7          	jalr	298(ra) # 80000530 <panic>

000000008000340e <iget>:
{
    8000340e:	7179                	addi	sp,sp,-48
    80003410:	f406                	sd	ra,40(sp)
    80003412:	f022                	sd	s0,32(sp)
    80003414:	ec26                	sd	s1,24(sp)
    80003416:	e84a                	sd	s2,16(sp)
    80003418:	e44e                	sd	s3,8(sp)
    8000341a:	e052                	sd	s4,0(sp)
    8000341c:	1800                	addi	s0,sp,48
    8000341e:	89aa                	mv	s3,a0
    80003420:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80003422:	0001c517          	auipc	a0,0x1c
    80003426:	5a650513          	addi	a0,a0,1446 # 8001f9c8 <itable>
    8000342a:	ffffd097          	auipc	ra,0xffffd
    8000342e:	7ac080e7          	jalr	1964(ra) # 80000bd6 <acquire>
  empty = 0;
    80003432:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003434:	0001c497          	auipc	s1,0x1c
    80003438:	5ac48493          	addi	s1,s1,1452 # 8001f9e0 <itable+0x18>
    8000343c:	0001e697          	auipc	a3,0x1e
    80003440:	03468693          	addi	a3,a3,52 # 80021470 <log>
    80003444:	a039                	j	80003452 <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003446:	02090b63          	beqz	s2,8000347c <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    8000344a:	08848493          	addi	s1,s1,136
    8000344e:	02d48a63          	beq	s1,a3,80003482 <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80003452:	449c                	lw	a5,8(s1)
    80003454:	fef059e3          	blez	a5,80003446 <iget+0x38>
    80003458:	4098                	lw	a4,0(s1)
    8000345a:	ff3716e3          	bne	a4,s3,80003446 <iget+0x38>
    8000345e:	40d8                	lw	a4,4(s1)
    80003460:	ff4713e3          	bne	a4,s4,80003446 <iget+0x38>
      ip->ref++;
    80003464:	2785                	addiw	a5,a5,1
    80003466:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80003468:	0001c517          	auipc	a0,0x1c
    8000346c:	56050513          	addi	a0,a0,1376 # 8001f9c8 <itable>
    80003470:	ffffe097          	auipc	ra,0xffffe
    80003474:	81a080e7          	jalr	-2022(ra) # 80000c8a <release>
      return ip;
    80003478:	8926                	mv	s2,s1
    8000347a:	a03d                	j	800034a8 <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    8000347c:	f7f9                	bnez	a5,8000344a <iget+0x3c>
    8000347e:	8926                	mv	s2,s1
    80003480:	b7e9                	j	8000344a <iget+0x3c>
  if(empty == 0)
    80003482:	02090c63          	beqz	s2,800034ba <iget+0xac>
  ip->dev = dev;
    80003486:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    8000348a:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    8000348e:	4785                	li	a5,1
    80003490:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80003494:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    80003498:	0001c517          	auipc	a0,0x1c
    8000349c:	53050513          	addi	a0,a0,1328 # 8001f9c8 <itable>
    800034a0:	ffffd097          	auipc	ra,0xffffd
    800034a4:	7ea080e7          	jalr	2026(ra) # 80000c8a <release>
}
    800034a8:	854a                	mv	a0,s2
    800034aa:	70a2                	ld	ra,40(sp)
    800034ac:	7402                	ld	s0,32(sp)
    800034ae:	64e2                	ld	s1,24(sp)
    800034b0:	6942                	ld	s2,16(sp)
    800034b2:	69a2                	ld	s3,8(sp)
    800034b4:	6a02                	ld	s4,0(sp)
    800034b6:	6145                	addi	sp,sp,48
    800034b8:	8082                	ret
    panic("iget: no inodes");
    800034ba:	00005517          	auipc	a0,0x5
    800034be:	0b650513          	addi	a0,a0,182 # 80008570 <syscalls+0x140>
    800034c2:	ffffd097          	auipc	ra,0xffffd
    800034c6:	06e080e7          	jalr	110(ra) # 80000530 <panic>

00000000800034ca <fsinit>:
fsinit(int dev) {
    800034ca:	7179                	addi	sp,sp,-48
    800034cc:	f406                	sd	ra,40(sp)
    800034ce:	f022                	sd	s0,32(sp)
    800034d0:	ec26                	sd	s1,24(sp)
    800034d2:	e84a                	sd	s2,16(sp)
    800034d4:	e44e                	sd	s3,8(sp)
    800034d6:	1800                	addi	s0,sp,48
    800034d8:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    800034da:	4585                	li	a1,1
    800034dc:	00000097          	auipc	ra,0x0
    800034e0:	a64080e7          	jalr	-1436(ra) # 80002f40 <bread>
    800034e4:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    800034e6:	0001c997          	auipc	s3,0x1c
    800034ea:	4c298993          	addi	s3,s3,1218 # 8001f9a8 <sb>
    800034ee:	02000613          	li	a2,32
    800034f2:	05850593          	addi	a1,a0,88
    800034f6:	854e                	mv	a0,s3
    800034f8:	ffffe097          	auipc	ra,0xffffe
    800034fc:	83a080e7          	jalr	-1990(ra) # 80000d32 <memmove>
  brelse(bp);
    80003500:	8526                	mv	a0,s1
    80003502:	00000097          	auipc	ra,0x0
    80003506:	b6e080e7          	jalr	-1170(ra) # 80003070 <brelse>
  if(sb.magic != FSMAGIC)
    8000350a:	0009a703          	lw	a4,0(s3)
    8000350e:	102037b7          	lui	a5,0x10203
    80003512:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003516:	02f71263          	bne	a4,a5,8000353a <fsinit+0x70>
  initlog(dev, &sb);
    8000351a:	0001c597          	auipc	a1,0x1c
    8000351e:	48e58593          	addi	a1,a1,1166 # 8001f9a8 <sb>
    80003522:	854a                	mv	a0,s2
    80003524:	00001097          	auipc	ra,0x1
    80003528:	b4c080e7          	jalr	-1204(ra) # 80004070 <initlog>
}
    8000352c:	70a2                	ld	ra,40(sp)
    8000352e:	7402                	ld	s0,32(sp)
    80003530:	64e2                	ld	s1,24(sp)
    80003532:	6942                	ld	s2,16(sp)
    80003534:	69a2                	ld	s3,8(sp)
    80003536:	6145                	addi	sp,sp,48
    80003538:	8082                	ret
    panic("invalid file system");
    8000353a:	00005517          	auipc	a0,0x5
    8000353e:	04650513          	addi	a0,a0,70 # 80008580 <syscalls+0x150>
    80003542:	ffffd097          	auipc	ra,0xffffd
    80003546:	fee080e7          	jalr	-18(ra) # 80000530 <panic>

000000008000354a <iinit>:
{
    8000354a:	7179                	addi	sp,sp,-48
    8000354c:	f406                	sd	ra,40(sp)
    8000354e:	f022                	sd	s0,32(sp)
    80003550:	ec26                	sd	s1,24(sp)
    80003552:	e84a                	sd	s2,16(sp)
    80003554:	e44e                	sd	s3,8(sp)
    80003556:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80003558:	00005597          	auipc	a1,0x5
    8000355c:	04058593          	addi	a1,a1,64 # 80008598 <syscalls+0x168>
    80003560:	0001c517          	auipc	a0,0x1c
    80003564:	46850513          	addi	a0,a0,1128 # 8001f9c8 <itable>
    80003568:	ffffd097          	auipc	ra,0xffffd
    8000356c:	5de080e7          	jalr	1502(ra) # 80000b46 <initlock>
  for(i = 0; i < NINODE; i++) {
    80003570:	0001c497          	auipc	s1,0x1c
    80003574:	48048493          	addi	s1,s1,1152 # 8001f9f0 <itable+0x28>
    80003578:	0001e997          	auipc	s3,0x1e
    8000357c:	f0898993          	addi	s3,s3,-248 # 80021480 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80003580:	00005917          	auipc	s2,0x5
    80003584:	02090913          	addi	s2,s2,32 # 800085a0 <syscalls+0x170>
    80003588:	85ca                	mv	a1,s2
    8000358a:	8526                	mv	a0,s1
    8000358c:	00001097          	auipc	ra,0x1
    80003590:	e46080e7          	jalr	-442(ra) # 800043d2 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80003594:	08848493          	addi	s1,s1,136
    80003598:	ff3498e3          	bne	s1,s3,80003588 <iinit+0x3e>
}
    8000359c:	70a2                	ld	ra,40(sp)
    8000359e:	7402                	ld	s0,32(sp)
    800035a0:	64e2                	ld	s1,24(sp)
    800035a2:	6942                	ld	s2,16(sp)
    800035a4:	69a2                	ld	s3,8(sp)
    800035a6:	6145                	addi	sp,sp,48
    800035a8:	8082                	ret

00000000800035aa <ialloc>:
{
    800035aa:	715d                	addi	sp,sp,-80
    800035ac:	e486                	sd	ra,72(sp)
    800035ae:	e0a2                	sd	s0,64(sp)
    800035b0:	fc26                	sd	s1,56(sp)
    800035b2:	f84a                	sd	s2,48(sp)
    800035b4:	f44e                	sd	s3,40(sp)
    800035b6:	f052                	sd	s4,32(sp)
    800035b8:	ec56                	sd	s5,24(sp)
    800035ba:	e85a                	sd	s6,16(sp)
    800035bc:	e45e                	sd	s7,8(sp)
    800035be:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    800035c0:	0001c717          	auipc	a4,0x1c
    800035c4:	3f472703          	lw	a4,1012(a4) # 8001f9b4 <sb+0xc>
    800035c8:	4785                	li	a5,1
    800035ca:	04e7fa63          	bgeu	a5,a4,8000361e <ialloc+0x74>
    800035ce:	8aaa                	mv	s5,a0
    800035d0:	8bae                	mv	s7,a1
    800035d2:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    800035d4:	0001ca17          	auipc	s4,0x1c
    800035d8:	3d4a0a13          	addi	s4,s4,980 # 8001f9a8 <sb>
    800035dc:	00048b1b          	sext.w	s6,s1
    800035e0:	0044d593          	srli	a1,s1,0x4
    800035e4:	018a2783          	lw	a5,24(s4)
    800035e8:	9dbd                	addw	a1,a1,a5
    800035ea:	8556                	mv	a0,s5
    800035ec:	00000097          	auipc	ra,0x0
    800035f0:	954080e7          	jalr	-1708(ra) # 80002f40 <bread>
    800035f4:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    800035f6:	05850993          	addi	s3,a0,88
    800035fa:	00f4f793          	andi	a5,s1,15
    800035fe:	079a                	slli	a5,a5,0x6
    80003600:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80003602:	00099783          	lh	a5,0(s3)
    80003606:	c785                	beqz	a5,8000362e <ialloc+0x84>
    brelse(bp);
    80003608:	00000097          	auipc	ra,0x0
    8000360c:	a68080e7          	jalr	-1432(ra) # 80003070 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80003610:	0485                	addi	s1,s1,1
    80003612:	00ca2703          	lw	a4,12(s4)
    80003616:	0004879b          	sext.w	a5,s1
    8000361a:	fce7e1e3          	bltu	a5,a4,800035dc <ialloc+0x32>
  panic("ialloc: no inodes");
    8000361e:	00005517          	auipc	a0,0x5
    80003622:	f8a50513          	addi	a0,a0,-118 # 800085a8 <syscalls+0x178>
    80003626:	ffffd097          	auipc	ra,0xffffd
    8000362a:	f0a080e7          	jalr	-246(ra) # 80000530 <panic>
      memset(dip, 0, sizeof(*dip));
    8000362e:	04000613          	li	a2,64
    80003632:	4581                	li	a1,0
    80003634:	854e                	mv	a0,s3
    80003636:	ffffd097          	auipc	ra,0xffffd
    8000363a:	69c080e7          	jalr	1692(ra) # 80000cd2 <memset>
      dip->type = type;
    8000363e:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003642:	854a                	mv	a0,s2
    80003644:	00001097          	auipc	ra,0x1
    80003648:	ca8080e7          	jalr	-856(ra) # 800042ec <log_write>
      brelse(bp);
    8000364c:	854a                	mv	a0,s2
    8000364e:	00000097          	auipc	ra,0x0
    80003652:	a22080e7          	jalr	-1502(ra) # 80003070 <brelse>
      return iget(dev, inum);
    80003656:	85da                	mv	a1,s6
    80003658:	8556                	mv	a0,s5
    8000365a:	00000097          	auipc	ra,0x0
    8000365e:	db4080e7          	jalr	-588(ra) # 8000340e <iget>
}
    80003662:	60a6                	ld	ra,72(sp)
    80003664:	6406                	ld	s0,64(sp)
    80003666:	74e2                	ld	s1,56(sp)
    80003668:	7942                	ld	s2,48(sp)
    8000366a:	79a2                	ld	s3,40(sp)
    8000366c:	7a02                	ld	s4,32(sp)
    8000366e:	6ae2                	ld	s5,24(sp)
    80003670:	6b42                	ld	s6,16(sp)
    80003672:	6ba2                	ld	s7,8(sp)
    80003674:	6161                	addi	sp,sp,80
    80003676:	8082                	ret

0000000080003678 <iupdate>:
{
    80003678:	1101                	addi	sp,sp,-32
    8000367a:	ec06                	sd	ra,24(sp)
    8000367c:	e822                	sd	s0,16(sp)
    8000367e:	e426                	sd	s1,8(sp)
    80003680:	e04a                	sd	s2,0(sp)
    80003682:	1000                	addi	s0,sp,32
    80003684:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003686:	415c                	lw	a5,4(a0)
    80003688:	0047d79b          	srliw	a5,a5,0x4
    8000368c:	0001c597          	auipc	a1,0x1c
    80003690:	3345a583          	lw	a1,820(a1) # 8001f9c0 <sb+0x18>
    80003694:	9dbd                	addw	a1,a1,a5
    80003696:	4108                	lw	a0,0(a0)
    80003698:	00000097          	auipc	ra,0x0
    8000369c:	8a8080e7          	jalr	-1880(ra) # 80002f40 <bread>
    800036a0:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    800036a2:	05850793          	addi	a5,a0,88
    800036a6:	40c8                	lw	a0,4(s1)
    800036a8:	893d                	andi	a0,a0,15
    800036aa:	051a                	slli	a0,a0,0x6
    800036ac:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    800036ae:	04449703          	lh	a4,68(s1)
    800036b2:	00e51023          	sh	a4,0(a0)
  dip->major = ip->major;
    800036b6:	04649703          	lh	a4,70(s1)
    800036ba:	00e51123          	sh	a4,2(a0)
  dip->minor = ip->minor;
    800036be:	04849703          	lh	a4,72(s1)
    800036c2:	00e51223          	sh	a4,4(a0)
  dip->nlink = ip->nlink;
    800036c6:	04a49703          	lh	a4,74(s1)
    800036ca:	00e51323          	sh	a4,6(a0)
  dip->size = ip->size;
    800036ce:	44f8                	lw	a4,76(s1)
    800036d0:	c518                	sw	a4,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    800036d2:	03400613          	li	a2,52
    800036d6:	05048593          	addi	a1,s1,80
    800036da:	0531                	addi	a0,a0,12
    800036dc:	ffffd097          	auipc	ra,0xffffd
    800036e0:	656080e7          	jalr	1622(ra) # 80000d32 <memmove>
  log_write(bp);
    800036e4:	854a                	mv	a0,s2
    800036e6:	00001097          	auipc	ra,0x1
    800036ea:	c06080e7          	jalr	-1018(ra) # 800042ec <log_write>
  brelse(bp);
    800036ee:	854a                	mv	a0,s2
    800036f0:	00000097          	auipc	ra,0x0
    800036f4:	980080e7          	jalr	-1664(ra) # 80003070 <brelse>
}
    800036f8:	60e2                	ld	ra,24(sp)
    800036fa:	6442                	ld	s0,16(sp)
    800036fc:	64a2                	ld	s1,8(sp)
    800036fe:	6902                	ld	s2,0(sp)
    80003700:	6105                	addi	sp,sp,32
    80003702:	8082                	ret

0000000080003704 <idup>:
{
    80003704:	1101                	addi	sp,sp,-32
    80003706:	ec06                	sd	ra,24(sp)
    80003708:	e822                	sd	s0,16(sp)
    8000370a:	e426                	sd	s1,8(sp)
    8000370c:	1000                	addi	s0,sp,32
    8000370e:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003710:	0001c517          	auipc	a0,0x1c
    80003714:	2b850513          	addi	a0,a0,696 # 8001f9c8 <itable>
    80003718:	ffffd097          	auipc	ra,0xffffd
    8000371c:	4be080e7          	jalr	1214(ra) # 80000bd6 <acquire>
  ip->ref++;
    80003720:	449c                	lw	a5,8(s1)
    80003722:	2785                	addiw	a5,a5,1
    80003724:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003726:	0001c517          	auipc	a0,0x1c
    8000372a:	2a250513          	addi	a0,a0,674 # 8001f9c8 <itable>
    8000372e:	ffffd097          	auipc	ra,0xffffd
    80003732:	55c080e7          	jalr	1372(ra) # 80000c8a <release>
}
    80003736:	8526                	mv	a0,s1
    80003738:	60e2                	ld	ra,24(sp)
    8000373a:	6442                	ld	s0,16(sp)
    8000373c:	64a2                	ld	s1,8(sp)
    8000373e:	6105                	addi	sp,sp,32
    80003740:	8082                	ret

0000000080003742 <ilock>:
{
    80003742:	1101                	addi	sp,sp,-32
    80003744:	ec06                	sd	ra,24(sp)
    80003746:	e822                	sd	s0,16(sp)
    80003748:	e426                	sd	s1,8(sp)
    8000374a:	e04a                	sd	s2,0(sp)
    8000374c:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    8000374e:	c115                	beqz	a0,80003772 <ilock+0x30>
    80003750:	84aa                	mv	s1,a0
    80003752:	451c                	lw	a5,8(a0)
    80003754:	00f05f63          	blez	a5,80003772 <ilock+0x30>
  acquiresleep(&ip->lock);
    80003758:	0541                	addi	a0,a0,16
    8000375a:	00001097          	auipc	ra,0x1
    8000375e:	cb2080e7          	jalr	-846(ra) # 8000440c <acquiresleep>
  if(ip->valid == 0){
    80003762:	40bc                	lw	a5,64(s1)
    80003764:	cf99                	beqz	a5,80003782 <ilock+0x40>
}
    80003766:	60e2                	ld	ra,24(sp)
    80003768:	6442                	ld	s0,16(sp)
    8000376a:	64a2                	ld	s1,8(sp)
    8000376c:	6902                	ld	s2,0(sp)
    8000376e:	6105                	addi	sp,sp,32
    80003770:	8082                	ret
    panic("ilock");
    80003772:	00005517          	auipc	a0,0x5
    80003776:	e4e50513          	addi	a0,a0,-434 # 800085c0 <syscalls+0x190>
    8000377a:	ffffd097          	auipc	ra,0xffffd
    8000377e:	db6080e7          	jalr	-586(ra) # 80000530 <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003782:	40dc                	lw	a5,4(s1)
    80003784:	0047d79b          	srliw	a5,a5,0x4
    80003788:	0001c597          	auipc	a1,0x1c
    8000378c:	2385a583          	lw	a1,568(a1) # 8001f9c0 <sb+0x18>
    80003790:	9dbd                	addw	a1,a1,a5
    80003792:	4088                	lw	a0,0(s1)
    80003794:	fffff097          	auipc	ra,0xfffff
    80003798:	7ac080e7          	jalr	1964(ra) # 80002f40 <bread>
    8000379c:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    8000379e:	05850593          	addi	a1,a0,88
    800037a2:	40dc                	lw	a5,4(s1)
    800037a4:	8bbd                	andi	a5,a5,15
    800037a6:	079a                	slli	a5,a5,0x6
    800037a8:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    800037aa:	00059783          	lh	a5,0(a1)
    800037ae:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    800037b2:	00259783          	lh	a5,2(a1)
    800037b6:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    800037ba:	00459783          	lh	a5,4(a1)
    800037be:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    800037c2:	00659783          	lh	a5,6(a1)
    800037c6:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    800037ca:	459c                	lw	a5,8(a1)
    800037cc:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    800037ce:	03400613          	li	a2,52
    800037d2:	05b1                	addi	a1,a1,12
    800037d4:	05048513          	addi	a0,s1,80
    800037d8:	ffffd097          	auipc	ra,0xffffd
    800037dc:	55a080e7          	jalr	1370(ra) # 80000d32 <memmove>
    brelse(bp);
    800037e0:	854a                	mv	a0,s2
    800037e2:	00000097          	auipc	ra,0x0
    800037e6:	88e080e7          	jalr	-1906(ra) # 80003070 <brelse>
    ip->valid = 1;
    800037ea:	4785                	li	a5,1
    800037ec:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    800037ee:	04449783          	lh	a5,68(s1)
    800037f2:	fbb5                	bnez	a5,80003766 <ilock+0x24>
      panic("ilock: no type");
    800037f4:	00005517          	auipc	a0,0x5
    800037f8:	dd450513          	addi	a0,a0,-556 # 800085c8 <syscalls+0x198>
    800037fc:	ffffd097          	auipc	ra,0xffffd
    80003800:	d34080e7          	jalr	-716(ra) # 80000530 <panic>

0000000080003804 <iunlock>:
{
    80003804:	1101                	addi	sp,sp,-32
    80003806:	ec06                	sd	ra,24(sp)
    80003808:	e822                	sd	s0,16(sp)
    8000380a:	e426                	sd	s1,8(sp)
    8000380c:	e04a                	sd	s2,0(sp)
    8000380e:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003810:	c905                	beqz	a0,80003840 <iunlock+0x3c>
    80003812:	84aa                	mv	s1,a0
    80003814:	01050913          	addi	s2,a0,16
    80003818:	854a                	mv	a0,s2
    8000381a:	00001097          	auipc	ra,0x1
    8000381e:	c8c080e7          	jalr	-884(ra) # 800044a6 <holdingsleep>
    80003822:	cd19                	beqz	a0,80003840 <iunlock+0x3c>
    80003824:	449c                	lw	a5,8(s1)
    80003826:	00f05d63          	blez	a5,80003840 <iunlock+0x3c>
  releasesleep(&ip->lock);
    8000382a:	854a                	mv	a0,s2
    8000382c:	00001097          	auipc	ra,0x1
    80003830:	c36080e7          	jalr	-970(ra) # 80004462 <releasesleep>
}
    80003834:	60e2                	ld	ra,24(sp)
    80003836:	6442                	ld	s0,16(sp)
    80003838:	64a2                	ld	s1,8(sp)
    8000383a:	6902                	ld	s2,0(sp)
    8000383c:	6105                	addi	sp,sp,32
    8000383e:	8082                	ret
    panic("iunlock");
    80003840:	00005517          	auipc	a0,0x5
    80003844:	d9850513          	addi	a0,a0,-616 # 800085d8 <syscalls+0x1a8>
    80003848:	ffffd097          	auipc	ra,0xffffd
    8000384c:	ce8080e7          	jalr	-792(ra) # 80000530 <panic>

0000000080003850 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003850:	7179                	addi	sp,sp,-48
    80003852:	f406                	sd	ra,40(sp)
    80003854:	f022                	sd	s0,32(sp)
    80003856:	ec26                	sd	s1,24(sp)
    80003858:	e84a                	sd	s2,16(sp)
    8000385a:	e44e                	sd	s3,8(sp)
    8000385c:	e052                	sd	s4,0(sp)
    8000385e:	1800                	addi	s0,sp,48
    80003860:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003862:	05050493          	addi	s1,a0,80
    80003866:	08050913          	addi	s2,a0,128
    8000386a:	a021                	j	80003872 <itrunc+0x22>
    8000386c:	0491                	addi	s1,s1,4
    8000386e:	01248d63          	beq	s1,s2,80003888 <itrunc+0x38>
    if(ip->addrs[i]){
    80003872:	408c                	lw	a1,0(s1)
    80003874:	dde5                	beqz	a1,8000386c <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    80003876:	0009a503          	lw	a0,0(s3)
    8000387a:	00000097          	auipc	ra,0x0
    8000387e:	90c080e7          	jalr	-1780(ra) # 80003186 <bfree>
      ip->addrs[i] = 0;
    80003882:	0004a023          	sw	zero,0(s1)
    80003886:	b7dd                	j	8000386c <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003888:	0809a583          	lw	a1,128(s3)
    8000388c:	e185                	bnez	a1,800038ac <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    8000388e:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003892:	854e                	mv	a0,s3
    80003894:	00000097          	auipc	ra,0x0
    80003898:	de4080e7          	jalr	-540(ra) # 80003678 <iupdate>
}
    8000389c:	70a2                	ld	ra,40(sp)
    8000389e:	7402                	ld	s0,32(sp)
    800038a0:	64e2                	ld	s1,24(sp)
    800038a2:	6942                	ld	s2,16(sp)
    800038a4:	69a2                	ld	s3,8(sp)
    800038a6:	6a02                	ld	s4,0(sp)
    800038a8:	6145                	addi	sp,sp,48
    800038aa:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    800038ac:	0009a503          	lw	a0,0(s3)
    800038b0:	fffff097          	auipc	ra,0xfffff
    800038b4:	690080e7          	jalr	1680(ra) # 80002f40 <bread>
    800038b8:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    800038ba:	05850493          	addi	s1,a0,88
    800038be:	45850913          	addi	s2,a0,1112
    800038c2:	a811                	j	800038d6 <itrunc+0x86>
        bfree(ip->dev, a[j]);
    800038c4:	0009a503          	lw	a0,0(s3)
    800038c8:	00000097          	auipc	ra,0x0
    800038cc:	8be080e7          	jalr	-1858(ra) # 80003186 <bfree>
    for(j = 0; j < NINDIRECT; j++){
    800038d0:	0491                	addi	s1,s1,4
    800038d2:	01248563          	beq	s1,s2,800038dc <itrunc+0x8c>
      if(a[j])
    800038d6:	408c                	lw	a1,0(s1)
    800038d8:	dde5                	beqz	a1,800038d0 <itrunc+0x80>
    800038da:	b7ed                	j	800038c4 <itrunc+0x74>
    brelse(bp);
    800038dc:	8552                	mv	a0,s4
    800038de:	fffff097          	auipc	ra,0xfffff
    800038e2:	792080e7          	jalr	1938(ra) # 80003070 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    800038e6:	0809a583          	lw	a1,128(s3)
    800038ea:	0009a503          	lw	a0,0(s3)
    800038ee:	00000097          	auipc	ra,0x0
    800038f2:	898080e7          	jalr	-1896(ra) # 80003186 <bfree>
    ip->addrs[NDIRECT] = 0;
    800038f6:	0809a023          	sw	zero,128(s3)
    800038fa:	bf51                	j	8000388e <itrunc+0x3e>

00000000800038fc <iput>:
{
    800038fc:	1101                	addi	sp,sp,-32
    800038fe:	ec06                	sd	ra,24(sp)
    80003900:	e822                	sd	s0,16(sp)
    80003902:	e426                	sd	s1,8(sp)
    80003904:	e04a                	sd	s2,0(sp)
    80003906:	1000                	addi	s0,sp,32
    80003908:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    8000390a:	0001c517          	auipc	a0,0x1c
    8000390e:	0be50513          	addi	a0,a0,190 # 8001f9c8 <itable>
    80003912:	ffffd097          	auipc	ra,0xffffd
    80003916:	2c4080e7          	jalr	708(ra) # 80000bd6 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    8000391a:	4498                	lw	a4,8(s1)
    8000391c:	4785                	li	a5,1
    8000391e:	02f70363          	beq	a4,a5,80003944 <iput+0x48>
  ip->ref--;
    80003922:	449c                	lw	a5,8(s1)
    80003924:	37fd                	addiw	a5,a5,-1
    80003926:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003928:	0001c517          	auipc	a0,0x1c
    8000392c:	0a050513          	addi	a0,a0,160 # 8001f9c8 <itable>
    80003930:	ffffd097          	auipc	ra,0xffffd
    80003934:	35a080e7          	jalr	858(ra) # 80000c8a <release>
}
    80003938:	60e2                	ld	ra,24(sp)
    8000393a:	6442                	ld	s0,16(sp)
    8000393c:	64a2                	ld	s1,8(sp)
    8000393e:	6902                	ld	s2,0(sp)
    80003940:	6105                	addi	sp,sp,32
    80003942:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003944:	40bc                	lw	a5,64(s1)
    80003946:	dff1                	beqz	a5,80003922 <iput+0x26>
    80003948:	04a49783          	lh	a5,74(s1)
    8000394c:	fbf9                	bnez	a5,80003922 <iput+0x26>
    acquiresleep(&ip->lock);
    8000394e:	01048913          	addi	s2,s1,16
    80003952:	854a                	mv	a0,s2
    80003954:	00001097          	auipc	ra,0x1
    80003958:	ab8080e7          	jalr	-1352(ra) # 8000440c <acquiresleep>
    release(&itable.lock);
    8000395c:	0001c517          	auipc	a0,0x1c
    80003960:	06c50513          	addi	a0,a0,108 # 8001f9c8 <itable>
    80003964:	ffffd097          	auipc	ra,0xffffd
    80003968:	326080e7          	jalr	806(ra) # 80000c8a <release>
    itrunc(ip);
    8000396c:	8526                	mv	a0,s1
    8000396e:	00000097          	auipc	ra,0x0
    80003972:	ee2080e7          	jalr	-286(ra) # 80003850 <itrunc>
    ip->type = 0;
    80003976:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    8000397a:	8526                	mv	a0,s1
    8000397c:	00000097          	auipc	ra,0x0
    80003980:	cfc080e7          	jalr	-772(ra) # 80003678 <iupdate>
    ip->valid = 0;
    80003984:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003988:	854a                	mv	a0,s2
    8000398a:	00001097          	auipc	ra,0x1
    8000398e:	ad8080e7          	jalr	-1320(ra) # 80004462 <releasesleep>
    acquire(&itable.lock);
    80003992:	0001c517          	auipc	a0,0x1c
    80003996:	03650513          	addi	a0,a0,54 # 8001f9c8 <itable>
    8000399a:	ffffd097          	auipc	ra,0xffffd
    8000399e:	23c080e7          	jalr	572(ra) # 80000bd6 <acquire>
    800039a2:	b741                	j	80003922 <iput+0x26>

00000000800039a4 <iunlockput>:
{
    800039a4:	1101                	addi	sp,sp,-32
    800039a6:	ec06                	sd	ra,24(sp)
    800039a8:	e822                	sd	s0,16(sp)
    800039aa:	e426                	sd	s1,8(sp)
    800039ac:	1000                	addi	s0,sp,32
    800039ae:	84aa                	mv	s1,a0
  iunlock(ip);
    800039b0:	00000097          	auipc	ra,0x0
    800039b4:	e54080e7          	jalr	-428(ra) # 80003804 <iunlock>
  iput(ip);
    800039b8:	8526                	mv	a0,s1
    800039ba:	00000097          	auipc	ra,0x0
    800039be:	f42080e7          	jalr	-190(ra) # 800038fc <iput>
}
    800039c2:	60e2                	ld	ra,24(sp)
    800039c4:	6442                	ld	s0,16(sp)
    800039c6:	64a2                	ld	s1,8(sp)
    800039c8:	6105                	addi	sp,sp,32
    800039ca:	8082                	ret

00000000800039cc <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    800039cc:	1141                	addi	sp,sp,-16
    800039ce:	e422                	sd	s0,8(sp)
    800039d0:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    800039d2:	411c                	lw	a5,0(a0)
    800039d4:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    800039d6:	415c                	lw	a5,4(a0)
    800039d8:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    800039da:	04451783          	lh	a5,68(a0)
    800039de:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    800039e2:	04a51783          	lh	a5,74(a0)
    800039e6:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    800039ea:	04c56783          	lwu	a5,76(a0)
    800039ee:	e99c                	sd	a5,16(a1)
}
    800039f0:	6422                	ld	s0,8(sp)
    800039f2:	0141                	addi	sp,sp,16
    800039f4:	8082                	ret

00000000800039f6 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    800039f6:	457c                	lw	a5,76(a0)
    800039f8:	0ed7e963          	bltu	a5,a3,80003aea <readi+0xf4>
{
    800039fc:	7159                	addi	sp,sp,-112
    800039fe:	f486                	sd	ra,104(sp)
    80003a00:	f0a2                	sd	s0,96(sp)
    80003a02:	eca6                	sd	s1,88(sp)
    80003a04:	e8ca                	sd	s2,80(sp)
    80003a06:	e4ce                	sd	s3,72(sp)
    80003a08:	e0d2                	sd	s4,64(sp)
    80003a0a:	fc56                	sd	s5,56(sp)
    80003a0c:	f85a                	sd	s6,48(sp)
    80003a0e:	f45e                	sd	s7,40(sp)
    80003a10:	f062                	sd	s8,32(sp)
    80003a12:	ec66                	sd	s9,24(sp)
    80003a14:	e86a                	sd	s10,16(sp)
    80003a16:	e46e                	sd	s11,8(sp)
    80003a18:	1880                	addi	s0,sp,112
    80003a1a:	8baa                	mv	s7,a0
    80003a1c:	8c2e                	mv	s8,a1
    80003a1e:	8ab2                	mv	s5,a2
    80003a20:	84b6                	mv	s1,a3
    80003a22:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003a24:	9f35                	addw	a4,a4,a3
    return 0;
    80003a26:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003a28:	0ad76063          	bltu	a4,a3,80003ac8 <readi+0xd2>
  if(off + n > ip->size)
    80003a2c:	00e7f463          	bgeu	a5,a4,80003a34 <readi+0x3e>
    n = ip->size - off;
    80003a30:	40d78b3b          	subw	s6,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003a34:	0a0b0963          	beqz	s6,80003ae6 <readi+0xf0>
    80003a38:	4981                	li	s3,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80003a3a:	40000d13          	li	s10,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003a3e:	5cfd                	li	s9,-1
    80003a40:	a82d                	j	80003a7a <readi+0x84>
    80003a42:	020a1d93          	slli	s11,s4,0x20
    80003a46:	020ddd93          	srli	s11,s11,0x20
    80003a4a:	05890613          	addi	a2,s2,88
    80003a4e:	86ee                	mv	a3,s11
    80003a50:	963a                	add	a2,a2,a4
    80003a52:	85d6                	mv	a1,s5
    80003a54:	8562                	mv	a0,s8
    80003a56:	fffff097          	auipc	ra,0xfffff
    80003a5a:	9fa080e7          	jalr	-1542(ra) # 80002450 <either_copyout>
    80003a5e:	05950d63          	beq	a0,s9,80003ab8 <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003a62:	854a                	mv	a0,s2
    80003a64:	fffff097          	auipc	ra,0xfffff
    80003a68:	60c080e7          	jalr	1548(ra) # 80003070 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003a6c:	013a09bb          	addw	s3,s4,s3
    80003a70:	009a04bb          	addw	s1,s4,s1
    80003a74:	9aee                	add	s5,s5,s11
    80003a76:	0569f763          	bgeu	s3,s6,80003ac4 <readi+0xce>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80003a7a:	000ba903          	lw	s2,0(s7)
    80003a7e:	00a4d59b          	srliw	a1,s1,0xa
    80003a82:	855e                	mv	a0,s7
    80003a84:	00000097          	auipc	ra,0x0
    80003a88:	8b0080e7          	jalr	-1872(ra) # 80003334 <bmap>
    80003a8c:	0005059b          	sext.w	a1,a0
    80003a90:	854a                	mv	a0,s2
    80003a92:	fffff097          	auipc	ra,0xfffff
    80003a96:	4ae080e7          	jalr	1198(ra) # 80002f40 <bread>
    80003a9a:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003a9c:	3ff4f713          	andi	a4,s1,1023
    80003aa0:	40ed07bb          	subw	a5,s10,a4
    80003aa4:	413b06bb          	subw	a3,s6,s3
    80003aa8:	8a3e                	mv	s4,a5
    80003aaa:	2781                	sext.w	a5,a5
    80003aac:	0006861b          	sext.w	a2,a3
    80003ab0:	f8f679e3          	bgeu	a2,a5,80003a42 <readi+0x4c>
    80003ab4:	8a36                	mv	s4,a3
    80003ab6:	b771                	j	80003a42 <readi+0x4c>
      brelse(bp);
    80003ab8:	854a                	mv	a0,s2
    80003aba:	fffff097          	auipc	ra,0xfffff
    80003abe:	5b6080e7          	jalr	1462(ra) # 80003070 <brelse>
      tot = -1;
    80003ac2:	59fd                	li	s3,-1
  }
  return tot;
    80003ac4:	0009851b          	sext.w	a0,s3
}
    80003ac8:	70a6                	ld	ra,104(sp)
    80003aca:	7406                	ld	s0,96(sp)
    80003acc:	64e6                	ld	s1,88(sp)
    80003ace:	6946                	ld	s2,80(sp)
    80003ad0:	69a6                	ld	s3,72(sp)
    80003ad2:	6a06                	ld	s4,64(sp)
    80003ad4:	7ae2                	ld	s5,56(sp)
    80003ad6:	7b42                	ld	s6,48(sp)
    80003ad8:	7ba2                	ld	s7,40(sp)
    80003ada:	7c02                	ld	s8,32(sp)
    80003adc:	6ce2                	ld	s9,24(sp)
    80003ade:	6d42                	ld	s10,16(sp)
    80003ae0:	6da2                	ld	s11,8(sp)
    80003ae2:	6165                	addi	sp,sp,112
    80003ae4:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003ae6:	89da                	mv	s3,s6
    80003ae8:	bff1                	j	80003ac4 <readi+0xce>
    return 0;
    80003aea:	4501                	li	a0,0
}
    80003aec:	8082                	ret

0000000080003aee <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003aee:	457c                	lw	a5,76(a0)
    80003af0:	10d7e863          	bltu	a5,a3,80003c00 <writei+0x112>
{
    80003af4:	7159                	addi	sp,sp,-112
    80003af6:	f486                	sd	ra,104(sp)
    80003af8:	f0a2                	sd	s0,96(sp)
    80003afa:	eca6                	sd	s1,88(sp)
    80003afc:	e8ca                	sd	s2,80(sp)
    80003afe:	e4ce                	sd	s3,72(sp)
    80003b00:	e0d2                	sd	s4,64(sp)
    80003b02:	fc56                	sd	s5,56(sp)
    80003b04:	f85a                	sd	s6,48(sp)
    80003b06:	f45e                	sd	s7,40(sp)
    80003b08:	f062                	sd	s8,32(sp)
    80003b0a:	ec66                	sd	s9,24(sp)
    80003b0c:	e86a                	sd	s10,16(sp)
    80003b0e:	e46e                	sd	s11,8(sp)
    80003b10:	1880                	addi	s0,sp,112
    80003b12:	8b2a                	mv	s6,a0
    80003b14:	8c2e                	mv	s8,a1
    80003b16:	8ab2                	mv	s5,a2
    80003b18:	8936                	mv	s2,a3
    80003b1a:	8bba                	mv	s7,a4
  if(off > ip->size || off + n < off)
    80003b1c:	00e687bb          	addw	a5,a3,a4
    80003b20:	0ed7e263          	bltu	a5,a3,80003c04 <writei+0x116>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003b24:	00043737          	lui	a4,0x43
    80003b28:	0ef76063          	bltu	a4,a5,80003c08 <writei+0x11a>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003b2c:	0c0b8863          	beqz	s7,80003bfc <writei+0x10e>
    80003b30:	4a01                	li	s4,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80003b32:	40000d13          	li	s10,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003b36:	5cfd                	li	s9,-1
    80003b38:	a091                	j	80003b7c <writei+0x8e>
    80003b3a:	02099d93          	slli	s11,s3,0x20
    80003b3e:	020ddd93          	srli	s11,s11,0x20
    80003b42:	05848513          	addi	a0,s1,88
    80003b46:	86ee                	mv	a3,s11
    80003b48:	8656                	mv	a2,s5
    80003b4a:	85e2                	mv	a1,s8
    80003b4c:	953a                	add	a0,a0,a4
    80003b4e:	fffff097          	auipc	ra,0xfffff
    80003b52:	958080e7          	jalr	-1704(ra) # 800024a6 <either_copyin>
    80003b56:	07950263          	beq	a0,s9,80003bba <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003b5a:	8526                	mv	a0,s1
    80003b5c:	00000097          	auipc	ra,0x0
    80003b60:	790080e7          	jalr	1936(ra) # 800042ec <log_write>
    brelse(bp);
    80003b64:	8526                	mv	a0,s1
    80003b66:	fffff097          	auipc	ra,0xfffff
    80003b6a:	50a080e7          	jalr	1290(ra) # 80003070 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003b6e:	01498a3b          	addw	s4,s3,s4
    80003b72:	0129893b          	addw	s2,s3,s2
    80003b76:	9aee                	add	s5,s5,s11
    80003b78:	057a7663          	bgeu	s4,s7,80003bc4 <writei+0xd6>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80003b7c:	000b2483          	lw	s1,0(s6)
    80003b80:	00a9559b          	srliw	a1,s2,0xa
    80003b84:	855a                	mv	a0,s6
    80003b86:	fffff097          	auipc	ra,0xfffff
    80003b8a:	7ae080e7          	jalr	1966(ra) # 80003334 <bmap>
    80003b8e:	0005059b          	sext.w	a1,a0
    80003b92:	8526                	mv	a0,s1
    80003b94:	fffff097          	auipc	ra,0xfffff
    80003b98:	3ac080e7          	jalr	940(ra) # 80002f40 <bread>
    80003b9c:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003b9e:	3ff97713          	andi	a4,s2,1023
    80003ba2:	40ed07bb          	subw	a5,s10,a4
    80003ba6:	414b86bb          	subw	a3,s7,s4
    80003baa:	89be                	mv	s3,a5
    80003bac:	2781                	sext.w	a5,a5
    80003bae:	0006861b          	sext.w	a2,a3
    80003bb2:	f8f674e3          	bgeu	a2,a5,80003b3a <writei+0x4c>
    80003bb6:	89b6                	mv	s3,a3
    80003bb8:	b749                	j	80003b3a <writei+0x4c>
      brelse(bp);
    80003bba:	8526                	mv	a0,s1
    80003bbc:	fffff097          	auipc	ra,0xfffff
    80003bc0:	4b4080e7          	jalr	1204(ra) # 80003070 <brelse>
  }

  if(off > ip->size)
    80003bc4:	04cb2783          	lw	a5,76(s6)
    80003bc8:	0127f463          	bgeu	a5,s2,80003bd0 <writei+0xe2>
    ip->size = off;
    80003bcc:	052b2623          	sw	s2,76(s6)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80003bd0:	855a                	mv	a0,s6
    80003bd2:	00000097          	auipc	ra,0x0
    80003bd6:	aa6080e7          	jalr	-1370(ra) # 80003678 <iupdate>

  return tot;
    80003bda:	000a051b          	sext.w	a0,s4
}
    80003bde:	70a6                	ld	ra,104(sp)
    80003be0:	7406                	ld	s0,96(sp)
    80003be2:	64e6                	ld	s1,88(sp)
    80003be4:	6946                	ld	s2,80(sp)
    80003be6:	69a6                	ld	s3,72(sp)
    80003be8:	6a06                	ld	s4,64(sp)
    80003bea:	7ae2                	ld	s5,56(sp)
    80003bec:	7b42                	ld	s6,48(sp)
    80003bee:	7ba2                	ld	s7,40(sp)
    80003bf0:	7c02                	ld	s8,32(sp)
    80003bf2:	6ce2                	ld	s9,24(sp)
    80003bf4:	6d42                	ld	s10,16(sp)
    80003bf6:	6da2                	ld	s11,8(sp)
    80003bf8:	6165                	addi	sp,sp,112
    80003bfa:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003bfc:	8a5e                	mv	s4,s7
    80003bfe:	bfc9                	j	80003bd0 <writei+0xe2>
    return -1;
    80003c00:	557d                	li	a0,-1
}
    80003c02:	8082                	ret
    return -1;
    80003c04:	557d                	li	a0,-1
    80003c06:	bfe1                	j	80003bde <writei+0xf0>
    return -1;
    80003c08:	557d                	li	a0,-1
    80003c0a:	bfd1                	j	80003bde <writei+0xf0>

0000000080003c0c <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003c0c:	1141                	addi	sp,sp,-16
    80003c0e:	e406                	sd	ra,8(sp)
    80003c10:	e022                	sd	s0,0(sp)
    80003c12:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003c14:	4639                	li	a2,14
    80003c16:	ffffd097          	auipc	ra,0xffffd
    80003c1a:	198080e7          	jalr	408(ra) # 80000dae <strncmp>
}
    80003c1e:	60a2                	ld	ra,8(sp)
    80003c20:	6402                	ld	s0,0(sp)
    80003c22:	0141                	addi	sp,sp,16
    80003c24:	8082                	ret

0000000080003c26 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003c26:	7139                	addi	sp,sp,-64
    80003c28:	fc06                	sd	ra,56(sp)
    80003c2a:	f822                	sd	s0,48(sp)
    80003c2c:	f426                	sd	s1,40(sp)
    80003c2e:	f04a                	sd	s2,32(sp)
    80003c30:	ec4e                	sd	s3,24(sp)
    80003c32:	e852                	sd	s4,16(sp)
    80003c34:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003c36:	04451703          	lh	a4,68(a0)
    80003c3a:	4785                	li	a5,1
    80003c3c:	00f71a63          	bne	a4,a5,80003c50 <dirlookup+0x2a>
    80003c40:	892a                	mv	s2,a0
    80003c42:	89ae                	mv	s3,a1
    80003c44:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003c46:	457c                	lw	a5,76(a0)
    80003c48:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003c4a:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003c4c:	e79d                	bnez	a5,80003c7a <dirlookup+0x54>
    80003c4e:	a8a5                	j	80003cc6 <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80003c50:	00005517          	auipc	a0,0x5
    80003c54:	99050513          	addi	a0,a0,-1648 # 800085e0 <syscalls+0x1b0>
    80003c58:	ffffd097          	auipc	ra,0xffffd
    80003c5c:	8d8080e7          	jalr	-1832(ra) # 80000530 <panic>
      panic("dirlookup read");
    80003c60:	00005517          	auipc	a0,0x5
    80003c64:	99850513          	addi	a0,a0,-1640 # 800085f8 <syscalls+0x1c8>
    80003c68:	ffffd097          	auipc	ra,0xffffd
    80003c6c:	8c8080e7          	jalr	-1848(ra) # 80000530 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003c70:	24c1                	addiw	s1,s1,16
    80003c72:	04c92783          	lw	a5,76(s2)
    80003c76:	04f4f763          	bgeu	s1,a5,80003cc4 <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003c7a:	4741                	li	a4,16
    80003c7c:	86a6                	mv	a3,s1
    80003c7e:	fc040613          	addi	a2,s0,-64
    80003c82:	4581                	li	a1,0
    80003c84:	854a                	mv	a0,s2
    80003c86:	00000097          	auipc	ra,0x0
    80003c8a:	d70080e7          	jalr	-656(ra) # 800039f6 <readi>
    80003c8e:	47c1                	li	a5,16
    80003c90:	fcf518e3          	bne	a0,a5,80003c60 <dirlookup+0x3a>
    if(de.inum == 0)
    80003c94:	fc045783          	lhu	a5,-64(s0)
    80003c98:	dfe1                	beqz	a5,80003c70 <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    80003c9a:	fc240593          	addi	a1,s0,-62
    80003c9e:	854e                	mv	a0,s3
    80003ca0:	00000097          	auipc	ra,0x0
    80003ca4:	f6c080e7          	jalr	-148(ra) # 80003c0c <namecmp>
    80003ca8:	f561                	bnez	a0,80003c70 <dirlookup+0x4a>
      if(poff)
    80003caa:	000a0463          	beqz	s4,80003cb2 <dirlookup+0x8c>
        *poff = off;
    80003cae:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80003cb2:	fc045583          	lhu	a1,-64(s0)
    80003cb6:	00092503          	lw	a0,0(s2)
    80003cba:	fffff097          	auipc	ra,0xfffff
    80003cbe:	754080e7          	jalr	1876(ra) # 8000340e <iget>
    80003cc2:	a011                	j	80003cc6 <dirlookup+0xa0>
  return 0;
    80003cc4:	4501                	li	a0,0
}
    80003cc6:	70e2                	ld	ra,56(sp)
    80003cc8:	7442                	ld	s0,48(sp)
    80003cca:	74a2                	ld	s1,40(sp)
    80003ccc:	7902                	ld	s2,32(sp)
    80003cce:	69e2                	ld	s3,24(sp)
    80003cd0:	6a42                	ld	s4,16(sp)
    80003cd2:	6121                	addi	sp,sp,64
    80003cd4:	8082                	ret

0000000080003cd6 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003cd6:	711d                	addi	sp,sp,-96
    80003cd8:	ec86                	sd	ra,88(sp)
    80003cda:	e8a2                	sd	s0,80(sp)
    80003cdc:	e4a6                	sd	s1,72(sp)
    80003cde:	e0ca                	sd	s2,64(sp)
    80003ce0:	fc4e                	sd	s3,56(sp)
    80003ce2:	f852                	sd	s4,48(sp)
    80003ce4:	f456                	sd	s5,40(sp)
    80003ce6:	f05a                	sd	s6,32(sp)
    80003ce8:	ec5e                	sd	s7,24(sp)
    80003cea:	e862                	sd	s8,16(sp)
    80003cec:	e466                	sd	s9,8(sp)
    80003cee:	1080                	addi	s0,sp,96
    80003cf0:	84aa                	mv	s1,a0
    80003cf2:	8b2e                	mv	s6,a1
    80003cf4:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003cf6:	00054703          	lbu	a4,0(a0)
    80003cfa:	02f00793          	li	a5,47
    80003cfe:	02f70363          	beq	a4,a5,80003d24 <namex+0x4e>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003d02:	ffffe097          	auipc	ra,0xffffe
    80003d06:	c92080e7          	jalr	-878(ra) # 80001994 <myproc>
    80003d0a:	15053503          	ld	a0,336(a0)
    80003d0e:	00000097          	auipc	ra,0x0
    80003d12:	9f6080e7          	jalr	-1546(ra) # 80003704 <idup>
    80003d16:	89aa                	mv	s3,a0
  while(*path == '/')
    80003d18:	02f00913          	li	s2,47
  len = path - s;
    80003d1c:	4b81                	li	s7,0
  if(len >= DIRSIZ)
    80003d1e:	4cb5                	li	s9,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003d20:	4c05                	li	s8,1
    80003d22:	a865                	j	80003dda <namex+0x104>
    ip = iget(ROOTDEV, ROOTINO);
    80003d24:	4585                	li	a1,1
    80003d26:	4505                	li	a0,1
    80003d28:	fffff097          	auipc	ra,0xfffff
    80003d2c:	6e6080e7          	jalr	1766(ra) # 8000340e <iget>
    80003d30:	89aa                	mv	s3,a0
    80003d32:	b7dd                	j	80003d18 <namex+0x42>
      iunlockput(ip);
    80003d34:	854e                	mv	a0,s3
    80003d36:	00000097          	auipc	ra,0x0
    80003d3a:	c6e080e7          	jalr	-914(ra) # 800039a4 <iunlockput>
      return 0;
    80003d3e:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003d40:	854e                	mv	a0,s3
    80003d42:	60e6                	ld	ra,88(sp)
    80003d44:	6446                	ld	s0,80(sp)
    80003d46:	64a6                	ld	s1,72(sp)
    80003d48:	6906                	ld	s2,64(sp)
    80003d4a:	79e2                	ld	s3,56(sp)
    80003d4c:	7a42                	ld	s4,48(sp)
    80003d4e:	7aa2                	ld	s5,40(sp)
    80003d50:	7b02                	ld	s6,32(sp)
    80003d52:	6be2                	ld	s7,24(sp)
    80003d54:	6c42                	ld	s8,16(sp)
    80003d56:	6ca2                	ld	s9,8(sp)
    80003d58:	6125                	addi	sp,sp,96
    80003d5a:	8082                	ret
      iunlock(ip);
    80003d5c:	854e                	mv	a0,s3
    80003d5e:	00000097          	auipc	ra,0x0
    80003d62:	aa6080e7          	jalr	-1370(ra) # 80003804 <iunlock>
      return ip;
    80003d66:	bfe9                	j	80003d40 <namex+0x6a>
      iunlockput(ip);
    80003d68:	854e                	mv	a0,s3
    80003d6a:	00000097          	auipc	ra,0x0
    80003d6e:	c3a080e7          	jalr	-966(ra) # 800039a4 <iunlockput>
      return 0;
    80003d72:	89d2                	mv	s3,s4
    80003d74:	b7f1                	j	80003d40 <namex+0x6a>
  len = path - s;
    80003d76:	40b48633          	sub	a2,s1,a1
    80003d7a:	00060a1b          	sext.w	s4,a2
  if(len >= DIRSIZ)
    80003d7e:	094cd463          	bge	s9,s4,80003e06 <namex+0x130>
    memmove(name, s, DIRSIZ);
    80003d82:	4639                	li	a2,14
    80003d84:	8556                	mv	a0,s5
    80003d86:	ffffd097          	auipc	ra,0xffffd
    80003d8a:	fac080e7          	jalr	-84(ra) # 80000d32 <memmove>
  while(*path == '/')
    80003d8e:	0004c783          	lbu	a5,0(s1)
    80003d92:	01279763          	bne	a5,s2,80003da0 <namex+0xca>
    path++;
    80003d96:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003d98:	0004c783          	lbu	a5,0(s1)
    80003d9c:	ff278de3          	beq	a5,s2,80003d96 <namex+0xc0>
    ilock(ip);
    80003da0:	854e                	mv	a0,s3
    80003da2:	00000097          	auipc	ra,0x0
    80003da6:	9a0080e7          	jalr	-1632(ra) # 80003742 <ilock>
    if(ip->type != T_DIR){
    80003daa:	04499783          	lh	a5,68(s3)
    80003dae:	f98793e3          	bne	a5,s8,80003d34 <namex+0x5e>
    if(nameiparent && *path == '\0'){
    80003db2:	000b0563          	beqz	s6,80003dbc <namex+0xe6>
    80003db6:	0004c783          	lbu	a5,0(s1)
    80003dba:	d3cd                	beqz	a5,80003d5c <namex+0x86>
    if((next = dirlookup(ip, name, 0)) == 0){
    80003dbc:	865e                	mv	a2,s7
    80003dbe:	85d6                	mv	a1,s5
    80003dc0:	854e                	mv	a0,s3
    80003dc2:	00000097          	auipc	ra,0x0
    80003dc6:	e64080e7          	jalr	-412(ra) # 80003c26 <dirlookup>
    80003dca:	8a2a                	mv	s4,a0
    80003dcc:	dd51                	beqz	a0,80003d68 <namex+0x92>
    iunlockput(ip);
    80003dce:	854e                	mv	a0,s3
    80003dd0:	00000097          	auipc	ra,0x0
    80003dd4:	bd4080e7          	jalr	-1068(ra) # 800039a4 <iunlockput>
    ip = next;
    80003dd8:	89d2                	mv	s3,s4
  while(*path == '/')
    80003dda:	0004c783          	lbu	a5,0(s1)
    80003dde:	05279763          	bne	a5,s2,80003e2c <namex+0x156>
    path++;
    80003de2:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003de4:	0004c783          	lbu	a5,0(s1)
    80003de8:	ff278de3          	beq	a5,s2,80003de2 <namex+0x10c>
  if(*path == 0)
    80003dec:	c79d                	beqz	a5,80003e1a <namex+0x144>
    path++;
    80003dee:	85a6                	mv	a1,s1
  len = path - s;
    80003df0:	8a5e                	mv	s4,s7
    80003df2:	865e                	mv	a2,s7
  while(*path != '/' && *path != 0)
    80003df4:	01278963          	beq	a5,s2,80003e06 <namex+0x130>
    80003df8:	dfbd                	beqz	a5,80003d76 <namex+0xa0>
    path++;
    80003dfa:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    80003dfc:	0004c783          	lbu	a5,0(s1)
    80003e00:	ff279ce3          	bne	a5,s2,80003df8 <namex+0x122>
    80003e04:	bf8d                	j	80003d76 <namex+0xa0>
    memmove(name, s, len);
    80003e06:	2601                	sext.w	a2,a2
    80003e08:	8556                	mv	a0,s5
    80003e0a:	ffffd097          	auipc	ra,0xffffd
    80003e0e:	f28080e7          	jalr	-216(ra) # 80000d32 <memmove>
    name[len] = 0;
    80003e12:	9a56                	add	s4,s4,s5
    80003e14:	000a0023          	sb	zero,0(s4)
    80003e18:	bf9d                	j	80003d8e <namex+0xb8>
  if(nameiparent){
    80003e1a:	f20b03e3          	beqz	s6,80003d40 <namex+0x6a>
    iput(ip);
    80003e1e:	854e                	mv	a0,s3
    80003e20:	00000097          	auipc	ra,0x0
    80003e24:	adc080e7          	jalr	-1316(ra) # 800038fc <iput>
    return 0;
    80003e28:	4981                	li	s3,0
    80003e2a:	bf19                	j	80003d40 <namex+0x6a>
  if(*path == 0)
    80003e2c:	d7fd                	beqz	a5,80003e1a <namex+0x144>
  while(*path != '/' && *path != 0)
    80003e2e:	0004c783          	lbu	a5,0(s1)
    80003e32:	85a6                	mv	a1,s1
    80003e34:	b7d1                	j	80003df8 <namex+0x122>

0000000080003e36 <dirlink>:
{
    80003e36:	7139                	addi	sp,sp,-64
    80003e38:	fc06                	sd	ra,56(sp)
    80003e3a:	f822                	sd	s0,48(sp)
    80003e3c:	f426                	sd	s1,40(sp)
    80003e3e:	f04a                	sd	s2,32(sp)
    80003e40:	ec4e                	sd	s3,24(sp)
    80003e42:	e852                	sd	s4,16(sp)
    80003e44:	0080                	addi	s0,sp,64
    80003e46:	892a                	mv	s2,a0
    80003e48:	8a2e                	mv	s4,a1
    80003e4a:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80003e4c:	4601                	li	a2,0
    80003e4e:	00000097          	auipc	ra,0x0
    80003e52:	dd8080e7          	jalr	-552(ra) # 80003c26 <dirlookup>
    80003e56:	e93d                	bnez	a0,80003ecc <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003e58:	04c92483          	lw	s1,76(s2)
    80003e5c:	c49d                	beqz	s1,80003e8a <dirlink+0x54>
    80003e5e:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003e60:	4741                	li	a4,16
    80003e62:	86a6                	mv	a3,s1
    80003e64:	fc040613          	addi	a2,s0,-64
    80003e68:	4581                	li	a1,0
    80003e6a:	854a                	mv	a0,s2
    80003e6c:	00000097          	auipc	ra,0x0
    80003e70:	b8a080e7          	jalr	-1142(ra) # 800039f6 <readi>
    80003e74:	47c1                	li	a5,16
    80003e76:	06f51163          	bne	a0,a5,80003ed8 <dirlink+0xa2>
    if(de.inum == 0)
    80003e7a:	fc045783          	lhu	a5,-64(s0)
    80003e7e:	c791                	beqz	a5,80003e8a <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003e80:	24c1                	addiw	s1,s1,16
    80003e82:	04c92783          	lw	a5,76(s2)
    80003e86:	fcf4ede3          	bltu	s1,a5,80003e60 <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    80003e8a:	4639                	li	a2,14
    80003e8c:	85d2                	mv	a1,s4
    80003e8e:	fc240513          	addi	a0,s0,-62
    80003e92:	ffffd097          	auipc	ra,0xffffd
    80003e96:	f58080e7          	jalr	-168(ra) # 80000dea <strncpy>
  de.inum = inum;
    80003e9a:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003e9e:	4741                	li	a4,16
    80003ea0:	86a6                	mv	a3,s1
    80003ea2:	fc040613          	addi	a2,s0,-64
    80003ea6:	4581                	li	a1,0
    80003ea8:	854a                	mv	a0,s2
    80003eaa:	00000097          	auipc	ra,0x0
    80003eae:	c44080e7          	jalr	-956(ra) # 80003aee <writei>
    80003eb2:	872a                	mv	a4,a0
    80003eb4:	47c1                	li	a5,16
  return 0;
    80003eb6:	4501                	li	a0,0
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003eb8:	02f71863          	bne	a4,a5,80003ee8 <dirlink+0xb2>
}
    80003ebc:	70e2                	ld	ra,56(sp)
    80003ebe:	7442                	ld	s0,48(sp)
    80003ec0:	74a2                	ld	s1,40(sp)
    80003ec2:	7902                	ld	s2,32(sp)
    80003ec4:	69e2                	ld	s3,24(sp)
    80003ec6:	6a42                	ld	s4,16(sp)
    80003ec8:	6121                	addi	sp,sp,64
    80003eca:	8082                	ret
    iput(ip);
    80003ecc:	00000097          	auipc	ra,0x0
    80003ed0:	a30080e7          	jalr	-1488(ra) # 800038fc <iput>
    return -1;
    80003ed4:	557d                	li	a0,-1
    80003ed6:	b7dd                	j	80003ebc <dirlink+0x86>
      panic("dirlink read");
    80003ed8:	00004517          	auipc	a0,0x4
    80003edc:	73050513          	addi	a0,a0,1840 # 80008608 <syscalls+0x1d8>
    80003ee0:	ffffc097          	auipc	ra,0xffffc
    80003ee4:	650080e7          	jalr	1616(ra) # 80000530 <panic>
    panic("dirlink");
    80003ee8:	00005517          	auipc	a0,0x5
    80003eec:	83050513          	addi	a0,a0,-2000 # 80008718 <syscalls+0x2e8>
    80003ef0:	ffffc097          	auipc	ra,0xffffc
    80003ef4:	640080e7          	jalr	1600(ra) # 80000530 <panic>

0000000080003ef8 <namei>:

struct inode*
namei(char *path)
{
    80003ef8:	1101                	addi	sp,sp,-32
    80003efa:	ec06                	sd	ra,24(sp)
    80003efc:	e822                	sd	s0,16(sp)
    80003efe:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80003f00:	fe040613          	addi	a2,s0,-32
    80003f04:	4581                	li	a1,0
    80003f06:	00000097          	auipc	ra,0x0
    80003f0a:	dd0080e7          	jalr	-560(ra) # 80003cd6 <namex>
}
    80003f0e:	60e2                	ld	ra,24(sp)
    80003f10:	6442                	ld	s0,16(sp)
    80003f12:	6105                	addi	sp,sp,32
    80003f14:	8082                	ret

0000000080003f16 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80003f16:	1141                	addi	sp,sp,-16
    80003f18:	e406                	sd	ra,8(sp)
    80003f1a:	e022                	sd	s0,0(sp)
    80003f1c:	0800                	addi	s0,sp,16
    80003f1e:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80003f20:	4585                	li	a1,1
    80003f22:	00000097          	auipc	ra,0x0
    80003f26:	db4080e7          	jalr	-588(ra) # 80003cd6 <namex>
}
    80003f2a:	60a2                	ld	ra,8(sp)
    80003f2c:	6402                	ld	s0,0(sp)
    80003f2e:	0141                	addi	sp,sp,16
    80003f30:	8082                	ret

0000000080003f32 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80003f32:	1101                	addi	sp,sp,-32
    80003f34:	ec06                	sd	ra,24(sp)
    80003f36:	e822                	sd	s0,16(sp)
    80003f38:	e426                	sd	s1,8(sp)
    80003f3a:	e04a                	sd	s2,0(sp)
    80003f3c:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80003f3e:	0001d917          	auipc	s2,0x1d
    80003f42:	53290913          	addi	s2,s2,1330 # 80021470 <log>
    80003f46:	01892583          	lw	a1,24(s2)
    80003f4a:	02892503          	lw	a0,40(s2)
    80003f4e:	fffff097          	auipc	ra,0xfffff
    80003f52:	ff2080e7          	jalr	-14(ra) # 80002f40 <bread>
    80003f56:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80003f58:	02c92683          	lw	a3,44(s2)
    80003f5c:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80003f5e:	02d05763          	blez	a3,80003f8c <write_head+0x5a>
    80003f62:	0001d797          	auipc	a5,0x1d
    80003f66:	53e78793          	addi	a5,a5,1342 # 800214a0 <log+0x30>
    80003f6a:	05c50713          	addi	a4,a0,92
    80003f6e:	36fd                	addiw	a3,a3,-1
    80003f70:	1682                	slli	a3,a3,0x20
    80003f72:	9281                	srli	a3,a3,0x20
    80003f74:	068a                	slli	a3,a3,0x2
    80003f76:	0001d617          	auipc	a2,0x1d
    80003f7a:	52e60613          	addi	a2,a2,1326 # 800214a4 <log+0x34>
    80003f7e:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    80003f80:	4390                	lw	a2,0(a5)
    80003f82:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80003f84:	0791                	addi	a5,a5,4
    80003f86:	0711                	addi	a4,a4,4
    80003f88:	fed79ce3          	bne	a5,a3,80003f80 <write_head+0x4e>
  }
  bwrite(buf);
    80003f8c:	8526                	mv	a0,s1
    80003f8e:	fffff097          	auipc	ra,0xfffff
    80003f92:	0a4080e7          	jalr	164(ra) # 80003032 <bwrite>
  brelse(buf);
    80003f96:	8526                	mv	a0,s1
    80003f98:	fffff097          	auipc	ra,0xfffff
    80003f9c:	0d8080e7          	jalr	216(ra) # 80003070 <brelse>
}
    80003fa0:	60e2                	ld	ra,24(sp)
    80003fa2:	6442                	ld	s0,16(sp)
    80003fa4:	64a2                	ld	s1,8(sp)
    80003fa6:	6902                	ld	s2,0(sp)
    80003fa8:	6105                	addi	sp,sp,32
    80003faa:	8082                	ret

0000000080003fac <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80003fac:	0001d797          	auipc	a5,0x1d
    80003fb0:	4f07a783          	lw	a5,1264(a5) # 8002149c <log+0x2c>
    80003fb4:	0af05d63          	blez	a5,8000406e <install_trans+0xc2>
{
    80003fb8:	7139                	addi	sp,sp,-64
    80003fba:	fc06                	sd	ra,56(sp)
    80003fbc:	f822                	sd	s0,48(sp)
    80003fbe:	f426                	sd	s1,40(sp)
    80003fc0:	f04a                	sd	s2,32(sp)
    80003fc2:	ec4e                	sd	s3,24(sp)
    80003fc4:	e852                	sd	s4,16(sp)
    80003fc6:	e456                	sd	s5,8(sp)
    80003fc8:	e05a                	sd	s6,0(sp)
    80003fca:	0080                	addi	s0,sp,64
    80003fcc:	8b2a                	mv	s6,a0
    80003fce:	0001da97          	auipc	s5,0x1d
    80003fd2:	4d2a8a93          	addi	s5,s5,1234 # 800214a0 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003fd6:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003fd8:	0001d997          	auipc	s3,0x1d
    80003fdc:	49898993          	addi	s3,s3,1176 # 80021470 <log>
    80003fe0:	a035                	j	8000400c <install_trans+0x60>
      bunpin(dbuf);
    80003fe2:	8526                	mv	a0,s1
    80003fe4:	fffff097          	auipc	ra,0xfffff
    80003fe8:	166080e7          	jalr	358(ra) # 8000314a <bunpin>
    brelse(lbuf);
    80003fec:	854a                	mv	a0,s2
    80003fee:	fffff097          	auipc	ra,0xfffff
    80003ff2:	082080e7          	jalr	130(ra) # 80003070 <brelse>
    brelse(dbuf);
    80003ff6:	8526                	mv	a0,s1
    80003ff8:	fffff097          	auipc	ra,0xfffff
    80003ffc:	078080e7          	jalr	120(ra) # 80003070 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004000:	2a05                	addiw	s4,s4,1
    80004002:	0a91                	addi	s5,s5,4
    80004004:	02c9a783          	lw	a5,44(s3)
    80004008:	04fa5963          	bge	s4,a5,8000405a <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    8000400c:	0189a583          	lw	a1,24(s3)
    80004010:	014585bb          	addw	a1,a1,s4
    80004014:	2585                	addiw	a1,a1,1
    80004016:	0289a503          	lw	a0,40(s3)
    8000401a:	fffff097          	auipc	ra,0xfffff
    8000401e:	f26080e7          	jalr	-218(ra) # 80002f40 <bread>
    80004022:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80004024:	000aa583          	lw	a1,0(s5)
    80004028:	0289a503          	lw	a0,40(s3)
    8000402c:	fffff097          	auipc	ra,0xfffff
    80004030:	f14080e7          	jalr	-236(ra) # 80002f40 <bread>
    80004034:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80004036:	40000613          	li	a2,1024
    8000403a:	05890593          	addi	a1,s2,88
    8000403e:	05850513          	addi	a0,a0,88
    80004042:	ffffd097          	auipc	ra,0xffffd
    80004046:	cf0080e7          	jalr	-784(ra) # 80000d32 <memmove>
    bwrite(dbuf);  // write dst to disk
    8000404a:	8526                	mv	a0,s1
    8000404c:	fffff097          	auipc	ra,0xfffff
    80004050:	fe6080e7          	jalr	-26(ra) # 80003032 <bwrite>
    if(recovering == 0)
    80004054:	f80b1ce3          	bnez	s6,80003fec <install_trans+0x40>
    80004058:	b769                	j	80003fe2 <install_trans+0x36>
}
    8000405a:	70e2                	ld	ra,56(sp)
    8000405c:	7442                	ld	s0,48(sp)
    8000405e:	74a2                	ld	s1,40(sp)
    80004060:	7902                	ld	s2,32(sp)
    80004062:	69e2                	ld	s3,24(sp)
    80004064:	6a42                	ld	s4,16(sp)
    80004066:	6aa2                	ld	s5,8(sp)
    80004068:	6b02                	ld	s6,0(sp)
    8000406a:	6121                	addi	sp,sp,64
    8000406c:	8082                	ret
    8000406e:	8082                	ret

0000000080004070 <initlog>:
{
    80004070:	7179                	addi	sp,sp,-48
    80004072:	f406                	sd	ra,40(sp)
    80004074:	f022                	sd	s0,32(sp)
    80004076:	ec26                	sd	s1,24(sp)
    80004078:	e84a                	sd	s2,16(sp)
    8000407a:	e44e                	sd	s3,8(sp)
    8000407c:	1800                	addi	s0,sp,48
    8000407e:	892a                	mv	s2,a0
    80004080:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80004082:	0001d497          	auipc	s1,0x1d
    80004086:	3ee48493          	addi	s1,s1,1006 # 80021470 <log>
    8000408a:	00004597          	auipc	a1,0x4
    8000408e:	58e58593          	addi	a1,a1,1422 # 80008618 <syscalls+0x1e8>
    80004092:	8526                	mv	a0,s1
    80004094:	ffffd097          	auipc	ra,0xffffd
    80004098:	ab2080e7          	jalr	-1358(ra) # 80000b46 <initlock>
  log.start = sb->logstart;
    8000409c:	0149a583          	lw	a1,20(s3)
    800040a0:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    800040a2:	0109a783          	lw	a5,16(s3)
    800040a6:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    800040a8:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    800040ac:	854a                	mv	a0,s2
    800040ae:	fffff097          	auipc	ra,0xfffff
    800040b2:	e92080e7          	jalr	-366(ra) # 80002f40 <bread>
  log.lh.n = lh->n;
    800040b6:	4d3c                	lw	a5,88(a0)
    800040b8:	d4dc                	sw	a5,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    800040ba:	02f05563          	blez	a5,800040e4 <initlog+0x74>
    800040be:	05c50713          	addi	a4,a0,92
    800040c2:	0001d697          	auipc	a3,0x1d
    800040c6:	3de68693          	addi	a3,a3,990 # 800214a0 <log+0x30>
    800040ca:	37fd                	addiw	a5,a5,-1
    800040cc:	1782                	slli	a5,a5,0x20
    800040ce:	9381                	srli	a5,a5,0x20
    800040d0:	078a                	slli	a5,a5,0x2
    800040d2:	06050613          	addi	a2,a0,96
    800040d6:	97b2                	add	a5,a5,a2
    log.lh.block[i] = lh->block[i];
    800040d8:	4310                	lw	a2,0(a4)
    800040da:	c290                	sw	a2,0(a3)
  for (i = 0; i < log.lh.n; i++) {
    800040dc:	0711                	addi	a4,a4,4
    800040de:	0691                	addi	a3,a3,4
    800040e0:	fef71ce3          	bne	a4,a5,800040d8 <initlog+0x68>
  brelse(buf);
    800040e4:	fffff097          	auipc	ra,0xfffff
    800040e8:	f8c080e7          	jalr	-116(ra) # 80003070 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    800040ec:	4505                	li	a0,1
    800040ee:	00000097          	auipc	ra,0x0
    800040f2:	ebe080e7          	jalr	-322(ra) # 80003fac <install_trans>
  log.lh.n = 0;
    800040f6:	0001d797          	auipc	a5,0x1d
    800040fa:	3a07a323          	sw	zero,934(a5) # 8002149c <log+0x2c>
  write_head(); // clear the log
    800040fe:	00000097          	auipc	ra,0x0
    80004102:	e34080e7          	jalr	-460(ra) # 80003f32 <write_head>
}
    80004106:	70a2                	ld	ra,40(sp)
    80004108:	7402                	ld	s0,32(sp)
    8000410a:	64e2                	ld	s1,24(sp)
    8000410c:	6942                	ld	s2,16(sp)
    8000410e:	69a2                	ld	s3,8(sp)
    80004110:	6145                	addi	sp,sp,48
    80004112:	8082                	ret

0000000080004114 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80004114:	1101                	addi	sp,sp,-32
    80004116:	ec06                	sd	ra,24(sp)
    80004118:	e822                	sd	s0,16(sp)
    8000411a:	e426                	sd	s1,8(sp)
    8000411c:	e04a                	sd	s2,0(sp)
    8000411e:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80004120:	0001d517          	auipc	a0,0x1d
    80004124:	35050513          	addi	a0,a0,848 # 80021470 <log>
    80004128:	ffffd097          	auipc	ra,0xffffd
    8000412c:	aae080e7          	jalr	-1362(ra) # 80000bd6 <acquire>
  while(1){
    if(log.committing){
    80004130:	0001d497          	auipc	s1,0x1d
    80004134:	34048493          	addi	s1,s1,832 # 80021470 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004138:	4979                	li	s2,30
    8000413a:	a039                	j	80004148 <begin_op+0x34>
      sleep(&log, &log.lock);
    8000413c:	85a6                	mv	a1,s1
    8000413e:	8526                	mv	a0,s1
    80004140:	ffffe097          	auipc	ra,0xffffe
    80004144:	f6c080e7          	jalr	-148(ra) # 800020ac <sleep>
    if(log.committing){
    80004148:	50dc                	lw	a5,36(s1)
    8000414a:	fbed                	bnez	a5,8000413c <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    8000414c:	509c                	lw	a5,32(s1)
    8000414e:	0017871b          	addiw	a4,a5,1
    80004152:	0007069b          	sext.w	a3,a4
    80004156:	0027179b          	slliw	a5,a4,0x2
    8000415a:	9fb9                	addw	a5,a5,a4
    8000415c:	0017979b          	slliw	a5,a5,0x1
    80004160:	54d8                	lw	a4,44(s1)
    80004162:	9fb9                	addw	a5,a5,a4
    80004164:	00f95963          	bge	s2,a5,80004176 <begin_op+0x62>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80004168:	85a6                	mv	a1,s1
    8000416a:	8526                	mv	a0,s1
    8000416c:	ffffe097          	auipc	ra,0xffffe
    80004170:	f40080e7          	jalr	-192(ra) # 800020ac <sleep>
    80004174:	bfd1                	j	80004148 <begin_op+0x34>
    } else {
      log.outstanding += 1;
    80004176:	0001d517          	auipc	a0,0x1d
    8000417a:	2fa50513          	addi	a0,a0,762 # 80021470 <log>
    8000417e:	d114                	sw	a3,32(a0)
      release(&log.lock);
    80004180:	ffffd097          	auipc	ra,0xffffd
    80004184:	b0a080e7          	jalr	-1270(ra) # 80000c8a <release>
      break;
    }
  }
}
    80004188:	60e2                	ld	ra,24(sp)
    8000418a:	6442                	ld	s0,16(sp)
    8000418c:	64a2                	ld	s1,8(sp)
    8000418e:	6902                	ld	s2,0(sp)
    80004190:	6105                	addi	sp,sp,32
    80004192:	8082                	ret

0000000080004194 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80004194:	7139                	addi	sp,sp,-64
    80004196:	fc06                	sd	ra,56(sp)
    80004198:	f822                	sd	s0,48(sp)
    8000419a:	f426                	sd	s1,40(sp)
    8000419c:	f04a                	sd	s2,32(sp)
    8000419e:	ec4e                	sd	s3,24(sp)
    800041a0:	e852                	sd	s4,16(sp)
    800041a2:	e456                	sd	s5,8(sp)
    800041a4:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    800041a6:	0001d497          	auipc	s1,0x1d
    800041aa:	2ca48493          	addi	s1,s1,714 # 80021470 <log>
    800041ae:	8526                	mv	a0,s1
    800041b0:	ffffd097          	auipc	ra,0xffffd
    800041b4:	a26080e7          	jalr	-1498(ra) # 80000bd6 <acquire>
  log.outstanding -= 1;
    800041b8:	509c                	lw	a5,32(s1)
    800041ba:	37fd                	addiw	a5,a5,-1
    800041bc:	0007891b          	sext.w	s2,a5
    800041c0:	d09c                	sw	a5,32(s1)
  if(log.committing)
    800041c2:	50dc                	lw	a5,36(s1)
    800041c4:	efb9                	bnez	a5,80004222 <end_op+0x8e>
    panic("log.committing");
  if(log.outstanding == 0){
    800041c6:	06091663          	bnez	s2,80004232 <end_op+0x9e>
    do_commit = 1;
    log.committing = 1;
    800041ca:	0001d497          	auipc	s1,0x1d
    800041ce:	2a648493          	addi	s1,s1,678 # 80021470 <log>
    800041d2:	4785                	li	a5,1
    800041d4:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    800041d6:	8526                	mv	a0,s1
    800041d8:	ffffd097          	auipc	ra,0xffffd
    800041dc:	ab2080e7          	jalr	-1358(ra) # 80000c8a <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    800041e0:	54dc                	lw	a5,44(s1)
    800041e2:	06f04763          	bgtz	a5,80004250 <end_op+0xbc>
    acquire(&log.lock);
    800041e6:	0001d497          	auipc	s1,0x1d
    800041ea:	28a48493          	addi	s1,s1,650 # 80021470 <log>
    800041ee:	8526                	mv	a0,s1
    800041f0:	ffffd097          	auipc	ra,0xffffd
    800041f4:	9e6080e7          	jalr	-1562(ra) # 80000bd6 <acquire>
    log.committing = 0;
    800041f8:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    800041fc:	8526                	mv	a0,s1
    800041fe:	ffffe097          	auipc	ra,0xffffe
    80004202:	03a080e7          	jalr	58(ra) # 80002238 <wakeup>
    release(&log.lock);
    80004206:	8526                	mv	a0,s1
    80004208:	ffffd097          	auipc	ra,0xffffd
    8000420c:	a82080e7          	jalr	-1406(ra) # 80000c8a <release>
}
    80004210:	70e2                	ld	ra,56(sp)
    80004212:	7442                	ld	s0,48(sp)
    80004214:	74a2                	ld	s1,40(sp)
    80004216:	7902                	ld	s2,32(sp)
    80004218:	69e2                	ld	s3,24(sp)
    8000421a:	6a42                	ld	s4,16(sp)
    8000421c:	6aa2                	ld	s5,8(sp)
    8000421e:	6121                	addi	sp,sp,64
    80004220:	8082                	ret
    panic("log.committing");
    80004222:	00004517          	auipc	a0,0x4
    80004226:	3fe50513          	addi	a0,a0,1022 # 80008620 <syscalls+0x1f0>
    8000422a:	ffffc097          	auipc	ra,0xffffc
    8000422e:	306080e7          	jalr	774(ra) # 80000530 <panic>
    wakeup(&log);
    80004232:	0001d497          	auipc	s1,0x1d
    80004236:	23e48493          	addi	s1,s1,574 # 80021470 <log>
    8000423a:	8526                	mv	a0,s1
    8000423c:	ffffe097          	auipc	ra,0xffffe
    80004240:	ffc080e7          	jalr	-4(ra) # 80002238 <wakeup>
  release(&log.lock);
    80004244:	8526                	mv	a0,s1
    80004246:	ffffd097          	auipc	ra,0xffffd
    8000424a:	a44080e7          	jalr	-1468(ra) # 80000c8a <release>
  if(do_commit){
    8000424e:	b7c9                	j	80004210 <end_op+0x7c>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004250:	0001da97          	auipc	s5,0x1d
    80004254:	250a8a93          	addi	s5,s5,592 # 800214a0 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80004258:	0001da17          	auipc	s4,0x1d
    8000425c:	218a0a13          	addi	s4,s4,536 # 80021470 <log>
    80004260:	018a2583          	lw	a1,24(s4)
    80004264:	012585bb          	addw	a1,a1,s2
    80004268:	2585                	addiw	a1,a1,1
    8000426a:	028a2503          	lw	a0,40(s4)
    8000426e:	fffff097          	auipc	ra,0xfffff
    80004272:	cd2080e7          	jalr	-814(ra) # 80002f40 <bread>
    80004276:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80004278:	000aa583          	lw	a1,0(s5)
    8000427c:	028a2503          	lw	a0,40(s4)
    80004280:	fffff097          	auipc	ra,0xfffff
    80004284:	cc0080e7          	jalr	-832(ra) # 80002f40 <bread>
    80004288:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    8000428a:	40000613          	li	a2,1024
    8000428e:	05850593          	addi	a1,a0,88
    80004292:	05848513          	addi	a0,s1,88
    80004296:	ffffd097          	auipc	ra,0xffffd
    8000429a:	a9c080e7          	jalr	-1380(ra) # 80000d32 <memmove>
    bwrite(to);  // write the log
    8000429e:	8526                	mv	a0,s1
    800042a0:	fffff097          	auipc	ra,0xfffff
    800042a4:	d92080e7          	jalr	-622(ra) # 80003032 <bwrite>
    brelse(from);
    800042a8:	854e                	mv	a0,s3
    800042aa:	fffff097          	auipc	ra,0xfffff
    800042ae:	dc6080e7          	jalr	-570(ra) # 80003070 <brelse>
    brelse(to);
    800042b2:	8526                	mv	a0,s1
    800042b4:	fffff097          	auipc	ra,0xfffff
    800042b8:	dbc080e7          	jalr	-580(ra) # 80003070 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800042bc:	2905                	addiw	s2,s2,1
    800042be:	0a91                	addi	s5,s5,4
    800042c0:	02ca2783          	lw	a5,44(s4)
    800042c4:	f8f94ee3          	blt	s2,a5,80004260 <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    800042c8:	00000097          	auipc	ra,0x0
    800042cc:	c6a080e7          	jalr	-918(ra) # 80003f32 <write_head>
    install_trans(0); // Now install writes to home locations
    800042d0:	4501                	li	a0,0
    800042d2:	00000097          	auipc	ra,0x0
    800042d6:	cda080e7          	jalr	-806(ra) # 80003fac <install_trans>
    log.lh.n = 0;
    800042da:	0001d797          	auipc	a5,0x1d
    800042de:	1c07a123          	sw	zero,450(a5) # 8002149c <log+0x2c>
    write_head();    // Erase the transaction from the log
    800042e2:	00000097          	auipc	ra,0x0
    800042e6:	c50080e7          	jalr	-944(ra) # 80003f32 <write_head>
    800042ea:	bdf5                	j	800041e6 <end_op+0x52>

00000000800042ec <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    800042ec:	1101                	addi	sp,sp,-32
    800042ee:	ec06                	sd	ra,24(sp)
    800042f0:	e822                	sd	s0,16(sp)
    800042f2:	e426                	sd	s1,8(sp)
    800042f4:	e04a                	sd	s2,0(sp)
    800042f6:	1000                	addi	s0,sp,32
    800042f8:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    800042fa:	0001d917          	auipc	s2,0x1d
    800042fe:	17690913          	addi	s2,s2,374 # 80021470 <log>
    80004302:	854a                	mv	a0,s2
    80004304:	ffffd097          	auipc	ra,0xffffd
    80004308:	8d2080e7          	jalr	-1838(ra) # 80000bd6 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    8000430c:	02c92603          	lw	a2,44(s2)
    80004310:	47f5                	li	a5,29
    80004312:	06c7c563          	blt	a5,a2,8000437c <log_write+0x90>
    80004316:	0001d797          	auipc	a5,0x1d
    8000431a:	1767a783          	lw	a5,374(a5) # 8002148c <log+0x1c>
    8000431e:	37fd                	addiw	a5,a5,-1
    80004320:	04f65e63          	bge	a2,a5,8000437c <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80004324:	0001d797          	auipc	a5,0x1d
    80004328:	16c7a783          	lw	a5,364(a5) # 80021490 <log+0x20>
    8000432c:	06f05063          	blez	a5,8000438c <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80004330:	4781                	li	a5,0
    80004332:	06c05563          	blez	a2,8000439c <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
    80004336:	44cc                	lw	a1,12(s1)
    80004338:	0001d717          	auipc	a4,0x1d
    8000433c:	16870713          	addi	a4,a4,360 # 800214a0 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    80004340:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorbtion
    80004342:	4314                	lw	a3,0(a4)
    80004344:	04b68c63          	beq	a3,a1,8000439c <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    80004348:	2785                	addiw	a5,a5,1
    8000434a:	0711                	addi	a4,a4,4
    8000434c:	fef61be3          	bne	a2,a5,80004342 <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    80004350:	0621                	addi	a2,a2,8
    80004352:	060a                	slli	a2,a2,0x2
    80004354:	0001d797          	auipc	a5,0x1d
    80004358:	11c78793          	addi	a5,a5,284 # 80021470 <log>
    8000435c:	963e                	add	a2,a2,a5
    8000435e:	44dc                	lw	a5,12(s1)
    80004360:	ca1c                	sw	a5,16(a2)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80004362:	8526                	mv	a0,s1
    80004364:	fffff097          	auipc	ra,0xfffff
    80004368:	daa080e7          	jalr	-598(ra) # 8000310e <bpin>
    log.lh.n++;
    8000436c:	0001d717          	auipc	a4,0x1d
    80004370:	10470713          	addi	a4,a4,260 # 80021470 <log>
    80004374:	575c                	lw	a5,44(a4)
    80004376:	2785                	addiw	a5,a5,1
    80004378:	d75c                	sw	a5,44(a4)
    8000437a:	a835                	j	800043b6 <log_write+0xca>
    panic("too big a transaction");
    8000437c:	00004517          	auipc	a0,0x4
    80004380:	2b450513          	addi	a0,a0,692 # 80008630 <syscalls+0x200>
    80004384:	ffffc097          	auipc	ra,0xffffc
    80004388:	1ac080e7          	jalr	428(ra) # 80000530 <panic>
    panic("log_write outside of trans");
    8000438c:	00004517          	auipc	a0,0x4
    80004390:	2bc50513          	addi	a0,a0,700 # 80008648 <syscalls+0x218>
    80004394:	ffffc097          	auipc	ra,0xffffc
    80004398:	19c080e7          	jalr	412(ra) # 80000530 <panic>
  log.lh.block[i] = b->blockno;
    8000439c:	00878713          	addi	a4,a5,8
    800043a0:	00271693          	slli	a3,a4,0x2
    800043a4:	0001d717          	auipc	a4,0x1d
    800043a8:	0cc70713          	addi	a4,a4,204 # 80021470 <log>
    800043ac:	9736                	add	a4,a4,a3
    800043ae:	44d4                	lw	a3,12(s1)
    800043b0:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    800043b2:	faf608e3          	beq	a2,a5,80004362 <log_write+0x76>
  }
  release(&log.lock);
    800043b6:	0001d517          	auipc	a0,0x1d
    800043ba:	0ba50513          	addi	a0,a0,186 # 80021470 <log>
    800043be:	ffffd097          	auipc	ra,0xffffd
    800043c2:	8cc080e7          	jalr	-1844(ra) # 80000c8a <release>
}
    800043c6:	60e2                	ld	ra,24(sp)
    800043c8:	6442                	ld	s0,16(sp)
    800043ca:	64a2                	ld	s1,8(sp)
    800043cc:	6902                	ld	s2,0(sp)
    800043ce:	6105                	addi	sp,sp,32
    800043d0:	8082                	ret

00000000800043d2 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    800043d2:	1101                	addi	sp,sp,-32
    800043d4:	ec06                	sd	ra,24(sp)
    800043d6:	e822                	sd	s0,16(sp)
    800043d8:	e426                	sd	s1,8(sp)
    800043da:	e04a                	sd	s2,0(sp)
    800043dc:	1000                	addi	s0,sp,32
    800043de:	84aa                	mv	s1,a0
    800043e0:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    800043e2:	00004597          	auipc	a1,0x4
    800043e6:	28658593          	addi	a1,a1,646 # 80008668 <syscalls+0x238>
    800043ea:	0521                	addi	a0,a0,8
    800043ec:	ffffc097          	auipc	ra,0xffffc
    800043f0:	75a080e7          	jalr	1882(ra) # 80000b46 <initlock>
  lk->name = name;
    800043f4:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    800043f8:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800043fc:	0204a423          	sw	zero,40(s1)
}
    80004400:	60e2                	ld	ra,24(sp)
    80004402:	6442                	ld	s0,16(sp)
    80004404:	64a2                	ld	s1,8(sp)
    80004406:	6902                	ld	s2,0(sp)
    80004408:	6105                	addi	sp,sp,32
    8000440a:	8082                	ret

000000008000440c <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    8000440c:	1101                	addi	sp,sp,-32
    8000440e:	ec06                	sd	ra,24(sp)
    80004410:	e822                	sd	s0,16(sp)
    80004412:	e426                	sd	s1,8(sp)
    80004414:	e04a                	sd	s2,0(sp)
    80004416:	1000                	addi	s0,sp,32
    80004418:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    8000441a:	00850913          	addi	s2,a0,8
    8000441e:	854a                	mv	a0,s2
    80004420:	ffffc097          	auipc	ra,0xffffc
    80004424:	7b6080e7          	jalr	1974(ra) # 80000bd6 <acquire>
  while (lk->locked) {
    80004428:	409c                	lw	a5,0(s1)
    8000442a:	cb89                	beqz	a5,8000443c <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    8000442c:	85ca                	mv	a1,s2
    8000442e:	8526                	mv	a0,s1
    80004430:	ffffe097          	auipc	ra,0xffffe
    80004434:	c7c080e7          	jalr	-900(ra) # 800020ac <sleep>
  while (lk->locked) {
    80004438:	409c                	lw	a5,0(s1)
    8000443a:	fbed                	bnez	a5,8000442c <acquiresleep+0x20>
  }
  lk->locked = 1;
    8000443c:	4785                	li	a5,1
    8000443e:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80004440:	ffffd097          	auipc	ra,0xffffd
    80004444:	554080e7          	jalr	1364(ra) # 80001994 <myproc>
    80004448:	591c                	lw	a5,48(a0)
    8000444a:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    8000444c:	854a                	mv	a0,s2
    8000444e:	ffffd097          	auipc	ra,0xffffd
    80004452:	83c080e7          	jalr	-1988(ra) # 80000c8a <release>
}
    80004456:	60e2                	ld	ra,24(sp)
    80004458:	6442                	ld	s0,16(sp)
    8000445a:	64a2                	ld	s1,8(sp)
    8000445c:	6902                	ld	s2,0(sp)
    8000445e:	6105                	addi	sp,sp,32
    80004460:	8082                	ret

0000000080004462 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80004462:	1101                	addi	sp,sp,-32
    80004464:	ec06                	sd	ra,24(sp)
    80004466:	e822                	sd	s0,16(sp)
    80004468:	e426                	sd	s1,8(sp)
    8000446a:	e04a                	sd	s2,0(sp)
    8000446c:	1000                	addi	s0,sp,32
    8000446e:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004470:	00850913          	addi	s2,a0,8
    80004474:	854a                	mv	a0,s2
    80004476:	ffffc097          	auipc	ra,0xffffc
    8000447a:	760080e7          	jalr	1888(ra) # 80000bd6 <acquire>
  lk->locked = 0;
    8000447e:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004482:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80004486:	8526                	mv	a0,s1
    80004488:	ffffe097          	auipc	ra,0xffffe
    8000448c:	db0080e7          	jalr	-592(ra) # 80002238 <wakeup>
  release(&lk->lk);
    80004490:	854a                	mv	a0,s2
    80004492:	ffffc097          	auipc	ra,0xffffc
    80004496:	7f8080e7          	jalr	2040(ra) # 80000c8a <release>
}
    8000449a:	60e2                	ld	ra,24(sp)
    8000449c:	6442                	ld	s0,16(sp)
    8000449e:	64a2                	ld	s1,8(sp)
    800044a0:	6902                	ld	s2,0(sp)
    800044a2:	6105                	addi	sp,sp,32
    800044a4:	8082                	ret

00000000800044a6 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    800044a6:	7179                	addi	sp,sp,-48
    800044a8:	f406                	sd	ra,40(sp)
    800044aa:	f022                	sd	s0,32(sp)
    800044ac:	ec26                	sd	s1,24(sp)
    800044ae:	e84a                	sd	s2,16(sp)
    800044b0:	e44e                	sd	s3,8(sp)
    800044b2:	1800                	addi	s0,sp,48
    800044b4:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    800044b6:	00850913          	addi	s2,a0,8
    800044ba:	854a                	mv	a0,s2
    800044bc:	ffffc097          	auipc	ra,0xffffc
    800044c0:	71a080e7          	jalr	1818(ra) # 80000bd6 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    800044c4:	409c                	lw	a5,0(s1)
    800044c6:	ef99                	bnez	a5,800044e4 <holdingsleep+0x3e>
    800044c8:	4481                	li	s1,0
  release(&lk->lk);
    800044ca:	854a                	mv	a0,s2
    800044cc:	ffffc097          	auipc	ra,0xffffc
    800044d0:	7be080e7          	jalr	1982(ra) # 80000c8a <release>
  return r;
}
    800044d4:	8526                	mv	a0,s1
    800044d6:	70a2                	ld	ra,40(sp)
    800044d8:	7402                	ld	s0,32(sp)
    800044da:	64e2                	ld	s1,24(sp)
    800044dc:	6942                	ld	s2,16(sp)
    800044de:	69a2                	ld	s3,8(sp)
    800044e0:	6145                	addi	sp,sp,48
    800044e2:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    800044e4:	0284a983          	lw	s3,40(s1)
    800044e8:	ffffd097          	auipc	ra,0xffffd
    800044ec:	4ac080e7          	jalr	1196(ra) # 80001994 <myproc>
    800044f0:	5904                	lw	s1,48(a0)
    800044f2:	413484b3          	sub	s1,s1,s3
    800044f6:	0014b493          	seqz	s1,s1
    800044fa:	bfc1                	j	800044ca <holdingsleep+0x24>

00000000800044fc <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    800044fc:	1141                	addi	sp,sp,-16
    800044fe:	e406                	sd	ra,8(sp)
    80004500:	e022                	sd	s0,0(sp)
    80004502:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80004504:	00004597          	auipc	a1,0x4
    80004508:	17458593          	addi	a1,a1,372 # 80008678 <syscalls+0x248>
    8000450c:	0001d517          	auipc	a0,0x1d
    80004510:	0ac50513          	addi	a0,a0,172 # 800215b8 <ftable>
    80004514:	ffffc097          	auipc	ra,0xffffc
    80004518:	632080e7          	jalr	1586(ra) # 80000b46 <initlock>
}
    8000451c:	60a2                	ld	ra,8(sp)
    8000451e:	6402                	ld	s0,0(sp)
    80004520:	0141                	addi	sp,sp,16
    80004522:	8082                	ret

0000000080004524 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80004524:	1101                	addi	sp,sp,-32
    80004526:	ec06                	sd	ra,24(sp)
    80004528:	e822                	sd	s0,16(sp)
    8000452a:	e426                	sd	s1,8(sp)
    8000452c:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    8000452e:	0001d517          	auipc	a0,0x1d
    80004532:	08a50513          	addi	a0,a0,138 # 800215b8 <ftable>
    80004536:	ffffc097          	auipc	ra,0xffffc
    8000453a:	6a0080e7          	jalr	1696(ra) # 80000bd6 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    8000453e:	0001d497          	auipc	s1,0x1d
    80004542:	09248493          	addi	s1,s1,146 # 800215d0 <ftable+0x18>
    80004546:	0001e717          	auipc	a4,0x1e
    8000454a:	02a70713          	addi	a4,a4,42 # 80022570 <ftable+0xfb8>
    if(f->ref == 0){
    8000454e:	40dc                	lw	a5,4(s1)
    80004550:	cf99                	beqz	a5,8000456e <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004552:	02848493          	addi	s1,s1,40
    80004556:	fee49ce3          	bne	s1,a4,8000454e <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    8000455a:	0001d517          	auipc	a0,0x1d
    8000455e:	05e50513          	addi	a0,a0,94 # 800215b8 <ftable>
    80004562:	ffffc097          	auipc	ra,0xffffc
    80004566:	728080e7          	jalr	1832(ra) # 80000c8a <release>
  return 0;
    8000456a:	4481                	li	s1,0
    8000456c:	a819                	j	80004582 <filealloc+0x5e>
      f->ref = 1;
    8000456e:	4785                	li	a5,1
    80004570:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80004572:	0001d517          	auipc	a0,0x1d
    80004576:	04650513          	addi	a0,a0,70 # 800215b8 <ftable>
    8000457a:	ffffc097          	auipc	ra,0xffffc
    8000457e:	710080e7          	jalr	1808(ra) # 80000c8a <release>
}
    80004582:	8526                	mv	a0,s1
    80004584:	60e2                	ld	ra,24(sp)
    80004586:	6442                	ld	s0,16(sp)
    80004588:	64a2                	ld	s1,8(sp)
    8000458a:	6105                	addi	sp,sp,32
    8000458c:	8082                	ret

000000008000458e <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    8000458e:	1101                	addi	sp,sp,-32
    80004590:	ec06                	sd	ra,24(sp)
    80004592:	e822                	sd	s0,16(sp)
    80004594:	e426                	sd	s1,8(sp)
    80004596:	1000                	addi	s0,sp,32
    80004598:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    8000459a:	0001d517          	auipc	a0,0x1d
    8000459e:	01e50513          	addi	a0,a0,30 # 800215b8 <ftable>
    800045a2:	ffffc097          	auipc	ra,0xffffc
    800045a6:	634080e7          	jalr	1588(ra) # 80000bd6 <acquire>
  if(f->ref < 1)
    800045aa:	40dc                	lw	a5,4(s1)
    800045ac:	02f05263          	blez	a5,800045d0 <filedup+0x42>
    panic("filedup");
  f->ref++;
    800045b0:	2785                	addiw	a5,a5,1
    800045b2:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    800045b4:	0001d517          	auipc	a0,0x1d
    800045b8:	00450513          	addi	a0,a0,4 # 800215b8 <ftable>
    800045bc:	ffffc097          	auipc	ra,0xffffc
    800045c0:	6ce080e7          	jalr	1742(ra) # 80000c8a <release>
  return f;
}
    800045c4:	8526                	mv	a0,s1
    800045c6:	60e2                	ld	ra,24(sp)
    800045c8:	6442                	ld	s0,16(sp)
    800045ca:	64a2                	ld	s1,8(sp)
    800045cc:	6105                	addi	sp,sp,32
    800045ce:	8082                	ret
    panic("filedup");
    800045d0:	00004517          	auipc	a0,0x4
    800045d4:	0b050513          	addi	a0,a0,176 # 80008680 <syscalls+0x250>
    800045d8:	ffffc097          	auipc	ra,0xffffc
    800045dc:	f58080e7          	jalr	-168(ra) # 80000530 <panic>

00000000800045e0 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    800045e0:	7139                	addi	sp,sp,-64
    800045e2:	fc06                	sd	ra,56(sp)
    800045e4:	f822                	sd	s0,48(sp)
    800045e6:	f426                	sd	s1,40(sp)
    800045e8:	f04a                	sd	s2,32(sp)
    800045ea:	ec4e                	sd	s3,24(sp)
    800045ec:	e852                	sd	s4,16(sp)
    800045ee:	e456                	sd	s5,8(sp)
    800045f0:	0080                	addi	s0,sp,64
    800045f2:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    800045f4:	0001d517          	auipc	a0,0x1d
    800045f8:	fc450513          	addi	a0,a0,-60 # 800215b8 <ftable>
    800045fc:	ffffc097          	auipc	ra,0xffffc
    80004600:	5da080e7          	jalr	1498(ra) # 80000bd6 <acquire>
  if(f->ref < 1)
    80004604:	40dc                	lw	a5,4(s1)
    80004606:	06f05163          	blez	a5,80004668 <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    8000460a:	37fd                	addiw	a5,a5,-1
    8000460c:	0007871b          	sext.w	a4,a5
    80004610:	c0dc                	sw	a5,4(s1)
    80004612:	06e04363          	bgtz	a4,80004678 <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004616:	0004a903          	lw	s2,0(s1)
    8000461a:	0094ca83          	lbu	s5,9(s1)
    8000461e:	0104ba03          	ld	s4,16(s1)
    80004622:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80004626:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    8000462a:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    8000462e:	0001d517          	auipc	a0,0x1d
    80004632:	f8a50513          	addi	a0,a0,-118 # 800215b8 <ftable>
    80004636:	ffffc097          	auipc	ra,0xffffc
    8000463a:	654080e7          	jalr	1620(ra) # 80000c8a <release>

  if(ff.type == FD_PIPE){
    8000463e:	4785                	li	a5,1
    80004640:	04f90d63          	beq	s2,a5,8000469a <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80004644:	3979                	addiw	s2,s2,-2
    80004646:	4785                	li	a5,1
    80004648:	0527e063          	bltu	a5,s2,80004688 <fileclose+0xa8>
    begin_op();
    8000464c:	00000097          	auipc	ra,0x0
    80004650:	ac8080e7          	jalr	-1336(ra) # 80004114 <begin_op>
    iput(ff.ip);
    80004654:	854e                	mv	a0,s3
    80004656:	fffff097          	auipc	ra,0xfffff
    8000465a:	2a6080e7          	jalr	678(ra) # 800038fc <iput>
    end_op();
    8000465e:	00000097          	auipc	ra,0x0
    80004662:	b36080e7          	jalr	-1226(ra) # 80004194 <end_op>
    80004666:	a00d                	j	80004688 <fileclose+0xa8>
    panic("fileclose");
    80004668:	00004517          	auipc	a0,0x4
    8000466c:	02050513          	addi	a0,a0,32 # 80008688 <syscalls+0x258>
    80004670:	ffffc097          	auipc	ra,0xffffc
    80004674:	ec0080e7          	jalr	-320(ra) # 80000530 <panic>
    release(&ftable.lock);
    80004678:	0001d517          	auipc	a0,0x1d
    8000467c:	f4050513          	addi	a0,a0,-192 # 800215b8 <ftable>
    80004680:	ffffc097          	auipc	ra,0xffffc
    80004684:	60a080e7          	jalr	1546(ra) # 80000c8a <release>
  }
}
    80004688:	70e2                	ld	ra,56(sp)
    8000468a:	7442                	ld	s0,48(sp)
    8000468c:	74a2                	ld	s1,40(sp)
    8000468e:	7902                	ld	s2,32(sp)
    80004690:	69e2                	ld	s3,24(sp)
    80004692:	6a42                	ld	s4,16(sp)
    80004694:	6aa2                	ld	s5,8(sp)
    80004696:	6121                	addi	sp,sp,64
    80004698:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    8000469a:	85d6                	mv	a1,s5
    8000469c:	8552                	mv	a0,s4
    8000469e:	00000097          	auipc	ra,0x0
    800046a2:	34c080e7          	jalr	844(ra) # 800049ea <pipeclose>
    800046a6:	b7cd                	j	80004688 <fileclose+0xa8>

00000000800046a8 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    800046a8:	715d                	addi	sp,sp,-80
    800046aa:	e486                	sd	ra,72(sp)
    800046ac:	e0a2                	sd	s0,64(sp)
    800046ae:	fc26                	sd	s1,56(sp)
    800046b0:	f84a                	sd	s2,48(sp)
    800046b2:	f44e                	sd	s3,40(sp)
    800046b4:	0880                	addi	s0,sp,80
    800046b6:	84aa                	mv	s1,a0
    800046b8:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    800046ba:	ffffd097          	auipc	ra,0xffffd
    800046be:	2da080e7          	jalr	730(ra) # 80001994 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    800046c2:	409c                	lw	a5,0(s1)
    800046c4:	37f9                	addiw	a5,a5,-2
    800046c6:	4705                	li	a4,1
    800046c8:	04f76763          	bltu	a4,a5,80004716 <filestat+0x6e>
    800046cc:	892a                	mv	s2,a0
    ilock(f->ip);
    800046ce:	6c88                	ld	a0,24(s1)
    800046d0:	fffff097          	auipc	ra,0xfffff
    800046d4:	072080e7          	jalr	114(ra) # 80003742 <ilock>
    stati(f->ip, &st);
    800046d8:	fb840593          	addi	a1,s0,-72
    800046dc:	6c88                	ld	a0,24(s1)
    800046de:	fffff097          	auipc	ra,0xfffff
    800046e2:	2ee080e7          	jalr	750(ra) # 800039cc <stati>
    iunlock(f->ip);
    800046e6:	6c88                	ld	a0,24(s1)
    800046e8:	fffff097          	auipc	ra,0xfffff
    800046ec:	11c080e7          	jalr	284(ra) # 80003804 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    800046f0:	46e1                	li	a3,24
    800046f2:	fb840613          	addi	a2,s0,-72
    800046f6:	85ce                	mv	a1,s3
    800046f8:	05093503          	ld	a0,80(s2)
    800046fc:	ffffd097          	auipc	ra,0xffffd
    80004700:	f5a080e7          	jalr	-166(ra) # 80001656 <copyout>
    80004704:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    80004708:	60a6                	ld	ra,72(sp)
    8000470a:	6406                	ld	s0,64(sp)
    8000470c:	74e2                	ld	s1,56(sp)
    8000470e:	7942                	ld	s2,48(sp)
    80004710:	79a2                	ld	s3,40(sp)
    80004712:	6161                	addi	sp,sp,80
    80004714:	8082                	ret
  return -1;
    80004716:	557d                	li	a0,-1
    80004718:	bfc5                	j	80004708 <filestat+0x60>

000000008000471a <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    8000471a:	7179                	addi	sp,sp,-48
    8000471c:	f406                	sd	ra,40(sp)
    8000471e:	f022                	sd	s0,32(sp)
    80004720:	ec26                	sd	s1,24(sp)
    80004722:	e84a                	sd	s2,16(sp)
    80004724:	e44e                	sd	s3,8(sp)
    80004726:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80004728:	00854783          	lbu	a5,8(a0)
    8000472c:	c3d5                	beqz	a5,800047d0 <fileread+0xb6>
    8000472e:	84aa                	mv	s1,a0
    80004730:	89ae                	mv	s3,a1
    80004732:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80004734:	411c                	lw	a5,0(a0)
    80004736:	4705                	li	a4,1
    80004738:	04e78963          	beq	a5,a4,8000478a <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    8000473c:	470d                	li	a4,3
    8000473e:	04e78d63          	beq	a5,a4,80004798 <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80004742:	4709                	li	a4,2
    80004744:	06e79e63          	bne	a5,a4,800047c0 <fileread+0xa6>
    ilock(f->ip);
    80004748:	6d08                	ld	a0,24(a0)
    8000474a:	fffff097          	auipc	ra,0xfffff
    8000474e:	ff8080e7          	jalr	-8(ra) # 80003742 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004752:	874a                	mv	a4,s2
    80004754:	5094                	lw	a3,32(s1)
    80004756:	864e                	mv	a2,s3
    80004758:	4585                	li	a1,1
    8000475a:	6c88                	ld	a0,24(s1)
    8000475c:	fffff097          	auipc	ra,0xfffff
    80004760:	29a080e7          	jalr	666(ra) # 800039f6 <readi>
    80004764:	892a                	mv	s2,a0
    80004766:	00a05563          	blez	a0,80004770 <fileread+0x56>
      f->off += r;
    8000476a:	509c                	lw	a5,32(s1)
    8000476c:	9fa9                	addw	a5,a5,a0
    8000476e:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004770:	6c88                	ld	a0,24(s1)
    80004772:	fffff097          	auipc	ra,0xfffff
    80004776:	092080e7          	jalr	146(ra) # 80003804 <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    8000477a:	854a                	mv	a0,s2
    8000477c:	70a2                	ld	ra,40(sp)
    8000477e:	7402                	ld	s0,32(sp)
    80004780:	64e2                	ld	s1,24(sp)
    80004782:	6942                	ld	s2,16(sp)
    80004784:	69a2                	ld	s3,8(sp)
    80004786:	6145                	addi	sp,sp,48
    80004788:	8082                	ret
    r = piperead(f->pipe, addr, n);
    8000478a:	6908                	ld	a0,16(a0)
    8000478c:	00000097          	auipc	ra,0x0
    80004790:	3c8080e7          	jalr	968(ra) # 80004b54 <piperead>
    80004794:	892a                	mv	s2,a0
    80004796:	b7d5                	j	8000477a <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004798:	02451783          	lh	a5,36(a0)
    8000479c:	03079693          	slli	a3,a5,0x30
    800047a0:	92c1                	srli	a3,a3,0x30
    800047a2:	4725                	li	a4,9
    800047a4:	02d76863          	bltu	a4,a3,800047d4 <fileread+0xba>
    800047a8:	0792                	slli	a5,a5,0x4
    800047aa:	0001d717          	auipc	a4,0x1d
    800047ae:	d6e70713          	addi	a4,a4,-658 # 80021518 <devsw>
    800047b2:	97ba                	add	a5,a5,a4
    800047b4:	639c                	ld	a5,0(a5)
    800047b6:	c38d                	beqz	a5,800047d8 <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    800047b8:	4505                	li	a0,1
    800047ba:	9782                	jalr	a5
    800047bc:	892a                	mv	s2,a0
    800047be:	bf75                	j	8000477a <fileread+0x60>
    panic("fileread");
    800047c0:	00004517          	auipc	a0,0x4
    800047c4:	ed850513          	addi	a0,a0,-296 # 80008698 <syscalls+0x268>
    800047c8:	ffffc097          	auipc	ra,0xffffc
    800047cc:	d68080e7          	jalr	-664(ra) # 80000530 <panic>
    return -1;
    800047d0:	597d                	li	s2,-1
    800047d2:	b765                	j	8000477a <fileread+0x60>
      return -1;
    800047d4:	597d                	li	s2,-1
    800047d6:	b755                	j	8000477a <fileread+0x60>
    800047d8:	597d                	li	s2,-1
    800047da:	b745                	j	8000477a <fileread+0x60>

00000000800047dc <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    800047dc:	715d                	addi	sp,sp,-80
    800047de:	e486                	sd	ra,72(sp)
    800047e0:	e0a2                	sd	s0,64(sp)
    800047e2:	fc26                	sd	s1,56(sp)
    800047e4:	f84a                	sd	s2,48(sp)
    800047e6:	f44e                	sd	s3,40(sp)
    800047e8:	f052                	sd	s4,32(sp)
    800047ea:	ec56                	sd	s5,24(sp)
    800047ec:	e85a                	sd	s6,16(sp)
    800047ee:	e45e                	sd	s7,8(sp)
    800047f0:	e062                	sd	s8,0(sp)
    800047f2:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    800047f4:	00954783          	lbu	a5,9(a0)
    800047f8:	10078663          	beqz	a5,80004904 <filewrite+0x128>
    800047fc:	892a                	mv	s2,a0
    800047fe:	8aae                	mv	s5,a1
    80004800:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80004802:	411c                	lw	a5,0(a0)
    80004804:	4705                	li	a4,1
    80004806:	02e78263          	beq	a5,a4,8000482a <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    8000480a:	470d                	li	a4,3
    8000480c:	02e78663          	beq	a5,a4,80004838 <filewrite+0x5c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80004810:	4709                	li	a4,2
    80004812:	0ee79163          	bne	a5,a4,800048f4 <filewrite+0x118>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004816:	0ac05d63          	blez	a2,800048d0 <filewrite+0xf4>
    int i = 0;
    8000481a:	4981                	li	s3,0
    8000481c:	6b05                	lui	s6,0x1
    8000481e:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    80004822:	6b85                	lui	s7,0x1
    80004824:	c00b8b9b          	addiw	s7,s7,-1024
    80004828:	a861                	j	800048c0 <filewrite+0xe4>
    ret = pipewrite(f->pipe, addr, n);
    8000482a:	6908                	ld	a0,16(a0)
    8000482c:	00000097          	auipc	ra,0x0
    80004830:	22e080e7          	jalr	558(ra) # 80004a5a <pipewrite>
    80004834:	8a2a                	mv	s4,a0
    80004836:	a045                	j	800048d6 <filewrite+0xfa>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004838:	02451783          	lh	a5,36(a0)
    8000483c:	03079693          	slli	a3,a5,0x30
    80004840:	92c1                	srli	a3,a3,0x30
    80004842:	4725                	li	a4,9
    80004844:	0cd76263          	bltu	a4,a3,80004908 <filewrite+0x12c>
    80004848:	0792                	slli	a5,a5,0x4
    8000484a:	0001d717          	auipc	a4,0x1d
    8000484e:	cce70713          	addi	a4,a4,-818 # 80021518 <devsw>
    80004852:	97ba                	add	a5,a5,a4
    80004854:	679c                	ld	a5,8(a5)
    80004856:	cbdd                	beqz	a5,8000490c <filewrite+0x130>
    ret = devsw[f->major].write(1, addr, n);
    80004858:	4505                	li	a0,1
    8000485a:	9782                	jalr	a5
    8000485c:	8a2a                	mv	s4,a0
    8000485e:	a8a5                	j	800048d6 <filewrite+0xfa>
    80004860:	00048c1b          	sext.w	s8,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    80004864:	00000097          	auipc	ra,0x0
    80004868:	8b0080e7          	jalr	-1872(ra) # 80004114 <begin_op>
      ilock(f->ip);
    8000486c:	01893503          	ld	a0,24(s2)
    80004870:	fffff097          	auipc	ra,0xfffff
    80004874:	ed2080e7          	jalr	-302(ra) # 80003742 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004878:	8762                	mv	a4,s8
    8000487a:	02092683          	lw	a3,32(s2)
    8000487e:	01598633          	add	a2,s3,s5
    80004882:	4585                	li	a1,1
    80004884:	01893503          	ld	a0,24(s2)
    80004888:	fffff097          	auipc	ra,0xfffff
    8000488c:	266080e7          	jalr	614(ra) # 80003aee <writei>
    80004890:	84aa                	mv	s1,a0
    80004892:	00a05763          	blez	a0,800048a0 <filewrite+0xc4>
        f->off += r;
    80004896:	02092783          	lw	a5,32(s2)
    8000489a:	9fa9                	addw	a5,a5,a0
    8000489c:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    800048a0:	01893503          	ld	a0,24(s2)
    800048a4:	fffff097          	auipc	ra,0xfffff
    800048a8:	f60080e7          	jalr	-160(ra) # 80003804 <iunlock>
      end_op();
    800048ac:	00000097          	auipc	ra,0x0
    800048b0:	8e8080e7          	jalr	-1816(ra) # 80004194 <end_op>

      if(r != n1){
    800048b4:	009c1f63          	bne	s8,s1,800048d2 <filewrite+0xf6>
        // error from writei
        break;
      }
      i += r;
    800048b8:	013489bb          	addw	s3,s1,s3
    while(i < n){
    800048bc:	0149db63          	bge	s3,s4,800048d2 <filewrite+0xf6>
      int n1 = n - i;
    800048c0:	413a07bb          	subw	a5,s4,s3
      if(n1 > max)
    800048c4:	84be                	mv	s1,a5
    800048c6:	2781                	sext.w	a5,a5
    800048c8:	f8fb5ce3          	bge	s6,a5,80004860 <filewrite+0x84>
    800048cc:	84de                	mv	s1,s7
    800048ce:	bf49                	j	80004860 <filewrite+0x84>
    int i = 0;
    800048d0:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    800048d2:	013a1f63          	bne	s4,s3,800048f0 <filewrite+0x114>
  } else {
    panic("filewrite");
  }

  return ret;
}
    800048d6:	8552                	mv	a0,s4
    800048d8:	60a6                	ld	ra,72(sp)
    800048da:	6406                	ld	s0,64(sp)
    800048dc:	74e2                	ld	s1,56(sp)
    800048de:	7942                	ld	s2,48(sp)
    800048e0:	79a2                	ld	s3,40(sp)
    800048e2:	7a02                	ld	s4,32(sp)
    800048e4:	6ae2                	ld	s5,24(sp)
    800048e6:	6b42                	ld	s6,16(sp)
    800048e8:	6ba2                	ld	s7,8(sp)
    800048ea:	6c02                	ld	s8,0(sp)
    800048ec:	6161                	addi	sp,sp,80
    800048ee:	8082                	ret
    ret = (i == n ? n : -1);
    800048f0:	5a7d                	li	s4,-1
    800048f2:	b7d5                	j	800048d6 <filewrite+0xfa>
    panic("filewrite");
    800048f4:	00004517          	auipc	a0,0x4
    800048f8:	db450513          	addi	a0,a0,-588 # 800086a8 <syscalls+0x278>
    800048fc:	ffffc097          	auipc	ra,0xffffc
    80004900:	c34080e7          	jalr	-972(ra) # 80000530 <panic>
    return -1;
    80004904:	5a7d                	li	s4,-1
    80004906:	bfc1                	j	800048d6 <filewrite+0xfa>
      return -1;
    80004908:	5a7d                	li	s4,-1
    8000490a:	b7f1                	j	800048d6 <filewrite+0xfa>
    8000490c:	5a7d                	li	s4,-1
    8000490e:	b7e1                	j	800048d6 <filewrite+0xfa>

0000000080004910 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004910:	7179                	addi	sp,sp,-48
    80004912:	f406                	sd	ra,40(sp)
    80004914:	f022                	sd	s0,32(sp)
    80004916:	ec26                	sd	s1,24(sp)
    80004918:	e84a                	sd	s2,16(sp)
    8000491a:	e44e                	sd	s3,8(sp)
    8000491c:	e052                	sd	s4,0(sp)
    8000491e:	1800                	addi	s0,sp,48
    80004920:	84aa                	mv	s1,a0
    80004922:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004924:	0005b023          	sd	zero,0(a1)
    80004928:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    8000492c:	00000097          	auipc	ra,0x0
    80004930:	bf8080e7          	jalr	-1032(ra) # 80004524 <filealloc>
    80004934:	e088                	sd	a0,0(s1)
    80004936:	c551                	beqz	a0,800049c2 <pipealloc+0xb2>
    80004938:	00000097          	auipc	ra,0x0
    8000493c:	bec080e7          	jalr	-1044(ra) # 80004524 <filealloc>
    80004940:	00aa3023          	sd	a0,0(s4)
    80004944:	c92d                	beqz	a0,800049b6 <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004946:	ffffc097          	auipc	ra,0xffffc
    8000494a:	1a0080e7          	jalr	416(ra) # 80000ae6 <kalloc>
    8000494e:	892a                	mv	s2,a0
    80004950:	c125                	beqz	a0,800049b0 <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    80004952:	4985                	li	s3,1
    80004954:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004958:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    8000495c:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004960:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004964:	00004597          	auipc	a1,0x4
    80004968:	d5458593          	addi	a1,a1,-684 # 800086b8 <syscalls+0x288>
    8000496c:	ffffc097          	auipc	ra,0xffffc
    80004970:	1da080e7          	jalr	474(ra) # 80000b46 <initlock>
  (*f0)->type = FD_PIPE;
    80004974:	609c                	ld	a5,0(s1)
    80004976:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    8000497a:	609c                	ld	a5,0(s1)
    8000497c:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004980:	609c                	ld	a5,0(s1)
    80004982:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004986:	609c                	ld	a5,0(s1)
    80004988:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    8000498c:	000a3783          	ld	a5,0(s4)
    80004990:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004994:	000a3783          	ld	a5,0(s4)
    80004998:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    8000499c:	000a3783          	ld	a5,0(s4)
    800049a0:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    800049a4:	000a3783          	ld	a5,0(s4)
    800049a8:	0127b823          	sd	s2,16(a5)
  return 0;
    800049ac:	4501                	li	a0,0
    800049ae:	a025                	j	800049d6 <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    800049b0:	6088                	ld	a0,0(s1)
    800049b2:	e501                	bnez	a0,800049ba <pipealloc+0xaa>
    800049b4:	a039                	j	800049c2 <pipealloc+0xb2>
    800049b6:	6088                	ld	a0,0(s1)
    800049b8:	c51d                	beqz	a0,800049e6 <pipealloc+0xd6>
    fileclose(*f0);
    800049ba:	00000097          	auipc	ra,0x0
    800049be:	c26080e7          	jalr	-986(ra) # 800045e0 <fileclose>
  if(*f1)
    800049c2:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    800049c6:	557d                	li	a0,-1
  if(*f1)
    800049c8:	c799                	beqz	a5,800049d6 <pipealloc+0xc6>
    fileclose(*f1);
    800049ca:	853e                	mv	a0,a5
    800049cc:	00000097          	auipc	ra,0x0
    800049d0:	c14080e7          	jalr	-1004(ra) # 800045e0 <fileclose>
  return -1;
    800049d4:	557d                	li	a0,-1
}
    800049d6:	70a2                	ld	ra,40(sp)
    800049d8:	7402                	ld	s0,32(sp)
    800049da:	64e2                	ld	s1,24(sp)
    800049dc:	6942                	ld	s2,16(sp)
    800049de:	69a2                	ld	s3,8(sp)
    800049e0:	6a02                	ld	s4,0(sp)
    800049e2:	6145                	addi	sp,sp,48
    800049e4:	8082                	ret
  return -1;
    800049e6:	557d                	li	a0,-1
    800049e8:	b7fd                	j	800049d6 <pipealloc+0xc6>

00000000800049ea <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    800049ea:	1101                	addi	sp,sp,-32
    800049ec:	ec06                	sd	ra,24(sp)
    800049ee:	e822                	sd	s0,16(sp)
    800049f0:	e426                	sd	s1,8(sp)
    800049f2:	e04a                	sd	s2,0(sp)
    800049f4:	1000                	addi	s0,sp,32
    800049f6:	84aa                	mv	s1,a0
    800049f8:	892e                	mv	s2,a1
  acquire(&pi->lock);
    800049fa:	ffffc097          	auipc	ra,0xffffc
    800049fe:	1dc080e7          	jalr	476(ra) # 80000bd6 <acquire>
  if(writable){
    80004a02:	02090d63          	beqz	s2,80004a3c <pipeclose+0x52>
    pi->writeopen = 0;
    80004a06:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004a0a:	21848513          	addi	a0,s1,536
    80004a0e:	ffffe097          	auipc	ra,0xffffe
    80004a12:	82a080e7          	jalr	-2006(ra) # 80002238 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004a16:	2204b783          	ld	a5,544(s1)
    80004a1a:	eb95                	bnez	a5,80004a4e <pipeclose+0x64>
    release(&pi->lock);
    80004a1c:	8526                	mv	a0,s1
    80004a1e:	ffffc097          	auipc	ra,0xffffc
    80004a22:	26c080e7          	jalr	620(ra) # 80000c8a <release>
    kfree((char*)pi);
    80004a26:	8526                	mv	a0,s1
    80004a28:	ffffc097          	auipc	ra,0xffffc
    80004a2c:	fc2080e7          	jalr	-62(ra) # 800009ea <kfree>
  } else
    release(&pi->lock);
}
    80004a30:	60e2                	ld	ra,24(sp)
    80004a32:	6442                	ld	s0,16(sp)
    80004a34:	64a2                	ld	s1,8(sp)
    80004a36:	6902                	ld	s2,0(sp)
    80004a38:	6105                	addi	sp,sp,32
    80004a3a:	8082                	ret
    pi->readopen = 0;
    80004a3c:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004a40:	21c48513          	addi	a0,s1,540
    80004a44:	ffffd097          	auipc	ra,0xffffd
    80004a48:	7f4080e7          	jalr	2036(ra) # 80002238 <wakeup>
    80004a4c:	b7e9                	j	80004a16 <pipeclose+0x2c>
    release(&pi->lock);
    80004a4e:	8526                	mv	a0,s1
    80004a50:	ffffc097          	auipc	ra,0xffffc
    80004a54:	23a080e7          	jalr	570(ra) # 80000c8a <release>
}
    80004a58:	bfe1                	j	80004a30 <pipeclose+0x46>

0000000080004a5a <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004a5a:	7159                	addi	sp,sp,-112
    80004a5c:	f486                	sd	ra,104(sp)
    80004a5e:	f0a2                	sd	s0,96(sp)
    80004a60:	eca6                	sd	s1,88(sp)
    80004a62:	e8ca                	sd	s2,80(sp)
    80004a64:	e4ce                	sd	s3,72(sp)
    80004a66:	e0d2                	sd	s4,64(sp)
    80004a68:	fc56                	sd	s5,56(sp)
    80004a6a:	f85a                	sd	s6,48(sp)
    80004a6c:	f45e                	sd	s7,40(sp)
    80004a6e:	f062                	sd	s8,32(sp)
    80004a70:	ec66                	sd	s9,24(sp)
    80004a72:	1880                	addi	s0,sp,112
    80004a74:	84aa                	mv	s1,a0
    80004a76:	8aae                	mv	s5,a1
    80004a78:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80004a7a:	ffffd097          	auipc	ra,0xffffd
    80004a7e:	f1a080e7          	jalr	-230(ra) # 80001994 <myproc>
    80004a82:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80004a84:	8526                	mv	a0,s1
    80004a86:	ffffc097          	auipc	ra,0xffffc
    80004a8a:	150080e7          	jalr	336(ra) # 80000bd6 <acquire>
  while(i < n){
    80004a8e:	0d405163          	blez	s4,80004b50 <pipewrite+0xf6>
    80004a92:	8ba6                	mv	s7,s1
  int i = 0;
    80004a94:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004a96:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80004a98:	21848c93          	addi	s9,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004a9c:	21c48c13          	addi	s8,s1,540
    80004aa0:	a08d                	j	80004b02 <pipewrite+0xa8>
      release(&pi->lock);
    80004aa2:	8526                	mv	a0,s1
    80004aa4:	ffffc097          	auipc	ra,0xffffc
    80004aa8:	1e6080e7          	jalr	486(ra) # 80000c8a <release>
      return -1;
    80004aac:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80004aae:	854a                	mv	a0,s2
    80004ab0:	70a6                	ld	ra,104(sp)
    80004ab2:	7406                	ld	s0,96(sp)
    80004ab4:	64e6                	ld	s1,88(sp)
    80004ab6:	6946                	ld	s2,80(sp)
    80004ab8:	69a6                	ld	s3,72(sp)
    80004aba:	6a06                	ld	s4,64(sp)
    80004abc:	7ae2                	ld	s5,56(sp)
    80004abe:	7b42                	ld	s6,48(sp)
    80004ac0:	7ba2                	ld	s7,40(sp)
    80004ac2:	7c02                	ld	s8,32(sp)
    80004ac4:	6ce2                	ld	s9,24(sp)
    80004ac6:	6165                	addi	sp,sp,112
    80004ac8:	8082                	ret
      wakeup(&pi->nread);
    80004aca:	8566                	mv	a0,s9
    80004acc:	ffffd097          	auipc	ra,0xffffd
    80004ad0:	76c080e7          	jalr	1900(ra) # 80002238 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004ad4:	85de                	mv	a1,s7
    80004ad6:	8562                	mv	a0,s8
    80004ad8:	ffffd097          	auipc	ra,0xffffd
    80004adc:	5d4080e7          	jalr	1492(ra) # 800020ac <sleep>
    80004ae0:	a839                	j	80004afe <pipewrite+0xa4>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004ae2:	21c4a783          	lw	a5,540(s1)
    80004ae6:	0017871b          	addiw	a4,a5,1
    80004aea:	20e4ae23          	sw	a4,540(s1)
    80004aee:	1ff7f793          	andi	a5,a5,511
    80004af2:	97a6                	add	a5,a5,s1
    80004af4:	f9f44703          	lbu	a4,-97(s0)
    80004af8:	00e78c23          	sb	a4,24(a5)
      i++;
    80004afc:	2905                	addiw	s2,s2,1
  while(i < n){
    80004afe:	03495d63          	bge	s2,s4,80004b38 <pipewrite+0xde>
    if(pi->readopen == 0 || pr->killed){
    80004b02:	2204a783          	lw	a5,544(s1)
    80004b06:	dfd1                	beqz	a5,80004aa2 <pipewrite+0x48>
    80004b08:	0289a783          	lw	a5,40(s3)
    80004b0c:	fbd9                	bnez	a5,80004aa2 <pipewrite+0x48>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80004b0e:	2184a783          	lw	a5,536(s1)
    80004b12:	21c4a703          	lw	a4,540(s1)
    80004b16:	2007879b          	addiw	a5,a5,512
    80004b1a:	faf708e3          	beq	a4,a5,80004aca <pipewrite+0x70>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004b1e:	4685                	li	a3,1
    80004b20:	01590633          	add	a2,s2,s5
    80004b24:	f9f40593          	addi	a1,s0,-97
    80004b28:	0509b503          	ld	a0,80(s3)
    80004b2c:	ffffd097          	auipc	ra,0xffffd
    80004b30:	bb6080e7          	jalr	-1098(ra) # 800016e2 <copyin>
    80004b34:	fb6517e3          	bne	a0,s6,80004ae2 <pipewrite+0x88>
  wakeup(&pi->nread);
    80004b38:	21848513          	addi	a0,s1,536
    80004b3c:	ffffd097          	auipc	ra,0xffffd
    80004b40:	6fc080e7          	jalr	1788(ra) # 80002238 <wakeup>
  release(&pi->lock);
    80004b44:	8526                	mv	a0,s1
    80004b46:	ffffc097          	auipc	ra,0xffffc
    80004b4a:	144080e7          	jalr	324(ra) # 80000c8a <release>
  return i;
    80004b4e:	b785                	j	80004aae <pipewrite+0x54>
  int i = 0;
    80004b50:	4901                	li	s2,0
    80004b52:	b7dd                	j	80004b38 <pipewrite+0xde>

0000000080004b54 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004b54:	715d                	addi	sp,sp,-80
    80004b56:	e486                	sd	ra,72(sp)
    80004b58:	e0a2                	sd	s0,64(sp)
    80004b5a:	fc26                	sd	s1,56(sp)
    80004b5c:	f84a                	sd	s2,48(sp)
    80004b5e:	f44e                	sd	s3,40(sp)
    80004b60:	f052                	sd	s4,32(sp)
    80004b62:	ec56                	sd	s5,24(sp)
    80004b64:	e85a                	sd	s6,16(sp)
    80004b66:	0880                	addi	s0,sp,80
    80004b68:	84aa                	mv	s1,a0
    80004b6a:	892e                	mv	s2,a1
    80004b6c:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004b6e:	ffffd097          	auipc	ra,0xffffd
    80004b72:	e26080e7          	jalr	-474(ra) # 80001994 <myproc>
    80004b76:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004b78:	8b26                	mv	s6,s1
    80004b7a:	8526                	mv	a0,s1
    80004b7c:	ffffc097          	auipc	ra,0xffffc
    80004b80:	05a080e7          	jalr	90(ra) # 80000bd6 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004b84:	2184a703          	lw	a4,536(s1)
    80004b88:	21c4a783          	lw	a5,540(s1)
    if(pr->killed){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004b8c:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004b90:	02f71463          	bne	a4,a5,80004bb8 <piperead+0x64>
    80004b94:	2244a783          	lw	a5,548(s1)
    80004b98:	c385                	beqz	a5,80004bb8 <piperead+0x64>
    if(pr->killed){
    80004b9a:	028a2783          	lw	a5,40(s4)
    80004b9e:	ebc1                	bnez	a5,80004c2e <piperead+0xda>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004ba0:	85da                	mv	a1,s6
    80004ba2:	854e                	mv	a0,s3
    80004ba4:	ffffd097          	auipc	ra,0xffffd
    80004ba8:	508080e7          	jalr	1288(ra) # 800020ac <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004bac:	2184a703          	lw	a4,536(s1)
    80004bb0:	21c4a783          	lw	a5,540(s1)
    80004bb4:	fef700e3          	beq	a4,a5,80004b94 <piperead+0x40>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004bb8:	09505263          	blez	s5,80004c3c <piperead+0xe8>
    80004bbc:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004bbe:	5b7d                	li	s6,-1
    if(pi->nread == pi->nwrite)
    80004bc0:	2184a783          	lw	a5,536(s1)
    80004bc4:	21c4a703          	lw	a4,540(s1)
    80004bc8:	02f70d63          	beq	a4,a5,80004c02 <piperead+0xae>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80004bcc:	0017871b          	addiw	a4,a5,1
    80004bd0:	20e4ac23          	sw	a4,536(s1)
    80004bd4:	1ff7f793          	andi	a5,a5,511
    80004bd8:	97a6                	add	a5,a5,s1
    80004bda:	0187c783          	lbu	a5,24(a5)
    80004bde:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004be2:	4685                	li	a3,1
    80004be4:	fbf40613          	addi	a2,s0,-65
    80004be8:	85ca                	mv	a1,s2
    80004bea:	050a3503          	ld	a0,80(s4)
    80004bee:	ffffd097          	auipc	ra,0xffffd
    80004bf2:	a68080e7          	jalr	-1432(ra) # 80001656 <copyout>
    80004bf6:	01650663          	beq	a0,s6,80004c02 <piperead+0xae>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004bfa:	2985                	addiw	s3,s3,1
    80004bfc:	0905                	addi	s2,s2,1
    80004bfe:	fd3a91e3          	bne	s5,s3,80004bc0 <piperead+0x6c>
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004c02:	21c48513          	addi	a0,s1,540
    80004c06:	ffffd097          	auipc	ra,0xffffd
    80004c0a:	632080e7          	jalr	1586(ra) # 80002238 <wakeup>
  release(&pi->lock);
    80004c0e:	8526                	mv	a0,s1
    80004c10:	ffffc097          	auipc	ra,0xffffc
    80004c14:	07a080e7          	jalr	122(ra) # 80000c8a <release>
  return i;
}
    80004c18:	854e                	mv	a0,s3
    80004c1a:	60a6                	ld	ra,72(sp)
    80004c1c:	6406                	ld	s0,64(sp)
    80004c1e:	74e2                	ld	s1,56(sp)
    80004c20:	7942                	ld	s2,48(sp)
    80004c22:	79a2                	ld	s3,40(sp)
    80004c24:	7a02                	ld	s4,32(sp)
    80004c26:	6ae2                	ld	s5,24(sp)
    80004c28:	6b42                	ld	s6,16(sp)
    80004c2a:	6161                	addi	sp,sp,80
    80004c2c:	8082                	ret
      release(&pi->lock);
    80004c2e:	8526                	mv	a0,s1
    80004c30:	ffffc097          	auipc	ra,0xffffc
    80004c34:	05a080e7          	jalr	90(ra) # 80000c8a <release>
      return -1;
    80004c38:	59fd                	li	s3,-1
    80004c3a:	bff9                	j	80004c18 <piperead+0xc4>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004c3c:	4981                	li	s3,0
    80004c3e:	b7d1                	j	80004c02 <piperead+0xae>

0000000080004c40 <exec>:

static int loadseg(pde_t *pgdir, uint64 addr, struct inode *ip, uint offset, uint sz);

int
exec(char *path, char **argv)
{
    80004c40:	df010113          	addi	sp,sp,-528
    80004c44:	20113423          	sd	ra,520(sp)
    80004c48:	20813023          	sd	s0,512(sp)
    80004c4c:	ffa6                	sd	s1,504(sp)
    80004c4e:	fbca                	sd	s2,496(sp)
    80004c50:	f7ce                	sd	s3,488(sp)
    80004c52:	f3d2                	sd	s4,480(sp)
    80004c54:	efd6                	sd	s5,472(sp)
    80004c56:	ebda                	sd	s6,464(sp)
    80004c58:	e7de                	sd	s7,456(sp)
    80004c5a:	e3e2                	sd	s8,448(sp)
    80004c5c:	ff66                	sd	s9,440(sp)
    80004c5e:	fb6a                	sd	s10,432(sp)
    80004c60:	f76e                	sd	s11,424(sp)
    80004c62:	0c00                	addi	s0,sp,528
    80004c64:	84aa                	mv	s1,a0
    80004c66:	dea43c23          	sd	a0,-520(s0)
    80004c6a:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004c6e:	ffffd097          	auipc	ra,0xffffd
    80004c72:	d26080e7          	jalr	-730(ra) # 80001994 <myproc>
    80004c76:	892a                	mv	s2,a0

  begin_op();
    80004c78:	fffff097          	auipc	ra,0xfffff
    80004c7c:	49c080e7          	jalr	1180(ra) # 80004114 <begin_op>

  if((ip = namei(path)) == 0){
    80004c80:	8526                	mv	a0,s1
    80004c82:	fffff097          	auipc	ra,0xfffff
    80004c86:	276080e7          	jalr	630(ra) # 80003ef8 <namei>
    80004c8a:	c92d                	beqz	a0,80004cfc <exec+0xbc>
    80004c8c:	84aa                	mv	s1,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80004c8e:	fffff097          	auipc	ra,0xfffff
    80004c92:	ab4080e7          	jalr	-1356(ra) # 80003742 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004c96:	04000713          	li	a4,64
    80004c9a:	4681                	li	a3,0
    80004c9c:	e4840613          	addi	a2,s0,-440
    80004ca0:	4581                	li	a1,0
    80004ca2:	8526                	mv	a0,s1
    80004ca4:	fffff097          	auipc	ra,0xfffff
    80004ca8:	d52080e7          	jalr	-686(ra) # 800039f6 <readi>
    80004cac:	04000793          	li	a5,64
    80004cb0:	00f51a63          	bne	a0,a5,80004cc4 <exec+0x84>
    goto bad;
  if(elf.magic != ELF_MAGIC)
    80004cb4:	e4842703          	lw	a4,-440(s0)
    80004cb8:	464c47b7          	lui	a5,0x464c4
    80004cbc:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004cc0:	04f70463          	beq	a4,a5,80004d08 <exec+0xc8>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80004cc4:	8526                	mv	a0,s1
    80004cc6:	fffff097          	auipc	ra,0xfffff
    80004cca:	cde080e7          	jalr	-802(ra) # 800039a4 <iunlockput>
    end_op();
    80004cce:	fffff097          	auipc	ra,0xfffff
    80004cd2:	4c6080e7          	jalr	1222(ra) # 80004194 <end_op>
  }
  return -1;
    80004cd6:	557d                	li	a0,-1
}
    80004cd8:	20813083          	ld	ra,520(sp)
    80004cdc:	20013403          	ld	s0,512(sp)
    80004ce0:	74fe                	ld	s1,504(sp)
    80004ce2:	795e                	ld	s2,496(sp)
    80004ce4:	79be                	ld	s3,488(sp)
    80004ce6:	7a1e                	ld	s4,480(sp)
    80004ce8:	6afe                	ld	s5,472(sp)
    80004cea:	6b5e                	ld	s6,464(sp)
    80004cec:	6bbe                	ld	s7,456(sp)
    80004cee:	6c1e                	ld	s8,448(sp)
    80004cf0:	7cfa                	ld	s9,440(sp)
    80004cf2:	7d5a                	ld	s10,432(sp)
    80004cf4:	7dba                	ld	s11,424(sp)
    80004cf6:	21010113          	addi	sp,sp,528
    80004cfa:	8082                	ret
    end_op();
    80004cfc:	fffff097          	auipc	ra,0xfffff
    80004d00:	498080e7          	jalr	1176(ra) # 80004194 <end_op>
    return -1;
    80004d04:	557d                	li	a0,-1
    80004d06:	bfc9                	j	80004cd8 <exec+0x98>
  if((pagetable = proc_pagetable(p)) == 0)
    80004d08:	854a                	mv	a0,s2
    80004d0a:	ffffd097          	auipc	ra,0xffffd
    80004d0e:	d4e080e7          	jalr	-690(ra) # 80001a58 <proc_pagetable>
    80004d12:	8baa                	mv	s7,a0
    80004d14:	d945                	beqz	a0,80004cc4 <exec+0x84>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004d16:	e6842983          	lw	s3,-408(s0)
    80004d1a:	e8045783          	lhu	a5,-384(s0)
    80004d1e:	c7ad                	beqz	a5,80004d88 <exec+0x148>
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
    80004d20:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004d22:	4b01                	li	s6,0
    if(ph.vaddr % PGSIZE != 0)
    80004d24:	6c85                	lui	s9,0x1
    80004d26:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    80004d2a:	def43823          	sd	a5,-528(s0)
    80004d2e:	a42d                	j	80004f58 <exec+0x318>
    panic("loadseg: va must be page aligned");

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    80004d30:	00004517          	auipc	a0,0x4
    80004d34:	99050513          	addi	a0,a0,-1648 # 800086c0 <syscalls+0x290>
    80004d38:	ffffb097          	auipc	ra,0xffffb
    80004d3c:	7f8080e7          	jalr	2040(ra) # 80000530 <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80004d40:	8756                	mv	a4,s5
    80004d42:	012d86bb          	addw	a3,s11,s2
    80004d46:	4581                	li	a1,0
    80004d48:	8526                	mv	a0,s1
    80004d4a:	fffff097          	auipc	ra,0xfffff
    80004d4e:	cac080e7          	jalr	-852(ra) # 800039f6 <readi>
    80004d52:	2501                	sext.w	a0,a0
    80004d54:	1aaa9963          	bne	s5,a0,80004f06 <exec+0x2c6>
  for(i = 0; i < sz; i += PGSIZE){
    80004d58:	6785                	lui	a5,0x1
    80004d5a:	0127893b          	addw	s2,a5,s2
    80004d5e:	77fd                	lui	a5,0xfffff
    80004d60:	01478a3b          	addw	s4,a5,s4
    80004d64:	1f897163          	bgeu	s2,s8,80004f46 <exec+0x306>
    pa = walkaddr(pagetable, va + i);
    80004d68:	02091593          	slli	a1,s2,0x20
    80004d6c:	9181                	srli	a1,a1,0x20
    80004d6e:	95ea                	add	a1,a1,s10
    80004d70:	855e                	mv	a0,s7
    80004d72:	ffffc097          	auipc	ra,0xffffc
    80004d76:	2f2080e7          	jalr	754(ra) # 80001064 <walkaddr>
    80004d7a:	862a                	mv	a2,a0
    if(pa == 0)
    80004d7c:	d955                	beqz	a0,80004d30 <exec+0xf0>
      n = PGSIZE;
    80004d7e:	8ae6                	mv	s5,s9
    if(sz - i < PGSIZE)
    80004d80:	fd9a70e3          	bgeu	s4,s9,80004d40 <exec+0x100>
      n = sz - i;
    80004d84:	8ad2                	mv	s5,s4
    80004d86:	bf6d                	j	80004d40 <exec+0x100>
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
    80004d88:	4901                	li	s2,0
  iunlockput(ip);
    80004d8a:	8526                	mv	a0,s1
    80004d8c:	fffff097          	auipc	ra,0xfffff
    80004d90:	c18080e7          	jalr	-1000(ra) # 800039a4 <iunlockput>
  end_op();
    80004d94:	fffff097          	auipc	ra,0xfffff
    80004d98:	400080e7          	jalr	1024(ra) # 80004194 <end_op>
  p = myproc();
    80004d9c:	ffffd097          	auipc	ra,0xffffd
    80004da0:	bf8080e7          	jalr	-1032(ra) # 80001994 <myproc>
    80004da4:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    80004da6:	04853d03          	ld	s10,72(a0)
  sz = PGROUNDUP(sz);
    80004daa:	6785                	lui	a5,0x1
    80004dac:	17fd                	addi	a5,a5,-1
    80004dae:	993e                	add	s2,s2,a5
    80004db0:	757d                	lui	a0,0xfffff
    80004db2:	00a977b3          	and	a5,s2,a0
    80004db6:	e0f43423          	sd	a5,-504(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    80004dba:	6609                	lui	a2,0x2
    80004dbc:	963e                	add	a2,a2,a5
    80004dbe:	85be                	mv	a1,a5
    80004dc0:	855e                	mv	a0,s7
    80004dc2:	ffffc097          	auipc	ra,0xffffc
    80004dc6:	644080e7          	jalr	1604(ra) # 80001406 <uvmalloc>
    80004dca:	8b2a                	mv	s6,a0
  ip = 0;
    80004dcc:	4481                	li	s1,0
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    80004dce:	12050c63          	beqz	a0,80004f06 <exec+0x2c6>
  uvmclear(pagetable, sz-2*PGSIZE);
    80004dd2:	75f9                	lui	a1,0xffffe
    80004dd4:	95aa                	add	a1,a1,a0
    80004dd6:	855e                	mv	a0,s7
    80004dd8:	ffffd097          	auipc	ra,0xffffd
    80004ddc:	84c080e7          	jalr	-1972(ra) # 80001624 <uvmclear>
  stackbase = sp - PGSIZE;
    80004de0:	7c7d                	lui	s8,0xfffff
    80004de2:	9c5a                	add	s8,s8,s6
  for(argc = 0; argv[argc]; argc++) {
    80004de4:	e0043783          	ld	a5,-512(s0)
    80004de8:	6388                	ld	a0,0(a5)
    80004dea:	c535                	beqz	a0,80004e56 <exec+0x216>
    80004dec:	e8840993          	addi	s3,s0,-376
    80004df0:	f8840c93          	addi	s9,s0,-120
  sp = sz;
    80004df4:	895a                	mv	s2,s6
    sp -= strlen(argv[argc]) + 1;
    80004df6:	ffffc097          	auipc	ra,0xffffc
    80004dfa:	064080e7          	jalr	100(ra) # 80000e5a <strlen>
    80004dfe:	2505                	addiw	a0,a0,1
    80004e00:	40a90933          	sub	s2,s2,a0
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80004e04:	ff097913          	andi	s2,s2,-16
    if(sp < stackbase)
    80004e08:	13896363          	bltu	s2,s8,80004f2e <exec+0x2ee>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80004e0c:	e0043d83          	ld	s11,-512(s0)
    80004e10:	000dba03          	ld	s4,0(s11)
    80004e14:	8552                	mv	a0,s4
    80004e16:	ffffc097          	auipc	ra,0xffffc
    80004e1a:	044080e7          	jalr	68(ra) # 80000e5a <strlen>
    80004e1e:	0015069b          	addiw	a3,a0,1
    80004e22:	8652                	mv	a2,s4
    80004e24:	85ca                	mv	a1,s2
    80004e26:	855e                	mv	a0,s7
    80004e28:	ffffd097          	auipc	ra,0xffffd
    80004e2c:	82e080e7          	jalr	-2002(ra) # 80001656 <copyout>
    80004e30:	10054363          	bltz	a0,80004f36 <exec+0x2f6>
    ustack[argc] = sp;
    80004e34:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80004e38:	0485                	addi	s1,s1,1
    80004e3a:	008d8793          	addi	a5,s11,8
    80004e3e:	e0f43023          	sd	a5,-512(s0)
    80004e42:	008db503          	ld	a0,8(s11)
    80004e46:	c911                	beqz	a0,80004e5a <exec+0x21a>
    if(argc >= MAXARG)
    80004e48:	09a1                	addi	s3,s3,8
    80004e4a:	fb3c96e3          	bne	s9,s3,80004df6 <exec+0x1b6>
  sz = sz1;
    80004e4e:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    80004e52:	4481                	li	s1,0
    80004e54:	a84d                	j	80004f06 <exec+0x2c6>
  sp = sz;
    80004e56:	895a                	mv	s2,s6
  for(argc = 0; argv[argc]; argc++) {
    80004e58:	4481                	li	s1,0
  ustack[argc] = 0;
    80004e5a:	00349793          	slli	a5,s1,0x3
    80004e5e:	f9040713          	addi	a4,s0,-112
    80004e62:	97ba                	add	a5,a5,a4
    80004e64:	ee07bc23          	sd	zero,-264(a5) # ef8 <_entry-0x7ffff108>
  sp -= (argc+1) * sizeof(uint64);
    80004e68:	00148693          	addi	a3,s1,1
    80004e6c:	068e                	slli	a3,a3,0x3
    80004e6e:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80004e72:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    80004e76:	01897663          	bgeu	s2,s8,80004e82 <exec+0x242>
  sz = sz1;
    80004e7a:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    80004e7e:	4481                	li	s1,0
    80004e80:	a059                	j	80004f06 <exec+0x2c6>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80004e82:	e8840613          	addi	a2,s0,-376
    80004e86:	85ca                	mv	a1,s2
    80004e88:	855e                	mv	a0,s7
    80004e8a:	ffffc097          	auipc	ra,0xffffc
    80004e8e:	7cc080e7          	jalr	1996(ra) # 80001656 <copyout>
    80004e92:	0a054663          	bltz	a0,80004f3e <exec+0x2fe>
  p->trapframe->a1 = sp;
    80004e96:	058ab783          	ld	a5,88(s5)
    80004e9a:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80004e9e:	df843783          	ld	a5,-520(s0)
    80004ea2:	0007c703          	lbu	a4,0(a5)
    80004ea6:	cf11                	beqz	a4,80004ec2 <exec+0x282>
    80004ea8:	0785                	addi	a5,a5,1
    if(*s == '/')
    80004eaa:	02f00693          	li	a3,47
    80004eae:	a029                	j	80004eb8 <exec+0x278>
  for(last=s=path; *s; s++)
    80004eb0:	0785                	addi	a5,a5,1
    80004eb2:	fff7c703          	lbu	a4,-1(a5)
    80004eb6:	c711                	beqz	a4,80004ec2 <exec+0x282>
    if(*s == '/')
    80004eb8:	fed71ce3          	bne	a4,a3,80004eb0 <exec+0x270>
      last = s+1;
    80004ebc:	def43c23          	sd	a5,-520(s0)
    80004ec0:	bfc5                	j	80004eb0 <exec+0x270>
  safestrcpy(p->name, last, sizeof(p->name));
    80004ec2:	4641                	li	a2,16
    80004ec4:	df843583          	ld	a1,-520(s0)
    80004ec8:	158a8513          	addi	a0,s5,344
    80004ecc:	ffffc097          	auipc	ra,0xffffc
    80004ed0:	f5c080e7          	jalr	-164(ra) # 80000e28 <safestrcpy>
  oldpagetable = p->pagetable;
    80004ed4:	050ab503          	ld	a0,80(s5)
  p->pagetable = pagetable;
    80004ed8:	057ab823          	sd	s7,80(s5)
  p->sz = sz;
    80004edc:	056ab423          	sd	s6,72(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    80004ee0:	058ab783          	ld	a5,88(s5)
    80004ee4:	e6043703          	ld	a4,-416(s0)
    80004ee8:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80004eea:	058ab783          	ld	a5,88(s5)
    80004eee:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80004ef2:	85ea                	mv	a1,s10
    80004ef4:	ffffd097          	auipc	ra,0xffffd
    80004ef8:	c00080e7          	jalr	-1024(ra) # 80001af4 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80004efc:	0004851b          	sext.w	a0,s1
    80004f00:	bbe1                	j	80004cd8 <exec+0x98>
    80004f02:	e1243423          	sd	s2,-504(s0)
    proc_freepagetable(pagetable, sz);
    80004f06:	e0843583          	ld	a1,-504(s0)
    80004f0a:	855e                	mv	a0,s7
    80004f0c:	ffffd097          	auipc	ra,0xffffd
    80004f10:	be8080e7          	jalr	-1048(ra) # 80001af4 <proc_freepagetable>
  if(ip){
    80004f14:	da0498e3          	bnez	s1,80004cc4 <exec+0x84>
  return -1;
    80004f18:	557d                	li	a0,-1
    80004f1a:	bb7d                	j	80004cd8 <exec+0x98>
    80004f1c:	e1243423          	sd	s2,-504(s0)
    80004f20:	b7dd                	j	80004f06 <exec+0x2c6>
    80004f22:	e1243423          	sd	s2,-504(s0)
    80004f26:	b7c5                	j	80004f06 <exec+0x2c6>
    80004f28:	e1243423          	sd	s2,-504(s0)
    80004f2c:	bfe9                	j	80004f06 <exec+0x2c6>
  sz = sz1;
    80004f2e:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    80004f32:	4481                	li	s1,0
    80004f34:	bfc9                	j	80004f06 <exec+0x2c6>
  sz = sz1;
    80004f36:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    80004f3a:	4481                	li	s1,0
    80004f3c:	b7e9                	j	80004f06 <exec+0x2c6>
  sz = sz1;
    80004f3e:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    80004f42:	4481                	li	s1,0
    80004f44:	b7c9                	j	80004f06 <exec+0x2c6>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    80004f46:	e0843903          	ld	s2,-504(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004f4a:	2b05                	addiw	s6,s6,1
    80004f4c:	0389899b          	addiw	s3,s3,56
    80004f50:	e8045783          	lhu	a5,-384(s0)
    80004f54:	e2fb5be3          	bge	s6,a5,80004d8a <exec+0x14a>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80004f58:	2981                	sext.w	s3,s3
    80004f5a:	03800713          	li	a4,56
    80004f5e:	86ce                	mv	a3,s3
    80004f60:	e1040613          	addi	a2,s0,-496
    80004f64:	4581                	li	a1,0
    80004f66:	8526                	mv	a0,s1
    80004f68:	fffff097          	auipc	ra,0xfffff
    80004f6c:	a8e080e7          	jalr	-1394(ra) # 800039f6 <readi>
    80004f70:	03800793          	li	a5,56
    80004f74:	f8f517e3          	bne	a0,a5,80004f02 <exec+0x2c2>
    if(ph.type != ELF_PROG_LOAD)
    80004f78:	e1042783          	lw	a5,-496(s0)
    80004f7c:	4705                	li	a4,1
    80004f7e:	fce796e3          	bne	a5,a4,80004f4a <exec+0x30a>
    if(ph.memsz < ph.filesz)
    80004f82:	e3843603          	ld	a2,-456(s0)
    80004f86:	e3043783          	ld	a5,-464(s0)
    80004f8a:	f8f669e3          	bltu	a2,a5,80004f1c <exec+0x2dc>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80004f8e:	e2043783          	ld	a5,-480(s0)
    80004f92:	963e                	add	a2,a2,a5
    80004f94:	f8f667e3          	bltu	a2,a5,80004f22 <exec+0x2e2>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    80004f98:	85ca                	mv	a1,s2
    80004f9a:	855e                	mv	a0,s7
    80004f9c:	ffffc097          	auipc	ra,0xffffc
    80004fa0:	46a080e7          	jalr	1130(ra) # 80001406 <uvmalloc>
    80004fa4:	e0a43423          	sd	a0,-504(s0)
    80004fa8:	d141                	beqz	a0,80004f28 <exec+0x2e8>
    if(ph.vaddr % PGSIZE != 0)
    80004faa:	e2043d03          	ld	s10,-480(s0)
    80004fae:	df043783          	ld	a5,-528(s0)
    80004fb2:	00fd77b3          	and	a5,s10,a5
    80004fb6:	fba1                	bnez	a5,80004f06 <exec+0x2c6>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80004fb8:	e1842d83          	lw	s11,-488(s0)
    80004fbc:	e3042c03          	lw	s8,-464(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80004fc0:	f80c03e3          	beqz	s8,80004f46 <exec+0x306>
    80004fc4:	8a62                	mv	s4,s8
    80004fc6:	4901                	li	s2,0
    80004fc8:	b345                	j	80004d68 <exec+0x128>

0000000080004fca <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80004fca:	7179                	addi	sp,sp,-48
    80004fcc:	f406                	sd	ra,40(sp)
    80004fce:	f022                	sd	s0,32(sp)
    80004fd0:	ec26                	sd	s1,24(sp)
    80004fd2:	e84a                	sd	s2,16(sp)
    80004fd4:	1800                	addi	s0,sp,48
    80004fd6:	892e                	mv	s2,a1
    80004fd8:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
    80004fda:	fdc40593          	addi	a1,s0,-36
    80004fde:	ffffe097          	auipc	ra,0xffffe
    80004fe2:	b98080e7          	jalr	-1128(ra) # 80002b76 <argint>
    80004fe6:	04054063          	bltz	a0,80005026 <argfd+0x5c>
    return -1;
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80004fea:	fdc42703          	lw	a4,-36(s0)
    80004fee:	47bd                	li	a5,15
    80004ff0:	02e7ed63          	bltu	a5,a4,8000502a <argfd+0x60>
    80004ff4:	ffffd097          	auipc	ra,0xffffd
    80004ff8:	9a0080e7          	jalr	-1632(ra) # 80001994 <myproc>
    80004ffc:	fdc42703          	lw	a4,-36(s0)
    80005000:	01a70793          	addi	a5,a4,26
    80005004:	078e                	slli	a5,a5,0x3
    80005006:	953e                	add	a0,a0,a5
    80005008:	611c                	ld	a5,0(a0)
    8000500a:	c395                	beqz	a5,8000502e <argfd+0x64>
    return -1;
  if(pfd)
    8000500c:	00090463          	beqz	s2,80005014 <argfd+0x4a>
    *pfd = fd;
    80005010:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80005014:	4501                	li	a0,0
  if(pf)
    80005016:	c091                	beqz	s1,8000501a <argfd+0x50>
    *pf = f;
    80005018:	e09c                	sd	a5,0(s1)
}
    8000501a:	70a2                	ld	ra,40(sp)
    8000501c:	7402                	ld	s0,32(sp)
    8000501e:	64e2                	ld	s1,24(sp)
    80005020:	6942                	ld	s2,16(sp)
    80005022:	6145                	addi	sp,sp,48
    80005024:	8082                	ret
    return -1;
    80005026:	557d                	li	a0,-1
    80005028:	bfcd                	j	8000501a <argfd+0x50>
    return -1;
    8000502a:	557d                	li	a0,-1
    8000502c:	b7fd                	j	8000501a <argfd+0x50>
    8000502e:	557d                	li	a0,-1
    80005030:	b7ed                	j	8000501a <argfd+0x50>

0000000080005032 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80005032:	1101                	addi	sp,sp,-32
    80005034:	ec06                	sd	ra,24(sp)
    80005036:	e822                	sd	s0,16(sp)
    80005038:	e426                	sd	s1,8(sp)
    8000503a:	1000                	addi	s0,sp,32
    8000503c:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    8000503e:	ffffd097          	auipc	ra,0xffffd
    80005042:	956080e7          	jalr	-1706(ra) # 80001994 <myproc>
    80005046:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80005048:	0d050793          	addi	a5,a0,208 # fffffffffffff0d0 <end+0xffffffff7ffd90d0>
    8000504c:	4501                	li	a0,0
    8000504e:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80005050:	6398                	ld	a4,0(a5)
    80005052:	cb19                	beqz	a4,80005068 <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    80005054:	2505                	addiw	a0,a0,1
    80005056:	07a1                	addi	a5,a5,8
    80005058:	fed51ce3          	bne	a0,a3,80005050 <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    8000505c:	557d                	li	a0,-1
}
    8000505e:	60e2                	ld	ra,24(sp)
    80005060:	6442                	ld	s0,16(sp)
    80005062:	64a2                	ld	s1,8(sp)
    80005064:	6105                	addi	sp,sp,32
    80005066:	8082                	ret
      p->ofile[fd] = f;
    80005068:	01a50793          	addi	a5,a0,26
    8000506c:	078e                	slli	a5,a5,0x3
    8000506e:	963e                	add	a2,a2,a5
    80005070:	e204                	sd	s1,0(a2)
      return fd;
    80005072:	b7f5                	j	8000505e <fdalloc+0x2c>

0000000080005074 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80005074:	715d                	addi	sp,sp,-80
    80005076:	e486                	sd	ra,72(sp)
    80005078:	e0a2                	sd	s0,64(sp)
    8000507a:	fc26                	sd	s1,56(sp)
    8000507c:	f84a                	sd	s2,48(sp)
    8000507e:	f44e                	sd	s3,40(sp)
    80005080:	f052                	sd	s4,32(sp)
    80005082:	ec56                	sd	s5,24(sp)
    80005084:	0880                	addi	s0,sp,80
    80005086:	89ae                	mv	s3,a1
    80005088:	8ab2                	mv	s5,a2
    8000508a:	8a36                	mv	s4,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    8000508c:	fb040593          	addi	a1,s0,-80
    80005090:	fffff097          	auipc	ra,0xfffff
    80005094:	e86080e7          	jalr	-378(ra) # 80003f16 <nameiparent>
    80005098:	892a                	mv	s2,a0
    8000509a:	12050f63          	beqz	a0,800051d8 <create+0x164>
    return 0;

  ilock(dp);
    8000509e:	ffffe097          	auipc	ra,0xffffe
    800050a2:	6a4080e7          	jalr	1700(ra) # 80003742 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    800050a6:	4601                	li	a2,0
    800050a8:	fb040593          	addi	a1,s0,-80
    800050ac:	854a                	mv	a0,s2
    800050ae:	fffff097          	auipc	ra,0xfffff
    800050b2:	b78080e7          	jalr	-1160(ra) # 80003c26 <dirlookup>
    800050b6:	84aa                	mv	s1,a0
    800050b8:	c921                	beqz	a0,80005108 <create+0x94>
    iunlockput(dp);
    800050ba:	854a                	mv	a0,s2
    800050bc:	fffff097          	auipc	ra,0xfffff
    800050c0:	8e8080e7          	jalr	-1816(ra) # 800039a4 <iunlockput>
    ilock(ip);
    800050c4:	8526                	mv	a0,s1
    800050c6:	ffffe097          	auipc	ra,0xffffe
    800050ca:	67c080e7          	jalr	1660(ra) # 80003742 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    800050ce:	2981                	sext.w	s3,s3
    800050d0:	4789                	li	a5,2
    800050d2:	02f99463          	bne	s3,a5,800050fa <create+0x86>
    800050d6:	0444d783          	lhu	a5,68(s1)
    800050da:	37f9                	addiw	a5,a5,-2
    800050dc:	17c2                	slli	a5,a5,0x30
    800050de:	93c1                	srli	a5,a5,0x30
    800050e0:	4705                	li	a4,1
    800050e2:	00f76c63          	bltu	a4,a5,800050fa <create+0x86>
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
    800050e6:	8526                	mv	a0,s1
    800050e8:	60a6                	ld	ra,72(sp)
    800050ea:	6406                	ld	s0,64(sp)
    800050ec:	74e2                	ld	s1,56(sp)
    800050ee:	7942                	ld	s2,48(sp)
    800050f0:	79a2                	ld	s3,40(sp)
    800050f2:	7a02                	ld	s4,32(sp)
    800050f4:	6ae2                	ld	s5,24(sp)
    800050f6:	6161                	addi	sp,sp,80
    800050f8:	8082                	ret
    iunlockput(ip);
    800050fa:	8526                	mv	a0,s1
    800050fc:	fffff097          	auipc	ra,0xfffff
    80005100:	8a8080e7          	jalr	-1880(ra) # 800039a4 <iunlockput>
    return 0;
    80005104:	4481                	li	s1,0
    80005106:	b7c5                	j	800050e6 <create+0x72>
  if((ip = ialloc(dp->dev, type)) == 0)
    80005108:	85ce                	mv	a1,s3
    8000510a:	00092503          	lw	a0,0(s2)
    8000510e:	ffffe097          	auipc	ra,0xffffe
    80005112:	49c080e7          	jalr	1180(ra) # 800035aa <ialloc>
    80005116:	84aa                	mv	s1,a0
    80005118:	c529                	beqz	a0,80005162 <create+0xee>
  ilock(ip);
    8000511a:	ffffe097          	auipc	ra,0xffffe
    8000511e:	628080e7          	jalr	1576(ra) # 80003742 <ilock>
  ip->major = major;
    80005122:	05549323          	sh	s5,70(s1)
  ip->minor = minor;
    80005126:	05449423          	sh	s4,72(s1)
  ip->nlink = 1;
    8000512a:	4785                	li	a5,1
    8000512c:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005130:	8526                	mv	a0,s1
    80005132:	ffffe097          	auipc	ra,0xffffe
    80005136:	546080e7          	jalr	1350(ra) # 80003678 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    8000513a:	2981                	sext.w	s3,s3
    8000513c:	4785                	li	a5,1
    8000513e:	02f98a63          	beq	s3,a5,80005172 <create+0xfe>
  if(dirlink(dp, name, ip->inum) < 0)
    80005142:	40d0                	lw	a2,4(s1)
    80005144:	fb040593          	addi	a1,s0,-80
    80005148:	854a                	mv	a0,s2
    8000514a:	fffff097          	auipc	ra,0xfffff
    8000514e:	cec080e7          	jalr	-788(ra) # 80003e36 <dirlink>
    80005152:	06054b63          	bltz	a0,800051c8 <create+0x154>
  iunlockput(dp);
    80005156:	854a                	mv	a0,s2
    80005158:	fffff097          	auipc	ra,0xfffff
    8000515c:	84c080e7          	jalr	-1972(ra) # 800039a4 <iunlockput>
  return ip;
    80005160:	b759                	j	800050e6 <create+0x72>
    panic("create: ialloc");
    80005162:	00003517          	auipc	a0,0x3
    80005166:	57e50513          	addi	a0,a0,1406 # 800086e0 <syscalls+0x2b0>
    8000516a:	ffffb097          	auipc	ra,0xffffb
    8000516e:	3c6080e7          	jalr	966(ra) # 80000530 <panic>
    dp->nlink++;  // for ".."
    80005172:	04a95783          	lhu	a5,74(s2)
    80005176:	2785                	addiw	a5,a5,1
    80005178:	04f91523          	sh	a5,74(s2)
    iupdate(dp);
    8000517c:	854a                	mv	a0,s2
    8000517e:	ffffe097          	auipc	ra,0xffffe
    80005182:	4fa080e7          	jalr	1274(ra) # 80003678 <iupdate>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80005186:	40d0                	lw	a2,4(s1)
    80005188:	00003597          	auipc	a1,0x3
    8000518c:	56858593          	addi	a1,a1,1384 # 800086f0 <syscalls+0x2c0>
    80005190:	8526                	mv	a0,s1
    80005192:	fffff097          	auipc	ra,0xfffff
    80005196:	ca4080e7          	jalr	-860(ra) # 80003e36 <dirlink>
    8000519a:	00054f63          	bltz	a0,800051b8 <create+0x144>
    8000519e:	00492603          	lw	a2,4(s2)
    800051a2:	00003597          	auipc	a1,0x3
    800051a6:	55658593          	addi	a1,a1,1366 # 800086f8 <syscalls+0x2c8>
    800051aa:	8526                	mv	a0,s1
    800051ac:	fffff097          	auipc	ra,0xfffff
    800051b0:	c8a080e7          	jalr	-886(ra) # 80003e36 <dirlink>
    800051b4:	f80557e3          	bgez	a0,80005142 <create+0xce>
      panic("create dots");
    800051b8:	00003517          	auipc	a0,0x3
    800051bc:	54850513          	addi	a0,a0,1352 # 80008700 <syscalls+0x2d0>
    800051c0:	ffffb097          	auipc	ra,0xffffb
    800051c4:	370080e7          	jalr	880(ra) # 80000530 <panic>
    panic("create: dirlink");
    800051c8:	00003517          	auipc	a0,0x3
    800051cc:	54850513          	addi	a0,a0,1352 # 80008710 <syscalls+0x2e0>
    800051d0:	ffffb097          	auipc	ra,0xffffb
    800051d4:	360080e7          	jalr	864(ra) # 80000530 <panic>
    return 0;
    800051d8:	84aa                	mv	s1,a0
    800051da:	b731                	j	800050e6 <create+0x72>

00000000800051dc <sys_dup>:
{
    800051dc:	7179                	addi	sp,sp,-48
    800051de:	f406                	sd	ra,40(sp)
    800051e0:	f022                	sd	s0,32(sp)
    800051e2:	ec26                	sd	s1,24(sp)
    800051e4:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    800051e6:	fd840613          	addi	a2,s0,-40
    800051ea:	4581                	li	a1,0
    800051ec:	4501                	li	a0,0
    800051ee:	00000097          	auipc	ra,0x0
    800051f2:	ddc080e7          	jalr	-548(ra) # 80004fca <argfd>
    return -1;
    800051f6:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    800051f8:	02054363          	bltz	a0,8000521e <sys_dup+0x42>
  if((fd=fdalloc(f)) < 0)
    800051fc:	fd843503          	ld	a0,-40(s0)
    80005200:	00000097          	auipc	ra,0x0
    80005204:	e32080e7          	jalr	-462(ra) # 80005032 <fdalloc>
    80005208:	84aa                	mv	s1,a0
    return -1;
    8000520a:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    8000520c:	00054963          	bltz	a0,8000521e <sys_dup+0x42>
  filedup(f);
    80005210:	fd843503          	ld	a0,-40(s0)
    80005214:	fffff097          	auipc	ra,0xfffff
    80005218:	37a080e7          	jalr	890(ra) # 8000458e <filedup>
  return fd;
    8000521c:	87a6                	mv	a5,s1
}
    8000521e:	853e                	mv	a0,a5
    80005220:	70a2                	ld	ra,40(sp)
    80005222:	7402                	ld	s0,32(sp)
    80005224:	64e2                	ld	s1,24(sp)
    80005226:	6145                	addi	sp,sp,48
    80005228:	8082                	ret

000000008000522a <sys_read>:
{
    8000522a:	7179                	addi	sp,sp,-48
    8000522c:	f406                	sd	ra,40(sp)
    8000522e:	f022                	sd	s0,32(sp)
    80005230:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005232:	fe840613          	addi	a2,s0,-24
    80005236:	4581                	li	a1,0
    80005238:	4501                	li	a0,0
    8000523a:	00000097          	auipc	ra,0x0
    8000523e:	d90080e7          	jalr	-624(ra) # 80004fca <argfd>
    return -1;
    80005242:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005244:	04054163          	bltz	a0,80005286 <sys_read+0x5c>
    80005248:	fe440593          	addi	a1,s0,-28
    8000524c:	4509                	li	a0,2
    8000524e:	ffffe097          	auipc	ra,0xffffe
    80005252:	928080e7          	jalr	-1752(ra) # 80002b76 <argint>
    return -1;
    80005256:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005258:	02054763          	bltz	a0,80005286 <sys_read+0x5c>
    8000525c:	fd840593          	addi	a1,s0,-40
    80005260:	4505                	li	a0,1
    80005262:	ffffe097          	auipc	ra,0xffffe
    80005266:	936080e7          	jalr	-1738(ra) # 80002b98 <argaddr>
    return -1;
    8000526a:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000526c:	00054d63          	bltz	a0,80005286 <sys_read+0x5c>
  return fileread(f, p, n);
    80005270:	fe442603          	lw	a2,-28(s0)
    80005274:	fd843583          	ld	a1,-40(s0)
    80005278:	fe843503          	ld	a0,-24(s0)
    8000527c:	fffff097          	auipc	ra,0xfffff
    80005280:	49e080e7          	jalr	1182(ra) # 8000471a <fileread>
    80005284:	87aa                	mv	a5,a0
}
    80005286:	853e                	mv	a0,a5
    80005288:	70a2                	ld	ra,40(sp)
    8000528a:	7402                	ld	s0,32(sp)
    8000528c:	6145                	addi	sp,sp,48
    8000528e:	8082                	ret

0000000080005290 <sys_write>:
{
    80005290:	7179                	addi	sp,sp,-48
    80005292:	f406                	sd	ra,40(sp)
    80005294:	f022                	sd	s0,32(sp)
    80005296:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005298:	fe840613          	addi	a2,s0,-24
    8000529c:	4581                	li	a1,0
    8000529e:	4501                	li	a0,0
    800052a0:	00000097          	auipc	ra,0x0
    800052a4:	d2a080e7          	jalr	-726(ra) # 80004fca <argfd>
    return -1;
    800052a8:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800052aa:	04054163          	bltz	a0,800052ec <sys_write+0x5c>
    800052ae:	fe440593          	addi	a1,s0,-28
    800052b2:	4509                	li	a0,2
    800052b4:	ffffe097          	auipc	ra,0xffffe
    800052b8:	8c2080e7          	jalr	-1854(ra) # 80002b76 <argint>
    return -1;
    800052bc:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800052be:	02054763          	bltz	a0,800052ec <sys_write+0x5c>
    800052c2:	fd840593          	addi	a1,s0,-40
    800052c6:	4505                	li	a0,1
    800052c8:	ffffe097          	auipc	ra,0xffffe
    800052cc:	8d0080e7          	jalr	-1840(ra) # 80002b98 <argaddr>
    return -1;
    800052d0:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800052d2:	00054d63          	bltz	a0,800052ec <sys_write+0x5c>
  return filewrite(f, p, n);
    800052d6:	fe442603          	lw	a2,-28(s0)
    800052da:	fd843583          	ld	a1,-40(s0)
    800052de:	fe843503          	ld	a0,-24(s0)
    800052e2:	fffff097          	auipc	ra,0xfffff
    800052e6:	4fa080e7          	jalr	1274(ra) # 800047dc <filewrite>
    800052ea:	87aa                	mv	a5,a0
}
    800052ec:	853e                	mv	a0,a5
    800052ee:	70a2                	ld	ra,40(sp)
    800052f0:	7402                	ld	s0,32(sp)
    800052f2:	6145                	addi	sp,sp,48
    800052f4:	8082                	ret

00000000800052f6 <sys_close>:
{
    800052f6:	1101                	addi	sp,sp,-32
    800052f8:	ec06                	sd	ra,24(sp)
    800052fa:	e822                	sd	s0,16(sp)
    800052fc:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    800052fe:	fe040613          	addi	a2,s0,-32
    80005302:	fec40593          	addi	a1,s0,-20
    80005306:	4501                	li	a0,0
    80005308:	00000097          	auipc	ra,0x0
    8000530c:	cc2080e7          	jalr	-830(ra) # 80004fca <argfd>
    return -1;
    80005310:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80005312:	02054463          	bltz	a0,8000533a <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    80005316:	ffffc097          	auipc	ra,0xffffc
    8000531a:	67e080e7          	jalr	1662(ra) # 80001994 <myproc>
    8000531e:	fec42783          	lw	a5,-20(s0)
    80005322:	07e9                	addi	a5,a5,26
    80005324:	078e                	slli	a5,a5,0x3
    80005326:	97aa                	add	a5,a5,a0
    80005328:	0007b023          	sd	zero,0(a5)
  fileclose(f);
    8000532c:	fe043503          	ld	a0,-32(s0)
    80005330:	fffff097          	auipc	ra,0xfffff
    80005334:	2b0080e7          	jalr	688(ra) # 800045e0 <fileclose>
  return 0;
    80005338:	4781                	li	a5,0
}
    8000533a:	853e                	mv	a0,a5
    8000533c:	60e2                	ld	ra,24(sp)
    8000533e:	6442                	ld	s0,16(sp)
    80005340:	6105                	addi	sp,sp,32
    80005342:	8082                	ret

0000000080005344 <sys_fstat>:
{
    80005344:	1101                	addi	sp,sp,-32
    80005346:	ec06                	sd	ra,24(sp)
    80005348:	e822                	sd	s0,16(sp)
    8000534a:	1000                	addi	s0,sp,32
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    8000534c:	fe840613          	addi	a2,s0,-24
    80005350:	4581                	li	a1,0
    80005352:	4501                	li	a0,0
    80005354:	00000097          	auipc	ra,0x0
    80005358:	c76080e7          	jalr	-906(ra) # 80004fca <argfd>
    return -1;
    8000535c:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    8000535e:	02054563          	bltz	a0,80005388 <sys_fstat+0x44>
    80005362:	fe040593          	addi	a1,s0,-32
    80005366:	4505                	li	a0,1
    80005368:	ffffe097          	auipc	ra,0xffffe
    8000536c:	830080e7          	jalr	-2000(ra) # 80002b98 <argaddr>
    return -1;
    80005370:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    80005372:	00054b63          	bltz	a0,80005388 <sys_fstat+0x44>
  return filestat(f, st);
    80005376:	fe043583          	ld	a1,-32(s0)
    8000537a:	fe843503          	ld	a0,-24(s0)
    8000537e:	fffff097          	auipc	ra,0xfffff
    80005382:	32a080e7          	jalr	810(ra) # 800046a8 <filestat>
    80005386:	87aa                	mv	a5,a0
}
    80005388:	853e                	mv	a0,a5
    8000538a:	60e2                	ld	ra,24(sp)
    8000538c:	6442                	ld	s0,16(sp)
    8000538e:	6105                	addi	sp,sp,32
    80005390:	8082                	ret

0000000080005392 <sys_link>:
{
    80005392:	7169                	addi	sp,sp,-304
    80005394:	f606                	sd	ra,296(sp)
    80005396:	f222                	sd	s0,288(sp)
    80005398:	ee26                	sd	s1,280(sp)
    8000539a:	ea4a                	sd	s2,272(sp)
    8000539c:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000539e:	08000613          	li	a2,128
    800053a2:	ed040593          	addi	a1,s0,-304
    800053a6:	4501                	li	a0,0
    800053a8:	ffffe097          	auipc	ra,0xffffe
    800053ac:	812080e7          	jalr	-2030(ra) # 80002bba <argstr>
    return -1;
    800053b0:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800053b2:	10054e63          	bltz	a0,800054ce <sys_link+0x13c>
    800053b6:	08000613          	li	a2,128
    800053ba:	f5040593          	addi	a1,s0,-176
    800053be:	4505                	li	a0,1
    800053c0:	ffffd097          	auipc	ra,0xffffd
    800053c4:	7fa080e7          	jalr	2042(ra) # 80002bba <argstr>
    return -1;
    800053c8:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800053ca:	10054263          	bltz	a0,800054ce <sys_link+0x13c>
  begin_op();
    800053ce:	fffff097          	auipc	ra,0xfffff
    800053d2:	d46080e7          	jalr	-698(ra) # 80004114 <begin_op>
  if((ip = namei(old)) == 0){
    800053d6:	ed040513          	addi	a0,s0,-304
    800053da:	fffff097          	auipc	ra,0xfffff
    800053de:	b1e080e7          	jalr	-1250(ra) # 80003ef8 <namei>
    800053e2:	84aa                	mv	s1,a0
    800053e4:	c551                	beqz	a0,80005470 <sys_link+0xde>
  ilock(ip);
    800053e6:	ffffe097          	auipc	ra,0xffffe
    800053ea:	35c080e7          	jalr	860(ra) # 80003742 <ilock>
  if(ip->type == T_DIR){
    800053ee:	04449703          	lh	a4,68(s1)
    800053f2:	4785                	li	a5,1
    800053f4:	08f70463          	beq	a4,a5,8000547c <sys_link+0xea>
  ip->nlink++;
    800053f8:	04a4d783          	lhu	a5,74(s1)
    800053fc:	2785                	addiw	a5,a5,1
    800053fe:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005402:	8526                	mv	a0,s1
    80005404:	ffffe097          	auipc	ra,0xffffe
    80005408:	274080e7          	jalr	628(ra) # 80003678 <iupdate>
  iunlock(ip);
    8000540c:	8526                	mv	a0,s1
    8000540e:	ffffe097          	auipc	ra,0xffffe
    80005412:	3f6080e7          	jalr	1014(ra) # 80003804 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80005416:	fd040593          	addi	a1,s0,-48
    8000541a:	f5040513          	addi	a0,s0,-176
    8000541e:	fffff097          	auipc	ra,0xfffff
    80005422:	af8080e7          	jalr	-1288(ra) # 80003f16 <nameiparent>
    80005426:	892a                	mv	s2,a0
    80005428:	c935                	beqz	a0,8000549c <sys_link+0x10a>
  ilock(dp);
    8000542a:	ffffe097          	auipc	ra,0xffffe
    8000542e:	318080e7          	jalr	792(ra) # 80003742 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80005432:	00092703          	lw	a4,0(s2)
    80005436:	409c                	lw	a5,0(s1)
    80005438:	04f71d63          	bne	a4,a5,80005492 <sys_link+0x100>
    8000543c:	40d0                	lw	a2,4(s1)
    8000543e:	fd040593          	addi	a1,s0,-48
    80005442:	854a                	mv	a0,s2
    80005444:	fffff097          	auipc	ra,0xfffff
    80005448:	9f2080e7          	jalr	-1550(ra) # 80003e36 <dirlink>
    8000544c:	04054363          	bltz	a0,80005492 <sys_link+0x100>
  iunlockput(dp);
    80005450:	854a                	mv	a0,s2
    80005452:	ffffe097          	auipc	ra,0xffffe
    80005456:	552080e7          	jalr	1362(ra) # 800039a4 <iunlockput>
  iput(ip);
    8000545a:	8526                	mv	a0,s1
    8000545c:	ffffe097          	auipc	ra,0xffffe
    80005460:	4a0080e7          	jalr	1184(ra) # 800038fc <iput>
  end_op();
    80005464:	fffff097          	auipc	ra,0xfffff
    80005468:	d30080e7          	jalr	-720(ra) # 80004194 <end_op>
  return 0;
    8000546c:	4781                	li	a5,0
    8000546e:	a085                	j	800054ce <sys_link+0x13c>
    end_op();
    80005470:	fffff097          	auipc	ra,0xfffff
    80005474:	d24080e7          	jalr	-732(ra) # 80004194 <end_op>
    return -1;
    80005478:	57fd                	li	a5,-1
    8000547a:	a891                	j	800054ce <sys_link+0x13c>
    iunlockput(ip);
    8000547c:	8526                	mv	a0,s1
    8000547e:	ffffe097          	auipc	ra,0xffffe
    80005482:	526080e7          	jalr	1318(ra) # 800039a4 <iunlockput>
    end_op();
    80005486:	fffff097          	auipc	ra,0xfffff
    8000548a:	d0e080e7          	jalr	-754(ra) # 80004194 <end_op>
    return -1;
    8000548e:	57fd                	li	a5,-1
    80005490:	a83d                	j	800054ce <sys_link+0x13c>
    iunlockput(dp);
    80005492:	854a                	mv	a0,s2
    80005494:	ffffe097          	auipc	ra,0xffffe
    80005498:	510080e7          	jalr	1296(ra) # 800039a4 <iunlockput>
  ilock(ip);
    8000549c:	8526                	mv	a0,s1
    8000549e:	ffffe097          	auipc	ra,0xffffe
    800054a2:	2a4080e7          	jalr	676(ra) # 80003742 <ilock>
  ip->nlink--;
    800054a6:	04a4d783          	lhu	a5,74(s1)
    800054aa:	37fd                	addiw	a5,a5,-1
    800054ac:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800054b0:	8526                	mv	a0,s1
    800054b2:	ffffe097          	auipc	ra,0xffffe
    800054b6:	1c6080e7          	jalr	454(ra) # 80003678 <iupdate>
  iunlockput(ip);
    800054ba:	8526                	mv	a0,s1
    800054bc:	ffffe097          	auipc	ra,0xffffe
    800054c0:	4e8080e7          	jalr	1256(ra) # 800039a4 <iunlockput>
  end_op();
    800054c4:	fffff097          	auipc	ra,0xfffff
    800054c8:	cd0080e7          	jalr	-816(ra) # 80004194 <end_op>
  return -1;
    800054cc:	57fd                	li	a5,-1
}
    800054ce:	853e                	mv	a0,a5
    800054d0:	70b2                	ld	ra,296(sp)
    800054d2:	7412                	ld	s0,288(sp)
    800054d4:	64f2                	ld	s1,280(sp)
    800054d6:	6952                	ld	s2,272(sp)
    800054d8:	6155                	addi	sp,sp,304
    800054da:	8082                	ret

00000000800054dc <sys_unlink>:
{
    800054dc:	7151                	addi	sp,sp,-240
    800054de:	f586                	sd	ra,232(sp)
    800054e0:	f1a2                	sd	s0,224(sp)
    800054e2:	eda6                	sd	s1,216(sp)
    800054e4:	e9ca                	sd	s2,208(sp)
    800054e6:	e5ce                	sd	s3,200(sp)
    800054e8:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    800054ea:	08000613          	li	a2,128
    800054ee:	f3040593          	addi	a1,s0,-208
    800054f2:	4501                	li	a0,0
    800054f4:	ffffd097          	auipc	ra,0xffffd
    800054f8:	6c6080e7          	jalr	1734(ra) # 80002bba <argstr>
    800054fc:	18054163          	bltz	a0,8000567e <sys_unlink+0x1a2>
  begin_op();
    80005500:	fffff097          	auipc	ra,0xfffff
    80005504:	c14080e7          	jalr	-1004(ra) # 80004114 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80005508:	fb040593          	addi	a1,s0,-80
    8000550c:	f3040513          	addi	a0,s0,-208
    80005510:	fffff097          	auipc	ra,0xfffff
    80005514:	a06080e7          	jalr	-1530(ra) # 80003f16 <nameiparent>
    80005518:	84aa                	mv	s1,a0
    8000551a:	c979                	beqz	a0,800055f0 <sys_unlink+0x114>
  ilock(dp);
    8000551c:	ffffe097          	auipc	ra,0xffffe
    80005520:	226080e7          	jalr	550(ra) # 80003742 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80005524:	00003597          	auipc	a1,0x3
    80005528:	1cc58593          	addi	a1,a1,460 # 800086f0 <syscalls+0x2c0>
    8000552c:	fb040513          	addi	a0,s0,-80
    80005530:	ffffe097          	auipc	ra,0xffffe
    80005534:	6dc080e7          	jalr	1756(ra) # 80003c0c <namecmp>
    80005538:	14050a63          	beqz	a0,8000568c <sys_unlink+0x1b0>
    8000553c:	00003597          	auipc	a1,0x3
    80005540:	1bc58593          	addi	a1,a1,444 # 800086f8 <syscalls+0x2c8>
    80005544:	fb040513          	addi	a0,s0,-80
    80005548:	ffffe097          	auipc	ra,0xffffe
    8000554c:	6c4080e7          	jalr	1732(ra) # 80003c0c <namecmp>
    80005550:	12050e63          	beqz	a0,8000568c <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    80005554:	f2c40613          	addi	a2,s0,-212
    80005558:	fb040593          	addi	a1,s0,-80
    8000555c:	8526                	mv	a0,s1
    8000555e:	ffffe097          	auipc	ra,0xffffe
    80005562:	6c8080e7          	jalr	1736(ra) # 80003c26 <dirlookup>
    80005566:	892a                	mv	s2,a0
    80005568:	12050263          	beqz	a0,8000568c <sys_unlink+0x1b0>
  ilock(ip);
    8000556c:	ffffe097          	auipc	ra,0xffffe
    80005570:	1d6080e7          	jalr	470(ra) # 80003742 <ilock>
  if(ip->nlink < 1)
    80005574:	04a91783          	lh	a5,74(s2)
    80005578:	08f05263          	blez	a5,800055fc <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    8000557c:	04491703          	lh	a4,68(s2)
    80005580:	4785                	li	a5,1
    80005582:	08f70563          	beq	a4,a5,8000560c <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    80005586:	4641                	li	a2,16
    80005588:	4581                	li	a1,0
    8000558a:	fc040513          	addi	a0,s0,-64
    8000558e:	ffffb097          	auipc	ra,0xffffb
    80005592:	744080e7          	jalr	1860(ra) # 80000cd2 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005596:	4741                	li	a4,16
    80005598:	f2c42683          	lw	a3,-212(s0)
    8000559c:	fc040613          	addi	a2,s0,-64
    800055a0:	4581                	li	a1,0
    800055a2:	8526                	mv	a0,s1
    800055a4:	ffffe097          	auipc	ra,0xffffe
    800055a8:	54a080e7          	jalr	1354(ra) # 80003aee <writei>
    800055ac:	47c1                	li	a5,16
    800055ae:	0af51563          	bne	a0,a5,80005658 <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    800055b2:	04491703          	lh	a4,68(s2)
    800055b6:	4785                	li	a5,1
    800055b8:	0af70863          	beq	a4,a5,80005668 <sys_unlink+0x18c>
  iunlockput(dp);
    800055bc:	8526                	mv	a0,s1
    800055be:	ffffe097          	auipc	ra,0xffffe
    800055c2:	3e6080e7          	jalr	998(ra) # 800039a4 <iunlockput>
  ip->nlink--;
    800055c6:	04a95783          	lhu	a5,74(s2)
    800055ca:	37fd                	addiw	a5,a5,-1
    800055cc:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    800055d0:	854a                	mv	a0,s2
    800055d2:	ffffe097          	auipc	ra,0xffffe
    800055d6:	0a6080e7          	jalr	166(ra) # 80003678 <iupdate>
  iunlockput(ip);
    800055da:	854a                	mv	a0,s2
    800055dc:	ffffe097          	auipc	ra,0xffffe
    800055e0:	3c8080e7          	jalr	968(ra) # 800039a4 <iunlockput>
  end_op();
    800055e4:	fffff097          	auipc	ra,0xfffff
    800055e8:	bb0080e7          	jalr	-1104(ra) # 80004194 <end_op>
  return 0;
    800055ec:	4501                	li	a0,0
    800055ee:	a84d                	j	800056a0 <sys_unlink+0x1c4>
    end_op();
    800055f0:	fffff097          	auipc	ra,0xfffff
    800055f4:	ba4080e7          	jalr	-1116(ra) # 80004194 <end_op>
    return -1;
    800055f8:	557d                	li	a0,-1
    800055fa:	a05d                	j	800056a0 <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    800055fc:	00003517          	auipc	a0,0x3
    80005600:	12450513          	addi	a0,a0,292 # 80008720 <syscalls+0x2f0>
    80005604:	ffffb097          	auipc	ra,0xffffb
    80005608:	f2c080e7          	jalr	-212(ra) # 80000530 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    8000560c:	04c92703          	lw	a4,76(s2)
    80005610:	02000793          	li	a5,32
    80005614:	f6e7f9e3          	bgeu	a5,a4,80005586 <sys_unlink+0xaa>
    80005618:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000561c:	4741                	li	a4,16
    8000561e:	86ce                	mv	a3,s3
    80005620:	f1840613          	addi	a2,s0,-232
    80005624:	4581                	li	a1,0
    80005626:	854a                	mv	a0,s2
    80005628:	ffffe097          	auipc	ra,0xffffe
    8000562c:	3ce080e7          	jalr	974(ra) # 800039f6 <readi>
    80005630:	47c1                	li	a5,16
    80005632:	00f51b63          	bne	a0,a5,80005648 <sys_unlink+0x16c>
    if(de.inum != 0)
    80005636:	f1845783          	lhu	a5,-232(s0)
    8000563a:	e7a1                	bnez	a5,80005682 <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    8000563c:	29c1                	addiw	s3,s3,16
    8000563e:	04c92783          	lw	a5,76(s2)
    80005642:	fcf9ede3          	bltu	s3,a5,8000561c <sys_unlink+0x140>
    80005646:	b781                	j	80005586 <sys_unlink+0xaa>
      panic("isdirempty: readi");
    80005648:	00003517          	auipc	a0,0x3
    8000564c:	0f050513          	addi	a0,a0,240 # 80008738 <syscalls+0x308>
    80005650:	ffffb097          	auipc	ra,0xffffb
    80005654:	ee0080e7          	jalr	-288(ra) # 80000530 <panic>
    panic("unlink: writei");
    80005658:	00003517          	auipc	a0,0x3
    8000565c:	0f850513          	addi	a0,a0,248 # 80008750 <syscalls+0x320>
    80005660:	ffffb097          	auipc	ra,0xffffb
    80005664:	ed0080e7          	jalr	-304(ra) # 80000530 <panic>
    dp->nlink--;
    80005668:	04a4d783          	lhu	a5,74(s1)
    8000566c:	37fd                	addiw	a5,a5,-1
    8000566e:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005672:	8526                	mv	a0,s1
    80005674:	ffffe097          	auipc	ra,0xffffe
    80005678:	004080e7          	jalr	4(ra) # 80003678 <iupdate>
    8000567c:	b781                	j	800055bc <sys_unlink+0xe0>
    return -1;
    8000567e:	557d                	li	a0,-1
    80005680:	a005                	j	800056a0 <sys_unlink+0x1c4>
    iunlockput(ip);
    80005682:	854a                	mv	a0,s2
    80005684:	ffffe097          	auipc	ra,0xffffe
    80005688:	320080e7          	jalr	800(ra) # 800039a4 <iunlockput>
  iunlockput(dp);
    8000568c:	8526                	mv	a0,s1
    8000568e:	ffffe097          	auipc	ra,0xffffe
    80005692:	316080e7          	jalr	790(ra) # 800039a4 <iunlockput>
  end_op();
    80005696:	fffff097          	auipc	ra,0xfffff
    8000569a:	afe080e7          	jalr	-1282(ra) # 80004194 <end_op>
  return -1;
    8000569e:	557d                	li	a0,-1
}
    800056a0:	70ae                	ld	ra,232(sp)
    800056a2:	740e                	ld	s0,224(sp)
    800056a4:	64ee                	ld	s1,216(sp)
    800056a6:	694e                	ld	s2,208(sp)
    800056a8:	69ae                	ld	s3,200(sp)
    800056aa:	616d                	addi	sp,sp,240
    800056ac:	8082                	ret

00000000800056ae <sys_open>:

uint64
sys_open(void)
{
    800056ae:	7131                	addi	sp,sp,-192
    800056b0:	fd06                	sd	ra,184(sp)
    800056b2:	f922                	sd	s0,176(sp)
    800056b4:	f526                	sd	s1,168(sp)
    800056b6:	f14a                	sd	s2,160(sp)
    800056b8:	ed4e                	sd	s3,152(sp)
    800056ba:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    800056bc:	08000613          	li	a2,128
    800056c0:	f5040593          	addi	a1,s0,-176
    800056c4:	4501                	li	a0,0
    800056c6:	ffffd097          	auipc	ra,0xffffd
    800056ca:	4f4080e7          	jalr	1268(ra) # 80002bba <argstr>
    return -1;
    800056ce:	54fd                	li	s1,-1
  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    800056d0:	0c054163          	bltz	a0,80005792 <sys_open+0xe4>
    800056d4:	f4c40593          	addi	a1,s0,-180
    800056d8:	4505                	li	a0,1
    800056da:	ffffd097          	auipc	ra,0xffffd
    800056de:	49c080e7          	jalr	1180(ra) # 80002b76 <argint>
    800056e2:	0a054863          	bltz	a0,80005792 <sys_open+0xe4>

  begin_op();
    800056e6:	fffff097          	auipc	ra,0xfffff
    800056ea:	a2e080e7          	jalr	-1490(ra) # 80004114 <begin_op>

  if(omode & O_CREATE){
    800056ee:	f4c42783          	lw	a5,-180(s0)
    800056f2:	2007f793          	andi	a5,a5,512
    800056f6:	cbdd                	beqz	a5,800057ac <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    800056f8:	4681                	li	a3,0
    800056fa:	4601                	li	a2,0
    800056fc:	4589                	li	a1,2
    800056fe:	f5040513          	addi	a0,s0,-176
    80005702:	00000097          	auipc	ra,0x0
    80005706:	972080e7          	jalr	-1678(ra) # 80005074 <create>
    8000570a:	892a                	mv	s2,a0
    if(ip == 0){
    8000570c:	c959                	beqz	a0,800057a2 <sys_open+0xf4>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    8000570e:	04491703          	lh	a4,68(s2)
    80005712:	478d                	li	a5,3
    80005714:	00f71763          	bne	a4,a5,80005722 <sys_open+0x74>
    80005718:	04695703          	lhu	a4,70(s2)
    8000571c:	47a5                	li	a5,9
    8000571e:	0ce7ec63          	bltu	a5,a4,800057f6 <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80005722:	fffff097          	auipc	ra,0xfffff
    80005726:	e02080e7          	jalr	-510(ra) # 80004524 <filealloc>
    8000572a:	89aa                	mv	s3,a0
    8000572c:	10050263          	beqz	a0,80005830 <sys_open+0x182>
    80005730:	00000097          	auipc	ra,0x0
    80005734:	902080e7          	jalr	-1790(ra) # 80005032 <fdalloc>
    80005738:	84aa                	mv	s1,a0
    8000573a:	0e054663          	bltz	a0,80005826 <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    8000573e:	04491703          	lh	a4,68(s2)
    80005742:	478d                	li	a5,3
    80005744:	0cf70463          	beq	a4,a5,8000580c <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80005748:	4789                	li	a5,2
    8000574a:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    8000574e:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    80005752:	0129bc23          	sd	s2,24(s3)
  f->readable = !(omode & O_WRONLY);
    80005756:	f4c42783          	lw	a5,-180(s0)
    8000575a:	0017c713          	xori	a4,a5,1
    8000575e:	8b05                	andi	a4,a4,1
    80005760:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005764:	0037f713          	andi	a4,a5,3
    80005768:	00e03733          	snez	a4,a4
    8000576c:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80005770:	4007f793          	andi	a5,a5,1024
    80005774:	c791                	beqz	a5,80005780 <sys_open+0xd2>
    80005776:	04491703          	lh	a4,68(s2)
    8000577a:	4789                	li	a5,2
    8000577c:	08f70f63          	beq	a4,a5,8000581a <sys_open+0x16c>
    itrunc(ip);
  }

  iunlock(ip);
    80005780:	854a                	mv	a0,s2
    80005782:	ffffe097          	auipc	ra,0xffffe
    80005786:	082080e7          	jalr	130(ra) # 80003804 <iunlock>
  end_op();
    8000578a:	fffff097          	auipc	ra,0xfffff
    8000578e:	a0a080e7          	jalr	-1526(ra) # 80004194 <end_op>

  return fd;
}
    80005792:	8526                	mv	a0,s1
    80005794:	70ea                	ld	ra,184(sp)
    80005796:	744a                	ld	s0,176(sp)
    80005798:	74aa                	ld	s1,168(sp)
    8000579a:	790a                	ld	s2,160(sp)
    8000579c:	69ea                	ld	s3,152(sp)
    8000579e:	6129                	addi	sp,sp,192
    800057a0:	8082                	ret
      end_op();
    800057a2:	fffff097          	auipc	ra,0xfffff
    800057a6:	9f2080e7          	jalr	-1550(ra) # 80004194 <end_op>
      return -1;
    800057aa:	b7e5                	j	80005792 <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    800057ac:	f5040513          	addi	a0,s0,-176
    800057b0:	ffffe097          	auipc	ra,0xffffe
    800057b4:	748080e7          	jalr	1864(ra) # 80003ef8 <namei>
    800057b8:	892a                	mv	s2,a0
    800057ba:	c905                	beqz	a0,800057ea <sys_open+0x13c>
    ilock(ip);
    800057bc:	ffffe097          	auipc	ra,0xffffe
    800057c0:	f86080e7          	jalr	-122(ra) # 80003742 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    800057c4:	04491703          	lh	a4,68(s2)
    800057c8:	4785                	li	a5,1
    800057ca:	f4f712e3          	bne	a4,a5,8000570e <sys_open+0x60>
    800057ce:	f4c42783          	lw	a5,-180(s0)
    800057d2:	dba1                	beqz	a5,80005722 <sys_open+0x74>
      iunlockput(ip);
    800057d4:	854a                	mv	a0,s2
    800057d6:	ffffe097          	auipc	ra,0xffffe
    800057da:	1ce080e7          	jalr	462(ra) # 800039a4 <iunlockput>
      end_op();
    800057de:	fffff097          	auipc	ra,0xfffff
    800057e2:	9b6080e7          	jalr	-1610(ra) # 80004194 <end_op>
      return -1;
    800057e6:	54fd                	li	s1,-1
    800057e8:	b76d                	j	80005792 <sys_open+0xe4>
      end_op();
    800057ea:	fffff097          	auipc	ra,0xfffff
    800057ee:	9aa080e7          	jalr	-1622(ra) # 80004194 <end_op>
      return -1;
    800057f2:	54fd                	li	s1,-1
    800057f4:	bf79                	j	80005792 <sys_open+0xe4>
    iunlockput(ip);
    800057f6:	854a                	mv	a0,s2
    800057f8:	ffffe097          	auipc	ra,0xffffe
    800057fc:	1ac080e7          	jalr	428(ra) # 800039a4 <iunlockput>
    end_op();
    80005800:	fffff097          	auipc	ra,0xfffff
    80005804:	994080e7          	jalr	-1644(ra) # 80004194 <end_op>
    return -1;
    80005808:	54fd                	li	s1,-1
    8000580a:	b761                	j	80005792 <sys_open+0xe4>
    f->type = FD_DEVICE;
    8000580c:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    80005810:	04691783          	lh	a5,70(s2)
    80005814:	02f99223          	sh	a5,36(s3)
    80005818:	bf2d                	j	80005752 <sys_open+0xa4>
    itrunc(ip);
    8000581a:	854a                	mv	a0,s2
    8000581c:	ffffe097          	auipc	ra,0xffffe
    80005820:	034080e7          	jalr	52(ra) # 80003850 <itrunc>
    80005824:	bfb1                	j	80005780 <sys_open+0xd2>
      fileclose(f);
    80005826:	854e                	mv	a0,s3
    80005828:	fffff097          	auipc	ra,0xfffff
    8000582c:	db8080e7          	jalr	-584(ra) # 800045e0 <fileclose>
    iunlockput(ip);
    80005830:	854a                	mv	a0,s2
    80005832:	ffffe097          	auipc	ra,0xffffe
    80005836:	172080e7          	jalr	370(ra) # 800039a4 <iunlockput>
    end_op();
    8000583a:	fffff097          	auipc	ra,0xfffff
    8000583e:	95a080e7          	jalr	-1702(ra) # 80004194 <end_op>
    return -1;
    80005842:	54fd                	li	s1,-1
    80005844:	b7b9                	j	80005792 <sys_open+0xe4>

0000000080005846 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005846:	7175                	addi	sp,sp,-144
    80005848:	e506                	sd	ra,136(sp)
    8000584a:	e122                	sd	s0,128(sp)
    8000584c:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    8000584e:	fffff097          	auipc	ra,0xfffff
    80005852:	8c6080e7          	jalr	-1850(ra) # 80004114 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005856:	08000613          	li	a2,128
    8000585a:	f7040593          	addi	a1,s0,-144
    8000585e:	4501                	li	a0,0
    80005860:	ffffd097          	auipc	ra,0xffffd
    80005864:	35a080e7          	jalr	858(ra) # 80002bba <argstr>
    80005868:	02054963          	bltz	a0,8000589a <sys_mkdir+0x54>
    8000586c:	4681                	li	a3,0
    8000586e:	4601                	li	a2,0
    80005870:	4585                	li	a1,1
    80005872:	f7040513          	addi	a0,s0,-144
    80005876:	fffff097          	auipc	ra,0xfffff
    8000587a:	7fe080e7          	jalr	2046(ra) # 80005074 <create>
    8000587e:	cd11                	beqz	a0,8000589a <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005880:	ffffe097          	auipc	ra,0xffffe
    80005884:	124080e7          	jalr	292(ra) # 800039a4 <iunlockput>
  end_op();
    80005888:	fffff097          	auipc	ra,0xfffff
    8000588c:	90c080e7          	jalr	-1780(ra) # 80004194 <end_op>
  return 0;
    80005890:	4501                	li	a0,0
}
    80005892:	60aa                	ld	ra,136(sp)
    80005894:	640a                	ld	s0,128(sp)
    80005896:	6149                	addi	sp,sp,144
    80005898:	8082                	ret
    end_op();
    8000589a:	fffff097          	auipc	ra,0xfffff
    8000589e:	8fa080e7          	jalr	-1798(ra) # 80004194 <end_op>
    return -1;
    800058a2:	557d                	li	a0,-1
    800058a4:	b7fd                	j	80005892 <sys_mkdir+0x4c>

00000000800058a6 <sys_mknod>:

uint64
sys_mknod(void)
{
    800058a6:	7135                	addi	sp,sp,-160
    800058a8:	ed06                	sd	ra,152(sp)
    800058aa:	e922                	sd	s0,144(sp)
    800058ac:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    800058ae:	fffff097          	auipc	ra,0xfffff
    800058b2:	866080e7          	jalr	-1946(ra) # 80004114 <begin_op>
  if((argstr(0, path, MAXPATH)) < 0 ||
    800058b6:	08000613          	li	a2,128
    800058ba:	f7040593          	addi	a1,s0,-144
    800058be:	4501                	li	a0,0
    800058c0:	ffffd097          	auipc	ra,0xffffd
    800058c4:	2fa080e7          	jalr	762(ra) # 80002bba <argstr>
    800058c8:	04054a63          	bltz	a0,8000591c <sys_mknod+0x76>
     argint(1, &major) < 0 ||
    800058cc:	f6c40593          	addi	a1,s0,-148
    800058d0:	4505                	li	a0,1
    800058d2:	ffffd097          	auipc	ra,0xffffd
    800058d6:	2a4080e7          	jalr	676(ra) # 80002b76 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    800058da:	04054163          	bltz	a0,8000591c <sys_mknod+0x76>
     argint(2, &minor) < 0 ||
    800058de:	f6840593          	addi	a1,s0,-152
    800058e2:	4509                	li	a0,2
    800058e4:	ffffd097          	auipc	ra,0xffffd
    800058e8:	292080e7          	jalr	658(ra) # 80002b76 <argint>
     argint(1, &major) < 0 ||
    800058ec:	02054863          	bltz	a0,8000591c <sys_mknod+0x76>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    800058f0:	f6841683          	lh	a3,-152(s0)
    800058f4:	f6c41603          	lh	a2,-148(s0)
    800058f8:	458d                	li	a1,3
    800058fa:	f7040513          	addi	a0,s0,-144
    800058fe:	fffff097          	auipc	ra,0xfffff
    80005902:	776080e7          	jalr	1910(ra) # 80005074 <create>
     argint(2, &minor) < 0 ||
    80005906:	c919                	beqz	a0,8000591c <sys_mknod+0x76>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005908:	ffffe097          	auipc	ra,0xffffe
    8000590c:	09c080e7          	jalr	156(ra) # 800039a4 <iunlockput>
  end_op();
    80005910:	fffff097          	auipc	ra,0xfffff
    80005914:	884080e7          	jalr	-1916(ra) # 80004194 <end_op>
  return 0;
    80005918:	4501                	li	a0,0
    8000591a:	a031                	j	80005926 <sys_mknod+0x80>
    end_op();
    8000591c:	fffff097          	auipc	ra,0xfffff
    80005920:	878080e7          	jalr	-1928(ra) # 80004194 <end_op>
    return -1;
    80005924:	557d                	li	a0,-1
}
    80005926:	60ea                	ld	ra,152(sp)
    80005928:	644a                	ld	s0,144(sp)
    8000592a:	610d                	addi	sp,sp,160
    8000592c:	8082                	ret

000000008000592e <sys_chdir>:

uint64
sys_chdir(void)
{
    8000592e:	7135                	addi	sp,sp,-160
    80005930:	ed06                	sd	ra,152(sp)
    80005932:	e922                	sd	s0,144(sp)
    80005934:	e526                	sd	s1,136(sp)
    80005936:	e14a                	sd	s2,128(sp)
    80005938:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    8000593a:	ffffc097          	auipc	ra,0xffffc
    8000593e:	05a080e7          	jalr	90(ra) # 80001994 <myproc>
    80005942:	892a                	mv	s2,a0
  
  begin_op();
    80005944:	ffffe097          	auipc	ra,0xffffe
    80005948:	7d0080e7          	jalr	2000(ra) # 80004114 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    8000594c:	08000613          	li	a2,128
    80005950:	f6040593          	addi	a1,s0,-160
    80005954:	4501                	li	a0,0
    80005956:	ffffd097          	auipc	ra,0xffffd
    8000595a:	264080e7          	jalr	612(ra) # 80002bba <argstr>
    8000595e:	04054b63          	bltz	a0,800059b4 <sys_chdir+0x86>
    80005962:	f6040513          	addi	a0,s0,-160
    80005966:	ffffe097          	auipc	ra,0xffffe
    8000596a:	592080e7          	jalr	1426(ra) # 80003ef8 <namei>
    8000596e:	84aa                	mv	s1,a0
    80005970:	c131                	beqz	a0,800059b4 <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80005972:	ffffe097          	auipc	ra,0xffffe
    80005976:	dd0080e7          	jalr	-560(ra) # 80003742 <ilock>
  if(ip->type != T_DIR){
    8000597a:	04449703          	lh	a4,68(s1)
    8000597e:	4785                	li	a5,1
    80005980:	04f71063          	bne	a4,a5,800059c0 <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005984:	8526                	mv	a0,s1
    80005986:	ffffe097          	auipc	ra,0xffffe
    8000598a:	e7e080e7          	jalr	-386(ra) # 80003804 <iunlock>
  iput(p->cwd);
    8000598e:	15093503          	ld	a0,336(s2)
    80005992:	ffffe097          	auipc	ra,0xffffe
    80005996:	f6a080e7          	jalr	-150(ra) # 800038fc <iput>
  end_op();
    8000599a:	ffffe097          	auipc	ra,0xffffe
    8000599e:	7fa080e7          	jalr	2042(ra) # 80004194 <end_op>
  p->cwd = ip;
    800059a2:	14993823          	sd	s1,336(s2)
  return 0;
    800059a6:	4501                	li	a0,0
}
    800059a8:	60ea                	ld	ra,152(sp)
    800059aa:	644a                	ld	s0,144(sp)
    800059ac:	64aa                	ld	s1,136(sp)
    800059ae:	690a                	ld	s2,128(sp)
    800059b0:	610d                	addi	sp,sp,160
    800059b2:	8082                	ret
    end_op();
    800059b4:	ffffe097          	auipc	ra,0xffffe
    800059b8:	7e0080e7          	jalr	2016(ra) # 80004194 <end_op>
    return -1;
    800059bc:	557d                	li	a0,-1
    800059be:	b7ed                	j	800059a8 <sys_chdir+0x7a>
    iunlockput(ip);
    800059c0:	8526                	mv	a0,s1
    800059c2:	ffffe097          	auipc	ra,0xffffe
    800059c6:	fe2080e7          	jalr	-30(ra) # 800039a4 <iunlockput>
    end_op();
    800059ca:	ffffe097          	auipc	ra,0xffffe
    800059ce:	7ca080e7          	jalr	1994(ra) # 80004194 <end_op>
    return -1;
    800059d2:	557d                	li	a0,-1
    800059d4:	bfd1                	j	800059a8 <sys_chdir+0x7a>

00000000800059d6 <sys_exec>:

uint64
sys_exec(void)
{
    800059d6:	7145                	addi	sp,sp,-464
    800059d8:	e786                	sd	ra,456(sp)
    800059da:	e3a2                	sd	s0,448(sp)
    800059dc:	ff26                	sd	s1,440(sp)
    800059de:	fb4a                	sd	s2,432(sp)
    800059e0:	f74e                	sd	s3,424(sp)
    800059e2:	f352                	sd	s4,416(sp)
    800059e4:	ef56                	sd	s5,408(sp)
    800059e6:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    800059e8:	08000613          	li	a2,128
    800059ec:	f4040593          	addi	a1,s0,-192
    800059f0:	4501                	li	a0,0
    800059f2:	ffffd097          	auipc	ra,0xffffd
    800059f6:	1c8080e7          	jalr	456(ra) # 80002bba <argstr>
    return -1;
    800059fa:	597d                	li	s2,-1
  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    800059fc:	0c054a63          	bltz	a0,80005ad0 <sys_exec+0xfa>
    80005a00:	e3840593          	addi	a1,s0,-456
    80005a04:	4505                	li	a0,1
    80005a06:	ffffd097          	auipc	ra,0xffffd
    80005a0a:	192080e7          	jalr	402(ra) # 80002b98 <argaddr>
    80005a0e:	0c054163          	bltz	a0,80005ad0 <sys_exec+0xfa>
  }
  memset(argv, 0, sizeof(argv));
    80005a12:	10000613          	li	a2,256
    80005a16:	4581                	li	a1,0
    80005a18:	e4040513          	addi	a0,s0,-448
    80005a1c:	ffffb097          	auipc	ra,0xffffb
    80005a20:	2b6080e7          	jalr	694(ra) # 80000cd2 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005a24:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    80005a28:	89a6                	mv	s3,s1
    80005a2a:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80005a2c:	02000a13          	li	s4,32
    80005a30:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005a34:	00391513          	slli	a0,s2,0x3
    80005a38:	e3040593          	addi	a1,s0,-464
    80005a3c:	e3843783          	ld	a5,-456(s0)
    80005a40:	953e                	add	a0,a0,a5
    80005a42:	ffffd097          	auipc	ra,0xffffd
    80005a46:	09a080e7          	jalr	154(ra) # 80002adc <fetchaddr>
    80005a4a:	02054a63          	bltz	a0,80005a7e <sys_exec+0xa8>
      goto bad;
    }
    if(uarg == 0){
    80005a4e:	e3043783          	ld	a5,-464(s0)
    80005a52:	c3b9                	beqz	a5,80005a98 <sys_exec+0xc2>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005a54:	ffffb097          	auipc	ra,0xffffb
    80005a58:	092080e7          	jalr	146(ra) # 80000ae6 <kalloc>
    80005a5c:	85aa                	mv	a1,a0
    80005a5e:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005a62:	cd11                	beqz	a0,80005a7e <sys_exec+0xa8>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005a64:	6605                	lui	a2,0x1
    80005a66:	e3043503          	ld	a0,-464(s0)
    80005a6a:	ffffd097          	auipc	ra,0xffffd
    80005a6e:	0c4080e7          	jalr	196(ra) # 80002b2e <fetchstr>
    80005a72:	00054663          	bltz	a0,80005a7e <sys_exec+0xa8>
    if(i >= NELEM(argv)){
    80005a76:	0905                	addi	s2,s2,1
    80005a78:	09a1                	addi	s3,s3,8
    80005a7a:	fb491be3          	bne	s2,s4,80005a30 <sys_exec+0x5a>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005a7e:	10048913          	addi	s2,s1,256
    80005a82:	6088                	ld	a0,0(s1)
    80005a84:	c529                	beqz	a0,80005ace <sys_exec+0xf8>
    kfree(argv[i]);
    80005a86:	ffffb097          	auipc	ra,0xffffb
    80005a8a:	f64080e7          	jalr	-156(ra) # 800009ea <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005a8e:	04a1                	addi	s1,s1,8
    80005a90:	ff2499e3          	bne	s1,s2,80005a82 <sys_exec+0xac>
  return -1;
    80005a94:	597d                	li	s2,-1
    80005a96:	a82d                	j	80005ad0 <sys_exec+0xfa>
      argv[i] = 0;
    80005a98:	0a8e                	slli	s5,s5,0x3
    80005a9a:	fc040793          	addi	a5,s0,-64
    80005a9e:	9abe                	add	s5,s5,a5
    80005aa0:	e80ab023          	sd	zero,-384(s5)
  int ret = exec(path, argv);
    80005aa4:	e4040593          	addi	a1,s0,-448
    80005aa8:	f4040513          	addi	a0,s0,-192
    80005aac:	fffff097          	auipc	ra,0xfffff
    80005ab0:	194080e7          	jalr	404(ra) # 80004c40 <exec>
    80005ab4:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005ab6:	10048993          	addi	s3,s1,256
    80005aba:	6088                	ld	a0,0(s1)
    80005abc:	c911                	beqz	a0,80005ad0 <sys_exec+0xfa>
    kfree(argv[i]);
    80005abe:	ffffb097          	auipc	ra,0xffffb
    80005ac2:	f2c080e7          	jalr	-212(ra) # 800009ea <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005ac6:	04a1                	addi	s1,s1,8
    80005ac8:	ff3499e3          	bne	s1,s3,80005aba <sys_exec+0xe4>
    80005acc:	a011                	j	80005ad0 <sys_exec+0xfa>
  return -1;
    80005ace:	597d                	li	s2,-1
}
    80005ad0:	854a                	mv	a0,s2
    80005ad2:	60be                	ld	ra,456(sp)
    80005ad4:	641e                	ld	s0,448(sp)
    80005ad6:	74fa                	ld	s1,440(sp)
    80005ad8:	795a                	ld	s2,432(sp)
    80005ada:	79ba                	ld	s3,424(sp)
    80005adc:	7a1a                	ld	s4,416(sp)
    80005ade:	6afa                	ld	s5,408(sp)
    80005ae0:	6179                	addi	sp,sp,464
    80005ae2:	8082                	ret

0000000080005ae4 <sys_pipe>:

uint64
sys_pipe(void)
{
    80005ae4:	7139                	addi	sp,sp,-64
    80005ae6:	fc06                	sd	ra,56(sp)
    80005ae8:	f822                	sd	s0,48(sp)
    80005aea:	f426                	sd	s1,40(sp)
    80005aec:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005aee:	ffffc097          	auipc	ra,0xffffc
    80005af2:	ea6080e7          	jalr	-346(ra) # 80001994 <myproc>
    80005af6:	84aa                	mv	s1,a0

  if(argaddr(0, &fdarray) < 0)
    80005af8:	fd840593          	addi	a1,s0,-40
    80005afc:	4501                	li	a0,0
    80005afe:	ffffd097          	auipc	ra,0xffffd
    80005b02:	09a080e7          	jalr	154(ra) # 80002b98 <argaddr>
    return -1;
    80005b06:	57fd                	li	a5,-1
  if(argaddr(0, &fdarray) < 0)
    80005b08:	0e054063          	bltz	a0,80005be8 <sys_pipe+0x104>
  if(pipealloc(&rf, &wf) < 0)
    80005b0c:	fc840593          	addi	a1,s0,-56
    80005b10:	fd040513          	addi	a0,s0,-48
    80005b14:	fffff097          	auipc	ra,0xfffff
    80005b18:	dfc080e7          	jalr	-516(ra) # 80004910 <pipealloc>
    return -1;
    80005b1c:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005b1e:	0c054563          	bltz	a0,80005be8 <sys_pipe+0x104>
  fd0 = -1;
    80005b22:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005b26:	fd043503          	ld	a0,-48(s0)
    80005b2a:	fffff097          	auipc	ra,0xfffff
    80005b2e:	508080e7          	jalr	1288(ra) # 80005032 <fdalloc>
    80005b32:	fca42223          	sw	a0,-60(s0)
    80005b36:	08054c63          	bltz	a0,80005bce <sys_pipe+0xea>
    80005b3a:	fc843503          	ld	a0,-56(s0)
    80005b3e:	fffff097          	auipc	ra,0xfffff
    80005b42:	4f4080e7          	jalr	1268(ra) # 80005032 <fdalloc>
    80005b46:	fca42023          	sw	a0,-64(s0)
    80005b4a:	06054863          	bltz	a0,80005bba <sys_pipe+0xd6>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005b4e:	4691                	li	a3,4
    80005b50:	fc440613          	addi	a2,s0,-60
    80005b54:	fd843583          	ld	a1,-40(s0)
    80005b58:	68a8                	ld	a0,80(s1)
    80005b5a:	ffffc097          	auipc	ra,0xffffc
    80005b5e:	afc080e7          	jalr	-1284(ra) # 80001656 <copyout>
    80005b62:	02054063          	bltz	a0,80005b82 <sys_pipe+0x9e>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005b66:	4691                	li	a3,4
    80005b68:	fc040613          	addi	a2,s0,-64
    80005b6c:	fd843583          	ld	a1,-40(s0)
    80005b70:	0591                	addi	a1,a1,4
    80005b72:	68a8                	ld	a0,80(s1)
    80005b74:	ffffc097          	auipc	ra,0xffffc
    80005b78:	ae2080e7          	jalr	-1310(ra) # 80001656 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005b7c:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005b7e:	06055563          	bgez	a0,80005be8 <sys_pipe+0x104>
    p->ofile[fd0] = 0;
    80005b82:	fc442783          	lw	a5,-60(s0)
    80005b86:	07e9                	addi	a5,a5,26
    80005b88:	078e                	slli	a5,a5,0x3
    80005b8a:	97a6                	add	a5,a5,s1
    80005b8c:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80005b90:	fc042503          	lw	a0,-64(s0)
    80005b94:	0569                	addi	a0,a0,26
    80005b96:	050e                	slli	a0,a0,0x3
    80005b98:	9526                	add	a0,a0,s1
    80005b9a:	00053023          	sd	zero,0(a0)
    fileclose(rf);
    80005b9e:	fd043503          	ld	a0,-48(s0)
    80005ba2:	fffff097          	auipc	ra,0xfffff
    80005ba6:	a3e080e7          	jalr	-1474(ra) # 800045e0 <fileclose>
    fileclose(wf);
    80005baa:	fc843503          	ld	a0,-56(s0)
    80005bae:	fffff097          	auipc	ra,0xfffff
    80005bb2:	a32080e7          	jalr	-1486(ra) # 800045e0 <fileclose>
    return -1;
    80005bb6:	57fd                	li	a5,-1
    80005bb8:	a805                	j	80005be8 <sys_pipe+0x104>
    if(fd0 >= 0)
    80005bba:	fc442783          	lw	a5,-60(s0)
    80005bbe:	0007c863          	bltz	a5,80005bce <sys_pipe+0xea>
      p->ofile[fd0] = 0;
    80005bc2:	01a78513          	addi	a0,a5,26
    80005bc6:	050e                	slli	a0,a0,0x3
    80005bc8:	9526                	add	a0,a0,s1
    80005bca:	00053023          	sd	zero,0(a0)
    fileclose(rf);
    80005bce:	fd043503          	ld	a0,-48(s0)
    80005bd2:	fffff097          	auipc	ra,0xfffff
    80005bd6:	a0e080e7          	jalr	-1522(ra) # 800045e0 <fileclose>
    fileclose(wf);
    80005bda:	fc843503          	ld	a0,-56(s0)
    80005bde:	fffff097          	auipc	ra,0xfffff
    80005be2:	a02080e7          	jalr	-1534(ra) # 800045e0 <fileclose>
    return -1;
    80005be6:	57fd                	li	a5,-1
}
    80005be8:	853e                	mv	a0,a5
    80005bea:	70e2                	ld	ra,56(sp)
    80005bec:	7442                	ld	s0,48(sp)
    80005bee:	74a2                	ld	s1,40(sp)
    80005bf0:	6121                	addi	sp,sp,64
    80005bf2:	8082                	ret
	...

0000000080005c00 <kernelvec>:
    80005c00:	7111                	addi	sp,sp,-256
    80005c02:	e006                	sd	ra,0(sp)
    80005c04:	e40a                	sd	sp,8(sp)
    80005c06:	e80e                	sd	gp,16(sp)
    80005c08:	ec12                	sd	tp,24(sp)
    80005c0a:	f016                	sd	t0,32(sp)
    80005c0c:	f41a                	sd	t1,40(sp)
    80005c0e:	f81e                	sd	t2,48(sp)
    80005c10:	fc22                	sd	s0,56(sp)
    80005c12:	e0a6                	sd	s1,64(sp)
    80005c14:	e4aa                	sd	a0,72(sp)
    80005c16:	e8ae                	sd	a1,80(sp)
    80005c18:	ecb2                	sd	a2,88(sp)
    80005c1a:	f0b6                	sd	a3,96(sp)
    80005c1c:	f4ba                	sd	a4,104(sp)
    80005c1e:	f8be                	sd	a5,112(sp)
    80005c20:	fcc2                	sd	a6,120(sp)
    80005c22:	e146                	sd	a7,128(sp)
    80005c24:	e54a                	sd	s2,136(sp)
    80005c26:	e94e                	sd	s3,144(sp)
    80005c28:	ed52                	sd	s4,152(sp)
    80005c2a:	f156                	sd	s5,160(sp)
    80005c2c:	f55a                	sd	s6,168(sp)
    80005c2e:	f95e                	sd	s7,176(sp)
    80005c30:	fd62                	sd	s8,184(sp)
    80005c32:	e1e6                	sd	s9,192(sp)
    80005c34:	e5ea                	sd	s10,200(sp)
    80005c36:	e9ee                	sd	s11,208(sp)
    80005c38:	edf2                	sd	t3,216(sp)
    80005c3a:	f1f6                	sd	t4,224(sp)
    80005c3c:	f5fa                	sd	t5,232(sp)
    80005c3e:	f9fe                	sd	t6,240(sp)
    80005c40:	d69fc0ef          	jal	ra,800029a8 <kerneltrap>
    80005c44:	6082                	ld	ra,0(sp)
    80005c46:	6122                	ld	sp,8(sp)
    80005c48:	61c2                	ld	gp,16(sp)
    80005c4a:	7282                	ld	t0,32(sp)
    80005c4c:	7322                	ld	t1,40(sp)
    80005c4e:	73c2                	ld	t2,48(sp)
    80005c50:	7462                	ld	s0,56(sp)
    80005c52:	6486                	ld	s1,64(sp)
    80005c54:	6526                	ld	a0,72(sp)
    80005c56:	65c6                	ld	a1,80(sp)
    80005c58:	6666                	ld	a2,88(sp)
    80005c5a:	7686                	ld	a3,96(sp)
    80005c5c:	7726                	ld	a4,104(sp)
    80005c5e:	77c6                	ld	a5,112(sp)
    80005c60:	7866                	ld	a6,120(sp)
    80005c62:	688a                	ld	a7,128(sp)
    80005c64:	692a                	ld	s2,136(sp)
    80005c66:	69ca                	ld	s3,144(sp)
    80005c68:	6a6a                	ld	s4,152(sp)
    80005c6a:	7a8a                	ld	s5,160(sp)
    80005c6c:	7b2a                	ld	s6,168(sp)
    80005c6e:	7bca                	ld	s7,176(sp)
    80005c70:	7c6a                	ld	s8,184(sp)
    80005c72:	6c8e                	ld	s9,192(sp)
    80005c74:	6d2e                	ld	s10,200(sp)
    80005c76:	6dce                	ld	s11,208(sp)
    80005c78:	6e6e                	ld	t3,216(sp)
    80005c7a:	7e8e                	ld	t4,224(sp)
    80005c7c:	7f2e                	ld	t5,232(sp)
    80005c7e:	7fce                	ld	t6,240(sp)
    80005c80:	6111                	addi	sp,sp,256
    80005c82:	10200073          	sret
    80005c86:	00000013          	nop
    80005c8a:	00000013          	nop
    80005c8e:	0001                	nop

0000000080005c90 <timervec>:
    80005c90:	34051573          	csrrw	a0,mscratch,a0
    80005c94:	e10c                	sd	a1,0(a0)
    80005c96:	e510                	sd	a2,8(a0)
    80005c98:	e914                	sd	a3,16(a0)
    80005c9a:	6d0c                	ld	a1,24(a0)
    80005c9c:	7110                	ld	a2,32(a0)
    80005c9e:	6194                	ld	a3,0(a1)
    80005ca0:	96b2                	add	a3,a3,a2
    80005ca2:	e194                	sd	a3,0(a1)
    80005ca4:	4589                	li	a1,2
    80005ca6:	14459073          	csrw	sip,a1
    80005caa:	6914                	ld	a3,16(a0)
    80005cac:	6510                	ld	a2,8(a0)
    80005cae:	610c                	ld	a1,0(a0)
    80005cb0:	34051573          	csrrw	a0,mscratch,a0
    80005cb4:	30200073          	mret
	...

0000000080005cba <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    80005cba:	1141                	addi	sp,sp,-16
    80005cbc:	e422                	sd	s0,8(sp)
    80005cbe:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80005cc0:	0c0007b7          	lui	a5,0xc000
    80005cc4:	4705                	li	a4,1
    80005cc6:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80005cc8:	c3d8                	sw	a4,4(a5)
}
    80005cca:	6422                	ld	s0,8(sp)
    80005ccc:	0141                	addi	sp,sp,16
    80005cce:	8082                	ret

0000000080005cd0 <plicinithart>:

void
plicinithart(void)
{
    80005cd0:	1141                	addi	sp,sp,-16
    80005cd2:	e406                	sd	ra,8(sp)
    80005cd4:	e022                	sd	s0,0(sp)
    80005cd6:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005cd8:	ffffc097          	auipc	ra,0xffffc
    80005cdc:	c90080e7          	jalr	-880(ra) # 80001968 <cpuid>
  
  // set uart's enable bit for this hart's S-mode. 
  *(uint32*)PLIC_SENABLE(hart)= (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005ce0:	0085171b          	slliw	a4,a0,0x8
    80005ce4:	0c0027b7          	lui	a5,0xc002
    80005ce8:	97ba                	add	a5,a5,a4
    80005cea:	40200713          	li	a4,1026
    80005cee:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005cf2:	00d5151b          	slliw	a0,a0,0xd
    80005cf6:	0c2017b7          	lui	a5,0xc201
    80005cfa:	953e                	add	a0,a0,a5
    80005cfc:	00052023          	sw	zero,0(a0)
}
    80005d00:	60a2                	ld	ra,8(sp)
    80005d02:	6402                	ld	s0,0(sp)
    80005d04:	0141                	addi	sp,sp,16
    80005d06:	8082                	ret

0000000080005d08 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80005d08:	1141                	addi	sp,sp,-16
    80005d0a:	e406                	sd	ra,8(sp)
    80005d0c:	e022                	sd	s0,0(sp)
    80005d0e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005d10:	ffffc097          	auipc	ra,0xffffc
    80005d14:	c58080e7          	jalr	-936(ra) # 80001968 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80005d18:	00d5179b          	slliw	a5,a0,0xd
    80005d1c:	0c201537          	lui	a0,0xc201
    80005d20:	953e                	add	a0,a0,a5
  return irq;
}
    80005d22:	4148                	lw	a0,4(a0)
    80005d24:	60a2                	ld	ra,8(sp)
    80005d26:	6402                	ld	s0,0(sp)
    80005d28:	0141                	addi	sp,sp,16
    80005d2a:	8082                	ret

0000000080005d2c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80005d2c:	1101                	addi	sp,sp,-32
    80005d2e:	ec06                	sd	ra,24(sp)
    80005d30:	e822                	sd	s0,16(sp)
    80005d32:	e426                	sd	s1,8(sp)
    80005d34:	1000                	addi	s0,sp,32
    80005d36:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005d38:	ffffc097          	auipc	ra,0xffffc
    80005d3c:	c30080e7          	jalr	-976(ra) # 80001968 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80005d40:	00d5151b          	slliw	a0,a0,0xd
    80005d44:	0c2017b7          	lui	a5,0xc201
    80005d48:	97aa                	add	a5,a5,a0
    80005d4a:	c3c4                	sw	s1,4(a5)
}
    80005d4c:	60e2                	ld	ra,24(sp)
    80005d4e:	6442                	ld	s0,16(sp)
    80005d50:	64a2                	ld	s1,8(sp)
    80005d52:	6105                	addi	sp,sp,32
    80005d54:	8082                	ret

0000000080005d56 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80005d56:	1141                	addi	sp,sp,-16
    80005d58:	e406                	sd	ra,8(sp)
    80005d5a:	e022                	sd	s0,0(sp)
    80005d5c:	0800                	addi	s0,sp,16
  if(i >= NUM)
    80005d5e:	479d                	li	a5,7
    80005d60:	06a7c963          	blt	a5,a0,80005dd2 <free_desc+0x7c>
    panic("free_desc 1");
  if(disk.free[i])
    80005d64:	0001d797          	auipc	a5,0x1d
    80005d68:	29c78793          	addi	a5,a5,668 # 80023000 <disk>
    80005d6c:	00a78733          	add	a4,a5,a0
    80005d70:	6789                	lui	a5,0x2
    80005d72:	97ba                	add	a5,a5,a4
    80005d74:	0187c783          	lbu	a5,24(a5) # 2018 <_entry-0x7fffdfe8>
    80005d78:	e7ad                	bnez	a5,80005de2 <free_desc+0x8c>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80005d7a:	00451793          	slli	a5,a0,0x4
    80005d7e:	0001f717          	auipc	a4,0x1f
    80005d82:	28270713          	addi	a4,a4,642 # 80025000 <disk+0x2000>
    80005d86:	6314                	ld	a3,0(a4)
    80005d88:	96be                	add	a3,a3,a5
    80005d8a:	0006b023          	sd	zero,0(a3)
  disk.desc[i].len = 0;
    80005d8e:	6314                	ld	a3,0(a4)
    80005d90:	96be                	add	a3,a3,a5
    80005d92:	0006a423          	sw	zero,8(a3)
  disk.desc[i].flags = 0;
    80005d96:	6314                	ld	a3,0(a4)
    80005d98:	96be                	add	a3,a3,a5
    80005d9a:	00069623          	sh	zero,12(a3)
  disk.desc[i].next = 0;
    80005d9e:	6318                	ld	a4,0(a4)
    80005da0:	97ba                	add	a5,a5,a4
    80005da2:	00079723          	sh	zero,14(a5)
  disk.free[i] = 1;
    80005da6:	0001d797          	auipc	a5,0x1d
    80005daa:	25a78793          	addi	a5,a5,602 # 80023000 <disk>
    80005dae:	97aa                	add	a5,a5,a0
    80005db0:	6509                	lui	a0,0x2
    80005db2:	953e                	add	a0,a0,a5
    80005db4:	4785                	li	a5,1
    80005db6:	00f50c23          	sb	a5,24(a0) # 2018 <_entry-0x7fffdfe8>
  wakeup(&disk.free[0]);
    80005dba:	0001f517          	auipc	a0,0x1f
    80005dbe:	25e50513          	addi	a0,a0,606 # 80025018 <disk+0x2018>
    80005dc2:	ffffc097          	auipc	ra,0xffffc
    80005dc6:	476080e7          	jalr	1142(ra) # 80002238 <wakeup>
}
    80005dca:	60a2                	ld	ra,8(sp)
    80005dcc:	6402                	ld	s0,0(sp)
    80005dce:	0141                	addi	sp,sp,16
    80005dd0:	8082                	ret
    panic("free_desc 1");
    80005dd2:	00003517          	auipc	a0,0x3
    80005dd6:	98e50513          	addi	a0,a0,-1650 # 80008760 <syscalls+0x330>
    80005dda:	ffffa097          	auipc	ra,0xffffa
    80005dde:	756080e7          	jalr	1878(ra) # 80000530 <panic>
    panic("free_desc 2");
    80005de2:	00003517          	auipc	a0,0x3
    80005de6:	98e50513          	addi	a0,a0,-1650 # 80008770 <syscalls+0x340>
    80005dea:	ffffa097          	auipc	ra,0xffffa
    80005dee:	746080e7          	jalr	1862(ra) # 80000530 <panic>

0000000080005df2 <virtio_disk_init>:
{
    80005df2:	1101                	addi	sp,sp,-32
    80005df4:	ec06                	sd	ra,24(sp)
    80005df6:	e822                	sd	s0,16(sp)
    80005df8:	e426                	sd	s1,8(sp)
    80005dfa:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80005dfc:	00003597          	auipc	a1,0x3
    80005e00:	98458593          	addi	a1,a1,-1660 # 80008780 <syscalls+0x350>
    80005e04:	0001f517          	auipc	a0,0x1f
    80005e08:	32450513          	addi	a0,a0,804 # 80025128 <disk+0x2128>
    80005e0c:	ffffb097          	auipc	ra,0xffffb
    80005e10:	d3a080e7          	jalr	-710(ra) # 80000b46 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005e14:	100017b7          	lui	a5,0x10001
    80005e18:	4398                	lw	a4,0(a5)
    80005e1a:	2701                	sext.w	a4,a4
    80005e1c:	747277b7          	lui	a5,0x74727
    80005e20:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80005e24:	0ef71163          	bne	a4,a5,80005f06 <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    80005e28:	100017b7          	lui	a5,0x10001
    80005e2c:	43dc                	lw	a5,4(a5)
    80005e2e:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005e30:	4705                	li	a4,1
    80005e32:	0ce79a63          	bne	a5,a4,80005f06 <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005e36:	100017b7          	lui	a5,0x10001
    80005e3a:	479c                	lw	a5,8(a5)
    80005e3c:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    80005e3e:	4709                	li	a4,2
    80005e40:	0ce79363          	bne	a5,a4,80005f06 <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80005e44:	100017b7          	lui	a5,0x10001
    80005e48:	47d8                	lw	a4,12(a5)
    80005e4a:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005e4c:	554d47b7          	lui	a5,0x554d4
    80005e50:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80005e54:	0af71963          	bne	a4,a5,80005f06 <virtio_disk_init+0x114>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005e58:	100017b7          	lui	a5,0x10001
    80005e5c:	4705                	li	a4,1
    80005e5e:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005e60:	470d                	li	a4,3
    80005e62:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    80005e64:	4b94                	lw	a3,16(a5)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80005e66:	c7ffe737          	lui	a4,0xc7ffe
    80005e6a:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fd875f>
    80005e6e:	8f75                	and	a4,a4,a3
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80005e70:	2701                	sext.w	a4,a4
    80005e72:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005e74:	472d                	li	a4,11
    80005e76:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005e78:	473d                	li	a4,15
    80005e7a:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_GUEST_PAGE_SIZE) = PGSIZE;
    80005e7c:	6705                	lui	a4,0x1
    80005e7e:	d798                	sw	a4,40(a5)
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80005e80:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80005e84:	5bdc                	lw	a5,52(a5)
    80005e86:	2781                	sext.w	a5,a5
  if(max == 0)
    80005e88:	c7d9                	beqz	a5,80005f16 <virtio_disk_init+0x124>
  if(max < NUM)
    80005e8a:	471d                	li	a4,7
    80005e8c:	08f77d63          	bgeu	a4,a5,80005f26 <virtio_disk_init+0x134>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80005e90:	100014b7          	lui	s1,0x10001
    80005e94:	47a1                	li	a5,8
    80005e96:	dc9c                	sw	a5,56(s1)
  memset(disk.pages, 0, sizeof(disk.pages));
    80005e98:	6609                	lui	a2,0x2
    80005e9a:	4581                	li	a1,0
    80005e9c:	0001d517          	auipc	a0,0x1d
    80005ea0:	16450513          	addi	a0,a0,356 # 80023000 <disk>
    80005ea4:	ffffb097          	auipc	ra,0xffffb
    80005ea8:	e2e080e7          	jalr	-466(ra) # 80000cd2 <memset>
  *R(VIRTIO_MMIO_QUEUE_PFN) = ((uint64)disk.pages) >> PGSHIFT;
    80005eac:	0001d717          	auipc	a4,0x1d
    80005eb0:	15470713          	addi	a4,a4,340 # 80023000 <disk>
    80005eb4:	00c75793          	srli	a5,a4,0xc
    80005eb8:	2781                	sext.w	a5,a5
    80005eba:	c0bc                	sw	a5,64(s1)
  disk.desc = (struct virtq_desc *) disk.pages;
    80005ebc:	0001f797          	auipc	a5,0x1f
    80005ec0:	14478793          	addi	a5,a5,324 # 80025000 <disk+0x2000>
    80005ec4:	e398                	sd	a4,0(a5)
  disk.avail = (struct virtq_avail *)(disk.pages + NUM*sizeof(struct virtq_desc));
    80005ec6:	0001d717          	auipc	a4,0x1d
    80005eca:	1ba70713          	addi	a4,a4,442 # 80023080 <disk+0x80>
    80005ece:	e798                	sd	a4,8(a5)
  disk.used = (struct virtq_used *) (disk.pages + PGSIZE);
    80005ed0:	0001e717          	auipc	a4,0x1e
    80005ed4:	13070713          	addi	a4,a4,304 # 80024000 <disk+0x1000>
    80005ed8:	eb98                	sd	a4,16(a5)
    disk.free[i] = 1;
    80005eda:	4705                	li	a4,1
    80005edc:	00e78c23          	sb	a4,24(a5)
    80005ee0:	00e78ca3          	sb	a4,25(a5)
    80005ee4:	00e78d23          	sb	a4,26(a5)
    80005ee8:	00e78da3          	sb	a4,27(a5)
    80005eec:	00e78e23          	sb	a4,28(a5)
    80005ef0:	00e78ea3          	sb	a4,29(a5)
    80005ef4:	00e78f23          	sb	a4,30(a5)
    80005ef8:	00e78fa3          	sb	a4,31(a5)
}
    80005efc:	60e2                	ld	ra,24(sp)
    80005efe:	6442                	ld	s0,16(sp)
    80005f00:	64a2                	ld	s1,8(sp)
    80005f02:	6105                	addi	sp,sp,32
    80005f04:	8082                	ret
    panic("could not find virtio disk");
    80005f06:	00003517          	auipc	a0,0x3
    80005f0a:	88a50513          	addi	a0,a0,-1910 # 80008790 <syscalls+0x360>
    80005f0e:	ffffa097          	auipc	ra,0xffffa
    80005f12:	622080e7          	jalr	1570(ra) # 80000530 <panic>
    panic("virtio disk has no queue 0");
    80005f16:	00003517          	auipc	a0,0x3
    80005f1a:	89a50513          	addi	a0,a0,-1894 # 800087b0 <syscalls+0x380>
    80005f1e:	ffffa097          	auipc	ra,0xffffa
    80005f22:	612080e7          	jalr	1554(ra) # 80000530 <panic>
    panic("virtio disk max queue too short");
    80005f26:	00003517          	auipc	a0,0x3
    80005f2a:	8aa50513          	addi	a0,a0,-1878 # 800087d0 <syscalls+0x3a0>
    80005f2e:	ffffa097          	auipc	ra,0xffffa
    80005f32:	602080e7          	jalr	1538(ra) # 80000530 <panic>

0000000080005f36 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80005f36:	7159                	addi	sp,sp,-112
    80005f38:	f486                	sd	ra,104(sp)
    80005f3a:	f0a2                	sd	s0,96(sp)
    80005f3c:	eca6                	sd	s1,88(sp)
    80005f3e:	e8ca                	sd	s2,80(sp)
    80005f40:	e4ce                	sd	s3,72(sp)
    80005f42:	e0d2                	sd	s4,64(sp)
    80005f44:	fc56                	sd	s5,56(sp)
    80005f46:	f85a                	sd	s6,48(sp)
    80005f48:	f45e                	sd	s7,40(sp)
    80005f4a:	f062                	sd	s8,32(sp)
    80005f4c:	ec66                	sd	s9,24(sp)
    80005f4e:	e86a                	sd	s10,16(sp)
    80005f50:	1880                	addi	s0,sp,112
    80005f52:	892a                	mv	s2,a0
    80005f54:	8d2e                	mv	s10,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80005f56:	00c52c83          	lw	s9,12(a0)
    80005f5a:	001c9c9b          	slliw	s9,s9,0x1
    80005f5e:	1c82                	slli	s9,s9,0x20
    80005f60:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    80005f64:	0001f517          	auipc	a0,0x1f
    80005f68:	1c450513          	addi	a0,a0,452 # 80025128 <disk+0x2128>
    80005f6c:	ffffb097          	auipc	ra,0xffffb
    80005f70:	c6a080e7          	jalr	-918(ra) # 80000bd6 <acquire>
  for(int i = 0; i < 3; i++){
    80005f74:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    80005f76:	4c21                	li	s8,8
      disk.free[i] = 0;
    80005f78:	0001db97          	auipc	s7,0x1d
    80005f7c:	088b8b93          	addi	s7,s7,136 # 80023000 <disk>
    80005f80:	6b09                	lui	s6,0x2
  for(int i = 0; i < 3; i++){
    80005f82:	4a8d                	li	s5,3
  for(int i = 0; i < NUM; i++){
    80005f84:	8a4e                	mv	s4,s3
    80005f86:	a051                	j	8000600a <virtio_disk_rw+0xd4>
      disk.free[i] = 0;
    80005f88:	00fb86b3          	add	a3,s7,a5
    80005f8c:	96da                	add	a3,a3,s6
    80005f8e:	00068c23          	sb	zero,24(a3)
    idx[i] = alloc_desc();
    80005f92:	c21c                	sw	a5,0(a2)
    if(idx[i] < 0){
    80005f94:	0207c563          	bltz	a5,80005fbe <virtio_disk_rw+0x88>
  for(int i = 0; i < 3; i++){
    80005f98:	2485                	addiw	s1,s1,1
    80005f9a:	0711                	addi	a4,a4,4
    80005f9c:	25548063          	beq	s1,s5,800061dc <virtio_disk_rw+0x2a6>
    idx[i] = alloc_desc();
    80005fa0:	863a                	mv	a2,a4
  for(int i = 0; i < NUM; i++){
    80005fa2:	0001f697          	auipc	a3,0x1f
    80005fa6:	07668693          	addi	a3,a3,118 # 80025018 <disk+0x2018>
    80005faa:	87d2                	mv	a5,s4
    if(disk.free[i]){
    80005fac:	0006c583          	lbu	a1,0(a3)
    80005fb0:	fde1                	bnez	a1,80005f88 <virtio_disk_rw+0x52>
  for(int i = 0; i < NUM; i++){
    80005fb2:	2785                	addiw	a5,a5,1
    80005fb4:	0685                	addi	a3,a3,1
    80005fb6:	ff879be3          	bne	a5,s8,80005fac <virtio_disk_rw+0x76>
    idx[i] = alloc_desc();
    80005fba:	57fd                	li	a5,-1
    80005fbc:	c21c                	sw	a5,0(a2)
      for(int j = 0; j < i; j++)
    80005fbe:	02905a63          	blez	s1,80005ff2 <virtio_disk_rw+0xbc>
        free_desc(idx[j]);
    80005fc2:	f9042503          	lw	a0,-112(s0)
    80005fc6:	00000097          	auipc	ra,0x0
    80005fca:	d90080e7          	jalr	-624(ra) # 80005d56 <free_desc>
      for(int j = 0; j < i; j++)
    80005fce:	4785                	li	a5,1
    80005fd0:	0297d163          	bge	a5,s1,80005ff2 <virtio_disk_rw+0xbc>
        free_desc(idx[j]);
    80005fd4:	f9442503          	lw	a0,-108(s0)
    80005fd8:	00000097          	auipc	ra,0x0
    80005fdc:	d7e080e7          	jalr	-642(ra) # 80005d56 <free_desc>
      for(int j = 0; j < i; j++)
    80005fe0:	4789                	li	a5,2
    80005fe2:	0097d863          	bge	a5,s1,80005ff2 <virtio_disk_rw+0xbc>
        free_desc(idx[j]);
    80005fe6:	f9842503          	lw	a0,-104(s0)
    80005fea:	00000097          	auipc	ra,0x0
    80005fee:	d6c080e7          	jalr	-660(ra) # 80005d56 <free_desc>
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80005ff2:	0001f597          	auipc	a1,0x1f
    80005ff6:	13658593          	addi	a1,a1,310 # 80025128 <disk+0x2128>
    80005ffa:	0001f517          	auipc	a0,0x1f
    80005ffe:	01e50513          	addi	a0,a0,30 # 80025018 <disk+0x2018>
    80006002:	ffffc097          	auipc	ra,0xffffc
    80006006:	0aa080e7          	jalr	170(ra) # 800020ac <sleep>
  for(int i = 0; i < 3; i++){
    8000600a:	f9040713          	addi	a4,s0,-112
    8000600e:	84ce                	mv	s1,s3
    80006010:	bf41                	j	80005fa0 <virtio_disk_rw+0x6a>
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];

  if(write)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
    80006012:	20058713          	addi	a4,a1,512
    80006016:	00471693          	slli	a3,a4,0x4
    8000601a:	0001d717          	auipc	a4,0x1d
    8000601e:	fe670713          	addi	a4,a4,-26 # 80023000 <disk>
    80006022:	9736                	add	a4,a4,a3
    80006024:	4685                	li	a3,1
    80006026:	0ad72423          	sw	a3,168(a4)
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    8000602a:	20058713          	addi	a4,a1,512
    8000602e:	00471693          	slli	a3,a4,0x4
    80006032:	0001d717          	auipc	a4,0x1d
    80006036:	fce70713          	addi	a4,a4,-50 # 80023000 <disk>
    8000603a:	9736                	add	a4,a4,a3
    8000603c:	0a072623          	sw	zero,172(a4)
  buf0->sector = sector;
    80006040:	0b973823          	sd	s9,176(a4)

  disk.desc[idx[0]].addr = (uint64) buf0;
    80006044:	7679                	lui	a2,0xffffe
    80006046:	963e                	add	a2,a2,a5
    80006048:	0001f697          	auipc	a3,0x1f
    8000604c:	fb868693          	addi	a3,a3,-72 # 80025000 <disk+0x2000>
    80006050:	6298                	ld	a4,0(a3)
    80006052:	9732                	add	a4,a4,a2
    80006054:	e308                	sd	a0,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80006056:	6298                	ld	a4,0(a3)
    80006058:	9732                	add	a4,a4,a2
    8000605a:	4541                	li	a0,16
    8000605c:	c708                	sw	a0,8(a4)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    8000605e:	6298                	ld	a4,0(a3)
    80006060:	9732                	add	a4,a4,a2
    80006062:	4505                	li	a0,1
    80006064:	00a71623          	sh	a0,12(a4)
  disk.desc[idx[0]].next = idx[1];
    80006068:	f9442703          	lw	a4,-108(s0)
    8000606c:	6288                	ld	a0,0(a3)
    8000606e:	962a                	add	a2,a2,a0
    80006070:	00e61723          	sh	a4,14(a2) # ffffffffffffe00e <end+0xffffffff7ffd800e>

  disk.desc[idx[1]].addr = (uint64) b->data;
    80006074:	0712                	slli	a4,a4,0x4
    80006076:	6290                	ld	a2,0(a3)
    80006078:	963a                	add	a2,a2,a4
    8000607a:	05890513          	addi	a0,s2,88
    8000607e:	e208                	sd	a0,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    80006080:	6294                	ld	a3,0(a3)
    80006082:	96ba                	add	a3,a3,a4
    80006084:	40000613          	li	a2,1024
    80006088:	c690                	sw	a2,8(a3)
  if(write)
    8000608a:	140d0063          	beqz	s10,800061ca <virtio_disk_rw+0x294>
    disk.desc[idx[1]].flags = 0; // device reads b->data
    8000608e:	0001f697          	auipc	a3,0x1f
    80006092:	f726b683          	ld	a3,-142(a3) # 80025000 <disk+0x2000>
    80006096:	96ba                	add	a3,a3,a4
    80006098:	00069623          	sh	zero,12(a3)
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    8000609c:	0001d817          	auipc	a6,0x1d
    800060a0:	f6480813          	addi	a6,a6,-156 # 80023000 <disk>
    800060a4:	0001f517          	auipc	a0,0x1f
    800060a8:	f5c50513          	addi	a0,a0,-164 # 80025000 <disk+0x2000>
    800060ac:	6114                	ld	a3,0(a0)
    800060ae:	96ba                	add	a3,a3,a4
    800060b0:	00c6d603          	lhu	a2,12(a3)
    800060b4:	00166613          	ori	a2,a2,1
    800060b8:	00c69623          	sh	a2,12(a3)
  disk.desc[idx[1]].next = idx[2];
    800060bc:	f9842683          	lw	a3,-104(s0)
    800060c0:	6110                	ld	a2,0(a0)
    800060c2:	9732                	add	a4,a4,a2
    800060c4:	00d71723          	sh	a3,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    800060c8:	20058613          	addi	a2,a1,512
    800060cc:	0612                	slli	a2,a2,0x4
    800060ce:	9642                	add	a2,a2,a6
    800060d0:	577d                	li	a4,-1
    800060d2:	02e60823          	sb	a4,48(a2)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    800060d6:	00469713          	slli	a4,a3,0x4
    800060da:	6114                	ld	a3,0(a0)
    800060dc:	96ba                	add	a3,a3,a4
    800060de:	03078793          	addi	a5,a5,48
    800060e2:	97c2                	add	a5,a5,a6
    800060e4:	e29c                	sd	a5,0(a3)
  disk.desc[idx[2]].len = 1;
    800060e6:	611c                	ld	a5,0(a0)
    800060e8:	97ba                	add	a5,a5,a4
    800060ea:	4685                	li	a3,1
    800060ec:	c794                	sw	a3,8(a5)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    800060ee:	611c                	ld	a5,0(a0)
    800060f0:	97ba                	add	a5,a5,a4
    800060f2:	4809                	li	a6,2
    800060f4:	01079623          	sh	a6,12(a5)
  disk.desc[idx[2]].next = 0;
    800060f8:	611c                	ld	a5,0(a0)
    800060fa:	973e                	add	a4,a4,a5
    800060fc:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80006100:	00d92223          	sw	a3,4(s2)
  disk.info[idx[0]].b = b;
    80006104:	03263423          	sd	s2,40(a2)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80006108:	6518                	ld	a4,8(a0)
    8000610a:	00275783          	lhu	a5,2(a4)
    8000610e:	8b9d                	andi	a5,a5,7
    80006110:	0786                	slli	a5,a5,0x1
    80006112:	97ba                	add	a5,a5,a4
    80006114:	00b79223          	sh	a1,4(a5)

  __sync_synchronize();
    80006118:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    8000611c:	6518                	ld	a4,8(a0)
    8000611e:	00275783          	lhu	a5,2(a4)
    80006122:	2785                	addiw	a5,a5,1
    80006124:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80006128:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    8000612c:	100017b7          	lui	a5,0x10001
    80006130:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80006134:	00492703          	lw	a4,4(s2)
    80006138:	4785                	li	a5,1
    8000613a:	02f71163          	bne	a4,a5,8000615c <virtio_disk_rw+0x226>
    sleep(b, &disk.vdisk_lock);
    8000613e:	0001f997          	auipc	s3,0x1f
    80006142:	fea98993          	addi	s3,s3,-22 # 80025128 <disk+0x2128>
  while(b->disk == 1) {
    80006146:	4485                	li	s1,1
    sleep(b, &disk.vdisk_lock);
    80006148:	85ce                	mv	a1,s3
    8000614a:	854a                	mv	a0,s2
    8000614c:	ffffc097          	auipc	ra,0xffffc
    80006150:	f60080e7          	jalr	-160(ra) # 800020ac <sleep>
  while(b->disk == 1) {
    80006154:	00492783          	lw	a5,4(s2)
    80006158:	fe9788e3          	beq	a5,s1,80006148 <virtio_disk_rw+0x212>
  }

  disk.info[idx[0]].b = 0;
    8000615c:	f9042903          	lw	s2,-112(s0)
    80006160:	20090793          	addi	a5,s2,512
    80006164:	00479713          	slli	a4,a5,0x4
    80006168:	0001d797          	auipc	a5,0x1d
    8000616c:	e9878793          	addi	a5,a5,-360 # 80023000 <disk>
    80006170:	97ba                	add	a5,a5,a4
    80006172:	0207b423          	sd	zero,40(a5)
    int flag = disk.desc[i].flags;
    80006176:	0001f997          	auipc	s3,0x1f
    8000617a:	e8a98993          	addi	s3,s3,-374 # 80025000 <disk+0x2000>
    8000617e:	00491713          	slli	a4,s2,0x4
    80006182:	0009b783          	ld	a5,0(s3)
    80006186:	97ba                	add	a5,a5,a4
    80006188:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    8000618c:	854a                	mv	a0,s2
    8000618e:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80006192:	00000097          	auipc	ra,0x0
    80006196:	bc4080e7          	jalr	-1084(ra) # 80005d56 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    8000619a:	8885                	andi	s1,s1,1
    8000619c:	f0ed                	bnez	s1,8000617e <virtio_disk_rw+0x248>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    8000619e:	0001f517          	auipc	a0,0x1f
    800061a2:	f8a50513          	addi	a0,a0,-118 # 80025128 <disk+0x2128>
    800061a6:	ffffb097          	auipc	ra,0xffffb
    800061aa:	ae4080e7          	jalr	-1308(ra) # 80000c8a <release>
}
    800061ae:	70a6                	ld	ra,104(sp)
    800061b0:	7406                	ld	s0,96(sp)
    800061b2:	64e6                	ld	s1,88(sp)
    800061b4:	6946                	ld	s2,80(sp)
    800061b6:	69a6                	ld	s3,72(sp)
    800061b8:	6a06                	ld	s4,64(sp)
    800061ba:	7ae2                	ld	s5,56(sp)
    800061bc:	7b42                	ld	s6,48(sp)
    800061be:	7ba2                	ld	s7,40(sp)
    800061c0:	7c02                	ld	s8,32(sp)
    800061c2:	6ce2                	ld	s9,24(sp)
    800061c4:	6d42                	ld	s10,16(sp)
    800061c6:	6165                	addi	sp,sp,112
    800061c8:	8082                	ret
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    800061ca:	0001f697          	auipc	a3,0x1f
    800061ce:	e366b683          	ld	a3,-458(a3) # 80025000 <disk+0x2000>
    800061d2:	96ba                	add	a3,a3,a4
    800061d4:	4609                	li	a2,2
    800061d6:	00c69623          	sh	a2,12(a3)
    800061da:	b5c9                	j	8000609c <virtio_disk_rw+0x166>
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    800061dc:	f9042583          	lw	a1,-112(s0)
    800061e0:	20058793          	addi	a5,a1,512
    800061e4:	0792                	slli	a5,a5,0x4
    800061e6:	0001d517          	auipc	a0,0x1d
    800061ea:	ec250513          	addi	a0,a0,-318 # 800230a8 <disk+0xa8>
    800061ee:	953e                	add	a0,a0,a5
  if(write)
    800061f0:	e20d11e3          	bnez	s10,80006012 <virtio_disk_rw+0xdc>
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
    800061f4:	20058713          	addi	a4,a1,512
    800061f8:	00471693          	slli	a3,a4,0x4
    800061fc:	0001d717          	auipc	a4,0x1d
    80006200:	e0470713          	addi	a4,a4,-508 # 80023000 <disk>
    80006204:	9736                	add	a4,a4,a3
    80006206:	0a072423          	sw	zero,168(a4)
    8000620a:	b505                	j	8000602a <virtio_disk_rw+0xf4>

000000008000620c <virtio_disk_intr>:

void
virtio_disk_intr()
{
    8000620c:	1101                	addi	sp,sp,-32
    8000620e:	ec06                	sd	ra,24(sp)
    80006210:	e822                	sd	s0,16(sp)
    80006212:	e426                	sd	s1,8(sp)
    80006214:	e04a                	sd	s2,0(sp)
    80006216:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80006218:	0001f517          	auipc	a0,0x1f
    8000621c:	f1050513          	addi	a0,a0,-240 # 80025128 <disk+0x2128>
    80006220:	ffffb097          	auipc	ra,0xffffb
    80006224:	9b6080e7          	jalr	-1610(ra) # 80000bd6 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80006228:	10001737          	lui	a4,0x10001
    8000622c:	533c                	lw	a5,96(a4)
    8000622e:	8b8d                	andi	a5,a5,3
    80006230:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    80006232:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80006236:	0001f797          	auipc	a5,0x1f
    8000623a:	dca78793          	addi	a5,a5,-566 # 80025000 <disk+0x2000>
    8000623e:	6b94                	ld	a3,16(a5)
    80006240:	0207d703          	lhu	a4,32(a5)
    80006244:	0026d783          	lhu	a5,2(a3)
    80006248:	06f70163          	beq	a4,a5,800062aa <virtio_disk_intr+0x9e>
    __sync_synchronize();
    int id = disk.used->ring[disk.used_idx % NUM].id;
    8000624c:	0001d917          	auipc	s2,0x1d
    80006250:	db490913          	addi	s2,s2,-588 # 80023000 <disk>
    80006254:	0001f497          	auipc	s1,0x1f
    80006258:	dac48493          	addi	s1,s1,-596 # 80025000 <disk+0x2000>
    __sync_synchronize();
    8000625c:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80006260:	6898                	ld	a4,16(s1)
    80006262:	0204d783          	lhu	a5,32(s1)
    80006266:	8b9d                	andi	a5,a5,7
    80006268:	078e                	slli	a5,a5,0x3
    8000626a:	97ba                	add	a5,a5,a4
    8000626c:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    8000626e:	20078713          	addi	a4,a5,512
    80006272:	0712                	slli	a4,a4,0x4
    80006274:	974a                	add	a4,a4,s2
    80006276:	03074703          	lbu	a4,48(a4) # 10001030 <_entry-0x6fffefd0>
    8000627a:	e731                	bnez	a4,800062c6 <virtio_disk_intr+0xba>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    8000627c:	20078793          	addi	a5,a5,512
    80006280:	0792                	slli	a5,a5,0x4
    80006282:	97ca                	add	a5,a5,s2
    80006284:	7788                	ld	a0,40(a5)
    b->disk = 0;   // disk is done with buf
    80006286:	00052223          	sw	zero,4(a0)
    wakeup(b);
    8000628a:	ffffc097          	auipc	ra,0xffffc
    8000628e:	fae080e7          	jalr	-82(ra) # 80002238 <wakeup>

    disk.used_idx += 1;
    80006292:	0204d783          	lhu	a5,32(s1)
    80006296:	2785                	addiw	a5,a5,1
    80006298:	17c2                	slli	a5,a5,0x30
    8000629a:	93c1                	srli	a5,a5,0x30
    8000629c:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    800062a0:	6898                	ld	a4,16(s1)
    800062a2:	00275703          	lhu	a4,2(a4)
    800062a6:	faf71be3          	bne	a4,a5,8000625c <virtio_disk_intr+0x50>
  }

  release(&disk.vdisk_lock);
    800062aa:	0001f517          	auipc	a0,0x1f
    800062ae:	e7e50513          	addi	a0,a0,-386 # 80025128 <disk+0x2128>
    800062b2:	ffffb097          	auipc	ra,0xffffb
    800062b6:	9d8080e7          	jalr	-1576(ra) # 80000c8a <release>
}
    800062ba:	60e2                	ld	ra,24(sp)
    800062bc:	6442                	ld	s0,16(sp)
    800062be:	64a2                	ld	s1,8(sp)
    800062c0:	6902                	ld	s2,0(sp)
    800062c2:	6105                	addi	sp,sp,32
    800062c4:	8082                	ret
      panic("virtio_disk_intr status");
    800062c6:	00002517          	auipc	a0,0x2
    800062ca:	52a50513          	addi	a0,a0,1322 # 800087f0 <syscalls+0x3c0>
    800062ce:	ffffa097          	auipc	ra,0xffffa
    800062d2:	262080e7          	jalr	610(ra) # 80000530 <panic>
	...

0000000080007000 <_trampoline>:
    80007000:	14051573          	csrrw	a0,sscratch,a0
    80007004:	02153423          	sd	ra,40(a0)
    80007008:	02253823          	sd	sp,48(a0)
    8000700c:	02353c23          	sd	gp,56(a0)
    80007010:	04453023          	sd	tp,64(a0)
    80007014:	04553423          	sd	t0,72(a0)
    80007018:	04653823          	sd	t1,80(a0)
    8000701c:	04753c23          	sd	t2,88(a0)
    80007020:	f120                	sd	s0,96(a0)
    80007022:	f524                	sd	s1,104(a0)
    80007024:	fd2c                	sd	a1,120(a0)
    80007026:	e150                	sd	a2,128(a0)
    80007028:	e554                	sd	a3,136(a0)
    8000702a:	e958                	sd	a4,144(a0)
    8000702c:	ed5c                	sd	a5,152(a0)
    8000702e:	0b053023          	sd	a6,160(a0)
    80007032:	0b153423          	sd	a7,168(a0)
    80007036:	0b253823          	sd	s2,176(a0)
    8000703a:	0b353c23          	sd	s3,184(a0)
    8000703e:	0d453023          	sd	s4,192(a0)
    80007042:	0d553423          	sd	s5,200(a0)
    80007046:	0d653823          	sd	s6,208(a0)
    8000704a:	0d753c23          	sd	s7,216(a0)
    8000704e:	0f853023          	sd	s8,224(a0)
    80007052:	0f953423          	sd	s9,232(a0)
    80007056:	0fa53823          	sd	s10,240(a0)
    8000705a:	0fb53c23          	sd	s11,248(a0)
    8000705e:	11c53023          	sd	t3,256(a0)
    80007062:	11d53423          	sd	t4,264(a0)
    80007066:	11e53823          	sd	t5,272(a0)
    8000706a:	11f53c23          	sd	t6,280(a0)
    8000706e:	140022f3          	csrr	t0,sscratch
    80007072:	06553823          	sd	t0,112(a0)
    80007076:	00853103          	ld	sp,8(a0)
    8000707a:	02053203          	ld	tp,32(a0)
    8000707e:	01053283          	ld	t0,16(a0)
    80007082:	00053303          	ld	t1,0(a0)
    80007086:	18031073          	csrw	satp,t1
    8000708a:	12000073          	sfence.vma
    8000708e:	8282                	jr	t0

0000000080007090 <userret>:
    80007090:	18059073          	csrw	satp,a1
    80007094:	12000073          	sfence.vma
    80007098:	07053283          	ld	t0,112(a0)
    8000709c:	14029073          	csrw	sscratch,t0
    800070a0:	02853083          	ld	ra,40(a0)
    800070a4:	03053103          	ld	sp,48(a0)
    800070a8:	03853183          	ld	gp,56(a0)
    800070ac:	04053203          	ld	tp,64(a0)
    800070b0:	04853283          	ld	t0,72(a0)
    800070b4:	05053303          	ld	t1,80(a0)
    800070b8:	05853383          	ld	t2,88(a0)
    800070bc:	7120                	ld	s0,96(a0)
    800070be:	7524                	ld	s1,104(a0)
    800070c0:	7d2c                	ld	a1,120(a0)
    800070c2:	6150                	ld	a2,128(a0)
    800070c4:	6554                	ld	a3,136(a0)
    800070c6:	6958                	ld	a4,144(a0)
    800070c8:	6d5c                	ld	a5,152(a0)
    800070ca:	0a053803          	ld	a6,160(a0)
    800070ce:	0a853883          	ld	a7,168(a0)
    800070d2:	0b053903          	ld	s2,176(a0)
    800070d6:	0b853983          	ld	s3,184(a0)
    800070da:	0c053a03          	ld	s4,192(a0)
    800070de:	0c853a83          	ld	s5,200(a0)
    800070e2:	0d053b03          	ld	s6,208(a0)
    800070e6:	0d853b83          	ld	s7,216(a0)
    800070ea:	0e053c03          	ld	s8,224(a0)
    800070ee:	0e853c83          	ld	s9,232(a0)
    800070f2:	0f053d03          	ld	s10,240(a0)
    800070f6:	0f853d83          	ld	s11,248(a0)
    800070fa:	10053e03          	ld	t3,256(a0)
    800070fe:	10853e83          	ld	t4,264(a0)
    80007102:	11053f03          	ld	t5,272(a0)
    80007106:	11853f83          	ld	t6,280(a0)
    8000710a:	14051573          	csrrw	a0,sscratch,a0
    8000710e:	10200073          	sret
	...
