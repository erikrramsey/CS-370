
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00009117          	auipc	sp,0x9
    80000004:	87013103          	ld	sp,-1936(sp) # 80008870 <_GLOBAL_OFFSET_TABLE_+0x8>
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
    80000068:	b6c78793          	addi	a5,a5,-1172 # 80005bd0 <timervec>
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
    80000122:	3e2080e7          	jalr	994(ra) # 80002500 <either_copyin>
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
    800001b6:	00002097          	auipc	ra,0x2
    800001ba:	894080e7          	jalr	-1900(ra) # 80001a4a <myproc>
    800001be:	551c                	lw	a5,40(a0)
    800001c0:	e7b5                	bnez	a5,8000022c <consoleread+0xd6>
      sleep(&cons.r, &cons.lock);
    800001c2:	85ce                	mv	a1,s3
    800001c4:	854a                	mv	a0,s2
    800001c6:	00002097          	auipc	ra,0x2
    800001ca:	f40080e7          	jalr	-192(ra) # 80002106 <sleep>
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
    80000206:	2a8080e7          	jalr	680(ra) # 800024aa <either_copyout>
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
    800002e8:	272080e7          	jalr	626(ra) # 80002556 <procdump>
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
    8000043c:	e5a080e7          	jalr	-422(ra) # 80002292 <wakeup>
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
    8000044e:	bc658593          	addi	a1,a1,-1082 # 80008010 <etext+0x10>
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
    8000046e:	eae78793          	addi	a5,a5,-338 # 80021318 <devsw>
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
    80000548:	ad450513          	addi	a0,a0,-1324 # 80008018 <etext+0x18>
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
    80000600:	a2c50513          	addi	a0,a0,-1492 # 80008028 <etext+0x28>
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
    80000700:	92490913          	addi	s2,s2,-1756 # 80008020 <etext+0x20>
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
    80000776:	8c658593          	addi	a1,a1,-1850 # 80008038 <etext+0x38>
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
    80000896:	a00080e7          	jalr	-1536(ra) # 80002292 <wakeup>
    
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
    80000922:	7e8080e7          	jalr	2024(ra) # 80002106 <sleep>
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
    80000b74:	ebe080e7          	jalr	-322(ra) # 80001a2e <mycpu>
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
    80000ba6:	e8c080e7          	jalr	-372(ra) # 80001a2e <mycpu>
    80000baa:	5d3c                	lw	a5,120(a0)
    80000bac:	cf89                	beqz	a5,80000bc6 <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000bae:	00001097          	auipc	ra,0x1
    80000bb2:	e80080e7          	jalr	-384(ra) # 80001a2e <mycpu>
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
    80000bca:	e68080e7          	jalr	-408(ra) # 80001a2e <mycpu>
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
    80000c0a:	e28080e7          	jalr	-472(ra) # 80001a2e <mycpu>
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
    80000c36:	dfc080e7          	jalr	-516(ra) # 80001a2e <mycpu>
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
    80000e90:	b92080e7          	jalr	-1134(ra) # 80001a1e <cpuid>
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
    80000eac:	b76080e7          	jalr	-1162(ra) # 80001a1e <cpuid>
    80000eb0:	85aa                	mv	a1,a0
    80000eb2:	00007517          	auipc	a0,0x7
    80000eb6:	20650513          	addi	a0,a0,518 # 800080b8 <digits+0x78>
    80000eba:	fffff097          	auipc	ra,0xfffff
    80000ebe:	6c0080e7          	jalr	1728(ra) # 8000057a <printf>
    kvminithart();    // turn on paging
    80000ec2:	00000097          	auipc	ra,0x0
    80000ec6:	0d8080e7          	jalr	216(ra) # 80000f9a <kvminithart>
    trapinithart();   // install kernel trap vector
    80000eca:	00001097          	auipc	ra,0x1
    80000ece:	7cc080e7          	jalr	1996(ra) # 80002696 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000ed2:	00005097          	auipc	ra,0x5
    80000ed6:	d3e080e7          	jalr	-706(ra) # 80005c10 <plicinithart>
  }

  scheduler();        
    80000eda:	00001097          	auipc	ra,0x1
    80000ede:	07a080e7          	jalr	122(ra) # 80001f54 <scheduler>
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
    80000f3e:	a34080e7          	jalr	-1484(ra) # 8000196e <procinit>
    trapinit();      // trap vectors
    80000f42:	00001097          	auipc	ra,0x1
    80000f46:	72c080e7          	jalr	1836(ra) # 8000266e <trapinit>
    trapinithart();  // install kernel trap vector
    80000f4a:	00001097          	auipc	ra,0x1
    80000f4e:	74c080e7          	jalr	1868(ra) # 80002696 <trapinithart>
    plicinit();      // set up interrupt controller
    80000f52:	00005097          	auipc	ra,0x5
    80000f56:	ca8080e7          	jalr	-856(ra) # 80005bfa <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000f5a:	00005097          	auipc	ra,0x5
    80000f5e:	cb6080e7          	jalr	-842(ra) # 80005c10 <plicinithart>
    binit();         // buffer cache
    80000f62:	00002097          	auipc	ra,0x2
    80000f66:	e9c080e7          	jalr	-356(ra) # 80002dfe <binit>
    iinit();         // inode cache
    80000f6a:	00002097          	auipc	ra,0x2
    80000f6e:	52c080e7          	jalr	1324(ra) # 80003496 <iinit>
    fileinit();      // file table
    80000f72:	00003097          	auipc	ra,0x3
    80000f76:	4d6080e7          	jalr	1238(ra) # 80004448 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f7a:	00005097          	auipc	ra,0x5
    80000f7e:	db8080e7          	jalr	-584(ra) # 80005d32 <virtio_disk_init>
    userinit();      // first user process
    80000f82:	00001097          	auipc	ra,0x1
    80000f86:	da0080e7          	jalr	-608(ra) # 80001d22 <userinit>
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
    80001228:	6b4080e7          	jalr	1716(ra) # 800018d8 <proc_mapstacks>
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

0000000080001822 <printTable>:

void printTable(pagetable_t pagetable, uint64 level)
{
    80001822:	7159                	addi	sp,sp,-112
    80001824:	f486                	sd	ra,104(sp)
    80001826:	f0a2                	sd	s0,96(sp)
    80001828:	eca6                	sd	s1,88(sp)
    8000182a:	e8ca                	sd	s2,80(sp)
    8000182c:	e4ce                	sd	s3,72(sp)
    8000182e:	e0d2                	sd	s4,64(sp)
    80001830:	fc56                	sd	s5,56(sp)
    80001832:	f85a                	sd	s6,48(sp)
    80001834:	f45e                	sd	s7,40(sp)
    80001836:	f062                	sd	s8,32(sp)
    80001838:	ec66                	sd	s9,24(sp)
    8000183a:	e86a                	sd	s10,16(sp)
    8000183c:	e46e                	sd	s11,8(sp)
    8000183e:	1880                	addi	s0,sp,112
  // there are 2^9 = 512 PTEs in a page table.
  for (int i = 0; i < 512; i++) {
    80001840:	8a2a                	mv	s4,a0
    80001842:	4981                	li	s3,0
    80001844:	00158b1b          	addiw	s6,a1,1
    pte_t pte = pagetable[i];
    if (pte & PTE_V) {
      for (int j = 0; j <= level; j++) printf("    ");
    80001848:	4d01                	li	s10,0
    8000184a:	00007a97          	auipc	s5,0x7
    8000184e:	976a8a93          	addi	s5,s5,-1674 # 800081c0 <digits+0x180>
      printf("%d: pte %p pa %p\n", i, pte, PTE2PA(pte));
    80001852:	00007c97          	auipc	s9,0x7
    80001856:	976c8c93          	addi	s9,s9,-1674 # 800081c8 <digits+0x188>
    }
    if ((pte & PTE_V) && (pte & (PTE_R | PTE_W | PTE_X)) == 0) {
    8000185a:	4c05                	li	s8,1
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
      printTable((pagetable_t)child, level + 1);
    8000185c:	00158d93          	addi	s11,a1,1 # 4000001 <_entry-0x7bffffff>
  for (int i = 0; i < 512; i++) {
    80001860:	20000b93          	li	s7,512
    80001864:	a01d                	j	8000188a <printTable+0x68>
      printf("%d: pte %p pa %p\n", i, pte, PTE2PA(pte));
    80001866:	00a95693          	srli	a3,s2,0xa
    8000186a:	06b2                	slli	a3,a3,0xc
    8000186c:	864a                	mv	a2,s2
    8000186e:	85ce                	mv	a1,s3
    80001870:	8566                	mv	a0,s9
    80001872:	fffff097          	auipc	ra,0xfffff
    80001876:	d08080e7          	jalr	-760(ra) # 8000057a <printf>
    if ((pte & PTE_V) && (pte & (PTE_R | PTE_W | PTE_X)) == 0) {
    8000187a:	00f97793          	andi	a5,s2,15
    8000187e:	03878563          	beq	a5,s8,800018a8 <printTable+0x86>
  for (int i = 0; i < 512; i++) {
    80001882:	2985                	addiw	s3,s3,1
    80001884:	0a21                	addi	s4,s4,8
    80001886:	03798a63          	beq	s3,s7,800018ba <printTable+0x98>
    pte_t pte = pagetable[i];
    8000188a:	000a3903          	ld	s2,0(s4) # fffffffffffff000 <end+0xffffffff7ffd9000>
    if (pte & PTE_V) {
    8000188e:	00197793          	andi	a5,s2,1
    80001892:	d7e5                	beqz	a5,8000187a <printTable+0x58>
      for (int j = 0; j <= level; j++) printf("    ");
    80001894:	84ea                	mv	s1,s10
    80001896:	8556                	mv	a0,s5
    80001898:	fffff097          	auipc	ra,0xfffff
    8000189c:	ce2080e7          	jalr	-798(ra) # 8000057a <printf>
    800018a0:	2485                	addiw	s1,s1,1
    800018a2:	fe9b1ae3          	bne	s6,s1,80001896 <printTable+0x74>
    800018a6:	b7c1                	j	80001866 <printTable+0x44>
      uint64 child = PTE2PA(pte);
    800018a8:	00a95513          	srli	a0,s2,0xa
      printTable((pagetable_t)child, level + 1);
    800018ac:	85ee                	mv	a1,s11
    800018ae:	0532                	slli	a0,a0,0xc
    800018b0:	00000097          	auipc	ra,0x0
    800018b4:	f72080e7          	jalr	-142(ra) # 80001822 <printTable>
    800018b8:	b7e9                	j	80001882 <printTable+0x60>
    }
  }
    800018ba:	70a6                	ld	ra,104(sp)
    800018bc:	7406                	ld	s0,96(sp)
    800018be:	64e6                	ld	s1,88(sp)
    800018c0:	6946                	ld	s2,80(sp)
    800018c2:	69a6                	ld	s3,72(sp)
    800018c4:	6a06                	ld	s4,64(sp)
    800018c6:	7ae2                	ld	s5,56(sp)
    800018c8:	7b42                	ld	s6,48(sp)
    800018ca:	7ba2                	ld	s7,40(sp)
    800018cc:	7c02                	ld	s8,32(sp)
    800018ce:	6ce2                	ld	s9,24(sp)
    800018d0:	6d42                	ld	s10,16(sp)
    800018d2:	6da2                	ld	s11,8(sp)
    800018d4:	6165                	addi	sp,sp,112
    800018d6:	8082                	ret

00000000800018d8 <proc_mapstacks>:

// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl) {
    800018d8:	7139                	addi	sp,sp,-64
    800018da:	fc06                	sd	ra,56(sp)
    800018dc:	f822                	sd	s0,48(sp)
    800018de:	f426                	sd	s1,40(sp)
    800018e0:	f04a                	sd	s2,32(sp)
    800018e2:	ec4e                	sd	s3,24(sp)
    800018e4:	e852                	sd	s4,16(sp)
    800018e6:	e456                	sd	s5,8(sp)
    800018e8:	e05a                	sd	s6,0(sp)
    800018ea:	0080                	addi	s0,sp,64
    800018ec:	89aa                	mv	s3,a0
  struct proc *p;
  
  for(p = proc; p < &proc[NPROC]; p++) {
    800018ee:	00010497          	auipc	s1,0x10
    800018f2:	de248493          	addi	s1,s1,-542 # 800116d0 <proc>
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    800018f6:	8b26                	mv	s6,s1
    800018f8:	00006a97          	auipc	s5,0x6
    800018fc:	708a8a93          	addi	s5,s5,1800 # 80008000 <etext>
    80001900:	04000937          	lui	s2,0x4000
    80001904:	197d                	addi	s2,s2,-1
    80001906:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001908:	00015a17          	auipc	s4,0x15
    8000190c:	7c8a0a13          	addi	s4,s4,1992 # 800170d0 <tickslock>
    char *pa = kalloc();
    80001910:	fffff097          	auipc	ra,0xfffff
    80001914:	1d6080e7          	jalr	470(ra) # 80000ae6 <kalloc>
    80001918:	862a                	mv	a2,a0
    if(pa == 0)
    8000191a:	c131                	beqz	a0,8000195e <proc_mapstacks+0x86>
    uint64 va = KSTACK((int) (p - proc));
    8000191c:	416485b3          	sub	a1,s1,s6
    80001920:	858d                	srai	a1,a1,0x3
    80001922:	000ab783          	ld	a5,0(s5)
    80001926:	02f585b3          	mul	a1,a1,a5
    8000192a:	2585                	addiw	a1,a1,1
    8000192c:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80001930:	4719                	li	a4,6
    80001932:	6685                	lui	a3,0x1
    80001934:	40b905b3          	sub	a1,s2,a1
    80001938:	854e                	mv	a0,s3
    8000193a:	fffff097          	auipc	ra,0xfffff
    8000193e:	7fa080e7          	jalr	2042(ra) # 80001134 <kvmmap>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001942:	16848493          	addi	s1,s1,360
    80001946:	fd4495e3          	bne	s1,s4,80001910 <proc_mapstacks+0x38>
  }
}
    8000194a:	70e2                	ld	ra,56(sp)
    8000194c:	7442                	ld	s0,48(sp)
    8000194e:	74a2                	ld	s1,40(sp)
    80001950:	7902                	ld	s2,32(sp)
    80001952:	69e2                	ld	s3,24(sp)
    80001954:	6a42                	ld	s4,16(sp)
    80001956:	6aa2                	ld	s5,8(sp)
    80001958:	6b02                	ld	s6,0(sp)
    8000195a:	6121                	addi	sp,sp,64
    8000195c:	8082                	ret
      panic("kalloc");
    8000195e:	00007517          	auipc	a0,0x7
    80001962:	88250513          	addi	a0,a0,-1918 # 800081e0 <digits+0x1a0>
    80001966:	fffff097          	auipc	ra,0xfffff
    8000196a:	bca080e7          	jalr	-1078(ra) # 80000530 <panic>

000000008000196e <procinit>:

// initialize the proc table at boot time.
void
procinit(void)
{
    8000196e:	7139                	addi	sp,sp,-64
    80001970:	fc06                	sd	ra,56(sp)
    80001972:	f822                	sd	s0,48(sp)
    80001974:	f426                	sd	s1,40(sp)
    80001976:	f04a                	sd	s2,32(sp)
    80001978:	ec4e                	sd	s3,24(sp)
    8000197a:	e852                	sd	s4,16(sp)
    8000197c:	e456                	sd	s5,8(sp)
    8000197e:	e05a                	sd	s6,0(sp)
    80001980:	0080                	addi	s0,sp,64
  struct proc *p;
  
  initlock(&pid_lock, "nextpid");
    80001982:	00007597          	auipc	a1,0x7
    80001986:	86658593          	addi	a1,a1,-1946 # 800081e8 <digits+0x1a8>
    8000198a:	00010517          	auipc	a0,0x10
    8000198e:	91650513          	addi	a0,a0,-1770 # 800112a0 <pid_lock>
    80001992:	fffff097          	auipc	ra,0xfffff
    80001996:	1b4080e7          	jalr	436(ra) # 80000b46 <initlock>
  initlock(&wait_lock, "wait_lock");
    8000199a:	00007597          	auipc	a1,0x7
    8000199e:	85658593          	addi	a1,a1,-1962 # 800081f0 <digits+0x1b0>
    800019a2:	00010517          	auipc	a0,0x10
    800019a6:	91650513          	addi	a0,a0,-1770 # 800112b8 <wait_lock>
    800019aa:	fffff097          	auipc	ra,0xfffff
    800019ae:	19c080e7          	jalr	412(ra) # 80000b46 <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    800019b2:	00010497          	auipc	s1,0x10
    800019b6:	d1e48493          	addi	s1,s1,-738 # 800116d0 <proc>
      initlock(&p->lock, "proc");
    800019ba:	00007b17          	auipc	s6,0x7
    800019be:	846b0b13          	addi	s6,s6,-1978 # 80008200 <digits+0x1c0>
      p->kstack = KSTACK((int) (p - proc));
    800019c2:	8aa6                	mv	s5,s1
    800019c4:	00006a17          	auipc	s4,0x6
    800019c8:	63ca0a13          	addi	s4,s4,1596 # 80008000 <etext>
    800019cc:	04000937          	lui	s2,0x4000
    800019d0:	197d                	addi	s2,s2,-1
    800019d2:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    800019d4:	00015997          	auipc	s3,0x15
    800019d8:	6fc98993          	addi	s3,s3,1788 # 800170d0 <tickslock>
      initlock(&p->lock, "proc");
    800019dc:	85da                	mv	a1,s6
    800019de:	8526                	mv	a0,s1
    800019e0:	fffff097          	auipc	ra,0xfffff
    800019e4:	166080e7          	jalr	358(ra) # 80000b46 <initlock>
      p->kstack = KSTACK((int) (p - proc));
    800019e8:	415487b3          	sub	a5,s1,s5
    800019ec:	878d                	srai	a5,a5,0x3
    800019ee:	000a3703          	ld	a4,0(s4)
    800019f2:	02e787b3          	mul	a5,a5,a4
    800019f6:	2785                	addiw	a5,a5,1
    800019f8:	00d7979b          	slliw	a5,a5,0xd
    800019fc:	40f907b3          	sub	a5,s2,a5
    80001a00:	e0bc                	sd	a5,64(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    80001a02:	16848493          	addi	s1,s1,360
    80001a06:	fd349be3          	bne	s1,s3,800019dc <procinit+0x6e>
  }
}
    80001a0a:	70e2                	ld	ra,56(sp)
    80001a0c:	7442                	ld	s0,48(sp)
    80001a0e:	74a2                	ld	s1,40(sp)
    80001a10:	7902                	ld	s2,32(sp)
    80001a12:	69e2                	ld	s3,24(sp)
    80001a14:	6a42                	ld	s4,16(sp)
    80001a16:	6aa2                	ld	s5,8(sp)
    80001a18:	6b02                	ld	s6,0(sp)
    80001a1a:	6121                	addi	sp,sp,64
    80001a1c:	8082                	ret

0000000080001a1e <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    80001a1e:	1141                	addi	sp,sp,-16
    80001a20:	e422                	sd	s0,8(sp)
    80001a22:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80001a24:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    80001a26:	2501                	sext.w	a0,a0
    80001a28:	6422                	ld	s0,8(sp)
    80001a2a:	0141                	addi	sp,sp,16
    80001a2c:	8082                	ret

0000000080001a2e <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void) {
    80001a2e:	1141                	addi	sp,sp,-16
    80001a30:	e422                	sd	s0,8(sp)
    80001a32:	0800                	addi	s0,sp,16
    80001a34:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    80001a36:	2781                	sext.w	a5,a5
    80001a38:	079e                	slli	a5,a5,0x7
  return c;
}
    80001a3a:	00010517          	auipc	a0,0x10
    80001a3e:	89650513          	addi	a0,a0,-1898 # 800112d0 <cpus>
    80001a42:	953e                	add	a0,a0,a5
    80001a44:	6422                	ld	s0,8(sp)
    80001a46:	0141                	addi	sp,sp,16
    80001a48:	8082                	ret

0000000080001a4a <myproc>:

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void) {
    80001a4a:	1101                	addi	sp,sp,-32
    80001a4c:	ec06                	sd	ra,24(sp)
    80001a4e:	e822                	sd	s0,16(sp)
    80001a50:	e426                	sd	s1,8(sp)
    80001a52:	1000                	addi	s0,sp,32
  push_off();
    80001a54:	fffff097          	auipc	ra,0xfffff
    80001a58:	136080e7          	jalr	310(ra) # 80000b8a <push_off>
    80001a5c:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    80001a5e:	2781                	sext.w	a5,a5
    80001a60:	079e                	slli	a5,a5,0x7
    80001a62:	00010717          	auipc	a4,0x10
    80001a66:	83e70713          	addi	a4,a4,-1986 # 800112a0 <pid_lock>
    80001a6a:	97ba                	add	a5,a5,a4
    80001a6c:	7b84                	ld	s1,48(a5)
  pop_off();
    80001a6e:	fffff097          	auipc	ra,0xfffff
    80001a72:	1bc080e7          	jalr	444(ra) # 80000c2a <pop_off>
  return p;
}
    80001a76:	8526                	mv	a0,s1
    80001a78:	60e2                	ld	ra,24(sp)
    80001a7a:	6442                	ld	s0,16(sp)
    80001a7c:	64a2                	ld	s1,8(sp)
    80001a7e:	6105                	addi	sp,sp,32
    80001a80:	8082                	ret

0000000080001a82 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    80001a82:	1141                	addi	sp,sp,-16
    80001a84:	e406                	sd	ra,8(sp)
    80001a86:	e022                	sd	s0,0(sp)
    80001a88:	0800                	addi	s0,sp,16
  static int first = 1;

  // Still holding p->lock from scheduler.
  release(&myproc()->lock);
    80001a8a:	00000097          	auipc	ra,0x0
    80001a8e:	fc0080e7          	jalr	-64(ra) # 80001a4a <myproc>
    80001a92:	fffff097          	auipc	ra,0xfffff
    80001a96:	1f8080e7          	jalr	504(ra) # 80000c8a <release>

  if (first) {
    80001a9a:	00007797          	auipc	a5,0x7
    80001a9e:	d867a783          	lw	a5,-634(a5) # 80008820 <first.1671>
    80001aa2:	eb89                	bnez	a5,80001ab4 <forkret+0x32>
    // be run from main().
    first = 0;
    fsinit(ROOTDEV);
  }

  usertrapret();
    80001aa4:	00001097          	auipc	ra,0x1
    80001aa8:	c0a080e7          	jalr	-1014(ra) # 800026ae <usertrapret>
}
    80001aac:	60a2                	ld	ra,8(sp)
    80001aae:	6402                	ld	s0,0(sp)
    80001ab0:	0141                	addi	sp,sp,16
    80001ab2:	8082                	ret
    first = 0;
    80001ab4:	00007797          	auipc	a5,0x7
    80001ab8:	d607a623          	sw	zero,-660(a5) # 80008820 <first.1671>
    fsinit(ROOTDEV);
    80001abc:	4505                	li	a0,1
    80001abe:	00002097          	auipc	ra,0x2
    80001ac2:	958080e7          	jalr	-1704(ra) # 80003416 <fsinit>
    80001ac6:	bff9                	j	80001aa4 <forkret+0x22>

0000000080001ac8 <allocpid>:
allocpid() {
    80001ac8:	1101                	addi	sp,sp,-32
    80001aca:	ec06                	sd	ra,24(sp)
    80001acc:	e822                	sd	s0,16(sp)
    80001ace:	e426                	sd	s1,8(sp)
    80001ad0:	e04a                	sd	s2,0(sp)
    80001ad2:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001ad4:	0000f917          	auipc	s2,0xf
    80001ad8:	7cc90913          	addi	s2,s2,1996 # 800112a0 <pid_lock>
    80001adc:	854a                	mv	a0,s2
    80001ade:	fffff097          	auipc	ra,0xfffff
    80001ae2:	0f8080e7          	jalr	248(ra) # 80000bd6 <acquire>
  pid = nextpid;
    80001ae6:	00007797          	auipc	a5,0x7
    80001aea:	d3e78793          	addi	a5,a5,-706 # 80008824 <nextpid>
    80001aee:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001af0:	0014871b          	addiw	a4,s1,1
    80001af4:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001af6:	854a                	mv	a0,s2
    80001af8:	fffff097          	auipc	ra,0xfffff
    80001afc:	192080e7          	jalr	402(ra) # 80000c8a <release>
}
    80001b00:	8526                	mv	a0,s1
    80001b02:	60e2                	ld	ra,24(sp)
    80001b04:	6442                	ld	s0,16(sp)
    80001b06:	64a2                	ld	s1,8(sp)
    80001b08:	6902                	ld	s2,0(sp)
    80001b0a:	6105                	addi	sp,sp,32
    80001b0c:	8082                	ret

0000000080001b0e <proc_pagetable>:
{
    80001b0e:	1101                	addi	sp,sp,-32
    80001b10:	ec06                	sd	ra,24(sp)
    80001b12:	e822                	sd	s0,16(sp)
    80001b14:	e426                	sd	s1,8(sp)
    80001b16:	e04a                	sd	s2,0(sp)
    80001b18:	1000                	addi	s0,sp,32
    80001b1a:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001b1c:	00000097          	auipc	ra,0x0
    80001b20:	802080e7          	jalr	-2046(ra) # 8000131e <uvmcreate>
    80001b24:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001b26:	c121                	beqz	a0,80001b66 <proc_pagetable+0x58>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001b28:	4729                	li	a4,10
    80001b2a:	00005697          	auipc	a3,0x5
    80001b2e:	4d668693          	addi	a3,a3,1238 # 80007000 <_trampoline>
    80001b32:	6605                	lui	a2,0x1
    80001b34:	040005b7          	lui	a1,0x4000
    80001b38:	15fd                	addi	a1,a1,-1
    80001b3a:	05b2                	slli	a1,a1,0xc
    80001b3c:	fffff097          	auipc	ra,0xfffff
    80001b40:	56a080e7          	jalr	1386(ra) # 800010a6 <mappages>
    80001b44:	02054863          	bltz	a0,80001b74 <proc_pagetable+0x66>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80001b48:	4719                	li	a4,6
    80001b4a:	05893683          	ld	a3,88(s2)
    80001b4e:	6605                	lui	a2,0x1
    80001b50:	020005b7          	lui	a1,0x2000
    80001b54:	15fd                	addi	a1,a1,-1
    80001b56:	05b6                	slli	a1,a1,0xd
    80001b58:	8526                	mv	a0,s1
    80001b5a:	fffff097          	auipc	ra,0xfffff
    80001b5e:	54c080e7          	jalr	1356(ra) # 800010a6 <mappages>
    80001b62:	02054163          	bltz	a0,80001b84 <proc_pagetable+0x76>
}
    80001b66:	8526                	mv	a0,s1
    80001b68:	60e2                	ld	ra,24(sp)
    80001b6a:	6442                	ld	s0,16(sp)
    80001b6c:	64a2                	ld	s1,8(sp)
    80001b6e:	6902                	ld	s2,0(sp)
    80001b70:	6105                	addi	sp,sp,32
    80001b72:	8082                	ret
    uvmfree(pagetable, 0);
    80001b74:	4581                	li	a1,0
    80001b76:	8526                	mv	a0,s1
    80001b78:	00000097          	auipc	ra,0x0
    80001b7c:	9a2080e7          	jalr	-1630(ra) # 8000151a <uvmfree>
    return 0;
    80001b80:	4481                	li	s1,0
    80001b82:	b7d5                	j	80001b66 <proc_pagetable+0x58>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001b84:	4681                	li	a3,0
    80001b86:	4605                	li	a2,1
    80001b88:	040005b7          	lui	a1,0x4000
    80001b8c:	15fd                	addi	a1,a1,-1
    80001b8e:	05b2                	slli	a1,a1,0xc
    80001b90:	8526                	mv	a0,s1
    80001b92:	fffff097          	auipc	ra,0xfffff
    80001b96:	6c8080e7          	jalr	1736(ra) # 8000125a <uvmunmap>
    uvmfree(pagetable, 0);
    80001b9a:	4581                	li	a1,0
    80001b9c:	8526                	mv	a0,s1
    80001b9e:	00000097          	auipc	ra,0x0
    80001ba2:	97c080e7          	jalr	-1668(ra) # 8000151a <uvmfree>
    return 0;
    80001ba6:	4481                	li	s1,0
    80001ba8:	bf7d                	j	80001b66 <proc_pagetable+0x58>

0000000080001baa <proc_freepagetable>:
{
    80001baa:	1101                	addi	sp,sp,-32
    80001bac:	ec06                	sd	ra,24(sp)
    80001bae:	e822                	sd	s0,16(sp)
    80001bb0:	e426                	sd	s1,8(sp)
    80001bb2:	e04a                	sd	s2,0(sp)
    80001bb4:	1000                	addi	s0,sp,32
    80001bb6:	84aa                	mv	s1,a0
    80001bb8:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001bba:	4681                	li	a3,0
    80001bbc:	4605                	li	a2,1
    80001bbe:	040005b7          	lui	a1,0x4000
    80001bc2:	15fd                	addi	a1,a1,-1
    80001bc4:	05b2                	slli	a1,a1,0xc
    80001bc6:	fffff097          	auipc	ra,0xfffff
    80001bca:	694080e7          	jalr	1684(ra) # 8000125a <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001bce:	4681                	li	a3,0
    80001bd0:	4605                	li	a2,1
    80001bd2:	020005b7          	lui	a1,0x2000
    80001bd6:	15fd                	addi	a1,a1,-1
    80001bd8:	05b6                	slli	a1,a1,0xd
    80001bda:	8526                	mv	a0,s1
    80001bdc:	fffff097          	auipc	ra,0xfffff
    80001be0:	67e080e7          	jalr	1662(ra) # 8000125a <uvmunmap>
  uvmfree(pagetable, sz);
    80001be4:	85ca                	mv	a1,s2
    80001be6:	8526                	mv	a0,s1
    80001be8:	00000097          	auipc	ra,0x0
    80001bec:	932080e7          	jalr	-1742(ra) # 8000151a <uvmfree>
}
    80001bf0:	60e2                	ld	ra,24(sp)
    80001bf2:	6442                	ld	s0,16(sp)
    80001bf4:	64a2                	ld	s1,8(sp)
    80001bf6:	6902                	ld	s2,0(sp)
    80001bf8:	6105                	addi	sp,sp,32
    80001bfa:	8082                	ret

0000000080001bfc <freeproc>:
{
    80001bfc:	1101                	addi	sp,sp,-32
    80001bfe:	ec06                	sd	ra,24(sp)
    80001c00:	e822                	sd	s0,16(sp)
    80001c02:	e426                	sd	s1,8(sp)
    80001c04:	1000                	addi	s0,sp,32
    80001c06:	84aa                	mv	s1,a0
  if(p->trapframe)
    80001c08:	6d28                	ld	a0,88(a0)
    80001c0a:	c509                	beqz	a0,80001c14 <freeproc+0x18>
    kfree((void*)p->trapframe);
    80001c0c:	fffff097          	auipc	ra,0xfffff
    80001c10:	dde080e7          	jalr	-546(ra) # 800009ea <kfree>
  p->trapframe = 0;
    80001c14:	0404bc23          	sd	zero,88(s1)
  if(p->pagetable)
    80001c18:	68a8                	ld	a0,80(s1)
    80001c1a:	c511                	beqz	a0,80001c26 <freeproc+0x2a>
    proc_freepagetable(p->pagetable, p->sz);
    80001c1c:	64ac                	ld	a1,72(s1)
    80001c1e:	00000097          	auipc	ra,0x0
    80001c22:	f8c080e7          	jalr	-116(ra) # 80001baa <proc_freepagetable>
  p->pagetable = 0;
    80001c26:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001c2a:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001c2e:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001c32:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    80001c36:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001c3a:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001c3e:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001c42:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001c46:	0004ac23          	sw	zero,24(s1)
}
    80001c4a:	60e2                	ld	ra,24(sp)
    80001c4c:	6442                	ld	s0,16(sp)
    80001c4e:	64a2                	ld	s1,8(sp)
    80001c50:	6105                	addi	sp,sp,32
    80001c52:	8082                	ret

0000000080001c54 <allocproc>:
{
    80001c54:	1101                	addi	sp,sp,-32
    80001c56:	ec06                	sd	ra,24(sp)
    80001c58:	e822                	sd	s0,16(sp)
    80001c5a:	e426                	sd	s1,8(sp)
    80001c5c:	e04a                	sd	s2,0(sp)
    80001c5e:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001c60:	00010497          	auipc	s1,0x10
    80001c64:	a7048493          	addi	s1,s1,-1424 # 800116d0 <proc>
    80001c68:	00015917          	auipc	s2,0x15
    80001c6c:	46890913          	addi	s2,s2,1128 # 800170d0 <tickslock>
    acquire(&p->lock);
    80001c70:	8526                	mv	a0,s1
    80001c72:	fffff097          	auipc	ra,0xfffff
    80001c76:	f64080e7          	jalr	-156(ra) # 80000bd6 <acquire>
    if(p->state == UNUSED) {
    80001c7a:	4c9c                	lw	a5,24(s1)
    80001c7c:	cf81                	beqz	a5,80001c94 <allocproc+0x40>
      release(&p->lock);
    80001c7e:	8526                	mv	a0,s1
    80001c80:	fffff097          	auipc	ra,0xfffff
    80001c84:	00a080e7          	jalr	10(ra) # 80000c8a <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001c88:	16848493          	addi	s1,s1,360
    80001c8c:	ff2492e3          	bne	s1,s2,80001c70 <allocproc+0x1c>
  return 0;
    80001c90:	4481                	li	s1,0
    80001c92:	a889                	j	80001ce4 <allocproc+0x90>
  p->pid = allocpid();
    80001c94:	00000097          	auipc	ra,0x0
    80001c98:	e34080e7          	jalr	-460(ra) # 80001ac8 <allocpid>
    80001c9c:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001c9e:	4785                	li	a5,1
    80001ca0:	cc9c                	sw	a5,24(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001ca2:	fffff097          	auipc	ra,0xfffff
    80001ca6:	e44080e7          	jalr	-444(ra) # 80000ae6 <kalloc>
    80001caa:	892a                	mv	s2,a0
    80001cac:	eca8                	sd	a0,88(s1)
    80001cae:	c131                	beqz	a0,80001cf2 <allocproc+0x9e>
  p->pagetable = proc_pagetable(p);
    80001cb0:	8526                	mv	a0,s1
    80001cb2:	00000097          	auipc	ra,0x0
    80001cb6:	e5c080e7          	jalr	-420(ra) # 80001b0e <proc_pagetable>
    80001cba:	892a                	mv	s2,a0
    80001cbc:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    80001cbe:	c531                	beqz	a0,80001d0a <allocproc+0xb6>
  memset(&p->context, 0, sizeof(p->context));
    80001cc0:	07000613          	li	a2,112
    80001cc4:	4581                	li	a1,0
    80001cc6:	06048513          	addi	a0,s1,96
    80001cca:	fffff097          	auipc	ra,0xfffff
    80001cce:	008080e7          	jalr	8(ra) # 80000cd2 <memset>
  p->context.ra = (uint64)forkret;
    80001cd2:	00000797          	auipc	a5,0x0
    80001cd6:	db078793          	addi	a5,a5,-592 # 80001a82 <forkret>
    80001cda:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001cdc:	60bc                	ld	a5,64(s1)
    80001cde:	6705                	lui	a4,0x1
    80001ce0:	97ba                	add	a5,a5,a4
    80001ce2:	f4bc                	sd	a5,104(s1)
}
    80001ce4:	8526                	mv	a0,s1
    80001ce6:	60e2                	ld	ra,24(sp)
    80001ce8:	6442                	ld	s0,16(sp)
    80001cea:	64a2                	ld	s1,8(sp)
    80001cec:	6902                	ld	s2,0(sp)
    80001cee:	6105                	addi	sp,sp,32
    80001cf0:	8082                	ret
    freeproc(p);
    80001cf2:	8526                	mv	a0,s1
    80001cf4:	00000097          	auipc	ra,0x0
    80001cf8:	f08080e7          	jalr	-248(ra) # 80001bfc <freeproc>
    release(&p->lock);
    80001cfc:	8526                	mv	a0,s1
    80001cfe:	fffff097          	auipc	ra,0xfffff
    80001d02:	f8c080e7          	jalr	-116(ra) # 80000c8a <release>
    return 0;
    80001d06:	84ca                	mv	s1,s2
    80001d08:	bff1                	j	80001ce4 <allocproc+0x90>
    freeproc(p);
    80001d0a:	8526                	mv	a0,s1
    80001d0c:	00000097          	auipc	ra,0x0
    80001d10:	ef0080e7          	jalr	-272(ra) # 80001bfc <freeproc>
    release(&p->lock);
    80001d14:	8526                	mv	a0,s1
    80001d16:	fffff097          	auipc	ra,0xfffff
    80001d1a:	f74080e7          	jalr	-140(ra) # 80000c8a <release>
    return 0;
    80001d1e:	84ca                	mv	s1,s2
    80001d20:	b7d1                	j	80001ce4 <allocproc+0x90>

0000000080001d22 <userinit>:
{
    80001d22:	1101                	addi	sp,sp,-32
    80001d24:	ec06                	sd	ra,24(sp)
    80001d26:	e822                	sd	s0,16(sp)
    80001d28:	e426                	sd	s1,8(sp)
    80001d2a:	1000                	addi	s0,sp,32
  p = allocproc();
    80001d2c:	00000097          	auipc	ra,0x0
    80001d30:	f28080e7          	jalr	-216(ra) # 80001c54 <allocproc>
    80001d34:	84aa                	mv	s1,a0
  initproc = p;
    80001d36:	00007797          	auipc	a5,0x7
    80001d3a:	2ea7b923          	sd	a0,754(a5) # 80009028 <initproc>
  uvminit(p->pagetable, initcode, sizeof(initcode));
    80001d3e:	03400613          	li	a2,52
    80001d42:	00007597          	auipc	a1,0x7
    80001d46:	aee58593          	addi	a1,a1,-1298 # 80008830 <initcode>
    80001d4a:	6928                	ld	a0,80(a0)
    80001d4c:	fffff097          	auipc	ra,0xfffff
    80001d50:	600080e7          	jalr	1536(ra) # 8000134c <uvminit>
  p->sz = PGSIZE;
    80001d54:	6785                	lui	a5,0x1
    80001d56:	e4bc                	sd	a5,72(s1)
  p->trapframe->epc = 0;      // user program counter
    80001d58:	6cb8                	ld	a4,88(s1)
    80001d5a:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE;  // user stack pointer
    80001d5e:	6cb8                	ld	a4,88(s1)
    80001d60:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001d62:	4641                	li	a2,16
    80001d64:	00006597          	auipc	a1,0x6
    80001d68:	4a458593          	addi	a1,a1,1188 # 80008208 <digits+0x1c8>
    80001d6c:	15848513          	addi	a0,s1,344
    80001d70:	fffff097          	auipc	ra,0xfffff
    80001d74:	0b8080e7          	jalr	184(ra) # 80000e28 <safestrcpy>
  p->cwd = namei("/");
    80001d78:	00006517          	auipc	a0,0x6
    80001d7c:	4a050513          	addi	a0,a0,1184 # 80008218 <digits+0x1d8>
    80001d80:	00002097          	auipc	ra,0x2
    80001d84:	0c4080e7          	jalr	196(ra) # 80003e44 <namei>
    80001d88:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001d8c:	478d                	li	a5,3
    80001d8e:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001d90:	8526                	mv	a0,s1
    80001d92:	fffff097          	auipc	ra,0xfffff
    80001d96:	ef8080e7          	jalr	-264(ra) # 80000c8a <release>
}
    80001d9a:	60e2                	ld	ra,24(sp)
    80001d9c:	6442                	ld	s0,16(sp)
    80001d9e:	64a2                	ld	s1,8(sp)
    80001da0:	6105                	addi	sp,sp,32
    80001da2:	8082                	ret

0000000080001da4 <growproc>:
{
    80001da4:	1101                	addi	sp,sp,-32
    80001da6:	ec06                	sd	ra,24(sp)
    80001da8:	e822                	sd	s0,16(sp)
    80001daa:	e426                	sd	s1,8(sp)
    80001dac:	e04a                	sd	s2,0(sp)
    80001dae:	1000                	addi	s0,sp,32
    80001db0:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001db2:	00000097          	auipc	ra,0x0
    80001db6:	c98080e7          	jalr	-872(ra) # 80001a4a <myproc>
    80001dba:	892a                	mv	s2,a0
  sz = p->sz;
    80001dbc:	652c                	ld	a1,72(a0)
    80001dbe:	0005861b          	sext.w	a2,a1
  if(n > 0){
    80001dc2:	00904f63          	bgtz	s1,80001de0 <growproc+0x3c>
  } else if(n < 0){
    80001dc6:	0204cc63          	bltz	s1,80001dfe <growproc+0x5a>
  p->sz = sz;
    80001dca:	1602                	slli	a2,a2,0x20
    80001dcc:	9201                	srli	a2,a2,0x20
    80001dce:	04c93423          	sd	a2,72(s2)
  return 0;
    80001dd2:	4501                	li	a0,0
}
    80001dd4:	60e2                	ld	ra,24(sp)
    80001dd6:	6442                	ld	s0,16(sp)
    80001dd8:	64a2                	ld	s1,8(sp)
    80001dda:	6902                	ld	s2,0(sp)
    80001ddc:	6105                	addi	sp,sp,32
    80001dde:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n)) == 0) {
    80001de0:	9e25                	addw	a2,a2,s1
    80001de2:	1602                	slli	a2,a2,0x20
    80001de4:	9201                	srli	a2,a2,0x20
    80001de6:	1582                	slli	a1,a1,0x20
    80001de8:	9181                	srli	a1,a1,0x20
    80001dea:	6928                	ld	a0,80(a0)
    80001dec:	fffff097          	auipc	ra,0xfffff
    80001df0:	61a080e7          	jalr	1562(ra) # 80001406 <uvmalloc>
    80001df4:	0005061b          	sext.w	a2,a0
    80001df8:	fa69                	bnez	a2,80001dca <growproc+0x26>
      return -1;
    80001dfa:	557d                	li	a0,-1
    80001dfc:	bfe1                	j	80001dd4 <growproc+0x30>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001dfe:	9e25                	addw	a2,a2,s1
    80001e00:	1602                	slli	a2,a2,0x20
    80001e02:	9201                	srli	a2,a2,0x20
    80001e04:	1582                	slli	a1,a1,0x20
    80001e06:	9181                	srli	a1,a1,0x20
    80001e08:	6928                	ld	a0,80(a0)
    80001e0a:	fffff097          	auipc	ra,0xfffff
    80001e0e:	5b4080e7          	jalr	1460(ra) # 800013be <uvmdealloc>
    80001e12:	0005061b          	sext.w	a2,a0
    80001e16:	bf55                	j	80001dca <growproc+0x26>

0000000080001e18 <fork>:
{
    80001e18:	7179                	addi	sp,sp,-48
    80001e1a:	f406                	sd	ra,40(sp)
    80001e1c:	f022                	sd	s0,32(sp)
    80001e1e:	ec26                	sd	s1,24(sp)
    80001e20:	e84a                	sd	s2,16(sp)
    80001e22:	e44e                	sd	s3,8(sp)
    80001e24:	e052                	sd	s4,0(sp)
    80001e26:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001e28:	00000097          	auipc	ra,0x0
    80001e2c:	c22080e7          	jalr	-990(ra) # 80001a4a <myproc>
    80001e30:	892a                	mv	s2,a0
  if((np = allocproc()) == 0){
    80001e32:	00000097          	auipc	ra,0x0
    80001e36:	e22080e7          	jalr	-478(ra) # 80001c54 <allocproc>
    80001e3a:	10050b63          	beqz	a0,80001f50 <fork+0x138>
    80001e3e:	89aa                	mv	s3,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001e40:	04893603          	ld	a2,72(s2)
    80001e44:	692c                	ld	a1,80(a0)
    80001e46:	05093503          	ld	a0,80(s2)
    80001e4a:	fffff097          	auipc	ra,0xfffff
    80001e4e:	708080e7          	jalr	1800(ra) # 80001552 <uvmcopy>
    80001e52:	04054663          	bltz	a0,80001e9e <fork+0x86>
  np->sz = p->sz;
    80001e56:	04893783          	ld	a5,72(s2)
    80001e5a:	04f9b423          	sd	a5,72(s3)
  *(np->trapframe) = *(p->trapframe);
    80001e5e:	05893683          	ld	a3,88(s2)
    80001e62:	87b6                	mv	a5,a3
    80001e64:	0589b703          	ld	a4,88(s3)
    80001e68:	12068693          	addi	a3,a3,288
    80001e6c:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80001e70:	6788                	ld	a0,8(a5)
    80001e72:	6b8c                	ld	a1,16(a5)
    80001e74:	6f90                	ld	a2,24(a5)
    80001e76:	01073023          	sd	a6,0(a4)
    80001e7a:	e708                	sd	a0,8(a4)
    80001e7c:	eb0c                	sd	a1,16(a4)
    80001e7e:	ef10                	sd	a2,24(a4)
    80001e80:	02078793          	addi	a5,a5,32
    80001e84:	02070713          	addi	a4,a4,32
    80001e88:	fed792e3          	bne	a5,a3,80001e6c <fork+0x54>
  np->trapframe->a0 = 0;
    80001e8c:	0589b783          	ld	a5,88(s3)
    80001e90:	0607b823          	sd	zero,112(a5)
    80001e94:	0d000493          	li	s1,208
  for(i = 0; i < NOFILE; i++)
    80001e98:	15000a13          	li	s4,336
    80001e9c:	a03d                	j	80001eca <fork+0xb2>
    freeproc(np);
    80001e9e:	854e                	mv	a0,s3
    80001ea0:	00000097          	auipc	ra,0x0
    80001ea4:	d5c080e7          	jalr	-676(ra) # 80001bfc <freeproc>
    release(&np->lock);
    80001ea8:	854e                	mv	a0,s3
    80001eaa:	fffff097          	auipc	ra,0xfffff
    80001eae:	de0080e7          	jalr	-544(ra) # 80000c8a <release>
    return -1;
    80001eb2:	5a7d                	li	s4,-1
    80001eb4:	a069                	j	80001f3e <fork+0x126>
      np->ofile[i] = filedup(p->ofile[i]);
    80001eb6:	00002097          	auipc	ra,0x2
    80001eba:	624080e7          	jalr	1572(ra) # 800044da <filedup>
    80001ebe:	009987b3          	add	a5,s3,s1
    80001ec2:	e388                	sd	a0,0(a5)
  for(i = 0; i < NOFILE; i++)
    80001ec4:	04a1                	addi	s1,s1,8
    80001ec6:	01448763          	beq	s1,s4,80001ed4 <fork+0xbc>
    if(p->ofile[i])
    80001eca:	009907b3          	add	a5,s2,s1
    80001ece:	6388                	ld	a0,0(a5)
    80001ed0:	f17d                	bnez	a0,80001eb6 <fork+0x9e>
    80001ed2:	bfcd                	j	80001ec4 <fork+0xac>
  np->cwd = idup(p->cwd);
    80001ed4:	15093503          	ld	a0,336(s2)
    80001ed8:	00001097          	auipc	ra,0x1
    80001edc:	778080e7          	jalr	1912(ra) # 80003650 <idup>
    80001ee0:	14a9b823          	sd	a0,336(s3)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001ee4:	4641                	li	a2,16
    80001ee6:	15890593          	addi	a1,s2,344
    80001eea:	15898513          	addi	a0,s3,344
    80001eee:	fffff097          	auipc	ra,0xfffff
    80001ef2:	f3a080e7          	jalr	-198(ra) # 80000e28 <safestrcpy>
  pid = np->pid;
    80001ef6:	0309aa03          	lw	s4,48(s3)
  release(&np->lock);
    80001efa:	854e                	mv	a0,s3
    80001efc:	fffff097          	auipc	ra,0xfffff
    80001f00:	d8e080e7          	jalr	-626(ra) # 80000c8a <release>
  acquire(&wait_lock);
    80001f04:	0000f497          	auipc	s1,0xf
    80001f08:	3b448493          	addi	s1,s1,948 # 800112b8 <wait_lock>
    80001f0c:	8526                	mv	a0,s1
    80001f0e:	fffff097          	auipc	ra,0xfffff
    80001f12:	cc8080e7          	jalr	-824(ra) # 80000bd6 <acquire>
  np->parent = p;
    80001f16:	0329bc23          	sd	s2,56(s3)
  release(&wait_lock);
    80001f1a:	8526                	mv	a0,s1
    80001f1c:	fffff097          	auipc	ra,0xfffff
    80001f20:	d6e080e7          	jalr	-658(ra) # 80000c8a <release>
  acquire(&np->lock);
    80001f24:	854e                	mv	a0,s3
    80001f26:	fffff097          	auipc	ra,0xfffff
    80001f2a:	cb0080e7          	jalr	-848(ra) # 80000bd6 <acquire>
  np->state = RUNNABLE;
    80001f2e:	478d                	li	a5,3
    80001f30:	00f9ac23          	sw	a5,24(s3)
  release(&np->lock);
    80001f34:	854e                	mv	a0,s3
    80001f36:	fffff097          	auipc	ra,0xfffff
    80001f3a:	d54080e7          	jalr	-684(ra) # 80000c8a <release>
}
    80001f3e:	8552                	mv	a0,s4
    80001f40:	70a2                	ld	ra,40(sp)
    80001f42:	7402                	ld	s0,32(sp)
    80001f44:	64e2                	ld	s1,24(sp)
    80001f46:	6942                	ld	s2,16(sp)
    80001f48:	69a2                	ld	s3,8(sp)
    80001f4a:	6a02                	ld	s4,0(sp)
    80001f4c:	6145                	addi	sp,sp,48
    80001f4e:	8082                	ret
    return -1;
    80001f50:	5a7d                	li	s4,-1
    80001f52:	b7f5                	j	80001f3e <fork+0x126>

0000000080001f54 <scheduler>:
{
    80001f54:	7139                	addi	sp,sp,-64
    80001f56:	fc06                	sd	ra,56(sp)
    80001f58:	f822                	sd	s0,48(sp)
    80001f5a:	f426                	sd	s1,40(sp)
    80001f5c:	f04a                	sd	s2,32(sp)
    80001f5e:	ec4e                	sd	s3,24(sp)
    80001f60:	e852                	sd	s4,16(sp)
    80001f62:	e456                	sd	s5,8(sp)
    80001f64:	e05a                	sd	s6,0(sp)
    80001f66:	0080                	addi	s0,sp,64
    80001f68:	8792                	mv	a5,tp
  int id = r_tp();
    80001f6a:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001f6c:	00779a93          	slli	s5,a5,0x7
    80001f70:	0000f717          	auipc	a4,0xf
    80001f74:	33070713          	addi	a4,a4,816 # 800112a0 <pid_lock>
    80001f78:	9756                	add	a4,a4,s5
    80001f7a:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    80001f7e:	0000f717          	auipc	a4,0xf
    80001f82:	35a70713          	addi	a4,a4,858 # 800112d8 <cpus+0x8>
    80001f86:	9aba                	add	s5,s5,a4
      if(p->state == RUNNABLE) {
    80001f88:	498d                	li	s3,3
        p->state = RUNNING;
    80001f8a:	4b11                	li	s6,4
        c->proc = p;
    80001f8c:	079e                	slli	a5,a5,0x7
    80001f8e:	0000fa17          	auipc	s4,0xf
    80001f92:	312a0a13          	addi	s4,s4,786 # 800112a0 <pid_lock>
    80001f96:	9a3e                	add	s4,s4,a5
    for(p = proc; p < &proc[NPROC]; p++) {
    80001f98:	00015917          	auipc	s2,0x15
    80001f9c:	13890913          	addi	s2,s2,312 # 800170d0 <tickslock>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001fa0:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001fa4:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001fa8:	10079073          	csrw	sstatus,a5
    80001fac:	0000f497          	auipc	s1,0xf
    80001fb0:	72448493          	addi	s1,s1,1828 # 800116d0 <proc>
    80001fb4:	a03d                	j	80001fe2 <scheduler+0x8e>
        p->state = RUNNING;
    80001fb6:	0164ac23          	sw	s6,24(s1)
        c->proc = p;
    80001fba:	029a3823          	sd	s1,48(s4)
        swtch(&c->context, &p->context);
    80001fbe:	06048593          	addi	a1,s1,96
    80001fc2:	8556                	mv	a0,s5
    80001fc4:	00000097          	auipc	ra,0x0
    80001fc8:	640080e7          	jalr	1600(ra) # 80002604 <swtch>
        c->proc = 0;
    80001fcc:	020a3823          	sd	zero,48(s4)
      release(&p->lock);
    80001fd0:	8526                	mv	a0,s1
    80001fd2:	fffff097          	auipc	ra,0xfffff
    80001fd6:	cb8080e7          	jalr	-840(ra) # 80000c8a <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    80001fda:	16848493          	addi	s1,s1,360
    80001fde:	fd2481e3          	beq	s1,s2,80001fa0 <scheduler+0x4c>
      acquire(&p->lock);
    80001fe2:	8526                	mv	a0,s1
    80001fe4:	fffff097          	auipc	ra,0xfffff
    80001fe8:	bf2080e7          	jalr	-1038(ra) # 80000bd6 <acquire>
      if(p->state == RUNNABLE) {
    80001fec:	4c9c                	lw	a5,24(s1)
    80001fee:	ff3791e3          	bne	a5,s3,80001fd0 <scheduler+0x7c>
    80001ff2:	b7d1                	j	80001fb6 <scheduler+0x62>

0000000080001ff4 <sched>:
{
    80001ff4:	7179                	addi	sp,sp,-48
    80001ff6:	f406                	sd	ra,40(sp)
    80001ff8:	f022                	sd	s0,32(sp)
    80001ffa:	ec26                	sd	s1,24(sp)
    80001ffc:	e84a                	sd	s2,16(sp)
    80001ffe:	e44e                	sd	s3,8(sp)
    80002000:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80002002:	00000097          	auipc	ra,0x0
    80002006:	a48080e7          	jalr	-1464(ra) # 80001a4a <myproc>
    8000200a:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    8000200c:	fffff097          	auipc	ra,0xfffff
    80002010:	b50080e7          	jalr	-1200(ra) # 80000b5c <holding>
    80002014:	c93d                	beqz	a0,8000208a <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002016:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    80002018:	2781                	sext.w	a5,a5
    8000201a:	079e                	slli	a5,a5,0x7
    8000201c:	0000f717          	auipc	a4,0xf
    80002020:	28470713          	addi	a4,a4,644 # 800112a0 <pid_lock>
    80002024:	97ba                	add	a5,a5,a4
    80002026:	0a87a703          	lw	a4,168(a5)
    8000202a:	4785                	li	a5,1
    8000202c:	06f71763          	bne	a4,a5,8000209a <sched+0xa6>
  if(p->state == RUNNING)
    80002030:	4c98                	lw	a4,24(s1)
    80002032:	4791                	li	a5,4
    80002034:	06f70b63          	beq	a4,a5,800020aa <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002038:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    8000203c:	8b89                	andi	a5,a5,2
  if(intr_get())
    8000203e:	efb5                	bnez	a5,800020ba <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002040:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80002042:	0000f917          	auipc	s2,0xf
    80002046:	25e90913          	addi	s2,s2,606 # 800112a0 <pid_lock>
    8000204a:	2781                	sext.w	a5,a5
    8000204c:	079e                	slli	a5,a5,0x7
    8000204e:	97ca                	add	a5,a5,s2
    80002050:	0ac7a983          	lw	s3,172(a5)
    80002054:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80002056:	2781                	sext.w	a5,a5
    80002058:	079e                	slli	a5,a5,0x7
    8000205a:	0000f597          	auipc	a1,0xf
    8000205e:	27e58593          	addi	a1,a1,638 # 800112d8 <cpus+0x8>
    80002062:	95be                	add	a1,a1,a5
    80002064:	06048513          	addi	a0,s1,96
    80002068:	00000097          	auipc	ra,0x0
    8000206c:	59c080e7          	jalr	1436(ra) # 80002604 <swtch>
    80002070:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80002072:	2781                	sext.w	a5,a5
    80002074:	079e                	slli	a5,a5,0x7
    80002076:	97ca                	add	a5,a5,s2
    80002078:	0b37a623          	sw	s3,172(a5)
}
    8000207c:	70a2                	ld	ra,40(sp)
    8000207e:	7402                	ld	s0,32(sp)
    80002080:	64e2                	ld	s1,24(sp)
    80002082:	6942                	ld	s2,16(sp)
    80002084:	69a2                	ld	s3,8(sp)
    80002086:	6145                	addi	sp,sp,48
    80002088:	8082                	ret
    panic("sched p->lock");
    8000208a:	00006517          	auipc	a0,0x6
    8000208e:	19650513          	addi	a0,a0,406 # 80008220 <digits+0x1e0>
    80002092:	ffffe097          	auipc	ra,0xffffe
    80002096:	49e080e7          	jalr	1182(ra) # 80000530 <panic>
    panic("sched locks");
    8000209a:	00006517          	auipc	a0,0x6
    8000209e:	19650513          	addi	a0,a0,406 # 80008230 <digits+0x1f0>
    800020a2:	ffffe097          	auipc	ra,0xffffe
    800020a6:	48e080e7          	jalr	1166(ra) # 80000530 <panic>
    panic("sched running");
    800020aa:	00006517          	auipc	a0,0x6
    800020ae:	19650513          	addi	a0,a0,406 # 80008240 <digits+0x200>
    800020b2:	ffffe097          	auipc	ra,0xffffe
    800020b6:	47e080e7          	jalr	1150(ra) # 80000530 <panic>
    panic("sched interruptible");
    800020ba:	00006517          	auipc	a0,0x6
    800020be:	19650513          	addi	a0,a0,406 # 80008250 <digits+0x210>
    800020c2:	ffffe097          	auipc	ra,0xffffe
    800020c6:	46e080e7          	jalr	1134(ra) # 80000530 <panic>

00000000800020ca <yield>:
{
    800020ca:	1101                	addi	sp,sp,-32
    800020cc:	ec06                	sd	ra,24(sp)
    800020ce:	e822                	sd	s0,16(sp)
    800020d0:	e426                	sd	s1,8(sp)
    800020d2:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    800020d4:	00000097          	auipc	ra,0x0
    800020d8:	976080e7          	jalr	-1674(ra) # 80001a4a <myproc>
    800020dc:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800020de:	fffff097          	auipc	ra,0xfffff
    800020e2:	af8080e7          	jalr	-1288(ra) # 80000bd6 <acquire>
  p->state = RUNNABLE;
    800020e6:	478d                	li	a5,3
    800020e8:	cc9c                	sw	a5,24(s1)
  sched();
    800020ea:	00000097          	auipc	ra,0x0
    800020ee:	f0a080e7          	jalr	-246(ra) # 80001ff4 <sched>
  release(&p->lock);
    800020f2:	8526                	mv	a0,s1
    800020f4:	fffff097          	auipc	ra,0xfffff
    800020f8:	b96080e7          	jalr	-1130(ra) # 80000c8a <release>
}
    800020fc:	60e2                	ld	ra,24(sp)
    800020fe:	6442                	ld	s0,16(sp)
    80002100:	64a2                	ld	s1,8(sp)
    80002102:	6105                	addi	sp,sp,32
    80002104:	8082                	ret

0000000080002106 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    80002106:	7179                	addi	sp,sp,-48
    80002108:	f406                	sd	ra,40(sp)
    8000210a:	f022                	sd	s0,32(sp)
    8000210c:	ec26                	sd	s1,24(sp)
    8000210e:	e84a                	sd	s2,16(sp)
    80002110:	e44e                	sd	s3,8(sp)
    80002112:	1800                	addi	s0,sp,48
    80002114:	89aa                	mv	s3,a0
    80002116:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002118:	00000097          	auipc	ra,0x0
    8000211c:	932080e7          	jalr	-1742(ra) # 80001a4a <myproc>
    80002120:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    80002122:	fffff097          	auipc	ra,0xfffff
    80002126:	ab4080e7          	jalr	-1356(ra) # 80000bd6 <acquire>
  release(lk);
    8000212a:	854a                	mv	a0,s2
    8000212c:	fffff097          	auipc	ra,0xfffff
    80002130:	b5e080e7          	jalr	-1186(ra) # 80000c8a <release>

  // Go to sleep.
  p->chan = chan;
    80002134:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    80002138:	4789                	li	a5,2
    8000213a:	cc9c                	sw	a5,24(s1)

  sched();
    8000213c:	00000097          	auipc	ra,0x0
    80002140:	eb8080e7          	jalr	-328(ra) # 80001ff4 <sched>

  // Tidy up.
  p->chan = 0;
    80002144:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    80002148:	8526                	mv	a0,s1
    8000214a:	fffff097          	auipc	ra,0xfffff
    8000214e:	b40080e7          	jalr	-1216(ra) # 80000c8a <release>
  acquire(lk);
    80002152:	854a                	mv	a0,s2
    80002154:	fffff097          	auipc	ra,0xfffff
    80002158:	a82080e7          	jalr	-1406(ra) # 80000bd6 <acquire>
}
    8000215c:	70a2                	ld	ra,40(sp)
    8000215e:	7402                	ld	s0,32(sp)
    80002160:	64e2                	ld	s1,24(sp)
    80002162:	6942                	ld	s2,16(sp)
    80002164:	69a2                	ld	s3,8(sp)
    80002166:	6145                	addi	sp,sp,48
    80002168:	8082                	ret

000000008000216a <wait>:
{
    8000216a:	715d                	addi	sp,sp,-80
    8000216c:	e486                	sd	ra,72(sp)
    8000216e:	e0a2                	sd	s0,64(sp)
    80002170:	fc26                	sd	s1,56(sp)
    80002172:	f84a                	sd	s2,48(sp)
    80002174:	f44e                	sd	s3,40(sp)
    80002176:	f052                	sd	s4,32(sp)
    80002178:	ec56                	sd	s5,24(sp)
    8000217a:	e85a                	sd	s6,16(sp)
    8000217c:	e45e                	sd	s7,8(sp)
    8000217e:	e062                	sd	s8,0(sp)
    80002180:	0880                	addi	s0,sp,80
    80002182:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    80002184:	00000097          	auipc	ra,0x0
    80002188:	8c6080e7          	jalr	-1850(ra) # 80001a4a <myproc>
    8000218c:	892a                	mv	s2,a0
  acquire(&wait_lock);
    8000218e:	0000f517          	auipc	a0,0xf
    80002192:	12a50513          	addi	a0,a0,298 # 800112b8 <wait_lock>
    80002196:	fffff097          	auipc	ra,0xfffff
    8000219a:	a40080e7          	jalr	-1472(ra) # 80000bd6 <acquire>
    havekids = 0;
    8000219e:	4b81                	li	s7,0
        if(np->state == ZOMBIE){
    800021a0:	4a15                	li	s4,5
    for(np = proc; np < &proc[NPROC]; np++){
    800021a2:	00015997          	auipc	s3,0x15
    800021a6:	f2e98993          	addi	s3,s3,-210 # 800170d0 <tickslock>
        havekids = 1;
    800021aa:	4a85                	li	s5,1
    sleep(p, &wait_lock);  //DOC: wait-sleep
    800021ac:	0000fc17          	auipc	s8,0xf
    800021b0:	10cc0c13          	addi	s8,s8,268 # 800112b8 <wait_lock>
    havekids = 0;
    800021b4:	875e                	mv	a4,s7
    for(np = proc; np < &proc[NPROC]; np++){
    800021b6:	0000f497          	auipc	s1,0xf
    800021ba:	51a48493          	addi	s1,s1,1306 # 800116d0 <proc>
    800021be:	a0bd                	j	8000222c <wait+0xc2>
          pid = np->pid;
    800021c0:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    800021c4:	000b0e63          	beqz	s6,800021e0 <wait+0x76>
    800021c8:	4691                	li	a3,4
    800021ca:	02c48613          	addi	a2,s1,44
    800021ce:	85da                	mv	a1,s6
    800021d0:	05093503          	ld	a0,80(s2)
    800021d4:	fffff097          	auipc	ra,0xfffff
    800021d8:	482080e7          	jalr	1154(ra) # 80001656 <copyout>
    800021dc:	02054563          	bltz	a0,80002206 <wait+0x9c>
          freeproc(np);
    800021e0:	8526                	mv	a0,s1
    800021e2:	00000097          	auipc	ra,0x0
    800021e6:	a1a080e7          	jalr	-1510(ra) # 80001bfc <freeproc>
          release(&np->lock);
    800021ea:	8526                	mv	a0,s1
    800021ec:	fffff097          	auipc	ra,0xfffff
    800021f0:	a9e080e7          	jalr	-1378(ra) # 80000c8a <release>
          release(&wait_lock);
    800021f4:	0000f517          	auipc	a0,0xf
    800021f8:	0c450513          	addi	a0,a0,196 # 800112b8 <wait_lock>
    800021fc:	fffff097          	auipc	ra,0xfffff
    80002200:	a8e080e7          	jalr	-1394(ra) # 80000c8a <release>
          return pid;
    80002204:	a09d                	j	8000226a <wait+0x100>
            release(&np->lock);
    80002206:	8526                	mv	a0,s1
    80002208:	fffff097          	auipc	ra,0xfffff
    8000220c:	a82080e7          	jalr	-1406(ra) # 80000c8a <release>
            release(&wait_lock);
    80002210:	0000f517          	auipc	a0,0xf
    80002214:	0a850513          	addi	a0,a0,168 # 800112b8 <wait_lock>
    80002218:	fffff097          	auipc	ra,0xfffff
    8000221c:	a72080e7          	jalr	-1422(ra) # 80000c8a <release>
            return -1;
    80002220:	59fd                	li	s3,-1
    80002222:	a0a1                	j	8000226a <wait+0x100>
    for(np = proc; np < &proc[NPROC]; np++){
    80002224:	16848493          	addi	s1,s1,360
    80002228:	03348463          	beq	s1,s3,80002250 <wait+0xe6>
      if(np->parent == p){
    8000222c:	7c9c                	ld	a5,56(s1)
    8000222e:	ff279be3          	bne	a5,s2,80002224 <wait+0xba>
        acquire(&np->lock);
    80002232:	8526                	mv	a0,s1
    80002234:	fffff097          	auipc	ra,0xfffff
    80002238:	9a2080e7          	jalr	-1630(ra) # 80000bd6 <acquire>
        if(np->state == ZOMBIE){
    8000223c:	4c9c                	lw	a5,24(s1)
    8000223e:	f94781e3          	beq	a5,s4,800021c0 <wait+0x56>
        release(&np->lock);
    80002242:	8526                	mv	a0,s1
    80002244:	fffff097          	auipc	ra,0xfffff
    80002248:	a46080e7          	jalr	-1466(ra) # 80000c8a <release>
        havekids = 1;
    8000224c:	8756                	mv	a4,s5
    8000224e:	bfd9                	j	80002224 <wait+0xba>
    if(!havekids || p->killed){
    80002250:	c701                	beqz	a4,80002258 <wait+0xee>
    80002252:	02892783          	lw	a5,40(s2)
    80002256:	c79d                	beqz	a5,80002284 <wait+0x11a>
      release(&wait_lock);
    80002258:	0000f517          	auipc	a0,0xf
    8000225c:	06050513          	addi	a0,a0,96 # 800112b8 <wait_lock>
    80002260:	fffff097          	auipc	ra,0xfffff
    80002264:	a2a080e7          	jalr	-1494(ra) # 80000c8a <release>
      return -1;
    80002268:	59fd                	li	s3,-1
}
    8000226a:	854e                	mv	a0,s3
    8000226c:	60a6                	ld	ra,72(sp)
    8000226e:	6406                	ld	s0,64(sp)
    80002270:	74e2                	ld	s1,56(sp)
    80002272:	7942                	ld	s2,48(sp)
    80002274:	79a2                	ld	s3,40(sp)
    80002276:	7a02                	ld	s4,32(sp)
    80002278:	6ae2                	ld	s5,24(sp)
    8000227a:	6b42                	ld	s6,16(sp)
    8000227c:	6ba2                	ld	s7,8(sp)
    8000227e:	6c02                	ld	s8,0(sp)
    80002280:	6161                	addi	sp,sp,80
    80002282:	8082                	ret
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002284:	85e2                	mv	a1,s8
    80002286:	854a                	mv	a0,s2
    80002288:	00000097          	auipc	ra,0x0
    8000228c:	e7e080e7          	jalr	-386(ra) # 80002106 <sleep>
    havekids = 0;
    80002290:	b715                	j	800021b4 <wait+0x4a>

0000000080002292 <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void
wakeup(void *chan)
{
    80002292:	7139                	addi	sp,sp,-64
    80002294:	fc06                	sd	ra,56(sp)
    80002296:	f822                	sd	s0,48(sp)
    80002298:	f426                	sd	s1,40(sp)
    8000229a:	f04a                	sd	s2,32(sp)
    8000229c:	ec4e                	sd	s3,24(sp)
    8000229e:	e852                	sd	s4,16(sp)
    800022a0:	e456                	sd	s5,8(sp)
    800022a2:	0080                	addi	s0,sp,64
    800022a4:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    800022a6:	0000f497          	auipc	s1,0xf
    800022aa:	42a48493          	addi	s1,s1,1066 # 800116d0 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    800022ae:	4989                	li	s3,2
        p->state = RUNNABLE;
    800022b0:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    800022b2:	00015917          	auipc	s2,0x15
    800022b6:	e1e90913          	addi	s2,s2,-482 # 800170d0 <tickslock>
    800022ba:	a821                	j	800022d2 <wakeup+0x40>
        p->state = RUNNABLE;
    800022bc:	0154ac23          	sw	s5,24(s1)
      }
      release(&p->lock);
    800022c0:	8526                	mv	a0,s1
    800022c2:	fffff097          	auipc	ra,0xfffff
    800022c6:	9c8080e7          	jalr	-1592(ra) # 80000c8a <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    800022ca:	16848493          	addi	s1,s1,360
    800022ce:	03248463          	beq	s1,s2,800022f6 <wakeup+0x64>
    if(p != myproc()){
    800022d2:	fffff097          	auipc	ra,0xfffff
    800022d6:	778080e7          	jalr	1912(ra) # 80001a4a <myproc>
    800022da:	fea488e3          	beq	s1,a0,800022ca <wakeup+0x38>
      acquire(&p->lock);
    800022de:	8526                	mv	a0,s1
    800022e0:	fffff097          	auipc	ra,0xfffff
    800022e4:	8f6080e7          	jalr	-1802(ra) # 80000bd6 <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    800022e8:	4c9c                	lw	a5,24(s1)
    800022ea:	fd379be3          	bne	a5,s3,800022c0 <wakeup+0x2e>
    800022ee:	709c                	ld	a5,32(s1)
    800022f0:	fd4798e3          	bne	a5,s4,800022c0 <wakeup+0x2e>
    800022f4:	b7e1                	j	800022bc <wakeup+0x2a>
    }
  }
}
    800022f6:	70e2                	ld	ra,56(sp)
    800022f8:	7442                	ld	s0,48(sp)
    800022fa:	74a2                	ld	s1,40(sp)
    800022fc:	7902                	ld	s2,32(sp)
    800022fe:	69e2                	ld	s3,24(sp)
    80002300:	6a42                	ld	s4,16(sp)
    80002302:	6aa2                	ld	s5,8(sp)
    80002304:	6121                	addi	sp,sp,64
    80002306:	8082                	ret

0000000080002308 <reparent>:
{
    80002308:	7179                	addi	sp,sp,-48
    8000230a:	f406                	sd	ra,40(sp)
    8000230c:	f022                	sd	s0,32(sp)
    8000230e:	ec26                	sd	s1,24(sp)
    80002310:	e84a                	sd	s2,16(sp)
    80002312:	e44e                	sd	s3,8(sp)
    80002314:	e052                	sd	s4,0(sp)
    80002316:	1800                	addi	s0,sp,48
    80002318:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    8000231a:	0000f497          	auipc	s1,0xf
    8000231e:	3b648493          	addi	s1,s1,950 # 800116d0 <proc>
      pp->parent = initproc;
    80002322:	00007a17          	auipc	s4,0x7
    80002326:	d06a0a13          	addi	s4,s4,-762 # 80009028 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    8000232a:	00015997          	auipc	s3,0x15
    8000232e:	da698993          	addi	s3,s3,-602 # 800170d0 <tickslock>
    80002332:	a029                	j	8000233c <reparent+0x34>
    80002334:	16848493          	addi	s1,s1,360
    80002338:	01348d63          	beq	s1,s3,80002352 <reparent+0x4a>
    if(pp->parent == p){
    8000233c:	7c9c                	ld	a5,56(s1)
    8000233e:	ff279be3          	bne	a5,s2,80002334 <reparent+0x2c>
      pp->parent = initproc;
    80002342:	000a3503          	ld	a0,0(s4)
    80002346:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    80002348:	00000097          	auipc	ra,0x0
    8000234c:	f4a080e7          	jalr	-182(ra) # 80002292 <wakeup>
    80002350:	b7d5                	j	80002334 <reparent+0x2c>
}
    80002352:	70a2                	ld	ra,40(sp)
    80002354:	7402                	ld	s0,32(sp)
    80002356:	64e2                	ld	s1,24(sp)
    80002358:	6942                	ld	s2,16(sp)
    8000235a:	69a2                	ld	s3,8(sp)
    8000235c:	6a02                	ld	s4,0(sp)
    8000235e:	6145                	addi	sp,sp,48
    80002360:	8082                	ret

0000000080002362 <exit>:
{
    80002362:	7179                	addi	sp,sp,-48
    80002364:	f406                	sd	ra,40(sp)
    80002366:	f022                	sd	s0,32(sp)
    80002368:	ec26                	sd	s1,24(sp)
    8000236a:	e84a                	sd	s2,16(sp)
    8000236c:	e44e                	sd	s3,8(sp)
    8000236e:	e052                	sd	s4,0(sp)
    80002370:	1800                	addi	s0,sp,48
    80002372:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    80002374:	fffff097          	auipc	ra,0xfffff
    80002378:	6d6080e7          	jalr	1750(ra) # 80001a4a <myproc>
    8000237c:	89aa                	mv	s3,a0
  if(p == initproc)
    8000237e:	00007797          	auipc	a5,0x7
    80002382:	caa7b783          	ld	a5,-854(a5) # 80009028 <initproc>
    80002386:	0d050493          	addi	s1,a0,208
    8000238a:	15050913          	addi	s2,a0,336
    8000238e:	02a79363          	bne	a5,a0,800023b4 <exit+0x52>
    panic("init exiting");
    80002392:	00006517          	auipc	a0,0x6
    80002396:	ed650513          	addi	a0,a0,-298 # 80008268 <digits+0x228>
    8000239a:	ffffe097          	auipc	ra,0xffffe
    8000239e:	196080e7          	jalr	406(ra) # 80000530 <panic>
      fileclose(f);
    800023a2:	00002097          	auipc	ra,0x2
    800023a6:	18a080e7          	jalr	394(ra) # 8000452c <fileclose>
      p->ofile[fd] = 0;
    800023aa:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    800023ae:	04a1                	addi	s1,s1,8
    800023b0:	01248563          	beq	s1,s2,800023ba <exit+0x58>
    if(p->ofile[fd]){
    800023b4:	6088                	ld	a0,0(s1)
    800023b6:	f575                	bnez	a0,800023a2 <exit+0x40>
    800023b8:	bfdd                	j	800023ae <exit+0x4c>
  begin_op();
    800023ba:	00002097          	auipc	ra,0x2
    800023be:	ca6080e7          	jalr	-858(ra) # 80004060 <begin_op>
  iput(p->cwd);
    800023c2:	1509b503          	ld	a0,336(s3)
    800023c6:	00001097          	auipc	ra,0x1
    800023ca:	482080e7          	jalr	1154(ra) # 80003848 <iput>
  end_op();
    800023ce:	00002097          	auipc	ra,0x2
    800023d2:	d12080e7          	jalr	-750(ra) # 800040e0 <end_op>
  p->cwd = 0;
    800023d6:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    800023da:	0000f497          	auipc	s1,0xf
    800023de:	ede48493          	addi	s1,s1,-290 # 800112b8 <wait_lock>
    800023e2:	8526                	mv	a0,s1
    800023e4:	ffffe097          	auipc	ra,0xffffe
    800023e8:	7f2080e7          	jalr	2034(ra) # 80000bd6 <acquire>
  reparent(p);
    800023ec:	854e                	mv	a0,s3
    800023ee:	00000097          	auipc	ra,0x0
    800023f2:	f1a080e7          	jalr	-230(ra) # 80002308 <reparent>
  wakeup(p->parent);
    800023f6:	0389b503          	ld	a0,56(s3)
    800023fa:	00000097          	auipc	ra,0x0
    800023fe:	e98080e7          	jalr	-360(ra) # 80002292 <wakeup>
  acquire(&p->lock);
    80002402:	854e                	mv	a0,s3
    80002404:	ffffe097          	auipc	ra,0xffffe
    80002408:	7d2080e7          	jalr	2002(ra) # 80000bd6 <acquire>
  p->xstate = status;
    8000240c:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    80002410:	4795                	li	a5,5
    80002412:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    80002416:	8526                	mv	a0,s1
    80002418:	fffff097          	auipc	ra,0xfffff
    8000241c:	872080e7          	jalr	-1934(ra) # 80000c8a <release>
  sched();
    80002420:	00000097          	auipc	ra,0x0
    80002424:	bd4080e7          	jalr	-1068(ra) # 80001ff4 <sched>
  panic("zombie exit");
    80002428:	00006517          	auipc	a0,0x6
    8000242c:	e5050513          	addi	a0,a0,-432 # 80008278 <digits+0x238>
    80002430:	ffffe097          	auipc	ra,0xffffe
    80002434:	100080e7          	jalr	256(ra) # 80000530 <panic>

0000000080002438 <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    80002438:	7179                	addi	sp,sp,-48
    8000243a:	f406                	sd	ra,40(sp)
    8000243c:	f022                	sd	s0,32(sp)
    8000243e:	ec26                	sd	s1,24(sp)
    80002440:	e84a                	sd	s2,16(sp)
    80002442:	e44e                	sd	s3,8(sp)
    80002444:	1800                	addi	s0,sp,48
    80002446:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    80002448:	0000f497          	auipc	s1,0xf
    8000244c:	28848493          	addi	s1,s1,648 # 800116d0 <proc>
    80002450:	00015997          	auipc	s3,0x15
    80002454:	c8098993          	addi	s3,s3,-896 # 800170d0 <tickslock>
    acquire(&p->lock);
    80002458:	8526                	mv	a0,s1
    8000245a:	ffffe097          	auipc	ra,0xffffe
    8000245e:	77c080e7          	jalr	1916(ra) # 80000bd6 <acquire>
    if(p->pid == pid){
    80002462:	589c                	lw	a5,48(s1)
    80002464:	01278d63          	beq	a5,s2,8000247e <kill+0x46>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    80002468:	8526                	mv	a0,s1
    8000246a:	fffff097          	auipc	ra,0xfffff
    8000246e:	820080e7          	jalr	-2016(ra) # 80000c8a <release>
  for(p = proc; p < &proc[NPROC]; p++){
    80002472:	16848493          	addi	s1,s1,360
    80002476:	ff3491e3          	bne	s1,s3,80002458 <kill+0x20>
  }
  return -1;
    8000247a:	557d                	li	a0,-1
    8000247c:	a829                	j	80002496 <kill+0x5e>
      p->killed = 1;
    8000247e:	4785                	li	a5,1
    80002480:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    80002482:	4c98                	lw	a4,24(s1)
    80002484:	4789                	li	a5,2
    80002486:	00f70f63          	beq	a4,a5,800024a4 <kill+0x6c>
      release(&p->lock);
    8000248a:	8526                	mv	a0,s1
    8000248c:	ffffe097          	auipc	ra,0xffffe
    80002490:	7fe080e7          	jalr	2046(ra) # 80000c8a <release>
      return 0;
    80002494:	4501                	li	a0,0
}
    80002496:	70a2                	ld	ra,40(sp)
    80002498:	7402                	ld	s0,32(sp)
    8000249a:	64e2                	ld	s1,24(sp)
    8000249c:	6942                	ld	s2,16(sp)
    8000249e:	69a2                	ld	s3,8(sp)
    800024a0:	6145                	addi	sp,sp,48
    800024a2:	8082                	ret
        p->state = RUNNABLE;
    800024a4:	478d                	li	a5,3
    800024a6:	cc9c                	sw	a5,24(s1)
    800024a8:	b7cd                	j	8000248a <kill+0x52>

00000000800024aa <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    800024aa:	7179                	addi	sp,sp,-48
    800024ac:	f406                	sd	ra,40(sp)
    800024ae:	f022                	sd	s0,32(sp)
    800024b0:	ec26                	sd	s1,24(sp)
    800024b2:	e84a                	sd	s2,16(sp)
    800024b4:	e44e                	sd	s3,8(sp)
    800024b6:	e052                	sd	s4,0(sp)
    800024b8:	1800                	addi	s0,sp,48
    800024ba:	84aa                	mv	s1,a0
    800024bc:	892e                	mv	s2,a1
    800024be:	89b2                	mv	s3,a2
    800024c0:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800024c2:	fffff097          	auipc	ra,0xfffff
    800024c6:	588080e7          	jalr	1416(ra) # 80001a4a <myproc>
  if(user_dst){
    800024ca:	c08d                	beqz	s1,800024ec <either_copyout+0x42>
    return copyout(p->pagetable, dst, src, len);
    800024cc:	86d2                	mv	a3,s4
    800024ce:	864e                	mv	a2,s3
    800024d0:	85ca                	mv	a1,s2
    800024d2:	6928                	ld	a0,80(a0)
    800024d4:	fffff097          	auipc	ra,0xfffff
    800024d8:	182080e7          	jalr	386(ra) # 80001656 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    800024dc:	70a2                	ld	ra,40(sp)
    800024de:	7402                	ld	s0,32(sp)
    800024e0:	64e2                	ld	s1,24(sp)
    800024e2:	6942                	ld	s2,16(sp)
    800024e4:	69a2                	ld	s3,8(sp)
    800024e6:	6a02                	ld	s4,0(sp)
    800024e8:	6145                	addi	sp,sp,48
    800024ea:	8082                	ret
    memmove((char *)dst, src, len);
    800024ec:	000a061b          	sext.w	a2,s4
    800024f0:	85ce                	mv	a1,s3
    800024f2:	854a                	mv	a0,s2
    800024f4:	fffff097          	auipc	ra,0xfffff
    800024f8:	83e080e7          	jalr	-1986(ra) # 80000d32 <memmove>
    return 0;
    800024fc:	8526                	mv	a0,s1
    800024fe:	bff9                	j	800024dc <either_copyout+0x32>

0000000080002500 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    80002500:	7179                	addi	sp,sp,-48
    80002502:	f406                	sd	ra,40(sp)
    80002504:	f022                	sd	s0,32(sp)
    80002506:	ec26                	sd	s1,24(sp)
    80002508:	e84a                	sd	s2,16(sp)
    8000250a:	e44e                	sd	s3,8(sp)
    8000250c:	e052                	sd	s4,0(sp)
    8000250e:	1800                	addi	s0,sp,48
    80002510:	892a                	mv	s2,a0
    80002512:	84ae                	mv	s1,a1
    80002514:	89b2                	mv	s3,a2
    80002516:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002518:	fffff097          	auipc	ra,0xfffff
    8000251c:	532080e7          	jalr	1330(ra) # 80001a4a <myproc>
  if(user_src){
    80002520:	c08d                	beqz	s1,80002542 <either_copyin+0x42>
    return copyin(p->pagetable, dst, src, len);
    80002522:	86d2                	mv	a3,s4
    80002524:	864e                	mv	a2,s3
    80002526:	85ca                	mv	a1,s2
    80002528:	6928                	ld	a0,80(a0)
    8000252a:	fffff097          	auipc	ra,0xfffff
    8000252e:	1b8080e7          	jalr	440(ra) # 800016e2 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    80002532:	70a2                	ld	ra,40(sp)
    80002534:	7402                	ld	s0,32(sp)
    80002536:	64e2                	ld	s1,24(sp)
    80002538:	6942                	ld	s2,16(sp)
    8000253a:	69a2                	ld	s3,8(sp)
    8000253c:	6a02                	ld	s4,0(sp)
    8000253e:	6145                	addi	sp,sp,48
    80002540:	8082                	ret
    memmove(dst, (char*)src, len);
    80002542:	000a061b          	sext.w	a2,s4
    80002546:	85ce                	mv	a1,s3
    80002548:	854a                	mv	a0,s2
    8000254a:	ffffe097          	auipc	ra,0xffffe
    8000254e:	7e8080e7          	jalr	2024(ra) # 80000d32 <memmove>
    return 0;
    80002552:	8526                	mv	a0,s1
    80002554:	bff9                	j	80002532 <either_copyin+0x32>

0000000080002556 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    80002556:	715d                	addi	sp,sp,-80
    80002558:	e486                	sd	ra,72(sp)
    8000255a:	e0a2                	sd	s0,64(sp)
    8000255c:	fc26                	sd	s1,56(sp)
    8000255e:	f84a                	sd	s2,48(sp)
    80002560:	f44e                	sd	s3,40(sp)
    80002562:	f052                	sd	s4,32(sp)
    80002564:	ec56                	sd	s5,24(sp)
    80002566:	e85a                	sd	s6,16(sp)
    80002568:	e45e                	sd	s7,8(sp)
    8000256a:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    8000256c:	00006517          	auipc	a0,0x6
    80002570:	b5c50513          	addi	a0,a0,-1188 # 800080c8 <digits+0x88>
    80002574:	ffffe097          	auipc	ra,0xffffe
    80002578:	006080e7          	jalr	6(ra) # 8000057a <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    8000257c:	0000f497          	auipc	s1,0xf
    80002580:	2ac48493          	addi	s1,s1,684 # 80011828 <proc+0x158>
    80002584:	00015917          	auipc	s2,0x15
    80002588:	ca490913          	addi	s2,s2,-860 # 80017228 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000258c:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    8000258e:	00006997          	auipc	s3,0x6
    80002592:	cfa98993          	addi	s3,s3,-774 # 80008288 <digits+0x248>
    printf("%d %s %s", p->pid, state, p->name);
    80002596:	00006a97          	auipc	s5,0x6
    8000259a:	cfaa8a93          	addi	s5,s5,-774 # 80008290 <digits+0x250>
    printf("\n");
    8000259e:	00006a17          	auipc	s4,0x6
    800025a2:	b2aa0a13          	addi	s4,s4,-1238 # 800080c8 <digits+0x88>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800025a6:	00006b97          	auipc	s7,0x6
    800025aa:	d22b8b93          	addi	s7,s7,-734 # 800082c8 <states.1708>
    800025ae:	a00d                	j	800025d0 <procdump+0x7a>
    printf("%d %s %s", p->pid, state, p->name);
    800025b0:	ed86a583          	lw	a1,-296(a3)
    800025b4:	8556                	mv	a0,s5
    800025b6:	ffffe097          	auipc	ra,0xffffe
    800025ba:	fc4080e7          	jalr	-60(ra) # 8000057a <printf>
    printf("\n");
    800025be:	8552                	mv	a0,s4
    800025c0:	ffffe097          	auipc	ra,0xffffe
    800025c4:	fba080e7          	jalr	-70(ra) # 8000057a <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800025c8:	16848493          	addi	s1,s1,360
    800025cc:	03248163          	beq	s1,s2,800025ee <procdump+0x98>
    if(p->state == UNUSED)
    800025d0:	86a6                	mv	a3,s1
    800025d2:	ec04a783          	lw	a5,-320(s1)
    800025d6:	dbed                	beqz	a5,800025c8 <procdump+0x72>
      state = "???";
    800025d8:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800025da:	fcfb6be3          	bltu	s6,a5,800025b0 <procdump+0x5a>
    800025de:	1782                	slli	a5,a5,0x20
    800025e0:	9381                	srli	a5,a5,0x20
    800025e2:	078e                	slli	a5,a5,0x3
    800025e4:	97de                	add	a5,a5,s7
    800025e6:	6390                	ld	a2,0(a5)
    800025e8:	f661                	bnez	a2,800025b0 <procdump+0x5a>
      state = "???";
    800025ea:	864e                	mv	a2,s3
    800025ec:	b7d1                	j	800025b0 <procdump+0x5a>
  }
}
    800025ee:	60a6                	ld	ra,72(sp)
    800025f0:	6406                	ld	s0,64(sp)
    800025f2:	74e2                	ld	s1,56(sp)
    800025f4:	7942                	ld	s2,48(sp)
    800025f6:	79a2                	ld	s3,40(sp)
    800025f8:	7a02                	ld	s4,32(sp)
    800025fa:	6ae2                	ld	s5,24(sp)
    800025fc:	6b42                	ld	s6,16(sp)
    800025fe:	6ba2                	ld	s7,8(sp)
    80002600:	6161                	addi	sp,sp,80
    80002602:	8082                	ret

0000000080002604 <swtch>:
    80002604:	00153023          	sd	ra,0(a0)
    80002608:	00253423          	sd	sp,8(a0)
    8000260c:	e900                	sd	s0,16(a0)
    8000260e:	ed04                	sd	s1,24(a0)
    80002610:	03253023          	sd	s2,32(a0)
    80002614:	03353423          	sd	s3,40(a0)
    80002618:	03453823          	sd	s4,48(a0)
    8000261c:	03553c23          	sd	s5,56(a0)
    80002620:	05653023          	sd	s6,64(a0)
    80002624:	05753423          	sd	s7,72(a0)
    80002628:	05853823          	sd	s8,80(a0)
    8000262c:	05953c23          	sd	s9,88(a0)
    80002630:	07a53023          	sd	s10,96(a0)
    80002634:	07b53423          	sd	s11,104(a0)
    80002638:	0005b083          	ld	ra,0(a1)
    8000263c:	0085b103          	ld	sp,8(a1)
    80002640:	6980                	ld	s0,16(a1)
    80002642:	6d84                	ld	s1,24(a1)
    80002644:	0205b903          	ld	s2,32(a1)
    80002648:	0285b983          	ld	s3,40(a1)
    8000264c:	0305ba03          	ld	s4,48(a1)
    80002650:	0385ba83          	ld	s5,56(a1)
    80002654:	0405bb03          	ld	s6,64(a1)
    80002658:	0485bb83          	ld	s7,72(a1)
    8000265c:	0505bc03          	ld	s8,80(a1)
    80002660:	0585bc83          	ld	s9,88(a1)
    80002664:	0605bd03          	ld	s10,96(a1)
    80002668:	0685bd83          	ld	s11,104(a1)
    8000266c:	8082                	ret

000000008000266e <trapinit>:

extern int devintr();

void
trapinit(void)
{
    8000266e:	1141                	addi	sp,sp,-16
    80002670:	e406                	sd	ra,8(sp)
    80002672:	e022                	sd	s0,0(sp)
    80002674:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002676:	00006597          	auipc	a1,0x6
    8000267a:	c8258593          	addi	a1,a1,-894 # 800082f8 <states.1708+0x30>
    8000267e:	00015517          	auipc	a0,0x15
    80002682:	a5250513          	addi	a0,a0,-1454 # 800170d0 <tickslock>
    80002686:	ffffe097          	auipc	ra,0xffffe
    8000268a:	4c0080e7          	jalr	1216(ra) # 80000b46 <initlock>
}
    8000268e:	60a2                	ld	ra,8(sp)
    80002690:	6402                	ld	s0,0(sp)
    80002692:	0141                	addi	sp,sp,16
    80002694:	8082                	ret

0000000080002696 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80002696:	1141                	addi	sp,sp,-16
    80002698:	e422                	sd	s0,8(sp)
    8000269a:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    8000269c:	00003797          	auipc	a5,0x3
    800026a0:	4a478793          	addi	a5,a5,1188 # 80005b40 <kernelvec>
    800026a4:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    800026a8:	6422                	ld	s0,8(sp)
    800026aa:	0141                	addi	sp,sp,16
    800026ac:	8082                	ret

00000000800026ae <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    800026ae:	1141                	addi	sp,sp,-16
    800026b0:	e406                	sd	ra,8(sp)
    800026b2:	e022                	sd	s0,0(sp)
    800026b4:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    800026b6:	fffff097          	auipc	ra,0xfffff
    800026ba:	394080e7          	jalr	916(ra) # 80001a4a <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800026be:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    800026c2:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800026c4:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to trampoline.S
  w_stvec(TRAMPOLINE + (uservec - trampoline));
    800026c8:	00005617          	auipc	a2,0x5
    800026cc:	93860613          	addi	a2,a2,-1736 # 80007000 <_trampoline>
    800026d0:	00005697          	auipc	a3,0x5
    800026d4:	93068693          	addi	a3,a3,-1744 # 80007000 <_trampoline>
    800026d8:	8e91                	sub	a3,a3,a2
    800026da:	040007b7          	lui	a5,0x4000
    800026de:	17fd                	addi	a5,a5,-1
    800026e0:	07b2                	slli	a5,a5,0xc
    800026e2:	96be                	add	a3,a3,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    800026e4:	10569073          	csrw	stvec,a3

  // set up trapframe values that uservec will need when
  // the process next re-enters the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    800026e8:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    800026ea:	180026f3          	csrr	a3,satp
    800026ee:	e314                	sd	a3,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    800026f0:	6d38                	ld	a4,88(a0)
    800026f2:	6134                	ld	a3,64(a0)
    800026f4:	6585                	lui	a1,0x1
    800026f6:	96ae                	add	a3,a3,a1
    800026f8:	e714                	sd	a3,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    800026fa:	6d38                	ld	a4,88(a0)
    800026fc:	00000697          	auipc	a3,0x0
    80002700:	13868693          	addi	a3,a3,312 # 80002834 <usertrap>
    80002704:	eb14                	sd	a3,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    80002706:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80002708:	8692                	mv	a3,tp
    8000270a:	f314                	sd	a3,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000270c:	100026f3          	csrr	a3,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002710:	eff6f693          	andi	a3,a3,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002714:	0206e693          	ori	a3,a3,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002718:	10069073          	csrw	sstatus,a3
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    8000271c:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    8000271e:	6f18                	ld	a4,24(a4)
    80002720:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    80002724:	692c                	ld	a1,80(a0)
    80002726:	81b1                	srli	a1,a1,0xc

  // jump to trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 fn = TRAMPOLINE + (userret - trampoline);
    80002728:	00005717          	auipc	a4,0x5
    8000272c:	96870713          	addi	a4,a4,-1688 # 80007090 <userret>
    80002730:	8f11                	sub	a4,a4,a2
    80002732:	97ba                	add	a5,a5,a4
  ((void (*)(uint64,uint64))fn)(TRAPFRAME, satp);
    80002734:	577d                	li	a4,-1
    80002736:	177e                	slli	a4,a4,0x3f
    80002738:	8dd9                	or	a1,a1,a4
    8000273a:	02000537          	lui	a0,0x2000
    8000273e:	157d                	addi	a0,a0,-1
    80002740:	0536                	slli	a0,a0,0xd
    80002742:	9782                	jalr	a5
}
    80002744:	60a2                	ld	ra,8(sp)
    80002746:	6402                	ld	s0,0(sp)
    80002748:	0141                	addi	sp,sp,16
    8000274a:	8082                	ret

000000008000274c <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    8000274c:	1101                	addi	sp,sp,-32
    8000274e:	ec06                	sd	ra,24(sp)
    80002750:	e822                	sd	s0,16(sp)
    80002752:	e426                	sd	s1,8(sp)
    80002754:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    80002756:	00015497          	auipc	s1,0x15
    8000275a:	97a48493          	addi	s1,s1,-1670 # 800170d0 <tickslock>
    8000275e:	8526                	mv	a0,s1
    80002760:	ffffe097          	auipc	ra,0xffffe
    80002764:	476080e7          	jalr	1142(ra) # 80000bd6 <acquire>
  ticks++;
    80002768:	00007517          	auipc	a0,0x7
    8000276c:	8c850513          	addi	a0,a0,-1848 # 80009030 <ticks>
    80002770:	411c                	lw	a5,0(a0)
    80002772:	2785                	addiw	a5,a5,1
    80002774:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    80002776:	00000097          	auipc	ra,0x0
    8000277a:	b1c080e7          	jalr	-1252(ra) # 80002292 <wakeup>
  release(&tickslock);
    8000277e:	8526                	mv	a0,s1
    80002780:	ffffe097          	auipc	ra,0xffffe
    80002784:	50a080e7          	jalr	1290(ra) # 80000c8a <release>
}
    80002788:	60e2                	ld	ra,24(sp)
    8000278a:	6442                	ld	s0,16(sp)
    8000278c:	64a2                	ld	s1,8(sp)
    8000278e:	6105                	addi	sp,sp,32
    80002790:	8082                	ret

0000000080002792 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    80002792:	1101                	addi	sp,sp,-32
    80002794:	ec06                	sd	ra,24(sp)
    80002796:	e822                	sd	s0,16(sp)
    80002798:	e426                	sd	s1,8(sp)
    8000279a:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    8000279c:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if((scause & 0x8000000000000000L) &&
    800027a0:	00074d63          	bltz	a4,800027ba <devintr+0x28>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000001L){
    800027a4:	57fd                	li	a5,-1
    800027a6:	17fe                	slli	a5,a5,0x3f
    800027a8:	0785                	addi	a5,a5,1
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    800027aa:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    800027ac:	06f70363          	beq	a4,a5,80002812 <devintr+0x80>
  }
}
    800027b0:	60e2                	ld	ra,24(sp)
    800027b2:	6442                	ld	s0,16(sp)
    800027b4:	64a2                	ld	s1,8(sp)
    800027b6:	6105                	addi	sp,sp,32
    800027b8:	8082                	ret
     (scause & 0xff) == 9){
    800027ba:	0ff77793          	andi	a5,a4,255
  if((scause & 0x8000000000000000L) &&
    800027be:	46a5                	li	a3,9
    800027c0:	fed792e3          	bne	a5,a3,800027a4 <devintr+0x12>
    int irq = plic_claim();
    800027c4:	00003097          	auipc	ra,0x3
    800027c8:	484080e7          	jalr	1156(ra) # 80005c48 <plic_claim>
    800027cc:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    800027ce:	47a9                	li	a5,10
    800027d0:	02f50763          	beq	a0,a5,800027fe <devintr+0x6c>
    } else if(irq == VIRTIO0_IRQ){
    800027d4:	4785                	li	a5,1
    800027d6:	02f50963          	beq	a0,a5,80002808 <devintr+0x76>
    return 1;
    800027da:	4505                	li	a0,1
    } else if(irq){
    800027dc:	d8f1                	beqz	s1,800027b0 <devintr+0x1e>
      printf("unexpected interrupt irq=%d\n", irq);
    800027de:	85a6                	mv	a1,s1
    800027e0:	00006517          	auipc	a0,0x6
    800027e4:	b2050513          	addi	a0,a0,-1248 # 80008300 <states.1708+0x38>
    800027e8:	ffffe097          	auipc	ra,0xffffe
    800027ec:	d92080e7          	jalr	-622(ra) # 8000057a <printf>
      plic_complete(irq);
    800027f0:	8526                	mv	a0,s1
    800027f2:	00003097          	auipc	ra,0x3
    800027f6:	47a080e7          	jalr	1146(ra) # 80005c6c <plic_complete>
    return 1;
    800027fa:	4505                	li	a0,1
    800027fc:	bf55                	j	800027b0 <devintr+0x1e>
      uartintr();
    800027fe:	ffffe097          	auipc	ra,0xffffe
    80002802:	19c080e7          	jalr	412(ra) # 8000099a <uartintr>
    80002806:	b7ed                	j	800027f0 <devintr+0x5e>
      virtio_disk_intr();
    80002808:	00004097          	auipc	ra,0x4
    8000280c:	944080e7          	jalr	-1724(ra) # 8000614c <virtio_disk_intr>
    80002810:	b7c5                	j	800027f0 <devintr+0x5e>
    if(cpuid() == 0){
    80002812:	fffff097          	auipc	ra,0xfffff
    80002816:	20c080e7          	jalr	524(ra) # 80001a1e <cpuid>
    8000281a:	c901                	beqz	a0,8000282a <devintr+0x98>
  asm volatile("csrr %0, sip" : "=r" (x) );
    8000281c:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    80002820:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    80002822:	14479073          	csrw	sip,a5
    return 2;
    80002826:	4509                	li	a0,2
    80002828:	b761                	j	800027b0 <devintr+0x1e>
      clockintr();
    8000282a:	00000097          	auipc	ra,0x0
    8000282e:	f22080e7          	jalr	-222(ra) # 8000274c <clockintr>
    80002832:	b7ed                	j	8000281c <devintr+0x8a>

0000000080002834 <usertrap>:
{
    80002834:	1101                	addi	sp,sp,-32
    80002836:	ec06                	sd	ra,24(sp)
    80002838:	e822                	sd	s0,16(sp)
    8000283a:	e426                	sd	s1,8(sp)
    8000283c:	e04a                	sd	s2,0(sp)
    8000283e:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002840:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80002844:	1007f793          	andi	a5,a5,256
    80002848:	e3ad                	bnez	a5,800028aa <usertrap+0x76>
  asm volatile("csrw stvec, %0" : : "r" (x));
    8000284a:	00003797          	auipc	a5,0x3
    8000284e:	2f678793          	addi	a5,a5,758 # 80005b40 <kernelvec>
    80002852:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002856:	fffff097          	auipc	ra,0xfffff
    8000285a:	1f4080e7          	jalr	500(ra) # 80001a4a <myproc>
    8000285e:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002860:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002862:	14102773          	csrr	a4,sepc
    80002866:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002868:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    8000286c:	47a1                	li	a5,8
    8000286e:	04f71c63          	bne	a4,a5,800028c6 <usertrap+0x92>
    if(p->killed)
    80002872:	551c                	lw	a5,40(a0)
    80002874:	e3b9                	bnez	a5,800028ba <usertrap+0x86>
    p->trapframe->epc += 4;
    80002876:	6cb8                	ld	a4,88(s1)
    80002878:	6f1c                	ld	a5,24(a4)
    8000287a:	0791                	addi	a5,a5,4
    8000287c:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000287e:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002882:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002886:	10079073          	csrw	sstatus,a5
    syscall();
    8000288a:	00000097          	auipc	ra,0x0
    8000288e:	2e0080e7          	jalr	736(ra) # 80002b6a <syscall>
  if(p->killed)
    80002892:	549c                	lw	a5,40(s1)
    80002894:	ebc1                	bnez	a5,80002924 <usertrap+0xf0>
  usertrapret();
    80002896:	00000097          	auipc	ra,0x0
    8000289a:	e18080e7          	jalr	-488(ra) # 800026ae <usertrapret>
}
    8000289e:	60e2                	ld	ra,24(sp)
    800028a0:	6442                	ld	s0,16(sp)
    800028a2:	64a2                	ld	s1,8(sp)
    800028a4:	6902                	ld	s2,0(sp)
    800028a6:	6105                	addi	sp,sp,32
    800028a8:	8082                	ret
    panic("usertrap: not from user mode");
    800028aa:	00006517          	auipc	a0,0x6
    800028ae:	a7650513          	addi	a0,a0,-1418 # 80008320 <states.1708+0x58>
    800028b2:	ffffe097          	auipc	ra,0xffffe
    800028b6:	c7e080e7          	jalr	-898(ra) # 80000530 <panic>
      exit(-1);
    800028ba:	557d                	li	a0,-1
    800028bc:	00000097          	auipc	ra,0x0
    800028c0:	aa6080e7          	jalr	-1370(ra) # 80002362 <exit>
    800028c4:	bf4d                	j	80002876 <usertrap+0x42>
  } else if((which_dev = devintr()) != 0){
    800028c6:	00000097          	auipc	ra,0x0
    800028ca:	ecc080e7          	jalr	-308(ra) # 80002792 <devintr>
    800028ce:	892a                	mv	s2,a0
    800028d0:	c501                	beqz	a0,800028d8 <usertrap+0xa4>
  if(p->killed)
    800028d2:	549c                	lw	a5,40(s1)
    800028d4:	c3a1                	beqz	a5,80002914 <usertrap+0xe0>
    800028d6:	a815                	j	8000290a <usertrap+0xd6>
  asm volatile("csrr %0, scause" : "=r" (x) );
    800028d8:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    800028dc:	5890                	lw	a2,48(s1)
    800028de:	00006517          	auipc	a0,0x6
    800028e2:	a6250513          	addi	a0,a0,-1438 # 80008340 <states.1708+0x78>
    800028e6:	ffffe097          	auipc	ra,0xffffe
    800028ea:	c94080e7          	jalr	-876(ra) # 8000057a <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800028ee:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    800028f2:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    800028f6:	00006517          	auipc	a0,0x6
    800028fa:	a7a50513          	addi	a0,a0,-1414 # 80008370 <states.1708+0xa8>
    800028fe:	ffffe097          	auipc	ra,0xffffe
    80002902:	c7c080e7          	jalr	-900(ra) # 8000057a <printf>
    p->killed = 1;
    80002906:	4785                	li	a5,1
    80002908:	d49c                	sw	a5,40(s1)
    exit(-1);
    8000290a:	557d                	li	a0,-1
    8000290c:	00000097          	auipc	ra,0x0
    80002910:	a56080e7          	jalr	-1450(ra) # 80002362 <exit>
  if(which_dev == 2)
    80002914:	4789                	li	a5,2
    80002916:	f8f910e3          	bne	s2,a5,80002896 <usertrap+0x62>
    yield();
    8000291a:	fffff097          	auipc	ra,0xfffff
    8000291e:	7b0080e7          	jalr	1968(ra) # 800020ca <yield>
    80002922:	bf95                	j	80002896 <usertrap+0x62>
  int which_dev = 0;
    80002924:	4901                	li	s2,0
    80002926:	b7d5                	j	8000290a <usertrap+0xd6>

0000000080002928 <kerneltrap>:
{
    80002928:	7179                	addi	sp,sp,-48
    8000292a:	f406                	sd	ra,40(sp)
    8000292c:	f022                	sd	s0,32(sp)
    8000292e:	ec26                	sd	s1,24(sp)
    80002930:	e84a                	sd	s2,16(sp)
    80002932:	e44e                	sd	s3,8(sp)
    80002934:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002936:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000293a:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    8000293e:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80002942:	1004f793          	andi	a5,s1,256
    80002946:	cb85                	beqz	a5,80002976 <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002948:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    8000294c:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    8000294e:	ef85                	bnez	a5,80002986 <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    80002950:	00000097          	auipc	ra,0x0
    80002954:	e42080e7          	jalr	-446(ra) # 80002792 <devintr>
    80002958:	cd1d                	beqz	a0,80002996 <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    8000295a:	4789                	li	a5,2
    8000295c:	06f50a63          	beq	a0,a5,800029d0 <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002960:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002964:	10049073          	csrw	sstatus,s1
}
    80002968:	70a2                	ld	ra,40(sp)
    8000296a:	7402                	ld	s0,32(sp)
    8000296c:	64e2                	ld	s1,24(sp)
    8000296e:	6942                	ld	s2,16(sp)
    80002970:	69a2                	ld	s3,8(sp)
    80002972:	6145                	addi	sp,sp,48
    80002974:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002976:	00006517          	auipc	a0,0x6
    8000297a:	a1a50513          	addi	a0,a0,-1510 # 80008390 <states.1708+0xc8>
    8000297e:	ffffe097          	auipc	ra,0xffffe
    80002982:	bb2080e7          	jalr	-1102(ra) # 80000530 <panic>
    panic("kerneltrap: interrupts enabled");
    80002986:	00006517          	auipc	a0,0x6
    8000298a:	a3250513          	addi	a0,a0,-1486 # 800083b8 <states.1708+0xf0>
    8000298e:	ffffe097          	auipc	ra,0xffffe
    80002992:	ba2080e7          	jalr	-1118(ra) # 80000530 <panic>
    printf("scause %p\n", scause);
    80002996:	85ce                	mv	a1,s3
    80002998:	00006517          	auipc	a0,0x6
    8000299c:	a4050513          	addi	a0,a0,-1472 # 800083d8 <states.1708+0x110>
    800029a0:	ffffe097          	auipc	ra,0xffffe
    800029a4:	bda080e7          	jalr	-1062(ra) # 8000057a <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800029a8:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    800029ac:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    800029b0:	00006517          	auipc	a0,0x6
    800029b4:	a3850513          	addi	a0,a0,-1480 # 800083e8 <states.1708+0x120>
    800029b8:	ffffe097          	auipc	ra,0xffffe
    800029bc:	bc2080e7          	jalr	-1086(ra) # 8000057a <printf>
    panic("kerneltrap");
    800029c0:	00006517          	auipc	a0,0x6
    800029c4:	a4050513          	addi	a0,a0,-1472 # 80008400 <states.1708+0x138>
    800029c8:	ffffe097          	auipc	ra,0xffffe
    800029cc:	b68080e7          	jalr	-1176(ra) # 80000530 <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    800029d0:	fffff097          	auipc	ra,0xfffff
    800029d4:	07a080e7          	jalr	122(ra) # 80001a4a <myproc>
    800029d8:	d541                	beqz	a0,80002960 <kerneltrap+0x38>
    800029da:	fffff097          	auipc	ra,0xfffff
    800029de:	070080e7          	jalr	112(ra) # 80001a4a <myproc>
    800029e2:	4d18                	lw	a4,24(a0)
    800029e4:	4791                	li	a5,4
    800029e6:	f6f71de3          	bne	a4,a5,80002960 <kerneltrap+0x38>
    yield();
    800029ea:	fffff097          	auipc	ra,0xfffff
    800029ee:	6e0080e7          	jalr	1760(ra) # 800020ca <yield>
    800029f2:	b7bd                	j	80002960 <kerneltrap+0x38>

00000000800029f4 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    800029f4:	1101                	addi	sp,sp,-32
    800029f6:	ec06                	sd	ra,24(sp)
    800029f8:	e822                	sd	s0,16(sp)
    800029fa:	e426                	sd	s1,8(sp)
    800029fc:	1000                	addi	s0,sp,32
    800029fe:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002a00:	fffff097          	auipc	ra,0xfffff
    80002a04:	04a080e7          	jalr	74(ra) # 80001a4a <myproc>
  switch (n) {
    80002a08:	4795                	li	a5,5
    80002a0a:	0497e163          	bltu	a5,s1,80002a4c <argraw+0x58>
    80002a0e:	048a                	slli	s1,s1,0x2
    80002a10:	00006717          	auipc	a4,0x6
    80002a14:	a2870713          	addi	a4,a4,-1496 # 80008438 <states.1708+0x170>
    80002a18:	94ba                	add	s1,s1,a4
    80002a1a:	409c                	lw	a5,0(s1)
    80002a1c:	97ba                	add	a5,a5,a4
    80002a1e:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002a20:	6d3c                	ld	a5,88(a0)
    80002a22:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002a24:	60e2                	ld	ra,24(sp)
    80002a26:	6442                	ld	s0,16(sp)
    80002a28:	64a2                	ld	s1,8(sp)
    80002a2a:	6105                	addi	sp,sp,32
    80002a2c:	8082                	ret
    return p->trapframe->a1;
    80002a2e:	6d3c                	ld	a5,88(a0)
    80002a30:	7fa8                	ld	a0,120(a5)
    80002a32:	bfcd                	j	80002a24 <argraw+0x30>
    return p->trapframe->a2;
    80002a34:	6d3c                	ld	a5,88(a0)
    80002a36:	63c8                	ld	a0,128(a5)
    80002a38:	b7f5                	j	80002a24 <argraw+0x30>
    return p->trapframe->a3;
    80002a3a:	6d3c                	ld	a5,88(a0)
    80002a3c:	67c8                	ld	a0,136(a5)
    80002a3e:	b7dd                	j	80002a24 <argraw+0x30>
    return p->trapframe->a4;
    80002a40:	6d3c                	ld	a5,88(a0)
    80002a42:	6bc8                	ld	a0,144(a5)
    80002a44:	b7c5                	j	80002a24 <argraw+0x30>
    return p->trapframe->a5;
    80002a46:	6d3c                	ld	a5,88(a0)
    80002a48:	6fc8                	ld	a0,152(a5)
    80002a4a:	bfe9                	j	80002a24 <argraw+0x30>
  panic("argraw");
    80002a4c:	00006517          	auipc	a0,0x6
    80002a50:	9c450513          	addi	a0,a0,-1596 # 80008410 <states.1708+0x148>
    80002a54:	ffffe097          	auipc	ra,0xffffe
    80002a58:	adc080e7          	jalr	-1316(ra) # 80000530 <panic>

0000000080002a5c <fetchaddr>:
{
    80002a5c:	1101                	addi	sp,sp,-32
    80002a5e:	ec06                	sd	ra,24(sp)
    80002a60:	e822                	sd	s0,16(sp)
    80002a62:	e426                	sd	s1,8(sp)
    80002a64:	e04a                	sd	s2,0(sp)
    80002a66:	1000                	addi	s0,sp,32
    80002a68:	84aa                	mv	s1,a0
    80002a6a:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002a6c:	fffff097          	auipc	ra,0xfffff
    80002a70:	fde080e7          	jalr	-34(ra) # 80001a4a <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz)
    80002a74:	653c                	ld	a5,72(a0)
    80002a76:	02f4f863          	bgeu	s1,a5,80002aa6 <fetchaddr+0x4a>
    80002a7a:	00848713          	addi	a4,s1,8
    80002a7e:	02e7e663          	bltu	a5,a4,80002aaa <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002a82:	46a1                	li	a3,8
    80002a84:	8626                	mv	a2,s1
    80002a86:	85ca                	mv	a1,s2
    80002a88:	6928                	ld	a0,80(a0)
    80002a8a:	fffff097          	auipc	ra,0xfffff
    80002a8e:	c58080e7          	jalr	-936(ra) # 800016e2 <copyin>
    80002a92:	00a03533          	snez	a0,a0
    80002a96:	40a00533          	neg	a0,a0
}
    80002a9a:	60e2                	ld	ra,24(sp)
    80002a9c:	6442                	ld	s0,16(sp)
    80002a9e:	64a2                	ld	s1,8(sp)
    80002aa0:	6902                	ld	s2,0(sp)
    80002aa2:	6105                	addi	sp,sp,32
    80002aa4:	8082                	ret
    return -1;
    80002aa6:	557d                	li	a0,-1
    80002aa8:	bfcd                	j	80002a9a <fetchaddr+0x3e>
    80002aaa:	557d                	li	a0,-1
    80002aac:	b7fd                	j	80002a9a <fetchaddr+0x3e>

0000000080002aae <fetchstr>:
{
    80002aae:	7179                	addi	sp,sp,-48
    80002ab0:	f406                	sd	ra,40(sp)
    80002ab2:	f022                	sd	s0,32(sp)
    80002ab4:	ec26                	sd	s1,24(sp)
    80002ab6:	e84a                	sd	s2,16(sp)
    80002ab8:	e44e                	sd	s3,8(sp)
    80002aba:	1800                	addi	s0,sp,48
    80002abc:	892a                	mv	s2,a0
    80002abe:	84ae                	mv	s1,a1
    80002ac0:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002ac2:	fffff097          	auipc	ra,0xfffff
    80002ac6:	f88080e7          	jalr	-120(ra) # 80001a4a <myproc>
  int err = copyinstr(p->pagetable, buf, addr, max);
    80002aca:	86ce                	mv	a3,s3
    80002acc:	864a                	mv	a2,s2
    80002ace:	85a6                	mv	a1,s1
    80002ad0:	6928                	ld	a0,80(a0)
    80002ad2:	fffff097          	auipc	ra,0xfffff
    80002ad6:	c9c080e7          	jalr	-868(ra) # 8000176e <copyinstr>
  if(err < 0)
    80002ada:	00054763          	bltz	a0,80002ae8 <fetchstr+0x3a>
  return strlen(buf);
    80002ade:	8526                	mv	a0,s1
    80002ae0:	ffffe097          	auipc	ra,0xffffe
    80002ae4:	37a080e7          	jalr	890(ra) # 80000e5a <strlen>
}
    80002ae8:	70a2                	ld	ra,40(sp)
    80002aea:	7402                	ld	s0,32(sp)
    80002aec:	64e2                	ld	s1,24(sp)
    80002aee:	6942                	ld	s2,16(sp)
    80002af0:	69a2                	ld	s3,8(sp)
    80002af2:	6145                	addi	sp,sp,48
    80002af4:	8082                	ret

0000000080002af6 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
    80002af6:	1101                	addi	sp,sp,-32
    80002af8:	ec06                	sd	ra,24(sp)
    80002afa:	e822                	sd	s0,16(sp)
    80002afc:	e426                	sd	s1,8(sp)
    80002afe:	1000                	addi	s0,sp,32
    80002b00:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002b02:	00000097          	auipc	ra,0x0
    80002b06:	ef2080e7          	jalr	-270(ra) # 800029f4 <argraw>
    80002b0a:	c088                	sw	a0,0(s1)
  return 0;
}
    80002b0c:	4501                	li	a0,0
    80002b0e:	60e2                	ld	ra,24(sp)
    80002b10:	6442                	ld	s0,16(sp)
    80002b12:	64a2                	ld	s1,8(sp)
    80002b14:	6105                	addi	sp,sp,32
    80002b16:	8082                	ret

0000000080002b18 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
int
argaddr(int n, uint64 *ip)
{
    80002b18:	1101                	addi	sp,sp,-32
    80002b1a:	ec06                	sd	ra,24(sp)
    80002b1c:	e822                	sd	s0,16(sp)
    80002b1e:	e426                	sd	s1,8(sp)
    80002b20:	1000                	addi	s0,sp,32
    80002b22:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002b24:	00000097          	auipc	ra,0x0
    80002b28:	ed0080e7          	jalr	-304(ra) # 800029f4 <argraw>
    80002b2c:	e088                	sd	a0,0(s1)
  return 0;
}
    80002b2e:	4501                	li	a0,0
    80002b30:	60e2                	ld	ra,24(sp)
    80002b32:	6442                	ld	s0,16(sp)
    80002b34:	64a2                	ld	s1,8(sp)
    80002b36:	6105                	addi	sp,sp,32
    80002b38:	8082                	ret

0000000080002b3a <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002b3a:	1101                	addi	sp,sp,-32
    80002b3c:	ec06                	sd	ra,24(sp)
    80002b3e:	e822                	sd	s0,16(sp)
    80002b40:	e426                	sd	s1,8(sp)
    80002b42:	e04a                	sd	s2,0(sp)
    80002b44:	1000                	addi	s0,sp,32
    80002b46:	84ae                	mv	s1,a1
    80002b48:	8932                	mv	s2,a2
  *ip = argraw(n);
    80002b4a:	00000097          	auipc	ra,0x0
    80002b4e:	eaa080e7          	jalr	-342(ra) # 800029f4 <argraw>
  uint64 addr;
  if(argaddr(n, &addr) < 0)
    return -1;
  return fetchstr(addr, buf, max);
    80002b52:	864a                	mv	a2,s2
    80002b54:	85a6                	mv	a1,s1
    80002b56:	00000097          	auipc	ra,0x0
    80002b5a:	f58080e7          	jalr	-168(ra) # 80002aae <fetchstr>
}
    80002b5e:	60e2                	ld	ra,24(sp)
    80002b60:	6442                	ld	s0,16(sp)
    80002b62:	64a2                	ld	s1,8(sp)
    80002b64:	6902                	ld	s2,0(sp)
    80002b66:	6105                	addi	sp,sp,32
    80002b68:	8082                	ret

0000000080002b6a <syscall>:
[SYS_prtpgtbl] sys_prtpgtbl,
};

void
syscall(void)
{
    80002b6a:	1101                	addi	sp,sp,-32
    80002b6c:	ec06                	sd	ra,24(sp)
    80002b6e:	e822                	sd	s0,16(sp)
    80002b70:	e426                	sd	s1,8(sp)
    80002b72:	e04a                	sd	s2,0(sp)
    80002b74:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002b76:	fffff097          	auipc	ra,0xfffff
    80002b7a:	ed4080e7          	jalr	-300(ra) # 80001a4a <myproc>
    80002b7e:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002b80:	05853903          	ld	s2,88(a0)
    80002b84:	0a893783          	ld	a5,168(s2)
    80002b88:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002b8c:	37fd                	addiw	a5,a5,-1
    80002b8e:	4755                	li	a4,21
    80002b90:	00f76f63          	bltu	a4,a5,80002bae <syscall+0x44>
    80002b94:	00369713          	slli	a4,a3,0x3
    80002b98:	00006797          	auipc	a5,0x6
    80002b9c:	8b878793          	addi	a5,a5,-1864 # 80008450 <syscalls>
    80002ba0:	97ba                	add	a5,a5,a4
    80002ba2:	639c                	ld	a5,0(a5)
    80002ba4:	c789                	beqz	a5,80002bae <syscall+0x44>
    p->trapframe->a0 = syscalls[num]();
    80002ba6:	9782                	jalr	a5
    80002ba8:	06a93823          	sd	a0,112(s2)
    80002bac:	a839                	j	80002bca <syscall+0x60>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002bae:	15848613          	addi	a2,s1,344
    80002bb2:	588c                	lw	a1,48(s1)
    80002bb4:	00006517          	auipc	a0,0x6
    80002bb8:	86450513          	addi	a0,a0,-1948 # 80008418 <states.1708+0x150>
    80002bbc:	ffffe097          	auipc	ra,0xffffe
    80002bc0:	9be080e7          	jalr	-1602(ra) # 8000057a <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002bc4:	6cbc                	ld	a5,88(s1)
    80002bc6:	577d                	li	a4,-1
    80002bc8:	fbb8                	sd	a4,112(a5)
  }
}
    80002bca:	60e2                	ld	ra,24(sp)
    80002bcc:	6442                	ld	s0,16(sp)
    80002bce:	64a2                	ld	s1,8(sp)
    80002bd0:	6902                	ld	s2,0(sp)
    80002bd2:	6105                	addi	sp,sp,32
    80002bd4:	8082                	ret

0000000080002bd6 <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    80002bd6:	1101                	addi	sp,sp,-32
    80002bd8:	ec06                	sd	ra,24(sp)
    80002bda:	e822                	sd	s0,16(sp)
    80002bdc:	1000                	addi	s0,sp,32
  int n;
  if(argint(0, &n) < 0)
    80002bde:	fec40593          	addi	a1,s0,-20
    80002be2:	4501                	li	a0,0
    80002be4:	00000097          	auipc	ra,0x0
    80002be8:	f12080e7          	jalr	-238(ra) # 80002af6 <argint>
    return -1;
    80002bec:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80002bee:	00054963          	bltz	a0,80002c00 <sys_exit+0x2a>
  exit(n);
    80002bf2:	fec42503          	lw	a0,-20(s0)
    80002bf6:	fffff097          	auipc	ra,0xfffff
    80002bfa:	76c080e7          	jalr	1900(ra) # 80002362 <exit>
  return 0;  // not reached
    80002bfe:	4781                	li	a5,0
}
    80002c00:	853e                	mv	a0,a5
    80002c02:	60e2                	ld	ra,24(sp)
    80002c04:	6442                	ld	s0,16(sp)
    80002c06:	6105                	addi	sp,sp,32
    80002c08:	8082                	ret

0000000080002c0a <sys_getpid>:

uint64
sys_getpid(void)
{
    80002c0a:	1141                	addi	sp,sp,-16
    80002c0c:	e406                	sd	ra,8(sp)
    80002c0e:	e022                	sd	s0,0(sp)
    80002c10:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002c12:	fffff097          	auipc	ra,0xfffff
    80002c16:	e38080e7          	jalr	-456(ra) # 80001a4a <myproc>
}
    80002c1a:	5908                	lw	a0,48(a0)
    80002c1c:	60a2                	ld	ra,8(sp)
    80002c1e:	6402                	ld	s0,0(sp)
    80002c20:	0141                	addi	sp,sp,16
    80002c22:	8082                	ret

0000000080002c24 <sys_fork>:

uint64
sys_fork(void)
{
    80002c24:	1141                	addi	sp,sp,-16
    80002c26:	e406                	sd	ra,8(sp)
    80002c28:	e022                	sd	s0,0(sp)
    80002c2a:	0800                	addi	s0,sp,16
  return fork();
    80002c2c:	fffff097          	auipc	ra,0xfffff
    80002c30:	1ec080e7          	jalr	492(ra) # 80001e18 <fork>
}
    80002c34:	60a2                	ld	ra,8(sp)
    80002c36:	6402                	ld	s0,0(sp)
    80002c38:	0141                	addi	sp,sp,16
    80002c3a:	8082                	ret

0000000080002c3c <sys_wait>:

uint64
sys_wait(void)
{
    80002c3c:	1101                	addi	sp,sp,-32
    80002c3e:	ec06                	sd	ra,24(sp)
    80002c40:	e822                	sd	s0,16(sp)
    80002c42:	1000                	addi	s0,sp,32
  uint64 p;
  if(argaddr(0, &p) < 0)
    80002c44:	fe840593          	addi	a1,s0,-24
    80002c48:	4501                	li	a0,0
    80002c4a:	00000097          	auipc	ra,0x0
    80002c4e:	ece080e7          	jalr	-306(ra) # 80002b18 <argaddr>
    80002c52:	87aa                	mv	a5,a0
    return -1;
    80002c54:	557d                	li	a0,-1
  if(argaddr(0, &p) < 0)
    80002c56:	0007c863          	bltz	a5,80002c66 <sys_wait+0x2a>
  return wait(p);
    80002c5a:	fe843503          	ld	a0,-24(s0)
    80002c5e:	fffff097          	auipc	ra,0xfffff
    80002c62:	50c080e7          	jalr	1292(ra) # 8000216a <wait>
}
    80002c66:	60e2                	ld	ra,24(sp)
    80002c68:	6442                	ld	s0,16(sp)
    80002c6a:	6105                	addi	sp,sp,32
    80002c6c:	8082                	ret

0000000080002c6e <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002c6e:	7179                	addi	sp,sp,-48
    80002c70:	f406                	sd	ra,40(sp)
    80002c72:	f022                	sd	s0,32(sp)
    80002c74:	ec26                	sd	s1,24(sp)
    80002c76:	1800                	addi	s0,sp,48
  int addr;
  int n;

  if(argint(0, &n) < 0)
    80002c78:	fdc40593          	addi	a1,s0,-36
    80002c7c:	4501                	li	a0,0
    80002c7e:	00000097          	auipc	ra,0x0
    80002c82:	e78080e7          	jalr	-392(ra) # 80002af6 <argint>
    80002c86:	87aa                	mv	a5,a0
    return -1;
    80002c88:	557d                	li	a0,-1
  if(argint(0, &n) < 0)
    80002c8a:	0207c063          	bltz	a5,80002caa <sys_sbrk+0x3c>
  addr = myproc()->sz;
    80002c8e:	fffff097          	auipc	ra,0xfffff
    80002c92:	dbc080e7          	jalr	-580(ra) # 80001a4a <myproc>
    80002c96:	4524                	lw	s1,72(a0)
  if(growproc(n) < 0)
    80002c98:	fdc42503          	lw	a0,-36(s0)
    80002c9c:	fffff097          	auipc	ra,0xfffff
    80002ca0:	108080e7          	jalr	264(ra) # 80001da4 <growproc>
    80002ca4:	00054863          	bltz	a0,80002cb4 <sys_sbrk+0x46>
    return -1;
  return addr;
    80002ca8:	8526                	mv	a0,s1
}
    80002caa:	70a2                	ld	ra,40(sp)
    80002cac:	7402                	ld	s0,32(sp)
    80002cae:	64e2                	ld	s1,24(sp)
    80002cb0:	6145                	addi	sp,sp,48
    80002cb2:	8082                	ret
    return -1;
    80002cb4:	557d                	li	a0,-1
    80002cb6:	bfd5                	j	80002caa <sys_sbrk+0x3c>

0000000080002cb8 <sys_sleep>:

uint64
sys_sleep(void)
{
    80002cb8:	7139                	addi	sp,sp,-64
    80002cba:	fc06                	sd	ra,56(sp)
    80002cbc:	f822                	sd	s0,48(sp)
    80002cbe:	f426                	sd	s1,40(sp)
    80002cc0:	f04a                	sd	s2,32(sp)
    80002cc2:	ec4e                	sd	s3,24(sp)
    80002cc4:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
    80002cc6:	fcc40593          	addi	a1,s0,-52
    80002cca:	4501                	li	a0,0
    80002ccc:	00000097          	auipc	ra,0x0
    80002cd0:	e2a080e7          	jalr	-470(ra) # 80002af6 <argint>
    return -1;
    80002cd4:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80002cd6:	06054563          	bltz	a0,80002d40 <sys_sleep+0x88>
  acquire(&tickslock);
    80002cda:	00014517          	auipc	a0,0x14
    80002cde:	3f650513          	addi	a0,a0,1014 # 800170d0 <tickslock>
    80002ce2:	ffffe097          	auipc	ra,0xffffe
    80002ce6:	ef4080e7          	jalr	-268(ra) # 80000bd6 <acquire>
  ticks0 = ticks;
    80002cea:	00006917          	auipc	s2,0x6
    80002cee:	34692903          	lw	s2,838(s2) # 80009030 <ticks>
  while(ticks - ticks0 < n){
    80002cf2:	fcc42783          	lw	a5,-52(s0)
    80002cf6:	cf85                	beqz	a5,80002d2e <sys_sleep+0x76>
    if(myproc()->killed){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002cf8:	00014997          	auipc	s3,0x14
    80002cfc:	3d898993          	addi	s3,s3,984 # 800170d0 <tickslock>
    80002d00:	00006497          	auipc	s1,0x6
    80002d04:	33048493          	addi	s1,s1,816 # 80009030 <ticks>
    if(myproc()->killed){
    80002d08:	fffff097          	auipc	ra,0xfffff
    80002d0c:	d42080e7          	jalr	-702(ra) # 80001a4a <myproc>
    80002d10:	551c                	lw	a5,40(a0)
    80002d12:	ef9d                	bnez	a5,80002d50 <sys_sleep+0x98>
    sleep(&ticks, &tickslock);
    80002d14:	85ce                	mv	a1,s3
    80002d16:	8526                	mv	a0,s1
    80002d18:	fffff097          	auipc	ra,0xfffff
    80002d1c:	3ee080e7          	jalr	1006(ra) # 80002106 <sleep>
  while(ticks - ticks0 < n){
    80002d20:	409c                	lw	a5,0(s1)
    80002d22:	412787bb          	subw	a5,a5,s2
    80002d26:	fcc42703          	lw	a4,-52(s0)
    80002d2a:	fce7efe3          	bltu	a5,a4,80002d08 <sys_sleep+0x50>
  }
  release(&tickslock);
    80002d2e:	00014517          	auipc	a0,0x14
    80002d32:	3a250513          	addi	a0,a0,930 # 800170d0 <tickslock>
    80002d36:	ffffe097          	auipc	ra,0xffffe
    80002d3a:	f54080e7          	jalr	-172(ra) # 80000c8a <release>
  return 0;
    80002d3e:	4781                	li	a5,0
}
    80002d40:	853e                	mv	a0,a5
    80002d42:	70e2                	ld	ra,56(sp)
    80002d44:	7442                	ld	s0,48(sp)
    80002d46:	74a2                	ld	s1,40(sp)
    80002d48:	7902                	ld	s2,32(sp)
    80002d4a:	69e2                	ld	s3,24(sp)
    80002d4c:	6121                	addi	sp,sp,64
    80002d4e:	8082                	ret
      release(&tickslock);
    80002d50:	00014517          	auipc	a0,0x14
    80002d54:	38050513          	addi	a0,a0,896 # 800170d0 <tickslock>
    80002d58:	ffffe097          	auipc	ra,0xffffe
    80002d5c:	f32080e7          	jalr	-206(ra) # 80000c8a <release>
      return -1;
    80002d60:	57fd                	li	a5,-1
    80002d62:	bff9                	j	80002d40 <sys_sleep+0x88>

0000000080002d64 <sys_kill>:

uint64
sys_kill(void)
{
    80002d64:	1101                	addi	sp,sp,-32
    80002d66:	ec06                	sd	ra,24(sp)
    80002d68:	e822                	sd	s0,16(sp)
    80002d6a:	1000                	addi	s0,sp,32
  int pid;

  if(argint(0, &pid) < 0)
    80002d6c:	fec40593          	addi	a1,s0,-20
    80002d70:	4501                	li	a0,0
    80002d72:	00000097          	auipc	ra,0x0
    80002d76:	d84080e7          	jalr	-636(ra) # 80002af6 <argint>
    80002d7a:	87aa                	mv	a5,a0
    return -1;
    80002d7c:	557d                	li	a0,-1
  if(argint(0, &pid) < 0)
    80002d7e:	0007c863          	bltz	a5,80002d8e <sys_kill+0x2a>
  return kill(pid);
    80002d82:	fec42503          	lw	a0,-20(s0)
    80002d86:	fffff097          	auipc	ra,0xfffff
    80002d8a:	6b2080e7          	jalr	1714(ra) # 80002438 <kill>
}
    80002d8e:	60e2                	ld	ra,24(sp)
    80002d90:	6442                	ld	s0,16(sp)
    80002d92:	6105                	addi	sp,sp,32
    80002d94:	8082                	ret

0000000080002d96 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002d96:	1101                	addi	sp,sp,-32
    80002d98:	ec06                	sd	ra,24(sp)
    80002d9a:	e822                	sd	s0,16(sp)
    80002d9c:	e426                	sd	s1,8(sp)
    80002d9e:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002da0:	00014517          	auipc	a0,0x14
    80002da4:	33050513          	addi	a0,a0,816 # 800170d0 <tickslock>
    80002da8:	ffffe097          	auipc	ra,0xffffe
    80002dac:	e2e080e7          	jalr	-466(ra) # 80000bd6 <acquire>
  xticks = ticks;
    80002db0:	00006497          	auipc	s1,0x6
    80002db4:	2804a483          	lw	s1,640(s1) # 80009030 <ticks>
  release(&tickslock);
    80002db8:	00014517          	auipc	a0,0x14
    80002dbc:	31850513          	addi	a0,a0,792 # 800170d0 <tickslock>
    80002dc0:	ffffe097          	auipc	ra,0xffffe
    80002dc4:	eca080e7          	jalr	-310(ra) # 80000c8a <release>
  return xticks;
}
    80002dc8:	02049513          	slli	a0,s1,0x20
    80002dcc:	9101                	srli	a0,a0,0x20
    80002dce:	60e2                	ld	ra,24(sp)
    80002dd0:	6442                	ld	s0,16(sp)
    80002dd2:	64a2                	ld	s1,8(sp)
    80002dd4:	6105                	addi	sp,sp,32
    80002dd6:	8082                	ret

0000000080002dd8 <sys_prtpgtbl>:

uint64
sys_prtpgtbl(void)
{
    80002dd8:	1141                	addi	sp,sp,-16
    80002dda:	e406                	sd	ra,8(sp)
    80002ddc:	e022                	sd	s0,0(sp)
    80002dde:	0800                	addi	s0,sp,16
  struct proc* p = myproc();
    80002de0:	fffff097          	auipc	ra,0xfffff
    80002de4:	c6a080e7          	jalr	-918(ra) # 80001a4a <myproc>
  printTable(p->pagetable, 0);
    80002de8:	4581                	li	a1,0
    80002dea:	6928                	ld	a0,80(a0)
    80002dec:	fffff097          	auipc	ra,0xfffff
    80002df0:	a36080e7          	jalr	-1482(ra) # 80001822 <printTable>
  return 0;
    80002df4:	4501                	li	a0,0
    80002df6:	60a2                	ld	ra,8(sp)
    80002df8:	6402                	ld	s0,0(sp)
    80002dfa:	0141                	addi	sp,sp,16
    80002dfc:	8082                	ret

0000000080002dfe <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002dfe:	7179                	addi	sp,sp,-48
    80002e00:	f406                	sd	ra,40(sp)
    80002e02:	f022                	sd	s0,32(sp)
    80002e04:	ec26                	sd	s1,24(sp)
    80002e06:	e84a                	sd	s2,16(sp)
    80002e08:	e44e                	sd	s3,8(sp)
    80002e0a:	e052                	sd	s4,0(sp)
    80002e0c:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80002e0e:	00005597          	auipc	a1,0x5
    80002e12:	6fa58593          	addi	a1,a1,1786 # 80008508 <syscalls+0xb8>
    80002e16:	00014517          	auipc	a0,0x14
    80002e1a:	2d250513          	addi	a0,a0,722 # 800170e8 <bcache>
    80002e1e:	ffffe097          	auipc	ra,0xffffe
    80002e22:	d28080e7          	jalr	-728(ra) # 80000b46 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80002e26:	0001c797          	auipc	a5,0x1c
    80002e2a:	2c278793          	addi	a5,a5,706 # 8001f0e8 <bcache+0x8000>
    80002e2e:	0001c717          	auipc	a4,0x1c
    80002e32:	52270713          	addi	a4,a4,1314 # 8001f350 <bcache+0x8268>
    80002e36:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80002e3a:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002e3e:	00014497          	auipc	s1,0x14
    80002e42:	2c248493          	addi	s1,s1,706 # 80017100 <bcache+0x18>
    b->next = bcache.head.next;
    80002e46:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80002e48:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80002e4a:	00005a17          	auipc	s4,0x5
    80002e4e:	6c6a0a13          	addi	s4,s4,1734 # 80008510 <syscalls+0xc0>
    b->next = bcache.head.next;
    80002e52:	2b893783          	ld	a5,696(s2)
    80002e56:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80002e58:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80002e5c:	85d2                	mv	a1,s4
    80002e5e:	01048513          	addi	a0,s1,16
    80002e62:	00001097          	auipc	ra,0x1
    80002e66:	4bc080e7          	jalr	1212(ra) # 8000431e <initsleeplock>
    bcache.head.next->prev = b;
    80002e6a:	2b893783          	ld	a5,696(s2)
    80002e6e:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80002e70:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002e74:	45848493          	addi	s1,s1,1112
    80002e78:	fd349de3          	bne	s1,s3,80002e52 <binit+0x54>
  }
}
    80002e7c:	70a2                	ld	ra,40(sp)
    80002e7e:	7402                	ld	s0,32(sp)
    80002e80:	64e2                	ld	s1,24(sp)
    80002e82:	6942                	ld	s2,16(sp)
    80002e84:	69a2                	ld	s3,8(sp)
    80002e86:	6a02                	ld	s4,0(sp)
    80002e88:	6145                	addi	sp,sp,48
    80002e8a:	8082                	ret

0000000080002e8c <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80002e8c:	7179                	addi	sp,sp,-48
    80002e8e:	f406                	sd	ra,40(sp)
    80002e90:	f022                	sd	s0,32(sp)
    80002e92:	ec26                	sd	s1,24(sp)
    80002e94:	e84a                	sd	s2,16(sp)
    80002e96:	e44e                	sd	s3,8(sp)
    80002e98:	1800                	addi	s0,sp,48
    80002e9a:	89aa                	mv	s3,a0
    80002e9c:	892e                	mv	s2,a1
  acquire(&bcache.lock);
    80002e9e:	00014517          	auipc	a0,0x14
    80002ea2:	24a50513          	addi	a0,a0,586 # 800170e8 <bcache>
    80002ea6:	ffffe097          	auipc	ra,0xffffe
    80002eaa:	d30080e7          	jalr	-720(ra) # 80000bd6 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80002eae:	0001c497          	auipc	s1,0x1c
    80002eb2:	4f24b483          	ld	s1,1266(s1) # 8001f3a0 <bcache+0x82b8>
    80002eb6:	0001c797          	auipc	a5,0x1c
    80002eba:	49a78793          	addi	a5,a5,1178 # 8001f350 <bcache+0x8268>
    80002ebe:	02f48f63          	beq	s1,a5,80002efc <bread+0x70>
    80002ec2:	873e                	mv	a4,a5
    80002ec4:	a021                	j	80002ecc <bread+0x40>
    80002ec6:	68a4                	ld	s1,80(s1)
    80002ec8:	02e48a63          	beq	s1,a4,80002efc <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    80002ecc:	449c                	lw	a5,8(s1)
    80002ece:	ff379ce3          	bne	a5,s3,80002ec6 <bread+0x3a>
    80002ed2:	44dc                	lw	a5,12(s1)
    80002ed4:	ff2799e3          	bne	a5,s2,80002ec6 <bread+0x3a>
      b->refcnt++;
    80002ed8:	40bc                	lw	a5,64(s1)
    80002eda:	2785                	addiw	a5,a5,1
    80002edc:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002ede:	00014517          	auipc	a0,0x14
    80002ee2:	20a50513          	addi	a0,a0,522 # 800170e8 <bcache>
    80002ee6:	ffffe097          	auipc	ra,0xffffe
    80002eea:	da4080e7          	jalr	-604(ra) # 80000c8a <release>
      acquiresleep(&b->lock);
    80002eee:	01048513          	addi	a0,s1,16
    80002ef2:	00001097          	auipc	ra,0x1
    80002ef6:	466080e7          	jalr	1126(ra) # 80004358 <acquiresleep>
      return b;
    80002efa:	a8b9                	j	80002f58 <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002efc:	0001c497          	auipc	s1,0x1c
    80002f00:	49c4b483          	ld	s1,1180(s1) # 8001f398 <bcache+0x82b0>
    80002f04:	0001c797          	auipc	a5,0x1c
    80002f08:	44c78793          	addi	a5,a5,1100 # 8001f350 <bcache+0x8268>
    80002f0c:	00f48863          	beq	s1,a5,80002f1c <bread+0x90>
    80002f10:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80002f12:	40bc                	lw	a5,64(s1)
    80002f14:	cf81                	beqz	a5,80002f2c <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002f16:	64a4                	ld	s1,72(s1)
    80002f18:	fee49de3          	bne	s1,a4,80002f12 <bread+0x86>
  panic("bget: no buffers");
    80002f1c:	00005517          	auipc	a0,0x5
    80002f20:	5fc50513          	addi	a0,a0,1532 # 80008518 <syscalls+0xc8>
    80002f24:	ffffd097          	auipc	ra,0xffffd
    80002f28:	60c080e7          	jalr	1548(ra) # 80000530 <panic>
      b->dev = dev;
    80002f2c:	0134a423          	sw	s3,8(s1)
      b->blockno = blockno;
    80002f30:	0124a623          	sw	s2,12(s1)
      b->valid = 0;
    80002f34:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80002f38:	4785                	li	a5,1
    80002f3a:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002f3c:	00014517          	auipc	a0,0x14
    80002f40:	1ac50513          	addi	a0,a0,428 # 800170e8 <bcache>
    80002f44:	ffffe097          	auipc	ra,0xffffe
    80002f48:	d46080e7          	jalr	-698(ra) # 80000c8a <release>
      acquiresleep(&b->lock);
    80002f4c:	01048513          	addi	a0,s1,16
    80002f50:	00001097          	auipc	ra,0x1
    80002f54:	408080e7          	jalr	1032(ra) # 80004358 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80002f58:	409c                	lw	a5,0(s1)
    80002f5a:	cb89                	beqz	a5,80002f6c <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80002f5c:	8526                	mv	a0,s1
    80002f5e:	70a2                	ld	ra,40(sp)
    80002f60:	7402                	ld	s0,32(sp)
    80002f62:	64e2                	ld	s1,24(sp)
    80002f64:	6942                	ld	s2,16(sp)
    80002f66:	69a2                	ld	s3,8(sp)
    80002f68:	6145                	addi	sp,sp,48
    80002f6a:	8082                	ret
    virtio_disk_rw(b, 0);
    80002f6c:	4581                	li	a1,0
    80002f6e:	8526                	mv	a0,s1
    80002f70:	00003097          	auipc	ra,0x3
    80002f74:	f06080e7          	jalr	-250(ra) # 80005e76 <virtio_disk_rw>
    b->valid = 1;
    80002f78:	4785                	li	a5,1
    80002f7a:	c09c                	sw	a5,0(s1)
  return b;
    80002f7c:	b7c5                	j	80002f5c <bread+0xd0>

0000000080002f7e <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80002f7e:	1101                	addi	sp,sp,-32
    80002f80:	ec06                	sd	ra,24(sp)
    80002f82:	e822                	sd	s0,16(sp)
    80002f84:	e426                	sd	s1,8(sp)
    80002f86:	1000                	addi	s0,sp,32
    80002f88:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002f8a:	0541                	addi	a0,a0,16
    80002f8c:	00001097          	auipc	ra,0x1
    80002f90:	466080e7          	jalr	1126(ra) # 800043f2 <holdingsleep>
    80002f94:	cd01                	beqz	a0,80002fac <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80002f96:	4585                	li	a1,1
    80002f98:	8526                	mv	a0,s1
    80002f9a:	00003097          	auipc	ra,0x3
    80002f9e:	edc080e7          	jalr	-292(ra) # 80005e76 <virtio_disk_rw>
}
    80002fa2:	60e2                	ld	ra,24(sp)
    80002fa4:	6442                	ld	s0,16(sp)
    80002fa6:	64a2                	ld	s1,8(sp)
    80002fa8:	6105                	addi	sp,sp,32
    80002faa:	8082                	ret
    panic("bwrite");
    80002fac:	00005517          	auipc	a0,0x5
    80002fb0:	58450513          	addi	a0,a0,1412 # 80008530 <syscalls+0xe0>
    80002fb4:	ffffd097          	auipc	ra,0xffffd
    80002fb8:	57c080e7          	jalr	1404(ra) # 80000530 <panic>

0000000080002fbc <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80002fbc:	1101                	addi	sp,sp,-32
    80002fbe:	ec06                	sd	ra,24(sp)
    80002fc0:	e822                	sd	s0,16(sp)
    80002fc2:	e426                	sd	s1,8(sp)
    80002fc4:	e04a                	sd	s2,0(sp)
    80002fc6:	1000                	addi	s0,sp,32
    80002fc8:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002fca:	01050913          	addi	s2,a0,16
    80002fce:	854a                	mv	a0,s2
    80002fd0:	00001097          	auipc	ra,0x1
    80002fd4:	422080e7          	jalr	1058(ra) # 800043f2 <holdingsleep>
    80002fd8:	c92d                	beqz	a0,8000304a <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    80002fda:	854a                	mv	a0,s2
    80002fdc:	00001097          	auipc	ra,0x1
    80002fe0:	3d2080e7          	jalr	978(ra) # 800043ae <releasesleep>

  acquire(&bcache.lock);
    80002fe4:	00014517          	auipc	a0,0x14
    80002fe8:	10450513          	addi	a0,a0,260 # 800170e8 <bcache>
    80002fec:	ffffe097          	auipc	ra,0xffffe
    80002ff0:	bea080e7          	jalr	-1046(ra) # 80000bd6 <acquire>
  b->refcnt--;
    80002ff4:	40bc                	lw	a5,64(s1)
    80002ff6:	37fd                	addiw	a5,a5,-1
    80002ff8:	0007871b          	sext.w	a4,a5
    80002ffc:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80002ffe:	eb05                	bnez	a4,8000302e <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80003000:	68bc                	ld	a5,80(s1)
    80003002:	64b8                	ld	a4,72(s1)
    80003004:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    80003006:	64bc                	ld	a5,72(s1)
    80003008:	68b8                	ld	a4,80(s1)
    8000300a:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    8000300c:	0001c797          	auipc	a5,0x1c
    80003010:	0dc78793          	addi	a5,a5,220 # 8001f0e8 <bcache+0x8000>
    80003014:	2b87b703          	ld	a4,696(a5)
    80003018:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    8000301a:	0001c717          	auipc	a4,0x1c
    8000301e:	33670713          	addi	a4,a4,822 # 8001f350 <bcache+0x8268>
    80003022:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80003024:	2b87b703          	ld	a4,696(a5)
    80003028:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    8000302a:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    8000302e:	00014517          	auipc	a0,0x14
    80003032:	0ba50513          	addi	a0,a0,186 # 800170e8 <bcache>
    80003036:	ffffe097          	auipc	ra,0xffffe
    8000303a:	c54080e7          	jalr	-940(ra) # 80000c8a <release>
}
    8000303e:	60e2                	ld	ra,24(sp)
    80003040:	6442                	ld	s0,16(sp)
    80003042:	64a2                	ld	s1,8(sp)
    80003044:	6902                	ld	s2,0(sp)
    80003046:	6105                	addi	sp,sp,32
    80003048:	8082                	ret
    panic("brelse");
    8000304a:	00005517          	auipc	a0,0x5
    8000304e:	4ee50513          	addi	a0,a0,1262 # 80008538 <syscalls+0xe8>
    80003052:	ffffd097          	auipc	ra,0xffffd
    80003056:	4de080e7          	jalr	1246(ra) # 80000530 <panic>

000000008000305a <bpin>:

void
bpin(struct buf *b) {
    8000305a:	1101                	addi	sp,sp,-32
    8000305c:	ec06                	sd	ra,24(sp)
    8000305e:	e822                	sd	s0,16(sp)
    80003060:	e426                	sd	s1,8(sp)
    80003062:	1000                	addi	s0,sp,32
    80003064:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003066:	00014517          	auipc	a0,0x14
    8000306a:	08250513          	addi	a0,a0,130 # 800170e8 <bcache>
    8000306e:	ffffe097          	auipc	ra,0xffffe
    80003072:	b68080e7          	jalr	-1176(ra) # 80000bd6 <acquire>
  b->refcnt++;
    80003076:	40bc                	lw	a5,64(s1)
    80003078:	2785                	addiw	a5,a5,1
    8000307a:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    8000307c:	00014517          	auipc	a0,0x14
    80003080:	06c50513          	addi	a0,a0,108 # 800170e8 <bcache>
    80003084:	ffffe097          	auipc	ra,0xffffe
    80003088:	c06080e7          	jalr	-1018(ra) # 80000c8a <release>
}
    8000308c:	60e2                	ld	ra,24(sp)
    8000308e:	6442                	ld	s0,16(sp)
    80003090:	64a2                	ld	s1,8(sp)
    80003092:	6105                	addi	sp,sp,32
    80003094:	8082                	ret

0000000080003096 <bunpin>:

void
bunpin(struct buf *b) {
    80003096:	1101                	addi	sp,sp,-32
    80003098:	ec06                	sd	ra,24(sp)
    8000309a:	e822                	sd	s0,16(sp)
    8000309c:	e426                	sd	s1,8(sp)
    8000309e:	1000                	addi	s0,sp,32
    800030a0:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800030a2:	00014517          	auipc	a0,0x14
    800030a6:	04650513          	addi	a0,a0,70 # 800170e8 <bcache>
    800030aa:	ffffe097          	auipc	ra,0xffffe
    800030ae:	b2c080e7          	jalr	-1236(ra) # 80000bd6 <acquire>
  b->refcnt--;
    800030b2:	40bc                	lw	a5,64(s1)
    800030b4:	37fd                	addiw	a5,a5,-1
    800030b6:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800030b8:	00014517          	auipc	a0,0x14
    800030bc:	03050513          	addi	a0,a0,48 # 800170e8 <bcache>
    800030c0:	ffffe097          	auipc	ra,0xffffe
    800030c4:	bca080e7          	jalr	-1078(ra) # 80000c8a <release>
}
    800030c8:	60e2                	ld	ra,24(sp)
    800030ca:	6442                	ld	s0,16(sp)
    800030cc:	64a2                	ld	s1,8(sp)
    800030ce:	6105                	addi	sp,sp,32
    800030d0:	8082                	ret

00000000800030d2 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    800030d2:	1101                	addi	sp,sp,-32
    800030d4:	ec06                	sd	ra,24(sp)
    800030d6:	e822                	sd	s0,16(sp)
    800030d8:	e426                	sd	s1,8(sp)
    800030da:	e04a                	sd	s2,0(sp)
    800030dc:	1000                	addi	s0,sp,32
    800030de:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    800030e0:	00d5d59b          	srliw	a1,a1,0xd
    800030e4:	0001c797          	auipc	a5,0x1c
    800030e8:	6e07a783          	lw	a5,1760(a5) # 8001f7c4 <sb+0x1c>
    800030ec:	9dbd                	addw	a1,a1,a5
    800030ee:	00000097          	auipc	ra,0x0
    800030f2:	d9e080e7          	jalr	-610(ra) # 80002e8c <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    800030f6:	0074f713          	andi	a4,s1,7
    800030fa:	4785                	li	a5,1
    800030fc:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    80003100:	14ce                	slli	s1,s1,0x33
    80003102:	90d9                	srli	s1,s1,0x36
    80003104:	00950733          	add	a4,a0,s1
    80003108:	05874703          	lbu	a4,88(a4)
    8000310c:	00e7f6b3          	and	a3,a5,a4
    80003110:	c69d                	beqz	a3,8000313e <bfree+0x6c>
    80003112:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80003114:	94aa                	add	s1,s1,a0
    80003116:	fff7c793          	not	a5,a5
    8000311a:	8ff9                	and	a5,a5,a4
    8000311c:	04f48c23          	sb	a5,88(s1)
  log_write(bp);
    80003120:	00001097          	auipc	ra,0x1
    80003124:	118080e7          	jalr	280(ra) # 80004238 <log_write>
  brelse(bp);
    80003128:	854a                	mv	a0,s2
    8000312a:	00000097          	auipc	ra,0x0
    8000312e:	e92080e7          	jalr	-366(ra) # 80002fbc <brelse>
}
    80003132:	60e2                	ld	ra,24(sp)
    80003134:	6442                	ld	s0,16(sp)
    80003136:	64a2                	ld	s1,8(sp)
    80003138:	6902                	ld	s2,0(sp)
    8000313a:	6105                	addi	sp,sp,32
    8000313c:	8082                	ret
    panic("freeing free block");
    8000313e:	00005517          	auipc	a0,0x5
    80003142:	40250513          	addi	a0,a0,1026 # 80008540 <syscalls+0xf0>
    80003146:	ffffd097          	auipc	ra,0xffffd
    8000314a:	3ea080e7          	jalr	1002(ra) # 80000530 <panic>

000000008000314e <balloc>:
{
    8000314e:	711d                	addi	sp,sp,-96
    80003150:	ec86                	sd	ra,88(sp)
    80003152:	e8a2                	sd	s0,80(sp)
    80003154:	e4a6                	sd	s1,72(sp)
    80003156:	e0ca                	sd	s2,64(sp)
    80003158:	fc4e                	sd	s3,56(sp)
    8000315a:	f852                	sd	s4,48(sp)
    8000315c:	f456                	sd	s5,40(sp)
    8000315e:	f05a                	sd	s6,32(sp)
    80003160:	ec5e                	sd	s7,24(sp)
    80003162:	e862                	sd	s8,16(sp)
    80003164:	e466                	sd	s9,8(sp)
    80003166:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    80003168:	0001c797          	auipc	a5,0x1c
    8000316c:	6447a783          	lw	a5,1604(a5) # 8001f7ac <sb+0x4>
    80003170:	cbd1                	beqz	a5,80003204 <balloc+0xb6>
    80003172:	8baa                	mv	s7,a0
    80003174:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80003176:	0001cb17          	auipc	s6,0x1c
    8000317a:	632b0b13          	addi	s6,s6,1586 # 8001f7a8 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000317e:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    80003180:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003182:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80003184:	6c89                	lui	s9,0x2
    80003186:	a831                	j	800031a2 <balloc+0x54>
    brelse(bp);
    80003188:	854a                	mv	a0,s2
    8000318a:	00000097          	auipc	ra,0x0
    8000318e:	e32080e7          	jalr	-462(ra) # 80002fbc <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80003192:	015c87bb          	addw	a5,s9,s5
    80003196:	00078a9b          	sext.w	s5,a5
    8000319a:	004b2703          	lw	a4,4(s6)
    8000319e:	06eaf363          	bgeu	s5,a4,80003204 <balloc+0xb6>
    bp = bread(dev, BBLOCK(b, sb));
    800031a2:	41fad79b          	sraiw	a5,s5,0x1f
    800031a6:	0137d79b          	srliw	a5,a5,0x13
    800031aa:	015787bb          	addw	a5,a5,s5
    800031ae:	40d7d79b          	sraiw	a5,a5,0xd
    800031b2:	01cb2583          	lw	a1,28(s6)
    800031b6:	9dbd                	addw	a1,a1,a5
    800031b8:	855e                	mv	a0,s7
    800031ba:	00000097          	auipc	ra,0x0
    800031be:	cd2080e7          	jalr	-814(ra) # 80002e8c <bread>
    800031c2:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800031c4:	004b2503          	lw	a0,4(s6)
    800031c8:	000a849b          	sext.w	s1,s5
    800031cc:	8662                	mv	a2,s8
    800031ce:	faa4fde3          	bgeu	s1,a0,80003188 <balloc+0x3a>
      m = 1 << (bi % 8);
    800031d2:	41f6579b          	sraiw	a5,a2,0x1f
    800031d6:	01d7d69b          	srliw	a3,a5,0x1d
    800031da:	00c6873b          	addw	a4,a3,a2
    800031de:	00777793          	andi	a5,a4,7
    800031e2:	9f95                	subw	a5,a5,a3
    800031e4:	00f997bb          	sllw	a5,s3,a5
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    800031e8:	4037571b          	sraiw	a4,a4,0x3
    800031ec:	00e906b3          	add	a3,s2,a4
    800031f0:	0586c683          	lbu	a3,88(a3)
    800031f4:	00d7f5b3          	and	a1,a5,a3
    800031f8:	cd91                	beqz	a1,80003214 <balloc+0xc6>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800031fa:	2605                	addiw	a2,a2,1
    800031fc:	2485                	addiw	s1,s1,1
    800031fe:	fd4618e3          	bne	a2,s4,800031ce <balloc+0x80>
    80003202:	b759                	j	80003188 <balloc+0x3a>
  panic("balloc: out of blocks");
    80003204:	00005517          	auipc	a0,0x5
    80003208:	35450513          	addi	a0,a0,852 # 80008558 <syscalls+0x108>
    8000320c:	ffffd097          	auipc	ra,0xffffd
    80003210:	324080e7          	jalr	804(ra) # 80000530 <panic>
        bp->data[bi/8] |= m;  // Mark block in use.
    80003214:	974a                	add	a4,a4,s2
    80003216:	8fd5                	or	a5,a5,a3
    80003218:	04f70c23          	sb	a5,88(a4)
        log_write(bp);
    8000321c:	854a                	mv	a0,s2
    8000321e:	00001097          	auipc	ra,0x1
    80003222:	01a080e7          	jalr	26(ra) # 80004238 <log_write>
        brelse(bp);
    80003226:	854a                	mv	a0,s2
    80003228:	00000097          	auipc	ra,0x0
    8000322c:	d94080e7          	jalr	-620(ra) # 80002fbc <brelse>
  bp = bread(dev, bno);
    80003230:	85a6                	mv	a1,s1
    80003232:	855e                	mv	a0,s7
    80003234:	00000097          	auipc	ra,0x0
    80003238:	c58080e7          	jalr	-936(ra) # 80002e8c <bread>
    8000323c:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    8000323e:	40000613          	li	a2,1024
    80003242:	4581                	li	a1,0
    80003244:	05850513          	addi	a0,a0,88
    80003248:	ffffe097          	auipc	ra,0xffffe
    8000324c:	a8a080e7          	jalr	-1398(ra) # 80000cd2 <memset>
  log_write(bp);
    80003250:	854a                	mv	a0,s2
    80003252:	00001097          	auipc	ra,0x1
    80003256:	fe6080e7          	jalr	-26(ra) # 80004238 <log_write>
  brelse(bp);
    8000325a:	854a                	mv	a0,s2
    8000325c:	00000097          	auipc	ra,0x0
    80003260:	d60080e7          	jalr	-672(ra) # 80002fbc <brelse>
}
    80003264:	8526                	mv	a0,s1
    80003266:	60e6                	ld	ra,88(sp)
    80003268:	6446                	ld	s0,80(sp)
    8000326a:	64a6                	ld	s1,72(sp)
    8000326c:	6906                	ld	s2,64(sp)
    8000326e:	79e2                	ld	s3,56(sp)
    80003270:	7a42                	ld	s4,48(sp)
    80003272:	7aa2                	ld	s5,40(sp)
    80003274:	7b02                	ld	s6,32(sp)
    80003276:	6be2                	ld	s7,24(sp)
    80003278:	6c42                	ld	s8,16(sp)
    8000327a:	6ca2                	ld	s9,8(sp)
    8000327c:	6125                	addi	sp,sp,96
    8000327e:	8082                	ret

0000000080003280 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
    80003280:	7179                	addi	sp,sp,-48
    80003282:	f406                	sd	ra,40(sp)
    80003284:	f022                	sd	s0,32(sp)
    80003286:	ec26                	sd	s1,24(sp)
    80003288:	e84a                	sd	s2,16(sp)
    8000328a:	e44e                	sd	s3,8(sp)
    8000328c:	e052                	sd	s4,0(sp)
    8000328e:	1800                	addi	s0,sp,48
    80003290:	892a                	mv	s2,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80003292:	47ad                	li	a5,11
    80003294:	04b7fe63          	bgeu	a5,a1,800032f0 <bmap+0x70>
    if((addr = ip->addrs[bn]) == 0)
      ip->addrs[bn] = addr = balloc(ip->dev);
    return addr;
  }
  bn -= NDIRECT;
    80003298:	ff45849b          	addiw	s1,a1,-12
    8000329c:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    800032a0:	0ff00793          	li	a5,255
    800032a4:	0ae7e363          	bltu	a5,a4,8000334a <bmap+0xca>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
    800032a8:	08052583          	lw	a1,128(a0)
    800032ac:	c5ad                	beqz	a1,80003316 <bmap+0x96>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    bp = bread(ip->dev, addr);
    800032ae:	00092503          	lw	a0,0(s2)
    800032b2:	00000097          	auipc	ra,0x0
    800032b6:	bda080e7          	jalr	-1062(ra) # 80002e8c <bread>
    800032ba:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    800032bc:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    800032c0:	02049593          	slli	a1,s1,0x20
    800032c4:	9181                	srli	a1,a1,0x20
    800032c6:	058a                	slli	a1,a1,0x2
    800032c8:	00b784b3          	add	s1,a5,a1
    800032cc:	0004a983          	lw	s3,0(s1)
    800032d0:	04098d63          	beqz	s3,8000332a <bmap+0xaa>
      a[bn] = addr = balloc(ip->dev);
      log_write(bp);
    }
    brelse(bp);
    800032d4:	8552                	mv	a0,s4
    800032d6:	00000097          	auipc	ra,0x0
    800032da:	ce6080e7          	jalr	-794(ra) # 80002fbc <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    800032de:	854e                	mv	a0,s3
    800032e0:	70a2                	ld	ra,40(sp)
    800032e2:	7402                	ld	s0,32(sp)
    800032e4:	64e2                	ld	s1,24(sp)
    800032e6:	6942                	ld	s2,16(sp)
    800032e8:	69a2                	ld	s3,8(sp)
    800032ea:	6a02                	ld	s4,0(sp)
    800032ec:	6145                	addi	sp,sp,48
    800032ee:	8082                	ret
    if((addr = ip->addrs[bn]) == 0)
    800032f0:	02059493          	slli	s1,a1,0x20
    800032f4:	9081                	srli	s1,s1,0x20
    800032f6:	048a                	slli	s1,s1,0x2
    800032f8:	94aa                	add	s1,s1,a0
    800032fa:	0504a983          	lw	s3,80(s1)
    800032fe:	fe0990e3          	bnez	s3,800032de <bmap+0x5e>
      ip->addrs[bn] = addr = balloc(ip->dev);
    80003302:	4108                	lw	a0,0(a0)
    80003304:	00000097          	auipc	ra,0x0
    80003308:	e4a080e7          	jalr	-438(ra) # 8000314e <balloc>
    8000330c:	0005099b          	sext.w	s3,a0
    80003310:	0534a823          	sw	s3,80(s1)
    80003314:	b7e9                	j	800032de <bmap+0x5e>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    80003316:	4108                	lw	a0,0(a0)
    80003318:	00000097          	auipc	ra,0x0
    8000331c:	e36080e7          	jalr	-458(ra) # 8000314e <balloc>
    80003320:	0005059b          	sext.w	a1,a0
    80003324:	08b92023          	sw	a1,128(s2)
    80003328:	b759                	j	800032ae <bmap+0x2e>
      a[bn] = addr = balloc(ip->dev);
    8000332a:	00092503          	lw	a0,0(s2)
    8000332e:	00000097          	auipc	ra,0x0
    80003332:	e20080e7          	jalr	-480(ra) # 8000314e <balloc>
    80003336:	0005099b          	sext.w	s3,a0
    8000333a:	0134a023          	sw	s3,0(s1)
      log_write(bp);
    8000333e:	8552                	mv	a0,s4
    80003340:	00001097          	auipc	ra,0x1
    80003344:	ef8080e7          	jalr	-264(ra) # 80004238 <log_write>
    80003348:	b771                	j	800032d4 <bmap+0x54>
  panic("bmap: out of range");
    8000334a:	00005517          	auipc	a0,0x5
    8000334e:	22650513          	addi	a0,a0,550 # 80008570 <syscalls+0x120>
    80003352:	ffffd097          	auipc	ra,0xffffd
    80003356:	1de080e7          	jalr	478(ra) # 80000530 <panic>

000000008000335a <iget>:
{
    8000335a:	7179                	addi	sp,sp,-48
    8000335c:	f406                	sd	ra,40(sp)
    8000335e:	f022                	sd	s0,32(sp)
    80003360:	ec26                	sd	s1,24(sp)
    80003362:	e84a                	sd	s2,16(sp)
    80003364:	e44e                	sd	s3,8(sp)
    80003366:	e052                	sd	s4,0(sp)
    80003368:	1800                	addi	s0,sp,48
    8000336a:	89aa                	mv	s3,a0
    8000336c:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    8000336e:	0001c517          	auipc	a0,0x1c
    80003372:	45a50513          	addi	a0,a0,1114 # 8001f7c8 <itable>
    80003376:	ffffe097          	auipc	ra,0xffffe
    8000337a:	860080e7          	jalr	-1952(ra) # 80000bd6 <acquire>
  empty = 0;
    8000337e:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003380:	0001c497          	auipc	s1,0x1c
    80003384:	46048493          	addi	s1,s1,1120 # 8001f7e0 <itable+0x18>
    80003388:	0001e697          	auipc	a3,0x1e
    8000338c:	ee868693          	addi	a3,a3,-280 # 80021270 <log>
    80003390:	a039                	j	8000339e <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003392:	02090b63          	beqz	s2,800033c8 <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003396:	08848493          	addi	s1,s1,136
    8000339a:	02d48a63          	beq	s1,a3,800033ce <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    8000339e:	449c                	lw	a5,8(s1)
    800033a0:	fef059e3          	blez	a5,80003392 <iget+0x38>
    800033a4:	4098                	lw	a4,0(s1)
    800033a6:	ff3716e3          	bne	a4,s3,80003392 <iget+0x38>
    800033aa:	40d8                	lw	a4,4(s1)
    800033ac:	ff4713e3          	bne	a4,s4,80003392 <iget+0x38>
      ip->ref++;
    800033b0:	2785                	addiw	a5,a5,1
    800033b2:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    800033b4:	0001c517          	auipc	a0,0x1c
    800033b8:	41450513          	addi	a0,a0,1044 # 8001f7c8 <itable>
    800033bc:	ffffe097          	auipc	ra,0xffffe
    800033c0:	8ce080e7          	jalr	-1842(ra) # 80000c8a <release>
      return ip;
    800033c4:	8926                	mv	s2,s1
    800033c6:	a03d                	j	800033f4 <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800033c8:	f7f9                	bnez	a5,80003396 <iget+0x3c>
    800033ca:	8926                	mv	s2,s1
    800033cc:	b7e9                	j	80003396 <iget+0x3c>
  if(empty == 0)
    800033ce:	02090c63          	beqz	s2,80003406 <iget+0xac>
  ip->dev = dev;
    800033d2:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    800033d6:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    800033da:	4785                	li	a5,1
    800033dc:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    800033e0:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    800033e4:	0001c517          	auipc	a0,0x1c
    800033e8:	3e450513          	addi	a0,a0,996 # 8001f7c8 <itable>
    800033ec:	ffffe097          	auipc	ra,0xffffe
    800033f0:	89e080e7          	jalr	-1890(ra) # 80000c8a <release>
}
    800033f4:	854a                	mv	a0,s2
    800033f6:	70a2                	ld	ra,40(sp)
    800033f8:	7402                	ld	s0,32(sp)
    800033fa:	64e2                	ld	s1,24(sp)
    800033fc:	6942                	ld	s2,16(sp)
    800033fe:	69a2                	ld	s3,8(sp)
    80003400:	6a02                	ld	s4,0(sp)
    80003402:	6145                	addi	sp,sp,48
    80003404:	8082                	ret
    panic("iget: no inodes");
    80003406:	00005517          	auipc	a0,0x5
    8000340a:	18250513          	addi	a0,a0,386 # 80008588 <syscalls+0x138>
    8000340e:	ffffd097          	auipc	ra,0xffffd
    80003412:	122080e7          	jalr	290(ra) # 80000530 <panic>

0000000080003416 <fsinit>:
fsinit(int dev) {
    80003416:	7179                	addi	sp,sp,-48
    80003418:	f406                	sd	ra,40(sp)
    8000341a:	f022                	sd	s0,32(sp)
    8000341c:	ec26                	sd	s1,24(sp)
    8000341e:	e84a                	sd	s2,16(sp)
    80003420:	e44e                	sd	s3,8(sp)
    80003422:	1800                	addi	s0,sp,48
    80003424:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80003426:	4585                	li	a1,1
    80003428:	00000097          	auipc	ra,0x0
    8000342c:	a64080e7          	jalr	-1436(ra) # 80002e8c <bread>
    80003430:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003432:	0001c997          	auipc	s3,0x1c
    80003436:	37698993          	addi	s3,s3,886 # 8001f7a8 <sb>
    8000343a:	02000613          	li	a2,32
    8000343e:	05850593          	addi	a1,a0,88
    80003442:	854e                	mv	a0,s3
    80003444:	ffffe097          	auipc	ra,0xffffe
    80003448:	8ee080e7          	jalr	-1810(ra) # 80000d32 <memmove>
  brelse(bp);
    8000344c:	8526                	mv	a0,s1
    8000344e:	00000097          	auipc	ra,0x0
    80003452:	b6e080e7          	jalr	-1170(ra) # 80002fbc <brelse>
  if(sb.magic != FSMAGIC)
    80003456:	0009a703          	lw	a4,0(s3)
    8000345a:	102037b7          	lui	a5,0x10203
    8000345e:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003462:	02f71263          	bne	a4,a5,80003486 <fsinit+0x70>
  initlog(dev, &sb);
    80003466:	0001c597          	auipc	a1,0x1c
    8000346a:	34258593          	addi	a1,a1,834 # 8001f7a8 <sb>
    8000346e:	854a                	mv	a0,s2
    80003470:	00001097          	auipc	ra,0x1
    80003474:	b4c080e7          	jalr	-1204(ra) # 80003fbc <initlog>
}
    80003478:	70a2                	ld	ra,40(sp)
    8000347a:	7402                	ld	s0,32(sp)
    8000347c:	64e2                	ld	s1,24(sp)
    8000347e:	6942                	ld	s2,16(sp)
    80003480:	69a2                	ld	s3,8(sp)
    80003482:	6145                	addi	sp,sp,48
    80003484:	8082                	ret
    panic("invalid file system");
    80003486:	00005517          	auipc	a0,0x5
    8000348a:	11250513          	addi	a0,a0,274 # 80008598 <syscalls+0x148>
    8000348e:	ffffd097          	auipc	ra,0xffffd
    80003492:	0a2080e7          	jalr	162(ra) # 80000530 <panic>

0000000080003496 <iinit>:
{
    80003496:	7179                	addi	sp,sp,-48
    80003498:	f406                	sd	ra,40(sp)
    8000349a:	f022                	sd	s0,32(sp)
    8000349c:	ec26                	sd	s1,24(sp)
    8000349e:	e84a                	sd	s2,16(sp)
    800034a0:	e44e                	sd	s3,8(sp)
    800034a2:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    800034a4:	00005597          	auipc	a1,0x5
    800034a8:	10c58593          	addi	a1,a1,268 # 800085b0 <syscalls+0x160>
    800034ac:	0001c517          	auipc	a0,0x1c
    800034b0:	31c50513          	addi	a0,a0,796 # 8001f7c8 <itable>
    800034b4:	ffffd097          	auipc	ra,0xffffd
    800034b8:	692080e7          	jalr	1682(ra) # 80000b46 <initlock>
  for(i = 0; i < NINODE; i++) {
    800034bc:	0001c497          	auipc	s1,0x1c
    800034c0:	33448493          	addi	s1,s1,820 # 8001f7f0 <itable+0x28>
    800034c4:	0001e997          	auipc	s3,0x1e
    800034c8:	dbc98993          	addi	s3,s3,-580 # 80021280 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    800034cc:	00005917          	auipc	s2,0x5
    800034d0:	0ec90913          	addi	s2,s2,236 # 800085b8 <syscalls+0x168>
    800034d4:	85ca                	mv	a1,s2
    800034d6:	8526                	mv	a0,s1
    800034d8:	00001097          	auipc	ra,0x1
    800034dc:	e46080e7          	jalr	-442(ra) # 8000431e <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    800034e0:	08848493          	addi	s1,s1,136
    800034e4:	ff3498e3          	bne	s1,s3,800034d4 <iinit+0x3e>
}
    800034e8:	70a2                	ld	ra,40(sp)
    800034ea:	7402                	ld	s0,32(sp)
    800034ec:	64e2                	ld	s1,24(sp)
    800034ee:	6942                	ld	s2,16(sp)
    800034f0:	69a2                	ld	s3,8(sp)
    800034f2:	6145                	addi	sp,sp,48
    800034f4:	8082                	ret

00000000800034f6 <ialloc>:
{
    800034f6:	715d                	addi	sp,sp,-80
    800034f8:	e486                	sd	ra,72(sp)
    800034fa:	e0a2                	sd	s0,64(sp)
    800034fc:	fc26                	sd	s1,56(sp)
    800034fe:	f84a                	sd	s2,48(sp)
    80003500:	f44e                	sd	s3,40(sp)
    80003502:	f052                	sd	s4,32(sp)
    80003504:	ec56                	sd	s5,24(sp)
    80003506:	e85a                	sd	s6,16(sp)
    80003508:	e45e                	sd	s7,8(sp)
    8000350a:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    8000350c:	0001c717          	auipc	a4,0x1c
    80003510:	2a872703          	lw	a4,680(a4) # 8001f7b4 <sb+0xc>
    80003514:	4785                	li	a5,1
    80003516:	04e7fa63          	bgeu	a5,a4,8000356a <ialloc+0x74>
    8000351a:	8aaa                	mv	s5,a0
    8000351c:	8bae                	mv	s7,a1
    8000351e:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    80003520:	0001ca17          	auipc	s4,0x1c
    80003524:	288a0a13          	addi	s4,s4,648 # 8001f7a8 <sb>
    80003528:	00048b1b          	sext.w	s6,s1
    8000352c:	0044d593          	srli	a1,s1,0x4
    80003530:	018a2783          	lw	a5,24(s4)
    80003534:	9dbd                	addw	a1,a1,a5
    80003536:	8556                	mv	a0,s5
    80003538:	00000097          	auipc	ra,0x0
    8000353c:	954080e7          	jalr	-1708(ra) # 80002e8c <bread>
    80003540:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80003542:	05850993          	addi	s3,a0,88
    80003546:	00f4f793          	andi	a5,s1,15
    8000354a:	079a                	slli	a5,a5,0x6
    8000354c:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    8000354e:	00099783          	lh	a5,0(s3)
    80003552:	c785                	beqz	a5,8000357a <ialloc+0x84>
    brelse(bp);
    80003554:	00000097          	auipc	ra,0x0
    80003558:	a68080e7          	jalr	-1432(ra) # 80002fbc <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    8000355c:	0485                	addi	s1,s1,1
    8000355e:	00ca2703          	lw	a4,12(s4)
    80003562:	0004879b          	sext.w	a5,s1
    80003566:	fce7e1e3          	bltu	a5,a4,80003528 <ialloc+0x32>
  panic("ialloc: no inodes");
    8000356a:	00005517          	auipc	a0,0x5
    8000356e:	05650513          	addi	a0,a0,86 # 800085c0 <syscalls+0x170>
    80003572:	ffffd097          	auipc	ra,0xffffd
    80003576:	fbe080e7          	jalr	-66(ra) # 80000530 <panic>
      memset(dip, 0, sizeof(*dip));
    8000357a:	04000613          	li	a2,64
    8000357e:	4581                	li	a1,0
    80003580:	854e                	mv	a0,s3
    80003582:	ffffd097          	auipc	ra,0xffffd
    80003586:	750080e7          	jalr	1872(ra) # 80000cd2 <memset>
      dip->type = type;
    8000358a:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    8000358e:	854a                	mv	a0,s2
    80003590:	00001097          	auipc	ra,0x1
    80003594:	ca8080e7          	jalr	-856(ra) # 80004238 <log_write>
      brelse(bp);
    80003598:	854a                	mv	a0,s2
    8000359a:	00000097          	auipc	ra,0x0
    8000359e:	a22080e7          	jalr	-1502(ra) # 80002fbc <brelse>
      return iget(dev, inum);
    800035a2:	85da                	mv	a1,s6
    800035a4:	8556                	mv	a0,s5
    800035a6:	00000097          	auipc	ra,0x0
    800035aa:	db4080e7          	jalr	-588(ra) # 8000335a <iget>
}
    800035ae:	60a6                	ld	ra,72(sp)
    800035b0:	6406                	ld	s0,64(sp)
    800035b2:	74e2                	ld	s1,56(sp)
    800035b4:	7942                	ld	s2,48(sp)
    800035b6:	79a2                	ld	s3,40(sp)
    800035b8:	7a02                	ld	s4,32(sp)
    800035ba:	6ae2                	ld	s5,24(sp)
    800035bc:	6b42                	ld	s6,16(sp)
    800035be:	6ba2                	ld	s7,8(sp)
    800035c0:	6161                	addi	sp,sp,80
    800035c2:	8082                	ret

00000000800035c4 <iupdate>:
{
    800035c4:	1101                	addi	sp,sp,-32
    800035c6:	ec06                	sd	ra,24(sp)
    800035c8:	e822                	sd	s0,16(sp)
    800035ca:	e426                	sd	s1,8(sp)
    800035cc:	e04a                	sd	s2,0(sp)
    800035ce:	1000                	addi	s0,sp,32
    800035d0:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800035d2:	415c                	lw	a5,4(a0)
    800035d4:	0047d79b          	srliw	a5,a5,0x4
    800035d8:	0001c597          	auipc	a1,0x1c
    800035dc:	1e85a583          	lw	a1,488(a1) # 8001f7c0 <sb+0x18>
    800035e0:	9dbd                	addw	a1,a1,a5
    800035e2:	4108                	lw	a0,0(a0)
    800035e4:	00000097          	auipc	ra,0x0
    800035e8:	8a8080e7          	jalr	-1880(ra) # 80002e8c <bread>
    800035ec:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    800035ee:	05850793          	addi	a5,a0,88
    800035f2:	40c8                	lw	a0,4(s1)
    800035f4:	893d                	andi	a0,a0,15
    800035f6:	051a                	slli	a0,a0,0x6
    800035f8:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    800035fa:	04449703          	lh	a4,68(s1)
    800035fe:	00e51023          	sh	a4,0(a0)
  dip->major = ip->major;
    80003602:	04649703          	lh	a4,70(s1)
    80003606:	00e51123          	sh	a4,2(a0)
  dip->minor = ip->minor;
    8000360a:	04849703          	lh	a4,72(s1)
    8000360e:	00e51223          	sh	a4,4(a0)
  dip->nlink = ip->nlink;
    80003612:	04a49703          	lh	a4,74(s1)
    80003616:	00e51323          	sh	a4,6(a0)
  dip->size = ip->size;
    8000361a:	44f8                	lw	a4,76(s1)
    8000361c:	c518                	sw	a4,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    8000361e:	03400613          	li	a2,52
    80003622:	05048593          	addi	a1,s1,80
    80003626:	0531                	addi	a0,a0,12
    80003628:	ffffd097          	auipc	ra,0xffffd
    8000362c:	70a080e7          	jalr	1802(ra) # 80000d32 <memmove>
  log_write(bp);
    80003630:	854a                	mv	a0,s2
    80003632:	00001097          	auipc	ra,0x1
    80003636:	c06080e7          	jalr	-1018(ra) # 80004238 <log_write>
  brelse(bp);
    8000363a:	854a                	mv	a0,s2
    8000363c:	00000097          	auipc	ra,0x0
    80003640:	980080e7          	jalr	-1664(ra) # 80002fbc <brelse>
}
    80003644:	60e2                	ld	ra,24(sp)
    80003646:	6442                	ld	s0,16(sp)
    80003648:	64a2                	ld	s1,8(sp)
    8000364a:	6902                	ld	s2,0(sp)
    8000364c:	6105                	addi	sp,sp,32
    8000364e:	8082                	ret

0000000080003650 <idup>:
{
    80003650:	1101                	addi	sp,sp,-32
    80003652:	ec06                	sd	ra,24(sp)
    80003654:	e822                	sd	s0,16(sp)
    80003656:	e426                	sd	s1,8(sp)
    80003658:	1000                	addi	s0,sp,32
    8000365a:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    8000365c:	0001c517          	auipc	a0,0x1c
    80003660:	16c50513          	addi	a0,a0,364 # 8001f7c8 <itable>
    80003664:	ffffd097          	auipc	ra,0xffffd
    80003668:	572080e7          	jalr	1394(ra) # 80000bd6 <acquire>
  ip->ref++;
    8000366c:	449c                	lw	a5,8(s1)
    8000366e:	2785                	addiw	a5,a5,1
    80003670:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003672:	0001c517          	auipc	a0,0x1c
    80003676:	15650513          	addi	a0,a0,342 # 8001f7c8 <itable>
    8000367a:	ffffd097          	auipc	ra,0xffffd
    8000367e:	610080e7          	jalr	1552(ra) # 80000c8a <release>
}
    80003682:	8526                	mv	a0,s1
    80003684:	60e2                	ld	ra,24(sp)
    80003686:	6442                	ld	s0,16(sp)
    80003688:	64a2                	ld	s1,8(sp)
    8000368a:	6105                	addi	sp,sp,32
    8000368c:	8082                	ret

000000008000368e <ilock>:
{
    8000368e:	1101                	addi	sp,sp,-32
    80003690:	ec06                	sd	ra,24(sp)
    80003692:	e822                	sd	s0,16(sp)
    80003694:	e426                	sd	s1,8(sp)
    80003696:	e04a                	sd	s2,0(sp)
    80003698:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    8000369a:	c115                	beqz	a0,800036be <ilock+0x30>
    8000369c:	84aa                	mv	s1,a0
    8000369e:	451c                	lw	a5,8(a0)
    800036a0:	00f05f63          	blez	a5,800036be <ilock+0x30>
  acquiresleep(&ip->lock);
    800036a4:	0541                	addi	a0,a0,16
    800036a6:	00001097          	auipc	ra,0x1
    800036aa:	cb2080e7          	jalr	-846(ra) # 80004358 <acquiresleep>
  if(ip->valid == 0){
    800036ae:	40bc                	lw	a5,64(s1)
    800036b0:	cf99                	beqz	a5,800036ce <ilock+0x40>
}
    800036b2:	60e2                	ld	ra,24(sp)
    800036b4:	6442                	ld	s0,16(sp)
    800036b6:	64a2                	ld	s1,8(sp)
    800036b8:	6902                	ld	s2,0(sp)
    800036ba:	6105                	addi	sp,sp,32
    800036bc:	8082                	ret
    panic("ilock");
    800036be:	00005517          	auipc	a0,0x5
    800036c2:	f1a50513          	addi	a0,a0,-230 # 800085d8 <syscalls+0x188>
    800036c6:	ffffd097          	auipc	ra,0xffffd
    800036ca:	e6a080e7          	jalr	-406(ra) # 80000530 <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800036ce:	40dc                	lw	a5,4(s1)
    800036d0:	0047d79b          	srliw	a5,a5,0x4
    800036d4:	0001c597          	auipc	a1,0x1c
    800036d8:	0ec5a583          	lw	a1,236(a1) # 8001f7c0 <sb+0x18>
    800036dc:	9dbd                	addw	a1,a1,a5
    800036de:	4088                	lw	a0,0(s1)
    800036e0:	fffff097          	auipc	ra,0xfffff
    800036e4:	7ac080e7          	jalr	1964(ra) # 80002e8c <bread>
    800036e8:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    800036ea:	05850593          	addi	a1,a0,88
    800036ee:	40dc                	lw	a5,4(s1)
    800036f0:	8bbd                	andi	a5,a5,15
    800036f2:	079a                	slli	a5,a5,0x6
    800036f4:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    800036f6:	00059783          	lh	a5,0(a1)
    800036fa:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    800036fe:	00259783          	lh	a5,2(a1)
    80003702:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003706:	00459783          	lh	a5,4(a1)
    8000370a:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    8000370e:	00659783          	lh	a5,6(a1)
    80003712:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003716:	459c                	lw	a5,8(a1)
    80003718:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    8000371a:	03400613          	li	a2,52
    8000371e:	05b1                	addi	a1,a1,12
    80003720:	05048513          	addi	a0,s1,80
    80003724:	ffffd097          	auipc	ra,0xffffd
    80003728:	60e080e7          	jalr	1550(ra) # 80000d32 <memmove>
    brelse(bp);
    8000372c:	854a                	mv	a0,s2
    8000372e:	00000097          	auipc	ra,0x0
    80003732:	88e080e7          	jalr	-1906(ra) # 80002fbc <brelse>
    ip->valid = 1;
    80003736:	4785                	li	a5,1
    80003738:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    8000373a:	04449783          	lh	a5,68(s1)
    8000373e:	fbb5                	bnez	a5,800036b2 <ilock+0x24>
      panic("ilock: no type");
    80003740:	00005517          	auipc	a0,0x5
    80003744:	ea050513          	addi	a0,a0,-352 # 800085e0 <syscalls+0x190>
    80003748:	ffffd097          	auipc	ra,0xffffd
    8000374c:	de8080e7          	jalr	-536(ra) # 80000530 <panic>

0000000080003750 <iunlock>:
{
    80003750:	1101                	addi	sp,sp,-32
    80003752:	ec06                	sd	ra,24(sp)
    80003754:	e822                	sd	s0,16(sp)
    80003756:	e426                	sd	s1,8(sp)
    80003758:	e04a                	sd	s2,0(sp)
    8000375a:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    8000375c:	c905                	beqz	a0,8000378c <iunlock+0x3c>
    8000375e:	84aa                	mv	s1,a0
    80003760:	01050913          	addi	s2,a0,16
    80003764:	854a                	mv	a0,s2
    80003766:	00001097          	auipc	ra,0x1
    8000376a:	c8c080e7          	jalr	-884(ra) # 800043f2 <holdingsleep>
    8000376e:	cd19                	beqz	a0,8000378c <iunlock+0x3c>
    80003770:	449c                	lw	a5,8(s1)
    80003772:	00f05d63          	blez	a5,8000378c <iunlock+0x3c>
  releasesleep(&ip->lock);
    80003776:	854a                	mv	a0,s2
    80003778:	00001097          	auipc	ra,0x1
    8000377c:	c36080e7          	jalr	-970(ra) # 800043ae <releasesleep>
}
    80003780:	60e2                	ld	ra,24(sp)
    80003782:	6442                	ld	s0,16(sp)
    80003784:	64a2                	ld	s1,8(sp)
    80003786:	6902                	ld	s2,0(sp)
    80003788:	6105                	addi	sp,sp,32
    8000378a:	8082                	ret
    panic("iunlock");
    8000378c:	00005517          	auipc	a0,0x5
    80003790:	e6450513          	addi	a0,a0,-412 # 800085f0 <syscalls+0x1a0>
    80003794:	ffffd097          	auipc	ra,0xffffd
    80003798:	d9c080e7          	jalr	-612(ra) # 80000530 <panic>

000000008000379c <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    8000379c:	7179                	addi	sp,sp,-48
    8000379e:	f406                	sd	ra,40(sp)
    800037a0:	f022                	sd	s0,32(sp)
    800037a2:	ec26                	sd	s1,24(sp)
    800037a4:	e84a                	sd	s2,16(sp)
    800037a6:	e44e                	sd	s3,8(sp)
    800037a8:	e052                	sd	s4,0(sp)
    800037aa:	1800                	addi	s0,sp,48
    800037ac:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    800037ae:	05050493          	addi	s1,a0,80
    800037b2:	08050913          	addi	s2,a0,128
    800037b6:	a021                	j	800037be <itrunc+0x22>
    800037b8:	0491                	addi	s1,s1,4
    800037ba:	01248d63          	beq	s1,s2,800037d4 <itrunc+0x38>
    if(ip->addrs[i]){
    800037be:	408c                	lw	a1,0(s1)
    800037c0:	dde5                	beqz	a1,800037b8 <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    800037c2:	0009a503          	lw	a0,0(s3)
    800037c6:	00000097          	auipc	ra,0x0
    800037ca:	90c080e7          	jalr	-1780(ra) # 800030d2 <bfree>
      ip->addrs[i] = 0;
    800037ce:	0004a023          	sw	zero,0(s1)
    800037d2:	b7dd                	j	800037b8 <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    800037d4:	0809a583          	lw	a1,128(s3)
    800037d8:	e185                	bnez	a1,800037f8 <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    800037da:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    800037de:	854e                	mv	a0,s3
    800037e0:	00000097          	auipc	ra,0x0
    800037e4:	de4080e7          	jalr	-540(ra) # 800035c4 <iupdate>
}
    800037e8:	70a2                	ld	ra,40(sp)
    800037ea:	7402                	ld	s0,32(sp)
    800037ec:	64e2                	ld	s1,24(sp)
    800037ee:	6942                	ld	s2,16(sp)
    800037f0:	69a2                	ld	s3,8(sp)
    800037f2:	6a02                	ld	s4,0(sp)
    800037f4:	6145                	addi	sp,sp,48
    800037f6:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    800037f8:	0009a503          	lw	a0,0(s3)
    800037fc:	fffff097          	auipc	ra,0xfffff
    80003800:	690080e7          	jalr	1680(ra) # 80002e8c <bread>
    80003804:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003806:	05850493          	addi	s1,a0,88
    8000380a:	45850913          	addi	s2,a0,1112
    8000380e:	a811                	j	80003822 <itrunc+0x86>
        bfree(ip->dev, a[j]);
    80003810:	0009a503          	lw	a0,0(s3)
    80003814:	00000097          	auipc	ra,0x0
    80003818:	8be080e7          	jalr	-1858(ra) # 800030d2 <bfree>
    for(j = 0; j < NINDIRECT; j++){
    8000381c:	0491                	addi	s1,s1,4
    8000381e:	01248563          	beq	s1,s2,80003828 <itrunc+0x8c>
      if(a[j])
    80003822:	408c                	lw	a1,0(s1)
    80003824:	dde5                	beqz	a1,8000381c <itrunc+0x80>
    80003826:	b7ed                	j	80003810 <itrunc+0x74>
    brelse(bp);
    80003828:	8552                	mv	a0,s4
    8000382a:	fffff097          	auipc	ra,0xfffff
    8000382e:	792080e7          	jalr	1938(ra) # 80002fbc <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003832:	0809a583          	lw	a1,128(s3)
    80003836:	0009a503          	lw	a0,0(s3)
    8000383a:	00000097          	auipc	ra,0x0
    8000383e:	898080e7          	jalr	-1896(ra) # 800030d2 <bfree>
    ip->addrs[NDIRECT] = 0;
    80003842:	0809a023          	sw	zero,128(s3)
    80003846:	bf51                	j	800037da <itrunc+0x3e>

0000000080003848 <iput>:
{
    80003848:	1101                	addi	sp,sp,-32
    8000384a:	ec06                	sd	ra,24(sp)
    8000384c:	e822                	sd	s0,16(sp)
    8000384e:	e426                	sd	s1,8(sp)
    80003850:	e04a                	sd	s2,0(sp)
    80003852:	1000                	addi	s0,sp,32
    80003854:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003856:	0001c517          	auipc	a0,0x1c
    8000385a:	f7250513          	addi	a0,a0,-142 # 8001f7c8 <itable>
    8000385e:	ffffd097          	auipc	ra,0xffffd
    80003862:	378080e7          	jalr	888(ra) # 80000bd6 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003866:	4498                	lw	a4,8(s1)
    80003868:	4785                	li	a5,1
    8000386a:	02f70363          	beq	a4,a5,80003890 <iput+0x48>
  ip->ref--;
    8000386e:	449c                	lw	a5,8(s1)
    80003870:	37fd                	addiw	a5,a5,-1
    80003872:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003874:	0001c517          	auipc	a0,0x1c
    80003878:	f5450513          	addi	a0,a0,-172 # 8001f7c8 <itable>
    8000387c:	ffffd097          	auipc	ra,0xffffd
    80003880:	40e080e7          	jalr	1038(ra) # 80000c8a <release>
}
    80003884:	60e2                	ld	ra,24(sp)
    80003886:	6442                	ld	s0,16(sp)
    80003888:	64a2                	ld	s1,8(sp)
    8000388a:	6902                	ld	s2,0(sp)
    8000388c:	6105                	addi	sp,sp,32
    8000388e:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003890:	40bc                	lw	a5,64(s1)
    80003892:	dff1                	beqz	a5,8000386e <iput+0x26>
    80003894:	04a49783          	lh	a5,74(s1)
    80003898:	fbf9                	bnez	a5,8000386e <iput+0x26>
    acquiresleep(&ip->lock);
    8000389a:	01048913          	addi	s2,s1,16
    8000389e:	854a                	mv	a0,s2
    800038a0:	00001097          	auipc	ra,0x1
    800038a4:	ab8080e7          	jalr	-1352(ra) # 80004358 <acquiresleep>
    release(&itable.lock);
    800038a8:	0001c517          	auipc	a0,0x1c
    800038ac:	f2050513          	addi	a0,a0,-224 # 8001f7c8 <itable>
    800038b0:	ffffd097          	auipc	ra,0xffffd
    800038b4:	3da080e7          	jalr	986(ra) # 80000c8a <release>
    itrunc(ip);
    800038b8:	8526                	mv	a0,s1
    800038ba:	00000097          	auipc	ra,0x0
    800038be:	ee2080e7          	jalr	-286(ra) # 8000379c <itrunc>
    ip->type = 0;
    800038c2:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    800038c6:	8526                	mv	a0,s1
    800038c8:	00000097          	auipc	ra,0x0
    800038cc:	cfc080e7          	jalr	-772(ra) # 800035c4 <iupdate>
    ip->valid = 0;
    800038d0:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    800038d4:	854a                	mv	a0,s2
    800038d6:	00001097          	auipc	ra,0x1
    800038da:	ad8080e7          	jalr	-1320(ra) # 800043ae <releasesleep>
    acquire(&itable.lock);
    800038de:	0001c517          	auipc	a0,0x1c
    800038e2:	eea50513          	addi	a0,a0,-278 # 8001f7c8 <itable>
    800038e6:	ffffd097          	auipc	ra,0xffffd
    800038ea:	2f0080e7          	jalr	752(ra) # 80000bd6 <acquire>
    800038ee:	b741                	j	8000386e <iput+0x26>

00000000800038f0 <iunlockput>:
{
    800038f0:	1101                	addi	sp,sp,-32
    800038f2:	ec06                	sd	ra,24(sp)
    800038f4:	e822                	sd	s0,16(sp)
    800038f6:	e426                	sd	s1,8(sp)
    800038f8:	1000                	addi	s0,sp,32
    800038fa:	84aa                	mv	s1,a0
  iunlock(ip);
    800038fc:	00000097          	auipc	ra,0x0
    80003900:	e54080e7          	jalr	-428(ra) # 80003750 <iunlock>
  iput(ip);
    80003904:	8526                	mv	a0,s1
    80003906:	00000097          	auipc	ra,0x0
    8000390a:	f42080e7          	jalr	-190(ra) # 80003848 <iput>
}
    8000390e:	60e2                	ld	ra,24(sp)
    80003910:	6442                	ld	s0,16(sp)
    80003912:	64a2                	ld	s1,8(sp)
    80003914:	6105                	addi	sp,sp,32
    80003916:	8082                	ret

0000000080003918 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003918:	1141                	addi	sp,sp,-16
    8000391a:	e422                	sd	s0,8(sp)
    8000391c:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    8000391e:	411c                	lw	a5,0(a0)
    80003920:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003922:	415c                	lw	a5,4(a0)
    80003924:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003926:	04451783          	lh	a5,68(a0)
    8000392a:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    8000392e:	04a51783          	lh	a5,74(a0)
    80003932:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003936:	04c56783          	lwu	a5,76(a0)
    8000393a:	e99c                	sd	a5,16(a1)
}
    8000393c:	6422                	ld	s0,8(sp)
    8000393e:	0141                	addi	sp,sp,16
    80003940:	8082                	ret

0000000080003942 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003942:	457c                	lw	a5,76(a0)
    80003944:	0ed7e963          	bltu	a5,a3,80003a36 <readi+0xf4>
{
    80003948:	7159                	addi	sp,sp,-112
    8000394a:	f486                	sd	ra,104(sp)
    8000394c:	f0a2                	sd	s0,96(sp)
    8000394e:	eca6                	sd	s1,88(sp)
    80003950:	e8ca                	sd	s2,80(sp)
    80003952:	e4ce                	sd	s3,72(sp)
    80003954:	e0d2                	sd	s4,64(sp)
    80003956:	fc56                	sd	s5,56(sp)
    80003958:	f85a                	sd	s6,48(sp)
    8000395a:	f45e                	sd	s7,40(sp)
    8000395c:	f062                	sd	s8,32(sp)
    8000395e:	ec66                	sd	s9,24(sp)
    80003960:	e86a                	sd	s10,16(sp)
    80003962:	e46e                	sd	s11,8(sp)
    80003964:	1880                	addi	s0,sp,112
    80003966:	8baa                	mv	s7,a0
    80003968:	8c2e                	mv	s8,a1
    8000396a:	8ab2                	mv	s5,a2
    8000396c:	84b6                	mv	s1,a3
    8000396e:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003970:	9f35                	addw	a4,a4,a3
    return 0;
    80003972:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003974:	0ad76063          	bltu	a4,a3,80003a14 <readi+0xd2>
  if(off + n > ip->size)
    80003978:	00e7f463          	bgeu	a5,a4,80003980 <readi+0x3e>
    n = ip->size - off;
    8000397c:	40d78b3b          	subw	s6,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003980:	0a0b0963          	beqz	s6,80003a32 <readi+0xf0>
    80003984:	4981                	li	s3,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80003986:	40000d13          	li	s10,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    8000398a:	5cfd                	li	s9,-1
    8000398c:	a82d                	j	800039c6 <readi+0x84>
    8000398e:	020a1d93          	slli	s11,s4,0x20
    80003992:	020ddd93          	srli	s11,s11,0x20
    80003996:	05890613          	addi	a2,s2,88
    8000399a:	86ee                	mv	a3,s11
    8000399c:	963a                	add	a2,a2,a4
    8000399e:	85d6                	mv	a1,s5
    800039a0:	8562                	mv	a0,s8
    800039a2:	fffff097          	auipc	ra,0xfffff
    800039a6:	b08080e7          	jalr	-1272(ra) # 800024aa <either_copyout>
    800039aa:	05950d63          	beq	a0,s9,80003a04 <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    800039ae:	854a                	mv	a0,s2
    800039b0:	fffff097          	auipc	ra,0xfffff
    800039b4:	60c080e7          	jalr	1548(ra) # 80002fbc <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800039b8:	013a09bb          	addw	s3,s4,s3
    800039bc:	009a04bb          	addw	s1,s4,s1
    800039c0:	9aee                	add	s5,s5,s11
    800039c2:	0569f763          	bgeu	s3,s6,80003a10 <readi+0xce>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    800039c6:	000ba903          	lw	s2,0(s7)
    800039ca:	00a4d59b          	srliw	a1,s1,0xa
    800039ce:	855e                	mv	a0,s7
    800039d0:	00000097          	auipc	ra,0x0
    800039d4:	8b0080e7          	jalr	-1872(ra) # 80003280 <bmap>
    800039d8:	0005059b          	sext.w	a1,a0
    800039dc:	854a                	mv	a0,s2
    800039de:	fffff097          	auipc	ra,0xfffff
    800039e2:	4ae080e7          	jalr	1198(ra) # 80002e8c <bread>
    800039e6:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    800039e8:	3ff4f713          	andi	a4,s1,1023
    800039ec:	40ed07bb          	subw	a5,s10,a4
    800039f0:	413b06bb          	subw	a3,s6,s3
    800039f4:	8a3e                	mv	s4,a5
    800039f6:	2781                	sext.w	a5,a5
    800039f8:	0006861b          	sext.w	a2,a3
    800039fc:	f8f679e3          	bgeu	a2,a5,8000398e <readi+0x4c>
    80003a00:	8a36                	mv	s4,a3
    80003a02:	b771                	j	8000398e <readi+0x4c>
      brelse(bp);
    80003a04:	854a                	mv	a0,s2
    80003a06:	fffff097          	auipc	ra,0xfffff
    80003a0a:	5b6080e7          	jalr	1462(ra) # 80002fbc <brelse>
      tot = -1;
    80003a0e:	59fd                	li	s3,-1
  }
  return tot;
    80003a10:	0009851b          	sext.w	a0,s3
}
    80003a14:	70a6                	ld	ra,104(sp)
    80003a16:	7406                	ld	s0,96(sp)
    80003a18:	64e6                	ld	s1,88(sp)
    80003a1a:	6946                	ld	s2,80(sp)
    80003a1c:	69a6                	ld	s3,72(sp)
    80003a1e:	6a06                	ld	s4,64(sp)
    80003a20:	7ae2                	ld	s5,56(sp)
    80003a22:	7b42                	ld	s6,48(sp)
    80003a24:	7ba2                	ld	s7,40(sp)
    80003a26:	7c02                	ld	s8,32(sp)
    80003a28:	6ce2                	ld	s9,24(sp)
    80003a2a:	6d42                	ld	s10,16(sp)
    80003a2c:	6da2                	ld	s11,8(sp)
    80003a2e:	6165                	addi	sp,sp,112
    80003a30:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003a32:	89da                	mv	s3,s6
    80003a34:	bff1                	j	80003a10 <readi+0xce>
    return 0;
    80003a36:	4501                	li	a0,0
}
    80003a38:	8082                	ret

0000000080003a3a <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003a3a:	457c                	lw	a5,76(a0)
    80003a3c:	10d7e863          	bltu	a5,a3,80003b4c <writei+0x112>
{
    80003a40:	7159                	addi	sp,sp,-112
    80003a42:	f486                	sd	ra,104(sp)
    80003a44:	f0a2                	sd	s0,96(sp)
    80003a46:	eca6                	sd	s1,88(sp)
    80003a48:	e8ca                	sd	s2,80(sp)
    80003a4a:	e4ce                	sd	s3,72(sp)
    80003a4c:	e0d2                	sd	s4,64(sp)
    80003a4e:	fc56                	sd	s5,56(sp)
    80003a50:	f85a                	sd	s6,48(sp)
    80003a52:	f45e                	sd	s7,40(sp)
    80003a54:	f062                	sd	s8,32(sp)
    80003a56:	ec66                	sd	s9,24(sp)
    80003a58:	e86a                	sd	s10,16(sp)
    80003a5a:	e46e                	sd	s11,8(sp)
    80003a5c:	1880                	addi	s0,sp,112
    80003a5e:	8b2a                	mv	s6,a0
    80003a60:	8c2e                	mv	s8,a1
    80003a62:	8ab2                	mv	s5,a2
    80003a64:	8936                	mv	s2,a3
    80003a66:	8bba                	mv	s7,a4
  if(off > ip->size || off + n < off)
    80003a68:	00e687bb          	addw	a5,a3,a4
    80003a6c:	0ed7e263          	bltu	a5,a3,80003b50 <writei+0x116>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003a70:	00043737          	lui	a4,0x43
    80003a74:	0ef76063          	bltu	a4,a5,80003b54 <writei+0x11a>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003a78:	0c0b8863          	beqz	s7,80003b48 <writei+0x10e>
    80003a7c:	4a01                	li	s4,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80003a7e:	40000d13          	li	s10,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003a82:	5cfd                	li	s9,-1
    80003a84:	a091                	j	80003ac8 <writei+0x8e>
    80003a86:	02099d93          	slli	s11,s3,0x20
    80003a8a:	020ddd93          	srli	s11,s11,0x20
    80003a8e:	05848513          	addi	a0,s1,88
    80003a92:	86ee                	mv	a3,s11
    80003a94:	8656                	mv	a2,s5
    80003a96:	85e2                	mv	a1,s8
    80003a98:	953a                	add	a0,a0,a4
    80003a9a:	fffff097          	auipc	ra,0xfffff
    80003a9e:	a66080e7          	jalr	-1434(ra) # 80002500 <either_copyin>
    80003aa2:	07950263          	beq	a0,s9,80003b06 <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003aa6:	8526                	mv	a0,s1
    80003aa8:	00000097          	auipc	ra,0x0
    80003aac:	790080e7          	jalr	1936(ra) # 80004238 <log_write>
    brelse(bp);
    80003ab0:	8526                	mv	a0,s1
    80003ab2:	fffff097          	auipc	ra,0xfffff
    80003ab6:	50a080e7          	jalr	1290(ra) # 80002fbc <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003aba:	01498a3b          	addw	s4,s3,s4
    80003abe:	0129893b          	addw	s2,s3,s2
    80003ac2:	9aee                	add	s5,s5,s11
    80003ac4:	057a7663          	bgeu	s4,s7,80003b10 <writei+0xd6>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80003ac8:	000b2483          	lw	s1,0(s6)
    80003acc:	00a9559b          	srliw	a1,s2,0xa
    80003ad0:	855a                	mv	a0,s6
    80003ad2:	fffff097          	auipc	ra,0xfffff
    80003ad6:	7ae080e7          	jalr	1966(ra) # 80003280 <bmap>
    80003ada:	0005059b          	sext.w	a1,a0
    80003ade:	8526                	mv	a0,s1
    80003ae0:	fffff097          	auipc	ra,0xfffff
    80003ae4:	3ac080e7          	jalr	940(ra) # 80002e8c <bread>
    80003ae8:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003aea:	3ff97713          	andi	a4,s2,1023
    80003aee:	40ed07bb          	subw	a5,s10,a4
    80003af2:	414b86bb          	subw	a3,s7,s4
    80003af6:	89be                	mv	s3,a5
    80003af8:	2781                	sext.w	a5,a5
    80003afa:	0006861b          	sext.w	a2,a3
    80003afe:	f8f674e3          	bgeu	a2,a5,80003a86 <writei+0x4c>
    80003b02:	89b6                	mv	s3,a3
    80003b04:	b749                	j	80003a86 <writei+0x4c>
      brelse(bp);
    80003b06:	8526                	mv	a0,s1
    80003b08:	fffff097          	auipc	ra,0xfffff
    80003b0c:	4b4080e7          	jalr	1204(ra) # 80002fbc <brelse>
  }

  if(off > ip->size)
    80003b10:	04cb2783          	lw	a5,76(s6)
    80003b14:	0127f463          	bgeu	a5,s2,80003b1c <writei+0xe2>
    ip->size = off;
    80003b18:	052b2623          	sw	s2,76(s6)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80003b1c:	855a                	mv	a0,s6
    80003b1e:	00000097          	auipc	ra,0x0
    80003b22:	aa6080e7          	jalr	-1370(ra) # 800035c4 <iupdate>

  return tot;
    80003b26:	000a051b          	sext.w	a0,s4
}
    80003b2a:	70a6                	ld	ra,104(sp)
    80003b2c:	7406                	ld	s0,96(sp)
    80003b2e:	64e6                	ld	s1,88(sp)
    80003b30:	6946                	ld	s2,80(sp)
    80003b32:	69a6                	ld	s3,72(sp)
    80003b34:	6a06                	ld	s4,64(sp)
    80003b36:	7ae2                	ld	s5,56(sp)
    80003b38:	7b42                	ld	s6,48(sp)
    80003b3a:	7ba2                	ld	s7,40(sp)
    80003b3c:	7c02                	ld	s8,32(sp)
    80003b3e:	6ce2                	ld	s9,24(sp)
    80003b40:	6d42                	ld	s10,16(sp)
    80003b42:	6da2                	ld	s11,8(sp)
    80003b44:	6165                	addi	sp,sp,112
    80003b46:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003b48:	8a5e                	mv	s4,s7
    80003b4a:	bfc9                	j	80003b1c <writei+0xe2>
    return -1;
    80003b4c:	557d                	li	a0,-1
}
    80003b4e:	8082                	ret
    return -1;
    80003b50:	557d                	li	a0,-1
    80003b52:	bfe1                	j	80003b2a <writei+0xf0>
    return -1;
    80003b54:	557d                	li	a0,-1
    80003b56:	bfd1                	j	80003b2a <writei+0xf0>

0000000080003b58 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003b58:	1141                	addi	sp,sp,-16
    80003b5a:	e406                	sd	ra,8(sp)
    80003b5c:	e022                	sd	s0,0(sp)
    80003b5e:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003b60:	4639                	li	a2,14
    80003b62:	ffffd097          	auipc	ra,0xffffd
    80003b66:	24c080e7          	jalr	588(ra) # 80000dae <strncmp>
}
    80003b6a:	60a2                	ld	ra,8(sp)
    80003b6c:	6402                	ld	s0,0(sp)
    80003b6e:	0141                	addi	sp,sp,16
    80003b70:	8082                	ret

0000000080003b72 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003b72:	7139                	addi	sp,sp,-64
    80003b74:	fc06                	sd	ra,56(sp)
    80003b76:	f822                	sd	s0,48(sp)
    80003b78:	f426                	sd	s1,40(sp)
    80003b7a:	f04a                	sd	s2,32(sp)
    80003b7c:	ec4e                	sd	s3,24(sp)
    80003b7e:	e852                	sd	s4,16(sp)
    80003b80:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003b82:	04451703          	lh	a4,68(a0)
    80003b86:	4785                	li	a5,1
    80003b88:	00f71a63          	bne	a4,a5,80003b9c <dirlookup+0x2a>
    80003b8c:	892a                	mv	s2,a0
    80003b8e:	89ae                	mv	s3,a1
    80003b90:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003b92:	457c                	lw	a5,76(a0)
    80003b94:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003b96:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003b98:	e79d                	bnez	a5,80003bc6 <dirlookup+0x54>
    80003b9a:	a8a5                	j	80003c12 <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80003b9c:	00005517          	auipc	a0,0x5
    80003ba0:	a5c50513          	addi	a0,a0,-1444 # 800085f8 <syscalls+0x1a8>
    80003ba4:	ffffd097          	auipc	ra,0xffffd
    80003ba8:	98c080e7          	jalr	-1652(ra) # 80000530 <panic>
      panic("dirlookup read");
    80003bac:	00005517          	auipc	a0,0x5
    80003bb0:	a6450513          	addi	a0,a0,-1436 # 80008610 <syscalls+0x1c0>
    80003bb4:	ffffd097          	auipc	ra,0xffffd
    80003bb8:	97c080e7          	jalr	-1668(ra) # 80000530 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003bbc:	24c1                	addiw	s1,s1,16
    80003bbe:	04c92783          	lw	a5,76(s2)
    80003bc2:	04f4f763          	bgeu	s1,a5,80003c10 <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003bc6:	4741                	li	a4,16
    80003bc8:	86a6                	mv	a3,s1
    80003bca:	fc040613          	addi	a2,s0,-64
    80003bce:	4581                	li	a1,0
    80003bd0:	854a                	mv	a0,s2
    80003bd2:	00000097          	auipc	ra,0x0
    80003bd6:	d70080e7          	jalr	-656(ra) # 80003942 <readi>
    80003bda:	47c1                	li	a5,16
    80003bdc:	fcf518e3          	bne	a0,a5,80003bac <dirlookup+0x3a>
    if(de.inum == 0)
    80003be0:	fc045783          	lhu	a5,-64(s0)
    80003be4:	dfe1                	beqz	a5,80003bbc <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    80003be6:	fc240593          	addi	a1,s0,-62
    80003bea:	854e                	mv	a0,s3
    80003bec:	00000097          	auipc	ra,0x0
    80003bf0:	f6c080e7          	jalr	-148(ra) # 80003b58 <namecmp>
    80003bf4:	f561                	bnez	a0,80003bbc <dirlookup+0x4a>
      if(poff)
    80003bf6:	000a0463          	beqz	s4,80003bfe <dirlookup+0x8c>
        *poff = off;
    80003bfa:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80003bfe:	fc045583          	lhu	a1,-64(s0)
    80003c02:	00092503          	lw	a0,0(s2)
    80003c06:	fffff097          	auipc	ra,0xfffff
    80003c0a:	754080e7          	jalr	1876(ra) # 8000335a <iget>
    80003c0e:	a011                	j	80003c12 <dirlookup+0xa0>
  return 0;
    80003c10:	4501                	li	a0,0
}
    80003c12:	70e2                	ld	ra,56(sp)
    80003c14:	7442                	ld	s0,48(sp)
    80003c16:	74a2                	ld	s1,40(sp)
    80003c18:	7902                	ld	s2,32(sp)
    80003c1a:	69e2                	ld	s3,24(sp)
    80003c1c:	6a42                	ld	s4,16(sp)
    80003c1e:	6121                	addi	sp,sp,64
    80003c20:	8082                	ret

0000000080003c22 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003c22:	711d                	addi	sp,sp,-96
    80003c24:	ec86                	sd	ra,88(sp)
    80003c26:	e8a2                	sd	s0,80(sp)
    80003c28:	e4a6                	sd	s1,72(sp)
    80003c2a:	e0ca                	sd	s2,64(sp)
    80003c2c:	fc4e                	sd	s3,56(sp)
    80003c2e:	f852                	sd	s4,48(sp)
    80003c30:	f456                	sd	s5,40(sp)
    80003c32:	f05a                	sd	s6,32(sp)
    80003c34:	ec5e                	sd	s7,24(sp)
    80003c36:	e862                	sd	s8,16(sp)
    80003c38:	e466                	sd	s9,8(sp)
    80003c3a:	1080                	addi	s0,sp,96
    80003c3c:	84aa                	mv	s1,a0
    80003c3e:	8b2e                	mv	s6,a1
    80003c40:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003c42:	00054703          	lbu	a4,0(a0)
    80003c46:	02f00793          	li	a5,47
    80003c4a:	02f70363          	beq	a4,a5,80003c70 <namex+0x4e>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003c4e:	ffffe097          	auipc	ra,0xffffe
    80003c52:	dfc080e7          	jalr	-516(ra) # 80001a4a <myproc>
    80003c56:	15053503          	ld	a0,336(a0)
    80003c5a:	00000097          	auipc	ra,0x0
    80003c5e:	9f6080e7          	jalr	-1546(ra) # 80003650 <idup>
    80003c62:	89aa                	mv	s3,a0
  while(*path == '/')
    80003c64:	02f00913          	li	s2,47
  len = path - s;
    80003c68:	4b81                	li	s7,0
  if(len >= DIRSIZ)
    80003c6a:	4cb5                	li	s9,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003c6c:	4c05                	li	s8,1
    80003c6e:	a865                	j	80003d26 <namex+0x104>
    ip = iget(ROOTDEV, ROOTINO);
    80003c70:	4585                	li	a1,1
    80003c72:	4505                	li	a0,1
    80003c74:	fffff097          	auipc	ra,0xfffff
    80003c78:	6e6080e7          	jalr	1766(ra) # 8000335a <iget>
    80003c7c:	89aa                	mv	s3,a0
    80003c7e:	b7dd                	j	80003c64 <namex+0x42>
      iunlockput(ip);
    80003c80:	854e                	mv	a0,s3
    80003c82:	00000097          	auipc	ra,0x0
    80003c86:	c6e080e7          	jalr	-914(ra) # 800038f0 <iunlockput>
      return 0;
    80003c8a:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003c8c:	854e                	mv	a0,s3
    80003c8e:	60e6                	ld	ra,88(sp)
    80003c90:	6446                	ld	s0,80(sp)
    80003c92:	64a6                	ld	s1,72(sp)
    80003c94:	6906                	ld	s2,64(sp)
    80003c96:	79e2                	ld	s3,56(sp)
    80003c98:	7a42                	ld	s4,48(sp)
    80003c9a:	7aa2                	ld	s5,40(sp)
    80003c9c:	7b02                	ld	s6,32(sp)
    80003c9e:	6be2                	ld	s7,24(sp)
    80003ca0:	6c42                	ld	s8,16(sp)
    80003ca2:	6ca2                	ld	s9,8(sp)
    80003ca4:	6125                	addi	sp,sp,96
    80003ca6:	8082                	ret
      iunlock(ip);
    80003ca8:	854e                	mv	a0,s3
    80003caa:	00000097          	auipc	ra,0x0
    80003cae:	aa6080e7          	jalr	-1370(ra) # 80003750 <iunlock>
      return ip;
    80003cb2:	bfe9                	j	80003c8c <namex+0x6a>
      iunlockput(ip);
    80003cb4:	854e                	mv	a0,s3
    80003cb6:	00000097          	auipc	ra,0x0
    80003cba:	c3a080e7          	jalr	-966(ra) # 800038f0 <iunlockput>
      return 0;
    80003cbe:	89d2                	mv	s3,s4
    80003cc0:	b7f1                	j	80003c8c <namex+0x6a>
  len = path - s;
    80003cc2:	40b48633          	sub	a2,s1,a1
    80003cc6:	00060a1b          	sext.w	s4,a2
  if(len >= DIRSIZ)
    80003cca:	094cd463          	bge	s9,s4,80003d52 <namex+0x130>
    memmove(name, s, DIRSIZ);
    80003cce:	4639                	li	a2,14
    80003cd0:	8556                	mv	a0,s5
    80003cd2:	ffffd097          	auipc	ra,0xffffd
    80003cd6:	060080e7          	jalr	96(ra) # 80000d32 <memmove>
  while(*path == '/')
    80003cda:	0004c783          	lbu	a5,0(s1)
    80003cde:	01279763          	bne	a5,s2,80003cec <namex+0xca>
    path++;
    80003ce2:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003ce4:	0004c783          	lbu	a5,0(s1)
    80003ce8:	ff278de3          	beq	a5,s2,80003ce2 <namex+0xc0>
    ilock(ip);
    80003cec:	854e                	mv	a0,s3
    80003cee:	00000097          	auipc	ra,0x0
    80003cf2:	9a0080e7          	jalr	-1632(ra) # 8000368e <ilock>
    if(ip->type != T_DIR){
    80003cf6:	04499783          	lh	a5,68(s3)
    80003cfa:	f98793e3          	bne	a5,s8,80003c80 <namex+0x5e>
    if(nameiparent && *path == '\0'){
    80003cfe:	000b0563          	beqz	s6,80003d08 <namex+0xe6>
    80003d02:	0004c783          	lbu	a5,0(s1)
    80003d06:	d3cd                	beqz	a5,80003ca8 <namex+0x86>
    if((next = dirlookup(ip, name, 0)) == 0){
    80003d08:	865e                	mv	a2,s7
    80003d0a:	85d6                	mv	a1,s5
    80003d0c:	854e                	mv	a0,s3
    80003d0e:	00000097          	auipc	ra,0x0
    80003d12:	e64080e7          	jalr	-412(ra) # 80003b72 <dirlookup>
    80003d16:	8a2a                	mv	s4,a0
    80003d18:	dd51                	beqz	a0,80003cb4 <namex+0x92>
    iunlockput(ip);
    80003d1a:	854e                	mv	a0,s3
    80003d1c:	00000097          	auipc	ra,0x0
    80003d20:	bd4080e7          	jalr	-1068(ra) # 800038f0 <iunlockput>
    ip = next;
    80003d24:	89d2                	mv	s3,s4
  while(*path == '/')
    80003d26:	0004c783          	lbu	a5,0(s1)
    80003d2a:	05279763          	bne	a5,s2,80003d78 <namex+0x156>
    path++;
    80003d2e:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003d30:	0004c783          	lbu	a5,0(s1)
    80003d34:	ff278de3          	beq	a5,s2,80003d2e <namex+0x10c>
  if(*path == 0)
    80003d38:	c79d                	beqz	a5,80003d66 <namex+0x144>
    path++;
    80003d3a:	85a6                	mv	a1,s1
  len = path - s;
    80003d3c:	8a5e                	mv	s4,s7
    80003d3e:	865e                	mv	a2,s7
  while(*path != '/' && *path != 0)
    80003d40:	01278963          	beq	a5,s2,80003d52 <namex+0x130>
    80003d44:	dfbd                	beqz	a5,80003cc2 <namex+0xa0>
    path++;
    80003d46:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    80003d48:	0004c783          	lbu	a5,0(s1)
    80003d4c:	ff279ce3          	bne	a5,s2,80003d44 <namex+0x122>
    80003d50:	bf8d                	j	80003cc2 <namex+0xa0>
    memmove(name, s, len);
    80003d52:	2601                	sext.w	a2,a2
    80003d54:	8556                	mv	a0,s5
    80003d56:	ffffd097          	auipc	ra,0xffffd
    80003d5a:	fdc080e7          	jalr	-36(ra) # 80000d32 <memmove>
    name[len] = 0;
    80003d5e:	9a56                	add	s4,s4,s5
    80003d60:	000a0023          	sb	zero,0(s4)
    80003d64:	bf9d                	j	80003cda <namex+0xb8>
  if(nameiparent){
    80003d66:	f20b03e3          	beqz	s6,80003c8c <namex+0x6a>
    iput(ip);
    80003d6a:	854e                	mv	a0,s3
    80003d6c:	00000097          	auipc	ra,0x0
    80003d70:	adc080e7          	jalr	-1316(ra) # 80003848 <iput>
    return 0;
    80003d74:	4981                	li	s3,0
    80003d76:	bf19                	j	80003c8c <namex+0x6a>
  if(*path == 0)
    80003d78:	d7fd                	beqz	a5,80003d66 <namex+0x144>
  while(*path != '/' && *path != 0)
    80003d7a:	0004c783          	lbu	a5,0(s1)
    80003d7e:	85a6                	mv	a1,s1
    80003d80:	b7d1                	j	80003d44 <namex+0x122>

0000000080003d82 <dirlink>:
{
    80003d82:	7139                	addi	sp,sp,-64
    80003d84:	fc06                	sd	ra,56(sp)
    80003d86:	f822                	sd	s0,48(sp)
    80003d88:	f426                	sd	s1,40(sp)
    80003d8a:	f04a                	sd	s2,32(sp)
    80003d8c:	ec4e                	sd	s3,24(sp)
    80003d8e:	e852                	sd	s4,16(sp)
    80003d90:	0080                	addi	s0,sp,64
    80003d92:	892a                	mv	s2,a0
    80003d94:	8a2e                	mv	s4,a1
    80003d96:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80003d98:	4601                	li	a2,0
    80003d9a:	00000097          	auipc	ra,0x0
    80003d9e:	dd8080e7          	jalr	-552(ra) # 80003b72 <dirlookup>
    80003da2:	e93d                	bnez	a0,80003e18 <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003da4:	04c92483          	lw	s1,76(s2)
    80003da8:	c49d                	beqz	s1,80003dd6 <dirlink+0x54>
    80003daa:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003dac:	4741                	li	a4,16
    80003dae:	86a6                	mv	a3,s1
    80003db0:	fc040613          	addi	a2,s0,-64
    80003db4:	4581                	li	a1,0
    80003db6:	854a                	mv	a0,s2
    80003db8:	00000097          	auipc	ra,0x0
    80003dbc:	b8a080e7          	jalr	-1142(ra) # 80003942 <readi>
    80003dc0:	47c1                	li	a5,16
    80003dc2:	06f51163          	bne	a0,a5,80003e24 <dirlink+0xa2>
    if(de.inum == 0)
    80003dc6:	fc045783          	lhu	a5,-64(s0)
    80003dca:	c791                	beqz	a5,80003dd6 <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003dcc:	24c1                	addiw	s1,s1,16
    80003dce:	04c92783          	lw	a5,76(s2)
    80003dd2:	fcf4ede3          	bltu	s1,a5,80003dac <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    80003dd6:	4639                	li	a2,14
    80003dd8:	85d2                	mv	a1,s4
    80003dda:	fc240513          	addi	a0,s0,-62
    80003dde:	ffffd097          	auipc	ra,0xffffd
    80003de2:	00c080e7          	jalr	12(ra) # 80000dea <strncpy>
  de.inum = inum;
    80003de6:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003dea:	4741                	li	a4,16
    80003dec:	86a6                	mv	a3,s1
    80003dee:	fc040613          	addi	a2,s0,-64
    80003df2:	4581                	li	a1,0
    80003df4:	854a                	mv	a0,s2
    80003df6:	00000097          	auipc	ra,0x0
    80003dfa:	c44080e7          	jalr	-956(ra) # 80003a3a <writei>
    80003dfe:	872a                	mv	a4,a0
    80003e00:	47c1                	li	a5,16
  return 0;
    80003e02:	4501                	li	a0,0
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003e04:	02f71863          	bne	a4,a5,80003e34 <dirlink+0xb2>
}
    80003e08:	70e2                	ld	ra,56(sp)
    80003e0a:	7442                	ld	s0,48(sp)
    80003e0c:	74a2                	ld	s1,40(sp)
    80003e0e:	7902                	ld	s2,32(sp)
    80003e10:	69e2                	ld	s3,24(sp)
    80003e12:	6a42                	ld	s4,16(sp)
    80003e14:	6121                	addi	sp,sp,64
    80003e16:	8082                	ret
    iput(ip);
    80003e18:	00000097          	auipc	ra,0x0
    80003e1c:	a30080e7          	jalr	-1488(ra) # 80003848 <iput>
    return -1;
    80003e20:	557d                	li	a0,-1
    80003e22:	b7dd                	j	80003e08 <dirlink+0x86>
      panic("dirlink read");
    80003e24:	00004517          	auipc	a0,0x4
    80003e28:	7fc50513          	addi	a0,a0,2044 # 80008620 <syscalls+0x1d0>
    80003e2c:	ffffc097          	auipc	ra,0xffffc
    80003e30:	704080e7          	jalr	1796(ra) # 80000530 <panic>
    panic("dirlink");
    80003e34:	00005517          	auipc	a0,0x5
    80003e38:	8fc50513          	addi	a0,a0,-1796 # 80008730 <syscalls+0x2e0>
    80003e3c:	ffffc097          	auipc	ra,0xffffc
    80003e40:	6f4080e7          	jalr	1780(ra) # 80000530 <panic>

0000000080003e44 <namei>:

struct inode*
namei(char *path)
{
    80003e44:	1101                	addi	sp,sp,-32
    80003e46:	ec06                	sd	ra,24(sp)
    80003e48:	e822                	sd	s0,16(sp)
    80003e4a:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80003e4c:	fe040613          	addi	a2,s0,-32
    80003e50:	4581                	li	a1,0
    80003e52:	00000097          	auipc	ra,0x0
    80003e56:	dd0080e7          	jalr	-560(ra) # 80003c22 <namex>
}
    80003e5a:	60e2                	ld	ra,24(sp)
    80003e5c:	6442                	ld	s0,16(sp)
    80003e5e:	6105                	addi	sp,sp,32
    80003e60:	8082                	ret

0000000080003e62 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80003e62:	1141                	addi	sp,sp,-16
    80003e64:	e406                	sd	ra,8(sp)
    80003e66:	e022                	sd	s0,0(sp)
    80003e68:	0800                	addi	s0,sp,16
    80003e6a:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80003e6c:	4585                	li	a1,1
    80003e6e:	00000097          	auipc	ra,0x0
    80003e72:	db4080e7          	jalr	-588(ra) # 80003c22 <namex>
}
    80003e76:	60a2                	ld	ra,8(sp)
    80003e78:	6402                	ld	s0,0(sp)
    80003e7a:	0141                	addi	sp,sp,16
    80003e7c:	8082                	ret

0000000080003e7e <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80003e7e:	1101                	addi	sp,sp,-32
    80003e80:	ec06                	sd	ra,24(sp)
    80003e82:	e822                	sd	s0,16(sp)
    80003e84:	e426                	sd	s1,8(sp)
    80003e86:	e04a                	sd	s2,0(sp)
    80003e88:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80003e8a:	0001d917          	auipc	s2,0x1d
    80003e8e:	3e690913          	addi	s2,s2,998 # 80021270 <log>
    80003e92:	01892583          	lw	a1,24(s2)
    80003e96:	02892503          	lw	a0,40(s2)
    80003e9a:	fffff097          	auipc	ra,0xfffff
    80003e9e:	ff2080e7          	jalr	-14(ra) # 80002e8c <bread>
    80003ea2:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80003ea4:	02c92683          	lw	a3,44(s2)
    80003ea8:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80003eaa:	02d05763          	blez	a3,80003ed8 <write_head+0x5a>
    80003eae:	0001d797          	auipc	a5,0x1d
    80003eb2:	3f278793          	addi	a5,a5,1010 # 800212a0 <log+0x30>
    80003eb6:	05c50713          	addi	a4,a0,92
    80003eba:	36fd                	addiw	a3,a3,-1
    80003ebc:	1682                	slli	a3,a3,0x20
    80003ebe:	9281                	srli	a3,a3,0x20
    80003ec0:	068a                	slli	a3,a3,0x2
    80003ec2:	0001d617          	auipc	a2,0x1d
    80003ec6:	3e260613          	addi	a2,a2,994 # 800212a4 <log+0x34>
    80003eca:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    80003ecc:	4390                	lw	a2,0(a5)
    80003ece:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80003ed0:	0791                	addi	a5,a5,4
    80003ed2:	0711                	addi	a4,a4,4
    80003ed4:	fed79ce3          	bne	a5,a3,80003ecc <write_head+0x4e>
  }
  bwrite(buf);
    80003ed8:	8526                	mv	a0,s1
    80003eda:	fffff097          	auipc	ra,0xfffff
    80003ede:	0a4080e7          	jalr	164(ra) # 80002f7e <bwrite>
  brelse(buf);
    80003ee2:	8526                	mv	a0,s1
    80003ee4:	fffff097          	auipc	ra,0xfffff
    80003ee8:	0d8080e7          	jalr	216(ra) # 80002fbc <brelse>
}
    80003eec:	60e2                	ld	ra,24(sp)
    80003eee:	6442                	ld	s0,16(sp)
    80003ef0:	64a2                	ld	s1,8(sp)
    80003ef2:	6902                	ld	s2,0(sp)
    80003ef4:	6105                	addi	sp,sp,32
    80003ef6:	8082                	ret

0000000080003ef8 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80003ef8:	0001d797          	auipc	a5,0x1d
    80003efc:	3a47a783          	lw	a5,932(a5) # 8002129c <log+0x2c>
    80003f00:	0af05d63          	blez	a5,80003fba <install_trans+0xc2>
{
    80003f04:	7139                	addi	sp,sp,-64
    80003f06:	fc06                	sd	ra,56(sp)
    80003f08:	f822                	sd	s0,48(sp)
    80003f0a:	f426                	sd	s1,40(sp)
    80003f0c:	f04a                	sd	s2,32(sp)
    80003f0e:	ec4e                	sd	s3,24(sp)
    80003f10:	e852                	sd	s4,16(sp)
    80003f12:	e456                	sd	s5,8(sp)
    80003f14:	e05a                	sd	s6,0(sp)
    80003f16:	0080                	addi	s0,sp,64
    80003f18:	8b2a                	mv	s6,a0
    80003f1a:	0001da97          	auipc	s5,0x1d
    80003f1e:	386a8a93          	addi	s5,s5,902 # 800212a0 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003f22:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003f24:	0001d997          	auipc	s3,0x1d
    80003f28:	34c98993          	addi	s3,s3,844 # 80021270 <log>
    80003f2c:	a035                	j	80003f58 <install_trans+0x60>
      bunpin(dbuf);
    80003f2e:	8526                	mv	a0,s1
    80003f30:	fffff097          	auipc	ra,0xfffff
    80003f34:	166080e7          	jalr	358(ra) # 80003096 <bunpin>
    brelse(lbuf);
    80003f38:	854a                	mv	a0,s2
    80003f3a:	fffff097          	auipc	ra,0xfffff
    80003f3e:	082080e7          	jalr	130(ra) # 80002fbc <brelse>
    brelse(dbuf);
    80003f42:	8526                	mv	a0,s1
    80003f44:	fffff097          	auipc	ra,0xfffff
    80003f48:	078080e7          	jalr	120(ra) # 80002fbc <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003f4c:	2a05                	addiw	s4,s4,1
    80003f4e:	0a91                	addi	s5,s5,4
    80003f50:	02c9a783          	lw	a5,44(s3)
    80003f54:	04fa5963          	bge	s4,a5,80003fa6 <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003f58:	0189a583          	lw	a1,24(s3)
    80003f5c:	014585bb          	addw	a1,a1,s4
    80003f60:	2585                	addiw	a1,a1,1
    80003f62:	0289a503          	lw	a0,40(s3)
    80003f66:	fffff097          	auipc	ra,0xfffff
    80003f6a:	f26080e7          	jalr	-218(ra) # 80002e8c <bread>
    80003f6e:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80003f70:	000aa583          	lw	a1,0(s5)
    80003f74:	0289a503          	lw	a0,40(s3)
    80003f78:	fffff097          	auipc	ra,0xfffff
    80003f7c:	f14080e7          	jalr	-236(ra) # 80002e8c <bread>
    80003f80:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80003f82:	40000613          	li	a2,1024
    80003f86:	05890593          	addi	a1,s2,88
    80003f8a:	05850513          	addi	a0,a0,88
    80003f8e:	ffffd097          	auipc	ra,0xffffd
    80003f92:	da4080e7          	jalr	-604(ra) # 80000d32 <memmove>
    bwrite(dbuf);  // write dst to disk
    80003f96:	8526                	mv	a0,s1
    80003f98:	fffff097          	auipc	ra,0xfffff
    80003f9c:	fe6080e7          	jalr	-26(ra) # 80002f7e <bwrite>
    if(recovering == 0)
    80003fa0:	f80b1ce3          	bnez	s6,80003f38 <install_trans+0x40>
    80003fa4:	b769                	j	80003f2e <install_trans+0x36>
}
    80003fa6:	70e2                	ld	ra,56(sp)
    80003fa8:	7442                	ld	s0,48(sp)
    80003faa:	74a2                	ld	s1,40(sp)
    80003fac:	7902                	ld	s2,32(sp)
    80003fae:	69e2                	ld	s3,24(sp)
    80003fb0:	6a42                	ld	s4,16(sp)
    80003fb2:	6aa2                	ld	s5,8(sp)
    80003fb4:	6b02                	ld	s6,0(sp)
    80003fb6:	6121                	addi	sp,sp,64
    80003fb8:	8082                	ret
    80003fba:	8082                	ret

0000000080003fbc <initlog>:
{
    80003fbc:	7179                	addi	sp,sp,-48
    80003fbe:	f406                	sd	ra,40(sp)
    80003fc0:	f022                	sd	s0,32(sp)
    80003fc2:	ec26                	sd	s1,24(sp)
    80003fc4:	e84a                	sd	s2,16(sp)
    80003fc6:	e44e                	sd	s3,8(sp)
    80003fc8:	1800                	addi	s0,sp,48
    80003fca:	892a                	mv	s2,a0
    80003fcc:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80003fce:	0001d497          	auipc	s1,0x1d
    80003fd2:	2a248493          	addi	s1,s1,674 # 80021270 <log>
    80003fd6:	00004597          	auipc	a1,0x4
    80003fda:	65a58593          	addi	a1,a1,1626 # 80008630 <syscalls+0x1e0>
    80003fde:	8526                	mv	a0,s1
    80003fe0:	ffffd097          	auipc	ra,0xffffd
    80003fe4:	b66080e7          	jalr	-1178(ra) # 80000b46 <initlock>
  log.start = sb->logstart;
    80003fe8:	0149a583          	lw	a1,20(s3)
    80003fec:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    80003fee:	0109a783          	lw	a5,16(s3)
    80003ff2:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    80003ff4:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    80003ff8:	854a                	mv	a0,s2
    80003ffa:	fffff097          	auipc	ra,0xfffff
    80003ffe:	e92080e7          	jalr	-366(ra) # 80002e8c <bread>
  log.lh.n = lh->n;
    80004002:	4d3c                	lw	a5,88(a0)
    80004004:	d4dc                	sw	a5,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    80004006:	02f05563          	blez	a5,80004030 <initlog+0x74>
    8000400a:	05c50713          	addi	a4,a0,92
    8000400e:	0001d697          	auipc	a3,0x1d
    80004012:	29268693          	addi	a3,a3,658 # 800212a0 <log+0x30>
    80004016:	37fd                	addiw	a5,a5,-1
    80004018:	1782                	slli	a5,a5,0x20
    8000401a:	9381                	srli	a5,a5,0x20
    8000401c:	078a                	slli	a5,a5,0x2
    8000401e:	06050613          	addi	a2,a0,96
    80004022:	97b2                	add	a5,a5,a2
    log.lh.block[i] = lh->block[i];
    80004024:	4310                	lw	a2,0(a4)
    80004026:	c290                	sw	a2,0(a3)
  for (i = 0; i < log.lh.n; i++) {
    80004028:	0711                	addi	a4,a4,4
    8000402a:	0691                	addi	a3,a3,4
    8000402c:	fef71ce3          	bne	a4,a5,80004024 <initlog+0x68>
  brelse(buf);
    80004030:	fffff097          	auipc	ra,0xfffff
    80004034:	f8c080e7          	jalr	-116(ra) # 80002fbc <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80004038:	4505                	li	a0,1
    8000403a:	00000097          	auipc	ra,0x0
    8000403e:	ebe080e7          	jalr	-322(ra) # 80003ef8 <install_trans>
  log.lh.n = 0;
    80004042:	0001d797          	auipc	a5,0x1d
    80004046:	2407ad23          	sw	zero,602(a5) # 8002129c <log+0x2c>
  write_head(); // clear the log
    8000404a:	00000097          	auipc	ra,0x0
    8000404e:	e34080e7          	jalr	-460(ra) # 80003e7e <write_head>
}
    80004052:	70a2                	ld	ra,40(sp)
    80004054:	7402                	ld	s0,32(sp)
    80004056:	64e2                	ld	s1,24(sp)
    80004058:	6942                	ld	s2,16(sp)
    8000405a:	69a2                	ld	s3,8(sp)
    8000405c:	6145                	addi	sp,sp,48
    8000405e:	8082                	ret

0000000080004060 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80004060:	1101                	addi	sp,sp,-32
    80004062:	ec06                	sd	ra,24(sp)
    80004064:	e822                	sd	s0,16(sp)
    80004066:	e426                	sd	s1,8(sp)
    80004068:	e04a                	sd	s2,0(sp)
    8000406a:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    8000406c:	0001d517          	auipc	a0,0x1d
    80004070:	20450513          	addi	a0,a0,516 # 80021270 <log>
    80004074:	ffffd097          	auipc	ra,0xffffd
    80004078:	b62080e7          	jalr	-1182(ra) # 80000bd6 <acquire>
  while(1){
    if(log.committing){
    8000407c:	0001d497          	auipc	s1,0x1d
    80004080:	1f448493          	addi	s1,s1,500 # 80021270 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004084:	4979                	li	s2,30
    80004086:	a039                	j	80004094 <begin_op+0x34>
      sleep(&log, &log.lock);
    80004088:	85a6                	mv	a1,s1
    8000408a:	8526                	mv	a0,s1
    8000408c:	ffffe097          	auipc	ra,0xffffe
    80004090:	07a080e7          	jalr	122(ra) # 80002106 <sleep>
    if(log.committing){
    80004094:	50dc                	lw	a5,36(s1)
    80004096:	fbed                	bnez	a5,80004088 <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004098:	509c                	lw	a5,32(s1)
    8000409a:	0017871b          	addiw	a4,a5,1
    8000409e:	0007069b          	sext.w	a3,a4
    800040a2:	0027179b          	slliw	a5,a4,0x2
    800040a6:	9fb9                	addw	a5,a5,a4
    800040a8:	0017979b          	slliw	a5,a5,0x1
    800040ac:	54d8                	lw	a4,44(s1)
    800040ae:	9fb9                	addw	a5,a5,a4
    800040b0:	00f95963          	bge	s2,a5,800040c2 <begin_op+0x62>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    800040b4:	85a6                	mv	a1,s1
    800040b6:	8526                	mv	a0,s1
    800040b8:	ffffe097          	auipc	ra,0xffffe
    800040bc:	04e080e7          	jalr	78(ra) # 80002106 <sleep>
    800040c0:	bfd1                	j	80004094 <begin_op+0x34>
    } else {
      log.outstanding += 1;
    800040c2:	0001d517          	auipc	a0,0x1d
    800040c6:	1ae50513          	addi	a0,a0,430 # 80021270 <log>
    800040ca:	d114                	sw	a3,32(a0)
      release(&log.lock);
    800040cc:	ffffd097          	auipc	ra,0xffffd
    800040d0:	bbe080e7          	jalr	-1090(ra) # 80000c8a <release>
      break;
    }
  }
}
    800040d4:	60e2                	ld	ra,24(sp)
    800040d6:	6442                	ld	s0,16(sp)
    800040d8:	64a2                	ld	s1,8(sp)
    800040da:	6902                	ld	s2,0(sp)
    800040dc:	6105                	addi	sp,sp,32
    800040de:	8082                	ret

00000000800040e0 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    800040e0:	7139                	addi	sp,sp,-64
    800040e2:	fc06                	sd	ra,56(sp)
    800040e4:	f822                	sd	s0,48(sp)
    800040e6:	f426                	sd	s1,40(sp)
    800040e8:	f04a                	sd	s2,32(sp)
    800040ea:	ec4e                	sd	s3,24(sp)
    800040ec:	e852                	sd	s4,16(sp)
    800040ee:	e456                	sd	s5,8(sp)
    800040f0:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    800040f2:	0001d497          	auipc	s1,0x1d
    800040f6:	17e48493          	addi	s1,s1,382 # 80021270 <log>
    800040fa:	8526                	mv	a0,s1
    800040fc:	ffffd097          	auipc	ra,0xffffd
    80004100:	ada080e7          	jalr	-1318(ra) # 80000bd6 <acquire>
  log.outstanding -= 1;
    80004104:	509c                	lw	a5,32(s1)
    80004106:	37fd                	addiw	a5,a5,-1
    80004108:	0007891b          	sext.w	s2,a5
    8000410c:	d09c                	sw	a5,32(s1)
  if(log.committing)
    8000410e:	50dc                	lw	a5,36(s1)
    80004110:	efb9                	bnez	a5,8000416e <end_op+0x8e>
    panic("log.committing");
  if(log.outstanding == 0){
    80004112:	06091663          	bnez	s2,8000417e <end_op+0x9e>
    do_commit = 1;
    log.committing = 1;
    80004116:	0001d497          	auipc	s1,0x1d
    8000411a:	15a48493          	addi	s1,s1,346 # 80021270 <log>
    8000411e:	4785                	li	a5,1
    80004120:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80004122:	8526                	mv	a0,s1
    80004124:	ffffd097          	auipc	ra,0xffffd
    80004128:	b66080e7          	jalr	-1178(ra) # 80000c8a <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    8000412c:	54dc                	lw	a5,44(s1)
    8000412e:	06f04763          	bgtz	a5,8000419c <end_op+0xbc>
    acquire(&log.lock);
    80004132:	0001d497          	auipc	s1,0x1d
    80004136:	13e48493          	addi	s1,s1,318 # 80021270 <log>
    8000413a:	8526                	mv	a0,s1
    8000413c:	ffffd097          	auipc	ra,0xffffd
    80004140:	a9a080e7          	jalr	-1382(ra) # 80000bd6 <acquire>
    log.committing = 0;
    80004144:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    80004148:	8526                	mv	a0,s1
    8000414a:	ffffe097          	auipc	ra,0xffffe
    8000414e:	148080e7          	jalr	328(ra) # 80002292 <wakeup>
    release(&log.lock);
    80004152:	8526                	mv	a0,s1
    80004154:	ffffd097          	auipc	ra,0xffffd
    80004158:	b36080e7          	jalr	-1226(ra) # 80000c8a <release>
}
    8000415c:	70e2                	ld	ra,56(sp)
    8000415e:	7442                	ld	s0,48(sp)
    80004160:	74a2                	ld	s1,40(sp)
    80004162:	7902                	ld	s2,32(sp)
    80004164:	69e2                	ld	s3,24(sp)
    80004166:	6a42                	ld	s4,16(sp)
    80004168:	6aa2                	ld	s5,8(sp)
    8000416a:	6121                	addi	sp,sp,64
    8000416c:	8082                	ret
    panic("log.committing");
    8000416e:	00004517          	auipc	a0,0x4
    80004172:	4ca50513          	addi	a0,a0,1226 # 80008638 <syscalls+0x1e8>
    80004176:	ffffc097          	auipc	ra,0xffffc
    8000417a:	3ba080e7          	jalr	954(ra) # 80000530 <panic>
    wakeup(&log);
    8000417e:	0001d497          	auipc	s1,0x1d
    80004182:	0f248493          	addi	s1,s1,242 # 80021270 <log>
    80004186:	8526                	mv	a0,s1
    80004188:	ffffe097          	auipc	ra,0xffffe
    8000418c:	10a080e7          	jalr	266(ra) # 80002292 <wakeup>
  release(&log.lock);
    80004190:	8526                	mv	a0,s1
    80004192:	ffffd097          	auipc	ra,0xffffd
    80004196:	af8080e7          	jalr	-1288(ra) # 80000c8a <release>
  if(do_commit){
    8000419a:	b7c9                	j	8000415c <end_op+0x7c>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000419c:	0001da97          	auipc	s5,0x1d
    800041a0:	104a8a93          	addi	s5,s5,260 # 800212a0 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    800041a4:	0001da17          	auipc	s4,0x1d
    800041a8:	0cca0a13          	addi	s4,s4,204 # 80021270 <log>
    800041ac:	018a2583          	lw	a1,24(s4)
    800041b0:	012585bb          	addw	a1,a1,s2
    800041b4:	2585                	addiw	a1,a1,1
    800041b6:	028a2503          	lw	a0,40(s4)
    800041ba:	fffff097          	auipc	ra,0xfffff
    800041be:	cd2080e7          	jalr	-814(ra) # 80002e8c <bread>
    800041c2:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    800041c4:	000aa583          	lw	a1,0(s5)
    800041c8:	028a2503          	lw	a0,40(s4)
    800041cc:	fffff097          	auipc	ra,0xfffff
    800041d0:	cc0080e7          	jalr	-832(ra) # 80002e8c <bread>
    800041d4:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    800041d6:	40000613          	li	a2,1024
    800041da:	05850593          	addi	a1,a0,88
    800041de:	05848513          	addi	a0,s1,88
    800041e2:	ffffd097          	auipc	ra,0xffffd
    800041e6:	b50080e7          	jalr	-1200(ra) # 80000d32 <memmove>
    bwrite(to);  // write the log
    800041ea:	8526                	mv	a0,s1
    800041ec:	fffff097          	auipc	ra,0xfffff
    800041f0:	d92080e7          	jalr	-622(ra) # 80002f7e <bwrite>
    brelse(from);
    800041f4:	854e                	mv	a0,s3
    800041f6:	fffff097          	auipc	ra,0xfffff
    800041fa:	dc6080e7          	jalr	-570(ra) # 80002fbc <brelse>
    brelse(to);
    800041fe:	8526                	mv	a0,s1
    80004200:	fffff097          	auipc	ra,0xfffff
    80004204:	dbc080e7          	jalr	-580(ra) # 80002fbc <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004208:	2905                	addiw	s2,s2,1
    8000420a:	0a91                	addi	s5,s5,4
    8000420c:	02ca2783          	lw	a5,44(s4)
    80004210:	f8f94ee3          	blt	s2,a5,800041ac <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80004214:	00000097          	auipc	ra,0x0
    80004218:	c6a080e7          	jalr	-918(ra) # 80003e7e <write_head>
    install_trans(0); // Now install writes to home locations
    8000421c:	4501                	li	a0,0
    8000421e:	00000097          	auipc	ra,0x0
    80004222:	cda080e7          	jalr	-806(ra) # 80003ef8 <install_trans>
    log.lh.n = 0;
    80004226:	0001d797          	auipc	a5,0x1d
    8000422a:	0607ab23          	sw	zero,118(a5) # 8002129c <log+0x2c>
    write_head();    // Erase the transaction from the log
    8000422e:	00000097          	auipc	ra,0x0
    80004232:	c50080e7          	jalr	-944(ra) # 80003e7e <write_head>
    80004236:	bdf5                	j	80004132 <end_op+0x52>

0000000080004238 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80004238:	1101                	addi	sp,sp,-32
    8000423a:	ec06                	sd	ra,24(sp)
    8000423c:	e822                	sd	s0,16(sp)
    8000423e:	e426                	sd	s1,8(sp)
    80004240:	e04a                	sd	s2,0(sp)
    80004242:	1000                	addi	s0,sp,32
    80004244:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80004246:	0001d917          	auipc	s2,0x1d
    8000424a:	02a90913          	addi	s2,s2,42 # 80021270 <log>
    8000424e:	854a                	mv	a0,s2
    80004250:	ffffd097          	auipc	ra,0xffffd
    80004254:	986080e7          	jalr	-1658(ra) # 80000bd6 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    80004258:	02c92603          	lw	a2,44(s2)
    8000425c:	47f5                	li	a5,29
    8000425e:	06c7c563          	blt	a5,a2,800042c8 <log_write+0x90>
    80004262:	0001d797          	auipc	a5,0x1d
    80004266:	02a7a783          	lw	a5,42(a5) # 8002128c <log+0x1c>
    8000426a:	37fd                	addiw	a5,a5,-1
    8000426c:	04f65e63          	bge	a2,a5,800042c8 <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80004270:	0001d797          	auipc	a5,0x1d
    80004274:	0207a783          	lw	a5,32(a5) # 80021290 <log+0x20>
    80004278:	06f05063          	blez	a5,800042d8 <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    8000427c:	4781                	li	a5,0
    8000427e:	06c05563          	blez	a2,800042e8 <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
    80004282:	44cc                	lw	a1,12(s1)
    80004284:	0001d717          	auipc	a4,0x1d
    80004288:	01c70713          	addi	a4,a4,28 # 800212a0 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    8000428c:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorbtion
    8000428e:	4314                	lw	a3,0(a4)
    80004290:	04b68c63          	beq	a3,a1,800042e8 <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    80004294:	2785                	addiw	a5,a5,1
    80004296:	0711                	addi	a4,a4,4
    80004298:	fef61be3          	bne	a2,a5,8000428e <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    8000429c:	0621                	addi	a2,a2,8
    8000429e:	060a                	slli	a2,a2,0x2
    800042a0:	0001d797          	auipc	a5,0x1d
    800042a4:	fd078793          	addi	a5,a5,-48 # 80021270 <log>
    800042a8:	963e                	add	a2,a2,a5
    800042aa:	44dc                	lw	a5,12(s1)
    800042ac:	ca1c                	sw	a5,16(a2)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    800042ae:	8526                	mv	a0,s1
    800042b0:	fffff097          	auipc	ra,0xfffff
    800042b4:	daa080e7          	jalr	-598(ra) # 8000305a <bpin>
    log.lh.n++;
    800042b8:	0001d717          	auipc	a4,0x1d
    800042bc:	fb870713          	addi	a4,a4,-72 # 80021270 <log>
    800042c0:	575c                	lw	a5,44(a4)
    800042c2:	2785                	addiw	a5,a5,1
    800042c4:	d75c                	sw	a5,44(a4)
    800042c6:	a835                	j	80004302 <log_write+0xca>
    panic("too big a transaction");
    800042c8:	00004517          	auipc	a0,0x4
    800042cc:	38050513          	addi	a0,a0,896 # 80008648 <syscalls+0x1f8>
    800042d0:	ffffc097          	auipc	ra,0xffffc
    800042d4:	260080e7          	jalr	608(ra) # 80000530 <panic>
    panic("log_write outside of trans");
    800042d8:	00004517          	auipc	a0,0x4
    800042dc:	38850513          	addi	a0,a0,904 # 80008660 <syscalls+0x210>
    800042e0:	ffffc097          	auipc	ra,0xffffc
    800042e4:	250080e7          	jalr	592(ra) # 80000530 <panic>
  log.lh.block[i] = b->blockno;
    800042e8:	00878713          	addi	a4,a5,8
    800042ec:	00271693          	slli	a3,a4,0x2
    800042f0:	0001d717          	auipc	a4,0x1d
    800042f4:	f8070713          	addi	a4,a4,-128 # 80021270 <log>
    800042f8:	9736                	add	a4,a4,a3
    800042fa:	44d4                	lw	a3,12(s1)
    800042fc:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    800042fe:	faf608e3          	beq	a2,a5,800042ae <log_write+0x76>
  }
  release(&log.lock);
    80004302:	0001d517          	auipc	a0,0x1d
    80004306:	f6e50513          	addi	a0,a0,-146 # 80021270 <log>
    8000430a:	ffffd097          	auipc	ra,0xffffd
    8000430e:	980080e7          	jalr	-1664(ra) # 80000c8a <release>
}
    80004312:	60e2                	ld	ra,24(sp)
    80004314:	6442                	ld	s0,16(sp)
    80004316:	64a2                	ld	s1,8(sp)
    80004318:	6902                	ld	s2,0(sp)
    8000431a:	6105                	addi	sp,sp,32
    8000431c:	8082                	ret

000000008000431e <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    8000431e:	1101                	addi	sp,sp,-32
    80004320:	ec06                	sd	ra,24(sp)
    80004322:	e822                	sd	s0,16(sp)
    80004324:	e426                	sd	s1,8(sp)
    80004326:	e04a                	sd	s2,0(sp)
    80004328:	1000                	addi	s0,sp,32
    8000432a:	84aa                	mv	s1,a0
    8000432c:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    8000432e:	00004597          	auipc	a1,0x4
    80004332:	35258593          	addi	a1,a1,850 # 80008680 <syscalls+0x230>
    80004336:	0521                	addi	a0,a0,8
    80004338:	ffffd097          	auipc	ra,0xffffd
    8000433c:	80e080e7          	jalr	-2034(ra) # 80000b46 <initlock>
  lk->name = name;
    80004340:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80004344:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004348:	0204a423          	sw	zero,40(s1)
}
    8000434c:	60e2                	ld	ra,24(sp)
    8000434e:	6442                	ld	s0,16(sp)
    80004350:	64a2                	ld	s1,8(sp)
    80004352:	6902                	ld	s2,0(sp)
    80004354:	6105                	addi	sp,sp,32
    80004356:	8082                	ret

0000000080004358 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80004358:	1101                	addi	sp,sp,-32
    8000435a:	ec06                	sd	ra,24(sp)
    8000435c:	e822                	sd	s0,16(sp)
    8000435e:	e426                	sd	s1,8(sp)
    80004360:	e04a                	sd	s2,0(sp)
    80004362:	1000                	addi	s0,sp,32
    80004364:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004366:	00850913          	addi	s2,a0,8
    8000436a:	854a                	mv	a0,s2
    8000436c:	ffffd097          	auipc	ra,0xffffd
    80004370:	86a080e7          	jalr	-1942(ra) # 80000bd6 <acquire>
  while (lk->locked) {
    80004374:	409c                	lw	a5,0(s1)
    80004376:	cb89                	beqz	a5,80004388 <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    80004378:	85ca                	mv	a1,s2
    8000437a:	8526                	mv	a0,s1
    8000437c:	ffffe097          	auipc	ra,0xffffe
    80004380:	d8a080e7          	jalr	-630(ra) # 80002106 <sleep>
  while (lk->locked) {
    80004384:	409c                	lw	a5,0(s1)
    80004386:	fbed                	bnez	a5,80004378 <acquiresleep+0x20>
  }
  lk->locked = 1;
    80004388:	4785                	li	a5,1
    8000438a:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    8000438c:	ffffd097          	auipc	ra,0xffffd
    80004390:	6be080e7          	jalr	1726(ra) # 80001a4a <myproc>
    80004394:	591c                	lw	a5,48(a0)
    80004396:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80004398:	854a                	mv	a0,s2
    8000439a:	ffffd097          	auipc	ra,0xffffd
    8000439e:	8f0080e7          	jalr	-1808(ra) # 80000c8a <release>
}
    800043a2:	60e2                	ld	ra,24(sp)
    800043a4:	6442                	ld	s0,16(sp)
    800043a6:	64a2                	ld	s1,8(sp)
    800043a8:	6902                	ld	s2,0(sp)
    800043aa:	6105                	addi	sp,sp,32
    800043ac:	8082                	ret

00000000800043ae <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    800043ae:	1101                	addi	sp,sp,-32
    800043b0:	ec06                	sd	ra,24(sp)
    800043b2:	e822                	sd	s0,16(sp)
    800043b4:	e426                	sd	s1,8(sp)
    800043b6:	e04a                	sd	s2,0(sp)
    800043b8:	1000                	addi	s0,sp,32
    800043ba:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800043bc:	00850913          	addi	s2,a0,8
    800043c0:	854a                	mv	a0,s2
    800043c2:	ffffd097          	auipc	ra,0xffffd
    800043c6:	814080e7          	jalr	-2028(ra) # 80000bd6 <acquire>
  lk->locked = 0;
    800043ca:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800043ce:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    800043d2:	8526                	mv	a0,s1
    800043d4:	ffffe097          	auipc	ra,0xffffe
    800043d8:	ebe080e7          	jalr	-322(ra) # 80002292 <wakeup>
  release(&lk->lk);
    800043dc:	854a                	mv	a0,s2
    800043de:	ffffd097          	auipc	ra,0xffffd
    800043e2:	8ac080e7          	jalr	-1876(ra) # 80000c8a <release>
}
    800043e6:	60e2                	ld	ra,24(sp)
    800043e8:	6442                	ld	s0,16(sp)
    800043ea:	64a2                	ld	s1,8(sp)
    800043ec:	6902                	ld	s2,0(sp)
    800043ee:	6105                	addi	sp,sp,32
    800043f0:	8082                	ret

00000000800043f2 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    800043f2:	7179                	addi	sp,sp,-48
    800043f4:	f406                	sd	ra,40(sp)
    800043f6:	f022                	sd	s0,32(sp)
    800043f8:	ec26                	sd	s1,24(sp)
    800043fa:	e84a                	sd	s2,16(sp)
    800043fc:	e44e                	sd	s3,8(sp)
    800043fe:	1800                	addi	s0,sp,48
    80004400:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80004402:	00850913          	addi	s2,a0,8
    80004406:	854a                	mv	a0,s2
    80004408:	ffffc097          	auipc	ra,0xffffc
    8000440c:	7ce080e7          	jalr	1998(ra) # 80000bd6 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80004410:	409c                	lw	a5,0(s1)
    80004412:	ef99                	bnez	a5,80004430 <holdingsleep+0x3e>
    80004414:	4481                	li	s1,0
  release(&lk->lk);
    80004416:	854a                	mv	a0,s2
    80004418:	ffffd097          	auipc	ra,0xffffd
    8000441c:	872080e7          	jalr	-1934(ra) # 80000c8a <release>
  return r;
}
    80004420:	8526                	mv	a0,s1
    80004422:	70a2                	ld	ra,40(sp)
    80004424:	7402                	ld	s0,32(sp)
    80004426:	64e2                	ld	s1,24(sp)
    80004428:	6942                	ld	s2,16(sp)
    8000442a:	69a2                	ld	s3,8(sp)
    8000442c:	6145                	addi	sp,sp,48
    8000442e:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    80004430:	0284a983          	lw	s3,40(s1)
    80004434:	ffffd097          	auipc	ra,0xffffd
    80004438:	616080e7          	jalr	1558(ra) # 80001a4a <myproc>
    8000443c:	5904                	lw	s1,48(a0)
    8000443e:	413484b3          	sub	s1,s1,s3
    80004442:	0014b493          	seqz	s1,s1
    80004446:	bfc1                	j	80004416 <holdingsleep+0x24>

0000000080004448 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80004448:	1141                	addi	sp,sp,-16
    8000444a:	e406                	sd	ra,8(sp)
    8000444c:	e022                	sd	s0,0(sp)
    8000444e:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80004450:	00004597          	auipc	a1,0x4
    80004454:	24058593          	addi	a1,a1,576 # 80008690 <syscalls+0x240>
    80004458:	0001d517          	auipc	a0,0x1d
    8000445c:	f6050513          	addi	a0,a0,-160 # 800213b8 <ftable>
    80004460:	ffffc097          	auipc	ra,0xffffc
    80004464:	6e6080e7          	jalr	1766(ra) # 80000b46 <initlock>
}
    80004468:	60a2                	ld	ra,8(sp)
    8000446a:	6402                	ld	s0,0(sp)
    8000446c:	0141                	addi	sp,sp,16
    8000446e:	8082                	ret

0000000080004470 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80004470:	1101                	addi	sp,sp,-32
    80004472:	ec06                	sd	ra,24(sp)
    80004474:	e822                	sd	s0,16(sp)
    80004476:	e426                	sd	s1,8(sp)
    80004478:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    8000447a:	0001d517          	auipc	a0,0x1d
    8000447e:	f3e50513          	addi	a0,a0,-194 # 800213b8 <ftable>
    80004482:	ffffc097          	auipc	ra,0xffffc
    80004486:	754080e7          	jalr	1876(ra) # 80000bd6 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    8000448a:	0001d497          	auipc	s1,0x1d
    8000448e:	f4648493          	addi	s1,s1,-186 # 800213d0 <ftable+0x18>
    80004492:	0001e717          	auipc	a4,0x1e
    80004496:	ede70713          	addi	a4,a4,-290 # 80022370 <ftable+0xfb8>
    if(f->ref == 0){
    8000449a:	40dc                	lw	a5,4(s1)
    8000449c:	cf99                	beqz	a5,800044ba <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    8000449e:	02848493          	addi	s1,s1,40
    800044a2:	fee49ce3          	bne	s1,a4,8000449a <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    800044a6:	0001d517          	auipc	a0,0x1d
    800044aa:	f1250513          	addi	a0,a0,-238 # 800213b8 <ftable>
    800044ae:	ffffc097          	auipc	ra,0xffffc
    800044b2:	7dc080e7          	jalr	2012(ra) # 80000c8a <release>
  return 0;
    800044b6:	4481                	li	s1,0
    800044b8:	a819                	j	800044ce <filealloc+0x5e>
      f->ref = 1;
    800044ba:	4785                	li	a5,1
    800044bc:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    800044be:	0001d517          	auipc	a0,0x1d
    800044c2:	efa50513          	addi	a0,a0,-262 # 800213b8 <ftable>
    800044c6:	ffffc097          	auipc	ra,0xffffc
    800044ca:	7c4080e7          	jalr	1988(ra) # 80000c8a <release>
}
    800044ce:	8526                	mv	a0,s1
    800044d0:	60e2                	ld	ra,24(sp)
    800044d2:	6442                	ld	s0,16(sp)
    800044d4:	64a2                	ld	s1,8(sp)
    800044d6:	6105                	addi	sp,sp,32
    800044d8:	8082                	ret

00000000800044da <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    800044da:	1101                	addi	sp,sp,-32
    800044dc:	ec06                	sd	ra,24(sp)
    800044de:	e822                	sd	s0,16(sp)
    800044e0:	e426                	sd	s1,8(sp)
    800044e2:	1000                	addi	s0,sp,32
    800044e4:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    800044e6:	0001d517          	auipc	a0,0x1d
    800044ea:	ed250513          	addi	a0,a0,-302 # 800213b8 <ftable>
    800044ee:	ffffc097          	auipc	ra,0xffffc
    800044f2:	6e8080e7          	jalr	1768(ra) # 80000bd6 <acquire>
  if(f->ref < 1)
    800044f6:	40dc                	lw	a5,4(s1)
    800044f8:	02f05263          	blez	a5,8000451c <filedup+0x42>
    panic("filedup");
  f->ref++;
    800044fc:	2785                	addiw	a5,a5,1
    800044fe:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004500:	0001d517          	auipc	a0,0x1d
    80004504:	eb850513          	addi	a0,a0,-328 # 800213b8 <ftable>
    80004508:	ffffc097          	auipc	ra,0xffffc
    8000450c:	782080e7          	jalr	1922(ra) # 80000c8a <release>
  return f;
}
    80004510:	8526                	mv	a0,s1
    80004512:	60e2                	ld	ra,24(sp)
    80004514:	6442                	ld	s0,16(sp)
    80004516:	64a2                	ld	s1,8(sp)
    80004518:	6105                	addi	sp,sp,32
    8000451a:	8082                	ret
    panic("filedup");
    8000451c:	00004517          	auipc	a0,0x4
    80004520:	17c50513          	addi	a0,a0,380 # 80008698 <syscalls+0x248>
    80004524:	ffffc097          	auipc	ra,0xffffc
    80004528:	00c080e7          	jalr	12(ra) # 80000530 <panic>

000000008000452c <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    8000452c:	7139                	addi	sp,sp,-64
    8000452e:	fc06                	sd	ra,56(sp)
    80004530:	f822                	sd	s0,48(sp)
    80004532:	f426                	sd	s1,40(sp)
    80004534:	f04a                	sd	s2,32(sp)
    80004536:	ec4e                	sd	s3,24(sp)
    80004538:	e852                	sd	s4,16(sp)
    8000453a:	e456                	sd	s5,8(sp)
    8000453c:	0080                	addi	s0,sp,64
    8000453e:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004540:	0001d517          	auipc	a0,0x1d
    80004544:	e7850513          	addi	a0,a0,-392 # 800213b8 <ftable>
    80004548:	ffffc097          	auipc	ra,0xffffc
    8000454c:	68e080e7          	jalr	1678(ra) # 80000bd6 <acquire>
  if(f->ref < 1)
    80004550:	40dc                	lw	a5,4(s1)
    80004552:	06f05163          	blez	a5,800045b4 <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    80004556:	37fd                	addiw	a5,a5,-1
    80004558:	0007871b          	sext.w	a4,a5
    8000455c:	c0dc                	sw	a5,4(s1)
    8000455e:	06e04363          	bgtz	a4,800045c4 <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004562:	0004a903          	lw	s2,0(s1)
    80004566:	0094ca83          	lbu	s5,9(s1)
    8000456a:	0104ba03          	ld	s4,16(s1)
    8000456e:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80004572:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004576:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    8000457a:	0001d517          	auipc	a0,0x1d
    8000457e:	e3e50513          	addi	a0,a0,-450 # 800213b8 <ftable>
    80004582:	ffffc097          	auipc	ra,0xffffc
    80004586:	708080e7          	jalr	1800(ra) # 80000c8a <release>

  if(ff.type == FD_PIPE){
    8000458a:	4785                	li	a5,1
    8000458c:	04f90d63          	beq	s2,a5,800045e6 <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80004590:	3979                	addiw	s2,s2,-2
    80004592:	4785                	li	a5,1
    80004594:	0527e063          	bltu	a5,s2,800045d4 <fileclose+0xa8>
    begin_op();
    80004598:	00000097          	auipc	ra,0x0
    8000459c:	ac8080e7          	jalr	-1336(ra) # 80004060 <begin_op>
    iput(ff.ip);
    800045a0:	854e                	mv	a0,s3
    800045a2:	fffff097          	auipc	ra,0xfffff
    800045a6:	2a6080e7          	jalr	678(ra) # 80003848 <iput>
    end_op();
    800045aa:	00000097          	auipc	ra,0x0
    800045ae:	b36080e7          	jalr	-1226(ra) # 800040e0 <end_op>
    800045b2:	a00d                	j	800045d4 <fileclose+0xa8>
    panic("fileclose");
    800045b4:	00004517          	auipc	a0,0x4
    800045b8:	0ec50513          	addi	a0,a0,236 # 800086a0 <syscalls+0x250>
    800045bc:	ffffc097          	auipc	ra,0xffffc
    800045c0:	f74080e7          	jalr	-140(ra) # 80000530 <panic>
    release(&ftable.lock);
    800045c4:	0001d517          	auipc	a0,0x1d
    800045c8:	df450513          	addi	a0,a0,-524 # 800213b8 <ftable>
    800045cc:	ffffc097          	auipc	ra,0xffffc
    800045d0:	6be080e7          	jalr	1726(ra) # 80000c8a <release>
  }
}
    800045d4:	70e2                	ld	ra,56(sp)
    800045d6:	7442                	ld	s0,48(sp)
    800045d8:	74a2                	ld	s1,40(sp)
    800045da:	7902                	ld	s2,32(sp)
    800045dc:	69e2                	ld	s3,24(sp)
    800045de:	6a42                	ld	s4,16(sp)
    800045e0:	6aa2                	ld	s5,8(sp)
    800045e2:	6121                	addi	sp,sp,64
    800045e4:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    800045e6:	85d6                	mv	a1,s5
    800045e8:	8552                	mv	a0,s4
    800045ea:	00000097          	auipc	ra,0x0
    800045ee:	34c080e7          	jalr	844(ra) # 80004936 <pipeclose>
    800045f2:	b7cd                	j	800045d4 <fileclose+0xa8>

00000000800045f4 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    800045f4:	715d                	addi	sp,sp,-80
    800045f6:	e486                	sd	ra,72(sp)
    800045f8:	e0a2                	sd	s0,64(sp)
    800045fa:	fc26                	sd	s1,56(sp)
    800045fc:	f84a                	sd	s2,48(sp)
    800045fe:	f44e                	sd	s3,40(sp)
    80004600:	0880                	addi	s0,sp,80
    80004602:	84aa                	mv	s1,a0
    80004604:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80004606:	ffffd097          	auipc	ra,0xffffd
    8000460a:	444080e7          	jalr	1092(ra) # 80001a4a <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    8000460e:	409c                	lw	a5,0(s1)
    80004610:	37f9                	addiw	a5,a5,-2
    80004612:	4705                	li	a4,1
    80004614:	04f76763          	bltu	a4,a5,80004662 <filestat+0x6e>
    80004618:	892a                	mv	s2,a0
    ilock(f->ip);
    8000461a:	6c88                	ld	a0,24(s1)
    8000461c:	fffff097          	auipc	ra,0xfffff
    80004620:	072080e7          	jalr	114(ra) # 8000368e <ilock>
    stati(f->ip, &st);
    80004624:	fb840593          	addi	a1,s0,-72
    80004628:	6c88                	ld	a0,24(s1)
    8000462a:	fffff097          	auipc	ra,0xfffff
    8000462e:	2ee080e7          	jalr	750(ra) # 80003918 <stati>
    iunlock(f->ip);
    80004632:	6c88                	ld	a0,24(s1)
    80004634:	fffff097          	auipc	ra,0xfffff
    80004638:	11c080e7          	jalr	284(ra) # 80003750 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    8000463c:	46e1                	li	a3,24
    8000463e:	fb840613          	addi	a2,s0,-72
    80004642:	85ce                	mv	a1,s3
    80004644:	05093503          	ld	a0,80(s2)
    80004648:	ffffd097          	auipc	ra,0xffffd
    8000464c:	00e080e7          	jalr	14(ra) # 80001656 <copyout>
    80004650:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    80004654:	60a6                	ld	ra,72(sp)
    80004656:	6406                	ld	s0,64(sp)
    80004658:	74e2                	ld	s1,56(sp)
    8000465a:	7942                	ld	s2,48(sp)
    8000465c:	79a2                	ld	s3,40(sp)
    8000465e:	6161                	addi	sp,sp,80
    80004660:	8082                	ret
  return -1;
    80004662:	557d                	li	a0,-1
    80004664:	bfc5                	j	80004654 <filestat+0x60>

0000000080004666 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004666:	7179                	addi	sp,sp,-48
    80004668:	f406                	sd	ra,40(sp)
    8000466a:	f022                	sd	s0,32(sp)
    8000466c:	ec26                	sd	s1,24(sp)
    8000466e:	e84a                	sd	s2,16(sp)
    80004670:	e44e                	sd	s3,8(sp)
    80004672:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80004674:	00854783          	lbu	a5,8(a0)
    80004678:	c3d5                	beqz	a5,8000471c <fileread+0xb6>
    8000467a:	84aa                	mv	s1,a0
    8000467c:	89ae                	mv	s3,a1
    8000467e:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80004680:	411c                	lw	a5,0(a0)
    80004682:	4705                	li	a4,1
    80004684:	04e78963          	beq	a5,a4,800046d6 <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004688:	470d                	li	a4,3
    8000468a:	04e78d63          	beq	a5,a4,800046e4 <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    8000468e:	4709                	li	a4,2
    80004690:	06e79e63          	bne	a5,a4,8000470c <fileread+0xa6>
    ilock(f->ip);
    80004694:	6d08                	ld	a0,24(a0)
    80004696:	fffff097          	auipc	ra,0xfffff
    8000469a:	ff8080e7          	jalr	-8(ra) # 8000368e <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    8000469e:	874a                	mv	a4,s2
    800046a0:	5094                	lw	a3,32(s1)
    800046a2:	864e                	mv	a2,s3
    800046a4:	4585                	li	a1,1
    800046a6:	6c88                	ld	a0,24(s1)
    800046a8:	fffff097          	auipc	ra,0xfffff
    800046ac:	29a080e7          	jalr	666(ra) # 80003942 <readi>
    800046b0:	892a                	mv	s2,a0
    800046b2:	00a05563          	blez	a0,800046bc <fileread+0x56>
      f->off += r;
    800046b6:	509c                	lw	a5,32(s1)
    800046b8:	9fa9                	addw	a5,a5,a0
    800046ba:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    800046bc:	6c88                	ld	a0,24(s1)
    800046be:	fffff097          	auipc	ra,0xfffff
    800046c2:	092080e7          	jalr	146(ra) # 80003750 <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    800046c6:	854a                	mv	a0,s2
    800046c8:	70a2                	ld	ra,40(sp)
    800046ca:	7402                	ld	s0,32(sp)
    800046cc:	64e2                	ld	s1,24(sp)
    800046ce:	6942                	ld	s2,16(sp)
    800046d0:	69a2                	ld	s3,8(sp)
    800046d2:	6145                	addi	sp,sp,48
    800046d4:	8082                	ret
    r = piperead(f->pipe, addr, n);
    800046d6:	6908                	ld	a0,16(a0)
    800046d8:	00000097          	auipc	ra,0x0
    800046dc:	3c8080e7          	jalr	968(ra) # 80004aa0 <piperead>
    800046e0:	892a                	mv	s2,a0
    800046e2:	b7d5                	j	800046c6 <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    800046e4:	02451783          	lh	a5,36(a0)
    800046e8:	03079693          	slli	a3,a5,0x30
    800046ec:	92c1                	srli	a3,a3,0x30
    800046ee:	4725                	li	a4,9
    800046f0:	02d76863          	bltu	a4,a3,80004720 <fileread+0xba>
    800046f4:	0792                	slli	a5,a5,0x4
    800046f6:	0001d717          	auipc	a4,0x1d
    800046fa:	c2270713          	addi	a4,a4,-990 # 80021318 <devsw>
    800046fe:	97ba                	add	a5,a5,a4
    80004700:	639c                	ld	a5,0(a5)
    80004702:	c38d                	beqz	a5,80004724 <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    80004704:	4505                	li	a0,1
    80004706:	9782                	jalr	a5
    80004708:	892a                	mv	s2,a0
    8000470a:	bf75                	j	800046c6 <fileread+0x60>
    panic("fileread");
    8000470c:	00004517          	auipc	a0,0x4
    80004710:	fa450513          	addi	a0,a0,-92 # 800086b0 <syscalls+0x260>
    80004714:	ffffc097          	auipc	ra,0xffffc
    80004718:	e1c080e7          	jalr	-484(ra) # 80000530 <panic>
    return -1;
    8000471c:	597d                	li	s2,-1
    8000471e:	b765                	j	800046c6 <fileread+0x60>
      return -1;
    80004720:	597d                	li	s2,-1
    80004722:	b755                	j	800046c6 <fileread+0x60>
    80004724:	597d                	li	s2,-1
    80004726:	b745                	j	800046c6 <fileread+0x60>

0000000080004728 <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    80004728:	715d                	addi	sp,sp,-80
    8000472a:	e486                	sd	ra,72(sp)
    8000472c:	e0a2                	sd	s0,64(sp)
    8000472e:	fc26                	sd	s1,56(sp)
    80004730:	f84a                	sd	s2,48(sp)
    80004732:	f44e                	sd	s3,40(sp)
    80004734:	f052                	sd	s4,32(sp)
    80004736:	ec56                	sd	s5,24(sp)
    80004738:	e85a                	sd	s6,16(sp)
    8000473a:	e45e                	sd	s7,8(sp)
    8000473c:	e062                	sd	s8,0(sp)
    8000473e:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    80004740:	00954783          	lbu	a5,9(a0)
    80004744:	10078663          	beqz	a5,80004850 <filewrite+0x128>
    80004748:	892a                	mv	s2,a0
    8000474a:	8aae                	mv	s5,a1
    8000474c:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    8000474e:	411c                	lw	a5,0(a0)
    80004750:	4705                	li	a4,1
    80004752:	02e78263          	beq	a5,a4,80004776 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004756:	470d                	li	a4,3
    80004758:	02e78663          	beq	a5,a4,80004784 <filewrite+0x5c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    8000475c:	4709                	li	a4,2
    8000475e:	0ee79163          	bne	a5,a4,80004840 <filewrite+0x118>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004762:	0ac05d63          	blez	a2,8000481c <filewrite+0xf4>
    int i = 0;
    80004766:	4981                	li	s3,0
    80004768:	6b05                	lui	s6,0x1
    8000476a:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    8000476e:	6b85                	lui	s7,0x1
    80004770:	c00b8b9b          	addiw	s7,s7,-1024
    80004774:	a861                	j	8000480c <filewrite+0xe4>
    ret = pipewrite(f->pipe, addr, n);
    80004776:	6908                	ld	a0,16(a0)
    80004778:	00000097          	auipc	ra,0x0
    8000477c:	22e080e7          	jalr	558(ra) # 800049a6 <pipewrite>
    80004780:	8a2a                	mv	s4,a0
    80004782:	a045                	j	80004822 <filewrite+0xfa>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004784:	02451783          	lh	a5,36(a0)
    80004788:	03079693          	slli	a3,a5,0x30
    8000478c:	92c1                	srli	a3,a3,0x30
    8000478e:	4725                	li	a4,9
    80004790:	0cd76263          	bltu	a4,a3,80004854 <filewrite+0x12c>
    80004794:	0792                	slli	a5,a5,0x4
    80004796:	0001d717          	auipc	a4,0x1d
    8000479a:	b8270713          	addi	a4,a4,-1150 # 80021318 <devsw>
    8000479e:	97ba                	add	a5,a5,a4
    800047a0:	679c                	ld	a5,8(a5)
    800047a2:	cbdd                	beqz	a5,80004858 <filewrite+0x130>
    ret = devsw[f->major].write(1, addr, n);
    800047a4:	4505                	li	a0,1
    800047a6:	9782                	jalr	a5
    800047a8:	8a2a                	mv	s4,a0
    800047aa:	a8a5                	j	80004822 <filewrite+0xfa>
    800047ac:	00048c1b          	sext.w	s8,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    800047b0:	00000097          	auipc	ra,0x0
    800047b4:	8b0080e7          	jalr	-1872(ra) # 80004060 <begin_op>
      ilock(f->ip);
    800047b8:	01893503          	ld	a0,24(s2)
    800047bc:	fffff097          	auipc	ra,0xfffff
    800047c0:	ed2080e7          	jalr	-302(ra) # 8000368e <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    800047c4:	8762                	mv	a4,s8
    800047c6:	02092683          	lw	a3,32(s2)
    800047ca:	01598633          	add	a2,s3,s5
    800047ce:	4585                	li	a1,1
    800047d0:	01893503          	ld	a0,24(s2)
    800047d4:	fffff097          	auipc	ra,0xfffff
    800047d8:	266080e7          	jalr	614(ra) # 80003a3a <writei>
    800047dc:	84aa                	mv	s1,a0
    800047de:	00a05763          	blez	a0,800047ec <filewrite+0xc4>
        f->off += r;
    800047e2:	02092783          	lw	a5,32(s2)
    800047e6:	9fa9                	addw	a5,a5,a0
    800047e8:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    800047ec:	01893503          	ld	a0,24(s2)
    800047f0:	fffff097          	auipc	ra,0xfffff
    800047f4:	f60080e7          	jalr	-160(ra) # 80003750 <iunlock>
      end_op();
    800047f8:	00000097          	auipc	ra,0x0
    800047fc:	8e8080e7          	jalr	-1816(ra) # 800040e0 <end_op>

      if(r != n1){
    80004800:	009c1f63          	bne	s8,s1,8000481e <filewrite+0xf6>
        // error from writei
        break;
      }
      i += r;
    80004804:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80004808:	0149db63          	bge	s3,s4,8000481e <filewrite+0xf6>
      int n1 = n - i;
    8000480c:	413a07bb          	subw	a5,s4,s3
      if(n1 > max)
    80004810:	84be                	mv	s1,a5
    80004812:	2781                	sext.w	a5,a5
    80004814:	f8fb5ce3          	bge	s6,a5,800047ac <filewrite+0x84>
    80004818:	84de                	mv	s1,s7
    8000481a:	bf49                	j	800047ac <filewrite+0x84>
    int i = 0;
    8000481c:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    8000481e:	013a1f63          	bne	s4,s3,8000483c <filewrite+0x114>
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004822:	8552                	mv	a0,s4
    80004824:	60a6                	ld	ra,72(sp)
    80004826:	6406                	ld	s0,64(sp)
    80004828:	74e2                	ld	s1,56(sp)
    8000482a:	7942                	ld	s2,48(sp)
    8000482c:	79a2                	ld	s3,40(sp)
    8000482e:	7a02                	ld	s4,32(sp)
    80004830:	6ae2                	ld	s5,24(sp)
    80004832:	6b42                	ld	s6,16(sp)
    80004834:	6ba2                	ld	s7,8(sp)
    80004836:	6c02                	ld	s8,0(sp)
    80004838:	6161                	addi	sp,sp,80
    8000483a:	8082                	ret
    ret = (i == n ? n : -1);
    8000483c:	5a7d                	li	s4,-1
    8000483e:	b7d5                	j	80004822 <filewrite+0xfa>
    panic("filewrite");
    80004840:	00004517          	auipc	a0,0x4
    80004844:	e8050513          	addi	a0,a0,-384 # 800086c0 <syscalls+0x270>
    80004848:	ffffc097          	auipc	ra,0xffffc
    8000484c:	ce8080e7          	jalr	-792(ra) # 80000530 <panic>
    return -1;
    80004850:	5a7d                	li	s4,-1
    80004852:	bfc1                	j	80004822 <filewrite+0xfa>
      return -1;
    80004854:	5a7d                	li	s4,-1
    80004856:	b7f1                	j	80004822 <filewrite+0xfa>
    80004858:	5a7d                	li	s4,-1
    8000485a:	b7e1                	j	80004822 <filewrite+0xfa>

000000008000485c <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    8000485c:	7179                	addi	sp,sp,-48
    8000485e:	f406                	sd	ra,40(sp)
    80004860:	f022                	sd	s0,32(sp)
    80004862:	ec26                	sd	s1,24(sp)
    80004864:	e84a                	sd	s2,16(sp)
    80004866:	e44e                	sd	s3,8(sp)
    80004868:	e052                	sd	s4,0(sp)
    8000486a:	1800                	addi	s0,sp,48
    8000486c:	84aa                	mv	s1,a0
    8000486e:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004870:	0005b023          	sd	zero,0(a1)
    80004874:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004878:	00000097          	auipc	ra,0x0
    8000487c:	bf8080e7          	jalr	-1032(ra) # 80004470 <filealloc>
    80004880:	e088                	sd	a0,0(s1)
    80004882:	c551                	beqz	a0,8000490e <pipealloc+0xb2>
    80004884:	00000097          	auipc	ra,0x0
    80004888:	bec080e7          	jalr	-1044(ra) # 80004470 <filealloc>
    8000488c:	00aa3023          	sd	a0,0(s4)
    80004890:	c92d                	beqz	a0,80004902 <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004892:	ffffc097          	auipc	ra,0xffffc
    80004896:	254080e7          	jalr	596(ra) # 80000ae6 <kalloc>
    8000489a:	892a                	mv	s2,a0
    8000489c:	c125                	beqz	a0,800048fc <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    8000489e:	4985                	li	s3,1
    800048a0:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    800048a4:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    800048a8:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    800048ac:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    800048b0:	00004597          	auipc	a1,0x4
    800048b4:	e2058593          	addi	a1,a1,-480 # 800086d0 <syscalls+0x280>
    800048b8:	ffffc097          	auipc	ra,0xffffc
    800048bc:	28e080e7          	jalr	654(ra) # 80000b46 <initlock>
  (*f0)->type = FD_PIPE;
    800048c0:	609c                	ld	a5,0(s1)
    800048c2:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    800048c6:	609c                	ld	a5,0(s1)
    800048c8:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    800048cc:	609c                	ld	a5,0(s1)
    800048ce:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    800048d2:	609c                	ld	a5,0(s1)
    800048d4:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    800048d8:	000a3783          	ld	a5,0(s4)
    800048dc:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    800048e0:	000a3783          	ld	a5,0(s4)
    800048e4:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    800048e8:	000a3783          	ld	a5,0(s4)
    800048ec:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    800048f0:	000a3783          	ld	a5,0(s4)
    800048f4:	0127b823          	sd	s2,16(a5)
  return 0;
    800048f8:	4501                	li	a0,0
    800048fa:	a025                	j	80004922 <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    800048fc:	6088                	ld	a0,0(s1)
    800048fe:	e501                	bnez	a0,80004906 <pipealloc+0xaa>
    80004900:	a039                	j	8000490e <pipealloc+0xb2>
    80004902:	6088                	ld	a0,0(s1)
    80004904:	c51d                	beqz	a0,80004932 <pipealloc+0xd6>
    fileclose(*f0);
    80004906:	00000097          	auipc	ra,0x0
    8000490a:	c26080e7          	jalr	-986(ra) # 8000452c <fileclose>
  if(*f1)
    8000490e:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004912:	557d                	li	a0,-1
  if(*f1)
    80004914:	c799                	beqz	a5,80004922 <pipealloc+0xc6>
    fileclose(*f1);
    80004916:	853e                	mv	a0,a5
    80004918:	00000097          	auipc	ra,0x0
    8000491c:	c14080e7          	jalr	-1004(ra) # 8000452c <fileclose>
  return -1;
    80004920:	557d                	li	a0,-1
}
    80004922:	70a2                	ld	ra,40(sp)
    80004924:	7402                	ld	s0,32(sp)
    80004926:	64e2                	ld	s1,24(sp)
    80004928:	6942                	ld	s2,16(sp)
    8000492a:	69a2                	ld	s3,8(sp)
    8000492c:	6a02                	ld	s4,0(sp)
    8000492e:	6145                	addi	sp,sp,48
    80004930:	8082                	ret
  return -1;
    80004932:	557d                	li	a0,-1
    80004934:	b7fd                	j	80004922 <pipealloc+0xc6>

0000000080004936 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004936:	1101                	addi	sp,sp,-32
    80004938:	ec06                	sd	ra,24(sp)
    8000493a:	e822                	sd	s0,16(sp)
    8000493c:	e426                	sd	s1,8(sp)
    8000493e:	e04a                	sd	s2,0(sp)
    80004940:	1000                	addi	s0,sp,32
    80004942:	84aa                	mv	s1,a0
    80004944:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004946:	ffffc097          	auipc	ra,0xffffc
    8000494a:	290080e7          	jalr	656(ra) # 80000bd6 <acquire>
  if(writable){
    8000494e:	02090d63          	beqz	s2,80004988 <pipeclose+0x52>
    pi->writeopen = 0;
    80004952:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004956:	21848513          	addi	a0,s1,536
    8000495a:	ffffe097          	auipc	ra,0xffffe
    8000495e:	938080e7          	jalr	-1736(ra) # 80002292 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004962:	2204b783          	ld	a5,544(s1)
    80004966:	eb95                	bnez	a5,8000499a <pipeclose+0x64>
    release(&pi->lock);
    80004968:	8526                	mv	a0,s1
    8000496a:	ffffc097          	auipc	ra,0xffffc
    8000496e:	320080e7          	jalr	800(ra) # 80000c8a <release>
    kfree((char*)pi);
    80004972:	8526                	mv	a0,s1
    80004974:	ffffc097          	auipc	ra,0xffffc
    80004978:	076080e7          	jalr	118(ra) # 800009ea <kfree>
  } else
    release(&pi->lock);
}
    8000497c:	60e2                	ld	ra,24(sp)
    8000497e:	6442                	ld	s0,16(sp)
    80004980:	64a2                	ld	s1,8(sp)
    80004982:	6902                	ld	s2,0(sp)
    80004984:	6105                	addi	sp,sp,32
    80004986:	8082                	ret
    pi->readopen = 0;
    80004988:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    8000498c:	21c48513          	addi	a0,s1,540
    80004990:	ffffe097          	auipc	ra,0xffffe
    80004994:	902080e7          	jalr	-1790(ra) # 80002292 <wakeup>
    80004998:	b7e9                	j	80004962 <pipeclose+0x2c>
    release(&pi->lock);
    8000499a:	8526                	mv	a0,s1
    8000499c:	ffffc097          	auipc	ra,0xffffc
    800049a0:	2ee080e7          	jalr	750(ra) # 80000c8a <release>
}
    800049a4:	bfe1                	j	8000497c <pipeclose+0x46>

00000000800049a6 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    800049a6:	7159                	addi	sp,sp,-112
    800049a8:	f486                	sd	ra,104(sp)
    800049aa:	f0a2                	sd	s0,96(sp)
    800049ac:	eca6                	sd	s1,88(sp)
    800049ae:	e8ca                	sd	s2,80(sp)
    800049b0:	e4ce                	sd	s3,72(sp)
    800049b2:	e0d2                	sd	s4,64(sp)
    800049b4:	fc56                	sd	s5,56(sp)
    800049b6:	f85a                	sd	s6,48(sp)
    800049b8:	f45e                	sd	s7,40(sp)
    800049ba:	f062                	sd	s8,32(sp)
    800049bc:	ec66                	sd	s9,24(sp)
    800049be:	1880                	addi	s0,sp,112
    800049c0:	84aa                	mv	s1,a0
    800049c2:	8aae                	mv	s5,a1
    800049c4:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    800049c6:	ffffd097          	auipc	ra,0xffffd
    800049ca:	084080e7          	jalr	132(ra) # 80001a4a <myproc>
    800049ce:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    800049d0:	8526                	mv	a0,s1
    800049d2:	ffffc097          	auipc	ra,0xffffc
    800049d6:	204080e7          	jalr	516(ra) # 80000bd6 <acquire>
  while(i < n){
    800049da:	0d405163          	blez	s4,80004a9c <pipewrite+0xf6>
    800049de:	8ba6                	mv	s7,s1
  int i = 0;
    800049e0:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    800049e2:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    800049e4:	21848c93          	addi	s9,s1,536
      sleep(&pi->nwrite, &pi->lock);
    800049e8:	21c48c13          	addi	s8,s1,540
    800049ec:	a08d                	j	80004a4e <pipewrite+0xa8>
      release(&pi->lock);
    800049ee:	8526                	mv	a0,s1
    800049f0:	ffffc097          	auipc	ra,0xffffc
    800049f4:	29a080e7          	jalr	666(ra) # 80000c8a <release>
      return -1;
    800049f8:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    800049fa:	854a                	mv	a0,s2
    800049fc:	70a6                	ld	ra,104(sp)
    800049fe:	7406                	ld	s0,96(sp)
    80004a00:	64e6                	ld	s1,88(sp)
    80004a02:	6946                	ld	s2,80(sp)
    80004a04:	69a6                	ld	s3,72(sp)
    80004a06:	6a06                	ld	s4,64(sp)
    80004a08:	7ae2                	ld	s5,56(sp)
    80004a0a:	7b42                	ld	s6,48(sp)
    80004a0c:	7ba2                	ld	s7,40(sp)
    80004a0e:	7c02                	ld	s8,32(sp)
    80004a10:	6ce2                	ld	s9,24(sp)
    80004a12:	6165                	addi	sp,sp,112
    80004a14:	8082                	ret
      wakeup(&pi->nread);
    80004a16:	8566                	mv	a0,s9
    80004a18:	ffffe097          	auipc	ra,0xffffe
    80004a1c:	87a080e7          	jalr	-1926(ra) # 80002292 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004a20:	85de                	mv	a1,s7
    80004a22:	8562                	mv	a0,s8
    80004a24:	ffffd097          	auipc	ra,0xffffd
    80004a28:	6e2080e7          	jalr	1762(ra) # 80002106 <sleep>
    80004a2c:	a839                	j	80004a4a <pipewrite+0xa4>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004a2e:	21c4a783          	lw	a5,540(s1)
    80004a32:	0017871b          	addiw	a4,a5,1
    80004a36:	20e4ae23          	sw	a4,540(s1)
    80004a3a:	1ff7f793          	andi	a5,a5,511
    80004a3e:	97a6                	add	a5,a5,s1
    80004a40:	f9f44703          	lbu	a4,-97(s0)
    80004a44:	00e78c23          	sb	a4,24(a5)
      i++;
    80004a48:	2905                	addiw	s2,s2,1
  while(i < n){
    80004a4a:	03495d63          	bge	s2,s4,80004a84 <pipewrite+0xde>
    if(pi->readopen == 0 || pr->killed){
    80004a4e:	2204a783          	lw	a5,544(s1)
    80004a52:	dfd1                	beqz	a5,800049ee <pipewrite+0x48>
    80004a54:	0289a783          	lw	a5,40(s3)
    80004a58:	fbd9                	bnez	a5,800049ee <pipewrite+0x48>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80004a5a:	2184a783          	lw	a5,536(s1)
    80004a5e:	21c4a703          	lw	a4,540(s1)
    80004a62:	2007879b          	addiw	a5,a5,512
    80004a66:	faf708e3          	beq	a4,a5,80004a16 <pipewrite+0x70>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004a6a:	4685                	li	a3,1
    80004a6c:	01590633          	add	a2,s2,s5
    80004a70:	f9f40593          	addi	a1,s0,-97
    80004a74:	0509b503          	ld	a0,80(s3)
    80004a78:	ffffd097          	auipc	ra,0xffffd
    80004a7c:	c6a080e7          	jalr	-918(ra) # 800016e2 <copyin>
    80004a80:	fb6517e3          	bne	a0,s6,80004a2e <pipewrite+0x88>
  wakeup(&pi->nread);
    80004a84:	21848513          	addi	a0,s1,536
    80004a88:	ffffe097          	auipc	ra,0xffffe
    80004a8c:	80a080e7          	jalr	-2038(ra) # 80002292 <wakeup>
  release(&pi->lock);
    80004a90:	8526                	mv	a0,s1
    80004a92:	ffffc097          	auipc	ra,0xffffc
    80004a96:	1f8080e7          	jalr	504(ra) # 80000c8a <release>
  return i;
    80004a9a:	b785                	j	800049fa <pipewrite+0x54>
  int i = 0;
    80004a9c:	4901                	li	s2,0
    80004a9e:	b7dd                	j	80004a84 <pipewrite+0xde>

0000000080004aa0 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004aa0:	715d                	addi	sp,sp,-80
    80004aa2:	e486                	sd	ra,72(sp)
    80004aa4:	e0a2                	sd	s0,64(sp)
    80004aa6:	fc26                	sd	s1,56(sp)
    80004aa8:	f84a                	sd	s2,48(sp)
    80004aaa:	f44e                	sd	s3,40(sp)
    80004aac:	f052                	sd	s4,32(sp)
    80004aae:	ec56                	sd	s5,24(sp)
    80004ab0:	e85a                	sd	s6,16(sp)
    80004ab2:	0880                	addi	s0,sp,80
    80004ab4:	84aa                	mv	s1,a0
    80004ab6:	892e                	mv	s2,a1
    80004ab8:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004aba:	ffffd097          	auipc	ra,0xffffd
    80004abe:	f90080e7          	jalr	-112(ra) # 80001a4a <myproc>
    80004ac2:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004ac4:	8b26                	mv	s6,s1
    80004ac6:	8526                	mv	a0,s1
    80004ac8:	ffffc097          	auipc	ra,0xffffc
    80004acc:	10e080e7          	jalr	270(ra) # 80000bd6 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004ad0:	2184a703          	lw	a4,536(s1)
    80004ad4:	21c4a783          	lw	a5,540(s1)
    if(pr->killed){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004ad8:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004adc:	02f71463          	bne	a4,a5,80004b04 <piperead+0x64>
    80004ae0:	2244a783          	lw	a5,548(s1)
    80004ae4:	c385                	beqz	a5,80004b04 <piperead+0x64>
    if(pr->killed){
    80004ae6:	028a2783          	lw	a5,40(s4)
    80004aea:	ebc1                	bnez	a5,80004b7a <piperead+0xda>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004aec:	85da                	mv	a1,s6
    80004aee:	854e                	mv	a0,s3
    80004af0:	ffffd097          	auipc	ra,0xffffd
    80004af4:	616080e7          	jalr	1558(ra) # 80002106 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004af8:	2184a703          	lw	a4,536(s1)
    80004afc:	21c4a783          	lw	a5,540(s1)
    80004b00:	fef700e3          	beq	a4,a5,80004ae0 <piperead+0x40>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004b04:	09505263          	blez	s5,80004b88 <piperead+0xe8>
    80004b08:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004b0a:	5b7d                	li	s6,-1
    if(pi->nread == pi->nwrite)
    80004b0c:	2184a783          	lw	a5,536(s1)
    80004b10:	21c4a703          	lw	a4,540(s1)
    80004b14:	02f70d63          	beq	a4,a5,80004b4e <piperead+0xae>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80004b18:	0017871b          	addiw	a4,a5,1
    80004b1c:	20e4ac23          	sw	a4,536(s1)
    80004b20:	1ff7f793          	andi	a5,a5,511
    80004b24:	97a6                	add	a5,a5,s1
    80004b26:	0187c783          	lbu	a5,24(a5)
    80004b2a:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004b2e:	4685                	li	a3,1
    80004b30:	fbf40613          	addi	a2,s0,-65
    80004b34:	85ca                	mv	a1,s2
    80004b36:	050a3503          	ld	a0,80(s4)
    80004b3a:	ffffd097          	auipc	ra,0xffffd
    80004b3e:	b1c080e7          	jalr	-1252(ra) # 80001656 <copyout>
    80004b42:	01650663          	beq	a0,s6,80004b4e <piperead+0xae>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004b46:	2985                	addiw	s3,s3,1
    80004b48:	0905                	addi	s2,s2,1
    80004b4a:	fd3a91e3          	bne	s5,s3,80004b0c <piperead+0x6c>
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004b4e:	21c48513          	addi	a0,s1,540
    80004b52:	ffffd097          	auipc	ra,0xffffd
    80004b56:	740080e7          	jalr	1856(ra) # 80002292 <wakeup>
  release(&pi->lock);
    80004b5a:	8526                	mv	a0,s1
    80004b5c:	ffffc097          	auipc	ra,0xffffc
    80004b60:	12e080e7          	jalr	302(ra) # 80000c8a <release>
  return i;
}
    80004b64:	854e                	mv	a0,s3
    80004b66:	60a6                	ld	ra,72(sp)
    80004b68:	6406                	ld	s0,64(sp)
    80004b6a:	74e2                	ld	s1,56(sp)
    80004b6c:	7942                	ld	s2,48(sp)
    80004b6e:	79a2                	ld	s3,40(sp)
    80004b70:	7a02                	ld	s4,32(sp)
    80004b72:	6ae2                	ld	s5,24(sp)
    80004b74:	6b42                	ld	s6,16(sp)
    80004b76:	6161                	addi	sp,sp,80
    80004b78:	8082                	ret
      release(&pi->lock);
    80004b7a:	8526                	mv	a0,s1
    80004b7c:	ffffc097          	auipc	ra,0xffffc
    80004b80:	10e080e7          	jalr	270(ra) # 80000c8a <release>
      return -1;
    80004b84:	59fd                	li	s3,-1
    80004b86:	bff9                	j	80004b64 <piperead+0xc4>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004b88:	4981                	li	s3,0
    80004b8a:	b7d1                	j	80004b4e <piperead+0xae>

0000000080004b8c <exec>:

static int loadseg(pde_t *pgdir, uint64 addr, struct inode *ip, uint offset, uint sz);

int
exec(char *path, char **argv)
{
    80004b8c:	df010113          	addi	sp,sp,-528
    80004b90:	20113423          	sd	ra,520(sp)
    80004b94:	20813023          	sd	s0,512(sp)
    80004b98:	ffa6                	sd	s1,504(sp)
    80004b9a:	fbca                	sd	s2,496(sp)
    80004b9c:	f7ce                	sd	s3,488(sp)
    80004b9e:	f3d2                	sd	s4,480(sp)
    80004ba0:	efd6                	sd	s5,472(sp)
    80004ba2:	ebda                	sd	s6,464(sp)
    80004ba4:	e7de                	sd	s7,456(sp)
    80004ba6:	e3e2                	sd	s8,448(sp)
    80004ba8:	ff66                	sd	s9,440(sp)
    80004baa:	fb6a                	sd	s10,432(sp)
    80004bac:	f76e                	sd	s11,424(sp)
    80004bae:	0c00                	addi	s0,sp,528
    80004bb0:	84aa                	mv	s1,a0
    80004bb2:	dea43c23          	sd	a0,-520(s0)
    80004bb6:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004bba:	ffffd097          	auipc	ra,0xffffd
    80004bbe:	e90080e7          	jalr	-368(ra) # 80001a4a <myproc>
    80004bc2:	892a                	mv	s2,a0

  begin_op();
    80004bc4:	fffff097          	auipc	ra,0xfffff
    80004bc8:	49c080e7          	jalr	1180(ra) # 80004060 <begin_op>

  if((ip = namei(path)) == 0){
    80004bcc:	8526                	mv	a0,s1
    80004bce:	fffff097          	auipc	ra,0xfffff
    80004bd2:	276080e7          	jalr	630(ra) # 80003e44 <namei>
    80004bd6:	c92d                	beqz	a0,80004c48 <exec+0xbc>
    80004bd8:	84aa                	mv	s1,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80004bda:	fffff097          	auipc	ra,0xfffff
    80004bde:	ab4080e7          	jalr	-1356(ra) # 8000368e <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004be2:	04000713          	li	a4,64
    80004be6:	4681                	li	a3,0
    80004be8:	e4840613          	addi	a2,s0,-440
    80004bec:	4581                	li	a1,0
    80004bee:	8526                	mv	a0,s1
    80004bf0:	fffff097          	auipc	ra,0xfffff
    80004bf4:	d52080e7          	jalr	-686(ra) # 80003942 <readi>
    80004bf8:	04000793          	li	a5,64
    80004bfc:	00f51a63          	bne	a0,a5,80004c10 <exec+0x84>
    goto bad;
  if(elf.magic != ELF_MAGIC)
    80004c00:	e4842703          	lw	a4,-440(s0)
    80004c04:	464c47b7          	lui	a5,0x464c4
    80004c08:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004c0c:	04f70463          	beq	a4,a5,80004c54 <exec+0xc8>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80004c10:	8526                	mv	a0,s1
    80004c12:	fffff097          	auipc	ra,0xfffff
    80004c16:	cde080e7          	jalr	-802(ra) # 800038f0 <iunlockput>
    end_op();
    80004c1a:	fffff097          	auipc	ra,0xfffff
    80004c1e:	4c6080e7          	jalr	1222(ra) # 800040e0 <end_op>
  }
  return -1;
    80004c22:	557d                	li	a0,-1
}
    80004c24:	20813083          	ld	ra,520(sp)
    80004c28:	20013403          	ld	s0,512(sp)
    80004c2c:	74fe                	ld	s1,504(sp)
    80004c2e:	795e                	ld	s2,496(sp)
    80004c30:	79be                	ld	s3,488(sp)
    80004c32:	7a1e                	ld	s4,480(sp)
    80004c34:	6afe                	ld	s5,472(sp)
    80004c36:	6b5e                	ld	s6,464(sp)
    80004c38:	6bbe                	ld	s7,456(sp)
    80004c3a:	6c1e                	ld	s8,448(sp)
    80004c3c:	7cfa                	ld	s9,440(sp)
    80004c3e:	7d5a                	ld	s10,432(sp)
    80004c40:	7dba                	ld	s11,424(sp)
    80004c42:	21010113          	addi	sp,sp,528
    80004c46:	8082                	ret
    end_op();
    80004c48:	fffff097          	auipc	ra,0xfffff
    80004c4c:	498080e7          	jalr	1176(ra) # 800040e0 <end_op>
    return -1;
    80004c50:	557d                	li	a0,-1
    80004c52:	bfc9                	j	80004c24 <exec+0x98>
  if((pagetable = proc_pagetable(p)) == 0)
    80004c54:	854a                	mv	a0,s2
    80004c56:	ffffd097          	auipc	ra,0xffffd
    80004c5a:	eb8080e7          	jalr	-328(ra) # 80001b0e <proc_pagetable>
    80004c5e:	8baa                	mv	s7,a0
    80004c60:	d945                	beqz	a0,80004c10 <exec+0x84>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004c62:	e6842983          	lw	s3,-408(s0)
    80004c66:	e8045783          	lhu	a5,-384(s0)
    80004c6a:	c7ad                	beqz	a5,80004cd4 <exec+0x148>
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
    80004c6c:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004c6e:	4b01                	li	s6,0
    if(ph.vaddr % PGSIZE != 0)
    80004c70:	6c85                	lui	s9,0x1
    80004c72:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    80004c76:	def43823          	sd	a5,-528(s0)
    80004c7a:	a42d                	j	80004ea4 <exec+0x318>
    panic("loadseg: va must be page aligned");

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    80004c7c:	00004517          	auipc	a0,0x4
    80004c80:	a5c50513          	addi	a0,a0,-1444 # 800086d8 <syscalls+0x288>
    80004c84:	ffffc097          	auipc	ra,0xffffc
    80004c88:	8ac080e7          	jalr	-1876(ra) # 80000530 <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80004c8c:	8756                	mv	a4,s5
    80004c8e:	012d86bb          	addw	a3,s11,s2
    80004c92:	4581                	li	a1,0
    80004c94:	8526                	mv	a0,s1
    80004c96:	fffff097          	auipc	ra,0xfffff
    80004c9a:	cac080e7          	jalr	-852(ra) # 80003942 <readi>
    80004c9e:	2501                	sext.w	a0,a0
    80004ca0:	1aaa9963          	bne	s5,a0,80004e52 <exec+0x2c6>
  for(i = 0; i < sz; i += PGSIZE){
    80004ca4:	6785                	lui	a5,0x1
    80004ca6:	0127893b          	addw	s2,a5,s2
    80004caa:	77fd                	lui	a5,0xfffff
    80004cac:	01478a3b          	addw	s4,a5,s4
    80004cb0:	1f897163          	bgeu	s2,s8,80004e92 <exec+0x306>
    pa = walkaddr(pagetable, va + i);
    80004cb4:	02091593          	slli	a1,s2,0x20
    80004cb8:	9181                	srli	a1,a1,0x20
    80004cba:	95ea                	add	a1,a1,s10
    80004cbc:	855e                	mv	a0,s7
    80004cbe:	ffffc097          	auipc	ra,0xffffc
    80004cc2:	3a6080e7          	jalr	934(ra) # 80001064 <walkaddr>
    80004cc6:	862a                	mv	a2,a0
    if(pa == 0)
    80004cc8:	d955                	beqz	a0,80004c7c <exec+0xf0>
      n = PGSIZE;
    80004cca:	8ae6                	mv	s5,s9
    if(sz - i < PGSIZE)
    80004ccc:	fd9a70e3          	bgeu	s4,s9,80004c8c <exec+0x100>
      n = sz - i;
    80004cd0:	8ad2                	mv	s5,s4
    80004cd2:	bf6d                	j	80004c8c <exec+0x100>
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
    80004cd4:	4901                	li	s2,0
  iunlockput(ip);
    80004cd6:	8526                	mv	a0,s1
    80004cd8:	fffff097          	auipc	ra,0xfffff
    80004cdc:	c18080e7          	jalr	-1000(ra) # 800038f0 <iunlockput>
  end_op();
    80004ce0:	fffff097          	auipc	ra,0xfffff
    80004ce4:	400080e7          	jalr	1024(ra) # 800040e0 <end_op>
  p = myproc();
    80004ce8:	ffffd097          	auipc	ra,0xffffd
    80004cec:	d62080e7          	jalr	-670(ra) # 80001a4a <myproc>
    80004cf0:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    80004cf2:	04853d03          	ld	s10,72(a0)
  sz = PGROUNDUP(sz);
    80004cf6:	6785                	lui	a5,0x1
    80004cf8:	17fd                	addi	a5,a5,-1
    80004cfa:	993e                	add	s2,s2,a5
    80004cfc:	757d                	lui	a0,0xfffff
    80004cfe:	00a977b3          	and	a5,s2,a0
    80004d02:	e0f43423          	sd	a5,-504(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    80004d06:	6609                	lui	a2,0x2
    80004d08:	963e                	add	a2,a2,a5
    80004d0a:	85be                	mv	a1,a5
    80004d0c:	855e                	mv	a0,s7
    80004d0e:	ffffc097          	auipc	ra,0xffffc
    80004d12:	6f8080e7          	jalr	1784(ra) # 80001406 <uvmalloc>
    80004d16:	8b2a                	mv	s6,a0
  ip = 0;
    80004d18:	4481                	li	s1,0
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    80004d1a:	12050c63          	beqz	a0,80004e52 <exec+0x2c6>
  uvmclear(pagetable, sz-2*PGSIZE);
    80004d1e:	75f9                	lui	a1,0xffffe
    80004d20:	95aa                	add	a1,a1,a0
    80004d22:	855e                	mv	a0,s7
    80004d24:	ffffd097          	auipc	ra,0xffffd
    80004d28:	900080e7          	jalr	-1792(ra) # 80001624 <uvmclear>
  stackbase = sp - PGSIZE;
    80004d2c:	7c7d                	lui	s8,0xfffff
    80004d2e:	9c5a                	add	s8,s8,s6
  for(argc = 0; argv[argc]; argc++) {
    80004d30:	e0043783          	ld	a5,-512(s0)
    80004d34:	6388                	ld	a0,0(a5)
    80004d36:	c535                	beqz	a0,80004da2 <exec+0x216>
    80004d38:	e8840993          	addi	s3,s0,-376
    80004d3c:	f8840c93          	addi	s9,s0,-120
  sp = sz;
    80004d40:	895a                	mv	s2,s6
    sp -= strlen(argv[argc]) + 1;
    80004d42:	ffffc097          	auipc	ra,0xffffc
    80004d46:	118080e7          	jalr	280(ra) # 80000e5a <strlen>
    80004d4a:	2505                	addiw	a0,a0,1
    80004d4c:	40a90933          	sub	s2,s2,a0
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80004d50:	ff097913          	andi	s2,s2,-16
    if(sp < stackbase)
    80004d54:	13896363          	bltu	s2,s8,80004e7a <exec+0x2ee>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80004d58:	e0043d83          	ld	s11,-512(s0)
    80004d5c:	000dba03          	ld	s4,0(s11)
    80004d60:	8552                	mv	a0,s4
    80004d62:	ffffc097          	auipc	ra,0xffffc
    80004d66:	0f8080e7          	jalr	248(ra) # 80000e5a <strlen>
    80004d6a:	0015069b          	addiw	a3,a0,1
    80004d6e:	8652                	mv	a2,s4
    80004d70:	85ca                	mv	a1,s2
    80004d72:	855e                	mv	a0,s7
    80004d74:	ffffd097          	auipc	ra,0xffffd
    80004d78:	8e2080e7          	jalr	-1822(ra) # 80001656 <copyout>
    80004d7c:	10054363          	bltz	a0,80004e82 <exec+0x2f6>
    ustack[argc] = sp;
    80004d80:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80004d84:	0485                	addi	s1,s1,1
    80004d86:	008d8793          	addi	a5,s11,8
    80004d8a:	e0f43023          	sd	a5,-512(s0)
    80004d8e:	008db503          	ld	a0,8(s11)
    80004d92:	c911                	beqz	a0,80004da6 <exec+0x21a>
    if(argc >= MAXARG)
    80004d94:	09a1                	addi	s3,s3,8
    80004d96:	fb3c96e3          	bne	s9,s3,80004d42 <exec+0x1b6>
  sz = sz1;
    80004d9a:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    80004d9e:	4481                	li	s1,0
    80004da0:	a84d                	j	80004e52 <exec+0x2c6>
  sp = sz;
    80004da2:	895a                	mv	s2,s6
  for(argc = 0; argv[argc]; argc++) {
    80004da4:	4481                	li	s1,0
  ustack[argc] = 0;
    80004da6:	00349793          	slli	a5,s1,0x3
    80004daa:	f9040713          	addi	a4,s0,-112
    80004dae:	97ba                	add	a5,a5,a4
    80004db0:	ee07bc23          	sd	zero,-264(a5) # ef8 <_entry-0x7ffff108>
  sp -= (argc+1) * sizeof(uint64);
    80004db4:	00148693          	addi	a3,s1,1
    80004db8:	068e                	slli	a3,a3,0x3
    80004dba:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80004dbe:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    80004dc2:	01897663          	bgeu	s2,s8,80004dce <exec+0x242>
  sz = sz1;
    80004dc6:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    80004dca:	4481                	li	s1,0
    80004dcc:	a059                	j	80004e52 <exec+0x2c6>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80004dce:	e8840613          	addi	a2,s0,-376
    80004dd2:	85ca                	mv	a1,s2
    80004dd4:	855e                	mv	a0,s7
    80004dd6:	ffffd097          	auipc	ra,0xffffd
    80004dda:	880080e7          	jalr	-1920(ra) # 80001656 <copyout>
    80004dde:	0a054663          	bltz	a0,80004e8a <exec+0x2fe>
  p->trapframe->a1 = sp;
    80004de2:	058ab783          	ld	a5,88(s5)
    80004de6:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80004dea:	df843783          	ld	a5,-520(s0)
    80004dee:	0007c703          	lbu	a4,0(a5)
    80004df2:	cf11                	beqz	a4,80004e0e <exec+0x282>
    80004df4:	0785                	addi	a5,a5,1
    if(*s == '/')
    80004df6:	02f00693          	li	a3,47
    80004dfa:	a029                	j	80004e04 <exec+0x278>
  for(last=s=path; *s; s++)
    80004dfc:	0785                	addi	a5,a5,1
    80004dfe:	fff7c703          	lbu	a4,-1(a5)
    80004e02:	c711                	beqz	a4,80004e0e <exec+0x282>
    if(*s == '/')
    80004e04:	fed71ce3          	bne	a4,a3,80004dfc <exec+0x270>
      last = s+1;
    80004e08:	def43c23          	sd	a5,-520(s0)
    80004e0c:	bfc5                	j	80004dfc <exec+0x270>
  safestrcpy(p->name, last, sizeof(p->name));
    80004e0e:	4641                	li	a2,16
    80004e10:	df843583          	ld	a1,-520(s0)
    80004e14:	158a8513          	addi	a0,s5,344
    80004e18:	ffffc097          	auipc	ra,0xffffc
    80004e1c:	010080e7          	jalr	16(ra) # 80000e28 <safestrcpy>
  oldpagetable = p->pagetable;
    80004e20:	050ab503          	ld	a0,80(s5)
  p->pagetable = pagetable;
    80004e24:	057ab823          	sd	s7,80(s5)
  p->sz = sz;
    80004e28:	056ab423          	sd	s6,72(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    80004e2c:	058ab783          	ld	a5,88(s5)
    80004e30:	e6043703          	ld	a4,-416(s0)
    80004e34:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80004e36:	058ab783          	ld	a5,88(s5)
    80004e3a:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80004e3e:	85ea                	mv	a1,s10
    80004e40:	ffffd097          	auipc	ra,0xffffd
    80004e44:	d6a080e7          	jalr	-662(ra) # 80001baa <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80004e48:	0004851b          	sext.w	a0,s1
    80004e4c:	bbe1                	j	80004c24 <exec+0x98>
    80004e4e:	e1243423          	sd	s2,-504(s0)
    proc_freepagetable(pagetable, sz);
    80004e52:	e0843583          	ld	a1,-504(s0)
    80004e56:	855e                	mv	a0,s7
    80004e58:	ffffd097          	auipc	ra,0xffffd
    80004e5c:	d52080e7          	jalr	-686(ra) # 80001baa <proc_freepagetable>
  if(ip){
    80004e60:	da0498e3          	bnez	s1,80004c10 <exec+0x84>
  return -1;
    80004e64:	557d                	li	a0,-1
    80004e66:	bb7d                	j	80004c24 <exec+0x98>
    80004e68:	e1243423          	sd	s2,-504(s0)
    80004e6c:	b7dd                	j	80004e52 <exec+0x2c6>
    80004e6e:	e1243423          	sd	s2,-504(s0)
    80004e72:	b7c5                	j	80004e52 <exec+0x2c6>
    80004e74:	e1243423          	sd	s2,-504(s0)
    80004e78:	bfe9                	j	80004e52 <exec+0x2c6>
  sz = sz1;
    80004e7a:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    80004e7e:	4481                	li	s1,0
    80004e80:	bfc9                	j	80004e52 <exec+0x2c6>
  sz = sz1;
    80004e82:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    80004e86:	4481                	li	s1,0
    80004e88:	b7e9                	j	80004e52 <exec+0x2c6>
  sz = sz1;
    80004e8a:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    80004e8e:	4481                	li	s1,0
    80004e90:	b7c9                	j	80004e52 <exec+0x2c6>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    80004e92:	e0843903          	ld	s2,-504(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004e96:	2b05                	addiw	s6,s6,1
    80004e98:	0389899b          	addiw	s3,s3,56
    80004e9c:	e8045783          	lhu	a5,-384(s0)
    80004ea0:	e2fb5be3          	bge	s6,a5,80004cd6 <exec+0x14a>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80004ea4:	2981                	sext.w	s3,s3
    80004ea6:	03800713          	li	a4,56
    80004eaa:	86ce                	mv	a3,s3
    80004eac:	e1040613          	addi	a2,s0,-496
    80004eb0:	4581                	li	a1,0
    80004eb2:	8526                	mv	a0,s1
    80004eb4:	fffff097          	auipc	ra,0xfffff
    80004eb8:	a8e080e7          	jalr	-1394(ra) # 80003942 <readi>
    80004ebc:	03800793          	li	a5,56
    80004ec0:	f8f517e3          	bne	a0,a5,80004e4e <exec+0x2c2>
    if(ph.type != ELF_PROG_LOAD)
    80004ec4:	e1042783          	lw	a5,-496(s0)
    80004ec8:	4705                	li	a4,1
    80004eca:	fce796e3          	bne	a5,a4,80004e96 <exec+0x30a>
    if(ph.memsz < ph.filesz)
    80004ece:	e3843603          	ld	a2,-456(s0)
    80004ed2:	e3043783          	ld	a5,-464(s0)
    80004ed6:	f8f669e3          	bltu	a2,a5,80004e68 <exec+0x2dc>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80004eda:	e2043783          	ld	a5,-480(s0)
    80004ede:	963e                	add	a2,a2,a5
    80004ee0:	f8f667e3          	bltu	a2,a5,80004e6e <exec+0x2e2>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    80004ee4:	85ca                	mv	a1,s2
    80004ee6:	855e                	mv	a0,s7
    80004ee8:	ffffc097          	auipc	ra,0xffffc
    80004eec:	51e080e7          	jalr	1310(ra) # 80001406 <uvmalloc>
    80004ef0:	e0a43423          	sd	a0,-504(s0)
    80004ef4:	d141                	beqz	a0,80004e74 <exec+0x2e8>
    if(ph.vaddr % PGSIZE != 0)
    80004ef6:	e2043d03          	ld	s10,-480(s0)
    80004efa:	df043783          	ld	a5,-528(s0)
    80004efe:	00fd77b3          	and	a5,s10,a5
    80004f02:	fba1                	bnez	a5,80004e52 <exec+0x2c6>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80004f04:	e1842d83          	lw	s11,-488(s0)
    80004f08:	e3042c03          	lw	s8,-464(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80004f0c:	f80c03e3          	beqz	s8,80004e92 <exec+0x306>
    80004f10:	8a62                	mv	s4,s8
    80004f12:	4901                	li	s2,0
    80004f14:	b345                	j	80004cb4 <exec+0x128>

0000000080004f16 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80004f16:	7179                	addi	sp,sp,-48
    80004f18:	f406                	sd	ra,40(sp)
    80004f1a:	f022                	sd	s0,32(sp)
    80004f1c:	ec26                	sd	s1,24(sp)
    80004f1e:	e84a                	sd	s2,16(sp)
    80004f20:	1800                	addi	s0,sp,48
    80004f22:	892e                	mv	s2,a1
    80004f24:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
    80004f26:	fdc40593          	addi	a1,s0,-36
    80004f2a:	ffffe097          	auipc	ra,0xffffe
    80004f2e:	bcc080e7          	jalr	-1076(ra) # 80002af6 <argint>
    80004f32:	04054063          	bltz	a0,80004f72 <argfd+0x5c>
    return -1;
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80004f36:	fdc42703          	lw	a4,-36(s0)
    80004f3a:	47bd                	li	a5,15
    80004f3c:	02e7ed63          	bltu	a5,a4,80004f76 <argfd+0x60>
    80004f40:	ffffd097          	auipc	ra,0xffffd
    80004f44:	b0a080e7          	jalr	-1270(ra) # 80001a4a <myproc>
    80004f48:	fdc42703          	lw	a4,-36(s0)
    80004f4c:	01a70793          	addi	a5,a4,26
    80004f50:	078e                	slli	a5,a5,0x3
    80004f52:	953e                	add	a0,a0,a5
    80004f54:	611c                	ld	a5,0(a0)
    80004f56:	c395                	beqz	a5,80004f7a <argfd+0x64>
    return -1;
  if(pfd)
    80004f58:	00090463          	beqz	s2,80004f60 <argfd+0x4a>
    *pfd = fd;
    80004f5c:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80004f60:	4501                	li	a0,0
  if(pf)
    80004f62:	c091                	beqz	s1,80004f66 <argfd+0x50>
    *pf = f;
    80004f64:	e09c                	sd	a5,0(s1)
}
    80004f66:	70a2                	ld	ra,40(sp)
    80004f68:	7402                	ld	s0,32(sp)
    80004f6a:	64e2                	ld	s1,24(sp)
    80004f6c:	6942                	ld	s2,16(sp)
    80004f6e:	6145                	addi	sp,sp,48
    80004f70:	8082                	ret
    return -1;
    80004f72:	557d                	li	a0,-1
    80004f74:	bfcd                	j	80004f66 <argfd+0x50>
    return -1;
    80004f76:	557d                	li	a0,-1
    80004f78:	b7fd                	j	80004f66 <argfd+0x50>
    80004f7a:	557d                	li	a0,-1
    80004f7c:	b7ed                	j	80004f66 <argfd+0x50>

0000000080004f7e <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80004f7e:	1101                	addi	sp,sp,-32
    80004f80:	ec06                	sd	ra,24(sp)
    80004f82:	e822                	sd	s0,16(sp)
    80004f84:	e426                	sd	s1,8(sp)
    80004f86:	1000                	addi	s0,sp,32
    80004f88:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80004f8a:	ffffd097          	auipc	ra,0xffffd
    80004f8e:	ac0080e7          	jalr	-1344(ra) # 80001a4a <myproc>
    80004f92:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80004f94:	0d050793          	addi	a5,a0,208 # fffffffffffff0d0 <end+0xffffffff7ffd90d0>
    80004f98:	4501                	li	a0,0
    80004f9a:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80004f9c:	6398                	ld	a4,0(a5)
    80004f9e:	cb19                	beqz	a4,80004fb4 <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    80004fa0:	2505                	addiw	a0,a0,1
    80004fa2:	07a1                	addi	a5,a5,8
    80004fa4:	fed51ce3          	bne	a0,a3,80004f9c <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80004fa8:	557d                	li	a0,-1
}
    80004faa:	60e2                	ld	ra,24(sp)
    80004fac:	6442                	ld	s0,16(sp)
    80004fae:	64a2                	ld	s1,8(sp)
    80004fb0:	6105                	addi	sp,sp,32
    80004fb2:	8082                	ret
      p->ofile[fd] = f;
    80004fb4:	01a50793          	addi	a5,a0,26
    80004fb8:	078e                	slli	a5,a5,0x3
    80004fba:	963e                	add	a2,a2,a5
    80004fbc:	e204                	sd	s1,0(a2)
      return fd;
    80004fbe:	b7f5                	j	80004faa <fdalloc+0x2c>

0000000080004fc0 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80004fc0:	715d                	addi	sp,sp,-80
    80004fc2:	e486                	sd	ra,72(sp)
    80004fc4:	e0a2                	sd	s0,64(sp)
    80004fc6:	fc26                	sd	s1,56(sp)
    80004fc8:	f84a                	sd	s2,48(sp)
    80004fca:	f44e                	sd	s3,40(sp)
    80004fcc:	f052                	sd	s4,32(sp)
    80004fce:	ec56                	sd	s5,24(sp)
    80004fd0:	0880                	addi	s0,sp,80
    80004fd2:	89ae                	mv	s3,a1
    80004fd4:	8ab2                	mv	s5,a2
    80004fd6:	8a36                	mv	s4,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80004fd8:	fb040593          	addi	a1,s0,-80
    80004fdc:	fffff097          	auipc	ra,0xfffff
    80004fe0:	e86080e7          	jalr	-378(ra) # 80003e62 <nameiparent>
    80004fe4:	892a                	mv	s2,a0
    80004fe6:	12050f63          	beqz	a0,80005124 <create+0x164>
    return 0;

  ilock(dp);
    80004fea:	ffffe097          	auipc	ra,0xffffe
    80004fee:	6a4080e7          	jalr	1700(ra) # 8000368e <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80004ff2:	4601                	li	a2,0
    80004ff4:	fb040593          	addi	a1,s0,-80
    80004ff8:	854a                	mv	a0,s2
    80004ffa:	fffff097          	auipc	ra,0xfffff
    80004ffe:	b78080e7          	jalr	-1160(ra) # 80003b72 <dirlookup>
    80005002:	84aa                	mv	s1,a0
    80005004:	c921                	beqz	a0,80005054 <create+0x94>
    iunlockput(dp);
    80005006:	854a                	mv	a0,s2
    80005008:	fffff097          	auipc	ra,0xfffff
    8000500c:	8e8080e7          	jalr	-1816(ra) # 800038f0 <iunlockput>
    ilock(ip);
    80005010:	8526                	mv	a0,s1
    80005012:	ffffe097          	auipc	ra,0xffffe
    80005016:	67c080e7          	jalr	1660(ra) # 8000368e <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    8000501a:	2981                	sext.w	s3,s3
    8000501c:	4789                	li	a5,2
    8000501e:	02f99463          	bne	s3,a5,80005046 <create+0x86>
    80005022:	0444d783          	lhu	a5,68(s1)
    80005026:	37f9                	addiw	a5,a5,-2
    80005028:	17c2                	slli	a5,a5,0x30
    8000502a:	93c1                	srli	a5,a5,0x30
    8000502c:	4705                	li	a4,1
    8000502e:	00f76c63          	bltu	a4,a5,80005046 <create+0x86>
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
    80005032:	8526                	mv	a0,s1
    80005034:	60a6                	ld	ra,72(sp)
    80005036:	6406                	ld	s0,64(sp)
    80005038:	74e2                	ld	s1,56(sp)
    8000503a:	7942                	ld	s2,48(sp)
    8000503c:	79a2                	ld	s3,40(sp)
    8000503e:	7a02                	ld	s4,32(sp)
    80005040:	6ae2                	ld	s5,24(sp)
    80005042:	6161                	addi	sp,sp,80
    80005044:	8082                	ret
    iunlockput(ip);
    80005046:	8526                	mv	a0,s1
    80005048:	fffff097          	auipc	ra,0xfffff
    8000504c:	8a8080e7          	jalr	-1880(ra) # 800038f0 <iunlockput>
    return 0;
    80005050:	4481                	li	s1,0
    80005052:	b7c5                	j	80005032 <create+0x72>
  if((ip = ialloc(dp->dev, type)) == 0)
    80005054:	85ce                	mv	a1,s3
    80005056:	00092503          	lw	a0,0(s2)
    8000505a:	ffffe097          	auipc	ra,0xffffe
    8000505e:	49c080e7          	jalr	1180(ra) # 800034f6 <ialloc>
    80005062:	84aa                	mv	s1,a0
    80005064:	c529                	beqz	a0,800050ae <create+0xee>
  ilock(ip);
    80005066:	ffffe097          	auipc	ra,0xffffe
    8000506a:	628080e7          	jalr	1576(ra) # 8000368e <ilock>
  ip->major = major;
    8000506e:	05549323          	sh	s5,70(s1)
  ip->minor = minor;
    80005072:	05449423          	sh	s4,72(s1)
  ip->nlink = 1;
    80005076:	4785                	li	a5,1
    80005078:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    8000507c:	8526                	mv	a0,s1
    8000507e:	ffffe097          	auipc	ra,0xffffe
    80005082:	546080e7          	jalr	1350(ra) # 800035c4 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80005086:	2981                	sext.w	s3,s3
    80005088:	4785                	li	a5,1
    8000508a:	02f98a63          	beq	s3,a5,800050be <create+0xfe>
  if(dirlink(dp, name, ip->inum) < 0)
    8000508e:	40d0                	lw	a2,4(s1)
    80005090:	fb040593          	addi	a1,s0,-80
    80005094:	854a                	mv	a0,s2
    80005096:	fffff097          	auipc	ra,0xfffff
    8000509a:	cec080e7          	jalr	-788(ra) # 80003d82 <dirlink>
    8000509e:	06054b63          	bltz	a0,80005114 <create+0x154>
  iunlockput(dp);
    800050a2:	854a                	mv	a0,s2
    800050a4:	fffff097          	auipc	ra,0xfffff
    800050a8:	84c080e7          	jalr	-1972(ra) # 800038f0 <iunlockput>
  return ip;
    800050ac:	b759                	j	80005032 <create+0x72>
    panic("create: ialloc");
    800050ae:	00003517          	auipc	a0,0x3
    800050b2:	64a50513          	addi	a0,a0,1610 # 800086f8 <syscalls+0x2a8>
    800050b6:	ffffb097          	auipc	ra,0xffffb
    800050ba:	47a080e7          	jalr	1146(ra) # 80000530 <panic>
    dp->nlink++;  // for ".."
    800050be:	04a95783          	lhu	a5,74(s2)
    800050c2:	2785                	addiw	a5,a5,1
    800050c4:	04f91523          	sh	a5,74(s2)
    iupdate(dp);
    800050c8:	854a                	mv	a0,s2
    800050ca:	ffffe097          	auipc	ra,0xffffe
    800050ce:	4fa080e7          	jalr	1274(ra) # 800035c4 <iupdate>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    800050d2:	40d0                	lw	a2,4(s1)
    800050d4:	00003597          	auipc	a1,0x3
    800050d8:	63458593          	addi	a1,a1,1588 # 80008708 <syscalls+0x2b8>
    800050dc:	8526                	mv	a0,s1
    800050de:	fffff097          	auipc	ra,0xfffff
    800050e2:	ca4080e7          	jalr	-860(ra) # 80003d82 <dirlink>
    800050e6:	00054f63          	bltz	a0,80005104 <create+0x144>
    800050ea:	00492603          	lw	a2,4(s2)
    800050ee:	00003597          	auipc	a1,0x3
    800050f2:	62258593          	addi	a1,a1,1570 # 80008710 <syscalls+0x2c0>
    800050f6:	8526                	mv	a0,s1
    800050f8:	fffff097          	auipc	ra,0xfffff
    800050fc:	c8a080e7          	jalr	-886(ra) # 80003d82 <dirlink>
    80005100:	f80557e3          	bgez	a0,8000508e <create+0xce>
      panic("create dots");
    80005104:	00003517          	auipc	a0,0x3
    80005108:	61450513          	addi	a0,a0,1556 # 80008718 <syscalls+0x2c8>
    8000510c:	ffffb097          	auipc	ra,0xffffb
    80005110:	424080e7          	jalr	1060(ra) # 80000530 <panic>
    panic("create: dirlink");
    80005114:	00003517          	auipc	a0,0x3
    80005118:	61450513          	addi	a0,a0,1556 # 80008728 <syscalls+0x2d8>
    8000511c:	ffffb097          	auipc	ra,0xffffb
    80005120:	414080e7          	jalr	1044(ra) # 80000530 <panic>
    return 0;
    80005124:	84aa                	mv	s1,a0
    80005126:	b731                	j	80005032 <create+0x72>

0000000080005128 <sys_dup>:
{
    80005128:	7179                	addi	sp,sp,-48
    8000512a:	f406                	sd	ra,40(sp)
    8000512c:	f022                	sd	s0,32(sp)
    8000512e:	ec26                	sd	s1,24(sp)
    80005130:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80005132:	fd840613          	addi	a2,s0,-40
    80005136:	4581                	li	a1,0
    80005138:	4501                	li	a0,0
    8000513a:	00000097          	auipc	ra,0x0
    8000513e:	ddc080e7          	jalr	-548(ra) # 80004f16 <argfd>
    return -1;
    80005142:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80005144:	02054363          	bltz	a0,8000516a <sys_dup+0x42>
  if((fd=fdalloc(f)) < 0)
    80005148:	fd843503          	ld	a0,-40(s0)
    8000514c:	00000097          	auipc	ra,0x0
    80005150:	e32080e7          	jalr	-462(ra) # 80004f7e <fdalloc>
    80005154:	84aa                	mv	s1,a0
    return -1;
    80005156:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80005158:	00054963          	bltz	a0,8000516a <sys_dup+0x42>
  filedup(f);
    8000515c:	fd843503          	ld	a0,-40(s0)
    80005160:	fffff097          	auipc	ra,0xfffff
    80005164:	37a080e7          	jalr	890(ra) # 800044da <filedup>
  return fd;
    80005168:	87a6                	mv	a5,s1
}
    8000516a:	853e                	mv	a0,a5
    8000516c:	70a2                	ld	ra,40(sp)
    8000516e:	7402                	ld	s0,32(sp)
    80005170:	64e2                	ld	s1,24(sp)
    80005172:	6145                	addi	sp,sp,48
    80005174:	8082                	ret

0000000080005176 <sys_read>:
{
    80005176:	7179                	addi	sp,sp,-48
    80005178:	f406                	sd	ra,40(sp)
    8000517a:	f022                	sd	s0,32(sp)
    8000517c:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000517e:	fe840613          	addi	a2,s0,-24
    80005182:	4581                	li	a1,0
    80005184:	4501                	li	a0,0
    80005186:	00000097          	auipc	ra,0x0
    8000518a:	d90080e7          	jalr	-624(ra) # 80004f16 <argfd>
    return -1;
    8000518e:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005190:	04054163          	bltz	a0,800051d2 <sys_read+0x5c>
    80005194:	fe440593          	addi	a1,s0,-28
    80005198:	4509                	li	a0,2
    8000519a:	ffffe097          	auipc	ra,0xffffe
    8000519e:	95c080e7          	jalr	-1700(ra) # 80002af6 <argint>
    return -1;
    800051a2:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800051a4:	02054763          	bltz	a0,800051d2 <sys_read+0x5c>
    800051a8:	fd840593          	addi	a1,s0,-40
    800051ac:	4505                	li	a0,1
    800051ae:	ffffe097          	auipc	ra,0xffffe
    800051b2:	96a080e7          	jalr	-1686(ra) # 80002b18 <argaddr>
    return -1;
    800051b6:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800051b8:	00054d63          	bltz	a0,800051d2 <sys_read+0x5c>
  return fileread(f, p, n);
    800051bc:	fe442603          	lw	a2,-28(s0)
    800051c0:	fd843583          	ld	a1,-40(s0)
    800051c4:	fe843503          	ld	a0,-24(s0)
    800051c8:	fffff097          	auipc	ra,0xfffff
    800051cc:	49e080e7          	jalr	1182(ra) # 80004666 <fileread>
    800051d0:	87aa                	mv	a5,a0
}
    800051d2:	853e                	mv	a0,a5
    800051d4:	70a2                	ld	ra,40(sp)
    800051d6:	7402                	ld	s0,32(sp)
    800051d8:	6145                	addi	sp,sp,48
    800051da:	8082                	ret

00000000800051dc <sys_write>:
{
    800051dc:	7179                	addi	sp,sp,-48
    800051de:	f406                	sd	ra,40(sp)
    800051e0:	f022                	sd	s0,32(sp)
    800051e2:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800051e4:	fe840613          	addi	a2,s0,-24
    800051e8:	4581                	li	a1,0
    800051ea:	4501                	li	a0,0
    800051ec:	00000097          	auipc	ra,0x0
    800051f0:	d2a080e7          	jalr	-726(ra) # 80004f16 <argfd>
    return -1;
    800051f4:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800051f6:	04054163          	bltz	a0,80005238 <sys_write+0x5c>
    800051fa:	fe440593          	addi	a1,s0,-28
    800051fe:	4509                	li	a0,2
    80005200:	ffffe097          	auipc	ra,0xffffe
    80005204:	8f6080e7          	jalr	-1802(ra) # 80002af6 <argint>
    return -1;
    80005208:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000520a:	02054763          	bltz	a0,80005238 <sys_write+0x5c>
    8000520e:	fd840593          	addi	a1,s0,-40
    80005212:	4505                	li	a0,1
    80005214:	ffffe097          	auipc	ra,0xffffe
    80005218:	904080e7          	jalr	-1788(ra) # 80002b18 <argaddr>
    return -1;
    8000521c:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000521e:	00054d63          	bltz	a0,80005238 <sys_write+0x5c>
  return filewrite(f, p, n);
    80005222:	fe442603          	lw	a2,-28(s0)
    80005226:	fd843583          	ld	a1,-40(s0)
    8000522a:	fe843503          	ld	a0,-24(s0)
    8000522e:	fffff097          	auipc	ra,0xfffff
    80005232:	4fa080e7          	jalr	1274(ra) # 80004728 <filewrite>
    80005236:	87aa                	mv	a5,a0
}
    80005238:	853e                	mv	a0,a5
    8000523a:	70a2                	ld	ra,40(sp)
    8000523c:	7402                	ld	s0,32(sp)
    8000523e:	6145                	addi	sp,sp,48
    80005240:	8082                	ret

0000000080005242 <sys_close>:
{
    80005242:	1101                	addi	sp,sp,-32
    80005244:	ec06                	sd	ra,24(sp)
    80005246:	e822                	sd	s0,16(sp)
    80005248:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    8000524a:	fe040613          	addi	a2,s0,-32
    8000524e:	fec40593          	addi	a1,s0,-20
    80005252:	4501                	li	a0,0
    80005254:	00000097          	auipc	ra,0x0
    80005258:	cc2080e7          	jalr	-830(ra) # 80004f16 <argfd>
    return -1;
    8000525c:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    8000525e:	02054463          	bltz	a0,80005286 <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    80005262:	ffffc097          	auipc	ra,0xffffc
    80005266:	7e8080e7          	jalr	2024(ra) # 80001a4a <myproc>
    8000526a:	fec42783          	lw	a5,-20(s0)
    8000526e:	07e9                	addi	a5,a5,26
    80005270:	078e                	slli	a5,a5,0x3
    80005272:	97aa                	add	a5,a5,a0
    80005274:	0007b023          	sd	zero,0(a5)
  fileclose(f);
    80005278:	fe043503          	ld	a0,-32(s0)
    8000527c:	fffff097          	auipc	ra,0xfffff
    80005280:	2b0080e7          	jalr	688(ra) # 8000452c <fileclose>
  return 0;
    80005284:	4781                	li	a5,0
}
    80005286:	853e                	mv	a0,a5
    80005288:	60e2                	ld	ra,24(sp)
    8000528a:	6442                	ld	s0,16(sp)
    8000528c:	6105                	addi	sp,sp,32
    8000528e:	8082                	ret

0000000080005290 <sys_fstat>:
{
    80005290:	1101                	addi	sp,sp,-32
    80005292:	ec06                	sd	ra,24(sp)
    80005294:	e822                	sd	s0,16(sp)
    80005296:	1000                	addi	s0,sp,32
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    80005298:	fe840613          	addi	a2,s0,-24
    8000529c:	4581                	li	a1,0
    8000529e:	4501                	li	a0,0
    800052a0:	00000097          	auipc	ra,0x0
    800052a4:	c76080e7          	jalr	-906(ra) # 80004f16 <argfd>
    return -1;
    800052a8:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    800052aa:	02054563          	bltz	a0,800052d4 <sys_fstat+0x44>
    800052ae:	fe040593          	addi	a1,s0,-32
    800052b2:	4505                	li	a0,1
    800052b4:	ffffe097          	auipc	ra,0xffffe
    800052b8:	864080e7          	jalr	-1948(ra) # 80002b18 <argaddr>
    return -1;
    800052bc:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    800052be:	00054b63          	bltz	a0,800052d4 <sys_fstat+0x44>
  return filestat(f, st);
    800052c2:	fe043583          	ld	a1,-32(s0)
    800052c6:	fe843503          	ld	a0,-24(s0)
    800052ca:	fffff097          	auipc	ra,0xfffff
    800052ce:	32a080e7          	jalr	810(ra) # 800045f4 <filestat>
    800052d2:	87aa                	mv	a5,a0
}
    800052d4:	853e                	mv	a0,a5
    800052d6:	60e2                	ld	ra,24(sp)
    800052d8:	6442                	ld	s0,16(sp)
    800052da:	6105                	addi	sp,sp,32
    800052dc:	8082                	ret

00000000800052de <sys_link>:
{
    800052de:	7169                	addi	sp,sp,-304
    800052e0:	f606                	sd	ra,296(sp)
    800052e2:	f222                	sd	s0,288(sp)
    800052e4:	ee26                	sd	s1,280(sp)
    800052e6:	ea4a                	sd	s2,272(sp)
    800052e8:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800052ea:	08000613          	li	a2,128
    800052ee:	ed040593          	addi	a1,s0,-304
    800052f2:	4501                	li	a0,0
    800052f4:	ffffe097          	auipc	ra,0xffffe
    800052f8:	846080e7          	jalr	-1978(ra) # 80002b3a <argstr>
    return -1;
    800052fc:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800052fe:	10054e63          	bltz	a0,8000541a <sys_link+0x13c>
    80005302:	08000613          	li	a2,128
    80005306:	f5040593          	addi	a1,s0,-176
    8000530a:	4505                	li	a0,1
    8000530c:	ffffe097          	auipc	ra,0xffffe
    80005310:	82e080e7          	jalr	-2002(ra) # 80002b3a <argstr>
    return -1;
    80005314:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005316:	10054263          	bltz	a0,8000541a <sys_link+0x13c>
  begin_op();
    8000531a:	fffff097          	auipc	ra,0xfffff
    8000531e:	d46080e7          	jalr	-698(ra) # 80004060 <begin_op>
  if((ip = namei(old)) == 0){
    80005322:	ed040513          	addi	a0,s0,-304
    80005326:	fffff097          	auipc	ra,0xfffff
    8000532a:	b1e080e7          	jalr	-1250(ra) # 80003e44 <namei>
    8000532e:	84aa                	mv	s1,a0
    80005330:	c551                	beqz	a0,800053bc <sys_link+0xde>
  ilock(ip);
    80005332:	ffffe097          	auipc	ra,0xffffe
    80005336:	35c080e7          	jalr	860(ra) # 8000368e <ilock>
  if(ip->type == T_DIR){
    8000533a:	04449703          	lh	a4,68(s1)
    8000533e:	4785                	li	a5,1
    80005340:	08f70463          	beq	a4,a5,800053c8 <sys_link+0xea>
  ip->nlink++;
    80005344:	04a4d783          	lhu	a5,74(s1)
    80005348:	2785                	addiw	a5,a5,1
    8000534a:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    8000534e:	8526                	mv	a0,s1
    80005350:	ffffe097          	auipc	ra,0xffffe
    80005354:	274080e7          	jalr	628(ra) # 800035c4 <iupdate>
  iunlock(ip);
    80005358:	8526                	mv	a0,s1
    8000535a:	ffffe097          	auipc	ra,0xffffe
    8000535e:	3f6080e7          	jalr	1014(ra) # 80003750 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80005362:	fd040593          	addi	a1,s0,-48
    80005366:	f5040513          	addi	a0,s0,-176
    8000536a:	fffff097          	auipc	ra,0xfffff
    8000536e:	af8080e7          	jalr	-1288(ra) # 80003e62 <nameiparent>
    80005372:	892a                	mv	s2,a0
    80005374:	c935                	beqz	a0,800053e8 <sys_link+0x10a>
  ilock(dp);
    80005376:	ffffe097          	auipc	ra,0xffffe
    8000537a:	318080e7          	jalr	792(ra) # 8000368e <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    8000537e:	00092703          	lw	a4,0(s2)
    80005382:	409c                	lw	a5,0(s1)
    80005384:	04f71d63          	bne	a4,a5,800053de <sys_link+0x100>
    80005388:	40d0                	lw	a2,4(s1)
    8000538a:	fd040593          	addi	a1,s0,-48
    8000538e:	854a                	mv	a0,s2
    80005390:	fffff097          	auipc	ra,0xfffff
    80005394:	9f2080e7          	jalr	-1550(ra) # 80003d82 <dirlink>
    80005398:	04054363          	bltz	a0,800053de <sys_link+0x100>
  iunlockput(dp);
    8000539c:	854a                	mv	a0,s2
    8000539e:	ffffe097          	auipc	ra,0xffffe
    800053a2:	552080e7          	jalr	1362(ra) # 800038f0 <iunlockput>
  iput(ip);
    800053a6:	8526                	mv	a0,s1
    800053a8:	ffffe097          	auipc	ra,0xffffe
    800053ac:	4a0080e7          	jalr	1184(ra) # 80003848 <iput>
  end_op();
    800053b0:	fffff097          	auipc	ra,0xfffff
    800053b4:	d30080e7          	jalr	-720(ra) # 800040e0 <end_op>
  return 0;
    800053b8:	4781                	li	a5,0
    800053ba:	a085                	j	8000541a <sys_link+0x13c>
    end_op();
    800053bc:	fffff097          	auipc	ra,0xfffff
    800053c0:	d24080e7          	jalr	-732(ra) # 800040e0 <end_op>
    return -1;
    800053c4:	57fd                	li	a5,-1
    800053c6:	a891                	j	8000541a <sys_link+0x13c>
    iunlockput(ip);
    800053c8:	8526                	mv	a0,s1
    800053ca:	ffffe097          	auipc	ra,0xffffe
    800053ce:	526080e7          	jalr	1318(ra) # 800038f0 <iunlockput>
    end_op();
    800053d2:	fffff097          	auipc	ra,0xfffff
    800053d6:	d0e080e7          	jalr	-754(ra) # 800040e0 <end_op>
    return -1;
    800053da:	57fd                	li	a5,-1
    800053dc:	a83d                	j	8000541a <sys_link+0x13c>
    iunlockput(dp);
    800053de:	854a                	mv	a0,s2
    800053e0:	ffffe097          	auipc	ra,0xffffe
    800053e4:	510080e7          	jalr	1296(ra) # 800038f0 <iunlockput>
  ilock(ip);
    800053e8:	8526                	mv	a0,s1
    800053ea:	ffffe097          	auipc	ra,0xffffe
    800053ee:	2a4080e7          	jalr	676(ra) # 8000368e <ilock>
  ip->nlink--;
    800053f2:	04a4d783          	lhu	a5,74(s1)
    800053f6:	37fd                	addiw	a5,a5,-1
    800053f8:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800053fc:	8526                	mv	a0,s1
    800053fe:	ffffe097          	auipc	ra,0xffffe
    80005402:	1c6080e7          	jalr	454(ra) # 800035c4 <iupdate>
  iunlockput(ip);
    80005406:	8526                	mv	a0,s1
    80005408:	ffffe097          	auipc	ra,0xffffe
    8000540c:	4e8080e7          	jalr	1256(ra) # 800038f0 <iunlockput>
  end_op();
    80005410:	fffff097          	auipc	ra,0xfffff
    80005414:	cd0080e7          	jalr	-816(ra) # 800040e0 <end_op>
  return -1;
    80005418:	57fd                	li	a5,-1
}
    8000541a:	853e                	mv	a0,a5
    8000541c:	70b2                	ld	ra,296(sp)
    8000541e:	7412                	ld	s0,288(sp)
    80005420:	64f2                	ld	s1,280(sp)
    80005422:	6952                	ld	s2,272(sp)
    80005424:	6155                	addi	sp,sp,304
    80005426:	8082                	ret

0000000080005428 <sys_unlink>:
{
    80005428:	7151                	addi	sp,sp,-240
    8000542a:	f586                	sd	ra,232(sp)
    8000542c:	f1a2                	sd	s0,224(sp)
    8000542e:	eda6                	sd	s1,216(sp)
    80005430:	e9ca                	sd	s2,208(sp)
    80005432:	e5ce                	sd	s3,200(sp)
    80005434:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80005436:	08000613          	li	a2,128
    8000543a:	f3040593          	addi	a1,s0,-208
    8000543e:	4501                	li	a0,0
    80005440:	ffffd097          	auipc	ra,0xffffd
    80005444:	6fa080e7          	jalr	1786(ra) # 80002b3a <argstr>
    80005448:	18054163          	bltz	a0,800055ca <sys_unlink+0x1a2>
  begin_op();
    8000544c:	fffff097          	auipc	ra,0xfffff
    80005450:	c14080e7          	jalr	-1004(ra) # 80004060 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80005454:	fb040593          	addi	a1,s0,-80
    80005458:	f3040513          	addi	a0,s0,-208
    8000545c:	fffff097          	auipc	ra,0xfffff
    80005460:	a06080e7          	jalr	-1530(ra) # 80003e62 <nameiparent>
    80005464:	84aa                	mv	s1,a0
    80005466:	c979                	beqz	a0,8000553c <sys_unlink+0x114>
  ilock(dp);
    80005468:	ffffe097          	auipc	ra,0xffffe
    8000546c:	226080e7          	jalr	550(ra) # 8000368e <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80005470:	00003597          	auipc	a1,0x3
    80005474:	29858593          	addi	a1,a1,664 # 80008708 <syscalls+0x2b8>
    80005478:	fb040513          	addi	a0,s0,-80
    8000547c:	ffffe097          	auipc	ra,0xffffe
    80005480:	6dc080e7          	jalr	1756(ra) # 80003b58 <namecmp>
    80005484:	14050a63          	beqz	a0,800055d8 <sys_unlink+0x1b0>
    80005488:	00003597          	auipc	a1,0x3
    8000548c:	28858593          	addi	a1,a1,648 # 80008710 <syscalls+0x2c0>
    80005490:	fb040513          	addi	a0,s0,-80
    80005494:	ffffe097          	auipc	ra,0xffffe
    80005498:	6c4080e7          	jalr	1732(ra) # 80003b58 <namecmp>
    8000549c:	12050e63          	beqz	a0,800055d8 <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    800054a0:	f2c40613          	addi	a2,s0,-212
    800054a4:	fb040593          	addi	a1,s0,-80
    800054a8:	8526                	mv	a0,s1
    800054aa:	ffffe097          	auipc	ra,0xffffe
    800054ae:	6c8080e7          	jalr	1736(ra) # 80003b72 <dirlookup>
    800054b2:	892a                	mv	s2,a0
    800054b4:	12050263          	beqz	a0,800055d8 <sys_unlink+0x1b0>
  ilock(ip);
    800054b8:	ffffe097          	auipc	ra,0xffffe
    800054bc:	1d6080e7          	jalr	470(ra) # 8000368e <ilock>
  if(ip->nlink < 1)
    800054c0:	04a91783          	lh	a5,74(s2)
    800054c4:	08f05263          	blez	a5,80005548 <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    800054c8:	04491703          	lh	a4,68(s2)
    800054cc:	4785                	li	a5,1
    800054ce:	08f70563          	beq	a4,a5,80005558 <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    800054d2:	4641                	li	a2,16
    800054d4:	4581                	li	a1,0
    800054d6:	fc040513          	addi	a0,s0,-64
    800054da:	ffffb097          	auipc	ra,0xffffb
    800054de:	7f8080e7          	jalr	2040(ra) # 80000cd2 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800054e2:	4741                	li	a4,16
    800054e4:	f2c42683          	lw	a3,-212(s0)
    800054e8:	fc040613          	addi	a2,s0,-64
    800054ec:	4581                	li	a1,0
    800054ee:	8526                	mv	a0,s1
    800054f0:	ffffe097          	auipc	ra,0xffffe
    800054f4:	54a080e7          	jalr	1354(ra) # 80003a3a <writei>
    800054f8:	47c1                	li	a5,16
    800054fa:	0af51563          	bne	a0,a5,800055a4 <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    800054fe:	04491703          	lh	a4,68(s2)
    80005502:	4785                	li	a5,1
    80005504:	0af70863          	beq	a4,a5,800055b4 <sys_unlink+0x18c>
  iunlockput(dp);
    80005508:	8526                	mv	a0,s1
    8000550a:	ffffe097          	auipc	ra,0xffffe
    8000550e:	3e6080e7          	jalr	998(ra) # 800038f0 <iunlockput>
  ip->nlink--;
    80005512:	04a95783          	lhu	a5,74(s2)
    80005516:	37fd                	addiw	a5,a5,-1
    80005518:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    8000551c:	854a                	mv	a0,s2
    8000551e:	ffffe097          	auipc	ra,0xffffe
    80005522:	0a6080e7          	jalr	166(ra) # 800035c4 <iupdate>
  iunlockput(ip);
    80005526:	854a                	mv	a0,s2
    80005528:	ffffe097          	auipc	ra,0xffffe
    8000552c:	3c8080e7          	jalr	968(ra) # 800038f0 <iunlockput>
  end_op();
    80005530:	fffff097          	auipc	ra,0xfffff
    80005534:	bb0080e7          	jalr	-1104(ra) # 800040e0 <end_op>
  return 0;
    80005538:	4501                	li	a0,0
    8000553a:	a84d                	j	800055ec <sys_unlink+0x1c4>
    end_op();
    8000553c:	fffff097          	auipc	ra,0xfffff
    80005540:	ba4080e7          	jalr	-1116(ra) # 800040e0 <end_op>
    return -1;
    80005544:	557d                	li	a0,-1
    80005546:	a05d                	j	800055ec <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    80005548:	00003517          	auipc	a0,0x3
    8000554c:	1f050513          	addi	a0,a0,496 # 80008738 <syscalls+0x2e8>
    80005550:	ffffb097          	auipc	ra,0xffffb
    80005554:	fe0080e7          	jalr	-32(ra) # 80000530 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005558:	04c92703          	lw	a4,76(s2)
    8000555c:	02000793          	li	a5,32
    80005560:	f6e7f9e3          	bgeu	a5,a4,800054d2 <sys_unlink+0xaa>
    80005564:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005568:	4741                	li	a4,16
    8000556a:	86ce                	mv	a3,s3
    8000556c:	f1840613          	addi	a2,s0,-232
    80005570:	4581                	li	a1,0
    80005572:	854a                	mv	a0,s2
    80005574:	ffffe097          	auipc	ra,0xffffe
    80005578:	3ce080e7          	jalr	974(ra) # 80003942 <readi>
    8000557c:	47c1                	li	a5,16
    8000557e:	00f51b63          	bne	a0,a5,80005594 <sys_unlink+0x16c>
    if(de.inum != 0)
    80005582:	f1845783          	lhu	a5,-232(s0)
    80005586:	e7a1                	bnez	a5,800055ce <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005588:	29c1                	addiw	s3,s3,16
    8000558a:	04c92783          	lw	a5,76(s2)
    8000558e:	fcf9ede3          	bltu	s3,a5,80005568 <sys_unlink+0x140>
    80005592:	b781                	j	800054d2 <sys_unlink+0xaa>
      panic("isdirempty: readi");
    80005594:	00003517          	auipc	a0,0x3
    80005598:	1bc50513          	addi	a0,a0,444 # 80008750 <syscalls+0x300>
    8000559c:	ffffb097          	auipc	ra,0xffffb
    800055a0:	f94080e7          	jalr	-108(ra) # 80000530 <panic>
    panic("unlink: writei");
    800055a4:	00003517          	auipc	a0,0x3
    800055a8:	1c450513          	addi	a0,a0,452 # 80008768 <syscalls+0x318>
    800055ac:	ffffb097          	auipc	ra,0xffffb
    800055b0:	f84080e7          	jalr	-124(ra) # 80000530 <panic>
    dp->nlink--;
    800055b4:	04a4d783          	lhu	a5,74(s1)
    800055b8:	37fd                	addiw	a5,a5,-1
    800055ba:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    800055be:	8526                	mv	a0,s1
    800055c0:	ffffe097          	auipc	ra,0xffffe
    800055c4:	004080e7          	jalr	4(ra) # 800035c4 <iupdate>
    800055c8:	b781                	j	80005508 <sys_unlink+0xe0>
    return -1;
    800055ca:	557d                	li	a0,-1
    800055cc:	a005                	j	800055ec <sys_unlink+0x1c4>
    iunlockput(ip);
    800055ce:	854a                	mv	a0,s2
    800055d0:	ffffe097          	auipc	ra,0xffffe
    800055d4:	320080e7          	jalr	800(ra) # 800038f0 <iunlockput>
  iunlockput(dp);
    800055d8:	8526                	mv	a0,s1
    800055da:	ffffe097          	auipc	ra,0xffffe
    800055de:	316080e7          	jalr	790(ra) # 800038f0 <iunlockput>
  end_op();
    800055e2:	fffff097          	auipc	ra,0xfffff
    800055e6:	afe080e7          	jalr	-1282(ra) # 800040e0 <end_op>
  return -1;
    800055ea:	557d                	li	a0,-1
}
    800055ec:	70ae                	ld	ra,232(sp)
    800055ee:	740e                	ld	s0,224(sp)
    800055f0:	64ee                	ld	s1,216(sp)
    800055f2:	694e                	ld	s2,208(sp)
    800055f4:	69ae                	ld	s3,200(sp)
    800055f6:	616d                	addi	sp,sp,240
    800055f8:	8082                	ret

00000000800055fa <sys_open>:

uint64
sys_open(void)
{
    800055fa:	7131                	addi	sp,sp,-192
    800055fc:	fd06                	sd	ra,184(sp)
    800055fe:	f922                	sd	s0,176(sp)
    80005600:	f526                	sd	s1,168(sp)
    80005602:	f14a                	sd	s2,160(sp)
    80005604:	ed4e                	sd	s3,152(sp)
    80005606:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    80005608:	08000613          	li	a2,128
    8000560c:	f5040593          	addi	a1,s0,-176
    80005610:	4501                	li	a0,0
    80005612:	ffffd097          	auipc	ra,0xffffd
    80005616:	528080e7          	jalr	1320(ra) # 80002b3a <argstr>
    return -1;
    8000561a:	54fd                	li	s1,-1
  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    8000561c:	0c054163          	bltz	a0,800056de <sys_open+0xe4>
    80005620:	f4c40593          	addi	a1,s0,-180
    80005624:	4505                	li	a0,1
    80005626:	ffffd097          	auipc	ra,0xffffd
    8000562a:	4d0080e7          	jalr	1232(ra) # 80002af6 <argint>
    8000562e:	0a054863          	bltz	a0,800056de <sys_open+0xe4>

  begin_op();
    80005632:	fffff097          	auipc	ra,0xfffff
    80005636:	a2e080e7          	jalr	-1490(ra) # 80004060 <begin_op>

  if(omode & O_CREATE){
    8000563a:	f4c42783          	lw	a5,-180(s0)
    8000563e:	2007f793          	andi	a5,a5,512
    80005642:	cbdd                	beqz	a5,800056f8 <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    80005644:	4681                	li	a3,0
    80005646:	4601                	li	a2,0
    80005648:	4589                	li	a1,2
    8000564a:	f5040513          	addi	a0,s0,-176
    8000564e:	00000097          	auipc	ra,0x0
    80005652:	972080e7          	jalr	-1678(ra) # 80004fc0 <create>
    80005656:	892a                	mv	s2,a0
    if(ip == 0){
    80005658:	c959                	beqz	a0,800056ee <sys_open+0xf4>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    8000565a:	04491703          	lh	a4,68(s2)
    8000565e:	478d                	li	a5,3
    80005660:	00f71763          	bne	a4,a5,8000566e <sys_open+0x74>
    80005664:	04695703          	lhu	a4,70(s2)
    80005668:	47a5                	li	a5,9
    8000566a:	0ce7ec63          	bltu	a5,a4,80005742 <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    8000566e:	fffff097          	auipc	ra,0xfffff
    80005672:	e02080e7          	jalr	-510(ra) # 80004470 <filealloc>
    80005676:	89aa                	mv	s3,a0
    80005678:	10050263          	beqz	a0,8000577c <sys_open+0x182>
    8000567c:	00000097          	auipc	ra,0x0
    80005680:	902080e7          	jalr	-1790(ra) # 80004f7e <fdalloc>
    80005684:	84aa                	mv	s1,a0
    80005686:	0e054663          	bltz	a0,80005772 <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    8000568a:	04491703          	lh	a4,68(s2)
    8000568e:	478d                	li	a5,3
    80005690:	0cf70463          	beq	a4,a5,80005758 <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80005694:	4789                	li	a5,2
    80005696:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    8000569a:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    8000569e:	0129bc23          	sd	s2,24(s3)
  f->readable = !(omode & O_WRONLY);
    800056a2:	f4c42783          	lw	a5,-180(s0)
    800056a6:	0017c713          	xori	a4,a5,1
    800056aa:	8b05                	andi	a4,a4,1
    800056ac:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    800056b0:	0037f713          	andi	a4,a5,3
    800056b4:	00e03733          	snez	a4,a4
    800056b8:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    800056bc:	4007f793          	andi	a5,a5,1024
    800056c0:	c791                	beqz	a5,800056cc <sys_open+0xd2>
    800056c2:	04491703          	lh	a4,68(s2)
    800056c6:	4789                	li	a5,2
    800056c8:	08f70f63          	beq	a4,a5,80005766 <sys_open+0x16c>
    itrunc(ip);
  }

  iunlock(ip);
    800056cc:	854a                	mv	a0,s2
    800056ce:	ffffe097          	auipc	ra,0xffffe
    800056d2:	082080e7          	jalr	130(ra) # 80003750 <iunlock>
  end_op();
    800056d6:	fffff097          	auipc	ra,0xfffff
    800056da:	a0a080e7          	jalr	-1526(ra) # 800040e0 <end_op>

  return fd;
}
    800056de:	8526                	mv	a0,s1
    800056e0:	70ea                	ld	ra,184(sp)
    800056e2:	744a                	ld	s0,176(sp)
    800056e4:	74aa                	ld	s1,168(sp)
    800056e6:	790a                	ld	s2,160(sp)
    800056e8:	69ea                	ld	s3,152(sp)
    800056ea:	6129                	addi	sp,sp,192
    800056ec:	8082                	ret
      end_op();
    800056ee:	fffff097          	auipc	ra,0xfffff
    800056f2:	9f2080e7          	jalr	-1550(ra) # 800040e0 <end_op>
      return -1;
    800056f6:	b7e5                	j	800056de <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    800056f8:	f5040513          	addi	a0,s0,-176
    800056fc:	ffffe097          	auipc	ra,0xffffe
    80005700:	748080e7          	jalr	1864(ra) # 80003e44 <namei>
    80005704:	892a                	mv	s2,a0
    80005706:	c905                	beqz	a0,80005736 <sys_open+0x13c>
    ilock(ip);
    80005708:	ffffe097          	auipc	ra,0xffffe
    8000570c:	f86080e7          	jalr	-122(ra) # 8000368e <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005710:	04491703          	lh	a4,68(s2)
    80005714:	4785                	li	a5,1
    80005716:	f4f712e3          	bne	a4,a5,8000565a <sys_open+0x60>
    8000571a:	f4c42783          	lw	a5,-180(s0)
    8000571e:	dba1                	beqz	a5,8000566e <sys_open+0x74>
      iunlockput(ip);
    80005720:	854a                	mv	a0,s2
    80005722:	ffffe097          	auipc	ra,0xffffe
    80005726:	1ce080e7          	jalr	462(ra) # 800038f0 <iunlockput>
      end_op();
    8000572a:	fffff097          	auipc	ra,0xfffff
    8000572e:	9b6080e7          	jalr	-1610(ra) # 800040e0 <end_op>
      return -1;
    80005732:	54fd                	li	s1,-1
    80005734:	b76d                	j	800056de <sys_open+0xe4>
      end_op();
    80005736:	fffff097          	auipc	ra,0xfffff
    8000573a:	9aa080e7          	jalr	-1622(ra) # 800040e0 <end_op>
      return -1;
    8000573e:	54fd                	li	s1,-1
    80005740:	bf79                	j	800056de <sys_open+0xe4>
    iunlockput(ip);
    80005742:	854a                	mv	a0,s2
    80005744:	ffffe097          	auipc	ra,0xffffe
    80005748:	1ac080e7          	jalr	428(ra) # 800038f0 <iunlockput>
    end_op();
    8000574c:	fffff097          	auipc	ra,0xfffff
    80005750:	994080e7          	jalr	-1644(ra) # 800040e0 <end_op>
    return -1;
    80005754:	54fd                	li	s1,-1
    80005756:	b761                	j	800056de <sys_open+0xe4>
    f->type = FD_DEVICE;
    80005758:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    8000575c:	04691783          	lh	a5,70(s2)
    80005760:	02f99223          	sh	a5,36(s3)
    80005764:	bf2d                	j	8000569e <sys_open+0xa4>
    itrunc(ip);
    80005766:	854a                	mv	a0,s2
    80005768:	ffffe097          	auipc	ra,0xffffe
    8000576c:	034080e7          	jalr	52(ra) # 8000379c <itrunc>
    80005770:	bfb1                	j	800056cc <sys_open+0xd2>
      fileclose(f);
    80005772:	854e                	mv	a0,s3
    80005774:	fffff097          	auipc	ra,0xfffff
    80005778:	db8080e7          	jalr	-584(ra) # 8000452c <fileclose>
    iunlockput(ip);
    8000577c:	854a                	mv	a0,s2
    8000577e:	ffffe097          	auipc	ra,0xffffe
    80005782:	172080e7          	jalr	370(ra) # 800038f0 <iunlockput>
    end_op();
    80005786:	fffff097          	auipc	ra,0xfffff
    8000578a:	95a080e7          	jalr	-1702(ra) # 800040e0 <end_op>
    return -1;
    8000578e:	54fd                	li	s1,-1
    80005790:	b7b9                	j	800056de <sys_open+0xe4>

0000000080005792 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005792:	7175                	addi	sp,sp,-144
    80005794:	e506                	sd	ra,136(sp)
    80005796:	e122                	sd	s0,128(sp)
    80005798:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    8000579a:	fffff097          	auipc	ra,0xfffff
    8000579e:	8c6080e7          	jalr	-1850(ra) # 80004060 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    800057a2:	08000613          	li	a2,128
    800057a6:	f7040593          	addi	a1,s0,-144
    800057aa:	4501                	li	a0,0
    800057ac:	ffffd097          	auipc	ra,0xffffd
    800057b0:	38e080e7          	jalr	910(ra) # 80002b3a <argstr>
    800057b4:	02054963          	bltz	a0,800057e6 <sys_mkdir+0x54>
    800057b8:	4681                	li	a3,0
    800057ba:	4601                	li	a2,0
    800057bc:	4585                	li	a1,1
    800057be:	f7040513          	addi	a0,s0,-144
    800057c2:	fffff097          	auipc	ra,0xfffff
    800057c6:	7fe080e7          	jalr	2046(ra) # 80004fc0 <create>
    800057ca:	cd11                	beqz	a0,800057e6 <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    800057cc:	ffffe097          	auipc	ra,0xffffe
    800057d0:	124080e7          	jalr	292(ra) # 800038f0 <iunlockput>
  end_op();
    800057d4:	fffff097          	auipc	ra,0xfffff
    800057d8:	90c080e7          	jalr	-1780(ra) # 800040e0 <end_op>
  return 0;
    800057dc:	4501                	li	a0,0
}
    800057de:	60aa                	ld	ra,136(sp)
    800057e0:	640a                	ld	s0,128(sp)
    800057e2:	6149                	addi	sp,sp,144
    800057e4:	8082                	ret
    end_op();
    800057e6:	fffff097          	auipc	ra,0xfffff
    800057ea:	8fa080e7          	jalr	-1798(ra) # 800040e0 <end_op>
    return -1;
    800057ee:	557d                	li	a0,-1
    800057f0:	b7fd                	j	800057de <sys_mkdir+0x4c>

00000000800057f2 <sys_mknod>:

uint64
sys_mknod(void)
{
    800057f2:	7135                	addi	sp,sp,-160
    800057f4:	ed06                	sd	ra,152(sp)
    800057f6:	e922                	sd	s0,144(sp)
    800057f8:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    800057fa:	fffff097          	auipc	ra,0xfffff
    800057fe:	866080e7          	jalr	-1946(ra) # 80004060 <begin_op>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005802:	08000613          	li	a2,128
    80005806:	f7040593          	addi	a1,s0,-144
    8000580a:	4501                	li	a0,0
    8000580c:	ffffd097          	auipc	ra,0xffffd
    80005810:	32e080e7          	jalr	814(ra) # 80002b3a <argstr>
    80005814:	04054a63          	bltz	a0,80005868 <sys_mknod+0x76>
     argint(1, &major) < 0 ||
    80005818:	f6c40593          	addi	a1,s0,-148
    8000581c:	4505                	li	a0,1
    8000581e:	ffffd097          	auipc	ra,0xffffd
    80005822:	2d8080e7          	jalr	728(ra) # 80002af6 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005826:	04054163          	bltz	a0,80005868 <sys_mknod+0x76>
     argint(2, &minor) < 0 ||
    8000582a:	f6840593          	addi	a1,s0,-152
    8000582e:	4509                	li	a0,2
    80005830:	ffffd097          	auipc	ra,0xffffd
    80005834:	2c6080e7          	jalr	710(ra) # 80002af6 <argint>
     argint(1, &major) < 0 ||
    80005838:	02054863          	bltz	a0,80005868 <sys_mknod+0x76>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    8000583c:	f6841683          	lh	a3,-152(s0)
    80005840:	f6c41603          	lh	a2,-148(s0)
    80005844:	458d                	li	a1,3
    80005846:	f7040513          	addi	a0,s0,-144
    8000584a:	fffff097          	auipc	ra,0xfffff
    8000584e:	776080e7          	jalr	1910(ra) # 80004fc0 <create>
     argint(2, &minor) < 0 ||
    80005852:	c919                	beqz	a0,80005868 <sys_mknod+0x76>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005854:	ffffe097          	auipc	ra,0xffffe
    80005858:	09c080e7          	jalr	156(ra) # 800038f0 <iunlockput>
  end_op();
    8000585c:	fffff097          	auipc	ra,0xfffff
    80005860:	884080e7          	jalr	-1916(ra) # 800040e0 <end_op>
  return 0;
    80005864:	4501                	li	a0,0
    80005866:	a031                	j	80005872 <sys_mknod+0x80>
    end_op();
    80005868:	fffff097          	auipc	ra,0xfffff
    8000586c:	878080e7          	jalr	-1928(ra) # 800040e0 <end_op>
    return -1;
    80005870:	557d                	li	a0,-1
}
    80005872:	60ea                	ld	ra,152(sp)
    80005874:	644a                	ld	s0,144(sp)
    80005876:	610d                	addi	sp,sp,160
    80005878:	8082                	ret

000000008000587a <sys_chdir>:

uint64
sys_chdir(void)
{
    8000587a:	7135                	addi	sp,sp,-160
    8000587c:	ed06                	sd	ra,152(sp)
    8000587e:	e922                	sd	s0,144(sp)
    80005880:	e526                	sd	s1,136(sp)
    80005882:	e14a                	sd	s2,128(sp)
    80005884:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005886:	ffffc097          	auipc	ra,0xffffc
    8000588a:	1c4080e7          	jalr	452(ra) # 80001a4a <myproc>
    8000588e:	892a                	mv	s2,a0
  
  begin_op();
    80005890:	ffffe097          	auipc	ra,0xffffe
    80005894:	7d0080e7          	jalr	2000(ra) # 80004060 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005898:	08000613          	li	a2,128
    8000589c:	f6040593          	addi	a1,s0,-160
    800058a0:	4501                	li	a0,0
    800058a2:	ffffd097          	auipc	ra,0xffffd
    800058a6:	298080e7          	jalr	664(ra) # 80002b3a <argstr>
    800058aa:	04054b63          	bltz	a0,80005900 <sys_chdir+0x86>
    800058ae:	f6040513          	addi	a0,s0,-160
    800058b2:	ffffe097          	auipc	ra,0xffffe
    800058b6:	592080e7          	jalr	1426(ra) # 80003e44 <namei>
    800058ba:	84aa                	mv	s1,a0
    800058bc:	c131                	beqz	a0,80005900 <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    800058be:	ffffe097          	auipc	ra,0xffffe
    800058c2:	dd0080e7          	jalr	-560(ra) # 8000368e <ilock>
  if(ip->type != T_DIR){
    800058c6:	04449703          	lh	a4,68(s1)
    800058ca:	4785                	li	a5,1
    800058cc:	04f71063          	bne	a4,a5,8000590c <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    800058d0:	8526                	mv	a0,s1
    800058d2:	ffffe097          	auipc	ra,0xffffe
    800058d6:	e7e080e7          	jalr	-386(ra) # 80003750 <iunlock>
  iput(p->cwd);
    800058da:	15093503          	ld	a0,336(s2)
    800058de:	ffffe097          	auipc	ra,0xffffe
    800058e2:	f6a080e7          	jalr	-150(ra) # 80003848 <iput>
  end_op();
    800058e6:	ffffe097          	auipc	ra,0xffffe
    800058ea:	7fa080e7          	jalr	2042(ra) # 800040e0 <end_op>
  p->cwd = ip;
    800058ee:	14993823          	sd	s1,336(s2)
  return 0;
    800058f2:	4501                	li	a0,0
}
    800058f4:	60ea                	ld	ra,152(sp)
    800058f6:	644a                	ld	s0,144(sp)
    800058f8:	64aa                	ld	s1,136(sp)
    800058fa:	690a                	ld	s2,128(sp)
    800058fc:	610d                	addi	sp,sp,160
    800058fe:	8082                	ret
    end_op();
    80005900:	ffffe097          	auipc	ra,0xffffe
    80005904:	7e0080e7          	jalr	2016(ra) # 800040e0 <end_op>
    return -1;
    80005908:	557d                	li	a0,-1
    8000590a:	b7ed                	j	800058f4 <sys_chdir+0x7a>
    iunlockput(ip);
    8000590c:	8526                	mv	a0,s1
    8000590e:	ffffe097          	auipc	ra,0xffffe
    80005912:	fe2080e7          	jalr	-30(ra) # 800038f0 <iunlockput>
    end_op();
    80005916:	ffffe097          	auipc	ra,0xffffe
    8000591a:	7ca080e7          	jalr	1994(ra) # 800040e0 <end_op>
    return -1;
    8000591e:	557d                	li	a0,-1
    80005920:	bfd1                	j	800058f4 <sys_chdir+0x7a>

0000000080005922 <sys_exec>:

uint64
sys_exec(void)
{
    80005922:	7145                	addi	sp,sp,-464
    80005924:	e786                	sd	ra,456(sp)
    80005926:	e3a2                	sd	s0,448(sp)
    80005928:	ff26                	sd	s1,440(sp)
    8000592a:	fb4a                	sd	s2,432(sp)
    8000592c:	f74e                	sd	s3,424(sp)
    8000592e:	f352                	sd	s4,416(sp)
    80005930:	ef56                	sd	s5,408(sp)
    80005932:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80005934:	08000613          	li	a2,128
    80005938:	f4040593          	addi	a1,s0,-192
    8000593c:	4501                	li	a0,0
    8000593e:	ffffd097          	auipc	ra,0xffffd
    80005942:	1fc080e7          	jalr	508(ra) # 80002b3a <argstr>
    return -1;
    80005946:	597d                	li	s2,-1
  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80005948:	0c054a63          	bltz	a0,80005a1c <sys_exec+0xfa>
    8000594c:	e3840593          	addi	a1,s0,-456
    80005950:	4505                	li	a0,1
    80005952:	ffffd097          	auipc	ra,0xffffd
    80005956:	1c6080e7          	jalr	454(ra) # 80002b18 <argaddr>
    8000595a:	0c054163          	bltz	a0,80005a1c <sys_exec+0xfa>
  }
  memset(argv, 0, sizeof(argv));
    8000595e:	10000613          	li	a2,256
    80005962:	4581                	li	a1,0
    80005964:	e4040513          	addi	a0,s0,-448
    80005968:	ffffb097          	auipc	ra,0xffffb
    8000596c:	36a080e7          	jalr	874(ra) # 80000cd2 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005970:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    80005974:	89a6                	mv	s3,s1
    80005976:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80005978:	02000a13          	li	s4,32
    8000597c:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005980:	00391513          	slli	a0,s2,0x3
    80005984:	e3040593          	addi	a1,s0,-464
    80005988:	e3843783          	ld	a5,-456(s0)
    8000598c:	953e                	add	a0,a0,a5
    8000598e:	ffffd097          	auipc	ra,0xffffd
    80005992:	0ce080e7          	jalr	206(ra) # 80002a5c <fetchaddr>
    80005996:	02054a63          	bltz	a0,800059ca <sys_exec+0xa8>
      goto bad;
    }
    if(uarg == 0){
    8000599a:	e3043783          	ld	a5,-464(s0)
    8000599e:	c3b9                	beqz	a5,800059e4 <sys_exec+0xc2>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    800059a0:	ffffb097          	auipc	ra,0xffffb
    800059a4:	146080e7          	jalr	326(ra) # 80000ae6 <kalloc>
    800059a8:	85aa                	mv	a1,a0
    800059aa:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    800059ae:	cd11                	beqz	a0,800059ca <sys_exec+0xa8>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    800059b0:	6605                	lui	a2,0x1
    800059b2:	e3043503          	ld	a0,-464(s0)
    800059b6:	ffffd097          	auipc	ra,0xffffd
    800059ba:	0f8080e7          	jalr	248(ra) # 80002aae <fetchstr>
    800059be:	00054663          	bltz	a0,800059ca <sys_exec+0xa8>
    if(i >= NELEM(argv)){
    800059c2:	0905                	addi	s2,s2,1
    800059c4:	09a1                	addi	s3,s3,8
    800059c6:	fb491be3          	bne	s2,s4,8000597c <sys_exec+0x5a>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800059ca:	10048913          	addi	s2,s1,256
    800059ce:	6088                	ld	a0,0(s1)
    800059d0:	c529                	beqz	a0,80005a1a <sys_exec+0xf8>
    kfree(argv[i]);
    800059d2:	ffffb097          	auipc	ra,0xffffb
    800059d6:	018080e7          	jalr	24(ra) # 800009ea <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800059da:	04a1                	addi	s1,s1,8
    800059dc:	ff2499e3          	bne	s1,s2,800059ce <sys_exec+0xac>
  return -1;
    800059e0:	597d                	li	s2,-1
    800059e2:	a82d                	j	80005a1c <sys_exec+0xfa>
      argv[i] = 0;
    800059e4:	0a8e                	slli	s5,s5,0x3
    800059e6:	fc040793          	addi	a5,s0,-64
    800059ea:	9abe                	add	s5,s5,a5
    800059ec:	e80ab023          	sd	zero,-384(s5)
  int ret = exec(path, argv);
    800059f0:	e4040593          	addi	a1,s0,-448
    800059f4:	f4040513          	addi	a0,s0,-192
    800059f8:	fffff097          	auipc	ra,0xfffff
    800059fc:	194080e7          	jalr	404(ra) # 80004b8c <exec>
    80005a00:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005a02:	10048993          	addi	s3,s1,256
    80005a06:	6088                	ld	a0,0(s1)
    80005a08:	c911                	beqz	a0,80005a1c <sys_exec+0xfa>
    kfree(argv[i]);
    80005a0a:	ffffb097          	auipc	ra,0xffffb
    80005a0e:	fe0080e7          	jalr	-32(ra) # 800009ea <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005a12:	04a1                	addi	s1,s1,8
    80005a14:	ff3499e3          	bne	s1,s3,80005a06 <sys_exec+0xe4>
    80005a18:	a011                	j	80005a1c <sys_exec+0xfa>
  return -1;
    80005a1a:	597d                	li	s2,-1
}
    80005a1c:	854a                	mv	a0,s2
    80005a1e:	60be                	ld	ra,456(sp)
    80005a20:	641e                	ld	s0,448(sp)
    80005a22:	74fa                	ld	s1,440(sp)
    80005a24:	795a                	ld	s2,432(sp)
    80005a26:	79ba                	ld	s3,424(sp)
    80005a28:	7a1a                	ld	s4,416(sp)
    80005a2a:	6afa                	ld	s5,408(sp)
    80005a2c:	6179                	addi	sp,sp,464
    80005a2e:	8082                	ret

0000000080005a30 <sys_pipe>:

uint64
sys_pipe(void)
{
    80005a30:	7139                	addi	sp,sp,-64
    80005a32:	fc06                	sd	ra,56(sp)
    80005a34:	f822                	sd	s0,48(sp)
    80005a36:	f426                	sd	s1,40(sp)
    80005a38:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005a3a:	ffffc097          	auipc	ra,0xffffc
    80005a3e:	010080e7          	jalr	16(ra) # 80001a4a <myproc>
    80005a42:	84aa                	mv	s1,a0

  if(argaddr(0, &fdarray) < 0)
    80005a44:	fd840593          	addi	a1,s0,-40
    80005a48:	4501                	li	a0,0
    80005a4a:	ffffd097          	auipc	ra,0xffffd
    80005a4e:	0ce080e7          	jalr	206(ra) # 80002b18 <argaddr>
    return -1;
    80005a52:	57fd                	li	a5,-1
  if(argaddr(0, &fdarray) < 0)
    80005a54:	0e054063          	bltz	a0,80005b34 <sys_pipe+0x104>
  if(pipealloc(&rf, &wf) < 0)
    80005a58:	fc840593          	addi	a1,s0,-56
    80005a5c:	fd040513          	addi	a0,s0,-48
    80005a60:	fffff097          	auipc	ra,0xfffff
    80005a64:	dfc080e7          	jalr	-516(ra) # 8000485c <pipealloc>
    return -1;
    80005a68:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005a6a:	0c054563          	bltz	a0,80005b34 <sys_pipe+0x104>
  fd0 = -1;
    80005a6e:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005a72:	fd043503          	ld	a0,-48(s0)
    80005a76:	fffff097          	auipc	ra,0xfffff
    80005a7a:	508080e7          	jalr	1288(ra) # 80004f7e <fdalloc>
    80005a7e:	fca42223          	sw	a0,-60(s0)
    80005a82:	08054c63          	bltz	a0,80005b1a <sys_pipe+0xea>
    80005a86:	fc843503          	ld	a0,-56(s0)
    80005a8a:	fffff097          	auipc	ra,0xfffff
    80005a8e:	4f4080e7          	jalr	1268(ra) # 80004f7e <fdalloc>
    80005a92:	fca42023          	sw	a0,-64(s0)
    80005a96:	06054863          	bltz	a0,80005b06 <sys_pipe+0xd6>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005a9a:	4691                	li	a3,4
    80005a9c:	fc440613          	addi	a2,s0,-60
    80005aa0:	fd843583          	ld	a1,-40(s0)
    80005aa4:	68a8                	ld	a0,80(s1)
    80005aa6:	ffffc097          	auipc	ra,0xffffc
    80005aaa:	bb0080e7          	jalr	-1104(ra) # 80001656 <copyout>
    80005aae:	02054063          	bltz	a0,80005ace <sys_pipe+0x9e>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005ab2:	4691                	li	a3,4
    80005ab4:	fc040613          	addi	a2,s0,-64
    80005ab8:	fd843583          	ld	a1,-40(s0)
    80005abc:	0591                	addi	a1,a1,4
    80005abe:	68a8                	ld	a0,80(s1)
    80005ac0:	ffffc097          	auipc	ra,0xffffc
    80005ac4:	b96080e7          	jalr	-1130(ra) # 80001656 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005ac8:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005aca:	06055563          	bgez	a0,80005b34 <sys_pipe+0x104>
    p->ofile[fd0] = 0;
    80005ace:	fc442783          	lw	a5,-60(s0)
    80005ad2:	07e9                	addi	a5,a5,26
    80005ad4:	078e                	slli	a5,a5,0x3
    80005ad6:	97a6                	add	a5,a5,s1
    80005ad8:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80005adc:	fc042503          	lw	a0,-64(s0)
    80005ae0:	0569                	addi	a0,a0,26
    80005ae2:	050e                	slli	a0,a0,0x3
    80005ae4:	9526                	add	a0,a0,s1
    80005ae6:	00053023          	sd	zero,0(a0)
    fileclose(rf);
    80005aea:	fd043503          	ld	a0,-48(s0)
    80005aee:	fffff097          	auipc	ra,0xfffff
    80005af2:	a3e080e7          	jalr	-1474(ra) # 8000452c <fileclose>
    fileclose(wf);
    80005af6:	fc843503          	ld	a0,-56(s0)
    80005afa:	fffff097          	auipc	ra,0xfffff
    80005afe:	a32080e7          	jalr	-1486(ra) # 8000452c <fileclose>
    return -1;
    80005b02:	57fd                	li	a5,-1
    80005b04:	a805                	j	80005b34 <sys_pipe+0x104>
    if(fd0 >= 0)
    80005b06:	fc442783          	lw	a5,-60(s0)
    80005b0a:	0007c863          	bltz	a5,80005b1a <sys_pipe+0xea>
      p->ofile[fd0] = 0;
    80005b0e:	01a78513          	addi	a0,a5,26
    80005b12:	050e                	slli	a0,a0,0x3
    80005b14:	9526                	add	a0,a0,s1
    80005b16:	00053023          	sd	zero,0(a0)
    fileclose(rf);
    80005b1a:	fd043503          	ld	a0,-48(s0)
    80005b1e:	fffff097          	auipc	ra,0xfffff
    80005b22:	a0e080e7          	jalr	-1522(ra) # 8000452c <fileclose>
    fileclose(wf);
    80005b26:	fc843503          	ld	a0,-56(s0)
    80005b2a:	fffff097          	auipc	ra,0xfffff
    80005b2e:	a02080e7          	jalr	-1534(ra) # 8000452c <fileclose>
    return -1;
    80005b32:	57fd                	li	a5,-1
}
    80005b34:	853e                	mv	a0,a5
    80005b36:	70e2                	ld	ra,56(sp)
    80005b38:	7442                	ld	s0,48(sp)
    80005b3a:	74a2                	ld	s1,40(sp)
    80005b3c:	6121                	addi	sp,sp,64
    80005b3e:	8082                	ret

0000000080005b40 <kernelvec>:
    80005b40:	7111                	addi	sp,sp,-256
    80005b42:	e006                	sd	ra,0(sp)
    80005b44:	e40a                	sd	sp,8(sp)
    80005b46:	e80e                	sd	gp,16(sp)
    80005b48:	ec12                	sd	tp,24(sp)
    80005b4a:	f016                	sd	t0,32(sp)
    80005b4c:	f41a                	sd	t1,40(sp)
    80005b4e:	f81e                	sd	t2,48(sp)
    80005b50:	fc22                	sd	s0,56(sp)
    80005b52:	e0a6                	sd	s1,64(sp)
    80005b54:	e4aa                	sd	a0,72(sp)
    80005b56:	e8ae                	sd	a1,80(sp)
    80005b58:	ecb2                	sd	a2,88(sp)
    80005b5a:	f0b6                	sd	a3,96(sp)
    80005b5c:	f4ba                	sd	a4,104(sp)
    80005b5e:	f8be                	sd	a5,112(sp)
    80005b60:	fcc2                	sd	a6,120(sp)
    80005b62:	e146                	sd	a7,128(sp)
    80005b64:	e54a                	sd	s2,136(sp)
    80005b66:	e94e                	sd	s3,144(sp)
    80005b68:	ed52                	sd	s4,152(sp)
    80005b6a:	f156                	sd	s5,160(sp)
    80005b6c:	f55a                	sd	s6,168(sp)
    80005b6e:	f95e                	sd	s7,176(sp)
    80005b70:	fd62                	sd	s8,184(sp)
    80005b72:	e1e6                	sd	s9,192(sp)
    80005b74:	e5ea                	sd	s10,200(sp)
    80005b76:	e9ee                	sd	s11,208(sp)
    80005b78:	edf2                	sd	t3,216(sp)
    80005b7a:	f1f6                	sd	t4,224(sp)
    80005b7c:	f5fa                	sd	t5,232(sp)
    80005b7e:	f9fe                	sd	t6,240(sp)
    80005b80:	da9fc0ef          	jal	ra,80002928 <kerneltrap>
    80005b84:	6082                	ld	ra,0(sp)
    80005b86:	6122                	ld	sp,8(sp)
    80005b88:	61c2                	ld	gp,16(sp)
    80005b8a:	7282                	ld	t0,32(sp)
    80005b8c:	7322                	ld	t1,40(sp)
    80005b8e:	73c2                	ld	t2,48(sp)
    80005b90:	7462                	ld	s0,56(sp)
    80005b92:	6486                	ld	s1,64(sp)
    80005b94:	6526                	ld	a0,72(sp)
    80005b96:	65c6                	ld	a1,80(sp)
    80005b98:	6666                	ld	a2,88(sp)
    80005b9a:	7686                	ld	a3,96(sp)
    80005b9c:	7726                	ld	a4,104(sp)
    80005b9e:	77c6                	ld	a5,112(sp)
    80005ba0:	7866                	ld	a6,120(sp)
    80005ba2:	688a                	ld	a7,128(sp)
    80005ba4:	692a                	ld	s2,136(sp)
    80005ba6:	69ca                	ld	s3,144(sp)
    80005ba8:	6a6a                	ld	s4,152(sp)
    80005baa:	7a8a                	ld	s5,160(sp)
    80005bac:	7b2a                	ld	s6,168(sp)
    80005bae:	7bca                	ld	s7,176(sp)
    80005bb0:	7c6a                	ld	s8,184(sp)
    80005bb2:	6c8e                	ld	s9,192(sp)
    80005bb4:	6d2e                	ld	s10,200(sp)
    80005bb6:	6dce                	ld	s11,208(sp)
    80005bb8:	6e6e                	ld	t3,216(sp)
    80005bba:	7e8e                	ld	t4,224(sp)
    80005bbc:	7f2e                	ld	t5,232(sp)
    80005bbe:	7fce                	ld	t6,240(sp)
    80005bc0:	6111                	addi	sp,sp,256
    80005bc2:	10200073          	sret
    80005bc6:	00000013          	nop
    80005bca:	00000013          	nop
    80005bce:	0001                	nop

0000000080005bd0 <timervec>:
    80005bd0:	34051573          	csrrw	a0,mscratch,a0
    80005bd4:	e10c                	sd	a1,0(a0)
    80005bd6:	e510                	sd	a2,8(a0)
    80005bd8:	e914                	sd	a3,16(a0)
    80005bda:	6d0c                	ld	a1,24(a0)
    80005bdc:	7110                	ld	a2,32(a0)
    80005bde:	6194                	ld	a3,0(a1)
    80005be0:	96b2                	add	a3,a3,a2
    80005be2:	e194                	sd	a3,0(a1)
    80005be4:	4589                	li	a1,2
    80005be6:	14459073          	csrw	sip,a1
    80005bea:	6914                	ld	a3,16(a0)
    80005bec:	6510                	ld	a2,8(a0)
    80005bee:	610c                	ld	a1,0(a0)
    80005bf0:	34051573          	csrrw	a0,mscratch,a0
    80005bf4:	30200073          	mret
	...

0000000080005bfa <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    80005bfa:	1141                	addi	sp,sp,-16
    80005bfc:	e422                	sd	s0,8(sp)
    80005bfe:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80005c00:	0c0007b7          	lui	a5,0xc000
    80005c04:	4705                	li	a4,1
    80005c06:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80005c08:	c3d8                	sw	a4,4(a5)
}
    80005c0a:	6422                	ld	s0,8(sp)
    80005c0c:	0141                	addi	sp,sp,16
    80005c0e:	8082                	ret

0000000080005c10 <plicinithart>:

void
plicinithart(void)
{
    80005c10:	1141                	addi	sp,sp,-16
    80005c12:	e406                	sd	ra,8(sp)
    80005c14:	e022                	sd	s0,0(sp)
    80005c16:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005c18:	ffffc097          	auipc	ra,0xffffc
    80005c1c:	e06080e7          	jalr	-506(ra) # 80001a1e <cpuid>
  
  // set uart's enable bit for this hart's S-mode. 
  *(uint32*)PLIC_SENABLE(hart)= (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005c20:	0085171b          	slliw	a4,a0,0x8
    80005c24:	0c0027b7          	lui	a5,0xc002
    80005c28:	97ba                	add	a5,a5,a4
    80005c2a:	40200713          	li	a4,1026
    80005c2e:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005c32:	00d5151b          	slliw	a0,a0,0xd
    80005c36:	0c2017b7          	lui	a5,0xc201
    80005c3a:	953e                	add	a0,a0,a5
    80005c3c:	00052023          	sw	zero,0(a0)
}
    80005c40:	60a2                	ld	ra,8(sp)
    80005c42:	6402                	ld	s0,0(sp)
    80005c44:	0141                	addi	sp,sp,16
    80005c46:	8082                	ret

0000000080005c48 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80005c48:	1141                	addi	sp,sp,-16
    80005c4a:	e406                	sd	ra,8(sp)
    80005c4c:	e022                	sd	s0,0(sp)
    80005c4e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005c50:	ffffc097          	auipc	ra,0xffffc
    80005c54:	dce080e7          	jalr	-562(ra) # 80001a1e <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80005c58:	00d5179b          	slliw	a5,a0,0xd
    80005c5c:	0c201537          	lui	a0,0xc201
    80005c60:	953e                	add	a0,a0,a5
  return irq;
}
    80005c62:	4148                	lw	a0,4(a0)
    80005c64:	60a2                	ld	ra,8(sp)
    80005c66:	6402                	ld	s0,0(sp)
    80005c68:	0141                	addi	sp,sp,16
    80005c6a:	8082                	ret

0000000080005c6c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80005c6c:	1101                	addi	sp,sp,-32
    80005c6e:	ec06                	sd	ra,24(sp)
    80005c70:	e822                	sd	s0,16(sp)
    80005c72:	e426                	sd	s1,8(sp)
    80005c74:	1000                	addi	s0,sp,32
    80005c76:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005c78:	ffffc097          	auipc	ra,0xffffc
    80005c7c:	da6080e7          	jalr	-602(ra) # 80001a1e <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80005c80:	00d5151b          	slliw	a0,a0,0xd
    80005c84:	0c2017b7          	lui	a5,0xc201
    80005c88:	97aa                	add	a5,a5,a0
    80005c8a:	c3c4                	sw	s1,4(a5)
}
    80005c8c:	60e2                	ld	ra,24(sp)
    80005c8e:	6442                	ld	s0,16(sp)
    80005c90:	64a2                	ld	s1,8(sp)
    80005c92:	6105                	addi	sp,sp,32
    80005c94:	8082                	ret

0000000080005c96 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80005c96:	1141                	addi	sp,sp,-16
    80005c98:	e406                	sd	ra,8(sp)
    80005c9a:	e022                	sd	s0,0(sp)
    80005c9c:	0800                	addi	s0,sp,16
  if(i >= NUM)
    80005c9e:	479d                	li	a5,7
    80005ca0:	06a7c963          	blt	a5,a0,80005d12 <free_desc+0x7c>
    panic("free_desc 1");
  if(disk.free[i])
    80005ca4:	0001d797          	auipc	a5,0x1d
    80005ca8:	35c78793          	addi	a5,a5,860 # 80023000 <disk>
    80005cac:	00a78733          	add	a4,a5,a0
    80005cb0:	6789                	lui	a5,0x2
    80005cb2:	97ba                	add	a5,a5,a4
    80005cb4:	0187c783          	lbu	a5,24(a5) # 2018 <_entry-0x7fffdfe8>
    80005cb8:	e7ad                	bnez	a5,80005d22 <free_desc+0x8c>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80005cba:	00451793          	slli	a5,a0,0x4
    80005cbe:	0001f717          	auipc	a4,0x1f
    80005cc2:	34270713          	addi	a4,a4,834 # 80025000 <disk+0x2000>
    80005cc6:	6314                	ld	a3,0(a4)
    80005cc8:	96be                	add	a3,a3,a5
    80005cca:	0006b023          	sd	zero,0(a3)
  disk.desc[i].len = 0;
    80005cce:	6314                	ld	a3,0(a4)
    80005cd0:	96be                	add	a3,a3,a5
    80005cd2:	0006a423          	sw	zero,8(a3)
  disk.desc[i].flags = 0;
    80005cd6:	6314                	ld	a3,0(a4)
    80005cd8:	96be                	add	a3,a3,a5
    80005cda:	00069623          	sh	zero,12(a3)
  disk.desc[i].next = 0;
    80005cde:	6318                	ld	a4,0(a4)
    80005ce0:	97ba                	add	a5,a5,a4
    80005ce2:	00079723          	sh	zero,14(a5)
  disk.free[i] = 1;
    80005ce6:	0001d797          	auipc	a5,0x1d
    80005cea:	31a78793          	addi	a5,a5,794 # 80023000 <disk>
    80005cee:	97aa                	add	a5,a5,a0
    80005cf0:	6509                	lui	a0,0x2
    80005cf2:	953e                	add	a0,a0,a5
    80005cf4:	4785                	li	a5,1
    80005cf6:	00f50c23          	sb	a5,24(a0) # 2018 <_entry-0x7fffdfe8>
  wakeup(&disk.free[0]);
    80005cfa:	0001f517          	auipc	a0,0x1f
    80005cfe:	31e50513          	addi	a0,a0,798 # 80025018 <disk+0x2018>
    80005d02:	ffffc097          	auipc	ra,0xffffc
    80005d06:	590080e7          	jalr	1424(ra) # 80002292 <wakeup>
}
    80005d0a:	60a2                	ld	ra,8(sp)
    80005d0c:	6402                	ld	s0,0(sp)
    80005d0e:	0141                	addi	sp,sp,16
    80005d10:	8082                	ret
    panic("free_desc 1");
    80005d12:	00003517          	auipc	a0,0x3
    80005d16:	a6650513          	addi	a0,a0,-1434 # 80008778 <syscalls+0x328>
    80005d1a:	ffffb097          	auipc	ra,0xffffb
    80005d1e:	816080e7          	jalr	-2026(ra) # 80000530 <panic>
    panic("free_desc 2");
    80005d22:	00003517          	auipc	a0,0x3
    80005d26:	a6650513          	addi	a0,a0,-1434 # 80008788 <syscalls+0x338>
    80005d2a:	ffffb097          	auipc	ra,0xffffb
    80005d2e:	806080e7          	jalr	-2042(ra) # 80000530 <panic>

0000000080005d32 <virtio_disk_init>:
{
    80005d32:	1101                	addi	sp,sp,-32
    80005d34:	ec06                	sd	ra,24(sp)
    80005d36:	e822                	sd	s0,16(sp)
    80005d38:	e426                	sd	s1,8(sp)
    80005d3a:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80005d3c:	00003597          	auipc	a1,0x3
    80005d40:	a5c58593          	addi	a1,a1,-1444 # 80008798 <syscalls+0x348>
    80005d44:	0001f517          	auipc	a0,0x1f
    80005d48:	3e450513          	addi	a0,a0,996 # 80025128 <disk+0x2128>
    80005d4c:	ffffb097          	auipc	ra,0xffffb
    80005d50:	dfa080e7          	jalr	-518(ra) # 80000b46 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005d54:	100017b7          	lui	a5,0x10001
    80005d58:	4398                	lw	a4,0(a5)
    80005d5a:	2701                	sext.w	a4,a4
    80005d5c:	747277b7          	lui	a5,0x74727
    80005d60:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80005d64:	0ef71163          	bne	a4,a5,80005e46 <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    80005d68:	100017b7          	lui	a5,0x10001
    80005d6c:	43dc                	lw	a5,4(a5)
    80005d6e:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005d70:	4705                	li	a4,1
    80005d72:	0ce79a63          	bne	a5,a4,80005e46 <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005d76:	100017b7          	lui	a5,0x10001
    80005d7a:	479c                	lw	a5,8(a5)
    80005d7c:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    80005d7e:	4709                	li	a4,2
    80005d80:	0ce79363          	bne	a5,a4,80005e46 <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80005d84:	100017b7          	lui	a5,0x10001
    80005d88:	47d8                	lw	a4,12(a5)
    80005d8a:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005d8c:	554d47b7          	lui	a5,0x554d4
    80005d90:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80005d94:	0af71963          	bne	a4,a5,80005e46 <virtio_disk_init+0x114>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005d98:	100017b7          	lui	a5,0x10001
    80005d9c:	4705                	li	a4,1
    80005d9e:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005da0:	470d                	li	a4,3
    80005da2:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    80005da4:	4b94                	lw	a3,16(a5)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80005da6:	c7ffe737          	lui	a4,0xc7ffe
    80005daa:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fd875f>
    80005dae:	8f75                	and	a4,a4,a3
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80005db0:	2701                	sext.w	a4,a4
    80005db2:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005db4:	472d                	li	a4,11
    80005db6:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005db8:	473d                	li	a4,15
    80005dba:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_GUEST_PAGE_SIZE) = PGSIZE;
    80005dbc:	6705                	lui	a4,0x1
    80005dbe:	d798                	sw	a4,40(a5)
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80005dc0:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80005dc4:	5bdc                	lw	a5,52(a5)
    80005dc6:	2781                	sext.w	a5,a5
  if(max == 0)
    80005dc8:	c7d9                	beqz	a5,80005e56 <virtio_disk_init+0x124>
  if(max < NUM)
    80005dca:	471d                	li	a4,7
    80005dcc:	08f77d63          	bgeu	a4,a5,80005e66 <virtio_disk_init+0x134>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80005dd0:	100014b7          	lui	s1,0x10001
    80005dd4:	47a1                	li	a5,8
    80005dd6:	dc9c                	sw	a5,56(s1)
  memset(disk.pages, 0, sizeof(disk.pages));
    80005dd8:	6609                	lui	a2,0x2
    80005dda:	4581                	li	a1,0
    80005ddc:	0001d517          	auipc	a0,0x1d
    80005de0:	22450513          	addi	a0,a0,548 # 80023000 <disk>
    80005de4:	ffffb097          	auipc	ra,0xffffb
    80005de8:	eee080e7          	jalr	-274(ra) # 80000cd2 <memset>
  *R(VIRTIO_MMIO_QUEUE_PFN) = ((uint64)disk.pages) >> PGSHIFT;
    80005dec:	0001d717          	auipc	a4,0x1d
    80005df0:	21470713          	addi	a4,a4,532 # 80023000 <disk>
    80005df4:	00c75793          	srli	a5,a4,0xc
    80005df8:	2781                	sext.w	a5,a5
    80005dfa:	c0bc                	sw	a5,64(s1)
  disk.desc = (struct virtq_desc *) disk.pages;
    80005dfc:	0001f797          	auipc	a5,0x1f
    80005e00:	20478793          	addi	a5,a5,516 # 80025000 <disk+0x2000>
    80005e04:	e398                	sd	a4,0(a5)
  disk.avail = (struct virtq_avail *)(disk.pages + NUM*sizeof(struct virtq_desc));
    80005e06:	0001d717          	auipc	a4,0x1d
    80005e0a:	27a70713          	addi	a4,a4,634 # 80023080 <disk+0x80>
    80005e0e:	e798                	sd	a4,8(a5)
  disk.used = (struct virtq_used *) (disk.pages + PGSIZE);
    80005e10:	0001e717          	auipc	a4,0x1e
    80005e14:	1f070713          	addi	a4,a4,496 # 80024000 <disk+0x1000>
    80005e18:	eb98                	sd	a4,16(a5)
    disk.free[i] = 1;
    80005e1a:	4705                	li	a4,1
    80005e1c:	00e78c23          	sb	a4,24(a5)
    80005e20:	00e78ca3          	sb	a4,25(a5)
    80005e24:	00e78d23          	sb	a4,26(a5)
    80005e28:	00e78da3          	sb	a4,27(a5)
    80005e2c:	00e78e23          	sb	a4,28(a5)
    80005e30:	00e78ea3          	sb	a4,29(a5)
    80005e34:	00e78f23          	sb	a4,30(a5)
    80005e38:	00e78fa3          	sb	a4,31(a5)
}
    80005e3c:	60e2                	ld	ra,24(sp)
    80005e3e:	6442                	ld	s0,16(sp)
    80005e40:	64a2                	ld	s1,8(sp)
    80005e42:	6105                	addi	sp,sp,32
    80005e44:	8082                	ret
    panic("could not find virtio disk");
    80005e46:	00003517          	auipc	a0,0x3
    80005e4a:	96250513          	addi	a0,a0,-1694 # 800087a8 <syscalls+0x358>
    80005e4e:	ffffa097          	auipc	ra,0xffffa
    80005e52:	6e2080e7          	jalr	1762(ra) # 80000530 <panic>
    panic("virtio disk has no queue 0");
    80005e56:	00003517          	auipc	a0,0x3
    80005e5a:	97250513          	addi	a0,a0,-1678 # 800087c8 <syscalls+0x378>
    80005e5e:	ffffa097          	auipc	ra,0xffffa
    80005e62:	6d2080e7          	jalr	1746(ra) # 80000530 <panic>
    panic("virtio disk max queue too short");
    80005e66:	00003517          	auipc	a0,0x3
    80005e6a:	98250513          	addi	a0,a0,-1662 # 800087e8 <syscalls+0x398>
    80005e6e:	ffffa097          	auipc	ra,0xffffa
    80005e72:	6c2080e7          	jalr	1730(ra) # 80000530 <panic>

0000000080005e76 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80005e76:	7159                	addi	sp,sp,-112
    80005e78:	f486                	sd	ra,104(sp)
    80005e7a:	f0a2                	sd	s0,96(sp)
    80005e7c:	eca6                	sd	s1,88(sp)
    80005e7e:	e8ca                	sd	s2,80(sp)
    80005e80:	e4ce                	sd	s3,72(sp)
    80005e82:	e0d2                	sd	s4,64(sp)
    80005e84:	fc56                	sd	s5,56(sp)
    80005e86:	f85a                	sd	s6,48(sp)
    80005e88:	f45e                	sd	s7,40(sp)
    80005e8a:	f062                	sd	s8,32(sp)
    80005e8c:	ec66                	sd	s9,24(sp)
    80005e8e:	e86a                	sd	s10,16(sp)
    80005e90:	1880                	addi	s0,sp,112
    80005e92:	892a                	mv	s2,a0
    80005e94:	8d2e                	mv	s10,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80005e96:	00c52c83          	lw	s9,12(a0)
    80005e9a:	001c9c9b          	slliw	s9,s9,0x1
    80005e9e:	1c82                	slli	s9,s9,0x20
    80005ea0:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    80005ea4:	0001f517          	auipc	a0,0x1f
    80005ea8:	28450513          	addi	a0,a0,644 # 80025128 <disk+0x2128>
    80005eac:	ffffb097          	auipc	ra,0xffffb
    80005eb0:	d2a080e7          	jalr	-726(ra) # 80000bd6 <acquire>
  for(int i = 0; i < 3; i++){
    80005eb4:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    80005eb6:	4c21                	li	s8,8
      disk.free[i] = 0;
    80005eb8:	0001db97          	auipc	s7,0x1d
    80005ebc:	148b8b93          	addi	s7,s7,328 # 80023000 <disk>
    80005ec0:	6b09                	lui	s6,0x2
  for(int i = 0; i < 3; i++){
    80005ec2:	4a8d                	li	s5,3
  for(int i = 0; i < NUM; i++){
    80005ec4:	8a4e                	mv	s4,s3
    80005ec6:	a051                	j	80005f4a <virtio_disk_rw+0xd4>
      disk.free[i] = 0;
    80005ec8:	00fb86b3          	add	a3,s7,a5
    80005ecc:	96da                	add	a3,a3,s6
    80005ece:	00068c23          	sb	zero,24(a3)
    idx[i] = alloc_desc();
    80005ed2:	c21c                	sw	a5,0(a2)
    if(idx[i] < 0){
    80005ed4:	0207c563          	bltz	a5,80005efe <virtio_disk_rw+0x88>
  for(int i = 0; i < 3; i++){
    80005ed8:	2485                	addiw	s1,s1,1
    80005eda:	0711                	addi	a4,a4,4
    80005edc:	25548063          	beq	s1,s5,8000611c <virtio_disk_rw+0x2a6>
    idx[i] = alloc_desc();
    80005ee0:	863a                	mv	a2,a4
  for(int i = 0; i < NUM; i++){
    80005ee2:	0001f697          	auipc	a3,0x1f
    80005ee6:	13668693          	addi	a3,a3,310 # 80025018 <disk+0x2018>
    80005eea:	87d2                	mv	a5,s4
    if(disk.free[i]){
    80005eec:	0006c583          	lbu	a1,0(a3)
    80005ef0:	fde1                	bnez	a1,80005ec8 <virtio_disk_rw+0x52>
  for(int i = 0; i < NUM; i++){
    80005ef2:	2785                	addiw	a5,a5,1
    80005ef4:	0685                	addi	a3,a3,1
    80005ef6:	ff879be3          	bne	a5,s8,80005eec <virtio_disk_rw+0x76>
    idx[i] = alloc_desc();
    80005efa:	57fd                	li	a5,-1
    80005efc:	c21c                	sw	a5,0(a2)
      for(int j = 0; j < i; j++)
    80005efe:	02905a63          	blez	s1,80005f32 <virtio_disk_rw+0xbc>
        free_desc(idx[j]);
    80005f02:	f9042503          	lw	a0,-112(s0)
    80005f06:	00000097          	auipc	ra,0x0
    80005f0a:	d90080e7          	jalr	-624(ra) # 80005c96 <free_desc>
      for(int j = 0; j < i; j++)
    80005f0e:	4785                	li	a5,1
    80005f10:	0297d163          	bge	a5,s1,80005f32 <virtio_disk_rw+0xbc>
        free_desc(idx[j]);
    80005f14:	f9442503          	lw	a0,-108(s0)
    80005f18:	00000097          	auipc	ra,0x0
    80005f1c:	d7e080e7          	jalr	-642(ra) # 80005c96 <free_desc>
      for(int j = 0; j < i; j++)
    80005f20:	4789                	li	a5,2
    80005f22:	0097d863          	bge	a5,s1,80005f32 <virtio_disk_rw+0xbc>
        free_desc(idx[j]);
    80005f26:	f9842503          	lw	a0,-104(s0)
    80005f2a:	00000097          	auipc	ra,0x0
    80005f2e:	d6c080e7          	jalr	-660(ra) # 80005c96 <free_desc>
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80005f32:	0001f597          	auipc	a1,0x1f
    80005f36:	1f658593          	addi	a1,a1,502 # 80025128 <disk+0x2128>
    80005f3a:	0001f517          	auipc	a0,0x1f
    80005f3e:	0de50513          	addi	a0,a0,222 # 80025018 <disk+0x2018>
    80005f42:	ffffc097          	auipc	ra,0xffffc
    80005f46:	1c4080e7          	jalr	452(ra) # 80002106 <sleep>
  for(int i = 0; i < 3; i++){
    80005f4a:	f9040713          	addi	a4,s0,-112
    80005f4e:	84ce                	mv	s1,s3
    80005f50:	bf41                	j	80005ee0 <virtio_disk_rw+0x6a>
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];

  if(write)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
    80005f52:	20058713          	addi	a4,a1,512
    80005f56:	00471693          	slli	a3,a4,0x4
    80005f5a:	0001d717          	auipc	a4,0x1d
    80005f5e:	0a670713          	addi	a4,a4,166 # 80023000 <disk>
    80005f62:	9736                	add	a4,a4,a3
    80005f64:	4685                	li	a3,1
    80005f66:	0ad72423          	sw	a3,168(a4)
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80005f6a:	20058713          	addi	a4,a1,512
    80005f6e:	00471693          	slli	a3,a4,0x4
    80005f72:	0001d717          	auipc	a4,0x1d
    80005f76:	08e70713          	addi	a4,a4,142 # 80023000 <disk>
    80005f7a:	9736                	add	a4,a4,a3
    80005f7c:	0a072623          	sw	zero,172(a4)
  buf0->sector = sector;
    80005f80:	0b973823          	sd	s9,176(a4)

  disk.desc[idx[0]].addr = (uint64) buf0;
    80005f84:	7679                	lui	a2,0xffffe
    80005f86:	963e                	add	a2,a2,a5
    80005f88:	0001f697          	auipc	a3,0x1f
    80005f8c:	07868693          	addi	a3,a3,120 # 80025000 <disk+0x2000>
    80005f90:	6298                	ld	a4,0(a3)
    80005f92:	9732                	add	a4,a4,a2
    80005f94:	e308                	sd	a0,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80005f96:	6298                	ld	a4,0(a3)
    80005f98:	9732                	add	a4,a4,a2
    80005f9a:	4541                	li	a0,16
    80005f9c:	c708                	sw	a0,8(a4)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80005f9e:	6298                	ld	a4,0(a3)
    80005fa0:	9732                	add	a4,a4,a2
    80005fa2:	4505                	li	a0,1
    80005fa4:	00a71623          	sh	a0,12(a4)
  disk.desc[idx[0]].next = idx[1];
    80005fa8:	f9442703          	lw	a4,-108(s0)
    80005fac:	6288                	ld	a0,0(a3)
    80005fae:	962a                	add	a2,a2,a0
    80005fb0:	00e61723          	sh	a4,14(a2) # ffffffffffffe00e <end+0xffffffff7ffd800e>

  disk.desc[idx[1]].addr = (uint64) b->data;
    80005fb4:	0712                	slli	a4,a4,0x4
    80005fb6:	6290                	ld	a2,0(a3)
    80005fb8:	963a                	add	a2,a2,a4
    80005fba:	05890513          	addi	a0,s2,88
    80005fbe:	e208                	sd	a0,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    80005fc0:	6294                	ld	a3,0(a3)
    80005fc2:	96ba                	add	a3,a3,a4
    80005fc4:	40000613          	li	a2,1024
    80005fc8:	c690                	sw	a2,8(a3)
  if(write)
    80005fca:	140d0063          	beqz	s10,8000610a <virtio_disk_rw+0x294>
    disk.desc[idx[1]].flags = 0; // device reads b->data
    80005fce:	0001f697          	auipc	a3,0x1f
    80005fd2:	0326b683          	ld	a3,50(a3) # 80025000 <disk+0x2000>
    80005fd6:	96ba                	add	a3,a3,a4
    80005fd8:	00069623          	sh	zero,12(a3)
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80005fdc:	0001d817          	auipc	a6,0x1d
    80005fe0:	02480813          	addi	a6,a6,36 # 80023000 <disk>
    80005fe4:	0001f517          	auipc	a0,0x1f
    80005fe8:	01c50513          	addi	a0,a0,28 # 80025000 <disk+0x2000>
    80005fec:	6114                	ld	a3,0(a0)
    80005fee:	96ba                	add	a3,a3,a4
    80005ff0:	00c6d603          	lhu	a2,12(a3)
    80005ff4:	00166613          	ori	a2,a2,1
    80005ff8:	00c69623          	sh	a2,12(a3)
  disk.desc[idx[1]].next = idx[2];
    80005ffc:	f9842683          	lw	a3,-104(s0)
    80006000:	6110                	ld	a2,0(a0)
    80006002:	9732                	add	a4,a4,a2
    80006004:	00d71723          	sh	a3,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80006008:	20058613          	addi	a2,a1,512
    8000600c:	0612                	slli	a2,a2,0x4
    8000600e:	9642                	add	a2,a2,a6
    80006010:	577d                	li	a4,-1
    80006012:	02e60823          	sb	a4,48(a2)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    80006016:	00469713          	slli	a4,a3,0x4
    8000601a:	6114                	ld	a3,0(a0)
    8000601c:	96ba                	add	a3,a3,a4
    8000601e:	03078793          	addi	a5,a5,48
    80006022:	97c2                	add	a5,a5,a6
    80006024:	e29c                	sd	a5,0(a3)
  disk.desc[idx[2]].len = 1;
    80006026:	611c                	ld	a5,0(a0)
    80006028:	97ba                	add	a5,a5,a4
    8000602a:	4685                	li	a3,1
    8000602c:	c794                	sw	a3,8(a5)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    8000602e:	611c                	ld	a5,0(a0)
    80006030:	97ba                	add	a5,a5,a4
    80006032:	4809                	li	a6,2
    80006034:	01079623          	sh	a6,12(a5)
  disk.desc[idx[2]].next = 0;
    80006038:	611c                	ld	a5,0(a0)
    8000603a:	973e                	add	a4,a4,a5
    8000603c:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80006040:	00d92223          	sw	a3,4(s2)
  disk.info[idx[0]].b = b;
    80006044:	03263423          	sd	s2,40(a2)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80006048:	6518                	ld	a4,8(a0)
    8000604a:	00275783          	lhu	a5,2(a4)
    8000604e:	8b9d                	andi	a5,a5,7
    80006050:	0786                	slli	a5,a5,0x1
    80006052:	97ba                	add	a5,a5,a4
    80006054:	00b79223          	sh	a1,4(a5)

  __sync_synchronize();
    80006058:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    8000605c:	6518                	ld	a4,8(a0)
    8000605e:	00275783          	lhu	a5,2(a4)
    80006062:	2785                	addiw	a5,a5,1
    80006064:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80006068:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    8000606c:	100017b7          	lui	a5,0x10001
    80006070:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80006074:	00492703          	lw	a4,4(s2)
    80006078:	4785                	li	a5,1
    8000607a:	02f71163          	bne	a4,a5,8000609c <virtio_disk_rw+0x226>
    sleep(b, &disk.vdisk_lock);
    8000607e:	0001f997          	auipc	s3,0x1f
    80006082:	0aa98993          	addi	s3,s3,170 # 80025128 <disk+0x2128>
  while(b->disk == 1) {
    80006086:	4485                	li	s1,1
    sleep(b, &disk.vdisk_lock);
    80006088:	85ce                	mv	a1,s3
    8000608a:	854a                	mv	a0,s2
    8000608c:	ffffc097          	auipc	ra,0xffffc
    80006090:	07a080e7          	jalr	122(ra) # 80002106 <sleep>
  while(b->disk == 1) {
    80006094:	00492783          	lw	a5,4(s2)
    80006098:	fe9788e3          	beq	a5,s1,80006088 <virtio_disk_rw+0x212>
  }

  disk.info[idx[0]].b = 0;
    8000609c:	f9042903          	lw	s2,-112(s0)
    800060a0:	20090793          	addi	a5,s2,512
    800060a4:	00479713          	slli	a4,a5,0x4
    800060a8:	0001d797          	auipc	a5,0x1d
    800060ac:	f5878793          	addi	a5,a5,-168 # 80023000 <disk>
    800060b0:	97ba                	add	a5,a5,a4
    800060b2:	0207b423          	sd	zero,40(a5)
    int flag = disk.desc[i].flags;
    800060b6:	0001f997          	auipc	s3,0x1f
    800060ba:	f4a98993          	addi	s3,s3,-182 # 80025000 <disk+0x2000>
    800060be:	00491713          	slli	a4,s2,0x4
    800060c2:	0009b783          	ld	a5,0(s3)
    800060c6:	97ba                	add	a5,a5,a4
    800060c8:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    800060cc:	854a                	mv	a0,s2
    800060ce:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    800060d2:	00000097          	auipc	ra,0x0
    800060d6:	bc4080e7          	jalr	-1084(ra) # 80005c96 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    800060da:	8885                	andi	s1,s1,1
    800060dc:	f0ed                	bnez	s1,800060be <virtio_disk_rw+0x248>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    800060de:	0001f517          	auipc	a0,0x1f
    800060e2:	04a50513          	addi	a0,a0,74 # 80025128 <disk+0x2128>
    800060e6:	ffffb097          	auipc	ra,0xffffb
    800060ea:	ba4080e7          	jalr	-1116(ra) # 80000c8a <release>
}
    800060ee:	70a6                	ld	ra,104(sp)
    800060f0:	7406                	ld	s0,96(sp)
    800060f2:	64e6                	ld	s1,88(sp)
    800060f4:	6946                	ld	s2,80(sp)
    800060f6:	69a6                	ld	s3,72(sp)
    800060f8:	6a06                	ld	s4,64(sp)
    800060fa:	7ae2                	ld	s5,56(sp)
    800060fc:	7b42                	ld	s6,48(sp)
    800060fe:	7ba2                	ld	s7,40(sp)
    80006100:	7c02                	ld	s8,32(sp)
    80006102:	6ce2                	ld	s9,24(sp)
    80006104:	6d42                	ld	s10,16(sp)
    80006106:	6165                	addi	sp,sp,112
    80006108:	8082                	ret
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    8000610a:	0001f697          	auipc	a3,0x1f
    8000610e:	ef66b683          	ld	a3,-266(a3) # 80025000 <disk+0x2000>
    80006112:	96ba                	add	a3,a3,a4
    80006114:	4609                	li	a2,2
    80006116:	00c69623          	sh	a2,12(a3)
    8000611a:	b5c9                	j	80005fdc <virtio_disk_rw+0x166>
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    8000611c:	f9042583          	lw	a1,-112(s0)
    80006120:	20058793          	addi	a5,a1,512
    80006124:	0792                	slli	a5,a5,0x4
    80006126:	0001d517          	auipc	a0,0x1d
    8000612a:	f8250513          	addi	a0,a0,-126 # 800230a8 <disk+0xa8>
    8000612e:	953e                	add	a0,a0,a5
  if(write)
    80006130:	e20d11e3          	bnez	s10,80005f52 <virtio_disk_rw+0xdc>
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
    80006134:	20058713          	addi	a4,a1,512
    80006138:	00471693          	slli	a3,a4,0x4
    8000613c:	0001d717          	auipc	a4,0x1d
    80006140:	ec470713          	addi	a4,a4,-316 # 80023000 <disk>
    80006144:	9736                	add	a4,a4,a3
    80006146:	0a072423          	sw	zero,168(a4)
    8000614a:	b505                	j	80005f6a <virtio_disk_rw+0xf4>

000000008000614c <virtio_disk_intr>:

void
virtio_disk_intr()
{
    8000614c:	1101                	addi	sp,sp,-32
    8000614e:	ec06                	sd	ra,24(sp)
    80006150:	e822                	sd	s0,16(sp)
    80006152:	e426                	sd	s1,8(sp)
    80006154:	e04a                	sd	s2,0(sp)
    80006156:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80006158:	0001f517          	auipc	a0,0x1f
    8000615c:	fd050513          	addi	a0,a0,-48 # 80025128 <disk+0x2128>
    80006160:	ffffb097          	auipc	ra,0xffffb
    80006164:	a76080e7          	jalr	-1418(ra) # 80000bd6 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80006168:	10001737          	lui	a4,0x10001
    8000616c:	533c                	lw	a5,96(a4)
    8000616e:	8b8d                	andi	a5,a5,3
    80006170:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    80006172:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80006176:	0001f797          	auipc	a5,0x1f
    8000617a:	e8a78793          	addi	a5,a5,-374 # 80025000 <disk+0x2000>
    8000617e:	6b94                	ld	a3,16(a5)
    80006180:	0207d703          	lhu	a4,32(a5)
    80006184:	0026d783          	lhu	a5,2(a3)
    80006188:	06f70163          	beq	a4,a5,800061ea <virtio_disk_intr+0x9e>
    __sync_synchronize();
    int id = disk.used->ring[disk.used_idx % NUM].id;
    8000618c:	0001d917          	auipc	s2,0x1d
    80006190:	e7490913          	addi	s2,s2,-396 # 80023000 <disk>
    80006194:	0001f497          	auipc	s1,0x1f
    80006198:	e6c48493          	addi	s1,s1,-404 # 80025000 <disk+0x2000>
    __sync_synchronize();
    8000619c:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    800061a0:	6898                	ld	a4,16(s1)
    800061a2:	0204d783          	lhu	a5,32(s1)
    800061a6:	8b9d                	andi	a5,a5,7
    800061a8:	078e                	slli	a5,a5,0x3
    800061aa:	97ba                	add	a5,a5,a4
    800061ac:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    800061ae:	20078713          	addi	a4,a5,512
    800061b2:	0712                	slli	a4,a4,0x4
    800061b4:	974a                	add	a4,a4,s2
    800061b6:	03074703          	lbu	a4,48(a4) # 10001030 <_entry-0x6fffefd0>
    800061ba:	e731                	bnez	a4,80006206 <virtio_disk_intr+0xba>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    800061bc:	20078793          	addi	a5,a5,512
    800061c0:	0792                	slli	a5,a5,0x4
    800061c2:	97ca                	add	a5,a5,s2
    800061c4:	7788                	ld	a0,40(a5)
    b->disk = 0;   // disk is done with buf
    800061c6:	00052223          	sw	zero,4(a0)
    wakeup(b);
    800061ca:	ffffc097          	auipc	ra,0xffffc
    800061ce:	0c8080e7          	jalr	200(ra) # 80002292 <wakeup>

    disk.used_idx += 1;
    800061d2:	0204d783          	lhu	a5,32(s1)
    800061d6:	2785                	addiw	a5,a5,1
    800061d8:	17c2                	slli	a5,a5,0x30
    800061da:	93c1                	srli	a5,a5,0x30
    800061dc:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    800061e0:	6898                	ld	a4,16(s1)
    800061e2:	00275703          	lhu	a4,2(a4)
    800061e6:	faf71be3          	bne	a4,a5,8000619c <virtio_disk_intr+0x50>
  }

  release(&disk.vdisk_lock);
    800061ea:	0001f517          	auipc	a0,0x1f
    800061ee:	f3e50513          	addi	a0,a0,-194 # 80025128 <disk+0x2128>
    800061f2:	ffffb097          	auipc	ra,0xffffb
    800061f6:	a98080e7          	jalr	-1384(ra) # 80000c8a <release>
}
    800061fa:	60e2                	ld	ra,24(sp)
    800061fc:	6442                	ld	s0,16(sp)
    800061fe:	64a2                	ld	s1,8(sp)
    80006200:	6902                	ld	s2,0(sp)
    80006202:	6105                	addi	sp,sp,32
    80006204:	8082                	ret
      panic("virtio_disk_intr status");
    80006206:	00002517          	auipc	a0,0x2
    8000620a:	60250513          	addi	a0,a0,1538 # 80008808 <syscalls+0x3b8>
    8000620e:	ffffa097          	auipc	ra,0xffffa
    80006212:	322080e7          	jalr	802(ra) # 80000530 <panic>
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
