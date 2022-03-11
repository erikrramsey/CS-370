
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00009117          	auipc	sp,0x9
    80000004:	85013103          	ld	sp,-1968(sp) # 80008850 <_GLOBAL_OFFSET_TABLE_+0x8>
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
    80000068:	aac78793          	addi	a5,a5,-1364 # 80005b10 <timervec>
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
    80000122:	332080e7          	jalr	818(ra) # 80002450 <either_copyin>
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
    800001ca:	e90080e7          	jalr	-368(ra) # 80002056 <sleep>
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
    80000206:	1f8080e7          	jalr	504(ra) # 800023fa <either_copyout>
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
    800002e8:	1c2080e7          	jalr	450(ra) # 800024a6 <procdump>
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
    8000043c:	daa080e7          	jalr	-598(ra) # 800021e2 <wakeup>
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
    80000896:	950080e7          	jalr	-1712(ra) # 800021e2 <wakeup>
    
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
    80000922:	738080e7          	jalr	1848(ra) # 80002056 <sleep>
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
    80000eca:	00001097          	auipc	ra,0x1
    80000ece:	72a080e7          	jalr	1834(ra) # 800025f4 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000ed2:	00005097          	auipc	ra,0x5
    80000ed6:	c7e080e7          	jalr	-898(ra) # 80005b50 <plicinithart>
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
    80000f46:	68a080e7          	jalr	1674(ra) # 800025cc <trapinit>
    trapinithart();  // install kernel trap vector
    80000f4a:	00001097          	auipc	ra,0x1
    80000f4e:	6aa080e7          	jalr	1706(ra) # 800025f4 <trapinithart>
    plicinit();      // set up interrupt controller
    80000f52:	00005097          	auipc	ra,0x5
    80000f56:	be8080e7          	jalr	-1048(ra) # 80005b3a <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000f5a:	00005097          	auipc	ra,0x5
    80000f5e:	bf6080e7          	jalr	-1034(ra) # 80005b50 <plicinithart>
    binit();         // buffer cache
    80000f62:	00002097          	auipc	ra,0x2
    80000f66:	dd4080e7          	jalr	-556(ra) # 80002d36 <binit>
    iinit();         // inode cache
    80000f6a:	00002097          	auipc	ra,0x2
    80000f6e:	464080e7          	jalr	1124(ra) # 800033ce <iinit>
    fileinit();      // file table
    80000f72:	00003097          	auipc	ra,0x3
    80000f76:	40e080e7          	jalr	1038(ra) # 80004380 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f7a:	00005097          	auipc	ra,0x5
    80000f7e:	cf8080e7          	jalr	-776(ra) # 80005c72 <virtio_disk_init>
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
    8000194a:	e4bc                	sd	a5,72(s1)
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
    800019e8:	e1c7a783          	lw	a5,-484(a5) # 80008800 <first.1685>
    800019ec:	eb89                	bnez	a5,800019fe <forkret+0x32>
    // be run from main().
    first = 0;
    fsinit(ROOTDEV);
  }

  usertrapret();
    800019ee:	00001097          	auipc	ra,0x1
    800019f2:	c1e080e7          	jalr	-994(ra) # 8000260c <usertrapret>
}
    800019f6:	60a2                	ld	ra,8(sp)
    800019f8:	6402                	ld	s0,0(sp)
    800019fa:	0141                	addi	sp,sp,16
    800019fc:	8082                	ret
    first = 0;
    800019fe:	00007797          	auipc	a5,0x7
    80001a02:	e007a123          	sw	zero,-510(a5) # 80008800 <first.1685>
    fsinit(ROOTDEV);
    80001a06:	4505                	li	a0,1
    80001a08:	00002097          	auipc	ra,0x2
    80001a0c:	946080e7          	jalr	-1722(ra) # 8000334e <fsinit>
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
    80001a34:	dd478793          	addi	a5,a5,-556 # 80008804 <nextpid>
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
    80001a94:	06093683          	ld	a3,96(s2)
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
    80001b52:	7128                	ld	a0,96(a0)
    80001b54:	c509                	beqz	a0,80001b5e <freeproc+0x18>
    kfree((void*)p->trapframe);
    80001b56:	fffff097          	auipc	ra,0xfffff
    80001b5a:	e94080e7          	jalr	-364(ra) # 800009ea <kfree>
  p->trapframe = 0;
    80001b5e:	0604b023          	sd	zero,96(s1)
  if(p->pagetable)
    80001b62:	6ca8                	ld	a0,88(s1)
    80001b64:	c511                	beqz	a0,80001b70 <freeproc+0x2a>
    proc_freepagetable(p->pagetable, p->sz);
    80001b66:	68ac                	ld	a1,80(s1)
    80001b68:	00000097          	auipc	ra,0x0
    80001b6c:	f8c080e7          	jalr	-116(ra) # 80001af4 <proc_freepagetable>
  p->pagetable = 0;
    80001b70:	0404bc23          	sd	zero,88(s1)
  p->sz = 0;
    80001b74:	0404b823          	sd	zero,80(s1)
  p->pid = 0;
    80001b78:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001b7c:	0404b023          	sd	zero,64(s1)
  p->name[0] = 0;
    80001b80:	16048023          	sb	zero,352(s1)
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
    80001bf6:	f0a8                	sd	a0,96(s1)
    80001bf8:	c131                	beqz	a0,80001c3c <allocproc+0x9e>
  p->pagetable = proc_pagetable(p);
    80001bfa:	8526                	mv	a0,s1
    80001bfc:	00000097          	auipc	ra,0x0
    80001c00:	e5c080e7          	jalr	-420(ra) # 80001a58 <proc_pagetable>
    80001c04:	892a                	mv	s2,a0
    80001c06:	eca8                	sd	a0,88(s1)
  if(p->pagetable == 0){
    80001c08:	c531                	beqz	a0,80001c54 <allocproc+0xb6>
  memset(&p->context, 0, sizeof(p->context));
    80001c0a:	07000613          	li	a2,112
    80001c0e:	4581                	li	a1,0
    80001c10:	06848513          	addi	a0,s1,104
    80001c14:	fffff097          	auipc	ra,0xfffff
    80001c18:	0be080e7          	jalr	190(ra) # 80000cd2 <memset>
  p->context.ra = (uint64)forkret;
    80001c1c:	00000797          	auipc	a5,0x0
    80001c20:	db078793          	addi	a5,a5,-592 # 800019cc <forkret>
    80001c24:	f4bc                	sd	a5,104(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001c26:	64bc                	ld	a5,72(s1)
    80001c28:	6705                	lui	a4,0x1
    80001c2a:	97ba                	add	a5,a5,a4
    80001c2c:	f8bc                	sd	a5,112(s1)
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
    80001c90:	b8458593          	addi	a1,a1,-1148 # 80008810 <initcode>
    80001c94:	6d28                	ld	a0,88(a0)
    80001c96:	fffff097          	auipc	ra,0xfffff
    80001c9a:	6b6080e7          	jalr	1718(ra) # 8000134c <uvminit>
  p->sz = PGSIZE;
    80001c9e:	6785                	lui	a5,0x1
    80001ca0:	e8bc                	sd	a5,80(s1)
  p->trapframe->epc = 0;      // user program counter
    80001ca2:	70b8                	ld	a4,96(s1)
    80001ca4:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE;  // user stack pointer
    80001ca8:	70b8                	ld	a4,96(s1)
    80001caa:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001cac:	4641                	li	a2,16
    80001cae:	00006597          	auipc	a1,0x6
    80001cb2:	53a58593          	addi	a1,a1,1338 # 800081e8 <digits+0x1a8>
    80001cb6:	16048513          	addi	a0,s1,352
    80001cba:	fffff097          	auipc	ra,0xfffff
    80001cbe:	16e080e7          	jalr	366(ra) # 80000e28 <safestrcpy>
  p->cwd = namei("/");
    80001cc2:	00006517          	auipc	a0,0x6
    80001cc6:	53650513          	addi	a0,a0,1334 # 800081f8 <digits+0x1b8>
    80001cca:	00002097          	auipc	ra,0x2
    80001cce:	0b2080e7          	jalr	178(ra) # 80003d7c <namei>
    80001cd2:	14a4bc23          	sd	a0,344(s1)
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
    80001d06:	692c                	ld	a1,80(a0)
    80001d08:	0005861b          	sext.w	a2,a1
  if(n > 0){
    80001d0c:	00904f63          	bgtz	s1,80001d2a <growproc+0x3c>
  } else if(n < 0){
    80001d10:	0204cc63          	bltz	s1,80001d48 <growproc+0x5a>
  p->sz = sz;
    80001d14:	1602                	slli	a2,a2,0x20
    80001d16:	9201                	srli	a2,a2,0x20
    80001d18:	04c93823          	sd	a2,80(s2)
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
    80001d34:	6d28                	ld	a0,88(a0)
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
    80001d52:	6d28                	ld	a0,88(a0)
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
    80001d8a:	05093603          	ld	a2,80(s2)
    80001d8e:	6d2c                	ld	a1,88(a0)
    80001d90:	05893503          	ld	a0,88(s2)
    80001d94:	fffff097          	auipc	ra,0xfffff
    80001d98:	7be080e7          	jalr	1982(ra) # 80001552 <uvmcopy>
    80001d9c:	04054963          	bltz	a0,80001dee <fork+0x8c>
  np->sz = p->sz;
    80001da0:	05093783          	ld	a5,80(s2)
    80001da4:	04f9b823          	sd	a5,80(s3)
  np->priority = 2;
    80001da8:	4789                	li	a5,2
    80001daa:	02f9bc23          	sd	a5,56(s3)
  *(np->trapframe) = *(p->trapframe);
    80001dae:	06093683          	ld	a3,96(s2)
    80001db2:	87b6                	mv	a5,a3
    80001db4:	0609b703          	ld	a4,96(s3)
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
    80001ddc:	0609b783          	ld	a5,96(s3)
    80001de0:	0607b823          	sd	zero,112(a5)
    80001de4:	0d800493          	li	s1,216
  for(i = 0; i < NOFILE; i++)
    80001de8:	15800a13          	li	s4,344
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
    80001e0a:	60c080e7          	jalr	1548(ra) # 80004412 <filedup>
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
    80001e24:	15893503          	ld	a0,344(s2)
    80001e28:	00001097          	auipc	ra,0x1
    80001e2c:	760080e7          	jalr	1888(ra) # 80003588 <idup>
    80001e30:	14a9bc23          	sd	a0,344(s3)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001e34:	4641                	li	a2,16
    80001e36:	16090593          	addi	a1,s2,352
    80001e3a:	16098513          	addi	a0,s3,352
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
    80001e66:	0529b023          	sd	s2,64(s3)
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
    80001ea4:	7139                	addi	sp,sp,-64
    80001ea6:	fc06                	sd	ra,56(sp)
    80001ea8:	f822                	sd	s0,48(sp)
    80001eaa:	f426                	sd	s1,40(sp)
    80001eac:	f04a                	sd	s2,32(sp)
    80001eae:	ec4e                	sd	s3,24(sp)
    80001eb0:	e852                	sd	s4,16(sp)
    80001eb2:	e456                	sd	s5,8(sp)
    80001eb4:	e05a                	sd	s6,0(sp)
    80001eb6:	0080                	addi	s0,sp,64
    80001eb8:	8792                	mv	a5,tp
  int id = r_tp();
    80001eba:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001ebc:	00779a93          	slli	s5,a5,0x7
    80001ec0:	0000f717          	auipc	a4,0xf
    80001ec4:	3e070713          	addi	a4,a4,992 # 800112a0 <pid_lock>
    80001ec8:	9756                	add	a4,a4,s5
    80001eca:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    80001ece:	0000f717          	auipc	a4,0xf
    80001ed2:	40a70713          	addi	a4,a4,1034 # 800112d8 <cpus+0x8>
    80001ed6:	9aba                	add	s5,s5,a4
      if(p->state == RUNNABLE) {
    80001ed8:	498d                	li	s3,3
        p->state = RUNNING;
    80001eda:	4b11                	li	s6,4
        c->proc = p;
    80001edc:	079e                	slli	a5,a5,0x7
    80001ede:	0000fa17          	auipc	s4,0xf
    80001ee2:	3c2a0a13          	addi	s4,s4,962 # 800112a0 <pid_lock>
    80001ee6:	9a3e                	add	s4,s4,a5
    for(p = proc; p < &proc[NPROC]; p++) {
    80001ee8:	00015917          	auipc	s2,0x15
    80001eec:	3e890913          	addi	s2,s2,1000 # 800172d0 <tickslock>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001ef0:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001ef4:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001ef8:	10079073          	csrw	sstatus,a5
    80001efc:	0000f497          	auipc	s1,0xf
    80001f00:	7d448493          	addi	s1,s1,2004 # 800116d0 <proc>
    80001f04:	a03d                	j	80001f32 <scheduler+0x8e>
        p->state = RUNNING;
    80001f06:	0164ac23          	sw	s6,24(s1)
        c->proc = p;
    80001f0a:	029a3823          	sd	s1,48(s4)
        swtch(&c->context, &p->context);
    80001f0e:	06848593          	addi	a1,s1,104
    80001f12:	8556                	mv	a0,s5
    80001f14:	00000097          	auipc	ra,0x0
    80001f18:	64e080e7          	jalr	1614(ra) # 80002562 <swtch>
        c->proc = 0;
    80001f1c:	020a3823          	sd	zero,48(s4)
      release(&p->lock);
    80001f20:	8526                	mv	a0,s1
    80001f22:	fffff097          	auipc	ra,0xfffff
    80001f26:	d68080e7          	jalr	-664(ra) # 80000c8a <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    80001f2a:	17048493          	addi	s1,s1,368
    80001f2e:	fd2481e3          	beq	s1,s2,80001ef0 <scheduler+0x4c>
      acquire(&p->lock);
    80001f32:	8526                	mv	a0,s1
    80001f34:	fffff097          	auipc	ra,0xfffff
    80001f38:	ca2080e7          	jalr	-862(ra) # 80000bd6 <acquire>
      if(p->state == RUNNABLE) {
    80001f3c:	4c9c                	lw	a5,24(s1)
    80001f3e:	ff3791e3          	bne	a5,s3,80001f20 <scheduler+0x7c>
    80001f42:	b7d1                	j	80001f06 <scheduler+0x62>

0000000080001f44 <sched>:
{
    80001f44:	7179                	addi	sp,sp,-48
    80001f46:	f406                	sd	ra,40(sp)
    80001f48:	f022                	sd	s0,32(sp)
    80001f4a:	ec26                	sd	s1,24(sp)
    80001f4c:	e84a                	sd	s2,16(sp)
    80001f4e:	e44e                	sd	s3,8(sp)
    80001f50:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001f52:	00000097          	auipc	ra,0x0
    80001f56:	a42080e7          	jalr	-1470(ra) # 80001994 <myproc>
    80001f5a:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80001f5c:	fffff097          	auipc	ra,0xfffff
    80001f60:	c00080e7          	jalr	-1024(ra) # 80000b5c <holding>
    80001f64:	c93d                	beqz	a0,80001fda <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001f66:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    80001f68:	2781                	sext.w	a5,a5
    80001f6a:	079e                	slli	a5,a5,0x7
    80001f6c:	0000f717          	auipc	a4,0xf
    80001f70:	33470713          	addi	a4,a4,820 # 800112a0 <pid_lock>
    80001f74:	97ba                	add	a5,a5,a4
    80001f76:	0a87a703          	lw	a4,168(a5)
    80001f7a:	4785                	li	a5,1
    80001f7c:	06f71763          	bne	a4,a5,80001fea <sched+0xa6>
  if(p->state == RUNNING)
    80001f80:	4c98                	lw	a4,24(s1)
    80001f82:	4791                	li	a5,4
    80001f84:	06f70b63          	beq	a4,a5,80001ffa <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001f88:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80001f8c:	8b89                	andi	a5,a5,2
  if(intr_get())
    80001f8e:	efb5                	bnez	a5,8000200a <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001f90:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80001f92:	0000f917          	auipc	s2,0xf
    80001f96:	30e90913          	addi	s2,s2,782 # 800112a0 <pid_lock>
    80001f9a:	2781                	sext.w	a5,a5
    80001f9c:	079e                	slli	a5,a5,0x7
    80001f9e:	97ca                	add	a5,a5,s2
    80001fa0:	0ac7a983          	lw	s3,172(a5)
    80001fa4:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80001fa6:	2781                	sext.w	a5,a5
    80001fa8:	079e                	slli	a5,a5,0x7
    80001faa:	0000f597          	auipc	a1,0xf
    80001fae:	32e58593          	addi	a1,a1,814 # 800112d8 <cpus+0x8>
    80001fb2:	95be                	add	a1,a1,a5
    80001fb4:	06848513          	addi	a0,s1,104
    80001fb8:	00000097          	auipc	ra,0x0
    80001fbc:	5aa080e7          	jalr	1450(ra) # 80002562 <swtch>
    80001fc0:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80001fc2:	2781                	sext.w	a5,a5
    80001fc4:	079e                	slli	a5,a5,0x7
    80001fc6:	97ca                	add	a5,a5,s2
    80001fc8:	0b37a623          	sw	s3,172(a5)
}
    80001fcc:	70a2                	ld	ra,40(sp)
    80001fce:	7402                	ld	s0,32(sp)
    80001fd0:	64e2                	ld	s1,24(sp)
    80001fd2:	6942                	ld	s2,16(sp)
    80001fd4:	69a2                	ld	s3,8(sp)
    80001fd6:	6145                	addi	sp,sp,48
    80001fd8:	8082                	ret
    panic("sched p->lock");
    80001fda:	00006517          	auipc	a0,0x6
    80001fde:	22650513          	addi	a0,a0,550 # 80008200 <digits+0x1c0>
    80001fe2:	ffffe097          	auipc	ra,0xffffe
    80001fe6:	54e080e7          	jalr	1358(ra) # 80000530 <panic>
    panic("sched locks");
    80001fea:	00006517          	auipc	a0,0x6
    80001fee:	22650513          	addi	a0,a0,550 # 80008210 <digits+0x1d0>
    80001ff2:	ffffe097          	auipc	ra,0xffffe
    80001ff6:	53e080e7          	jalr	1342(ra) # 80000530 <panic>
    panic("sched running");
    80001ffa:	00006517          	auipc	a0,0x6
    80001ffe:	22650513          	addi	a0,a0,550 # 80008220 <digits+0x1e0>
    80002002:	ffffe097          	auipc	ra,0xffffe
    80002006:	52e080e7          	jalr	1326(ra) # 80000530 <panic>
    panic("sched interruptible");
    8000200a:	00006517          	auipc	a0,0x6
    8000200e:	22650513          	addi	a0,a0,550 # 80008230 <digits+0x1f0>
    80002012:	ffffe097          	auipc	ra,0xffffe
    80002016:	51e080e7          	jalr	1310(ra) # 80000530 <panic>

000000008000201a <yield>:
{
    8000201a:	1101                	addi	sp,sp,-32
    8000201c:	ec06                	sd	ra,24(sp)
    8000201e:	e822                	sd	s0,16(sp)
    80002020:	e426                	sd	s1,8(sp)
    80002022:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80002024:	00000097          	auipc	ra,0x0
    80002028:	970080e7          	jalr	-1680(ra) # 80001994 <myproc>
    8000202c:	84aa                	mv	s1,a0
  acquire(&p->lock);
    8000202e:	fffff097          	auipc	ra,0xfffff
    80002032:	ba8080e7          	jalr	-1112(ra) # 80000bd6 <acquire>
  p->state = RUNNABLE;
    80002036:	478d                	li	a5,3
    80002038:	cc9c                	sw	a5,24(s1)
  sched();
    8000203a:	00000097          	auipc	ra,0x0
    8000203e:	f0a080e7          	jalr	-246(ra) # 80001f44 <sched>
  release(&p->lock);
    80002042:	8526                	mv	a0,s1
    80002044:	fffff097          	auipc	ra,0xfffff
    80002048:	c46080e7          	jalr	-954(ra) # 80000c8a <release>
}
    8000204c:	60e2                	ld	ra,24(sp)
    8000204e:	6442                	ld	s0,16(sp)
    80002050:	64a2                	ld	s1,8(sp)
    80002052:	6105                	addi	sp,sp,32
    80002054:	8082                	ret

0000000080002056 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    80002056:	7179                	addi	sp,sp,-48
    80002058:	f406                	sd	ra,40(sp)
    8000205a:	f022                	sd	s0,32(sp)
    8000205c:	ec26                	sd	s1,24(sp)
    8000205e:	e84a                	sd	s2,16(sp)
    80002060:	e44e                	sd	s3,8(sp)
    80002062:	1800                	addi	s0,sp,48
    80002064:	89aa                	mv	s3,a0
    80002066:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002068:	00000097          	auipc	ra,0x0
    8000206c:	92c080e7          	jalr	-1748(ra) # 80001994 <myproc>
    80002070:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    80002072:	fffff097          	auipc	ra,0xfffff
    80002076:	b64080e7          	jalr	-1180(ra) # 80000bd6 <acquire>
  release(lk);
    8000207a:	854a                	mv	a0,s2
    8000207c:	fffff097          	auipc	ra,0xfffff
    80002080:	c0e080e7          	jalr	-1010(ra) # 80000c8a <release>

  // Go to sleep.
  p->chan = chan;
    80002084:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    80002088:	4789                	li	a5,2
    8000208a:	cc9c                	sw	a5,24(s1)

  sched();
    8000208c:	00000097          	auipc	ra,0x0
    80002090:	eb8080e7          	jalr	-328(ra) # 80001f44 <sched>

  // Tidy up.
  p->chan = 0;
    80002094:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    80002098:	8526                	mv	a0,s1
    8000209a:	fffff097          	auipc	ra,0xfffff
    8000209e:	bf0080e7          	jalr	-1040(ra) # 80000c8a <release>
  acquire(lk);
    800020a2:	854a                	mv	a0,s2
    800020a4:	fffff097          	auipc	ra,0xfffff
    800020a8:	b32080e7          	jalr	-1230(ra) # 80000bd6 <acquire>
}
    800020ac:	70a2                	ld	ra,40(sp)
    800020ae:	7402                	ld	s0,32(sp)
    800020b0:	64e2                	ld	s1,24(sp)
    800020b2:	6942                	ld	s2,16(sp)
    800020b4:	69a2                	ld	s3,8(sp)
    800020b6:	6145                	addi	sp,sp,48
    800020b8:	8082                	ret

00000000800020ba <wait>:
{
    800020ba:	715d                	addi	sp,sp,-80
    800020bc:	e486                	sd	ra,72(sp)
    800020be:	e0a2                	sd	s0,64(sp)
    800020c0:	fc26                	sd	s1,56(sp)
    800020c2:	f84a                	sd	s2,48(sp)
    800020c4:	f44e                	sd	s3,40(sp)
    800020c6:	f052                	sd	s4,32(sp)
    800020c8:	ec56                	sd	s5,24(sp)
    800020ca:	e85a                	sd	s6,16(sp)
    800020cc:	e45e                	sd	s7,8(sp)
    800020ce:	e062                	sd	s8,0(sp)
    800020d0:	0880                	addi	s0,sp,80
    800020d2:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    800020d4:	00000097          	auipc	ra,0x0
    800020d8:	8c0080e7          	jalr	-1856(ra) # 80001994 <myproc>
    800020dc:	892a                	mv	s2,a0
  acquire(&wait_lock);
    800020de:	0000f517          	auipc	a0,0xf
    800020e2:	1da50513          	addi	a0,a0,474 # 800112b8 <wait_lock>
    800020e6:	fffff097          	auipc	ra,0xfffff
    800020ea:	af0080e7          	jalr	-1296(ra) # 80000bd6 <acquire>
    havekids = 0;
    800020ee:	4b81                	li	s7,0
        if(np->state == ZOMBIE){
    800020f0:	4a15                	li	s4,5
    for(np = proc; np < &proc[NPROC]; np++){
    800020f2:	00015997          	auipc	s3,0x15
    800020f6:	1de98993          	addi	s3,s3,478 # 800172d0 <tickslock>
        havekids = 1;
    800020fa:	4a85                	li	s5,1
    sleep(p, &wait_lock);  //DOC: wait-sleep
    800020fc:	0000fc17          	auipc	s8,0xf
    80002100:	1bcc0c13          	addi	s8,s8,444 # 800112b8 <wait_lock>
    havekids = 0;
    80002104:	875e                	mv	a4,s7
    for(np = proc; np < &proc[NPROC]; np++){
    80002106:	0000f497          	auipc	s1,0xf
    8000210a:	5ca48493          	addi	s1,s1,1482 # 800116d0 <proc>
    8000210e:	a0bd                	j	8000217c <wait+0xc2>
          pid = np->pid;
    80002110:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    80002114:	000b0e63          	beqz	s6,80002130 <wait+0x76>
    80002118:	4691                	li	a3,4
    8000211a:	02c48613          	addi	a2,s1,44
    8000211e:	85da                	mv	a1,s6
    80002120:	05893503          	ld	a0,88(s2)
    80002124:	fffff097          	auipc	ra,0xfffff
    80002128:	532080e7          	jalr	1330(ra) # 80001656 <copyout>
    8000212c:	02054563          	bltz	a0,80002156 <wait+0x9c>
          freeproc(np);
    80002130:	8526                	mv	a0,s1
    80002132:	00000097          	auipc	ra,0x0
    80002136:	a14080e7          	jalr	-1516(ra) # 80001b46 <freeproc>
          release(&np->lock);
    8000213a:	8526                	mv	a0,s1
    8000213c:	fffff097          	auipc	ra,0xfffff
    80002140:	b4e080e7          	jalr	-1202(ra) # 80000c8a <release>
          release(&wait_lock);
    80002144:	0000f517          	auipc	a0,0xf
    80002148:	17450513          	addi	a0,a0,372 # 800112b8 <wait_lock>
    8000214c:	fffff097          	auipc	ra,0xfffff
    80002150:	b3e080e7          	jalr	-1218(ra) # 80000c8a <release>
          return pid;
    80002154:	a09d                	j	800021ba <wait+0x100>
            release(&np->lock);
    80002156:	8526                	mv	a0,s1
    80002158:	fffff097          	auipc	ra,0xfffff
    8000215c:	b32080e7          	jalr	-1230(ra) # 80000c8a <release>
            release(&wait_lock);
    80002160:	0000f517          	auipc	a0,0xf
    80002164:	15850513          	addi	a0,a0,344 # 800112b8 <wait_lock>
    80002168:	fffff097          	auipc	ra,0xfffff
    8000216c:	b22080e7          	jalr	-1246(ra) # 80000c8a <release>
            return -1;
    80002170:	59fd                	li	s3,-1
    80002172:	a0a1                	j	800021ba <wait+0x100>
    for(np = proc; np < &proc[NPROC]; np++){
    80002174:	17048493          	addi	s1,s1,368
    80002178:	03348463          	beq	s1,s3,800021a0 <wait+0xe6>
      if(np->parent == p){
    8000217c:	60bc                	ld	a5,64(s1)
    8000217e:	ff279be3          	bne	a5,s2,80002174 <wait+0xba>
        acquire(&np->lock);
    80002182:	8526                	mv	a0,s1
    80002184:	fffff097          	auipc	ra,0xfffff
    80002188:	a52080e7          	jalr	-1454(ra) # 80000bd6 <acquire>
        if(np->state == ZOMBIE){
    8000218c:	4c9c                	lw	a5,24(s1)
    8000218e:	f94781e3          	beq	a5,s4,80002110 <wait+0x56>
        release(&np->lock);
    80002192:	8526                	mv	a0,s1
    80002194:	fffff097          	auipc	ra,0xfffff
    80002198:	af6080e7          	jalr	-1290(ra) # 80000c8a <release>
        havekids = 1;
    8000219c:	8756                	mv	a4,s5
    8000219e:	bfd9                	j	80002174 <wait+0xba>
    if(!havekids || p->killed){
    800021a0:	c701                	beqz	a4,800021a8 <wait+0xee>
    800021a2:	02892783          	lw	a5,40(s2)
    800021a6:	c79d                	beqz	a5,800021d4 <wait+0x11a>
      release(&wait_lock);
    800021a8:	0000f517          	auipc	a0,0xf
    800021ac:	11050513          	addi	a0,a0,272 # 800112b8 <wait_lock>
    800021b0:	fffff097          	auipc	ra,0xfffff
    800021b4:	ada080e7          	jalr	-1318(ra) # 80000c8a <release>
      return -1;
    800021b8:	59fd                	li	s3,-1
}
    800021ba:	854e                	mv	a0,s3
    800021bc:	60a6                	ld	ra,72(sp)
    800021be:	6406                	ld	s0,64(sp)
    800021c0:	74e2                	ld	s1,56(sp)
    800021c2:	7942                	ld	s2,48(sp)
    800021c4:	79a2                	ld	s3,40(sp)
    800021c6:	7a02                	ld	s4,32(sp)
    800021c8:	6ae2                	ld	s5,24(sp)
    800021ca:	6b42                	ld	s6,16(sp)
    800021cc:	6ba2                	ld	s7,8(sp)
    800021ce:	6c02                	ld	s8,0(sp)
    800021d0:	6161                	addi	sp,sp,80
    800021d2:	8082                	ret
    sleep(p, &wait_lock);  //DOC: wait-sleep
    800021d4:	85e2                	mv	a1,s8
    800021d6:	854a                	mv	a0,s2
    800021d8:	00000097          	auipc	ra,0x0
    800021dc:	e7e080e7          	jalr	-386(ra) # 80002056 <sleep>
    havekids = 0;
    800021e0:	b715                	j	80002104 <wait+0x4a>

00000000800021e2 <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void
wakeup(void *chan)
{
    800021e2:	7139                	addi	sp,sp,-64
    800021e4:	fc06                	sd	ra,56(sp)
    800021e6:	f822                	sd	s0,48(sp)
    800021e8:	f426                	sd	s1,40(sp)
    800021ea:	f04a                	sd	s2,32(sp)
    800021ec:	ec4e                	sd	s3,24(sp)
    800021ee:	e852                	sd	s4,16(sp)
    800021f0:	e456                	sd	s5,8(sp)
    800021f2:	0080                	addi	s0,sp,64
    800021f4:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    800021f6:	0000f497          	auipc	s1,0xf
    800021fa:	4da48493          	addi	s1,s1,1242 # 800116d0 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    800021fe:	4989                	li	s3,2
        p->state = RUNNABLE;
    80002200:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    80002202:	00015917          	auipc	s2,0x15
    80002206:	0ce90913          	addi	s2,s2,206 # 800172d0 <tickslock>
    8000220a:	a821                	j	80002222 <wakeup+0x40>
        p->state = RUNNABLE;
    8000220c:	0154ac23          	sw	s5,24(s1)
      }
      release(&p->lock);
    80002210:	8526                	mv	a0,s1
    80002212:	fffff097          	auipc	ra,0xfffff
    80002216:	a78080e7          	jalr	-1416(ra) # 80000c8a <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    8000221a:	17048493          	addi	s1,s1,368
    8000221e:	03248463          	beq	s1,s2,80002246 <wakeup+0x64>
    if(p != myproc()){
    80002222:	fffff097          	auipc	ra,0xfffff
    80002226:	772080e7          	jalr	1906(ra) # 80001994 <myproc>
    8000222a:	fea488e3          	beq	s1,a0,8000221a <wakeup+0x38>
      acquire(&p->lock);
    8000222e:	8526                	mv	a0,s1
    80002230:	fffff097          	auipc	ra,0xfffff
    80002234:	9a6080e7          	jalr	-1626(ra) # 80000bd6 <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    80002238:	4c9c                	lw	a5,24(s1)
    8000223a:	fd379be3          	bne	a5,s3,80002210 <wakeup+0x2e>
    8000223e:	709c                	ld	a5,32(s1)
    80002240:	fd4798e3          	bne	a5,s4,80002210 <wakeup+0x2e>
    80002244:	b7e1                	j	8000220c <wakeup+0x2a>
    }
  }
}
    80002246:	70e2                	ld	ra,56(sp)
    80002248:	7442                	ld	s0,48(sp)
    8000224a:	74a2                	ld	s1,40(sp)
    8000224c:	7902                	ld	s2,32(sp)
    8000224e:	69e2                	ld	s3,24(sp)
    80002250:	6a42                	ld	s4,16(sp)
    80002252:	6aa2                	ld	s5,8(sp)
    80002254:	6121                	addi	sp,sp,64
    80002256:	8082                	ret

0000000080002258 <reparent>:
{
    80002258:	7179                	addi	sp,sp,-48
    8000225a:	f406                	sd	ra,40(sp)
    8000225c:	f022                	sd	s0,32(sp)
    8000225e:	ec26                	sd	s1,24(sp)
    80002260:	e84a                	sd	s2,16(sp)
    80002262:	e44e                	sd	s3,8(sp)
    80002264:	e052                	sd	s4,0(sp)
    80002266:	1800                	addi	s0,sp,48
    80002268:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    8000226a:	0000f497          	auipc	s1,0xf
    8000226e:	46648493          	addi	s1,s1,1126 # 800116d0 <proc>
      pp->parent = initproc;
    80002272:	00007a17          	auipc	s4,0x7
    80002276:	db6a0a13          	addi	s4,s4,-586 # 80009028 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    8000227a:	00015997          	auipc	s3,0x15
    8000227e:	05698993          	addi	s3,s3,86 # 800172d0 <tickslock>
    80002282:	a029                	j	8000228c <reparent+0x34>
    80002284:	17048493          	addi	s1,s1,368
    80002288:	01348d63          	beq	s1,s3,800022a2 <reparent+0x4a>
    if(pp->parent == p){
    8000228c:	60bc                	ld	a5,64(s1)
    8000228e:	ff279be3          	bne	a5,s2,80002284 <reparent+0x2c>
      pp->parent = initproc;
    80002292:	000a3503          	ld	a0,0(s4)
    80002296:	e0a8                	sd	a0,64(s1)
      wakeup(initproc);
    80002298:	00000097          	auipc	ra,0x0
    8000229c:	f4a080e7          	jalr	-182(ra) # 800021e2 <wakeup>
    800022a0:	b7d5                	j	80002284 <reparent+0x2c>
}
    800022a2:	70a2                	ld	ra,40(sp)
    800022a4:	7402                	ld	s0,32(sp)
    800022a6:	64e2                	ld	s1,24(sp)
    800022a8:	6942                	ld	s2,16(sp)
    800022aa:	69a2                	ld	s3,8(sp)
    800022ac:	6a02                	ld	s4,0(sp)
    800022ae:	6145                	addi	sp,sp,48
    800022b0:	8082                	ret

00000000800022b2 <exit>:
{
    800022b2:	7179                	addi	sp,sp,-48
    800022b4:	f406                	sd	ra,40(sp)
    800022b6:	f022                	sd	s0,32(sp)
    800022b8:	ec26                	sd	s1,24(sp)
    800022ba:	e84a                	sd	s2,16(sp)
    800022bc:	e44e                	sd	s3,8(sp)
    800022be:	e052                	sd	s4,0(sp)
    800022c0:	1800                	addi	s0,sp,48
    800022c2:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    800022c4:	fffff097          	auipc	ra,0xfffff
    800022c8:	6d0080e7          	jalr	1744(ra) # 80001994 <myproc>
    800022cc:	89aa                	mv	s3,a0
  if(p == initproc)
    800022ce:	00007797          	auipc	a5,0x7
    800022d2:	d5a7b783          	ld	a5,-678(a5) # 80009028 <initproc>
    800022d6:	0d850493          	addi	s1,a0,216
    800022da:	15850913          	addi	s2,a0,344
    800022de:	02a79363          	bne	a5,a0,80002304 <exit+0x52>
    panic("init exiting");
    800022e2:	00006517          	auipc	a0,0x6
    800022e6:	f6650513          	addi	a0,a0,-154 # 80008248 <digits+0x208>
    800022ea:	ffffe097          	auipc	ra,0xffffe
    800022ee:	246080e7          	jalr	582(ra) # 80000530 <panic>
      fileclose(f);
    800022f2:	00002097          	auipc	ra,0x2
    800022f6:	172080e7          	jalr	370(ra) # 80004464 <fileclose>
      p->ofile[fd] = 0;
    800022fa:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    800022fe:	04a1                	addi	s1,s1,8
    80002300:	01248563          	beq	s1,s2,8000230a <exit+0x58>
    if(p->ofile[fd]){
    80002304:	6088                	ld	a0,0(s1)
    80002306:	f575                	bnez	a0,800022f2 <exit+0x40>
    80002308:	bfdd                	j	800022fe <exit+0x4c>
  begin_op();
    8000230a:	00002097          	auipc	ra,0x2
    8000230e:	c8e080e7          	jalr	-882(ra) # 80003f98 <begin_op>
  iput(p->cwd);
    80002312:	1589b503          	ld	a0,344(s3)
    80002316:	00001097          	auipc	ra,0x1
    8000231a:	46a080e7          	jalr	1130(ra) # 80003780 <iput>
  end_op();
    8000231e:	00002097          	auipc	ra,0x2
    80002322:	cfa080e7          	jalr	-774(ra) # 80004018 <end_op>
  p->cwd = 0;
    80002326:	1409bc23          	sd	zero,344(s3)
  acquire(&wait_lock);
    8000232a:	0000f497          	auipc	s1,0xf
    8000232e:	f8e48493          	addi	s1,s1,-114 # 800112b8 <wait_lock>
    80002332:	8526                	mv	a0,s1
    80002334:	fffff097          	auipc	ra,0xfffff
    80002338:	8a2080e7          	jalr	-1886(ra) # 80000bd6 <acquire>
  reparent(p);
    8000233c:	854e                	mv	a0,s3
    8000233e:	00000097          	auipc	ra,0x0
    80002342:	f1a080e7          	jalr	-230(ra) # 80002258 <reparent>
  wakeup(p->parent);
    80002346:	0409b503          	ld	a0,64(s3)
    8000234a:	00000097          	auipc	ra,0x0
    8000234e:	e98080e7          	jalr	-360(ra) # 800021e2 <wakeup>
  acquire(&p->lock);
    80002352:	854e                	mv	a0,s3
    80002354:	fffff097          	auipc	ra,0xfffff
    80002358:	882080e7          	jalr	-1918(ra) # 80000bd6 <acquire>
  p->xstate = status;
    8000235c:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    80002360:	4795                	li	a5,5
    80002362:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    80002366:	8526                	mv	a0,s1
    80002368:	fffff097          	auipc	ra,0xfffff
    8000236c:	922080e7          	jalr	-1758(ra) # 80000c8a <release>
  sched();
    80002370:	00000097          	auipc	ra,0x0
    80002374:	bd4080e7          	jalr	-1068(ra) # 80001f44 <sched>
  panic("zombie exit");
    80002378:	00006517          	auipc	a0,0x6
    8000237c:	ee050513          	addi	a0,a0,-288 # 80008258 <digits+0x218>
    80002380:	ffffe097          	auipc	ra,0xffffe
    80002384:	1b0080e7          	jalr	432(ra) # 80000530 <panic>

0000000080002388 <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    80002388:	7179                	addi	sp,sp,-48
    8000238a:	f406                	sd	ra,40(sp)
    8000238c:	f022                	sd	s0,32(sp)
    8000238e:	ec26                	sd	s1,24(sp)
    80002390:	e84a                	sd	s2,16(sp)
    80002392:	e44e                	sd	s3,8(sp)
    80002394:	1800                	addi	s0,sp,48
    80002396:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    80002398:	0000f497          	auipc	s1,0xf
    8000239c:	33848493          	addi	s1,s1,824 # 800116d0 <proc>
    800023a0:	00015997          	auipc	s3,0x15
    800023a4:	f3098993          	addi	s3,s3,-208 # 800172d0 <tickslock>
    acquire(&p->lock);
    800023a8:	8526                	mv	a0,s1
    800023aa:	fffff097          	auipc	ra,0xfffff
    800023ae:	82c080e7          	jalr	-2004(ra) # 80000bd6 <acquire>
    if(p->pid == pid){
    800023b2:	589c                	lw	a5,48(s1)
    800023b4:	01278d63          	beq	a5,s2,800023ce <kill+0x46>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    800023b8:	8526                	mv	a0,s1
    800023ba:	fffff097          	auipc	ra,0xfffff
    800023be:	8d0080e7          	jalr	-1840(ra) # 80000c8a <release>
  for(p = proc; p < &proc[NPROC]; p++){
    800023c2:	17048493          	addi	s1,s1,368
    800023c6:	ff3491e3          	bne	s1,s3,800023a8 <kill+0x20>
  }
  return -1;
    800023ca:	557d                	li	a0,-1
    800023cc:	a829                	j	800023e6 <kill+0x5e>
      p->killed = 1;
    800023ce:	4785                	li	a5,1
    800023d0:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    800023d2:	4c98                	lw	a4,24(s1)
    800023d4:	4789                	li	a5,2
    800023d6:	00f70f63          	beq	a4,a5,800023f4 <kill+0x6c>
      release(&p->lock);
    800023da:	8526                	mv	a0,s1
    800023dc:	fffff097          	auipc	ra,0xfffff
    800023e0:	8ae080e7          	jalr	-1874(ra) # 80000c8a <release>
      return 0;
    800023e4:	4501                	li	a0,0
}
    800023e6:	70a2                	ld	ra,40(sp)
    800023e8:	7402                	ld	s0,32(sp)
    800023ea:	64e2                	ld	s1,24(sp)
    800023ec:	6942                	ld	s2,16(sp)
    800023ee:	69a2                	ld	s3,8(sp)
    800023f0:	6145                	addi	sp,sp,48
    800023f2:	8082                	ret
        p->state = RUNNABLE;
    800023f4:	478d                	li	a5,3
    800023f6:	cc9c                	sw	a5,24(s1)
    800023f8:	b7cd                	j	800023da <kill+0x52>

00000000800023fa <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    800023fa:	7179                	addi	sp,sp,-48
    800023fc:	f406                	sd	ra,40(sp)
    800023fe:	f022                	sd	s0,32(sp)
    80002400:	ec26                	sd	s1,24(sp)
    80002402:	e84a                	sd	s2,16(sp)
    80002404:	e44e                	sd	s3,8(sp)
    80002406:	e052                	sd	s4,0(sp)
    80002408:	1800                	addi	s0,sp,48
    8000240a:	84aa                	mv	s1,a0
    8000240c:	892e                	mv	s2,a1
    8000240e:	89b2                	mv	s3,a2
    80002410:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002412:	fffff097          	auipc	ra,0xfffff
    80002416:	582080e7          	jalr	1410(ra) # 80001994 <myproc>
  if(user_dst){
    8000241a:	c08d                	beqz	s1,8000243c <either_copyout+0x42>
    return copyout(p->pagetable, dst, src, len);
    8000241c:	86d2                	mv	a3,s4
    8000241e:	864e                	mv	a2,s3
    80002420:	85ca                	mv	a1,s2
    80002422:	6d28                	ld	a0,88(a0)
    80002424:	fffff097          	auipc	ra,0xfffff
    80002428:	232080e7          	jalr	562(ra) # 80001656 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    8000242c:	70a2                	ld	ra,40(sp)
    8000242e:	7402                	ld	s0,32(sp)
    80002430:	64e2                	ld	s1,24(sp)
    80002432:	6942                	ld	s2,16(sp)
    80002434:	69a2                	ld	s3,8(sp)
    80002436:	6a02                	ld	s4,0(sp)
    80002438:	6145                	addi	sp,sp,48
    8000243a:	8082                	ret
    memmove((char *)dst, src, len);
    8000243c:	000a061b          	sext.w	a2,s4
    80002440:	85ce                	mv	a1,s3
    80002442:	854a                	mv	a0,s2
    80002444:	fffff097          	auipc	ra,0xfffff
    80002448:	8ee080e7          	jalr	-1810(ra) # 80000d32 <memmove>
    return 0;
    8000244c:	8526                	mv	a0,s1
    8000244e:	bff9                	j	8000242c <either_copyout+0x32>

0000000080002450 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    80002450:	7179                	addi	sp,sp,-48
    80002452:	f406                	sd	ra,40(sp)
    80002454:	f022                	sd	s0,32(sp)
    80002456:	ec26                	sd	s1,24(sp)
    80002458:	e84a                	sd	s2,16(sp)
    8000245a:	e44e                	sd	s3,8(sp)
    8000245c:	e052                	sd	s4,0(sp)
    8000245e:	1800                	addi	s0,sp,48
    80002460:	892a                	mv	s2,a0
    80002462:	84ae                	mv	s1,a1
    80002464:	89b2                	mv	s3,a2
    80002466:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002468:	fffff097          	auipc	ra,0xfffff
    8000246c:	52c080e7          	jalr	1324(ra) # 80001994 <myproc>
  if(user_src){
    80002470:	c08d                	beqz	s1,80002492 <either_copyin+0x42>
    return copyin(p->pagetable, dst, src, len);
    80002472:	86d2                	mv	a3,s4
    80002474:	864e                	mv	a2,s3
    80002476:	85ca                	mv	a1,s2
    80002478:	6d28                	ld	a0,88(a0)
    8000247a:	fffff097          	auipc	ra,0xfffff
    8000247e:	268080e7          	jalr	616(ra) # 800016e2 <copyin>
  } else {
    memmove(dst, (char*)src, len);
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
    memmove(dst, (char*)src, len);
    80002492:	000a061b          	sext.w	a2,s4
    80002496:	85ce                	mv	a1,s3
    80002498:	854a                	mv	a0,s2
    8000249a:	fffff097          	auipc	ra,0xfffff
    8000249e:	898080e7          	jalr	-1896(ra) # 80000d32 <memmove>
    return 0;
    800024a2:	8526                	mv	a0,s1
    800024a4:	bff9                	j	80002482 <either_copyin+0x32>

00000000800024a6 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    800024a6:	715d                	addi	sp,sp,-80
    800024a8:	e486                	sd	ra,72(sp)
    800024aa:	e0a2                	sd	s0,64(sp)
    800024ac:	fc26                	sd	s1,56(sp)
    800024ae:	f84a                	sd	s2,48(sp)
    800024b0:	f44e                	sd	s3,40(sp)
    800024b2:	f052                	sd	s4,32(sp)
    800024b4:	ec56                	sd	s5,24(sp)
    800024b6:	e85a                	sd	s6,16(sp)
    800024b8:	e45e                	sd	s7,8(sp)
    800024ba:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    800024bc:	00006517          	auipc	a0,0x6
    800024c0:	c0c50513          	addi	a0,a0,-1012 # 800080c8 <digits+0x88>
    800024c4:	ffffe097          	auipc	ra,0xffffe
    800024c8:	0b6080e7          	jalr	182(ra) # 8000057a <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800024cc:	0000f497          	auipc	s1,0xf
    800024d0:	36448493          	addi	s1,s1,868 # 80011830 <proc+0x160>
    800024d4:	00015917          	auipc	s2,0x15
    800024d8:	f5c90913          	addi	s2,s2,-164 # 80017430 <bcache+0x148>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800024dc:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    800024de:	00006997          	auipc	s3,0x6
    800024e2:	d8a98993          	addi	s3,s3,-630 # 80008268 <digits+0x228>
    printf("%d %s %s", p->pid, state, p->name);
    800024e6:	00006a97          	auipc	s5,0x6
    800024ea:	d8aa8a93          	addi	s5,s5,-630 # 80008270 <digits+0x230>
    printf("\n");
    800024ee:	00006a17          	auipc	s4,0x6
    800024f2:	bdaa0a13          	addi	s4,s4,-1062 # 800080c8 <digits+0x88>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800024f6:	00006b97          	auipc	s7,0x6
    800024fa:	db2b8b93          	addi	s7,s7,-590 # 800082a8 <states.1722>
    800024fe:	a00d                	j	80002520 <procdump+0x7a>
    printf("%d %s %s", p->pid, state, p->name);
    80002500:	ed06a583          	lw	a1,-304(a3)
    80002504:	8556                	mv	a0,s5
    80002506:	ffffe097          	auipc	ra,0xffffe
    8000250a:	074080e7          	jalr	116(ra) # 8000057a <printf>
    printf("\n");
    8000250e:	8552                	mv	a0,s4
    80002510:	ffffe097          	auipc	ra,0xffffe
    80002514:	06a080e7          	jalr	106(ra) # 8000057a <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002518:	17048493          	addi	s1,s1,368
    8000251c:	03248163          	beq	s1,s2,8000253e <procdump+0x98>
    if(p->state == UNUSED)
    80002520:	86a6                	mv	a3,s1
    80002522:	eb84a783          	lw	a5,-328(s1)
    80002526:	dbed                	beqz	a5,80002518 <procdump+0x72>
      state = "???";
    80002528:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000252a:	fcfb6be3          	bltu	s6,a5,80002500 <procdump+0x5a>
    8000252e:	1782                	slli	a5,a5,0x20
    80002530:	9381                	srli	a5,a5,0x20
    80002532:	078e                	slli	a5,a5,0x3
    80002534:	97de                	add	a5,a5,s7
    80002536:	6390                	ld	a2,0(a5)
    80002538:	f661                	bnez	a2,80002500 <procdump+0x5a>
      state = "???";
    8000253a:	864e                	mv	a2,s3
    8000253c:	b7d1                	j	80002500 <procdump+0x5a>
  }
}
    8000253e:	60a6                	ld	ra,72(sp)
    80002540:	6406                	ld	s0,64(sp)
    80002542:	74e2                	ld	s1,56(sp)
    80002544:	7942                	ld	s2,48(sp)
    80002546:	79a2                	ld	s3,40(sp)
    80002548:	7a02                	ld	s4,32(sp)
    8000254a:	6ae2                	ld	s5,24(sp)
    8000254c:	6b42                	ld	s6,16(sp)
    8000254e:	6ba2                	ld	s7,8(sp)
    80002550:	6161                	addi	sp,sp,80
    80002552:	8082                	ret

0000000080002554 <ps>:

uint64 ps(struct ps_proc* procs) {
    80002554:	1141                	addi	sp,sp,-16
    80002556:	e422                	sd	s0,8(sp)
    80002558:	0800                	addi	s0,sp,16
  return 0;
    8000255a:	4501                	li	a0,0
    8000255c:	6422                	ld	s0,8(sp)
    8000255e:	0141                	addi	sp,sp,16
    80002560:	8082                	ret

0000000080002562 <swtch>:
    80002562:	00153023          	sd	ra,0(a0)
    80002566:	00253423          	sd	sp,8(a0)
    8000256a:	e900                	sd	s0,16(a0)
    8000256c:	ed04                	sd	s1,24(a0)
    8000256e:	03253023          	sd	s2,32(a0)
    80002572:	03353423          	sd	s3,40(a0)
    80002576:	03453823          	sd	s4,48(a0)
    8000257a:	03553c23          	sd	s5,56(a0)
    8000257e:	05653023          	sd	s6,64(a0)
    80002582:	05753423          	sd	s7,72(a0)
    80002586:	05853823          	sd	s8,80(a0)
    8000258a:	05953c23          	sd	s9,88(a0)
    8000258e:	07a53023          	sd	s10,96(a0)
    80002592:	07b53423          	sd	s11,104(a0)
    80002596:	0005b083          	ld	ra,0(a1)
    8000259a:	0085b103          	ld	sp,8(a1)
    8000259e:	6980                	ld	s0,16(a1)
    800025a0:	6d84                	ld	s1,24(a1)
    800025a2:	0205b903          	ld	s2,32(a1)
    800025a6:	0285b983          	ld	s3,40(a1)
    800025aa:	0305ba03          	ld	s4,48(a1)
    800025ae:	0385ba83          	ld	s5,56(a1)
    800025b2:	0405bb03          	ld	s6,64(a1)
    800025b6:	0485bb83          	ld	s7,72(a1)
    800025ba:	0505bc03          	ld	s8,80(a1)
    800025be:	0585bc83          	ld	s9,88(a1)
    800025c2:	0605bd03          	ld	s10,96(a1)
    800025c6:	0685bd83          	ld	s11,104(a1)
    800025ca:	8082                	ret

00000000800025cc <trapinit>:

extern int devintr();

void
trapinit(void)
{
    800025cc:	1141                	addi	sp,sp,-16
    800025ce:	e406                	sd	ra,8(sp)
    800025d0:	e022                	sd	s0,0(sp)
    800025d2:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    800025d4:	00006597          	auipc	a1,0x6
    800025d8:	d0458593          	addi	a1,a1,-764 # 800082d8 <states.1722+0x30>
    800025dc:	00015517          	auipc	a0,0x15
    800025e0:	cf450513          	addi	a0,a0,-780 # 800172d0 <tickslock>
    800025e4:	ffffe097          	auipc	ra,0xffffe
    800025e8:	562080e7          	jalr	1378(ra) # 80000b46 <initlock>
}
    800025ec:	60a2                	ld	ra,8(sp)
    800025ee:	6402                	ld	s0,0(sp)
    800025f0:	0141                	addi	sp,sp,16
    800025f2:	8082                	ret

00000000800025f4 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    800025f4:	1141                	addi	sp,sp,-16
    800025f6:	e422                	sd	s0,8(sp)
    800025f8:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    800025fa:	00003797          	auipc	a5,0x3
    800025fe:	48678793          	addi	a5,a5,1158 # 80005a80 <kernelvec>
    80002602:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80002606:	6422                	ld	s0,8(sp)
    80002608:	0141                	addi	sp,sp,16
    8000260a:	8082                	ret

000000008000260c <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    8000260c:	1141                	addi	sp,sp,-16
    8000260e:	e406                	sd	ra,8(sp)
    80002610:	e022                	sd	s0,0(sp)
    80002612:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002614:	fffff097          	auipc	ra,0xfffff
    80002618:	380080e7          	jalr	896(ra) # 80001994 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000261c:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002620:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002622:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to trampoline.S
  w_stvec(TRAMPOLINE + (uservec - trampoline));
    80002626:	00005617          	auipc	a2,0x5
    8000262a:	9da60613          	addi	a2,a2,-1574 # 80007000 <_trampoline>
    8000262e:	00005697          	auipc	a3,0x5
    80002632:	9d268693          	addi	a3,a3,-1582 # 80007000 <_trampoline>
    80002636:	8e91                	sub	a3,a3,a2
    80002638:	040007b7          	lui	a5,0x4000
    8000263c:	17fd                	addi	a5,a5,-1
    8000263e:	07b2                	slli	a5,a5,0xc
    80002640:	96be                	add	a3,a3,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002642:	10569073          	csrw	stvec,a3

  // set up trapframe values that uservec will need when
  // the process next re-enters the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80002646:	7138                	ld	a4,96(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80002648:	180026f3          	csrr	a3,satp
    8000264c:	e314                	sd	a3,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    8000264e:	7138                	ld	a4,96(a0)
    80002650:	6534                	ld	a3,72(a0)
    80002652:	6585                	lui	a1,0x1
    80002654:	96ae                	add	a3,a3,a1
    80002656:	e714                	sd	a3,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80002658:	7138                	ld	a4,96(a0)
    8000265a:	00000697          	auipc	a3,0x0
    8000265e:	13868693          	addi	a3,a3,312 # 80002792 <usertrap>
    80002662:	eb14                	sd	a3,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    80002664:	7138                	ld	a4,96(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80002666:	8692                	mv	a3,tp
    80002668:	f314                	sd	a3,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000266a:	100026f3          	csrr	a3,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    8000266e:	eff6f693          	andi	a3,a3,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002672:	0206e693          	ori	a3,a3,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002676:	10069073          	csrw	sstatus,a3
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    8000267a:	7138                	ld	a4,96(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    8000267c:	6f18                	ld	a4,24(a4)
    8000267e:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    80002682:	6d2c                	ld	a1,88(a0)
    80002684:	81b1                	srli	a1,a1,0xc

  // jump to trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 fn = TRAMPOLINE + (userret - trampoline);
    80002686:	00005717          	auipc	a4,0x5
    8000268a:	a0a70713          	addi	a4,a4,-1526 # 80007090 <userret>
    8000268e:	8f11                	sub	a4,a4,a2
    80002690:	97ba                	add	a5,a5,a4
  ((void (*)(uint64,uint64))fn)(TRAPFRAME, satp);
    80002692:	577d                	li	a4,-1
    80002694:	177e                	slli	a4,a4,0x3f
    80002696:	8dd9                	or	a1,a1,a4
    80002698:	02000537          	lui	a0,0x2000
    8000269c:	157d                	addi	a0,a0,-1
    8000269e:	0536                	slli	a0,a0,0xd
    800026a0:	9782                	jalr	a5
}
    800026a2:	60a2                	ld	ra,8(sp)
    800026a4:	6402                	ld	s0,0(sp)
    800026a6:	0141                	addi	sp,sp,16
    800026a8:	8082                	ret

00000000800026aa <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    800026aa:	1101                	addi	sp,sp,-32
    800026ac:	ec06                	sd	ra,24(sp)
    800026ae:	e822                	sd	s0,16(sp)
    800026b0:	e426                	sd	s1,8(sp)
    800026b2:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    800026b4:	00015497          	auipc	s1,0x15
    800026b8:	c1c48493          	addi	s1,s1,-996 # 800172d0 <tickslock>
    800026bc:	8526                	mv	a0,s1
    800026be:	ffffe097          	auipc	ra,0xffffe
    800026c2:	518080e7          	jalr	1304(ra) # 80000bd6 <acquire>
  ticks++;
    800026c6:	00007517          	auipc	a0,0x7
    800026ca:	96a50513          	addi	a0,a0,-1686 # 80009030 <ticks>
    800026ce:	411c                	lw	a5,0(a0)
    800026d0:	2785                	addiw	a5,a5,1
    800026d2:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    800026d4:	00000097          	auipc	ra,0x0
    800026d8:	b0e080e7          	jalr	-1266(ra) # 800021e2 <wakeup>
  release(&tickslock);
    800026dc:	8526                	mv	a0,s1
    800026de:	ffffe097          	auipc	ra,0xffffe
    800026e2:	5ac080e7          	jalr	1452(ra) # 80000c8a <release>
}
    800026e6:	60e2                	ld	ra,24(sp)
    800026e8:	6442                	ld	s0,16(sp)
    800026ea:	64a2                	ld	s1,8(sp)
    800026ec:	6105                	addi	sp,sp,32
    800026ee:	8082                	ret

00000000800026f0 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    800026f0:	1101                	addi	sp,sp,-32
    800026f2:	ec06                	sd	ra,24(sp)
    800026f4:	e822                	sd	s0,16(sp)
    800026f6:	e426                	sd	s1,8(sp)
    800026f8:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    800026fa:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if((scause & 0x8000000000000000L) &&
    800026fe:	00074d63          	bltz	a4,80002718 <devintr+0x28>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000001L){
    80002702:	57fd                	li	a5,-1
    80002704:	17fe                	slli	a5,a5,0x3f
    80002706:	0785                	addi	a5,a5,1
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    80002708:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    8000270a:	06f70363          	beq	a4,a5,80002770 <devintr+0x80>
  }
}
    8000270e:	60e2                	ld	ra,24(sp)
    80002710:	6442                	ld	s0,16(sp)
    80002712:	64a2                	ld	s1,8(sp)
    80002714:	6105                	addi	sp,sp,32
    80002716:	8082                	ret
     (scause & 0xff) == 9){
    80002718:	0ff77793          	andi	a5,a4,255
  if((scause & 0x8000000000000000L) &&
    8000271c:	46a5                	li	a3,9
    8000271e:	fed792e3          	bne	a5,a3,80002702 <devintr+0x12>
    int irq = plic_claim();
    80002722:	00003097          	auipc	ra,0x3
    80002726:	466080e7          	jalr	1126(ra) # 80005b88 <plic_claim>
    8000272a:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    8000272c:	47a9                	li	a5,10
    8000272e:	02f50763          	beq	a0,a5,8000275c <devintr+0x6c>
    } else if(irq == VIRTIO0_IRQ){
    80002732:	4785                	li	a5,1
    80002734:	02f50963          	beq	a0,a5,80002766 <devintr+0x76>
    return 1;
    80002738:	4505                	li	a0,1
    } else if(irq){
    8000273a:	d8f1                	beqz	s1,8000270e <devintr+0x1e>
      printf("unexpected interrupt irq=%d\n", irq);
    8000273c:	85a6                	mv	a1,s1
    8000273e:	00006517          	auipc	a0,0x6
    80002742:	ba250513          	addi	a0,a0,-1118 # 800082e0 <states.1722+0x38>
    80002746:	ffffe097          	auipc	ra,0xffffe
    8000274a:	e34080e7          	jalr	-460(ra) # 8000057a <printf>
      plic_complete(irq);
    8000274e:	8526                	mv	a0,s1
    80002750:	00003097          	auipc	ra,0x3
    80002754:	45c080e7          	jalr	1116(ra) # 80005bac <plic_complete>
    return 1;
    80002758:	4505                	li	a0,1
    8000275a:	bf55                	j	8000270e <devintr+0x1e>
      uartintr();
    8000275c:	ffffe097          	auipc	ra,0xffffe
    80002760:	23e080e7          	jalr	574(ra) # 8000099a <uartintr>
    80002764:	b7ed                	j	8000274e <devintr+0x5e>
      virtio_disk_intr();
    80002766:	00004097          	auipc	ra,0x4
    8000276a:	926080e7          	jalr	-1754(ra) # 8000608c <virtio_disk_intr>
    8000276e:	b7c5                	j	8000274e <devintr+0x5e>
    if(cpuid() == 0){
    80002770:	fffff097          	auipc	ra,0xfffff
    80002774:	1f8080e7          	jalr	504(ra) # 80001968 <cpuid>
    80002778:	c901                	beqz	a0,80002788 <devintr+0x98>
  asm volatile("csrr %0, sip" : "=r" (x) );
    8000277a:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    8000277e:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    80002780:	14479073          	csrw	sip,a5
    return 2;
    80002784:	4509                	li	a0,2
    80002786:	b761                	j	8000270e <devintr+0x1e>
      clockintr();
    80002788:	00000097          	auipc	ra,0x0
    8000278c:	f22080e7          	jalr	-222(ra) # 800026aa <clockintr>
    80002790:	b7ed                	j	8000277a <devintr+0x8a>

0000000080002792 <usertrap>:
{
    80002792:	1101                	addi	sp,sp,-32
    80002794:	ec06                	sd	ra,24(sp)
    80002796:	e822                	sd	s0,16(sp)
    80002798:	e426                	sd	s1,8(sp)
    8000279a:	e04a                	sd	s2,0(sp)
    8000279c:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000279e:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    800027a2:	1007f793          	andi	a5,a5,256
    800027a6:	e3ad                	bnez	a5,80002808 <usertrap+0x76>
  asm volatile("csrw stvec, %0" : : "r" (x));
    800027a8:	00003797          	auipc	a5,0x3
    800027ac:	2d878793          	addi	a5,a5,728 # 80005a80 <kernelvec>
    800027b0:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    800027b4:	fffff097          	auipc	ra,0xfffff
    800027b8:	1e0080e7          	jalr	480(ra) # 80001994 <myproc>
    800027bc:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    800027be:	713c                	ld	a5,96(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800027c0:	14102773          	csrr	a4,sepc
    800027c4:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    800027c6:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    800027ca:	47a1                	li	a5,8
    800027cc:	04f71c63          	bne	a4,a5,80002824 <usertrap+0x92>
    if(p->killed)
    800027d0:	551c                	lw	a5,40(a0)
    800027d2:	e3b9                	bnez	a5,80002818 <usertrap+0x86>
    p->trapframe->epc += 4;
    800027d4:	70b8                	ld	a4,96(s1)
    800027d6:	6f1c                	ld	a5,24(a4)
    800027d8:	0791                	addi	a5,a5,4
    800027da:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800027dc:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    800027e0:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800027e4:	10079073          	csrw	sstatus,a5
    syscall();
    800027e8:	00000097          	auipc	ra,0x0
    800027ec:	2e0080e7          	jalr	736(ra) # 80002ac8 <syscall>
  if(p->killed)
    800027f0:	549c                	lw	a5,40(s1)
    800027f2:	ebc1                	bnez	a5,80002882 <usertrap+0xf0>
  usertrapret();
    800027f4:	00000097          	auipc	ra,0x0
    800027f8:	e18080e7          	jalr	-488(ra) # 8000260c <usertrapret>
}
    800027fc:	60e2                	ld	ra,24(sp)
    800027fe:	6442                	ld	s0,16(sp)
    80002800:	64a2                	ld	s1,8(sp)
    80002802:	6902                	ld	s2,0(sp)
    80002804:	6105                	addi	sp,sp,32
    80002806:	8082                	ret
    panic("usertrap: not from user mode");
    80002808:	00006517          	auipc	a0,0x6
    8000280c:	af850513          	addi	a0,a0,-1288 # 80008300 <states.1722+0x58>
    80002810:	ffffe097          	auipc	ra,0xffffe
    80002814:	d20080e7          	jalr	-736(ra) # 80000530 <panic>
      exit(-1);
    80002818:	557d                	li	a0,-1
    8000281a:	00000097          	auipc	ra,0x0
    8000281e:	a98080e7          	jalr	-1384(ra) # 800022b2 <exit>
    80002822:	bf4d                	j	800027d4 <usertrap+0x42>
  } else if((which_dev = devintr()) != 0){
    80002824:	00000097          	auipc	ra,0x0
    80002828:	ecc080e7          	jalr	-308(ra) # 800026f0 <devintr>
    8000282c:	892a                	mv	s2,a0
    8000282e:	c501                	beqz	a0,80002836 <usertrap+0xa4>
  if(p->killed)
    80002830:	549c                	lw	a5,40(s1)
    80002832:	c3a1                	beqz	a5,80002872 <usertrap+0xe0>
    80002834:	a815                	j	80002868 <usertrap+0xd6>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002836:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    8000283a:	5890                	lw	a2,48(s1)
    8000283c:	00006517          	auipc	a0,0x6
    80002840:	ae450513          	addi	a0,a0,-1308 # 80008320 <states.1722+0x78>
    80002844:	ffffe097          	auipc	ra,0xffffe
    80002848:	d36080e7          	jalr	-714(ra) # 8000057a <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    8000284c:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002850:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002854:	00006517          	auipc	a0,0x6
    80002858:	afc50513          	addi	a0,a0,-1284 # 80008350 <states.1722+0xa8>
    8000285c:	ffffe097          	auipc	ra,0xffffe
    80002860:	d1e080e7          	jalr	-738(ra) # 8000057a <printf>
    p->killed = 1;
    80002864:	4785                	li	a5,1
    80002866:	d49c                	sw	a5,40(s1)
    exit(-1);
    80002868:	557d                	li	a0,-1
    8000286a:	00000097          	auipc	ra,0x0
    8000286e:	a48080e7          	jalr	-1464(ra) # 800022b2 <exit>
  if(which_dev == 2)
    80002872:	4789                	li	a5,2
    80002874:	f8f910e3          	bne	s2,a5,800027f4 <usertrap+0x62>
    yield();
    80002878:	fffff097          	auipc	ra,0xfffff
    8000287c:	7a2080e7          	jalr	1954(ra) # 8000201a <yield>
    80002880:	bf95                	j	800027f4 <usertrap+0x62>
  int which_dev = 0;
    80002882:	4901                	li	s2,0
    80002884:	b7d5                	j	80002868 <usertrap+0xd6>

0000000080002886 <kerneltrap>:
{
    80002886:	7179                	addi	sp,sp,-48
    80002888:	f406                	sd	ra,40(sp)
    8000288a:	f022                	sd	s0,32(sp)
    8000288c:	ec26                	sd	s1,24(sp)
    8000288e:	e84a                	sd	s2,16(sp)
    80002890:	e44e                	sd	s3,8(sp)
    80002892:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002894:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002898:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    8000289c:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    800028a0:	1004f793          	andi	a5,s1,256
    800028a4:	cb85                	beqz	a5,800028d4 <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800028a6:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    800028aa:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    800028ac:	ef85                	bnez	a5,800028e4 <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    800028ae:	00000097          	auipc	ra,0x0
    800028b2:	e42080e7          	jalr	-446(ra) # 800026f0 <devintr>
    800028b6:	cd1d                	beqz	a0,800028f4 <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    800028b8:	4789                	li	a5,2
    800028ba:	06f50a63          	beq	a0,a5,8000292e <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    800028be:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800028c2:	10049073          	csrw	sstatus,s1
}
    800028c6:	70a2                	ld	ra,40(sp)
    800028c8:	7402                	ld	s0,32(sp)
    800028ca:	64e2                	ld	s1,24(sp)
    800028cc:	6942                	ld	s2,16(sp)
    800028ce:	69a2                	ld	s3,8(sp)
    800028d0:	6145                	addi	sp,sp,48
    800028d2:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    800028d4:	00006517          	auipc	a0,0x6
    800028d8:	a9c50513          	addi	a0,a0,-1380 # 80008370 <states.1722+0xc8>
    800028dc:	ffffe097          	auipc	ra,0xffffe
    800028e0:	c54080e7          	jalr	-940(ra) # 80000530 <panic>
    panic("kerneltrap: interrupts enabled");
    800028e4:	00006517          	auipc	a0,0x6
    800028e8:	ab450513          	addi	a0,a0,-1356 # 80008398 <states.1722+0xf0>
    800028ec:	ffffe097          	auipc	ra,0xffffe
    800028f0:	c44080e7          	jalr	-956(ra) # 80000530 <panic>
    printf("scause %p\n", scause);
    800028f4:	85ce                	mv	a1,s3
    800028f6:	00006517          	auipc	a0,0x6
    800028fa:	ac250513          	addi	a0,a0,-1342 # 800083b8 <states.1722+0x110>
    800028fe:	ffffe097          	auipc	ra,0xffffe
    80002902:	c7c080e7          	jalr	-900(ra) # 8000057a <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002906:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    8000290a:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    8000290e:	00006517          	auipc	a0,0x6
    80002912:	aba50513          	addi	a0,a0,-1350 # 800083c8 <states.1722+0x120>
    80002916:	ffffe097          	auipc	ra,0xffffe
    8000291a:	c64080e7          	jalr	-924(ra) # 8000057a <printf>
    panic("kerneltrap");
    8000291e:	00006517          	auipc	a0,0x6
    80002922:	ac250513          	addi	a0,a0,-1342 # 800083e0 <states.1722+0x138>
    80002926:	ffffe097          	auipc	ra,0xffffe
    8000292a:	c0a080e7          	jalr	-1014(ra) # 80000530 <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    8000292e:	fffff097          	auipc	ra,0xfffff
    80002932:	066080e7          	jalr	102(ra) # 80001994 <myproc>
    80002936:	d541                	beqz	a0,800028be <kerneltrap+0x38>
    80002938:	fffff097          	auipc	ra,0xfffff
    8000293c:	05c080e7          	jalr	92(ra) # 80001994 <myproc>
    80002940:	4d18                	lw	a4,24(a0)
    80002942:	4791                	li	a5,4
    80002944:	f6f71de3          	bne	a4,a5,800028be <kerneltrap+0x38>
    yield();
    80002948:	fffff097          	auipc	ra,0xfffff
    8000294c:	6d2080e7          	jalr	1746(ra) # 8000201a <yield>
    80002950:	b7bd                	j	800028be <kerneltrap+0x38>

0000000080002952 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002952:	1101                	addi	sp,sp,-32
    80002954:	ec06                	sd	ra,24(sp)
    80002956:	e822                	sd	s0,16(sp)
    80002958:	e426                	sd	s1,8(sp)
    8000295a:	1000                	addi	s0,sp,32
    8000295c:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    8000295e:	fffff097          	auipc	ra,0xfffff
    80002962:	036080e7          	jalr	54(ra) # 80001994 <myproc>
  switch (n) {
    80002966:	4795                	li	a5,5
    80002968:	0497e163          	bltu	a5,s1,800029aa <argraw+0x58>
    8000296c:	048a                	slli	s1,s1,0x2
    8000296e:	00006717          	auipc	a4,0x6
    80002972:	aaa70713          	addi	a4,a4,-1366 # 80008418 <states.1722+0x170>
    80002976:	94ba                	add	s1,s1,a4
    80002978:	409c                	lw	a5,0(s1)
    8000297a:	97ba                	add	a5,a5,a4
    8000297c:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    8000297e:	713c                	ld	a5,96(a0)
    80002980:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002982:	60e2                	ld	ra,24(sp)
    80002984:	6442                	ld	s0,16(sp)
    80002986:	64a2                	ld	s1,8(sp)
    80002988:	6105                	addi	sp,sp,32
    8000298a:	8082                	ret
    return p->trapframe->a1;
    8000298c:	713c                	ld	a5,96(a0)
    8000298e:	7fa8                	ld	a0,120(a5)
    80002990:	bfcd                	j	80002982 <argraw+0x30>
    return p->trapframe->a2;
    80002992:	713c                	ld	a5,96(a0)
    80002994:	63c8                	ld	a0,128(a5)
    80002996:	b7f5                	j	80002982 <argraw+0x30>
    return p->trapframe->a3;
    80002998:	713c                	ld	a5,96(a0)
    8000299a:	67c8                	ld	a0,136(a5)
    8000299c:	b7dd                	j	80002982 <argraw+0x30>
    return p->trapframe->a4;
    8000299e:	713c                	ld	a5,96(a0)
    800029a0:	6bc8                	ld	a0,144(a5)
    800029a2:	b7c5                	j	80002982 <argraw+0x30>
    return p->trapframe->a5;
    800029a4:	713c                	ld	a5,96(a0)
    800029a6:	6fc8                	ld	a0,152(a5)
    800029a8:	bfe9                	j	80002982 <argraw+0x30>
  panic("argraw");
    800029aa:	00006517          	auipc	a0,0x6
    800029ae:	a4650513          	addi	a0,a0,-1466 # 800083f0 <states.1722+0x148>
    800029b2:	ffffe097          	auipc	ra,0xffffe
    800029b6:	b7e080e7          	jalr	-1154(ra) # 80000530 <panic>

00000000800029ba <fetchaddr>:
{
    800029ba:	1101                	addi	sp,sp,-32
    800029bc:	ec06                	sd	ra,24(sp)
    800029be:	e822                	sd	s0,16(sp)
    800029c0:	e426                	sd	s1,8(sp)
    800029c2:	e04a                	sd	s2,0(sp)
    800029c4:	1000                	addi	s0,sp,32
    800029c6:	84aa                	mv	s1,a0
    800029c8:	892e                	mv	s2,a1
  struct proc *p = myproc();
    800029ca:	fffff097          	auipc	ra,0xfffff
    800029ce:	fca080e7          	jalr	-54(ra) # 80001994 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz)
    800029d2:	693c                	ld	a5,80(a0)
    800029d4:	02f4f863          	bgeu	s1,a5,80002a04 <fetchaddr+0x4a>
    800029d8:	00848713          	addi	a4,s1,8
    800029dc:	02e7e663          	bltu	a5,a4,80002a08 <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    800029e0:	46a1                	li	a3,8
    800029e2:	8626                	mv	a2,s1
    800029e4:	85ca                	mv	a1,s2
    800029e6:	6d28                	ld	a0,88(a0)
    800029e8:	fffff097          	auipc	ra,0xfffff
    800029ec:	cfa080e7          	jalr	-774(ra) # 800016e2 <copyin>
    800029f0:	00a03533          	snez	a0,a0
    800029f4:	40a00533          	neg	a0,a0
}
    800029f8:	60e2                	ld	ra,24(sp)
    800029fa:	6442                	ld	s0,16(sp)
    800029fc:	64a2                	ld	s1,8(sp)
    800029fe:	6902                	ld	s2,0(sp)
    80002a00:	6105                	addi	sp,sp,32
    80002a02:	8082                	ret
    return -1;
    80002a04:	557d                	li	a0,-1
    80002a06:	bfcd                	j	800029f8 <fetchaddr+0x3e>
    80002a08:	557d                	li	a0,-1
    80002a0a:	b7fd                	j	800029f8 <fetchaddr+0x3e>

0000000080002a0c <fetchstr>:
{
    80002a0c:	7179                	addi	sp,sp,-48
    80002a0e:	f406                	sd	ra,40(sp)
    80002a10:	f022                	sd	s0,32(sp)
    80002a12:	ec26                	sd	s1,24(sp)
    80002a14:	e84a                	sd	s2,16(sp)
    80002a16:	e44e                	sd	s3,8(sp)
    80002a18:	1800                	addi	s0,sp,48
    80002a1a:	892a                	mv	s2,a0
    80002a1c:	84ae                	mv	s1,a1
    80002a1e:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002a20:	fffff097          	auipc	ra,0xfffff
    80002a24:	f74080e7          	jalr	-140(ra) # 80001994 <myproc>
  int err = copyinstr(p->pagetable, buf, addr, max);
    80002a28:	86ce                	mv	a3,s3
    80002a2a:	864a                	mv	a2,s2
    80002a2c:	85a6                	mv	a1,s1
    80002a2e:	6d28                	ld	a0,88(a0)
    80002a30:	fffff097          	auipc	ra,0xfffff
    80002a34:	d3e080e7          	jalr	-706(ra) # 8000176e <copyinstr>
  if(err < 0)
    80002a38:	00054763          	bltz	a0,80002a46 <fetchstr+0x3a>
  return strlen(buf);
    80002a3c:	8526                	mv	a0,s1
    80002a3e:	ffffe097          	auipc	ra,0xffffe
    80002a42:	41c080e7          	jalr	1052(ra) # 80000e5a <strlen>
}
    80002a46:	70a2                	ld	ra,40(sp)
    80002a48:	7402                	ld	s0,32(sp)
    80002a4a:	64e2                	ld	s1,24(sp)
    80002a4c:	6942                	ld	s2,16(sp)
    80002a4e:	69a2                	ld	s3,8(sp)
    80002a50:	6145                	addi	sp,sp,48
    80002a52:	8082                	ret

0000000080002a54 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
    80002a54:	1101                	addi	sp,sp,-32
    80002a56:	ec06                	sd	ra,24(sp)
    80002a58:	e822                	sd	s0,16(sp)
    80002a5a:	e426                	sd	s1,8(sp)
    80002a5c:	1000                	addi	s0,sp,32
    80002a5e:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002a60:	00000097          	auipc	ra,0x0
    80002a64:	ef2080e7          	jalr	-270(ra) # 80002952 <argraw>
    80002a68:	c088                	sw	a0,0(s1)
  return 0;
}
    80002a6a:	4501                	li	a0,0
    80002a6c:	60e2                	ld	ra,24(sp)
    80002a6e:	6442                	ld	s0,16(sp)
    80002a70:	64a2                	ld	s1,8(sp)
    80002a72:	6105                	addi	sp,sp,32
    80002a74:	8082                	ret

0000000080002a76 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
int
argaddr(int n, uint64 *ip)
{
    80002a76:	1101                	addi	sp,sp,-32
    80002a78:	ec06                	sd	ra,24(sp)
    80002a7a:	e822                	sd	s0,16(sp)
    80002a7c:	e426                	sd	s1,8(sp)
    80002a7e:	1000                	addi	s0,sp,32
    80002a80:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002a82:	00000097          	auipc	ra,0x0
    80002a86:	ed0080e7          	jalr	-304(ra) # 80002952 <argraw>
    80002a8a:	e088                	sd	a0,0(s1)
  return 0;
}
    80002a8c:	4501                	li	a0,0
    80002a8e:	60e2                	ld	ra,24(sp)
    80002a90:	6442                	ld	s0,16(sp)
    80002a92:	64a2                	ld	s1,8(sp)
    80002a94:	6105                	addi	sp,sp,32
    80002a96:	8082                	ret

0000000080002a98 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002a98:	1101                	addi	sp,sp,-32
    80002a9a:	ec06                	sd	ra,24(sp)
    80002a9c:	e822                	sd	s0,16(sp)
    80002a9e:	e426                	sd	s1,8(sp)
    80002aa0:	e04a                	sd	s2,0(sp)
    80002aa2:	1000                	addi	s0,sp,32
    80002aa4:	84ae                	mv	s1,a1
    80002aa6:	8932                	mv	s2,a2
  *ip = argraw(n);
    80002aa8:	00000097          	auipc	ra,0x0
    80002aac:	eaa080e7          	jalr	-342(ra) # 80002952 <argraw>
  uint64 addr;
  if(argaddr(n, &addr) < 0)
    return -1;
  return fetchstr(addr, buf, max);
    80002ab0:	864a                	mv	a2,s2
    80002ab2:	85a6                	mv	a1,s1
    80002ab4:	00000097          	auipc	ra,0x0
    80002ab8:	f58080e7          	jalr	-168(ra) # 80002a0c <fetchstr>
}
    80002abc:	60e2                	ld	ra,24(sp)
    80002abe:	6442                	ld	s0,16(sp)
    80002ac0:	64a2                	ld	s1,8(sp)
    80002ac2:	6902                	ld	s2,0(sp)
    80002ac4:	6105                	addi	sp,sp,32
    80002ac6:	8082                	ret

0000000080002ac8 <syscall>:
[SYS_close]   sys_close,
};

void
syscall(void)
{
    80002ac8:	1101                	addi	sp,sp,-32
    80002aca:	ec06                	sd	ra,24(sp)
    80002acc:	e822                	sd	s0,16(sp)
    80002ace:	e426                	sd	s1,8(sp)
    80002ad0:	e04a                	sd	s2,0(sp)
    80002ad2:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002ad4:	fffff097          	auipc	ra,0xfffff
    80002ad8:	ec0080e7          	jalr	-320(ra) # 80001994 <myproc>
    80002adc:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002ade:	06053903          	ld	s2,96(a0)
    80002ae2:	0a893783          	ld	a5,168(s2)
    80002ae6:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002aea:	37fd                	addiw	a5,a5,-1
    80002aec:	4751                	li	a4,20
    80002aee:	00f76f63          	bltu	a4,a5,80002b0c <syscall+0x44>
    80002af2:	00369713          	slli	a4,a3,0x3
    80002af6:	00006797          	auipc	a5,0x6
    80002afa:	93a78793          	addi	a5,a5,-1734 # 80008430 <syscalls>
    80002afe:	97ba                	add	a5,a5,a4
    80002b00:	639c                	ld	a5,0(a5)
    80002b02:	c789                	beqz	a5,80002b0c <syscall+0x44>
    p->trapframe->a0 = syscalls[num]();
    80002b04:	9782                	jalr	a5
    80002b06:	06a93823          	sd	a0,112(s2)
    80002b0a:	a839                	j	80002b28 <syscall+0x60>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002b0c:	16048613          	addi	a2,s1,352
    80002b10:	588c                	lw	a1,48(s1)
    80002b12:	00006517          	auipc	a0,0x6
    80002b16:	8e650513          	addi	a0,a0,-1818 # 800083f8 <states.1722+0x150>
    80002b1a:	ffffe097          	auipc	ra,0xffffe
    80002b1e:	a60080e7          	jalr	-1440(ra) # 8000057a <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002b22:	70bc                	ld	a5,96(s1)
    80002b24:	577d                	li	a4,-1
    80002b26:	fbb8                	sd	a4,112(a5)
  }
}
    80002b28:	60e2                	ld	ra,24(sp)
    80002b2a:	6442                	ld	s0,16(sp)
    80002b2c:	64a2                	ld	s1,8(sp)
    80002b2e:	6902                	ld	s2,0(sp)
    80002b30:	6105                	addi	sp,sp,32
    80002b32:	8082                	ret

0000000080002b34 <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    80002b34:	1101                	addi	sp,sp,-32
    80002b36:	ec06                	sd	ra,24(sp)
    80002b38:	e822                	sd	s0,16(sp)
    80002b3a:	1000                	addi	s0,sp,32
  int n;
  if(argint(0, &n) < 0)
    80002b3c:	fec40593          	addi	a1,s0,-20
    80002b40:	4501                	li	a0,0
    80002b42:	00000097          	auipc	ra,0x0
    80002b46:	f12080e7          	jalr	-238(ra) # 80002a54 <argint>
    return -1;
    80002b4a:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80002b4c:	00054963          	bltz	a0,80002b5e <sys_exit+0x2a>
  exit(n);
    80002b50:	fec42503          	lw	a0,-20(s0)
    80002b54:	fffff097          	auipc	ra,0xfffff
    80002b58:	75e080e7          	jalr	1886(ra) # 800022b2 <exit>
  return 0;  // not reached
    80002b5c:	4781                	li	a5,0
}
    80002b5e:	853e                	mv	a0,a5
    80002b60:	60e2                	ld	ra,24(sp)
    80002b62:	6442                	ld	s0,16(sp)
    80002b64:	6105                	addi	sp,sp,32
    80002b66:	8082                	ret

0000000080002b68 <sys_getpid>:

uint64
sys_getpid(void)
{
    80002b68:	1141                	addi	sp,sp,-16
    80002b6a:	e406                	sd	ra,8(sp)
    80002b6c:	e022                	sd	s0,0(sp)
    80002b6e:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002b70:	fffff097          	auipc	ra,0xfffff
    80002b74:	e24080e7          	jalr	-476(ra) # 80001994 <myproc>
}
    80002b78:	5908                	lw	a0,48(a0)
    80002b7a:	60a2                	ld	ra,8(sp)
    80002b7c:	6402                	ld	s0,0(sp)
    80002b7e:	0141                	addi	sp,sp,16
    80002b80:	8082                	ret

0000000080002b82 <sys_fork>:

uint64
sys_fork(void)
{
    80002b82:	1141                	addi	sp,sp,-16
    80002b84:	e406                	sd	ra,8(sp)
    80002b86:	e022                	sd	s0,0(sp)
    80002b88:	0800                	addi	s0,sp,16
  return fork();
    80002b8a:	fffff097          	auipc	ra,0xfffff
    80002b8e:	1d8080e7          	jalr	472(ra) # 80001d62 <fork>
}
    80002b92:	60a2                	ld	ra,8(sp)
    80002b94:	6402                	ld	s0,0(sp)
    80002b96:	0141                	addi	sp,sp,16
    80002b98:	8082                	ret

0000000080002b9a <sys_wait>:

uint64
sys_wait(void)
{
    80002b9a:	1101                	addi	sp,sp,-32
    80002b9c:	ec06                	sd	ra,24(sp)
    80002b9e:	e822                	sd	s0,16(sp)
    80002ba0:	1000                	addi	s0,sp,32
  uint64 p;
  if(argaddr(0, &p) < 0)
    80002ba2:	fe840593          	addi	a1,s0,-24
    80002ba6:	4501                	li	a0,0
    80002ba8:	00000097          	auipc	ra,0x0
    80002bac:	ece080e7          	jalr	-306(ra) # 80002a76 <argaddr>
    80002bb0:	87aa                	mv	a5,a0
    return -1;
    80002bb2:	557d                	li	a0,-1
  if(argaddr(0, &p) < 0)
    80002bb4:	0007c863          	bltz	a5,80002bc4 <sys_wait+0x2a>
  return wait(p);
    80002bb8:	fe843503          	ld	a0,-24(s0)
    80002bbc:	fffff097          	auipc	ra,0xfffff
    80002bc0:	4fe080e7          	jalr	1278(ra) # 800020ba <wait>
}
    80002bc4:	60e2                	ld	ra,24(sp)
    80002bc6:	6442                	ld	s0,16(sp)
    80002bc8:	6105                	addi	sp,sp,32
    80002bca:	8082                	ret

0000000080002bcc <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002bcc:	7179                	addi	sp,sp,-48
    80002bce:	f406                	sd	ra,40(sp)
    80002bd0:	f022                	sd	s0,32(sp)
    80002bd2:	ec26                	sd	s1,24(sp)
    80002bd4:	1800                	addi	s0,sp,48
  int addr;
  int n;

  if(argint(0, &n) < 0)
    80002bd6:	fdc40593          	addi	a1,s0,-36
    80002bda:	4501                	li	a0,0
    80002bdc:	00000097          	auipc	ra,0x0
    80002be0:	e78080e7          	jalr	-392(ra) # 80002a54 <argint>
    80002be4:	87aa                	mv	a5,a0
    return -1;
    80002be6:	557d                	li	a0,-1
  if(argint(0, &n) < 0)
    80002be8:	0207c063          	bltz	a5,80002c08 <sys_sbrk+0x3c>
  addr = myproc()->sz;
    80002bec:	fffff097          	auipc	ra,0xfffff
    80002bf0:	da8080e7          	jalr	-600(ra) # 80001994 <myproc>
    80002bf4:	4924                	lw	s1,80(a0)
  if(growproc(n) < 0)
    80002bf6:	fdc42503          	lw	a0,-36(s0)
    80002bfa:	fffff097          	auipc	ra,0xfffff
    80002bfe:	0f4080e7          	jalr	244(ra) # 80001cee <growproc>
    80002c02:	00054863          	bltz	a0,80002c12 <sys_sbrk+0x46>
    return -1;
  return addr;
    80002c06:	8526                	mv	a0,s1
}
    80002c08:	70a2                	ld	ra,40(sp)
    80002c0a:	7402                	ld	s0,32(sp)
    80002c0c:	64e2                	ld	s1,24(sp)
    80002c0e:	6145                	addi	sp,sp,48
    80002c10:	8082                	ret
    return -1;
    80002c12:	557d                	li	a0,-1
    80002c14:	bfd5                	j	80002c08 <sys_sbrk+0x3c>

0000000080002c16 <sys_sleep>:

uint64
sys_sleep(void)
{
    80002c16:	7139                	addi	sp,sp,-64
    80002c18:	fc06                	sd	ra,56(sp)
    80002c1a:	f822                	sd	s0,48(sp)
    80002c1c:	f426                	sd	s1,40(sp)
    80002c1e:	f04a                	sd	s2,32(sp)
    80002c20:	ec4e                	sd	s3,24(sp)
    80002c22:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
    80002c24:	fcc40593          	addi	a1,s0,-52
    80002c28:	4501                	li	a0,0
    80002c2a:	00000097          	auipc	ra,0x0
    80002c2e:	e2a080e7          	jalr	-470(ra) # 80002a54 <argint>
    return -1;
    80002c32:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80002c34:	06054563          	bltz	a0,80002c9e <sys_sleep+0x88>
  acquire(&tickslock);
    80002c38:	00014517          	auipc	a0,0x14
    80002c3c:	69850513          	addi	a0,a0,1688 # 800172d0 <tickslock>
    80002c40:	ffffe097          	auipc	ra,0xffffe
    80002c44:	f96080e7          	jalr	-106(ra) # 80000bd6 <acquire>
  ticks0 = ticks;
    80002c48:	00006917          	auipc	s2,0x6
    80002c4c:	3e892903          	lw	s2,1000(s2) # 80009030 <ticks>
  while(ticks - ticks0 < n){
    80002c50:	fcc42783          	lw	a5,-52(s0)
    80002c54:	cf85                	beqz	a5,80002c8c <sys_sleep+0x76>
    if(myproc()->killed){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002c56:	00014997          	auipc	s3,0x14
    80002c5a:	67a98993          	addi	s3,s3,1658 # 800172d0 <tickslock>
    80002c5e:	00006497          	auipc	s1,0x6
    80002c62:	3d248493          	addi	s1,s1,978 # 80009030 <ticks>
    if(myproc()->killed){
    80002c66:	fffff097          	auipc	ra,0xfffff
    80002c6a:	d2e080e7          	jalr	-722(ra) # 80001994 <myproc>
    80002c6e:	551c                	lw	a5,40(a0)
    80002c70:	ef9d                	bnez	a5,80002cae <sys_sleep+0x98>
    sleep(&ticks, &tickslock);
    80002c72:	85ce                	mv	a1,s3
    80002c74:	8526                	mv	a0,s1
    80002c76:	fffff097          	auipc	ra,0xfffff
    80002c7a:	3e0080e7          	jalr	992(ra) # 80002056 <sleep>
  while(ticks - ticks0 < n){
    80002c7e:	409c                	lw	a5,0(s1)
    80002c80:	412787bb          	subw	a5,a5,s2
    80002c84:	fcc42703          	lw	a4,-52(s0)
    80002c88:	fce7efe3          	bltu	a5,a4,80002c66 <sys_sleep+0x50>
  }
  release(&tickslock);
    80002c8c:	00014517          	auipc	a0,0x14
    80002c90:	64450513          	addi	a0,a0,1604 # 800172d0 <tickslock>
    80002c94:	ffffe097          	auipc	ra,0xffffe
    80002c98:	ff6080e7          	jalr	-10(ra) # 80000c8a <release>
  return 0;
    80002c9c:	4781                	li	a5,0
}
    80002c9e:	853e                	mv	a0,a5
    80002ca0:	70e2                	ld	ra,56(sp)
    80002ca2:	7442                	ld	s0,48(sp)
    80002ca4:	74a2                	ld	s1,40(sp)
    80002ca6:	7902                	ld	s2,32(sp)
    80002ca8:	69e2                	ld	s3,24(sp)
    80002caa:	6121                	addi	sp,sp,64
    80002cac:	8082                	ret
      release(&tickslock);
    80002cae:	00014517          	auipc	a0,0x14
    80002cb2:	62250513          	addi	a0,a0,1570 # 800172d0 <tickslock>
    80002cb6:	ffffe097          	auipc	ra,0xffffe
    80002cba:	fd4080e7          	jalr	-44(ra) # 80000c8a <release>
      return -1;
    80002cbe:	57fd                	li	a5,-1
    80002cc0:	bff9                	j	80002c9e <sys_sleep+0x88>

0000000080002cc2 <sys_kill>:

uint64
sys_kill(void)
{
    80002cc2:	1101                	addi	sp,sp,-32
    80002cc4:	ec06                	sd	ra,24(sp)
    80002cc6:	e822                	sd	s0,16(sp)
    80002cc8:	1000                	addi	s0,sp,32
  int pid;

  if(argint(0, &pid) < 0)
    80002cca:	fec40593          	addi	a1,s0,-20
    80002cce:	4501                	li	a0,0
    80002cd0:	00000097          	auipc	ra,0x0
    80002cd4:	d84080e7          	jalr	-636(ra) # 80002a54 <argint>
    80002cd8:	87aa                	mv	a5,a0
    return -1;
    80002cda:	557d                	li	a0,-1
  if(argint(0, &pid) < 0)
    80002cdc:	0007c863          	bltz	a5,80002cec <sys_kill+0x2a>
  return kill(pid);
    80002ce0:	fec42503          	lw	a0,-20(s0)
    80002ce4:	fffff097          	auipc	ra,0xfffff
    80002ce8:	6a4080e7          	jalr	1700(ra) # 80002388 <kill>
}
    80002cec:	60e2                	ld	ra,24(sp)
    80002cee:	6442                	ld	s0,16(sp)
    80002cf0:	6105                	addi	sp,sp,32
    80002cf2:	8082                	ret

0000000080002cf4 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002cf4:	1101                	addi	sp,sp,-32
    80002cf6:	ec06                	sd	ra,24(sp)
    80002cf8:	e822                	sd	s0,16(sp)
    80002cfa:	e426                	sd	s1,8(sp)
    80002cfc:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002cfe:	00014517          	auipc	a0,0x14
    80002d02:	5d250513          	addi	a0,a0,1490 # 800172d0 <tickslock>
    80002d06:	ffffe097          	auipc	ra,0xffffe
    80002d0a:	ed0080e7          	jalr	-304(ra) # 80000bd6 <acquire>
  xticks = ticks;
    80002d0e:	00006497          	auipc	s1,0x6
    80002d12:	3224a483          	lw	s1,802(s1) # 80009030 <ticks>
  release(&tickslock);
    80002d16:	00014517          	auipc	a0,0x14
    80002d1a:	5ba50513          	addi	a0,a0,1466 # 800172d0 <tickslock>
    80002d1e:	ffffe097          	auipc	ra,0xffffe
    80002d22:	f6c080e7          	jalr	-148(ra) # 80000c8a <release>
  return xticks;
}
    80002d26:	02049513          	slli	a0,s1,0x20
    80002d2a:	9101                	srli	a0,a0,0x20
    80002d2c:	60e2                	ld	ra,24(sp)
    80002d2e:	6442                	ld	s0,16(sp)
    80002d30:	64a2                	ld	s1,8(sp)
    80002d32:	6105                	addi	sp,sp,32
    80002d34:	8082                	ret

0000000080002d36 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002d36:	7179                	addi	sp,sp,-48
    80002d38:	f406                	sd	ra,40(sp)
    80002d3a:	f022                	sd	s0,32(sp)
    80002d3c:	ec26                	sd	s1,24(sp)
    80002d3e:	e84a                	sd	s2,16(sp)
    80002d40:	e44e                	sd	s3,8(sp)
    80002d42:	e052                	sd	s4,0(sp)
    80002d44:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80002d46:	00005597          	auipc	a1,0x5
    80002d4a:	79a58593          	addi	a1,a1,1946 # 800084e0 <syscalls+0xb0>
    80002d4e:	00014517          	auipc	a0,0x14
    80002d52:	59a50513          	addi	a0,a0,1434 # 800172e8 <bcache>
    80002d56:	ffffe097          	auipc	ra,0xffffe
    80002d5a:	df0080e7          	jalr	-528(ra) # 80000b46 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80002d5e:	0001c797          	auipc	a5,0x1c
    80002d62:	58a78793          	addi	a5,a5,1418 # 8001f2e8 <bcache+0x8000>
    80002d66:	0001c717          	auipc	a4,0x1c
    80002d6a:	7ea70713          	addi	a4,a4,2026 # 8001f550 <bcache+0x8268>
    80002d6e:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80002d72:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002d76:	00014497          	auipc	s1,0x14
    80002d7a:	58a48493          	addi	s1,s1,1418 # 80017300 <bcache+0x18>
    b->next = bcache.head.next;
    80002d7e:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80002d80:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80002d82:	00005a17          	auipc	s4,0x5
    80002d86:	766a0a13          	addi	s4,s4,1894 # 800084e8 <syscalls+0xb8>
    b->next = bcache.head.next;
    80002d8a:	2b893783          	ld	a5,696(s2)
    80002d8e:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80002d90:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80002d94:	85d2                	mv	a1,s4
    80002d96:	01048513          	addi	a0,s1,16
    80002d9a:	00001097          	auipc	ra,0x1
    80002d9e:	4bc080e7          	jalr	1212(ra) # 80004256 <initsleeplock>
    bcache.head.next->prev = b;
    80002da2:	2b893783          	ld	a5,696(s2)
    80002da6:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80002da8:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002dac:	45848493          	addi	s1,s1,1112
    80002db0:	fd349de3          	bne	s1,s3,80002d8a <binit+0x54>
  }
}
    80002db4:	70a2                	ld	ra,40(sp)
    80002db6:	7402                	ld	s0,32(sp)
    80002db8:	64e2                	ld	s1,24(sp)
    80002dba:	6942                	ld	s2,16(sp)
    80002dbc:	69a2                	ld	s3,8(sp)
    80002dbe:	6a02                	ld	s4,0(sp)
    80002dc0:	6145                	addi	sp,sp,48
    80002dc2:	8082                	ret

0000000080002dc4 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80002dc4:	7179                	addi	sp,sp,-48
    80002dc6:	f406                	sd	ra,40(sp)
    80002dc8:	f022                	sd	s0,32(sp)
    80002dca:	ec26                	sd	s1,24(sp)
    80002dcc:	e84a                	sd	s2,16(sp)
    80002dce:	e44e                	sd	s3,8(sp)
    80002dd0:	1800                	addi	s0,sp,48
    80002dd2:	89aa                	mv	s3,a0
    80002dd4:	892e                	mv	s2,a1
  acquire(&bcache.lock);
    80002dd6:	00014517          	auipc	a0,0x14
    80002dda:	51250513          	addi	a0,a0,1298 # 800172e8 <bcache>
    80002dde:	ffffe097          	auipc	ra,0xffffe
    80002de2:	df8080e7          	jalr	-520(ra) # 80000bd6 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80002de6:	0001c497          	auipc	s1,0x1c
    80002dea:	7ba4b483          	ld	s1,1978(s1) # 8001f5a0 <bcache+0x82b8>
    80002dee:	0001c797          	auipc	a5,0x1c
    80002df2:	76278793          	addi	a5,a5,1890 # 8001f550 <bcache+0x8268>
    80002df6:	02f48f63          	beq	s1,a5,80002e34 <bread+0x70>
    80002dfa:	873e                	mv	a4,a5
    80002dfc:	a021                	j	80002e04 <bread+0x40>
    80002dfe:	68a4                	ld	s1,80(s1)
    80002e00:	02e48a63          	beq	s1,a4,80002e34 <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    80002e04:	449c                	lw	a5,8(s1)
    80002e06:	ff379ce3          	bne	a5,s3,80002dfe <bread+0x3a>
    80002e0a:	44dc                	lw	a5,12(s1)
    80002e0c:	ff2799e3          	bne	a5,s2,80002dfe <bread+0x3a>
      b->refcnt++;
    80002e10:	40bc                	lw	a5,64(s1)
    80002e12:	2785                	addiw	a5,a5,1
    80002e14:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002e16:	00014517          	auipc	a0,0x14
    80002e1a:	4d250513          	addi	a0,a0,1234 # 800172e8 <bcache>
    80002e1e:	ffffe097          	auipc	ra,0xffffe
    80002e22:	e6c080e7          	jalr	-404(ra) # 80000c8a <release>
      acquiresleep(&b->lock);
    80002e26:	01048513          	addi	a0,s1,16
    80002e2a:	00001097          	auipc	ra,0x1
    80002e2e:	466080e7          	jalr	1126(ra) # 80004290 <acquiresleep>
      return b;
    80002e32:	a8b9                	j	80002e90 <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002e34:	0001c497          	auipc	s1,0x1c
    80002e38:	7644b483          	ld	s1,1892(s1) # 8001f598 <bcache+0x82b0>
    80002e3c:	0001c797          	auipc	a5,0x1c
    80002e40:	71478793          	addi	a5,a5,1812 # 8001f550 <bcache+0x8268>
    80002e44:	00f48863          	beq	s1,a5,80002e54 <bread+0x90>
    80002e48:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80002e4a:	40bc                	lw	a5,64(s1)
    80002e4c:	cf81                	beqz	a5,80002e64 <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002e4e:	64a4                	ld	s1,72(s1)
    80002e50:	fee49de3          	bne	s1,a4,80002e4a <bread+0x86>
  panic("bget: no buffers");
    80002e54:	00005517          	auipc	a0,0x5
    80002e58:	69c50513          	addi	a0,a0,1692 # 800084f0 <syscalls+0xc0>
    80002e5c:	ffffd097          	auipc	ra,0xffffd
    80002e60:	6d4080e7          	jalr	1748(ra) # 80000530 <panic>
      b->dev = dev;
    80002e64:	0134a423          	sw	s3,8(s1)
      b->blockno = blockno;
    80002e68:	0124a623          	sw	s2,12(s1)
      b->valid = 0;
    80002e6c:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80002e70:	4785                	li	a5,1
    80002e72:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002e74:	00014517          	auipc	a0,0x14
    80002e78:	47450513          	addi	a0,a0,1140 # 800172e8 <bcache>
    80002e7c:	ffffe097          	auipc	ra,0xffffe
    80002e80:	e0e080e7          	jalr	-498(ra) # 80000c8a <release>
      acquiresleep(&b->lock);
    80002e84:	01048513          	addi	a0,s1,16
    80002e88:	00001097          	auipc	ra,0x1
    80002e8c:	408080e7          	jalr	1032(ra) # 80004290 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80002e90:	409c                	lw	a5,0(s1)
    80002e92:	cb89                	beqz	a5,80002ea4 <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80002e94:	8526                	mv	a0,s1
    80002e96:	70a2                	ld	ra,40(sp)
    80002e98:	7402                	ld	s0,32(sp)
    80002e9a:	64e2                	ld	s1,24(sp)
    80002e9c:	6942                	ld	s2,16(sp)
    80002e9e:	69a2                	ld	s3,8(sp)
    80002ea0:	6145                	addi	sp,sp,48
    80002ea2:	8082                	ret
    virtio_disk_rw(b, 0);
    80002ea4:	4581                	li	a1,0
    80002ea6:	8526                	mv	a0,s1
    80002ea8:	00003097          	auipc	ra,0x3
    80002eac:	f0e080e7          	jalr	-242(ra) # 80005db6 <virtio_disk_rw>
    b->valid = 1;
    80002eb0:	4785                	li	a5,1
    80002eb2:	c09c                	sw	a5,0(s1)
  return b;
    80002eb4:	b7c5                	j	80002e94 <bread+0xd0>

0000000080002eb6 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80002eb6:	1101                	addi	sp,sp,-32
    80002eb8:	ec06                	sd	ra,24(sp)
    80002eba:	e822                	sd	s0,16(sp)
    80002ebc:	e426                	sd	s1,8(sp)
    80002ebe:	1000                	addi	s0,sp,32
    80002ec0:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002ec2:	0541                	addi	a0,a0,16
    80002ec4:	00001097          	auipc	ra,0x1
    80002ec8:	466080e7          	jalr	1126(ra) # 8000432a <holdingsleep>
    80002ecc:	cd01                	beqz	a0,80002ee4 <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80002ece:	4585                	li	a1,1
    80002ed0:	8526                	mv	a0,s1
    80002ed2:	00003097          	auipc	ra,0x3
    80002ed6:	ee4080e7          	jalr	-284(ra) # 80005db6 <virtio_disk_rw>
}
    80002eda:	60e2                	ld	ra,24(sp)
    80002edc:	6442                	ld	s0,16(sp)
    80002ede:	64a2                	ld	s1,8(sp)
    80002ee0:	6105                	addi	sp,sp,32
    80002ee2:	8082                	ret
    panic("bwrite");
    80002ee4:	00005517          	auipc	a0,0x5
    80002ee8:	62450513          	addi	a0,a0,1572 # 80008508 <syscalls+0xd8>
    80002eec:	ffffd097          	auipc	ra,0xffffd
    80002ef0:	644080e7          	jalr	1604(ra) # 80000530 <panic>

0000000080002ef4 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80002ef4:	1101                	addi	sp,sp,-32
    80002ef6:	ec06                	sd	ra,24(sp)
    80002ef8:	e822                	sd	s0,16(sp)
    80002efa:	e426                	sd	s1,8(sp)
    80002efc:	e04a                	sd	s2,0(sp)
    80002efe:	1000                	addi	s0,sp,32
    80002f00:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002f02:	01050913          	addi	s2,a0,16
    80002f06:	854a                	mv	a0,s2
    80002f08:	00001097          	auipc	ra,0x1
    80002f0c:	422080e7          	jalr	1058(ra) # 8000432a <holdingsleep>
    80002f10:	c92d                	beqz	a0,80002f82 <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    80002f12:	854a                	mv	a0,s2
    80002f14:	00001097          	auipc	ra,0x1
    80002f18:	3d2080e7          	jalr	978(ra) # 800042e6 <releasesleep>

  acquire(&bcache.lock);
    80002f1c:	00014517          	auipc	a0,0x14
    80002f20:	3cc50513          	addi	a0,a0,972 # 800172e8 <bcache>
    80002f24:	ffffe097          	auipc	ra,0xffffe
    80002f28:	cb2080e7          	jalr	-846(ra) # 80000bd6 <acquire>
  b->refcnt--;
    80002f2c:	40bc                	lw	a5,64(s1)
    80002f2e:	37fd                	addiw	a5,a5,-1
    80002f30:	0007871b          	sext.w	a4,a5
    80002f34:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80002f36:	eb05                	bnez	a4,80002f66 <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80002f38:	68bc                	ld	a5,80(s1)
    80002f3a:	64b8                	ld	a4,72(s1)
    80002f3c:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    80002f3e:	64bc                	ld	a5,72(s1)
    80002f40:	68b8                	ld	a4,80(s1)
    80002f42:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80002f44:	0001c797          	auipc	a5,0x1c
    80002f48:	3a478793          	addi	a5,a5,932 # 8001f2e8 <bcache+0x8000>
    80002f4c:	2b87b703          	ld	a4,696(a5)
    80002f50:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80002f52:	0001c717          	auipc	a4,0x1c
    80002f56:	5fe70713          	addi	a4,a4,1534 # 8001f550 <bcache+0x8268>
    80002f5a:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80002f5c:	2b87b703          	ld	a4,696(a5)
    80002f60:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80002f62:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80002f66:	00014517          	auipc	a0,0x14
    80002f6a:	38250513          	addi	a0,a0,898 # 800172e8 <bcache>
    80002f6e:	ffffe097          	auipc	ra,0xffffe
    80002f72:	d1c080e7          	jalr	-740(ra) # 80000c8a <release>
}
    80002f76:	60e2                	ld	ra,24(sp)
    80002f78:	6442                	ld	s0,16(sp)
    80002f7a:	64a2                	ld	s1,8(sp)
    80002f7c:	6902                	ld	s2,0(sp)
    80002f7e:	6105                	addi	sp,sp,32
    80002f80:	8082                	ret
    panic("brelse");
    80002f82:	00005517          	auipc	a0,0x5
    80002f86:	58e50513          	addi	a0,a0,1422 # 80008510 <syscalls+0xe0>
    80002f8a:	ffffd097          	auipc	ra,0xffffd
    80002f8e:	5a6080e7          	jalr	1446(ra) # 80000530 <panic>

0000000080002f92 <bpin>:

void
bpin(struct buf *b) {
    80002f92:	1101                	addi	sp,sp,-32
    80002f94:	ec06                	sd	ra,24(sp)
    80002f96:	e822                	sd	s0,16(sp)
    80002f98:	e426                	sd	s1,8(sp)
    80002f9a:	1000                	addi	s0,sp,32
    80002f9c:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002f9e:	00014517          	auipc	a0,0x14
    80002fa2:	34a50513          	addi	a0,a0,842 # 800172e8 <bcache>
    80002fa6:	ffffe097          	auipc	ra,0xffffe
    80002faa:	c30080e7          	jalr	-976(ra) # 80000bd6 <acquire>
  b->refcnt++;
    80002fae:	40bc                	lw	a5,64(s1)
    80002fb0:	2785                	addiw	a5,a5,1
    80002fb2:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002fb4:	00014517          	auipc	a0,0x14
    80002fb8:	33450513          	addi	a0,a0,820 # 800172e8 <bcache>
    80002fbc:	ffffe097          	auipc	ra,0xffffe
    80002fc0:	cce080e7          	jalr	-818(ra) # 80000c8a <release>
}
    80002fc4:	60e2                	ld	ra,24(sp)
    80002fc6:	6442                	ld	s0,16(sp)
    80002fc8:	64a2                	ld	s1,8(sp)
    80002fca:	6105                	addi	sp,sp,32
    80002fcc:	8082                	ret

0000000080002fce <bunpin>:

void
bunpin(struct buf *b) {
    80002fce:	1101                	addi	sp,sp,-32
    80002fd0:	ec06                	sd	ra,24(sp)
    80002fd2:	e822                	sd	s0,16(sp)
    80002fd4:	e426                	sd	s1,8(sp)
    80002fd6:	1000                	addi	s0,sp,32
    80002fd8:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002fda:	00014517          	auipc	a0,0x14
    80002fde:	30e50513          	addi	a0,a0,782 # 800172e8 <bcache>
    80002fe2:	ffffe097          	auipc	ra,0xffffe
    80002fe6:	bf4080e7          	jalr	-1036(ra) # 80000bd6 <acquire>
  b->refcnt--;
    80002fea:	40bc                	lw	a5,64(s1)
    80002fec:	37fd                	addiw	a5,a5,-1
    80002fee:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002ff0:	00014517          	auipc	a0,0x14
    80002ff4:	2f850513          	addi	a0,a0,760 # 800172e8 <bcache>
    80002ff8:	ffffe097          	auipc	ra,0xffffe
    80002ffc:	c92080e7          	jalr	-878(ra) # 80000c8a <release>
}
    80003000:	60e2                	ld	ra,24(sp)
    80003002:	6442                	ld	s0,16(sp)
    80003004:	64a2                	ld	s1,8(sp)
    80003006:	6105                	addi	sp,sp,32
    80003008:	8082                	ret

000000008000300a <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    8000300a:	1101                	addi	sp,sp,-32
    8000300c:	ec06                	sd	ra,24(sp)
    8000300e:	e822                	sd	s0,16(sp)
    80003010:	e426                	sd	s1,8(sp)
    80003012:	e04a                	sd	s2,0(sp)
    80003014:	1000                	addi	s0,sp,32
    80003016:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80003018:	00d5d59b          	srliw	a1,a1,0xd
    8000301c:	0001d797          	auipc	a5,0x1d
    80003020:	9a87a783          	lw	a5,-1624(a5) # 8001f9c4 <sb+0x1c>
    80003024:	9dbd                	addw	a1,a1,a5
    80003026:	00000097          	auipc	ra,0x0
    8000302a:	d9e080e7          	jalr	-610(ra) # 80002dc4 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    8000302e:	0074f713          	andi	a4,s1,7
    80003032:	4785                	li	a5,1
    80003034:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    80003038:	14ce                	slli	s1,s1,0x33
    8000303a:	90d9                	srli	s1,s1,0x36
    8000303c:	00950733          	add	a4,a0,s1
    80003040:	05874703          	lbu	a4,88(a4)
    80003044:	00e7f6b3          	and	a3,a5,a4
    80003048:	c69d                	beqz	a3,80003076 <bfree+0x6c>
    8000304a:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    8000304c:	94aa                	add	s1,s1,a0
    8000304e:	fff7c793          	not	a5,a5
    80003052:	8ff9                	and	a5,a5,a4
    80003054:	04f48c23          	sb	a5,88(s1)
  log_write(bp);
    80003058:	00001097          	auipc	ra,0x1
    8000305c:	118080e7          	jalr	280(ra) # 80004170 <log_write>
  brelse(bp);
    80003060:	854a                	mv	a0,s2
    80003062:	00000097          	auipc	ra,0x0
    80003066:	e92080e7          	jalr	-366(ra) # 80002ef4 <brelse>
}
    8000306a:	60e2                	ld	ra,24(sp)
    8000306c:	6442                	ld	s0,16(sp)
    8000306e:	64a2                	ld	s1,8(sp)
    80003070:	6902                	ld	s2,0(sp)
    80003072:	6105                	addi	sp,sp,32
    80003074:	8082                	ret
    panic("freeing free block");
    80003076:	00005517          	auipc	a0,0x5
    8000307a:	4a250513          	addi	a0,a0,1186 # 80008518 <syscalls+0xe8>
    8000307e:	ffffd097          	auipc	ra,0xffffd
    80003082:	4b2080e7          	jalr	1202(ra) # 80000530 <panic>

0000000080003086 <balloc>:
{
    80003086:	711d                	addi	sp,sp,-96
    80003088:	ec86                	sd	ra,88(sp)
    8000308a:	e8a2                	sd	s0,80(sp)
    8000308c:	e4a6                	sd	s1,72(sp)
    8000308e:	e0ca                	sd	s2,64(sp)
    80003090:	fc4e                	sd	s3,56(sp)
    80003092:	f852                	sd	s4,48(sp)
    80003094:	f456                	sd	s5,40(sp)
    80003096:	f05a                	sd	s6,32(sp)
    80003098:	ec5e                	sd	s7,24(sp)
    8000309a:	e862                	sd	s8,16(sp)
    8000309c:	e466                	sd	s9,8(sp)
    8000309e:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    800030a0:	0001d797          	auipc	a5,0x1d
    800030a4:	90c7a783          	lw	a5,-1780(a5) # 8001f9ac <sb+0x4>
    800030a8:	cbd1                	beqz	a5,8000313c <balloc+0xb6>
    800030aa:	8baa                	mv	s7,a0
    800030ac:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    800030ae:	0001db17          	auipc	s6,0x1d
    800030b2:	8fab0b13          	addi	s6,s6,-1798 # 8001f9a8 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800030b6:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    800030b8:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800030ba:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    800030bc:	6c89                	lui	s9,0x2
    800030be:	a831                	j	800030da <balloc+0x54>
    brelse(bp);
    800030c0:	854a                	mv	a0,s2
    800030c2:	00000097          	auipc	ra,0x0
    800030c6:	e32080e7          	jalr	-462(ra) # 80002ef4 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    800030ca:	015c87bb          	addw	a5,s9,s5
    800030ce:	00078a9b          	sext.w	s5,a5
    800030d2:	004b2703          	lw	a4,4(s6)
    800030d6:	06eaf363          	bgeu	s5,a4,8000313c <balloc+0xb6>
    bp = bread(dev, BBLOCK(b, sb));
    800030da:	41fad79b          	sraiw	a5,s5,0x1f
    800030de:	0137d79b          	srliw	a5,a5,0x13
    800030e2:	015787bb          	addw	a5,a5,s5
    800030e6:	40d7d79b          	sraiw	a5,a5,0xd
    800030ea:	01cb2583          	lw	a1,28(s6)
    800030ee:	9dbd                	addw	a1,a1,a5
    800030f0:	855e                	mv	a0,s7
    800030f2:	00000097          	auipc	ra,0x0
    800030f6:	cd2080e7          	jalr	-814(ra) # 80002dc4 <bread>
    800030fa:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800030fc:	004b2503          	lw	a0,4(s6)
    80003100:	000a849b          	sext.w	s1,s5
    80003104:	8662                	mv	a2,s8
    80003106:	faa4fde3          	bgeu	s1,a0,800030c0 <balloc+0x3a>
      m = 1 << (bi % 8);
    8000310a:	41f6579b          	sraiw	a5,a2,0x1f
    8000310e:	01d7d69b          	srliw	a3,a5,0x1d
    80003112:	00c6873b          	addw	a4,a3,a2
    80003116:	00777793          	andi	a5,a4,7
    8000311a:	9f95                	subw	a5,a5,a3
    8000311c:	00f997bb          	sllw	a5,s3,a5
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80003120:	4037571b          	sraiw	a4,a4,0x3
    80003124:	00e906b3          	add	a3,s2,a4
    80003128:	0586c683          	lbu	a3,88(a3)
    8000312c:	00d7f5b3          	and	a1,a5,a3
    80003130:	cd91                	beqz	a1,8000314c <balloc+0xc6>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003132:	2605                	addiw	a2,a2,1
    80003134:	2485                	addiw	s1,s1,1
    80003136:	fd4618e3          	bne	a2,s4,80003106 <balloc+0x80>
    8000313a:	b759                	j	800030c0 <balloc+0x3a>
  panic("balloc: out of blocks");
    8000313c:	00005517          	auipc	a0,0x5
    80003140:	3f450513          	addi	a0,a0,1012 # 80008530 <syscalls+0x100>
    80003144:	ffffd097          	auipc	ra,0xffffd
    80003148:	3ec080e7          	jalr	1004(ra) # 80000530 <panic>
        bp->data[bi/8] |= m;  // Mark block in use.
    8000314c:	974a                	add	a4,a4,s2
    8000314e:	8fd5                	or	a5,a5,a3
    80003150:	04f70c23          	sb	a5,88(a4)
        log_write(bp);
    80003154:	854a                	mv	a0,s2
    80003156:	00001097          	auipc	ra,0x1
    8000315a:	01a080e7          	jalr	26(ra) # 80004170 <log_write>
        brelse(bp);
    8000315e:	854a                	mv	a0,s2
    80003160:	00000097          	auipc	ra,0x0
    80003164:	d94080e7          	jalr	-620(ra) # 80002ef4 <brelse>
  bp = bread(dev, bno);
    80003168:	85a6                	mv	a1,s1
    8000316a:	855e                	mv	a0,s7
    8000316c:	00000097          	auipc	ra,0x0
    80003170:	c58080e7          	jalr	-936(ra) # 80002dc4 <bread>
    80003174:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80003176:	40000613          	li	a2,1024
    8000317a:	4581                	li	a1,0
    8000317c:	05850513          	addi	a0,a0,88
    80003180:	ffffe097          	auipc	ra,0xffffe
    80003184:	b52080e7          	jalr	-1198(ra) # 80000cd2 <memset>
  log_write(bp);
    80003188:	854a                	mv	a0,s2
    8000318a:	00001097          	auipc	ra,0x1
    8000318e:	fe6080e7          	jalr	-26(ra) # 80004170 <log_write>
  brelse(bp);
    80003192:	854a                	mv	a0,s2
    80003194:	00000097          	auipc	ra,0x0
    80003198:	d60080e7          	jalr	-672(ra) # 80002ef4 <brelse>
}
    8000319c:	8526                	mv	a0,s1
    8000319e:	60e6                	ld	ra,88(sp)
    800031a0:	6446                	ld	s0,80(sp)
    800031a2:	64a6                	ld	s1,72(sp)
    800031a4:	6906                	ld	s2,64(sp)
    800031a6:	79e2                	ld	s3,56(sp)
    800031a8:	7a42                	ld	s4,48(sp)
    800031aa:	7aa2                	ld	s5,40(sp)
    800031ac:	7b02                	ld	s6,32(sp)
    800031ae:	6be2                	ld	s7,24(sp)
    800031b0:	6c42                	ld	s8,16(sp)
    800031b2:	6ca2                	ld	s9,8(sp)
    800031b4:	6125                	addi	sp,sp,96
    800031b6:	8082                	ret

00000000800031b8 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
    800031b8:	7179                	addi	sp,sp,-48
    800031ba:	f406                	sd	ra,40(sp)
    800031bc:	f022                	sd	s0,32(sp)
    800031be:	ec26                	sd	s1,24(sp)
    800031c0:	e84a                	sd	s2,16(sp)
    800031c2:	e44e                	sd	s3,8(sp)
    800031c4:	e052                	sd	s4,0(sp)
    800031c6:	1800                	addi	s0,sp,48
    800031c8:	892a                	mv	s2,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    800031ca:	47ad                	li	a5,11
    800031cc:	04b7fe63          	bgeu	a5,a1,80003228 <bmap+0x70>
    if((addr = ip->addrs[bn]) == 0)
      ip->addrs[bn] = addr = balloc(ip->dev);
    return addr;
  }
  bn -= NDIRECT;
    800031d0:	ff45849b          	addiw	s1,a1,-12
    800031d4:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    800031d8:	0ff00793          	li	a5,255
    800031dc:	0ae7e363          	bltu	a5,a4,80003282 <bmap+0xca>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
    800031e0:	08052583          	lw	a1,128(a0)
    800031e4:	c5ad                	beqz	a1,8000324e <bmap+0x96>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    bp = bread(ip->dev, addr);
    800031e6:	00092503          	lw	a0,0(s2)
    800031ea:	00000097          	auipc	ra,0x0
    800031ee:	bda080e7          	jalr	-1062(ra) # 80002dc4 <bread>
    800031f2:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    800031f4:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    800031f8:	02049593          	slli	a1,s1,0x20
    800031fc:	9181                	srli	a1,a1,0x20
    800031fe:	058a                	slli	a1,a1,0x2
    80003200:	00b784b3          	add	s1,a5,a1
    80003204:	0004a983          	lw	s3,0(s1)
    80003208:	04098d63          	beqz	s3,80003262 <bmap+0xaa>
      a[bn] = addr = balloc(ip->dev);
      log_write(bp);
    }
    brelse(bp);
    8000320c:	8552                	mv	a0,s4
    8000320e:	00000097          	auipc	ra,0x0
    80003212:	ce6080e7          	jalr	-794(ra) # 80002ef4 <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    80003216:	854e                	mv	a0,s3
    80003218:	70a2                	ld	ra,40(sp)
    8000321a:	7402                	ld	s0,32(sp)
    8000321c:	64e2                	ld	s1,24(sp)
    8000321e:	6942                	ld	s2,16(sp)
    80003220:	69a2                	ld	s3,8(sp)
    80003222:	6a02                	ld	s4,0(sp)
    80003224:	6145                	addi	sp,sp,48
    80003226:	8082                	ret
    if((addr = ip->addrs[bn]) == 0)
    80003228:	02059493          	slli	s1,a1,0x20
    8000322c:	9081                	srli	s1,s1,0x20
    8000322e:	048a                	slli	s1,s1,0x2
    80003230:	94aa                	add	s1,s1,a0
    80003232:	0504a983          	lw	s3,80(s1)
    80003236:	fe0990e3          	bnez	s3,80003216 <bmap+0x5e>
      ip->addrs[bn] = addr = balloc(ip->dev);
    8000323a:	4108                	lw	a0,0(a0)
    8000323c:	00000097          	auipc	ra,0x0
    80003240:	e4a080e7          	jalr	-438(ra) # 80003086 <balloc>
    80003244:	0005099b          	sext.w	s3,a0
    80003248:	0534a823          	sw	s3,80(s1)
    8000324c:	b7e9                	j	80003216 <bmap+0x5e>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    8000324e:	4108                	lw	a0,0(a0)
    80003250:	00000097          	auipc	ra,0x0
    80003254:	e36080e7          	jalr	-458(ra) # 80003086 <balloc>
    80003258:	0005059b          	sext.w	a1,a0
    8000325c:	08b92023          	sw	a1,128(s2)
    80003260:	b759                	j	800031e6 <bmap+0x2e>
      a[bn] = addr = balloc(ip->dev);
    80003262:	00092503          	lw	a0,0(s2)
    80003266:	00000097          	auipc	ra,0x0
    8000326a:	e20080e7          	jalr	-480(ra) # 80003086 <balloc>
    8000326e:	0005099b          	sext.w	s3,a0
    80003272:	0134a023          	sw	s3,0(s1)
      log_write(bp);
    80003276:	8552                	mv	a0,s4
    80003278:	00001097          	auipc	ra,0x1
    8000327c:	ef8080e7          	jalr	-264(ra) # 80004170 <log_write>
    80003280:	b771                	j	8000320c <bmap+0x54>
  panic("bmap: out of range");
    80003282:	00005517          	auipc	a0,0x5
    80003286:	2c650513          	addi	a0,a0,710 # 80008548 <syscalls+0x118>
    8000328a:	ffffd097          	auipc	ra,0xffffd
    8000328e:	2a6080e7          	jalr	678(ra) # 80000530 <panic>

0000000080003292 <iget>:
{
    80003292:	7179                	addi	sp,sp,-48
    80003294:	f406                	sd	ra,40(sp)
    80003296:	f022                	sd	s0,32(sp)
    80003298:	ec26                	sd	s1,24(sp)
    8000329a:	e84a                	sd	s2,16(sp)
    8000329c:	e44e                	sd	s3,8(sp)
    8000329e:	e052                	sd	s4,0(sp)
    800032a0:	1800                	addi	s0,sp,48
    800032a2:	89aa                	mv	s3,a0
    800032a4:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    800032a6:	0001c517          	auipc	a0,0x1c
    800032aa:	72250513          	addi	a0,a0,1826 # 8001f9c8 <itable>
    800032ae:	ffffe097          	auipc	ra,0xffffe
    800032b2:	928080e7          	jalr	-1752(ra) # 80000bd6 <acquire>
  empty = 0;
    800032b6:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    800032b8:	0001c497          	auipc	s1,0x1c
    800032bc:	72848493          	addi	s1,s1,1832 # 8001f9e0 <itable+0x18>
    800032c0:	0001e697          	auipc	a3,0x1e
    800032c4:	1b068693          	addi	a3,a3,432 # 80021470 <log>
    800032c8:	a039                	j	800032d6 <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800032ca:	02090b63          	beqz	s2,80003300 <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    800032ce:	08848493          	addi	s1,s1,136
    800032d2:	02d48a63          	beq	s1,a3,80003306 <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    800032d6:	449c                	lw	a5,8(s1)
    800032d8:	fef059e3          	blez	a5,800032ca <iget+0x38>
    800032dc:	4098                	lw	a4,0(s1)
    800032de:	ff3716e3          	bne	a4,s3,800032ca <iget+0x38>
    800032e2:	40d8                	lw	a4,4(s1)
    800032e4:	ff4713e3          	bne	a4,s4,800032ca <iget+0x38>
      ip->ref++;
    800032e8:	2785                	addiw	a5,a5,1
    800032ea:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    800032ec:	0001c517          	auipc	a0,0x1c
    800032f0:	6dc50513          	addi	a0,a0,1756 # 8001f9c8 <itable>
    800032f4:	ffffe097          	auipc	ra,0xffffe
    800032f8:	996080e7          	jalr	-1642(ra) # 80000c8a <release>
      return ip;
    800032fc:	8926                	mv	s2,s1
    800032fe:	a03d                	j	8000332c <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003300:	f7f9                	bnez	a5,800032ce <iget+0x3c>
    80003302:	8926                	mv	s2,s1
    80003304:	b7e9                	j	800032ce <iget+0x3c>
  if(empty == 0)
    80003306:	02090c63          	beqz	s2,8000333e <iget+0xac>
  ip->dev = dev;
    8000330a:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    8000330e:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80003312:	4785                	li	a5,1
    80003314:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80003318:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    8000331c:	0001c517          	auipc	a0,0x1c
    80003320:	6ac50513          	addi	a0,a0,1708 # 8001f9c8 <itable>
    80003324:	ffffe097          	auipc	ra,0xffffe
    80003328:	966080e7          	jalr	-1690(ra) # 80000c8a <release>
}
    8000332c:	854a                	mv	a0,s2
    8000332e:	70a2                	ld	ra,40(sp)
    80003330:	7402                	ld	s0,32(sp)
    80003332:	64e2                	ld	s1,24(sp)
    80003334:	6942                	ld	s2,16(sp)
    80003336:	69a2                	ld	s3,8(sp)
    80003338:	6a02                	ld	s4,0(sp)
    8000333a:	6145                	addi	sp,sp,48
    8000333c:	8082                	ret
    panic("iget: no inodes");
    8000333e:	00005517          	auipc	a0,0x5
    80003342:	22250513          	addi	a0,a0,546 # 80008560 <syscalls+0x130>
    80003346:	ffffd097          	auipc	ra,0xffffd
    8000334a:	1ea080e7          	jalr	490(ra) # 80000530 <panic>

000000008000334e <fsinit>:
fsinit(int dev) {
    8000334e:	7179                	addi	sp,sp,-48
    80003350:	f406                	sd	ra,40(sp)
    80003352:	f022                	sd	s0,32(sp)
    80003354:	ec26                	sd	s1,24(sp)
    80003356:	e84a                	sd	s2,16(sp)
    80003358:	e44e                	sd	s3,8(sp)
    8000335a:	1800                	addi	s0,sp,48
    8000335c:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    8000335e:	4585                	li	a1,1
    80003360:	00000097          	auipc	ra,0x0
    80003364:	a64080e7          	jalr	-1436(ra) # 80002dc4 <bread>
    80003368:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    8000336a:	0001c997          	auipc	s3,0x1c
    8000336e:	63e98993          	addi	s3,s3,1598 # 8001f9a8 <sb>
    80003372:	02000613          	li	a2,32
    80003376:	05850593          	addi	a1,a0,88
    8000337a:	854e                	mv	a0,s3
    8000337c:	ffffe097          	auipc	ra,0xffffe
    80003380:	9b6080e7          	jalr	-1610(ra) # 80000d32 <memmove>
  brelse(bp);
    80003384:	8526                	mv	a0,s1
    80003386:	00000097          	auipc	ra,0x0
    8000338a:	b6e080e7          	jalr	-1170(ra) # 80002ef4 <brelse>
  if(sb.magic != FSMAGIC)
    8000338e:	0009a703          	lw	a4,0(s3)
    80003392:	102037b7          	lui	a5,0x10203
    80003396:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    8000339a:	02f71263          	bne	a4,a5,800033be <fsinit+0x70>
  initlog(dev, &sb);
    8000339e:	0001c597          	auipc	a1,0x1c
    800033a2:	60a58593          	addi	a1,a1,1546 # 8001f9a8 <sb>
    800033a6:	854a                	mv	a0,s2
    800033a8:	00001097          	auipc	ra,0x1
    800033ac:	b4c080e7          	jalr	-1204(ra) # 80003ef4 <initlog>
}
    800033b0:	70a2                	ld	ra,40(sp)
    800033b2:	7402                	ld	s0,32(sp)
    800033b4:	64e2                	ld	s1,24(sp)
    800033b6:	6942                	ld	s2,16(sp)
    800033b8:	69a2                	ld	s3,8(sp)
    800033ba:	6145                	addi	sp,sp,48
    800033bc:	8082                	ret
    panic("invalid file system");
    800033be:	00005517          	auipc	a0,0x5
    800033c2:	1b250513          	addi	a0,a0,434 # 80008570 <syscalls+0x140>
    800033c6:	ffffd097          	auipc	ra,0xffffd
    800033ca:	16a080e7          	jalr	362(ra) # 80000530 <panic>

00000000800033ce <iinit>:
{
    800033ce:	7179                	addi	sp,sp,-48
    800033d0:	f406                	sd	ra,40(sp)
    800033d2:	f022                	sd	s0,32(sp)
    800033d4:	ec26                	sd	s1,24(sp)
    800033d6:	e84a                	sd	s2,16(sp)
    800033d8:	e44e                	sd	s3,8(sp)
    800033da:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    800033dc:	00005597          	auipc	a1,0x5
    800033e0:	1ac58593          	addi	a1,a1,428 # 80008588 <syscalls+0x158>
    800033e4:	0001c517          	auipc	a0,0x1c
    800033e8:	5e450513          	addi	a0,a0,1508 # 8001f9c8 <itable>
    800033ec:	ffffd097          	auipc	ra,0xffffd
    800033f0:	75a080e7          	jalr	1882(ra) # 80000b46 <initlock>
  for(i = 0; i < NINODE; i++) {
    800033f4:	0001c497          	auipc	s1,0x1c
    800033f8:	5fc48493          	addi	s1,s1,1532 # 8001f9f0 <itable+0x28>
    800033fc:	0001e997          	auipc	s3,0x1e
    80003400:	08498993          	addi	s3,s3,132 # 80021480 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80003404:	00005917          	auipc	s2,0x5
    80003408:	18c90913          	addi	s2,s2,396 # 80008590 <syscalls+0x160>
    8000340c:	85ca                	mv	a1,s2
    8000340e:	8526                	mv	a0,s1
    80003410:	00001097          	auipc	ra,0x1
    80003414:	e46080e7          	jalr	-442(ra) # 80004256 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80003418:	08848493          	addi	s1,s1,136
    8000341c:	ff3498e3          	bne	s1,s3,8000340c <iinit+0x3e>
}
    80003420:	70a2                	ld	ra,40(sp)
    80003422:	7402                	ld	s0,32(sp)
    80003424:	64e2                	ld	s1,24(sp)
    80003426:	6942                	ld	s2,16(sp)
    80003428:	69a2                	ld	s3,8(sp)
    8000342a:	6145                	addi	sp,sp,48
    8000342c:	8082                	ret

000000008000342e <ialloc>:
{
    8000342e:	715d                	addi	sp,sp,-80
    80003430:	e486                	sd	ra,72(sp)
    80003432:	e0a2                	sd	s0,64(sp)
    80003434:	fc26                	sd	s1,56(sp)
    80003436:	f84a                	sd	s2,48(sp)
    80003438:	f44e                	sd	s3,40(sp)
    8000343a:	f052                	sd	s4,32(sp)
    8000343c:	ec56                	sd	s5,24(sp)
    8000343e:	e85a                	sd	s6,16(sp)
    80003440:	e45e                	sd	s7,8(sp)
    80003442:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    80003444:	0001c717          	auipc	a4,0x1c
    80003448:	57072703          	lw	a4,1392(a4) # 8001f9b4 <sb+0xc>
    8000344c:	4785                	li	a5,1
    8000344e:	04e7fa63          	bgeu	a5,a4,800034a2 <ialloc+0x74>
    80003452:	8aaa                	mv	s5,a0
    80003454:	8bae                	mv	s7,a1
    80003456:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    80003458:	0001ca17          	auipc	s4,0x1c
    8000345c:	550a0a13          	addi	s4,s4,1360 # 8001f9a8 <sb>
    80003460:	00048b1b          	sext.w	s6,s1
    80003464:	0044d593          	srli	a1,s1,0x4
    80003468:	018a2783          	lw	a5,24(s4)
    8000346c:	9dbd                	addw	a1,a1,a5
    8000346e:	8556                	mv	a0,s5
    80003470:	00000097          	auipc	ra,0x0
    80003474:	954080e7          	jalr	-1708(ra) # 80002dc4 <bread>
    80003478:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    8000347a:	05850993          	addi	s3,a0,88
    8000347e:	00f4f793          	andi	a5,s1,15
    80003482:	079a                	slli	a5,a5,0x6
    80003484:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80003486:	00099783          	lh	a5,0(s3)
    8000348a:	c785                	beqz	a5,800034b2 <ialloc+0x84>
    brelse(bp);
    8000348c:	00000097          	auipc	ra,0x0
    80003490:	a68080e7          	jalr	-1432(ra) # 80002ef4 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80003494:	0485                	addi	s1,s1,1
    80003496:	00ca2703          	lw	a4,12(s4)
    8000349a:	0004879b          	sext.w	a5,s1
    8000349e:	fce7e1e3          	bltu	a5,a4,80003460 <ialloc+0x32>
  panic("ialloc: no inodes");
    800034a2:	00005517          	auipc	a0,0x5
    800034a6:	0f650513          	addi	a0,a0,246 # 80008598 <syscalls+0x168>
    800034aa:	ffffd097          	auipc	ra,0xffffd
    800034ae:	086080e7          	jalr	134(ra) # 80000530 <panic>
      memset(dip, 0, sizeof(*dip));
    800034b2:	04000613          	li	a2,64
    800034b6:	4581                	li	a1,0
    800034b8:	854e                	mv	a0,s3
    800034ba:	ffffe097          	auipc	ra,0xffffe
    800034be:	818080e7          	jalr	-2024(ra) # 80000cd2 <memset>
      dip->type = type;
    800034c2:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    800034c6:	854a                	mv	a0,s2
    800034c8:	00001097          	auipc	ra,0x1
    800034cc:	ca8080e7          	jalr	-856(ra) # 80004170 <log_write>
      brelse(bp);
    800034d0:	854a                	mv	a0,s2
    800034d2:	00000097          	auipc	ra,0x0
    800034d6:	a22080e7          	jalr	-1502(ra) # 80002ef4 <brelse>
      return iget(dev, inum);
    800034da:	85da                	mv	a1,s6
    800034dc:	8556                	mv	a0,s5
    800034de:	00000097          	auipc	ra,0x0
    800034e2:	db4080e7          	jalr	-588(ra) # 80003292 <iget>
}
    800034e6:	60a6                	ld	ra,72(sp)
    800034e8:	6406                	ld	s0,64(sp)
    800034ea:	74e2                	ld	s1,56(sp)
    800034ec:	7942                	ld	s2,48(sp)
    800034ee:	79a2                	ld	s3,40(sp)
    800034f0:	7a02                	ld	s4,32(sp)
    800034f2:	6ae2                	ld	s5,24(sp)
    800034f4:	6b42                	ld	s6,16(sp)
    800034f6:	6ba2                	ld	s7,8(sp)
    800034f8:	6161                	addi	sp,sp,80
    800034fa:	8082                	ret

00000000800034fc <iupdate>:
{
    800034fc:	1101                	addi	sp,sp,-32
    800034fe:	ec06                	sd	ra,24(sp)
    80003500:	e822                	sd	s0,16(sp)
    80003502:	e426                	sd	s1,8(sp)
    80003504:	e04a                	sd	s2,0(sp)
    80003506:	1000                	addi	s0,sp,32
    80003508:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    8000350a:	415c                	lw	a5,4(a0)
    8000350c:	0047d79b          	srliw	a5,a5,0x4
    80003510:	0001c597          	auipc	a1,0x1c
    80003514:	4b05a583          	lw	a1,1200(a1) # 8001f9c0 <sb+0x18>
    80003518:	9dbd                	addw	a1,a1,a5
    8000351a:	4108                	lw	a0,0(a0)
    8000351c:	00000097          	auipc	ra,0x0
    80003520:	8a8080e7          	jalr	-1880(ra) # 80002dc4 <bread>
    80003524:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003526:	05850793          	addi	a5,a0,88
    8000352a:	40c8                	lw	a0,4(s1)
    8000352c:	893d                	andi	a0,a0,15
    8000352e:	051a                	slli	a0,a0,0x6
    80003530:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    80003532:	04449703          	lh	a4,68(s1)
    80003536:	00e51023          	sh	a4,0(a0)
  dip->major = ip->major;
    8000353a:	04649703          	lh	a4,70(s1)
    8000353e:	00e51123          	sh	a4,2(a0)
  dip->minor = ip->minor;
    80003542:	04849703          	lh	a4,72(s1)
    80003546:	00e51223          	sh	a4,4(a0)
  dip->nlink = ip->nlink;
    8000354a:	04a49703          	lh	a4,74(s1)
    8000354e:	00e51323          	sh	a4,6(a0)
  dip->size = ip->size;
    80003552:	44f8                	lw	a4,76(s1)
    80003554:	c518                	sw	a4,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003556:	03400613          	li	a2,52
    8000355a:	05048593          	addi	a1,s1,80
    8000355e:	0531                	addi	a0,a0,12
    80003560:	ffffd097          	auipc	ra,0xffffd
    80003564:	7d2080e7          	jalr	2002(ra) # 80000d32 <memmove>
  log_write(bp);
    80003568:	854a                	mv	a0,s2
    8000356a:	00001097          	auipc	ra,0x1
    8000356e:	c06080e7          	jalr	-1018(ra) # 80004170 <log_write>
  brelse(bp);
    80003572:	854a                	mv	a0,s2
    80003574:	00000097          	auipc	ra,0x0
    80003578:	980080e7          	jalr	-1664(ra) # 80002ef4 <brelse>
}
    8000357c:	60e2                	ld	ra,24(sp)
    8000357e:	6442                	ld	s0,16(sp)
    80003580:	64a2                	ld	s1,8(sp)
    80003582:	6902                	ld	s2,0(sp)
    80003584:	6105                	addi	sp,sp,32
    80003586:	8082                	ret

0000000080003588 <idup>:
{
    80003588:	1101                	addi	sp,sp,-32
    8000358a:	ec06                	sd	ra,24(sp)
    8000358c:	e822                	sd	s0,16(sp)
    8000358e:	e426                	sd	s1,8(sp)
    80003590:	1000                	addi	s0,sp,32
    80003592:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003594:	0001c517          	auipc	a0,0x1c
    80003598:	43450513          	addi	a0,a0,1076 # 8001f9c8 <itable>
    8000359c:	ffffd097          	auipc	ra,0xffffd
    800035a0:	63a080e7          	jalr	1594(ra) # 80000bd6 <acquire>
  ip->ref++;
    800035a4:	449c                	lw	a5,8(s1)
    800035a6:	2785                	addiw	a5,a5,1
    800035a8:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    800035aa:	0001c517          	auipc	a0,0x1c
    800035ae:	41e50513          	addi	a0,a0,1054 # 8001f9c8 <itable>
    800035b2:	ffffd097          	auipc	ra,0xffffd
    800035b6:	6d8080e7          	jalr	1752(ra) # 80000c8a <release>
}
    800035ba:	8526                	mv	a0,s1
    800035bc:	60e2                	ld	ra,24(sp)
    800035be:	6442                	ld	s0,16(sp)
    800035c0:	64a2                	ld	s1,8(sp)
    800035c2:	6105                	addi	sp,sp,32
    800035c4:	8082                	ret

00000000800035c6 <ilock>:
{
    800035c6:	1101                	addi	sp,sp,-32
    800035c8:	ec06                	sd	ra,24(sp)
    800035ca:	e822                	sd	s0,16(sp)
    800035cc:	e426                	sd	s1,8(sp)
    800035ce:	e04a                	sd	s2,0(sp)
    800035d0:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    800035d2:	c115                	beqz	a0,800035f6 <ilock+0x30>
    800035d4:	84aa                	mv	s1,a0
    800035d6:	451c                	lw	a5,8(a0)
    800035d8:	00f05f63          	blez	a5,800035f6 <ilock+0x30>
  acquiresleep(&ip->lock);
    800035dc:	0541                	addi	a0,a0,16
    800035de:	00001097          	auipc	ra,0x1
    800035e2:	cb2080e7          	jalr	-846(ra) # 80004290 <acquiresleep>
  if(ip->valid == 0){
    800035e6:	40bc                	lw	a5,64(s1)
    800035e8:	cf99                	beqz	a5,80003606 <ilock+0x40>
}
    800035ea:	60e2                	ld	ra,24(sp)
    800035ec:	6442                	ld	s0,16(sp)
    800035ee:	64a2                	ld	s1,8(sp)
    800035f0:	6902                	ld	s2,0(sp)
    800035f2:	6105                	addi	sp,sp,32
    800035f4:	8082                	ret
    panic("ilock");
    800035f6:	00005517          	auipc	a0,0x5
    800035fa:	fba50513          	addi	a0,a0,-70 # 800085b0 <syscalls+0x180>
    800035fe:	ffffd097          	auipc	ra,0xffffd
    80003602:	f32080e7          	jalr	-206(ra) # 80000530 <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003606:	40dc                	lw	a5,4(s1)
    80003608:	0047d79b          	srliw	a5,a5,0x4
    8000360c:	0001c597          	auipc	a1,0x1c
    80003610:	3b45a583          	lw	a1,948(a1) # 8001f9c0 <sb+0x18>
    80003614:	9dbd                	addw	a1,a1,a5
    80003616:	4088                	lw	a0,0(s1)
    80003618:	fffff097          	auipc	ra,0xfffff
    8000361c:	7ac080e7          	jalr	1964(ra) # 80002dc4 <bread>
    80003620:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003622:	05850593          	addi	a1,a0,88
    80003626:	40dc                	lw	a5,4(s1)
    80003628:	8bbd                	andi	a5,a5,15
    8000362a:	079a                	slli	a5,a5,0x6
    8000362c:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    8000362e:	00059783          	lh	a5,0(a1)
    80003632:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003636:	00259783          	lh	a5,2(a1)
    8000363a:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    8000363e:	00459783          	lh	a5,4(a1)
    80003642:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003646:	00659783          	lh	a5,6(a1)
    8000364a:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    8000364e:	459c                	lw	a5,8(a1)
    80003650:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003652:	03400613          	li	a2,52
    80003656:	05b1                	addi	a1,a1,12
    80003658:	05048513          	addi	a0,s1,80
    8000365c:	ffffd097          	auipc	ra,0xffffd
    80003660:	6d6080e7          	jalr	1750(ra) # 80000d32 <memmove>
    brelse(bp);
    80003664:	854a                	mv	a0,s2
    80003666:	00000097          	auipc	ra,0x0
    8000366a:	88e080e7          	jalr	-1906(ra) # 80002ef4 <brelse>
    ip->valid = 1;
    8000366e:	4785                	li	a5,1
    80003670:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80003672:	04449783          	lh	a5,68(s1)
    80003676:	fbb5                	bnez	a5,800035ea <ilock+0x24>
      panic("ilock: no type");
    80003678:	00005517          	auipc	a0,0x5
    8000367c:	f4050513          	addi	a0,a0,-192 # 800085b8 <syscalls+0x188>
    80003680:	ffffd097          	auipc	ra,0xffffd
    80003684:	eb0080e7          	jalr	-336(ra) # 80000530 <panic>

0000000080003688 <iunlock>:
{
    80003688:	1101                	addi	sp,sp,-32
    8000368a:	ec06                	sd	ra,24(sp)
    8000368c:	e822                	sd	s0,16(sp)
    8000368e:	e426                	sd	s1,8(sp)
    80003690:	e04a                	sd	s2,0(sp)
    80003692:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003694:	c905                	beqz	a0,800036c4 <iunlock+0x3c>
    80003696:	84aa                	mv	s1,a0
    80003698:	01050913          	addi	s2,a0,16
    8000369c:	854a                	mv	a0,s2
    8000369e:	00001097          	auipc	ra,0x1
    800036a2:	c8c080e7          	jalr	-884(ra) # 8000432a <holdingsleep>
    800036a6:	cd19                	beqz	a0,800036c4 <iunlock+0x3c>
    800036a8:	449c                	lw	a5,8(s1)
    800036aa:	00f05d63          	blez	a5,800036c4 <iunlock+0x3c>
  releasesleep(&ip->lock);
    800036ae:	854a                	mv	a0,s2
    800036b0:	00001097          	auipc	ra,0x1
    800036b4:	c36080e7          	jalr	-970(ra) # 800042e6 <releasesleep>
}
    800036b8:	60e2                	ld	ra,24(sp)
    800036ba:	6442                	ld	s0,16(sp)
    800036bc:	64a2                	ld	s1,8(sp)
    800036be:	6902                	ld	s2,0(sp)
    800036c0:	6105                	addi	sp,sp,32
    800036c2:	8082                	ret
    panic("iunlock");
    800036c4:	00005517          	auipc	a0,0x5
    800036c8:	f0450513          	addi	a0,a0,-252 # 800085c8 <syscalls+0x198>
    800036cc:	ffffd097          	auipc	ra,0xffffd
    800036d0:	e64080e7          	jalr	-412(ra) # 80000530 <panic>

00000000800036d4 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    800036d4:	7179                	addi	sp,sp,-48
    800036d6:	f406                	sd	ra,40(sp)
    800036d8:	f022                	sd	s0,32(sp)
    800036da:	ec26                	sd	s1,24(sp)
    800036dc:	e84a                	sd	s2,16(sp)
    800036de:	e44e                	sd	s3,8(sp)
    800036e0:	e052                	sd	s4,0(sp)
    800036e2:	1800                	addi	s0,sp,48
    800036e4:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    800036e6:	05050493          	addi	s1,a0,80
    800036ea:	08050913          	addi	s2,a0,128
    800036ee:	a021                	j	800036f6 <itrunc+0x22>
    800036f0:	0491                	addi	s1,s1,4
    800036f2:	01248d63          	beq	s1,s2,8000370c <itrunc+0x38>
    if(ip->addrs[i]){
    800036f6:	408c                	lw	a1,0(s1)
    800036f8:	dde5                	beqz	a1,800036f0 <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    800036fa:	0009a503          	lw	a0,0(s3)
    800036fe:	00000097          	auipc	ra,0x0
    80003702:	90c080e7          	jalr	-1780(ra) # 8000300a <bfree>
      ip->addrs[i] = 0;
    80003706:	0004a023          	sw	zero,0(s1)
    8000370a:	b7dd                	j	800036f0 <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    8000370c:	0809a583          	lw	a1,128(s3)
    80003710:	e185                	bnez	a1,80003730 <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003712:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003716:	854e                	mv	a0,s3
    80003718:	00000097          	auipc	ra,0x0
    8000371c:	de4080e7          	jalr	-540(ra) # 800034fc <iupdate>
}
    80003720:	70a2                	ld	ra,40(sp)
    80003722:	7402                	ld	s0,32(sp)
    80003724:	64e2                	ld	s1,24(sp)
    80003726:	6942                	ld	s2,16(sp)
    80003728:	69a2                	ld	s3,8(sp)
    8000372a:	6a02                	ld	s4,0(sp)
    8000372c:	6145                	addi	sp,sp,48
    8000372e:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003730:	0009a503          	lw	a0,0(s3)
    80003734:	fffff097          	auipc	ra,0xfffff
    80003738:	690080e7          	jalr	1680(ra) # 80002dc4 <bread>
    8000373c:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    8000373e:	05850493          	addi	s1,a0,88
    80003742:	45850913          	addi	s2,a0,1112
    80003746:	a811                	j	8000375a <itrunc+0x86>
        bfree(ip->dev, a[j]);
    80003748:	0009a503          	lw	a0,0(s3)
    8000374c:	00000097          	auipc	ra,0x0
    80003750:	8be080e7          	jalr	-1858(ra) # 8000300a <bfree>
    for(j = 0; j < NINDIRECT; j++){
    80003754:	0491                	addi	s1,s1,4
    80003756:	01248563          	beq	s1,s2,80003760 <itrunc+0x8c>
      if(a[j])
    8000375a:	408c                	lw	a1,0(s1)
    8000375c:	dde5                	beqz	a1,80003754 <itrunc+0x80>
    8000375e:	b7ed                	j	80003748 <itrunc+0x74>
    brelse(bp);
    80003760:	8552                	mv	a0,s4
    80003762:	fffff097          	auipc	ra,0xfffff
    80003766:	792080e7          	jalr	1938(ra) # 80002ef4 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    8000376a:	0809a583          	lw	a1,128(s3)
    8000376e:	0009a503          	lw	a0,0(s3)
    80003772:	00000097          	auipc	ra,0x0
    80003776:	898080e7          	jalr	-1896(ra) # 8000300a <bfree>
    ip->addrs[NDIRECT] = 0;
    8000377a:	0809a023          	sw	zero,128(s3)
    8000377e:	bf51                	j	80003712 <itrunc+0x3e>

0000000080003780 <iput>:
{
    80003780:	1101                	addi	sp,sp,-32
    80003782:	ec06                	sd	ra,24(sp)
    80003784:	e822                	sd	s0,16(sp)
    80003786:	e426                	sd	s1,8(sp)
    80003788:	e04a                	sd	s2,0(sp)
    8000378a:	1000                	addi	s0,sp,32
    8000378c:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    8000378e:	0001c517          	auipc	a0,0x1c
    80003792:	23a50513          	addi	a0,a0,570 # 8001f9c8 <itable>
    80003796:	ffffd097          	auipc	ra,0xffffd
    8000379a:	440080e7          	jalr	1088(ra) # 80000bd6 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    8000379e:	4498                	lw	a4,8(s1)
    800037a0:	4785                	li	a5,1
    800037a2:	02f70363          	beq	a4,a5,800037c8 <iput+0x48>
  ip->ref--;
    800037a6:	449c                	lw	a5,8(s1)
    800037a8:	37fd                	addiw	a5,a5,-1
    800037aa:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    800037ac:	0001c517          	auipc	a0,0x1c
    800037b0:	21c50513          	addi	a0,a0,540 # 8001f9c8 <itable>
    800037b4:	ffffd097          	auipc	ra,0xffffd
    800037b8:	4d6080e7          	jalr	1238(ra) # 80000c8a <release>
}
    800037bc:	60e2                	ld	ra,24(sp)
    800037be:	6442                	ld	s0,16(sp)
    800037c0:	64a2                	ld	s1,8(sp)
    800037c2:	6902                	ld	s2,0(sp)
    800037c4:	6105                	addi	sp,sp,32
    800037c6:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    800037c8:	40bc                	lw	a5,64(s1)
    800037ca:	dff1                	beqz	a5,800037a6 <iput+0x26>
    800037cc:	04a49783          	lh	a5,74(s1)
    800037d0:	fbf9                	bnez	a5,800037a6 <iput+0x26>
    acquiresleep(&ip->lock);
    800037d2:	01048913          	addi	s2,s1,16
    800037d6:	854a                	mv	a0,s2
    800037d8:	00001097          	auipc	ra,0x1
    800037dc:	ab8080e7          	jalr	-1352(ra) # 80004290 <acquiresleep>
    release(&itable.lock);
    800037e0:	0001c517          	auipc	a0,0x1c
    800037e4:	1e850513          	addi	a0,a0,488 # 8001f9c8 <itable>
    800037e8:	ffffd097          	auipc	ra,0xffffd
    800037ec:	4a2080e7          	jalr	1186(ra) # 80000c8a <release>
    itrunc(ip);
    800037f0:	8526                	mv	a0,s1
    800037f2:	00000097          	auipc	ra,0x0
    800037f6:	ee2080e7          	jalr	-286(ra) # 800036d4 <itrunc>
    ip->type = 0;
    800037fa:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    800037fe:	8526                	mv	a0,s1
    80003800:	00000097          	auipc	ra,0x0
    80003804:	cfc080e7          	jalr	-772(ra) # 800034fc <iupdate>
    ip->valid = 0;
    80003808:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    8000380c:	854a                	mv	a0,s2
    8000380e:	00001097          	auipc	ra,0x1
    80003812:	ad8080e7          	jalr	-1320(ra) # 800042e6 <releasesleep>
    acquire(&itable.lock);
    80003816:	0001c517          	auipc	a0,0x1c
    8000381a:	1b250513          	addi	a0,a0,434 # 8001f9c8 <itable>
    8000381e:	ffffd097          	auipc	ra,0xffffd
    80003822:	3b8080e7          	jalr	952(ra) # 80000bd6 <acquire>
    80003826:	b741                	j	800037a6 <iput+0x26>

0000000080003828 <iunlockput>:
{
    80003828:	1101                	addi	sp,sp,-32
    8000382a:	ec06                	sd	ra,24(sp)
    8000382c:	e822                	sd	s0,16(sp)
    8000382e:	e426                	sd	s1,8(sp)
    80003830:	1000                	addi	s0,sp,32
    80003832:	84aa                	mv	s1,a0
  iunlock(ip);
    80003834:	00000097          	auipc	ra,0x0
    80003838:	e54080e7          	jalr	-428(ra) # 80003688 <iunlock>
  iput(ip);
    8000383c:	8526                	mv	a0,s1
    8000383e:	00000097          	auipc	ra,0x0
    80003842:	f42080e7          	jalr	-190(ra) # 80003780 <iput>
}
    80003846:	60e2                	ld	ra,24(sp)
    80003848:	6442                	ld	s0,16(sp)
    8000384a:	64a2                	ld	s1,8(sp)
    8000384c:	6105                	addi	sp,sp,32
    8000384e:	8082                	ret

0000000080003850 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003850:	1141                	addi	sp,sp,-16
    80003852:	e422                	sd	s0,8(sp)
    80003854:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003856:	411c                	lw	a5,0(a0)
    80003858:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    8000385a:	415c                	lw	a5,4(a0)
    8000385c:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    8000385e:	04451783          	lh	a5,68(a0)
    80003862:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003866:	04a51783          	lh	a5,74(a0)
    8000386a:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    8000386e:	04c56783          	lwu	a5,76(a0)
    80003872:	e99c                	sd	a5,16(a1)
}
    80003874:	6422                	ld	s0,8(sp)
    80003876:	0141                	addi	sp,sp,16
    80003878:	8082                	ret

000000008000387a <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    8000387a:	457c                	lw	a5,76(a0)
    8000387c:	0ed7e963          	bltu	a5,a3,8000396e <readi+0xf4>
{
    80003880:	7159                	addi	sp,sp,-112
    80003882:	f486                	sd	ra,104(sp)
    80003884:	f0a2                	sd	s0,96(sp)
    80003886:	eca6                	sd	s1,88(sp)
    80003888:	e8ca                	sd	s2,80(sp)
    8000388a:	e4ce                	sd	s3,72(sp)
    8000388c:	e0d2                	sd	s4,64(sp)
    8000388e:	fc56                	sd	s5,56(sp)
    80003890:	f85a                	sd	s6,48(sp)
    80003892:	f45e                	sd	s7,40(sp)
    80003894:	f062                	sd	s8,32(sp)
    80003896:	ec66                	sd	s9,24(sp)
    80003898:	e86a                	sd	s10,16(sp)
    8000389a:	e46e                	sd	s11,8(sp)
    8000389c:	1880                	addi	s0,sp,112
    8000389e:	8baa                	mv	s7,a0
    800038a0:	8c2e                	mv	s8,a1
    800038a2:	8ab2                	mv	s5,a2
    800038a4:	84b6                	mv	s1,a3
    800038a6:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    800038a8:	9f35                	addw	a4,a4,a3
    return 0;
    800038aa:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    800038ac:	0ad76063          	bltu	a4,a3,8000394c <readi+0xd2>
  if(off + n > ip->size)
    800038b0:	00e7f463          	bgeu	a5,a4,800038b8 <readi+0x3e>
    n = ip->size - off;
    800038b4:	40d78b3b          	subw	s6,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800038b8:	0a0b0963          	beqz	s6,8000396a <readi+0xf0>
    800038bc:	4981                	li	s3,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    800038be:	40000d13          	li	s10,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    800038c2:	5cfd                	li	s9,-1
    800038c4:	a82d                	j	800038fe <readi+0x84>
    800038c6:	020a1d93          	slli	s11,s4,0x20
    800038ca:	020ddd93          	srli	s11,s11,0x20
    800038ce:	05890613          	addi	a2,s2,88
    800038d2:	86ee                	mv	a3,s11
    800038d4:	963a                	add	a2,a2,a4
    800038d6:	85d6                	mv	a1,s5
    800038d8:	8562                	mv	a0,s8
    800038da:	fffff097          	auipc	ra,0xfffff
    800038de:	b20080e7          	jalr	-1248(ra) # 800023fa <either_copyout>
    800038e2:	05950d63          	beq	a0,s9,8000393c <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    800038e6:	854a                	mv	a0,s2
    800038e8:	fffff097          	auipc	ra,0xfffff
    800038ec:	60c080e7          	jalr	1548(ra) # 80002ef4 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800038f0:	013a09bb          	addw	s3,s4,s3
    800038f4:	009a04bb          	addw	s1,s4,s1
    800038f8:	9aee                	add	s5,s5,s11
    800038fa:	0569f763          	bgeu	s3,s6,80003948 <readi+0xce>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    800038fe:	000ba903          	lw	s2,0(s7)
    80003902:	00a4d59b          	srliw	a1,s1,0xa
    80003906:	855e                	mv	a0,s7
    80003908:	00000097          	auipc	ra,0x0
    8000390c:	8b0080e7          	jalr	-1872(ra) # 800031b8 <bmap>
    80003910:	0005059b          	sext.w	a1,a0
    80003914:	854a                	mv	a0,s2
    80003916:	fffff097          	auipc	ra,0xfffff
    8000391a:	4ae080e7          	jalr	1198(ra) # 80002dc4 <bread>
    8000391e:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003920:	3ff4f713          	andi	a4,s1,1023
    80003924:	40ed07bb          	subw	a5,s10,a4
    80003928:	413b06bb          	subw	a3,s6,s3
    8000392c:	8a3e                	mv	s4,a5
    8000392e:	2781                	sext.w	a5,a5
    80003930:	0006861b          	sext.w	a2,a3
    80003934:	f8f679e3          	bgeu	a2,a5,800038c6 <readi+0x4c>
    80003938:	8a36                	mv	s4,a3
    8000393a:	b771                	j	800038c6 <readi+0x4c>
      brelse(bp);
    8000393c:	854a                	mv	a0,s2
    8000393e:	fffff097          	auipc	ra,0xfffff
    80003942:	5b6080e7          	jalr	1462(ra) # 80002ef4 <brelse>
      tot = -1;
    80003946:	59fd                	li	s3,-1
  }
  return tot;
    80003948:	0009851b          	sext.w	a0,s3
}
    8000394c:	70a6                	ld	ra,104(sp)
    8000394e:	7406                	ld	s0,96(sp)
    80003950:	64e6                	ld	s1,88(sp)
    80003952:	6946                	ld	s2,80(sp)
    80003954:	69a6                	ld	s3,72(sp)
    80003956:	6a06                	ld	s4,64(sp)
    80003958:	7ae2                	ld	s5,56(sp)
    8000395a:	7b42                	ld	s6,48(sp)
    8000395c:	7ba2                	ld	s7,40(sp)
    8000395e:	7c02                	ld	s8,32(sp)
    80003960:	6ce2                	ld	s9,24(sp)
    80003962:	6d42                	ld	s10,16(sp)
    80003964:	6da2                	ld	s11,8(sp)
    80003966:	6165                	addi	sp,sp,112
    80003968:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    8000396a:	89da                	mv	s3,s6
    8000396c:	bff1                	j	80003948 <readi+0xce>
    return 0;
    8000396e:	4501                	li	a0,0
}
    80003970:	8082                	ret

0000000080003972 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003972:	457c                	lw	a5,76(a0)
    80003974:	10d7e863          	bltu	a5,a3,80003a84 <writei+0x112>
{
    80003978:	7159                	addi	sp,sp,-112
    8000397a:	f486                	sd	ra,104(sp)
    8000397c:	f0a2                	sd	s0,96(sp)
    8000397e:	eca6                	sd	s1,88(sp)
    80003980:	e8ca                	sd	s2,80(sp)
    80003982:	e4ce                	sd	s3,72(sp)
    80003984:	e0d2                	sd	s4,64(sp)
    80003986:	fc56                	sd	s5,56(sp)
    80003988:	f85a                	sd	s6,48(sp)
    8000398a:	f45e                	sd	s7,40(sp)
    8000398c:	f062                	sd	s8,32(sp)
    8000398e:	ec66                	sd	s9,24(sp)
    80003990:	e86a                	sd	s10,16(sp)
    80003992:	e46e                	sd	s11,8(sp)
    80003994:	1880                	addi	s0,sp,112
    80003996:	8b2a                	mv	s6,a0
    80003998:	8c2e                	mv	s8,a1
    8000399a:	8ab2                	mv	s5,a2
    8000399c:	8936                	mv	s2,a3
    8000399e:	8bba                	mv	s7,a4
  if(off > ip->size || off + n < off)
    800039a0:	00e687bb          	addw	a5,a3,a4
    800039a4:	0ed7e263          	bltu	a5,a3,80003a88 <writei+0x116>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    800039a8:	00043737          	lui	a4,0x43
    800039ac:	0ef76063          	bltu	a4,a5,80003a8c <writei+0x11a>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    800039b0:	0c0b8863          	beqz	s7,80003a80 <writei+0x10e>
    800039b4:	4a01                	li	s4,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    800039b6:	40000d13          	li	s10,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    800039ba:	5cfd                	li	s9,-1
    800039bc:	a091                	j	80003a00 <writei+0x8e>
    800039be:	02099d93          	slli	s11,s3,0x20
    800039c2:	020ddd93          	srli	s11,s11,0x20
    800039c6:	05848513          	addi	a0,s1,88
    800039ca:	86ee                	mv	a3,s11
    800039cc:	8656                	mv	a2,s5
    800039ce:	85e2                	mv	a1,s8
    800039d0:	953a                	add	a0,a0,a4
    800039d2:	fffff097          	auipc	ra,0xfffff
    800039d6:	a7e080e7          	jalr	-1410(ra) # 80002450 <either_copyin>
    800039da:	07950263          	beq	a0,s9,80003a3e <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    800039de:	8526                	mv	a0,s1
    800039e0:	00000097          	auipc	ra,0x0
    800039e4:	790080e7          	jalr	1936(ra) # 80004170 <log_write>
    brelse(bp);
    800039e8:	8526                	mv	a0,s1
    800039ea:	fffff097          	auipc	ra,0xfffff
    800039ee:	50a080e7          	jalr	1290(ra) # 80002ef4 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    800039f2:	01498a3b          	addw	s4,s3,s4
    800039f6:	0129893b          	addw	s2,s3,s2
    800039fa:	9aee                	add	s5,s5,s11
    800039fc:	057a7663          	bgeu	s4,s7,80003a48 <writei+0xd6>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80003a00:	000b2483          	lw	s1,0(s6)
    80003a04:	00a9559b          	srliw	a1,s2,0xa
    80003a08:	855a                	mv	a0,s6
    80003a0a:	fffff097          	auipc	ra,0xfffff
    80003a0e:	7ae080e7          	jalr	1966(ra) # 800031b8 <bmap>
    80003a12:	0005059b          	sext.w	a1,a0
    80003a16:	8526                	mv	a0,s1
    80003a18:	fffff097          	auipc	ra,0xfffff
    80003a1c:	3ac080e7          	jalr	940(ra) # 80002dc4 <bread>
    80003a20:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003a22:	3ff97713          	andi	a4,s2,1023
    80003a26:	40ed07bb          	subw	a5,s10,a4
    80003a2a:	414b86bb          	subw	a3,s7,s4
    80003a2e:	89be                	mv	s3,a5
    80003a30:	2781                	sext.w	a5,a5
    80003a32:	0006861b          	sext.w	a2,a3
    80003a36:	f8f674e3          	bgeu	a2,a5,800039be <writei+0x4c>
    80003a3a:	89b6                	mv	s3,a3
    80003a3c:	b749                	j	800039be <writei+0x4c>
      brelse(bp);
    80003a3e:	8526                	mv	a0,s1
    80003a40:	fffff097          	auipc	ra,0xfffff
    80003a44:	4b4080e7          	jalr	1204(ra) # 80002ef4 <brelse>
  }

  if(off > ip->size)
    80003a48:	04cb2783          	lw	a5,76(s6)
    80003a4c:	0127f463          	bgeu	a5,s2,80003a54 <writei+0xe2>
    ip->size = off;
    80003a50:	052b2623          	sw	s2,76(s6)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80003a54:	855a                	mv	a0,s6
    80003a56:	00000097          	auipc	ra,0x0
    80003a5a:	aa6080e7          	jalr	-1370(ra) # 800034fc <iupdate>

  return tot;
    80003a5e:	000a051b          	sext.w	a0,s4
}
    80003a62:	70a6                	ld	ra,104(sp)
    80003a64:	7406                	ld	s0,96(sp)
    80003a66:	64e6                	ld	s1,88(sp)
    80003a68:	6946                	ld	s2,80(sp)
    80003a6a:	69a6                	ld	s3,72(sp)
    80003a6c:	6a06                	ld	s4,64(sp)
    80003a6e:	7ae2                	ld	s5,56(sp)
    80003a70:	7b42                	ld	s6,48(sp)
    80003a72:	7ba2                	ld	s7,40(sp)
    80003a74:	7c02                	ld	s8,32(sp)
    80003a76:	6ce2                	ld	s9,24(sp)
    80003a78:	6d42                	ld	s10,16(sp)
    80003a7a:	6da2                	ld	s11,8(sp)
    80003a7c:	6165                	addi	sp,sp,112
    80003a7e:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003a80:	8a5e                	mv	s4,s7
    80003a82:	bfc9                	j	80003a54 <writei+0xe2>
    return -1;
    80003a84:	557d                	li	a0,-1
}
    80003a86:	8082                	ret
    return -1;
    80003a88:	557d                	li	a0,-1
    80003a8a:	bfe1                	j	80003a62 <writei+0xf0>
    return -1;
    80003a8c:	557d                	li	a0,-1
    80003a8e:	bfd1                	j	80003a62 <writei+0xf0>

0000000080003a90 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003a90:	1141                	addi	sp,sp,-16
    80003a92:	e406                	sd	ra,8(sp)
    80003a94:	e022                	sd	s0,0(sp)
    80003a96:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003a98:	4639                	li	a2,14
    80003a9a:	ffffd097          	auipc	ra,0xffffd
    80003a9e:	314080e7          	jalr	788(ra) # 80000dae <strncmp>
}
    80003aa2:	60a2                	ld	ra,8(sp)
    80003aa4:	6402                	ld	s0,0(sp)
    80003aa6:	0141                	addi	sp,sp,16
    80003aa8:	8082                	ret

0000000080003aaa <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003aaa:	7139                	addi	sp,sp,-64
    80003aac:	fc06                	sd	ra,56(sp)
    80003aae:	f822                	sd	s0,48(sp)
    80003ab0:	f426                	sd	s1,40(sp)
    80003ab2:	f04a                	sd	s2,32(sp)
    80003ab4:	ec4e                	sd	s3,24(sp)
    80003ab6:	e852                	sd	s4,16(sp)
    80003ab8:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003aba:	04451703          	lh	a4,68(a0)
    80003abe:	4785                	li	a5,1
    80003ac0:	00f71a63          	bne	a4,a5,80003ad4 <dirlookup+0x2a>
    80003ac4:	892a                	mv	s2,a0
    80003ac6:	89ae                	mv	s3,a1
    80003ac8:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003aca:	457c                	lw	a5,76(a0)
    80003acc:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003ace:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003ad0:	e79d                	bnez	a5,80003afe <dirlookup+0x54>
    80003ad2:	a8a5                	j	80003b4a <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80003ad4:	00005517          	auipc	a0,0x5
    80003ad8:	afc50513          	addi	a0,a0,-1284 # 800085d0 <syscalls+0x1a0>
    80003adc:	ffffd097          	auipc	ra,0xffffd
    80003ae0:	a54080e7          	jalr	-1452(ra) # 80000530 <panic>
      panic("dirlookup read");
    80003ae4:	00005517          	auipc	a0,0x5
    80003ae8:	b0450513          	addi	a0,a0,-1276 # 800085e8 <syscalls+0x1b8>
    80003aec:	ffffd097          	auipc	ra,0xffffd
    80003af0:	a44080e7          	jalr	-1468(ra) # 80000530 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003af4:	24c1                	addiw	s1,s1,16
    80003af6:	04c92783          	lw	a5,76(s2)
    80003afa:	04f4f763          	bgeu	s1,a5,80003b48 <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003afe:	4741                	li	a4,16
    80003b00:	86a6                	mv	a3,s1
    80003b02:	fc040613          	addi	a2,s0,-64
    80003b06:	4581                	li	a1,0
    80003b08:	854a                	mv	a0,s2
    80003b0a:	00000097          	auipc	ra,0x0
    80003b0e:	d70080e7          	jalr	-656(ra) # 8000387a <readi>
    80003b12:	47c1                	li	a5,16
    80003b14:	fcf518e3          	bne	a0,a5,80003ae4 <dirlookup+0x3a>
    if(de.inum == 0)
    80003b18:	fc045783          	lhu	a5,-64(s0)
    80003b1c:	dfe1                	beqz	a5,80003af4 <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    80003b1e:	fc240593          	addi	a1,s0,-62
    80003b22:	854e                	mv	a0,s3
    80003b24:	00000097          	auipc	ra,0x0
    80003b28:	f6c080e7          	jalr	-148(ra) # 80003a90 <namecmp>
    80003b2c:	f561                	bnez	a0,80003af4 <dirlookup+0x4a>
      if(poff)
    80003b2e:	000a0463          	beqz	s4,80003b36 <dirlookup+0x8c>
        *poff = off;
    80003b32:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80003b36:	fc045583          	lhu	a1,-64(s0)
    80003b3a:	00092503          	lw	a0,0(s2)
    80003b3e:	fffff097          	auipc	ra,0xfffff
    80003b42:	754080e7          	jalr	1876(ra) # 80003292 <iget>
    80003b46:	a011                	j	80003b4a <dirlookup+0xa0>
  return 0;
    80003b48:	4501                	li	a0,0
}
    80003b4a:	70e2                	ld	ra,56(sp)
    80003b4c:	7442                	ld	s0,48(sp)
    80003b4e:	74a2                	ld	s1,40(sp)
    80003b50:	7902                	ld	s2,32(sp)
    80003b52:	69e2                	ld	s3,24(sp)
    80003b54:	6a42                	ld	s4,16(sp)
    80003b56:	6121                	addi	sp,sp,64
    80003b58:	8082                	ret

0000000080003b5a <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003b5a:	711d                	addi	sp,sp,-96
    80003b5c:	ec86                	sd	ra,88(sp)
    80003b5e:	e8a2                	sd	s0,80(sp)
    80003b60:	e4a6                	sd	s1,72(sp)
    80003b62:	e0ca                	sd	s2,64(sp)
    80003b64:	fc4e                	sd	s3,56(sp)
    80003b66:	f852                	sd	s4,48(sp)
    80003b68:	f456                	sd	s5,40(sp)
    80003b6a:	f05a                	sd	s6,32(sp)
    80003b6c:	ec5e                	sd	s7,24(sp)
    80003b6e:	e862                	sd	s8,16(sp)
    80003b70:	e466                	sd	s9,8(sp)
    80003b72:	1080                	addi	s0,sp,96
    80003b74:	84aa                	mv	s1,a0
    80003b76:	8b2e                	mv	s6,a1
    80003b78:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003b7a:	00054703          	lbu	a4,0(a0)
    80003b7e:	02f00793          	li	a5,47
    80003b82:	02f70363          	beq	a4,a5,80003ba8 <namex+0x4e>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003b86:	ffffe097          	auipc	ra,0xffffe
    80003b8a:	e0e080e7          	jalr	-498(ra) # 80001994 <myproc>
    80003b8e:	15853503          	ld	a0,344(a0)
    80003b92:	00000097          	auipc	ra,0x0
    80003b96:	9f6080e7          	jalr	-1546(ra) # 80003588 <idup>
    80003b9a:	89aa                	mv	s3,a0
  while(*path == '/')
    80003b9c:	02f00913          	li	s2,47
  len = path - s;
    80003ba0:	4b81                	li	s7,0
  if(len >= DIRSIZ)
    80003ba2:	4cb5                	li	s9,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003ba4:	4c05                	li	s8,1
    80003ba6:	a865                	j	80003c5e <namex+0x104>
    ip = iget(ROOTDEV, ROOTINO);
    80003ba8:	4585                	li	a1,1
    80003baa:	4505                	li	a0,1
    80003bac:	fffff097          	auipc	ra,0xfffff
    80003bb0:	6e6080e7          	jalr	1766(ra) # 80003292 <iget>
    80003bb4:	89aa                	mv	s3,a0
    80003bb6:	b7dd                	j	80003b9c <namex+0x42>
      iunlockput(ip);
    80003bb8:	854e                	mv	a0,s3
    80003bba:	00000097          	auipc	ra,0x0
    80003bbe:	c6e080e7          	jalr	-914(ra) # 80003828 <iunlockput>
      return 0;
    80003bc2:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003bc4:	854e                	mv	a0,s3
    80003bc6:	60e6                	ld	ra,88(sp)
    80003bc8:	6446                	ld	s0,80(sp)
    80003bca:	64a6                	ld	s1,72(sp)
    80003bcc:	6906                	ld	s2,64(sp)
    80003bce:	79e2                	ld	s3,56(sp)
    80003bd0:	7a42                	ld	s4,48(sp)
    80003bd2:	7aa2                	ld	s5,40(sp)
    80003bd4:	7b02                	ld	s6,32(sp)
    80003bd6:	6be2                	ld	s7,24(sp)
    80003bd8:	6c42                	ld	s8,16(sp)
    80003bda:	6ca2                	ld	s9,8(sp)
    80003bdc:	6125                	addi	sp,sp,96
    80003bde:	8082                	ret
      iunlock(ip);
    80003be0:	854e                	mv	a0,s3
    80003be2:	00000097          	auipc	ra,0x0
    80003be6:	aa6080e7          	jalr	-1370(ra) # 80003688 <iunlock>
      return ip;
    80003bea:	bfe9                	j	80003bc4 <namex+0x6a>
      iunlockput(ip);
    80003bec:	854e                	mv	a0,s3
    80003bee:	00000097          	auipc	ra,0x0
    80003bf2:	c3a080e7          	jalr	-966(ra) # 80003828 <iunlockput>
      return 0;
    80003bf6:	89d2                	mv	s3,s4
    80003bf8:	b7f1                	j	80003bc4 <namex+0x6a>
  len = path - s;
    80003bfa:	40b48633          	sub	a2,s1,a1
    80003bfe:	00060a1b          	sext.w	s4,a2
  if(len >= DIRSIZ)
    80003c02:	094cd463          	bge	s9,s4,80003c8a <namex+0x130>
    memmove(name, s, DIRSIZ);
    80003c06:	4639                	li	a2,14
    80003c08:	8556                	mv	a0,s5
    80003c0a:	ffffd097          	auipc	ra,0xffffd
    80003c0e:	128080e7          	jalr	296(ra) # 80000d32 <memmove>
  while(*path == '/')
    80003c12:	0004c783          	lbu	a5,0(s1)
    80003c16:	01279763          	bne	a5,s2,80003c24 <namex+0xca>
    path++;
    80003c1a:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003c1c:	0004c783          	lbu	a5,0(s1)
    80003c20:	ff278de3          	beq	a5,s2,80003c1a <namex+0xc0>
    ilock(ip);
    80003c24:	854e                	mv	a0,s3
    80003c26:	00000097          	auipc	ra,0x0
    80003c2a:	9a0080e7          	jalr	-1632(ra) # 800035c6 <ilock>
    if(ip->type != T_DIR){
    80003c2e:	04499783          	lh	a5,68(s3)
    80003c32:	f98793e3          	bne	a5,s8,80003bb8 <namex+0x5e>
    if(nameiparent && *path == '\0'){
    80003c36:	000b0563          	beqz	s6,80003c40 <namex+0xe6>
    80003c3a:	0004c783          	lbu	a5,0(s1)
    80003c3e:	d3cd                	beqz	a5,80003be0 <namex+0x86>
    if((next = dirlookup(ip, name, 0)) == 0){
    80003c40:	865e                	mv	a2,s7
    80003c42:	85d6                	mv	a1,s5
    80003c44:	854e                	mv	a0,s3
    80003c46:	00000097          	auipc	ra,0x0
    80003c4a:	e64080e7          	jalr	-412(ra) # 80003aaa <dirlookup>
    80003c4e:	8a2a                	mv	s4,a0
    80003c50:	dd51                	beqz	a0,80003bec <namex+0x92>
    iunlockput(ip);
    80003c52:	854e                	mv	a0,s3
    80003c54:	00000097          	auipc	ra,0x0
    80003c58:	bd4080e7          	jalr	-1068(ra) # 80003828 <iunlockput>
    ip = next;
    80003c5c:	89d2                	mv	s3,s4
  while(*path == '/')
    80003c5e:	0004c783          	lbu	a5,0(s1)
    80003c62:	05279763          	bne	a5,s2,80003cb0 <namex+0x156>
    path++;
    80003c66:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003c68:	0004c783          	lbu	a5,0(s1)
    80003c6c:	ff278de3          	beq	a5,s2,80003c66 <namex+0x10c>
  if(*path == 0)
    80003c70:	c79d                	beqz	a5,80003c9e <namex+0x144>
    path++;
    80003c72:	85a6                	mv	a1,s1
  len = path - s;
    80003c74:	8a5e                	mv	s4,s7
    80003c76:	865e                	mv	a2,s7
  while(*path != '/' && *path != 0)
    80003c78:	01278963          	beq	a5,s2,80003c8a <namex+0x130>
    80003c7c:	dfbd                	beqz	a5,80003bfa <namex+0xa0>
    path++;
    80003c7e:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    80003c80:	0004c783          	lbu	a5,0(s1)
    80003c84:	ff279ce3          	bne	a5,s2,80003c7c <namex+0x122>
    80003c88:	bf8d                	j	80003bfa <namex+0xa0>
    memmove(name, s, len);
    80003c8a:	2601                	sext.w	a2,a2
    80003c8c:	8556                	mv	a0,s5
    80003c8e:	ffffd097          	auipc	ra,0xffffd
    80003c92:	0a4080e7          	jalr	164(ra) # 80000d32 <memmove>
    name[len] = 0;
    80003c96:	9a56                	add	s4,s4,s5
    80003c98:	000a0023          	sb	zero,0(s4)
    80003c9c:	bf9d                	j	80003c12 <namex+0xb8>
  if(nameiparent){
    80003c9e:	f20b03e3          	beqz	s6,80003bc4 <namex+0x6a>
    iput(ip);
    80003ca2:	854e                	mv	a0,s3
    80003ca4:	00000097          	auipc	ra,0x0
    80003ca8:	adc080e7          	jalr	-1316(ra) # 80003780 <iput>
    return 0;
    80003cac:	4981                	li	s3,0
    80003cae:	bf19                	j	80003bc4 <namex+0x6a>
  if(*path == 0)
    80003cb0:	d7fd                	beqz	a5,80003c9e <namex+0x144>
  while(*path != '/' && *path != 0)
    80003cb2:	0004c783          	lbu	a5,0(s1)
    80003cb6:	85a6                	mv	a1,s1
    80003cb8:	b7d1                	j	80003c7c <namex+0x122>

0000000080003cba <dirlink>:
{
    80003cba:	7139                	addi	sp,sp,-64
    80003cbc:	fc06                	sd	ra,56(sp)
    80003cbe:	f822                	sd	s0,48(sp)
    80003cc0:	f426                	sd	s1,40(sp)
    80003cc2:	f04a                	sd	s2,32(sp)
    80003cc4:	ec4e                	sd	s3,24(sp)
    80003cc6:	e852                	sd	s4,16(sp)
    80003cc8:	0080                	addi	s0,sp,64
    80003cca:	892a                	mv	s2,a0
    80003ccc:	8a2e                	mv	s4,a1
    80003cce:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80003cd0:	4601                	li	a2,0
    80003cd2:	00000097          	auipc	ra,0x0
    80003cd6:	dd8080e7          	jalr	-552(ra) # 80003aaa <dirlookup>
    80003cda:	e93d                	bnez	a0,80003d50 <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003cdc:	04c92483          	lw	s1,76(s2)
    80003ce0:	c49d                	beqz	s1,80003d0e <dirlink+0x54>
    80003ce2:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003ce4:	4741                	li	a4,16
    80003ce6:	86a6                	mv	a3,s1
    80003ce8:	fc040613          	addi	a2,s0,-64
    80003cec:	4581                	li	a1,0
    80003cee:	854a                	mv	a0,s2
    80003cf0:	00000097          	auipc	ra,0x0
    80003cf4:	b8a080e7          	jalr	-1142(ra) # 8000387a <readi>
    80003cf8:	47c1                	li	a5,16
    80003cfa:	06f51163          	bne	a0,a5,80003d5c <dirlink+0xa2>
    if(de.inum == 0)
    80003cfe:	fc045783          	lhu	a5,-64(s0)
    80003d02:	c791                	beqz	a5,80003d0e <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003d04:	24c1                	addiw	s1,s1,16
    80003d06:	04c92783          	lw	a5,76(s2)
    80003d0a:	fcf4ede3          	bltu	s1,a5,80003ce4 <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    80003d0e:	4639                	li	a2,14
    80003d10:	85d2                	mv	a1,s4
    80003d12:	fc240513          	addi	a0,s0,-62
    80003d16:	ffffd097          	auipc	ra,0xffffd
    80003d1a:	0d4080e7          	jalr	212(ra) # 80000dea <strncpy>
  de.inum = inum;
    80003d1e:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003d22:	4741                	li	a4,16
    80003d24:	86a6                	mv	a3,s1
    80003d26:	fc040613          	addi	a2,s0,-64
    80003d2a:	4581                	li	a1,0
    80003d2c:	854a                	mv	a0,s2
    80003d2e:	00000097          	auipc	ra,0x0
    80003d32:	c44080e7          	jalr	-956(ra) # 80003972 <writei>
    80003d36:	872a                	mv	a4,a0
    80003d38:	47c1                	li	a5,16
  return 0;
    80003d3a:	4501                	li	a0,0
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003d3c:	02f71863          	bne	a4,a5,80003d6c <dirlink+0xb2>
}
    80003d40:	70e2                	ld	ra,56(sp)
    80003d42:	7442                	ld	s0,48(sp)
    80003d44:	74a2                	ld	s1,40(sp)
    80003d46:	7902                	ld	s2,32(sp)
    80003d48:	69e2                	ld	s3,24(sp)
    80003d4a:	6a42                	ld	s4,16(sp)
    80003d4c:	6121                	addi	sp,sp,64
    80003d4e:	8082                	ret
    iput(ip);
    80003d50:	00000097          	auipc	ra,0x0
    80003d54:	a30080e7          	jalr	-1488(ra) # 80003780 <iput>
    return -1;
    80003d58:	557d                	li	a0,-1
    80003d5a:	b7dd                	j	80003d40 <dirlink+0x86>
      panic("dirlink read");
    80003d5c:	00005517          	auipc	a0,0x5
    80003d60:	89c50513          	addi	a0,a0,-1892 # 800085f8 <syscalls+0x1c8>
    80003d64:	ffffc097          	auipc	ra,0xffffc
    80003d68:	7cc080e7          	jalr	1996(ra) # 80000530 <panic>
    panic("dirlink");
    80003d6c:	00005517          	auipc	a0,0x5
    80003d70:	99c50513          	addi	a0,a0,-1636 # 80008708 <syscalls+0x2d8>
    80003d74:	ffffc097          	auipc	ra,0xffffc
    80003d78:	7bc080e7          	jalr	1980(ra) # 80000530 <panic>

0000000080003d7c <namei>:

struct inode*
namei(char *path)
{
    80003d7c:	1101                	addi	sp,sp,-32
    80003d7e:	ec06                	sd	ra,24(sp)
    80003d80:	e822                	sd	s0,16(sp)
    80003d82:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80003d84:	fe040613          	addi	a2,s0,-32
    80003d88:	4581                	li	a1,0
    80003d8a:	00000097          	auipc	ra,0x0
    80003d8e:	dd0080e7          	jalr	-560(ra) # 80003b5a <namex>
}
    80003d92:	60e2                	ld	ra,24(sp)
    80003d94:	6442                	ld	s0,16(sp)
    80003d96:	6105                	addi	sp,sp,32
    80003d98:	8082                	ret

0000000080003d9a <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80003d9a:	1141                	addi	sp,sp,-16
    80003d9c:	e406                	sd	ra,8(sp)
    80003d9e:	e022                	sd	s0,0(sp)
    80003da0:	0800                	addi	s0,sp,16
    80003da2:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80003da4:	4585                	li	a1,1
    80003da6:	00000097          	auipc	ra,0x0
    80003daa:	db4080e7          	jalr	-588(ra) # 80003b5a <namex>
}
    80003dae:	60a2                	ld	ra,8(sp)
    80003db0:	6402                	ld	s0,0(sp)
    80003db2:	0141                	addi	sp,sp,16
    80003db4:	8082                	ret

0000000080003db6 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80003db6:	1101                	addi	sp,sp,-32
    80003db8:	ec06                	sd	ra,24(sp)
    80003dba:	e822                	sd	s0,16(sp)
    80003dbc:	e426                	sd	s1,8(sp)
    80003dbe:	e04a                	sd	s2,0(sp)
    80003dc0:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80003dc2:	0001d917          	auipc	s2,0x1d
    80003dc6:	6ae90913          	addi	s2,s2,1710 # 80021470 <log>
    80003dca:	01892583          	lw	a1,24(s2)
    80003dce:	02892503          	lw	a0,40(s2)
    80003dd2:	fffff097          	auipc	ra,0xfffff
    80003dd6:	ff2080e7          	jalr	-14(ra) # 80002dc4 <bread>
    80003dda:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80003ddc:	02c92683          	lw	a3,44(s2)
    80003de0:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80003de2:	02d05763          	blez	a3,80003e10 <write_head+0x5a>
    80003de6:	0001d797          	auipc	a5,0x1d
    80003dea:	6ba78793          	addi	a5,a5,1722 # 800214a0 <log+0x30>
    80003dee:	05c50713          	addi	a4,a0,92
    80003df2:	36fd                	addiw	a3,a3,-1
    80003df4:	1682                	slli	a3,a3,0x20
    80003df6:	9281                	srli	a3,a3,0x20
    80003df8:	068a                	slli	a3,a3,0x2
    80003dfa:	0001d617          	auipc	a2,0x1d
    80003dfe:	6aa60613          	addi	a2,a2,1706 # 800214a4 <log+0x34>
    80003e02:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    80003e04:	4390                	lw	a2,0(a5)
    80003e06:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80003e08:	0791                	addi	a5,a5,4
    80003e0a:	0711                	addi	a4,a4,4
    80003e0c:	fed79ce3          	bne	a5,a3,80003e04 <write_head+0x4e>
  }
  bwrite(buf);
    80003e10:	8526                	mv	a0,s1
    80003e12:	fffff097          	auipc	ra,0xfffff
    80003e16:	0a4080e7          	jalr	164(ra) # 80002eb6 <bwrite>
  brelse(buf);
    80003e1a:	8526                	mv	a0,s1
    80003e1c:	fffff097          	auipc	ra,0xfffff
    80003e20:	0d8080e7          	jalr	216(ra) # 80002ef4 <brelse>
}
    80003e24:	60e2                	ld	ra,24(sp)
    80003e26:	6442                	ld	s0,16(sp)
    80003e28:	64a2                	ld	s1,8(sp)
    80003e2a:	6902                	ld	s2,0(sp)
    80003e2c:	6105                	addi	sp,sp,32
    80003e2e:	8082                	ret

0000000080003e30 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80003e30:	0001d797          	auipc	a5,0x1d
    80003e34:	66c7a783          	lw	a5,1644(a5) # 8002149c <log+0x2c>
    80003e38:	0af05d63          	blez	a5,80003ef2 <install_trans+0xc2>
{
    80003e3c:	7139                	addi	sp,sp,-64
    80003e3e:	fc06                	sd	ra,56(sp)
    80003e40:	f822                	sd	s0,48(sp)
    80003e42:	f426                	sd	s1,40(sp)
    80003e44:	f04a                	sd	s2,32(sp)
    80003e46:	ec4e                	sd	s3,24(sp)
    80003e48:	e852                	sd	s4,16(sp)
    80003e4a:	e456                	sd	s5,8(sp)
    80003e4c:	e05a                	sd	s6,0(sp)
    80003e4e:	0080                	addi	s0,sp,64
    80003e50:	8b2a                	mv	s6,a0
    80003e52:	0001da97          	auipc	s5,0x1d
    80003e56:	64ea8a93          	addi	s5,s5,1614 # 800214a0 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003e5a:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003e5c:	0001d997          	auipc	s3,0x1d
    80003e60:	61498993          	addi	s3,s3,1556 # 80021470 <log>
    80003e64:	a035                	j	80003e90 <install_trans+0x60>
      bunpin(dbuf);
    80003e66:	8526                	mv	a0,s1
    80003e68:	fffff097          	auipc	ra,0xfffff
    80003e6c:	166080e7          	jalr	358(ra) # 80002fce <bunpin>
    brelse(lbuf);
    80003e70:	854a                	mv	a0,s2
    80003e72:	fffff097          	auipc	ra,0xfffff
    80003e76:	082080e7          	jalr	130(ra) # 80002ef4 <brelse>
    brelse(dbuf);
    80003e7a:	8526                	mv	a0,s1
    80003e7c:	fffff097          	auipc	ra,0xfffff
    80003e80:	078080e7          	jalr	120(ra) # 80002ef4 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003e84:	2a05                	addiw	s4,s4,1
    80003e86:	0a91                	addi	s5,s5,4
    80003e88:	02c9a783          	lw	a5,44(s3)
    80003e8c:	04fa5963          	bge	s4,a5,80003ede <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003e90:	0189a583          	lw	a1,24(s3)
    80003e94:	014585bb          	addw	a1,a1,s4
    80003e98:	2585                	addiw	a1,a1,1
    80003e9a:	0289a503          	lw	a0,40(s3)
    80003e9e:	fffff097          	auipc	ra,0xfffff
    80003ea2:	f26080e7          	jalr	-218(ra) # 80002dc4 <bread>
    80003ea6:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80003ea8:	000aa583          	lw	a1,0(s5)
    80003eac:	0289a503          	lw	a0,40(s3)
    80003eb0:	fffff097          	auipc	ra,0xfffff
    80003eb4:	f14080e7          	jalr	-236(ra) # 80002dc4 <bread>
    80003eb8:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80003eba:	40000613          	li	a2,1024
    80003ebe:	05890593          	addi	a1,s2,88
    80003ec2:	05850513          	addi	a0,a0,88
    80003ec6:	ffffd097          	auipc	ra,0xffffd
    80003eca:	e6c080e7          	jalr	-404(ra) # 80000d32 <memmove>
    bwrite(dbuf);  // write dst to disk
    80003ece:	8526                	mv	a0,s1
    80003ed0:	fffff097          	auipc	ra,0xfffff
    80003ed4:	fe6080e7          	jalr	-26(ra) # 80002eb6 <bwrite>
    if(recovering == 0)
    80003ed8:	f80b1ce3          	bnez	s6,80003e70 <install_trans+0x40>
    80003edc:	b769                	j	80003e66 <install_trans+0x36>
}
    80003ede:	70e2                	ld	ra,56(sp)
    80003ee0:	7442                	ld	s0,48(sp)
    80003ee2:	74a2                	ld	s1,40(sp)
    80003ee4:	7902                	ld	s2,32(sp)
    80003ee6:	69e2                	ld	s3,24(sp)
    80003ee8:	6a42                	ld	s4,16(sp)
    80003eea:	6aa2                	ld	s5,8(sp)
    80003eec:	6b02                	ld	s6,0(sp)
    80003eee:	6121                	addi	sp,sp,64
    80003ef0:	8082                	ret
    80003ef2:	8082                	ret

0000000080003ef4 <initlog>:
{
    80003ef4:	7179                	addi	sp,sp,-48
    80003ef6:	f406                	sd	ra,40(sp)
    80003ef8:	f022                	sd	s0,32(sp)
    80003efa:	ec26                	sd	s1,24(sp)
    80003efc:	e84a                	sd	s2,16(sp)
    80003efe:	e44e                	sd	s3,8(sp)
    80003f00:	1800                	addi	s0,sp,48
    80003f02:	892a                	mv	s2,a0
    80003f04:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80003f06:	0001d497          	auipc	s1,0x1d
    80003f0a:	56a48493          	addi	s1,s1,1386 # 80021470 <log>
    80003f0e:	00004597          	auipc	a1,0x4
    80003f12:	6fa58593          	addi	a1,a1,1786 # 80008608 <syscalls+0x1d8>
    80003f16:	8526                	mv	a0,s1
    80003f18:	ffffd097          	auipc	ra,0xffffd
    80003f1c:	c2e080e7          	jalr	-978(ra) # 80000b46 <initlock>
  log.start = sb->logstart;
    80003f20:	0149a583          	lw	a1,20(s3)
    80003f24:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    80003f26:	0109a783          	lw	a5,16(s3)
    80003f2a:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    80003f2c:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    80003f30:	854a                	mv	a0,s2
    80003f32:	fffff097          	auipc	ra,0xfffff
    80003f36:	e92080e7          	jalr	-366(ra) # 80002dc4 <bread>
  log.lh.n = lh->n;
    80003f3a:	4d3c                	lw	a5,88(a0)
    80003f3c:	d4dc                	sw	a5,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    80003f3e:	02f05563          	blez	a5,80003f68 <initlog+0x74>
    80003f42:	05c50713          	addi	a4,a0,92
    80003f46:	0001d697          	auipc	a3,0x1d
    80003f4a:	55a68693          	addi	a3,a3,1370 # 800214a0 <log+0x30>
    80003f4e:	37fd                	addiw	a5,a5,-1
    80003f50:	1782                	slli	a5,a5,0x20
    80003f52:	9381                	srli	a5,a5,0x20
    80003f54:	078a                	slli	a5,a5,0x2
    80003f56:	06050613          	addi	a2,a0,96
    80003f5a:	97b2                	add	a5,a5,a2
    log.lh.block[i] = lh->block[i];
    80003f5c:	4310                	lw	a2,0(a4)
    80003f5e:	c290                	sw	a2,0(a3)
  for (i = 0; i < log.lh.n; i++) {
    80003f60:	0711                	addi	a4,a4,4
    80003f62:	0691                	addi	a3,a3,4
    80003f64:	fef71ce3          	bne	a4,a5,80003f5c <initlog+0x68>
  brelse(buf);
    80003f68:	fffff097          	auipc	ra,0xfffff
    80003f6c:	f8c080e7          	jalr	-116(ra) # 80002ef4 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80003f70:	4505                	li	a0,1
    80003f72:	00000097          	auipc	ra,0x0
    80003f76:	ebe080e7          	jalr	-322(ra) # 80003e30 <install_trans>
  log.lh.n = 0;
    80003f7a:	0001d797          	auipc	a5,0x1d
    80003f7e:	5207a123          	sw	zero,1314(a5) # 8002149c <log+0x2c>
  write_head(); // clear the log
    80003f82:	00000097          	auipc	ra,0x0
    80003f86:	e34080e7          	jalr	-460(ra) # 80003db6 <write_head>
}
    80003f8a:	70a2                	ld	ra,40(sp)
    80003f8c:	7402                	ld	s0,32(sp)
    80003f8e:	64e2                	ld	s1,24(sp)
    80003f90:	6942                	ld	s2,16(sp)
    80003f92:	69a2                	ld	s3,8(sp)
    80003f94:	6145                	addi	sp,sp,48
    80003f96:	8082                	ret

0000000080003f98 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80003f98:	1101                	addi	sp,sp,-32
    80003f9a:	ec06                	sd	ra,24(sp)
    80003f9c:	e822                	sd	s0,16(sp)
    80003f9e:	e426                	sd	s1,8(sp)
    80003fa0:	e04a                	sd	s2,0(sp)
    80003fa2:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80003fa4:	0001d517          	auipc	a0,0x1d
    80003fa8:	4cc50513          	addi	a0,a0,1228 # 80021470 <log>
    80003fac:	ffffd097          	auipc	ra,0xffffd
    80003fb0:	c2a080e7          	jalr	-982(ra) # 80000bd6 <acquire>
  while(1){
    if(log.committing){
    80003fb4:	0001d497          	auipc	s1,0x1d
    80003fb8:	4bc48493          	addi	s1,s1,1212 # 80021470 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80003fbc:	4979                	li	s2,30
    80003fbe:	a039                	j	80003fcc <begin_op+0x34>
      sleep(&log, &log.lock);
    80003fc0:	85a6                	mv	a1,s1
    80003fc2:	8526                	mv	a0,s1
    80003fc4:	ffffe097          	auipc	ra,0xffffe
    80003fc8:	092080e7          	jalr	146(ra) # 80002056 <sleep>
    if(log.committing){
    80003fcc:	50dc                	lw	a5,36(s1)
    80003fce:	fbed                	bnez	a5,80003fc0 <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80003fd0:	509c                	lw	a5,32(s1)
    80003fd2:	0017871b          	addiw	a4,a5,1
    80003fd6:	0007069b          	sext.w	a3,a4
    80003fda:	0027179b          	slliw	a5,a4,0x2
    80003fde:	9fb9                	addw	a5,a5,a4
    80003fe0:	0017979b          	slliw	a5,a5,0x1
    80003fe4:	54d8                	lw	a4,44(s1)
    80003fe6:	9fb9                	addw	a5,a5,a4
    80003fe8:	00f95963          	bge	s2,a5,80003ffa <begin_op+0x62>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80003fec:	85a6                	mv	a1,s1
    80003fee:	8526                	mv	a0,s1
    80003ff0:	ffffe097          	auipc	ra,0xffffe
    80003ff4:	066080e7          	jalr	102(ra) # 80002056 <sleep>
    80003ff8:	bfd1                	j	80003fcc <begin_op+0x34>
    } else {
      log.outstanding += 1;
    80003ffa:	0001d517          	auipc	a0,0x1d
    80003ffe:	47650513          	addi	a0,a0,1142 # 80021470 <log>
    80004002:	d114                	sw	a3,32(a0)
      release(&log.lock);
    80004004:	ffffd097          	auipc	ra,0xffffd
    80004008:	c86080e7          	jalr	-890(ra) # 80000c8a <release>
      break;
    }
  }
}
    8000400c:	60e2                	ld	ra,24(sp)
    8000400e:	6442                	ld	s0,16(sp)
    80004010:	64a2                	ld	s1,8(sp)
    80004012:	6902                	ld	s2,0(sp)
    80004014:	6105                	addi	sp,sp,32
    80004016:	8082                	ret

0000000080004018 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80004018:	7139                	addi	sp,sp,-64
    8000401a:	fc06                	sd	ra,56(sp)
    8000401c:	f822                	sd	s0,48(sp)
    8000401e:	f426                	sd	s1,40(sp)
    80004020:	f04a                	sd	s2,32(sp)
    80004022:	ec4e                	sd	s3,24(sp)
    80004024:	e852                	sd	s4,16(sp)
    80004026:	e456                	sd	s5,8(sp)
    80004028:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    8000402a:	0001d497          	auipc	s1,0x1d
    8000402e:	44648493          	addi	s1,s1,1094 # 80021470 <log>
    80004032:	8526                	mv	a0,s1
    80004034:	ffffd097          	auipc	ra,0xffffd
    80004038:	ba2080e7          	jalr	-1118(ra) # 80000bd6 <acquire>
  log.outstanding -= 1;
    8000403c:	509c                	lw	a5,32(s1)
    8000403e:	37fd                	addiw	a5,a5,-1
    80004040:	0007891b          	sext.w	s2,a5
    80004044:	d09c                	sw	a5,32(s1)
  if(log.committing)
    80004046:	50dc                	lw	a5,36(s1)
    80004048:	efb9                	bnez	a5,800040a6 <end_op+0x8e>
    panic("log.committing");
  if(log.outstanding == 0){
    8000404a:	06091663          	bnez	s2,800040b6 <end_op+0x9e>
    do_commit = 1;
    log.committing = 1;
    8000404e:	0001d497          	auipc	s1,0x1d
    80004052:	42248493          	addi	s1,s1,1058 # 80021470 <log>
    80004056:	4785                	li	a5,1
    80004058:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    8000405a:	8526                	mv	a0,s1
    8000405c:	ffffd097          	auipc	ra,0xffffd
    80004060:	c2e080e7          	jalr	-978(ra) # 80000c8a <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80004064:	54dc                	lw	a5,44(s1)
    80004066:	06f04763          	bgtz	a5,800040d4 <end_op+0xbc>
    acquire(&log.lock);
    8000406a:	0001d497          	auipc	s1,0x1d
    8000406e:	40648493          	addi	s1,s1,1030 # 80021470 <log>
    80004072:	8526                	mv	a0,s1
    80004074:	ffffd097          	auipc	ra,0xffffd
    80004078:	b62080e7          	jalr	-1182(ra) # 80000bd6 <acquire>
    log.committing = 0;
    8000407c:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    80004080:	8526                	mv	a0,s1
    80004082:	ffffe097          	auipc	ra,0xffffe
    80004086:	160080e7          	jalr	352(ra) # 800021e2 <wakeup>
    release(&log.lock);
    8000408a:	8526                	mv	a0,s1
    8000408c:	ffffd097          	auipc	ra,0xffffd
    80004090:	bfe080e7          	jalr	-1026(ra) # 80000c8a <release>
}
    80004094:	70e2                	ld	ra,56(sp)
    80004096:	7442                	ld	s0,48(sp)
    80004098:	74a2                	ld	s1,40(sp)
    8000409a:	7902                	ld	s2,32(sp)
    8000409c:	69e2                	ld	s3,24(sp)
    8000409e:	6a42                	ld	s4,16(sp)
    800040a0:	6aa2                	ld	s5,8(sp)
    800040a2:	6121                	addi	sp,sp,64
    800040a4:	8082                	ret
    panic("log.committing");
    800040a6:	00004517          	auipc	a0,0x4
    800040aa:	56a50513          	addi	a0,a0,1386 # 80008610 <syscalls+0x1e0>
    800040ae:	ffffc097          	auipc	ra,0xffffc
    800040b2:	482080e7          	jalr	1154(ra) # 80000530 <panic>
    wakeup(&log);
    800040b6:	0001d497          	auipc	s1,0x1d
    800040ba:	3ba48493          	addi	s1,s1,954 # 80021470 <log>
    800040be:	8526                	mv	a0,s1
    800040c0:	ffffe097          	auipc	ra,0xffffe
    800040c4:	122080e7          	jalr	290(ra) # 800021e2 <wakeup>
  release(&log.lock);
    800040c8:	8526                	mv	a0,s1
    800040ca:	ffffd097          	auipc	ra,0xffffd
    800040ce:	bc0080e7          	jalr	-1088(ra) # 80000c8a <release>
  if(do_commit){
    800040d2:	b7c9                	j	80004094 <end_op+0x7c>
  for (tail = 0; tail < log.lh.n; tail++) {
    800040d4:	0001da97          	auipc	s5,0x1d
    800040d8:	3cca8a93          	addi	s5,s5,972 # 800214a0 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    800040dc:	0001da17          	auipc	s4,0x1d
    800040e0:	394a0a13          	addi	s4,s4,916 # 80021470 <log>
    800040e4:	018a2583          	lw	a1,24(s4)
    800040e8:	012585bb          	addw	a1,a1,s2
    800040ec:	2585                	addiw	a1,a1,1
    800040ee:	028a2503          	lw	a0,40(s4)
    800040f2:	fffff097          	auipc	ra,0xfffff
    800040f6:	cd2080e7          	jalr	-814(ra) # 80002dc4 <bread>
    800040fa:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    800040fc:	000aa583          	lw	a1,0(s5)
    80004100:	028a2503          	lw	a0,40(s4)
    80004104:	fffff097          	auipc	ra,0xfffff
    80004108:	cc0080e7          	jalr	-832(ra) # 80002dc4 <bread>
    8000410c:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    8000410e:	40000613          	li	a2,1024
    80004112:	05850593          	addi	a1,a0,88
    80004116:	05848513          	addi	a0,s1,88
    8000411a:	ffffd097          	auipc	ra,0xffffd
    8000411e:	c18080e7          	jalr	-1000(ra) # 80000d32 <memmove>
    bwrite(to);  // write the log
    80004122:	8526                	mv	a0,s1
    80004124:	fffff097          	auipc	ra,0xfffff
    80004128:	d92080e7          	jalr	-622(ra) # 80002eb6 <bwrite>
    brelse(from);
    8000412c:	854e                	mv	a0,s3
    8000412e:	fffff097          	auipc	ra,0xfffff
    80004132:	dc6080e7          	jalr	-570(ra) # 80002ef4 <brelse>
    brelse(to);
    80004136:	8526                	mv	a0,s1
    80004138:	fffff097          	auipc	ra,0xfffff
    8000413c:	dbc080e7          	jalr	-580(ra) # 80002ef4 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004140:	2905                	addiw	s2,s2,1
    80004142:	0a91                	addi	s5,s5,4
    80004144:	02ca2783          	lw	a5,44(s4)
    80004148:	f8f94ee3          	blt	s2,a5,800040e4 <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    8000414c:	00000097          	auipc	ra,0x0
    80004150:	c6a080e7          	jalr	-918(ra) # 80003db6 <write_head>
    install_trans(0); // Now install writes to home locations
    80004154:	4501                	li	a0,0
    80004156:	00000097          	auipc	ra,0x0
    8000415a:	cda080e7          	jalr	-806(ra) # 80003e30 <install_trans>
    log.lh.n = 0;
    8000415e:	0001d797          	auipc	a5,0x1d
    80004162:	3207af23          	sw	zero,830(a5) # 8002149c <log+0x2c>
    write_head();    // Erase the transaction from the log
    80004166:	00000097          	auipc	ra,0x0
    8000416a:	c50080e7          	jalr	-944(ra) # 80003db6 <write_head>
    8000416e:	bdf5                	j	8000406a <end_op+0x52>

0000000080004170 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80004170:	1101                	addi	sp,sp,-32
    80004172:	ec06                	sd	ra,24(sp)
    80004174:	e822                	sd	s0,16(sp)
    80004176:	e426                	sd	s1,8(sp)
    80004178:	e04a                	sd	s2,0(sp)
    8000417a:	1000                	addi	s0,sp,32
    8000417c:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    8000417e:	0001d917          	auipc	s2,0x1d
    80004182:	2f290913          	addi	s2,s2,754 # 80021470 <log>
    80004186:	854a                	mv	a0,s2
    80004188:	ffffd097          	auipc	ra,0xffffd
    8000418c:	a4e080e7          	jalr	-1458(ra) # 80000bd6 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    80004190:	02c92603          	lw	a2,44(s2)
    80004194:	47f5                	li	a5,29
    80004196:	06c7c563          	blt	a5,a2,80004200 <log_write+0x90>
    8000419a:	0001d797          	auipc	a5,0x1d
    8000419e:	2f27a783          	lw	a5,754(a5) # 8002148c <log+0x1c>
    800041a2:	37fd                	addiw	a5,a5,-1
    800041a4:	04f65e63          	bge	a2,a5,80004200 <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    800041a8:	0001d797          	auipc	a5,0x1d
    800041ac:	2e87a783          	lw	a5,744(a5) # 80021490 <log+0x20>
    800041b0:	06f05063          	blez	a5,80004210 <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    800041b4:	4781                	li	a5,0
    800041b6:	06c05563          	blez	a2,80004220 <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
    800041ba:	44cc                	lw	a1,12(s1)
    800041bc:	0001d717          	auipc	a4,0x1d
    800041c0:	2e470713          	addi	a4,a4,740 # 800214a0 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    800041c4:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorbtion
    800041c6:	4314                	lw	a3,0(a4)
    800041c8:	04b68c63          	beq	a3,a1,80004220 <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    800041cc:	2785                	addiw	a5,a5,1
    800041ce:	0711                	addi	a4,a4,4
    800041d0:	fef61be3          	bne	a2,a5,800041c6 <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    800041d4:	0621                	addi	a2,a2,8
    800041d6:	060a                	slli	a2,a2,0x2
    800041d8:	0001d797          	auipc	a5,0x1d
    800041dc:	29878793          	addi	a5,a5,664 # 80021470 <log>
    800041e0:	963e                	add	a2,a2,a5
    800041e2:	44dc                	lw	a5,12(s1)
    800041e4:	ca1c                	sw	a5,16(a2)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    800041e6:	8526                	mv	a0,s1
    800041e8:	fffff097          	auipc	ra,0xfffff
    800041ec:	daa080e7          	jalr	-598(ra) # 80002f92 <bpin>
    log.lh.n++;
    800041f0:	0001d717          	auipc	a4,0x1d
    800041f4:	28070713          	addi	a4,a4,640 # 80021470 <log>
    800041f8:	575c                	lw	a5,44(a4)
    800041fa:	2785                	addiw	a5,a5,1
    800041fc:	d75c                	sw	a5,44(a4)
    800041fe:	a835                	j	8000423a <log_write+0xca>
    panic("too big a transaction");
    80004200:	00004517          	auipc	a0,0x4
    80004204:	42050513          	addi	a0,a0,1056 # 80008620 <syscalls+0x1f0>
    80004208:	ffffc097          	auipc	ra,0xffffc
    8000420c:	328080e7          	jalr	808(ra) # 80000530 <panic>
    panic("log_write outside of trans");
    80004210:	00004517          	auipc	a0,0x4
    80004214:	42850513          	addi	a0,a0,1064 # 80008638 <syscalls+0x208>
    80004218:	ffffc097          	auipc	ra,0xffffc
    8000421c:	318080e7          	jalr	792(ra) # 80000530 <panic>
  log.lh.block[i] = b->blockno;
    80004220:	00878713          	addi	a4,a5,8
    80004224:	00271693          	slli	a3,a4,0x2
    80004228:	0001d717          	auipc	a4,0x1d
    8000422c:	24870713          	addi	a4,a4,584 # 80021470 <log>
    80004230:	9736                	add	a4,a4,a3
    80004232:	44d4                	lw	a3,12(s1)
    80004234:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80004236:	faf608e3          	beq	a2,a5,800041e6 <log_write+0x76>
  }
  release(&log.lock);
    8000423a:	0001d517          	auipc	a0,0x1d
    8000423e:	23650513          	addi	a0,a0,566 # 80021470 <log>
    80004242:	ffffd097          	auipc	ra,0xffffd
    80004246:	a48080e7          	jalr	-1464(ra) # 80000c8a <release>
}
    8000424a:	60e2                	ld	ra,24(sp)
    8000424c:	6442                	ld	s0,16(sp)
    8000424e:	64a2                	ld	s1,8(sp)
    80004250:	6902                	ld	s2,0(sp)
    80004252:	6105                	addi	sp,sp,32
    80004254:	8082                	ret

0000000080004256 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80004256:	1101                	addi	sp,sp,-32
    80004258:	ec06                	sd	ra,24(sp)
    8000425a:	e822                	sd	s0,16(sp)
    8000425c:	e426                	sd	s1,8(sp)
    8000425e:	e04a                	sd	s2,0(sp)
    80004260:	1000                	addi	s0,sp,32
    80004262:	84aa                	mv	s1,a0
    80004264:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80004266:	00004597          	auipc	a1,0x4
    8000426a:	3f258593          	addi	a1,a1,1010 # 80008658 <syscalls+0x228>
    8000426e:	0521                	addi	a0,a0,8
    80004270:	ffffd097          	auipc	ra,0xffffd
    80004274:	8d6080e7          	jalr	-1834(ra) # 80000b46 <initlock>
  lk->name = name;
    80004278:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    8000427c:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004280:	0204a423          	sw	zero,40(s1)
}
    80004284:	60e2                	ld	ra,24(sp)
    80004286:	6442                	ld	s0,16(sp)
    80004288:	64a2                	ld	s1,8(sp)
    8000428a:	6902                	ld	s2,0(sp)
    8000428c:	6105                	addi	sp,sp,32
    8000428e:	8082                	ret

0000000080004290 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80004290:	1101                	addi	sp,sp,-32
    80004292:	ec06                	sd	ra,24(sp)
    80004294:	e822                	sd	s0,16(sp)
    80004296:	e426                	sd	s1,8(sp)
    80004298:	e04a                	sd	s2,0(sp)
    8000429a:	1000                	addi	s0,sp,32
    8000429c:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    8000429e:	00850913          	addi	s2,a0,8
    800042a2:	854a                	mv	a0,s2
    800042a4:	ffffd097          	auipc	ra,0xffffd
    800042a8:	932080e7          	jalr	-1742(ra) # 80000bd6 <acquire>
  while (lk->locked) {
    800042ac:	409c                	lw	a5,0(s1)
    800042ae:	cb89                	beqz	a5,800042c0 <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    800042b0:	85ca                	mv	a1,s2
    800042b2:	8526                	mv	a0,s1
    800042b4:	ffffe097          	auipc	ra,0xffffe
    800042b8:	da2080e7          	jalr	-606(ra) # 80002056 <sleep>
  while (lk->locked) {
    800042bc:	409c                	lw	a5,0(s1)
    800042be:	fbed                	bnez	a5,800042b0 <acquiresleep+0x20>
  }
  lk->locked = 1;
    800042c0:	4785                	li	a5,1
    800042c2:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    800042c4:	ffffd097          	auipc	ra,0xffffd
    800042c8:	6d0080e7          	jalr	1744(ra) # 80001994 <myproc>
    800042cc:	591c                	lw	a5,48(a0)
    800042ce:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    800042d0:	854a                	mv	a0,s2
    800042d2:	ffffd097          	auipc	ra,0xffffd
    800042d6:	9b8080e7          	jalr	-1608(ra) # 80000c8a <release>
}
    800042da:	60e2                	ld	ra,24(sp)
    800042dc:	6442                	ld	s0,16(sp)
    800042de:	64a2                	ld	s1,8(sp)
    800042e0:	6902                	ld	s2,0(sp)
    800042e2:	6105                	addi	sp,sp,32
    800042e4:	8082                	ret

00000000800042e6 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    800042e6:	1101                	addi	sp,sp,-32
    800042e8:	ec06                	sd	ra,24(sp)
    800042ea:	e822                	sd	s0,16(sp)
    800042ec:	e426                	sd	s1,8(sp)
    800042ee:	e04a                	sd	s2,0(sp)
    800042f0:	1000                	addi	s0,sp,32
    800042f2:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800042f4:	00850913          	addi	s2,a0,8
    800042f8:	854a                	mv	a0,s2
    800042fa:	ffffd097          	auipc	ra,0xffffd
    800042fe:	8dc080e7          	jalr	-1828(ra) # 80000bd6 <acquire>
  lk->locked = 0;
    80004302:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004306:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    8000430a:	8526                	mv	a0,s1
    8000430c:	ffffe097          	auipc	ra,0xffffe
    80004310:	ed6080e7          	jalr	-298(ra) # 800021e2 <wakeup>
  release(&lk->lk);
    80004314:	854a                	mv	a0,s2
    80004316:	ffffd097          	auipc	ra,0xffffd
    8000431a:	974080e7          	jalr	-1676(ra) # 80000c8a <release>
}
    8000431e:	60e2                	ld	ra,24(sp)
    80004320:	6442                	ld	s0,16(sp)
    80004322:	64a2                	ld	s1,8(sp)
    80004324:	6902                	ld	s2,0(sp)
    80004326:	6105                	addi	sp,sp,32
    80004328:	8082                	ret

000000008000432a <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    8000432a:	7179                	addi	sp,sp,-48
    8000432c:	f406                	sd	ra,40(sp)
    8000432e:	f022                	sd	s0,32(sp)
    80004330:	ec26                	sd	s1,24(sp)
    80004332:	e84a                	sd	s2,16(sp)
    80004334:	e44e                	sd	s3,8(sp)
    80004336:	1800                	addi	s0,sp,48
    80004338:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    8000433a:	00850913          	addi	s2,a0,8
    8000433e:	854a                	mv	a0,s2
    80004340:	ffffd097          	auipc	ra,0xffffd
    80004344:	896080e7          	jalr	-1898(ra) # 80000bd6 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80004348:	409c                	lw	a5,0(s1)
    8000434a:	ef99                	bnez	a5,80004368 <holdingsleep+0x3e>
    8000434c:	4481                	li	s1,0
  release(&lk->lk);
    8000434e:	854a                	mv	a0,s2
    80004350:	ffffd097          	auipc	ra,0xffffd
    80004354:	93a080e7          	jalr	-1734(ra) # 80000c8a <release>
  return r;
}
    80004358:	8526                	mv	a0,s1
    8000435a:	70a2                	ld	ra,40(sp)
    8000435c:	7402                	ld	s0,32(sp)
    8000435e:	64e2                	ld	s1,24(sp)
    80004360:	6942                	ld	s2,16(sp)
    80004362:	69a2                	ld	s3,8(sp)
    80004364:	6145                	addi	sp,sp,48
    80004366:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    80004368:	0284a983          	lw	s3,40(s1)
    8000436c:	ffffd097          	auipc	ra,0xffffd
    80004370:	628080e7          	jalr	1576(ra) # 80001994 <myproc>
    80004374:	5904                	lw	s1,48(a0)
    80004376:	413484b3          	sub	s1,s1,s3
    8000437a:	0014b493          	seqz	s1,s1
    8000437e:	bfc1                	j	8000434e <holdingsleep+0x24>

0000000080004380 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80004380:	1141                	addi	sp,sp,-16
    80004382:	e406                	sd	ra,8(sp)
    80004384:	e022                	sd	s0,0(sp)
    80004386:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80004388:	00004597          	auipc	a1,0x4
    8000438c:	2e058593          	addi	a1,a1,736 # 80008668 <syscalls+0x238>
    80004390:	0001d517          	auipc	a0,0x1d
    80004394:	22850513          	addi	a0,a0,552 # 800215b8 <ftable>
    80004398:	ffffc097          	auipc	ra,0xffffc
    8000439c:	7ae080e7          	jalr	1966(ra) # 80000b46 <initlock>
}
    800043a0:	60a2                	ld	ra,8(sp)
    800043a2:	6402                	ld	s0,0(sp)
    800043a4:	0141                	addi	sp,sp,16
    800043a6:	8082                	ret

00000000800043a8 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    800043a8:	1101                	addi	sp,sp,-32
    800043aa:	ec06                	sd	ra,24(sp)
    800043ac:	e822                	sd	s0,16(sp)
    800043ae:	e426                	sd	s1,8(sp)
    800043b0:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    800043b2:	0001d517          	auipc	a0,0x1d
    800043b6:	20650513          	addi	a0,a0,518 # 800215b8 <ftable>
    800043ba:	ffffd097          	auipc	ra,0xffffd
    800043be:	81c080e7          	jalr	-2020(ra) # 80000bd6 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800043c2:	0001d497          	auipc	s1,0x1d
    800043c6:	20e48493          	addi	s1,s1,526 # 800215d0 <ftable+0x18>
    800043ca:	0001e717          	auipc	a4,0x1e
    800043ce:	1a670713          	addi	a4,a4,422 # 80022570 <ftable+0xfb8>
    if(f->ref == 0){
    800043d2:	40dc                	lw	a5,4(s1)
    800043d4:	cf99                	beqz	a5,800043f2 <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800043d6:	02848493          	addi	s1,s1,40
    800043da:	fee49ce3          	bne	s1,a4,800043d2 <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    800043de:	0001d517          	auipc	a0,0x1d
    800043e2:	1da50513          	addi	a0,a0,474 # 800215b8 <ftable>
    800043e6:	ffffd097          	auipc	ra,0xffffd
    800043ea:	8a4080e7          	jalr	-1884(ra) # 80000c8a <release>
  return 0;
    800043ee:	4481                	li	s1,0
    800043f0:	a819                	j	80004406 <filealloc+0x5e>
      f->ref = 1;
    800043f2:	4785                	li	a5,1
    800043f4:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    800043f6:	0001d517          	auipc	a0,0x1d
    800043fa:	1c250513          	addi	a0,a0,450 # 800215b8 <ftable>
    800043fe:	ffffd097          	auipc	ra,0xffffd
    80004402:	88c080e7          	jalr	-1908(ra) # 80000c8a <release>
}
    80004406:	8526                	mv	a0,s1
    80004408:	60e2                	ld	ra,24(sp)
    8000440a:	6442                	ld	s0,16(sp)
    8000440c:	64a2                	ld	s1,8(sp)
    8000440e:	6105                	addi	sp,sp,32
    80004410:	8082                	ret

0000000080004412 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80004412:	1101                	addi	sp,sp,-32
    80004414:	ec06                	sd	ra,24(sp)
    80004416:	e822                	sd	s0,16(sp)
    80004418:	e426                	sd	s1,8(sp)
    8000441a:	1000                	addi	s0,sp,32
    8000441c:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    8000441e:	0001d517          	auipc	a0,0x1d
    80004422:	19a50513          	addi	a0,a0,410 # 800215b8 <ftable>
    80004426:	ffffc097          	auipc	ra,0xffffc
    8000442a:	7b0080e7          	jalr	1968(ra) # 80000bd6 <acquire>
  if(f->ref < 1)
    8000442e:	40dc                	lw	a5,4(s1)
    80004430:	02f05263          	blez	a5,80004454 <filedup+0x42>
    panic("filedup");
  f->ref++;
    80004434:	2785                	addiw	a5,a5,1
    80004436:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004438:	0001d517          	auipc	a0,0x1d
    8000443c:	18050513          	addi	a0,a0,384 # 800215b8 <ftable>
    80004440:	ffffd097          	auipc	ra,0xffffd
    80004444:	84a080e7          	jalr	-1974(ra) # 80000c8a <release>
  return f;
}
    80004448:	8526                	mv	a0,s1
    8000444a:	60e2                	ld	ra,24(sp)
    8000444c:	6442                	ld	s0,16(sp)
    8000444e:	64a2                	ld	s1,8(sp)
    80004450:	6105                	addi	sp,sp,32
    80004452:	8082                	ret
    panic("filedup");
    80004454:	00004517          	auipc	a0,0x4
    80004458:	21c50513          	addi	a0,a0,540 # 80008670 <syscalls+0x240>
    8000445c:	ffffc097          	auipc	ra,0xffffc
    80004460:	0d4080e7          	jalr	212(ra) # 80000530 <panic>

0000000080004464 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80004464:	7139                	addi	sp,sp,-64
    80004466:	fc06                	sd	ra,56(sp)
    80004468:	f822                	sd	s0,48(sp)
    8000446a:	f426                	sd	s1,40(sp)
    8000446c:	f04a                	sd	s2,32(sp)
    8000446e:	ec4e                	sd	s3,24(sp)
    80004470:	e852                	sd	s4,16(sp)
    80004472:	e456                	sd	s5,8(sp)
    80004474:	0080                	addi	s0,sp,64
    80004476:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004478:	0001d517          	auipc	a0,0x1d
    8000447c:	14050513          	addi	a0,a0,320 # 800215b8 <ftable>
    80004480:	ffffc097          	auipc	ra,0xffffc
    80004484:	756080e7          	jalr	1878(ra) # 80000bd6 <acquire>
  if(f->ref < 1)
    80004488:	40dc                	lw	a5,4(s1)
    8000448a:	06f05163          	blez	a5,800044ec <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    8000448e:	37fd                	addiw	a5,a5,-1
    80004490:	0007871b          	sext.w	a4,a5
    80004494:	c0dc                	sw	a5,4(s1)
    80004496:	06e04363          	bgtz	a4,800044fc <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    8000449a:	0004a903          	lw	s2,0(s1)
    8000449e:	0094ca83          	lbu	s5,9(s1)
    800044a2:	0104ba03          	ld	s4,16(s1)
    800044a6:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    800044aa:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    800044ae:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    800044b2:	0001d517          	auipc	a0,0x1d
    800044b6:	10650513          	addi	a0,a0,262 # 800215b8 <ftable>
    800044ba:	ffffc097          	auipc	ra,0xffffc
    800044be:	7d0080e7          	jalr	2000(ra) # 80000c8a <release>

  if(ff.type == FD_PIPE){
    800044c2:	4785                	li	a5,1
    800044c4:	04f90d63          	beq	s2,a5,8000451e <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    800044c8:	3979                	addiw	s2,s2,-2
    800044ca:	4785                	li	a5,1
    800044cc:	0527e063          	bltu	a5,s2,8000450c <fileclose+0xa8>
    begin_op();
    800044d0:	00000097          	auipc	ra,0x0
    800044d4:	ac8080e7          	jalr	-1336(ra) # 80003f98 <begin_op>
    iput(ff.ip);
    800044d8:	854e                	mv	a0,s3
    800044da:	fffff097          	auipc	ra,0xfffff
    800044de:	2a6080e7          	jalr	678(ra) # 80003780 <iput>
    end_op();
    800044e2:	00000097          	auipc	ra,0x0
    800044e6:	b36080e7          	jalr	-1226(ra) # 80004018 <end_op>
    800044ea:	a00d                	j	8000450c <fileclose+0xa8>
    panic("fileclose");
    800044ec:	00004517          	auipc	a0,0x4
    800044f0:	18c50513          	addi	a0,a0,396 # 80008678 <syscalls+0x248>
    800044f4:	ffffc097          	auipc	ra,0xffffc
    800044f8:	03c080e7          	jalr	60(ra) # 80000530 <panic>
    release(&ftable.lock);
    800044fc:	0001d517          	auipc	a0,0x1d
    80004500:	0bc50513          	addi	a0,a0,188 # 800215b8 <ftable>
    80004504:	ffffc097          	auipc	ra,0xffffc
    80004508:	786080e7          	jalr	1926(ra) # 80000c8a <release>
  }
}
    8000450c:	70e2                	ld	ra,56(sp)
    8000450e:	7442                	ld	s0,48(sp)
    80004510:	74a2                	ld	s1,40(sp)
    80004512:	7902                	ld	s2,32(sp)
    80004514:	69e2                	ld	s3,24(sp)
    80004516:	6a42                	ld	s4,16(sp)
    80004518:	6aa2                	ld	s5,8(sp)
    8000451a:	6121                	addi	sp,sp,64
    8000451c:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    8000451e:	85d6                	mv	a1,s5
    80004520:	8552                	mv	a0,s4
    80004522:	00000097          	auipc	ra,0x0
    80004526:	34c080e7          	jalr	844(ra) # 8000486e <pipeclose>
    8000452a:	b7cd                	j	8000450c <fileclose+0xa8>

000000008000452c <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    8000452c:	715d                	addi	sp,sp,-80
    8000452e:	e486                	sd	ra,72(sp)
    80004530:	e0a2                	sd	s0,64(sp)
    80004532:	fc26                	sd	s1,56(sp)
    80004534:	f84a                	sd	s2,48(sp)
    80004536:	f44e                	sd	s3,40(sp)
    80004538:	0880                	addi	s0,sp,80
    8000453a:	84aa                	mv	s1,a0
    8000453c:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    8000453e:	ffffd097          	auipc	ra,0xffffd
    80004542:	456080e7          	jalr	1110(ra) # 80001994 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004546:	409c                	lw	a5,0(s1)
    80004548:	37f9                	addiw	a5,a5,-2
    8000454a:	4705                	li	a4,1
    8000454c:	04f76763          	bltu	a4,a5,8000459a <filestat+0x6e>
    80004550:	892a                	mv	s2,a0
    ilock(f->ip);
    80004552:	6c88                	ld	a0,24(s1)
    80004554:	fffff097          	auipc	ra,0xfffff
    80004558:	072080e7          	jalr	114(ra) # 800035c6 <ilock>
    stati(f->ip, &st);
    8000455c:	fb840593          	addi	a1,s0,-72
    80004560:	6c88                	ld	a0,24(s1)
    80004562:	fffff097          	auipc	ra,0xfffff
    80004566:	2ee080e7          	jalr	750(ra) # 80003850 <stati>
    iunlock(f->ip);
    8000456a:	6c88                	ld	a0,24(s1)
    8000456c:	fffff097          	auipc	ra,0xfffff
    80004570:	11c080e7          	jalr	284(ra) # 80003688 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004574:	46e1                	li	a3,24
    80004576:	fb840613          	addi	a2,s0,-72
    8000457a:	85ce                	mv	a1,s3
    8000457c:	05893503          	ld	a0,88(s2)
    80004580:	ffffd097          	auipc	ra,0xffffd
    80004584:	0d6080e7          	jalr	214(ra) # 80001656 <copyout>
    80004588:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    8000458c:	60a6                	ld	ra,72(sp)
    8000458e:	6406                	ld	s0,64(sp)
    80004590:	74e2                	ld	s1,56(sp)
    80004592:	7942                	ld	s2,48(sp)
    80004594:	79a2                	ld	s3,40(sp)
    80004596:	6161                	addi	sp,sp,80
    80004598:	8082                	ret
  return -1;
    8000459a:	557d                	li	a0,-1
    8000459c:	bfc5                	j	8000458c <filestat+0x60>

000000008000459e <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    8000459e:	7179                	addi	sp,sp,-48
    800045a0:	f406                	sd	ra,40(sp)
    800045a2:	f022                	sd	s0,32(sp)
    800045a4:	ec26                	sd	s1,24(sp)
    800045a6:	e84a                	sd	s2,16(sp)
    800045a8:	e44e                	sd	s3,8(sp)
    800045aa:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    800045ac:	00854783          	lbu	a5,8(a0)
    800045b0:	c3d5                	beqz	a5,80004654 <fileread+0xb6>
    800045b2:	84aa                	mv	s1,a0
    800045b4:	89ae                	mv	s3,a1
    800045b6:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    800045b8:	411c                	lw	a5,0(a0)
    800045ba:	4705                	li	a4,1
    800045bc:	04e78963          	beq	a5,a4,8000460e <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800045c0:	470d                	li	a4,3
    800045c2:	04e78d63          	beq	a5,a4,8000461c <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    800045c6:	4709                	li	a4,2
    800045c8:	06e79e63          	bne	a5,a4,80004644 <fileread+0xa6>
    ilock(f->ip);
    800045cc:	6d08                	ld	a0,24(a0)
    800045ce:	fffff097          	auipc	ra,0xfffff
    800045d2:	ff8080e7          	jalr	-8(ra) # 800035c6 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    800045d6:	874a                	mv	a4,s2
    800045d8:	5094                	lw	a3,32(s1)
    800045da:	864e                	mv	a2,s3
    800045dc:	4585                	li	a1,1
    800045de:	6c88                	ld	a0,24(s1)
    800045e0:	fffff097          	auipc	ra,0xfffff
    800045e4:	29a080e7          	jalr	666(ra) # 8000387a <readi>
    800045e8:	892a                	mv	s2,a0
    800045ea:	00a05563          	blez	a0,800045f4 <fileread+0x56>
      f->off += r;
    800045ee:	509c                	lw	a5,32(s1)
    800045f0:	9fa9                	addw	a5,a5,a0
    800045f2:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    800045f4:	6c88                	ld	a0,24(s1)
    800045f6:	fffff097          	auipc	ra,0xfffff
    800045fa:	092080e7          	jalr	146(ra) # 80003688 <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    800045fe:	854a                	mv	a0,s2
    80004600:	70a2                	ld	ra,40(sp)
    80004602:	7402                	ld	s0,32(sp)
    80004604:	64e2                	ld	s1,24(sp)
    80004606:	6942                	ld	s2,16(sp)
    80004608:	69a2                	ld	s3,8(sp)
    8000460a:	6145                	addi	sp,sp,48
    8000460c:	8082                	ret
    r = piperead(f->pipe, addr, n);
    8000460e:	6908                	ld	a0,16(a0)
    80004610:	00000097          	auipc	ra,0x0
    80004614:	3c8080e7          	jalr	968(ra) # 800049d8 <piperead>
    80004618:	892a                	mv	s2,a0
    8000461a:	b7d5                	j	800045fe <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    8000461c:	02451783          	lh	a5,36(a0)
    80004620:	03079693          	slli	a3,a5,0x30
    80004624:	92c1                	srli	a3,a3,0x30
    80004626:	4725                	li	a4,9
    80004628:	02d76863          	bltu	a4,a3,80004658 <fileread+0xba>
    8000462c:	0792                	slli	a5,a5,0x4
    8000462e:	0001d717          	auipc	a4,0x1d
    80004632:	eea70713          	addi	a4,a4,-278 # 80021518 <devsw>
    80004636:	97ba                	add	a5,a5,a4
    80004638:	639c                	ld	a5,0(a5)
    8000463a:	c38d                	beqz	a5,8000465c <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    8000463c:	4505                	li	a0,1
    8000463e:	9782                	jalr	a5
    80004640:	892a                	mv	s2,a0
    80004642:	bf75                	j	800045fe <fileread+0x60>
    panic("fileread");
    80004644:	00004517          	auipc	a0,0x4
    80004648:	04450513          	addi	a0,a0,68 # 80008688 <syscalls+0x258>
    8000464c:	ffffc097          	auipc	ra,0xffffc
    80004650:	ee4080e7          	jalr	-284(ra) # 80000530 <panic>
    return -1;
    80004654:	597d                	li	s2,-1
    80004656:	b765                	j	800045fe <fileread+0x60>
      return -1;
    80004658:	597d                	li	s2,-1
    8000465a:	b755                	j	800045fe <fileread+0x60>
    8000465c:	597d                	li	s2,-1
    8000465e:	b745                	j	800045fe <fileread+0x60>

0000000080004660 <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    80004660:	715d                	addi	sp,sp,-80
    80004662:	e486                	sd	ra,72(sp)
    80004664:	e0a2                	sd	s0,64(sp)
    80004666:	fc26                	sd	s1,56(sp)
    80004668:	f84a                	sd	s2,48(sp)
    8000466a:	f44e                	sd	s3,40(sp)
    8000466c:	f052                	sd	s4,32(sp)
    8000466e:	ec56                	sd	s5,24(sp)
    80004670:	e85a                	sd	s6,16(sp)
    80004672:	e45e                	sd	s7,8(sp)
    80004674:	e062                	sd	s8,0(sp)
    80004676:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    80004678:	00954783          	lbu	a5,9(a0)
    8000467c:	10078663          	beqz	a5,80004788 <filewrite+0x128>
    80004680:	892a                	mv	s2,a0
    80004682:	8aae                	mv	s5,a1
    80004684:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80004686:	411c                	lw	a5,0(a0)
    80004688:	4705                	li	a4,1
    8000468a:	02e78263          	beq	a5,a4,800046ae <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    8000468e:	470d                	li	a4,3
    80004690:	02e78663          	beq	a5,a4,800046bc <filewrite+0x5c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80004694:	4709                	li	a4,2
    80004696:	0ee79163          	bne	a5,a4,80004778 <filewrite+0x118>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    8000469a:	0ac05d63          	blez	a2,80004754 <filewrite+0xf4>
    int i = 0;
    8000469e:	4981                	li	s3,0
    800046a0:	6b05                	lui	s6,0x1
    800046a2:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    800046a6:	6b85                	lui	s7,0x1
    800046a8:	c00b8b9b          	addiw	s7,s7,-1024
    800046ac:	a861                	j	80004744 <filewrite+0xe4>
    ret = pipewrite(f->pipe, addr, n);
    800046ae:	6908                	ld	a0,16(a0)
    800046b0:	00000097          	auipc	ra,0x0
    800046b4:	22e080e7          	jalr	558(ra) # 800048de <pipewrite>
    800046b8:	8a2a                	mv	s4,a0
    800046ba:	a045                	j	8000475a <filewrite+0xfa>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    800046bc:	02451783          	lh	a5,36(a0)
    800046c0:	03079693          	slli	a3,a5,0x30
    800046c4:	92c1                	srli	a3,a3,0x30
    800046c6:	4725                	li	a4,9
    800046c8:	0cd76263          	bltu	a4,a3,8000478c <filewrite+0x12c>
    800046cc:	0792                	slli	a5,a5,0x4
    800046ce:	0001d717          	auipc	a4,0x1d
    800046d2:	e4a70713          	addi	a4,a4,-438 # 80021518 <devsw>
    800046d6:	97ba                	add	a5,a5,a4
    800046d8:	679c                	ld	a5,8(a5)
    800046da:	cbdd                	beqz	a5,80004790 <filewrite+0x130>
    ret = devsw[f->major].write(1, addr, n);
    800046dc:	4505                	li	a0,1
    800046de:	9782                	jalr	a5
    800046e0:	8a2a                	mv	s4,a0
    800046e2:	a8a5                	j	8000475a <filewrite+0xfa>
    800046e4:	00048c1b          	sext.w	s8,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    800046e8:	00000097          	auipc	ra,0x0
    800046ec:	8b0080e7          	jalr	-1872(ra) # 80003f98 <begin_op>
      ilock(f->ip);
    800046f0:	01893503          	ld	a0,24(s2)
    800046f4:	fffff097          	auipc	ra,0xfffff
    800046f8:	ed2080e7          	jalr	-302(ra) # 800035c6 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    800046fc:	8762                	mv	a4,s8
    800046fe:	02092683          	lw	a3,32(s2)
    80004702:	01598633          	add	a2,s3,s5
    80004706:	4585                	li	a1,1
    80004708:	01893503          	ld	a0,24(s2)
    8000470c:	fffff097          	auipc	ra,0xfffff
    80004710:	266080e7          	jalr	614(ra) # 80003972 <writei>
    80004714:	84aa                	mv	s1,a0
    80004716:	00a05763          	blez	a0,80004724 <filewrite+0xc4>
        f->off += r;
    8000471a:	02092783          	lw	a5,32(s2)
    8000471e:	9fa9                	addw	a5,a5,a0
    80004720:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004724:	01893503          	ld	a0,24(s2)
    80004728:	fffff097          	auipc	ra,0xfffff
    8000472c:	f60080e7          	jalr	-160(ra) # 80003688 <iunlock>
      end_op();
    80004730:	00000097          	auipc	ra,0x0
    80004734:	8e8080e7          	jalr	-1816(ra) # 80004018 <end_op>

      if(r != n1){
    80004738:	009c1f63          	bne	s8,s1,80004756 <filewrite+0xf6>
        // error from writei
        break;
      }
      i += r;
    8000473c:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80004740:	0149db63          	bge	s3,s4,80004756 <filewrite+0xf6>
      int n1 = n - i;
    80004744:	413a07bb          	subw	a5,s4,s3
      if(n1 > max)
    80004748:	84be                	mv	s1,a5
    8000474a:	2781                	sext.w	a5,a5
    8000474c:	f8fb5ce3          	bge	s6,a5,800046e4 <filewrite+0x84>
    80004750:	84de                	mv	s1,s7
    80004752:	bf49                	j	800046e4 <filewrite+0x84>
    int i = 0;
    80004754:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    80004756:	013a1f63          	bne	s4,s3,80004774 <filewrite+0x114>
  } else {
    panic("filewrite");
  }

  return ret;
}
    8000475a:	8552                	mv	a0,s4
    8000475c:	60a6                	ld	ra,72(sp)
    8000475e:	6406                	ld	s0,64(sp)
    80004760:	74e2                	ld	s1,56(sp)
    80004762:	7942                	ld	s2,48(sp)
    80004764:	79a2                	ld	s3,40(sp)
    80004766:	7a02                	ld	s4,32(sp)
    80004768:	6ae2                	ld	s5,24(sp)
    8000476a:	6b42                	ld	s6,16(sp)
    8000476c:	6ba2                	ld	s7,8(sp)
    8000476e:	6c02                	ld	s8,0(sp)
    80004770:	6161                	addi	sp,sp,80
    80004772:	8082                	ret
    ret = (i == n ? n : -1);
    80004774:	5a7d                	li	s4,-1
    80004776:	b7d5                	j	8000475a <filewrite+0xfa>
    panic("filewrite");
    80004778:	00004517          	auipc	a0,0x4
    8000477c:	f2050513          	addi	a0,a0,-224 # 80008698 <syscalls+0x268>
    80004780:	ffffc097          	auipc	ra,0xffffc
    80004784:	db0080e7          	jalr	-592(ra) # 80000530 <panic>
    return -1;
    80004788:	5a7d                	li	s4,-1
    8000478a:	bfc1                	j	8000475a <filewrite+0xfa>
      return -1;
    8000478c:	5a7d                	li	s4,-1
    8000478e:	b7f1                	j	8000475a <filewrite+0xfa>
    80004790:	5a7d                	li	s4,-1
    80004792:	b7e1                	j	8000475a <filewrite+0xfa>

0000000080004794 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004794:	7179                	addi	sp,sp,-48
    80004796:	f406                	sd	ra,40(sp)
    80004798:	f022                	sd	s0,32(sp)
    8000479a:	ec26                	sd	s1,24(sp)
    8000479c:	e84a                	sd	s2,16(sp)
    8000479e:	e44e                	sd	s3,8(sp)
    800047a0:	e052                	sd	s4,0(sp)
    800047a2:	1800                	addi	s0,sp,48
    800047a4:	84aa                	mv	s1,a0
    800047a6:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    800047a8:	0005b023          	sd	zero,0(a1)
    800047ac:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    800047b0:	00000097          	auipc	ra,0x0
    800047b4:	bf8080e7          	jalr	-1032(ra) # 800043a8 <filealloc>
    800047b8:	e088                	sd	a0,0(s1)
    800047ba:	c551                	beqz	a0,80004846 <pipealloc+0xb2>
    800047bc:	00000097          	auipc	ra,0x0
    800047c0:	bec080e7          	jalr	-1044(ra) # 800043a8 <filealloc>
    800047c4:	00aa3023          	sd	a0,0(s4)
    800047c8:	c92d                	beqz	a0,8000483a <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    800047ca:	ffffc097          	auipc	ra,0xffffc
    800047ce:	31c080e7          	jalr	796(ra) # 80000ae6 <kalloc>
    800047d2:	892a                	mv	s2,a0
    800047d4:	c125                	beqz	a0,80004834 <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    800047d6:	4985                	li	s3,1
    800047d8:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    800047dc:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    800047e0:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    800047e4:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    800047e8:	00004597          	auipc	a1,0x4
    800047ec:	ec058593          	addi	a1,a1,-320 # 800086a8 <syscalls+0x278>
    800047f0:	ffffc097          	auipc	ra,0xffffc
    800047f4:	356080e7          	jalr	854(ra) # 80000b46 <initlock>
  (*f0)->type = FD_PIPE;
    800047f8:	609c                	ld	a5,0(s1)
    800047fa:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    800047fe:	609c                	ld	a5,0(s1)
    80004800:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004804:	609c                	ld	a5,0(s1)
    80004806:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    8000480a:	609c                	ld	a5,0(s1)
    8000480c:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004810:	000a3783          	ld	a5,0(s4)
    80004814:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004818:	000a3783          	ld	a5,0(s4)
    8000481c:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004820:	000a3783          	ld	a5,0(s4)
    80004824:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004828:	000a3783          	ld	a5,0(s4)
    8000482c:	0127b823          	sd	s2,16(a5)
  return 0;
    80004830:	4501                	li	a0,0
    80004832:	a025                	j	8000485a <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004834:	6088                	ld	a0,0(s1)
    80004836:	e501                	bnez	a0,8000483e <pipealloc+0xaa>
    80004838:	a039                	j	80004846 <pipealloc+0xb2>
    8000483a:	6088                	ld	a0,0(s1)
    8000483c:	c51d                	beqz	a0,8000486a <pipealloc+0xd6>
    fileclose(*f0);
    8000483e:	00000097          	auipc	ra,0x0
    80004842:	c26080e7          	jalr	-986(ra) # 80004464 <fileclose>
  if(*f1)
    80004846:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    8000484a:	557d                	li	a0,-1
  if(*f1)
    8000484c:	c799                	beqz	a5,8000485a <pipealloc+0xc6>
    fileclose(*f1);
    8000484e:	853e                	mv	a0,a5
    80004850:	00000097          	auipc	ra,0x0
    80004854:	c14080e7          	jalr	-1004(ra) # 80004464 <fileclose>
  return -1;
    80004858:	557d                	li	a0,-1
}
    8000485a:	70a2                	ld	ra,40(sp)
    8000485c:	7402                	ld	s0,32(sp)
    8000485e:	64e2                	ld	s1,24(sp)
    80004860:	6942                	ld	s2,16(sp)
    80004862:	69a2                	ld	s3,8(sp)
    80004864:	6a02                	ld	s4,0(sp)
    80004866:	6145                	addi	sp,sp,48
    80004868:	8082                	ret
  return -1;
    8000486a:	557d                	li	a0,-1
    8000486c:	b7fd                	j	8000485a <pipealloc+0xc6>

000000008000486e <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    8000486e:	1101                	addi	sp,sp,-32
    80004870:	ec06                	sd	ra,24(sp)
    80004872:	e822                	sd	s0,16(sp)
    80004874:	e426                	sd	s1,8(sp)
    80004876:	e04a                	sd	s2,0(sp)
    80004878:	1000                	addi	s0,sp,32
    8000487a:	84aa                	mv	s1,a0
    8000487c:	892e                	mv	s2,a1
  acquire(&pi->lock);
    8000487e:	ffffc097          	auipc	ra,0xffffc
    80004882:	358080e7          	jalr	856(ra) # 80000bd6 <acquire>
  if(writable){
    80004886:	02090d63          	beqz	s2,800048c0 <pipeclose+0x52>
    pi->writeopen = 0;
    8000488a:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    8000488e:	21848513          	addi	a0,s1,536
    80004892:	ffffe097          	auipc	ra,0xffffe
    80004896:	950080e7          	jalr	-1712(ra) # 800021e2 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    8000489a:	2204b783          	ld	a5,544(s1)
    8000489e:	eb95                	bnez	a5,800048d2 <pipeclose+0x64>
    release(&pi->lock);
    800048a0:	8526                	mv	a0,s1
    800048a2:	ffffc097          	auipc	ra,0xffffc
    800048a6:	3e8080e7          	jalr	1000(ra) # 80000c8a <release>
    kfree((char*)pi);
    800048aa:	8526                	mv	a0,s1
    800048ac:	ffffc097          	auipc	ra,0xffffc
    800048b0:	13e080e7          	jalr	318(ra) # 800009ea <kfree>
  } else
    release(&pi->lock);
}
    800048b4:	60e2                	ld	ra,24(sp)
    800048b6:	6442                	ld	s0,16(sp)
    800048b8:	64a2                	ld	s1,8(sp)
    800048ba:	6902                	ld	s2,0(sp)
    800048bc:	6105                	addi	sp,sp,32
    800048be:	8082                	ret
    pi->readopen = 0;
    800048c0:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    800048c4:	21c48513          	addi	a0,s1,540
    800048c8:	ffffe097          	auipc	ra,0xffffe
    800048cc:	91a080e7          	jalr	-1766(ra) # 800021e2 <wakeup>
    800048d0:	b7e9                	j	8000489a <pipeclose+0x2c>
    release(&pi->lock);
    800048d2:	8526                	mv	a0,s1
    800048d4:	ffffc097          	auipc	ra,0xffffc
    800048d8:	3b6080e7          	jalr	950(ra) # 80000c8a <release>
}
    800048dc:	bfe1                	j	800048b4 <pipeclose+0x46>

00000000800048de <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    800048de:	7159                	addi	sp,sp,-112
    800048e0:	f486                	sd	ra,104(sp)
    800048e2:	f0a2                	sd	s0,96(sp)
    800048e4:	eca6                	sd	s1,88(sp)
    800048e6:	e8ca                	sd	s2,80(sp)
    800048e8:	e4ce                	sd	s3,72(sp)
    800048ea:	e0d2                	sd	s4,64(sp)
    800048ec:	fc56                	sd	s5,56(sp)
    800048ee:	f85a                	sd	s6,48(sp)
    800048f0:	f45e                	sd	s7,40(sp)
    800048f2:	f062                	sd	s8,32(sp)
    800048f4:	ec66                	sd	s9,24(sp)
    800048f6:	1880                	addi	s0,sp,112
    800048f8:	84aa                	mv	s1,a0
    800048fa:	8aae                	mv	s5,a1
    800048fc:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    800048fe:	ffffd097          	auipc	ra,0xffffd
    80004902:	096080e7          	jalr	150(ra) # 80001994 <myproc>
    80004906:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80004908:	8526                	mv	a0,s1
    8000490a:	ffffc097          	auipc	ra,0xffffc
    8000490e:	2cc080e7          	jalr	716(ra) # 80000bd6 <acquire>
  while(i < n){
    80004912:	0d405163          	blez	s4,800049d4 <pipewrite+0xf6>
    80004916:	8ba6                	mv	s7,s1
  int i = 0;
    80004918:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    8000491a:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    8000491c:	21848c93          	addi	s9,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004920:	21c48c13          	addi	s8,s1,540
    80004924:	a08d                	j	80004986 <pipewrite+0xa8>
      release(&pi->lock);
    80004926:	8526                	mv	a0,s1
    80004928:	ffffc097          	auipc	ra,0xffffc
    8000492c:	362080e7          	jalr	866(ra) # 80000c8a <release>
      return -1;
    80004930:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80004932:	854a                	mv	a0,s2
    80004934:	70a6                	ld	ra,104(sp)
    80004936:	7406                	ld	s0,96(sp)
    80004938:	64e6                	ld	s1,88(sp)
    8000493a:	6946                	ld	s2,80(sp)
    8000493c:	69a6                	ld	s3,72(sp)
    8000493e:	6a06                	ld	s4,64(sp)
    80004940:	7ae2                	ld	s5,56(sp)
    80004942:	7b42                	ld	s6,48(sp)
    80004944:	7ba2                	ld	s7,40(sp)
    80004946:	7c02                	ld	s8,32(sp)
    80004948:	6ce2                	ld	s9,24(sp)
    8000494a:	6165                	addi	sp,sp,112
    8000494c:	8082                	ret
      wakeup(&pi->nread);
    8000494e:	8566                	mv	a0,s9
    80004950:	ffffe097          	auipc	ra,0xffffe
    80004954:	892080e7          	jalr	-1902(ra) # 800021e2 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004958:	85de                	mv	a1,s7
    8000495a:	8562                	mv	a0,s8
    8000495c:	ffffd097          	auipc	ra,0xffffd
    80004960:	6fa080e7          	jalr	1786(ra) # 80002056 <sleep>
    80004964:	a839                	j	80004982 <pipewrite+0xa4>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004966:	21c4a783          	lw	a5,540(s1)
    8000496a:	0017871b          	addiw	a4,a5,1
    8000496e:	20e4ae23          	sw	a4,540(s1)
    80004972:	1ff7f793          	andi	a5,a5,511
    80004976:	97a6                	add	a5,a5,s1
    80004978:	f9f44703          	lbu	a4,-97(s0)
    8000497c:	00e78c23          	sb	a4,24(a5)
      i++;
    80004980:	2905                	addiw	s2,s2,1
  while(i < n){
    80004982:	03495d63          	bge	s2,s4,800049bc <pipewrite+0xde>
    if(pi->readopen == 0 || pr->killed){
    80004986:	2204a783          	lw	a5,544(s1)
    8000498a:	dfd1                	beqz	a5,80004926 <pipewrite+0x48>
    8000498c:	0289a783          	lw	a5,40(s3)
    80004990:	fbd9                	bnez	a5,80004926 <pipewrite+0x48>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80004992:	2184a783          	lw	a5,536(s1)
    80004996:	21c4a703          	lw	a4,540(s1)
    8000499a:	2007879b          	addiw	a5,a5,512
    8000499e:	faf708e3          	beq	a4,a5,8000494e <pipewrite+0x70>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    800049a2:	4685                	li	a3,1
    800049a4:	01590633          	add	a2,s2,s5
    800049a8:	f9f40593          	addi	a1,s0,-97
    800049ac:	0589b503          	ld	a0,88(s3)
    800049b0:	ffffd097          	auipc	ra,0xffffd
    800049b4:	d32080e7          	jalr	-718(ra) # 800016e2 <copyin>
    800049b8:	fb6517e3          	bne	a0,s6,80004966 <pipewrite+0x88>
  wakeup(&pi->nread);
    800049bc:	21848513          	addi	a0,s1,536
    800049c0:	ffffe097          	auipc	ra,0xffffe
    800049c4:	822080e7          	jalr	-2014(ra) # 800021e2 <wakeup>
  release(&pi->lock);
    800049c8:	8526                	mv	a0,s1
    800049ca:	ffffc097          	auipc	ra,0xffffc
    800049ce:	2c0080e7          	jalr	704(ra) # 80000c8a <release>
  return i;
    800049d2:	b785                	j	80004932 <pipewrite+0x54>
  int i = 0;
    800049d4:	4901                	li	s2,0
    800049d6:	b7dd                	j	800049bc <pipewrite+0xde>

00000000800049d8 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    800049d8:	715d                	addi	sp,sp,-80
    800049da:	e486                	sd	ra,72(sp)
    800049dc:	e0a2                	sd	s0,64(sp)
    800049de:	fc26                	sd	s1,56(sp)
    800049e0:	f84a                	sd	s2,48(sp)
    800049e2:	f44e                	sd	s3,40(sp)
    800049e4:	f052                	sd	s4,32(sp)
    800049e6:	ec56                	sd	s5,24(sp)
    800049e8:	e85a                	sd	s6,16(sp)
    800049ea:	0880                	addi	s0,sp,80
    800049ec:	84aa                	mv	s1,a0
    800049ee:	892e                	mv	s2,a1
    800049f0:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    800049f2:	ffffd097          	auipc	ra,0xffffd
    800049f6:	fa2080e7          	jalr	-94(ra) # 80001994 <myproc>
    800049fa:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    800049fc:	8b26                	mv	s6,s1
    800049fe:	8526                	mv	a0,s1
    80004a00:	ffffc097          	auipc	ra,0xffffc
    80004a04:	1d6080e7          	jalr	470(ra) # 80000bd6 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004a08:	2184a703          	lw	a4,536(s1)
    80004a0c:	21c4a783          	lw	a5,540(s1)
    if(pr->killed){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004a10:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004a14:	02f71463          	bne	a4,a5,80004a3c <piperead+0x64>
    80004a18:	2244a783          	lw	a5,548(s1)
    80004a1c:	c385                	beqz	a5,80004a3c <piperead+0x64>
    if(pr->killed){
    80004a1e:	028a2783          	lw	a5,40(s4)
    80004a22:	ebc1                	bnez	a5,80004ab2 <piperead+0xda>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004a24:	85da                	mv	a1,s6
    80004a26:	854e                	mv	a0,s3
    80004a28:	ffffd097          	auipc	ra,0xffffd
    80004a2c:	62e080e7          	jalr	1582(ra) # 80002056 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004a30:	2184a703          	lw	a4,536(s1)
    80004a34:	21c4a783          	lw	a5,540(s1)
    80004a38:	fef700e3          	beq	a4,a5,80004a18 <piperead+0x40>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004a3c:	09505263          	blez	s5,80004ac0 <piperead+0xe8>
    80004a40:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004a42:	5b7d                	li	s6,-1
    if(pi->nread == pi->nwrite)
    80004a44:	2184a783          	lw	a5,536(s1)
    80004a48:	21c4a703          	lw	a4,540(s1)
    80004a4c:	02f70d63          	beq	a4,a5,80004a86 <piperead+0xae>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80004a50:	0017871b          	addiw	a4,a5,1
    80004a54:	20e4ac23          	sw	a4,536(s1)
    80004a58:	1ff7f793          	andi	a5,a5,511
    80004a5c:	97a6                	add	a5,a5,s1
    80004a5e:	0187c783          	lbu	a5,24(a5)
    80004a62:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004a66:	4685                	li	a3,1
    80004a68:	fbf40613          	addi	a2,s0,-65
    80004a6c:	85ca                	mv	a1,s2
    80004a6e:	058a3503          	ld	a0,88(s4)
    80004a72:	ffffd097          	auipc	ra,0xffffd
    80004a76:	be4080e7          	jalr	-1052(ra) # 80001656 <copyout>
    80004a7a:	01650663          	beq	a0,s6,80004a86 <piperead+0xae>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004a7e:	2985                	addiw	s3,s3,1
    80004a80:	0905                	addi	s2,s2,1
    80004a82:	fd3a91e3          	bne	s5,s3,80004a44 <piperead+0x6c>
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004a86:	21c48513          	addi	a0,s1,540
    80004a8a:	ffffd097          	auipc	ra,0xffffd
    80004a8e:	758080e7          	jalr	1880(ra) # 800021e2 <wakeup>
  release(&pi->lock);
    80004a92:	8526                	mv	a0,s1
    80004a94:	ffffc097          	auipc	ra,0xffffc
    80004a98:	1f6080e7          	jalr	502(ra) # 80000c8a <release>
  return i;
}
    80004a9c:	854e                	mv	a0,s3
    80004a9e:	60a6                	ld	ra,72(sp)
    80004aa0:	6406                	ld	s0,64(sp)
    80004aa2:	74e2                	ld	s1,56(sp)
    80004aa4:	7942                	ld	s2,48(sp)
    80004aa6:	79a2                	ld	s3,40(sp)
    80004aa8:	7a02                	ld	s4,32(sp)
    80004aaa:	6ae2                	ld	s5,24(sp)
    80004aac:	6b42                	ld	s6,16(sp)
    80004aae:	6161                	addi	sp,sp,80
    80004ab0:	8082                	ret
      release(&pi->lock);
    80004ab2:	8526                	mv	a0,s1
    80004ab4:	ffffc097          	auipc	ra,0xffffc
    80004ab8:	1d6080e7          	jalr	470(ra) # 80000c8a <release>
      return -1;
    80004abc:	59fd                	li	s3,-1
    80004abe:	bff9                	j	80004a9c <piperead+0xc4>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004ac0:	4981                	li	s3,0
    80004ac2:	b7d1                	j	80004a86 <piperead+0xae>

0000000080004ac4 <exec>:

static int loadseg(pde_t *pgdir, uint64 addr, struct inode *ip, uint offset, uint sz);

int
exec(char *path, char **argv)
{
    80004ac4:	df010113          	addi	sp,sp,-528
    80004ac8:	20113423          	sd	ra,520(sp)
    80004acc:	20813023          	sd	s0,512(sp)
    80004ad0:	ffa6                	sd	s1,504(sp)
    80004ad2:	fbca                	sd	s2,496(sp)
    80004ad4:	f7ce                	sd	s3,488(sp)
    80004ad6:	f3d2                	sd	s4,480(sp)
    80004ad8:	efd6                	sd	s5,472(sp)
    80004ada:	ebda                	sd	s6,464(sp)
    80004adc:	e7de                	sd	s7,456(sp)
    80004ade:	e3e2                	sd	s8,448(sp)
    80004ae0:	ff66                	sd	s9,440(sp)
    80004ae2:	fb6a                	sd	s10,432(sp)
    80004ae4:	f76e                	sd	s11,424(sp)
    80004ae6:	0c00                	addi	s0,sp,528
    80004ae8:	84aa                	mv	s1,a0
    80004aea:	dea43c23          	sd	a0,-520(s0)
    80004aee:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004af2:	ffffd097          	auipc	ra,0xffffd
    80004af6:	ea2080e7          	jalr	-350(ra) # 80001994 <myproc>
    80004afa:	892a                	mv	s2,a0

  begin_op();
    80004afc:	fffff097          	auipc	ra,0xfffff
    80004b00:	49c080e7          	jalr	1180(ra) # 80003f98 <begin_op>

  if((ip = namei(path)) == 0){
    80004b04:	8526                	mv	a0,s1
    80004b06:	fffff097          	auipc	ra,0xfffff
    80004b0a:	276080e7          	jalr	630(ra) # 80003d7c <namei>
    80004b0e:	c92d                	beqz	a0,80004b80 <exec+0xbc>
    80004b10:	84aa                	mv	s1,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80004b12:	fffff097          	auipc	ra,0xfffff
    80004b16:	ab4080e7          	jalr	-1356(ra) # 800035c6 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004b1a:	04000713          	li	a4,64
    80004b1e:	4681                	li	a3,0
    80004b20:	e4840613          	addi	a2,s0,-440
    80004b24:	4581                	li	a1,0
    80004b26:	8526                	mv	a0,s1
    80004b28:	fffff097          	auipc	ra,0xfffff
    80004b2c:	d52080e7          	jalr	-686(ra) # 8000387a <readi>
    80004b30:	04000793          	li	a5,64
    80004b34:	00f51a63          	bne	a0,a5,80004b48 <exec+0x84>
    goto bad;
  if(elf.magic != ELF_MAGIC)
    80004b38:	e4842703          	lw	a4,-440(s0)
    80004b3c:	464c47b7          	lui	a5,0x464c4
    80004b40:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004b44:	04f70463          	beq	a4,a5,80004b8c <exec+0xc8>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80004b48:	8526                	mv	a0,s1
    80004b4a:	fffff097          	auipc	ra,0xfffff
    80004b4e:	cde080e7          	jalr	-802(ra) # 80003828 <iunlockput>
    end_op();
    80004b52:	fffff097          	auipc	ra,0xfffff
    80004b56:	4c6080e7          	jalr	1222(ra) # 80004018 <end_op>
  }
  return -1;
    80004b5a:	557d                	li	a0,-1
}
    80004b5c:	20813083          	ld	ra,520(sp)
    80004b60:	20013403          	ld	s0,512(sp)
    80004b64:	74fe                	ld	s1,504(sp)
    80004b66:	795e                	ld	s2,496(sp)
    80004b68:	79be                	ld	s3,488(sp)
    80004b6a:	7a1e                	ld	s4,480(sp)
    80004b6c:	6afe                	ld	s5,472(sp)
    80004b6e:	6b5e                	ld	s6,464(sp)
    80004b70:	6bbe                	ld	s7,456(sp)
    80004b72:	6c1e                	ld	s8,448(sp)
    80004b74:	7cfa                	ld	s9,440(sp)
    80004b76:	7d5a                	ld	s10,432(sp)
    80004b78:	7dba                	ld	s11,424(sp)
    80004b7a:	21010113          	addi	sp,sp,528
    80004b7e:	8082                	ret
    end_op();
    80004b80:	fffff097          	auipc	ra,0xfffff
    80004b84:	498080e7          	jalr	1176(ra) # 80004018 <end_op>
    return -1;
    80004b88:	557d                	li	a0,-1
    80004b8a:	bfc9                	j	80004b5c <exec+0x98>
  if((pagetable = proc_pagetable(p)) == 0)
    80004b8c:	854a                	mv	a0,s2
    80004b8e:	ffffd097          	auipc	ra,0xffffd
    80004b92:	eca080e7          	jalr	-310(ra) # 80001a58 <proc_pagetable>
    80004b96:	8baa                	mv	s7,a0
    80004b98:	d945                	beqz	a0,80004b48 <exec+0x84>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004b9a:	e6842983          	lw	s3,-408(s0)
    80004b9e:	e8045783          	lhu	a5,-384(s0)
    80004ba2:	c7ad                	beqz	a5,80004c0c <exec+0x148>
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
    80004ba4:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004ba6:	4b01                	li	s6,0
    if(ph.vaddr % PGSIZE != 0)
    80004ba8:	6c85                	lui	s9,0x1
    80004baa:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    80004bae:	def43823          	sd	a5,-528(s0)
    80004bb2:	a42d                	j	80004ddc <exec+0x318>
    panic("loadseg: va must be page aligned");

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    80004bb4:	00004517          	auipc	a0,0x4
    80004bb8:	afc50513          	addi	a0,a0,-1284 # 800086b0 <syscalls+0x280>
    80004bbc:	ffffc097          	auipc	ra,0xffffc
    80004bc0:	974080e7          	jalr	-1676(ra) # 80000530 <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80004bc4:	8756                	mv	a4,s5
    80004bc6:	012d86bb          	addw	a3,s11,s2
    80004bca:	4581                	li	a1,0
    80004bcc:	8526                	mv	a0,s1
    80004bce:	fffff097          	auipc	ra,0xfffff
    80004bd2:	cac080e7          	jalr	-852(ra) # 8000387a <readi>
    80004bd6:	2501                	sext.w	a0,a0
    80004bd8:	1aaa9963          	bne	s5,a0,80004d8a <exec+0x2c6>
  for(i = 0; i < sz; i += PGSIZE){
    80004bdc:	6785                	lui	a5,0x1
    80004bde:	0127893b          	addw	s2,a5,s2
    80004be2:	77fd                	lui	a5,0xfffff
    80004be4:	01478a3b          	addw	s4,a5,s4
    80004be8:	1f897163          	bgeu	s2,s8,80004dca <exec+0x306>
    pa = walkaddr(pagetable, va + i);
    80004bec:	02091593          	slli	a1,s2,0x20
    80004bf0:	9181                	srli	a1,a1,0x20
    80004bf2:	95ea                	add	a1,a1,s10
    80004bf4:	855e                	mv	a0,s7
    80004bf6:	ffffc097          	auipc	ra,0xffffc
    80004bfa:	46e080e7          	jalr	1134(ra) # 80001064 <walkaddr>
    80004bfe:	862a                	mv	a2,a0
    if(pa == 0)
    80004c00:	d955                	beqz	a0,80004bb4 <exec+0xf0>
      n = PGSIZE;
    80004c02:	8ae6                	mv	s5,s9
    if(sz - i < PGSIZE)
    80004c04:	fd9a70e3          	bgeu	s4,s9,80004bc4 <exec+0x100>
      n = sz - i;
    80004c08:	8ad2                	mv	s5,s4
    80004c0a:	bf6d                	j	80004bc4 <exec+0x100>
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
    80004c0c:	4901                	li	s2,0
  iunlockput(ip);
    80004c0e:	8526                	mv	a0,s1
    80004c10:	fffff097          	auipc	ra,0xfffff
    80004c14:	c18080e7          	jalr	-1000(ra) # 80003828 <iunlockput>
  end_op();
    80004c18:	fffff097          	auipc	ra,0xfffff
    80004c1c:	400080e7          	jalr	1024(ra) # 80004018 <end_op>
  p = myproc();
    80004c20:	ffffd097          	auipc	ra,0xffffd
    80004c24:	d74080e7          	jalr	-652(ra) # 80001994 <myproc>
    80004c28:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    80004c2a:	05053d03          	ld	s10,80(a0)
  sz = PGROUNDUP(sz);
    80004c2e:	6785                	lui	a5,0x1
    80004c30:	17fd                	addi	a5,a5,-1
    80004c32:	993e                	add	s2,s2,a5
    80004c34:	757d                	lui	a0,0xfffff
    80004c36:	00a977b3          	and	a5,s2,a0
    80004c3a:	e0f43423          	sd	a5,-504(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    80004c3e:	6609                	lui	a2,0x2
    80004c40:	963e                	add	a2,a2,a5
    80004c42:	85be                	mv	a1,a5
    80004c44:	855e                	mv	a0,s7
    80004c46:	ffffc097          	auipc	ra,0xffffc
    80004c4a:	7c0080e7          	jalr	1984(ra) # 80001406 <uvmalloc>
    80004c4e:	8b2a                	mv	s6,a0
  ip = 0;
    80004c50:	4481                	li	s1,0
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    80004c52:	12050c63          	beqz	a0,80004d8a <exec+0x2c6>
  uvmclear(pagetable, sz-2*PGSIZE);
    80004c56:	75f9                	lui	a1,0xffffe
    80004c58:	95aa                	add	a1,a1,a0
    80004c5a:	855e                	mv	a0,s7
    80004c5c:	ffffd097          	auipc	ra,0xffffd
    80004c60:	9c8080e7          	jalr	-1592(ra) # 80001624 <uvmclear>
  stackbase = sp - PGSIZE;
    80004c64:	7c7d                	lui	s8,0xfffff
    80004c66:	9c5a                	add	s8,s8,s6
  for(argc = 0; argv[argc]; argc++) {
    80004c68:	e0043783          	ld	a5,-512(s0)
    80004c6c:	6388                	ld	a0,0(a5)
    80004c6e:	c535                	beqz	a0,80004cda <exec+0x216>
    80004c70:	e8840993          	addi	s3,s0,-376
    80004c74:	f8840c93          	addi	s9,s0,-120
  sp = sz;
    80004c78:	895a                	mv	s2,s6
    sp -= strlen(argv[argc]) + 1;
    80004c7a:	ffffc097          	auipc	ra,0xffffc
    80004c7e:	1e0080e7          	jalr	480(ra) # 80000e5a <strlen>
    80004c82:	2505                	addiw	a0,a0,1
    80004c84:	40a90933          	sub	s2,s2,a0
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80004c88:	ff097913          	andi	s2,s2,-16
    if(sp < stackbase)
    80004c8c:	13896363          	bltu	s2,s8,80004db2 <exec+0x2ee>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80004c90:	e0043d83          	ld	s11,-512(s0)
    80004c94:	000dba03          	ld	s4,0(s11)
    80004c98:	8552                	mv	a0,s4
    80004c9a:	ffffc097          	auipc	ra,0xffffc
    80004c9e:	1c0080e7          	jalr	448(ra) # 80000e5a <strlen>
    80004ca2:	0015069b          	addiw	a3,a0,1
    80004ca6:	8652                	mv	a2,s4
    80004ca8:	85ca                	mv	a1,s2
    80004caa:	855e                	mv	a0,s7
    80004cac:	ffffd097          	auipc	ra,0xffffd
    80004cb0:	9aa080e7          	jalr	-1622(ra) # 80001656 <copyout>
    80004cb4:	10054363          	bltz	a0,80004dba <exec+0x2f6>
    ustack[argc] = sp;
    80004cb8:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80004cbc:	0485                	addi	s1,s1,1
    80004cbe:	008d8793          	addi	a5,s11,8
    80004cc2:	e0f43023          	sd	a5,-512(s0)
    80004cc6:	008db503          	ld	a0,8(s11)
    80004cca:	c911                	beqz	a0,80004cde <exec+0x21a>
    if(argc >= MAXARG)
    80004ccc:	09a1                	addi	s3,s3,8
    80004cce:	fb3c96e3          	bne	s9,s3,80004c7a <exec+0x1b6>
  sz = sz1;
    80004cd2:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    80004cd6:	4481                	li	s1,0
    80004cd8:	a84d                	j	80004d8a <exec+0x2c6>
  sp = sz;
    80004cda:	895a                	mv	s2,s6
  for(argc = 0; argv[argc]; argc++) {
    80004cdc:	4481                	li	s1,0
  ustack[argc] = 0;
    80004cde:	00349793          	slli	a5,s1,0x3
    80004ce2:	f9040713          	addi	a4,s0,-112
    80004ce6:	97ba                	add	a5,a5,a4
    80004ce8:	ee07bc23          	sd	zero,-264(a5) # ef8 <_entry-0x7ffff108>
  sp -= (argc+1) * sizeof(uint64);
    80004cec:	00148693          	addi	a3,s1,1
    80004cf0:	068e                	slli	a3,a3,0x3
    80004cf2:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80004cf6:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    80004cfa:	01897663          	bgeu	s2,s8,80004d06 <exec+0x242>
  sz = sz1;
    80004cfe:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    80004d02:	4481                	li	s1,0
    80004d04:	a059                	j	80004d8a <exec+0x2c6>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80004d06:	e8840613          	addi	a2,s0,-376
    80004d0a:	85ca                	mv	a1,s2
    80004d0c:	855e                	mv	a0,s7
    80004d0e:	ffffd097          	auipc	ra,0xffffd
    80004d12:	948080e7          	jalr	-1720(ra) # 80001656 <copyout>
    80004d16:	0a054663          	bltz	a0,80004dc2 <exec+0x2fe>
  p->trapframe->a1 = sp;
    80004d1a:	060ab783          	ld	a5,96(s5)
    80004d1e:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80004d22:	df843783          	ld	a5,-520(s0)
    80004d26:	0007c703          	lbu	a4,0(a5)
    80004d2a:	cf11                	beqz	a4,80004d46 <exec+0x282>
    80004d2c:	0785                	addi	a5,a5,1
    if(*s == '/')
    80004d2e:	02f00693          	li	a3,47
    80004d32:	a029                	j	80004d3c <exec+0x278>
  for(last=s=path; *s; s++)
    80004d34:	0785                	addi	a5,a5,1
    80004d36:	fff7c703          	lbu	a4,-1(a5)
    80004d3a:	c711                	beqz	a4,80004d46 <exec+0x282>
    if(*s == '/')
    80004d3c:	fed71ce3          	bne	a4,a3,80004d34 <exec+0x270>
      last = s+1;
    80004d40:	def43c23          	sd	a5,-520(s0)
    80004d44:	bfc5                	j	80004d34 <exec+0x270>
  safestrcpy(p->name, last, sizeof(p->name));
    80004d46:	4641                	li	a2,16
    80004d48:	df843583          	ld	a1,-520(s0)
    80004d4c:	160a8513          	addi	a0,s5,352
    80004d50:	ffffc097          	auipc	ra,0xffffc
    80004d54:	0d8080e7          	jalr	216(ra) # 80000e28 <safestrcpy>
  oldpagetable = p->pagetable;
    80004d58:	058ab503          	ld	a0,88(s5)
  p->pagetable = pagetable;
    80004d5c:	057abc23          	sd	s7,88(s5)
  p->sz = sz;
    80004d60:	056ab823          	sd	s6,80(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    80004d64:	060ab783          	ld	a5,96(s5)
    80004d68:	e6043703          	ld	a4,-416(s0)
    80004d6c:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80004d6e:	060ab783          	ld	a5,96(s5)
    80004d72:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80004d76:	85ea                	mv	a1,s10
    80004d78:	ffffd097          	auipc	ra,0xffffd
    80004d7c:	d7c080e7          	jalr	-644(ra) # 80001af4 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80004d80:	0004851b          	sext.w	a0,s1
    80004d84:	bbe1                	j	80004b5c <exec+0x98>
    80004d86:	e1243423          	sd	s2,-504(s0)
    proc_freepagetable(pagetable, sz);
    80004d8a:	e0843583          	ld	a1,-504(s0)
    80004d8e:	855e                	mv	a0,s7
    80004d90:	ffffd097          	auipc	ra,0xffffd
    80004d94:	d64080e7          	jalr	-668(ra) # 80001af4 <proc_freepagetable>
  if(ip){
    80004d98:	da0498e3          	bnez	s1,80004b48 <exec+0x84>
  return -1;
    80004d9c:	557d                	li	a0,-1
    80004d9e:	bb7d                	j	80004b5c <exec+0x98>
    80004da0:	e1243423          	sd	s2,-504(s0)
    80004da4:	b7dd                	j	80004d8a <exec+0x2c6>
    80004da6:	e1243423          	sd	s2,-504(s0)
    80004daa:	b7c5                	j	80004d8a <exec+0x2c6>
    80004dac:	e1243423          	sd	s2,-504(s0)
    80004db0:	bfe9                	j	80004d8a <exec+0x2c6>
  sz = sz1;
    80004db2:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    80004db6:	4481                	li	s1,0
    80004db8:	bfc9                	j	80004d8a <exec+0x2c6>
  sz = sz1;
    80004dba:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    80004dbe:	4481                	li	s1,0
    80004dc0:	b7e9                	j	80004d8a <exec+0x2c6>
  sz = sz1;
    80004dc2:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    80004dc6:	4481                	li	s1,0
    80004dc8:	b7c9                	j	80004d8a <exec+0x2c6>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    80004dca:	e0843903          	ld	s2,-504(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004dce:	2b05                	addiw	s6,s6,1
    80004dd0:	0389899b          	addiw	s3,s3,56
    80004dd4:	e8045783          	lhu	a5,-384(s0)
    80004dd8:	e2fb5be3          	bge	s6,a5,80004c0e <exec+0x14a>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80004ddc:	2981                	sext.w	s3,s3
    80004dde:	03800713          	li	a4,56
    80004de2:	86ce                	mv	a3,s3
    80004de4:	e1040613          	addi	a2,s0,-496
    80004de8:	4581                	li	a1,0
    80004dea:	8526                	mv	a0,s1
    80004dec:	fffff097          	auipc	ra,0xfffff
    80004df0:	a8e080e7          	jalr	-1394(ra) # 8000387a <readi>
    80004df4:	03800793          	li	a5,56
    80004df8:	f8f517e3          	bne	a0,a5,80004d86 <exec+0x2c2>
    if(ph.type != ELF_PROG_LOAD)
    80004dfc:	e1042783          	lw	a5,-496(s0)
    80004e00:	4705                	li	a4,1
    80004e02:	fce796e3          	bne	a5,a4,80004dce <exec+0x30a>
    if(ph.memsz < ph.filesz)
    80004e06:	e3843603          	ld	a2,-456(s0)
    80004e0a:	e3043783          	ld	a5,-464(s0)
    80004e0e:	f8f669e3          	bltu	a2,a5,80004da0 <exec+0x2dc>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80004e12:	e2043783          	ld	a5,-480(s0)
    80004e16:	963e                	add	a2,a2,a5
    80004e18:	f8f667e3          	bltu	a2,a5,80004da6 <exec+0x2e2>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    80004e1c:	85ca                	mv	a1,s2
    80004e1e:	855e                	mv	a0,s7
    80004e20:	ffffc097          	auipc	ra,0xffffc
    80004e24:	5e6080e7          	jalr	1510(ra) # 80001406 <uvmalloc>
    80004e28:	e0a43423          	sd	a0,-504(s0)
    80004e2c:	d141                	beqz	a0,80004dac <exec+0x2e8>
    if(ph.vaddr % PGSIZE != 0)
    80004e2e:	e2043d03          	ld	s10,-480(s0)
    80004e32:	df043783          	ld	a5,-528(s0)
    80004e36:	00fd77b3          	and	a5,s10,a5
    80004e3a:	fba1                	bnez	a5,80004d8a <exec+0x2c6>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80004e3c:	e1842d83          	lw	s11,-488(s0)
    80004e40:	e3042c03          	lw	s8,-464(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80004e44:	f80c03e3          	beqz	s8,80004dca <exec+0x306>
    80004e48:	8a62                	mv	s4,s8
    80004e4a:	4901                	li	s2,0
    80004e4c:	b345                	j	80004bec <exec+0x128>

0000000080004e4e <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80004e4e:	7179                	addi	sp,sp,-48
    80004e50:	f406                	sd	ra,40(sp)
    80004e52:	f022                	sd	s0,32(sp)
    80004e54:	ec26                	sd	s1,24(sp)
    80004e56:	e84a                	sd	s2,16(sp)
    80004e58:	1800                	addi	s0,sp,48
    80004e5a:	892e                	mv	s2,a1
    80004e5c:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
    80004e5e:	fdc40593          	addi	a1,s0,-36
    80004e62:	ffffe097          	auipc	ra,0xffffe
    80004e66:	bf2080e7          	jalr	-1038(ra) # 80002a54 <argint>
    80004e6a:	04054063          	bltz	a0,80004eaa <argfd+0x5c>
    return -1;
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80004e6e:	fdc42703          	lw	a4,-36(s0)
    80004e72:	47bd                	li	a5,15
    80004e74:	02e7ed63          	bltu	a5,a4,80004eae <argfd+0x60>
    80004e78:	ffffd097          	auipc	ra,0xffffd
    80004e7c:	b1c080e7          	jalr	-1252(ra) # 80001994 <myproc>
    80004e80:	fdc42703          	lw	a4,-36(s0)
    80004e84:	01a70793          	addi	a5,a4,26
    80004e88:	078e                	slli	a5,a5,0x3
    80004e8a:	953e                	add	a0,a0,a5
    80004e8c:	651c                	ld	a5,8(a0)
    80004e8e:	c395                	beqz	a5,80004eb2 <argfd+0x64>
    return -1;
  if(pfd)
    80004e90:	00090463          	beqz	s2,80004e98 <argfd+0x4a>
    *pfd = fd;
    80004e94:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80004e98:	4501                	li	a0,0
  if(pf)
    80004e9a:	c091                	beqz	s1,80004e9e <argfd+0x50>
    *pf = f;
    80004e9c:	e09c                	sd	a5,0(s1)
}
    80004e9e:	70a2                	ld	ra,40(sp)
    80004ea0:	7402                	ld	s0,32(sp)
    80004ea2:	64e2                	ld	s1,24(sp)
    80004ea4:	6942                	ld	s2,16(sp)
    80004ea6:	6145                	addi	sp,sp,48
    80004ea8:	8082                	ret
    return -1;
    80004eaa:	557d                	li	a0,-1
    80004eac:	bfcd                	j	80004e9e <argfd+0x50>
    return -1;
    80004eae:	557d                	li	a0,-1
    80004eb0:	b7fd                	j	80004e9e <argfd+0x50>
    80004eb2:	557d                	li	a0,-1
    80004eb4:	b7ed                	j	80004e9e <argfd+0x50>

0000000080004eb6 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80004eb6:	1101                	addi	sp,sp,-32
    80004eb8:	ec06                	sd	ra,24(sp)
    80004eba:	e822                	sd	s0,16(sp)
    80004ebc:	e426                	sd	s1,8(sp)
    80004ebe:	1000                	addi	s0,sp,32
    80004ec0:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80004ec2:	ffffd097          	auipc	ra,0xffffd
    80004ec6:	ad2080e7          	jalr	-1326(ra) # 80001994 <myproc>
    80004eca:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80004ecc:	0d850793          	addi	a5,a0,216 # fffffffffffff0d8 <end+0xffffffff7ffd90d8>
    80004ed0:	4501                	li	a0,0
    80004ed2:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80004ed4:	6398                	ld	a4,0(a5)
    80004ed6:	cb19                	beqz	a4,80004eec <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    80004ed8:	2505                	addiw	a0,a0,1
    80004eda:	07a1                	addi	a5,a5,8
    80004edc:	fed51ce3          	bne	a0,a3,80004ed4 <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80004ee0:	557d                	li	a0,-1
}
    80004ee2:	60e2                	ld	ra,24(sp)
    80004ee4:	6442                	ld	s0,16(sp)
    80004ee6:	64a2                	ld	s1,8(sp)
    80004ee8:	6105                	addi	sp,sp,32
    80004eea:	8082                	ret
      p->ofile[fd] = f;
    80004eec:	01a50793          	addi	a5,a0,26
    80004ef0:	078e                	slli	a5,a5,0x3
    80004ef2:	963e                	add	a2,a2,a5
    80004ef4:	e604                	sd	s1,8(a2)
      return fd;
    80004ef6:	b7f5                	j	80004ee2 <fdalloc+0x2c>

0000000080004ef8 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80004ef8:	715d                	addi	sp,sp,-80
    80004efa:	e486                	sd	ra,72(sp)
    80004efc:	e0a2                	sd	s0,64(sp)
    80004efe:	fc26                	sd	s1,56(sp)
    80004f00:	f84a                	sd	s2,48(sp)
    80004f02:	f44e                	sd	s3,40(sp)
    80004f04:	f052                	sd	s4,32(sp)
    80004f06:	ec56                	sd	s5,24(sp)
    80004f08:	0880                	addi	s0,sp,80
    80004f0a:	89ae                	mv	s3,a1
    80004f0c:	8ab2                	mv	s5,a2
    80004f0e:	8a36                	mv	s4,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80004f10:	fb040593          	addi	a1,s0,-80
    80004f14:	fffff097          	auipc	ra,0xfffff
    80004f18:	e86080e7          	jalr	-378(ra) # 80003d9a <nameiparent>
    80004f1c:	892a                	mv	s2,a0
    80004f1e:	12050f63          	beqz	a0,8000505c <create+0x164>
    return 0;

  ilock(dp);
    80004f22:	ffffe097          	auipc	ra,0xffffe
    80004f26:	6a4080e7          	jalr	1700(ra) # 800035c6 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80004f2a:	4601                	li	a2,0
    80004f2c:	fb040593          	addi	a1,s0,-80
    80004f30:	854a                	mv	a0,s2
    80004f32:	fffff097          	auipc	ra,0xfffff
    80004f36:	b78080e7          	jalr	-1160(ra) # 80003aaa <dirlookup>
    80004f3a:	84aa                	mv	s1,a0
    80004f3c:	c921                	beqz	a0,80004f8c <create+0x94>
    iunlockput(dp);
    80004f3e:	854a                	mv	a0,s2
    80004f40:	fffff097          	auipc	ra,0xfffff
    80004f44:	8e8080e7          	jalr	-1816(ra) # 80003828 <iunlockput>
    ilock(ip);
    80004f48:	8526                	mv	a0,s1
    80004f4a:	ffffe097          	auipc	ra,0xffffe
    80004f4e:	67c080e7          	jalr	1660(ra) # 800035c6 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80004f52:	2981                	sext.w	s3,s3
    80004f54:	4789                	li	a5,2
    80004f56:	02f99463          	bne	s3,a5,80004f7e <create+0x86>
    80004f5a:	0444d783          	lhu	a5,68(s1)
    80004f5e:	37f9                	addiw	a5,a5,-2
    80004f60:	17c2                	slli	a5,a5,0x30
    80004f62:	93c1                	srli	a5,a5,0x30
    80004f64:	4705                	li	a4,1
    80004f66:	00f76c63          	bltu	a4,a5,80004f7e <create+0x86>
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
    80004f6a:	8526                	mv	a0,s1
    80004f6c:	60a6                	ld	ra,72(sp)
    80004f6e:	6406                	ld	s0,64(sp)
    80004f70:	74e2                	ld	s1,56(sp)
    80004f72:	7942                	ld	s2,48(sp)
    80004f74:	79a2                	ld	s3,40(sp)
    80004f76:	7a02                	ld	s4,32(sp)
    80004f78:	6ae2                	ld	s5,24(sp)
    80004f7a:	6161                	addi	sp,sp,80
    80004f7c:	8082                	ret
    iunlockput(ip);
    80004f7e:	8526                	mv	a0,s1
    80004f80:	fffff097          	auipc	ra,0xfffff
    80004f84:	8a8080e7          	jalr	-1880(ra) # 80003828 <iunlockput>
    return 0;
    80004f88:	4481                	li	s1,0
    80004f8a:	b7c5                	j	80004f6a <create+0x72>
  if((ip = ialloc(dp->dev, type)) == 0)
    80004f8c:	85ce                	mv	a1,s3
    80004f8e:	00092503          	lw	a0,0(s2)
    80004f92:	ffffe097          	auipc	ra,0xffffe
    80004f96:	49c080e7          	jalr	1180(ra) # 8000342e <ialloc>
    80004f9a:	84aa                	mv	s1,a0
    80004f9c:	c529                	beqz	a0,80004fe6 <create+0xee>
  ilock(ip);
    80004f9e:	ffffe097          	auipc	ra,0xffffe
    80004fa2:	628080e7          	jalr	1576(ra) # 800035c6 <ilock>
  ip->major = major;
    80004fa6:	05549323          	sh	s5,70(s1)
  ip->minor = minor;
    80004faa:	05449423          	sh	s4,72(s1)
  ip->nlink = 1;
    80004fae:	4785                	li	a5,1
    80004fb0:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80004fb4:	8526                	mv	a0,s1
    80004fb6:	ffffe097          	auipc	ra,0xffffe
    80004fba:	546080e7          	jalr	1350(ra) # 800034fc <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80004fbe:	2981                	sext.w	s3,s3
    80004fc0:	4785                	li	a5,1
    80004fc2:	02f98a63          	beq	s3,a5,80004ff6 <create+0xfe>
  if(dirlink(dp, name, ip->inum) < 0)
    80004fc6:	40d0                	lw	a2,4(s1)
    80004fc8:	fb040593          	addi	a1,s0,-80
    80004fcc:	854a                	mv	a0,s2
    80004fce:	fffff097          	auipc	ra,0xfffff
    80004fd2:	cec080e7          	jalr	-788(ra) # 80003cba <dirlink>
    80004fd6:	06054b63          	bltz	a0,8000504c <create+0x154>
  iunlockput(dp);
    80004fda:	854a                	mv	a0,s2
    80004fdc:	fffff097          	auipc	ra,0xfffff
    80004fe0:	84c080e7          	jalr	-1972(ra) # 80003828 <iunlockput>
  return ip;
    80004fe4:	b759                	j	80004f6a <create+0x72>
    panic("create: ialloc");
    80004fe6:	00003517          	auipc	a0,0x3
    80004fea:	6ea50513          	addi	a0,a0,1770 # 800086d0 <syscalls+0x2a0>
    80004fee:	ffffb097          	auipc	ra,0xffffb
    80004ff2:	542080e7          	jalr	1346(ra) # 80000530 <panic>
    dp->nlink++;  // for ".."
    80004ff6:	04a95783          	lhu	a5,74(s2)
    80004ffa:	2785                	addiw	a5,a5,1
    80004ffc:	04f91523          	sh	a5,74(s2)
    iupdate(dp);
    80005000:	854a                	mv	a0,s2
    80005002:	ffffe097          	auipc	ra,0xffffe
    80005006:	4fa080e7          	jalr	1274(ra) # 800034fc <iupdate>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    8000500a:	40d0                	lw	a2,4(s1)
    8000500c:	00003597          	auipc	a1,0x3
    80005010:	6d458593          	addi	a1,a1,1748 # 800086e0 <syscalls+0x2b0>
    80005014:	8526                	mv	a0,s1
    80005016:	fffff097          	auipc	ra,0xfffff
    8000501a:	ca4080e7          	jalr	-860(ra) # 80003cba <dirlink>
    8000501e:	00054f63          	bltz	a0,8000503c <create+0x144>
    80005022:	00492603          	lw	a2,4(s2)
    80005026:	00003597          	auipc	a1,0x3
    8000502a:	6c258593          	addi	a1,a1,1730 # 800086e8 <syscalls+0x2b8>
    8000502e:	8526                	mv	a0,s1
    80005030:	fffff097          	auipc	ra,0xfffff
    80005034:	c8a080e7          	jalr	-886(ra) # 80003cba <dirlink>
    80005038:	f80557e3          	bgez	a0,80004fc6 <create+0xce>
      panic("create dots");
    8000503c:	00003517          	auipc	a0,0x3
    80005040:	6b450513          	addi	a0,a0,1716 # 800086f0 <syscalls+0x2c0>
    80005044:	ffffb097          	auipc	ra,0xffffb
    80005048:	4ec080e7          	jalr	1260(ra) # 80000530 <panic>
    panic("create: dirlink");
    8000504c:	00003517          	auipc	a0,0x3
    80005050:	6b450513          	addi	a0,a0,1716 # 80008700 <syscalls+0x2d0>
    80005054:	ffffb097          	auipc	ra,0xffffb
    80005058:	4dc080e7          	jalr	1244(ra) # 80000530 <panic>
    return 0;
    8000505c:	84aa                	mv	s1,a0
    8000505e:	b731                	j	80004f6a <create+0x72>

0000000080005060 <sys_dup>:
{
    80005060:	7179                	addi	sp,sp,-48
    80005062:	f406                	sd	ra,40(sp)
    80005064:	f022                	sd	s0,32(sp)
    80005066:	ec26                	sd	s1,24(sp)
    80005068:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    8000506a:	fd840613          	addi	a2,s0,-40
    8000506e:	4581                	li	a1,0
    80005070:	4501                	li	a0,0
    80005072:	00000097          	auipc	ra,0x0
    80005076:	ddc080e7          	jalr	-548(ra) # 80004e4e <argfd>
    return -1;
    8000507a:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    8000507c:	02054363          	bltz	a0,800050a2 <sys_dup+0x42>
  if((fd=fdalloc(f)) < 0)
    80005080:	fd843503          	ld	a0,-40(s0)
    80005084:	00000097          	auipc	ra,0x0
    80005088:	e32080e7          	jalr	-462(ra) # 80004eb6 <fdalloc>
    8000508c:	84aa                	mv	s1,a0
    return -1;
    8000508e:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80005090:	00054963          	bltz	a0,800050a2 <sys_dup+0x42>
  filedup(f);
    80005094:	fd843503          	ld	a0,-40(s0)
    80005098:	fffff097          	auipc	ra,0xfffff
    8000509c:	37a080e7          	jalr	890(ra) # 80004412 <filedup>
  return fd;
    800050a0:	87a6                	mv	a5,s1
}
    800050a2:	853e                	mv	a0,a5
    800050a4:	70a2                	ld	ra,40(sp)
    800050a6:	7402                	ld	s0,32(sp)
    800050a8:	64e2                	ld	s1,24(sp)
    800050aa:	6145                	addi	sp,sp,48
    800050ac:	8082                	ret

00000000800050ae <sys_read>:
{
    800050ae:	7179                	addi	sp,sp,-48
    800050b0:	f406                	sd	ra,40(sp)
    800050b2:	f022                	sd	s0,32(sp)
    800050b4:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800050b6:	fe840613          	addi	a2,s0,-24
    800050ba:	4581                	li	a1,0
    800050bc:	4501                	li	a0,0
    800050be:	00000097          	auipc	ra,0x0
    800050c2:	d90080e7          	jalr	-624(ra) # 80004e4e <argfd>
    return -1;
    800050c6:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800050c8:	04054163          	bltz	a0,8000510a <sys_read+0x5c>
    800050cc:	fe440593          	addi	a1,s0,-28
    800050d0:	4509                	li	a0,2
    800050d2:	ffffe097          	auipc	ra,0xffffe
    800050d6:	982080e7          	jalr	-1662(ra) # 80002a54 <argint>
    return -1;
    800050da:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800050dc:	02054763          	bltz	a0,8000510a <sys_read+0x5c>
    800050e0:	fd840593          	addi	a1,s0,-40
    800050e4:	4505                	li	a0,1
    800050e6:	ffffe097          	auipc	ra,0xffffe
    800050ea:	990080e7          	jalr	-1648(ra) # 80002a76 <argaddr>
    return -1;
    800050ee:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800050f0:	00054d63          	bltz	a0,8000510a <sys_read+0x5c>
  return fileread(f, p, n);
    800050f4:	fe442603          	lw	a2,-28(s0)
    800050f8:	fd843583          	ld	a1,-40(s0)
    800050fc:	fe843503          	ld	a0,-24(s0)
    80005100:	fffff097          	auipc	ra,0xfffff
    80005104:	49e080e7          	jalr	1182(ra) # 8000459e <fileread>
    80005108:	87aa                	mv	a5,a0
}
    8000510a:	853e                	mv	a0,a5
    8000510c:	70a2                	ld	ra,40(sp)
    8000510e:	7402                	ld	s0,32(sp)
    80005110:	6145                	addi	sp,sp,48
    80005112:	8082                	ret

0000000080005114 <sys_write>:
{
    80005114:	7179                	addi	sp,sp,-48
    80005116:	f406                	sd	ra,40(sp)
    80005118:	f022                	sd	s0,32(sp)
    8000511a:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000511c:	fe840613          	addi	a2,s0,-24
    80005120:	4581                	li	a1,0
    80005122:	4501                	li	a0,0
    80005124:	00000097          	auipc	ra,0x0
    80005128:	d2a080e7          	jalr	-726(ra) # 80004e4e <argfd>
    return -1;
    8000512c:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000512e:	04054163          	bltz	a0,80005170 <sys_write+0x5c>
    80005132:	fe440593          	addi	a1,s0,-28
    80005136:	4509                	li	a0,2
    80005138:	ffffe097          	auipc	ra,0xffffe
    8000513c:	91c080e7          	jalr	-1764(ra) # 80002a54 <argint>
    return -1;
    80005140:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005142:	02054763          	bltz	a0,80005170 <sys_write+0x5c>
    80005146:	fd840593          	addi	a1,s0,-40
    8000514a:	4505                	li	a0,1
    8000514c:	ffffe097          	auipc	ra,0xffffe
    80005150:	92a080e7          	jalr	-1750(ra) # 80002a76 <argaddr>
    return -1;
    80005154:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005156:	00054d63          	bltz	a0,80005170 <sys_write+0x5c>
  return filewrite(f, p, n);
    8000515a:	fe442603          	lw	a2,-28(s0)
    8000515e:	fd843583          	ld	a1,-40(s0)
    80005162:	fe843503          	ld	a0,-24(s0)
    80005166:	fffff097          	auipc	ra,0xfffff
    8000516a:	4fa080e7          	jalr	1274(ra) # 80004660 <filewrite>
    8000516e:	87aa                	mv	a5,a0
}
    80005170:	853e                	mv	a0,a5
    80005172:	70a2                	ld	ra,40(sp)
    80005174:	7402                	ld	s0,32(sp)
    80005176:	6145                	addi	sp,sp,48
    80005178:	8082                	ret

000000008000517a <sys_close>:
{
    8000517a:	1101                	addi	sp,sp,-32
    8000517c:	ec06                	sd	ra,24(sp)
    8000517e:	e822                	sd	s0,16(sp)
    80005180:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80005182:	fe040613          	addi	a2,s0,-32
    80005186:	fec40593          	addi	a1,s0,-20
    8000518a:	4501                	li	a0,0
    8000518c:	00000097          	auipc	ra,0x0
    80005190:	cc2080e7          	jalr	-830(ra) # 80004e4e <argfd>
    return -1;
    80005194:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80005196:	02054463          	bltz	a0,800051be <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    8000519a:	ffffc097          	auipc	ra,0xffffc
    8000519e:	7fa080e7          	jalr	2042(ra) # 80001994 <myproc>
    800051a2:	fec42783          	lw	a5,-20(s0)
    800051a6:	07e9                	addi	a5,a5,26
    800051a8:	078e                	slli	a5,a5,0x3
    800051aa:	97aa                	add	a5,a5,a0
    800051ac:	0007b423          	sd	zero,8(a5)
  fileclose(f);
    800051b0:	fe043503          	ld	a0,-32(s0)
    800051b4:	fffff097          	auipc	ra,0xfffff
    800051b8:	2b0080e7          	jalr	688(ra) # 80004464 <fileclose>
  return 0;
    800051bc:	4781                	li	a5,0
}
    800051be:	853e                	mv	a0,a5
    800051c0:	60e2                	ld	ra,24(sp)
    800051c2:	6442                	ld	s0,16(sp)
    800051c4:	6105                	addi	sp,sp,32
    800051c6:	8082                	ret

00000000800051c8 <sys_fstat>:
{
    800051c8:	1101                	addi	sp,sp,-32
    800051ca:	ec06                	sd	ra,24(sp)
    800051cc:	e822                	sd	s0,16(sp)
    800051ce:	1000                	addi	s0,sp,32
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    800051d0:	fe840613          	addi	a2,s0,-24
    800051d4:	4581                	li	a1,0
    800051d6:	4501                	li	a0,0
    800051d8:	00000097          	auipc	ra,0x0
    800051dc:	c76080e7          	jalr	-906(ra) # 80004e4e <argfd>
    return -1;
    800051e0:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    800051e2:	02054563          	bltz	a0,8000520c <sys_fstat+0x44>
    800051e6:	fe040593          	addi	a1,s0,-32
    800051ea:	4505                	li	a0,1
    800051ec:	ffffe097          	auipc	ra,0xffffe
    800051f0:	88a080e7          	jalr	-1910(ra) # 80002a76 <argaddr>
    return -1;
    800051f4:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    800051f6:	00054b63          	bltz	a0,8000520c <sys_fstat+0x44>
  return filestat(f, st);
    800051fa:	fe043583          	ld	a1,-32(s0)
    800051fe:	fe843503          	ld	a0,-24(s0)
    80005202:	fffff097          	auipc	ra,0xfffff
    80005206:	32a080e7          	jalr	810(ra) # 8000452c <filestat>
    8000520a:	87aa                	mv	a5,a0
}
    8000520c:	853e                	mv	a0,a5
    8000520e:	60e2                	ld	ra,24(sp)
    80005210:	6442                	ld	s0,16(sp)
    80005212:	6105                	addi	sp,sp,32
    80005214:	8082                	ret

0000000080005216 <sys_link>:
{
    80005216:	7169                	addi	sp,sp,-304
    80005218:	f606                	sd	ra,296(sp)
    8000521a:	f222                	sd	s0,288(sp)
    8000521c:	ee26                	sd	s1,280(sp)
    8000521e:	ea4a                	sd	s2,272(sp)
    80005220:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005222:	08000613          	li	a2,128
    80005226:	ed040593          	addi	a1,s0,-304
    8000522a:	4501                	li	a0,0
    8000522c:	ffffe097          	auipc	ra,0xffffe
    80005230:	86c080e7          	jalr	-1940(ra) # 80002a98 <argstr>
    return -1;
    80005234:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005236:	10054e63          	bltz	a0,80005352 <sys_link+0x13c>
    8000523a:	08000613          	li	a2,128
    8000523e:	f5040593          	addi	a1,s0,-176
    80005242:	4505                	li	a0,1
    80005244:	ffffe097          	auipc	ra,0xffffe
    80005248:	854080e7          	jalr	-1964(ra) # 80002a98 <argstr>
    return -1;
    8000524c:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000524e:	10054263          	bltz	a0,80005352 <sys_link+0x13c>
  begin_op();
    80005252:	fffff097          	auipc	ra,0xfffff
    80005256:	d46080e7          	jalr	-698(ra) # 80003f98 <begin_op>
  if((ip = namei(old)) == 0){
    8000525a:	ed040513          	addi	a0,s0,-304
    8000525e:	fffff097          	auipc	ra,0xfffff
    80005262:	b1e080e7          	jalr	-1250(ra) # 80003d7c <namei>
    80005266:	84aa                	mv	s1,a0
    80005268:	c551                	beqz	a0,800052f4 <sys_link+0xde>
  ilock(ip);
    8000526a:	ffffe097          	auipc	ra,0xffffe
    8000526e:	35c080e7          	jalr	860(ra) # 800035c6 <ilock>
  if(ip->type == T_DIR){
    80005272:	04449703          	lh	a4,68(s1)
    80005276:	4785                	li	a5,1
    80005278:	08f70463          	beq	a4,a5,80005300 <sys_link+0xea>
  ip->nlink++;
    8000527c:	04a4d783          	lhu	a5,74(s1)
    80005280:	2785                	addiw	a5,a5,1
    80005282:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005286:	8526                	mv	a0,s1
    80005288:	ffffe097          	auipc	ra,0xffffe
    8000528c:	274080e7          	jalr	628(ra) # 800034fc <iupdate>
  iunlock(ip);
    80005290:	8526                	mv	a0,s1
    80005292:	ffffe097          	auipc	ra,0xffffe
    80005296:	3f6080e7          	jalr	1014(ra) # 80003688 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    8000529a:	fd040593          	addi	a1,s0,-48
    8000529e:	f5040513          	addi	a0,s0,-176
    800052a2:	fffff097          	auipc	ra,0xfffff
    800052a6:	af8080e7          	jalr	-1288(ra) # 80003d9a <nameiparent>
    800052aa:	892a                	mv	s2,a0
    800052ac:	c935                	beqz	a0,80005320 <sys_link+0x10a>
  ilock(dp);
    800052ae:	ffffe097          	auipc	ra,0xffffe
    800052b2:	318080e7          	jalr	792(ra) # 800035c6 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    800052b6:	00092703          	lw	a4,0(s2)
    800052ba:	409c                	lw	a5,0(s1)
    800052bc:	04f71d63          	bne	a4,a5,80005316 <sys_link+0x100>
    800052c0:	40d0                	lw	a2,4(s1)
    800052c2:	fd040593          	addi	a1,s0,-48
    800052c6:	854a                	mv	a0,s2
    800052c8:	fffff097          	auipc	ra,0xfffff
    800052cc:	9f2080e7          	jalr	-1550(ra) # 80003cba <dirlink>
    800052d0:	04054363          	bltz	a0,80005316 <sys_link+0x100>
  iunlockput(dp);
    800052d4:	854a                	mv	a0,s2
    800052d6:	ffffe097          	auipc	ra,0xffffe
    800052da:	552080e7          	jalr	1362(ra) # 80003828 <iunlockput>
  iput(ip);
    800052de:	8526                	mv	a0,s1
    800052e0:	ffffe097          	auipc	ra,0xffffe
    800052e4:	4a0080e7          	jalr	1184(ra) # 80003780 <iput>
  end_op();
    800052e8:	fffff097          	auipc	ra,0xfffff
    800052ec:	d30080e7          	jalr	-720(ra) # 80004018 <end_op>
  return 0;
    800052f0:	4781                	li	a5,0
    800052f2:	a085                	j	80005352 <sys_link+0x13c>
    end_op();
    800052f4:	fffff097          	auipc	ra,0xfffff
    800052f8:	d24080e7          	jalr	-732(ra) # 80004018 <end_op>
    return -1;
    800052fc:	57fd                	li	a5,-1
    800052fe:	a891                	j	80005352 <sys_link+0x13c>
    iunlockput(ip);
    80005300:	8526                	mv	a0,s1
    80005302:	ffffe097          	auipc	ra,0xffffe
    80005306:	526080e7          	jalr	1318(ra) # 80003828 <iunlockput>
    end_op();
    8000530a:	fffff097          	auipc	ra,0xfffff
    8000530e:	d0e080e7          	jalr	-754(ra) # 80004018 <end_op>
    return -1;
    80005312:	57fd                	li	a5,-1
    80005314:	a83d                	j	80005352 <sys_link+0x13c>
    iunlockput(dp);
    80005316:	854a                	mv	a0,s2
    80005318:	ffffe097          	auipc	ra,0xffffe
    8000531c:	510080e7          	jalr	1296(ra) # 80003828 <iunlockput>
  ilock(ip);
    80005320:	8526                	mv	a0,s1
    80005322:	ffffe097          	auipc	ra,0xffffe
    80005326:	2a4080e7          	jalr	676(ra) # 800035c6 <ilock>
  ip->nlink--;
    8000532a:	04a4d783          	lhu	a5,74(s1)
    8000532e:	37fd                	addiw	a5,a5,-1
    80005330:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005334:	8526                	mv	a0,s1
    80005336:	ffffe097          	auipc	ra,0xffffe
    8000533a:	1c6080e7          	jalr	454(ra) # 800034fc <iupdate>
  iunlockput(ip);
    8000533e:	8526                	mv	a0,s1
    80005340:	ffffe097          	auipc	ra,0xffffe
    80005344:	4e8080e7          	jalr	1256(ra) # 80003828 <iunlockput>
  end_op();
    80005348:	fffff097          	auipc	ra,0xfffff
    8000534c:	cd0080e7          	jalr	-816(ra) # 80004018 <end_op>
  return -1;
    80005350:	57fd                	li	a5,-1
}
    80005352:	853e                	mv	a0,a5
    80005354:	70b2                	ld	ra,296(sp)
    80005356:	7412                	ld	s0,288(sp)
    80005358:	64f2                	ld	s1,280(sp)
    8000535a:	6952                	ld	s2,272(sp)
    8000535c:	6155                	addi	sp,sp,304
    8000535e:	8082                	ret

0000000080005360 <sys_unlink>:
{
    80005360:	7151                	addi	sp,sp,-240
    80005362:	f586                	sd	ra,232(sp)
    80005364:	f1a2                	sd	s0,224(sp)
    80005366:	eda6                	sd	s1,216(sp)
    80005368:	e9ca                	sd	s2,208(sp)
    8000536a:	e5ce                	sd	s3,200(sp)
    8000536c:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    8000536e:	08000613          	li	a2,128
    80005372:	f3040593          	addi	a1,s0,-208
    80005376:	4501                	li	a0,0
    80005378:	ffffd097          	auipc	ra,0xffffd
    8000537c:	720080e7          	jalr	1824(ra) # 80002a98 <argstr>
    80005380:	18054163          	bltz	a0,80005502 <sys_unlink+0x1a2>
  begin_op();
    80005384:	fffff097          	auipc	ra,0xfffff
    80005388:	c14080e7          	jalr	-1004(ra) # 80003f98 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    8000538c:	fb040593          	addi	a1,s0,-80
    80005390:	f3040513          	addi	a0,s0,-208
    80005394:	fffff097          	auipc	ra,0xfffff
    80005398:	a06080e7          	jalr	-1530(ra) # 80003d9a <nameiparent>
    8000539c:	84aa                	mv	s1,a0
    8000539e:	c979                	beqz	a0,80005474 <sys_unlink+0x114>
  ilock(dp);
    800053a0:	ffffe097          	auipc	ra,0xffffe
    800053a4:	226080e7          	jalr	550(ra) # 800035c6 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    800053a8:	00003597          	auipc	a1,0x3
    800053ac:	33858593          	addi	a1,a1,824 # 800086e0 <syscalls+0x2b0>
    800053b0:	fb040513          	addi	a0,s0,-80
    800053b4:	ffffe097          	auipc	ra,0xffffe
    800053b8:	6dc080e7          	jalr	1756(ra) # 80003a90 <namecmp>
    800053bc:	14050a63          	beqz	a0,80005510 <sys_unlink+0x1b0>
    800053c0:	00003597          	auipc	a1,0x3
    800053c4:	32858593          	addi	a1,a1,808 # 800086e8 <syscalls+0x2b8>
    800053c8:	fb040513          	addi	a0,s0,-80
    800053cc:	ffffe097          	auipc	ra,0xffffe
    800053d0:	6c4080e7          	jalr	1732(ra) # 80003a90 <namecmp>
    800053d4:	12050e63          	beqz	a0,80005510 <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    800053d8:	f2c40613          	addi	a2,s0,-212
    800053dc:	fb040593          	addi	a1,s0,-80
    800053e0:	8526                	mv	a0,s1
    800053e2:	ffffe097          	auipc	ra,0xffffe
    800053e6:	6c8080e7          	jalr	1736(ra) # 80003aaa <dirlookup>
    800053ea:	892a                	mv	s2,a0
    800053ec:	12050263          	beqz	a0,80005510 <sys_unlink+0x1b0>
  ilock(ip);
    800053f0:	ffffe097          	auipc	ra,0xffffe
    800053f4:	1d6080e7          	jalr	470(ra) # 800035c6 <ilock>
  if(ip->nlink < 1)
    800053f8:	04a91783          	lh	a5,74(s2)
    800053fc:	08f05263          	blez	a5,80005480 <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80005400:	04491703          	lh	a4,68(s2)
    80005404:	4785                	li	a5,1
    80005406:	08f70563          	beq	a4,a5,80005490 <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    8000540a:	4641                	li	a2,16
    8000540c:	4581                	li	a1,0
    8000540e:	fc040513          	addi	a0,s0,-64
    80005412:	ffffc097          	auipc	ra,0xffffc
    80005416:	8c0080e7          	jalr	-1856(ra) # 80000cd2 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000541a:	4741                	li	a4,16
    8000541c:	f2c42683          	lw	a3,-212(s0)
    80005420:	fc040613          	addi	a2,s0,-64
    80005424:	4581                	li	a1,0
    80005426:	8526                	mv	a0,s1
    80005428:	ffffe097          	auipc	ra,0xffffe
    8000542c:	54a080e7          	jalr	1354(ra) # 80003972 <writei>
    80005430:	47c1                	li	a5,16
    80005432:	0af51563          	bne	a0,a5,800054dc <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    80005436:	04491703          	lh	a4,68(s2)
    8000543a:	4785                	li	a5,1
    8000543c:	0af70863          	beq	a4,a5,800054ec <sys_unlink+0x18c>
  iunlockput(dp);
    80005440:	8526                	mv	a0,s1
    80005442:	ffffe097          	auipc	ra,0xffffe
    80005446:	3e6080e7          	jalr	998(ra) # 80003828 <iunlockput>
  ip->nlink--;
    8000544a:	04a95783          	lhu	a5,74(s2)
    8000544e:	37fd                	addiw	a5,a5,-1
    80005450:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80005454:	854a                	mv	a0,s2
    80005456:	ffffe097          	auipc	ra,0xffffe
    8000545a:	0a6080e7          	jalr	166(ra) # 800034fc <iupdate>
  iunlockput(ip);
    8000545e:	854a                	mv	a0,s2
    80005460:	ffffe097          	auipc	ra,0xffffe
    80005464:	3c8080e7          	jalr	968(ra) # 80003828 <iunlockput>
  end_op();
    80005468:	fffff097          	auipc	ra,0xfffff
    8000546c:	bb0080e7          	jalr	-1104(ra) # 80004018 <end_op>
  return 0;
    80005470:	4501                	li	a0,0
    80005472:	a84d                	j	80005524 <sys_unlink+0x1c4>
    end_op();
    80005474:	fffff097          	auipc	ra,0xfffff
    80005478:	ba4080e7          	jalr	-1116(ra) # 80004018 <end_op>
    return -1;
    8000547c:	557d                	li	a0,-1
    8000547e:	a05d                	j	80005524 <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    80005480:	00003517          	auipc	a0,0x3
    80005484:	29050513          	addi	a0,a0,656 # 80008710 <syscalls+0x2e0>
    80005488:	ffffb097          	auipc	ra,0xffffb
    8000548c:	0a8080e7          	jalr	168(ra) # 80000530 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005490:	04c92703          	lw	a4,76(s2)
    80005494:	02000793          	li	a5,32
    80005498:	f6e7f9e3          	bgeu	a5,a4,8000540a <sys_unlink+0xaa>
    8000549c:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800054a0:	4741                	li	a4,16
    800054a2:	86ce                	mv	a3,s3
    800054a4:	f1840613          	addi	a2,s0,-232
    800054a8:	4581                	li	a1,0
    800054aa:	854a                	mv	a0,s2
    800054ac:	ffffe097          	auipc	ra,0xffffe
    800054b0:	3ce080e7          	jalr	974(ra) # 8000387a <readi>
    800054b4:	47c1                	li	a5,16
    800054b6:	00f51b63          	bne	a0,a5,800054cc <sys_unlink+0x16c>
    if(de.inum != 0)
    800054ba:	f1845783          	lhu	a5,-232(s0)
    800054be:	e7a1                	bnez	a5,80005506 <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800054c0:	29c1                	addiw	s3,s3,16
    800054c2:	04c92783          	lw	a5,76(s2)
    800054c6:	fcf9ede3          	bltu	s3,a5,800054a0 <sys_unlink+0x140>
    800054ca:	b781                	j	8000540a <sys_unlink+0xaa>
      panic("isdirempty: readi");
    800054cc:	00003517          	auipc	a0,0x3
    800054d0:	25c50513          	addi	a0,a0,604 # 80008728 <syscalls+0x2f8>
    800054d4:	ffffb097          	auipc	ra,0xffffb
    800054d8:	05c080e7          	jalr	92(ra) # 80000530 <panic>
    panic("unlink: writei");
    800054dc:	00003517          	auipc	a0,0x3
    800054e0:	26450513          	addi	a0,a0,612 # 80008740 <syscalls+0x310>
    800054e4:	ffffb097          	auipc	ra,0xffffb
    800054e8:	04c080e7          	jalr	76(ra) # 80000530 <panic>
    dp->nlink--;
    800054ec:	04a4d783          	lhu	a5,74(s1)
    800054f0:	37fd                	addiw	a5,a5,-1
    800054f2:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    800054f6:	8526                	mv	a0,s1
    800054f8:	ffffe097          	auipc	ra,0xffffe
    800054fc:	004080e7          	jalr	4(ra) # 800034fc <iupdate>
    80005500:	b781                	j	80005440 <sys_unlink+0xe0>
    return -1;
    80005502:	557d                	li	a0,-1
    80005504:	a005                	j	80005524 <sys_unlink+0x1c4>
    iunlockput(ip);
    80005506:	854a                	mv	a0,s2
    80005508:	ffffe097          	auipc	ra,0xffffe
    8000550c:	320080e7          	jalr	800(ra) # 80003828 <iunlockput>
  iunlockput(dp);
    80005510:	8526                	mv	a0,s1
    80005512:	ffffe097          	auipc	ra,0xffffe
    80005516:	316080e7          	jalr	790(ra) # 80003828 <iunlockput>
  end_op();
    8000551a:	fffff097          	auipc	ra,0xfffff
    8000551e:	afe080e7          	jalr	-1282(ra) # 80004018 <end_op>
  return -1;
    80005522:	557d                	li	a0,-1
}
    80005524:	70ae                	ld	ra,232(sp)
    80005526:	740e                	ld	s0,224(sp)
    80005528:	64ee                	ld	s1,216(sp)
    8000552a:	694e                	ld	s2,208(sp)
    8000552c:	69ae                	ld	s3,200(sp)
    8000552e:	616d                	addi	sp,sp,240
    80005530:	8082                	ret

0000000080005532 <sys_open>:

uint64
sys_open(void)
{
    80005532:	7131                	addi	sp,sp,-192
    80005534:	fd06                	sd	ra,184(sp)
    80005536:	f922                	sd	s0,176(sp)
    80005538:	f526                	sd	s1,168(sp)
    8000553a:	f14a                	sd	s2,160(sp)
    8000553c:	ed4e                	sd	s3,152(sp)
    8000553e:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    80005540:	08000613          	li	a2,128
    80005544:	f5040593          	addi	a1,s0,-176
    80005548:	4501                	li	a0,0
    8000554a:	ffffd097          	auipc	ra,0xffffd
    8000554e:	54e080e7          	jalr	1358(ra) # 80002a98 <argstr>
    return -1;
    80005552:	54fd                	li	s1,-1
  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    80005554:	0c054163          	bltz	a0,80005616 <sys_open+0xe4>
    80005558:	f4c40593          	addi	a1,s0,-180
    8000555c:	4505                	li	a0,1
    8000555e:	ffffd097          	auipc	ra,0xffffd
    80005562:	4f6080e7          	jalr	1270(ra) # 80002a54 <argint>
    80005566:	0a054863          	bltz	a0,80005616 <sys_open+0xe4>

  begin_op();
    8000556a:	fffff097          	auipc	ra,0xfffff
    8000556e:	a2e080e7          	jalr	-1490(ra) # 80003f98 <begin_op>

  if(omode & O_CREATE){
    80005572:	f4c42783          	lw	a5,-180(s0)
    80005576:	2007f793          	andi	a5,a5,512
    8000557a:	cbdd                	beqz	a5,80005630 <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    8000557c:	4681                	li	a3,0
    8000557e:	4601                	li	a2,0
    80005580:	4589                	li	a1,2
    80005582:	f5040513          	addi	a0,s0,-176
    80005586:	00000097          	auipc	ra,0x0
    8000558a:	972080e7          	jalr	-1678(ra) # 80004ef8 <create>
    8000558e:	892a                	mv	s2,a0
    if(ip == 0){
    80005590:	c959                	beqz	a0,80005626 <sys_open+0xf4>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80005592:	04491703          	lh	a4,68(s2)
    80005596:	478d                	li	a5,3
    80005598:	00f71763          	bne	a4,a5,800055a6 <sys_open+0x74>
    8000559c:	04695703          	lhu	a4,70(s2)
    800055a0:	47a5                	li	a5,9
    800055a2:	0ce7ec63          	bltu	a5,a4,8000567a <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    800055a6:	fffff097          	auipc	ra,0xfffff
    800055aa:	e02080e7          	jalr	-510(ra) # 800043a8 <filealloc>
    800055ae:	89aa                	mv	s3,a0
    800055b0:	10050263          	beqz	a0,800056b4 <sys_open+0x182>
    800055b4:	00000097          	auipc	ra,0x0
    800055b8:	902080e7          	jalr	-1790(ra) # 80004eb6 <fdalloc>
    800055bc:	84aa                	mv	s1,a0
    800055be:	0e054663          	bltz	a0,800056aa <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    800055c2:	04491703          	lh	a4,68(s2)
    800055c6:	478d                	li	a5,3
    800055c8:	0cf70463          	beq	a4,a5,80005690 <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    800055cc:	4789                	li	a5,2
    800055ce:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    800055d2:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    800055d6:	0129bc23          	sd	s2,24(s3)
  f->readable = !(omode & O_WRONLY);
    800055da:	f4c42783          	lw	a5,-180(s0)
    800055de:	0017c713          	xori	a4,a5,1
    800055e2:	8b05                	andi	a4,a4,1
    800055e4:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    800055e8:	0037f713          	andi	a4,a5,3
    800055ec:	00e03733          	snez	a4,a4
    800055f0:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    800055f4:	4007f793          	andi	a5,a5,1024
    800055f8:	c791                	beqz	a5,80005604 <sys_open+0xd2>
    800055fa:	04491703          	lh	a4,68(s2)
    800055fe:	4789                	li	a5,2
    80005600:	08f70f63          	beq	a4,a5,8000569e <sys_open+0x16c>
    itrunc(ip);
  }

  iunlock(ip);
    80005604:	854a                	mv	a0,s2
    80005606:	ffffe097          	auipc	ra,0xffffe
    8000560a:	082080e7          	jalr	130(ra) # 80003688 <iunlock>
  end_op();
    8000560e:	fffff097          	auipc	ra,0xfffff
    80005612:	a0a080e7          	jalr	-1526(ra) # 80004018 <end_op>

  return fd;
}
    80005616:	8526                	mv	a0,s1
    80005618:	70ea                	ld	ra,184(sp)
    8000561a:	744a                	ld	s0,176(sp)
    8000561c:	74aa                	ld	s1,168(sp)
    8000561e:	790a                	ld	s2,160(sp)
    80005620:	69ea                	ld	s3,152(sp)
    80005622:	6129                	addi	sp,sp,192
    80005624:	8082                	ret
      end_op();
    80005626:	fffff097          	auipc	ra,0xfffff
    8000562a:	9f2080e7          	jalr	-1550(ra) # 80004018 <end_op>
      return -1;
    8000562e:	b7e5                	j	80005616 <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    80005630:	f5040513          	addi	a0,s0,-176
    80005634:	ffffe097          	auipc	ra,0xffffe
    80005638:	748080e7          	jalr	1864(ra) # 80003d7c <namei>
    8000563c:	892a                	mv	s2,a0
    8000563e:	c905                	beqz	a0,8000566e <sys_open+0x13c>
    ilock(ip);
    80005640:	ffffe097          	auipc	ra,0xffffe
    80005644:	f86080e7          	jalr	-122(ra) # 800035c6 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005648:	04491703          	lh	a4,68(s2)
    8000564c:	4785                	li	a5,1
    8000564e:	f4f712e3          	bne	a4,a5,80005592 <sys_open+0x60>
    80005652:	f4c42783          	lw	a5,-180(s0)
    80005656:	dba1                	beqz	a5,800055a6 <sys_open+0x74>
      iunlockput(ip);
    80005658:	854a                	mv	a0,s2
    8000565a:	ffffe097          	auipc	ra,0xffffe
    8000565e:	1ce080e7          	jalr	462(ra) # 80003828 <iunlockput>
      end_op();
    80005662:	fffff097          	auipc	ra,0xfffff
    80005666:	9b6080e7          	jalr	-1610(ra) # 80004018 <end_op>
      return -1;
    8000566a:	54fd                	li	s1,-1
    8000566c:	b76d                	j	80005616 <sys_open+0xe4>
      end_op();
    8000566e:	fffff097          	auipc	ra,0xfffff
    80005672:	9aa080e7          	jalr	-1622(ra) # 80004018 <end_op>
      return -1;
    80005676:	54fd                	li	s1,-1
    80005678:	bf79                	j	80005616 <sys_open+0xe4>
    iunlockput(ip);
    8000567a:	854a                	mv	a0,s2
    8000567c:	ffffe097          	auipc	ra,0xffffe
    80005680:	1ac080e7          	jalr	428(ra) # 80003828 <iunlockput>
    end_op();
    80005684:	fffff097          	auipc	ra,0xfffff
    80005688:	994080e7          	jalr	-1644(ra) # 80004018 <end_op>
    return -1;
    8000568c:	54fd                	li	s1,-1
    8000568e:	b761                	j	80005616 <sys_open+0xe4>
    f->type = FD_DEVICE;
    80005690:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    80005694:	04691783          	lh	a5,70(s2)
    80005698:	02f99223          	sh	a5,36(s3)
    8000569c:	bf2d                	j	800055d6 <sys_open+0xa4>
    itrunc(ip);
    8000569e:	854a                	mv	a0,s2
    800056a0:	ffffe097          	auipc	ra,0xffffe
    800056a4:	034080e7          	jalr	52(ra) # 800036d4 <itrunc>
    800056a8:	bfb1                	j	80005604 <sys_open+0xd2>
      fileclose(f);
    800056aa:	854e                	mv	a0,s3
    800056ac:	fffff097          	auipc	ra,0xfffff
    800056b0:	db8080e7          	jalr	-584(ra) # 80004464 <fileclose>
    iunlockput(ip);
    800056b4:	854a                	mv	a0,s2
    800056b6:	ffffe097          	auipc	ra,0xffffe
    800056ba:	172080e7          	jalr	370(ra) # 80003828 <iunlockput>
    end_op();
    800056be:	fffff097          	auipc	ra,0xfffff
    800056c2:	95a080e7          	jalr	-1702(ra) # 80004018 <end_op>
    return -1;
    800056c6:	54fd                	li	s1,-1
    800056c8:	b7b9                	j	80005616 <sys_open+0xe4>

00000000800056ca <sys_mkdir>:

uint64
sys_mkdir(void)
{
    800056ca:	7175                	addi	sp,sp,-144
    800056cc:	e506                	sd	ra,136(sp)
    800056ce:	e122                	sd	s0,128(sp)
    800056d0:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    800056d2:	fffff097          	auipc	ra,0xfffff
    800056d6:	8c6080e7          	jalr	-1850(ra) # 80003f98 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    800056da:	08000613          	li	a2,128
    800056de:	f7040593          	addi	a1,s0,-144
    800056e2:	4501                	li	a0,0
    800056e4:	ffffd097          	auipc	ra,0xffffd
    800056e8:	3b4080e7          	jalr	948(ra) # 80002a98 <argstr>
    800056ec:	02054963          	bltz	a0,8000571e <sys_mkdir+0x54>
    800056f0:	4681                	li	a3,0
    800056f2:	4601                	li	a2,0
    800056f4:	4585                	li	a1,1
    800056f6:	f7040513          	addi	a0,s0,-144
    800056fa:	fffff097          	auipc	ra,0xfffff
    800056fe:	7fe080e7          	jalr	2046(ra) # 80004ef8 <create>
    80005702:	cd11                	beqz	a0,8000571e <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005704:	ffffe097          	auipc	ra,0xffffe
    80005708:	124080e7          	jalr	292(ra) # 80003828 <iunlockput>
  end_op();
    8000570c:	fffff097          	auipc	ra,0xfffff
    80005710:	90c080e7          	jalr	-1780(ra) # 80004018 <end_op>
  return 0;
    80005714:	4501                	li	a0,0
}
    80005716:	60aa                	ld	ra,136(sp)
    80005718:	640a                	ld	s0,128(sp)
    8000571a:	6149                	addi	sp,sp,144
    8000571c:	8082                	ret
    end_op();
    8000571e:	fffff097          	auipc	ra,0xfffff
    80005722:	8fa080e7          	jalr	-1798(ra) # 80004018 <end_op>
    return -1;
    80005726:	557d                	li	a0,-1
    80005728:	b7fd                	j	80005716 <sys_mkdir+0x4c>

000000008000572a <sys_mknod>:

uint64
sys_mknod(void)
{
    8000572a:	7135                	addi	sp,sp,-160
    8000572c:	ed06                	sd	ra,152(sp)
    8000572e:	e922                	sd	s0,144(sp)
    80005730:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005732:	fffff097          	auipc	ra,0xfffff
    80005736:	866080e7          	jalr	-1946(ra) # 80003f98 <begin_op>
  if((argstr(0, path, MAXPATH)) < 0 ||
    8000573a:	08000613          	li	a2,128
    8000573e:	f7040593          	addi	a1,s0,-144
    80005742:	4501                	li	a0,0
    80005744:	ffffd097          	auipc	ra,0xffffd
    80005748:	354080e7          	jalr	852(ra) # 80002a98 <argstr>
    8000574c:	04054a63          	bltz	a0,800057a0 <sys_mknod+0x76>
     argint(1, &major) < 0 ||
    80005750:	f6c40593          	addi	a1,s0,-148
    80005754:	4505                	li	a0,1
    80005756:	ffffd097          	auipc	ra,0xffffd
    8000575a:	2fe080e7          	jalr	766(ra) # 80002a54 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    8000575e:	04054163          	bltz	a0,800057a0 <sys_mknod+0x76>
     argint(2, &minor) < 0 ||
    80005762:	f6840593          	addi	a1,s0,-152
    80005766:	4509                	li	a0,2
    80005768:	ffffd097          	auipc	ra,0xffffd
    8000576c:	2ec080e7          	jalr	748(ra) # 80002a54 <argint>
     argint(1, &major) < 0 ||
    80005770:	02054863          	bltz	a0,800057a0 <sys_mknod+0x76>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005774:	f6841683          	lh	a3,-152(s0)
    80005778:	f6c41603          	lh	a2,-148(s0)
    8000577c:	458d                	li	a1,3
    8000577e:	f7040513          	addi	a0,s0,-144
    80005782:	fffff097          	auipc	ra,0xfffff
    80005786:	776080e7          	jalr	1910(ra) # 80004ef8 <create>
     argint(2, &minor) < 0 ||
    8000578a:	c919                	beqz	a0,800057a0 <sys_mknod+0x76>
    end_op();
    return -1;
  }
  iunlockput(ip);
    8000578c:	ffffe097          	auipc	ra,0xffffe
    80005790:	09c080e7          	jalr	156(ra) # 80003828 <iunlockput>
  end_op();
    80005794:	fffff097          	auipc	ra,0xfffff
    80005798:	884080e7          	jalr	-1916(ra) # 80004018 <end_op>
  return 0;
    8000579c:	4501                	li	a0,0
    8000579e:	a031                	j	800057aa <sys_mknod+0x80>
    end_op();
    800057a0:	fffff097          	auipc	ra,0xfffff
    800057a4:	878080e7          	jalr	-1928(ra) # 80004018 <end_op>
    return -1;
    800057a8:	557d                	li	a0,-1
}
    800057aa:	60ea                	ld	ra,152(sp)
    800057ac:	644a                	ld	s0,144(sp)
    800057ae:	610d                	addi	sp,sp,160
    800057b0:	8082                	ret

00000000800057b2 <sys_chdir>:

uint64
sys_chdir(void)
{
    800057b2:	7135                	addi	sp,sp,-160
    800057b4:	ed06                	sd	ra,152(sp)
    800057b6:	e922                	sd	s0,144(sp)
    800057b8:	e526                	sd	s1,136(sp)
    800057ba:	e14a                	sd	s2,128(sp)
    800057bc:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    800057be:	ffffc097          	auipc	ra,0xffffc
    800057c2:	1d6080e7          	jalr	470(ra) # 80001994 <myproc>
    800057c6:	892a                	mv	s2,a0
  
  begin_op();
    800057c8:	ffffe097          	auipc	ra,0xffffe
    800057cc:	7d0080e7          	jalr	2000(ra) # 80003f98 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    800057d0:	08000613          	li	a2,128
    800057d4:	f6040593          	addi	a1,s0,-160
    800057d8:	4501                	li	a0,0
    800057da:	ffffd097          	auipc	ra,0xffffd
    800057de:	2be080e7          	jalr	702(ra) # 80002a98 <argstr>
    800057e2:	04054b63          	bltz	a0,80005838 <sys_chdir+0x86>
    800057e6:	f6040513          	addi	a0,s0,-160
    800057ea:	ffffe097          	auipc	ra,0xffffe
    800057ee:	592080e7          	jalr	1426(ra) # 80003d7c <namei>
    800057f2:	84aa                	mv	s1,a0
    800057f4:	c131                	beqz	a0,80005838 <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    800057f6:	ffffe097          	auipc	ra,0xffffe
    800057fa:	dd0080e7          	jalr	-560(ra) # 800035c6 <ilock>
  if(ip->type != T_DIR){
    800057fe:	04449703          	lh	a4,68(s1)
    80005802:	4785                	li	a5,1
    80005804:	04f71063          	bne	a4,a5,80005844 <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005808:	8526                	mv	a0,s1
    8000580a:	ffffe097          	auipc	ra,0xffffe
    8000580e:	e7e080e7          	jalr	-386(ra) # 80003688 <iunlock>
  iput(p->cwd);
    80005812:	15893503          	ld	a0,344(s2)
    80005816:	ffffe097          	auipc	ra,0xffffe
    8000581a:	f6a080e7          	jalr	-150(ra) # 80003780 <iput>
  end_op();
    8000581e:	ffffe097          	auipc	ra,0xffffe
    80005822:	7fa080e7          	jalr	2042(ra) # 80004018 <end_op>
  p->cwd = ip;
    80005826:	14993c23          	sd	s1,344(s2)
  return 0;
    8000582a:	4501                	li	a0,0
}
    8000582c:	60ea                	ld	ra,152(sp)
    8000582e:	644a                	ld	s0,144(sp)
    80005830:	64aa                	ld	s1,136(sp)
    80005832:	690a                	ld	s2,128(sp)
    80005834:	610d                	addi	sp,sp,160
    80005836:	8082                	ret
    end_op();
    80005838:	ffffe097          	auipc	ra,0xffffe
    8000583c:	7e0080e7          	jalr	2016(ra) # 80004018 <end_op>
    return -1;
    80005840:	557d                	li	a0,-1
    80005842:	b7ed                	j	8000582c <sys_chdir+0x7a>
    iunlockput(ip);
    80005844:	8526                	mv	a0,s1
    80005846:	ffffe097          	auipc	ra,0xffffe
    8000584a:	fe2080e7          	jalr	-30(ra) # 80003828 <iunlockput>
    end_op();
    8000584e:	ffffe097          	auipc	ra,0xffffe
    80005852:	7ca080e7          	jalr	1994(ra) # 80004018 <end_op>
    return -1;
    80005856:	557d                	li	a0,-1
    80005858:	bfd1                	j	8000582c <sys_chdir+0x7a>

000000008000585a <sys_exec>:

uint64
sys_exec(void)
{
    8000585a:	7145                	addi	sp,sp,-464
    8000585c:	e786                	sd	ra,456(sp)
    8000585e:	e3a2                	sd	s0,448(sp)
    80005860:	ff26                	sd	s1,440(sp)
    80005862:	fb4a                	sd	s2,432(sp)
    80005864:	f74e                	sd	s3,424(sp)
    80005866:	f352                	sd	s4,416(sp)
    80005868:	ef56                	sd	s5,408(sp)
    8000586a:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    8000586c:	08000613          	li	a2,128
    80005870:	f4040593          	addi	a1,s0,-192
    80005874:	4501                	li	a0,0
    80005876:	ffffd097          	auipc	ra,0xffffd
    8000587a:	222080e7          	jalr	546(ra) # 80002a98 <argstr>
    return -1;
    8000587e:	597d                	li	s2,-1
  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80005880:	0c054a63          	bltz	a0,80005954 <sys_exec+0xfa>
    80005884:	e3840593          	addi	a1,s0,-456
    80005888:	4505                	li	a0,1
    8000588a:	ffffd097          	auipc	ra,0xffffd
    8000588e:	1ec080e7          	jalr	492(ra) # 80002a76 <argaddr>
    80005892:	0c054163          	bltz	a0,80005954 <sys_exec+0xfa>
  }
  memset(argv, 0, sizeof(argv));
    80005896:	10000613          	li	a2,256
    8000589a:	4581                	li	a1,0
    8000589c:	e4040513          	addi	a0,s0,-448
    800058a0:	ffffb097          	auipc	ra,0xffffb
    800058a4:	432080e7          	jalr	1074(ra) # 80000cd2 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    800058a8:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    800058ac:	89a6                	mv	s3,s1
    800058ae:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    800058b0:	02000a13          	li	s4,32
    800058b4:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    800058b8:	00391513          	slli	a0,s2,0x3
    800058bc:	e3040593          	addi	a1,s0,-464
    800058c0:	e3843783          	ld	a5,-456(s0)
    800058c4:	953e                	add	a0,a0,a5
    800058c6:	ffffd097          	auipc	ra,0xffffd
    800058ca:	0f4080e7          	jalr	244(ra) # 800029ba <fetchaddr>
    800058ce:	02054a63          	bltz	a0,80005902 <sys_exec+0xa8>
      goto bad;
    }
    if(uarg == 0){
    800058d2:	e3043783          	ld	a5,-464(s0)
    800058d6:	c3b9                	beqz	a5,8000591c <sys_exec+0xc2>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    800058d8:	ffffb097          	auipc	ra,0xffffb
    800058dc:	20e080e7          	jalr	526(ra) # 80000ae6 <kalloc>
    800058e0:	85aa                	mv	a1,a0
    800058e2:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    800058e6:	cd11                	beqz	a0,80005902 <sys_exec+0xa8>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    800058e8:	6605                	lui	a2,0x1
    800058ea:	e3043503          	ld	a0,-464(s0)
    800058ee:	ffffd097          	auipc	ra,0xffffd
    800058f2:	11e080e7          	jalr	286(ra) # 80002a0c <fetchstr>
    800058f6:	00054663          	bltz	a0,80005902 <sys_exec+0xa8>
    if(i >= NELEM(argv)){
    800058fa:	0905                	addi	s2,s2,1
    800058fc:	09a1                	addi	s3,s3,8
    800058fe:	fb491be3          	bne	s2,s4,800058b4 <sys_exec+0x5a>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005902:	10048913          	addi	s2,s1,256
    80005906:	6088                	ld	a0,0(s1)
    80005908:	c529                	beqz	a0,80005952 <sys_exec+0xf8>
    kfree(argv[i]);
    8000590a:	ffffb097          	auipc	ra,0xffffb
    8000590e:	0e0080e7          	jalr	224(ra) # 800009ea <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005912:	04a1                	addi	s1,s1,8
    80005914:	ff2499e3          	bne	s1,s2,80005906 <sys_exec+0xac>
  return -1;
    80005918:	597d                	li	s2,-1
    8000591a:	a82d                	j	80005954 <sys_exec+0xfa>
      argv[i] = 0;
    8000591c:	0a8e                	slli	s5,s5,0x3
    8000591e:	fc040793          	addi	a5,s0,-64
    80005922:	9abe                	add	s5,s5,a5
    80005924:	e80ab023          	sd	zero,-384(s5)
  int ret = exec(path, argv);
    80005928:	e4040593          	addi	a1,s0,-448
    8000592c:	f4040513          	addi	a0,s0,-192
    80005930:	fffff097          	auipc	ra,0xfffff
    80005934:	194080e7          	jalr	404(ra) # 80004ac4 <exec>
    80005938:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000593a:	10048993          	addi	s3,s1,256
    8000593e:	6088                	ld	a0,0(s1)
    80005940:	c911                	beqz	a0,80005954 <sys_exec+0xfa>
    kfree(argv[i]);
    80005942:	ffffb097          	auipc	ra,0xffffb
    80005946:	0a8080e7          	jalr	168(ra) # 800009ea <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000594a:	04a1                	addi	s1,s1,8
    8000594c:	ff3499e3          	bne	s1,s3,8000593e <sys_exec+0xe4>
    80005950:	a011                	j	80005954 <sys_exec+0xfa>
  return -1;
    80005952:	597d                	li	s2,-1
}
    80005954:	854a                	mv	a0,s2
    80005956:	60be                	ld	ra,456(sp)
    80005958:	641e                	ld	s0,448(sp)
    8000595a:	74fa                	ld	s1,440(sp)
    8000595c:	795a                	ld	s2,432(sp)
    8000595e:	79ba                	ld	s3,424(sp)
    80005960:	7a1a                	ld	s4,416(sp)
    80005962:	6afa                	ld	s5,408(sp)
    80005964:	6179                	addi	sp,sp,464
    80005966:	8082                	ret

0000000080005968 <sys_pipe>:

uint64
sys_pipe(void)
{
    80005968:	7139                	addi	sp,sp,-64
    8000596a:	fc06                	sd	ra,56(sp)
    8000596c:	f822                	sd	s0,48(sp)
    8000596e:	f426                	sd	s1,40(sp)
    80005970:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005972:	ffffc097          	auipc	ra,0xffffc
    80005976:	022080e7          	jalr	34(ra) # 80001994 <myproc>
    8000597a:	84aa                	mv	s1,a0

  if(argaddr(0, &fdarray) < 0)
    8000597c:	fd840593          	addi	a1,s0,-40
    80005980:	4501                	li	a0,0
    80005982:	ffffd097          	auipc	ra,0xffffd
    80005986:	0f4080e7          	jalr	244(ra) # 80002a76 <argaddr>
    return -1;
    8000598a:	57fd                	li	a5,-1
  if(argaddr(0, &fdarray) < 0)
    8000598c:	0e054063          	bltz	a0,80005a6c <sys_pipe+0x104>
  if(pipealloc(&rf, &wf) < 0)
    80005990:	fc840593          	addi	a1,s0,-56
    80005994:	fd040513          	addi	a0,s0,-48
    80005998:	fffff097          	auipc	ra,0xfffff
    8000599c:	dfc080e7          	jalr	-516(ra) # 80004794 <pipealloc>
    return -1;
    800059a0:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    800059a2:	0c054563          	bltz	a0,80005a6c <sys_pipe+0x104>
  fd0 = -1;
    800059a6:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    800059aa:	fd043503          	ld	a0,-48(s0)
    800059ae:	fffff097          	auipc	ra,0xfffff
    800059b2:	508080e7          	jalr	1288(ra) # 80004eb6 <fdalloc>
    800059b6:	fca42223          	sw	a0,-60(s0)
    800059ba:	08054c63          	bltz	a0,80005a52 <sys_pipe+0xea>
    800059be:	fc843503          	ld	a0,-56(s0)
    800059c2:	fffff097          	auipc	ra,0xfffff
    800059c6:	4f4080e7          	jalr	1268(ra) # 80004eb6 <fdalloc>
    800059ca:	fca42023          	sw	a0,-64(s0)
    800059ce:	06054863          	bltz	a0,80005a3e <sys_pipe+0xd6>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    800059d2:	4691                	li	a3,4
    800059d4:	fc440613          	addi	a2,s0,-60
    800059d8:	fd843583          	ld	a1,-40(s0)
    800059dc:	6ca8                	ld	a0,88(s1)
    800059de:	ffffc097          	auipc	ra,0xffffc
    800059e2:	c78080e7          	jalr	-904(ra) # 80001656 <copyout>
    800059e6:	02054063          	bltz	a0,80005a06 <sys_pipe+0x9e>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    800059ea:	4691                	li	a3,4
    800059ec:	fc040613          	addi	a2,s0,-64
    800059f0:	fd843583          	ld	a1,-40(s0)
    800059f4:	0591                	addi	a1,a1,4
    800059f6:	6ca8                	ld	a0,88(s1)
    800059f8:	ffffc097          	auipc	ra,0xffffc
    800059fc:	c5e080e7          	jalr	-930(ra) # 80001656 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005a00:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005a02:	06055563          	bgez	a0,80005a6c <sys_pipe+0x104>
    p->ofile[fd0] = 0;
    80005a06:	fc442783          	lw	a5,-60(s0)
    80005a0a:	07e9                	addi	a5,a5,26
    80005a0c:	078e                	slli	a5,a5,0x3
    80005a0e:	97a6                	add	a5,a5,s1
    80005a10:	0007b423          	sd	zero,8(a5)
    p->ofile[fd1] = 0;
    80005a14:	fc042503          	lw	a0,-64(s0)
    80005a18:	0569                	addi	a0,a0,26
    80005a1a:	050e                	slli	a0,a0,0x3
    80005a1c:	9526                	add	a0,a0,s1
    80005a1e:	00053423          	sd	zero,8(a0)
    fileclose(rf);
    80005a22:	fd043503          	ld	a0,-48(s0)
    80005a26:	fffff097          	auipc	ra,0xfffff
    80005a2a:	a3e080e7          	jalr	-1474(ra) # 80004464 <fileclose>
    fileclose(wf);
    80005a2e:	fc843503          	ld	a0,-56(s0)
    80005a32:	fffff097          	auipc	ra,0xfffff
    80005a36:	a32080e7          	jalr	-1486(ra) # 80004464 <fileclose>
    return -1;
    80005a3a:	57fd                	li	a5,-1
    80005a3c:	a805                	j	80005a6c <sys_pipe+0x104>
    if(fd0 >= 0)
    80005a3e:	fc442783          	lw	a5,-60(s0)
    80005a42:	0007c863          	bltz	a5,80005a52 <sys_pipe+0xea>
      p->ofile[fd0] = 0;
    80005a46:	01a78513          	addi	a0,a5,26
    80005a4a:	050e                	slli	a0,a0,0x3
    80005a4c:	9526                	add	a0,a0,s1
    80005a4e:	00053423          	sd	zero,8(a0)
    fileclose(rf);
    80005a52:	fd043503          	ld	a0,-48(s0)
    80005a56:	fffff097          	auipc	ra,0xfffff
    80005a5a:	a0e080e7          	jalr	-1522(ra) # 80004464 <fileclose>
    fileclose(wf);
    80005a5e:	fc843503          	ld	a0,-56(s0)
    80005a62:	fffff097          	auipc	ra,0xfffff
    80005a66:	a02080e7          	jalr	-1534(ra) # 80004464 <fileclose>
    return -1;
    80005a6a:	57fd                	li	a5,-1
}
    80005a6c:	853e                	mv	a0,a5
    80005a6e:	70e2                	ld	ra,56(sp)
    80005a70:	7442                	ld	s0,48(sp)
    80005a72:	74a2                	ld	s1,40(sp)
    80005a74:	6121                	addi	sp,sp,64
    80005a76:	8082                	ret
	...

0000000080005a80 <kernelvec>:
    80005a80:	7111                	addi	sp,sp,-256
    80005a82:	e006                	sd	ra,0(sp)
    80005a84:	e40a                	sd	sp,8(sp)
    80005a86:	e80e                	sd	gp,16(sp)
    80005a88:	ec12                	sd	tp,24(sp)
    80005a8a:	f016                	sd	t0,32(sp)
    80005a8c:	f41a                	sd	t1,40(sp)
    80005a8e:	f81e                	sd	t2,48(sp)
    80005a90:	fc22                	sd	s0,56(sp)
    80005a92:	e0a6                	sd	s1,64(sp)
    80005a94:	e4aa                	sd	a0,72(sp)
    80005a96:	e8ae                	sd	a1,80(sp)
    80005a98:	ecb2                	sd	a2,88(sp)
    80005a9a:	f0b6                	sd	a3,96(sp)
    80005a9c:	f4ba                	sd	a4,104(sp)
    80005a9e:	f8be                	sd	a5,112(sp)
    80005aa0:	fcc2                	sd	a6,120(sp)
    80005aa2:	e146                	sd	a7,128(sp)
    80005aa4:	e54a                	sd	s2,136(sp)
    80005aa6:	e94e                	sd	s3,144(sp)
    80005aa8:	ed52                	sd	s4,152(sp)
    80005aaa:	f156                	sd	s5,160(sp)
    80005aac:	f55a                	sd	s6,168(sp)
    80005aae:	f95e                	sd	s7,176(sp)
    80005ab0:	fd62                	sd	s8,184(sp)
    80005ab2:	e1e6                	sd	s9,192(sp)
    80005ab4:	e5ea                	sd	s10,200(sp)
    80005ab6:	e9ee                	sd	s11,208(sp)
    80005ab8:	edf2                	sd	t3,216(sp)
    80005aba:	f1f6                	sd	t4,224(sp)
    80005abc:	f5fa                	sd	t5,232(sp)
    80005abe:	f9fe                	sd	t6,240(sp)
    80005ac0:	dc7fc0ef          	jal	ra,80002886 <kerneltrap>
    80005ac4:	6082                	ld	ra,0(sp)
    80005ac6:	6122                	ld	sp,8(sp)
    80005ac8:	61c2                	ld	gp,16(sp)
    80005aca:	7282                	ld	t0,32(sp)
    80005acc:	7322                	ld	t1,40(sp)
    80005ace:	73c2                	ld	t2,48(sp)
    80005ad0:	7462                	ld	s0,56(sp)
    80005ad2:	6486                	ld	s1,64(sp)
    80005ad4:	6526                	ld	a0,72(sp)
    80005ad6:	65c6                	ld	a1,80(sp)
    80005ad8:	6666                	ld	a2,88(sp)
    80005ada:	7686                	ld	a3,96(sp)
    80005adc:	7726                	ld	a4,104(sp)
    80005ade:	77c6                	ld	a5,112(sp)
    80005ae0:	7866                	ld	a6,120(sp)
    80005ae2:	688a                	ld	a7,128(sp)
    80005ae4:	692a                	ld	s2,136(sp)
    80005ae6:	69ca                	ld	s3,144(sp)
    80005ae8:	6a6a                	ld	s4,152(sp)
    80005aea:	7a8a                	ld	s5,160(sp)
    80005aec:	7b2a                	ld	s6,168(sp)
    80005aee:	7bca                	ld	s7,176(sp)
    80005af0:	7c6a                	ld	s8,184(sp)
    80005af2:	6c8e                	ld	s9,192(sp)
    80005af4:	6d2e                	ld	s10,200(sp)
    80005af6:	6dce                	ld	s11,208(sp)
    80005af8:	6e6e                	ld	t3,216(sp)
    80005afa:	7e8e                	ld	t4,224(sp)
    80005afc:	7f2e                	ld	t5,232(sp)
    80005afe:	7fce                	ld	t6,240(sp)
    80005b00:	6111                	addi	sp,sp,256
    80005b02:	10200073          	sret
    80005b06:	00000013          	nop
    80005b0a:	00000013          	nop
    80005b0e:	0001                	nop

0000000080005b10 <timervec>:
    80005b10:	34051573          	csrrw	a0,mscratch,a0
    80005b14:	e10c                	sd	a1,0(a0)
    80005b16:	e510                	sd	a2,8(a0)
    80005b18:	e914                	sd	a3,16(a0)
    80005b1a:	6d0c                	ld	a1,24(a0)
    80005b1c:	7110                	ld	a2,32(a0)
    80005b1e:	6194                	ld	a3,0(a1)
    80005b20:	96b2                	add	a3,a3,a2
    80005b22:	e194                	sd	a3,0(a1)
    80005b24:	4589                	li	a1,2
    80005b26:	14459073          	csrw	sip,a1
    80005b2a:	6914                	ld	a3,16(a0)
    80005b2c:	6510                	ld	a2,8(a0)
    80005b2e:	610c                	ld	a1,0(a0)
    80005b30:	34051573          	csrrw	a0,mscratch,a0
    80005b34:	30200073          	mret
	...

0000000080005b3a <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    80005b3a:	1141                	addi	sp,sp,-16
    80005b3c:	e422                	sd	s0,8(sp)
    80005b3e:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80005b40:	0c0007b7          	lui	a5,0xc000
    80005b44:	4705                	li	a4,1
    80005b46:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80005b48:	c3d8                	sw	a4,4(a5)
}
    80005b4a:	6422                	ld	s0,8(sp)
    80005b4c:	0141                	addi	sp,sp,16
    80005b4e:	8082                	ret

0000000080005b50 <plicinithart>:

void
plicinithart(void)
{
    80005b50:	1141                	addi	sp,sp,-16
    80005b52:	e406                	sd	ra,8(sp)
    80005b54:	e022                	sd	s0,0(sp)
    80005b56:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005b58:	ffffc097          	auipc	ra,0xffffc
    80005b5c:	e10080e7          	jalr	-496(ra) # 80001968 <cpuid>
  
  // set uart's enable bit for this hart's S-mode. 
  *(uint32*)PLIC_SENABLE(hart)= (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005b60:	0085171b          	slliw	a4,a0,0x8
    80005b64:	0c0027b7          	lui	a5,0xc002
    80005b68:	97ba                	add	a5,a5,a4
    80005b6a:	40200713          	li	a4,1026
    80005b6e:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005b72:	00d5151b          	slliw	a0,a0,0xd
    80005b76:	0c2017b7          	lui	a5,0xc201
    80005b7a:	953e                	add	a0,a0,a5
    80005b7c:	00052023          	sw	zero,0(a0)
}
    80005b80:	60a2                	ld	ra,8(sp)
    80005b82:	6402                	ld	s0,0(sp)
    80005b84:	0141                	addi	sp,sp,16
    80005b86:	8082                	ret

0000000080005b88 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80005b88:	1141                	addi	sp,sp,-16
    80005b8a:	e406                	sd	ra,8(sp)
    80005b8c:	e022                	sd	s0,0(sp)
    80005b8e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005b90:	ffffc097          	auipc	ra,0xffffc
    80005b94:	dd8080e7          	jalr	-552(ra) # 80001968 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80005b98:	00d5179b          	slliw	a5,a0,0xd
    80005b9c:	0c201537          	lui	a0,0xc201
    80005ba0:	953e                	add	a0,a0,a5
  return irq;
}
    80005ba2:	4148                	lw	a0,4(a0)
    80005ba4:	60a2                	ld	ra,8(sp)
    80005ba6:	6402                	ld	s0,0(sp)
    80005ba8:	0141                	addi	sp,sp,16
    80005baa:	8082                	ret

0000000080005bac <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80005bac:	1101                	addi	sp,sp,-32
    80005bae:	ec06                	sd	ra,24(sp)
    80005bb0:	e822                	sd	s0,16(sp)
    80005bb2:	e426                	sd	s1,8(sp)
    80005bb4:	1000                	addi	s0,sp,32
    80005bb6:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005bb8:	ffffc097          	auipc	ra,0xffffc
    80005bbc:	db0080e7          	jalr	-592(ra) # 80001968 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80005bc0:	00d5151b          	slliw	a0,a0,0xd
    80005bc4:	0c2017b7          	lui	a5,0xc201
    80005bc8:	97aa                	add	a5,a5,a0
    80005bca:	c3c4                	sw	s1,4(a5)
}
    80005bcc:	60e2                	ld	ra,24(sp)
    80005bce:	6442                	ld	s0,16(sp)
    80005bd0:	64a2                	ld	s1,8(sp)
    80005bd2:	6105                	addi	sp,sp,32
    80005bd4:	8082                	ret

0000000080005bd6 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80005bd6:	1141                	addi	sp,sp,-16
    80005bd8:	e406                	sd	ra,8(sp)
    80005bda:	e022                	sd	s0,0(sp)
    80005bdc:	0800                	addi	s0,sp,16
  if(i >= NUM)
    80005bde:	479d                	li	a5,7
    80005be0:	06a7c963          	blt	a5,a0,80005c52 <free_desc+0x7c>
    panic("free_desc 1");
  if(disk.free[i])
    80005be4:	0001d797          	auipc	a5,0x1d
    80005be8:	41c78793          	addi	a5,a5,1052 # 80023000 <disk>
    80005bec:	00a78733          	add	a4,a5,a0
    80005bf0:	6789                	lui	a5,0x2
    80005bf2:	97ba                	add	a5,a5,a4
    80005bf4:	0187c783          	lbu	a5,24(a5) # 2018 <_entry-0x7fffdfe8>
    80005bf8:	e7ad                	bnez	a5,80005c62 <free_desc+0x8c>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80005bfa:	00451793          	slli	a5,a0,0x4
    80005bfe:	0001f717          	auipc	a4,0x1f
    80005c02:	40270713          	addi	a4,a4,1026 # 80025000 <disk+0x2000>
    80005c06:	6314                	ld	a3,0(a4)
    80005c08:	96be                	add	a3,a3,a5
    80005c0a:	0006b023          	sd	zero,0(a3)
  disk.desc[i].len = 0;
    80005c0e:	6314                	ld	a3,0(a4)
    80005c10:	96be                	add	a3,a3,a5
    80005c12:	0006a423          	sw	zero,8(a3)
  disk.desc[i].flags = 0;
    80005c16:	6314                	ld	a3,0(a4)
    80005c18:	96be                	add	a3,a3,a5
    80005c1a:	00069623          	sh	zero,12(a3)
  disk.desc[i].next = 0;
    80005c1e:	6318                	ld	a4,0(a4)
    80005c20:	97ba                	add	a5,a5,a4
    80005c22:	00079723          	sh	zero,14(a5)
  disk.free[i] = 1;
    80005c26:	0001d797          	auipc	a5,0x1d
    80005c2a:	3da78793          	addi	a5,a5,986 # 80023000 <disk>
    80005c2e:	97aa                	add	a5,a5,a0
    80005c30:	6509                	lui	a0,0x2
    80005c32:	953e                	add	a0,a0,a5
    80005c34:	4785                	li	a5,1
    80005c36:	00f50c23          	sb	a5,24(a0) # 2018 <_entry-0x7fffdfe8>
  wakeup(&disk.free[0]);
    80005c3a:	0001f517          	auipc	a0,0x1f
    80005c3e:	3de50513          	addi	a0,a0,990 # 80025018 <disk+0x2018>
    80005c42:	ffffc097          	auipc	ra,0xffffc
    80005c46:	5a0080e7          	jalr	1440(ra) # 800021e2 <wakeup>
}
    80005c4a:	60a2                	ld	ra,8(sp)
    80005c4c:	6402                	ld	s0,0(sp)
    80005c4e:	0141                	addi	sp,sp,16
    80005c50:	8082                	ret
    panic("free_desc 1");
    80005c52:	00003517          	auipc	a0,0x3
    80005c56:	afe50513          	addi	a0,a0,-1282 # 80008750 <syscalls+0x320>
    80005c5a:	ffffb097          	auipc	ra,0xffffb
    80005c5e:	8d6080e7          	jalr	-1834(ra) # 80000530 <panic>
    panic("free_desc 2");
    80005c62:	00003517          	auipc	a0,0x3
    80005c66:	afe50513          	addi	a0,a0,-1282 # 80008760 <syscalls+0x330>
    80005c6a:	ffffb097          	auipc	ra,0xffffb
    80005c6e:	8c6080e7          	jalr	-1850(ra) # 80000530 <panic>

0000000080005c72 <virtio_disk_init>:
{
    80005c72:	1101                	addi	sp,sp,-32
    80005c74:	ec06                	sd	ra,24(sp)
    80005c76:	e822                	sd	s0,16(sp)
    80005c78:	e426                	sd	s1,8(sp)
    80005c7a:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80005c7c:	00003597          	auipc	a1,0x3
    80005c80:	af458593          	addi	a1,a1,-1292 # 80008770 <syscalls+0x340>
    80005c84:	0001f517          	auipc	a0,0x1f
    80005c88:	4a450513          	addi	a0,a0,1188 # 80025128 <disk+0x2128>
    80005c8c:	ffffb097          	auipc	ra,0xffffb
    80005c90:	eba080e7          	jalr	-326(ra) # 80000b46 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005c94:	100017b7          	lui	a5,0x10001
    80005c98:	4398                	lw	a4,0(a5)
    80005c9a:	2701                	sext.w	a4,a4
    80005c9c:	747277b7          	lui	a5,0x74727
    80005ca0:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80005ca4:	0ef71163          	bne	a4,a5,80005d86 <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    80005ca8:	100017b7          	lui	a5,0x10001
    80005cac:	43dc                	lw	a5,4(a5)
    80005cae:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005cb0:	4705                	li	a4,1
    80005cb2:	0ce79a63          	bne	a5,a4,80005d86 <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005cb6:	100017b7          	lui	a5,0x10001
    80005cba:	479c                	lw	a5,8(a5)
    80005cbc:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    80005cbe:	4709                	li	a4,2
    80005cc0:	0ce79363          	bne	a5,a4,80005d86 <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80005cc4:	100017b7          	lui	a5,0x10001
    80005cc8:	47d8                	lw	a4,12(a5)
    80005cca:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005ccc:	554d47b7          	lui	a5,0x554d4
    80005cd0:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80005cd4:	0af71963          	bne	a4,a5,80005d86 <virtio_disk_init+0x114>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005cd8:	100017b7          	lui	a5,0x10001
    80005cdc:	4705                	li	a4,1
    80005cde:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005ce0:	470d                	li	a4,3
    80005ce2:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    80005ce4:	4b94                	lw	a3,16(a5)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80005ce6:	c7ffe737          	lui	a4,0xc7ffe
    80005cea:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fd875f>
    80005cee:	8f75                	and	a4,a4,a3
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80005cf0:	2701                	sext.w	a4,a4
    80005cf2:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005cf4:	472d                	li	a4,11
    80005cf6:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005cf8:	473d                	li	a4,15
    80005cfa:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_GUEST_PAGE_SIZE) = PGSIZE;
    80005cfc:	6705                	lui	a4,0x1
    80005cfe:	d798                	sw	a4,40(a5)
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80005d00:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80005d04:	5bdc                	lw	a5,52(a5)
    80005d06:	2781                	sext.w	a5,a5
  if(max == 0)
    80005d08:	c7d9                	beqz	a5,80005d96 <virtio_disk_init+0x124>
  if(max < NUM)
    80005d0a:	471d                	li	a4,7
    80005d0c:	08f77d63          	bgeu	a4,a5,80005da6 <virtio_disk_init+0x134>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80005d10:	100014b7          	lui	s1,0x10001
    80005d14:	47a1                	li	a5,8
    80005d16:	dc9c                	sw	a5,56(s1)
  memset(disk.pages, 0, sizeof(disk.pages));
    80005d18:	6609                	lui	a2,0x2
    80005d1a:	4581                	li	a1,0
    80005d1c:	0001d517          	auipc	a0,0x1d
    80005d20:	2e450513          	addi	a0,a0,740 # 80023000 <disk>
    80005d24:	ffffb097          	auipc	ra,0xffffb
    80005d28:	fae080e7          	jalr	-82(ra) # 80000cd2 <memset>
  *R(VIRTIO_MMIO_QUEUE_PFN) = ((uint64)disk.pages) >> PGSHIFT;
    80005d2c:	0001d717          	auipc	a4,0x1d
    80005d30:	2d470713          	addi	a4,a4,724 # 80023000 <disk>
    80005d34:	00c75793          	srli	a5,a4,0xc
    80005d38:	2781                	sext.w	a5,a5
    80005d3a:	c0bc                	sw	a5,64(s1)
  disk.desc = (struct virtq_desc *) disk.pages;
    80005d3c:	0001f797          	auipc	a5,0x1f
    80005d40:	2c478793          	addi	a5,a5,708 # 80025000 <disk+0x2000>
    80005d44:	e398                	sd	a4,0(a5)
  disk.avail = (struct virtq_avail *)(disk.pages + NUM*sizeof(struct virtq_desc));
    80005d46:	0001d717          	auipc	a4,0x1d
    80005d4a:	33a70713          	addi	a4,a4,826 # 80023080 <disk+0x80>
    80005d4e:	e798                	sd	a4,8(a5)
  disk.used = (struct virtq_used *) (disk.pages + PGSIZE);
    80005d50:	0001e717          	auipc	a4,0x1e
    80005d54:	2b070713          	addi	a4,a4,688 # 80024000 <disk+0x1000>
    80005d58:	eb98                	sd	a4,16(a5)
    disk.free[i] = 1;
    80005d5a:	4705                	li	a4,1
    80005d5c:	00e78c23          	sb	a4,24(a5)
    80005d60:	00e78ca3          	sb	a4,25(a5)
    80005d64:	00e78d23          	sb	a4,26(a5)
    80005d68:	00e78da3          	sb	a4,27(a5)
    80005d6c:	00e78e23          	sb	a4,28(a5)
    80005d70:	00e78ea3          	sb	a4,29(a5)
    80005d74:	00e78f23          	sb	a4,30(a5)
    80005d78:	00e78fa3          	sb	a4,31(a5)
}
    80005d7c:	60e2                	ld	ra,24(sp)
    80005d7e:	6442                	ld	s0,16(sp)
    80005d80:	64a2                	ld	s1,8(sp)
    80005d82:	6105                	addi	sp,sp,32
    80005d84:	8082                	ret
    panic("could not find virtio disk");
    80005d86:	00003517          	auipc	a0,0x3
    80005d8a:	9fa50513          	addi	a0,a0,-1542 # 80008780 <syscalls+0x350>
    80005d8e:	ffffa097          	auipc	ra,0xffffa
    80005d92:	7a2080e7          	jalr	1954(ra) # 80000530 <panic>
    panic("virtio disk has no queue 0");
    80005d96:	00003517          	auipc	a0,0x3
    80005d9a:	a0a50513          	addi	a0,a0,-1526 # 800087a0 <syscalls+0x370>
    80005d9e:	ffffa097          	auipc	ra,0xffffa
    80005da2:	792080e7          	jalr	1938(ra) # 80000530 <panic>
    panic("virtio disk max queue too short");
    80005da6:	00003517          	auipc	a0,0x3
    80005daa:	a1a50513          	addi	a0,a0,-1510 # 800087c0 <syscalls+0x390>
    80005dae:	ffffa097          	auipc	ra,0xffffa
    80005db2:	782080e7          	jalr	1922(ra) # 80000530 <panic>

0000000080005db6 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80005db6:	7159                	addi	sp,sp,-112
    80005db8:	f486                	sd	ra,104(sp)
    80005dba:	f0a2                	sd	s0,96(sp)
    80005dbc:	eca6                	sd	s1,88(sp)
    80005dbe:	e8ca                	sd	s2,80(sp)
    80005dc0:	e4ce                	sd	s3,72(sp)
    80005dc2:	e0d2                	sd	s4,64(sp)
    80005dc4:	fc56                	sd	s5,56(sp)
    80005dc6:	f85a                	sd	s6,48(sp)
    80005dc8:	f45e                	sd	s7,40(sp)
    80005dca:	f062                	sd	s8,32(sp)
    80005dcc:	ec66                	sd	s9,24(sp)
    80005dce:	e86a                	sd	s10,16(sp)
    80005dd0:	1880                	addi	s0,sp,112
    80005dd2:	892a                	mv	s2,a0
    80005dd4:	8d2e                	mv	s10,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80005dd6:	00c52c83          	lw	s9,12(a0)
    80005dda:	001c9c9b          	slliw	s9,s9,0x1
    80005dde:	1c82                	slli	s9,s9,0x20
    80005de0:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    80005de4:	0001f517          	auipc	a0,0x1f
    80005de8:	34450513          	addi	a0,a0,836 # 80025128 <disk+0x2128>
    80005dec:	ffffb097          	auipc	ra,0xffffb
    80005df0:	dea080e7          	jalr	-534(ra) # 80000bd6 <acquire>
  for(int i = 0; i < 3; i++){
    80005df4:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    80005df6:	4c21                	li	s8,8
      disk.free[i] = 0;
    80005df8:	0001db97          	auipc	s7,0x1d
    80005dfc:	208b8b93          	addi	s7,s7,520 # 80023000 <disk>
    80005e00:	6b09                	lui	s6,0x2
  for(int i = 0; i < 3; i++){
    80005e02:	4a8d                	li	s5,3
  for(int i = 0; i < NUM; i++){
    80005e04:	8a4e                	mv	s4,s3
    80005e06:	a051                	j	80005e8a <virtio_disk_rw+0xd4>
      disk.free[i] = 0;
    80005e08:	00fb86b3          	add	a3,s7,a5
    80005e0c:	96da                	add	a3,a3,s6
    80005e0e:	00068c23          	sb	zero,24(a3)
    idx[i] = alloc_desc();
    80005e12:	c21c                	sw	a5,0(a2)
    if(idx[i] < 0){
    80005e14:	0207c563          	bltz	a5,80005e3e <virtio_disk_rw+0x88>
  for(int i = 0; i < 3; i++){
    80005e18:	2485                	addiw	s1,s1,1
    80005e1a:	0711                	addi	a4,a4,4
    80005e1c:	25548063          	beq	s1,s5,8000605c <virtio_disk_rw+0x2a6>
    idx[i] = alloc_desc();
    80005e20:	863a                	mv	a2,a4
  for(int i = 0; i < NUM; i++){
    80005e22:	0001f697          	auipc	a3,0x1f
    80005e26:	1f668693          	addi	a3,a3,502 # 80025018 <disk+0x2018>
    80005e2a:	87d2                	mv	a5,s4
    if(disk.free[i]){
    80005e2c:	0006c583          	lbu	a1,0(a3)
    80005e30:	fde1                	bnez	a1,80005e08 <virtio_disk_rw+0x52>
  for(int i = 0; i < NUM; i++){
    80005e32:	2785                	addiw	a5,a5,1
    80005e34:	0685                	addi	a3,a3,1
    80005e36:	ff879be3          	bne	a5,s8,80005e2c <virtio_disk_rw+0x76>
    idx[i] = alloc_desc();
    80005e3a:	57fd                	li	a5,-1
    80005e3c:	c21c                	sw	a5,0(a2)
      for(int j = 0; j < i; j++)
    80005e3e:	02905a63          	blez	s1,80005e72 <virtio_disk_rw+0xbc>
        free_desc(idx[j]);
    80005e42:	f9042503          	lw	a0,-112(s0)
    80005e46:	00000097          	auipc	ra,0x0
    80005e4a:	d90080e7          	jalr	-624(ra) # 80005bd6 <free_desc>
      for(int j = 0; j < i; j++)
    80005e4e:	4785                	li	a5,1
    80005e50:	0297d163          	bge	a5,s1,80005e72 <virtio_disk_rw+0xbc>
        free_desc(idx[j]);
    80005e54:	f9442503          	lw	a0,-108(s0)
    80005e58:	00000097          	auipc	ra,0x0
    80005e5c:	d7e080e7          	jalr	-642(ra) # 80005bd6 <free_desc>
      for(int j = 0; j < i; j++)
    80005e60:	4789                	li	a5,2
    80005e62:	0097d863          	bge	a5,s1,80005e72 <virtio_disk_rw+0xbc>
        free_desc(idx[j]);
    80005e66:	f9842503          	lw	a0,-104(s0)
    80005e6a:	00000097          	auipc	ra,0x0
    80005e6e:	d6c080e7          	jalr	-660(ra) # 80005bd6 <free_desc>
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80005e72:	0001f597          	auipc	a1,0x1f
    80005e76:	2b658593          	addi	a1,a1,694 # 80025128 <disk+0x2128>
    80005e7a:	0001f517          	auipc	a0,0x1f
    80005e7e:	19e50513          	addi	a0,a0,414 # 80025018 <disk+0x2018>
    80005e82:	ffffc097          	auipc	ra,0xffffc
    80005e86:	1d4080e7          	jalr	468(ra) # 80002056 <sleep>
  for(int i = 0; i < 3; i++){
    80005e8a:	f9040713          	addi	a4,s0,-112
    80005e8e:	84ce                	mv	s1,s3
    80005e90:	bf41                	j	80005e20 <virtio_disk_rw+0x6a>
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];

  if(write)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
    80005e92:	20058713          	addi	a4,a1,512
    80005e96:	00471693          	slli	a3,a4,0x4
    80005e9a:	0001d717          	auipc	a4,0x1d
    80005e9e:	16670713          	addi	a4,a4,358 # 80023000 <disk>
    80005ea2:	9736                	add	a4,a4,a3
    80005ea4:	4685                	li	a3,1
    80005ea6:	0ad72423          	sw	a3,168(a4)
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80005eaa:	20058713          	addi	a4,a1,512
    80005eae:	00471693          	slli	a3,a4,0x4
    80005eb2:	0001d717          	auipc	a4,0x1d
    80005eb6:	14e70713          	addi	a4,a4,334 # 80023000 <disk>
    80005eba:	9736                	add	a4,a4,a3
    80005ebc:	0a072623          	sw	zero,172(a4)
  buf0->sector = sector;
    80005ec0:	0b973823          	sd	s9,176(a4)

  disk.desc[idx[0]].addr = (uint64) buf0;
    80005ec4:	7679                	lui	a2,0xffffe
    80005ec6:	963e                	add	a2,a2,a5
    80005ec8:	0001f697          	auipc	a3,0x1f
    80005ecc:	13868693          	addi	a3,a3,312 # 80025000 <disk+0x2000>
    80005ed0:	6298                	ld	a4,0(a3)
    80005ed2:	9732                	add	a4,a4,a2
    80005ed4:	e308                	sd	a0,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80005ed6:	6298                	ld	a4,0(a3)
    80005ed8:	9732                	add	a4,a4,a2
    80005eda:	4541                	li	a0,16
    80005edc:	c708                	sw	a0,8(a4)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80005ede:	6298                	ld	a4,0(a3)
    80005ee0:	9732                	add	a4,a4,a2
    80005ee2:	4505                	li	a0,1
    80005ee4:	00a71623          	sh	a0,12(a4)
  disk.desc[idx[0]].next = idx[1];
    80005ee8:	f9442703          	lw	a4,-108(s0)
    80005eec:	6288                	ld	a0,0(a3)
    80005eee:	962a                	add	a2,a2,a0
    80005ef0:	00e61723          	sh	a4,14(a2) # ffffffffffffe00e <end+0xffffffff7ffd800e>

  disk.desc[idx[1]].addr = (uint64) b->data;
    80005ef4:	0712                	slli	a4,a4,0x4
    80005ef6:	6290                	ld	a2,0(a3)
    80005ef8:	963a                	add	a2,a2,a4
    80005efa:	05890513          	addi	a0,s2,88
    80005efe:	e208                	sd	a0,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    80005f00:	6294                	ld	a3,0(a3)
    80005f02:	96ba                	add	a3,a3,a4
    80005f04:	40000613          	li	a2,1024
    80005f08:	c690                	sw	a2,8(a3)
  if(write)
    80005f0a:	140d0063          	beqz	s10,8000604a <virtio_disk_rw+0x294>
    disk.desc[idx[1]].flags = 0; // device reads b->data
    80005f0e:	0001f697          	auipc	a3,0x1f
    80005f12:	0f26b683          	ld	a3,242(a3) # 80025000 <disk+0x2000>
    80005f16:	96ba                	add	a3,a3,a4
    80005f18:	00069623          	sh	zero,12(a3)
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80005f1c:	0001d817          	auipc	a6,0x1d
    80005f20:	0e480813          	addi	a6,a6,228 # 80023000 <disk>
    80005f24:	0001f517          	auipc	a0,0x1f
    80005f28:	0dc50513          	addi	a0,a0,220 # 80025000 <disk+0x2000>
    80005f2c:	6114                	ld	a3,0(a0)
    80005f2e:	96ba                	add	a3,a3,a4
    80005f30:	00c6d603          	lhu	a2,12(a3)
    80005f34:	00166613          	ori	a2,a2,1
    80005f38:	00c69623          	sh	a2,12(a3)
  disk.desc[idx[1]].next = idx[2];
    80005f3c:	f9842683          	lw	a3,-104(s0)
    80005f40:	6110                	ld	a2,0(a0)
    80005f42:	9732                	add	a4,a4,a2
    80005f44:	00d71723          	sh	a3,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80005f48:	20058613          	addi	a2,a1,512
    80005f4c:	0612                	slli	a2,a2,0x4
    80005f4e:	9642                	add	a2,a2,a6
    80005f50:	577d                	li	a4,-1
    80005f52:	02e60823          	sb	a4,48(a2)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    80005f56:	00469713          	slli	a4,a3,0x4
    80005f5a:	6114                	ld	a3,0(a0)
    80005f5c:	96ba                	add	a3,a3,a4
    80005f5e:	03078793          	addi	a5,a5,48
    80005f62:	97c2                	add	a5,a5,a6
    80005f64:	e29c                	sd	a5,0(a3)
  disk.desc[idx[2]].len = 1;
    80005f66:	611c                	ld	a5,0(a0)
    80005f68:	97ba                	add	a5,a5,a4
    80005f6a:	4685                	li	a3,1
    80005f6c:	c794                	sw	a3,8(a5)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80005f6e:	611c                	ld	a5,0(a0)
    80005f70:	97ba                	add	a5,a5,a4
    80005f72:	4809                	li	a6,2
    80005f74:	01079623          	sh	a6,12(a5)
  disk.desc[idx[2]].next = 0;
    80005f78:	611c                	ld	a5,0(a0)
    80005f7a:	973e                	add	a4,a4,a5
    80005f7c:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80005f80:	00d92223          	sw	a3,4(s2)
  disk.info[idx[0]].b = b;
    80005f84:	03263423          	sd	s2,40(a2)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80005f88:	6518                	ld	a4,8(a0)
    80005f8a:	00275783          	lhu	a5,2(a4)
    80005f8e:	8b9d                	andi	a5,a5,7
    80005f90:	0786                	slli	a5,a5,0x1
    80005f92:	97ba                	add	a5,a5,a4
    80005f94:	00b79223          	sh	a1,4(a5)

  __sync_synchronize();
    80005f98:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80005f9c:	6518                	ld	a4,8(a0)
    80005f9e:	00275783          	lhu	a5,2(a4)
    80005fa2:	2785                	addiw	a5,a5,1
    80005fa4:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80005fa8:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80005fac:	100017b7          	lui	a5,0x10001
    80005fb0:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80005fb4:	00492703          	lw	a4,4(s2)
    80005fb8:	4785                	li	a5,1
    80005fba:	02f71163          	bne	a4,a5,80005fdc <virtio_disk_rw+0x226>
    sleep(b, &disk.vdisk_lock);
    80005fbe:	0001f997          	auipc	s3,0x1f
    80005fc2:	16a98993          	addi	s3,s3,362 # 80025128 <disk+0x2128>
  while(b->disk == 1) {
    80005fc6:	4485                	li	s1,1
    sleep(b, &disk.vdisk_lock);
    80005fc8:	85ce                	mv	a1,s3
    80005fca:	854a                	mv	a0,s2
    80005fcc:	ffffc097          	auipc	ra,0xffffc
    80005fd0:	08a080e7          	jalr	138(ra) # 80002056 <sleep>
  while(b->disk == 1) {
    80005fd4:	00492783          	lw	a5,4(s2)
    80005fd8:	fe9788e3          	beq	a5,s1,80005fc8 <virtio_disk_rw+0x212>
  }

  disk.info[idx[0]].b = 0;
    80005fdc:	f9042903          	lw	s2,-112(s0)
    80005fe0:	20090793          	addi	a5,s2,512
    80005fe4:	00479713          	slli	a4,a5,0x4
    80005fe8:	0001d797          	auipc	a5,0x1d
    80005fec:	01878793          	addi	a5,a5,24 # 80023000 <disk>
    80005ff0:	97ba                	add	a5,a5,a4
    80005ff2:	0207b423          	sd	zero,40(a5)
    int flag = disk.desc[i].flags;
    80005ff6:	0001f997          	auipc	s3,0x1f
    80005ffa:	00a98993          	addi	s3,s3,10 # 80025000 <disk+0x2000>
    80005ffe:	00491713          	slli	a4,s2,0x4
    80006002:	0009b783          	ld	a5,0(s3)
    80006006:	97ba                	add	a5,a5,a4
    80006008:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    8000600c:	854a                	mv	a0,s2
    8000600e:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80006012:	00000097          	auipc	ra,0x0
    80006016:	bc4080e7          	jalr	-1084(ra) # 80005bd6 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    8000601a:	8885                	andi	s1,s1,1
    8000601c:	f0ed                	bnez	s1,80005ffe <virtio_disk_rw+0x248>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    8000601e:	0001f517          	auipc	a0,0x1f
    80006022:	10a50513          	addi	a0,a0,266 # 80025128 <disk+0x2128>
    80006026:	ffffb097          	auipc	ra,0xffffb
    8000602a:	c64080e7          	jalr	-924(ra) # 80000c8a <release>
}
    8000602e:	70a6                	ld	ra,104(sp)
    80006030:	7406                	ld	s0,96(sp)
    80006032:	64e6                	ld	s1,88(sp)
    80006034:	6946                	ld	s2,80(sp)
    80006036:	69a6                	ld	s3,72(sp)
    80006038:	6a06                	ld	s4,64(sp)
    8000603a:	7ae2                	ld	s5,56(sp)
    8000603c:	7b42                	ld	s6,48(sp)
    8000603e:	7ba2                	ld	s7,40(sp)
    80006040:	7c02                	ld	s8,32(sp)
    80006042:	6ce2                	ld	s9,24(sp)
    80006044:	6d42                	ld	s10,16(sp)
    80006046:	6165                	addi	sp,sp,112
    80006048:	8082                	ret
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    8000604a:	0001f697          	auipc	a3,0x1f
    8000604e:	fb66b683          	ld	a3,-74(a3) # 80025000 <disk+0x2000>
    80006052:	96ba                	add	a3,a3,a4
    80006054:	4609                	li	a2,2
    80006056:	00c69623          	sh	a2,12(a3)
    8000605a:	b5c9                	j	80005f1c <virtio_disk_rw+0x166>
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    8000605c:	f9042583          	lw	a1,-112(s0)
    80006060:	20058793          	addi	a5,a1,512
    80006064:	0792                	slli	a5,a5,0x4
    80006066:	0001d517          	auipc	a0,0x1d
    8000606a:	04250513          	addi	a0,a0,66 # 800230a8 <disk+0xa8>
    8000606e:	953e                	add	a0,a0,a5
  if(write)
    80006070:	e20d11e3          	bnez	s10,80005e92 <virtio_disk_rw+0xdc>
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
    80006074:	20058713          	addi	a4,a1,512
    80006078:	00471693          	slli	a3,a4,0x4
    8000607c:	0001d717          	auipc	a4,0x1d
    80006080:	f8470713          	addi	a4,a4,-124 # 80023000 <disk>
    80006084:	9736                	add	a4,a4,a3
    80006086:	0a072423          	sw	zero,168(a4)
    8000608a:	b505                	j	80005eaa <virtio_disk_rw+0xf4>

000000008000608c <virtio_disk_intr>:

void
virtio_disk_intr()
{
    8000608c:	1101                	addi	sp,sp,-32
    8000608e:	ec06                	sd	ra,24(sp)
    80006090:	e822                	sd	s0,16(sp)
    80006092:	e426                	sd	s1,8(sp)
    80006094:	e04a                	sd	s2,0(sp)
    80006096:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80006098:	0001f517          	auipc	a0,0x1f
    8000609c:	09050513          	addi	a0,a0,144 # 80025128 <disk+0x2128>
    800060a0:	ffffb097          	auipc	ra,0xffffb
    800060a4:	b36080e7          	jalr	-1226(ra) # 80000bd6 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    800060a8:	10001737          	lui	a4,0x10001
    800060ac:	533c                	lw	a5,96(a4)
    800060ae:	8b8d                	andi	a5,a5,3
    800060b0:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    800060b2:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    800060b6:	0001f797          	auipc	a5,0x1f
    800060ba:	f4a78793          	addi	a5,a5,-182 # 80025000 <disk+0x2000>
    800060be:	6b94                	ld	a3,16(a5)
    800060c0:	0207d703          	lhu	a4,32(a5)
    800060c4:	0026d783          	lhu	a5,2(a3)
    800060c8:	06f70163          	beq	a4,a5,8000612a <virtio_disk_intr+0x9e>
    __sync_synchronize();
    int id = disk.used->ring[disk.used_idx % NUM].id;
    800060cc:	0001d917          	auipc	s2,0x1d
    800060d0:	f3490913          	addi	s2,s2,-204 # 80023000 <disk>
    800060d4:	0001f497          	auipc	s1,0x1f
    800060d8:	f2c48493          	addi	s1,s1,-212 # 80025000 <disk+0x2000>
    __sync_synchronize();
    800060dc:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    800060e0:	6898                	ld	a4,16(s1)
    800060e2:	0204d783          	lhu	a5,32(s1)
    800060e6:	8b9d                	andi	a5,a5,7
    800060e8:	078e                	slli	a5,a5,0x3
    800060ea:	97ba                	add	a5,a5,a4
    800060ec:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    800060ee:	20078713          	addi	a4,a5,512
    800060f2:	0712                	slli	a4,a4,0x4
    800060f4:	974a                	add	a4,a4,s2
    800060f6:	03074703          	lbu	a4,48(a4) # 10001030 <_entry-0x6fffefd0>
    800060fa:	e731                	bnez	a4,80006146 <virtio_disk_intr+0xba>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    800060fc:	20078793          	addi	a5,a5,512
    80006100:	0792                	slli	a5,a5,0x4
    80006102:	97ca                	add	a5,a5,s2
    80006104:	7788                	ld	a0,40(a5)
    b->disk = 0;   // disk is done with buf
    80006106:	00052223          	sw	zero,4(a0)
    wakeup(b);
    8000610a:	ffffc097          	auipc	ra,0xffffc
    8000610e:	0d8080e7          	jalr	216(ra) # 800021e2 <wakeup>

    disk.used_idx += 1;
    80006112:	0204d783          	lhu	a5,32(s1)
    80006116:	2785                	addiw	a5,a5,1
    80006118:	17c2                	slli	a5,a5,0x30
    8000611a:	93c1                	srli	a5,a5,0x30
    8000611c:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80006120:	6898                	ld	a4,16(s1)
    80006122:	00275703          	lhu	a4,2(a4)
    80006126:	faf71be3          	bne	a4,a5,800060dc <virtio_disk_intr+0x50>
  }

  release(&disk.vdisk_lock);
    8000612a:	0001f517          	auipc	a0,0x1f
    8000612e:	ffe50513          	addi	a0,a0,-2 # 80025128 <disk+0x2128>
    80006132:	ffffb097          	auipc	ra,0xffffb
    80006136:	b58080e7          	jalr	-1192(ra) # 80000c8a <release>
}
    8000613a:	60e2                	ld	ra,24(sp)
    8000613c:	6442                	ld	s0,16(sp)
    8000613e:	64a2                	ld	s1,8(sp)
    80006140:	6902                	ld	s2,0(sp)
    80006142:	6105                	addi	sp,sp,32
    80006144:	8082                	ret
      panic("virtio_disk_intr status");
    80006146:	00002517          	auipc	a0,0x2
    8000614a:	69a50513          	addi	a0,a0,1690 # 800087e0 <syscalls+0x3b0>
    8000614e:	ffffa097          	auipc	ra,0xffffa
    80006152:	3e2080e7          	jalr	994(ra) # 80000530 <panic>
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
