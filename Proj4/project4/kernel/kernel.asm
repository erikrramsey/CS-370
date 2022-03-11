
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
    80000068:	b9c78793          	addi	a5,a5,-1124 # 80005c00 <timervec>
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
    80000ece:	7e6080e7          	jalr	2022(ra) # 800026b0 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000ed2:	00005097          	auipc	ra,0x5
    80000ed6:	d6e080e7          	jalr	-658(ra) # 80005c40 <plicinithart>
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
    80000f46:	746080e7          	jalr	1862(ra) # 80002688 <trapinit>
    trapinithart();  // install kernel trap vector
    80000f4a:	00001097          	auipc	ra,0x1
    80000f4e:	766080e7          	jalr	1894(ra) # 800026b0 <trapinithart>
    plicinit();      // set up interrupt controller
    80000f52:	00005097          	auipc	ra,0x5
    80000f56:	cd8080e7          	jalr	-808(ra) # 80005c2a <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000f5a:	00005097          	auipc	ra,0x5
    80000f5e:	ce6080e7          	jalr	-794(ra) # 80005c40 <plicinithart>
    binit();         // buffer cache
    80000f62:	00002097          	auipc	ra,0x2
    80000f66:	ec2080e7          	jalr	-318(ra) # 80002e24 <binit>
    iinit();         // inode cache
    80000f6a:	00002097          	auipc	ra,0x2
    80000f6e:	552080e7          	jalr	1362(ra) # 800034bc <iinit>
    fileinit();      // file table
    80000f72:	00003097          	auipc	ra,0x3
    80000f76:	4fc080e7          	jalr	1276(ra) # 8000446e <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f7a:	00005097          	auipc	ra,0x5
    80000f7e:	de8080e7          	jalr	-536(ra) # 80005d62 <virtio_disk_init>
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
    800019e8:	e1c7a783          	lw	a5,-484(a5) # 80008800 <first.2383>
    800019ec:	eb89                	bnez	a5,800019fe <forkret+0x32>
    // be run from main().
    first = 0;
    fsinit(ROOTDEV);
  }

  usertrapret();
    800019ee:	00001097          	auipc	ra,0x1
    800019f2:	cda080e7          	jalr	-806(ra) # 800026c8 <usertrapret>
}
    800019f6:	60a2                	ld	ra,8(sp)
    800019f8:	6402                	ld	s0,0(sp)
    800019fa:	0141                	addi	sp,sp,16
    800019fc:	8082                	ret
    first = 0;
    800019fe:	00007797          	auipc	a5,0x7
    80001a02:	e007a123          	sw	zero,-510(a5) # 80008800 <first.2383>
    fsinit(ROOTDEV);
    80001a06:	4505                	li	a0,1
    80001a08:	00002097          	auipc	ra,0x2
    80001a0c:	a34080e7          	jalr	-1484(ra) # 8000343c <fsinit>
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
    80001c90:	b8458593          	addi	a1,a1,-1148 # 80008810 <initcode>
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
    80001cce:	1a0080e7          	jalr	416(ra) # 80003e6a <namei>
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
    80001e0a:	6fa080e7          	jalr	1786(ra) # 80004500 <filedup>
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
    80001e2c:	84e080e7          	jalr	-1970(ra) # 80003676 <idup>
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
    80001f0e:	06048593          	addi	a1,s1,96
    80001f12:	8556                	mv	a0,s5
    80001f14:	00000097          	auipc	ra,0x0
    80001f18:	70a080e7          	jalr	1802(ra) # 8000261e <swtch>
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
    80001fb4:	06048513          	addi	a0,s1,96
    80001fb8:	00000097          	auipc	ra,0x0
    80001fbc:	666080e7          	jalr	1638(ra) # 8000261e <swtch>
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
    80002120:	05093503          	ld	a0,80(s2)
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
    8000217c:	7c9c                	ld	a5,56(s1)
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
    8000228c:	7c9c                	ld	a5,56(s1)
    8000228e:	ff279be3          	bne	a5,s2,80002284 <reparent+0x2c>
      pp->parent = initproc;
    80002292:	000a3503          	ld	a0,0(s4)
    80002296:	fc88                	sd	a0,56(s1)
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
    800022d6:	0d050493          	addi	s1,a0,208
    800022da:	15050913          	addi	s2,a0,336
    800022de:	02a79363          	bne	a5,a0,80002304 <exit+0x52>
    panic("init exiting");
    800022e2:	00006517          	auipc	a0,0x6
    800022e6:	f6650513          	addi	a0,a0,-154 # 80008248 <digits+0x208>
    800022ea:	ffffe097          	auipc	ra,0xffffe
    800022ee:	246080e7          	jalr	582(ra) # 80000530 <panic>
      fileclose(f);
    800022f2:	00002097          	auipc	ra,0x2
    800022f6:	260080e7          	jalr	608(ra) # 80004552 <fileclose>
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
    8000230e:	d7c080e7          	jalr	-644(ra) # 80004086 <begin_op>
  iput(p->cwd);
    80002312:	1509b503          	ld	a0,336(s3)
    80002316:	00001097          	auipc	ra,0x1
    8000231a:	558080e7          	jalr	1368(ra) # 8000386e <iput>
  end_op();
    8000231e:	00002097          	auipc	ra,0x2
    80002322:	de8080e7          	jalr	-536(ra) # 80004106 <end_op>
  p->cwd = 0;
    80002326:	1409b823          	sd	zero,336(s3)
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
    80002346:	0389b503          	ld	a0,56(s3)
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
    80002422:	6928                	ld	a0,80(a0)
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
    80002478:	6928                	ld	a0,80(a0)
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
    800024d0:	35c48493          	addi	s1,s1,860 # 80011828 <proc+0x158>
    800024d4:	00015917          	auipc	s2,0x15
    800024d8:	f5490913          	addi	s2,s2,-172 # 80017428 <bcache+0x140>
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
    800024fa:	db2b8b93          	addi	s7,s7,-590 # 800082a8 <states.2420>
    800024fe:	a00d                	j	80002520 <procdump+0x7a>
    printf("%d %s %s", p->pid, state, p->name);
    80002500:	ed86a583          	lw	a1,-296(a3)
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
    80002522:	ec04a783          	lw	a5,-320(s1)
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

int
ps(struct ps_proc* procs) {
    80002554:	715d                	addi	sp,sp,-80
    80002556:	e486                	sd	ra,72(sp)
    80002558:	e0a2                	sd	s0,64(sp)
    8000255a:	fc26                	sd	s1,56(sp)
    8000255c:	f84a                	sd	s2,48(sp)
    8000255e:	f44e                	sd	s3,40(sp)
    80002560:	f052                	sd	s4,32(sp)
    80002562:	ec56                	sd	s5,24(sp)
    80002564:	e85a                	sd	s6,16(sp)
    80002566:	e45e                	sd	s7,8(sp)
    80002568:	e062                	sd	s8,0(sp)
    8000256a:	0880                	addi	s0,sp,80
    8000256c:	8c2a                	mv	s8,a0
  struct ps_proc ps_procs[MAX_PROCS];
    8000256e:	da010113          	addi	sp,sp,-608
    80002572:	8b0a                	mv	s6,sp
  struct proc* p = myproc();
    80002574:	fffff097          	auipc	ra,0xfffff
    80002578:	420080e7          	jalr	1056(ra) # 80001994 <myproc>
    8000257c:	8baa                	mv	s7,a0

  int total_procs = 0;
  for (int i = 0; i < NPROC && total_procs < MAX_PROCS; i++) {
    8000257e:	0000f497          	auipc	s1,0xf
    80002582:	2aa48493          	addi	s1,s1,682 # 80011828 <proc+0x158>
    80002586:	00015a17          	auipc	s4,0x15
    8000258a:	d32a0a13          	addi	s4,s4,-718 # 800172b8 <proc+0x5be8>
  int total_procs = 0;
    8000258e:	4981                	li	s3,0
  for (int i = 0; i < NPROC && total_procs < MAX_PROCS; i++) {
    80002590:	4ab9                	li	s5,14
    80002592:	a099                	j	800025d8 <ps+0x84>
    if (proc[i].state != UNUSED) {
      strncpy(ps_procs[total_procs].name, proc[i].name, 16);
    80002594:	00299913          	slli	s2,s3,0x2
    80002598:	994e                	add	s2,s2,s3
    8000259a:	090e                	slli	s2,s2,0x3
    8000259c:	995a                	add	s2,s2,s6
    8000259e:	4641                	li	a2,16
    800025a0:	85a6                	mv	a1,s1
    800025a2:	854a                	mv	a0,s2
    800025a4:	fffff097          	auipc	ra,0xfffff
    800025a8:	846080e7          	jalr	-1978(ra) # 80000dea <strncpy>
      ps_procs[total_procs].memory = proc[i].sz;
    800025ac:	ef04b783          	ld	a5,-272(s1)
    800025b0:	02f93023          	sd	a5,32(s2)
      ps_procs[total_procs].priority = proc[i].priority;
    800025b4:	489c                	lw	a5,16(s1)
    800025b6:	00f92c23          	sw	a5,24(s2)
      ps_procs[total_procs].state = proc[i].state;
    800025ba:	ec04a783          	lw	a5,-320(s1)
    800025be:	00f92823          	sw	a5,16(s2)
      ps_procs[total_procs].pid = proc[i].pid;
    800025c2:	ed84a783          	lw	a5,-296(s1)
    800025c6:	00f92a23          	sw	a5,20(s2)
      
      total_procs++;
    800025ca:	2985                	addiw	s3,s3,1
  for (int i = 0; i < NPROC && total_procs < MAX_PROCS; i++) {
    800025cc:	01448a63          	beq	s1,s4,800025e0 <ps+0x8c>
    800025d0:	17048493          	addi	s1,s1,368
    800025d4:	013ac663          	blt	s5,s3,800025e0 <ps+0x8c>
    if (proc[i].state != UNUSED) {
    800025d8:	ec04a783          	lw	a5,-320(s1)
    800025dc:	dbe5                	beqz	a5,800025cc <ps+0x78>
    800025de:	bf5d                	j	80002594 <ps+0x40>
    }
  }

  if (copyout(p->pagetable,(uint64)procs, (char*)ps_procs, sizeof(struct ps_proc) * total_procs) < 0) {
    800025e0:	00299693          	slli	a3,s3,0x2
    800025e4:	96ce                	add	a3,a3,s3
    800025e6:	068e                	slli	a3,a3,0x3
    800025e8:	865a                	mv	a2,s6
    800025ea:	85e2                	mv	a1,s8
    800025ec:	050bb503          	ld	a0,80(s7)
    800025f0:	fffff097          	auipc	ra,0xfffff
    800025f4:	066080e7          	jalr	102(ra) # 80001656 <copyout>
    800025f8:	02054163          	bltz	a0,8000261a <ps+0xc6>
    return -1;
  }

  return total_procs;
    800025fc:	854e                	mv	a0,s3
    800025fe:	fb040113          	addi	sp,s0,-80
    80002602:	60a6                	ld	ra,72(sp)
    80002604:	6406                	ld	s0,64(sp)
    80002606:	74e2                	ld	s1,56(sp)
    80002608:	7942                	ld	s2,48(sp)
    8000260a:	79a2                	ld	s3,40(sp)
    8000260c:	7a02                	ld	s4,32(sp)
    8000260e:	6ae2                	ld	s5,24(sp)
    80002610:	6b42                	ld	s6,16(sp)
    80002612:	6ba2                	ld	s7,8(sp)
    80002614:	6c02                	ld	s8,0(sp)
    80002616:	6161                	addi	sp,sp,80
    80002618:	8082                	ret
    return -1;
    8000261a:	59fd                	li	s3,-1
    8000261c:	b7c5                	j	800025fc <ps+0xa8>

000000008000261e <swtch>:
    8000261e:	00153023          	sd	ra,0(a0)
    80002622:	00253423          	sd	sp,8(a0)
    80002626:	e900                	sd	s0,16(a0)
    80002628:	ed04                	sd	s1,24(a0)
    8000262a:	03253023          	sd	s2,32(a0)
    8000262e:	03353423          	sd	s3,40(a0)
    80002632:	03453823          	sd	s4,48(a0)
    80002636:	03553c23          	sd	s5,56(a0)
    8000263a:	05653023          	sd	s6,64(a0)
    8000263e:	05753423          	sd	s7,72(a0)
    80002642:	05853823          	sd	s8,80(a0)
    80002646:	05953c23          	sd	s9,88(a0)
    8000264a:	07a53023          	sd	s10,96(a0)
    8000264e:	07b53423          	sd	s11,104(a0)
    80002652:	0005b083          	ld	ra,0(a1)
    80002656:	0085b103          	ld	sp,8(a1)
    8000265a:	6980                	ld	s0,16(a1)
    8000265c:	6d84                	ld	s1,24(a1)
    8000265e:	0205b903          	ld	s2,32(a1)
    80002662:	0285b983          	ld	s3,40(a1)
    80002666:	0305ba03          	ld	s4,48(a1)
    8000266a:	0385ba83          	ld	s5,56(a1)
    8000266e:	0405bb03          	ld	s6,64(a1)
    80002672:	0485bb83          	ld	s7,72(a1)
    80002676:	0505bc03          	ld	s8,80(a1)
    8000267a:	0585bc83          	ld	s9,88(a1)
    8000267e:	0605bd03          	ld	s10,96(a1)
    80002682:	0685bd83          	ld	s11,104(a1)
    80002686:	8082                	ret

0000000080002688 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    80002688:	1141                	addi	sp,sp,-16
    8000268a:	e406                	sd	ra,8(sp)
    8000268c:	e022                	sd	s0,0(sp)
    8000268e:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002690:	00006597          	auipc	a1,0x6
    80002694:	c4858593          	addi	a1,a1,-952 # 800082d8 <states.2420+0x30>
    80002698:	00015517          	auipc	a0,0x15
    8000269c:	c3850513          	addi	a0,a0,-968 # 800172d0 <tickslock>
    800026a0:	ffffe097          	auipc	ra,0xffffe
    800026a4:	4a6080e7          	jalr	1190(ra) # 80000b46 <initlock>
}
    800026a8:	60a2                	ld	ra,8(sp)
    800026aa:	6402                	ld	s0,0(sp)
    800026ac:	0141                	addi	sp,sp,16
    800026ae:	8082                	ret

00000000800026b0 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    800026b0:	1141                	addi	sp,sp,-16
    800026b2:	e422                	sd	s0,8(sp)
    800026b4:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    800026b6:	00003797          	auipc	a5,0x3
    800026ba:	4ba78793          	addi	a5,a5,1210 # 80005b70 <kernelvec>
    800026be:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    800026c2:	6422                	ld	s0,8(sp)
    800026c4:	0141                	addi	sp,sp,16
    800026c6:	8082                	ret

00000000800026c8 <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    800026c8:	1141                	addi	sp,sp,-16
    800026ca:	e406                	sd	ra,8(sp)
    800026cc:	e022                	sd	s0,0(sp)
    800026ce:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    800026d0:	fffff097          	auipc	ra,0xfffff
    800026d4:	2c4080e7          	jalr	708(ra) # 80001994 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800026d8:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    800026dc:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800026de:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to trampoline.S
  w_stvec(TRAMPOLINE + (uservec - trampoline));
    800026e2:	00005617          	auipc	a2,0x5
    800026e6:	91e60613          	addi	a2,a2,-1762 # 80007000 <_trampoline>
    800026ea:	00005697          	auipc	a3,0x5
    800026ee:	91668693          	addi	a3,a3,-1770 # 80007000 <_trampoline>
    800026f2:	8e91                	sub	a3,a3,a2
    800026f4:	040007b7          	lui	a5,0x4000
    800026f8:	17fd                	addi	a5,a5,-1
    800026fa:	07b2                	slli	a5,a5,0xc
    800026fc:	96be                	add	a3,a3,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    800026fe:	10569073          	csrw	stvec,a3

  // set up trapframe values that uservec will need when
  // the process next re-enters the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80002702:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80002704:	180026f3          	csrr	a3,satp
    80002708:	e314                	sd	a3,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    8000270a:	6d38                	ld	a4,88(a0)
    8000270c:	6134                	ld	a3,64(a0)
    8000270e:	6585                	lui	a1,0x1
    80002710:	96ae                	add	a3,a3,a1
    80002712:	e714                	sd	a3,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80002714:	6d38                	ld	a4,88(a0)
    80002716:	00000697          	auipc	a3,0x0
    8000271a:	13868693          	addi	a3,a3,312 # 8000284e <usertrap>
    8000271e:	eb14                	sd	a3,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    80002720:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80002722:	8692                	mv	a3,tp
    80002724:	f314                	sd	a3,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002726:	100026f3          	csrr	a3,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    8000272a:	eff6f693          	andi	a3,a3,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    8000272e:	0206e693          	ori	a3,a3,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002732:	10069073          	csrw	sstatus,a3
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80002736:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002738:	6f18                	ld	a4,24(a4)
    8000273a:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    8000273e:	692c                	ld	a1,80(a0)
    80002740:	81b1                	srli	a1,a1,0xc

  // jump to trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 fn = TRAMPOLINE + (userret - trampoline);
    80002742:	00005717          	auipc	a4,0x5
    80002746:	94e70713          	addi	a4,a4,-1714 # 80007090 <userret>
    8000274a:	8f11                	sub	a4,a4,a2
    8000274c:	97ba                	add	a5,a5,a4
  ((void (*)(uint64,uint64))fn)(TRAPFRAME, satp);
    8000274e:	577d                	li	a4,-1
    80002750:	177e                	slli	a4,a4,0x3f
    80002752:	8dd9                	or	a1,a1,a4
    80002754:	02000537          	lui	a0,0x2000
    80002758:	157d                	addi	a0,a0,-1
    8000275a:	0536                	slli	a0,a0,0xd
    8000275c:	9782                	jalr	a5
}
    8000275e:	60a2                	ld	ra,8(sp)
    80002760:	6402                	ld	s0,0(sp)
    80002762:	0141                	addi	sp,sp,16
    80002764:	8082                	ret

0000000080002766 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80002766:	1101                	addi	sp,sp,-32
    80002768:	ec06                	sd	ra,24(sp)
    8000276a:	e822                	sd	s0,16(sp)
    8000276c:	e426                	sd	s1,8(sp)
    8000276e:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    80002770:	00015497          	auipc	s1,0x15
    80002774:	b6048493          	addi	s1,s1,-1184 # 800172d0 <tickslock>
    80002778:	8526                	mv	a0,s1
    8000277a:	ffffe097          	auipc	ra,0xffffe
    8000277e:	45c080e7          	jalr	1116(ra) # 80000bd6 <acquire>
  ticks++;
    80002782:	00007517          	auipc	a0,0x7
    80002786:	8ae50513          	addi	a0,a0,-1874 # 80009030 <ticks>
    8000278a:	411c                	lw	a5,0(a0)
    8000278c:	2785                	addiw	a5,a5,1
    8000278e:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    80002790:	00000097          	auipc	ra,0x0
    80002794:	a52080e7          	jalr	-1454(ra) # 800021e2 <wakeup>
  release(&tickslock);
    80002798:	8526                	mv	a0,s1
    8000279a:	ffffe097          	auipc	ra,0xffffe
    8000279e:	4f0080e7          	jalr	1264(ra) # 80000c8a <release>
}
    800027a2:	60e2                	ld	ra,24(sp)
    800027a4:	6442                	ld	s0,16(sp)
    800027a6:	64a2                	ld	s1,8(sp)
    800027a8:	6105                	addi	sp,sp,32
    800027aa:	8082                	ret

00000000800027ac <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    800027ac:	1101                	addi	sp,sp,-32
    800027ae:	ec06                	sd	ra,24(sp)
    800027b0:	e822                	sd	s0,16(sp)
    800027b2:	e426                	sd	s1,8(sp)
    800027b4:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    800027b6:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if((scause & 0x8000000000000000L) &&
    800027ba:	00074d63          	bltz	a4,800027d4 <devintr+0x28>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000001L){
    800027be:	57fd                	li	a5,-1
    800027c0:	17fe                	slli	a5,a5,0x3f
    800027c2:	0785                	addi	a5,a5,1
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    800027c4:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    800027c6:	06f70363          	beq	a4,a5,8000282c <devintr+0x80>
  }
}
    800027ca:	60e2                	ld	ra,24(sp)
    800027cc:	6442                	ld	s0,16(sp)
    800027ce:	64a2                	ld	s1,8(sp)
    800027d0:	6105                	addi	sp,sp,32
    800027d2:	8082                	ret
     (scause & 0xff) == 9){
    800027d4:	0ff77793          	andi	a5,a4,255
  if((scause & 0x8000000000000000L) &&
    800027d8:	46a5                	li	a3,9
    800027da:	fed792e3          	bne	a5,a3,800027be <devintr+0x12>
    int irq = plic_claim();
    800027de:	00003097          	auipc	ra,0x3
    800027e2:	49a080e7          	jalr	1178(ra) # 80005c78 <plic_claim>
    800027e6:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    800027e8:	47a9                	li	a5,10
    800027ea:	02f50763          	beq	a0,a5,80002818 <devintr+0x6c>
    } else if(irq == VIRTIO0_IRQ){
    800027ee:	4785                	li	a5,1
    800027f0:	02f50963          	beq	a0,a5,80002822 <devintr+0x76>
    return 1;
    800027f4:	4505                	li	a0,1
    } else if(irq){
    800027f6:	d8f1                	beqz	s1,800027ca <devintr+0x1e>
      printf("unexpected interrupt irq=%d\n", irq);
    800027f8:	85a6                	mv	a1,s1
    800027fa:	00006517          	auipc	a0,0x6
    800027fe:	ae650513          	addi	a0,a0,-1306 # 800082e0 <states.2420+0x38>
    80002802:	ffffe097          	auipc	ra,0xffffe
    80002806:	d78080e7          	jalr	-648(ra) # 8000057a <printf>
      plic_complete(irq);
    8000280a:	8526                	mv	a0,s1
    8000280c:	00003097          	auipc	ra,0x3
    80002810:	490080e7          	jalr	1168(ra) # 80005c9c <plic_complete>
    return 1;
    80002814:	4505                	li	a0,1
    80002816:	bf55                	j	800027ca <devintr+0x1e>
      uartintr();
    80002818:	ffffe097          	auipc	ra,0xffffe
    8000281c:	182080e7          	jalr	386(ra) # 8000099a <uartintr>
    80002820:	b7ed                	j	8000280a <devintr+0x5e>
      virtio_disk_intr();
    80002822:	00004097          	auipc	ra,0x4
    80002826:	95a080e7          	jalr	-1702(ra) # 8000617c <virtio_disk_intr>
    8000282a:	b7c5                	j	8000280a <devintr+0x5e>
    if(cpuid() == 0){
    8000282c:	fffff097          	auipc	ra,0xfffff
    80002830:	13c080e7          	jalr	316(ra) # 80001968 <cpuid>
    80002834:	c901                	beqz	a0,80002844 <devintr+0x98>
  asm volatile("csrr %0, sip" : "=r" (x) );
    80002836:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    8000283a:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    8000283c:	14479073          	csrw	sip,a5
    return 2;
    80002840:	4509                	li	a0,2
    80002842:	b761                	j	800027ca <devintr+0x1e>
      clockintr();
    80002844:	00000097          	auipc	ra,0x0
    80002848:	f22080e7          	jalr	-222(ra) # 80002766 <clockintr>
    8000284c:	b7ed                	j	80002836 <devintr+0x8a>

000000008000284e <usertrap>:
{
    8000284e:	1101                	addi	sp,sp,-32
    80002850:	ec06                	sd	ra,24(sp)
    80002852:	e822                	sd	s0,16(sp)
    80002854:	e426                	sd	s1,8(sp)
    80002856:	e04a                	sd	s2,0(sp)
    80002858:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000285a:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    8000285e:	1007f793          	andi	a5,a5,256
    80002862:	e3ad                	bnez	a5,800028c4 <usertrap+0x76>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002864:	00003797          	auipc	a5,0x3
    80002868:	30c78793          	addi	a5,a5,780 # 80005b70 <kernelvec>
    8000286c:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002870:	fffff097          	auipc	ra,0xfffff
    80002874:	124080e7          	jalr	292(ra) # 80001994 <myproc>
    80002878:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    8000287a:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    8000287c:	14102773          	csrr	a4,sepc
    80002880:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002882:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002886:	47a1                	li	a5,8
    80002888:	04f71c63          	bne	a4,a5,800028e0 <usertrap+0x92>
    if(p->killed)
    8000288c:	551c                	lw	a5,40(a0)
    8000288e:	e3b9                	bnez	a5,800028d4 <usertrap+0x86>
    p->trapframe->epc += 4;
    80002890:	6cb8                	ld	a4,88(s1)
    80002892:	6f1c                	ld	a5,24(a4)
    80002894:	0791                	addi	a5,a5,4
    80002896:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002898:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    8000289c:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800028a0:	10079073          	csrw	sstatus,a5
    syscall();
    800028a4:	00000097          	auipc	ra,0x0
    800028a8:	2e0080e7          	jalr	736(ra) # 80002b84 <syscall>
  if(p->killed)
    800028ac:	549c                	lw	a5,40(s1)
    800028ae:	ebc1                	bnez	a5,8000293e <usertrap+0xf0>
  usertrapret();
    800028b0:	00000097          	auipc	ra,0x0
    800028b4:	e18080e7          	jalr	-488(ra) # 800026c8 <usertrapret>
}
    800028b8:	60e2                	ld	ra,24(sp)
    800028ba:	6442                	ld	s0,16(sp)
    800028bc:	64a2                	ld	s1,8(sp)
    800028be:	6902                	ld	s2,0(sp)
    800028c0:	6105                	addi	sp,sp,32
    800028c2:	8082                	ret
    panic("usertrap: not from user mode");
    800028c4:	00006517          	auipc	a0,0x6
    800028c8:	a3c50513          	addi	a0,a0,-1476 # 80008300 <states.2420+0x58>
    800028cc:	ffffe097          	auipc	ra,0xffffe
    800028d0:	c64080e7          	jalr	-924(ra) # 80000530 <panic>
      exit(-1);
    800028d4:	557d                	li	a0,-1
    800028d6:	00000097          	auipc	ra,0x0
    800028da:	9dc080e7          	jalr	-1572(ra) # 800022b2 <exit>
    800028de:	bf4d                	j	80002890 <usertrap+0x42>
  } else if((which_dev = devintr()) != 0){
    800028e0:	00000097          	auipc	ra,0x0
    800028e4:	ecc080e7          	jalr	-308(ra) # 800027ac <devintr>
    800028e8:	892a                	mv	s2,a0
    800028ea:	c501                	beqz	a0,800028f2 <usertrap+0xa4>
  if(p->killed)
    800028ec:	549c                	lw	a5,40(s1)
    800028ee:	c3a1                	beqz	a5,8000292e <usertrap+0xe0>
    800028f0:	a815                	j	80002924 <usertrap+0xd6>
  asm volatile("csrr %0, scause" : "=r" (x) );
    800028f2:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    800028f6:	5890                	lw	a2,48(s1)
    800028f8:	00006517          	auipc	a0,0x6
    800028fc:	a2850513          	addi	a0,a0,-1496 # 80008320 <states.2420+0x78>
    80002900:	ffffe097          	auipc	ra,0xffffe
    80002904:	c7a080e7          	jalr	-902(ra) # 8000057a <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002908:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    8000290c:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002910:	00006517          	auipc	a0,0x6
    80002914:	a4050513          	addi	a0,a0,-1472 # 80008350 <states.2420+0xa8>
    80002918:	ffffe097          	auipc	ra,0xffffe
    8000291c:	c62080e7          	jalr	-926(ra) # 8000057a <printf>
    p->killed = 1;
    80002920:	4785                	li	a5,1
    80002922:	d49c                	sw	a5,40(s1)
    exit(-1);
    80002924:	557d                	li	a0,-1
    80002926:	00000097          	auipc	ra,0x0
    8000292a:	98c080e7          	jalr	-1652(ra) # 800022b2 <exit>
  if(which_dev == 2)
    8000292e:	4789                	li	a5,2
    80002930:	f8f910e3          	bne	s2,a5,800028b0 <usertrap+0x62>
    yield();
    80002934:	fffff097          	auipc	ra,0xfffff
    80002938:	6e6080e7          	jalr	1766(ra) # 8000201a <yield>
    8000293c:	bf95                	j	800028b0 <usertrap+0x62>
  int which_dev = 0;
    8000293e:	4901                	li	s2,0
    80002940:	b7d5                	j	80002924 <usertrap+0xd6>

0000000080002942 <kerneltrap>:
{
    80002942:	7179                	addi	sp,sp,-48
    80002944:	f406                	sd	ra,40(sp)
    80002946:	f022                	sd	s0,32(sp)
    80002948:	ec26                	sd	s1,24(sp)
    8000294a:	e84a                	sd	s2,16(sp)
    8000294c:	e44e                	sd	s3,8(sp)
    8000294e:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002950:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002954:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002958:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    8000295c:	1004f793          	andi	a5,s1,256
    80002960:	cb85                	beqz	a5,80002990 <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002962:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002966:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80002968:	ef85                	bnez	a5,800029a0 <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    8000296a:	00000097          	auipc	ra,0x0
    8000296e:	e42080e7          	jalr	-446(ra) # 800027ac <devintr>
    80002972:	cd1d                	beqz	a0,800029b0 <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002974:	4789                	li	a5,2
    80002976:	06f50a63          	beq	a0,a5,800029ea <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    8000297a:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000297e:	10049073          	csrw	sstatus,s1
}
    80002982:	70a2                	ld	ra,40(sp)
    80002984:	7402                	ld	s0,32(sp)
    80002986:	64e2                	ld	s1,24(sp)
    80002988:	6942                	ld	s2,16(sp)
    8000298a:	69a2                	ld	s3,8(sp)
    8000298c:	6145                	addi	sp,sp,48
    8000298e:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002990:	00006517          	auipc	a0,0x6
    80002994:	9e050513          	addi	a0,a0,-1568 # 80008370 <states.2420+0xc8>
    80002998:	ffffe097          	auipc	ra,0xffffe
    8000299c:	b98080e7          	jalr	-1128(ra) # 80000530 <panic>
    panic("kerneltrap: interrupts enabled");
    800029a0:	00006517          	auipc	a0,0x6
    800029a4:	9f850513          	addi	a0,a0,-1544 # 80008398 <states.2420+0xf0>
    800029a8:	ffffe097          	auipc	ra,0xffffe
    800029ac:	b88080e7          	jalr	-1144(ra) # 80000530 <panic>
    printf("scause %p\n", scause);
    800029b0:	85ce                	mv	a1,s3
    800029b2:	00006517          	auipc	a0,0x6
    800029b6:	a0650513          	addi	a0,a0,-1530 # 800083b8 <states.2420+0x110>
    800029ba:	ffffe097          	auipc	ra,0xffffe
    800029be:	bc0080e7          	jalr	-1088(ra) # 8000057a <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800029c2:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    800029c6:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    800029ca:	00006517          	auipc	a0,0x6
    800029ce:	9fe50513          	addi	a0,a0,-1538 # 800083c8 <states.2420+0x120>
    800029d2:	ffffe097          	auipc	ra,0xffffe
    800029d6:	ba8080e7          	jalr	-1112(ra) # 8000057a <printf>
    panic("kerneltrap");
    800029da:	00006517          	auipc	a0,0x6
    800029de:	a0650513          	addi	a0,a0,-1530 # 800083e0 <states.2420+0x138>
    800029e2:	ffffe097          	auipc	ra,0xffffe
    800029e6:	b4e080e7          	jalr	-1202(ra) # 80000530 <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    800029ea:	fffff097          	auipc	ra,0xfffff
    800029ee:	faa080e7          	jalr	-86(ra) # 80001994 <myproc>
    800029f2:	d541                	beqz	a0,8000297a <kerneltrap+0x38>
    800029f4:	fffff097          	auipc	ra,0xfffff
    800029f8:	fa0080e7          	jalr	-96(ra) # 80001994 <myproc>
    800029fc:	4d18                	lw	a4,24(a0)
    800029fe:	4791                	li	a5,4
    80002a00:	f6f71de3          	bne	a4,a5,8000297a <kerneltrap+0x38>
    yield();
    80002a04:	fffff097          	auipc	ra,0xfffff
    80002a08:	616080e7          	jalr	1558(ra) # 8000201a <yield>
    80002a0c:	b7bd                	j	8000297a <kerneltrap+0x38>

0000000080002a0e <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002a0e:	1101                	addi	sp,sp,-32
    80002a10:	ec06                	sd	ra,24(sp)
    80002a12:	e822                	sd	s0,16(sp)
    80002a14:	e426                	sd	s1,8(sp)
    80002a16:	1000                	addi	s0,sp,32
    80002a18:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002a1a:	fffff097          	auipc	ra,0xfffff
    80002a1e:	f7a080e7          	jalr	-134(ra) # 80001994 <myproc>
  switch (n) {
    80002a22:	4795                	li	a5,5
    80002a24:	0497e163          	bltu	a5,s1,80002a66 <argraw+0x58>
    80002a28:	048a                	slli	s1,s1,0x2
    80002a2a:	00006717          	auipc	a4,0x6
    80002a2e:	9ee70713          	addi	a4,a4,-1554 # 80008418 <states.2420+0x170>
    80002a32:	94ba                	add	s1,s1,a4
    80002a34:	409c                	lw	a5,0(s1)
    80002a36:	97ba                	add	a5,a5,a4
    80002a38:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002a3a:	6d3c                	ld	a5,88(a0)
    80002a3c:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002a3e:	60e2                	ld	ra,24(sp)
    80002a40:	6442                	ld	s0,16(sp)
    80002a42:	64a2                	ld	s1,8(sp)
    80002a44:	6105                	addi	sp,sp,32
    80002a46:	8082                	ret
    return p->trapframe->a1;
    80002a48:	6d3c                	ld	a5,88(a0)
    80002a4a:	7fa8                	ld	a0,120(a5)
    80002a4c:	bfcd                	j	80002a3e <argraw+0x30>
    return p->trapframe->a2;
    80002a4e:	6d3c                	ld	a5,88(a0)
    80002a50:	63c8                	ld	a0,128(a5)
    80002a52:	b7f5                	j	80002a3e <argraw+0x30>
    return p->trapframe->a3;
    80002a54:	6d3c                	ld	a5,88(a0)
    80002a56:	67c8                	ld	a0,136(a5)
    80002a58:	b7dd                	j	80002a3e <argraw+0x30>
    return p->trapframe->a4;
    80002a5a:	6d3c                	ld	a5,88(a0)
    80002a5c:	6bc8                	ld	a0,144(a5)
    80002a5e:	b7c5                	j	80002a3e <argraw+0x30>
    return p->trapframe->a5;
    80002a60:	6d3c                	ld	a5,88(a0)
    80002a62:	6fc8                	ld	a0,152(a5)
    80002a64:	bfe9                	j	80002a3e <argraw+0x30>
  panic("argraw");
    80002a66:	00006517          	auipc	a0,0x6
    80002a6a:	98a50513          	addi	a0,a0,-1654 # 800083f0 <states.2420+0x148>
    80002a6e:	ffffe097          	auipc	ra,0xffffe
    80002a72:	ac2080e7          	jalr	-1342(ra) # 80000530 <panic>

0000000080002a76 <fetchaddr>:
{
    80002a76:	1101                	addi	sp,sp,-32
    80002a78:	ec06                	sd	ra,24(sp)
    80002a7a:	e822                	sd	s0,16(sp)
    80002a7c:	e426                	sd	s1,8(sp)
    80002a7e:	e04a                	sd	s2,0(sp)
    80002a80:	1000                	addi	s0,sp,32
    80002a82:	84aa                	mv	s1,a0
    80002a84:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002a86:	fffff097          	auipc	ra,0xfffff
    80002a8a:	f0e080e7          	jalr	-242(ra) # 80001994 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz)
    80002a8e:	653c                	ld	a5,72(a0)
    80002a90:	02f4f863          	bgeu	s1,a5,80002ac0 <fetchaddr+0x4a>
    80002a94:	00848713          	addi	a4,s1,8
    80002a98:	02e7e663          	bltu	a5,a4,80002ac4 <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002a9c:	46a1                	li	a3,8
    80002a9e:	8626                	mv	a2,s1
    80002aa0:	85ca                	mv	a1,s2
    80002aa2:	6928                	ld	a0,80(a0)
    80002aa4:	fffff097          	auipc	ra,0xfffff
    80002aa8:	c3e080e7          	jalr	-962(ra) # 800016e2 <copyin>
    80002aac:	00a03533          	snez	a0,a0
    80002ab0:	40a00533          	neg	a0,a0
}
    80002ab4:	60e2                	ld	ra,24(sp)
    80002ab6:	6442                	ld	s0,16(sp)
    80002ab8:	64a2                	ld	s1,8(sp)
    80002aba:	6902                	ld	s2,0(sp)
    80002abc:	6105                	addi	sp,sp,32
    80002abe:	8082                	ret
    return -1;
    80002ac0:	557d                	li	a0,-1
    80002ac2:	bfcd                	j	80002ab4 <fetchaddr+0x3e>
    80002ac4:	557d                	li	a0,-1
    80002ac6:	b7fd                	j	80002ab4 <fetchaddr+0x3e>

0000000080002ac8 <fetchstr>:
{
    80002ac8:	7179                	addi	sp,sp,-48
    80002aca:	f406                	sd	ra,40(sp)
    80002acc:	f022                	sd	s0,32(sp)
    80002ace:	ec26                	sd	s1,24(sp)
    80002ad0:	e84a                	sd	s2,16(sp)
    80002ad2:	e44e                	sd	s3,8(sp)
    80002ad4:	1800                	addi	s0,sp,48
    80002ad6:	892a                	mv	s2,a0
    80002ad8:	84ae                	mv	s1,a1
    80002ada:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002adc:	fffff097          	auipc	ra,0xfffff
    80002ae0:	eb8080e7          	jalr	-328(ra) # 80001994 <myproc>
  int err = copyinstr(p->pagetable, buf, addr, max);
    80002ae4:	86ce                	mv	a3,s3
    80002ae6:	864a                	mv	a2,s2
    80002ae8:	85a6                	mv	a1,s1
    80002aea:	6928                	ld	a0,80(a0)
    80002aec:	fffff097          	auipc	ra,0xfffff
    80002af0:	c82080e7          	jalr	-894(ra) # 8000176e <copyinstr>
  if(err < 0)
    80002af4:	00054763          	bltz	a0,80002b02 <fetchstr+0x3a>
  return strlen(buf);
    80002af8:	8526                	mv	a0,s1
    80002afa:	ffffe097          	auipc	ra,0xffffe
    80002afe:	360080e7          	jalr	864(ra) # 80000e5a <strlen>
}
    80002b02:	70a2                	ld	ra,40(sp)
    80002b04:	7402                	ld	s0,32(sp)
    80002b06:	64e2                	ld	s1,24(sp)
    80002b08:	6942                	ld	s2,16(sp)
    80002b0a:	69a2                	ld	s3,8(sp)
    80002b0c:	6145                	addi	sp,sp,48
    80002b0e:	8082                	ret

0000000080002b10 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
    80002b10:	1101                	addi	sp,sp,-32
    80002b12:	ec06                	sd	ra,24(sp)
    80002b14:	e822                	sd	s0,16(sp)
    80002b16:	e426                	sd	s1,8(sp)
    80002b18:	1000                	addi	s0,sp,32
    80002b1a:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002b1c:	00000097          	auipc	ra,0x0
    80002b20:	ef2080e7          	jalr	-270(ra) # 80002a0e <argraw>
    80002b24:	c088                	sw	a0,0(s1)
  return 0;
}
    80002b26:	4501                	li	a0,0
    80002b28:	60e2                	ld	ra,24(sp)
    80002b2a:	6442                	ld	s0,16(sp)
    80002b2c:	64a2                	ld	s1,8(sp)
    80002b2e:	6105                	addi	sp,sp,32
    80002b30:	8082                	ret

0000000080002b32 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
int
argaddr(int n, uint64 *ip)
{
    80002b32:	1101                	addi	sp,sp,-32
    80002b34:	ec06                	sd	ra,24(sp)
    80002b36:	e822                	sd	s0,16(sp)
    80002b38:	e426                	sd	s1,8(sp)
    80002b3a:	1000                	addi	s0,sp,32
    80002b3c:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002b3e:	00000097          	auipc	ra,0x0
    80002b42:	ed0080e7          	jalr	-304(ra) # 80002a0e <argraw>
    80002b46:	e088                	sd	a0,0(s1)
  return 0;
}
    80002b48:	4501                	li	a0,0
    80002b4a:	60e2                	ld	ra,24(sp)
    80002b4c:	6442                	ld	s0,16(sp)
    80002b4e:	64a2                	ld	s1,8(sp)
    80002b50:	6105                	addi	sp,sp,32
    80002b52:	8082                	ret

0000000080002b54 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002b54:	1101                	addi	sp,sp,-32
    80002b56:	ec06                	sd	ra,24(sp)
    80002b58:	e822                	sd	s0,16(sp)
    80002b5a:	e426                	sd	s1,8(sp)
    80002b5c:	e04a                	sd	s2,0(sp)
    80002b5e:	1000                	addi	s0,sp,32
    80002b60:	84ae                	mv	s1,a1
    80002b62:	8932                	mv	s2,a2
  *ip = argraw(n);
    80002b64:	00000097          	auipc	ra,0x0
    80002b68:	eaa080e7          	jalr	-342(ra) # 80002a0e <argraw>
  uint64 addr;
  if(argaddr(n, &addr) < 0)
    return -1;
  return fetchstr(addr, buf, max);
    80002b6c:	864a                	mv	a2,s2
    80002b6e:	85a6                	mv	a1,s1
    80002b70:	00000097          	auipc	ra,0x0
    80002b74:	f58080e7          	jalr	-168(ra) # 80002ac8 <fetchstr>
}
    80002b78:	60e2                	ld	ra,24(sp)
    80002b7a:	6442                	ld	s0,16(sp)
    80002b7c:	64a2                	ld	s1,8(sp)
    80002b7e:	6902                	ld	s2,0(sp)
    80002b80:	6105                	addi	sp,sp,32
    80002b82:	8082                	ret

0000000080002b84 <syscall>:
[SYS_ps]      sys_ps,
};

void
syscall(void)
{
    80002b84:	1101                	addi	sp,sp,-32
    80002b86:	ec06                	sd	ra,24(sp)
    80002b88:	e822                	sd	s0,16(sp)
    80002b8a:	e426                	sd	s1,8(sp)
    80002b8c:	e04a                	sd	s2,0(sp)
    80002b8e:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002b90:	fffff097          	auipc	ra,0xfffff
    80002b94:	e04080e7          	jalr	-508(ra) # 80001994 <myproc>
    80002b98:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002b9a:	05853903          	ld	s2,88(a0)
    80002b9e:	0a893783          	ld	a5,168(s2)
    80002ba2:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002ba6:	37fd                	addiw	a5,a5,-1
    80002ba8:	4755                	li	a4,21
    80002baa:	00f76f63          	bltu	a4,a5,80002bc8 <syscall+0x44>
    80002bae:	00369713          	slli	a4,a3,0x3
    80002bb2:	00006797          	auipc	a5,0x6
    80002bb6:	87e78793          	addi	a5,a5,-1922 # 80008430 <syscalls>
    80002bba:	97ba                	add	a5,a5,a4
    80002bbc:	639c                	ld	a5,0(a5)
    80002bbe:	c789                	beqz	a5,80002bc8 <syscall+0x44>
    p->trapframe->a0 = syscalls[num]();
    80002bc0:	9782                	jalr	a5
    80002bc2:	06a93823          	sd	a0,112(s2)
    80002bc6:	a839                	j	80002be4 <syscall+0x60>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002bc8:	15848613          	addi	a2,s1,344
    80002bcc:	588c                	lw	a1,48(s1)
    80002bce:	00006517          	auipc	a0,0x6
    80002bd2:	82a50513          	addi	a0,a0,-2006 # 800083f8 <states.2420+0x150>
    80002bd6:	ffffe097          	auipc	ra,0xffffe
    80002bda:	9a4080e7          	jalr	-1628(ra) # 8000057a <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002bde:	6cbc                	ld	a5,88(s1)
    80002be0:	577d                	li	a4,-1
    80002be2:	fbb8                	sd	a4,112(a5)
  }
}
    80002be4:	60e2                	ld	ra,24(sp)
    80002be6:	6442                	ld	s0,16(sp)
    80002be8:	64a2                	ld	s1,8(sp)
    80002bea:	6902                	ld	s2,0(sp)
    80002bec:	6105                	addi	sp,sp,32
    80002bee:	8082                	ret

0000000080002bf0 <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    80002bf0:	1101                	addi	sp,sp,-32
    80002bf2:	ec06                	sd	ra,24(sp)
    80002bf4:	e822                	sd	s0,16(sp)
    80002bf6:	1000                	addi	s0,sp,32
  int n;
  if(argint(0, &n) < 0)
    80002bf8:	fec40593          	addi	a1,s0,-20
    80002bfc:	4501                	li	a0,0
    80002bfe:	00000097          	auipc	ra,0x0
    80002c02:	f12080e7          	jalr	-238(ra) # 80002b10 <argint>
    return -1;
    80002c06:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80002c08:	00054963          	bltz	a0,80002c1a <sys_exit+0x2a>
  exit(n);
    80002c0c:	fec42503          	lw	a0,-20(s0)
    80002c10:	fffff097          	auipc	ra,0xfffff
    80002c14:	6a2080e7          	jalr	1698(ra) # 800022b2 <exit>
  return 0;  // not reached
    80002c18:	4781                	li	a5,0
}
    80002c1a:	853e                	mv	a0,a5
    80002c1c:	60e2                	ld	ra,24(sp)
    80002c1e:	6442                	ld	s0,16(sp)
    80002c20:	6105                	addi	sp,sp,32
    80002c22:	8082                	ret

0000000080002c24 <sys_getpid>:

uint64
sys_getpid(void)
{
    80002c24:	1141                	addi	sp,sp,-16
    80002c26:	e406                	sd	ra,8(sp)
    80002c28:	e022                	sd	s0,0(sp)
    80002c2a:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002c2c:	fffff097          	auipc	ra,0xfffff
    80002c30:	d68080e7          	jalr	-664(ra) # 80001994 <myproc>
}
    80002c34:	5908                	lw	a0,48(a0)
    80002c36:	60a2                	ld	ra,8(sp)
    80002c38:	6402                	ld	s0,0(sp)
    80002c3a:	0141                	addi	sp,sp,16
    80002c3c:	8082                	ret

0000000080002c3e <sys_fork>:

uint64
sys_fork(void)
{
    80002c3e:	1141                	addi	sp,sp,-16
    80002c40:	e406                	sd	ra,8(sp)
    80002c42:	e022                	sd	s0,0(sp)
    80002c44:	0800                	addi	s0,sp,16
  return fork();
    80002c46:	fffff097          	auipc	ra,0xfffff
    80002c4a:	11c080e7          	jalr	284(ra) # 80001d62 <fork>
}
    80002c4e:	60a2                	ld	ra,8(sp)
    80002c50:	6402                	ld	s0,0(sp)
    80002c52:	0141                	addi	sp,sp,16
    80002c54:	8082                	ret

0000000080002c56 <sys_wait>:

uint64
sys_wait(void)
{
    80002c56:	1101                	addi	sp,sp,-32
    80002c58:	ec06                	sd	ra,24(sp)
    80002c5a:	e822                	sd	s0,16(sp)
    80002c5c:	1000                	addi	s0,sp,32
  uint64 p;
  if(argaddr(0, &p) < 0)
    80002c5e:	fe840593          	addi	a1,s0,-24
    80002c62:	4501                	li	a0,0
    80002c64:	00000097          	auipc	ra,0x0
    80002c68:	ece080e7          	jalr	-306(ra) # 80002b32 <argaddr>
    80002c6c:	87aa                	mv	a5,a0
    return -1;
    80002c6e:	557d                	li	a0,-1
  if(argaddr(0, &p) < 0)
    80002c70:	0007c863          	bltz	a5,80002c80 <sys_wait+0x2a>
  return wait(p);
    80002c74:	fe843503          	ld	a0,-24(s0)
    80002c78:	fffff097          	auipc	ra,0xfffff
    80002c7c:	442080e7          	jalr	1090(ra) # 800020ba <wait>
}
    80002c80:	60e2                	ld	ra,24(sp)
    80002c82:	6442                	ld	s0,16(sp)
    80002c84:	6105                	addi	sp,sp,32
    80002c86:	8082                	ret

0000000080002c88 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002c88:	7179                	addi	sp,sp,-48
    80002c8a:	f406                	sd	ra,40(sp)
    80002c8c:	f022                	sd	s0,32(sp)
    80002c8e:	ec26                	sd	s1,24(sp)
    80002c90:	1800                	addi	s0,sp,48
  int addr;
  int n;

  if(argint(0, &n) < 0)
    80002c92:	fdc40593          	addi	a1,s0,-36
    80002c96:	4501                	li	a0,0
    80002c98:	00000097          	auipc	ra,0x0
    80002c9c:	e78080e7          	jalr	-392(ra) # 80002b10 <argint>
    80002ca0:	87aa                	mv	a5,a0
    return -1;
    80002ca2:	557d                	li	a0,-1
  if(argint(0, &n) < 0)
    80002ca4:	0207c063          	bltz	a5,80002cc4 <sys_sbrk+0x3c>
  addr = myproc()->sz;
    80002ca8:	fffff097          	auipc	ra,0xfffff
    80002cac:	cec080e7          	jalr	-788(ra) # 80001994 <myproc>
    80002cb0:	4524                	lw	s1,72(a0)
  if(growproc(n) < 0)
    80002cb2:	fdc42503          	lw	a0,-36(s0)
    80002cb6:	fffff097          	auipc	ra,0xfffff
    80002cba:	038080e7          	jalr	56(ra) # 80001cee <growproc>
    80002cbe:	00054863          	bltz	a0,80002cce <sys_sbrk+0x46>
    return -1;
  return addr;
    80002cc2:	8526                	mv	a0,s1
}
    80002cc4:	70a2                	ld	ra,40(sp)
    80002cc6:	7402                	ld	s0,32(sp)
    80002cc8:	64e2                	ld	s1,24(sp)
    80002cca:	6145                	addi	sp,sp,48
    80002ccc:	8082                	ret
    return -1;
    80002cce:	557d                	li	a0,-1
    80002cd0:	bfd5                	j	80002cc4 <sys_sbrk+0x3c>

0000000080002cd2 <sys_sleep>:

uint64
sys_sleep(void)
{
    80002cd2:	7139                	addi	sp,sp,-64
    80002cd4:	fc06                	sd	ra,56(sp)
    80002cd6:	f822                	sd	s0,48(sp)
    80002cd8:	f426                	sd	s1,40(sp)
    80002cda:	f04a                	sd	s2,32(sp)
    80002cdc:	ec4e                	sd	s3,24(sp)
    80002cde:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
    80002ce0:	fcc40593          	addi	a1,s0,-52
    80002ce4:	4501                	li	a0,0
    80002ce6:	00000097          	auipc	ra,0x0
    80002cea:	e2a080e7          	jalr	-470(ra) # 80002b10 <argint>
    return -1;
    80002cee:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80002cf0:	06054563          	bltz	a0,80002d5a <sys_sleep+0x88>
  acquire(&tickslock);
    80002cf4:	00014517          	auipc	a0,0x14
    80002cf8:	5dc50513          	addi	a0,a0,1500 # 800172d0 <tickslock>
    80002cfc:	ffffe097          	auipc	ra,0xffffe
    80002d00:	eda080e7          	jalr	-294(ra) # 80000bd6 <acquire>
  ticks0 = ticks;
    80002d04:	00006917          	auipc	s2,0x6
    80002d08:	32c92903          	lw	s2,812(s2) # 80009030 <ticks>
  while(ticks - ticks0 < n){
    80002d0c:	fcc42783          	lw	a5,-52(s0)
    80002d10:	cf85                	beqz	a5,80002d48 <sys_sleep+0x76>
    if(myproc()->killed){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002d12:	00014997          	auipc	s3,0x14
    80002d16:	5be98993          	addi	s3,s3,1470 # 800172d0 <tickslock>
    80002d1a:	00006497          	auipc	s1,0x6
    80002d1e:	31648493          	addi	s1,s1,790 # 80009030 <ticks>
    if(myproc()->killed){
    80002d22:	fffff097          	auipc	ra,0xfffff
    80002d26:	c72080e7          	jalr	-910(ra) # 80001994 <myproc>
    80002d2a:	551c                	lw	a5,40(a0)
    80002d2c:	ef9d                	bnez	a5,80002d6a <sys_sleep+0x98>
    sleep(&ticks, &tickslock);
    80002d2e:	85ce                	mv	a1,s3
    80002d30:	8526                	mv	a0,s1
    80002d32:	fffff097          	auipc	ra,0xfffff
    80002d36:	324080e7          	jalr	804(ra) # 80002056 <sleep>
  while(ticks - ticks0 < n){
    80002d3a:	409c                	lw	a5,0(s1)
    80002d3c:	412787bb          	subw	a5,a5,s2
    80002d40:	fcc42703          	lw	a4,-52(s0)
    80002d44:	fce7efe3          	bltu	a5,a4,80002d22 <sys_sleep+0x50>
  }
  release(&tickslock);
    80002d48:	00014517          	auipc	a0,0x14
    80002d4c:	58850513          	addi	a0,a0,1416 # 800172d0 <tickslock>
    80002d50:	ffffe097          	auipc	ra,0xffffe
    80002d54:	f3a080e7          	jalr	-198(ra) # 80000c8a <release>
  return 0;
    80002d58:	4781                	li	a5,0
}
    80002d5a:	853e                	mv	a0,a5
    80002d5c:	70e2                	ld	ra,56(sp)
    80002d5e:	7442                	ld	s0,48(sp)
    80002d60:	74a2                	ld	s1,40(sp)
    80002d62:	7902                	ld	s2,32(sp)
    80002d64:	69e2                	ld	s3,24(sp)
    80002d66:	6121                	addi	sp,sp,64
    80002d68:	8082                	ret
      release(&tickslock);
    80002d6a:	00014517          	auipc	a0,0x14
    80002d6e:	56650513          	addi	a0,a0,1382 # 800172d0 <tickslock>
    80002d72:	ffffe097          	auipc	ra,0xffffe
    80002d76:	f18080e7          	jalr	-232(ra) # 80000c8a <release>
      return -1;
    80002d7a:	57fd                	li	a5,-1
    80002d7c:	bff9                	j	80002d5a <sys_sleep+0x88>

0000000080002d7e <sys_kill>:

uint64
sys_kill(void)
{
    80002d7e:	1101                	addi	sp,sp,-32
    80002d80:	ec06                	sd	ra,24(sp)
    80002d82:	e822                	sd	s0,16(sp)
    80002d84:	1000                	addi	s0,sp,32
  int pid;

  if(argint(0, &pid) < 0)
    80002d86:	fec40593          	addi	a1,s0,-20
    80002d8a:	4501                	li	a0,0
    80002d8c:	00000097          	auipc	ra,0x0
    80002d90:	d84080e7          	jalr	-636(ra) # 80002b10 <argint>
    80002d94:	87aa                	mv	a5,a0
    return -1;
    80002d96:	557d                	li	a0,-1
  if(argint(0, &pid) < 0)
    80002d98:	0007c863          	bltz	a5,80002da8 <sys_kill+0x2a>
  return kill(pid);
    80002d9c:	fec42503          	lw	a0,-20(s0)
    80002da0:	fffff097          	auipc	ra,0xfffff
    80002da4:	5e8080e7          	jalr	1512(ra) # 80002388 <kill>
}
    80002da8:	60e2                	ld	ra,24(sp)
    80002daa:	6442                	ld	s0,16(sp)
    80002dac:	6105                	addi	sp,sp,32
    80002dae:	8082                	ret

0000000080002db0 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002db0:	1101                	addi	sp,sp,-32
    80002db2:	ec06                	sd	ra,24(sp)
    80002db4:	e822                	sd	s0,16(sp)
    80002db6:	e426                	sd	s1,8(sp)
    80002db8:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002dba:	00014517          	auipc	a0,0x14
    80002dbe:	51650513          	addi	a0,a0,1302 # 800172d0 <tickslock>
    80002dc2:	ffffe097          	auipc	ra,0xffffe
    80002dc6:	e14080e7          	jalr	-492(ra) # 80000bd6 <acquire>
  xticks = ticks;
    80002dca:	00006497          	auipc	s1,0x6
    80002dce:	2664a483          	lw	s1,614(s1) # 80009030 <ticks>
  release(&tickslock);
    80002dd2:	00014517          	auipc	a0,0x14
    80002dd6:	4fe50513          	addi	a0,a0,1278 # 800172d0 <tickslock>
    80002dda:	ffffe097          	auipc	ra,0xffffe
    80002dde:	eb0080e7          	jalr	-336(ra) # 80000c8a <release>
  return xticks;
}
    80002de2:	02049513          	slli	a0,s1,0x20
    80002de6:	9101                	srli	a0,a0,0x20
    80002de8:	60e2                	ld	ra,24(sp)
    80002dea:	6442                	ld	s0,16(sp)
    80002dec:	64a2                	ld	s1,8(sp)
    80002dee:	6105                	addi	sp,sp,32
    80002df0:	8082                	ret

0000000080002df2 <sys_ps>:

uint64
sys_ps(void) {
    80002df2:	1101                	addi	sp,sp,-32
    80002df4:	ec06                	sd	ra,24(sp)
    80002df6:	e822                	sd	s0,16(sp)
    80002df8:	1000                	addi	s0,sp,32
  uint64 p;
  if (argaddr(0, &p) < 0)
    80002dfa:	fe840593          	addi	a1,s0,-24
    80002dfe:	4501                	li	a0,0
    80002e00:	00000097          	auipc	ra,0x0
    80002e04:	d32080e7          	jalr	-718(ra) # 80002b32 <argaddr>
    80002e08:	87aa                	mv	a5,a0
    return -1;
    80002e0a:	557d                	li	a0,-1
  if (argaddr(0, &p) < 0)
    80002e0c:	0007c863          	bltz	a5,80002e1c <sys_ps+0x2a>
  return ps((struct ps_proc*)p);
    80002e10:	fe843503          	ld	a0,-24(s0)
    80002e14:	fffff097          	auipc	ra,0xfffff
    80002e18:	740080e7          	jalr	1856(ra) # 80002554 <ps>
    80002e1c:	60e2                	ld	ra,24(sp)
    80002e1e:	6442                	ld	s0,16(sp)
    80002e20:	6105                	addi	sp,sp,32
    80002e22:	8082                	ret

0000000080002e24 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002e24:	7179                	addi	sp,sp,-48
    80002e26:	f406                	sd	ra,40(sp)
    80002e28:	f022                	sd	s0,32(sp)
    80002e2a:	ec26                	sd	s1,24(sp)
    80002e2c:	e84a                	sd	s2,16(sp)
    80002e2e:	e44e                	sd	s3,8(sp)
    80002e30:	e052                	sd	s4,0(sp)
    80002e32:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80002e34:	00005597          	auipc	a1,0x5
    80002e38:	6b458593          	addi	a1,a1,1716 # 800084e8 <syscalls+0xb8>
    80002e3c:	00014517          	auipc	a0,0x14
    80002e40:	4ac50513          	addi	a0,a0,1196 # 800172e8 <bcache>
    80002e44:	ffffe097          	auipc	ra,0xffffe
    80002e48:	d02080e7          	jalr	-766(ra) # 80000b46 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80002e4c:	0001c797          	auipc	a5,0x1c
    80002e50:	49c78793          	addi	a5,a5,1180 # 8001f2e8 <bcache+0x8000>
    80002e54:	0001c717          	auipc	a4,0x1c
    80002e58:	6fc70713          	addi	a4,a4,1788 # 8001f550 <bcache+0x8268>
    80002e5c:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80002e60:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002e64:	00014497          	auipc	s1,0x14
    80002e68:	49c48493          	addi	s1,s1,1180 # 80017300 <bcache+0x18>
    b->next = bcache.head.next;
    80002e6c:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80002e6e:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80002e70:	00005a17          	auipc	s4,0x5
    80002e74:	680a0a13          	addi	s4,s4,1664 # 800084f0 <syscalls+0xc0>
    b->next = bcache.head.next;
    80002e78:	2b893783          	ld	a5,696(s2)
    80002e7c:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80002e7e:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80002e82:	85d2                	mv	a1,s4
    80002e84:	01048513          	addi	a0,s1,16
    80002e88:	00001097          	auipc	ra,0x1
    80002e8c:	4bc080e7          	jalr	1212(ra) # 80004344 <initsleeplock>
    bcache.head.next->prev = b;
    80002e90:	2b893783          	ld	a5,696(s2)
    80002e94:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80002e96:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002e9a:	45848493          	addi	s1,s1,1112
    80002e9e:	fd349de3          	bne	s1,s3,80002e78 <binit+0x54>
  }
}
    80002ea2:	70a2                	ld	ra,40(sp)
    80002ea4:	7402                	ld	s0,32(sp)
    80002ea6:	64e2                	ld	s1,24(sp)
    80002ea8:	6942                	ld	s2,16(sp)
    80002eaa:	69a2                	ld	s3,8(sp)
    80002eac:	6a02                	ld	s4,0(sp)
    80002eae:	6145                	addi	sp,sp,48
    80002eb0:	8082                	ret

0000000080002eb2 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80002eb2:	7179                	addi	sp,sp,-48
    80002eb4:	f406                	sd	ra,40(sp)
    80002eb6:	f022                	sd	s0,32(sp)
    80002eb8:	ec26                	sd	s1,24(sp)
    80002eba:	e84a                	sd	s2,16(sp)
    80002ebc:	e44e                	sd	s3,8(sp)
    80002ebe:	1800                	addi	s0,sp,48
    80002ec0:	89aa                	mv	s3,a0
    80002ec2:	892e                	mv	s2,a1
  acquire(&bcache.lock);
    80002ec4:	00014517          	auipc	a0,0x14
    80002ec8:	42450513          	addi	a0,a0,1060 # 800172e8 <bcache>
    80002ecc:	ffffe097          	auipc	ra,0xffffe
    80002ed0:	d0a080e7          	jalr	-758(ra) # 80000bd6 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80002ed4:	0001c497          	auipc	s1,0x1c
    80002ed8:	6cc4b483          	ld	s1,1740(s1) # 8001f5a0 <bcache+0x82b8>
    80002edc:	0001c797          	auipc	a5,0x1c
    80002ee0:	67478793          	addi	a5,a5,1652 # 8001f550 <bcache+0x8268>
    80002ee4:	02f48f63          	beq	s1,a5,80002f22 <bread+0x70>
    80002ee8:	873e                	mv	a4,a5
    80002eea:	a021                	j	80002ef2 <bread+0x40>
    80002eec:	68a4                	ld	s1,80(s1)
    80002eee:	02e48a63          	beq	s1,a4,80002f22 <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    80002ef2:	449c                	lw	a5,8(s1)
    80002ef4:	ff379ce3          	bne	a5,s3,80002eec <bread+0x3a>
    80002ef8:	44dc                	lw	a5,12(s1)
    80002efa:	ff2799e3          	bne	a5,s2,80002eec <bread+0x3a>
      b->refcnt++;
    80002efe:	40bc                	lw	a5,64(s1)
    80002f00:	2785                	addiw	a5,a5,1
    80002f02:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002f04:	00014517          	auipc	a0,0x14
    80002f08:	3e450513          	addi	a0,a0,996 # 800172e8 <bcache>
    80002f0c:	ffffe097          	auipc	ra,0xffffe
    80002f10:	d7e080e7          	jalr	-642(ra) # 80000c8a <release>
      acquiresleep(&b->lock);
    80002f14:	01048513          	addi	a0,s1,16
    80002f18:	00001097          	auipc	ra,0x1
    80002f1c:	466080e7          	jalr	1126(ra) # 8000437e <acquiresleep>
      return b;
    80002f20:	a8b9                	j	80002f7e <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002f22:	0001c497          	auipc	s1,0x1c
    80002f26:	6764b483          	ld	s1,1654(s1) # 8001f598 <bcache+0x82b0>
    80002f2a:	0001c797          	auipc	a5,0x1c
    80002f2e:	62678793          	addi	a5,a5,1574 # 8001f550 <bcache+0x8268>
    80002f32:	00f48863          	beq	s1,a5,80002f42 <bread+0x90>
    80002f36:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80002f38:	40bc                	lw	a5,64(s1)
    80002f3a:	cf81                	beqz	a5,80002f52 <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002f3c:	64a4                	ld	s1,72(s1)
    80002f3e:	fee49de3          	bne	s1,a4,80002f38 <bread+0x86>
  panic("bget: no buffers");
    80002f42:	00005517          	auipc	a0,0x5
    80002f46:	5b650513          	addi	a0,a0,1462 # 800084f8 <syscalls+0xc8>
    80002f4a:	ffffd097          	auipc	ra,0xffffd
    80002f4e:	5e6080e7          	jalr	1510(ra) # 80000530 <panic>
      b->dev = dev;
    80002f52:	0134a423          	sw	s3,8(s1)
      b->blockno = blockno;
    80002f56:	0124a623          	sw	s2,12(s1)
      b->valid = 0;
    80002f5a:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80002f5e:	4785                	li	a5,1
    80002f60:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002f62:	00014517          	auipc	a0,0x14
    80002f66:	38650513          	addi	a0,a0,902 # 800172e8 <bcache>
    80002f6a:	ffffe097          	auipc	ra,0xffffe
    80002f6e:	d20080e7          	jalr	-736(ra) # 80000c8a <release>
      acquiresleep(&b->lock);
    80002f72:	01048513          	addi	a0,s1,16
    80002f76:	00001097          	auipc	ra,0x1
    80002f7a:	408080e7          	jalr	1032(ra) # 8000437e <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80002f7e:	409c                	lw	a5,0(s1)
    80002f80:	cb89                	beqz	a5,80002f92 <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80002f82:	8526                	mv	a0,s1
    80002f84:	70a2                	ld	ra,40(sp)
    80002f86:	7402                	ld	s0,32(sp)
    80002f88:	64e2                	ld	s1,24(sp)
    80002f8a:	6942                	ld	s2,16(sp)
    80002f8c:	69a2                	ld	s3,8(sp)
    80002f8e:	6145                	addi	sp,sp,48
    80002f90:	8082                	ret
    virtio_disk_rw(b, 0);
    80002f92:	4581                	li	a1,0
    80002f94:	8526                	mv	a0,s1
    80002f96:	00003097          	auipc	ra,0x3
    80002f9a:	f10080e7          	jalr	-240(ra) # 80005ea6 <virtio_disk_rw>
    b->valid = 1;
    80002f9e:	4785                	li	a5,1
    80002fa0:	c09c                	sw	a5,0(s1)
  return b;
    80002fa2:	b7c5                	j	80002f82 <bread+0xd0>

0000000080002fa4 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80002fa4:	1101                	addi	sp,sp,-32
    80002fa6:	ec06                	sd	ra,24(sp)
    80002fa8:	e822                	sd	s0,16(sp)
    80002faa:	e426                	sd	s1,8(sp)
    80002fac:	1000                	addi	s0,sp,32
    80002fae:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002fb0:	0541                	addi	a0,a0,16
    80002fb2:	00001097          	auipc	ra,0x1
    80002fb6:	466080e7          	jalr	1126(ra) # 80004418 <holdingsleep>
    80002fba:	cd01                	beqz	a0,80002fd2 <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80002fbc:	4585                	li	a1,1
    80002fbe:	8526                	mv	a0,s1
    80002fc0:	00003097          	auipc	ra,0x3
    80002fc4:	ee6080e7          	jalr	-282(ra) # 80005ea6 <virtio_disk_rw>
}
    80002fc8:	60e2                	ld	ra,24(sp)
    80002fca:	6442                	ld	s0,16(sp)
    80002fcc:	64a2                	ld	s1,8(sp)
    80002fce:	6105                	addi	sp,sp,32
    80002fd0:	8082                	ret
    panic("bwrite");
    80002fd2:	00005517          	auipc	a0,0x5
    80002fd6:	53e50513          	addi	a0,a0,1342 # 80008510 <syscalls+0xe0>
    80002fda:	ffffd097          	auipc	ra,0xffffd
    80002fde:	556080e7          	jalr	1366(ra) # 80000530 <panic>

0000000080002fe2 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80002fe2:	1101                	addi	sp,sp,-32
    80002fe4:	ec06                	sd	ra,24(sp)
    80002fe6:	e822                	sd	s0,16(sp)
    80002fe8:	e426                	sd	s1,8(sp)
    80002fea:	e04a                	sd	s2,0(sp)
    80002fec:	1000                	addi	s0,sp,32
    80002fee:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002ff0:	01050913          	addi	s2,a0,16
    80002ff4:	854a                	mv	a0,s2
    80002ff6:	00001097          	auipc	ra,0x1
    80002ffa:	422080e7          	jalr	1058(ra) # 80004418 <holdingsleep>
    80002ffe:	c92d                	beqz	a0,80003070 <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    80003000:	854a                	mv	a0,s2
    80003002:	00001097          	auipc	ra,0x1
    80003006:	3d2080e7          	jalr	978(ra) # 800043d4 <releasesleep>

  acquire(&bcache.lock);
    8000300a:	00014517          	auipc	a0,0x14
    8000300e:	2de50513          	addi	a0,a0,734 # 800172e8 <bcache>
    80003012:	ffffe097          	auipc	ra,0xffffe
    80003016:	bc4080e7          	jalr	-1084(ra) # 80000bd6 <acquire>
  b->refcnt--;
    8000301a:	40bc                	lw	a5,64(s1)
    8000301c:	37fd                	addiw	a5,a5,-1
    8000301e:	0007871b          	sext.w	a4,a5
    80003022:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80003024:	eb05                	bnez	a4,80003054 <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80003026:	68bc                	ld	a5,80(s1)
    80003028:	64b8                	ld	a4,72(s1)
    8000302a:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    8000302c:	64bc                	ld	a5,72(s1)
    8000302e:	68b8                	ld	a4,80(s1)
    80003030:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80003032:	0001c797          	auipc	a5,0x1c
    80003036:	2b678793          	addi	a5,a5,694 # 8001f2e8 <bcache+0x8000>
    8000303a:	2b87b703          	ld	a4,696(a5)
    8000303e:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80003040:	0001c717          	auipc	a4,0x1c
    80003044:	51070713          	addi	a4,a4,1296 # 8001f550 <bcache+0x8268>
    80003048:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    8000304a:	2b87b703          	ld	a4,696(a5)
    8000304e:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80003050:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80003054:	00014517          	auipc	a0,0x14
    80003058:	29450513          	addi	a0,a0,660 # 800172e8 <bcache>
    8000305c:	ffffe097          	auipc	ra,0xffffe
    80003060:	c2e080e7          	jalr	-978(ra) # 80000c8a <release>
}
    80003064:	60e2                	ld	ra,24(sp)
    80003066:	6442                	ld	s0,16(sp)
    80003068:	64a2                	ld	s1,8(sp)
    8000306a:	6902                	ld	s2,0(sp)
    8000306c:	6105                	addi	sp,sp,32
    8000306e:	8082                	ret
    panic("brelse");
    80003070:	00005517          	auipc	a0,0x5
    80003074:	4a850513          	addi	a0,a0,1192 # 80008518 <syscalls+0xe8>
    80003078:	ffffd097          	auipc	ra,0xffffd
    8000307c:	4b8080e7          	jalr	1208(ra) # 80000530 <panic>

0000000080003080 <bpin>:

void
bpin(struct buf *b) {
    80003080:	1101                	addi	sp,sp,-32
    80003082:	ec06                	sd	ra,24(sp)
    80003084:	e822                	sd	s0,16(sp)
    80003086:	e426                	sd	s1,8(sp)
    80003088:	1000                	addi	s0,sp,32
    8000308a:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    8000308c:	00014517          	auipc	a0,0x14
    80003090:	25c50513          	addi	a0,a0,604 # 800172e8 <bcache>
    80003094:	ffffe097          	auipc	ra,0xffffe
    80003098:	b42080e7          	jalr	-1214(ra) # 80000bd6 <acquire>
  b->refcnt++;
    8000309c:	40bc                	lw	a5,64(s1)
    8000309e:	2785                	addiw	a5,a5,1
    800030a0:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800030a2:	00014517          	auipc	a0,0x14
    800030a6:	24650513          	addi	a0,a0,582 # 800172e8 <bcache>
    800030aa:	ffffe097          	auipc	ra,0xffffe
    800030ae:	be0080e7          	jalr	-1056(ra) # 80000c8a <release>
}
    800030b2:	60e2                	ld	ra,24(sp)
    800030b4:	6442                	ld	s0,16(sp)
    800030b6:	64a2                	ld	s1,8(sp)
    800030b8:	6105                	addi	sp,sp,32
    800030ba:	8082                	ret

00000000800030bc <bunpin>:

void
bunpin(struct buf *b) {
    800030bc:	1101                	addi	sp,sp,-32
    800030be:	ec06                	sd	ra,24(sp)
    800030c0:	e822                	sd	s0,16(sp)
    800030c2:	e426                	sd	s1,8(sp)
    800030c4:	1000                	addi	s0,sp,32
    800030c6:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800030c8:	00014517          	auipc	a0,0x14
    800030cc:	22050513          	addi	a0,a0,544 # 800172e8 <bcache>
    800030d0:	ffffe097          	auipc	ra,0xffffe
    800030d4:	b06080e7          	jalr	-1274(ra) # 80000bd6 <acquire>
  b->refcnt--;
    800030d8:	40bc                	lw	a5,64(s1)
    800030da:	37fd                	addiw	a5,a5,-1
    800030dc:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800030de:	00014517          	auipc	a0,0x14
    800030e2:	20a50513          	addi	a0,a0,522 # 800172e8 <bcache>
    800030e6:	ffffe097          	auipc	ra,0xffffe
    800030ea:	ba4080e7          	jalr	-1116(ra) # 80000c8a <release>
}
    800030ee:	60e2                	ld	ra,24(sp)
    800030f0:	6442                	ld	s0,16(sp)
    800030f2:	64a2                	ld	s1,8(sp)
    800030f4:	6105                	addi	sp,sp,32
    800030f6:	8082                	ret

00000000800030f8 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    800030f8:	1101                	addi	sp,sp,-32
    800030fa:	ec06                	sd	ra,24(sp)
    800030fc:	e822                	sd	s0,16(sp)
    800030fe:	e426                	sd	s1,8(sp)
    80003100:	e04a                	sd	s2,0(sp)
    80003102:	1000                	addi	s0,sp,32
    80003104:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80003106:	00d5d59b          	srliw	a1,a1,0xd
    8000310a:	0001d797          	auipc	a5,0x1d
    8000310e:	8ba7a783          	lw	a5,-1862(a5) # 8001f9c4 <sb+0x1c>
    80003112:	9dbd                	addw	a1,a1,a5
    80003114:	00000097          	auipc	ra,0x0
    80003118:	d9e080e7          	jalr	-610(ra) # 80002eb2 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    8000311c:	0074f713          	andi	a4,s1,7
    80003120:	4785                	li	a5,1
    80003122:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    80003126:	14ce                	slli	s1,s1,0x33
    80003128:	90d9                	srli	s1,s1,0x36
    8000312a:	00950733          	add	a4,a0,s1
    8000312e:	05874703          	lbu	a4,88(a4)
    80003132:	00e7f6b3          	and	a3,a5,a4
    80003136:	c69d                	beqz	a3,80003164 <bfree+0x6c>
    80003138:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    8000313a:	94aa                	add	s1,s1,a0
    8000313c:	fff7c793          	not	a5,a5
    80003140:	8ff9                	and	a5,a5,a4
    80003142:	04f48c23          	sb	a5,88(s1)
  log_write(bp);
    80003146:	00001097          	auipc	ra,0x1
    8000314a:	118080e7          	jalr	280(ra) # 8000425e <log_write>
  brelse(bp);
    8000314e:	854a                	mv	a0,s2
    80003150:	00000097          	auipc	ra,0x0
    80003154:	e92080e7          	jalr	-366(ra) # 80002fe2 <brelse>
}
    80003158:	60e2                	ld	ra,24(sp)
    8000315a:	6442                	ld	s0,16(sp)
    8000315c:	64a2                	ld	s1,8(sp)
    8000315e:	6902                	ld	s2,0(sp)
    80003160:	6105                	addi	sp,sp,32
    80003162:	8082                	ret
    panic("freeing free block");
    80003164:	00005517          	auipc	a0,0x5
    80003168:	3bc50513          	addi	a0,a0,956 # 80008520 <syscalls+0xf0>
    8000316c:	ffffd097          	auipc	ra,0xffffd
    80003170:	3c4080e7          	jalr	964(ra) # 80000530 <panic>

0000000080003174 <balloc>:
{
    80003174:	711d                	addi	sp,sp,-96
    80003176:	ec86                	sd	ra,88(sp)
    80003178:	e8a2                	sd	s0,80(sp)
    8000317a:	e4a6                	sd	s1,72(sp)
    8000317c:	e0ca                	sd	s2,64(sp)
    8000317e:	fc4e                	sd	s3,56(sp)
    80003180:	f852                	sd	s4,48(sp)
    80003182:	f456                	sd	s5,40(sp)
    80003184:	f05a                	sd	s6,32(sp)
    80003186:	ec5e                	sd	s7,24(sp)
    80003188:	e862                	sd	s8,16(sp)
    8000318a:	e466                	sd	s9,8(sp)
    8000318c:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    8000318e:	0001d797          	auipc	a5,0x1d
    80003192:	81e7a783          	lw	a5,-2018(a5) # 8001f9ac <sb+0x4>
    80003196:	cbd1                	beqz	a5,8000322a <balloc+0xb6>
    80003198:	8baa                	mv	s7,a0
    8000319a:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    8000319c:	0001db17          	auipc	s6,0x1d
    800031a0:	80cb0b13          	addi	s6,s6,-2036 # 8001f9a8 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800031a4:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    800031a6:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800031a8:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    800031aa:	6c89                	lui	s9,0x2
    800031ac:	a831                	j	800031c8 <balloc+0x54>
    brelse(bp);
    800031ae:	854a                	mv	a0,s2
    800031b0:	00000097          	auipc	ra,0x0
    800031b4:	e32080e7          	jalr	-462(ra) # 80002fe2 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    800031b8:	015c87bb          	addw	a5,s9,s5
    800031bc:	00078a9b          	sext.w	s5,a5
    800031c0:	004b2703          	lw	a4,4(s6)
    800031c4:	06eaf363          	bgeu	s5,a4,8000322a <balloc+0xb6>
    bp = bread(dev, BBLOCK(b, sb));
    800031c8:	41fad79b          	sraiw	a5,s5,0x1f
    800031cc:	0137d79b          	srliw	a5,a5,0x13
    800031d0:	015787bb          	addw	a5,a5,s5
    800031d4:	40d7d79b          	sraiw	a5,a5,0xd
    800031d8:	01cb2583          	lw	a1,28(s6)
    800031dc:	9dbd                	addw	a1,a1,a5
    800031de:	855e                	mv	a0,s7
    800031e0:	00000097          	auipc	ra,0x0
    800031e4:	cd2080e7          	jalr	-814(ra) # 80002eb2 <bread>
    800031e8:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800031ea:	004b2503          	lw	a0,4(s6)
    800031ee:	000a849b          	sext.w	s1,s5
    800031f2:	8662                	mv	a2,s8
    800031f4:	faa4fde3          	bgeu	s1,a0,800031ae <balloc+0x3a>
      m = 1 << (bi % 8);
    800031f8:	41f6579b          	sraiw	a5,a2,0x1f
    800031fc:	01d7d69b          	srliw	a3,a5,0x1d
    80003200:	00c6873b          	addw	a4,a3,a2
    80003204:	00777793          	andi	a5,a4,7
    80003208:	9f95                	subw	a5,a5,a3
    8000320a:	00f997bb          	sllw	a5,s3,a5
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    8000320e:	4037571b          	sraiw	a4,a4,0x3
    80003212:	00e906b3          	add	a3,s2,a4
    80003216:	0586c683          	lbu	a3,88(a3)
    8000321a:	00d7f5b3          	and	a1,a5,a3
    8000321e:	cd91                	beqz	a1,8000323a <balloc+0xc6>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003220:	2605                	addiw	a2,a2,1
    80003222:	2485                	addiw	s1,s1,1
    80003224:	fd4618e3          	bne	a2,s4,800031f4 <balloc+0x80>
    80003228:	b759                	j	800031ae <balloc+0x3a>
  panic("balloc: out of blocks");
    8000322a:	00005517          	auipc	a0,0x5
    8000322e:	30e50513          	addi	a0,a0,782 # 80008538 <syscalls+0x108>
    80003232:	ffffd097          	auipc	ra,0xffffd
    80003236:	2fe080e7          	jalr	766(ra) # 80000530 <panic>
        bp->data[bi/8] |= m;  // Mark block in use.
    8000323a:	974a                	add	a4,a4,s2
    8000323c:	8fd5                	or	a5,a5,a3
    8000323e:	04f70c23          	sb	a5,88(a4)
        log_write(bp);
    80003242:	854a                	mv	a0,s2
    80003244:	00001097          	auipc	ra,0x1
    80003248:	01a080e7          	jalr	26(ra) # 8000425e <log_write>
        brelse(bp);
    8000324c:	854a                	mv	a0,s2
    8000324e:	00000097          	auipc	ra,0x0
    80003252:	d94080e7          	jalr	-620(ra) # 80002fe2 <brelse>
  bp = bread(dev, bno);
    80003256:	85a6                	mv	a1,s1
    80003258:	855e                	mv	a0,s7
    8000325a:	00000097          	auipc	ra,0x0
    8000325e:	c58080e7          	jalr	-936(ra) # 80002eb2 <bread>
    80003262:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80003264:	40000613          	li	a2,1024
    80003268:	4581                	li	a1,0
    8000326a:	05850513          	addi	a0,a0,88
    8000326e:	ffffe097          	auipc	ra,0xffffe
    80003272:	a64080e7          	jalr	-1436(ra) # 80000cd2 <memset>
  log_write(bp);
    80003276:	854a                	mv	a0,s2
    80003278:	00001097          	auipc	ra,0x1
    8000327c:	fe6080e7          	jalr	-26(ra) # 8000425e <log_write>
  brelse(bp);
    80003280:	854a                	mv	a0,s2
    80003282:	00000097          	auipc	ra,0x0
    80003286:	d60080e7          	jalr	-672(ra) # 80002fe2 <brelse>
}
    8000328a:	8526                	mv	a0,s1
    8000328c:	60e6                	ld	ra,88(sp)
    8000328e:	6446                	ld	s0,80(sp)
    80003290:	64a6                	ld	s1,72(sp)
    80003292:	6906                	ld	s2,64(sp)
    80003294:	79e2                	ld	s3,56(sp)
    80003296:	7a42                	ld	s4,48(sp)
    80003298:	7aa2                	ld	s5,40(sp)
    8000329a:	7b02                	ld	s6,32(sp)
    8000329c:	6be2                	ld	s7,24(sp)
    8000329e:	6c42                	ld	s8,16(sp)
    800032a0:	6ca2                	ld	s9,8(sp)
    800032a2:	6125                	addi	sp,sp,96
    800032a4:	8082                	ret

00000000800032a6 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
    800032a6:	7179                	addi	sp,sp,-48
    800032a8:	f406                	sd	ra,40(sp)
    800032aa:	f022                	sd	s0,32(sp)
    800032ac:	ec26                	sd	s1,24(sp)
    800032ae:	e84a                	sd	s2,16(sp)
    800032b0:	e44e                	sd	s3,8(sp)
    800032b2:	e052                	sd	s4,0(sp)
    800032b4:	1800                	addi	s0,sp,48
    800032b6:	892a                	mv	s2,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    800032b8:	47ad                	li	a5,11
    800032ba:	04b7fe63          	bgeu	a5,a1,80003316 <bmap+0x70>
    if((addr = ip->addrs[bn]) == 0)
      ip->addrs[bn] = addr = balloc(ip->dev);
    return addr;
  }
  bn -= NDIRECT;
    800032be:	ff45849b          	addiw	s1,a1,-12
    800032c2:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    800032c6:	0ff00793          	li	a5,255
    800032ca:	0ae7e363          	bltu	a5,a4,80003370 <bmap+0xca>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
    800032ce:	08052583          	lw	a1,128(a0)
    800032d2:	c5ad                	beqz	a1,8000333c <bmap+0x96>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    bp = bread(ip->dev, addr);
    800032d4:	00092503          	lw	a0,0(s2)
    800032d8:	00000097          	auipc	ra,0x0
    800032dc:	bda080e7          	jalr	-1062(ra) # 80002eb2 <bread>
    800032e0:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    800032e2:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    800032e6:	02049593          	slli	a1,s1,0x20
    800032ea:	9181                	srli	a1,a1,0x20
    800032ec:	058a                	slli	a1,a1,0x2
    800032ee:	00b784b3          	add	s1,a5,a1
    800032f2:	0004a983          	lw	s3,0(s1)
    800032f6:	04098d63          	beqz	s3,80003350 <bmap+0xaa>
      a[bn] = addr = balloc(ip->dev);
      log_write(bp);
    }
    brelse(bp);
    800032fa:	8552                	mv	a0,s4
    800032fc:	00000097          	auipc	ra,0x0
    80003300:	ce6080e7          	jalr	-794(ra) # 80002fe2 <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    80003304:	854e                	mv	a0,s3
    80003306:	70a2                	ld	ra,40(sp)
    80003308:	7402                	ld	s0,32(sp)
    8000330a:	64e2                	ld	s1,24(sp)
    8000330c:	6942                	ld	s2,16(sp)
    8000330e:	69a2                	ld	s3,8(sp)
    80003310:	6a02                	ld	s4,0(sp)
    80003312:	6145                	addi	sp,sp,48
    80003314:	8082                	ret
    if((addr = ip->addrs[bn]) == 0)
    80003316:	02059493          	slli	s1,a1,0x20
    8000331a:	9081                	srli	s1,s1,0x20
    8000331c:	048a                	slli	s1,s1,0x2
    8000331e:	94aa                	add	s1,s1,a0
    80003320:	0504a983          	lw	s3,80(s1)
    80003324:	fe0990e3          	bnez	s3,80003304 <bmap+0x5e>
      ip->addrs[bn] = addr = balloc(ip->dev);
    80003328:	4108                	lw	a0,0(a0)
    8000332a:	00000097          	auipc	ra,0x0
    8000332e:	e4a080e7          	jalr	-438(ra) # 80003174 <balloc>
    80003332:	0005099b          	sext.w	s3,a0
    80003336:	0534a823          	sw	s3,80(s1)
    8000333a:	b7e9                	j	80003304 <bmap+0x5e>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    8000333c:	4108                	lw	a0,0(a0)
    8000333e:	00000097          	auipc	ra,0x0
    80003342:	e36080e7          	jalr	-458(ra) # 80003174 <balloc>
    80003346:	0005059b          	sext.w	a1,a0
    8000334a:	08b92023          	sw	a1,128(s2)
    8000334e:	b759                	j	800032d4 <bmap+0x2e>
      a[bn] = addr = balloc(ip->dev);
    80003350:	00092503          	lw	a0,0(s2)
    80003354:	00000097          	auipc	ra,0x0
    80003358:	e20080e7          	jalr	-480(ra) # 80003174 <balloc>
    8000335c:	0005099b          	sext.w	s3,a0
    80003360:	0134a023          	sw	s3,0(s1)
      log_write(bp);
    80003364:	8552                	mv	a0,s4
    80003366:	00001097          	auipc	ra,0x1
    8000336a:	ef8080e7          	jalr	-264(ra) # 8000425e <log_write>
    8000336e:	b771                	j	800032fa <bmap+0x54>
  panic("bmap: out of range");
    80003370:	00005517          	auipc	a0,0x5
    80003374:	1e050513          	addi	a0,a0,480 # 80008550 <syscalls+0x120>
    80003378:	ffffd097          	auipc	ra,0xffffd
    8000337c:	1b8080e7          	jalr	440(ra) # 80000530 <panic>

0000000080003380 <iget>:
{
    80003380:	7179                	addi	sp,sp,-48
    80003382:	f406                	sd	ra,40(sp)
    80003384:	f022                	sd	s0,32(sp)
    80003386:	ec26                	sd	s1,24(sp)
    80003388:	e84a                	sd	s2,16(sp)
    8000338a:	e44e                	sd	s3,8(sp)
    8000338c:	e052                	sd	s4,0(sp)
    8000338e:	1800                	addi	s0,sp,48
    80003390:	89aa                	mv	s3,a0
    80003392:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80003394:	0001c517          	auipc	a0,0x1c
    80003398:	63450513          	addi	a0,a0,1588 # 8001f9c8 <itable>
    8000339c:	ffffe097          	auipc	ra,0xffffe
    800033a0:	83a080e7          	jalr	-1990(ra) # 80000bd6 <acquire>
  empty = 0;
    800033a4:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    800033a6:	0001c497          	auipc	s1,0x1c
    800033aa:	63a48493          	addi	s1,s1,1594 # 8001f9e0 <itable+0x18>
    800033ae:	0001e697          	auipc	a3,0x1e
    800033b2:	0c268693          	addi	a3,a3,194 # 80021470 <log>
    800033b6:	a039                	j	800033c4 <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800033b8:	02090b63          	beqz	s2,800033ee <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    800033bc:	08848493          	addi	s1,s1,136
    800033c0:	02d48a63          	beq	s1,a3,800033f4 <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    800033c4:	449c                	lw	a5,8(s1)
    800033c6:	fef059e3          	blez	a5,800033b8 <iget+0x38>
    800033ca:	4098                	lw	a4,0(s1)
    800033cc:	ff3716e3          	bne	a4,s3,800033b8 <iget+0x38>
    800033d0:	40d8                	lw	a4,4(s1)
    800033d2:	ff4713e3          	bne	a4,s4,800033b8 <iget+0x38>
      ip->ref++;
    800033d6:	2785                	addiw	a5,a5,1
    800033d8:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    800033da:	0001c517          	auipc	a0,0x1c
    800033de:	5ee50513          	addi	a0,a0,1518 # 8001f9c8 <itable>
    800033e2:	ffffe097          	auipc	ra,0xffffe
    800033e6:	8a8080e7          	jalr	-1880(ra) # 80000c8a <release>
      return ip;
    800033ea:	8926                	mv	s2,s1
    800033ec:	a03d                	j	8000341a <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800033ee:	f7f9                	bnez	a5,800033bc <iget+0x3c>
    800033f0:	8926                	mv	s2,s1
    800033f2:	b7e9                	j	800033bc <iget+0x3c>
  if(empty == 0)
    800033f4:	02090c63          	beqz	s2,8000342c <iget+0xac>
  ip->dev = dev;
    800033f8:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    800033fc:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80003400:	4785                	li	a5,1
    80003402:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80003406:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    8000340a:	0001c517          	auipc	a0,0x1c
    8000340e:	5be50513          	addi	a0,a0,1470 # 8001f9c8 <itable>
    80003412:	ffffe097          	auipc	ra,0xffffe
    80003416:	878080e7          	jalr	-1928(ra) # 80000c8a <release>
}
    8000341a:	854a                	mv	a0,s2
    8000341c:	70a2                	ld	ra,40(sp)
    8000341e:	7402                	ld	s0,32(sp)
    80003420:	64e2                	ld	s1,24(sp)
    80003422:	6942                	ld	s2,16(sp)
    80003424:	69a2                	ld	s3,8(sp)
    80003426:	6a02                	ld	s4,0(sp)
    80003428:	6145                	addi	sp,sp,48
    8000342a:	8082                	ret
    panic("iget: no inodes");
    8000342c:	00005517          	auipc	a0,0x5
    80003430:	13c50513          	addi	a0,a0,316 # 80008568 <syscalls+0x138>
    80003434:	ffffd097          	auipc	ra,0xffffd
    80003438:	0fc080e7          	jalr	252(ra) # 80000530 <panic>

000000008000343c <fsinit>:
fsinit(int dev) {
    8000343c:	7179                	addi	sp,sp,-48
    8000343e:	f406                	sd	ra,40(sp)
    80003440:	f022                	sd	s0,32(sp)
    80003442:	ec26                	sd	s1,24(sp)
    80003444:	e84a                	sd	s2,16(sp)
    80003446:	e44e                	sd	s3,8(sp)
    80003448:	1800                	addi	s0,sp,48
    8000344a:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    8000344c:	4585                	li	a1,1
    8000344e:	00000097          	auipc	ra,0x0
    80003452:	a64080e7          	jalr	-1436(ra) # 80002eb2 <bread>
    80003456:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003458:	0001c997          	auipc	s3,0x1c
    8000345c:	55098993          	addi	s3,s3,1360 # 8001f9a8 <sb>
    80003460:	02000613          	li	a2,32
    80003464:	05850593          	addi	a1,a0,88
    80003468:	854e                	mv	a0,s3
    8000346a:	ffffe097          	auipc	ra,0xffffe
    8000346e:	8c8080e7          	jalr	-1848(ra) # 80000d32 <memmove>
  brelse(bp);
    80003472:	8526                	mv	a0,s1
    80003474:	00000097          	auipc	ra,0x0
    80003478:	b6e080e7          	jalr	-1170(ra) # 80002fe2 <brelse>
  if(sb.magic != FSMAGIC)
    8000347c:	0009a703          	lw	a4,0(s3)
    80003480:	102037b7          	lui	a5,0x10203
    80003484:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003488:	02f71263          	bne	a4,a5,800034ac <fsinit+0x70>
  initlog(dev, &sb);
    8000348c:	0001c597          	auipc	a1,0x1c
    80003490:	51c58593          	addi	a1,a1,1308 # 8001f9a8 <sb>
    80003494:	854a                	mv	a0,s2
    80003496:	00001097          	auipc	ra,0x1
    8000349a:	b4c080e7          	jalr	-1204(ra) # 80003fe2 <initlog>
}
    8000349e:	70a2                	ld	ra,40(sp)
    800034a0:	7402                	ld	s0,32(sp)
    800034a2:	64e2                	ld	s1,24(sp)
    800034a4:	6942                	ld	s2,16(sp)
    800034a6:	69a2                	ld	s3,8(sp)
    800034a8:	6145                	addi	sp,sp,48
    800034aa:	8082                	ret
    panic("invalid file system");
    800034ac:	00005517          	auipc	a0,0x5
    800034b0:	0cc50513          	addi	a0,a0,204 # 80008578 <syscalls+0x148>
    800034b4:	ffffd097          	auipc	ra,0xffffd
    800034b8:	07c080e7          	jalr	124(ra) # 80000530 <panic>

00000000800034bc <iinit>:
{
    800034bc:	7179                	addi	sp,sp,-48
    800034be:	f406                	sd	ra,40(sp)
    800034c0:	f022                	sd	s0,32(sp)
    800034c2:	ec26                	sd	s1,24(sp)
    800034c4:	e84a                	sd	s2,16(sp)
    800034c6:	e44e                	sd	s3,8(sp)
    800034c8:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    800034ca:	00005597          	auipc	a1,0x5
    800034ce:	0c658593          	addi	a1,a1,198 # 80008590 <syscalls+0x160>
    800034d2:	0001c517          	auipc	a0,0x1c
    800034d6:	4f650513          	addi	a0,a0,1270 # 8001f9c8 <itable>
    800034da:	ffffd097          	auipc	ra,0xffffd
    800034de:	66c080e7          	jalr	1644(ra) # 80000b46 <initlock>
  for(i = 0; i < NINODE; i++) {
    800034e2:	0001c497          	auipc	s1,0x1c
    800034e6:	50e48493          	addi	s1,s1,1294 # 8001f9f0 <itable+0x28>
    800034ea:	0001e997          	auipc	s3,0x1e
    800034ee:	f9698993          	addi	s3,s3,-106 # 80021480 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    800034f2:	00005917          	auipc	s2,0x5
    800034f6:	0a690913          	addi	s2,s2,166 # 80008598 <syscalls+0x168>
    800034fa:	85ca                	mv	a1,s2
    800034fc:	8526                	mv	a0,s1
    800034fe:	00001097          	auipc	ra,0x1
    80003502:	e46080e7          	jalr	-442(ra) # 80004344 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80003506:	08848493          	addi	s1,s1,136
    8000350a:	ff3498e3          	bne	s1,s3,800034fa <iinit+0x3e>
}
    8000350e:	70a2                	ld	ra,40(sp)
    80003510:	7402                	ld	s0,32(sp)
    80003512:	64e2                	ld	s1,24(sp)
    80003514:	6942                	ld	s2,16(sp)
    80003516:	69a2                	ld	s3,8(sp)
    80003518:	6145                	addi	sp,sp,48
    8000351a:	8082                	ret

000000008000351c <ialloc>:
{
    8000351c:	715d                	addi	sp,sp,-80
    8000351e:	e486                	sd	ra,72(sp)
    80003520:	e0a2                	sd	s0,64(sp)
    80003522:	fc26                	sd	s1,56(sp)
    80003524:	f84a                	sd	s2,48(sp)
    80003526:	f44e                	sd	s3,40(sp)
    80003528:	f052                	sd	s4,32(sp)
    8000352a:	ec56                	sd	s5,24(sp)
    8000352c:	e85a                	sd	s6,16(sp)
    8000352e:	e45e                	sd	s7,8(sp)
    80003530:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    80003532:	0001c717          	auipc	a4,0x1c
    80003536:	48272703          	lw	a4,1154(a4) # 8001f9b4 <sb+0xc>
    8000353a:	4785                	li	a5,1
    8000353c:	04e7fa63          	bgeu	a5,a4,80003590 <ialloc+0x74>
    80003540:	8aaa                	mv	s5,a0
    80003542:	8bae                	mv	s7,a1
    80003544:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    80003546:	0001ca17          	auipc	s4,0x1c
    8000354a:	462a0a13          	addi	s4,s4,1122 # 8001f9a8 <sb>
    8000354e:	00048b1b          	sext.w	s6,s1
    80003552:	0044d593          	srli	a1,s1,0x4
    80003556:	018a2783          	lw	a5,24(s4)
    8000355a:	9dbd                	addw	a1,a1,a5
    8000355c:	8556                	mv	a0,s5
    8000355e:	00000097          	auipc	ra,0x0
    80003562:	954080e7          	jalr	-1708(ra) # 80002eb2 <bread>
    80003566:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80003568:	05850993          	addi	s3,a0,88
    8000356c:	00f4f793          	andi	a5,s1,15
    80003570:	079a                	slli	a5,a5,0x6
    80003572:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80003574:	00099783          	lh	a5,0(s3)
    80003578:	c785                	beqz	a5,800035a0 <ialloc+0x84>
    brelse(bp);
    8000357a:	00000097          	auipc	ra,0x0
    8000357e:	a68080e7          	jalr	-1432(ra) # 80002fe2 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80003582:	0485                	addi	s1,s1,1
    80003584:	00ca2703          	lw	a4,12(s4)
    80003588:	0004879b          	sext.w	a5,s1
    8000358c:	fce7e1e3          	bltu	a5,a4,8000354e <ialloc+0x32>
  panic("ialloc: no inodes");
    80003590:	00005517          	auipc	a0,0x5
    80003594:	01050513          	addi	a0,a0,16 # 800085a0 <syscalls+0x170>
    80003598:	ffffd097          	auipc	ra,0xffffd
    8000359c:	f98080e7          	jalr	-104(ra) # 80000530 <panic>
      memset(dip, 0, sizeof(*dip));
    800035a0:	04000613          	li	a2,64
    800035a4:	4581                	li	a1,0
    800035a6:	854e                	mv	a0,s3
    800035a8:	ffffd097          	auipc	ra,0xffffd
    800035ac:	72a080e7          	jalr	1834(ra) # 80000cd2 <memset>
      dip->type = type;
    800035b0:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    800035b4:	854a                	mv	a0,s2
    800035b6:	00001097          	auipc	ra,0x1
    800035ba:	ca8080e7          	jalr	-856(ra) # 8000425e <log_write>
      brelse(bp);
    800035be:	854a                	mv	a0,s2
    800035c0:	00000097          	auipc	ra,0x0
    800035c4:	a22080e7          	jalr	-1502(ra) # 80002fe2 <brelse>
      return iget(dev, inum);
    800035c8:	85da                	mv	a1,s6
    800035ca:	8556                	mv	a0,s5
    800035cc:	00000097          	auipc	ra,0x0
    800035d0:	db4080e7          	jalr	-588(ra) # 80003380 <iget>
}
    800035d4:	60a6                	ld	ra,72(sp)
    800035d6:	6406                	ld	s0,64(sp)
    800035d8:	74e2                	ld	s1,56(sp)
    800035da:	7942                	ld	s2,48(sp)
    800035dc:	79a2                	ld	s3,40(sp)
    800035de:	7a02                	ld	s4,32(sp)
    800035e0:	6ae2                	ld	s5,24(sp)
    800035e2:	6b42                	ld	s6,16(sp)
    800035e4:	6ba2                	ld	s7,8(sp)
    800035e6:	6161                	addi	sp,sp,80
    800035e8:	8082                	ret

00000000800035ea <iupdate>:
{
    800035ea:	1101                	addi	sp,sp,-32
    800035ec:	ec06                	sd	ra,24(sp)
    800035ee:	e822                	sd	s0,16(sp)
    800035f0:	e426                	sd	s1,8(sp)
    800035f2:	e04a                	sd	s2,0(sp)
    800035f4:	1000                	addi	s0,sp,32
    800035f6:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800035f8:	415c                	lw	a5,4(a0)
    800035fa:	0047d79b          	srliw	a5,a5,0x4
    800035fe:	0001c597          	auipc	a1,0x1c
    80003602:	3c25a583          	lw	a1,962(a1) # 8001f9c0 <sb+0x18>
    80003606:	9dbd                	addw	a1,a1,a5
    80003608:	4108                	lw	a0,0(a0)
    8000360a:	00000097          	auipc	ra,0x0
    8000360e:	8a8080e7          	jalr	-1880(ra) # 80002eb2 <bread>
    80003612:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003614:	05850793          	addi	a5,a0,88
    80003618:	40c8                	lw	a0,4(s1)
    8000361a:	893d                	andi	a0,a0,15
    8000361c:	051a                	slli	a0,a0,0x6
    8000361e:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    80003620:	04449703          	lh	a4,68(s1)
    80003624:	00e51023          	sh	a4,0(a0)
  dip->major = ip->major;
    80003628:	04649703          	lh	a4,70(s1)
    8000362c:	00e51123          	sh	a4,2(a0)
  dip->minor = ip->minor;
    80003630:	04849703          	lh	a4,72(s1)
    80003634:	00e51223          	sh	a4,4(a0)
  dip->nlink = ip->nlink;
    80003638:	04a49703          	lh	a4,74(s1)
    8000363c:	00e51323          	sh	a4,6(a0)
  dip->size = ip->size;
    80003640:	44f8                	lw	a4,76(s1)
    80003642:	c518                	sw	a4,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003644:	03400613          	li	a2,52
    80003648:	05048593          	addi	a1,s1,80
    8000364c:	0531                	addi	a0,a0,12
    8000364e:	ffffd097          	auipc	ra,0xffffd
    80003652:	6e4080e7          	jalr	1764(ra) # 80000d32 <memmove>
  log_write(bp);
    80003656:	854a                	mv	a0,s2
    80003658:	00001097          	auipc	ra,0x1
    8000365c:	c06080e7          	jalr	-1018(ra) # 8000425e <log_write>
  brelse(bp);
    80003660:	854a                	mv	a0,s2
    80003662:	00000097          	auipc	ra,0x0
    80003666:	980080e7          	jalr	-1664(ra) # 80002fe2 <brelse>
}
    8000366a:	60e2                	ld	ra,24(sp)
    8000366c:	6442                	ld	s0,16(sp)
    8000366e:	64a2                	ld	s1,8(sp)
    80003670:	6902                	ld	s2,0(sp)
    80003672:	6105                	addi	sp,sp,32
    80003674:	8082                	ret

0000000080003676 <idup>:
{
    80003676:	1101                	addi	sp,sp,-32
    80003678:	ec06                	sd	ra,24(sp)
    8000367a:	e822                	sd	s0,16(sp)
    8000367c:	e426                	sd	s1,8(sp)
    8000367e:	1000                	addi	s0,sp,32
    80003680:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003682:	0001c517          	auipc	a0,0x1c
    80003686:	34650513          	addi	a0,a0,838 # 8001f9c8 <itable>
    8000368a:	ffffd097          	auipc	ra,0xffffd
    8000368e:	54c080e7          	jalr	1356(ra) # 80000bd6 <acquire>
  ip->ref++;
    80003692:	449c                	lw	a5,8(s1)
    80003694:	2785                	addiw	a5,a5,1
    80003696:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003698:	0001c517          	auipc	a0,0x1c
    8000369c:	33050513          	addi	a0,a0,816 # 8001f9c8 <itable>
    800036a0:	ffffd097          	auipc	ra,0xffffd
    800036a4:	5ea080e7          	jalr	1514(ra) # 80000c8a <release>
}
    800036a8:	8526                	mv	a0,s1
    800036aa:	60e2                	ld	ra,24(sp)
    800036ac:	6442                	ld	s0,16(sp)
    800036ae:	64a2                	ld	s1,8(sp)
    800036b0:	6105                	addi	sp,sp,32
    800036b2:	8082                	ret

00000000800036b4 <ilock>:
{
    800036b4:	1101                	addi	sp,sp,-32
    800036b6:	ec06                	sd	ra,24(sp)
    800036b8:	e822                	sd	s0,16(sp)
    800036ba:	e426                	sd	s1,8(sp)
    800036bc:	e04a                	sd	s2,0(sp)
    800036be:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    800036c0:	c115                	beqz	a0,800036e4 <ilock+0x30>
    800036c2:	84aa                	mv	s1,a0
    800036c4:	451c                	lw	a5,8(a0)
    800036c6:	00f05f63          	blez	a5,800036e4 <ilock+0x30>
  acquiresleep(&ip->lock);
    800036ca:	0541                	addi	a0,a0,16
    800036cc:	00001097          	auipc	ra,0x1
    800036d0:	cb2080e7          	jalr	-846(ra) # 8000437e <acquiresleep>
  if(ip->valid == 0){
    800036d4:	40bc                	lw	a5,64(s1)
    800036d6:	cf99                	beqz	a5,800036f4 <ilock+0x40>
}
    800036d8:	60e2                	ld	ra,24(sp)
    800036da:	6442                	ld	s0,16(sp)
    800036dc:	64a2                	ld	s1,8(sp)
    800036de:	6902                	ld	s2,0(sp)
    800036e0:	6105                	addi	sp,sp,32
    800036e2:	8082                	ret
    panic("ilock");
    800036e4:	00005517          	auipc	a0,0x5
    800036e8:	ed450513          	addi	a0,a0,-300 # 800085b8 <syscalls+0x188>
    800036ec:	ffffd097          	auipc	ra,0xffffd
    800036f0:	e44080e7          	jalr	-444(ra) # 80000530 <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800036f4:	40dc                	lw	a5,4(s1)
    800036f6:	0047d79b          	srliw	a5,a5,0x4
    800036fa:	0001c597          	auipc	a1,0x1c
    800036fe:	2c65a583          	lw	a1,710(a1) # 8001f9c0 <sb+0x18>
    80003702:	9dbd                	addw	a1,a1,a5
    80003704:	4088                	lw	a0,0(s1)
    80003706:	fffff097          	auipc	ra,0xfffff
    8000370a:	7ac080e7          	jalr	1964(ra) # 80002eb2 <bread>
    8000370e:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003710:	05850593          	addi	a1,a0,88
    80003714:	40dc                	lw	a5,4(s1)
    80003716:	8bbd                	andi	a5,a5,15
    80003718:	079a                	slli	a5,a5,0x6
    8000371a:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    8000371c:	00059783          	lh	a5,0(a1)
    80003720:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003724:	00259783          	lh	a5,2(a1)
    80003728:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    8000372c:	00459783          	lh	a5,4(a1)
    80003730:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003734:	00659783          	lh	a5,6(a1)
    80003738:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    8000373c:	459c                	lw	a5,8(a1)
    8000373e:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003740:	03400613          	li	a2,52
    80003744:	05b1                	addi	a1,a1,12
    80003746:	05048513          	addi	a0,s1,80
    8000374a:	ffffd097          	auipc	ra,0xffffd
    8000374e:	5e8080e7          	jalr	1512(ra) # 80000d32 <memmove>
    brelse(bp);
    80003752:	854a                	mv	a0,s2
    80003754:	00000097          	auipc	ra,0x0
    80003758:	88e080e7          	jalr	-1906(ra) # 80002fe2 <brelse>
    ip->valid = 1;
    8000375c:	4785                	li	a5,1
    8000375e:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80003760:	04449783          	lh	a5,68(s1)
    80003764:	fbb5                	bnez	a5,800036d8 <ilock+0x24>
      panic("ilock: no type");
    80003766:	00005517          	auipc	a0,0x5
    8000376a:	e5a50513          	addi	a0,a0,-422 # 800085c0 <syscalls+0x190>
    8000376e:	ffffd097          	auipc	ra,0xffffd
    80003772:	dc2080e7          	jalr	-574(ra) # 80000530 <panic>

0000000080003776 <iunlock>:
{
    80003776:	1101                	addi	sp,sp,-32
    80003778:	ec06                	sd	ra,24(sp)
    8000377a:	e822                	sd	s0,16(sp)
    8000377c:	e426                	sd	s1,8(sp)
    8000377e:	e04a                	sd	s2,0(sp)
    80003780:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003782:	c905                	beqz	a0,800037b2 <iunlock+0x3c>
    80003784:	84aa                	mv	s1,a0
    80003786:	01050913          	addi	s2,a0,16
    8000378a:	854a                	mv	a0,s2
    8000378c:	00001097          	auipc	ra,0x1
    80003790:	c8c080e7          	jalr	-884(ra) # 80004418 <holdingsleep>
    80003794:	cd19                	beqz	a0,800037b2 <iunlock+0x3c>
    80003796:	449c                	lw	a5,8(s1)
    80003798:	00f05d63          	blez	a5,800037b2 <iunlock+0x3c>
  releasesleep(&ip->lock);
    8000379c:	854a                	mv	a0,s2
    8000379e:	00001097          	auipc	ra,0x1
    800037a2:	c36080e7          	jalr	-970(ra) # 800043d4 <releasesleep>
}
    800037a6:	60e2                	ld	ra,24(sp)
    800037a8:	6442                	ld	s0,16(sp)
    800037aa:	64a2                	ld	s1,8(sp)
    800037ac:	6902                	ld	s2,0(sp)
    800037ae:	6105                	addi	sp,sp,32
    800037b0:	8082                	ret
    panic("iunlock");
    800037b2:	00005517          	auipc	a0,0x5
    800037b6:	e1e50513          	addi	a0,a0,-482 # 800085d0 <syscalls+0x1a0>
    800037ba:	ffffd097          	auipc	ra,0xffffd
    800037be:	d76080e7          	jalr	-650(ra) # 80000530 <panic>

00000000800037c2 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    800037c2:	7179                	addi	sp,sp,-48
    800037c4:	f406                	sd	ra,40(sp)
    800037c6:	f022                	sd	s0,32(sp)
    800037c8:	ec26                	sd	s1,24(sp)
    800037ca:	e84a                	sd	s2,16(sp)
    800037cc:	e44e                	sd	s3,8(sp)
    800037ce:	e052                	sd	s4,0(sp)
    800037d0:	1800                	addi	s0,sp,48
    800037d2:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    800037d4:	05050493          	addi	s1,a0,80
    800037d8:	08050913          	addi	s2,a0,128
    800037dc:	a021                	j	800037e4 <itrunc+0x22>
    800037de:	0491                	addi	s1,s1,4
    800037e0:	01248d63          	beq	s1,s2,800037fa <itrunc+0x38>
    if(ip->addrs[i]){
    800037e4:	408c                	lw	a1,0(s1)
    800037e6:	dde5                	beqz	a1,800037de <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    800037e8:	0009a503          	lw	a0,0(s3)
    800037ec:	00000097          	auipc	ra,0x0
    800037f0:	90c080e7          	jalr	-1780(ra) # 800030f8 <bfree>
      ip->addrs[i] = 0;
    800037f4:	0004a023          	sw	zero,0(s1)
    800037f8:	b7dd                	j	800037de <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    800037fa:	0809a583          	lw	a1,128(s3)
    800037fe:	e185                	bnez	a1,8000381e <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003800:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003804:	854e                	mv	a0,s3
    80003806:	00000097          	auipc	ra,0x0
    8000380a:	de4080e7          	jalr	-540(ra) # 800035ea <iupdate>
}
    8000380e:	70a2                	ld	ra,40(sp)
    80003810:	7402                	ld	s0,32(sp)
    80003812:	64e2                	ld	s1,24(sp)
    80003814:	6942                	ld	s2,16(sp)
    80003816:	69a2                	ld	s3,8(sp)
    80003818:	6a02                	ld	s4,0(sp)
    8000381a:	6145                	addi	sp,sp,48
    8000381c:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    8000381e:	0009a503          	lw	a0,0(s3)
    80003822:	fffff097          	auipc	ra,0xfffff
    80003826:	690080e7          	jalr	1680(ra) # 80002eb2 <bread>
    8000382a:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    8000382c:	05850493          	addi	s1,a0,88
    80003830:	45850913          	addi	s2,a0,1112
    80003834:	a811                	j	80003848 <itrunc+0x86>
        bfree(ip->dev, a[j]);
    80003836:	0009a503          	lw	a0,0(s3)
    8000383a:	00000097          	auipc	ra,0x0
    8000383e:	8be080e7          	jalr	-1858(ra) # 800030f8 <bfree>
    for(j = 0; j < NINDIRECT; j++){
    80003842:	0491                	addi	s1,s1,4
    80003844:	01248563          	beq	s1,s2,8000384e <itrunc+0x8c>
      if(a[j])
    80003848:	408c                	lw	a1,0(s1)
    8000384a:	dde5                	beqz	a1,80003842 <itrunc+0x80>
    8000384c:	b7ed                	j	80003836 <itrunc+0x74>
    brelse(bp);
    8000384e:	8552                	mv	a0,s4
    80003850:	fffff097          	auipc	ra,0xfffff
    80003854:	792080e7          	jalr	1938(ra) # 80002fe2 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003858:	0809a583          	lw	a1,128(s3)
    8000385c:	0009a503          	lw	a0,0(s3)
    80003860:	00000097          	auipc	ra,0x0
    80003864:	898080e7          	jalr	-1896(ra) # 800030f8 <bfree>
    ip->addrs[NDIRECT] = 0;
    80003868:	0809a023          	sw	zero,128(s3)
    8000386c:	bf51                	j	80003800 <itrunc+0x3e>

000000008000386e <iput>:
{
    8000386e:	1101                	addi	sp,sp,-32
    80003870:	ec06                	sd	ra,24(sp)
    80003872:	e822                	sd	s0,16(sp)
    80003874:	e426                	sd	s1,8(sp)
    80003876:	e04a                	sd	s2,0(sp)
    80003878:	1000                	addi	s0,sp,32
    8000387a:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    8000387c:	0001c517          	auipc	a0,0x1c
    80003880:	14c50513          	addi	a0,a0,332 # 8001f9c8 <itable>
    80003884:	ffffd097          	auipc	ra,0xffffd
    80003888:	352080e7          	jalr	850(ra) # 80000bd6 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    8000388c:	4498                	lw	a4,8(s1)
    8000388e:	4785                	li	a5,1
    80003890:	02f70363          	beq	a4,a5,800038b6 <iput+0x48>
  ip->ref--;
    80003894:	449c                	lw	a5,8(s1)
    80003896:	37fd                	addiw	a5,a5,-1
    80003898:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    8000389a:	0001c517          	auipc	a0,0x1c
    8000389e:	12e50513          	addi	a0,a0,302 # 8001f9c8 <itable>
    800038a2:	ffffd097          	auipc	ra,0xffffd
    800038a6:	3e8080e7          	jalr	1000(ra) # 80000c8a <release>
}
    800038aa:	60e2                	ld	ra,24(sp)
    800038ac:	6442                	ld	s0,16(sp)
    800038ae:	64a2                	ld	s1,8(sp)
    800038b0:	6902                	ld	s2,0(sp)
    800038b2:	6105                	addi	sp,sp,32
    800038b4:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    800038b6:	40bc                	lw	a5,64(s1)
    800038b8:	dff1                	beqz	a5,80003894 <iput+0x26>
    800038ba:	04a49783          	lh	a5,74(s1)
    800038be:	fbf9                	bnez	a5,80003894 <iput+0x26>
    acquiresleep(&ip->lock);
    800038c0:	01048913          	addi	s2,s1,16
    800038c4:	854a                	mv	a0,s2
    800038c6:	00001097          	auipc	ra,0x1
    800038ca:	ab8080e7          	jalr	-1352(ra) # 8000437e <acquiresleep>
    release(&itable.lock);
    800038ce:	0001c517          	auipc	a0,0x1c
    800038d2:	0fa50513          	addi	a0,a0,250 # 8001f9c8 <itable>
    800038d6:	ffffd097          	auipc	ra,0xffffd
    800038da:	3b4080e7          	jalr	948(ra) # 80000c8a <release>
    itrunc(ip);
    800038de:	8526                	mv	a0,s1
    800038e0:	00000097          	auipc	ra,0x0
    800038e4:	ee2080e7          	jalr	-286(ra) # 800037c2 <itrunc>
    ip->type = 0;
    800038e8:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    800038ec:	8526                	mv	a0,s1
    800038ee:	00000097          	auipc	ra,0x0
    800038f2:	cfc080e7          	jalr	-772(ra) # 800035ea <iupdate>
    ip->valid = 0;
    800038f6:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    800038fa:	854a                	mv	a0,s2
    800038fc:	00001097          	auipc	ra,0x1
    80003900:	ad8080e7          	jalr	-1320(ra) # 800043d4 <releasesleep>
    acquire(&itable.lock);
    80003904:	0001c517          	auipc	a0,0x1c
    80003908:	0c450513          	addi	a0,a0,196 # 8001f9c8 <itable>
    8000390c:	ffffd097          	auipc	ra,0xffffd
    80003910:	2ca080e7          	jalr	714(ra) # 80000bd6 <acquire>
    80003914:	b741                	j	80003894 <iput+0x26>

0000000080003916 <iunlockput>:
{
    80003916:	1101                	addi	sp,sp,-32
    80003918:	ec06                	sd	ra,24(sp)
    8000391a:	e822                	sd	s0,16(sp)
    8000391c:	e426                	sd	s1,8(sp)
    8000391e:	1000                	addi	s0,sp,32
    80003920:	84aa                	mv	s1,a0
  iunlock(ip);
    80003922:	00000097          	auipc	ra,0x0
    80003926:	e54080e7          	jalr	-428(ra) # 80003776 <iunlock>
  iput(ip);
    8000392a:	8526                	mv	a0,s1
    8000392c:	00000097          	auipc	ra,0x0
    80003930:	f42080e7          	jalr	-190(ra) # 8000386e <iput>
}
    80003934:	60e2                	ld	ra,24(sp)
    80003936:	6442                	ld	s0,16(sp)
    80003938:	64a2                	ld	s1,8(sp)
    8000393a:	6105                	addi	sp,sp,32
    8000393c:	8082                	ret

000000008000393e <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    8000393e:	1141                	addi	sp,sp,-16
    80003940:	e422                	sd	s0,8(sp)
    80003942:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003944:	411c                	lw	a5,0(a0)
    80003946:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003948:	415c                	lw	a5,4(a0)
    8000394a:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    8000394c:	04451783          	lh	a5,68(a0)
    80003950:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003954:	04a51783          	lh	a5,74(a0)
    80003958:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    8000395c:	04c56783          	lwu	a5,76(a0)
    80003960:	e99c                	sd	a5,16(a1)
}
    80003962:	6422                	ld	s0,8(sp)
    80003964:	0141                	addi	sp,sp,16
    80003966:	8082                	ret

0000000080003968 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003968:	457c                	lw	a5,76(a0)
    8000396a:	0ed7e963          	bltu	a5,a3,80003a5c <readi+0xf4>
{
    8000396e:	7159                	addi	sp,sp,-112
    80003970:	f486                	sd	ra,104(sp)
    80003972:	f0a2                	sd	s0,96(sp)
    80003974:	eca6                	sd	s1,88(sp)
    80003976:	e8ca                	sd	s2,80(sp)
    80003978:	e4ce                	sd	s3,72(sp)
    8000397a:	e0d2                	sd	s4,64(sp)
    8000397c:	fc56                	sd	s5,56(sp)
    8000397e:	f85a                	sd	s6,48(sp)
    80003980:	f45e                	sd	s7,40(sp)
    80003982:	f062                	sd	s8,32(sp)
    80003984:	ec66                	sd	s9,24(sp)
    80003986:	e86a                	sd	s10,16(sp)
    80003988:	e46e                	sd	s11,8(sp)
    8000398a:	1880                	addi	s0,sp,112
    8000398c:	8baa                	mv	s7,a0
    8000398e:	8c2e                	mv	s8,a1
    80003990:	8ab2                	mv	s5,a2
    80003992:	84b6                	mv	s1,a3
    80003994:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003996:	9f35                	addw	a4,a4,a3
    return 0;
    80003998:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    8000399a:	0ad76063          	bltu	a4,a3,80003a3a <readi+0xd2>
  if(off + n > ip->size)
    8000399e:	00e7f463          	bgeu	a5,a4,800039a6 <readi+0x3e>
    n = ip->size - off;
    800039a2:	40d78b3b          	subw	s6,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800039a6:	0a0b0963          	beqz	s6,80003a58 <readi+0xf0>
    800039aa:	4981                	li	s3,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    800039ac:	40000d13          	li	s10,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    800039b0:	5cfd                	li	s9,-1
    800039b2:	a82d                	j	800039ec <readi+0x84>
    800039b4:	020a1d93          	slli	s11,s4,0x20
    800039b8:	020ddd93          	srli	s11,s11,0x20
    800039bc:	05890613          	addi	a2,s2,88
    800039c0:	86ee                	mv	a3,s11
    800039c2:	963a                	add	a2,a2,a4
    800039c4:	85d6                	mv	a1,s5
    800039c6:	8562                	mv	a0,s8
    800039c8:	fffff097          	auipc	ra,0xfffff
    800039cc:	a32080e7          	jalr	-1486(ra) # 800023fa <either_copyout>
    800039d0:	05950d63          	beq	a0,s9,80003a2a <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    800039d4:	854a                	mv	a0,s2
    800039d6:	fffff097          	auipc	ra,0xfffff
    800039da:	60c080e7          	jalr	1548(ra) # 80002fe2 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800039de:	013a09bb          	addw	s3,s4,s3
    800039e2:	009a04bb          	addw	s1,s4,s1
    800039e6:	9aee                	add	s5,s5,s11
    800039e8:	0569f763          	bgeu	s3,s6,80003a36 <readi+0xce>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    800039ec:	000ba903          	lw	s2,0(s7)
    800039f0:	00a4d59b          	srliw	a1,s1,0xa
    800039f4:	855e                	mv	a0,s7
    800039f6:	00000097          	auipc	ra,0x0
    800039fa:	8b0080e7          	jalr	-1872(ra) # 800032a6 <bmap>
    800039fe:	0005059b          	sext.w	a1,a0
    80003a02:	854a                	mv	a0,s2
    80003a04:	fffff097          	auipc	ra,0xfffff
    80003a08:	4ae080e7          	jalr	1198(ra) # 80002eb2 <bread>
    80003a0c:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003a0e:	3ff4f713          	andi	a4,s1,1023
    80003a12:	40ed07bb          	subw	a5,s10,a4
    80003a16:	413b06bb          	subw	a3,s6,s3
    80003a1a:	8a3e                	mv	s4,a5
    80003a1c:	2781                	sext.w	a5,a5
    80003a1e:	0006861b          	sext.w	a2,a3
    80003a22:	f8f679e3          	bgeu	a2,a5,800039b4 <readi+0x4c>
    80003a26:	8a36                	mv	s4,a3
    80003a28:	b771                	j	800039b4 <readi+0x4c>
      brelse(bp);
    80003a2a:	854a                	mv	a0,s2
    80003a2c:	fffff097          	auipc	ra,0xfffff
    80003a30:	5b6080e7          	jalr	1462(ra) # 80002fe2 <brelse>
      tot = -1;
    80003a34:	59fd                	li	s3,-1
  }
  return tot;
    80003a36:	0009851b          	sext.w	a0,s3
}
    80003a3a:	70a6                	ld	ra,104(sp)
    80003a3c:	7406                	ld	s0,96(sp)
    80003a3e:	64e6                	ld	s1,88(sp)
    80003a40:	6946                	ld	s2,80(sp)
    80003a42:	69a6                	ld	s3,72(sp)
    80003a44:	6a06                	ld	s4,64(sp)
    80003a46:	7ae2                	ld	s5,56(sp)
    80003a48:	7b42                	ld	s6,48(sp)
    80003a4a:	7ba2                	ld	s7,40(sp)
    80003a4c:	7c02                	ld	s8,32(sp)
    80003a4e:	6ce2                	ld	s9,24(sp)
    80003a50:	6d42                	ld	s10,16(sp)
    80003a52:	6da2                	ld	s11,8(sp)
    80003a54:	6165                	addi	sp,sp,112
    80003a56:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003a58:	89da                	mv	s3,s6
    80003a5a:	bff1                	j	80003a36 <readi+0xce>
    return 0;
    80003a5c:	4501                	li	a0,0
}
    80003a5e:	8082                	ret

0000000080003a60 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003a60:	457c                	lw	a5,76(a0)
    80003a62:	10d7e863          	bltu	a5,a3,80003b72 <writei+0x112>
{
    80003a66:	7159                	addi	sp,sp,-112
    80003a68:	f486                	sd	ra,104(sp)
    80003a6a:	f0a2                	sd	s0,96(sp)
    80003a6c:	eca6                	sd	s1,88(sp)
    80003a6e:	e8ca                	sd	s2,80(sp)
    80003a70:	e4ce                	sd	s3,72(sp)
    80003a72:	e0d2                	sd	s4,64(sp)
    80003a74:	fc56                	sd	s5,56(sp)
    80003a76:	f85a                	sd	s6,48(sp)
    80003a78:	f45e                	sd	s7,40(sp)
    80003a7a:	f062                	sd	s8,32(sp)
    80003a7c:	ec66                	sd	s9,24(sp)
    80003a7e:	e86a                	sd	s10,16(sp)
    80003a80:	e46e                	sd	s11,8(sp)
    80003a82:	1880                	addi	s0,sp,112
    80003a84:	8b2a                	mv	s6,a0
    80003a86:	8c2e                	mv	s8,a1
    80003a88:	8ab2                	mv	s5,a2
    80003a8a:	8936                	mv	s2,a3
    80003a8c:	8bba                	mv	s7,a4
  if(off > ip->size || off + n < off)
    80003a8e:	00e687bb          	addw	a5,a3,a4
    80003a92:	0ed7e263          	bltu	a5,a3,80003b76 <writei+0x116>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003a96:	00043737          	lui	a4,0x43
    80003a9a:	0ef76063          	bltu	a4,a5,80003b7a <writei+0x11a>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003a9e:	0c0b8863          	beqz	s7,80003b6e <writei+0x10e>
    80003aa2:	4a01                	li	s4,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80003aa4:	40000d13          	li	s10,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003aa8:	5cfd                	li	s9,-1
    80003aaa:	a091                	j	80003aee <writei+0x8e>
    80003aac:	02099d93          	slli	s11,s3,0x20
    80003ab0:	020ddd93          	srli	s11,s11,0x20
    80003ab4:	05848513          	addi	a0,s1,88
    80003ab8:	86ee                	mv	a3,s11
    80003aba:	8656                	mv	a2,s5
    80003abc:	85e2                	mv	a1,s8
    80003abe:	953a                	add	a0,a0,a4
    80003ac0:	fffff097          	auipc	ra,0xfffff
    80003ac4:	990080e7          	jalr	-1648(ra) # 80002450 <either_copyin>
    80003ac8:	07950263          	beq	a0,s9,80003b2c <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003acc:	8526                	mv	a0,s1
    80003ace:	00000097          	auipc	ra,0x0
    80003ad2:	790080e7          	jalr	1936(ra) # 8000425e <log_write>
    brelse(bp);
    80003ad6:	8526                	mv	a0,s1
    80003ad8:	fffff097          	auipc	ra,0xfffff
    80003adc:	50a080e7          	jalr	1290(ra) # 80002fe2 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003ae0:	01498a3b          	addw	s4,s3,s4
    80003ae4:	0129893b          	addw	s2,s3,s2
    80003ae8:	9aee                	add	s5,s5,s11
    80003aea:	057a7663          	bgeu	s4,s7,80003b36 <writei+0xd6>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80003aee:	000b2483          	lw	s1,0(s6)
    80003af2:	00a9559b          	srliw	a1,s2,0xa
    80003af6:	855a                	mv	a0,s6
    80003af8:	fffff097          	auipc	ra,0xfffff
    80003afc:	7ae080e7          	jalr	1966(ra) # 800032a6 <bmap>
    80003b00:	0005059b          	sext.w	a1,a0
    80003b04:	8526                	mv	a0,s1
    80003b06:	fffff097          	auipc	ra,0xfffff
    80003b0a:	3ac080e7          	jalr	940(ra) # 80002eb2 <bread>
    80003b0e:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003b10:	3ff97713          	andi	a4,s2,1023
    80003b14:	40ed07bb          	subw	a5,s10,a4
    80003b18:	414b86bb          	subw	a3,s7,s4
    80003b1c:	89be                	mv	s3,a5
    80003b1e:	2781                	sext.w	a5,a5
    80003b20:	0006861b          	sext.w	a2,a3
    80003b24:	f8f674e3          	bgeu	a2,a5,80003aac <writei+0x4c>
    80003b28:	89b6                	mv	s3,a3
    80003b2a:	b749                	j	80003aac <writei+0x4c>
      brelse(bp);
    80003b2c:	8526                	mv	a0,s1
    80003b2e:	fffff097          	auipc	ra,0xfffff
    80003b32:	4b4080e7          	jalr	1204(ra) # 80002fe2 <brelse>
  }

  if(off > ip->size)
    80003b36:	04cb2783          	lw	a5,76(s6)
    80003b3a:	0127f463          	bgeu	a5,s2,80003b42 <writei+0xe2>
    ip->size = off;
    80003b3e:	052b2623          	sw	s2,76(s6)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80003b42:	855a                	mv	a0,s6
    80003b44:	00000097          	auipc	ra,0x0
    80003b48:	aa6080e7          	jalr	-1370(ra) # 800035ea <iupdate>

  return tot;
    80003b4c:	000a051b          	sext.w	a0,s4
}
    80003b50:	70a6                	ld	ra,104(sp)
    80003b52:	7406                	ld	s0,96(sp)
    80003b54:	64e6                	ld	s1,88(sp)
    80003b56:	6946                	ld	s2,80(sp)
    80003b58:	69a6                	ld	s3,72(sp)
    80003b5a:	6a06                	ld	s4,64(sp)
    80003b5c:	7ae2                	ld	s5,56(sp)
    80003b5e:	7b42                	ld	s6,48(sp)
    80003b60:	7ba2                	ld	s7,40(sp)
    80003b62:	7c02                	ld	s8,32(sp)
    80003b64:	6ce2                	ld	s9,24(sp)
    80003b66:	6d42                	ld	s10,16(sp)
    80003b68:	6da2                	ld	s11,8(sp)
    80003b6a:	6165                	addi	sp,sp,112
    80003b6c:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003b6e:	8a5e                	mv	s4,s7
    80003b70:	bfc9                	j	80003b42 <writei+0xe2>
    return -1;
    80003b72:	557d                	li	a0,-1
}
    80003b74:	8082                	ret
    return -1;
    80003b76:	557d                	li	a0,-1
    80003b78:	bfe1                	j	80003b50 <writei+0xf0>
    return -1;
    80003b7a:	557d                	li	a0,-1
    80003b7c:	bfd1                	j	80003b50 <writei+0xf0>

0000000080003b7e <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003b7e:	1141                	addi	sp,sp,-16
    80003b80:	e406                	sd	ra,8(sp)
    80003b82:	e022                	sd	s0,0(sp)
    80003b84:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003b86:	4639                	li	a2,14
    80003b88:	ffffd097          	auipc	ra,0xffffd
    80003b8c:	226080e7          	jalr	550(ra) # 80000dae <strncmp>
}
    80003b90:	60a2                	ld	ra,8(sp)
    80003b92:	6402                	ld	s0,0(sp)
    80003b94:	0141                	addi	sp,sp,16
    80003b96:	8082                	ret

0000000080003b98 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003b98:	7139                	addi	sp,sp,-64
    80003b9a:	fc06                	sd	ra,56(sp)
    80003b9c:	f822                	sd	s0,48(sp)
    80003b9e:	f426                	sd	s1,40(sp)
    80003ba0:	f04a                	sd	s2,32(sp)
    80003ba2:	ec4e                	sd	s3,24(sp)
    80003ba4:	e852                	sd	s4,16(sp)
    80003ba6:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003ba8:	04451703          	lh	a4,68(a0)
    80003bac:	4785                	li	a5,1
    80003bae:	00f71a63          	bne	a4,a5,80003bc2 <dirlookup+0x2a>
    80003bb2:	892a                	mv	s2,a0
    80003bb4:	89ae                	mv	s3,a1
    80003bb6:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003bb8:	457c                	lw	a5,76(a0)
    80003bba:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003bbc:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003bbe:	e79d                	bnez	a5,80003bec <dirlookup+0x54>
    80003bc0:	a8a5                	j	80003c38 <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80003bc2:	00005517          	auipc	a0,0x5
    80003bc6:	a1650513          	addi	a0,a0,-1514 # 800085d8 <syscalls+0x1a8>
    80003bca:	ffffd097          	auipc	ra,0xffffd
    80003bce:	966080e7          	jalr	-1690(ra) # 80000530 <panic>
      panic("dirlookup read");
    80003bd2:	00005517          	auipc	a0,0x5
    80003bd6:	a1e50513          	addi	a0,a0,-1506 # 800085f0 <syscalls+0x1c0>
    80003bda:	ffffd097          	auipc	ra,0xffffd
    80003bde:	956080e7          	jalr	-1706(ra) # 80000530 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003be2:	24c1                	addiw	s1,s1,16
    80003be4:	04c92783          	lw	a5,76(s2)
    80003be8:	04f4f763          	bgeu	s1,a5,80003c36 <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003bec:	4741                	li	a4,16
    80003bee:	86a6                	mv	a3,s1
    80003bf0:	fc040613          	addi	a2,s0,-64
    80003bf4:	4581                	li	a1,0
    80003bf6:	854a                	mv	a0,s2
    80003bf8:	00000097          	auipc	ra,0x0
    80003bfc:	d70080e7          	jalr	-656(ra) # 80003968 <readi>
    80003c00:	47c1                	li	a5,16
    80003c02:	fcf518e3          	bne	a0,a5,80003bd2 <dirlookup+0x3a>
    if(de.inum == 0)
    80003c06:	fc045783          	lhu	a5,-64(s0)
    80003c0a:	dfe1                	beqz	a5,80003be2 <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    80003c0c:	fc240593          	addi	a1,s0,-62
    80003c10:	854e                	mv	a0,s3
    80003c12:	00000097          	auipc	ra,0x0
    80003c16:	f6c080e7          	jalr	-148(ra) # 80003b7e <namecmp>
    80003c1a:	f561                	bnez	a0,80003be2 <dirlookup+0x4a>
      if(poff)
    80003c1c:	000a0463          	beqz	s4,80003c24 <dirlookup+0x8c>
        *poff = off;
    80003c20:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80003c24:	fc045583          	lhu	a1,-64(s0)
    80003c28:	00092503          	lw	a0,0(s2)
    80003c2c:	fffff097          	auipc	ra,0xfffff
    80003c30:	754080e7          	jalr	1876(ra) # 80003380 <iget>
    80003c34:	a011                	j	80003c38 <dirlookup+0xa0>
  return 0;
    80003c36:	4501                	li	a0,0
}
    80003c38:	70e2                	ld	ra,56(sp)
    80003c3a:	7442                	ld	s0,48(sp)
    80003c3c:	74a2                	ld	s1,40(sp)
    80003c3e:	7902                	ld	s2,32(sp)
    80003c40:	69e2                	ld	s3,24(sp)
    80003c42:	6a42                	ld	s4,16(sp)
    80003c44:	6121                	addi	sp,sp,64
    80003c46:	8082                	ret

0000000080003c48 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003c48:	711d                	addi	sp,sp,-96
    80003c4a:	ec86                	sd	ra,88(sp)
    80003c4c:	e8a2                	sd	s0,80(sp)
    80003c4e:	e4a6                	sd	s1,72(sp)
    80003c50:	e0ca                	sd	s2,64(sp)
    80003c52:	fc4e                	sd	s3,56(sp)
    80003c54:	f852                	sd	s4,48(sp)
    80003c56:	f456                	sd	s5,40(sp)
    80003c58:	f05a                	sd	s6,32(sp)
    80003c5a:	ec5e                	sd	s7,24(sp)
    80003c5c:	e862                	sd	s8,16(sp)
    80003c5e:	e466                	sd	s9,8(sp)
    80003c60:	1080                	addi	s0,sp,96
    80003c62:	84aa                	mv	s1,a0
    80003c64:	8b2e                	mv	s6,a1
    80003c66:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003c68:	00054703          	lbu	a4,0(a0)
    80003c6c:	02f00793          	li	a5,47
    80003c70:	02f70363          	beq	a4,a5,80003c96 <namex+0x4e>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003c74:	ffffe097          	auipc	ra,0xffffe
    80003c78:	d20080e7          	jalr	-736(ra) # 80001994 <myproc>
    80003c7c:	15053503          	ld	a0,336(a0)
    80003c80:	00000097          	auipc	ra,0x0
    80003c84:	9f6080e7          	jalr	-1546(ra) # 80003676 <idup>
    80003c88:	89aa                	mv	s3,a0
  while(*path == '/')
    80003c8a:	02f00913          	li	s2,47
  len = path - s;
    80003c8e:	4b81                	li	s7,0
  if(len >= DIRSIZ)
    80003c90:	4cb5                	li	s9,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003c92:	4c05                	li	s8,1
    80003c94:	a865                	j	80003d4c <namex+0x104>
    ip = iget(ROOTDEV, ROOTINO);
    80003c96:	4585                	li	a1,1
    80003c98:	4505                	li	a0,1
    80003c9a:	fffff097          	auipc	ra,0xfffff
    80003c9e:	6e6080e7          	jalr	1766(ra) # 80003380 <iget>
    80003ca2:	89aa                	mv	s3,a0
    80003ca4:	b7dd                	j	80003c8a <namex+0x42>
      iunlockput(ip);
    80003ca6:	854e                	mv	a0,s3
    80003ca8:	00000097          	auipc	ra,0x0
    80003cac:	c6e080e7          	jalr	-914(ra) # 80003916 <iunlockput>
      return 0;
    80003cb0:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003cb2:	854e                	mv	a0,s3
    80003cb4:	60e6                	ld	ra,88(sp)
    80003cb6:	6446                	ld	s0,80(sp)
    80003cb8:	64a6                	ld	s1,72(sp)
    80003cba:	6906                	ld	s2,64(sp)
    80003cbc:	79e2                	ld	s3,56(sp)
    80003cbe:	7a42                	ld	s4,48(sp)
    80003cc0:	7aa2                	ld	s5,40(sp)
    80003cc2:	7b02                	ld	s6,32(sp)
    80003cc4:	6be2                	ld	s7,24(sp)
    80003cc6:	6c42                	ld	s8,16(sp)
    80003cc8:	6ca2                	ld	s9,8(sp)
    80003cca:	6125                	addi	sp,sp,96
    80003ccc:	8082                	ret
      iunlock(ip);
    80003cce:	854e                	mv	a0,s3
    80003cd0:	00000097          	auipc	ra,0x0
    80003cd4:	aa6080e7          	jalr	-1370(ra) # 80003776 <iunlock>
      return ip;
    80003cd8:	bfe9                	j	80003cb2 <namex+0x6a>
      iunlockput(ip);
    80003cda:	854e                	mv	a0,s3
    80003cdc:	00000097          	auipc	ra,0x0
    80003ce0:	c3a080e7          	jalr	-966(ra) # 80003916 <iunlockput>
      return 0;
    80003ce4:	89d2                	mv	s3,s4
    80003ce6:	b7f1                	j	80003cb2 <namex+0x6a>
  len = path - s;
    80003ce8:	40b48633          	sub	a2,s1,a1
    80003cec:	00060a1b          	sext.w	s4,a2
  if(len >= DIRSIZ)
    80003cf0:	094cd463          	bge	s9,s4,80003d78 <namex+0x130>
    memmove(name, s, DIRSIZ);
    80003cf4:	4639                	li	a2,14
    80003cf6:	8556                	mv	a0,s5
    80003cf8:	ffffd097          	auipc	ra,0xffffd
    80003cfc:	03a080e7          	jalr	58(ra) # 80000d32 <memmove>
  while(*path == '/')
    80003d00:	0004c783          	lbu	a5,0(s1)
    80003d04:	01279763          	bne	a5,s2,80003d12 <namex+0xca>
    path++;
    80003d08:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003d0a:	0004c783          	lbu	a5,0(s1)
    80003d0e:	ff278de3          	beq	a5,s2,80003d08 <namex+0xc0>
    ilock(ip);
    80003d12:	854e                	mv	a0,s3
    80003d14:	00000097          	auipc	ra,0x0
    80003d18:	9a0080e7          	jalr	-1632(ra) # 800036b4 <ilock>
    if(ip->type != T_DIR){
    80003d1c:	04499783          	lh	a5,68(s3)
    80003d20:	f98793e3          	bne	a5,s8,80003ca6 <namex+0x5e>
    if(nameiparent && *path == '\0'){
    80003d24:	000b0563          	beqz	s6,80003d2e <namex+0xe6>
    80003d28:	0004c783          	lbu	a5,0(s1)
    80003d2c:	d3cd                	beqz	a5,80003cce <namex+0x86>
    if((next = dirlookup(ip, name, 0)) == 0){
    80003d2e:	865e                	mv	a2,s7
    80003d30:	85d6                	mv	a1,s5
    80003d32:	854e                	mv	a0,s3
    80003d34:	00000097          	auipc	ra,0x0
    80003d38:	e64080e7          	jalr	-412(ra) # 80003b98 <dirlookup>
    80003d3c:	8a2a                	mv	s4,a0
    80003d3e:	dd51                	beqz	a0,80003cda <namex+0x92>
    iunlockput(ip);
    80003d40:	854e                	mv	a0,s3
    80003d42:	00000097          	auipc	ra,0x0
    80003d46:	bd4080e7          	jalr	-1068(ra) # 80003916 <iunlockput>
    ip = next;
    80003d4a:	89d2                	mv	s3,s4
  while(*path == '/')
    80003d4c:	0004c783          	lbu	a5,0(s1)
    80003d50:	05279763          	bne	a5,s2,80003d9e <namex+0x156>
    path++;
    80003d54:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003d56:	0004c783          	lbu	a5,0(s1)
    80003d5a:	ff278de3          	beq	a5,s2,80003d54 <namex+0x10c>
  if(*path == 0)
    80003d5e:	c79d                	beqz	a5,80003d8c <namex+0x144>
    path++;
    80003d60:	85a6                	mv	a1,s1
  len = path - s;
    80003d62:	8a5e                	mv	s4,s7
    80003d64:	865e                	mv	a2,s7
  while(*path != '/' && *path != 0)
    80003d66:	01278963          	beq	a5,s2,80003d78 <namex+0x130>
    80003d6a:	dfbd                	beqz	a5,80003ce8 <namex+0xa0>
    path++;
    80003d6c:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    80003d6e:	0004c783          	lbu	a5,0(s1)
    80003d72:	ff279ce3          	bne	a5,s2,80003d6a <namex+0x122>
    80003d76:	bf8d                	j	80003ce8 <namex+0xa0>
    memmove(name, s, len);
    80003d78:	2601                	sext.w	a2,a2
    80003d7a:	8556                	mv	a0,s5
    80003d7c:	ffffd097          	auipc	ra,0xffffd
    80003d80:	fb6080e7          	jalr	-74(ra) # 80000d32 <memmove>
    name[len] = 0;
    80003d84:	9a56                	add	s4,s4,s5
    80003d86:	000a0023          	sb	zero,0(s4)
    80003d8a:	bf9d                	j	80003d00 <namex+0xb8>
  if(nameiparent){
    80003d8c:	f20b03e3          	beqz	s6,80003cb2 <namex+0x6a>
    iput(ip);
    80003d90:	854e                	mv	a0,s3
    80003d92:	00000097          	auipc	ra,0x0
    80003d96:	adc080e7          	jalr	-1316(ra) # 8000386e <iput>
    return 0;
    80003d9a:	4981                	li	s3,0
    80003d9c:	bf19                	j	80003cb2 <namex+0x6a>
  if(*path == 0)
    80003d9e:	d7fd                	beqz	a5,80003d8c <namex+0x144>
  while(*path != '/' && *path != 0)
    80003da0:	0004c783          	lbu	a5,0(s1)
    80003da4:	85a6                	mv	a1,s1
    80003da6:	b7d1                	j	80003d6a <namex+0x122>

0000000080003da8 <dirlink>:
{
    80003da8:	7139                	addi	sp,sp,-64
    80003daa:	fc06                	sd	ra,56(sp)
    80003dac:	f822                	sd	s0,48(sp)
    80003dae:	f426                	sd	s1,40(sp)
    80003db0:	f04a                	sd	s2,32(sp)
    80003db2:	ec4e                	sd	s3,24(sp)
    80003db4:	e852                	sd	s4,16(sp)
    80003db6:	0080                	addi	s0,sp,64
    80003db8:	892a                	mv	s2,a0
    80003dba:	8a2e                	mv	s4,a1
    80003dbc:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80003dbe:	4601                	li	a2,0
    80003dc0:	00000097          	auipc	ra,0x0
    80003dc4:	dd8080e7          	jalr	-552(ra) # 80003b98 <dirlookup>
    80003dc8:	e93d                	bnez	a0,80003e3e <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003dca:	04c92483          	lw	s1,76(s2)
    80003dce:	c49d                	beqz	s1,80003dfc <dirlink+0x54>
    80003dd0:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003dd2:	4741                	li	a4,16
    80003dd4:	86a6                	mv	a3,s1
    80003dd6:	fc040613          	addi	a2,s0,-64
    80003dda:	4581                	li	a1,0
    80003ddc:	854a                	mv	a0,s2
    80003dde:	00000097          	auipc	ra,0x0
    80003de2:	b8a080e7          	jalr	-1142(ra) # 80003968 <readi>
    80003de6:	47c1                	li	a5,16
    80003de8:	06f51163          	bne	a0,a5,80003e4a <dirlink+0xa2>
    if(de.inum == 0)
    80003dec:	fc045783          	lhu	a5,-64(s0)
    80003df0:	c791                	beqz	a5,80003dfc <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003df2:	24c1                	addiw	s1,s1,16
    80003df4:	04c92783          	lw	a5,76(s2)
    80003df8:	fcf4ede3          	bltu	s1,a5,80003dd2 <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    80003dfc:	4639                	li	a2,14
    80003dfe:	85d2                	mv	a1,s4
    80003e00:	fc240513          	addi	a0,s0,-62
    80003e04:	ffffd097          	auipc	ra,0xffffd
    80003e08:	fe6080e7          	jalr	-26(ra) # 80000dea <strncpy>
  de.inum = inum;
    80003e0c:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003e10:	4741                	li	a4,16
    80003e12:	86a6                	mv	a3,s1
    80003e14:	fc040613          	addi	a2,s0,-64
    80003e18:	4581                	li	a1,0
    80003e1a:	854a                	mv	a0,s2
    80003e1c:	00000097          	auipc	ra,0x0
    80003e20:	c44080e7          	jalr	-956(ra) # 80003a60 <writei>
    80003e24:	872a                	mv	a4,a0
    80003e26:	47c1                	li	a5,16
  return 0;
    80003e28:	4501                	li	a0,0
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003e2a:	02f71863          	bne	a4,a5,80003e5a <dirlink+0xb2>
}
    80003e2e:	70e2                	ld	ra,56(sp)
    80003e30:	7442                	ld	s0,48(sp)
    80003e32:	74a2                	ld	s1,40(sp)
    80003e34:	7902                	ld	s2,32(sp)
    80003e36:	69e2                	ld	s3,24(sp)
    80003e38:	6a42                	ld	s4,16(sp)
    80003e3a:	6121                	addi	sp,sp,64
    80003e3c:	8082                	ret
    iput(ip);
    80003e3e:	00000097          	auipc	ra,0x0
    80003e42:	a30080e7          	jalr	-1488(ra) # 8000386e <iput>
    return -1;
    80003e46:	557d                	li	a0,-1
    80003e48:	b7dd                	j	80003e2e <dirlink+0x86>
      panic("dirlink read");
    80003e4a:	00004517          	auipc	a0,0x4
    80003e4e:	7b650513          	addi	a0,a0,1974 # 80008600 <syscalls+0x1d0>
    80003e52:	ffffc097          	auipc	ra,0xffffc
    80003e56:	6de080e7          	jalr	1758(ra) # 80000530 <panic>
    panic("dirlink");
    80003e5a:	00005517          	auipc	a0,0x5
    80003e5e:	8b650513          	addi	a0,a0,-1866 # 80008710 <syscalls+0x2e0>
    80003e62:	ffffc097          	auipc	ra,0xffffc
    80003e66:	6ce080e7          	jalr	1742(ra) # 80000530 <panic>

0000000080003e6a <namei>:

struct inode*
namei(char *path)
{
    80003e6a:	1101                	addi	sp,sp,-32
    80003e6c:	ec06                	sd	ra,24(sp)
    80003e6e:	e822                	sd	s0,16(sp)
    80003e70:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80003e72:	fe040613          	addi	a2,s0,-32
    80003e76:	4581                	li	a1,0
    80003e78:	00000097          	auipc	ra,0x0
    80003e7c:	dd0080e7          	jalr	-560(ra) # 80003c48 <namex>
}
    80003e80:	60e2                	ld	ra,24(sp)
    80003e82:	6442                	ld	s0,16(sp)
    80003e84:	6105                	addi	sp,sp,32
    80003e86:	8082                	ret

0000000080003e88 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80003e88:	1141                	addi	sp,sp,-16
    80003e8a:	e406                	sd	ra,8(sp)
    80003e8c:	e022                	sd	s0,0(sp)
    80003e8e:	0800                	addi	s0,sp,16
    80003e90:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80003e92:	4585                	li	a1,1
    80003e94:	00000097          	auipc	ra,0x0
    80003e98:	db4080e7          	jalr	-588(ra) # 80003c48 <namex>
}
    80003e9c:	60a2                	ld	ra,8(sp)
    80003e9e:	6402                	ld	s0,0(sp)
    80003ea0:	0141                	addi	sp,sp,16
    80003ea2:	8082                	ret

0000000080003ea4 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80003ea4:	1101                	addi	sp,sp,-32
    80003ea6:	ec06                	sd	ra,24(sp)
    80003ea8:	e822                	sd	s0,16(sp)
    80003eaa:	e426                	sd	s1,8(sp)
    80003eac:	e04a                	sd	s2,0(sp)
    80003eae:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80003eb0:	0001d917          	auipc	s2,0x1d
    80003eb4:	5c090913          	addi	s2,s2,1472 # 80021470 <log>
    80003eb8:	01892583          	lw	a1,24(s2)
    80003ebc:	02892503          	lw	a0,40(s2)
    80003ec0:	fffff097          	auipc	ra,0xfffff
    80003ec4:	ff2080e7          	jalr	-14(ra) # 80002eb2 <bread>
    80003ec8:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80003eca:	02c92683          	lw	a3,44(s2)
    80003ece:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80003ed0:	02d05763          	blez	a3,80003efe <write_head+0x5a>
    80003ed4:	0001d797          	auipc	a5,0x1d
    80003ed8:	5cc78793          	addi	a5,a5,1484 # 800214a0 <log+0x30>
    80003edc:	05c50713          	addi	a4,a0,92
    80003ee0:	36fd                	addiw	a3,a3,-1
    80003ee2:	1682                	slli	a3,a3,0x20
    80003ee4:	9281                	srli	a3,a3,0x20
    80003ee6:	068a                	slli	a3,a3,0x2
    80003ee8:	0001d617          	auipc	a2,0x1d
    80003eec:	5bc60613          	addi	a2,a2,1468 # 800214a4 <log+0x34>
    80003ef0:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    80003ef2:	4390                	lw	a2,0(a5)
    80003ef4:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80003ef6:	0791                	addi	a5,a5,4
    80003ef8:	0711                	addi	a4,a4,4
    80003efa:	fed79ce3          	bne	a5,a3,80003ef2 <write_head+0x4e>
  }
  bwrite(buf);
    80003efe:	8526                	mv	a0,s1
    80003f00:	fffff097          	auipc	ra,0xfffff
    80003f04:	0a4080e7          	jalr	164(ra) # 80002fa4 <bwrite>
  brelse(buf);
    80003f08:	8526                	mv	a0,s1
    80003f0a:	fffff097          	auipc	ra,0xfffff
    80003f0e:	0d8080e7          	jalr	216(ra) # 80002fe2 <brelse>
}
    80003f12:	60e2                	ld	ra,24(sp)
    80003f14:	6442                	ld	s0,16(sp)
    80003f16:	64a2                	ld	s1,8(sp)
    80003f18:	6902                	ld	s2,0(sp)
    80003f1a:	6105                	addi	sp,sp,32
    80003f1c:	8082                	ret

0000000080003f1e <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80003f1e:	0001d797          	auipc	a5,0x1d
    80003f22:	57e7a783          	lw	a5,1406(a5) # 8002149c <log+0x2c>
    80003f26:	0af05d63          	blez	a5,80003fe0 <install_trans+0xc2>
{
    80003f2a:	7139                	addi	sp,sp,-64
    80003f2c:	fc06                	sd	ra,56(sp)
    80003f2e:	f822                	sd	s0,48(sp)
    80003f30:	f426                	sd	s1,40(sp)
    80003f32:	f04a                	sd	s2,32(sp)
    80003f34:	ec4e                	sd	s3,24(sp)
    80003f36:	e852                	sd	s4,16(sp)
    80003f38:	e456                	sd	s5,8(sp)
    80003f3a:	e05a                	sd	s6,0(sp)
    80003f3c:	0080                	addi	s0,sp,64
    80003f3e:	8b2a                	mv	s6,a0
    80003f40:	0001da97          	auipc	s5,0x1d
    80003f44:	560a8a93          	addi	s5,s5,1376 # 800214a0 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003f48:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003f4a:	0001d997          	auipc	s3,0x1d
    80003f4e:	52698993          	addi	s3,s3,1318 # 80021470 <log>
    80003f52:	a035                	j	80003f7e <install_trans+0x60>
      bunpin(dbuf);
    80003f54:	8526                	mv	a0,s1
    80003f56:	fffff097          	auipc	ra,0xfffff
    80003f5a:	166080e7          	jalr	358(ra) # 800030bc <bunpin>
    brelse(lbuf);
    80003f5e:	854a                	mv	a0,s2
    80003f60:	fffff097          	auipc	ra,0xfffff
    80003f64:	082080e7          	jalr	130(ra) # 80002fe2 <brelse>
    brelse(dbuf);
    80003f68:	8526                	mv	a0,s1
    80003f6a:	fffff097          	auipc	ra,0xfffff
    80003f6e:	078080e7          	jalr	120(ra) # 80002fe2 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003f72:	2a05                	addiw	s4,s4,1
    80003f74:	0a91                	addi	s5,s5,4
    80003f76:	02c9a783          	lw	a5,44(s3)
    80003f7a:	04fa5963          	bge	s4,a5,80003fcc <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003f7e:	0189a583          	lw	a1,24(s3)
    80003f82:	014585bb          	addw	a1,a1,s4
    80003f86:	2585                	addiw	a1,a1,1
    80003f88:	0289a503          	lw	a0,40(s3)
    80003f8c:	fffff097          	auipc	ra,0xfffff
    80003f90:	f26080e7          	jalr	-218(ra) # 80002eb2 <bread>
    80003f94:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80003f96:	000aa583          	lw	a1,0(s5)
    80003f9a:	0289a503          	lw	a0,40(s3)
    80003f9e:	fffff097          	auipc	ra,0xfffff
    80003fa2:	f14080e7          	jalr	-236(ra) # 80002eb2 <bread>
    80003fa6:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80003fa8:	40000613          	li	a2,1024
    80003fac:	05890593          	addi	a1,s2,88
    80003fb0:	05850513          	addi	a0,a0,88
    80003fb4:	ffffd097          	auipc	ra,0xffffd
    80003fb8:	d7e080e7          	jalr	-642(ra) # 80000d32 <memmove>
    bwrite(dbuf);  // write dst to disk
    80003fbc:	8526                	mv	a0,s1
    80003fbe:	fffff097          	auipc	ra,0xfffff
    80003fc2:	fe6080e7          	jalr	-26(ra) # 80002fa4 <bwrite>
    if(recovering == 0)
    80003fc6:	f80b1ce3          	bnez	s6,80003f5e <install_trans+0x40>
    80003fca:	b769                	j	80003f54 <install_trans+0x36>
}
    80003fcc:	70e2                	ld	ra,56(sp)
    80003fce:	7442                	ld	s0,48(sp)
    80003fd0:	74a2                	ld	s1,40(sp)
    80003fd2:	7902                	ld	s2,32(sp)
    80003fd4:	69e2                	ld	s3,24(sp)
    80003fd6:	6a42                	ld	s4,16(sp)
    80003fd8:	6aa2                	ld	s5,8(sp)
    80003fda:	6b02                	ld	s6,0(sp)
    80003fdc:	6121                	addi	sp,sp,64
    80003fde:	8082                	ret
    80003fe0:	8082                	ret

0000000080003fe2 <initlog>:
{
    80003fe2:	7179                	addi	sp,sp,-48
    80003fe4:	f406                	sd	ra,40(sp)
    80003fe6:	f022                	sd	s0,32(sp)
    80003fe8:	ec26                	sd	s1,24(sp)
    80003fea:	e84a                	sd	s2,16(sp)
    80003fec:	e44e                	sd	s3,8(sp)
    80003fee:	1800                	addi	s0,sp,48
    80003ff0:	892a                	mv	s2,a0
    80003ff2:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80003ff4:	0001d497          	auipc	s1,0x1d
    80003ff8:	47c48493          	addi	s1,s1,1148 # 80021470 <log>
    80003ffc:	00004597          	auipc	a1,0x4
    80004000:	61458593          	addi	a1,a1,1556 # 80008610 <syscalls+0x1e0>
    80004004:	8526                	mv	a0,s1
    80004006:	ffffd097          	auipc	ra,0xffffd
    8000400a:	b40080e7          	jalr	-1216(ra) # 80000b46 <initlock>
  log.start = sb->logstart;
    8000400e:	0149a583          	lw	a1,20(s3)
    80004012:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    80004014:	0109a783          	lw	a5,16(s3)
    80004018:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    8000401a:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    8000401e:	854a                	mv	a0,s2
    80004020:	fffff097          	auipc	ra,0xfffff
    80004024:	e92080e7          	jalr	-366(ra) # 80002eb2 <bread>
  log.lh.n = lh->n;
    80004028:	4d3c                	lw	a5,88(a0)
    8000402a:	d4dc                	sw	a5,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    8000402c:	02f05563          	blez	a5,80004056 <initlog+0x74>
    80004030:	05c50713          	addi	a4,a0,92
    80004034:	0001d697          	auipc	a3,0x1d
    80004038:	46c68693          	addi	a3,a3,1132 # 800214a0 <log+0x30>
    8000403c:	37fd                	addiw	a5,a5,-1
    8000403e:	1782                	slli	a5,a5,0x20
    80004040:	9381                	srli	a5,a5,0x20
    80004042:	078a                	slli	a5,a5,0x2
    80004044:	06050613          	addi	a2,a0,96
    80004048:	97b2                	add	a5,a5,a2
    log.lh.block[i] = lh->block[i];
    8000404a:	4310                	lw	a2,0(a4)
    8000404c:	c290                	sw	a2,0(a3)
  for (i = 0; i < log.lh.n; i++) {
    8000404e:	0711                	addi	a4,a4,4
    80004050:	0691                	addi	a3,a3,4
    80004052:	fef71ce3          	bne	a4,a5,8000404a <initlog+0x68>
  brelse(buf);
    80004056:	fffff097          	auipc	ra,0xfffff
    8000405a:	f8c080e7          	jalr	-116(ra) # 80002fe2 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    8000405e:	4505                	li	a0,1
    80004060:	00000097          	auipc	ra,0x0
    80004064:	ebe080e7          	jalr	-322(ra) # 80003f1e <install_trans>
  log.lh.n = 0;
    80004068:	0001d797          	auipc	a5,0x1d
    8000406c:	4207aa23          	sw	zero,1076(a5) # 8002149c <log+0x2c>
  write_head(); // clear the log
    80004070:	00000097          	auipc	ra,0x0
    80004074:	e34080e7          	jalr	-460(ra) # 80003ea4 <write_head>
}
    80004078:	70a2                	ld	ra,40(sp)
    8000407a:	7402                	ld	s0,32(sp)
    8000407c:	64e2                	ld	s1,24(sp)
    8000407e:	6942                	ld	s2,16(sp)
    80004080:	69a2                	ld	s3,8(sp)
    80004082:	6145                	addi	sp,sp,48
    80004084:	8082                	ret

0000000080004086 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80004086:	1101                	addi	sp,sp,-32
    80004088:	ec06                	sd	ra,24(sp)
    8000408a:	e822                	sd	s0,16(sp)
    8000408c:	e426                	sd	s1,8(sp)
    8000408e:	e04a                	sd	s2,0(sp)
    80004090:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80004092:	0001d517          	auipc	a0,0x1d
    80004096:	3de50513          	addi	a0,a0,990 # 80021470 <log>
    8000409a:	ffffd097          	auipc	ra,0xffffd
    8000409e:	b3c080e7          	jalr	-1220(ra) # 80000bd6 <acquire>
  while(1){
    if(log.committing){
    800040a2:	0001d497          	auipc	s1,0x1d
    800040a6:	3ce48493          	addi	s1,s1,974 # 80021470 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    800040aa:	4979                	li	s2,30
    800040ac:	a039                	j	800040ba <begin_op+0x34>
      sleep(&log, &log.lock);
    800040ae:	85a6                	mv	a1,s1
    800040b0:	8526                	mv	a0,s1
    800040b2:	ffffe097          	auipc	ra,0xffffe
    800040b6:	fa4080e7          	jalr	-92(ra) # 80002056 <sleep>
    if(log.committing){
    800040ba:	50dc                	lw	a5,36(s1)
    800040bc:	fbed                	bnez	a5,800040ae <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    800040be:	509c                	lw	a5,32(s1)
    800040c0:	0017871b          	addiw	a4,a5,1
    800040c4:	0007069b          	sext.w	a3,a4
    800040c8:	0027179b          	slliw	a5,a4,0x2
    800040cc:	9fb9                	addw	a5,a5,a4
    800040ce:	0017979b          	slliw	a5,a5,0x1
    800040d2:	54d8                	lw	a4,44(s1)
    800040d4:	9fb9                	addw	a5,a5,a4
    800040d6:	00f95963          	bge	s2,a5,800040e8 <begin_op+0x62>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    800040da:	85a6                	mv	a1,s1
    800040dc:	8526                	mv	a0,s1
    800040de:	ffffe097          	auipc	ra,0xffffe
    800040e2:	f78080e7          	jalr	-136(ra) # 80002056 <sleep>
    800040e6:	bfd1                	j	800040ba <begin_op+0x34>
    } else {
      log.outstanding += 1;
    800040e8:	0001d517          	auipc	a0,0x1d
    800040ec:	38850513          	addi	a0,a0,904 # 80021470 <log>
    800040f0:	d114                	sw	a3,32(a0)
      release(&log.lock);
    800040f2:	ffffd097          	auipc	ra,0xffffd
    800040f6:	b98080e7          	jalr	-1128(ra) # 80000c8a <release>
      break;
    }
  }
}
    800040fa:	60e2                	ld	ra,24(sp)
    800040fc:	6442                	ld	s0,16(sp)
    800040fe:	64a2                	ld	s1,8(sp)
    80004100:	6902                	ld	s2,0(sp)
    80004102:	6105                	addi	sp,sp,32
    80004104:	8082                	ret

0000000080004106 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80004106:	7139                	addi	sp,sp,-64
    80004108:	fc06                	sd	ra,56(sp)
    8000410a:	f822                	sd	s0,48(sp)
    8000410c:	f426                	sd	s1,40(sp)
    8000410e:	f04a                	sd	s2,32(sp)
    80004110:	ec4e                	sd	s3,24(sp)
    80004112:	e852                	sd	s4,16(sp)
    80004114:	e456                	sd	s5,8(sp)
    80004116:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80004118:	0001d497          	auipc	s1,0x1d
    8000411c:	35848493          	addi	s1,s1,856 # 80021470 <log>
    80004120:	8526                	mv	a0,s1
    80004122:	ffffd097          	auipc	ra,0xffffd
    80004126:	ab4080e7          	jalr	-1356(ra) # 80000bd6 <acquire>
  log.outstanding -= 1;
    8000412a:	509c                	lw	a5,32(s1)
    8000412c:	37fd                	addiw	a5,a5,-1
    8000412e:	0007891b          	sext.w	s2,a5
    80004132:	d09c                	sw	a5,32(s1)
  if(log.committing)
    80004134:	50dc                	lw	a5,36(s1)
    80004136:	efb9                	bnez	a5,80004194 <end_op+0x8e>
    panic("log.committing");
  if(log.outstanding == 0){
    80004138:	06091663          	bnez	s2,800041a4 <end_op+0x9e>
    do_commit = 1;
    log.committing = 1;
    8000413c:	0001d497          	auipc	s1,0x1d
    80004140:	33448493          	addi	s1,s1,820 # 80021470 <log>
    80004144:	4785                	li	a5,1
    80004146:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80004148:	8526                	mv	a0,s1
    8000414a:	ffffd097          	auipc	ra,0xffffd
    8000414e:	b40080e7          	jalr	-1216(ra) # 80000c8a <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80004152:	54dc                	lw	a5,44(s1)
    80004154:	06f04763          	bgtz	a5,800041c2 <end_op+0xbc>
    acquire(&log.lock);
    80004158:	0001d497          	auipc	s1,0x1d
    8000415c:	31848493          	addi	s1,s1,792 # 80021470 <log>
    80004160:	8526                	mv	a0,s1
    80004162:	ffffd097          	auipc	ra,0xffffd
    80004166:	a74080e7          	jalr	-1420(ra) # 80000bd6 <acquire>
    log.committing = 0;
    8000416a:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    8000416e:	8526                	mv	a0,s1
    80004170:	ffffe097          	auipc	ra,0xffffe
    80004174:	072080e7          	jalr	114(ra) # 800021e2 <wakeup>
    release(&log.lock);
    80004178:	8526                	mv	a0,s1
    8000417a:	ffffd097          	auipc	ra,0xffffd
    8000417e:	b10080e7          	jalr	-1264(ra) # 80000c8a <release>
}
    80004182:	70e2                	ld	ra,56(sp)
    80004184:	7442                	ld	s0,48(sp)
    80004186:	74a2                	ld	s1,40(sp)
    80004188:	7902                	ld	s2,32(sp)
    8000418a:	69e2                	ld	s3,24(sp)
    8000418c:	6a42                	ld	s4,16(sp)
    8000418e:	6aa2                	ld	s5,8(sp)
    80004190:	6121                	addi	sp,sp,64
    80004192:	8082                	ret
    panic("log.committing");
    80004194:	00004517          	auipc	a0,0x4
    80004198:	48450513          	addi	a0,a0,1156 # 80008618 <syscalls+0x1e8>
    8000419c:	ffffc097          	auipc	ra,0xffffc
    800041a0:	394080e7          	jalr	916(ra) # 80000530 <panic>
    wakeup(&log);
    800041a4:	0001d497          	auipc	s1,0x1d
    800041a8:	2cc48493          	addi	s1,s1,716 # 80021470 <log>
    800041ac:	8526                	mv	a0,s1
    800041ae:	ffffe097          	auipc	ra,0xffffe
    800041b2:	034080e7          	jalr	52(ra) # 800021e2 <wakeup>
  release(&log.lock);
    800041b6:	8526                	mv	a0,s1
    800041b8:	ffffd097          	auipc	ra,0xffffd
    800041bc:	ad2080e7          	jalr	-1326(ra) # 80000c8a <release>
  if(do_commit){
    800041c0:	b7c9                	j	80004182 <end_op+0x7c>
  for (tail = 0; tail < log.lh.n; tail++) {
    800041c2:	0001da97          	auipc	s5,0x1d
    800041c6:	2dea8a93          	addi	s5,s5,734 # 800214a0 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    800041ca:	0001da17          	auipc	s4,0x1d
    800041ce:	2a6a0a13          	addi	s4,s4,678 # 80021470 <log>
    800041d2:	018a2583          	lw	a1,24(s4)
    800041d6:	012585bb          	addw	a1,a1,s2
    800041da:	2585                	addiw	a1,a1,1
    800041dc:	028a2503          	lw	a0,40(s4)
    800041e0:	fffff097          	auipc	ra,0xfffff
    800041e4:	cd2080e7          	jalr	-814(ra) # 80002eb2 <bread>
    800041e8:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    800041ea:	000aa583          	lw	a1,0(s5)
    800041ee:	028a2503          	lw	a0,40(s4)
    800041f2:	fffff097          	auipc	ra,0xfffff
    800041f6:	cc0080e7          	jalr	-832(ra) # 80002eb2 <bread>
    800041fa:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    800041fc:	40000613          	li	a2,1024
    80004200:	05850593          	addi	a1,a0,88
    80004204:	05848513          	addi	a0,s1,88
    80004208:	ffffd097          	auipc	ra,0xffffd
    8000420c:	b2a080e7          	jalr	-1238(ra) # 80000d32 <memmove>
    bwrite(to);  // write the log
    80004210:	8526                	mv	a0,s1
    80004212:	fffff097          	auipc	ra,0xfffff
    80004216:	d92080e7          	jalr	-622(ra) # 80002fa4 <bwrite>
    brelse(from);
    8000421a:	854e                	mv	a0,s3
    8000421c:	fffff097          	auipc	ra,0xfffff
    80004220:	dc6080e7          	jalr	-570(ra) # 80002fe2 <brelse>
    brelse(to);
    80004224:	8526                	mv	a0,s1
    80004226:	fffff097          	auipc	ra,0xfffff
    8000422a:	dbc080e7          	jalr	-580(ra) # 80002fe2 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000422e:	2905                	addiw	s2,s2,1
    80004230:	0a91                	addi	s5,s5,4
    80004232:	02ca2783          	lw	a5,44(s4)
    80004236:	f8f94ee3          	blt	s2,a5,800041d2 <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    8000423a:	00000097          	auipc	ra,0x0
    8000423e:	c6a080e7          	jalr	-918(ra) # 80003ea4 <write_head>
    install_trans(0); // Now install writes to home locations
    80004242:	4501                	li	a0,0
    80004244:	00000097          	auipc	ra,0x0
    80004248:	cda080e7          	jalr	-806(ra) # 80003f1e <install_trans>
    log.lh.n = 0;
    8000424c:	0001d797          	auipc	a5,0x1d
    80004250:	2407a823          	sw	zero,592(a5) # 8002149c <log+0x2c>
    write_head();    // Erase the transaction from the log
    80004254:	00000097          	auipc	ra,0x0
    80004258:	c50080e7          	jalr	-944(ra) # 80003ea4 <write_head>
    8000425c:	bdf5                	j	80004158 <end_op+0x52>

000000008000425e <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    8000425e:	1101                	addi	sp,sp,-32
    80004260:	ec06                	sd	ra,24(sp)
    80004262:	e822                	sd	s0,16(sp)
    80004264:	e426                	sd	s1,8(sp)
    80004266:	e04a                	sd	s2,0(sp)
    80004268:	1000                	addi	s0,sp,32
    8000426a:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    8000426c:	0001d917          	auipc	s2,0x1d
    80004270:	20490913          	addi	s2,s2,516 # 80021470 <log>
    80004274:	854a                	mv	a0,s2
    80004276:	ffffd097          	auipc	ra,0xffffd
    8000427a:	960080e7          	jalr	-1696(ra) # 80000bd6 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    8000427e:	02c92603          	lw	a2,44(s2)
    80004282:	47f5                	li	a5,29
    80004284:	06c7c563          	blt	a5,a2,800042ee <log_write+0x90>
    80004288:	0001d797          	auipc	a5,0x1d
    8000428c:	2047a783          	lw	a5,516(a5) # 8002148c <log+0x1c>
    80004290:	37fd                	addiw	a5,a5,-1
    80004292:	04f65e63          	bge	a2,a5,800042ee <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80004296:	0001d797          	auipc	a5,0x1d
    8000429a:	1fa7a783          	lw	a5,506(a5) # 80021490 <log+0x20>
    8000429e:	06f05063          	blez	a5,800042fe <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    800042a2:	4781                	li	a5,0
    800042a4:	06c05563          	blez	a2,8000430e <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
    800042a8:	44cc                	lw	a1,12(s1)
    800042aa:	0001d717          	auipc	a4,0x1d
    800042ae:	1f670713          	addi	a4,a4,502 # 800214a0 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    800042b2:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorbtion
    800042b4:	4314                	lw	a3,0(a4)
    800042b6:	04b68c63          	beq	a3,a1,8000430e <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    800042ba:	2785                	addiw	a5,a5,1
    800042bc:	0711                	addi	a4,a4,4
    800042be:	fef61be3          	bne	a2,a5,800042b4 <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    800042c2:	0621                	addi	a2,a2,8
    800042c4:	060a                	slli	a2,a2,0x2
    800042c6:	0001d797          	auipc	a5,0x1d
    800042ca:	1aa78793          	addi	a5,a5,426 # 80021470 <log>
    800042ce:	963e                	add	a2,a2,a5
    800042d0:	44dc                	lw	a5,12(s1)
    800042d2:	ca1c                	sw	a5,16(a2)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    800042d4:	8526                	mv	a0,s1
    800042d6:	fffff097          	auipc	ra,0xfffff
    800042da:	daa080e7          	jalr	-598(ra) # 80003080 <bpin>
    log.lh.n++;
    800042de:	0001d717          	auipc	a4,0x1d
    800042e2:	19270713          	addi	a4,a4,402 # 80021470 <log>
    800042e6:	575c                	lw	a5,44(a4)
    800042e8:	2785                	addiw	a5,a5,1
    800042ea:	d75c                	sw	a5,44(a4)
    800042ec:	a835                	j	80004328 <log_write+0xca>
    panic("too big a transaction");
    800042ee:	00004517          	auipc	a0,0x4
    800042f2:	33a50513          	addi	a0,a0,826 # 80008628 <syscalls+0x1f8>
    800042f6:	ffffc097          	auipc	ra,0xffffc
    800042fa:	23a080e7          	jalr	570(ra) # 80000530 <panic>
    panic("log_write outside of trans");
    800042fe:	00004517          	auipc	a0,0x4
    80004302:	34250513          	addi	a0,a0,834 # 80008640 <syscalls+0x210>
    80004306:	ffffc097          	auipc	ra,0xffffc
    8000430a:	22a080e7          	jalr	554(ra) # 80000530 <panic>
  log.lh.block[i] = b->blockno;
    8000430e:	00878713          	addi	a4,a5,8
    80004312:	00271693          	slli	a3,a4,0x2
    80004316:	0001d717          	auipc	a4,0x1d
    8000431a:	15a70713          	addi	a4,a4,346 # 80021470 <log>
    8000431e:	9736                	add	a4,a4,a3
    80004320:	44d4                	lw	a3,12(s1)
    80004322:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80004324:	faf608e3          	beq	a2,a5,800042d4 <log_write+0x76>
  }
  release(&log.lock);
    80004328:	0001d517          	auipc	a0,0x1d
    8000432c:	14850513          	addi	a0,a0,328 # 80021470 <log>
    80004330:	ffffd097          	auipc	ra,0xffffd
    80004334:	95a080e7          	jalr	-1702(ra) # 80000c8a <release>
}
    80004338:	60e2                	ld	ra,24(sp)
    8000433a:	6442                	ld	s0,16(sp)
    8000433c:	64a2                	ld	s1,8(sp)
    8000433e:	6902                	ld	s2,0(sp)
    80004340:	6105                	addi	sp,sp,32
    80004342:	8082                	ret

0000000080004344 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80004344:	1101                	addi	sp,sp,-32
    80004346:	ec06                	sd	ra,24(sp)
    80004348:	e822                	sd	s0,16(sp)
    8000434a:	e426                	sd	s1,8(sp)
    8000434c:	e04a                	sd	s2,0(sp)
    8000434e:	1000                	addi	s0,sp,32
    80004350:	84aa                	mv	s1,a0
    80004352:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80004354:	00004597          	auipc	a1,0x4
    80004358:	30c58593          	addi	a1,a1,780 # 80008660 <syscalls+0x230>
    8000435c:	0521                	addi	a0,a0,8
    8000435e:	ffffc097          	auipc	ra,0xffffc
    80004362:	7e8080e7          	jalr	2024(ra) # 80000b46 <initlock>
  lk->name = name;
    80004366:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    8000436a:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    8000436e:	0204a423          	sw	zero,40(s1)
}
    80004372:	60e2                	ld	ra,24(sp)
    80004374:	6442                	ld	s0,16(sp)
    80004376:	64a2                	ld	s1,8(sp)
    80004378:	6902                	ld	s2,0(sp)
    8000437a:	6105                	addi	sp,sp,32
    8000437c:	8082                	ret

000000008000437e <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    8000437e:	1101                	addi	sp,sp,-32
    80004380:	ec06                	sd	ra,24(sp)
    80004382:	e822                	sd	s0,16(sp)
    80004384:	e426                	sd	s1,8(sp)
    80004386:	e04a                	sd	s2,0(sp)
    80004388:	1000                	addi	s0,sp,32
    8000438a:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    8000438c:	00850913          	addi	s2,a0,8
    80004390:	854a                	mv	a0,s2
    80004392:	ffffd097          	auipc	ra,0xffffd
    80004396:	844080e7          	jalr	-1980(ra) # 80000bd6 <acquire>
  while (lk->locked) {
    8000439a:	409c                	lw	a5,0(s1)
    8000439c:	cb89                	beqz	a5,800043ae <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    8000439e:	85ca                	mv	a1,s2
    800043a0:	8526                	mv	a0,s1
    800043a2:	ffffe097          	auipc	ra,0xffffe
    800043a6:	cb4080e7          	jalr	-844(ra) # 80002056 <sleep>
  while (lk->locked) {
    800043aa:	409c                	lw	a5,0(s1)
    800043ac:	fbed                	bnez	a5,8000439e <acquiresleep+0x20>
  }
  lk->locked = 1;
    800043ae:	4785                	li	a5,1
    800043b0:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    800043b2:	ffffd097          	auipc	ra,0xffffd
    800043b6:	5e2080e7          	jalr	1506(ra) # 80001994 <myproc>
    800043ba:	591c                	lw	a5,48(a0)
    800043bc:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    800043be:	854a                	mv	a0,s2
    800043c0:	ffffd097          	auipc	ra,0xffffd
    800043c4:	8ca080e7          	jalr	-1846(ra) # 80000c8a <release>
}
    800043c8:	60e2                	ld	ra,24(sp)
    800043ca:	6442                	ld	s0,16(sp)
    800043cc:	64a2                	ld	s1,8(sp)
    800043ce:	6902                	ld	s2,0(sp)
    800043d0:	6105                	addi	sp,sp,32
    800043d2:	8082                	ret

00000000800043d4 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    800043d4:	1101                	addi	sp,sp,-32
    800043d6:	ec06                	sd	ra,24(sp)
    800043d8:	e822                	sd	s0,16(sp)
    800043da:	e426                	sd	s1,8(sp)
    800043dc:	e04a                	sd	s2,0(sp)
    800043de:	1000                	addi	s0,sp,32
    800043e0:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800043e2:	00850913          	addi	s2,a0,8
    800043e6:	854a                	mv	a0,s2
    800043e8:	ffffc097          	auipc	ra,0xffffc
    800043ec:	7ee080e7          	jalr	2030(ra) # 80000bd6 <acquire>
  lk->locked = 0;
    800043f0:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800043f4:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    800043f8:	8526                	mv	a0,s1
    800043fa:	ffffe097          	auipc	ra,0xffffe
    800043fe:	de8080e7          	jalr	-536(ra) # 800021e2 <wakeup>
  release(&lk->lk);
    80004402:	854a                	mv	a0,s2
    80004404:	ffffd097          	auipc	ra,0xffffd
    80004408:	886080e7          	jalr	-1914(ra) # 80000c8a <release>
}
    8000440c:	60e2                	ld	ra,24(sp)
    8000440e:	6442                	ld	s0,16(sp)
    80004410:	64a2                	ld	s1,8(sp)
    80004412:	6902                	ld	s2,0(sp)
    80004414:	6105                	addi	sp,sp,32
    80004416:	8082                	ret

0000000080004418 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80004418:	7179                	addi	sp,sp,-48
    8000441a:	f406                	sd	ra,40(sp)
    8000441c:	f022                	sd	s0,32(sp)
    8000441e:	ec26                	sd	s1,24(sp)
    80004420:	e84a                	sd	s2,16(sp)
    80004422:	e44e                	sd	s3,8(sp)
    80004424:	1800                	addi	s0,sp,48
    80004426:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80004428:	00850913          	addi	s2,a0,8
    8000442c:	854a                	mv	a0,s2
    8000442e:	ffffc097          	auipc	ra,0xffffc
    80004432:	7a8080e7          	jalr	1960(ra) # 80000bd6 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80004436:	409c                	lw	a5,0(s1)
    80004438:	ef99                	bnez	a5,80004456 <holdingsleep+0x3e>
    8000443a:	4481                	li	s1,0
  release(&lk->lk);
    8000443c:	854a                	mv	a0,s2
    8000443e:	ffffd097          	auipc	ra,0xffffd
    80004442:	84c080e7          	jalr	-1972(ra) # 80000c8a <release>
  return r;
}
    80004446:	8526                	mv	a0,s1
    80004448:	70a2                	ld	ra,40(sp)
    8000444a:	7402                	ld	s0,32(sp)
    8000444c:	64e2                	ld	s1,24(sp)
    8000444e:	6942                	ld	s2,16(sp)
    80004450:	69a2                	ld	s3,8(sp)
    80004452:	6145                	addi	sp,sp,48
    80004454:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    80004456:	0284a983          	lw	s3,40(s1)
    8000445a:	ffffd097          	auipc	ra,0xffffd
    8000445e:	53a080e7          	jalr	1338(ra) # 80001994 <myproc>
    80004462:	5904                	lw	s1,48(a0)
    80004464:	413484b3          	sub	s1,s1,s3
    80004468:	0014b493          	seqz	s1,s1
    8000446c:	bfc1                	j	8000443c <holdingsleep+0x24>

000000008000446e <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    8000446e:	1141                	addi	sp,sp,-16
    80004470:	e406                	sd	ra,8(sp)
    80004472:	e022                	sd	s0,0(sp)
    80004474:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80004476:	00004597          	auipc	a1,0x4
    8000447a:	1fa58593          	addi	a1,a1,506 # 80008670 <syscalls+0x240>
    8000447e:	0001d517          	auipc	a0,0x1d
    80004482:	13a50513          	addi	a0,a0,314 # 800215b8 <ftable>
    80004486:	ffffc097          	auipc	ra,0xffffc
    8000448a:	6c0080e7          	jalr	1728(ra) # 80000b46 <initlock>
}
    8000448e:	60a2                	ld	ra,8(sp)
    80004490:	6402                	ld	s0,0(sp)
    80004492:	0141                	addi	sp,sp,16
    80004494:	8082                	ret

0000000080004496 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80004496:	1101                	addi	sp,sp,-32
    80004498:	ec06                	sd	ra,24(sp)
    8000449a:	e822                	sd	s0,16(sp)
    8000449c:	e426                	sd	s1,8(sp)
    8000449e:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    800044a0:	0001d517          	auipc	a0,0x1d
    800044a4:	11850513          	addi	a0,a0,280 # 800215b8 <ftable>
    800044a8:	ffffc097          	auipc	ra,0xffffc
    800044ac:	72e080e7          	jalr	1838(ra) # 80000bd6 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800044b0:	0001d497          	auipc	s1,0x1d
    800044b4:	12048493          	addi	s1,s1,288 # 800215d0 <ftable+0x18>
    800044b8:	0001e717          	auipc	a4,0x1e
    800044bc:	0b870713          	addi	a4,a4,184 # 80022570 <ftable+0xfb8>
    if(f->ref == 0){
    800044c0:	40dc                	lw	a5,4(s1)
    800044c2:	cf99                	beqz	a5,800044e0 <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800044c4:	02848493          	addi	s1,s1,40
    800044c8:	fee49ce3          	bne	s1,a4,800044c0 <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    800044cc:	0001d517          	auipc	a0,0x1d
    800044d0:	0ec50513          	addi	a0,a0,236 # 800215b8 <ftable>
    800044d4:	ffffc097          	auipc	ra,0xffffc
    800044d8:	7b6080e7          	jalr	1974(ra) # 80000c8a <release>
  return 0;
    800044dc:	4481                	li	s1,0
    800044de:	a819                	j	800044f4 <filealloc+0x5e>
      f->ref = 1;
    800044e0:	4785                	li	a5,1
    800044e2:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    800044e4:	0001d517          	auipc	a0,0x1d
    800044e8:	0d450513          	addi	a0,a0,212 # 800215b8 <ftable>
    800044ec:	ffffc097          	auipc	ra,0xffffc
    800044f0:	79e080e7          	jalr	1950(ra) # 80000c8a <release>
}
    800044f4:	8526                	mv	a0,s1
    800044f6:	60e2                	ld	ra,24(sp)
    800044f8:	6442                	ld	s0,16(sp)
    800044fa:	64a2                	ld	s1,8(sp)
    800044fc:	6105                	addi	sp,sp,32
    800044fe:	8082                	ret

0000000080004500 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80004500:	1101                	addi	sp,sp,-32
    80004502:	ec06                	sd	ra,24(sp)
    80004504:	e822                	sd	s0,16(sp)
    80004506:	e426                	sd	s1,8(sp)
    80004508:	1000                	addi	s0,sp,32
    8000450a:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    8000450c:	0001d517          	auipc	a0,0x1d
    80004510:	0ac50513          	addi	a0,a0,172 # 800215b8 <ftable>
    80004514:	ffffc097          	auipc	ra,0xffffc
    80004518:	6c2080e7          	jalr	1730(ra) # 80000bd6 <acquire>
  if(f->ref < 1)
    8000451c:	40dc                	lw	a5,4(s1)
    8000451e:	02f05263          	blez	a5,80004542 <filedup+0x42>
    panic("filedup");
  f->ref++;
    80004522:	2785                	addiw	a5,a5,1
    80004524:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004526:	0001d517          	auipc	a0,0x1d
    8000452a:	09250513          	addi	a0,a0,146 # 800215b8 <ftable>
    8000452e:	ffffc097          	auipc	ra,0xffffc
    80004532:	75c080e7          	jalr	1884(ra) # 80000c8a <release>
  return f;
}
    80004536:	8526                	mv	a0,s1
    80004538:	60e2                	ld	ra,24(sp)
    8000453a:	6442                	ld	s0,16(sp)
    8000453c:	64a2                	ld	s1,8(sp)
    8000453e:	6105                	addi	sp,sp,32
    80004540:	8082                	ret
    panic("filedup");
    80004542:	00004517          	auipc	a0,0x4
    80004546:	13650513          	addi	a0,a0,310 # 80008678 <syscalls+0x248>
    8000454a:	ffffc097          	auipc	ra,0xffffc
    8000454e:	fe6080e7          	jalr	-26(ra) # 80000530 <panic>

0000000080004552 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80004552:	7139                	addi	sp,sp,-64
    80004554:	fc06                	sd	ra,56(sp)
    80004556:	f822                	sd	s0,48(sp)
    80004558:	f426                	sd	s1,40(sp)
    8000455a:	f04a                	sd	s2,32(sp)
    8000455c:	ec4e                	sd	s3,24(sp)
    8000455e:	e852                	sd	s4,16(sp)
    80004560:	e456                	sd	s5,8(sp)
    80004562:	0080                	addi	s0,sp,64
    80004564:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004566:	0001d517          	auipc	a0,0x1d
    8000456a:	05250513          	addi	a0,a0,82 # 800215b8 <ftable>
    8000456e:	ffffc097          	auipc	ra,0xffffc
    80004572:	668080e7          	jalr	1640(ra) # 80000bd6 <acquire>
  if(f->ref < 1)
    80004576:	40dc                	lw	a5,4(s1)
    80004578:	06f05163          	blez	a5,800045da <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    8000457c:	37fd                	addiw	a5,a5,-1
    8000457e:	0007871b          	sext.w	a4,a5
    80004582:	c0dc                	sw	a5,4(s1)
    80004584:	06e04363          	bgtz	a4,800045ea <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004588:	0004a903          	lw	s2,0(s1)
    8000458c:	0094ca83          	lbu	s5,9(s1)
    80004590:	0104ba03          	ld	s4,16(s1)
    80004594:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80004598:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    8000459c:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    800045a0:	0001d517          	auipc	a0,0x1d
    800045a4:	01850513          	addi	a0,a0,24 # 800215b8 <ftable>
    800045a8:	ffffc097          	auipc	ra,0xffffc
    800045ac:	6e2080e7          	jalr	1762(ra) # 80000c8a <release>

  if(ff.type == FD_PIPE){
    800045b0:	4785                	li	a5,1
    800045b2:	04f90d63          	beq	s2,a5,8000460c <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    800045b6:	3979                	addiw	s2,s2,-2
    800045b8:	4785                	li	a5,1
    800045ba:	0527e063          	bltu	a5,s2,800045fa <fileclose+0xa8>
    begin_op();
    800045be:	00000097          	auipc	ra,0x0
    800045c2:	ac8080e7          	jalr	-1336(ra) # 80004086 <begin_op>
    iput(ff.ip);
    800045c6:	854e                	mv	a0,s3
    800045c8:	fffff097          	auipc	ra,0xfffff
    800045cc:	2a6080e7          	jalr	678(ra) # 8000386e <iput>
    end_op();
    800045d0:	00000097          	auipc	ra,0x0
    800045d4:	b36080e7          	jalr	-1226(ra) # 80004106 <end_op>
    800045d8:	a00d                	j	800045fa <fileclose+0xa8>
    panic("fileclose");
    800045da:	00004517          	auipc	a0,0x4
    800045de:	0a650513          	addi	a0,a0,166 # 80008680 <syscalls+0x250>
    800045e2:	ffffc097          	auipc	ra,0xffffc
    800045e6:	f4e080e7          	jalr	-178(ra) # 80000530 <panic>
    release(&ftable.lock);
    800045ea:	0001d517          	auipc	a0,0x1d
    800045ee:	fce50513          	addi	a0,a0,-50 # 800215b8 <ftable>
    800045f2:	ffffc097          	auipc	ra,0xffffc
    800045f6:	698080e7          	jalr	1688(ra) # 80000c8a <release>
  }
}
    800045fa:	70e2                	ld	ra,56(sp)
    800045fc:	7442                	ld	s0,48(sp)
    800045fe:	74a2                	ld	s1,40(sp)
    80004600:	7902                	ld	s2,32(sp)
    80004602:	69e2                	ld	s3,24(sp)
    80004604:	6a42                	ld	s4,16(sp)
    80004606:	6aa2                	ld	s5,8(sp)
    80004608:	6121                	addi	sp,sp,64
    8000460a:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    8000460c:	85d6                	mv	a1,s5
    8000460e:	8552                	mv	a0,s4
    80004610:	00000097          	auipc	ra,0x0
    80004614:	34c080e7          	jalr	844(ra) # 8000495c <pipeclose>
    80004618:	b7cd                	j	800045fa <fileclose+0xa8>

000000008000461a <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    8000461a:	715d                	addi	sp,sp,-80
    8000461c:	e486                	sd	ra,72(sp)
    8000461e:	e0a2                	sd	s0,64(sp)
    80004620:	fc26                	sd	s1,56(sp)
    80004622:	f84a                	sd	s2,48(sp)
    80004624:	f44e                	sd	s3,40(sp)
    80004626:	0880                	addi	s0,sp,80
    80004628:	84aa                	mv	s1,a0
    8000462a:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    8000462c:	ffffd097          	auipc	ra,0xffffd
    80004630:	368080e7          	jalr	872(ra) # 80001994 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004634:	409c                	lw	a5,0(s1)
    80004636:	37f9                	addiw	a5,a5,-2
    80004638:	4705                	li	a4,1
    8000463a:	04f76763          	bltu	a4,a5,80004688 <filestat+0x6e>
    8000463e:	892a                	mv	s2,a0
    ilock(f->ip);
    80004640:	6c88                	ld	a0,24(s1)
    80004642:	fffff097          	auipc	ra,0xfffff
    80004646:	072080e7          	jalr	114(ra) # 800036b4 <ilock>
    stati(f->ip, &st);
    8000464a:	fb840593          	addi	a1,s0,-72
    8000464e:	6c88                	ld	a0,24(s1)
    80004650:	fffff097          	auipc	ra,0xfffff
    80004654:	2ee080e7          	jalr	750(ra) # 8000393e <stati>
    iunlock(f->ip);
    80004658:	6c88                	ld	a0,24(s1)
    8000465a:	fffff097          	auipc	ra,0xfffff
    8000465e:	11c080e7          	jalr	284(ra) # 80003776 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004662:	46e1                	li	a3,24
    80004664:	fb840613          	addi	a2,s0,-72
    80004668:	85ce                	mv	a1,s3
    8000466a:	05093503          	ld	a0,80(s2)
    8000466e:	ffffd097          	auipc	ra,0xffffd
    80004672:	fe8080e7          	jalr	-24(ra) # 80001656 <copyout>
    80004676:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    8000467a:	60a6                	ld	ra,72(sp)
    8000467c:	6406                	ld	s0,64(sp)
    8000467e:	74e2                	ld	s1,56(sp)
    80004680:	7942                	ld	s2,48(sp)
    80004682:	79a2                	ld	s3,40(sp)
    80004684:	6161                	addi	sp,sp,80
    80004686:	8082                	ret
  return -1;
    80004688:	557d                	li	a0,-1
    8000468a:	bfc5                	j	8000467a <filestat+0x60>

000000008000468c <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    8000468c:	7179                	addi	sp,sp,-48
    8000468e:	f406                	sd	ra,40(sp)
    80004690:	f022                	sd	s0,32(sp)
    80004692:	ec26                	sd	s1,24(sp)
    80004694:	e84a                	sd	s2,16(sp)
    80004696:	e44e                	sd	s3,8(sp)
    80004698:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    8000469a:	00854783          	lbu	a5,8(a0)
    8000469e:	c3d5                	beqz	a5,80004742 <fileread+0xb6>
    800046a0:	84aa                	mv	s1,a0
    800046a2:	89ae                	mv	s3,a1
    800046a4:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    800046a6:	411c                	lw	a5,0(a0)
    800046a8:	4705                	li	a4,1
    800046aa:	04e78963          	beq	a5,a4,800046fc <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800046ae:	470d                	li	a4,3
    800046b0:	04e78d63          	beq	a5,a4,8000470a <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    800046b4:	4709                	li	a4,2
    800046b6:	06e79e63          	bne	a5,a4,80004732 <fileread+0xa6>
    ilock(f->ip);
    800046ba:	6d08                	ld	a0,24(a0)
    800046bc:	fffff097          	auipc	ra,0xfffff
    800046c0:	ff8080e7          	jalr	-8(ra) # 800036b4 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    800046c4:	874a                	mv	a4,s2
    800046c6:	5094                	lw	a3,32(s1)
    800046c8:	864e                	mv	a2,s3
    800046ca:	4585                	li	a1,1
    800046cc:	6c88                	ld	a0,24(s1)
    800046ce:	fffff097          	auipc	ra,0xfffff
    800046d2:	29a080e7          	jalr	666(ra) # 80003968 <readi>
    800046d6:	892a                	mv	s2,a0
    800046d8:	00a05563          	blez	a0,800046e2 <fileread+0x56>
      f->off += r;
    800046dc:	509c                	lw	a5,32(s1)
    800046de:	9fa9                	addw	a5,a5,a0
    800046e0:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    800046e2:	6c88                	ld	a0,24(s1)
    800046e4:	fffff097          	auipc	ra,0xfffff
    800046e8:	092080e7          	jalr	146(ra) # 80003776 <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    800046ec:	854a                	mv	a0,s2
    800046ee:	70a2                	ld	ra,40(sp)
    800046f0:	7402                	ld	s0,32(sp)
    800046f2:	64e2                	ld	s1,24(sp)
    800046f4:	6942                	ld	s2,16(sp)
    800046f6:	69a2                	ld	s3,8(sp)
    800046f8:	6145                	addi	sp,sp,48
    800046fa:	8082                	ret
    r = piperead(f->pipe, addr, n);
    800046fc:	6908                	ld	a0,16(a0)
    800046fe:	00000097          	auipc	ra,0x0
    80004702:	3c8080e7          	jalr	968(ra) # 80004ac6 <piperead>
    80004706:	892a                	mv	s2,a0
    80004708:	b7d5                	j	800046ec <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    8000470a:	02451783          	lh	a5,36(a0)
    8000470e:	03079693          	slli	a3,a5,0x30
    80004712:	92c1                	srli	a3,a3,0x30
    80004714:	4725                	li	a4,9
    80004716:	02d76863          	bltu	a4,a3,80004746 <fileread+0xba>
    8000471a:	0792                	slli	a5,a5,0x4
    8000471c:	0001d717          	auipc	a4,0x1d
    80004720:	dfc70713          	addi	a4,a4,-516 # 80021518 <devsw>
    80004724:	97ba                	add	a5,a5,a4
    80004726:	639c                	ld	a5,0(a5)
    80004728:	c38d                	beqz	a5,8000474a <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    8000472a:	4505                	li	a0,1
    8000472c:	9782                	jalr	a5
    8000472e:	892a                	mv	s2,a0
    80004730:	bf75                	j	800046ec <fileread+0x60>
    panic("fileread");
    80004732:	00004517          	auipc	a0,0x4
    80004736:	f5e50513          	addi	a0,a0,-162 # 80008690 <syscalls+0x260>
    8000473a:	ffffc097          	auipc	ra,0xffffc
    8000473e:	df6080e7          	jalr	-522(ra) # 80000530 <panic>
    return -1;
    80004742:	597d                	li	s2,-1
    80004744:	b765                	j	800046ec <fileread+0x60>
      return -1;
    80004746:	597d                	li	s2,-1
    80004748:	b755                	j	800046ec <fileread+0x60>
    8000474a:	597d                	li	s2,-1
    8000474c:	b745                	j	800046ec <fileread+0x60>

000000008000474e <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    8000474e:	715d                	addi	sp,sp,-80
    80004750:	e486                	sd	ra,72(sp)
    80004752:	e0a2                	sd	s0,64(sp)
    80004754:	fc26                	sd	s1,56(sp)
    80004756:	f84a                	sd	s2,48(sp)
    80004758:	f44e                	sd	s3,40(sp)
    8000475a:	f052                	sd	s4,32(sp)
    8000475c:	ec56                	sd	s5,24(sp)
    8000475e:	e85a                	sd	s6,16(sp)
    80004760:	e45e                	sd	s7,8(sp)
    80004762:	e062                	sd	s8,0(sp)
    80004764:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    80004766:	00954783          	lbu	a5,9(a0)
    8000476a:	10078663          	beqz	a5,80004876 <filewrite+0x128>
    8000476e:	892a                	mv	s2,a0
    80004770:	8aae                	mv	s5,a1
    80004772:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80004774:	411c                	lw	a5,0(a0)
    80004776:	4705                	li	a4,1
    80004778:	02e78263          	beq	a5,a4,8000479c <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    8000477c:	470d                	li	a4,3
    8000477e:	02e78663          	beq	a5,a4,800047aa <filewrite+0x5c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80004782:	4709                	li	a4,2
    80004784:	0ee79163          	bne	a5,a4,80004866 <filewrite+0x118>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004788:	0ac05d63          	blez	a2,80004842 <filewrite+0xf4>
    int i = 0;
    8000478c:	4981                	li	s3,0
    8000478e:	6b05                	lui	s6,0x1
    80004790:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    80004794:	6b85                	lui	s7,0x1
    80004796:	c00b8b9b          	addiw	s7,s7,-1024
    8000479a:	a861                	j	80004832 <filewrite+0xe4>
    ret = pipewrite(f->pipe, addr, n);
    8000479c:	6908                	ld	a0,16(a0)
    8000479e:	00000097          	auipc	ra,0x0
    800047a2:	22e080e7          	jalr	558(ra) # 800049cc <pipewrite>
    800047a6:	8a2a                	mv	s4,a0
    800047a8:	a045                	j	80004848 <filewrite+0xfa>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    800047aa:	02451783          	lh	a5,36(a0)
    800047ae:	03079693          	slli	a3,a5,0x30
    800047b2:	92c1                	srli	a3,a3,0x30
    800047b4:	4725                	li	a4,9
    800047b6:	0cd76263          	bltu	a4,a3,8000487a <filewrite+0x12c>
    800047ba:	0792                	slli	a5,a5,0x4
    800047bc:	0001d717          	auipc	a4,0x1d
    800047c0:	d5c70713          	addi	a4,a4,-676 # 80021518 <devsw>
    800047c4:	97ba                	add	a5,a5,a4
    800047c6:	679c                	ld	a5,8(a5)
    800047c8:	cbdd                	beqz	a5,8000487e <filewrite+0x130>
    ret = devsw[f->major].write(1, addr, n);
    800047ca:	4505                	li	a0,1
    800047cc:	9782                	jalr	a5
    800047ce:	8a2a                	mv	s4,a0
    800047d0:	a8a5                	j	80004848 <filewrite+0xfa>
    800047d2:	00048c1b          	sext.w	s8,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    800047d6:	00000097          	auipc	ra,0x0
    800047da:	8b0080e7          	jalr	-1872(ra) # 80004086 <begin_op>
      ilock(f->ip);
    800047de:	01893503          	ld	a0,24(s2)
    800047e2:	fffff097          	auipc	ra,0xfffff
    800047e6:	ed2080e7          	jalr	-302(ra) # 800036b4 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    800047ea:	8762                	mv	a4,s8
    800047ec:	02092683          	lw	a3,32(s2)
    800047f0:	01598633          	add	a2,s3,s5
    800047f4:	4585                	li	a1,1
    800047f6:	01893503          	ld	a0,24(s2)
    800047fa:	fffff097          	auipc	ra,0xfffff
    800047fe:	266080e7          	jalr	614(ra) # 80003a60 <writei>
    80004802:	84aa                	mv	s1,a0
    80004804:	00a05763          	blez	a0,80004812 <filewrite+0xc4>
        f->off += r;
    80004808:	02092783          	lw	a5,32(s2)
    8000480c:	9fa9                	addw	a5,a5,a0
    8000480e:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004812:	01893503          	ld	a0,24(s2)
    80004816:	fffff097          	auipc	ra,0xfffff
    8000481a:	f60080e7          	jalr	-160(ra) # 80003776 <iunlock>
      end_op();
    8000481e:	00000097          	auipc	ra,0x0
    80004822:	8e8080e7          	jalr	-1816(ra) # 80004106 <end_op>

      if(r != n1){
    80004826:	009c1f63          	bne	s8,s1,80004844 <filewrite+0xf6>
        // error from writei
        break;
      }
      i += r;
    8000482a:	013489bb          	addw	s3,s1,s3
    while(i < n){
    8000482e:	0149db63          	bge	s3,s4,80004844 <filewrite+0xf6>
      int n1 = n - i;
    80004832:	413a07bb          	subw	a5,s4,s3
      if(n1 > max)
    80004836:	84be                	mv	s1,a5
    80004838:	2781                	sext.w	a5,a5
    8000483a:	f8fb5ce3          	bge	s6,a5,800047d2 <filewrite+0x84>
    8000483e:	84de                	mv	s1,s7
    80004840:	bf49                	j	800047d2 <filewrite+0x84>
    int i = 0;
    80004842:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    80004844:	013a1f63          	bne	s4,s3,80004862 <filewrite+0x114>
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004848:	8552                	mv	a0,s4
    8000484a:	60a6                	ld	ra,72(sp)
    8000484c:	6406                	ld	s0,64(sp)
    8000484e:	74e2                	ld	s1,56(sp)
    80004850:	7942                	ld	s2,48(sp)
    80004852:	79a2                	ld	s3,40(sp)
    80004854:	7a02                	ld	s4,32(sp)
    80004856:	6ae2                	ld	s5,24(sp)
    80004858:	6b42                	ld	s6,16(sp)
    8000485a:	6ba2                	ld	s7,8(sp)
    8000485c:	6c02                	ld	s8,0(sp)
    8000485e:	6161                	addi	sp,sp,80
    80004860:	8082                	ret
    ret = (i == n ? n : -1);
    80004862:	5a7d                	li	s4,-1
    80004864:	b7d5                	j	80004848 <filewrite+0xfa>
    panic("filewrite");
    80004866:	00004517          	auipc	a0,0x4
    8000486a:	e3a50513          	addi	a0,a0,-454 # 800086a0 <syscalls+0x270>
    8000486e:	ffffc097          	auipc	ra,0xffffc
    80004872:	cc2080e7          	jalr	-830(ra) # 80000530 <panic>
    return -1;
    80004876:	5a7d                	li	s4,-1
    80004878:	bfc1                	j	80004848 <filewrite+0xfa>
      return -1;
    8000487a:	5a7d                	li	s4,-1
    8000487c:	b7f1                	j	80004848 <filewrite+0xfa>
    8000487e:	5a7d                	li	s4,-1
    80004880:	b7e1                	j	80004848 <filewrite+0xfa>

0000000080004882 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004882:	7179                	addi	sp,sp,-48
    80004884:	f406                	sd	ra,40(sp)
    80004886:	f022                	sd	s0,32(sp)
    80004888:	ec26                	sd	s1,24(sp)
    8000488a:	e84a                	sd	s2,16(sp)
    8000488c:	e44e                	sd	s3,8(sp)
    8000488e:	e052                	sd	s4,0(sp)
    80004890:	1800                	addi	s0,sp,48
    80004892:	84aa                	mv	s1,a0
    80004894:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004896:	0005b023          	sd	zero,0(a1)
    8000489a:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    8000489e:	00000097          	auipc	ra,0x0
    800048a2:	bf8080e7          	jalr	-1032(ra) # 80004496 <filealloc>
    800048a6:	e088                	sd	a0,0(s1)
    800048a8:	c551                	beqz	a0,80004934 <pipealloc+0xb2>
    800048aa:	00000097          	auipc	ra,0x0
    800048ae:	bec080e7          	jalr	-1044(ra) # 80004496 <filealloc>
    800048b2:	00aa3023          	sd	a0,0(s4)
    800048b6:	c92d                	beqz	a0,80004928 <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    800048b8:	ffffc097          	auipc	ra,0xffffc
    800048bc:	22e080e7          	jalr	558(ra) # 80000ae6 <kalloc>
    800048c0:	892a                	mv	s2,a0
    800048c2:	c125                	beqz	a0,80004922 <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    800048c4:	4985                	li	s3,1
    800048c6:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    800048ca:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    800048ce:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    800048d2:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    800048d6:	00004597          	auipc	a1,0x4
    800048da:	dda58593          	addi	a1,a1,-550 # 800086b0 <syscalls+0x280>
    800048de:	ffffc097          	auipc	ra,0xffffc
    800048e2:	268080e7          	jalr	616(ra) # 80000b46 <initlock>
  (*f0)->type = FD_PIPE;
    800048e6:	609c                	ld	a5,0(s1)
    800048e8:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    800048ec:	609c                	ld	a5,0(s1)
    800048ee:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    800048f2:	609c                	ld	a5,0(s1)
    800048f4:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    800048f8:	609c                	ld	a5,0(s1)
    800048fa:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    800048fe:	000a3783          	ld	a5,0(s4)
    80004902:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004906:	000a3783          	ld	a5,0(s4)
    8000490a:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    8000490e:	000a3783          	ld	a5,0(s4)
    80004912:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004916:	000a3783          	ld	a5,0(s4)
    8000491a:	0127b823          	sd	s2,16(a5)
  return 0;
    8000491e:	4501                	li	a0,0
    80004920:	a025                	j	80004948 <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004922:	6088                	ld	a0,0(s1)
    80004924:	e501                	bnez	a0,8000492c <pipealloc+0xaa>
    80004926:	a039                	j	80004934 <pipealloc+0xb2>
    80004928:	6088                	ld	a0,0(s1)
    8000492a:	c51d                	beqz	a0,80004958 <pipealloc+0xd6>
    fileclose(*f0);
    8000492c:	00000097          	auipc	ra,0x0
    80004930:	c26080e7          	jalr	-986(ra) # 80004552 <fileclose>
  if(*f1)
    80004934:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004938:	557d                	li	a0,-1
  if(*f1)
    8000493a:	c799                	beqz	a5,80004948 <pipealloc+0xc6>
    fileclose(*f1);
    8000493c:	853e                	mv	a0,a5
    8000493e:	00000097          	auipc	ra,0x0
    80004942:	c14080e7          	jalr	-1004(ra) # 80004552 <fileclose>
  return -1;
    80004946:	557d                	li	a0,-1
}
    80004948:	70a2                	ld	ra,40(sp)
    8000494a:	7402                	ld	s0,32(sp)
    8000494c:	64e2                	ld	s1,24(sp)
    8000494e:	6942                	ld	s2,16(sp)
    80004950:	69a2                	ld	s3,8(sp)
    80004952:	6a02                	ld	s4,0(sp)
    80004954:	6145                	addi	sp,sp,48
    80004956:	8082                	ret
  return -1;
    80004958:	557d                	li	a0,-1
    8000495a:	b7fd                	j	80004948 <pipealloc+0xc6>

000000008000495c <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    8000495c:	1101                	addi	sp,sp,-32
    8000495e:	ec06                	sd	ra,24(sp)
    80004960:	e822                	sd	s0,16(sp)
    80004962:	e426                	sd	s1,8(sp)
    80004964:	e04a                	sd	s2,0(sp)
    80004966:	1000                	addi	s0,sp,32
    80004968:	84aa                	mv	s1,a0
    8000496a:	892e                	mv	s2,a1
  acquire(&pi->lock);
    8000496c:	ffffc097          	auipc	ra,0xffffc
    80004970:	26a080e7          	jalr	618(ra) # 80000bd6 <acquire>
  if(writable){
    80004974:	02090d63          	beqz	s2,800049ae <pipeclose+0x52>
    pi->writeopen = 0;
    80004978:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    8000497c:	21848513          	addi	a0,s1,536
    80004980:	ffffe097          	auipc	ra,0xffffe
    80004984:	862080e7          	jalr	-1950(ra) # 800021e2 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004988:	2204b783          	ld	a5,544(s1)
    8000498c:	eb95                	bnez	a5,800049c0 <pipeclose+0x64>
    release(&pi->lock);
    8000498e:	8526                	mv	a0,s1
    80004990:	ffffc097          	auipc	ra,0xffffc
    80004994:	2fa080e7          	jalr	762(ra) # 80000c8a <release>
    kfree((char*)pi);
    80004998:	8526                	mv	a0,s1
    8000499a:	ffffc097          	auipc	ra,0xffffc
    8000499e:	050080e7          	jalr	80(ra) # 800009ea <kfree>
  } else
    release(&pi->lock);
}
    800049a2:	60e2                	ld	ra,24(sp)
    800049a4:	6442                	ld	s0,16(sp)
    800049a6:	64a2                	ld	s1,8(sp)
    800049a8:	6902                	ld	s2,0(sp)
    800049aa:	6105                	addi	sp,sp,32
    800049ac:	8082                	ret
    pi->readopen = 0;
    800049ae:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    800049b2:	21c48513          	addi	a0,s1,540
    800049b6:	ffffe097          	auipc	ra,0xffffe
    800049ba:	82c080e7          	jalr	-2004(ra) # 800021e2 <wakeup>
    800049be:	b7e9                	j	80004988 <pipeclose+0x2c>
    release(&pi->lock);
    800049c0:	8526                	mv	a0,s1
    800049c2:	ffffc097          	auipc	ra,0xffffc
    800049c6:	2c8080e7          	jalr	712(ra) # 80000c8a <release>
}
    800049ca:	bfe1                	j	800049a2 <pipeclose+0x46>

00000000800049cc <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    800049cc:	7159                	addi	sp,sp,-112
    800049ce:	f486                	sd	ra,104(sp)
    800049d0:	f0a2                	sd	s0,96(sp)
    800049d2:	eca6                	sd	s1,88(sp)
    800049d4:	e8ca                	sd	s2,80(sp)
    800049d6:	e4ce                	sd	s3,72(sp)
    800049d8:	e0d2                	sd	s4,64(sp)
    800049da:	fc56                	sd	s5,56(sp)
    800049dc:	f85a                	sd	s6,48(sp)
    800049de:	f45e                	sd	s7,40(sp)
    800049e0:	f062                	sd	s8,32(sp)
    800049e2:	ec66                	sd	s9,24(sp)
    800049e4:	1880                	addi	s0,sp,112
    800049e6:	84aa                	mv	s1,a0
    800049e8:	8aae                	mv	s5,a1
    800049ea:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    800049ec:	ffffd097          	auipc	ra,0xffffd
    800049f0:	fa8080e7          	jalr	-88(ra) # 80001994 <myproc>
    800049f4:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    800049f6:	8526                	mv	a0,s1
    800049f8:	ffffc097          	auipc	ra,0xffffc
    800049fc:	1de080e7          	jalr	478(ra) # 80000bd6 <acquire>
  while(i < n){
    80004a00:	0d405163          	blez	s4,80004ac2 <pipewrite+0xf6>
    80004a04:	8ba6                	mv	s7,s1
  int i = 0;
    80004a06:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004a08:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80004a0a:	21848c93          	addi	s9,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004a0e:	21c48c13          	addi	s8,s1,540
    80004a12:	a08d                	j	80004a74 <pipewrite+0xa8>
      release(&pi->lock);
    80004a14:	8526                	mv	a0,s1
    80004a16:	ffffc097          	auipc	ra,0xffffc
    80004a1a:	274080e7          	jalr	628(ra) # 80000c8a <release>
      return -1;
    80004a1e:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80004a20:	854a                	mv	a0,s2
    80004a22:	70a6                	ld	ra,104(sp)
    80004a24:	7406                	ld	s0,96(sp)
    80004a26:	64e6                	ld	s1,88(sp)
    80004a28:	6946                	ld	s2,80(sp)
    80004a2a:	69a6                	ld	s3,72(sp)
    80004a2c:	6a06                	ld	s4,64(sp)
    80004a2e:	7ae2                	ld	s5,56(sp)
    80004a30:	7b42                	ld	s6,48(sp)
    80004a32:	7ba2                	ld	s7,40(sp)
    80004a34:	7c02                	ld	s8,32(sp)
    80004a36:	6ce2                	ld	s9,24(sp)
    80004a38:	6165                	addi	sp,sp,112
    80004a3a:	8082                	ret
      wakeup(&pi->nread);
    80004a3c:	8566                	mv	a0,s9
    80004a3e:	ffffd097          	auipc	ra,0xffffd
    80004a42:	7a4080e7          	jalr	1956(ra) # 800021e2 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004a46:	85de                	mv	a1,s7
    80004a48:	8562                	mv	a0,s8
    80004a4a:	ffffd097          	auipc	ra,0xffffd
    80004a4e:	60c080e7          	jalr	1548(ra) # 80002056 <sleep>
    80004a52:	a839                	j	80004a70 <pipewrite+0xa4>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004a54:	21c4a783          	lw	a5,540(s1)
    80004a58:	0017871b          	addiw	a4,a5,1
    80004a5c:	20e4ae23          	sw	a4,540(s1)
    80004a60:	1ff7f793          	andi	a5,a5,511
    80004a64:	97a6                	add	a5,a5,s1
    80004a66:	f9f44703          	lbu	a4,-97(s0)
    80004a6a:	00e78c23          	sb	a4,24(a5)
      i++;
    80004a6e:	2905                	addiw	s2,s2,1
  while(i < n){
    80004a70:	03495d63          	bge	s2,s4,80004aaa <pipewrite+0xde>
    if(pi->readopen == 0 || pr->killed){
    80004a74:	2204a783          	lw	a5,544(s1)
    80004a78:	dfd1                	beqz	a5,80004a14 <pipewrite+0x48>
    80004a7a:	0289a783          	lw	a5,40(s3)
    80004a7e:	fbd9                	bnez	a5,80004a14 <pipewrite+0x48>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80004a80:	2184a783          	lw	a5,536(s1)
    80004a84:	21c4a703          	lw	a4,540(s1)
    80004a88:	2007879b          	addiw	a5,a5,512
    80004a8c:	faf708e3          	beq	a4,a5,80004a3c <pipewrite+0x70>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004a90:	4685                	li	a3,1
    80004a92:	01590633          	add	a2,s2,s5
    80004a96:	f9f40593          	addi	a1,s0,-97
    80004a9a:	0509b503          	ld	a0,80(s3)
    80004a9e:	ffffd097          	auipc	ra,0xffffd
    80004aa2:	c44080e7          	jalr	-956(ra) # 800016e2 <copyin>
    80004aa6:	fb6517e3          	bne	a0,s6,80004a54 <pipewrite+0x88>
  wakeup(&pi->nread);
    80004aaa:	21848513          	addi	a0,s1,536
    80004aae:	ffffd097          	auipc	ra,0xffffd
    80004ab2:	734080e7          	jalr	1844(ra) # 800021e2 <wakeup>
  release(&pi->lock);
    80004ab6:	8526                	mv	a0,s1
    80004ab8:	ffffc097          	auipc	ra,0xffffc
    80004abc:	1d2080e7          	jalr	466(ra) # 80000c8a <release>
  return i;
    80004ac0:	b785                	j	80004a20 <pipewrite+0x54>
  int i = 0;
    80004ac2:	4901                	li	s2,0
    80004ac4:	b7dd                	j	80004aaa <pipewrite+0xde>

0000000080004ac6 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004ac6:	715d                	addi	sp,sp,-80
    80004ac8:	e486                	sd	ra,72(sp)
    80004aca:	e0a2                	sd	s0,64(sp)
    80004acc:	fc26                	sd	s1,56(sp)
    80004ace:	f84a                	sd	s2,48(sp)
    80004ad0:	f44e                	sd	s3,40(sp)
    80004ad2:	f052                	sd	s4,32(sp)
    80004ad4:	ec56                	sd	s5,24(sp)
    80004ad6:	e85a                	sd	s6,16(sp)
    80004ad8:	0880                	addi	s0,sp,80
    80004ada:	84aa                	mv	s1,a0
    80004adc:	892e                	mv	s2,a1
    80004ade:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004ae0:	ffffd097          	auipc	ra,0xffffd
    80004ae4:	eb4080e7          	jalr	-332(ra) # 80001994 <myproc>
    80004ae8:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004aea:	8b26                	mv	s6,s1
    80004aec:	8526                	mv	a0,s1
    80004aee:	ffffc097          	auipc	ra,0xffffc
    80004af2:	0e8080e7          	jalr	232(ra) # 80000bd6 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004af6:	2184a703          	lw	a4,536(s1)
    80004afa:	21c4a783          	lw	a5,540(s1)
    if(pr->killed){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004afe:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004b02:	02f71463          	bne	a4,a5,80004b2a <piperead+0x64>
    80004b06:	2244a783          	lw	a5,548(s1)
    80004b0a:	c385                	beqz	a5,80004b2a <piperead+0x64>
    if(pr->killed){
    80004b0c:	028a2783          	lw	a5,40(s4)
    80004b10:	ebc1                	bnez	a5,80004ba0 <piperead+0xda>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004b12:	85da                	mv	a1,s6
    80004b14:	854e                	mv	a0,s3
    80004b16:	ffffd097          	auipc	ra,0xffffd
    80004b1a:	540080e7          	jalr	1344(ra) # 80002056 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004b1e:	2184a703          	lw	a4,536(s1)
    80004b22:	21c4a783          	lw	a5,540(s1)
    80004b26:	fef700e3          	beq	a4,a5,80004b06 <piperead+0x40>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004b2a:	09505263          	blez	s5,80004bae <piperead+0xe8>
    80004b2e:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004b30:	5b7d                	li	s6,-1
    if(pi->nread == pi->nwrite)
    80004b32:	2184a783          	lw	a5,536(s1)
    80004b36:	21c4a703          	lw	a4,540(s1)
    80004b3a:	02f70d63          	beq	a4,a5,80004b74 <piperead+0xae>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80004b3e:	0017871b          	addiw	a4,a5,1
    80004b42:	20e4ac23          	sw	a4,536(s1)
    80004b46:	1ff7f793          	andi	a5,a5,511
    80004b4a:	97a6                	add	a5,a5,s1
    80004b4c:	0187c783          	lbu	a5,24(a5)
    80004b50:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004b54:	4685                	li	a3,1
    80004b56:	fbf40613          	addi	a2,s0,-65
    80004b5a:	85ca                	mv	a1,s2
    80004b5c:	050a3503          	ld	a0,80(s4)
    80004b60:	ffffd097          	auipc	ra,0xffffd
    80004b64:	af6080e7          	jalr	-1290(ra) # 80001656 <copyout>
    80004b68:	01650663          	beq	a0,s6,80004b74 <piperead+0xae>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004b6c:	2985                	addiw	s3,s3,1
    80004b6e:	0905                	addi	s2,s2,1
    80004b70:	fd3a91e3          	bne	s5,s3,80004b32 <piperead+0x6c>
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004b74:	21c48513          	addi	a0,s1,540
    80004b78:	ffffd097          	auipc	ra,0xffffd
    80004b7c:	66a080e7          	jalr	1642(ra) # 800021e2 <wakeup>
  release(&pi->lock);
    80004b80:	8526                	mv	a0,s1
    80004b82:	ffffc097          	auipc	ra,0xffffc
    80004b86:	108080e7          	jalr	264(ra) # 80000c8a <release>
  return i;
}
    80004b8a:	854e                	mv	a0,s3
    80004b8c:	60a6                	ld	ra,72(sp)
    80004b8e:	6406                	ld	s0,64(sp)
    80004b90:	74e2                	ld	s1,56(sp)
    80004b92:	7942                	ld	s2,48(sp)
    80004b94:	79a2                	ld	s3,40(sp)
    80004b96:	7a02                	ld	s4,32(sp)
    80004b98:	6ae2                	ld	s5,24(sp)
    80004b9a:	6b42                	ld	s6,16(sp)
    80004b9c:	6161                	addi	sp,sp,80
    80004b9e:	8082                	ret
      release(&pi->lock);
    80004ba0:	8526                	mv	a0,s1
    80004ba2:	ffffc097          	auipc	ra,0xffffc
    80004ba6:	0e8080e7          	jalr	232(ra) # 80000c8a <release>
      return -1;
    80004baa:	59fd                	li	s3,-1
    80004bac:	bff9                	j	80004b8a <piperead+0xc4>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004bae:	4981                	li	s3,0
    80004bb0:	b7d1                	j	80004b74 <piperead+0xae>

0000000080004bb2 <exec>:

static int loadseg(pde_t *pgdir, uint64 addr, struct inode *ip, uint offset, uint sz);

int
exec(char *path, char **argv)
{
    80004bb2:	df010113          	addi	sp,sp,-528
    80004bb6:	20113423          	sd	ra,520(sp)
    80004bba:	20813023          	sd	s0,512(sp)
    80004bbe:	ffa6                	sd	s1,504(sp)
    80004bc0:	fbca                	sd	s2,496(sp)
    80004bc2:	f7ce                	sd	s3,488(sp)
    80004bc4:	f3d2                	sd	s4,480(sp)
    80004bc6:	efd6                	sd	s5,472(sp)
    80004bc8:	ebda                	sd	s6,464(sp)
    80004bca:	e7de                	sd	s7,456(sp)
    80004bcc:	e3e2                	sd	s8,448(sp)
    80004bce:	ff66                	sd	s9,440(sp)
    80004bd0:	fb6a                	sd	s10,432(sp)
    80004bd2:	f76e                	sd	s11,424(sp)
    80004bd4:	0c00                	addi	s0,sp,528
    80004bd6:	84aa                	mv	s1,a0
    80004bd8:	dea43c23          	sd	a0,-520(s0)
    80004bdc:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004be0:	ffffd097          	auipc	ra,0xffffd
    80004be4:	db4080e7          	jalr	-588(ra) # 80001994 <myproc>
    80004be8:	892a                	mv	s2,a0

  begin_op();
    80004bea:	fffff097          	auipc	ra,0xfffff
    80004bee:	49c080e7          	jalr	1180(ra) # 80004086 <begin_op>

  if((ip = namei(path)) == 0){
    80004bf2:	8526                	mv	a0,s1
    80004bf4:	fffff097          	auipc	ra,0xfffff
    80004bf8:	276080e7          	jalr	630(ra) # 80003e6a <namei>
    80004bfc:	c92d                	beqz	a0,80004c6e <exec+0xbc>
    80004bfe:	84aa                	mv	s1,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80004c00:	fffff097          	auipc	ra,0xfffff
    80004c04:	ab4080e7          	jalr	-1356(ra) # 800036b4 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004c08:	04000713          	li	a4,64
    80004c0c:	4681                	li	a3,0
    80004c0e:	e4840613          	addi	a2,s0,-440
    80004c12:	4581                	li	a1,0
    80004c14:	8526                	mv	a0,s1
    80004c16:	fffff097          	auipc	ra,0xfffff
    80004c1a:	d52080e7          	jalr	-686(ra) # 80003968 <readi>
    80004c1e:	04000793          	li	a5,64
    80004c22:	00f51a63          	bne	a0,a5,80004c36 <exec+0x84>
    goto bad;
  if(elf.magic != ELF_MAGIC)
    80004c26:	e4842703          	lw	a4,-440(s0)
    80004c2a:	464c47b7          	lui	a5,0x464c4
    80004c2e:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004c32:	04f70463          	beq	a4,a5,80004c7a <exec+0xc8>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80004c36:	8526                	mv	a0,s1
    80004c38:	fffff097          	auipc	ra,0xfffff
    80004c3c:	cde080e7          	jalr	-802(ra) # 80003916 <iunlockput>
    end_op();
    80004c40:	fffff097          	auipc	ra,0xfffff
    80004c44:	4c6080e7          	jalr	1222(ra) # 80004106 <end_op>
  }
  return -1;
    80004c48:	557d                	li	a0,-1
}
    80004c4a:	20813083          	ld	ra,520(sp)
    80004c4e:	20013403          	ld	s0,512(sp)
    80004c52:	74fe                	ld	s1,504(sp)
    80004c54:	795e                	ld	s2,496(sp)
    80004c56:	79be                	ld	s3,488(sp)
    80004c58:	7a1e                	ld	s4,480(sp)
    80004c5a:	6afe                	ld	s5,472(sp)
    80004c5c:	6b5e                	ld	s6,464(sp)
    80004c5e:	6bbe                	ld	s7,456(sp)
    80004c60:	6c1e                	ld	s8,448(sp)
    80004c62:	7cfa                	ld	s9,440(sp)
    80004c64:	7d5a                	ld	s10,432(sp)
    80004c66:	7dba                	ld	s11,424(sp)
    80004c68:	21010113          	addi	sp,sp,528
    80004c6c:	8082                	ret
    end_op();
    80004c6e:	fffff097          	auipc	ra,0xfffff
    80004c72:	498080e7          	jalr	1176(ra) # 80004106 <end_op>
    return -1;
    80004c76:	557d                	li	a0,-1
    80004c78:	bfc9                	j	80004c4a <exec+0x98>
  if((pagetable = proc_pagetable(p)) == 0)
    80004c7a:	854a                	mv	a0,s2
    80004c7c:	ffffd097          	auipc	ra,0xffffd
    80004c80:	ddc080e7          	jalr	-548(ra) # 80001a58 <proc_pagetable>
    80004c84:	8baa                	mv	s7,a0
    80004c86:	d945                	beqz	a0,80004c36 <exec+0x84>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004c88:	e6842983          	lw	s3,-408(s0)
    80004c8c:	e8045783          	lhu	a5,-384(s0)
    80004c90:	c7ad                	beqz	a5,80004cfa <exec+0x148>
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
    80004c92:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004c94:	4b01                	li	s6,0
    if(ph.vaddr % PGSIZE != 0)
    80004c96:	6c85                	lui	s9,0x1
    80004c98:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    80004c9c:	def43823          	sd	a5,-528(s0)
    80004ca0:	a42d                	j	80004eca <exec+0x318>
    panic("loadseg: va must be page aligned");

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    80004ca2:	00004517          	auipc	a0,0x4
    80004ca6:	a1650513          	addi	a0,a0,-1514 # 800086b8 <syscalls+0x288>
    80004caa:	ffffc097          	auipc	ra,0xffffc
    80004cae:	886080e7          	jalr	-1914(ra) # 80000530 <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80004cb2:	8756                	mv	a4,s5
    80004cb4:	012d86bb          	addw	a3,s11,s2
    80004cb8:	4581                	li	a1,0
    80004cba:	8526                	mv	a0,s1
    80004cbc:	fffff097          	auipc	ra,0xfffff
    80004cc0:	cac080e7          	jalr	-852(ra) # 80003968 <readi>
    80004cc4:	2501                	sext.w	a0,a0
    80004cc6:	1aaa9963          	bne	s5,a0,80004e78 <exec+0x2c6>
  for(i = 0; i < sz; i += PGSIZE){
    80004cca:	6785                	lui	a5,0x1
    80004ccc:	0127893b          	addw	s2,a5,s2
    80004cd0:	77fd                	lui	a5,0xfffff
    80004cd2:	01478a3b          	addw	s4,a5,s4
    80004cd6:	1f897163          	bgeu	s2,s8,80004eb8 <exec+0x306>
    pa = walkaddr(pagetable, va + i);
    80004cda:	02091593          	slli	a1,s2,0x20
    80004cde:	9181                	srli	a1,a1,0x20
    80004ce0:	95ea                	add	a1,a1,s10
    80004ce2:	855e                	mv	a0,s7
    80004ce4:	ffffc097          	auipc	ra,0xffffc
    80004ce8:	380080e7          	jalr	896(ra) # 80001064 <walkaddr>
    80004cec:	862a                	mv	a2,a0
    if(pa == 0)
    80004cee:	d955                	beqz	a0,80004ca2 <exec+0xf0>
      n = PGSIZE;
    80004cf0:	8ae6                	mv	s5,s9
    if(sz - i < PGSIZE)
    80004cf2:	fd9a70e3          	bgeu	s4,s9,80004cb2 <exec+0x100>
      n = sz - i;
    80004cf6:	8ad2                	mv	s5,s4
    80004cf8:	bf6d                	j	80004cb2 <exec+0x100>
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
    80004cfa:	4901                	li	s2,0
  iunlockput(ip);
    80004cfc:	8526                	mv	a0,s1
    80004cfe:	fffff097          	auipc	ra,0xfffff
    80004d02:	c18080e7          	jalr	-1000(ra) # 80003916 <iunlockput>
  end_op();
    80004d06:	fffff097          	auipc	ra,0xfffff
    80004d0a:	400080e7          	jalr	1024(ra) # 80004106 <end_op>
  p = myproc();
    80004d0e:	ffffd097          	auipc	ra,0xffffd
    80004d12:	c86080e7          	jalr	-890(ra) # 80001994 <myproc>
    80004d16:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    80004d18:	04853d03          	ld	s10,72(a0)
  sz = PGROUNDUP(sz);
    80004d1c:	6785                	lui	a5,0x1
    80004d1e:	17fd                	addi	a5,a5,-1
    80004d20:	993e                	add	s2,s2,a5
    80004d22:	757d                	lui	a0,0xfffff
    80004d24:	00a977b3          	and	a5,s2,a0
    80004d28:	e0f43423          	sd	a5,-504(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    80004d2c:	6609                	lui	a2,0x2
    80004d2e:	963e                	add	a2,a2,a5
    80004d30:	85be                	mv	a1,a5
    80004d32:	855e                	mv	a0,s7
    80004d34:	ffffc097          	auipc	ra,0xffffc
    80004d38:	6d2080e7          	jalr	1746(ra) # 80001406 <uvmalloc>
    80004d3c:	8b2a                	mv	s6,a0
  ip = 0;
    80004d3e:	4481                	li	s1,0
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    80004d40:	12050c63          	beqz	a0,80004e78 <exec+0x2c6>
  uvmclear(pagetable, sz-2*PGSIZE);
    80004d44:	75f9                	lui	a1,0xffffe
    80004d46:	95aa                	add	a1,a1,a0
    80004d48:	855e                	mv	a0,s7
    80004d4a:	ffffd097          	auipc	ra,0xffffd
    80004d4e:	8da080e7          	jalr	-1830(ra) # 80001624 <uvmclear>
  stackbase = sp - PGSIZE;
    80004d52:	7c7d                	lui	s8,0xfffff
    80004d54:	9c5a                	add	s8,s8,s6
  for(argc = 0; argv[argc]; argc++) {
    80004d56:	e0043783          	ld	a5,-512(s0)
    80004d5a:	6388                	ld	a0,0(a5)
    80004d5c:	c535                	beqz	a0,80004dc8 <exec+0x216>
    80004d5e:	e8840993          	addi	s3,s0,-376
    80004d62:	f8840c93          	addi	s9,s0,-120
  sp = sz;
    80004d66:	895a                	mv	s2,s6
    sp -= strlen(argv[argc]) + 1;
    80004d68:	ffffc097          	auipc	ra,0xffffc
    80004d6c:	0f2080e7          	jalr	242(ra) # 80000e5a <strlen>
    80004d70:	2505                	addiw	a0,a0,1
    80004d72:	40a90933          	sub	s2,s2,a0
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80004d76:	ff097913          	andi	s2,s2,-16
    if(sp < stackbase)
    80004d7a:	13896363          	bltu	s2,s8,80004ea0 <exec+0x2ee>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80004d7e:	e0043d83          	ld	s11,-512(s0)
    80004d82:	000dba03          	ld	s4,0(s11)
    80004d86:	8552                	mv	a0,s4
    80004d88:	ffffc097          	auipc	ra,0xffffc
    80004d8c:	0d2080e7          	jalr	210(ra) # 80000e5a <strlen>
    80004d90:	0015069b          	addiw	a3,a0,1
    80004d94:	8652                	mv	a2,s4
    80004d96:	85ca                	mv	a1,s2
    80004d98:	855e                	mv	a0,s7
    80004d9a:	ffffd097          	auipc	ra,0xffffd
    80004d9e:	8bc080e7          	jalr	-1860(ra) # 80001656 <copyout>
    80004da2:	10054363          	bltz	a0,80004ea8 <exec+0x2f6>
    ustack[argc] = sp;
    80004da6:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80004daa:	0485                	addi	s1,s1,1
    80004dac:	008d8793          	addi	a5,s11,8
    80004db0:	e0f43023          	sd	a5,-512(s0)
    80004db4:	008db503          	ld	a0,8(s11)
    80004db8:	c911                	beqz	a0,80004dcc <exec+0x21a>
    if(argc >= MAXARG)
    80004dba:	09a1                	addi	s3,s3,8
    80004dbc:	fb3c96e3          	bne	s9,s3,80004d68 <exec+0x1b6>
  sz = sz1;
    80004dc0:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    80004dc4:	4481                	li	s1,0
    80004dc6:	a84d                	j	80004e78 <exec+0x2c6>
  sp = sz;
    80004dc8:	895a                	mv	s2,s6
  for(argc = 0; argv[argc]; argc++) {
    80004dca:	4481                	li	s1,0
  ustack[argc] = 0;
    80004dcc:	00349793          	slli	a5,s1,0x3
    80004dd0:	f9040713          	addi	a4,s0,-112
    80004dd4:	97ba                	add	a5,a5,a4
    80004dd6:	ee07bc23          	sd	zero,-264(a5) # ef8 <_entry-0x7ffff108>
  sp -= (argc+1) * sizeof(uint64);
    80004dda:	00148693          	addi	a3,s1,1
    80004dde:	068e                	slli	a3,a3,0x3
    80004de0:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80004de4:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    80004de8:	01897663          	bgeu	s2,s8,80004df4 <exec+0x242>
  sz = sz1;
    80004dec:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    80004df0:	4481                	li	s1,0
    80004df2:	a059                	j	80004e78 <exec+0x2c6>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80004df4:	e8840613          	addi	a2,s0,-376
    80004df8:	85ca                	mv	a1,s2
    80004dfa:	855e                	mv	a0,s7
    80004dfc:	ffffd097          	auipc	ra,0xffffd
    80004e00:	85a080e7          	jalr	-1958(ra) # 80001656 <copyout>
    80004e04:	0a054663          	bltz	a0,80004eb0 <exec+0x2fe>
  p->trapframe->a1 = sp;
    80004e08:	058ab783          	ld	a5,88(s5)
    80004e0c:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80004e10:	df843783          	ld	a5,-520(s0)
    80004e14:	0007c703          	lbu	a4,0(a5)
    80004e18:	cf11                	beqz	a4,80004e34 <exec+0x282>
    80004e1a:	0785                	addi	a5,a5,1
    if(*s == '/')
    80004e1c:	02f00693          	li	a3,47
    80004e20:	a029                	j	80004e2a <exec+0x278>
  for(last=s=path; *s; s++)
    80004e22:	0785                	addi	a5,a5,1
    80004e24:	fff7c703          	lbu	a4,-1(a5)
    80004e28:	c711                	beqz	a4,80004e34 <exec+0x282>
    if(*s == '/')
    80004e2a:	fed71ce3          	bne	a4,a3,80004e22 <exec+0x270>
      last = s+1;
    80004e2e:	def43c23          	sd	a5,-520(s0)
    80004e32:	bfc5                	j	80004e22 <exec+0x270>
  safestrcpy(p->name, last, sizeof(p->name));
    80004e34:	4641                	li	a2,16
    80004e36:	df843583          	ld	a1,-520(s0)
    80004e3a:	158a8513          	addi	a0,s5,344
    80004e3e:	ffffc097          	auipc	ra,0xffffc
    80004e42:	fea080e7          	jalr	-22(ra) # 80000e28 <safestrcpy>
  oldpagetable = p->pagetable;
    80004e46:	050ab503          	ld	a0,80(s5)
  p->pagetable = pagetable;
    80004e4a:	057ab823          	sd	s7,80(s5)
  p->sz = sz;
    80004e4e:	056ab423          	sd	s6,72(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    80004e52:	058ab783          	ld	a5,88(s5)
    80004e56:	e6043703          	ld	a4,-416(s0)
    80004e5a:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80004e5c:	058ab783          	ld	a5,88(s5)
    80004e60:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80004e64:	85ea                	mv	a1,s10
    80004e66:	ffffd097          	auipc	ra,0xffffd
    80004e6a:	c8e080e7          	jalr	-882(ra) # 80001af4 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80004e6e:	0004851b          	sext.w	a0,s1
    80004e72:	bbe1                	j	80004c4a <exec+0x98>
    80004e74:	e1243423          	sd	s2,-504(s0)
    proc_freepagetable(pagetable, sz);
    80004e78:	e0843583          	ld	a1,-504(s0)
    80004e7c:	855e                	mv	a0,s7
    80004e7e:	ffffd097          	auipc	ra,0xffffd
    80004e82:	c76080e7          	jalr	-906(ra) # 80001af4 <proc_freepagetable>
  if(ip){
    80004e86:	da0498e3          	bnez	s1,80004c36 <exec+0x84>
  return -1;
    80004e8a:	557d                	li	a0,-1
    80004e8c:	bb7d                	j	80004c4a <exec+0x98>
    80004e8e:	e1243423          	sd	s2,-504(s0)
    80004e92:	b7dd                	j	80004e78 <exec+0x2c6>
    80004e94:	e1243423          	sd	s2,-504(s0)
    80004e98:	b7c5                	j	80004e78 <exec+0x2c6>
    80004e9a:	e1243423          	sd	s2,-504(s0)
    80004e9e:	bfe9                	j	80004e78 <exec+0x2c6>
  sz = sz1;
    80004ea0:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    80004ea4:	4481                	li	s1,0
    80004ea6:	bfc9                	j	80004e78 <exec+0x2c6>
  sz = sz1;
    80004ea8:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    80004eac:	4481                	li	s1,0
    80004eae:	b7e9                	j	80004e78 <exec+0x2c6>
  sz = sz1;
    80004eb0:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    80004eb4:	4481                	li	s1,0
    80004eb6:	b7c9                	j	80004e78 <exec+0x2c6>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    80004eb8:	e0843903          	ld	s2,-504(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004ebc:	2b05                	addiw	s6,s6,1
    80004ebe:	0389899b          	addiw	s3,s3,56
    80004ec2:	e8045783          	lhu	a5,-384(s0)
    80004ec6:	e2fb5be3          	bge	s6,a5,80004cfc <exec+0x14a>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80004eca:	2981                	sext.w	s3,s3
    80004ecc:	03800713          	li	a4,56
    80004ed0:	86ce                	mv	a3,s3
    80004ed2:	e1040613          	addi	a2,s0,-496
    80004ed6:	4581                	li	a1,0
    80004ed8:	8526                	mv	a0,s1
    80004eda:	fffff097          	auipc	ra,0xfffff
    80004ede:	a8e080e7          	jalr	-1394(ra) # 80003968 <readi>
    80004ee2:	03800793          	li	a5,56
    80004ee6:	f8f517e3          	bne	a0,a5,80004e74 <exec+0x2c2>
    if(ph.type != ELF_PROG_LOAD)
    80004eea:	e1042783          	lw	a5,-496(s0)
    80004eee:	4705                	li	a4,1
    80004ef0:	fce796e3          	bne	a5,a4,80004ebc <exec+0x30a>
    if(ph.memsz < ph.filesz)
    80004ef4:	e3843603          	ld	a2,-456(s0)
    80004ef8:	e3043783          	ld	a5,-464(s0)
    80004efc:	f8f669e3          	bltu	a2,a5,80004e8e <exec+0x2dc>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80004f00:	e2043783          	ld	a5,-480(s0)
    80004f04:	963e                	add	a2,a2,a5
    80004f06:	f8f667e3          	bltu	a2,a5,80004e94 <exec+0x2e2>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    80004f0a:	85ca                	mv	a1,s2
    80004f0c:	855e                	mv	a0,s7
    80004f0e:	ffffc097          	auipc	ra,0xffffc
    80004f12:	4f8080e7          	jalr	1272(ra) # 80001406 <uvmalloc>
    80004f16:	e0a43423          	sd	a0,-504(s0)
    80004f1a:	d141                	beqz	a0,80004e9a <exec+0x2e8>
    if(ph.vaddr % PGSIZE != 0)
    80004f1c:	e2043d03          	ld	s10,-480(s0)
    80004f20:	df043783          	ld	a5,-528(s0)
    80004f24:	00fd77b3          	and	a5,s10,a5
    80004f28:	fba1                	bnez	a5,80004e78 <exec+0x2c6>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80004f2a:	e1842d83          	lw	s11,-488(s0)
    80004f2e:	e3042c03          	lw	s8,-464(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80004f32:	f80c03e3          	beqz	s8,80004eb8 <exec+0x306>
    80004f36:	8a62                	mv	s4,s8
    80004f38:	4901                	li	s2,0
    80004f3a:	b345                	j	80004cda <exec+0x128>

0000000080004f3c <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80004f3c:	7179                	addi	sp,sp,-48
    80004f3e:	f406                	sd	ra,40(sp)
    80004f40:	f022                	sd	s0,32(sp)
    80004f42:	ec26                	sd	s1,24(sp)
    80004f44:	e84a                	sd	s2,16(sp)
    80004f46:	1800                	addi	s0,sp,48
    80004f48:	892e                	mv	s2,a1
    80004f4a:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
    80004f4c:	fdc40593          	addi	a1,s0,-36
    80004f50:	ffffe097          	auipc	ra,0xffffe
    80004f54:	bc0080e7          	jalr	-1088(ra) # 80002b10 <argint>
    80004f58:	04054063          	bltz	a0,80004f98 <argfd+0x5c>
    return -1;
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80004f5c:	fdc42703          	lw	a4,-36(s0)
    80004f60:	47bd                	li	a5,15
    80004f62:	02e7ed63          	bltu	a5,a4,80004f9c <argfd+0x60>
    80004f66:	ffffd097          	auipc	ra,0xffffd
    80004f6a:	a2e080e7          	jalr	-1490(ra) # 80001994 <myproc>
    80004f6e:	fdc42703          	lw	a4,-36(s0)
    80004f72:	01a70793          	addi	a5,a4,26
    80004f76:	078e                	slli	a5,a5,0x3
    80004f78:	953e                	add	a0,a0,a5
    80004f7a:	611c                	ld	a5,0(a0)
    80004f7c:	c395                	beqz	a5,80004fa0 <argfd+0x64>
    return -1;
  if(pfd)
    80004f7e:	00090463          	beqz	s2,80004f86 <argfd+0x4a>
    *pfd = fd;
    80004f82:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80004f86:	4501                	li	a0,0
  if(pf)
    80004f88:	c091                	beqz	s1,80004f8c <argfd+0x50>
    *pf = f;
    80004f8a:	e09c                	sd	a5,0(s1)
}
    80004f8c:	70a2                	ld	ra,40(sp)
    80004f8e:	7402                	ld	s0,32(sp)
    80004f90:	64e2                	ld	s1,24(sp)
    80004f92:	6942                	ld	s2,16(sp)
    80004f94:	6145                	addi	sp,sp,48
    80004f96:	8082                	ret
    return -1;
    80004f98:	557d                	li	a0,-1
    80004f9a:	bfcd                	j	80004f8c <argfd+0x50>
    return -1;
    80004f9c:	557d                	li	a0,-1
    80004f9e:	b7fd                	j	80004f8c <argfd+0x50>
    80004fa0:	557d                	li	a0,-1
    80004fa2:	b7ed                	j	80004f8c <argfd+0x50>

0000000080004fa4 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80004fa4:	1101                	addi	sp,sp,-32
    80004fa6:	ec06                	sd	ra,24(sp)
    80004fa8:	e822                	sd	s0,16(sp)
    80004faa:	e426                	sd	s1,8(sp)
    80004fac:	1000                	addi	s0,sp,32
    80004fae:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80004fb0:	ffffd097          	auipc	ra,0xffffd
    80004fb4:	9e4080e7          	jalr	-1564(ra) # 80001994 <myproc>
    80004fb8:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80004fba:	0d050793          	addi	a5,a0,208 # fffffffffffff0d0 <end+0xffffffff7ffd90d0>
    80004fbe:	4501                	li	a0,0
    80004fc0:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80004fc2:	6398                	ld	a4,0(a5)
    80004fc4:	cb19                	beqz	a4,80004fda <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    80004fc6:	2505                	addiw	a0,a0,1
    80004fc8:	07a1                	addi	a5,a5,8
    80004fca:	fed51ce3          	bne	a0,a3,80004fc2 <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80004fce:	557d                	li	a0,-1
}
    80004fd0:	60e2                	ld	ra,24(sp)
    80004fd2:	6442                	ld	s0,16(sp)
    80004fd4:	64a2                	ld	s1,8(sp)
    80004fd6:	6105                	addi	sp,sp,32
    80004fd8:	8082                	ret
      p->ofile[fd] = f;
    80004fda:	01a50793          	addi	a5,a0,26
    80004fde:	078e                	slli	a5,a5,0x3
    80004fe0:	963e                	add	a2,a2,a5
    80004fe2:	e204                	sd	s1,0(a2)
      return fd;
    80004fe4:	b7f5                	j	80004fd0 <fdalloc+0x2c>

0000000080004fe6 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80004fe6:	715d                	addi	sp,sp,-80
    80004fe8:	e486                	sd	ra,72(sp)
    80004fea:	e0a2                	sd	s0,64(sp)
    80004fec:	fc26                	sd	s1,56(sp)
    80004fee:	f84a                	sd	s2,48(sp)
    80004ff0:	f44e                	sd	s3,40(sp)
    80004ff2:	f052                	sd	s4,32(sp)
    80004ff4:	ec56                	sd	s5,24(sp)
    80004ff6:	0880                	addi	s0,sp,80
    80004ff8:	89ae                	mv	s3,a1
    80004ffa:	8ab2                	mv	s5,a2
    80004ffc:	8a36                	mv	s4,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80004ffe:	fb040593          	addi	a1,s0,-80
    80005002:	fffff097          	auipc	ra,0xfffff
    80005006:	e86080e7          	jalr	-378(ra) # 80003e88 <nameiparent>
    8000500a:	892a                	mv	s2,a0
    8000500c:	12050f63          	beqz	a0,8000514a <create+0x164>
    return 0;

  ilock(dp);
    80005010:	ffffe097          	auipc	ra,0xffffe
    80005014:	6a4080e7          	jalr	1700(ra) # 800036b4 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80005018:	4601                	li	a2,0
    8000501a:	fb040593          	addi	a1,s0,-80
    8000501e:	854a                	mv	a0,s2
    80005020:	fffff097          	auipc	ra,0xfffff
    80005024:	b78080e7          	jalr	-1160(ra) # 80003b98 <dirlookup>
    80005028:	84aa                	mv	s1,a0
    8000502a:	c921                	beqz	a0,8000507a <create+0x94>
    iunlockput(dp);
    8000502c:	854a                	mv	a0,s2
    8000502e:	fffff097          	auipc	ra,0xfffff
    80005032:	8e8080e7          	jalr	-1816(ra) # 80003916 <iunlockput>
    ilock(ip);
    80005036:	8526                	mv	a0,s1
    80005038:	ffffe097          	auipc	ra,0xffffe
    8000503c:	67c080e7          	jalr	1660(ra) # 800036b4 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80005040:	2981                	sext.w	s3,s3
    80005042:	4789                	li	a5,2
    80005044:	02f99463          	bne	s3,a5,8000506c <create+0x86>
    80005048:	0444d783          	lhu	a5,68(s1)
    8000504c:	37f9                	addiw	a5,a5,-2
    8000504e:	17c2                	slli	a5,a5,0x30
    80005050:	93c1                	srli	a5,a5,0x30
    80005052:	4705                	li	a4,1
    80005054:	00f76c63          	bltu	a4,a5,8000506c <create+0x86>
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
    80005058:	8526                	mv	a0,s1
    8000505a:	60a6                	ld	ra,72(sp)
    8000505c:	6406                	ld	s0,64(sp)
    8000505e:	74e2                	ld	s1,56(sp)
    80005060:	7942                	ld	s2,48(sp)
    80005062:	79a2                	ld	s3,40(sp)
    80005064:	7a02                	ld	s4,32(sp)
    80005066:	6ae2                	ld	s5,24(sp)
    80005068:	6161                	addi	sp,sp,80
    8000506a:	8082                	ret
    iunlockput(ip);
    8000506c:	8526                	mv	a0,s1
    8000506e:	fffff097          	auipc	ra,0xfffff
    80005072:	8a8080e7          	jalr	-1880(ra) # 80003916 <iunlockput>
    return 0;
    80005076:	4481                	li	s1,0
    80005078:	b7c5                	j	80005058 <create+0x72>
  if((ip = ialloc(dp->dev, type)) == 0)
    8000507a:	85ce                	mv	a1,s3
    8000507c:	00092503          	lw	a0,0(s2)
    80005080:	ffffe097          	auipc	ra,0xffffe
    80005084:	49c080e7          	jalr	1180(ra) # 8000351c <ialloc>
    80005088:	84aa                	mv	s1,a0
    8000508a:	c529                	beqz	a0,800050d4 <create+0xee>
  ilock(ip);
    8000508c:	ffffe097          	auipc	ra,0xffffe
    80005090:	628080e7          	jalr	1576(ra) # 800036b4 <ilock>
  ip->major = major;
    80005094:	05549323          	sh	s5,70(s1)
  ip->minor = minor;
    80005098:	05449423          	sh	s4,72(s1)
  ip->nlink = 1;
    8000509c:	4785                	li	a5,1
    8000509e:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800050a2:	8526                	mv	a0,s1
    800050a4:	ffffe097          	auipc	ra,0xffffe
    800050a8:	546080e7          	jalr	1350(ra) # 800035ea <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    800050ac:	2981                	sext.w	s3,s3
    800050ae:	4785                	li	a5,1
    800050b0:	02f98a63          	beq	s3,a5,800050e4 <create+0xfe>
  if(dirlink(dp, name, ip->inum) < 0)
    800050b4:	40d0                	lw	a2,4(s1)
    800050b6:	fb040593          	addi	a1,s0,-80
    800050ba:	854a                	mv	a0,s2
    800050bc:	fffff097          	auipc	ra,0xfffff
    800050c0:	cec080e7          	jalr	-788(ra) # 80003da8 <dirlink>
    800050c4:	06054b63          	bltz	a0,8000513a <create+0x154>
  iunlockput(dp);
    800050c8:	854a                	mv	a0,s2
    800050ca:	fffff097          	auipc	ra,0xfffff
    800050ce:	84c080e7          	jalr	-1972(ra) # 80003916 <iunlockput>
  return ip;
    800050d2:	b759                	j	80005058 <create+0x72>
    panic("create: ialloc");
    800050d4:	00003517          	auipc	a0,0x3
    800050d8:	60450513          	addi	a0,a0,1540 # 800086d8 <syscalls+0x2a8>
    800050dc:	ffffb097          	auipc	ra,0xffffb
    800050e0:	454080e7          	jalr	1108(ra) # 80000530 <panic>
    dp->nlink++;  // for ".."
    800050e4:	04a95783          	lhu	a5,74(s2)
    800050e8:	2785                	addiw	a5,a5,1
    800050ea:	04f91523          	sh	a5,74(s2)
    iupdate(dp);
    800050ee:	854a                	mv	a0,s2
    800050f0:	ffffe097          	auipc	ra,0xffffe
    800050f4:	4fa080e7          	jalr	1274(ra) # 800035ea <iupdate>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    800050f8:	40d0                	lw	a2,4(s1)
    800050fa:	00003597          	auipc	a1,0x3
    800050fe:	5ee58593          	addi	a1,a1,1518 # 800086e8 <syscalls+0x2b8>
    80005102:	8526                	mv	a0,s1
    80005104:	fffff097          	auipc	ra,0xfffff
    80005108:	ca4080e7          	jalr	-860(ra) # 80003da8 <dirlink>
    8000510c:	00054f63          	bltz	a0,8000512a <create+0x144>
    80005110:	00492603          	lw	a2,4(s2)
    80005114:	00003597          	auipc	a1,0x3
    80005118:	5dc58593          	addi	a1,a1,1500 # 800086f0 <syscalls+0x2c0>
    8000511c:	8526                	mv	a0,s1
    8000511e:	fffff097          	auipc	ra,0xfffff
    80005122:	c8a080e7          	jalr	-886(ra) # 80003da8 <dirlink>
    80005126:	f80557e3          	bgez	a0,800050b4 <create+0xce>
      panic("create dots");
    8000512a:	00003517          	auipc	a0,0x3
    8000512e:	5ce50513          	addi	a0,a0,1486 # 800086f8 <syscalls+0x2c8>
    80005132:	ffffb097          	auipc	ra,0xffffb
    80005136:	3fe080e7          	jalr	1022(ra) # 80000530 <panic>
    panic("create: dirlink");
    8000513a:	00003517          	auipc	a0,0x3
    8000513e:	5ce50513          	addi	a0,a0,1486 # 80008708 <syscalls+0x2d8>
    80005142:	ffffb097          	auipc	ra,0xffffb
    80005146:	3ee080e7          	jalr	1006(ra) # 80000530 <panic>
    return 0;
    8000514a:	84aa                	mv	s1,a0
    8000514c:	b731                	j	80005058 <create+0x72>

000000008000514e <sys_dup>:
{
    8000514e:	7179                	addi	sp,sp,-48
    80005150:	f406                	sd	ra,40(sp)
    80005152:	f022                	sd	s0,32(sp)
    80005154:	ec26                	sd	s1,24(sp)
    80005156:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80005158:	fd840613          	addi	a2,s0,-40
    8000515c:	4581                	li	a1,0
    8000515e:	4501                	li	a0,0
    80005160:	00000097          	auipc	ra,0x0
    80005164:	ddc080e7          	jalr	-548(ra) # 80004f3c <argfd>
    return -1;
    80005168:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    8000516a:	02054363          	bltz	a0,80005190 <sys_dup+0x42>
  if((fd=fdalloc(f)) < 0)
    8000516e:	fd843503          	ld	a0,-40(s0)
    80005172:	00000097          	auipc	ra,0x0
    80005176:	e32080e7          	jalr	-462(ra) # 80004fa4 <fdalloc>
    8000517a:	84aa                	mv	s1,a0
    return -1;
    8000517c:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    8000517e:	00054963          	bltz	a0,80005190 <sys_dup+0x42>
  filedup(f);
    80005182:	fd843503          	ld	a0,-40(s0)
    80005186:	fffff097          	auipc	ra,0xfffff
    8000518a:	37a080e7          	jalr	890(ra) # 80004500 <filedup>
  return fd;
    8000518e:	87a6                	mv	a5,s1
}
    80005190:	853e                	mv	a0,a5
    80005192:	70a2                	ld	ra,40(sp)
    80005194:	7402                	ld	s0,32(sp)
    80005196:	64e2                	ld	s1,24(sp)
    80005198:	6145                	addi	sp,sp,48
    8000519a:	8082                	ret

000000008000519c <sys_read>:
{
    8000519c:	7179                	addi	sp,sp,-48
    8000519e:	f406                	sd	ra,40(sp)
    800051a0:	f022                	sd	s0,32(sp)
    800051a2:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800051a4:	fe840613          	addi	a2,s0,-24
    800051a8:	4581                	li	a1,0
    800051aa:	4501                	li	a0,0
    800051ac:	00000097          	auipc	ra,0x0
    800051b0:	d90080e7          	jalr	-624(ra) # 80004f3c <argfd>
    return -1;
    800051b4:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800051b6:	04054163          	bltz	a0,800051f8 <sys_read+0x5c>
    800051ba:	fe440593          	addi	a1,s0,-28
    800051be:	4509                	li	a0,2
    800051c0:	ffffe097          	auipc	ra,0xffffe
    800051c4:	950080e7          	jalr	-1712(ra) # 80002b10 <argint>
    return -1;
    800051c8:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800051ca:	02054763          	bltz	a0,800051f8 <sys_read+0x5c>
    800051ce:	fd840593          	addi	a1,s0,-40
    800051d2:	4505                	li	a0,1
    800051d4:	ffffe097          	auipc	ra,0xffffe
    800051d8:	95e080e7          	jalr	-1698(ra) # 80002b32 <argaddr>
    return -1;
    800051dc:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800051de:	00054d63          	bltz	a0,800051f8 <sys_read+0x5c>
  return fileread(f, p, n);
    800051e2:	fe442603          	lw	a2,-28(s0)
    800051e6:	fd843583          	ld	a1,-40(s0)
    800051ea:	fe843503          	ld	a0,-24(s0)
    800051ee:	fffff097          	auipc	ra,0xfffff
    800051f2:	49e080e7          	jalr	1182(ra) # 8000468c <fileread>
    800051f6:	87aa                	mv	a5,a0
}
    800051f8:	853e                	mv	a0,a5
    800051fa:	70a2                	ld	ra,40(sp)
    800051fc:	7402                	ld	s0,32(sp)
    800051fe:	6145                	addi	sp,sp,48
    80005200:	8082                	ret

0000000080005202 <sys_write>:
{
    80005202:	7179                	addi	sp,sp,-48
    80005204:	f406                	sd	ra,40(sp)
    80005206:	f022                	sd	s0,32(sp)
    80005208:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000520a:	fe840613          	addi	a2,s0,-24
    8000520e:	4581                	li	a1,0
    80005210:	4501                	li	a0,0
    80005212:	00000097          	auipc	ra,0x0
    80005216:	d2a080e7          	jalr	-726(ra) # 80004f3c <argfd>
    return -1;
    8000521a:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000521c:	04054163          	bltz	a0,8000525e <sys_write+0x5c>
    80005220:	fe440593          	addi	a1,s0,-28
    80005224:	4509                	li	a0,2
    80005226:	ffffe097          	auipc	ra,0xffffe
    8000522a:	8ea080e7          	jalr	-1814(ra) # 80002b10 <argint>
    return -1;
    8000522e:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005230:	02054763          	bltz	a0,8000525e <sys_write+0x5c>
    80005234:	fd840593          	addi	a1,s0,-40
    80005238:	4505                	li	a0,1
    8000523a:	ffffe097          	auipc	ra,0xffffe
    8000523e:	8f8080e7          	jalr	-1800(ra) # 80002b32 <argaddr>
    return -1;
    80005242:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005244:	00054d63          	bltz	a0,8000525e <sys_write+0x5c>
  return filewrite(f, p, n);
    80005248:	fe442603          	lw	a2,-28(s0)
    8000524c:	fd843583          	ld	a1,-40(s0)
    80005250:	fe843503          	ld	a0,-24(s0)
    80005254:	fffff097          	auipc	ra,0xfffff
    80005258:	4fa080e7          	jalr	1274(ra) # 8000474e <filewrite>
    8000525c:	87aa                	mv	a5,a0
}
    8000525e:	853e                	mv	a0,a5
    80005260:	70a2                	ld	ra,40(sp)
    80005262:	7402                	ld	s0,32(sp)
    80005264:	6145                	addi	sp,sp,48
    80005266:	8082                	ret

0000000080005268 <sys_close>:
{
    80005268:	1101                	addi	sp,sp,-32
    8000526a:	ec06                	sd	ra,24(sp)
    8000526c:	e822                	sd	s0,16(sp)
    8000526e:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80005270:	fe040613          	addi	a2,s0,-32
    80005274:	fec40593          	addi	a1,s0,-20
    80005278:	4501                	li	a0,0
    8000527a:	00000097          	auipc	ra,0x0
    8000527e:	cc2080e7          	jalr	-830(ra) # 80004f3c <argfd>
    return -1;
    80005282:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80005284:	02054463          	bltz	a0,800052ac <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    80005288:	ffffc097          	auipc	ra,0xffffc
    8000528c:	70c080e7          	jalr	1804(ra) # 80001994 <myproc>
    80005290:	fec42783          	lw	a5,-20(s0)
    80005294:	07e9                	addi	a5,a5,26
    80005296:	078e                	slli	a5,a5,0x3
    80005298:	97aa                	add	a5,a5,a0
    8000529a:	0007b023          	sd	zero,0(a5)
  fileclose(f);
    8000529e:	fe043503          	ld	a0,-32(s0)
    800052a2:	fffff097          	auipc	ra,0xfffff
    800052a6:	2b0080e7          	jalr	688(ra) # 80004552 <fileclose>
  return 0;
    800052aa:	4781                	li	a5,0
}
    800052ac:	853e                	mv	a0,a5
    800052ae:	60e2                	ld	ra,24(sp)
    800052b0:	6442                	ld	s0,16(sp)
    800052b2:	6105                	addi	sp,sp,32
    800052b4:	8082                	ret

00000000800052b6 <sys_fstat>:
{
    800052b6:	1101                	addi	sp,sp,-32
    800052b8:	ec06                	sd	ra,24(sp)
    800052ba:	e822                	sd	s0,16(sp)
    800052bc:	1000                	addi	s0,sp,32
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    800052be:	fe840613          	addi	a2,s0,-24
    800052c2:	4581                	li	a1,0
    800052c4:	4501                	li	a0,0
    800052c6:	00000097          	auipc	ra,0x0
    800052ca:	c76080e7          	jalr	-906(ra) # 80004f3c <argfd>
    return -1;
    800052ce:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    800052d0:	02054563          	bltz	a0,800052fa <sys_fstat+0x44>
    800052d4:	fe040593          	addi	a1,s0,-32
    800052d8:	4505                	li	a0,1
    800052da:	ffffe097          	auipc	ra,0xffffe
    800052de:	858080e7          	jalr	-1960(ra) # 80002b32 <argaddr>
    return -1;
    800052e2:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    800052e4:	00054b63          	bltz	a0,800052fa <sys_fstat+0x44>
  return filestat(f, st);
    800052e8:	fe043583          	ld	a1,-32(s0)
    800052ec:	fe843503          	ld	a0,-24(s0)
    800052f0:	fffff097          	auipc	ra,0xfffff
    800052f4:	32a080e7          	jalr	810(ra) # 8000461a <filestat>
    800052f8:	87aa                	mv	a5,a0
}
    800052fa:	853e                	mv	a0,a5
    800052fc:	60e2                	ld	ra,24(sp)
    800052fe:	6442                	ld	s0,16(sp)
    80005300:	6105                	addi	sp,sp,32
    80005302:	8082                	ret

0000000080005304 <sys_link>:
{
    80005304:	7169                	addi	sp,sp,-304
    80005306:	f606                	sd	ra,296(sp)
    80005308:	f222                	sd	s0,288(sp)
    8000530a:	ee26                	sd	s1,280(sp)
    8000530c:	ea4a                	sd	s2,272(sp)
    8000530e:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005310:	08000613          	li	a2,128
    80005314:	ed040593          	addi	a1,s0,-304
    80005318:	4501                	li	a0,0
    8000531a:	ffffe097          	auipc	ra,0xffffe
    8000531e:	83a080e7          	jalr	-1990(ra) # 80002b54 <argstr>
    return -1;
    80005322:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005324:	10054e63          	bltz	a0,80005440 <sys_link+0x13c>
    80005328:	08000613          	li	a2,128
    8000532c:	f5040593          	addi	a1,s0,-176
    80005330:	4505                	li	a0,1
    80005332:	ffffe097          	auipc	ra,0xffffe
    80005336:	822080e7          	jalr	-2014(ra) # 80002b54 <argstr>
    return -1;
    8000533a:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000533c:	10054263          	bltz	a0,80005440 <sys_link+0x13c>
  begin_op();
    80005340:	fffff097          	auipc	ra,0xfffff
    80005344:	d46080e7          	jalr	-698(ra) # 80004086 <begin_op>
  if((ip = namei(old)) == 0){
    80005348:	ed040513          	addi	a0,s0,-304
    8000534c:	fffff097          	auipc	ra,0xfffff
    80005350:	b1e080e7          	jalr	-1250(ra) # 80003e6a <namei>
    80005354:	84aa                	mv	s1,a0
    80005356:	c551                	beqz	a0,800053e2 <sys_link+0xde>
  ilock(ip);
    80005358:	ffffe097          	auipc	ra,0xffffe
    8000535c:	35c080e7          	jalr	860(ra) # 800036b4 <ilock>
  if(ip->type == T_DIR){
    80005360:	04449703          	lh	a4,68(s1)
    80005364:	4785                	li	a5,1
    80005366:	08f70463          	beq	a4,a5,800053ee <sys_link+0xea>
  ip->nlink++;
    8000536a:	04a4d783          	lhu	a5,74(s1)
    8000536e:	2785                	addiw	a5,a5,1
    80005370:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005374:	8526                	mv	a0,s1
    80005376:	ffffe097          	auipc	ra,0xffffe
    8000537a:	274080e7          	jalr	628(ra) # 800035ea <iupdate>
  iunlock(ip);
    8000537e:	8526                	mv	a0,s1
    80005380:	ffffe097          	auipc	ra,0xffffe
    80005384:	3f6080e7          	jalr	1014(ra) # 80003776 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80005388:	fd040593          	addi	a1,s0,-48
    8000538c:	f5040513          	addi	a0,s0,-176
    80005390:	fffff097          	auipc	ra,0xfffff
    80005394:	af8080e7          	jalr	-1288(ra) # 80003e88 <nameiparent>
    80005398:	892a                	mv	s2,a0
    8000539a:	c935                	beqz	a0,8000540e <sys_link+0x10a>
  ilock(dp);
    8000539c:	ffffe097          	auipc	ra,0xffffe
    800053a0:	318080e7          	jalr	792(ra) # 800036b4 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    800053a4:	00092703          	lw	a4,0(s2)
    800053a8:	409c                	lw	a5,0(s1)
    800053aa:	04f71d63          	bne	a4,a5,80005404 <sys_link+0x100>
    800053ae:	40d0                	lw	a2,4(s1)
    800053b0:	fd040593          	addi	a1,s0,-48
    800053b4:	854a                	mv	a0,s2
    800053b6:	fffff097          	auipc	ra,0xfffff
    800053ba:	9f2080e7          	jalr	-1550(ra) # 80003da8 <dirlink>
    800053be:	04054363          	bltz	a0,80005404 <sys_link+0x100>
  iunlockput(dp);
    800053c2:	854a                	mv	a0,s2
    800053c4:	ffffe097          	auipc	ra,0xffffe
    800053c8:	552080e7          	jalr	1362(ra) # 80003916 <iunlockput>
  iput(ip);
    800053cc:	8526                	mv	a0,s1
    800053ce:	ffffe097          	auipc	ra,0xffffe
    800053d2:	4a0080e7          	jalr	1184(ra) # 8000386e <iput>
  end_op();
    800053d6:	fffff097          	auipc	ra,0xfffff
    800053da:	d30080e7          	jalr	-720(ra) # 80004106 <end_op>
  return 0;
    800053de:	4781                	li	a5,0
    800053e0:	a085                	j	80005440 <sys_link+0x13c>
    end_op();
    800053e2:	fffff097          	auipc	ra,0xfffff
    800053e6:	d24080e7          	jalr	-732(ra) # 80004106 <end_op>
    return -1;
    800053ea:	57fd                	li	a5,-1
    800053ec:	a891                	j	80005440 <sys_link+0x13c>
    iunlockput(ip);
    800053ee:	8526                	mv	a0,s1
    800053f0:	ffffe097          	auipc	ra,0xffffe
    800053f4:	526080e7          	jalr	1318(ra) # 80003916 <iunlockput>
    end_op();
    800053f8:	fffff097          	auipc	ra,0xfffff
    800053fc:	d0e080e7          	jalr	-754(ra) # 80004106 <end_op>
    return -1;
    80005400:	57fd                	li	a5,-1
    80005402:	a83d                	j	80005440 <sys_link+0x13c>
    iunlockput(dp);
    80005404:	854a                	mv	a0,s2
    80005406:	ffffe097          	auipc	ra,0xffffe
    8000540a:	510080e7          	jalr	1296(ra) # 80003916 <iunlockput>
  ilock(ip);
    8000540e:	8526                	mv	a0,s1
    80005410:	ffffe097          	auipc	ra,0xffffe
    80005414:	2a4080e7          	jalr	676(ra) # 800036b4 <ilock>
  ip->nlink--;
    80005418:	04a4d783          	lhu	a5,74(s1)
    8000541c:	37fd                	addiw	a5,a5,-1
    8000541e:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005422:	8526                	mv	a0,s1
    80005424:	ffffe097          	auipc	ra,0xffffe
    80005428:	1c6080e7          	jalr	454(ra) # 800035ea <iupdate>
  iunlockput(ip);
    8000542c:	8526                	mv	a0,s1
    8000542e:	ffffe097          	auipc	ra,0xffffe
    80005432:	4e8080e7          	jalr	1256(ra) # 80003916 <iunlockput>
  end_op();
    80005436:	fffff097          	auipc	ra,0xfffff
    8000543a:	cd0080e7          	jalr	-816(ra) # 80004106 <end_op>
  return -1;
    8000543e:	57fd                	li	a5,-1
}
    80005440:	853e                	mv	a0,a5
    80005442:	70b2                	ld	ra,296(sp)
    80005444:	7412                	ld	s0,288(sp)
    80005446:	64f2                	ld	s1,280(sp)
    80005448:	6952                	ld	s2,272(sp)
    8000544a:	6155                	addi	sp,sp,304
    8000544c:	8082                	ret

000000008000544e <sys_unlink>:
{
    8000544e:	7151                	addi	sp,sp,-240
    80005450:	f586                	sd	ra,232(sp)
    80005452:	f1a2                	sd	s0,224(sp)
    80005454:	eda6                	sd	s1,216(sp)
    80005456:	e9ca                	sd	s2,208(sp)
    80005458:	e5ce                	sd	s3,200(sp)
    8000545a:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    8000545c:	08000613          	li	a2,128
    80005460:	f3040593          	addi	a1,s0,-208
    80005464:	4501                	li	a0,0
    80005466:	ffffd097          	auipc	ra,0xffffd
    8000546a:	6ee080e7          	jalr	1774(ra) # 80002b54 <argstr>
    8000546e:	18054163          	bltz	a0,800055f0 <sys_unlink+0x1a2>
  begin_op();
    80005472:	fffff097          	auipc	ra,0xfffff
    80005476:	c14080e7          	jalr	-1004(ra) # 80004086 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    8000547a:	fb040593          	addi	a1,s0,-80
    8000547e:	f3040513          	addi	a0,s0,-208
    80005482:	fffff097          	auipc	ra,0xfffff
    80005486:	a06080e7          	jalr	-1530(ra) # 80003e88 <nameiparent>
    8000548a:	84aa                	mv	s1,a0
    8000548c:	c979                	beqz	a0,80005562 <sys_unlink+0x114>
  ilock(dp);
    8000548e:	ffffe097          	auipc	ra,0xffffe
    80005492:	226080e7          	jalr	550(ra) # 800036b4 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80005496:	00003597          	auipc	a1,0x3
    8000549a:	25258593          	addi	a1,a1,594 # 800086e8 <syscalls+0x2b8>
    8000549e:	fb040513          	addi	a0,s0,-80
    800054a2:	ffffe097          	auipc	ra,0xffffe
    800054a6:	6dc080e7          	jalr	1756(ra) # 80003b7e <namecmp>
    800054aa:	14050a63          	beqz	a0,800055fe <sys_unlink+0x1b0>
    800054ae:	00003597          	auipc	a1,0x3
    800054b2:	24258593          	addi	a1,a1,578 # 800086f0 <syscalls+0x2c0>
    800054b6:	fb040513          	addi	a0,s0,-80
    800054ba:	ffffe097          	auipc	ra,0xffffe
    800054be:	6c4080e7          	jalr	1732(ra) # 80003b7e <namecmp>
    800054c2:	12050e63          	beqz	a0,800055fe <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    800054c6:	f2c40613          	addi	a2,s0,-212
    800054ca:	fb040593          	addi	a1,s0,-80
    800054ce:	8526                	mv	a0,s1
    800054d0:	ffffe097          	auipc	ra,0xffffe
    800054d4:	6c8080e7          	jalr	1736(ra) # 80003b98 <dirlookup>
    800054d8:	892a                	mv	s2,a0
    800054da:	12050263          	beqz	a0,800055fe <sys_unlink+0x1b0>
  ilock(ip);
    800054de:	ffffe097          	auipc	ra,0xffffe
    800054e2:	1d6080e7          	jalr	470(ra) # 800036b4 <ilock>
  if(ip->nlink < 1)
    800054e6:	04a91783          	lh	a5,74(s2)
    800054ea:	08f05263          	blez	a5,8000556e <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    800054ee:	04491703          	lh	a4,68(s2)
    800054f2:	4785                	li	a5,1
    800054f4:	08f70563          	beq	a4,a5,8000557e <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    800054f8:	4641                	li	a2,16
    800054fa:	4581                	li	a1,0
    800054fc:	fc040513          	addi	a0,s0,-64
    80005500:	ffffb097          	auipc	ra,0xffffb
    80005504:	7d2080e7          	jalr	2002(ra) # 80000cd2 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005508:	4741                	li	a4,16
    8000550a:	f2c42683          	lw	a3,-212(s0)
    8000550e:	fc040613          	addi	a2,s0,-64
    80005512:	4581                	li	a1,0
    80005514:	8526                	mv	a0,s1
    80005516:	ffffe097          	auipc	ra,0xffffe
    8000551a:	54a080e7          	jalr	1354(ra) # 80003a60 <writei>
    8000551e:	47c1                	li	a5,16
    80005520:	0af51563          	bne	a0,a5,800055ca <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    80005524:	04491703          	lh	a4,68(s2)
    80005528:	4785                	li	a5,1
    8000552a:	0af70863          	beq	a4,a5,800055da <sys_unlink+0x18c>
  iunlockput(dp);
    8000552e:	8526                	mv	a0,s1
    80005530:	ffffe097          	auipc	ra,0xffffe
    80005534:	3e6080e7          	jalr	998(ra) # 80003916 <iunlockput>
  ip->nlink--;
    80005538:	04a95783          	lhu	a5,74(s2)
    8000553c:	37fd                	addiw	a5,a5,-1
    8000553e:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80005542:	854a                	mv	a0,s2
    80005544:	ffffe097          	auipc	ra,0xffffe
    80005548:	0a6080e7          	jalr	166(ra) # 800035ea <iupdate>
  iunlockput(ip);
    8000554c:	854a                	mv	a0,s2
    8000554e:	ffffe097          	auipc	ra,0xffffe
    80005552:	3c8080e7          	jalr	968(ra) # 80003916 <iunlockput>
  end_op();
    80005556:	fffff097          	auipc	ra,0xfffff
    8000555a:	bb0080e7          	jalr	-1104(ra) # 80004106 <end_op>
  return 0;
    8000555e:	4501                	li	a0,0
    80005560:	a84d                	j	80005612 <sys_unlink+0x1c4>
    end_op();
    80005562:	fffff097          	auipc	ra,0xfffff
    80005566:	ba4080e7          	jalr	-1116(ra) # 80004106 <end_op>
    return -1;
    8000556a:	557d                	li	a0,-1
    8000556c:	a05d                	j	80005612 <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    8000556e:	00003517          	auipc	a0,0x3
    80005572:	1aa50513          	addi	a0,a0,426 # 80008718 <syscalls+0x2e8>
    80005576:	ffffb097          	auipc	ra,0xffffb
    8000557a:	fba080e7          	jalr	-70(ra) # 80000530 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    8000557e:	04c92703          	lw	a4,76(s2)
    80005582:	02000793          	li	a5,32
    80005586:	f6e7f9e3          	bgeu	a5,a4,800054f8 <sys_unlink+0xaa>
    8000558a:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000558e:	4741                	li	a4,16
    80005590:	86ce                	mv	a3,s3
    80005592:	f1840613          	addi	a2,s0,-232
    80005596:	4581                	li	a1,0
    80005598:	854a                	mv	a0,s2
    8000559a:	ffffe097          	auipc	ra,0xffffe
    8000559e:	3ce080e7          	jalr	974(ra) # 80003968 <readi>
    800055a2:	47c1                	li	a5,16
    800055a4:	00f51b63          	bne	a0,a5,800055ba <sys_unlink+0x16c>
    if(de.inum != 0)
    800055a8:	f1845783          	lhu	a5,-232(s0)
    800055ac:	e7a1                	bnez	a5,800055f4 <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800055ae:	29c1                	addiw	s3,s3,16
    800055b0:	04c92783          	lw	a5,76(s2)
    800055b4:	fcf9ede3          	bltu	s3,a5,8000558e <sys_unlink+0x140>
    800055b8:	b781                	j	800054f8 <sys_unlink+0xaa>
      panic("isdirempty: readi");
    800055ba:	00003517          	auipc	a0,0x3
    800055be:	17650513          	addi	a0,a0,374 # 80008730 <syscalls+0x300>
    800055c2:	ffffb097          	auipc	ra,0xffffb
    800055c6:	f6e080e7          	jalr	-146(ra) # 80000530 <panic>
    panic("unlink: writei");
    800055ca:	00003517          	auipc	a0,0x3
    800055ce:	17e50513          	addi	a0,a0,382 # 80008748 <syscalls+0x318>
    800055d2:	ffffb097          	auipc	ra,0xffffb
    800055d6:	f5e080e7          	jalr	-162(ra) # 80000530 <panic>
    dp->nlink--;
    800055da:	04a4d783          	lhu	a5,74(s1)
    800055de:	37fd                	addiw	a5,a5,-1
    800055e0:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    800055e4:	8526                	mv	a0,s1
    800055e6:	ffffe097          	auipc	ra,0xffffe
    800055ea:	004080e7          	jalr	4(ra) # 800035ea <iupdate>
    800055ee:	b781                	j	8000552e <sys_unlink+0xe0>
    return -1;
    800055f0:	557d                	li	a0,-1
    800055f2:	a005                	j	80005612 <sys_unlink+0x1c4>
    iunlockput(ip);
    800055f4:	854a                	mv	a0,s2
    800055f6:	ffffe097          	auipc	ra,0xffffe
    800055fa:	320080e7          	jalr	800(ra) # 80003916 <iunlockput>
  iunlockput(dp);
    800055fe:	8526                	mv	a0,s1
    80005600:	ffffe097          	auipc	ra,0xffffe
    80005604:	316080e7          	jalr	790(ra) # 80003916 <iunlockput>
  end_op();
    80005608:	fffff097          	auipc	ra,0xfffff
    8000560c:	afe080e7          	jalr	-1282(ra) # 80004106 <end_op>
  return -1;
    80005610:	557d                	li	a0,-1
}
    80005612:	70ae                	ld	ra,232(sp)
    80005614:	740e                	ld	s0,224(sp)
    80005616:	64ee                	ld	s1,216(sp)
    80005618:	694e                	ld	s2,208(sp)
    8000561a:	69ae                	ld	s3,200(sp)
    8000561c:	616d                	addi	sp,sp,240
    8000561e:	8082                	ret

0000000080005620 <sys_open>:

uint64
sys_open(void)
{
    80005620:	7131                	addi	sp,sp,-192
    80005622:	fd06                	sd	ra,184(sp)
    80005624:	f922                	sd	s0,176(sp)
    80005626:	f526                	sd	s1,168(sp)
    80005628:	f14a                	sd	s2,160(sp)
    8000562a:	ed4e                	sd	s3,152(sp)
    8000562c:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    8000562e:	08000613          	li	a2,128
    80005632:	f5040593          	addi	a1,s0,-176
    80005636:	4501                	li	a0,0
    80005638:	ffffd097          	auipc	ra,0xffffd
    8000563c:	51c080e7          	jalr	1308(ra) # 80002b54 <argstr>
    return -1;
    80005640:	54fd                	li	s1,-1
  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    80005642:	0c054163          	bltz	a0,80005704 <sys_open+0xe4>
    80005646:	f4c40593          	addi	a1,s0,-180
    8000564a:	4505                	li	a0,1
    8000564c:	ffffd097          	auipc	ra,0xffffd
    80005650:	4c4080e7          	jalr	1220(ra) # 80002b10 <argint>
    80005654:	0a054863          	bltz	a0,80005704 <sys_open+0xe4>

  begin_op();
    80005658:	fffff097          	auipc	ra,0xfffff
    8000565c:	a2e080e7          	jalr	-1490(ra) # 80004086 <begin_op>

  if(omode & O_CREATE){
    80005660:	f4c42783          	lw	a5,-180(s0)
    80005664:	2007f793          	andi	a5,a5,512
    80005668:	cbdd                	beqz	a5,8000571e <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    8000566a:	4681                	li	a3,0
    8000566c:	4601                	li	a2,0
    8000566e:	4589                	li	a1,2
    80005670:	f5040513          	addi	a0,s0,-176
    80005674:	00000097          	auipc	ra,0x0
    80005678:	972080e7          	jalr	-1678(ra) # 80004fe6 <create>
    8000567c:	892a                	mv	s2,a0
    if(ip == 0){
    8000567e:	c959                	beqz	a0,80005714 <sys_open+0xf4>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80005680:	04491703          	lh	a4,68(s2)
    80005684:	478d                	li	a5,3
    80005686:	00f71763          	bne	a4,a5,80005694 <sys_open+0x74>
    8000568a:	04695703          	lhu	a4,70(s2)
    8000568e:	47a5                	li	a5,9
    80005690:	0ce7ec63          	bltu	a5,a4,80005768 <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80005694:	fffff097          	auipc	ra,0xfffff
    80005698:	e02080e7          	jalr	-510(ra) # 80004496 <filealloc>
    8000569c:	89aa                	mv	s3,a0
    8000569e:	10050263          	beqz	a0,800057a2 <sys_open+0x182>
    800056a2:	00000097          	auipc	ra,0x0
    800056a6:	902080e7          	jalr	-1790(ra) # 80004fa4 <fdalloc>
    800056aa:	84aa                	mv	s1,a0
    800056ac:	0e054663          	bltz	a0,80005798 <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    800056b0:	04491703          	lh	a4,68(s2)
    800056b4:	478d                	li	a5,3
    800056b6:	0cf70463          	beq	a4,a5,8000577e <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    800056ba:	4789                	li	a5,2
    800056bc:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    800056c0:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    800056c4:	0129bc23          	sd	s2,24(s3)
  f->readable = !(omode & O_WRONLY);
    800056c8:	f4c42783          	lw	a5,-180(s0)
    800056cc:	0017c713          	xori	a4,a5,1
    800056d0:	8b05                	andi	a4,a4,1
    800056d2:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    800056d6:	0037f713          	andi	a4,a5,3
    800056da:	00e03733          	snez	a4,a4
    800056de:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    800056e2:	4007f793          	andi	a5,a5,1024
    800056e6:	c791                	beqz	a5,800056f2 <sys_open+0xd2>
    800056e8:	04491703          	lh	a4,68(s2)
    800056ec:	4789                	li	a5,2
    800056ee:	08f70f63          	beq	a4,a5,8000578c <sys_open+0x16c>
    itrunc(ip);
  }

  iunlock(ip);
    800056f2:	854a                	mv	a0,s2
    800056f4:	ffffe097          	auipc	ra,0xffffe
    800056f8:	082080e7          	jalr	130(ra) # 80003776 <iunlock>
  end_op();
    800056fc:	fffff097          	auipc	ra,0xfffff
    80005700:	a0a080e7          	jalr	-1526(ra) # 80004106 <end_op>

  return fd;
}
    80005704:	8526                	mv	a0,s1
    80005706:	70ea                	ld	ra,184(sp)
    80005708:	744a                	ld	s0,176(sp)
    8000570a:	74aa                	ld	s1,168(sp)
    8000570c:	790a                	ld	s2,160(sp)
    8000570e:	69ea                	ld	s3,152(sp)
    80005710:	6129                	addi	sp,sp,192
    80005712:	8082                	ret
      end_op();
    80005714:	fffff097          	auipc	ra,0xfffff
    80005718:	9f2080e7          	jalr	-1550(ra) # 80004106 <end_op>
      return -1;
    8000571c:	b7e5                	j	80005704 <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    8000571e:	f5040513          	addi	a0,s0,-176
    80005722:	ffffe097          	auipc	ra,0xffffe
    80005726:	748080e7          	jalr	1864(ra) # 80003e6a <namei>
    8000572a:	892a                	mv	s2,a0
    8000572c:	c905                	beqz	a0,8000575c <sys_open+0x13c>
    ilock(ip);
    8000572e:	ffffe097          	auipc	ra,0xffffe
    80005732:	f86080e7          	jalr	-122(ra) # 800036b4 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005736:	04491703          	lh	a4,68(s2)
    8000573a:	4785                	li	a5,1
    8000573c:	f4f712e3          	bne	a4,a5,80005680 <sys_open+0x60>
    80005740:	f4c42783          	lw	a5,-180(s0)
    80005744:	dba1                	beqz	a5,80005694 <sys_open+0x74>
      iunlockput(ip);
    80005746:	854a                	mv	a0,s2
    80005748:	ffffe097          	auipc	ra,0xffffe
    8000574c:	1ce080e7          	jalr	462(ra) # 80003916 <iunlockput>
      end_op();
    80005750:	fffff097          	auipc	ra,0xfffff
    80005754:	9b6080e7          	jalr	-1610(ra) # 80004106 <end_op>
      return -1;
    80005758:	54fd                	li	s1,-1
    8000575a:	b76d                	j	80005704 <sys_open+0xe4>
      end_op();
    8000575c:	fffff097          	auipc	ra,0xfffff
    80005760:	9aa080e7          	jalr	-1622(ra) # 80004106 <end_op>
      return -1;
    80005764:	54fd                	li	s1,-1
    80005766:	bf79                	j	80005704 <sys_open+0xe4>
    iunlockput(ip);
    80005768:	854a                	mv	a0,s2
    8000576a:	ffffe097          	auipc	ra,0xffffe
    8000576e:	1ac080e7          	jalr	428(ra) # 80003916 <iunlockput>
    end_op();
    80005772:	fffff097          	auipc	ra,0xfffff
    80005776:	994080e7          	jalr	-1644(ra) # 80004106 <end_op>
    return -1;
    8000577a:	54fd                	li	s1,-1
    8000577c:	b761                	j	80005704 <sys_open+0xe4>
    f->type = FD_DEVICE;
    8000577e:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    80005782:	04691783          	lh	a5,70(s2)
    80005786:	02f99223          	sh	a5,36(s3)
    8000578a:	bf2d                	j	800056c4 <sys_open+0xa4>
    itrunc(ip);
    8000578c:	854a                	mv	a0,s2
    8000578e:	ffffe097          	auipc	ra,0xffffe
    80005792:	034080e7          	jalr	52(ra) # 800037c2 <itrunc>
    80005796:	bfb1                	j	800056f2 <sys_open+0xd2>
      fileclose(f);
    80005798:	854e                	mv	a0,s3
    8000579a:	fffff097          	auipc	ra,0xfffff
    8000579e:	db8080e7          	jalr	-584(ra) # 80004552 <fileclose>
    iunlockput(ip);
    800057a2:	854a                	mv	a0,s2
    800057a4:	ffffe097          	auipc	ra,0xffffe
    800057a8:	172080e7          	jalr	370(ra) # 80003916 <iunlockput>
    end_op();
    800057ac:	fffff097          	auipc	ra,0xfffff
    800057b0:	95a080e7          	jalr	-1702(ra) # 80004106 <end_op>
    return -1;
    800057b4:	54fd                	li	s1,-1
    800057b6:	b7b9                	j	80005704 <sys_open+0xe4>

00000000800057b8 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    800057b8:	7175                	addi	sp,sp,-144
    800057ba:	e506                	sd	ra,136(sp)
    800057bc:	e122                	sd	s0,128(sp)
    800057be:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    800057c0:	fffff097          	auipc	ra,0xfffff
    800057c4:	8c6080e7          	jalr	-1850(ra) # 80004086 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    800057c8:	08000613          	li	a2,128
    800057cc:	f7040593          	addi	a1,s0,-144
    800057d0:	4501                	li	a0,0
    800057d2:	ffffd097          	auipc	ra,0xffffd
    800057d6:	382080e7          	jalr	898(ra) # 80002b54 <argstr>
    800057da:	02054963          	bltz	a0,8000580c <sys_mkdir+0x54>
    800057de:	4681                	li	a3,0
    800057e0:	4601                	li	a2,0
    800057e2:	4585                	li	a1,1
    800057e4:	f7040513          	addi	a0,s0,-144
    800057e8:	fffff097          	auipc	ra,0xfffff
    800057ec:	7fe080e7          	jalr	2046(ra) # 80004fe6 <create>
    800057f0:	cd11                	beqz	a0,8000580c <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    800057f2:	ffffe097          	auipc	ra,0xffffe
    800057f6:	124080e7          	jalr	292(ra) # 80003916 <iunlockput>
  end_op();
    800057fa:	fffff097          	auipc	ra,0xfffff
    800057fe:	90c080e7          	jalr	-1780(ra) # 80004106 <end_op>
  return 0;
    80005802:	4501                	li	a0,0
}
    80005804:	60aa                	ld	ra,136(sp)
    80005806:	640a                	ld	s0,128(sp)
    80005808:	6149                	addi	sp,sp,144
    8000580a:	8082                	ret
    end_op();
    8000580c:	fffff097          	auipc	ra,0xfffff
    80005810:	8fa080e7          	jalr	-1798(ra) # 80004106 <end_op>
    return -1;
    80005814:	557d                	li	a0,-1
    80005816:	b7fd                	j	80005804 <sys_mkdir+0x4c>

0000000080005818 <sys_mknod>:

uint64
sys_mknod(void)
{
    80005818:	7135                	addi	sp,sp,-160
    8000581a:	ed06                	sd	ra,152(sp)
    8000581c:	e922                	sd	s0,144(sp)
    8000581e:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005820:	fffff097          	auipc	ra,0xfffff
    80005824:	866080e7          	jalr	-1946(ra) # 80004086 <begin_op>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005828:	08000613          	li	a2,128
    8000582c:	f7040593          	addi	a1,s0,-144
    80005830:	4501                	li	a0,0
    80005832:	ffffd097          	auipc	ra,0xffffd
    80005836:	322080e7          	jalr	802(ra) # 80002b54 <argstr>
    8000583a:	04054a63          	bltz	a0,8000588e <sys_mknod+0x76>
     argint(1, &major) < 0 ||
    8000583e:	f6c40593          	addi	a1,s0,-148
    80005842:	4505                	li	a0,1
    80005844:	ffffd097          	auipc	ra,0xffffd
    80005848:	2cc080e7          	jalr	716(ra) # 80002b10 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    8000584c:	04054163          	bltz	a0,8000588e <sys_mknod+0x76>
     argint(2, &minor) < 0 ||
    80005850:	f6840593          	addi	a1,s0,-152
    80005854:	4509                	li	a0,2
    80005856:	ffffd097          	auipc	ra,0xffffd
    8000585a:	2ba080e7          	jalr	698(ra) # 80002b10 <argint>
     argint(1, &major) < 0 ||
    8000585e:	02054863          	bltz	a0,8000588e <sys_mknod+0x76>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005862:	f6841683          	lh	a3,-152(s0)
    80005866:	f6c41603          	lh	a2,-148(s0)
    8000586a:	458d                	li	a1,3
    8000586c:	f7040513          	addi	a0,s0,-144
    80005870:	fffff097          	auipc	ra,0xfffff
    80005874:	776080e7          	jalr	1910(ra) # 80004fe6 <create>
     argint(2, &minor) < 0 ||
    80005878:	c919                	beqz	a0,8000588e <sys_mknod+0x76>
    end_op();
    return -1;
  }
  iunlockput(ip);
    8000587a:	ffffe097          	auipc	ra,0xffffe
    8000587e:	09c080e7          	jalr	156(ra) # 80003916 <iunlockput>
  end_op();
    80005882:	fffff097          	auipc	ra,0xfffff
    80005886:	884080e7          	jalr	-1916(ra) # 80004106 <end_op>
  return 0;
    8000588a:	4501                	li	a0,0
    8000588c:	a031                	j	80005898 <sys_mknod+0x80>
    end_op();
    8000588e:	fffff097          	auipc	ra,0xfffff
    80005892:	878080e7          	jalr	-1928(ra) # 80004106 <end_op>
    return -1;
    80005896:	557d                	li	a0,-1
}
    80005898:	60ea                	ld	ra,152(sp)
    8000589a:	644a                	ld	s0,144(sp)
    8000589c:	610d                	addi	sp,sp,160
    8000589e:	8082                	ret

00000000800058a0 <sys_chdir>:

uint64
sys_chdir(void)
{
    800058a0:	7135                	addi	sp,sp,-160
    800058a2:	ed06                	sd	ra,152(sp)
    800058a4:	e922                	sd	s0,144(sp)
    800058a6:	e526                	sd	s1,136(sp)
    800058a8:	e14a                	sd	s2,128(sp)
    800058aa:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    800058ac:	ffffc097          	auipc	ra,0xffffc
    800058b0:	0e8080e7          	jalr	232(ra) # 80001994 <myproc>
    800058b4:	892a                	mv	s2,a0
  
  begin_op();
    800058b6:	ffffe097          	auipc	ra,0xffffe
    800058ba:	7d0080e7          	jalr	2000(ra) # 80004086 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    800058be:	08000613          	li	a2,128
    800058c2:	f6040593          	addi	a1,s0,-160
    800058c6:	4501                	li	a0,0
    800058c8:	ffffd097          	auipc	ra,0xffffd
    800058cc:	28c080e7          	jalr	652(ra) # 80002b54 <argstr>
    800058d0:	04054b63          	bltz	a0,80005926 <sys_chdir+0x86>
    800058d4:	f6040513          	addi	a0,s0,-160
    800058d8:	ffffe097          	auipc	ra,0xffffe
    800058dc:	592080e7          	jalr	1426(ra) # 80003e6a <namei>
    800058e0:	84aa                	mv	s1,a0
    800058e2:	c131                	beqz	a0,80005926 <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    800058e4:	ffffe097          	auipc	ra,0xffffe
    800058e8:	dd0080e7          	jalr	-560(ra) # 800036b4 <ilock>
  if(ip->type != T_DIR){
    800058ec:	04449703          	lh	a4,68(s1)
    800058f0:	4785                	li	a5,1
    800058f2:	04f71063          	bne	a4,a5,80005932 <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    800058f6:	8526                	mv	a0,s1
    800058f8:	ffffe097          	auipc	ra,0xffffe
    800058fc:	e7e080e7          	jalr	-386(ra) # 80003776 <iunlock>
  iput(p->cwd);
    80005900:	15093503          	ld	a0,336(s2)
    80005904:	ffffe097          	auipc	ra,0xffffe
    80005908:	f6a080e7          	jalr	-150(ra) # 8000386e <iput>
  end_op();
    8000590c:	ffffe097          	auipc	ra,0xffffe
    80005910:	7fa080e7          	jalr	2042(ra) # 80004106 <end_op>
  p->cwd = ip;
    80005914:	14993823          	sd	s1,336(s2)
  return 0;
    80005918:	4501                	li	a0,0
}
    8000591a:	60ea                	ld	ra,152(sp)
    8000591c:	644a                	ld	s0,144(sp)
    8000591e:	64aa                	ld	s1,136(sp)
    80005920:	690a                	ld	s2,128(sp)
    80005922:	610d                	addi	sp,sp,160
    80005924:	8082                	ret
    end_op();
    80005926:	ffffe097          	auipc	ra,0xffffe
    8000592a:	7e0080e7          	jalr	2016(ra) # 80004106 <end_op>
    return -1;
    8000592e:	557d                	li	a0,-1
    80005930:	b7ed                	j	8000591a <sys_chdir+0x7a>
    iunlockput(ip);
    80005932:	8526                	mv	a0,s1
    80005934:	ffffe097          	auipc	ra,0xffffe
    80005938:	fe2080e7          	jalr	-30(ra) # 80003916 <iunlockput>
    end_op();
    8000593c:	ffffe097          	auipc	ra,0xffffe
    80005940:	7ca080e7          	jalr	1994(ra) # 80004106 <end_op>
    return -1;
    80005944:	557d                	li	a0,-1
    80005946:	bfd1                	j	8000591a <sys_chdir+0x7a>

0000000080005948 <sys_exec>:

uint64
sys_exec(void)
{
    80005948:	7145                	addi	sp,sp,-464
    8000594a:	e786                	sd	ra,456(sp)
    8000594c:	e3a2                	sd	s0,448(sp)
    8000594e:	ff26                	sd	s1,440(sp)
    80005950:	fb4a                	sd	s2,432(sp)
    80005952:	f74e                	sd	s3,424(sp)
    80005954:	f352                	sd	s4,416(sp)
    80005956:	ef56                	sd	s5,408(sp)
    80005958:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    8000595a:	08000613          	li	a2,128
    8000595e:	f4040593          	addi	a1,s0,-192
    80005962:	4501                	li	a0,0
    80005964:	ffffd097          	auipc	ra,0xffffd
    80005968:	1f0080e7          	jalr	496(ra) # 80002b54 <argstr>
    return -1;
    8000596c:	597d                	li	s2,-1
  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    8000596e:	0c054a63          	bltz	a0,80005a42 <sys_exec+0xfa>
    80005972:	e3840593          	addi	a1,s0,-456
    80005976:	4505                	li	a0,1
    80005978:	ffffd097          	auipc	ra,0xffffd
    8000597c:	1ba080e7          	jalr	442(ra) # 80002b32 <argaddr>
    80005980:	0c054163          	bltz	a0,80005a42 <sys_exec+0xfa>
  }
  memset(argv, 0, sizeof(argv));
    80005984:	10000613          	li	a2,256
    80005988:	4581                	li	a1,0
    8000598a:	e4040513          	addi	a0,s0,-448
    8000598e:	ffffb097          	auipc	ra,0xffffb
    80005992:	344080e7          	jalr	836(ra) # 80000cd2 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005996:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    8000599a:	89a6                	mv	s3,s1
    8000599c:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    8000599e:	02000a13          	li	s4,32
    800059a2:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    800059a6:	00391513          	slli	a0,s2,0x3
    800059aa:	e3040593          	addi	a1,s0,-464
    800059ae:	e3843783          	ld	a5,-456(s0)
    800059b2:	953e                	add	a0,a0,a5
    800059b4:	ffffd097          	auipc	ra,0xffffd
    800059b8:	0c2080e7          	jalr	194(ra) # 80002a76 <fetchaddr>
    800059bc:	02054a63          	bltz	a0,800059f0 <sys_exec+0xa8>
      goto bad;
    }
    if(uarg == 0){
    800059c0:	e3043783          	ld	a5,-464(s0)
    800059c4:	c3b9                	beqz	a5,80005a0a <sys_exec+0xc2>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    800059c6:	ffffb097          	auipc	ra,0xffffb
    800059ca:	120080e7          	jalr	288(ra) # 80000ae6 <kalloc>
    800059ce:	85aa                	mv	a1,a0
    800059d0:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    800059d4:	cd11                	beqz	a0,800059f0 <sys_exec+0xa8>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    800059d6:	6605                	lui	a2,0x1
    800059d8:	e3043503          	ld	a0,-464(s0)
    800059dc:	ffffd097          	auipc	ra,0xffffd
    800059e0:	0ec080e7          	jalr	236(ra) # 80002ac8 <fetchstr>
    800059e4:	00054663          	bltz	a0,800059f0 <sys_exec+0xa8>
    if(i >= NELEM(argv)){
    800059e8:	0905                	addi	s2,s2,1
    800059ea:	09a1                	addi	s3,s3,8
    800059ec:	fb491be3          	bne	s2,s4,800059a2 <sys_exec+0x5a>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800059f0:	10048913          	addi	s2,s1,256
    800059f4:	6088                	ld	a0,0(s1)
    800059f6:	c529                	beqz	a0,80005a40 <sys_exec+0xf8>
    kfree(argv[i]);
    800059f8:	ffffb097          	auipc	ra,0xffffb
    800059fc:	ff2080e7          	jalr	-14(ra) # 800009ea <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005a00:	04a1                	addi	s1,s1,8
    80005a02:	ff2499e3          	bne	s1,s2,800059f4 <sys_exec+0xac>
  return -1;
    80005a06:	597d                	li	s2,-1
    80005a08:	a82d                	j	80005a42 <sys_exec+0xfa>
      argv[i] = 0;
    80005a0a:	0a8e                	slli	s5,s5,0x3
    80005a0c:	fc040793          	addi	a5,s0,-64
    80005a10:	9abe                	add	s5,s5,a5
    80005a12:	e80ab023          	sd	zero,-384(s5)
  int ret = exec(path, argv);
    80005a16:	e4040593          	addi	a1,s0,-448
    80005a1a:	f4040513          	addi	a0,s0,-192
    80005a1e:	fffff097          	auipc	ra,0xfffff
    80005a22:	194080e7          	jalr	404(ra) # 80004bb2 <exec>
    80005a26:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005a28:	10048993          	addi	s3,s1,256
    80005a2c:	6088                	ld	a0,0(s1)
    80005a2e:	c911                	beqz	a0,80005a42 <sys_exec+0xfa>
    kfree(argv[i]);
    80005a30:	ffffb097          	auipc	ra,0xffffb
    80005a34:	fba080e7          	jalr	-70(ra) # 800009ea <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005a38:	04a1                	addi	s1,s1,8
    80005a3a:	ff3499e3          	bne	s1,s3,80005a2c <sys_exec+0xe4>
    80005a3e:	a011                	j	80005a42 <sys_exec+0xfa>
  return -1;
    80005a40:	597d                	li	s2,-1
}
    80005a42:	854a                	mv	a0,s2
    80005a44:	60be                	ld	ra,456(sp)
    80005a46:	641e                	ld	s0,448(sp)
    80005a48:	74fa                	ld	s1,440(sp)
    80005a4a:	795a                	ld	s2,432(sp)
    80005a4c:	79ba                	ld	s3,424(sp)
    80005a4e:	7a1a                	ld	s4,416(sp)
    80005a50:	6afa                	ld	s5,408(sp)
    80005a52:	6179                	addi	sp,sp,464
    80005a54:	8082                	ret

0000000080005a56 <sys_pipe>:

uint64
sys_pipe(void)
{
    80005a56:	7139                	addi	sp,sp,-64
    80005a58:	fc06                	sd	ra,56(sp)
    80005a5a:	f822                	sd	s0,48(sp)
    80005a5c:	f426                	sd	s1,40(sp)
    80005a5e:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005a60:	ffffc097          	auipc	ra,0xffffc
    80005a64:	f34080e7          	jalr	-204(ra) # 80001994 <myproc>
    80005a68:	84aa                	mv	s1,a0

  if(argaddr(0, &fdarray) < 0)
    80005a6a:	fd840593          	addi	a1,s0,-40
    80005a6e:	4501                	li	a0,0
    80005a70:	ffffd097          	auipc	ra,0xffffd
    80005a74:	0c2080e7          	jalr	194(ra) # 80002b32 <argaddr>
    return -1;
    80005a78:	57fd                	li	a5,-1
  if(argaddr(0, &fdarray) < 0)
    80005a7a:	0e054063          	bltz	a0,80005b5a <sys_pipe+0x104>
  if(pipealloc(&rf, &wf) < 0)
    80005a7e:	fc840593          	addi	a1,s0,-56
    80005a82:	fd040513          	addi	a0,s0,-48
    80005a86:	fffff097          	auipc	ra,0xfffff
    80005a8a:	dfc080e7          	jalr	-516(ra) # 80004882 <pipealloc>
    return -1;
    80005a8e:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005a90:	0c054563          	bltz	a0,80005b5a <sys_pipe+0x104>
  fd0 = -1;
    80005a94:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005a98:	fd043503          	ld	a0,-48(s0)
    80005a9c:	fffff097          	auipc	ra,0xfffff
    80005aa0:	508080e7          	jalr	1288(ra) # 80004fa4 <fdalloc>
    80005aa4:	fca42223          	sw	a0,-60(s0)
    80005aa8:	08054c63          	bltz	a0,80005b40 <sys_pipe+0xea>
    80005aac:	fc843503          	ld	a0,-56(s0)
    80005ab0:	fffff097          	auipc	ra,0xfffff
    80005ab4:	4f4080e7          	jalr	1268(ra) # 80004fa4 <fdalloc>
    80005ab8:	fca42023          	sw	a0,-64(s0)
    80005abc:	06054863          	bltz	a0,80005b2c <sys_pipe+0xd6>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005ac0:	4691                	li	a3,4
    80005ac2:	fc440613          	addi	a2,s0,-60
    80005ac6:	fd843583          	ld	a1,-40(s0)
    80005aca:	68a8                	ld	a0,80(s1)
    80005acc:	ffffc097          	auipc	ra,0xffffc
    80005ad0:	b8a080e7          	jalr	-1142(ra) # 80001656 <copyout>
    80005ad4:	02054063          	bltz	a0,80005af4 <sys_pipe+0x9e>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005ad8:	4691                	li	a3,4
    80005ada:	fc040613          	addi	a2,s0,-64
    80005ade:	fd843583          	ld	a1,-40(s0)
    80005ae2:	0591                	addi	a1,a1,4
    80005ae4:	68a8                	ld	a0,80(s1)
    80005ae6:	ffffc097          	auipc	ra,0xffffc
    80005aea:	b70080e7          	jalr	-1168(ra) # 80001656 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005aee:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005af0:	06055563          	bgez	a0,80005b5a <sys_pipe+0x104>
    p->ofile[fd0] = 0;
    80005af4:	fc442783          	lw	a5,-60(s0)
    80005af8:	07e9                	addi	a5,a5,26
    80005afa:	078e                	slli	a5,a5,0x3
    80005afc:	97a6                	add	a5,a5,s1
    80005afe:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80005b02:	fc042503          	lw	a0,-64(s0)
    80005b06:	0569                	addi	a0,a0,26
    80005b08:	050e                	slli	a0,a0,0x3
    80005b0a:	9526                	add	a0,a0,s1
    80005b0c:	00053023          	sd	zero,0(a0)
    fileclose(rf);
    80005b10:	fd043503          	ld	a0,-48(s0)
    80005b14:	fffff097          	auipc	ra,0xfffff
    80005b18:	a3e080e7          	jalr	-1474(ra) # 80004552 <fileclose>
    fileclose(wf);
    80005b1c:	fc843503          	ld	a0,-56(s0)
    80005b20:	fffff097          	auipc	ra,0xfffff
    80005b24:	a32080e7          	jalr	-1486(ra) # 80004552 <fileclose>
    return -1;
    80005b28:	57fd                	li	a5,-1
    80005b2a:	a805                	j	80005b5a <sys_pipe+0x104>
    if(fd0 >= 0)
    80005b2c:	fc442783          	lw	a5,-60(s0)
    80005b30:	0007c863          	bltz	a5,80005b40 <sys_pipe+0xea>
      p->ofile[fd0] = 0;
    80005b34:	01a78513          	addi	a0,a5,26
    80005b38:	050e                	slli	a0,a0,0x3
    80005b3a:	9526                	add	a0,a0,s1
    80005b3c:	00053023          	sd	zero,0(a0)
    fileclose(rf);
    80005b40:	fd043503          	ld	a0,-48(s0)
    80005b44:	fffff097          	auipc	ra,0xfffff
    80005b48:	a0e080e7          	jalr	-1522(ra) # 80004552 <fileclose>
    fileclose(wf);
    80005b4c:	fc843503          	ld	a0,-56(s0)
    80005b50:	fffff097          	auipc	ra,0xfffff
    80005b54:	a02080e7          	jalr	-1534(ra) # 80004552 <fileclose>
    return -1;
    80005b58:	57fd                	li	a5,-1
}
    80005b5a:	853e                	mv	a0,a5
    80005b5c:	70e2                	ld	ra,56(sp)
    80005b5e:	7442                	ld	s0,48(sp)
    80005b60:	74a2                	ld	s1,40(sp)
    80005b62:	6121                	addi	sp,sp,64
    80005b64:	8082                	ret
	...

0000000080005b70 <kernelvec>:
    80005b70:	7111                	addi	sp,sp,-256
    80005b72:	e006                	sd	ra,0(sp)
    80005b74:	e40a                	sd	sp,8(sp)
    80005b76:	e80e                	sd	gp,16(sp)
    80005b78:	ec12                	sd	tp,24(sp)
    80005b7a:	f016                	sd	t0,32(sp)
    80005b7c:	f41a                	sd	t1,40(sp)
    80005b7e:	f81e                	sd	t2,48(sp)
    80005b80:	fc22                	sd	s0,56(sp)
    80005b82:	e0a6                	sd	s1,64(sp)
    80005b84:	e4aa                	sd	a0,72(sp)
    80005b86:	e8ae                	sd	a1,80(sp)
    80005b88:	ecb2                	sd	a2,88(sp)
    80005b8a:	f0b6                	sd	a3,96(sp)
    80005b8c:	f4ba                	sd	a4,104(sp)
    80005b8e:	f8be                	sd	a5,112(sp)
    80005b90:	fcc2                	sd	a6,120(sp)
    80005b92:	e146                	sd	a7,128(sp)
    80005b94:	e54a                	sd	s2,136(sp)
    80005b96:	e94e                	sd	s3,144(sp)
    80005b98:	ed52                	sd	s4,152(sp)
    80005b9a:	f156                	sd	s5,160(sp)
    80005b9c:	f55a                	sd	s6,168(sp)
    80005b9e:	f95e                	sd	s7,176(sp)
    80005ba0:	fd62                	sd	s8,184(sp)
    80005ba2:	e1e6                	sd	s9,192(sp)
    80005ba4:	e5ea                	sd	s10,200(sp)
    80005ba6:	e9ee                	sd	s11,208(sp)
    80005ba8:	edf2                	sd	t3,216(sp)
    80005baa:	f1f6                	sd	t4,224(sp)
    80005bac:	f5fa                	sd	t5,232(sp)
    80005bae:	f9fe                	sd	t6,240(sp)
    80005bb0:	d93fc0ef          	jal	ra,80002942 <kerneltrap>
    80005bb4:	6082                	ld	ra,0(sp)
    80005bb6:	6122                	ld	sp,8(sp)
    80005bb8:	61c2                	ld	gp,16(sp)
    80005bba:	7282                	ld	t0,32(sp)
    80005bbc:	7322                	ld	t1,40(sp)
    80005bbe:	73c2                	ld	t2,48(sp)
    80005bc0:	7462                	ld	s0,56(sp)
    80005bc2:	6486                	ld	s1,64(sp)
    80005bc4:	6526                	ld	a0,72(sp)
    80005bc6:	65c6                	ld	a1,80(sp)
    80005bc8:	6666                	ld	a2,88(sp)
    80005bca:	7686                	ld	a3,96(sp)
    80005bcc:	7726                	ld	a4,104(sp)
    80005bce:	77c6                	ld	a5,112(sp)
    80005bd0:	7866                	ld	a6,120(sp)
    80005bd2:	688a                	ld	a7,128(sp)
    80005bd4:	692a                	ld	s2,136(sp)
    80005bd6:	69ca                	ld	s3,144(sp)
    80005bd8:	6a6a                	ld	s4,152(sp)
    80005bda:	7a8a                	ld	s5,160(sp)
    80005bdc:	7b2a                	ld	s6,168(sp)
    80005bde:	7bca                	ld	s7,176(sp)
    80005be0:	7c6a                	ld	s8,184(sp)
    80005be2:	6c8e                	ld	s9,192(sp)
    80005be4:	6d2e                	ld	s10,200(sp)
    80005be6:	6dce                	ld	s11,208(sp)
    80005be8:	6e6e                	ld	t3,216(sp)
    80005bea:	7e8e                	ld	t4,224(sp)
    80005bec:	7f2e                	ld	t5,232(sp)
    80005bee:	7fce                	ld	t6,240(sp)
    80005bf0:	6111                	addi	sp,sp,256
    80005bf2:	10200073          	sret
    80005bf6:	00000013          	nop
    80005bfa:	00000013          	nop
    80005bfe:	0001                	nop

0000000080005c00 <timervec>:
    80005c00:	34051573          	csrrw	a0,mscratch,a0
    80005c04:	e10c                	sd	a1,0(a0)
    80005c06:	e510                	sd	a2,8(a0)
    80005c08:	e914                	sd	a3,16(a0)
    80005c0a:	6d0c                	ld	a1,24(a0)
    80005c0c:	7110                	ld	a2,32(a0)
    80005c0e:	6194                	ld	a3,0(a1)
    80005c10:	96b2                	add	a3,a3,a2
    80005c12:	e194                	sd	a3,0(a1)
    80005c14:	4589                	li	a1,2
    80005c16:	14459073          	csrw	sip,a1
    80005c1a:	6914                	ld	a3,16(a0)
    80005c1c:	6510                	ld	a2,8(a0)
    80005c1e:	610c                	ld	a1,0(a0)
    80005c20:	34051573          	csrrw	a0,mscratch,a0
    80005c24:	30200073          	mret
	...

0000000080005c2a <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    80005c2a:	1141                	addi	sp,sp,-16
    80005c2c:	e422                	sd	s0,8(sp)
    80005c2e:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80005c30:	0c0007b7          	lui	a5,0xc000
    80005c34:	4705                	li	a4,1
    80005c36:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80005c38:	c3d8                	sw	a4,4(a5)
}
    80005c3a:	6422                	ld	s0,8(sp)
    80005c3c:	0141                	addi	sp,sp,16
    80005c3e:	8082                	ret

0000000080005c40 <plicinithart>:

void
plicinithart(void)
{
    80005c40:	1141                	addi	sp,sp,-16
    80005c42:	e406                	sd	ra,8(sp)
    80005c44:	e022                	sd	s0,0(sp)
    80005c46:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005c48:	ffffc097          	auipc	ra,0xffffc
    80005c4c:	d20080e7          	jalr	-736(ra) # 80001968 <cpuid>
  
  // set uart's enable bit for this hart's S-mode. 
  *(uint32*)PLIC_SENABLE(hart)= (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005c50:	0085171b          	slliw	a4,a0,0x8
    80005c54:	0c0027b7          	lui	a5,0xc002
    80005c58:	97ba                	add	a5,a5,a4
    80005c5a:	40200713          	li	a4,1026
    80005c5e:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005c62:	00d5151b          	slliw	a0,a0,0xd
    80005c66:	0c2017b7          	lui	a5,0xc201
    80005c6a:	953e                	add	a0,a0,a5
    80005c6c:	00052023          	sw	zero,0(a0)
}
    80005c70:	60a2                	ld	ra,8(sp)
    80005c72:	6402                	ld	s0,0(sp)
    80005c74:	0141                	addi	sp,sp,16
    80005c76:	8082                	ret

0000000080005c78 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80005c78:	1141                	addi	sp,sp,-16
    80005c7a:	e406                	sd	ra,8(sp)
    80005c7c:	e022                	sd	s0,0(sp)
    80005c7e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005c80:	ffffc097          	auipc	ra,0xffffc
    80005c84:	ce8080e7          	jalr	-792(ra) # 80001968 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80005c88:	00d5179b          	slliw	a5,a0,0xd
    80005c8c:	0c201537          	lui	a0,0xc201
    80005c90:	953e                	add	a0,a0,a5
  return irq;
}
    80005c92:	4148                	lw	a0,4(a0)
    80005c94:	60a2                	ld	ra,8(sp)
    80005c96:	6402                	ld	s0,0(sp)
    80005c98:	0141                	addi	sp,sp,16
    80005c9a:	8082                	ret

0000000080005c9c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80005c9c:	1101                	addi	sp,sp,-32
    80005c9e:	ec06                	sd	ra,24(sp)
    80005ca0:	e822                	sd	s0,16(sp)
    80005ca2:	e426                	sd	s1,8(sp)
    80005ca4:	1000                	addi	s0,sp,32
    80005ca6:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005ca8:	ffffc097          	auipc	ra,0xffffc
    80005cac:	cc0080e7          	jalr	-832(ra) # 80001968 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80005cb0:	00d5151b          	slliw	a0,a0,0xd
    80005cb4:	0c2017b7          	lui	a5,0xc201
    80005cb8:	97aa                	add	a5,a5,a0
    80005cba:	c3c4                	sw	s1,4(a5)
}
    80005cbc:	60e2                	ld	ra,24(sp)
    80005cbe:	6442                	ld	s0,16(sp)
    80005cc0:	64a2                	ld	s1,8(sp)
    80005cc2:	6105                	addi	sp,sp,32
    80005cc4:	8082                	ret

0000000080005cc6 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80005cc6:	1141                	addi	sp,sp,-16
    80005cc8:	e406                	sd	ra,8(sp)
    80005cca:	e022                	sd	s0,0(sp)
    80005ccc:	0800                	addi	s0,sp,16
  if(i >= NUM)
    80005cce:	479d                	li	a5,7
    80005cd0:	06a7c963          	blt	a5,a0,80005d42 <free_desc+0x7c>
    panic("free_desc 1");
  if(disk.free[i])
    80005cd4:	0001d797          	auipc	a5,0x1d
    80005cd8:	32c78793          	addi	a5,a5,812 # 80023000 <disk>
    80005cdc:	00a78733          	add	a4,a5,a0
    80005ce0:	6789                	lui	a5,0x2
    80005ce2:	97ba                	add	a5,a5,a4
    80005ce4:	0187c783          	lbu	a5,24(a5) # 2018 <_entry-0x7fffdfe8>
    80005ce8:	e7ad                	bnez	a5,80005d52 <free_desc+0x8c>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80005cea:	00451793          	slli	a5,a0,0x4
    80005cee:	0001f717          	auipc	a4,0x1f
    80005cf2:	31270713          	addi	a4,a4,786 # 80025000 <disk+0x2000>
    80005cf6:	6314                	ld	a3,0(a4)
    80005cf8:	96be                	add	a3,a3,a5
    80005cfa:	0006b023          	sd	zero,0(a3)
  disk.desc[i].len = 0;
    80005cfe:	6314                	ld	a3,0(a4)
    80005d00:	96be                	add	a3,a3,a5
    80005d02:	0006a423          	sw	zero,8(a3)
  disk.desc[i].flags = 0;
    80005d06:	6314                	ld	a3,0(a4)
    80005d08:	96be                	add	a3,a3,a5
    80005d0a:	00069623          	sh	zero,12(a3)
  disk.desc[i].next = 0;
    80005d0e:	6318                	ld	a4,0(a4)
    80005d10:	97ba                	add	a5,a5,a4
    80005d12:	00079723          	sh	zero,14(a5)
  disk.free[i] = 1;
    80005d16:	0001d797          	auipc	a5,0x1d
    80005d1a:	2ea78793          	addi	a5,a5,746 # 80023000 <disk>
    80005d1e:	97aa                	add	a5,a5,a0
    80005d20:	6509                	lui	a0,0x2
    80005d22:	953e                	add	a0,a0,a5
    80005d24:	4785                	li	a5,1
    80005d26:	00f50c23          	sb	a5,24(a0) # 2018 <_entry-0x7fffdfe8>
  wakeup(&disk.free[0]);
    80005d2a:	0001f517          	auipc	a0,0x1f
    80005d2e:	2ee50513          	addi	a0,a0,750 # 80025018 <disk+0x2018>
    80005d32:	ffffc097          	auipc	ra,0xffffc
    80005d36:	4b0080e7          	jalr	1200(ra) # 800021e2 <wakeup>
}
    80005d3a:	60a2                	ld	ra,8(sp)
    80005d3c:	6402                	ld	s0,0(sp)
    80005d3e:	0141                	addi	sp,sp,16
    80005d40:	8082                	ret
    panic("free_desc 1");
    80005d42:	00003517          	auipc	a0,0x3
    80005d46:	a1650513          	addi	a0,a0,-1514 # 80008758 <syscalls+0x328>
    80005d4a:	ffffa097          	auipc	ra,0xffffa
    80005d4e:	7e6080e7          	jalr	2022(ra) # 80000530 <panic>
    panic("free_desc 2");
    80005d52:	00003517          	auipc	a0,0x3
    80005d56:	a1650513          	addi	a0,a0,-1514 # 80008768 <syscalls+0x338>
    80005d5a:	ffffa097          	auipc	ra,0xffffa
    80005d5e:	7d6080e7          	jalr	2006(ra) # 80000530 <panic>

0000000080005d62 <virtio_disk_init>:
{
    80005d62:	1101                	addi	sp,sp,-32
    80005d64:	ec06                	sd	ra,24(sp)
    80005d66:	e822                	sd	s0,16(sp)
    80005d68:	e426                	sd	s1,8(sp)
    80005d6a:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80005d6c:	00003597          	auipc	a1,0x3
    80005d70:	a0c58593          	addi	a1,a1,-1524 # 80008778 <syscalls+0x348>
    80005d74:	0001f517          	auipc	a0,0x1f
    80005d78:	3b450513          	addi	a0,a0,948 # 80025128 <disk+0x2128>
    80005d7c:	ffffb097          	auipc	ra,0xffffb
    80005d80:	dca080e7          	jalr	-566(ra) # 80000b46 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005d84:	100017b7          	lui	a5,0x10001
    80005d88:	4398                	lw	a4,0(a5)
    80005d8a:	2701                	sext.w	a4,a4
    80005d8c:	747277b7          	lui	a5,0x74727
    80005d90:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80005d94:	0ef71163          	bne	a4,a5,80005e76 <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    80005d98:	100017b7          	lui	a5,0x10001
    80005d9c:	43dc                	lw	a5,4(a5)
    80005d9e:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005da0:	4705                	li	a4,1
    80005da2:	0ce79a63          	bne	a5,a4,80005e76 <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005da6:	100017b7          	lui	a5,0x10001
    80005daa:	479c                	lw	a5,8(a5)
    80005dac:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    80005dae:	4709                	li	a4,2
    80005db0:	0ce79363          	bne	a5,a4,80005e76 <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80005db4:	100017b7          	lui	a5,0x10001
    80005db8:	47d8                	lw	a4,12(a5)
    80005dba:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005dbc:	554d47b7          	lui	a5,0x554d4
    80005dc0:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80005dc4:	0af71963          	bne	a4,a5,80005e76 <virtio_disk_init+0x114>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005dc8:	100017b7          	lui	a5,0x10001
    80005dcc:	4705                	li	a4,1
    80005dce:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005dd0:	470d                	li	a4,3
    80005dd2:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    80005dd4:	4b94                	lw	a3,16(a5)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80005dd6:	c7ffe737          	lui	a4,0xc7ffe
    80005dda:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fd875f>
    80005dde:	8f75                	and	a4,a4,a3
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80005de0:	2701                	sext.w	a4,a4
    80005de2:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005de4:	472d                	li	a4,11
    80005de6:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005de8:	473d                	li	a4,15
    80005dea:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_GUEST_PAGE_SIZE) = PGSIZE;
    80005dec:	6705                	lui	a4,0x1
    80005dee:	d798                	sw	a4,40(a5)
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80005df0:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80005df4:	5bdc                	lw	a5,52(a5)
    80005df6:	2781                	sext.w	a5,a5
  if(max == 0)
    80005df8:	c7d9                	beqz	a5,80005e86 <virtio_disk_init+0x124>
  if(max < NUM)
    80005dfa:	471d                	li	a4,7
    80005dfc:	08f77d63          	bgeu	a4,a5,80005e96 <virtio_disk_init+0x134>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80005e00:	100014b7          	lui	s1,0x10001
    80005e04:	47a1                	li	a5,8
    80005e06:	dc9c                	sw	a5,56(s1)
  memset(disk.pages, 0, sizeof(disk.pages));
    80005e08:	6609                	lui	a2,0x2
    80005e0a:	4581                	li	a1,0
    80005e0c:	0001d517          	auipc	a0,0x1d
    80005e10:	1f450513          	addi	a0,a0,500 # 80023000 <disk>
    80005e14:	ffffb097          	auipc	ra,0xffffb
    80005e18:	ebe080e7          	jalr	-322(ra) # 80000cd2 <memset>
  *R(VIRTIO_MMIO_QUEUE_PFN) = ((uint64)disk.pages) >> PGSHIFT;
    80005e1c:	0001d717          	auipc	a4,0x1d
    80005e20:	1e470713          	addi	a4,a4,484 # 80023000 <disk>
    80005e24:	00c75793          	srli	a5,a4,0xc
    80005e28:	2781                	sext.w	a5,a5
    80005e2a:	c0bc                	sw	a5,64(s1)
  disk.desc = (struct virtq_desc *) disk.pages;
    80005e2c:	0001f797          	auipc	a5,0x1f
    80005e30:	1d478793          	addi	a5,a5,468 # 80025000 <disk+0x2000>
    80005e34:	e398                	sd	a4,0(a5)
  disk.avail = (struct virtq_avail *)(disk.pages + NUM*sizeof(struct virtq_desc));
    80005e36:	0001d717          	auipc	a4,0x1d
    80005e3a:	24a70713          	addi	a4,a4,586 # 80023080 <disk+0x80>
    80005e3e:	e798                	sd	a4,8(a5)
  disk.used = (struct virtq_used *) (disk.pages + PGSIZE);
    80005e40:	0001e717          	auipc	a4,0x1e
    80005e44:	1c070713          	addi	a4,a4,448 # 80024000 <disk+0x1000>
    80005e48:	eb98                	sd	a4,16(a5)
    disk.free[i] = 1;
    80005e4a:	4705                	li	a4,1
    80005e4c:	00e78c23          	sb	a4,24(a5)
    80005e50:	00e78ca3          	sb	a4,25(a5)
    80005e54:	00e78d23          	sb	a4,26(a5)
    80005e58:	00e78da3          	sb	a4,27(a5)
    80005e5c:	00e78e23          	sb	a4,28(a5)
    80005e60:	00e78ea3          	sb	a4,29(a5)
    80005e64:	00e78f23          	sb	a4,30(a5)
    80005e68:	00e78fa3          	sb	a4,31(a5)
}
    80005e6c:	60e2                	ld	ra,24(sp)
    80005e6e:	6442                	ld	s0,16(sp)
    80005e70:	64a2                	ld	s1,8(sp)
    80005e72:	6105                	addi	sp,sp,32
    80005e74:	8082                	ret
    panic("could not find virtio disk");
    80005e76:	00003517          	auipc	a0,0x3
    80005e7a:	91250513          	addi	a0,a0,-1774 # 80008788 <syscalls+0x358>
    80005e7e:	ffffa097          	auipc	ra,0xffffa
    80005e82:	6b2080e7          	jalr	1714(ra) # 80000530 <panic>
    panic("virtio disk has no queue 0");
    80005e86:	00003517          	auipc	a0,0x3
    80005e8a:	92250513          	addi	a0,a0,-1758 # 800087a8 <syscalls+0x378>
    80005e8e:	ffffa097          	auipc	ra,0xffffa
    80005e92:	6a2080e7          	jalr	1698(ra) # 80000530 <panic>
    panic("virtio disk max queue too short");
    80005e96:	00003517          	auipc	a0,0x3
    80005e9a:	93250513          	addi	a0,a0,-1742 # 800087c8 <syscalls+0x398>
    80005e9e:	ffffa097          	auipc	ra,0xffffa
    80005ea2:	692080e7          	jalr	1682(ra) # 80000530 <panic>

0000000080005ea6 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80005ea6:	7159                	addi	sp,sp,-112
    80005ea8:	f486                	sd	ra,104(sp)
    80005eaa:	f0a2                	sd	s0,96(sp)
    80005eac:	eca6                	sd	s1,88(sp)
    80005eae:	e8ca                	sd	s2,80(sp)
    80005eb0:	e4ce                	sd	s3,72(sp)
    80005eb2:	e0d2                	sd	s4,64(sp)
    80005eb4:	fc56                	sd	s5,56(sp)
    80005eb6:	f85a                	sd	s6,48(sp)
    80005eb8:	f45e                	sd	s7,40(sp)
    80005eba:	f062                	sd	s8,32(sp)
    80005ebc:	ec66                	sd	s9,24(sp)
    80005ebe:	e86a                	sd	s10,16(sp)
    80005ec0:	1880                	addi	s0,sp,112
    80005ec2:	892a                	mv	s2,a0
    80005ec4:	8d2e                	mv	s10,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80005ec6:	00c52c83          	lw	s9,12(a0)
    80005eca:	001c9c9b          	slliw	s9,s9,0x1
    80005ece:	1c82                	slli	s9,s9,0x20
    80005ed0:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    80005ed4:	0001f517          	auipc	a0,0x1f
    80005ed8:	25450513          	addi	a0,a0,596 # 80025128 <disk+0x2128>
    80005edc:	ffffb097          	auipc	ra,0xffffb
    80005ee0:	cfa080e7          	jalr	-774(ra) # 80000bd6 <acquire>
  for(int i = 0; i < 3; i++){
    80005ee4:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    80005ee6:	4c21                	li	s8,8
      disk.free[i] = 0;
    80005ee8:	0001db97          	auipc	s7,0x1d
    80005eec:	118b8b93          	addi	s7,s7,280 # 80023000 <disk>
    80005ef0:	6b09                	lui	s6,0x2
  for(int i = 0; i < 3; i++){
    80005ef2:	4a8d                	li	s5,3
  for(int i = 0; i < NUM; i++){
    80005ef4:	8a4e                	mv	s4,s3
    80005ef6:	a051                	j	80005f7a <virtio_disk_rw+0xd4>
      disk.free[i] = 0;
    80005ef8:	00fb86b3          	add	a3,s7,a5
    80005efc:	96da                	add	a3,a3,s6
    80005efe:	00068c23          	sb	zero,24(a3)
    idx[i] = alloc_desc();
    80005f02:	c21c                	sw	a5,0(a2)
    if(idx[i] < 0){
    80005f04:	0207c563          	bltz	a5,80005f2e <virtio_disk_rw+0x88>
  for(int i = 0; i < 3; i++){
    80005f08:	2485                	addiw	s1,s1,1
    80005f0a:	0711                	addi	a4,a4,4
    80005f0c:	25548063          	beq	s1,s5,8000614c <virtio_disk_rw+0x2a6>
    idx[i] = alloc_desc();
    80005f10:	863a                	mv	a2,a4
  for(int i = 0; i < NUM; i++){
    80005f12:	0001f697          	auipc	a3,0x1f
    80005f16:	10668693          	addi	a3,a3,262 # 80025018 <disk+0x2018>
    80005f1a:	87d2                	mv	a5,s4
    if(disk.free[i]){
    80005f1c:	0006c583          	lbu	a1,0(a3)
    80005f20:	fde1                	bnez	a1,80005ef8 <virtio_disk_rw+0x52>
  for(int i = 0; i < NUM; i++){
    80005f22:	2785                	addiw	a5,a5,1
    80005f24:	0685                	addi	a3,a3,1
    80005f26:	ff879be3          	bne	a5,s8,80005f1c <virtio_disk_rw+0x76>
    idx[i] = alloc_desc();
    80005f2a:	57fd                	li	a5,-1
    80005f2c:	c21c                	sw	a5,0(a2)
      for(int j = 0; j < i; j++)
    80005f2e:	02905a63          	blez	s1,80005f62 <virtio_disk_rw+0xbc>
        free_desc(idx[j]);
    80005f32:	f9042503          	lw	a0,-112(s0)
    80005f36:	00000097          	auipc	ra,0x0
    80005f3a:	d90080e7          	jalr	-624(ra) # 80005cc6 <free_desc>
      for(int j = 0; j < i; j++)
    80005f3e:	4785                	li	a5,1
    80005f40:	0297d163          	bge	a5,s1,80005f62 <virtio_disk_rw+0xbc>
        free_desc(idx[j]);
    80005f44:	f9442503          	lw	a0,-108(s0)
    80005f48:	00000097          	auipc	ra,0x0
    80005f4c:	d7e080e7          	jalr	-642(ra) # 80005cc6 <free_desc>
      for(int j = 0; j < i; j++)
    80005f50:	4789                	li	a5,2
    80005f52:	0097d863          	bge	a5,s1,80005f62 <virtio_disk_rw+0xbc>
        free_desc(idx[j]);
    80005f56:	f9842503          	lw	a0,-104(s0)
    80005f5a:	00000097          	auipc	ra,0x0
    80005f5e:	d6c080e7          	jalr	-660(ra) # 80005cc6 <free_desc>
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80005f62:	0001f597          	auipc	a1,0x1f
    80005f66:	1c658593          	addi	a1,a1,454 # 80025128 <disk+0x2128>
    80005f6a:	0001f517          	auipc	a0,0x1f
    80005f6e:	0ae50513          	addi	a0,a0,174 # 80025018 <disk+0x2018>
    80005f72:	ffffc097          	auipc	ra,0xffffc
    80005f76:	0e4080e7          	jalr	228(ra) # 80002056 <sleep>
  for(int i = 0; i < 3; i++){
    80005f7a:	f9040713          	addi	a4,s0,-112
    80005f7e:	84ce                	mv	s1,s3
    80005f80:	bf41                	j	80005f10 <virtio_disk_rw+0x6a>
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];

  if(write)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
    80005f82:	20058713          	addi	a4,a1,512
    80005f86:	00471693          	slli	a3,a4,0x4
    80005f8a:	0001d717          	auipc	a4,0x1d
    80005f8e:	07670713          	addi	a4,a4,118 # 80023000 <disk>
    80005f92:	9736                	add	a4,a4,a3
    80005f94:	4685                	li	a3,1
    80005f96:	0ad72423          	sw	a3,168(a4)
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80005f9a:	20058713          	addi	a4,a1,512
    80005f9e:	00471693          	slli	a3,a4,0x4
    80005fa2:	0001d717          	auipc	a4,0x1d
    80005fa6:	05e70713          	addi	a4,a4,94 # 80023000 <disk>
    80005faa:	9736                	add	a4,a4,a3
    80005fac:	0a072623          	sw	zero,172(a4)
  buf0->sector = sector;
    80005fb0:	0b973823          	sd	s9,176(a4)

  disk.desc[idx[0]].addr = (uint64) buf0;
    80005fb4:	7679                	lui	a2,0xffffe
    80005fb6:	963e                	add	a2,a2,a5
    80005fb8:	0001f697          	auipc	a3,0x1f
    80005fbc:	04868693          	addi	a3,a3,72 # 80025000 <disk+0x2000>
    80005fc0:	6298                	ld	a4,0(a3)
    80005fc2:	9732                	add	a4,a4,a2
    80005fc4:	e308                	sd	a0,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80005fc6:	6298                	ld	a4,0(a3)
    80005fc8:	9732                	add	a4,a4,a2
    80005fca:	4541                	li	a0,16
    80005fcc:	c708                	sw	a0,8(a4)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80005fce:	6298                	ld	a4,0(a3)
    80005fd0:	9732                	add	a4,a4,a2
    80005fd2:	4505                	li	a0,1
    80005fd4:	00a71623          	sh	a0,12(a4)
  disk.desc[idx[0]].next = idx[1];
    80005fd8:	f9442703          	lw	a4,-108(s0)
    80005fdc:	6288                	ld	a0,0(a3)
    80005fde:	962a                	add	a2,a2,a0
    80005fe0:	00e61723          	sh	a4,14(a2) # ffffffffffffe00e <end+0xffffffff7ffd800e>

  disk.desc[idx[1]].addr = (uint64) b->data;
    80005fe4:	0712                	slli	a4,a4,0x4
    80005fe6:	6290                	ld	a2,0(a3)
    80005fe8:	963a                	add	a2,a2,a4
    80005fea:	05890513          	addi	a0,s2,88
    80005fee:	e208                	sd	a0,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    80005ff0:	6294                	ld	a3,0(a3)
    80005ff2:	96ba                	add	a3,a3,a4
    80005ff4:	40000613          	li	a2,1024
    80005ff8:	c690                	sw	a2,8(a3)
  if(write)
    80005ffa:	140d0063          	beqz	s10,8000613a <virtio_disk_rw+0x294>
    disk.desc[idx[1]].flags = 0; // device reads b->data
    80005ffe:	0001f697          	auipc	a3,0x1f
    80006002:	0026b683          	ld	a3,2(a3) # 80025000 <disk+0x2000>
    80006006:	96ba                	add	a3,a3,a4
    80006008:	00069623          	sh	zero,12(a3)
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    8000600c:	0001d817          	auipc	a6,0x1d
    80006010:	ff480813          	addi	a6,a6,-12 # 80023000 <disk>
    80006014:	0001f517          	auipc	a0,0x1f
    80006018:	fec50513          	addi	a0,a0,-20 # 80025000 <disk+0x2000>
    8000601c:	6114                	ld	a3,0(a0)
    8000601e:	96ba                	add	a3,a3,a4
    80006020:	00c6d603          	lhu	a2,12(a3)
    80006024:	00166613          	ori	a2,a2,1
    80006028:	00c69623          	sh	a2,12(a3)
  disk.desc[idx[1]].next = idx[2];
    8000602c:	f9842683          	lw	a3,-104(s0)
    80006030:	6110                	ld	a2,0(a0)
    80006032:	9732                	add	a4,a4,a2
    80006034:	00d71723          	sh	a3,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80006038:	20058613          	addi	a2,a1,512
    8000603c:	0612                	slli	a2,a2,0x4
    8000603e:	9642                	add	a2,a2,a6
    80006040:	577d                	li	a4,-1
    80006042:	02e60823          	sb	a4,48(a2)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    80006046:	00469713          	slli	a4,a3,0x4
    8000604a:	6114                	ld	a3,0(a0)
    8000604c:	96ba                	add	a3,a3,a4
    8000604e:	03078793          	addi	a5,a5,48
    80006052:	97c2                	add	a5,a5,a6
    80006054:	e29c                	sd	a5,0(a3)
  disk.desc[idx[2]].len = 1;
    80006056:	611c                	ld	a5,0(a0)
    80006058:	97ba                	add	a5,a5,a4
    8000605a:	4685                	li	a3,1
    8000605c:	c794                	sw	a3,8(a5)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    8000605e:	611c                	ld	a5,0(a0)
    80006060:	97ba                	add	a5,a5,a4
    80006062:	4809                	li	a6,2
    80006064:	01079623          	sh	a6,12(a5)
  disk.desc[idx[2]].next = 0;
    80006068:	611c                	ld	a5,0(a0)
    8000606a:	973e                	add	a4,a4,a5
    8000606c:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80006070:	00d92223          	sw	a3,4(s2)
  disk.info[idx[0]].b = b;
    80006074:	03263423          	sd	s2,40(a2)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80006078:	6518                	ld	a4,8(a0)
    8000607a:	00275783          	lhu	a5,2(a4)
    8000607e:	8b9d                	andi	a5,a5,7
    80006080:	0786                	slli	a5,a5,0x1
    80006082:	97ba                	add	a5,a5,a4
    80006084:	00b79223          	sh	a1,4(a5)

  __sync_synchronize();
    80006088:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    8000608c:	6518                	ld	a4,8(a0)
    8000608e:	00275783          	lhu	a5,2(a4)
    80006092:	2785                	addiw	a5,a5,1
    80006094:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80006098:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    8000609c:	100017b7          	lui	a5,0x10001
    800060a0:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    800060a4:	00492703          	lw	a4,4(s2)
    800060a8:	4785                	li	a5,1
    800060aa:	02f71163          	bne	a4,a5,800060cc <virtio_disk_rw+0x226>
    sleep(b, &disk.vdisk_lock);
    800060ae:	0001f997          	auipc	s3,0x1f
    800060b2:	07a98993          	addi	s3,s3,122 # 80025128 <disk+0x2128>
  while(b->disk == 1) {
    800060b6:	4485                	li	s1,1
    sleep(b, &disk.vdisk_lock);
    800060b8:	85ce                	mv	a1,s3
    800060ba:	854a                	mv	a0,s2
    800060bc:	ffffc097          	auipc	ra,0xffffc
    800060c0:	f9a080e7          	jalr	-102(ra) # 80002056 <sleep>
  while(b->disk == 1) {
    800060c4:	00492783          	lw	a5,4(s2)
    800060c8:	fe9788e3          	beq	a5,s1,800060b8 <virtio_disk_rw+0x212>
  }

  disk.info[idx[0]].b = 0;
    800060cc:	f9042903          	lw	s2,-112(s0)
    800060d0:	20090793          	addi	a5,s2,512
    800060d4:	00479713          	slli	a4,a5,0x4
    800060d8:	0001d797          	auipc	a5,0x1d
    800060dc:	f2878793          	addi	a5,a5,-216 # 80023000 <disk>
    800060e0:	97ba                	add	a5,a5,a4
    800060e2:	0207b423          	sd	zero,40(a5)
    int flag = disk.desc[i].flags;
    800060e6:	0001f997          	auipc	s3,0x1f
    800060ea:	f1a98993          	addi	s3,s3,-230 # 80025000 <disk+0x2000>
    800060ee:	00491713          	slli	a4,s2,0x4
    800060f2:	0009b783          	ld	a5,0(s3)
    800060f6:	97ba                	add	a5,a5,a4
    800060f8:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    800060fc:	854a                	mv	a0,s2
    800060fe:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80006102:	00000097          	auipc	ra,0x0
    80006106:	bc4080e7          	jalr	-1084(ra) # 80005cc6 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    8000610a:	8885                	andi	s1,s1,1
    8000610c:	f0ed                	bnez	s1,800060ee <virtio_disk_rw+0x248>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    8000610e:	0001f517          	auipc	a0,0x1f
    80006112:	01a50513          	addi	a0,a0,26 # 80025128 <disk+0x2128>
    80006116:	ffffb097          	auipc	ra,0xffffb
    8000611a:	b74080e7          	jalr	-1164(ra) # 80000c8a <release>
}
    8000611e:	70a6                	ld	ra,104(sp)
    80006120:	7406                	ld	s0,96(sp)
    80006122:	64e6                	ld	s1,88(sp)
    80006124:	6946                	ld	s2,80(sp)
    80006126:	69a6                	ld	s3,72(sp)
    80006128:	6a06                	ld	s4,64(sp)
    8000612a:	7ae2                	ld	s5,56(sp)
    8000612c:	7b42                	ld	s6,48(sp)
    8000612e:	7ba2                	ld	s7,40(sp)
    80006130:	7c02                	ld	s8,32(sp)
    80006132:	6ce2                	ld	s9,24(sp)
    80006134:	6d42                	ld	s10,16(sp)
    80006136:	6165                	addi	sp,sp,112
    80006138:	8082                	ret
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    8000613a:	0001f697          	auipc	a3,0x1f
    8000613e:	ec66b683          	ld	a3,-314(a3) # 80025000 <disk+0x2000>
    80006142:	96ba                	add	a3,a3,a4
    80006144:	4609                	li	a2,2
    80006146:	00c69623          	sh	a2,12(a3)
    8000614a:	b5c9                	j	8000600c <virtio_disk_rw+0x166>
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    8000614c:	f9042583          	lw	a1,-112(s0)
    80006150:	20058793          	addi	a5,a1,512
    80006154:	0792                	slli	a5,a5,0x4
    80006156:	0001d517          	auipc	a0,0x1d
    8000615a:	f5250513          	addi	a0,a0,-174 # 800230a8 <disk+0xa8>
    8000615e:	953e                	add	a0,a0,a5
  if(write)
    80006160:	e20d11e3          	bnez	s10,80005f82 <virtio_disk_rw+0xdc>
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
    80006164:	20058713          	addi	a4,a1,512
    80006168:	00471693          	slli	a3,a4,0x4
    8000616c:	0001d717          	auipc	a4,0x1d
    80006170:	e9470713          	addi	a4,a4,-364 # 80023000 <disk>
    80006174:	9736                	add	a4,a4,a3
    80006176:	0a072423          	sw	zero,168(a4)
    8000617a:	b505                	j	80005f9a <virtio_disk_rw+0xf4>

000000008000617c <virtio_disk_intr>:

void
virtio_disk_intr()
{
    8000617c:	1101                	addi	sp,sp,-32
    8000617e:	ec06                	sd	ra,24(sp)
    80006180:	e822                	sd	s0,16(sp)
    80006182:	e426                	sd	s1,8(sp)
    80006184:	e04a                	sd	s2,0(sp)
    80006186:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80006188:	0001f517          	auipc	a0,0x1f
    8000618c:	fa050513          	addi	a0,a0,-96 # 80025128 <disk+0x2128>
    80006190:	ffffb097          	auipc	ra,0xffffb
    80006194:	a46080e7          	jalr	-1466(ra) # 80000bd6 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80006198:	10001737          	lui	a4,0x10001
    8000619c:	533c                	lw	a5,96(a4)
    8000619e:	8b8d                	andi	a5,a5,3
    800061a0:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    800061a2:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    800061a6:	0001f797          	auipc	a5,0x1f
    800061aa:	e5a78793          	addi	a5,a5,-422 # 80025000 <disk+0x2000>
    800061ae:	6b94                	ld	a3,16(a5)
    800061b0:	0207d703          	lhu	a4,32(a5)
    800061b4:	0026d783          	lhu	a5,2(a3)
    800061b8:	06f70163          	beq	a4,a5,8000621a <virtio_disk_intr+0x9e>
    __sync_synchronize();
    int id = disk.used->ring[disk.used_idx % NUM].id;
    800061bc:	0001d917          	auipc	s2,0x1d
    800061c0:	e4490913          	addi	s2,s2,-444 # 80023000 <disk>
    800061c4:	0001f497          	auipc	s1,0x1f
    800061c8:	e3c48493          	addi	s1,s1,-452 # 80025000 <disk+0x2000>
    __sync_synchronize();
    800061cc:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    800061d0:	6898                	ld	a4,16(s1)
    800061d2:	0204d783          	lhu	a5,32(s1)
    800061d6:	8b9d                	andi	a5,a5,7
    800061d8:	078e                	slli	a5,a5,0x3
    800061da:	97ba                	add	a5,a5,a4
    800061dc:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    800061de:	20078713          	addi	a4,a5,512
    800061e2:	0712                	slli	a4,a4,0x4
    800061e4:	974a                	add	a4,a4,s2
    800061e6:	03074703          	lbu	a4,48(a4) # 10001030 <_entry-0x6fffefd0>
    800061ea:	e731                	bnez	a4,80006236 <virtio_disk_intr+0xba>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    800061ec:	20078793          	addi	a5,a5,512
    800061f0:	0792                	slli	a5,a5,0x4
    800061f2:	97ca                	add	a5,a5,s2
    800061f4:	7788                	ld	a0,40(a5)
    b->disk = 0;   // disk is done with buf
    800061f6:	00052223          	sw	zero,4(a0)
    wakeup(b);
    800061fa:	ffffc097          	auipc	ra,0xffffc
    800061fe:	fe8080e7          	jalr	-24(ra) # 800021e2 <wakeup>

    disk.used_idx += 1;
    80006202:	0204d783          	lhu	a5,32(s1)
    80006206:	2785                	addiw	a5,a5,1
    80006208:	17c2                	slli	a5,a5,0x30
    8000620a:	93c1                	srli	a5,a5,0x30
    8000620c:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80006210:	6898                	ld	a4,16(s1)
    80006212:	00275703          	lhu	a4,2(a4)
    80006216:	faf71be3          	bne	a4,a5,800061cc <virtio_disk_intr+0x50>
  }

  release(&disk.vdisk_lock);
    8000621a:	0001f517          	auipc	a0,0x1f
    8000621e:	f0e50513          	addi	a0,a0,-242 # 80025128 <disk+0x2128>
    80006222:	ffffb097          	auipc	ra,0xffffb
    80006226:	a68080e7          	jalr	-1432(ra) # 80000c8a <release>
}
    8000622a:	60e2                	ld	ra,24(sp)
    8000622c:	6442                	ld	s0,16(sp)
    8000622e:	64a2                	ld	s1,8(sp)
    80006230:	6902                	ld	s2,0(sp)
    80006232:	6105                	addi	sp,sp,32
    80006234:	8082                	ret
      panic("virtio_disk_intr status");
    80006236:	00002517          	auipc	a0,0x2
    8000623a:	5b250513          	addi	a0,a0,1458 # 800087e8 <syscalls+0x3b8>
    8000623e:	ffffa097          	auipc	ra,0xffffa
    80006242:	2f2080e7          	jalr	754(ra) # 80000530 <panic>
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
