
kernel:     file format elf32-i386


Disassembly of section .text:

80100000 <multiboot_header>:
80100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
80100006:	00 00                	add    %al,(%eax)
80100008:	fe 4f 52             	decb   0x52(%edi)
8010000b:	e4                   	.byte 0xe4

8010000c <entry>:

# Entering xv6 on boot processor, with paging off.
.globl entry
entry:
  # Turn on page size extension for 4Mbyte pages
  movl    %cr4, %eax
8010000c:	0f 20 e0             	mov    %cr4,%eax
  orl     $(CR4_PSE), %eax
8010000f:	83 c8 10             	or     $0x10,%eax
  movl    %eax, %cr4
80100012:	0f 22 e0             	mov    %eax,%cr4
  # Set page directory
  movl    $(V2P_WO(entrypgdir)), %eax
80100015:	b8 00 a0 10 00       	mov    $0x10a000,%eax
  movl    %eax, %cr3
8010001a:	0f 22 d8             	mov    %eax,%cr3
  # Turn on paging.
  movl    %cr0, %eax
8010001d:	0f 20 c0             	mov    %cr0,%eax
  orl     $(CR0_PG|CR0_WP), %eax
80100020:	0d 00 00 01 80       	or     $0x80010000,%eax
  movl    %eax, %cr0
80100025:	0f 22 c0             	mov    %eax,%cr0

  # Set up the stack pointer.
  movl $(stack + KSTACKSIZE), %esp
80100028:	bc 30 c6 10 80       	mov    $0x8010c630,%esp

  # Jump to main(), and switch to executing at
  # high addresses. The indirect call is needed because
  # the assembler produces a PC-relative instruction
  # for a direct jump.
  mov $main, %eax
8010002d:	b8 54 38 10 80       	mov    $0x80103854,%eax
  jmp *%eax
80100032:	ff e0                	jmp    *%eax

80100034 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
80100034:	55                   	push   %ebp
80100035:	89 e5                	mov    %esp,%ebp
80100037:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  initlock(&bcache.lock, "bcache");
8010003a:	83 ec 08             	sub    $0x8,%esp
8010003d:	68 94 85 10 80       	push   $0x80108594
80100042:	68 40 c6 10 80       	push   $0x8010c640
80100047:	e8 ff 4e 00 00       	call   80104f4b <initlock>
8010004c:	83 c4 10             	add    $0x10,%esp

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
8010004f:	c7 05 8c 0d 11 80 3c 	movl   $0x80110d3c,0x80110d8c
80100056:	0d 11 80 
  bcache.head.next = &bcache.head;
80100059:	c7 05 90 0d 11 80 3c 	movl   $0x80110d3c,0x80110d90
80100060:	0d 11 80 
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
80100063:	c7 45 f4 74 c6 10 80 	movl   $0x8010c674,-0xc(%ebp)
8010006a:	eb 47                	jmp    801000b3 <binit+0x7f>
    b->next = bcache.head.next;
8010006c:	8b 15 90 0d 11 80    	mov    0x80110d90,%edx
80100072:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100075:	89 50 54             	mov    %edx,0x54(%eax)
    b->prev = &bcache.head;
80100078:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010007b:	c7 40 50 3c 0d 11 80 	movl   $0x80110d3c,0x50(%eax)
    initsleeplock(&b->lock, "buffer");
80100082:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100085:	83 c0 0c             	add    $0xc,%eax
80100088:	83 ec 08             	sub    $0x8,%esp
8010008b:	68 9b 85 10 80       	push   $0x8010859b
80100090:	50                   	push   %eax
80100091:	e8 58 4d 00 00       	call   80104dee <initsleeplock>
80100096:	83 c4 10             	add    $0x10,%esp
    bcache.head.next->prev = b;
80100099:	a1 90 0d 11 80       	mov    0x80110d90,%eax
8010009e:	8b 55 f4             	mov    -0xc(%ebp),%edx
801000a1:	89 50 50             	mov    %edx,0x50(%eax)
    bcache.head.next = b;
801000a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000a7:	a3 90 0d 11 80       	mov    %eax,0x80110d90

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
  bcache.head.next = &bcache.head;
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
801000ac:	81 45 f4 5c 02 00 00 	addl   $0x25c,-0xc(%ebp)
801000b3:	b8 3c 0d 11 80       	mov    $0x80110d3c,%eax
801000b8:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801000bb:	72 af                	jb     8010006c <binit+0x38>
    b->prev = &bcache.head;
    initsleeplock(&b->lock, "buffer");
    bcache.head.next->prev = b;
    bcache.head.next = b;
  }
}
801000bd:	90                   	nop
801000be:	c9                   	leave  
801000bf:	c3                   	ret    

801000c0 <bget>:
// Look through buffer cache for block on device dev.
// If not found, allocate a buffer.
// In either case, return locked buffer.
static struct buf*
bget(uint dev, uint blockno)
{
801000c0:	55                   	push   %ebp
801000c1:	89 e5                	mov    %esp,%ebp
801000c3:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  acquire(&bcache.lock);
801000c6:	83 ec 0c             	sub    $0xc,%esp
801000c9:	68 40 c6 10 80       	push   $0x8010c640
801000ce:	e8 9a 4e 00 00       	call   80104f6d <acquire>
801000d3:	83 c4 10             	add    $0x10,%esp

  // Is the block already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
801000d6:	a1 90 0d 11 80       	mov    0x80110d90,%eax
801000db:	89 45 f4             	mov    %eax,-0xc(%ebp)
801000de:	eb 58                	jmp    80100138 <bget+0x78>
    if(b->dev == dev && b->blockno == blockno){
801000e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000e3:	8b 40 04             	mov    0x4(%eax),%eax
801000e6:	3b 45 08             	cmp    0x8(%ebp),%eax
801000e9:	75 44                	jne    8010012f <bget+0x6f>
801000eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000ee:	8b 40 08             	mov    0x8(%eax),%eax
801000f1:	3b 45 0c             	cmp    0xc(%ebp),%eax
801000f4:	75 39                	jne    8010012f <bget+0x6f>
      b->refcnt++;
801000f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000f9:	8b 40 4c             	mov    0x4c(%eax),%eax
801000fc:	8d 50 01             	lea    0x1(%eax),%edx
801000ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100102:	89 50 4c             	mov    %edx,0x4c(%eax)
      release(&bcache.lock);
80100105:	83 ec 0c             	sub    $0xc,%esp
80100108:	68 40 c6 10 80       	push   $0x8010c640
8010010d:	e8 c9 4e 00 00       	call   80104fdb <release>
80100112:	83 c4 10             	add    $0x10,%esp
      acquiresleep(&b->lock);
80100115:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100118:	83 c0 0c             	add    $0xc,%eax
8010011b:	83 ec 0c             	sub    $0xc,%esp
8010011e:	50                   	push   %eax
8010011f:	e8 06 4d 00 00       	call   80104e2a <acquiresleep>
80100124:	83 c4 10             	add    $0x10,%esp
      return b;
80100127:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010012a:	e9 9d 00 00 00       	jmp    801001cc <bget+0x10c>
  struct buf *b;

  acquire(&bcache.lock);

  // Is the block already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
8010012f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100132:	8b 40 54             	mov    0x54(%eax),%eax
80100135:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100138:	81 7d f4 3c 0d 11 80 	cmpl   $0x80110d3c,-0xc(%ebp)
8010013f:	75 9f                	jne    801000e0 <bget+0x20>
  }

  // Not cached; recycle an unused buffer.
  // Even if refcnt==0, B_DIRTY indicates a buffer is in use
  // because log.c has modified it but not yet committed it.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100141:	a1 8c 0d 11 80       	mov    0x80110d8c,%eax
80100146:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100149:	eb 6b                	jmp    801001b6 <bget+0xf6>
    if(b->refcnt == 0 && (b->flags & B_DIRTY) == 0) {
8010014b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010014e:	8b 40 4c             	mov    0x4c(%eax),%eax
80100151:	85 c0                	test   %eax,%eax
80100153:	75 58                	jne    801001ad <bget+0xed>
80100155:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100158:	8b 00                	mov    (%eax),%eax
8010015a:	83 e0 04             	and    $0x4,%eax
8010015d:	85 c0                	test   %eax,%eax
8010015f:	75 4c                	jne    801001ad <bget+0xed>
      b->dev = dev;
80100161:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100164:	8b 55 08             	mov    0x8(%ebp),%edx
80100167:	89 50 04             	mov    %edx,0x4(%eax)
      b->blockno = blockno;
8010016a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010016d:	8b 55 0c             	mov    0xc(%ebp),%edx
80100170:	89 50 08             	mov    %edx,0x8(%eax)
      b->flags = 0;
80100173:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100176:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
      b->refcnt = 1;
8010017c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010017f:	c7 40 4c 01 00 00 00 	movl   $0x1,0x4c(%eax)
      release(&bcache.lock);
80100186:	83 ec 0c             	sub    $0xc,%esp
80100189:	68 40 c6 10 80       	push   $0x8010c640
8010018e:	e8 48 4e 00 00       	call   80104fdb <release>
80100193:	83 c4 10             	add    $0x10,%esp
      acquiresleep(&b->lock);
80100196:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100199:	83 c0 0c             	add    $0xc,%eax
8010019c:	83 ec 0c             	sub    $0xc,%esp
8010019f:	50                   	push   %eax
801001a0:	e8 85 4c 00 00       	call   80104e2a <acquiresleep>
801001a5:	83 c4 10             	add    $0x10,%esp
      return b;
801001a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001ab:	eb 1f                	jmp    801001cc <bget+0x10c>
  }

  // Not cached; recycle an unused buffer.
  // Even if refcnt==0, B_DIRTY indicates a buffer is in use
  // because log.c has modified it but not yet committed it.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
801001ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001b0:	8b 40 50             	mov    0x50(%eax),%eax
801001b3:	89 45 f4             	mov    %eax,-0xc(%ebp)
801001b6:	81 7d f4 3c 0d 11 80 	cmpl   $0x80110d3c,-0xc(%ebp)
801001bd:	75 8c                	jne    8010014b <bget+0x8b>
      release(&bcache.lock);
      acquiresleep(&b->lock);
      return b;
    }
  }
  panic("bget: no buffers");
801001bf:	83 ec 0c             	sub    $0xc,%esp
801001c2:	68 a2 85 10 80       	push   $0x801085a2
801001c7:	e8 d4 03 00 00       	call   801005a0 <panic>
}
801001cc:	c9                   	leave  
801001cd:	c3                   	ret    

801001ce <bread>:

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
801001ce:	55                   	push   %ebp
801001cf:	89 e5                	mov    %esp,%ebp
801001d1:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  b = bget(dev, blockno);
801001d4:	83 ec 08             	sub    $0x8,%esp
801001d7:	ff 75 0c             	pushl  0xc(%ebp)
801001da:	ff 75 08             	pushl  0x8(%ebp)
801001dd:	e8 de fe ff ff       	call   801000c0 <bget>
801001e2:	83 c4 10             	add    $0x10,%esp
801001e5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((b->flags & B_VALID) == 0) {
801001e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001eb:	8b 00                	mov    (%eax),%eax
801001ed:	83 e0 02             	and    $0x2,%eax
801001f0:	85 c0                	test   %eax,%eax
801001f2:	75 0e                	jne    80100202 <bread+0x34>
    iderw(b);
801001f4:	83 ec 0c             	sub    $0xc,%esp
801001f7:	ff 75 f4             	pushl  -0xc(%ebp)
801001fa:	e8 54 27 00 00       	call   80102953 <iderw>
801001ff:	83 c4 10             	add    $0x10,%esp
  }
  return b;
80100202:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80100205:	c9                   	leave  
80100206:	c3                   	ret    

80100207 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
80100207:	55                   	push   %ebp
80100208:	89 e5                	mov    %esp,%ebp
8010020a:	83 ec 08             	sub    $0x8,%esp
  if(!holdingsleep(&b->lock))
8010020d:	8b 45 08             	mov    0x8(%ebp),%eax
80100210:	83 c0 0c             	add    $0xc,%eax
80100213:	83 ec 0c             	sub    $0xc,%esp
80100216:	50                   	push   %eax
80100217:	e8 c0 4c 00 00       	call   80104edc <holdingsleep>
8010021c:	83 c4 10             	add    $0x10,%esp
8010021f:	85 c0                	test   %eax,%eax
80100221:	75 0d                	jne    80100230 <bwrite+0x29>
    panic("bwrite");
80100223:	83 ec 0c             	sub    $0xc,%esp
80100226:	68 b3 85 10 80       	push   $0x801085b3
8010022b:	e8 70 03 00 00       	call   801005a0 <panic>
  b->flags |= B_DIRTY;
80100230:	8b 45 08             	mov    0x8(%ebp),%eax
80100233:	8b 00                	mov    (%eax),%eax
80100235:	83 c8 04             	or     $0x4,%eax
80100238:	89 c2                	mov    %eax,%edx
8010023a:	8b 45 08             	mov    0x8(%ebp),%eax
8010023d:	89 10                	mov    %edx,(%eax)
  iderw(b);
8010023f:	83 ec 0c             	sub    $0xc,%esp
80100242:	ff 75 08             	pushl  0x8(%ebp)
80100245:	e8 09 27 00 00       	call   80102953 <iderw>
8010024a:	83 c4 10             	add    $0x10,%esp
}
8010024d:	90                   	nop
8010024e:	c9                   	leave  
8010024f:	c3                   	ret    

80100250 <brelse>:

// Release a locked buffer.
// Move to the head of the MRU list.
void
brelse(struct buf *b)
{
80100250:	55                   	push   %ebp
80100251:	89 e5                	mov    %esp,%ebp
80100253:	83 ec 08             	sub    $0x8,%esp
  if(!holdingsleep(&b->lock))
80100256:	8b 45 08             	mov    0x8(%ebp),%eax
80100259:	83 c0 0c             	add    $0xc,%eax
8010025c:	83 ec 0c             	sub    $0xc,%esp
8010025f:	50                   	push   %eax
80100260:	e8 77 4c 00 00       	call   80104edc <holdingsleep>
80100265:	83 c4 10             	add    $0x10,%esp
80100268:	85 c0                	test   %eax,%eax
8010026a:	75 0d                	jne    80100279 <brelse+0x29>
    panic("brelse");
8010026c:	83 ec 0c             	sub    $0xc,%esp
8010026f:	68 ba 85 10 80       	push   $0x801085ba
80100274:	e8 27 03 00 00       	call   801005a0 <panic>

  releasesleep(&b->lock);
80100279:	8b 45 08             	mov    0x8(%ebp),%eax
8010027c:	83 c0 0c             	add    $0xc,%eax
8010027f:	83 ec 0c             	sub    $0xc,%esp
80100282:	50                   	push   %eax
80100283:	e8 06 4c 00 00       	call   80104e8e <releasesleep>
80100288:	83 c4 10             	add    $0x10,%esp

  acquire(&bcache.lock);
8010028b:	83 ec 0c             	sub    $0xc,%esp
8010028e:	68 40 c6 10 80       	push   $0x8010c640
80100293:	e8 d5 4c 00 00       	call   80104f6d <acquire>
80100298:	83 c4 10             	add    $0x10,%esp
  b->refcnt--;
8010029b:	8b 45 08             	mov    0x8(%ebp),%eax
8010029e:	8b 40 4c             	mov    0x4c(%eax),%eax
801002a1:	8d 50 ff             	lea    -0x1(%eax),%edx
801002a4:	8b 45 08             	mov    0x8(%ebp),%eax
801002a7:	89 50 4c             	mov    %edx,0x4c(%eax)
  if (b->refcnt == 0) {
801002aa:	8b 45 08             	mov    0x8(%ebp),%eax
801002ad:	8b 40 4c             	mov    0x4c(%eax),%eax
801002b0:	85 c0                	test   %eax,%eax
801002b2:	75 47                	jne    801002fb <brelse+0xab>
    // no one is waiting for it.
    b->next->prev = b->prev;
801002b4:	8b 45 08             	mov    0x8(%ebp),%eax
801002b7:	8b 40 54             	mov    0x54(%eax),%eax
801002ba:	8b 55 08             	mov    0x8(%ebp),%edx
801002bd:	8b 52 50             	mov    0x50(%edx),%edx
801002c0:	89 50 50             	mov    %edx,0x50(%eax)
    b->prev->next = b->next;
801002c3:	8b 45 08             	mov    0x8(%ebp),%eax
801002c6:	8b 40 50             	mov    0x50(%eax),%eax
801002c9:	8b 55 08             	mov    0x8(%ebp),%edx
801002cc:	8b 52 54             	mov    0x54(%edx),%edx
801002cf:	89 50 54             	mov    %edx,0x54(%eax)
    b->next = bcache.head.next;
801002d2:	8b 15 90 0d 11 80    	mov    0x80110d90,%edx
801002d8:	8b 45 08             	mov    0x8(%ebp),%eax
801002db:	89 50 54             	mov    %edx,0x54(%eax)
    b->prev = &bcache.head;
801002de:	8b 45 08             	mov    0x8(%ebp),%eax
801002e1:	c7 40 50 3c 0d 11 80 	movl   $0x80110d3c,0x50(%eax)
    bcache.head.next->prev = b;
801002e8:	a1 90 0d 11 80       	mov    0x80110d90,%eax
801002ed:	8b 55 08             	mov    0x8(%ebp),%edx
801002f0:	89 50 50             	mov    %edx,0x50(%eax)
    bcache.head.next = b;
801002f3:	8b 45 08             	mov    0x8(%ebp),%eax
801002f6:	a3 90 0d 11 80       	mov    %eax,0x80110d90
  }
  
  release(&bcache.lock);
801002fb:	83 ec 0c             	sub    $0xc,%esp
801002fe:	68 40 c6 10 80       	push   $0x8010c640
80100303:	e8 d3 4c 00 00       	call   80104fdb <release>
80100308:	83 c4 10             	add    $0x10,%esp
}
8010030b:	90                   	nop
8010030c:	c9                   	leave  
8010030d:	c3                   	ret    

8010030e <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
8010030e:	55                   	push   %ebp
8010030f:	89 e5                	mov    %esp,%ebp
80100311:	83 ec 14             	sub    $0x14,%esp
80100314:	8b 45 08             	mov    0x8(%ebp),%eax
80100317:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010031b:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
8010031f:	89 c2                	mov    %eax,%edx
80100321:	ec                   	in     (%dx),%al
80100322:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80100325:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80100329:	c9                   	leave  
8010032a:	c3                   	ret    

8010032b <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
8010032b:	55                   	push   %ebp
8010032c:	89 e5                	mov    %esp,%ebp
8010032e:	83 ec 08             	sub    $0x8,%esp
80100331:	8b 55 08             	mov    0x8(%ebp),%edx
80100334:	8b 45 0c             	mov    0xc(%ebp),%eax
80100337:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
8010033b:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010033e:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80100342:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80100346:	ee                   	out    %al,(%dx)
}
80100347:	90                   	nop
80100348:	c9                   	leave  
80100349:	c3                   	ret    

8010034a <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
8010034a:	55                   	push   %ebp
8010034b:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
8010034d:	fa                   	cli    
}
8010034e:	90                   	nop
8010034f:	5d                   	pop    %ebp
80100350:	c3                   	ret    

80100351 <printint>:
  int locking;
} cons;

static void
printint(int xx, int base, int sign)
{
80100351:	55                   	push   %ebp
80100352:	89 e5                	mov    %esp,%ebp
80100354:	53                   	push   %ebx
80100355:	83 ec 24             	sub    $0x24,%esp
  static char digits[] = "0123456789abcdef";
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
80100358:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010035c:	74 1c                	je     8010037a <printint+0x29>
8010035e:	8b 45 08             	mov    0x8(%ebp),%eax
80100361:	c1 e8 1f             	shr    $0x1f,%eax
80100364:	0f b6 c0             	movzbl %al,%eax
80100367:	89 45 10             	mov    %eax,0x10(%ebp)
8010036a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010036e:	74 0a                	je     8010037a <printint+0x29>
    x = -xx;
80100370:	8b 45 08             	mov    0x8(%ebp),%eax
80100373:	f7 d8                	neg    %eax
80100375:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100378:	eb 06                	jmp    80100380 <printint+0x2f>
  else
    x = xx;
8010037a:	8b 45 08             	mov    0x8(%ebp),%eax
8010037d:	89 45 f0             	mov    %eax,-0x10(%ebp)

  i = 0;
80100380:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
80100387:	8b 4d f4             	mov    -0xc(%ebp),%ecx
8010038a:	8d 41 01             	lea    0x1(%ecx),%eax
8010038d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100390:	8b 5d 0c             	mov    0xc(%ebp),%ebx
80100393:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100396:	ba 00 00 00 00       	mov    $0x0,%edx
8010039b:	f7 f3                	div    %ebx
8010039d:	89 d0                	mov    %edx,%eax
8010039f:	0f b6 80 04 90 10 80 	movzbl -0x7fef6ffc(%eax),%eax
801003a6:	88 44 0d e0          	mov    %al,-0x20(%ebp,%ecx,1)
  }while((x /= base) != 0);
801003aa:	8b 5d 0c             	mov    0xc(%ebp),%ebx
801003ad:	8b 45 f0             	mov    -0x10(%ebp),%eax
801003b0:	ba 00 00 00 00       	mov    $0x0,%edx
801003b5:	f7 f3                	div    %ebx
801003b7:	89 45 f0             	mov    %eax,-0x10(%ebp)
801003ba:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801003be:	75 c7                	jne    80100387 <printint+0x36>

  if(sign)
801003c0:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801003c4:	74 2a                	je     801003f0 <printint+0x9f>
    buf[i++] = '-';
801003c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801003c9:	8d 50 01             	lea    0x1(%eax),%edx
801003cc:	89 55 f4             	mov    %edx,-0xc(%ebp)
801003cf:	c6 44 05 e0 2d       	movb   $0x2d,-0x20(%ebp,%eax,1)

  while(--i >= 0)
801003d4:	eb 1a                	jmp    801003f0 <printint+0x9f>
    consputc(buf[i]);
801003d6:	8d 55 e0             	lea    -0x20(%ebp),%edx
801003d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801003dc:	01 d0                	add    %edx,%eax
801003de:	0f b6 00             	movzbl (%eax),%eax
801003e1:	0f be c0             	movsbl %al,%eax
801003e4:	83 ec 0c             	sub    $0xc,%esp
801003e7:	50                   	push   %eax
801003e8:	e8 d8 03 00 00       	call   801007c5 <consputc>
801003ed:	83 c4 10             	add    $0x10,%esp
  }while((x /= base) != 0);

  if(sign)
    buf[i++] = '-';

  while(--i >= 0)
801003f0:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
801003f4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801003f8:	79 dc                	jns    801003d6 <printint+0x85>
    consputc(buf[i]);
}
801003fa:	90                   	nop
801003fb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801003fe:	c9                   	leave  
801003ff:	c3                   	ret    

80100400 <cprintf>:
//PAGEBREAK: 50

// Print to the console. only understands %d, %x, %p, %s.
void
cprintf(char *fmt, ...)
{
80100400:	55                   	push   %ebp
80100401:	89 e5                	mov    %esp,%ebp
80100403:	83 ec 28             	sub    $0x28,%esp
  int i, c, locking;
  uint *argp;
  char *s;

  locking = cons.locking;
80100406:	a1 d4 b5 10 80       	mov    0x8010b5d4,%eax
8010040b:	89 45 e8             	mov    %eax,-0x18(%ebp)
  if(locking)
8010040e:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80100412:	74 10                	je     80100424 <cprintf+0x24>
    acquire(&cons.lock);
80100414:	83 ec 0c             	sub    $0xc,%esp
80100417:	68 a0 b5 10 80       	push   $0x8010b5a0
8010041c:	e8 4c 4b 00 00       	call   80104f6d <acquire>
80100421:	83 c4 10             	add    $0x10,%esp

  if (fmt == 0)
80100424:	8b 45 08             	mov    0x8(%ebp),%eax
80100427:	85 c0                	test   %eax,%eax
80100429:	75 0d                	jne    80100438 <cprintf+0x38>
    panic("null fmt");
8010042b:	83 ec 0c             	sub    $0xc,%esp
8010042e:	68 c1 85 10 80       	push   $0x801085c1
80100433:	e8 68 01 00 00       	call   801005a0 <panic>

  argp = (uint*)(void*)(&fmt + 1);
80100438:	8d 45 0c             	lea    0xc(%ebp),%eax
8010043b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
8010043e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100445:	e9 1a 01 00 00       	jmp    80100564 <cprintf+0x164>
    if(c != '%'){
8010044a:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
8010044e:	74 13                	je     80100463 <cprintf+0x63>
      consputc(c);
80100450:	83 ec 0c             	sub    $0xc,%esp
80100453:	ff 75 e4             	pushl  -0x1c(%ebp)
80100456:	e8 6a 03 00 00       	call   801007c5 <consputc>
8010045b:	83 c4 10             	add    $0x10,%esp
      continue;
8010045e:	e9 fd 00 00 00       	jmp    80100560 <cprintf+0x160>
    }
    c = fmt[++i] & 0xff;
80100463:	8b 55 08             	mov    0x8(%ebp),%edx
80100466:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010046a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010046d:	01 d0                	add    %edx,%eax
8010046f:	0f b6 00             	movzbl (%eax),%eax
80100472:	0f be c0             	movsbl %al,%eax
80100475:	25 ff 00 00 00       	and    $0xff,%eax
8010047a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(c == 0)
8010047d:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100481:	0f 84 ff 00 00 00    	je     80100586 <cprintf+0x186>
      break;
    switch(c){
80100487:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010048a:	83 f8 70             	cmp    $0x70,%eax
8010048d:	74 47                	je     801004d6 <cprintf+0xd6>
8010048f:	83 f8 70             	cmp    $0x70,%eax
80100492:	7f 13                	jg     801004a7 <cprintf+0xa7>
80100494:	83 f8 25             	cmp    $0x25,%eax
80100497:	0f 84 98 00 00 00    	je     80100535 <cprintf+0x135>
8010049d:	83 f8 64             	cmp    $0x64,%eax
801004a0:	74 14                	je     801004b6 <cprintf+0xb6>
801004a2:	e9 9d 00 00 00       	jmp    80100544 <cprintf+0x144>
801004a7:	83 f8 73             	cmp    $0x73,%eax
801004aa:	74 47                	je     801004f3 <cprintf+0xf3>
801004ac:	83 f8 78             	cmp    $0x78,%eax
801004af:	74 25                	je     801004d6 <cprintf+0xd6>
801004b1:	e9 8e 00 00 00       	jmp    80100544 <cprintf+0x144>
    case 'd':
      printint(*argp++, 10, 1);
801004b6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801004b9:	8d 50 04             	lea    0x4(%eax),%edx
801004bc:	89 55 f0             	mov    %edx,-0x10(%ebp)
801004bf:	8b 00                	mov    (%eax),%eax
801004c1:	83 ec 04             	sub    $0x4,%esp
801004c4:	6a 01                	push   $0x1
801004c6:	6a 0a                	push   $0xa
801004c8:	50                   	push   %eax
801004c9:	e8 83 fe ff ff       	call   80100351 <printint>
801004ce:	83 c4 10             	add    $0x10,%esp
      break;
801004d1:	e9 8a 00 00 00       	jmp    80100560 <cprintf+0x160>
    case 'x':
    case 'p':
      printint(*argp++, 16, 0);
801004d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801004d9:	8d 50 04             	lea    0x4(%eax),%edx
801004dc:	89 55 f0             	mov    %edx,-0x10(%ebp)
801004df:	8b 00                	mov    (%eax),%eax
801004e1:	83 ec 04             	sub    $0x4,%esp
801004e4:	6a 00                	push   $0x0
801004e6:	6a 10                	push   $0x10
801004e8:	50                   	push   %eax
801004e9:	e8 63 fe ff ff       	call   80100351 <printint>
801004ee:	83 c4 10             	add    $0x10,%esp
      break;
801004f1:	eb 6d                	jmp    80100560 <cprintf+0x160>
    case 's':
      if((s = (char*)*argp++) == 0)
801004f3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801004f6:	8d 50 04             	lea    0x4(%eax),%edx
801004f9:	89 55 f0             	mov    %edx,-0x10(%ebp)
801004fc:	8b 00                	mov    (%eax),%eax
801004fe:	89 45 ec             	mov    %eax,-0x14(%ebp)
80100501:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80100505:	75 22                	jne    80100529 <cprintf+0x129>
        s = "(null)";
80100507:	c7 45 ec ca 85 10 80 	movl   $0x801085ca,-0x14(%ebp)
      for(; *s; s++)
8010050e:	eb 19                	jmp    80100529 <cprintf+0x129>
        consputc(*s);
80100510:	8b 45 ec             	mov    -0x14(%ebp),%eax
80100513:	0f b6 00             	movzbl (%eax),%eax
80100516:	0f be c0             	movsbl %al,%eax
80100519:	83 ec 0c             	sub    $0xc,%esp
8010051c:	50                   	push   %eax
8010051d:	e8 a3 02 00 00       	call   801007c5 <consputc>
80100522:	83 c4 10             	add    $0x10,%esp
      printint(*argp++, 16, 0);
      break;
    case 's':
      if((s = (char*)*argp++) == 0)
        s = "(null)";
      for(; *s; s++)
80100525:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80100529:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010052c:	0f b6 00             	movzbl (%eax),%eax
8010052f:	84 c0                	test   %al,%al
80100531:	75 dd                	jne    80100510 <cprintf+0x110>
        consputc(*s);
      break;
80100533:	eb 2b                	jmp    80100560 <cprintf+0x160>
    case '%':
      consputc('%');
80100535:	83 ec 0c             	sub    $0xc,%esp
80100538:	6a 25                	push   $0x25
8010053a:	e8 86 02 00 00       	call   801007c5 <consputc>
8010053f:	83 c4 10             	add    $0x10,%esp
      break;
80100542:	eb 1c                	jmp    80100560 <cprintf+0x160>
    default:
      // Print unknown % sequence to draw attention.
      consputc('%');
80100544:	83 ec 0c             	sub    $0xc,%esp
80100547:	6a 25                	push   $0x25
80100549:	e8 77 02 00 00       	call   801007c5 <consputc>
8010054e:	83 c4 10             	add    $0x10,%esp
      consputc(c);
80100551:	83 ec 0c             	sub    $0xc,%esp
80100554:	ff 75 e4             	pushl  -0x1c(%ebp)
80100557:	e8 69 02 00 00       	call   801007c5 <consputc>
8010055c:	83 c4 10             	add    $0x10,%esp
      break;
8010055f:	90                   	nop

  if (fmt == 0)
    panic("null fmt");

  argp = (uint*)(void*)(&fmt + 1);
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
80100560:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100564:	8b 55 08             	mov    0x8(%ebp),%edx
80100567:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010056a:	01 d0                	add    %edx,%eax
8010056c:	0f b6 00             	movzbl (%eax),%eax
8010056f:	0f be c0             	movsbl %al,%eax
80100572:	25 ff 00 00 00       	and    $0xff,%eax
80100577:	89 45 e4             	mov    %eax,-0x1c(%ebp)
8010057a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
8010057e:	0f 85 c6 fe ff ff    	jne    8010044a <cprintf+0x4a>
80100584:	eb 01                	jmp    80100587 <cprintf+0x187>
      consputc(c);
      continue;
    }
    c = fmt[++i] & 0xff;
    if(c == 0)
      break;
80100586:	90                   	nop
      consputc(c);
      break;
    }
  }

  if(locking)
80100587:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
8010058b:	74 10                	je     8010059d <cprintf+0x19d>
    release(&cons.lock);
8010058d:	83 ec 0c             	sub    $0xc,%esp
80100590:	68 a0 b5 10 80       	push   $0x8010b5a0
80100595:	e8 41 4a 00 00       	call   80104fdb <release>
8010059a:	83 c4 10             	add    $0x10,%esp
}
8010059d:	90                   	nop
8010059e:	c9                   	leave  
8010059f:	c3                   	ret    

801005a0 <panic>:

void
panic(char *s)
{
801005a0:	55                   	push   %ebp
801005a1:	89 e5                	mov    %esp,%ebp
801005a3:	83 ec 38             	sub    $0x38,%esp
  int i;
  uint pcs[10];

  cli();
801005a6:	e8 9f fd ff ff       	call   8010034a <cli>
  cons.locking = 0;
801005ab:	c7 05 d4 b5 10 80 00 	movl   $0x0,0x8010b5d4
801005b2:	00 00 00 
  // use lapiccpunum so that we can call panic from mycpu()
  cprintf("lapicid %d: panic: ", lapicid());
801005b5:	e8 28 2a 00 00       	call   80102fe2 <lapicid>
801005ba:	83 ec 08             	sub    $0x8,%esp
801005bd:	50                   	push   %eax
801005be:	68 d1 85 10 80       	push   $0x801085d1
801005c3:	e8 38 fe ff ff       	call   80100400 <cprintf>
801005c8:	83 c4 10             	add    $0x10,%esp
  cprintf(s);
801005cb:	8b 45 08             	mov    0x8(%ebp),%eax
801005ce:	83 ec 0c             	sub    $0xc,%esp
801005d1:	50                   	push   %eax
801005d2:	e8 29 fe ff ff       	call   80100400 <cprintf>
801005d7:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
801005da:	83 ec 0c             	sub    $0xc,%esp
801005dd:	68 e5 85 10 80       	push   $0x801085e5
801005e2:	e8 19 fe ff ff       	call   80100400 <cprintf>
801005e7:	83 c4 10             	add    $0x10,%esp
  getcallerpcs(&s, pcs);
801005ea:	83 ec 08             	sub    $0x8,%esp
801005ed:	8d 45 cc             	lea    -0x34(%ebp),%eax
801005f0:	50                   	push   %eax
801005f1:	8d 45 08             	lea    0x8(%ebp),%eax
801005f4:	50                   	push   %eax
801005f5:	e8 33 4a 00 00       	call   8010502d <getcallerpcs>
801005fa:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
801005fd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100604:	eb 1c                	jmp    80100622 <panic+0x82>
    cprintf(" %p", pcs[i]);
80100606:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100609:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
8010060d:	83 ec 08             	sub    $0x8,%esp
80100610:	50                   	push   %eax
80100611:	68 e7 85 10 80       	push   $0x801085e7
80100616:	e8 e5 fd ff ff       	call   80100400 <cprintf>
8010061b:	83 c4 10             	add    $0x10,%esp
  // use lapiccpunum so that we can call panic from mycpu()
  cprintf("lapicid %d: panic: ", lapicid());
  cprintf(s);
  cprintf("\n");
  getcallerpcs(&s, pcs);
  for(i=0; i<10; i++)
8010061e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100622:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
80100626:	7e de                	jle    80100606 <panic+0x66>
    cprintf(" %p", pcs[i]);
  panicked = 1; // freeze other CPU
80100628:	c7 05 80 b5 10 80 01 	movl   $0x1,0x8010b580
8010062f:	00 00 00 
  for(;;)
    ;
80100632:	eb fe                	jmp    80100632 <panic+0x92>

80100634 <cgaputc>:
#define CRTPORT 0x3d4
static ushort *crt = (ushort*)P2V(0xb8000);  // CGA memory

static void
cgaputc(int c)
{
80100634:	55                   	push   %ebp
80100635:	89 e5                	mov    %esp,%ebp
80100637:	83 ec 18             	sub    $0x18,%esp
  int pos;

  // Cursor position: col + 80*row.
  outb(CRTPORT, 14);
8010063a:	6a 0e                	push   $0xe
8010063c:	68 d4 03 00 00       	push   $0x3d4
80100641:	e8 e5 fc ff ff       	call   8010032b <outb>
80100646:	83 c4 08             	add    $0x8,%esp
  pos = inb(CRTPORT+1) << 8;
80100649:	68 d5 03 00 00       	push   $0x3d5
8010064e:	e8 bb fc ff ff       	call   8010030e <inb>
80100653:	83 c4 04             	add    $0x4,%esp
80100656:	0f b6 c0             	movzbl %al,%eax
80100659:	c1 e0 08             	shl    $0x8,%eax
8010065c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  outb(CRTPORT, 15);
8010065f:	6a 0f                	push   $0xf
80100661:	68 d4 03 00 00       	push   $0x3d4
80100666:	e8 c0 fc ff ff       	call   8010032b <outb>
8010066b:	83 c4 08             	add    $0x8,%esp
  pos |= inb(CRTPORT+1);
8010066e:	68 d5 03 00 00       	push   $0x3d5
80100673:	e8 96 fc ff ff       	call   8010030e <inb>
80100678:	83 c4 04             	add    $0x4,%esp
8010067b:	0f b6 c0             	movzbl %al,%eax
8010067e:	09 45 f4             	or     %eax,-0xc(%ebp)

  if(c == '\n')
80100681:	83 7d 08 0a          	cmpl   $0xa,0x8(%ebp)
80100685:	75 30                	jne    801006b7 <cgaputc+0x83>
    pos += 80 - pos%80;
80100687:	8b 4d f4             	mov    -0xc(%ebp),%ecx
8010068a:	ba 67 66 66 66       	mov    $0x66666667,%edx
8010068f:	89 c8                	mov    %ecx,%eax
80100691:	f7 ea                	imul   %edx
80100693:	c1 fa 05             	sar    $0x5,%edx
80100696:	89 c8                	mov    %ecx,%eax
80100698:	c1 f8 1f             	sar    $0x1f,%eax
8010069b:	29 c2                	sub    %eax,%edx
8010069d:	89 d0                	mov    %edx,%eax
8010069f:	c1 e0 02             	shl    $0x2,%eax
801006a2:	01 d0                	add    %edx,%eax
801006a4:	c1 e0 04             	shl    $0x4,%eax
801006a7:	29 c1                	sub    %eax,%ecx
801006a9:	89 ca                	mov    %ecx,%edx
801006ab:	b8 50 00 00 00       	mov    $0x50,%eax
801006b0:	29 d0                	sub    %edx,%eax
801006b2:	01 45 f4             	add    %eax,-0xc(%ebp)
801006b5:	eb 34                	jmp    801006eb <cgaputc+0xb7>
  else if(c == BACKSPACE){
801006b7:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
801006be:	75 0c                	jne    801006cc <cgaputc+0x98>
    if(pos > 0) --pos;
801006c0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801006c4:	7e 25                	jle    801006eb <cgaputc+0xb7>
801006c6:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
801006ca:	eb 1f                	jmp    801006eb <cgaputc+0xb7>
  } else
    crt[pos++] = (c&0xff) | 0x0700;  // black on white
801006cc:	8b 0d 00 90 10 80    	mov    0x80109000,%ecx
801006d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801006d5:	8d 50 01             	lea    0x1(%eax),%edx
801006d8:	89 55 f4             	mov    %edx,-0xc(%ebp)
801006db:	01 c0                	add    %eax,%eax
801006dd:	01 c8                	add    %ecx,%eax
801006df:	8b 55 08             	mov    0x8(%ebp),%edx
801006e2:	0f b6 d2             	movzbl %dl,%edx
801006e5:	80 ce 07             	or     $0x7,%dh
801006e8:	66 89 10             	mov    %dx,(%eax)

  if(pos < 0 || pos > 25*80)
801006eb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801006ef:	78 09                	js     801006fa <cgaputc+0xc6>
801006f1:	81 7d f4 d0 07 00 00 	cmpl   $0x7d0,-0xc(%ebp)
801006f8:	7e 0d                	jle    80100707 <cgaputc+0xd3>
    panic("pos under/overflow");
801006fa:	83 ec 0c             	sub    $0xc,%esp
801006fd:	68 eb 85 10 80       	push   $0x801085eb
80100702:	e8 99 fe ff ff       	call   801005a0 <panic>

  if((pos/80) >= 24){  // Scroll up.
80100707:	81 7d f4 7f 07 00 00 	cmpl   $0x77f,-0xc(%ebp)
8010070e:	7e 4c                	jle    8010075c <cgaputc+0x128>
    memmove(crt, crt+80, sizeof(crt[0])*23*80);
80100710:	a1 00 90 10 80       	mov    0x80109000,%eax
80100715:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
8010071b:	a1 00 90 10 80       	mov    0x80109000,%eax
80100720:	83 ec 04             	sub    $0x4,%esp
80100723:	68 60 0e 00 00       	push   $0xe60
80100728:	52                   	push   %edx
80100729:	50                   	push   %eax
8010072a:	e8 74 4b 00 00       	call   801052a3 <memmove>
8010072f:	83 c4 10             	add    $0x10,%esp
    pos -= 80;
80100732:	83 6d f4 50          	subl   $0x50,-0xc(%ebp)
    memset(crt+pos, 0, sizeof(crt[0])*(24*80 - pos));
80100736:	b8 80 07 00 00       	mov    $0x780,%eax
8010073b:	2b 45 f4             	sub    -0xc(%ebp),%eax
8010073e:	8d 14 00             	lea    (%eax,%eax,1),%edx
80100741:	a1 00 90 10 80       	mov    0x80109000,%eax
80100746:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80100749:	01 c9                	add    %ecx,%ecx
8010074b:	01 c8                	add    %ecx,%eax
8010074d:	83 ec 04             	sub    $0x4,%esp
80100750:	52                   	push   %edx
80100751:	6a 00                	push   $0x0
80100753:	50                   	push   %eax
80100754:	e8 8b 4a 00 00       	call   801051e4 <memset>
80100759:	83 c4 10             	add    $0x10,%esp
  }

  outb(CRTPORT, 14);
8010075c:	83 ec 08             	sub    $0x8,%esp
8010075f:	6a 0e                	push   $0xe
80100761:	68 d4 03 00 00       	push   $0x3d4
80100766:	e8 c0 fb ff ff       	call   8010032b <outb>
8010076b:	83 c4 10             	add    $0x10,%esp
  outb(CRTPORT+1, pos>>8);
8010076e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100771:	c1 f8 08             	sar    $0x8,%eax
80100774:	0f b6 c0             	movzbl %al,%eax
80100777:	83 ec 08             	sub    $0x8,%esp
8010077a:	50                   	push   %eax
8010077b:	68 d5 03 00 00       	push   $0x3d5
80100780:	e8 a6 fb ff ff       	call   8010032b <outb>
80100785:	83 c4 10             	add    $0x10,%esp
  outb(CRTPORT, 15);
80100788:	83 ec 08             	sub    $0x8,%esp
8010078b:	6a 0f                	push   $0xf
8010078d:	68 d4 03 00 00       	push   $0x3d4
80100792:	e8 94 fb ff ff       	call   8010032b <outb>
80100797:	83 c4 10             	add    $0x10,%esp
  outb(CRTPORT+1, pos);
8010079a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010079d:	0f b6 c0             	movzbl %al,%eax
801007a0:	83 ec 08             	sub    $0x8,%esp
801007a3:	50                   	push   %eax
801007a4:	68 d5 03 00 00       	push   $0x3d5
801007a9:	e8 7d fb ff ff       	call   8010032b <outb>
801007ae:	83 c4 10             	add    $0x10,%esp
  crt[pos] = ' ' | 0x0700;
801007b1:	a1 00 90 10 80       	mov    0x80109000,%eax
801007b6:	8b 55 f4             	mov    -0xc(%ebp),%edx
801007b9:	01 d2                	add    %edx,%edx
801007bb:	01 d0                	add    %edx,%eax
801007bd:	66 c7 00 20 07       	movw   $0x720,(%eax)
}
801007c2:	90                   	nop
801007c3:	c9                   	leave  
801007c4:	c3                   	ret    

801007c5 <consputc>:

void
consputc(int c)
{
801007c5:	55                   	push   %ebp
801007c6:	89 e5                	mov    %esp,%ebp
801007c8:	83 ec 08             	sub    $0x8,%esp
  if(panicked){
801007cb:	a1 80 b5 10 80       	mov    0x8010b580,%eax
801007d0:	85 c0                	test   %eax,%eax
801007d2:	74 07                	je     801007db <consputc+0x16>
    cli();
801007d4:	e8 71 fb ff ff       	call   8010034a <cli>
    for(;;)
      ;
801007d9:	eb fe                	jmp    801007d9 <consputc+0x14>
  }

  if(c == BACKSPACE){
801007db:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
801007e2:	75 29                	jne    8010080d <consputc+0x48>
    uartputc('\b'); uartputc(' '); uartputc('\b');
801007e4:	83 ec 0c             	sub    $0xc,%esp
801007e7:	6a 08                	push   $0x8
801007e9:	e8 af 63 00 00       	call   80106b9d <uartputc>
801007ee:	83 c4 10             	add    $0x10,%esp
801007f1:	83 ec 0c             	sub    $0xc,%esp
801007f4:	6a 20                	push   $0x20
801007f6:	e8 a2 63 00 00       	call   80106b9d <uartputc>
801007fb:	83 c4 10             	add    $0x10,%esp
801007fe:	83 ec 0c             	sub    $0xc,%esp
80100801:	6a 08                	push   $0x8
80100803:	e8 95 63 00 00       	call   80106b9d <uartputc>
80100808:	83 c4 10             	add    $0x10,%esp
8010080b:	eb 0e                	jmp    8010081b <consputc+0x56>
  } else
    uartputc(c);
8010080d:	83 ec 0c             	sub    $0xc,%esp
80100810:	ff 75 08             	pushl  0x8(%ebp)
80100813:	e8 85 63 00 00       	call   80106b9d <uartputc>
80100818:	83 c4 10             	add    $0x10,%esp
  cgaputc(c);
8010081b:	83 ec 0c             	sub    $0xc,%esp
8010081e:	ff 75 08             	pushl  0x8(%ebp)
80100821:	e8 0e fe ff ff       	call   80100634 <cgaputc>
80100826:	83 c4 10             	add    $0x10,%esp
}
80100829:	90                   	nop
8010082a:	c9                   	leave  
8010082b:	c3                   	ret    

8010082c <consoleintr>:

#define C(x)  ((x)-'@')  // Control-x

void
consoleintr(int (*getc)(void))
{
8010082c:	55                   	push   %ebp
8010082d:	89 e5                	mov    %esp,%ebp
8010082f:	83 ec 18             	sub    $0x18,%esp
  int c, doprocdump = 0;
80100832:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&cons.lock);
80100839:	83 ec 0c             	sub    $0xc,%esp
8010083c:	68 a0 b5 10 80       	push   $0x8010b5a0
80100841:	e8 27 47 00 00       	call   80104f6d <acquire>
80100846:	83 c4 10             	add    $0x10,%esp
  while((c = getc()) >= 0){
80100849:	e9 44 01 00 00       	jmp    80100992 <consoleintr+0x166>
    switch(c){
8010084e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100851:	83 f8 10             	cmp    $0x10,%eax
80100854:	74 1e                	je     80100874 <consoleintr+0x48>
80100856:	83 f8 10             	cmp    $0x10,%eax
80100859:	7f 0a                	jg     80100865 <consoleintr+0x39>
8010085b:	83 f8 08             	cmp    $0x8,%eax
8010085e:	74 6b                	je     801008cb <consoleintr+0x9f>
80100860:	e9 9b 00 00 00       	jmp    80100900 <consoleintr+0xd4>
80100865:	83 f8 15             	cmp    $0x15,%eax
80100868:	74 33                	je     8010089d <consoleintr+0x71>
8010086a:	83 f8 7f             	cmp    $0x7f,%eax
8010086d:	74 5c                	je     801008cb <consoleintr+0x9f>
8010086f:	e9 8c 00 00 00       	jmp    80100900 <consoleintr+0xd4>
    case C('P'):  // Process listing.
      // procdump() locks cons.lock indirectly; invoke later
      doprocdump = 1;
80100874:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
      break;
8010087b:	e9 12 01 00 00       	jmp    80100992 <consoleintr+0x166>
    case C('U'):  // Kill line.
      while(input.e != input.w &&
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
80100880:	a1 28 10 11 80       	mov    0x80111028,%eax
80100885:	83 e8 01             	sub    $0x1,%eax
80100888:	a3 28 10 11 80       	mov    %eax,0x80111028
        consputc(BACKSPACE);
8010088d:	83 ec 0c             	sub    $0xc,%esp
80100890:	68 00 01 00 00       	push   $0x100
80100895:	e8 2b ff ff ff       	call   801007c5 <consputc>
8010089a:	83 c4 10             	add    $0x10,%esp
    case C('P'):  // Process listing.
      // procdump() locks cons.lock indirectly; invoke later
      doprocdump = 1;
      break;
    case C('U'):  // Kill line.
      while(input.e != input.w &&
8010089d:	8b 15 28 10 11 80    	mov    0x80111028,%edx
801008a3:	a1 24 10 11 80       	mov    0x80111024,%eax
801008a8:	39 c2                	cmp    %eax,%edx
801008aa:	0f 84 e2 00 00 00    	je     80100992 <consoleintr+0x166>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
801008b0:	a1 28 10 11 80       	mov    0x80111028,%eax
801008b5:	83 e8 01             	sub    $0x1,%eax
801008b8:	83 e0 7f             	and    $0x7f,%eax
801008bb:	0f b6 80 a0 0f 11 80 	movzbl -0x7feef060(%eax),%eax
    case C('P'):  // Process listing.
      // procdump() locks cons.lock indirectly; invoke later
      doprocdump = 1;
      break;
    case C('U'):  // Kill line.
      while(input.e != input.w &&
801008c2:	3c 0a                	cmp    $0xa,%al
801008c4:	75 ba                	jne    80100880 <consoleintr+0x54>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
        consputc(BACKSPACE);
      }
      break;
801008c6:	e9 c7 00 00 00       	jmp    80100992 <consoleintr+0x166>
    case C('H'): case '\x7f':  // Backspace
      if(input.e != input.w){
801008cb:	8b 15 28 10 11 80    	mov    0x80111028,%edx
801008d1:	a1 24 10 11 80       	mov    0x80111024,%eax
801008d6:	39 c2                	cmp    %eax,%edx
801008d8:	0f 84 b4 00 00 00    	je     80100992 <consoleintr+0x166>
        input.e--;
801008de:	a1 28 10 11 80       	mov    0x80111028,%eax
801008e3:	83 e8 01             	sub    $0x1,%eax
801008e6:	a3 28 10 11 80       	mov    %eax,0x80111028
        consputc(BACKSPACE);
801008eb:	83 ec 0c             	sub    $0xc,%esp
801008ee:	68 00 01 00 00       	push   $0x100
801008f3:	e8 cd fe ff ff       	call   801007c5 <consputc>
801008f8:	83 c4 10             	add    $0x10,%esp
      }
      break;
801008fb:	e9 92 00 00 00       	jmp    80100992 <consoleintr+0x166>
    default:
      if(c != 0 && input.e-input.r < INPUT_BUF){
80100900:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80100904:	0f 84 87 00 00 00    	je     80100991 <consoleintr+0x165>
8010090a:	8b 15 28 10 11 80    	mov    0x80111028,%edx
80100910:	a1 20 10 11 80       	mov    0x80111020,%eax
80100915:	29 c2                	sub    %eax,%edx
80100917:	89 d0                	mov    %edx,%eax
80100919:	83 f8 7f             	cmp    $0x7f,%eax
8010091c:	77 73                	ja     80100991 <consoleintr+0x165>
        c = (c == '\r') ? '\n' : c;
8010091e:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
80100922:	74 05                	je     80100929 <consoleintr+0xfd>
80100924:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100927:	eb 05                	jmp    8010092e <consoleintr+0x102>
80100929:	b8 0a 00 00 00       	mov    $0xa,%eax
8010092e:	89 45 f0             	mov    %eax,-0x10(%ebp)
        input.buf[input.e++ % INPUT_BUF] = c;
80100931:	a1 28 10 11 80       	mov    0x80111028,%eax
80100936:	8d 50 01             	lea    0x1(%eax),%edx
80100939:	89 15 28 10 11 80    	mov    %edx,0x80111028
8010093f:	83 e0 7f             	and    $0x7f,%eax
80100942:	8b 55 f0             	mov    -0x10(%ebp),%edx
80100945:	88 90 a0 0f 11 80    	mov    %dl,-0x7feef060(%eax)
        consputc(c);
8010094b:	83 ec 0c             	sub    $0xc,%esp
8010094e:	ff 75 f0             	pushl  -0x10(%ebp)
80100951:	e8 6f fe ff ff       	call   801007c5 <consputc>
80100956:	83 c4 10             	add    $0x10,%esp
        if(c == '\n' || c == C('D') || input.e == input.r+INPUT_BUF){
80100959:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
8010095d:	74 18                	je     80100977 <consoleintr+0x14b>
8010095f:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
80100963:	74 12                	je     80100977 <consoleintr+0x14b>
80100965:	a1 28 10 11 80       	mov    0x80111028,%eax
8010096a:	8b 15 20 10 11 80    	mov    0x80111020,%edx
80100970:	83 ea 80             	sub    $0xffffff80,%edx
80100973:	39 d0                	cmp    %edx,%eax
80100975:	75 1a                	jne    80100991 <consoleintr+0x165>
          input.w = input.e;
80100977:	a1 28 10 11 80       	mov    0x80111028,%eax
8010097c:	a3 24 10 11 80       	mov    %eax,0x80111024
          wakeup(&input.r);
80100981:	83 ec 0c             	sub    $0xc,%esp
80100984:	68 20 10 11 80       	push   $0x80111020
80100989:	e8 a6 42 00 00       	call   80104c34 <wakeup>
8010098e:	83 c4 10             	add    $0x10,%esp
        }
      }
      break;
80100991:	90                   	nop
consoleintr(int (*getc)(void))
{
  int c, doprocdump = 0;

  acquire(&cons.lock);
  while((c = getc()) >= 0){
80100992:	8b 45 08             	mov    0x8(%ebp),%eax
80100995:	ff d0                	call   *%eax
80100997:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010099a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010099e:	0f 89 aa fe ff ff    	jns    8010084e <consoleintr+0x22>
        }
      }
      break;
    }
  }
  release(&cons.lock);
801009a4:	83 ec 0c             	sub    $0xc,%esp
801009a7:	68 a0 b5 10 80       	push   $0x8010b5a0
801009ac:	e8 2a 46 00 00       	call   80104fdb <release>
801009b1:	83 c4 10             	add    $0x10,%esp
  if(doprocdump) {
801009b4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801009b8:	74 05                	je     801009bf <consoleintr+0x193>
    procdump();  // now call procdump() wo. cons.lock held
801009ba:	e8 33 43 00 00       	call   80104cf2 <procdump>
  }
}
801009bf:	90                   	nop
801009c0:	c9                   	leave  
801009c1:	c3                   	ret    

801009c2 <consoleread>:

int
consoleread(struct inode *ip, char *dst, int n)
{
801009c2:	55                   	push   %ebp
801009c3:	89 e5                	mov    %esp,%ebp
801009c5:	83 ec 18             	sub    $0x18,%esp
  uint target;
  int c;

  iunlock(ip);
801009c8:	83 ec 0c             	sub    $0xc,%esp
801009cb:	ff 75 08             	pushl  0x8(%ebp)
801009ce:	e8 47 11 00 00       	call   80101b1a <iunlock>
801009d3:	83 c4 10             	add    $0x10,%esp
  target = n;
801009d6:	8b 45 10             	mov    0x10(%ebp),%eax
801009d9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  acquire(&cons.lock);
801009dc:	83 ec 0c             	sub    $0xc,%esp
801009df:	68 a0 b5 10 80       	push   $0x8010b5a0
801009e4:	e8 84 45 00 00       	call   80104f6d <acquire>
801009e9:	83 c4 10             	add    $0x10,%esp
  while(n > 0){
801009ec:	e9 ab 00 00 00       	jmp    80100a9c <consoleread+0xda>
    while(input.r == input.w){
      if(myproc()->killed){
801009f1:	e8 8e 38 00 00       	call   80104284 <myproc>
801009f6:	8b 40 2c             	mov    0x2c(%eax),%eax
801009f9:	85 c0                	test   %eax,%eax
801009fb:	74 28                	je     80100a25 <consoleread+0x63>
        release(&cons.lock);
801009fd:	83 ec 0c             	sub    $0xc,%esp
80100a00:	68 a0 b5 10 80       	push   $0x8010b5a0
80100a05:	e8 d1 45 00 00       	call   80104fdb <release>
80100a0a:	83 c4 10             	add    $0x10,%esp
        ilock(ip);
80100a0d:	83 ec 0c             	sub    $0xc,%esp
80100a10:	ff 75 08             	pushl  0x8(%ebp)
80100a13:	e8 ef 0f 00 00       	call   80101a07 <ilock>
80100a18:	83 c4 10             	add    $0x10,%esp
        return -1;
80100a1b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100a20:	e9 ab 00 00 00       	jmp    80100ad0 <consoleread+0x10e>
      }
      sleep(&input.r, &cons.lock);
80100a25:	83 ec 08             	sub    $0x8,%esp
80100a28:	68 a0 b5 10 80       	push   $0x8010b5a0
80100a2d:	68 20 10 11 80       	push   $0x80111020
80100a32:	e8 14 41 00 00       	call   80104b4b <sleep>
80100a37:	83 c4 10             	add    $0x10,%esp

  iunlock(ip);
  target = n;
  acquire(&cons.lock);
  while(n > 0){
    while(input.r == input.w){
80100a3a:	8b 15 20 10 11 80    	mov    0x80111020,%edx
80100a40:	a1 24 10 11 80       	mov    0x80111024,%eax
80100a45:	39 c2                	cmp    %eax,%edx
80100a47:	74 a8                	je     801009f1 <consoleread+0x2f>
        ilock(ip);
        return -1;
      }
      sleep(&input.r, &cons.lock);
    }
    c = input.buf[input.r++ % INPUT_BUF];
80100a49:	a1 20 10 11 80       	mov    0x80111020,%eax
80100a4e:	8d 50 01             	lea    0x1(%eax),%edx
80100a51:	89 15 20 10 11 80    	mov    %edx,0x80111020
80100a57:	83 e0 7f             	and    $0x7f,%eax
80100a5a:	0f b6 80 a0 0f 11 80 	movzbl -0x7feef060(%eax),%eax
80100a61:	0f be c0             	movsbl %al,%eax
80100a64:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(c == C('D')){  // EOF
80100a67:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
80100a6b:	75 17                	jne    80100a84 <consoleread+0xc2>
      if(n < target){
80100a6d:	8b 45 10             	mov    0x10(%ebp),%eax
80100a70:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80100a73:	73 2f                	jae    80100aa4 <consoleread+0xe2>
        // Save ^D for next time, to make sure
        // caller gets a 0-byte result.
        input.r--;
80100a75:	a1 20 10 11 80       	mov    0x80111020,%eax
80100a7a:	83 e8 01             	sub    $0x1,%eax
80100a7d:	a3 20 10 11 80       	mov    %eax,0x80111020
      }
      break;
80100a82:	eb 20                	jmp    80100aa4 <consoleread+0xe2>
    }
    *dst++ = c;
80100a84:	8b 45 0c             	mov    0xc(%ebp),%eax
80100a87:	8d 50 01             	lea    0x1(%eax),%edx
80100a8a:	89 55 0c             	mov    %edx,0xc(%ebp)
80100a8d:	8b 55 f0             	mov    -0x10(%ebp),%edx
80100a90:	88 10                	mov    %dl,(%eax)
    --n;
80100a92:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
    if(c == '\n')
80100a96:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
80100a9a:	74 0b                	je     80100aa7 <consoleread+0xe5>
  int c;

  iunlock(ip);
  target = n;
  acquire(&cons.lock);
  while(n > 0){
80100a9c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100aa0:	7f 98                	jg     80100a3a <consoleread+0x78>
80100aa2:	eb 04                	jmp    80100aa8 <consoleread+0xe6>
      if(n < target){
        // Save ^D for next time, to make sure
        // caller gets a 0-byte result.
        input.r--;
      }
      break;
80100aa4:	90                   	nop
80100aa5:	eb 01                	jmp    80100aa8 <consoleread+0xe6>
    }
    *dst++ = c;
    --n;
    if(c == '\n')
      break;
80100aa7:	90                   	nop
  }
  release(&cons.lock);
80100aa8:	83 ec 0c             	sub    $0xc,%esp
80100aab:	68 a0 b5 10 80       	push   $0x8010b5a0
80100ab0:	e8 26 45 00 00       	call   80104fdb <release>
80100ab5:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80100ab8:	83 ec 0c             	sub    $0xc,%esp
80100abb:	ff 75 08             	pushl  0x8(%ebp)
80100abe:	e8 44 0f 00 00       	call   80101a07 <ilock>
80100ac3:	83 c4 10             	add    $0x10,%esp

  return target - n;
80100ac6:	8b 45 10             	mov    0x10(%ebp),%eax
80100ac9:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100acc:	29 c2                	sub    %eax,%edx
80100ace:	89 d0                	mov    %edx,%eax
}
80100ad0:	c9                   	leave  
80100ad1:	c3                   	ret    

80100ad2 <consolewrite>:

int
consolewrite(struct inode *ip, char *buf, int n)
{
80100ad2:	55                   	push   %ebp
80100ad3:	89 e5                	mov    %esp,%ebp
80100ad5:	83 ec 18             	sub    $0x18,%esp
  int i;

  iunlock(ip);
80100ad8:	83 ec 0c             	sub    $0xc,%esp
80100adb:	ff 75 08             	pushl  0x8(%ebp)
80100ade:	e8 37 10 00 00       	call   80101b1a <iunlock>
80100ae3:	83 c4 10             	add    $0x10,%esp
  acquire(&cons.lock);
80100ae6:	83 ec 0c             	sub    $0xc,%esp
80100ae9:	68 a0 b5 10 80       	push   $0x8010b5a0
80100aee:	e8 7a 44 00 00       	call   80104f6d <acquire>
80100af3:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++)
80100af6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100afd:	eb 21                	jmp    80100b20 <consolewrite+0x4e>
    consputc(buf[i] & 0xff);
80100aff:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100b02:	8b 45 0c             	mov    0xc(%ebp),%eax
80100b05:	01 d0                	add    %edx,%eax
80100b07:	0f b6 00             	movzbl (%eax),%eax
80100b0a:	0f be c0             	movsbl %al,%eax
80100b0d:	0f b6 c0             	movzbl %al,%eax
80100b10:	83 ec 0c             	sub    $0xc,%esp
80100b13:	50                   	push   %eax
80100b14:	e8 ac fc ff ff       	call   801007c5 <consputc>
80100b19:	83 c4 10             	add    $0x10,%esp
{
  int i;

  iunlock(ip);
  acquire(&cons.lock);
  for(i = 0; i < n; i++)
80100b1c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100b20:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100b23:	3b 45 10             	cmp    0x10(%ebp),%eax
80100b26:	7c d7                	jl     80100aff <consolewrite+0x2d>
    consputc(buf[i] & 0xff);
  release(&cons.lock);
80100b28:	83 ec 0c             	sub    $0xc,%esp
80100b2b:	68 a0 b5 10 80       	push   $0x8010b5a0
80100b30:	e8 a6 44 00 00       	call   80104fdb <release>
80100b35:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80100b38:	83 ec 0c             	sub    $0xc,%esp
80100b3b:	ff 75 08             	pushl  0x8(%ebp)
80100b3e:	e8 c4 0e 00 00       	call   80101a07 <ilock>
80100b43:	83 c4 10             	add    $0x10,%esp

  return n;
80100b46:	8b 45 10             	mov    0x10(%ebp),%eax
}
80100b49:	c9                   	leave  
80100b4a:	c3                   	ret    

80100b4b <consoleinit>:

void
consoleinit(void)
{
80100b4b:	55                   	push   %ebp
80100b4c:	89 e5                	mov    %esp,%ebp
80100b4e:	83 ec 08             	sub    $0x8,%esp
  initlock(&cons.lock, "console");
80100b51:	83 ec 08             	sub    $0x8,%esp
80100b54:	68 fe 85 10 80       	push   $0x801085fe
80100b59:	68 a0 b5 10 80       	push   $0x8010b5a0
80100b5e:	e8 e8 43 00 00       	call   80104f4b <initlock>
80100b63:	83 c4 10             	add    $0x10,%esp

  devsw[CONSOLE].write = consolewrite;
80100b66:	c7 05 ec 19 11 80 d2 	movl   $0x80100ad2,0x801119ec
80100b6d:	0a 10 80 
  devsw[CONSOLE].read = consoleread;
80100b70:	c7 05 e8 19 11 80 c2 	movl   $0x801009c2,0x801119e8
80100b77:	09 10 80 
  cons.locking = 1;
80100b7a:	c7 05 d4 b5 10 80 01 	movl   $0x1,0x8010b5d4
80100b81:	00 00 00 

  ioapicenable(IRQ_KBD, 0);
80100b84:	83 ec 08             	sub    $0x8,%esp
80100b87:	6a 00                	push   $0x0
80100b89:	6a 01                	push   $0x1
80100b8b:	e8 8b 1f 00 00       	call   80102b1b <ioapicenable>
80100b90:	83 c4 10             	add    $0x10,%esp
}
80100b93:	90                   	nop
80100b94:	c9                   	leave  
80100b95:	c3                   	ret    

80100b96 <exec>:
#include "x86.h"
#include "elf.h"

int
exec(char *path, char **argv)
{
80100b96:	55                   	push   %ebp
80100b97:	89 e5                	mov    %esp,%ebp
80100b99:	81 ec 18 01 00 00    	sub    $0x118,%esp
  uint argc, sz, sp, ustack[3+MAXARG+1];
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pde_t *pgdir, *oldpgdir;
  struct proc *curproc = myproc();
80100b9f:	e8 e0 36 00 00       	call   80104284 <myproc>
80100ba4:	89 45 d0             	mov    %eax,-0x30(%ebp)

  begin_op();
80100ba7:	e8 80 29 00 00       	call   8010352c <begin_op>

  if((ip = namei(path)) == 0){
80100bac:	83 ec 0c             	sub    $0xc,%esp
80100baf:	ff 75 08             	pushl  0x8(%ebp)
80100bb2:	e8 90 19 00 00       	call   80102547 <namei>
80100bb7:	83 c4 10             	add    $0x10,%esp
80100bba:	89 45 d8             	mov    %eax,-0x28(%ebp)
80100bbd:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100bc1:	75 1f                	jne    80100be2 <exec+0x4c>
    end_op();
80100bc3:	e8 f0 29 00 00       	call   801035b8 <end_op>
    cprintf("exec: fail\n");
80100bc8:	83 ec 0c             	sub    $0xc,%esp
80100bcb:	68 06 86 10 80       	push   $0x80108606
80100bd0:	e8 2b f8 ff ff       	call   80100400 <cprintf>
80100bd5:	83 c4 10             	add    $0x10,%esp
    return -1;
80100bd8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100bdd:	e9 e8 03 00 00       	jmp    80100fca <exec+0x434>
  }
  ilock(ip);
80100be2:	83 ec 0c             	sub    $0xc,%esp
80100be5:	ff 75 d8             	pushl  -0x28(%ebp)
80100be8:	e8 1a 0e 00 00       	call   80101a07 <ilock>
80100bed:	83 c4 10             	add    $0x10,%esp
  pgdir = 0;
80100bf0:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) != sizeof(elf))
80100bf7:	6a 34                	push   $0x34
80100bf9:	6a 00                	push   $0x0
80100bfb:	8d 85 08 ff ff ff    	lea    -0xf8(%ebp),%eax
80100c01:	50                   	push   %eax
80100c02:	ff 75 d8             	pushl  -0x28(%ebp)
80100c05:	e8 ee 12 00 00       	call   80101ef8 <readi>
80100c0a:	83 c4 10             	add    $0x10,%esp
80100c0d:	83 f8 34             	cmp    $0x34,%eax
80100c10:	0f 85 5d 03 00 00    	jne    80100f73 <exec+0x3dd>
    goto bad;
  if(elf.magic != ELF_MAGIC)
80100c16:	8b 85 08 ff ff ff    	mov    -0xf8(%ebp),%eax
80100c1c:	3d 7f 45 4c 46       	cmp    $0x464c457f,%eax
80100c21:	0f 85 4f 03 00 00    	jne    80100f76 <exec+0x3e0>
    goto bad;

  if((pgdir = setupkvm()) == 0)
80100c27:	e8 6d 6f 00 00       	call   80107b99 <setupkvm>
80100c2c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80100c2f:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100c33:	0f 84 40 03 00 00    	je     80100f79 <exec+0x3e3>
    goto bad;

  // Load program into memory.
  sz = 0;
80100c39:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100c40:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80100c47:	8b 85 24 ff ff ff    	mov    -0xdc(%ebp),%eax
80100c4d:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100c50:	e9 de 00 00 00       	jmp    80100d33 <exec+0x19d>
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
80100c55:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100c58:	6a 20                	push   $0x20
80100c5a:	50                   	push   %eax
80100c5b:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
80100c61:	50                   	push   %eax
80100c62:	ff 75 d8             	pushl  -0x28(%ebp)
80100c65:	e8 8e 12 00 00       	call   80101ef8 <readi>
80100c6a:	83 c4 10             	add    $0x10,%esp
80100c6d:	83 f8 20             	cmp    $0x20,%eax
80100c70:	0f 85 06 03 00 00    	jne    80100f7c <exec+0x3e6>
      goto bad;
    if(ph.type != ELF_PROG_LOAD)
80100c76:	8b 85 e8 fe ff ff    	mov    -0x118(%ebp),%eax
80100c7c:	83 f8 01             	cmp    $0x1,%eax
80100c7f:	0f 85 a0 00 00 00    	jne    80100d25 <exec+0x18f>
      continue;
    if(ph.memsz < ph.filesz)
80100c85:	8b 95 fc fe ff ff    	mov    -0x104(%ebp),%edx
80100c8b:	8b 85 f8 fe ff ff    	mov    -0x108(%ebp),%eax
80100c91:	39 c2                	cmp    %eax,%edx
80100c93:	0f 82 e6 02 00 00    	jb     80100f7f <exec+0x3e9>
      goto bad;
    if(ph.vaddr + ph.memsz < ph.vaddr)
80100c99:	8b 95 f0 fe ff ff    	mov    -0x110(%ebp),%edx
80100c9f:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax
80100ca5:	01 c2                	add    %eax,%edx
80100ca7:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
80100cad:	39 c2                	cmp    %eax,%edx
80100caf:	0f 82 cd 02 00 00    	jb     80100f82 <exec+0x3ec>
      goto bad;
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
80100cb5:	8b 95 f0 fe ff ff    	mov    -0x110(%ebp),%edx
80100cbb:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax
80100cc1:	01 d0                	add    %edx,%eax
80100cc3:	83 ec 04             	sub    $0x4,%esp
80100cc6:	50                   	push   %eax
80100cc7:	ff 75 e0             	pushl  -0x20(%ebp)
80100cca:	ff 75 d4             	pushl  -0x2c(%ebp)
80100ccd:	e8 6c 72 00 00       	call   80107f3e <allocuvm>
80100cd2:	83 c4 10             	add    $0x10,%esp
80100cd5:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100cd8:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100cdc:	0f 84 a3 02 00 00    	je     80100f85 <exec+0x3ef>
      goto bad;
    if(ph.vaddr % PGSIZE != 0)
80100ce2:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
80100ce8:	25 ff 0f 00 00       	and    $0xfff,%eax
80100ced:	85 c0                	test   %eax,%eax
80100cef:	0f 85 93 02 00 00    	jne    80100f88 <exec+0x3f2>
      goto bad;
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
80100cf5:	8b 95 f8 fe ff ff    	mov    -0x108(%ebp),%edx
80100cfb:	8b 85 ec fe ff ff    	mov    -0x114(%ebp),%eax
80100d01:	8b 8d f0 fe ff ff    	mov    -0x110(%ebp),%ecx
80100d07:	83 ec 0c             	sub    $0xc,%esp
80100d0a:	52                   	push   %edx
80100d0b:	50                   	push   %eax
80100d0c:	ff 75 d8             	pushl  -0x28(%ebp)
80100d0f:	51                   	push   %ecx
80100d10:	ff 75 d4             	pushl  -0x2c(%ebp)
80100d13:	e8 59 71 00 00       	call   80107e71 <loaduvm>
80100d18:	83 c4 20             	add    $0x20,%esp
80100d1b:	85 c0                	test   %eax,%eax
80100d1d:	0f 88 68 02 00 00    	js     80100f8b <exec+0x3f5>
80100d23:	eb 01                	jmp    80100d26 <exec+0x190>
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
      goto bad;
    if(ph.type != ELF_PROG_LOAD)
      continue;
80100d25:	90                   	nop
  if((pgdir = setupkvm()) == 0)
    goto bad;

  // Load program into memory.
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100d26:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80100d2a:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100d2d:	83 c0 20             	add    $0x20,%eax
80100d30:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100d33:	0f b7 85 34 ff ff ff 	movzwl -0xcc(%ebp),%eax
80100d3a:	0f b7 c0             	movzwl %ax,%eax
80100d3d:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80100d40:	0f 8f 0f ff ff ff    	jg     80100c55 <exec+0xbf>
    if(ph.vaddr % PGSIZE != 0)
      goto bad;
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
      goto bad;
  }
  iunlockput(ip);
80100d46:	83 ec 0c             	sub    $0xc,%esp
80100d49:	ff 75 d8             	pushl  -0x28(%ebp)
80100d4c:	e8 e7 0e 00 00       	call   80101c38 <iunlockput>
80100d51:	83 c4 10             	add    $0x10,%esp
  end_op();
80100d54:	e8 5f 28 00 00       	call   801035b8 <end_op>
  ip = 0;
80100d59:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)

  // Allocate two pages at the next page boundary.
  // Make the first inaccessible.  Use the second as the user stack.
  sz = PGROUNDUP(sz);
80100d60:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d63:	05 ff 0f 00 00       	add    $0xfff,%eax
80100d68:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80100d6d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  //if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
    //goto bad;

  //Lab 2 additions
  if (allocuvm(pgdir, STACK_TOP - PGSIZE, STACK_TOP) == 0)
80100d70:	83 ec 04             	sub    $0x4,%esp
80100d73:	68 fc ff ff 7f       	push   $0x7ffffffc
80100d78:	68 fc ef ff 7f       	push   $0x7fffeffc
80100d7d:	ff 75 d4             	pushl  -0x2c(%ebp)
80100d80:	e8 b9 71 00 00       	call   80107f3e <allocuvm>
80100d85:	83 c4 10             	add    $0x10,%esp
80100d88:	85 c0                	test   %eax,%eax
80100d8a:	0f 84 fe 01 00 00    	je     80100f8e <exec+0x3f8>
    goto bad;
  //clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
  sp = STACK_TOP;
80100d90:	c7 45 dc fc ff ff 7f 	movl   $0x7ffffffc,-0x24(%ebp)

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100d97:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80100d9e:	e9 96 00 00 00       	jmp    80100e39 <exec+0x2a3>
    if(argc >= MAXARG)
80100da3:	83 7d e4 1f          	cmpl   $0x1f,-0x1c(%ebp)
80100da7:	0f 87 e4 01 00 00    	ja     80100f91 <exec+0x3fb>
      goto bad;
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80100dad:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100db0:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100db7:	8b 45 0c             	mov    0xc(%ebp),%eax
80100dba:	01 d0                	add    %edx,%eax
80100dbc:	8b 00                	mov    (%eax),%eax
80100dbe:	83 ec 0c             	sub    $0xc,%esp
80100dc1:	50                   	push   %eax
80100dc2:	e8 6a 46 00 00       	call   80105431 <strlen>
80100dc7:	83 c4 10             	add    $0x10,%esp
80100dca:	89 c2                	mov    %eax,%edx
80100dcc:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100dcf:	29 d0                	sub    %edx,%eax
80100dd1:	83 e8 01             	sub    $0x1,%eax
80100dd4:	83 e0 fc             	and    $0xfffffffc,%eax
80100dd7:	89 45 dc             	mov    %eax,-0x24(%ebp)
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100dda:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100ddd:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100de4:	8b 45 0c             	mov    0xc(%ebp),%eax
80100de7:	01 d0                	add    %edx,%eax
80100de9:	8b 00                	mov    (%eax),%eax
80100deb:	83 ec 0c             	sub    $0xc,%esp
80100dee:	50                   	push   %eax
80100def:	e8 3d 46 00 00       	call   80105431 <strlen>
80100df4:	83 c4 10             	add    $0x10,%esp
80100df7:	83 c0 01             	add    $0x1,%eax
80100dfa:	89 c1                	mov    %eax,%ecx
80100dfc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100dff:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e06:	8b 45 0c             	mov    0xc(%ebp),%eax
80100e09:	01 d0                	add    %edx,%eax
80100e0b:	8b 00                	mov    (%eax),%eax
80100e0d:	51                   	push   %ecx
80100e0e:	50                   	push   %eax
80100e0f:	ff 75 dc             	pushl  -0x24(%ebp)
80100e12:	ff 75 d4             	pushl  -0x2c(%ebp)
80100e15:	e8 32 76 00 00       	call   8010844c <copyout>
80100e1a:	83 c4 10             	add    $0x10,%esp
80100e1d:	85 c0                	test   %eax,%eax
80100e1f:	0f 88 6f 01 00 00    	js     80100f94 <exec+0x3fe>
      goto bad;
    ustack[3+argc] = sp;
80100e25:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e28:	8d 50 03             	lea    0x3(%eax),%edx
80100e2b:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100e2e:	89 84 95 3c ff ff ff 	mov    %eax,-0xc4(%ebp,%edx,4)
    goto bad;
  //clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
  sp = STACK_TOP;

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100e35:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80100e39:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e3c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e43:	8b 45 0c             	mov    0xc(%ebp),%eax
80100e46:	01 d0                	add    %edx,%eax
80100e48:	8b 00                	mov    (%eax),%eax
80100e4a:	85 c0                	test   %eax,%eax
80100e4c:	0f 85 51 ff ff ff    	jne    80100da3 <exec+0x20d>
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
      goto bad;
    ustack[3+argc] = sp;
  }
  ustack[3+argc] = 0;
80100e52:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e55:	83 c0 03             	add    $0x3,%eax
80100e58:	c7 84 85 3c ff ff ff 	movl   $0x0,-0xc4(%ebp,%eax,4)
80100e5f:	00 00 00 00 

  ustack[0] = 0xffffffff;  // fake return PC
80100e63:	c7 85 3c ff ff ff ff 	movl   $0xffffffff,-0xc4(%ebp)
80100e6a:	ff ff ff 
  ustack[1] = argc;
80100e6d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e70:	89 85 40 ff ff ff    	mov    %eax,-0xc0(%ebp)
  ustack[2] = sp - (argc+1)*4;  // argv pointer
80100e76:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e79:	83 c0 01             	add    $0x1,%eax
80100e7c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e83:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100e86:	29 d0                	sub    %edx,%eax
80100e88:	89 85 44 ff ff ff    	mov    %eax,-0xbc(%ebp)

  sp -= (3+argc+1) * 4;
80100e8e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e91:	83 c0 04             	add    $0x4,%eax
80100e94:	c1 e0 02             	shl    $0x2,%eax
80100e97:	29 45 dc             	sub    %eax,-0x24(%ebp)
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
80100e9a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e9d:	83 c0 04             	add    $0x4,%eax
80100ea0:	c1 e0 02             	shl    $0x2,%eax
80100ea3:	50                   	push   %eax
80100ea4:	8d 85 3c ff ff ff    	lea    -0xc4(%ebp),%eax
80100eaa:	50                   	push   %eax
80100eab:	ff 75 dc             	pushl  -0x24(%ebp)
80100eae:	ff 75 d4             	pushl  -0x2c(%ebp)
80100eb1:	e8 96 75 00 00       	call   8010844c <copyout>
80100eb6:	83 c4 10             	add    $0x10,%esp
80100eb9:	85 c0                	test   %eax,%eax
80100ebb:	0f 88 d6 00 00 00    	js     80100f97 <exec+0x401>
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80100ec1:	8b 45 08             	mov    0x8(%ebp),%eax
80100ec4:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100ec7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100eca:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100ecd:	eb 17                	jmp    80100ee6 <exec+0x350>
    if(*s == '/')
80100ecf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100ed2:	0f b6 00             	movzbl (%eax),%eax
80100ed5:	3c 2f                	cmp    $0x2f,%al
80100ed7:	75 09                	jne    80100ee2 <exec+0x34c>
      last = s+1;
80100ed9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100edc:	83 c0 01             	add    $0x1,%eax
80100edf:	89 45 f0             	mov    %eax,-0x10(%ebp)
  sp -= (3+argc+1) * 4;
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80100ee2:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100ee6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100ee9:	0f b6 00             	movzbl (%eax),%eax
80100eec:	84 c0                	test   %al,%al
80100eee:	75 df                	jne    80100ecf <exec+0x339>
    if(*s == '/')
      last = s+1;
  safestrcpy(curproc->name, last, sizeof(curproc->name));
80100ef0:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100ef3:	83 c0 74             	add    $0x74,%eax
80100ef6:	83 ec 04             	sub    $0x4,%esp
80100ef9:	6a 10                	push   $0x10
80100efb:	ff 75 f0             	pushl  -0x10(%ebp)
80100efe:	50                   	push   %eax
80100eff:	e8 e3 44 00 00       	call   801053e7 <safestrcpy>
80100f04:	83 c4 10             	add    $0x10,%esp

  // Commit to the user image.
  oldpgdir = curproc->pgdir;
80100f07:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f0a:	8b 40 0c             	mov    0xc(%eax),%eax
80100f0d:	89 45 cc             	mov    %eax,-0x34(%ebp)
  curproc->pgdir = pgdir;
80100f10:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f13:	8b 55 d4             	mov    -0x2c(%ebp),%edx
80100f16:	89 50 0c             	mov    %edx,0xc(%eax)
  curproc->sz = sz;
80100f19:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f1c:	8b 55 e0             	mov    -0x20(%ebp),%edx
80100f1f:	89 10                	mov    %edx,(%eax)
  curproc->tf->eip = elf.entry;  // main
80100f21:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f24:	8b 40 20             	mov    0x20(%eax),%eax
80100f27:	8b 95 20 ff ff ff    	mov    -0xe0(%ebp),%edx
80100f2d:	89 50 38             	mov    %edx,0x38(%eax)
  curproc->tf->esp = sp;
80100f30:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f33:	8b 40 20             	mov    0x20(%eax),%eax
80100f36:	8b 55 dc             	mov    -0x24(%ebp),%edx
80100f39:	89 50 44             	mov    %edx,0x44(%eax)
  //Lab 2 additions
  curproc->stacktop = STACK_TOP;
80100f3c:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f3f:	c7 40 04 fc ff ff 7f 	movl   $0x7ffffffc,0x4(%eax)
  curproc->stackSize = 1; //Currently set to 1 page
80100f46:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f49:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
  switchuvm(curproc);
80100f50:	83 ec 0c             	sub    $0xc,%esp
80100f53:	ff 75 d0             	pushl  -0x30(%ebp)
80100f56:	e8 08 6d 00 00       	call   80107c63 <switchuvm>
80100f5b:	83 c4 10             	add    $0x10,%esp
  freevm(oldpgdir);
80100f5e:	83 ec 0c             	sub    $0xc,%esp
80100f61:	ff 75 cc             	pushl  -0x34(%ebp)
80100f64:	e8 b7 71 00 00       	call   80108120 <freevm>
80100f69:	83 c4 10             	add    $0x10,%esp
  return 0;
80100f6c:	b8 00 00 00 00       	mov    $0x0,%eax
80100f71:	eb 57                	jmp    80100fca <exec+0x434>
  ilock(ip);
  pgdir = 0;

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) != sizeof(elf))
    goto bad;
80100f73:	90                   	nop
80100f74:	eb 22                	jmp    80100f98 <exec+0x402>
  if(elf.magic != ELF_MAGIC)
    goto bad;
80100f76:	90                   	nop
80100f77:	eb 1f                	jmp    80100f98 <exec+0x402>

  if((pgdir = setupkvm()) == 0)
    goto bad;
80100f79:	90                   	nop
80100f7a:	eb 1c                	jmp    80100f98 <exec+0x402>

  // Load program into memory.
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
      goto bad;
80100f7c:	90                   	nop
80100f7d:	eb 19                	jmp    80100f98 <exec+0x402>
    if(ph.type != ELF_PROG_LOAD)
      continue;
    if(ph.memsz < ph.filesz)
      goto bad;
80100f7f:	90                   	nop
80100f80:	eb 16                	jmp    80100f98 <exec+0x402>
    if(ph.vaddr + ph.memsz < ph.vaddr)
      goto bad;
80100f82:	90                   	nop
80100f83:	eb 13                	jmp    80100f98 <exec+0x402>
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
      goto bad;
80100f85:	90                   	nop
80100f86:	eb 10                	jmp    80100f98 <exec+0x402>
    if(ph.vaddr % PGSIZE != 0)
      goto bad;
80100f88:	90                   	nop
80100f89:	eb 0d                	jmp    80100f98 <exec+0x402>
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
      goto bad;
80100f8b:	90                   	nop
80100f8c:	eb 0a                	jmp    80100f98 <exec+0x402>
  //if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
    //goto bad;

  //Lab 2 additions
  if (allocuvm(pgdir, STACK_TOP - PGSIZE, STACK_TOP) == 0)
    goto bad;
80100f8e:	90                   	nop
80100f8f:	eb 07                	jmp    80100f98 <exec+0x402>
  sp = STACK_TOP;

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
    if(argc >= MAXARG)
      goto bad;
80100f91:	90                   	nop
80100f92:	eb 04                	jmp    80100f98 <exec+0x402>
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
      goto bad;
80100f94:	90                   	nop
80100f95:	eb 01                	jmp    80100f98 <exec+0x402>
  ustack[1] = argc;
  ustack[2] = sp - (argc+1)*4;  // argv pointer

  sp -= (3+argc+1) * 4;
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
    goto bad;
80100f97:	90                   	nop
  switchuvm(curproc);
  freevm(oldpgdir);
  return 0;

 bad:
  if(pgdir)
80100f98:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100f9c:	74 0e                	je     80100fac <exec+0x416>
    freevm(pgdir);
80100f9e:	83 ec 0c             	sub    $0xc,%esp
80100fa1:	ff 75 d4             	pushl  -0x2c(%ebp)
80100fa4:	e8 77 71 00 00       	call   80108120 <freevm>
80100fa9:	83 c4 10             	add    $0x10,%esp
  if(ip){
80100fac:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100fb0:	74 13                	je     80100fc5 <exec+0x42f>
    iunlockput(ip);
80100fb2:	83 ec 0c             	sub    $0xc,%esp
80100fb5:	ff 75 d8             	pushl  -0x28(%ebp)
80100fb8:	e8 7b 0c 00 00       	call   80101c38 <iunlockput>
80100fbd:	83 c4 10             	add    $0x10,%esp
    end_op();
80100fc0:	e8 f3 25 00 00       	call   801035b8 <end_op>
  }
  return -1;
80100fc5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80100fca:	c9                   	leave  
80100fcb:	c3                   	ret    

80100fcc <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
80100fcc:	55                   	push   %ebp
80100fcd:	89 e5                	mov    %esp,%ebp
80100fcf:	83 ec 08             	sub    $0x8,%esp
  initlock(&ftable.lock, "ftable");
80100fd2:	83 ec 08             	sub    $0x8,%esp
80100fd5:	68 12 86 10 80       	push   $0x80108612
80100fda:	68 40 10 11 80       	push   $0x80111040
80100fdf:	e8 67 3f 00 00       	call   80104f4b <initlock>
80100fe4:	83 c4 10             	add    $0x10,%esp
}
80100fe7:	90                   	nop
80100fe8:	c9                   	leave  
80100fe9:	c3                   	ret    

80100fea <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
80100fea:	55                   	push   %ebp
80100feb:	89 e5                	mov    %esp,%ebp
80100fed:	83 ec 18             	sub    $0x18,%esp
  struct file *f;

  acquire(&ftable.lock);
80100ff0:	83 ec 0c             	sub    $0xc,%esp
80100ff3:	68 40 10 11 80       	push   $0x80111040
80100ff8:	e8 70 3f 00 00       	call   80104f6d <acquire>
80100ffd:	83 c4 10             	add    $0x10,%esp
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80101000:	c7 45 f4 74 10 11 80 	movl   $0x80111074,-0xc(%ebp)
80101007:	eb 2d                	jmp    80101036 <filealloc+0x4c>
    if(f->ref == 0){
80101009:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010100c:	8b 40 04             	mov    0x4(%eax),%eax
8010100f:	85 c0                	test   %eax,%eax
80101011:	75 1f                	jne    80101032 <filealloc+0x48>
      f->ref = 1;
80101013:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101016:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
      release(&ftable.lock);
8010101d:	83 ec 0c             	sub    $0xc,%esp
80101020:	68 40 10 11 80       	push   $0x80111040
80101025:	e8 b1 3f 00 00       	call   80104fdb <release>
8010102a:	83 c4 10             	add    $0x10,%esp
      return f;
8010102d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101030:	eb 23                	jmp    80101055 <filealloc+0x6b>
filealloc(void)
{
  struct file *f;

  acquire(&ftable.lock);
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80101032:	83 45 f4 18          	addl   $0x18,-0xc(%ebp)
80101036:	b8 d4 19 11 80       	mov    $0x801119d4,%eax
8010103b:	39 45 f4             	cmp    %eax,-0xc(%ebp)
8010103e:	72 c9                	jb     80101009 <filealloc+0x1f>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
80101040:	83 ec 0c             	sub    $0xc,%esp
80101043:	68 40 10 11 80       	push   $0x80111040
80101048:	e8 8e 3f 00 00       	call   80104fdb <release>
8010104d:	83 c4 10             	add    $0x10,%esp
  return 0;
80101050:	b8 00 00 00 00       	mov    $0x0,%eax
}
80101055:	c9                   	leave  
80101056:	c3                   	ret    

80101057 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
80101057:	55                   	push   %ebp
80101058:	89 e5                	mov    %esp,%ebp
8010105a:	83 ec 08             	sub    $0x8,%esp
  acquire(&ftable.lock);
8010105d:	83 ec 0c             	sub    $0xc,%esp
80101060:	68 40 10 11 80       	push   $0x80111040
80101065:	e8 03 3f 00 00       	call   80104f6d <acquire>
8010106a:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
8010106d:	8b 45 08             	mov    0x8(%ebp),%eax
80101070:	8b 40 04             	mov    0x4(%eax),%eax
80101073:	85 c0                	test   %eax,%eax
80101075:	7f 0d                	jg     80101084 <filedup+0x2d>
    panic("filedup");
80101077:	83 ec 0c             	sub    $0xc,%esp
8010107a:	68 19 86 10 80       	push   $0x80108619
8010107f:	e8 1c f5 ff ff       	call   801005a0 <panic>
  f->ref++;
80101084:	8b 45 08             	mov    0x8(%ebp),%eax
80101087:	8b 40 04             	mov    0x4(%eax),%eax
8010108a:	8d 50 01             	lea    0x1(%eax),%edx
8010108d:	8b 45 08             	mov    0x8(%ebp),%eax
80101090:	89 50 04             	mov    %edx,0x4(%eax)
  release(&ftable.lock);
80101093:	83 ec 0c             	sub    $0xc,%esp
80101096:	68 40 10 11 80       	push   $0x80111040
8010109b:	e8 3b 3f 00 00       	call   80104fdb <release>
801010a0:	83 c4 10             	add    $0x10,%esp
  return f;
801010a3:	8b 45 08             	mov    0x8(%ebp),%eax
}
801010a6:	c9                   	leave  
801010a7:	c3                   	ret    

801010a8 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
801010a8:	55                   	push   %ebp
801010a9:	89 e5                	mov    %esp,%ebp
801010ab:	83 ec 28             	sub    $0x28,%esp
  struct file ff;

  acquire(&ftable.lock);
801010ae:	83 ec 0c             	sub    $0xc,%esp
801010b1:	68 40 10 11 80       	push   $0x80111040
801010b6:	e8 b2 3e 00 00       	call   80104f6d <acquire>
801010bb:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
801010be:	8b 45 08             	mov    0x8(%ebp),%eax
801010c1:	8b 40 04             	mov    0x4(%eax),%eax
801010c4:	85 c0                	test   %eax,%eax
801010c6:	7f 0d                	jg     801010d5 <fileclose+0x2d>
    panic("fileclose");
801010c8:	83 ec 0c             	sub    $0xc,%esp
801010cb:	68 21 86 10 80       	push   $0x80108621
801010d0:	e8 cb f4 ff ff       	call   801005a0 <panic>
  if(--f->ref > 0){
801010d5:	8b 45 08             	mov    0x8(%ebp),%eax
801010d8:	8b 40 04             	mov    0x4(%eax),%eax
801010db:	8d 50 ff             	lea    -0x1(%eax),%edx
801010de:	8b 45 08             	mov    0x8(%ebp),%eax
801010e1:	89 50 04             	mov    %edx,0x4(%eax)
801010e4:	8b 45 08             	mov    0x8(%ebp),%eax
801010e7:	8b 40 04             	mov    0x4(%eax),%eax
801010ea:	85 c0                	test   %eax,%eax
801010ec:	7e 15                	jle    80101103 <fileclose+0x5b>
    release(&ftable.lock);
801010ee:	83 ec 0c             	sub    $0xc,%esp
801010f1:	68 40 10 11 80       	push   $0x80111040
801010f6:	e8 e0 3e 00 00       	call   80104fdb <release>
801010fb:	83 c4 10             	add    $0x10,%esp
801010fe:	e9 8b 00 00 00       	jmp    8010118e <fileclose+0xe6>
    return;
  }
  ff = *f;
80101103:	8b 45 08             	mov    0x8(%ebp),%eax
80101106:	8b 10                	mov    (%eax),%edx
80101108:	89 55 e0             	mov    %edx,-0x20(%ebp)
8010110b:	8b 50 04             	mov    0x4(%eax),%edx
8010110e:	89 55 e4             	mov    %edx,-0x1c(%ebp)
80101111:	8b 50 08             	mov    0x8(%eax),%edx
80101114:	89 55 e8             	mov    %edx,-0x18(%ebp)
80101117:	8b 50 0c             	mov    0xc(%eax),%edx
8010111a:	89 55 ec             	mov    %edx,-0x14(%ebp)
8010111d:	8b 50 10             	mov    0x10(%eax),%edx
80101120:	89 55 f0             	mov    %edx,-0x10(%ebp)
80101123:	8b 40 14             	mov    0x14(%eax),%eax
80101126:	89 45 f4             	mov    %eax,-0xc(%ebp)
  f->ref = 0;
80101129:	8b 45 08             	mov    0x8(%ebp),%eax
8010112c:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  f->type = FD_NONE;
80101133:	8b 45 08             	mov    0x8(%ebp),%eax
80101136:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  release(&ftable.lock);
8010113c:	83 ec 0c             	sub    $0xc,%esp
8010113f:	68 40 10 11 80       	push   $0x80111040
80101144:	e8 92 3e 00 00       	call   80104fdb <release>
80101149:	83 c4 10             	add    $0x10,%esp

  if(ff.type == FD_PIPE)
8010114c:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010114f:	83 f8 01             	cmp    $0x1,%eax
80101152:	75 19                	jne    8010116d <fileclose+0xc5>
    pipeclose(ff.pipe, ff.writable);
80101154:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
80101158:	0f be d0             	movsbl %al,%edx
8010115b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010115e:	83 ec 08             	sub    $0x8,%esp
80101161:	52                   	push   %edx
80101162:	50                   	push   %eax
80101163:	e8 a6 2d 00 00       	call   80103f0e <pipeclose>
80101168:	83 c4 10             	add    $0x10,%esp
8010116b:	eb 21                	jmp    8010118e <fileclose+0xe6>
  else if(ff.type == FD_INODE){
8010116d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101170:	83 f8 02             	cmp    $0x2,%eax
80101173:	75 19                	jne    8010118e <fileclose+0xe6>
    begin_op();
80101175:	e8 b2 23 00 00       	call   8010352c <begin_op>
    iput(ff.ip);
8010117a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010117d:	83 ec 0c             	sub    $0xc,%esp
80101180:	50                   	push   %eax
80101181:	e8 e2 09 00 00       	call   80101b68 <iput>
80101186:	83 c4 10             	add    $0x10,%esp
    end_op();
80101189:	e8 2a 24 00 00       	call   801035b8 <end_op>
  }
}
8010118e:	c9                   	leave  
8010118f:	c3                   	ret    

80101190 <filestat>:

// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
80101190:	55                   	push   %ebp
80101191:	89 e5                	mov    %esp,%ebp
80101193:	83 ec 08             	sub    $0x8,%esp
  if(f->type == FD_INODE){
80101196:	8b 45 08             	mov    0x8(%ebp),%eax
80101199:	8b 00                	mov    (%eax),%eax
8010119b:	83 f8 02             	cmp    $0x2,%eax
8010119e:	75 40                	jne    801011e0 <filestat+0x50>
    ilock(f->ip);
801011a0:	8b 45 08             	mov    0x8(%ebp),%eax
801011a3:	8b 40 10             	mov    0x10(%eax),%eax
801011a6:	83 ec 0c             	sub    $0xc,%esp
801011a9:	50                   	push   %eax
801011aa:	e8 58 08 00 00       	call   80101a07 <ilock>
801011af:	83 c4 10             	add    $0x10,%esp
    stati(f->ip, st);
801011b2:	8b 45 08             	mov    0x8(%ebp),%eax
801011b5:	8b 40 10             	mov    0x10(%eax),%eax
801011b8:	83 ec 08             	sub    $0x8,%esp
801011bb:	ff 75 0c             	pushl  0xc(%ebp)
801011be:	50                   	push   %eax
801011bf:	e8 ee 0c 00 00       	call   80101eb2 <stati>
801011c4:	83 c4 10             	add    $0x10,%esp
    iunlock(f->ip);
801011c7:	8b 45 08             	mov    0x8(%ebp),%eax
801011ca:	8b 40 10             	mov    0x10(%eax),%eax
801011cd:	83 ec 0c             	sub    $0xc,%esp
801011d0:	50                   	push   %eax
801011d1:	e8 44 09 00 00       	call   80101b1a <iunlock>
801011d6:	83 c4 10             	add    $0x10,%esp
    return 0;
801011d9:	b8 00 00 00 00       	mov    $0x0,%eax
801011de:	eb 05                	jmp    801011e5 <filestat+0x55>
  }
  return -1;
801011e0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801011e5:	c9                   	leave  
801011e6:	c3                   	ret    

801011e7 <fileread>:

// Read from file f.
int
fileread(struct file *f, char *addr, int n)
{
801011e7:	55                   	push   %ebp
801011e8:	89 e5                	mov    %esp,%ebp
801011ea:	83 ec 18             	sub    $0x18,%esp
  int r;

  if(f->readable == 0)
801011ed:	8b 45 08             	mov    0x8(%ebp),%eax
801011f0:	0f b6 40 08          	movzbl 0x8(%eax),%eax
801011f4:	84 c0                	test   %al,%al
801011f6:	75 0a                	jne    80101202 <fileread+0x1b>
    return -1;
801011f8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801011fd:	e9 9b 00 00 00       	jmp    8010129d <fileread+0xb6>
  if(f->type == FD_PIPE)
80101202:	8b 45 08             	mov    0x8(%ebp),%eax
80101205:	8b 00                	mov    (%eax),%eax
80101207:	83 f8 01             	cmp    $0x1,%eax
8010120a:	75 1a                	jne    80101226 <fileread+0x3f>
    return piperead(f->pipe, addr, n);
8010120c:	8b 45 08             	mov    0x8(%ebp),%eax
8010120f:	8b 40 0c             	mov    0xc(%eax),%eax
80101212:	83 ec 04             	sub    $0x4,%esp
80101215:	ff 75 10             	pushl  0x10(%ebp)
80101218:	ff 75 0c             	pushl  0xc(%ebp)
8010121b:	50                   	push   %eax
8010121c:	e8 94 2e 00 00       	call   801040b5 <piperead>
80101221:	83 c4 10             	add    $0x10,%esp
80101224:	eb 77                	jmp    8010129d <fileread+0xb6>
  if(f->type == FD_INODE){
80101226:	8b 45 08             	mov    0x8(%ebp),%eax
80101229:	8b 00                	mov    (%eax),%eax
8010122b:	83 f8 02             	cmp    $0x2,%eax
8010122e:	75 60                	jne    80101290 <fileread+0xa9>
    ilock(f->ip);
80101230:	8b 45 08             	mov    0x8(%ebp),%eax
80101233:	8b 40 10             	mov    0x10(%eax),%eax
80101236:	83 ec 0c             	sub    $0xc,%esp
80101239:	50                   	push   %eax
8010123a:	e8 c8 07 00 00       	call   80101a07 <ilock>
8010123f:	83 c4 10             	add    $0x10,%esp
    if((r = readi(f->ip, addr, f->off, n)) > 0)
80101242:	8b 4d 10             	mov    0x10(%ebp),%ecx
80101245:	8b 45 08             	mov    0x8(%ebp),%eax
80101248:	8b 50 14             	mov    0x14(%eax),%edx
8010124b:	8b 45 08             	mov    0x8(%ebp),%eax
8010124e:	8b 40 10             	mov    0x10(%eax),%eax
80101251:	51                   	push   %ecx
80101252:	52                   	push   %edx
80101253:	ff 75 0c             	pushl  0xc(%ebp)
80101256:	50                   	push   %eax
80101257:	e8 9c 0c 00 00       	call   80101ef8 <readi>
8010125c:	83 c4 10             	add    $0x10,%esp
8010125f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101262:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101266:	7e 11                	jle    80101279 <fileread+0x92>
      f->off += r;
80101268:	8b 45 08             	mov    0x8(%ebp),%eax
8010126b:	8b 50 14             	mov    0x14(%eax),%edx
8010126e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101271:	01 c2                	add    %eax,%edx
80101273:	8b 45 08             	mov    0x8(%ebp),%eax
80101276:	89 50 14             	mov    %edx,0x14(%eax)
    iunlock(f->ip);
80101279:	8b 45 08             	mov    0x8(%ebp),%eax
8010127c:	8b 40 10             	mov    0x10(%eax),%eax
8010127f:	83 ec 0c             	sub    $0xc,%esp
80101282:	50                   	push   %eax
80101283:	e8 92 08 00 00       	call   80101b1a <iunlock>
80101288:	83 c4 10             	add    $0x10,%esp
    return r;
8010128b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010128e:	eb 0d                	jmp    8010129d <fileread+0xb6>
  }
  panic("fileread");
80101290:	83 ec 0c             	sub    $0xc,%esp
80101293:	68 2b 86 10 80       	push   $0x8010862b
80101298:	e8 03 f3 ff ff       	call   801005a0 <panic>
}
8010129d:	c9                   	leave  
8010129e:	c3                   	ret    

8010129f <filewrite>:

//PAGEBREAK!
// Write to file f.
int
filewrite(struct file *f, char *addr, int n)
{
8010129f:	55                   	push   %ebp
801012a0:	89 e5                	mov    %esp,%ebp
801012a2:	53                   	push   %ebx
801012a3:	83 ec 14             	sub    $0x14,%esp
  int r;

  if(f->writable == 0)
801012a6:	8b 45 08             	mov    0x8(%ebp),%eax
801012a9:	0f b6 40 09          	movzbl 0x9(%eax),%eax
801012ad:	84 c0                	test   %al,%al
801012af:	75 0a                	jne    801012bb <filewrite+0x1c>
    return -1;
801012b1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801012b6:	e9 1b 01 00 00       	jmp    801013d6 <filewrite+0x137>
  if(f->type == FD_PIPE)
801012bb:	8b 45 08             	mov    0x8(%ebp),%eax
801012be:	8b 00                	mov    (%eax),%eax
801012c0:	83 f8 01             	cmp    $0x1,%eax
801012c3:	75 1d                	jne    801012e2 <filewrite+0x43>
    return pipewrite(f->pipe, addr, n);
801012c5:	8b 45 08             	mov    0x8(%ebp),%eax
801012c8:	8b 40 0c             	mov    0xc(%eax),%eax
801012cb:	83 ec 04             	sub    $0x4,%esp
801012ce:	ff 75 10             	pushl  0x10(%ebp)
801012d1:	ff 75 0c             	pushl  0xc(%ebp)
801012d4:	50                   	push   %eax
801012d5:	e8 de 2c 00 00       	call   80103fb8 <pipewrite>
801012da:	83 c4 10             	add    $0x10,%esp
801012dd:	e9 f4 00 00 00       	jmp    801013d6 <filewrite+0x137>
  if(f->type == FD_INODE){
801012e2:	8b 45 08             	mov    0x8(%ebp),%eax
801012e5:	8b 00                	mov    (%eax),%eax
801012e7:	83 f8 02             	cmp    $0x2,%eax
801012ea:	0f 85 d9 00 00 00    	jne    801013c9 <filewrite+0x12a>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((LOGSIZE-1-1-2) / 2) * 512;
801012f0:	c7 45 ec 00 1a 00 00 	movl   $0x1a00,-0x14(%ebp)
    int i = 0;
801012f7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while(i < n){
801012fe:	e9 a3 00 00 00       	jmp    801013a6 <filewrite+0x107>
      int n1 = n - i;
80101303:	8b 45 10             	mov    0x10(%ebp),%eax
80101306:	2b 45 f4             	sub    -0xc(%ebp),%eax
80101309:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if(n1 > max)
8010130c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010130f:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80101312:	7e 06                	jle    8010131a <filewrite+0x7b>
        n1 = max;
80101314:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101317:	89 45 f0             	mov    %eax,-0x10(%ebp)

      begin_op();
8010131a:	e8 0d 22 00 00       	call   8010352c <begin_op>
      ilock(f->ip);
8010131f:	8b 45 08             	mov    0x8(%ebp),%eax
80101322:	8b 40 10             	mov    0x10(%eax),%eax
80101325:	83 ec 0c             	sub    $0xc,%esp
80101328:	50                   	push   %eax
80101329:	e8 d9 06 00 00       	call   80101a07 <ilock>
8010132e:	83 c4 10             	add    $0x10,%esp
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
80101331:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80101334:	8b 45 08             	mov    0x8(%ebp),%eax
80101337:	8b 50 14             	mov    0x14(%eax),%edx
8010133a:	8b 5d f4             	mov    -0xc(%ebp),%ebx
8010133d:	8b 45 0c             	mov    0xc(%ebp),%eax
80101340:	01 c3                	add    %eax,%ebx
80101342:	8b 45 08             	mov    0x8(%ebp),%eax
80101345:	8b 40 10             	mov    0x10(%eax),%eax
80101348:	51                   	push   %ecx
80101349:	52                   	push   %edx
8010134a:	53                   	push   %ebx
8010134b:	50                   	push   %eax
8010134c:	e8 fe 0c 00 00       	call   8010204f <writei>
80101351:	83 c4 10             	add    $0x10,%esp
80101354:	89 45 e8             	mov    %eax,-0x18(%ebp)
80101357:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
8010135b:	7e 11                	jle    8010136e <filewrite+0xcf>
        f->off += r;
8010135d:	8b 45 08             	mov    0x8(%ebp),%eax
80101360:	8b 50 14             	mov    0x14(%eax),%edx
80101363:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101366:	01 c2                	add    %eax,%edx
80101368:	8b 45 08             	mov    0x8(%ebp),%eax
8010136b:	89 50 14             	mov    %edx,0x14(%eax)
      iunlock(f->ip);
8010136e:	8b 45 08             	mov    0x8(%ebp),%eax
80101371:	8b 40 10             	mov    0x10(%eax),%eax
80101374:	83 ec 0c             	sub    $0xc,%esp
80101377:	50                   	push   %eax
80101378:	e8 9d 07 00 00       	call   80101b1a <iunlock>
8010137d:	83 c4 10             	add    $0x10,%esp
      end_op();
80101380:	e8 33 22 00 00       	call   801035b8 <end_op>

      if(r < 0)
80101385:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80101389:	78 29                	js     801013b4 <filewrite+0x115>
        break;
      if(r != n1)
8010138b:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010138e:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80101391:	74 0d                	je     801013a0 <filewrite+0x101>
        panic("short filewrite");
80101393:	83 ec 0c             	sub    $0xc,%esp
80101396:	68 34 86 10 80       	push   $0x80108634
8010139b:	e8 00 f2 ff ff       	call   801005a0 <panic>
      i += r;
801013a0:	8b 45 e8             	mov    -0x18(%ebp),%eax
801013a3:	01 45 f4             	add    %eax,-0xc(%ebp)
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((LOGSIZE-1-1-2) / 2) * 512;
    int i = 0;
    while(i < n){
801013a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801013a9:	3b 45 10             	cmp    0x10(%ebp),%eax
801013ac:	0f 8c 51 ff ff ff    	jl     80101303 <filewrite+0x64>
801013b2:	eb 01                	jmp    801013b5 <filewrite+0x116>
        f->off += r;
      iunlock(f->ip);
      end_op();

      if(r < 0)
        break;
801013b4:	90                   	nop
      if(r != n1)
        panic("short filewrite");
      i += r;
    }
    return i == n ? n : -1;
801013b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801013b8:	3b 45 10             	cmp    0x10(%ebp),%eax
801013bb:	75 05                	jne    801013c2 <filewrite+0x123>
801013bd:	8b 45 10             	mov    0x10(%ebp),%eax
801013c0:	eb 14                	jmp    801013d6 <filewrite+0x137>
801013c2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801013c7:	eb 0d                	jmp    801013d6 <filewrite+0x137>
  }
  panic("filewrite");
801013c9:	83 ec 0c             	sub    $0xc,%esp
801013cc:	68 44 86 10 80       	push   $0x80108644
801013d1:	e8 ca f1 ff ff       	call   801005a0 <panic>
}
801013d6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801013d9:	c9                   	leave  
801013da:	c3                   	ret    

801013db <readsb>:
struct superblock sb; 

// Read the super block.
void
readsb(int dev, struct superblock *sb)
{
801013db:	55                   	push   %ebp
801013dc:	89 e5                	mov    %esp,%ebp
801013de:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;

  bp = bread(dev, 1);
801013e1:	8b 45 08             	mov    0x8(%ebp),%eax
801013e4:	83 ec 08             	sub    $0x8,%esp
801013e7:	6a 01                	push   $0x1
801013e9:	50                   	push   %eax
801013ea:	e8 df ed ff ff       	call   801001ce <bread>
801013ef:	83 c4 10             	add    $0x10,%esp
801013f2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove(sb, bp->data, sizeof(*sb));
801013f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801013f8:	83 c0 5c             	add    $0x5c,%eax
801013fb:	83 ec 04             	sub    $0x4,%esp
801013fe:	6a 1c                	push   $0x1c
80101400:	50                   	push   %eax
80101401:	ff 75 0c             	pushl  0xc(%ebp)
80101404:	e8 9a 3e 00 00       	call   801052a3 <memmove>
80101409:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
8010140c:	83 ec 0c             	sub    $0xc,%esp
8010140f:	ff 75 f4             	pushl  -0xc(%ebp)
80101412:	e8 39 ee ff ff       	call   80100250 <brelse>
80101417:	83 c4 10             	add    $0x10,%esp
}
8010141a:	90                   	nop
8010141b:	c9                   	leave  
8010141c:	c3                   	ret    

8010141d <bzero>:

// Zero a block.
static void
bzero(int dev, int bno)
{
8010141d:	55                   	push   %ebp
8010141e:	89 e5                	mov    %esp,%ebp
80101420:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;

  bp = bread(dev, bno);
80101423:	8b 55 0c             	mov    0xc(%ebp),%edx
80101426:	8b 45 08             	mov    0x8(%ebp),%eax
80101429:	83 ec 08             	sub    $0x8,%esp
8010142c:	52                   	push   %edx
8010142d:	50                   	push   %eax
8010142e:	e8 9b ed ff ff       	call   801001ce <bread>
80101433:	83 c4 10             	add    $0x10,%esp
80101436:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(bp->data, 0, BSIZE);
80101439:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010143c:	83 c0 5c             	add    $0x5c,%eax
8010143f:	83 ec 04             	sub    $0x4,%esp
80101442:	68 00 02 00 00       	push   $0x200
80101447:	6a 00                	push   $0x0
80101449:	50                   	push   %eax
8010144a:	e8 95 3d 00 00       	call   801051e4 <memset>
8010144f:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
80101452:	83 ec 0c             	sub    $0xc,%esp
80101455:	ff 75 f4             	pushl  -0xc(%ebp)
80101458:	e8 07 23 00 00       	call   80103764 <log_write>
8010145d:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
80101460:	83 ec 0c             	sub    $0xc,%esp
80101463:	ff 75 f4             	pushl  -0xc(%ebp)
80101466:	e8 e5 ed ff ff       	call   80100250 <brelse>
8010146b:	83 c4 10             	add    $0x10,%esp
}
8010146e:	90                   	nop
8010146f:	c9                   	leave  
80101470:	c3                   	ret    

80101471 <balloc>:
// Blocks.

// Allocate a zeroed disk block.
static uint
balloc(uint dev)
{
80101471:	55                   	push   %ebp
80101472:	89 e5                	mov    %esp,%ebp
80101474:	83 ec 18             	sub    $0x18,%esp
  int b, bi, m;
  struct buf *bp;

  bp = 0;
80101477:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(b = 0; b < sb.size; b += BPB){
8010147e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101485:	e9 13 01 00 00       	jmp    8010159d <balloc+0x12c>
    bp = bread(dev, BBLOCK(b, sb));
8010148a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010148d:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
80101493:	85 c0                	test   %eax,%eax
80101495:	0f 48 c2             	cmovs  %edx,%eax
80101498:	c1 f8 0c             	sar    $0xc,%eax
8010149b:	89 c2                	mov    %eax,%edx
8010149d:	a1 58 1a 11 80       	mov    0x80111a58,%eax
801014a2:	01 d0                	add    %edx,%eax
801014a4:	83 ec 08             	sub    $0x8,%esp
801014a7:	50                   	push   %eax
801014a8:	ff 75 08             	pushl  0x8(%ebp)
801014ab:	e8 1e ed ff ff       	call   801001ce <bread>
801014b0:	83 c4 10             	add    $0x10,%esp
801014b3:	89 45 ec             	mov    %eax,-0x14(%ebp)
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
801014b6:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801014bd:	e9 a6 00 00 00       	jmp    80101568 <balloc+0xf7>
      m = 1 << (bi % 8);
801014c2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801014c5:	99                   	cltd   
801014c6:	c1 ea 1d             	shr    $0x1d,%edx
801014c9:	01 d0                	add    %edx,%eax
801014cb:	83 e0 07             	and    $0x7,%eax
801014ce:	29 d0                	sub    %edx,%eax
801014d0:	ba 01 00 00 00       	mov    $0x1,%edx
801014d5:	89 c1                	mov    %eax,%ecx
801014d7:	d3 e2                	shl    %cl,%edx
801014d9:	89 d0                	mov    %edx,%eax
801014db:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if((bp->data[bi/8] & m) == 0){  // Is block free?
801014de:	8b 45 f0             	mov    -0x10(%ebp),%eax
801014e1:	8d 50 07             	lea    0x7(%eax),%edx
801014e4:	85 c0                	test   %eax,%eax
801014e6:	0f 48 c2             	cmovs  %edx,%eax
801014e9:	c1 f8 03             	sar    $0x3,%eax
801014ec:	89 c2                	mov    %eax,%edx
801014ee:	8b 45 ec             	mov    -0x14(%ebp),%eax
801014f1:	0f b6 44 10 5c       	movzbl 0x5c(%eax,%edx,1),%eax
801014f6:	0f b6 c0             	movzbl %al,%eax
801014f9:	23 45 e8             	and    -0x18(%ebp),%eax
801014fc:	85 c0                	test   %eax,%eax
801014fe:	75 64                	jne    80101564 <balloc+0xf3>
        bp->data[bi/8] |= m;  // Mark block in use.
80101500:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101503:	8d 50 07             	lea    0x7(%eax),%edx
80101506:	85 c0                	test   %eax,%eax
80101508:	0f 48 c2             	cmovs  %edx,%eax
8010150b:	c1 f8 03             	sar    $0x3,%eax
8010150e:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101511:	0f b6 54 02 5c       	movzbl 0x5c(%edx,%eax,1),%edx
80101516:	89 d1                	mov    %edx,%ecx
80101518:	8b 55 e8             	mov    -0x18(%ebp),%edx
8010151b:	09 ca                	or     %ecx,%edx
8010151d:	89 d1                	mov    %edx,%ecx
8010151f:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101522:	88 4c 02 5c          	mov    %cl,0x5c(%edx,%eax,1)
        log_write(bp);
80101526:	83 ec 0c             	sub    $0xc,%esp
80101529:	ff 75 ec             	pushl  -0x14(%ebp)
8010152c:	e8 33 22 00 00       	call   80103764 <log_write>
80101531:	83 c4 10             	add    $0x10,%esp
        brelse(bp);
80101534:	83 ec 0c             	sub    $0xc,%esp
80101537:	ff 75 ec             	pushl  -0x14(%ebp)
8010153a:	e8 11 ed ff ff       	call   80100250 <brelse>
8010153f:	83 c4 10             	add    $0x10,%esp
        bzero(dev, b + bi);
80101542:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101545:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101548:	01 c2                	add    %eax,%edx
8010154a:	8b 45 08             	mov    0x8(%ebp),%eax
8010154d:	83 ec 08             	sub    $0x8,%esp
80101550:	52                   	push   %edx
80101551:	50                   	push   %eax
80101552:	e8 c6 fe ff ff       	call   8010141d <bzero>
80101557:	83 c4 10             	add    $0x10,%esp
        return b + bi;
8010155a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010155d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101560:	01 d0                	add    %edx,%eax
80101562:	eb 57                	jmp    801015bb <balloc+0x14a>
  struct buf *bp;

  bp = 0;
  for(b = 0; b < sb.size; b += BPB){
    bp = bread(dev, BBLOCK(b, sb));
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
80101564:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80101568:	81 7d f0 ff 0f 00 00 	cmpl   $0xfff,-0x10(%ebp)
8010156f:	7f 17                	jg     80101588 <balloc+0x117>
80101571:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101574:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101577:	01 d0                	add    %edx,%eax
80101579:	89 c2                	mov    %eax,%edx
8010157b:	a1 40 1a 11 80       	mov    0x80111a40,%eax
80101580:	39 c2                	cmp    %eax,%edx
80101582:	0f 82 3a ff ff ff    	jb     801014c2 <balloc+0x51>
        brelse(bp);
        bzero(dev, b + bi);
        return b + bi;
      }
    }
    brelse(bp);
80101588:	83 ec 0c             	sub    $0xc,%esp
8010158b:	ff 75 ec             	pushl  -0x14(%ebp)
8010158e:	e8 bd ec ff ff       	call   80100250 <brelse>
80101593:	83 c4 10             	add    $0x10,%esp
{
  int b, bi, m;
  struct buf *bp;

  bp = 0;
  for(b = 0; b < sb.size; b += BPB){
80101596:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010159d:	8b 15 40 1a 11 80    	mov    0x80111a40,%edx
801015a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801015a6:	39 c2                	cmp    %eax,%edx
801015a8:	0f 87 dc fe ff ff    	ja     8010148a <balloc+0x19>
        return b + bi;
      }
    }
    brelse(bp);
  }
  panic("balloc: out of blocks");
801015ae:	83 ec 0c             	sub    $0xc,%esp
801015b1:	68 50 86 10 80       	push   $0x80108650
801015b6:	e8 e5 ef ff ff       	call   801005a0 <panic>
}
801015bb:	c9                   	leave  
801015bc:	c3                   	ret    

801015bd <bfree>:

// Free a disk block.
static void
bfree(int dev, uint b)
{
801015bd:	55                   	push   %ebp
801015be:	89 e5                	mov    %esp,%ebp
801015c0:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  int bi, m;

  readsb(dev, &sb);
801015c3:	83 ec 08             	sub    $0x8,%esp
801015c6:	68 40 1a 11 80       	push   $0x80111a40
801015cb:	ff 75 08             	pushl  0x8(%ebp)
801015ce:	e8 08 fe ff ff       	call   801013db <readsb>
801015d3:	83 c4 10             	add    $0x10,%esp
  bp = bread(dev, BBLOCK(b, sb));
801015d6:	8b 45 0c             	mov    0xc(%ebp),%eax
801015d9:	c1 e8 0c             	shr    $0xc,%eax
801015dc:	89 c2                	mov    %eax,%edx
801015de:	a1 58 1a 11 80       	mov    0x80111a58,%eax
801015e3:	01 c2                	add    %eax,%edx
801015e5:	8b 45 08             	mov    0x8(%ebp),%eax
801015e8:	83 ec 08             	sub    $0x8,%esp
801015eb:	52                   	push   %edx
801015ec:	50                   	push   %eax
801015ed:	e8 dc eb ff ff       	call   801001ce <bread>
801015f2:	83 c4 10             	add    $0x10,%esp
801015f5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  bi = b % BPB;
801015f8:	8b 45 0c             	mov    0xc(%ebp),%eax
801015fb:	25 ff 0f 00 00       	and    $0xfff,%eax
80101600:	89 45 f0             	mov    %eax,-0x10(%ebp)
  m = 1 << (bi % 8);
80101603:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101606:	99                   	cltd   
80101607:	c1 ea 1d             	shr    $0x1d,%edx
8010160a:	01 d0                	add    %edx,%eax
8010160c:	83 e0 07             	and    $0x7,%eax
8010160f:	29 d0                	sub    %edx,%eax
80101611:	ba 01 00 00 00       	mov    $0x1,%edx
80101616:	89 c1                	mov    %eax,%ecx
80101618:	d3 e2                	shl    %cl,%edx
8010161a:	89 d0                	mov    %edx,%eax
8010161c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((bp->data[bi/8] & m) == 0)
8010161f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101622:	8d 50 07             	lea    0x7(%eax),%edx
80101625:	85 c0                	test   %eax,%eax
80101627:	0f 48 c2             	cmovs  %edx,%eax
8010162a:	c1 f8 03             	sar    $0x3,%eax
8010162d:	89 c2                	mov    %eax,%edx
8010162f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101632:	0f b6 44 10 5c       	movzbl 0x5c(%eax,%edx,1),%eax
80101637:	0f b6 c0             	movzbl %al,%eax
8010163a:	23 45 ec             	and    -0x14(%ebp),%eax
8010163d:	85 c0                	test   %eax,%eax
8010163f:	75 0d                	jne    8010164e <bfree+0x91>
    panic("freeing free block");
80101641:	83 ec 0c             	sub    $0xc,%esp
80101644:	68 66 86 10 80       	push   $0x80108666
80101649:	e8 52 ef ff ff       	call   801005a0 <panic>
  bp->data[bi/8] &= ~m;
8010164e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101651:	8d 50 07             	lea    0x7(%eax),%edx
80101654:	85 c0                	test   %eax,%eax
80101656:	0f 48 c2             	cmovs  %edx,%eax
80101659:	c1 f8 03             	sar    $0x3,%eax
8010165c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010165f:	0f b6 54 02 5c       	movzbl 0x5c(%edx,%eax,1),%edx
80101664:	89 d1                	mov    %edx,%ecx
80101666:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101669:	f7 d2                	not    %edx
8010166b:	21 ca                	and    %ecx,%edx
8010166d:	89 d1                	mov    %edx,%ecx
8010166f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101672:	88 4c 02 5c          	mov    %cl,0x5c(%edx,%eax,1)
  log_write(bp);
80101676:	83 ec 0c             	sub    $0xc,%esp
80101679:	ff 75 f4             	pushl  -0xc(%ebp)
8010167c:	e8 e3 20 00 00       	call   80103764 <log_write>
80101681:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
80101684:	83 ec 0c             	sub    $0xc,%esp
80101687:	ff 75 f4             	pushl  -0xc(%ebp)
8010168a:	e8 c1 eb ff ff       	call   80100250 <brelse>
8010168f:	83 c4 10             	add    $0x10,%esp
}
80101692:	90                   	nop
80101693:	c9                   	leave  
80101694:	c3                   	ret    

80101695 <iinit>:
  struct inode inode[NINODE];
} icache;

void
iinit(int dev)
{
80101695:	55                   	push   %ebp
80101696:	89 e5                	mov    %esp,%ebp
80101698:	57                   	push   %edi
80101699:	56                   	push   %esi
8010169a:	53                   	push   %ebx
8010169b:	83 ec 2c             	sub    $0x2c,%esp
  int i = 0;
8010169e:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  
  initlock(&icache.lock, "icache");
801016a5:	83 ec 08             	sub    $0x8,%esp
801016a8:	68 79 86 10 80       	push   $0x80108679
801016ad:	68 60 1a 11 80       	push   $0x80111a60
801016b2:	e8 94 38 00 00       	call   80104f4b <initlock>
801016b7:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NINODE; i++) {
801016ba:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
801016c1:	eb 2d                	jmp    801016f0 <iinit+0x5b>
    initsleeplock(&icache.inode[i].lock, "inode");
801016c3:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801016c6:	89 d0                	mov    %edx,%eax
801016c8:	c1 e0 03             	shl    $0x3,%eax
801016cb:	01 d0                	add    %edx,%eax
801016cd:	c1 e0 04             	shl    $0x4,%eax
801016d0:	83 c0 30             	add    $0x30,%eax
801016d3:	05 60 1a 11 80       	add    $0x80111a60,%eax
801016d8:	83 c0 10             	add    $0x10,%eax
801016db:	83 ec 08             	sub    $0x8,%esp
801016de:	68 80 86 10 80       	push   $0x80108680
801016e3:	50                   	push   %eax
801016e4:	e8 05 37 00 00       	call   80104dee <initsleeplock>
801016e9:	83 c4 10             	add    $0x10,%esp
iinit(int dev)
{
  int i = 0;
  
  initlock(&icache.lock, "icache");
  for(i = 0; i < NINODE; i++) {
801016ec:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
801016f0:	83 7d e4 31          	cmpl   $0x31,-0x1c(%ebp)
801016f4:	7e cd                	jle    801016c3 <iinit+0x2e>
    initsleeplock(&icache.inode[i].lock, "inode");
  }

  readsb(dev, &sb);
801016f6:	83 ec 08             	sub    $0x8,%esp
801016f9:	68 40 1a 11 80       	push   $0x80111a40
801016fe:	ff 75 08             	pushl  0x8(%ebp)
80101701:	e8 d5 fc ff ff       	call   801013db <readsb>
80101706:	83 c4 10             	add    $0x10,%esp
  cprintf("sb: size %d nblocks %d ninodes %d nlog %d logstart %d\
80101709:	a1 58 1a 11 80       	mov    0x80111a58,%eax
8010170e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80101711:	8b 3d 54 1a 11 80    	mov    0x80111a54,%edi
80101717:	8b 35 50 1a 11 80    	mov    0x80111a50,%esi
8010171d:	8b 1d 4c 1a 11 80    	mov    0x80111a4c,%ebx
80101723:	8b 0d 48 1a 11 80    	mov    0x80111a48,%ecx
80101729:	8b 15 44 1a 11 80    	mov    0x80111a44,%edx
8010172f:	a1 40 1a 11 80       	mov    0x80111a40,%eax
80101734:	ff 75 d4             	pushl  -0x2c(%ebp)
80101737:	57                   	push   %edi
80101738:	56                   	push   %esi
80101739:	53                   	push   %ebx
8010173a:	51                   	push   %ecx
8010173b:	52                   	push   %edx
8010173c:	50                   	push   %eax
8010173d:	68 88 86 10 80       	push   $0x80108688
80101742:	e8 b9 ec ff ff       	call   80100400 <cprintf>
80101747:	83 c4 20             	add    $0x20,%esp
 inodestart %d bmap start %d\n", sb.size, sb.nblocks,
          sb.ninodes, sb.nlog, sb.logstart, sb.inodestart,
          sb.bmapstart);
}
8010174a:	90                   	nop
8010174b:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010174e:	5b                   	pop    %ebx
8010174f:	5e                   	pop    %esi
80101750:	5f                   	pop    %edi
80101751:	5d                   	pop    %ebp
80101752:	c3                   	ret    

80101753 <ialloc>:
// Allocate an inode on device dev.
// Mark it as allocated by  giving it type type.
// Returns an unlocked but allocated and referenced inode.
struct inode*
ialloc(uint dev, short type)
{
80101753:	55                   	push   %ebp
80101754:	89 e5                	mov    %esp,%ebp
80101756:	83 ec 28             	sub    $0x28,%esp
80101759:	8b 45 0c             	mov    0xc(%ebp),%eax
8010175c:	66 89 45 e4          	mov    %ax,-0x1c(%ebp)
  int inum;
  struct buf *bp;
  struct dinode *dip;

  for(inum = 1; inum < sb.ninodes; inum++){
80101760:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
80101767:	e9 9e 00 00 00       	jmp    8010180a <ialloc+0xb7>
    bp = bread(dev, IBLOCK(inum, sb));
8010176c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010176f:	c1 e8 03             	shr    $0x3,%eax
80101772:	89 c2                	mov    %eax,%edx
80101774:	a1 54 1a 11 80       	mov    0x80111a54,%eax
80101779:	01 d0                	add    %edx,%eax
8010177b:	83 ec 08             	sub    $0x8,%esp
8010177e:	50                   	push   %eax
8010177f:	ff 75 08             	pushl  0x8(%ebp)
80101782:	e8 47 ea ff ff       	call   801001ce <bread>
80101787:	83 c4 10             	add    $0x10,%esp
8010178a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    dip = (struct dinode*)bp->data + inum%IPB;
8010178d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101790:	8d 50 5c             	lea    0x5c(%eax),%edx
80101793:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101796:	83 e0 07             	and    $0x7,%eax
80101799:	c1 e0 06             	shl    $0x6,%eax
8010179c:	01 d0                	add    %edx,%eax
8010179e:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(dip->type == 0){  // a free inode
801017a1:	8b 45 ec             	mov    -0x14(%ebp),%eax
801017a4:	0f b7 00             	movzwl (%eax),%eax
801017a7:	66 85 c0             	test   %ax,%ax
801017aa:	75 4c                	jne    801017f8 <ialloc+0xa5>
      memset(dip, 0, sizeof(*dip));
801017ac:	83 ec 04             	sub    $0x4,%esp
801017af:	6a 40                	push   $0x40
801017b1:	6a 00                	push   $0x0
801017b3:	ff 75 ec             	pushl  -0x14(%ebp)
801017b6:	e8 29 3a 00 00       	call   801051e4 <memset>
801017bb:	83 c4 10             	add    $0x10,%esp
      dip->type = type;
801017be:	8b 45 ec             	mov    -0x14(%ebp),%eax
801017c1:	0f b7 55 e4          	movzwl -0x1c(%ebp),%edx
801017c5:	66 89 10             	mov    %dx,(%eax)
      log_write(bp);   // mark it allocated on the disk
801017c8:	83 ec 0c             	sub    $0xc,%esp
801017cb:	ff 75 f0             	pushl  -0x10(%ebp)
801017ce:	e8 91 1f 00 00       	call   80103764 <log_write>
801017d3:	83 c4 10             	add    $0x10,%esp
      brelse(bp);
801017d6:	83 ec 0c             	sub    $0xc,%esp
801017d9:	ff 75 f0             	pushl  -0x10(%ebp)
801017dc:	e8 6f ea ff ff       	call   80100250 <brelse>
801017e1:	83 c4 10             	add    $0x10,%esp
      return iget(dev, inum);
801017e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017e7:	83 ec 08             	sub    $0x8,%esp
801017ea:	50                   	push   %eax
801017eb:	ff 75 08             	pushl  0x8(%ebp)
801017ee:	e8 f8 00 00 00       	call   801018eb <iget>
801017f3:	83 c4 10             	add    $0x10,%esp
801017f6:	eb 30                	jmp    80101828 <ialloc+0xd5>
    }
    brelse(bp);
801017f8:	83 ec 0c             	sub    $0xc,%esp
801017fb:	ff 75 f0             	pushl  -0x10(%ebp)
801017fe:	e8 4d ea ff ff       	call   80100250 <brelse>
80101803:	83 c4 10             	add    $0x10,%esp
{
  int inum;
  struct buf *bp;
  struct dinode *dip;

  for(inum = 1; inum < sb.ninodes; inum++){
80101806:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010180a:	8b 15 48 1a 11 80    	mov    0x80111a48,%edx
80101810:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101813:	39 c2                	cmp    %eax,%edx
80101815:	0f 87 51 ff ff ff    	ja     8010176c <ialloc+0x19>
      brelse(bp);
      return iget(dev, inum);
    }
    brelse(bp);
  }
  panic("ialloc: no inodes");
8010181b:	83 ec 0c             	sub    $0xc,%esp
8010181e:	68 db 86 10 80       	push   $0x801086db
80101823:	e8 78 ed ff ff       	call   801005a0 <panic>
}
80101828:	c9                   	leave  
80101829:	c3                   	ret    

8010182a <iupdate>:
// Must be called after every change to an ip->xxx field
// that lives on disk, since i-node cache is write-through.
// Caller must hold ip->lock.
void
iupdate(struct inode *ip)
{
8010182a:	55                   	push   %ebp
8010182b:	89 e5                	mov    %esp,%ebp
8010182d:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  struct dinode *dip;

  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101830:	8b 45 08             	mov    0x8(%ebp),%eax
80101833:	8b 40 04             	mov    0x4(%eax),%eax
80101836:	c1 e8 03             	shr    $0x3,%eax
80101839:	89 c2                	mov    %eax,%edx
8010183b:	a1 54 1a 11 80       	mov    0x80111a54,%eax
80101840:	01 c2                	add    %eax,%edx
80101842:	8b 45 08             	mov    0x8(%ebp),%eax
80101845:	8b 00                	mov    (%eax),%eax
80101847:	83 ec 08             	sub    $0x8,%esp
8010184a:	52                   	push   %edx
8010184b:	50                   	push   %eax
8010184c:	e8 7d e9 ff ff       	call   801001ce <bread>
80101851:	83 c4 10             	add    $0x10,%esp
80101854:	89 45 f4             	mov    %eax,-0xc(%ebp)
  dip = (struct dinode*)bp->data + ip->inum%IPB;
80101857:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010185a:	8d 50 5c             	lea    0x5c(%eax),%edx
8010185d:	8b 45 08             	mov    0x8(%ebp),%eax
80101860:	8b 40 04             	mov    0x4(%eax),%eax
80101863:	83 e0 07             	and    $0x7,%eax
80101866:	c1 e0 06             	shl    $0x6,%eax
80101869:	01 d0                	add    %edx,%eax
8010186b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dip->type = ip->type;
8010186e:	8b 45 08             	mov    0x8(%ebp),%eax
80101871:	0f b7 50 50          	movzwl 0x50(%eax),%edx
80101875:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101878:	66 89 10             	mov    %dx,(%eax)
  dip->major = ip->major;
8010187b:	8b 45 08             	mov    0x8(%ebp),%eax
8010187e:	0f b7 50 52          	movzwl 0x52(%eax),%edx
80101882:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101885:	66 89 50 02          	mov    %dx,0x2(%eax)
  dip->minor = ip->minor;
80101889:	8b 45 08             	mov    0x8(%ebp),%eax
8010188c:	0f b7 50 54          	movzwl 0x54(%eax),%edx
80101890:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101893:	66 89 50 04          	mov    %dx,0x4(%eax)
  dip->nlink = ip->nlink;
80101897:	8b 45 08             	mov    0x8(%ebp),%eax
8010189a:	0f b7 50 56          	movzwl 0x56(%eax),%edx
8010189e:	8b 45 f0             	mov    -0x10(%ebp),%eax
801018a1:	66 89 50 06          	mov    %dx,0x6(%eax)
  dip->size = ip->size;
801018a5:	8b 45 08             	mov    0x8(%ebp),%eax
801018a8:	8b 50 58             	mov    0x58(%eax),%edx
801018ab:	8b 45 f0             	mov    -0x10(%ebp),%eax
801018ae:	89 50 08             	mov    %edx,0x8(%eax)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
801018b1:	8b 45 08             	mov    0x8(%ebp),%eax
801018b4:	8d 50 5c             	lea    0x5c(%eax),%edx
801018b7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801018ba:	83 c0 0c             	add    $0xc,%eax
801018bd:	83 ec 04             	sub    $0x4,%esp
801018c0:	6a 34                	push   $0x34
801018c2:	52                   	push   %edx
801018c3:	50                   	push   %eax
801018c4:	e8 da 39 00 00       	call   801052a3 <memmove>
801018c9:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
801018cc:	83 ec 0c             	sub    $0xc,%esp
801018cf:	ff 75 f4             	pushl  -0xc(%ebp)
801018d2:	e8 8d 1e 00 00       	call   80103764 <log_write>
801018d7:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
801018da:	83 ec 0c             	sub    $0xc,%esp
801018dd:	ff 75 f4             	pushl  -0xc(%ebp)
801018e0:	e8 6b e9 ff ff       	call   80100250 <brelse>
801018e5:	83 c4 10             	add    $0x10,%esp
}
801018e8:	90                   	nop
801018e9:	c9                   	leave  
801018ea:	c3                   	ret    

801018eb <iget>:
// Find the inode with number inum on device dev
// and return the in-memory copy. Does not lock
// the inode and does not read it from disk.
static struct inode*
iget(uint dev, uint inum)
{
801018eb:	55                   	push   %ebp
801018ec:	89 e5                	mov    %esp,%ebp
801018ee:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip, *empty;

  acquire(&icache.lock);
801018f1:	83 ec 0c             	sub    $0xc,%esp
801018f4:	68 60 1a 11 80       	push   $0x80111a60
801018f9:	e8 6f 36 00 00       	call   80104f6d <acquire>
801018fe:	83 c4 10             	add    $0x10,%esp

  // Is the inode already cached?
  empty = 0;
80101901:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80101908:	c7 45 f4 94 1a 11 80 	movl   $0x80111a94,-0xc(%ebp)
8010190f:	eb 60                	jmp    80101971 <iget+0x86>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
80101911:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101914:	8b 40 08             	mov    0x8(%eax),%eax
80101917:	85 c0                	test   %eax,%eax
80101919:	7e 39                	jle    80101954 <iget+0x69>
8010191b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010191e:	8b 00                	mov    (%eax),%eax
80101920:	3b 45 08             	cmp    0x8(%ebp),%eax
80101923:	75 2f                	jne    80101954 <iget+0x69>
80101925:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101928:	8b 40 04             	mov    0x4(%eax),%eax
8010192b:	3b 45 0c             	cmp    0xc(%ebp),%eax
8010192e:	75 24                	jne    80101954 <iget+0x69>
      ip->ref++;
80101930:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101933:	8b 40 08             	mov    0x8(%eax),%eax
80101936:	8d 50 01             	lea    0x1(%eax),%edx
80101939:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010193c:	89 50 08             	mov    %edx,0x8(%eax)
      release(&icache.lock);
8010193f:	83 ec 0c             	sub    $0xc,%esp
80101942:	68 60 1a 11 80       	push   $0x80111a60
80101947:	e8 8f 36 00 00       	call   80104fdb <release>
8010194c:	83 c4 10             	add    $0x10,%esp
      return ip;
8010194f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101952:	eb 77                	jmp    801019cb <iget+0xe0>
    }
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
80101954:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80101958:	75 10                	jne    8010196a <iget+0x7f>
8010195a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010195d:	8b 40 08             	mov    0x8(%eax),%eax
80101960:	85 c0                	test   %eax,%eax
80101962:	75 06                	jne    8010196a <iget+0x7f>
      empty = ip;
80101964:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101967:	89 45 f0             	mov    %eax,-0x10(%ebp)

  acquire(&icache.lock);

  // Is the inode already cached?
  empty = 0;
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
8010196a:	81 45 f4 90 00 00 00 	addl   $0x90,-0xc(%ebp)
80101971:	81 7d f4 b4 36 11 80 	cmpl   $0x801136b4,-0xc(%ebp)
80101978:	72 97                	jb     80101911 <iget+0x26>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
      empty = ip;
  }

  // Recycle an inode cache entry.
  if(empty == 0)
8010197a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010197e:	75 0d                	jne    8010198d <iget+0xa2>
    panic("iget: no inodes");
80101980:	83 ec 0c             	sub    $0xc,%esp
80101983:	68 ed 86 10 80       	push   $0x801086ed
80101988:	e8 13 ec ff ff       	call   801005a0 <panic>

  ip = empty;
8010198d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101990:	89 45 f4             	mov    %eax,-0xc(%ebp)
  ip->dev = dev;
80101993:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101996:	8b 55 08             	mov    0x8(%ebp),%edx
80101999:	89 10                	mov    %edx,(%eax)
  ip->inum = inum;
8010199b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010199e:	8b 55 0c             	mov    0xc(%ebp),%edx
801019a1:	89 50 04             	mov    %edx,0x4(%eax)
  ip->ref = 1;
801019a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019a7:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
  ip->valid = 0;
801019ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019b1:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
  release(&icache.lock);
801019b8:	83 ec 0c             	sub    $0xc,%esp
801019bb:	68 60 1a 11 80       	push   $0x80111a60
801019c0:	e8 16 36 00 00       	call   80104fdb <release>
801019c5:	83 c4 10             	add    $0x10,%esp

  return ip;
801019c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801019cb:	c9                   	leave  
801019cc:	c3                   	ret    

801019cd <idup>:

// Increment reference count for ip.
// Returns ip to enable ip = idup(ip1) idiom.
struct inode*
idup(struct inode *ip)
{
801019cd:	55                   	push   %ebp
801019ce:	89 e5                	mov    %esp,%ebp
801019d0:	83 ec 08             	sub    $0x8,%esp
  acquire(&icache.lock);
801019d3:	83 ec 0c             	sub    $0xc,%esp
801019d6:	68 60 1a 11 80       	push   $0x80111a60
801019db:	e8 8d 35 00 00       	call   80104f6d <acquire>
801019e0:	83 c4 10             	add    $0x10,%esp
  ip->ref++;
801019e3:	8b 45 08             	mov    0x8(%ebp),%eax
801019e6:	8b 40 08             	mov    0x8(%eax),%eax
801019e9:	8d 50 01             	lea    0x1(%eax),%edx
801019ec:	8b 45 08             	mov    0x8(%ebp),%eax
801019ef:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
801019f2:	83 ec 0c             	sub    $0xc,%esp
801019f5:	68 60 1a 11 80       	push   $0x80111a60
801019fa:	e8 dc 35 00 00       	call   80104fdb <release>
801019ff:	83 c4 10             	add    $0x10,%esp
  return ip;
80101a02:	8b 45 08             	mov    0x8(%ebp),%eax
}
80101a05:	c9                   	leave  
80101a06:	c3                   	ret    

80101a07 <ilock>:

// Lock the given inode.
// Reads the inode from disk if necessary.
void
ilock(struct inode *ip)
{
80101a07:	55                   	push   %ebp
80101a08:	89 e5                	mov    %esp,%ebp
80101a0a:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  struct dinode *dip;

  if(ip == 0 || ip->ref < 1)
80101a0d:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101a11:	74 0a                	je     80101a1d <ilock+0x16>
80101a13:	8b 45 08             	mov    0x8(%ebp),%eax
80101a16:	8b 40 08             	mov    0x8(%eax),%eax
80101a19:	85 c0                	test   %eax,%eax
80101a1b:	7f 0d                	jg     80101a2a <ilock+0x23>
    panic("ilock");
80101a1d:	83 ec 0c             	sub    $0xc,%esp
80101a20:	68 fd 86 10 80       	push   $0x801086fd
80101a25:	e8 76 eb ff ff       	call   801005a0 <panic>

  acquiresleep(&ip->lock);
80101a2a:	8b 45 08             	mov    0x8(%ebp),%eax
80101a2d:	83 c0 0c             	add    $0xc,%eax
80101a30:	83 ec 0c             	sub    $0xc,%esp
80101a33:	50                   	push   %eax
80101a34:	e8 f1 33 00 00       	call   80104e2a <acquiresleep>
80101a39:	83 c4 10             	add    $0x10,%esp

  if(ip->valid == 0){
80101a3c:	8b 45 08             	mov    0x8(%ebp),%eax
80101a3f:	8b 40 4c             	mov    0x4c(%eax),%eax
80101a42:	85 c0                	test   %eax,%eax
80101a44:	0f 85 cd 00 00 00    	jne    80101b17 <ilock+0x110>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101a4a:	8b 45 08             	mov    0x8(%ebp),%eax
80101a4d:	8b 40 04             	mov    0x4(%eax),%eax
80101a50:	c1 e8 03             	shr    $0x3,%eax
80101a53:	89 c2                	mov    %eax,%edx
80101a55:	a1 54 1a 11 80       	mov    0x80111a54,%eax
80101a5a:	01 c2                	add    %eax,%edx
80101a5c:	8b 45 08             	mov    0x8(%ebp),%eax
80101a5f:	8b 00                	mov    (%eax),%eax
80101a61:	83 ec 08             	sub    $0x8,%esp
80101a64:	52                   	push   %edx
80101a65:	50                   	push   %eax
80101a66:	e8 63 e7 ff ff       	call   801001ce <bread>
80101a6b:	83 c4 10             	add    $0x10,%esp
80101a6e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    dip = (struct dinode*)bp->data + ip->inum%IPB;
80101a71:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a74:	8d 50 5c             	lea    0x5c(%eax),%edx
80101a77:	8b 45 08             	mov    0x8(%ebp),%eax
80101a7a:	8b 40 04             	mov    0x4(%eax),%eax
80101a7d:	83 e0 07             	and    $0x7,%eax
80101a80:	c1 e0 06             	shl    $0x6,%eax
80101a83:	01 d0                	add    %edx,%eax
80101a85:	89 45 f0             	mov    %eax,-0x10(%ebp)
    ip->type = dip->type;
80101a88:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a8b:	0f b7 10             	movzwl (%eax),%edx
80101a8e:	8b 45 08             	mov    0x8(%ebp),%eax
80101a91:	66 89 50 50          	mov    %dx,0x50(%eax)
    ip->major = dip->major;
80101a95:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a98:	0f b7 50 02          	movzwl 0x2(%eax),%edx
80101a9c:	8b 45 08             	mov    0x8(%ebp),%eax
80101a9f:	66 89 50 52          	mov    %dx,0x52(%eax)
    ip->minor = dip->minor;
80101aa3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101aa6:	0f b7 50 04          	movzwl 0x4(%eax),%edx
80101aaa:	8b 45 08             	mov    0x8(%ebp),%eax
80101aad:	66 89 50 54          	mov    %dx,0x54(%eax)
    ip->nlink = dip->nlink;
80101ab1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ab4:	0f b7 50 06          	movzwl 0x6(%eax),%edx
80101ab8:	8b 45 08             	mov    0x8(%ebp),%eax
80101abb:	66 89 50 56          	mov    %dx,0x56(%eax)
    ip->size = dip->size;
80101abf:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ac2:	8b 50 08             	mov    0x8(%eax),%edx
80101ac5:	8b 45 08             	mov    0x8(%ebp),%eax
80101ac8:	89 50 58             	mov    %edx,0x58(%eax)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
80101acb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ace:	8d 50 0c             	lea    0xc(%eax),%edx
80101ad1:	8b 45 08             	mov    0x8(%ebp),%eax
80101ad4:	83 c0 5c             	add    $0x5c,%eax
80101ad7:	83 ec 04             	sub    $0x4,%esp
80101ada:	6a 34                	push   $0x34
80101adc:	52                   	push   %edx
80101add:	50                   	push   %eax
80101ade:	e8 c0 37 00 00       	call   801052a3 <memmove>
80101ae3:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80101ae6:	83 ec 0c             	sub    $0xc,%esp
80101ae9:	ff 75 f4             	pushl  -0xc(%ebp)
80101aec:	e8 5f e7 ff ff       	call   80100250 <brelse>
80101af1:	83 c4 10             	add    $0x10,%esp
    ip->valid = 1;
80101af4:	8b 45 08             	mov    0x8(%ebp),%eax
80101af7:	c7 40 4c 01 00 00 00 	movl   $0x1,0x4c(%eax)
    if(ip->type == 0)
80101afe:	8b 45 08             	mov    0x8(%ebp),%eax
80101b01:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80101b05:	66 85 c0             	test   %ax,%ax
80101b08:	75 0d                	jne    80101b17 <ilock+0x110>
      panic("ilock: no type");
80101b0a:	83 ec 0c             	sub    $0xc,%esp
80101b0d:	68 03 87 10 80       	push   $0x80108703
80101b12:	e8 89 ea ff ff       	call   801005a0 <panic>
  }
}
80101b17:	90                   	nop
80101b18:	c9                   	leave  
80101b19:	c3                   	ret    

80101b1a <iunlock>:

// Unlock the given inode.
void
iunlock(struct inode *ip)
{
80101b1a:	55                   	push   %ebp
80101b1b:	89 e5                	mov    %esp,%ebp
80101b1d:	83 ec 08             	sub    $0x8,%esp
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
80101b20:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101b24:	74 20                	je     80101b46 <iunlock+0x2c>
80101b26:	8b 45 08             	mov    0x8(%ebp),%eax
80101b29:	83 c0 0c             	add    $0xc,%eax
80101b2c:	83 ec 0c             	sub    $0xc,%esp
80101b2f:	50                   	push   %eax
80101b30:	e8 a7 33 00 00       	call   80104edc <holdingsleep>
80101b35:	83 c4 10             	add    $0x10,%esp
80101b38:	85 c0                	test   %eax,%eax
80101b3a:	74 0a                	je     80101b46 <iunlock+0x2c>
80101b3c:	8b 45 08             	mov    0x8(%ebp),%eax
80101b3f:	8b 40 08             	mov    0x8(%eax),%eax
80101b42:	85 c0                	test   %eax,%eax
80101b44:	7f 0d                	jg     80101b53 <iunlock+0x39>
    panic("iunlock");
80101b46:	83 ec 0c             	sub    $0xc,%esp
80101b49:	68 12 87 10 80       	push   $0x80108712
80101b4e:	e8 4d ea ff ff       	call   801005a0 <panic>

  releasesleep(&ip->lock);
80101b53:	8b 45 08             	mov    0x8(%ebp),%eax
80101b56:	83 c0 0c             	add    $0xc,%eax
80101b59:	83 ec 0c             	sub    $0xc,%esp
80101b5c:	50                   	push   %eax
80101b5d:	e8 2c 33 00 00       	call   80104e8e <releasesleep>
80101b62:	83 c4 10             	add    $0x10,%esp
}
80101b65:	90                   	nop
80101b66:	c9                   	leave  
80101b67:	c3                   	ret    

80101b68 <iput>:
// to it, free the inode (and its content) on disk.
// All calls to iput() must be inside a transaction in
// case it has to free the inode.
void
iput(struct inode *ip)
{
80101b68:	55                   	push   %ebp
80101b69:	89 e5                	mov    %esp,%ebp
80101b6b:	83 ec 18             	sub    $0x18,%esp
  acquiresleep(&ip->lock);
80101b6e:	8b 45 08             	mov    0x8(%ebp),%eax
80101b71:	83 c0 0c             	add    $0xc,%eax
80101b74:	83 ec 0c             	sub    $0xc,%esp
80101b77:	50                   	push   %eax
80101b78:	e8 ad 32 00 00       	call   80104e2a <acquiresleep>
80101b7d:	83 c4 10             	add    $0x10,%esp
  if(ip->valid && ip->nlink == 0){
80101b80:	8b 45 08             	mov    0x8(%ebp),%eax
80101b83:	8b 40 4c             	mov    0x4c(%eax),%eax
80101b86:	85 c0                	test   %eax,%eax
80101b88:	74 6a                	je     80101bf4 <iput+0x8c>
80101b8a:	8b 45 08             	mov    0x8(%ebp),%eax
80101b8d:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80101b91:	66 85 c0             	test   %ax,%ax
80101b94:	75 5e                	jne    80101bf4 <iput+0x8c>
    acquire(&icache.lock);
80101b96:	83 ec 0c             	sub    $0xc,%esp
80101b99:	68 60 1a 11 80       	push   $0x80111a60
80101b9e:	e8 ca 33 00 00       	call   80104f6d <acquire>
80101ba3:	83 c4 10             	add    $0x10,%esp
    int r = ip->ref;
80101ba6:	8b 45 08             	mov    0x8(%ebp),%eax
80101ba9:	8b 40 08             	mov    0x8(%eax),%eax
80101bac:	89 45 f4             	mov    %eax,-0xc(%ebp)
    release(&icache.lock);
80101baf:	83 ec 0c             	sub    $0xc,%esp
80101bb2:	68 60 1a 11 80       	push   $0x80111a60
80101bb7:	e8 1f 34 00 00       	call   80104fdb <release>
80101bbc:	83 c4 10             	add    $0x10,%esp
    if(r == 1){
80101bbf:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
80101bc3:	75 2f                	jne    80101bf4 <iput+0x8c>
      // inode has no links and no other references: truncate and free.
      itrunc(ip);
80101bc5:	83 ec 0c             	sub    $0xc,%esp
80101bc8:	ff 75 08             	pushl  0x8(%ebp)
80101bcb:	e8 b2 01 00 00       	call   80101d82 <itrunc>
80101bd0:	83 c4 10             	add    $0x10,%esp
      ip->type = 0;
80101bd3:	8b 45 08             	mov    0x8(%ebp),%eax
80101bd6:	66 c7 40 50 00 00    	movw   $0x0,0x50(%eax)
      iupdate(ip);
80101bdc:	83 ec 0c             	sub    $0xc,%esp
80101bdf:	ff 75 08             	pushl  0x8(%ebp)
80101be2:	e8 43 fc ff ff       	call   8010182a <iupdate>
80101be7:	83 c4 10             	add    $0x10,%esp
      ip->valid = 0;
80101bea:	8b 45 08             	mov    0x8(%ebp),%eax
80101bed:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
    }
  }
  releasesleep(&ip->lock);
80101bf4:	8b 45 08             	mov    0x8(%ebp),%eax
80101bf7:	83 c0 0c             	add    $0xc,%eax
80101bfa:	83 ec 0c             	sub    $0xc,%esp
80101bfd:	50                   	push   %eax
80101bfe:	e8 8b 32 00 00       	call   80104e8e <releasesleep>
80101c03:	83 c4 10             	add    $0x10,%esp

  acquire(&icache.lock);
80101c06:	83 ec 0c             	sub    $0xc,%esp
80101c09:	68 60 1a 11 80       	push   $0x80111a60
80101c0e:	e8 5a 33 00 00       	call   80104f6d <acquire>
80101c13:	83 c4 10             	add    $0x10,%esp
  ip->ref--;
80101c16:	8b 45 08             	mov    0x8(%ebp),%eax
80101c19:	8b 40 08             	mov    0x8(%eax),%eax
80101c1c:	8d 50 ff             	lea    -0x1(%eax),%edx
80101c1f:	8b 45 08             	mov    0x8(%ebp),%eax
80101c22:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101c25:	83 ec 0c             	sub    $0xc,%esp
80101c28:	68 60 1a 11 80       	push   $0x80111a60
80101c2d:	e8 a9 33 00 00       	call   80104fdb <release>
80101c32:	83 c4 10             	add    $0x10,%esp
}
80101c35:	90                   	nop
80101c36:	c9                   	leave  
80101c37:	c3                   	ret    

80101c38 <iunlockput>:

// Common idiom: unlock, then put.
void
iunlockput(struct inode *ip)
{
80101c38:	55                   	push   %ebp
80101c39:	89 e5                	mov    %esp,%ebp
80101c3b:	83 ec 08             	sub    $0x8,%esp
  iunlock(ip);
80101c3e:	83 ec 0c             	sub    $0xc,%esp
80101c41:	ff 75 08             	pushl  0x8(%ebp)
80101c44:	e8 d1 fe ff ff       	call   80101b1a <iunlock>
80101c49:	83 c4 10             	add    $0x10,%esp
  iput(ip);
80101c4c:	83 ec 0c             	sub    $0xc,%esp
80101c4f:	ff 75 08             	pushl  0x8(%ebp)
80101c52:	e8 11 ff ff ff       	call   80101b68 <iput>
80101c57:	83 c4 10             	add    $0x10,%esp
}
80101c5a:	90                   	nop
80101c5b:	c9                   	leave  
80101c5c:	c3                   	ret    

80101c5d <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
80101c5d:	55                   	push   %ebp
80101c5e:	89 e5                	mov    %esp,%ebp
80101c60:	53                   	push   %ebx
80101c61:	83 ec 14             	sub    $0x14,%esp
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
80101c64:	83 7d 0c 0b          	cmpl   $0xb,0xc(%ebp)
80101c68:	77 42                	ja     80101cac <bmap+0x4f>
    if((addr = ip->addrs[bn]) == 0)
80101c6a:	8b 45 08             	mov    0x8(%ebp),%eax
80101c6d:	8b 55 0c             	mov    0xc(%ebp),%edx
80101c70:	83 c2 14             	add    $0x14,%edx
80101c73:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101c77:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101c7a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101c7e:	75 24                	jne    80101ca4 <bmap+0x47>
      ip->addrs[bn] = addr = balloc(ip->dev);
80101c80:	8b 45 08             	mov    0x8(%ebp),%eax
80101c83:	8b 00                	mov    (%eax),%eax
80101c85:	83 ec 0c             	sub    $0xc,%esp
80101c88:	50                   	push   %eax
80101c89:	e8 e3 f7 ff ff       	call   80101471 <balloc>
80101c8e:	83 c4 10             	add    $0x10,%esp
80101c91:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101c94:	8b 45 08             	mov    0x8(%ebp),%eax
80101c97:	8b 55 0c             	mov    0xc(%ebp),%edx
80101c9a:	8d 4a 14             	lea    0x14(%edx),%ecx
80101c9d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101ca0:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
    return addr;
80101ca4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101ca7:	e9 d1 00 00 00       	jmp    80101d7d <bmap+0x120>
  }
  bn -= NDIRECT;
80101cac:	83 6d 0c 0c          	subl   $0xc,0xc(%ebp)

  if(bn < NINDIRECT){
80101cb0:	83 7d 0c 7f          	cmpl   $0x7f,0xc(%ebp)
80101cb4:	0f 87 b6 00 00 00    	ja     80101d70 <bmap+0x113>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
80101cba:	8b 45 08             	mov    0x8(%ebp),%eax
80101cbd:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101cc3:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101cc6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101cca:	75 20                	jne    80101cec <bmap+0x8f>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
80101ccc:	8b 45 08             	mov    0x8(%ebp),%eax
80101ccf:	8b 00                	mov    (%eax),%eax
80101cd1:	83 ec 0c             	sub    $0xc,%esp
80101cd4:	50                   	push   %eax
80101cd5:	e8 97 f7 ff ff       	call   80101471 <balloc>
80101cda:	83 c4 10             	add    $0x10,%esp
80101cdd:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101ce0:	8b 45 08             	mov    0x8(%ebp),%eax
80101ce3:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101ce6:	89 90 8c 00 00 00    	mov    %edx,0x8c(%eax)
    bp = bread(ip->dev, addr);
80101cec:	8b 45 08             	mov    0x8(%ebp),%eax
80101cef:	8b 00                	mov    (%eax),%eax
80101cf1:	83 ec 08             	sub    $0x8,%esp
80101cf4:	ff 75 f4             	pushl  -0xc(%ebp)
80101cf7:	50                   	push   %eax
80101cf8:	e8 d1 e4 ff ff       	call   801001ce <bread>
80101cfd:	83 c4 10             	add    $0x10,%esp
80101d00:	89 45 f0             	mov    %eax,-0x10(%ebp)
    a = (uint*)bp->data;
80101d03:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101d06:	83 c0 5c             	add    $0x5c,%eax
80101d09:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if((addr = a[bn]) == 0){
80101d0c:	8b 45 0c             	mov    0xc(%ebp),%eax
80101d0f:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101d16:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101d19:	01 d0                	add    %edx,%eax
80101d1b:	8b 00                	mov    (%eax),%eax
80101d1d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d20:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101d24:	75 37                	jne    80101d5d <bmap+0x100>
      a[bn] = addr = balloc(ip->dev);
80101d26:	8b 45 0c             	mov    0xc(%ebp),%eax
80101d29:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101d30:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101d33:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80101d36:	8b 45 08             	mov    0x8(%ebp),%eax
80101d39:	8b 00                	mov    (%eax),%eax
80101d3b:	83 ec 0c             	sub    $0xc,%esp
80101d3e:	50                   	push   %eax
80101d3f:	e8 2d f7 ff ff       	call   80101471 <balloc>
80101d44:	83 c4 10             	add    $0x10,%esp
80101d47:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101d4d:	89 03                	mov    %eax,(%ebx)
      log_write(bp);
80101d4f:	83 ec 0c             	sub    $0xc,%esp
80101d52:	ff 75 f0             	pushl  -0x10(%ebp)
80101d55:	e8 0a 1a 00 00       	call   80103764 <log_write>
80101d5a:	83 c4 10             	add    $0x10,%esp
    }
    brelse(bp);
80101d5d:	83 ec 0c             	sub    $0xc,%esp
80101d60:	ff 75 f0             	pushl  -0x10(%ebp)
80101d63:	e8 e8 e4 ff ff       	call   80100250 <brelse>
80101d68:	83 c4 10             	add    $0x10,%esp
    return addr;
80101d6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101d6e:	eb 0d                	jmp    80101d7d <bmap+0x120>
  }

  panic("bmap: out of range");
80101d70:	83 ec 0c             	sub    $0xc,%esp
80101d73:	68 1a 87 10 80       	push   $0x8010871a
80101d78:	e8 23 e8 ff ff       	call   801005a0 <panic>
}
80101d7d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80101d80:	c9                   	leave  
80101d81:	c3                   	ret    

80101d82 <itrunc>:
// to it (no directory entries referring to it)
// and has no in-memory reference to it (is
// not an open file or current directory).
static void
itrunc(struct inode *ip)
{
80101d82:	55                   	push   %ebp
80101d83:	89 e5                	mov    %esp,%ebp
80101d85:	83 ec 18             	sub    $0x18,%esp
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101d88:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101d8f:	eb 45                	jmp    80101dd6 <itrunc+0x54>
    if(ip->addrs[i]){
80101d91:	8b 45 08             	mov    0x8(%ebp),%eax
80101d94:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101d97:	83 c2 14             	add    $0x14,%edx
80101d9a:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101d9e:	85 c0                	test   %eax,%eax
80101da0:	74 30                	je     80101dd2 <itrunc+0x50>
      bfree(ip->dev, ip->addrs[i]);
80101da2:	8b 45 08             	mov    0x8(%ebp),%eax
80101da5:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101da8:	83 c2 14             	add    $0x14,%edx
80101dab:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101daf:	8b 55 08             	mov    0x8(%ebp),%edx
80101db2:	8b 12                	mov    (%edx),%edx
80101db4:	83 ec 08             	sub    $0x8,%esp
80101db7:	50                   	push   %eax
80101db8:	52                   	push   %edx
80101db9:	e8 ff f7 ff ff       	call   801015bd <bfree>
80101dbe:	83 c4 10             	add    $0x10,%esp
      ip->addrs[i] = 0;
80101dc1:	8b 45 08             	mov    0x8(%ebp),%eax
80101dc4:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101dc7:	83 c2 14             	add    $0x14,%edx
80101dca:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
80101dd1:	00 
{
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101dd2:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101dd6:	83 7d f4 0b          	cmpl   $0xb,-0xc(%ebp)
80101dda:	7e b5                	jle    80101d91 <itrunc+0xf>
      bfree(ip->dev, ip->addrs[i]);
      ip->addrs[i] = 0;
    }
  }

  if(ip->addrs[NDIRECT]){
80101ddc:	8b 45 08             	mov    0x8(%ebp),%eax
80101ddf:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101de5:	85 c0                	test   %eax,%eax
80101de7:	0f 84 aa 00 00 00    	je     80101e97 <itrunc+0x115>
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
80101ded:	8b 45 08             	mov    0x8(%ebp),%eax
80101df0:	8b 90 8c 00 00 00    	mov    0x8c(%eax),%edx
80101df6:	8b 45 08             	mov    0x8(%ebp),%eax
80101df9:	8b 00                	mov    (%eax),%eax
80101dfb:	83 ec 08             	sub    $0x8,%esp
80101dfe:	52                   	push   %edx
80101dff:	50                   	push   %eax
80101e00:	e8 c9 e3 ff ff       	call   801001ce <bread>
80101e05:	83 c4 10             	add    $0x10,%esp
80101e08:	89 45 ec             	mov    %eax,-0x14(%ebp)
    a = (uint*)bp->data;
80101e0b:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101e0e:	83 c0 5c             	add    $0x5c,%eax
80101e11:	89 45 e8             	mov    %eax,-0x18(%ebp)
    for(j = 0; j < NINDIRECT; j++){
80101e14:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80101e1b:	eb 3c                	jmp    80101e59 <itrunc+0xd7>
      if(a[j])
80101e1d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e20:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101e27:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101e2a:	01 d0                	add    %edx,%eax
80101e2c:	8b 00                	mov    (%eax),%eax
80101e2e:	85 c0                	test   %eax,%eax
80101e30:	74 23                	je     80101e55 <itrunc+0xd3>
        bfree(ip->dev, a[j]);
80101e32:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e35:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101e3c:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101e3f:	01 d0                	add    %edx,%eax
80101e41:	8b 00                	mov    (%eax),%eax
80101e43:	8b 55 08             	mov    0x8(%ebp),%edx
80101e46:	8b 12                	mov    (%edx),%edx
80101e48:	83 ec 08             	sub    $0x8,%esp
80101e4b:	50                   	push   %eax
80101e4c:	52                   	push   %edx
80101e4d:	e8 6b f7 ff ff       	call   801015bd <bfree>
80101e52:	83 c4 10             	add    $0x10,%esp
  }

  if(ip->addrs[NDIRECT]){
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    a = (uint*)bp->data;
    for(j = 0; j < NINDIRECT; j++){
80101e55:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80101e59:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e5c:	83 f8 7f             	cmp    $0x7f,%eax
80101e5f:	76 bc                	jbe    80101e1d <itrunc+0x9b>
      if(a[j])
        bfree(ip->dev, a[j]);
    }
    brelse(bp);
80101e61:	83 ec 0c             	sub    $0xc,%esp
80101e64:	ff 75 ec             	pushl  -0x14(%ebp)
80101e67:	e8 e4 e3 ff ff       	call   80100250 <brelse>
80101e6c:	83 c4 10             	add    $0x10,%esp
    bfree(ip->dev, ip->addrs[NDIRECT]);
80101e6f:	8b 45 08             	mov    0x8(%ebp),%eax
80101e72:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101e78:	8b 55 08             	mov    0x8(%ebp),%edx
80101e7b:	8b 12                	mov    (%edx),%edx
80101e7d:	83 ec 08             	sub    $0x8,%esp
80101e80:	50                   	push   %eax
80101e81:	52                   	push   %edx
80101e82:	e8 36 f7 ff ff       	call   801015bd <bfree>
80101e87:	83 c4 10             	add    $0x10,%esp
    ip->addrs[NDIRECT] = 0;
80101e8a:	8b 45 08             	mov    0x8(%ebp),%eax
80101e8d:	c7 80 8c 00 00 00 00 	movl   $0x0,0x8c(%eax)
80101e94:	00 00 00 
  }

  ip->size = 0;
80101e97:	8b 45 08             	mov    0x8(%ebp),%eax
80101e9a:	c7 40 58 00 00 00 00 	movl   $0x0,0x58(%eax)
  iupdate(ip);
80101ea1:	83 ec 0c             	sub    $0xc,%esp
80101ea4:	ff 75 08             	pushl  0x8(%ebp)
80101ea7:	e8 7e f9 ff ff       	call   8010182a <iupdate>
80101eac:	83 c4 10             	add    $0x10,%esp
}
80101eaf:	90                   	nop
80101eb0:	c9                   	leave  
80101eb1:	c3                   	ret    

80101eb2 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
80101eb2:	55                   	push   %ebp
80101eb3:	89 e5                	mov    %esp,%ebp
  st->dev = ip->dev;
80101eb5:	8b 45 08             	mov    0x8(%ebp),%eax
80101eb8:	8b 00                	mov    (%eax),%eax
80101eba:	89 c2                	mov    %eax,%edx
80101ebc:	8b 45 0c             	mov    0xc(%ebp),%eax
80101ebf:	89 50 04             	mov    %edx,0x4(%eax)
  st->ino = ip->inum;
80101ec2:	8b 45 08             	mov    0x8(%ebp),%eax
80101ec5:	8b 50 04             	mov    0x4(%eax),%edx
80101ec8:	8b 45 0c             	mov    0xc(%ebp),%eax
80101ecb:	89 50 08             	mov    %edx,0x8(%eax)
  st->type = ip->type;
80101ece:	8b 45 08             	mov    0x8(%ebp),%eax
80101ed1:	0f b7 50 50          	movzwl 0x50(%eax),%edx
80101ed5:	8b 45 0c             	mov    0xc(%ebp),%eax
80101ed8:	66 89 10             	mov    %dx,(%eax)
  st->nlink = ip->nlink;
80101edb:	8b 45 08             	mov    0x8(%ebp),%eax
80101ede:	0f b7 50 56          	movzwl 0x56(%eax),%edx
80101ee2:	8b 45 0c             	mov    0xc(%ebp),%eax
80101ee5:	66 89 50 0c          	mov    %dx,0xc(%eax)
  st->size = ip->size;
80101ee9:	8b 45 08             	mov    0x8(%ebp),%eax
80101eec:	8b 50 58             	mov    0x58(%eax),%edx
80101eef:	8b 45 0c             	mov    0xc(%ebp),%eax
80101ef2:	89 50 10             	mov    %edx,0x10(%eax)
}
80101ef5:	90                   	nop
80101ef6:	5d                   	pop    %ebp
80101ef7:	c3                   	ret    

80101ef8 <readi>:
//PAGEBREAK!
// Read data from inode.
// Caller must hold ip->lock.
int
readi(struct inode *ip, char *dst, uint off, uint n)
{
80101ef8:	55                   	push   %ebp
80101ef9:	89 e5                	mov    %esp,%ebp
80101efb:	83 ec 18             	sub    $0x18,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80101efe:	8b 45 08             	mov    0x8(%ebp),%eax
80101f01:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80101f05:	66 83 f8 03          	cmp    $0x3,%ax
80101f09:	75 5c                	jne    80101f67 <readi+0x6f>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
80101f0b:	8b 45 08             	mov    0x8(%ebp),%eax
80101f0e:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101f12:	66 85 c0             	test   %ax,%ax
80101f15:	78 20                	js     80101f37 <readi+0x3f>
80101f17:	8b 45 08             	mov    0x8(%ebp),%eax
80101f1a:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101f1e:	66 83 f8 09          	cmp    $0x9,%ax
80101f22:	7f 13                	jg     80101f37 <readi+0x3f>
80101f24:	8b 45 08             	mov    0x8(%ebp),%eax
80101f27:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101f2b:	98                   	cwtl   
80101f2c:	8b 04 c5 e0 19 11 80 	mov    -0x7feee620(,%eax,8),%eax
80101f33:	85 c0                	test   %eax,%eax
80101f35:	75 0a                	jne    80101f41 <readi+0x49>
      return -1;
80101f37:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101f3c:	e9 0c 01 00 00       	jmp    8010204d <readi+0x155>
    return devsw[ip->major].read(ip, dst, n);
80101f41:	8b 45 08             	mov    0x8(%ebp),%eax
80101f44:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101f48:	98                   	cwtl   
80101f49:	8b 04 c5 e0 19 11 80 	mov    -0x7feee620(,%eax,8),%eax
80101f50:	8b 55 14             	mov    0x14(%ebp),%edx
80101f53:	83 ec 04             	sub    $0x4,%esp
80101f56:	52                   	push   %edx
80101f57:	ff 75 0c             	pushl  0xc(%ebp)
80101f5a:	ff 75 08             	pushl  0x8(%ebp)
80101f5d:	ff d0                	call   *%eax
80101f5f:	83 c4 10             	add    $0x10,%esp
80101f62:	e9 e6 00 00 00       	jmp    8010204d <readi+0x155>
  }

  if(off > ip->size || off + n < off)
80101f67:	8b 45 08             	mov    0x8(%ebp),%eax
80101f6a:	8b 40 58             	mov    0x58(%eax),%eax
80101f6d:	3b 45 10             	cmp    0x10(%ebp),%eax
80101f70:	72 0d                	jb     80101f7f <readi+0x87>
80101f72:	8b 55 10             	mov    0x10(%ebp),%edx
80101f75:	8b 45 14             	mov    0x14(%ebp),%eax
80101f78:	01 d0                	add    %edx,%eax
80101f7a:	3b 45 10             	cmp    0x10(%ebp),%eax
80101f7d:	73 0a                	jae    80101f89 <readi+0x91>
    return -1;
80101f7f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101f84:	e9 c4 00 00 00       	jmp    8010204d <readi+0x155>
  if(off + n > ip->size)
80101f89:	8b 55 10             	mov    0x10(%ebp),%edx
80101f8c:	8b 45 14             	mov    0x14(%ebp),%eax
80101f8f:	01 c2                	add    %eax,%edx
80101f91:	8b 45 08             	mov    0x8(%ebp),%eax
80101f94:	8b 40 58             	mov    0x58(%eax),%eax
80101f97:	39 c2                	cmp    %eax,%edx
80101f99:	76 0c                	jbe    80101fa7 <readi+0xaf>
    n = ip->size - off;
80101f9b:	8b 45 08             	mov    0x8(%ebp),%eax
80101f9e:	8b 40 58             	mov    0x58(%eax),%eax
80101fa1:	2b 45 10             	sub    0x10(%ebp),%eax
80101fa4:	89 45 14             	mov    %eax,0x14(%ebp)

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80101fa7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101fae:	e9 8b 00 00 00       	jmp    8010203e <readi+0x146>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80101fb3:	8b 45 10             	mov    0x10(%ebp),%eax
80101fb6:	c1 e8 09             	shr    $0x9,%eax
80101fb9:	83 ec 08             	sub    $0x8,%esp
80101fbc:	50                   	push   %eax
80101fbd:	ff 75 08             	pushl  0x8(%ebp)
80101fc0:	e8 98 fc ff ff       	call   80101c5d <bmap>
80101fc5:	83 c4 10             	add    $0x10,%esp
80101fc8:	89 c2                	mov    %eax,%edx
80101fca:	8b 45 08             	mov    0x8(%ebp),%eax
80101fcd:	8b 00                	mov    (%eax),%eax
80101fcf:	83 ec 08             	sub    $0x8,%esp
80101fd2:	52                   	push   %edx
80101fd3:	50                   	push   %eax
80101fd4:	e8 f5 e1 ff ff       	call   801001ce <bread>
80101fd9:	83 c4 10             	add    $0x10,%esp
80101fdc:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
80101fdf:	8b 45 10             	mov    0x10(%ebp),%eax
80101fe2:	25 ff 01 00 00       	and    $0x1ff,%eax
80101fe7:	ba 00 02 00 00       	mov    $0x200,%edx
80101fec:	29 c2                	sub    %eax,%edx
80101fee:	8b 45 14             	mov    0x14(%ebp),%eax
80101ff1:	2b 45 f4             	sub    -0xc(%ebp),%eax
80101ff4:	39 c2                	cmp    %eax,%edx
80101ff6:	0f 46 c2             	cmovbe %edx,%eax
80101ff9:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dst, bp->data + off%BSIZE, m);
80101ffc:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101fff:	8d 50 5c             	lea    0x5c(%eax),%edx
80102002:	8b 45 10             	mov    0x10(%ebp),%eax
80102005:	25 ff 01 00 00       	and    $0x1ff,%eax
8010200a:	01 d0                	add    %edx,%eax
8010200c:	83 ec 04             	sub    $0x4,%esp
8010200f:	ff 75 ec             	pushl  -0x14(%ebp)
80102012:	50                   	push   %eax
80102013:	ff 75 0c             	pushl  0xc(%ebp)
80102016:	e8 88 32 00 00       	call   801052a3 <memmove>
8010201b:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
8010201e:	83 ec 0c             	sub    $0xc,%esp
80102021:	ff 75 f0             	pushl  -0x10(%ebp)
80102024:	e8 27 e2 ff ff       	call   80100250 <brelse>
80102029:	83 c4 10             	add    $0x10,%esp
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > ip->size)
    n = ip->size - off;

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
8010202c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010202f:	01 45 f4             	add    %eax,-0xc(%ebp)
80102032:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102035:	01 45 10             	add    %eax,0x10(%ebp)
80102038:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010203b:	01 45 0c             	add    %eax,0xc(%ebp)
8010203e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102041:	3b 45 14             	cmp    0x14(%ebp),%eax
80102044:	0f 82 69 ff ff ff    	jb     80101fb3 <readi+0xbb>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    memmove(dst, bp->data + off%BSIZE, m);
    brelse(bp);
  }
  return n;
8010204a:	8b 45 14             	mov    0x14(%ebp),%eax
}
8010204d:	c9                   	leave  
8010204e:	c3                   	ret    

8010204f <writei>:
// PAGEBREAK!
// Write data to inode.
// Caller must hold ip->lock.
int
writei(struct inode *ip, char *src, uint off, uint n)
{
8010204f:	55                   	push   %ebp
80102050:	89 e5                	mov    %esp,%ebp
80102052:	83 ec 18             	sub    $0x18,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80102055:	8b 45 08             	mov    0x8(%ebp),%eax
80102058:	0f b7 40 50          	movzwl 0x50(%eax),%eax
8010205c:	66 83 f8 03          	cmp    $0x3,%ax
80102060:	75 5c                	jne    801020be <writei+0x6f>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
80102062:	8b 45 08             	mov    0x8(%ebp),%eax
80102065:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80102069:	66 85 c0             	test   %ax,%ax
8010206c:	78 20                	js     8010208e <writei+0x3f>
8010206e:	8b 45 08             	mov    0x8(%ebp),%eax
80102071:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80102075:	66 83 f8 09          	cmp    $0x9,%ax
80102079:	7f 13                	jg     8010208e <writei+0x3f>
8010207b:	8b 45 08             	mov    0x8(%ebp),%eax
8010207e:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80102082:	98                   	cwtl   
80102083:	8b 04 c5 e4 19 11 80 	mov    -0x7feee61c(,%eax,8),%eax
8010208a:	85 c0                	test   %eax,%eax
8010208c:	75 0a                	jne    80102098 <writei+0x49>
      return -1;
8010208e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102093:	e9 3d 01 00 00       	jmp    801021d5 <writei+0x186>
    return devsw[ip->major].write(ip, src, n);
80102098:	8b 45 08             	mov    0x8(%ebp),%eax
8010209b:	0f b7 40 52          	movzwl 0x52(%eax),%eax
8010209f:	98                   	cwtl   
801020a0:	8b 04 c5 e4 19 11 80 	mov    -0x7feee61c(,%eax,8),%eax
801020a7:	8b 55 14             	mov    0x14(%ebp),%edx
801020aa:	83 ec 04             	sub    $0x4,%esp
801020ad:	52                   	push   %edx
801020ae:	ff 75 0c             	pushl  0xc(%ebp)
801020b1:	ff 75 08             	pushl  0x8(%ebp)
801020b4:	ff d0                	call   *%eax
801020b6:	83 c4 10             	add    $0x10,%esp
801020b9:	e9 17 01 00 00       	jmp    801021d5 <writei+0x186>
  }

  if(off > ip->size || off + n < off)
801020be:	8b 45 08             	mov    0x8(%ebp),%eax
801020c1:	8b 40 58             	mov    0x58(%eax),%eax
801020c4:	3b 45 10             	cmp    0x10(%ebp),%eax
801020c7:	72 0d                	jb     801020d6 <writei+0x87>
801020c9:	8b 55 10             	mov    0x10(%ebp),%edx
801020cc:	8b 45 14             	mov    0x14(%ebp),%eax
801020cf:	01 d0                	add    %edx,%eax
801020d1:	3b 45 10             	cmp    0x10(%ebp),%eax
801020d4:	73 0a                	jae    801020e0 <writei+0x91>
    return -1;
801020d6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801020db:	e9 f5 00 00 00       	jmp    801021d5 <writei+0x186>
  if(off + n > MAXFILE*BSIZE)
801020e0:	8b 55 10             	mov    0x10(%ebp),%edx
801020e3:	8b 45 14             	mov    0x14(%ebp),%eax
801020e6:	01 d0                	add    %edx,%eax
801020e8:	3d 00 18 01 00       	cmp    $0x11800,%eax
801020ed:	76 0a                	jbe    801020f9 <writei+0xaa>
    return -1;
801020ef:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801020f4:	e9 dc 00 00 00       	jmp    801021d5 <writei+0x186>

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
801020f9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102100:	e9 99 00 00 00       	jmp    8010219e <writei+0x14f>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80102105:	8b 45 10             	mov    0x10(%ebp),%eax
80102108:	c1 e8 09             	shr    $0x9,%eax
8010210b:	83 ec 08             	sub    $0x8,%esp
8010210e:	50                   	push   %eax
8010210f:	ff 75 08             	pushl  0x8(%ebp)
80102112:	e8 46 fb ff ff       	call   80101c5d <bmap>
80102117:	83 c4 10             	add    $0x10,%esp
8010211a:	89 c2                	mov    %eax,%edx
8010211c:	8b 45 08             	mov    0x8(%ebp),%eax
8010211f:	8b 00                	mov    (%eax),%eax
80102121:	83 ec 08             	sub    $0x8,%esp
80102124:	52                   	push   %edx
80102125:	50                   	push   %eax
80102126:	e8 a3 e0 ff ff       	call   801001ce <bread>
8010212b:	83 c4 10             	add    $0x10,%esp
8010212e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
80102131:	8b 45 10             	mov    0x10(%ebp),%eax
80102134:	25 ff 01 00 00       	and    $0x1ff,%eax
80102139:	ba 00 02 00 00       	mov    $0x200,%edx
8010213e:	29 c2                	sub    %eax,%edx
80102140:	8b 45 14             	mov    0x14(%ebp),%eax
80102143:	2b 45 f4             	sub    -0xc(%ebp),%eax
80102146:	39 c2                	cmp    %eax,%edx
80102148:	0f 46 c2             	cmovbe %edx,%eax
8010214b:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(bp->data + off%BSIZE, src, m);
8010214e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102151:	8d 50 5c             	lea    0x5c(%eax),%edx
80102154:	8b 45 10             	mov    0x10(%ebp),%eax
80102157:	25 ff 01 00 00       	and    $0x1ff,%eax
8010215c:	01 d0                	add    %edx,%eax
8010215e:	83 ec 04             	sub    $0x4,%esp
80102161:	ff 75 ec             	pushl  -0x14(%ebp)
80102164:	ff 75 0c             	pushl  0xc(%ebp)
80102167:	50                   	push   %eax
80102168:	e8 36 31 00 00       	call   801052a3 <memmove>
8010216d:	83 c4 10             	add    $0x10,%esp
    log_write(bp);
80102170:	83 ec 0c             	sub    $0xc,%esp
80102173:	ff 75 f0             	pushl  -0x10(%ebp)
80102176:	e8 e9 15 00 00       	call   80103764 <log_write>
8010217b:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
8010217e:	83 ec 0c             	sub    $0xc,%esp
80102181:	ff 75 f0             	pushl  -0x10(%ebp)
80102184:	e8 c7 e0 ff ff       	call   80100250 <brelse>
80102189:	83 c4 10             	add    $0x10,%esp
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > MAXFILE*BSIZE)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
8010218c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010218f:	01 45 f4             	add    %eax,-0xc(%ebp)
80102192:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102195:	01 45 10             	add    %eax,0x10(%ebp)
80102198:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010219b:	01 45 0c             	add    %eax,0xc(%ebp)
8010219e:	8b 45 f4             	mov    -0xc(%ebp),%eax
801021a1:	3b 45 14             	cmp    0x14(%ebp),%eax
801021a4:	0f 82 5b ff ff ff    	jb     80102105 <writei+0xb6>
    memmove(bp->data + off%BSIZE, src, m);
    log_write(bp);
    brelse(bp);
  }

  if(n > 0 && off > ip->size){
801021aa:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
801021ae:	74 22                	je     801021d2 <writei+0x183>
801021b0:	8b 45 08             	mov    0x8(%ebp),%eax
801021b3:	8b 40 58             	mov    0x58(%eax),%eax
801021b6:	3b 45 10             	cmp    0x10(%ebp),%eax
801021b9:	73 17                	jae    801021d2 <writei+0x183>
    ip->size = off;
801021bb:	8b 45 08             	mov    0x8(%ebp),%eax
801021be:	8b 55 10             	mov    0x10(%ebp),%edx
801021c1:	89 50 58             	mov    %edx,0x58(%eax)
    iupdate(ip);
801021c4:	83 ec 0c             	sub    $0xc,%esp
801021c7:	ff 75 08             	pushl  0x8(%ebp)
801021ca:	e8 5b f6 ff ff       	call   8010182a <iupdate>
801021cf:	83 c4 10             	add    $0x10,%esp
  }
  return n;
801021d2:	8b 45 14             	mov    0x14(%ebp),%eax
}
801021d5:	c9                   	leave  
801021d6:	c3                   	ret    

801021d7 <namecmp>:
//PAGEBREAK!
// Directories

int
namecmp(const char *s, const char *t)
{
801021d7:	55                   	push   %ebp
801021d8:	89 e5                	mov    %esp,%ebp
801021da:	83 ec 08             	sub    $0x8,%esp
  return strncmp(s, t, DIRSIZ);
801021dd:	83 ec 04             	sub    $0x4,%esp
801021e0:	6a 0e                	push   $0xe
801021e2:	ff 75 0c             	pushl  0xc(%ebp)
801021e5:	ff 75 08             	pushl  0x8(%ebp)
801021e8:	e8 4c 31 00 00       	call   80105339 <strncmp>
801021ed:	83 c4 10             	add    $0x10,%esp
}
801021f0:	c9                   	leave  
801021f1:	c3                   	ret    

801021f2 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
801021f2:	55                   	push   %ebp
801021f3:	89 e5                	mov    %esp,%ebp
801021f5:	83 ec 28             	sub    $0x28,%esp
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
801021f8:	8b 45 08             	mov    0x8(%ebp),%eax
801021fb:	0f b7 40 50          	movzwl 0x50(%eax),%eax
801021ff:	66 83 f8 01          	cmp    $0x1,%ax
80102203:	74 0d                	je     80102212 <dirlookup+0x20>
    panic("dirlookup not DIR");
80102205:	83 ec 0c             	sub    $0xc,%esp
80102208:	68 2d 87 10 80       	push   $0x8010872d
8010220d:	e8 8e e3 ff ff       	call   801005a0 <panic>

  for(off = 0; off < dp->size; off += sizeof(de)){
80102212:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102219:	eb 7b                	jmp    80102296 <dirlookup+0xa4>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
8010221b:	6a 10                	push   $0x10
8010221d:	ff 75 f4             	pushl  -0xc(%ebp)
80102220:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102223:	50                   	push   %eax
80102224:	ff 75 08             	pushl  0x8(%ebp)
80102227:	e8 cc fc ff ff       	call   80101ef8 <readi>
8010222c:	83 c4 10             	add    $0x10,%esp
8010222f:	83 f8 10             	cmp    $0x10,%eax
80102232:	74 0d                	je     80102241 <dirlookup+0x4f>
      panic("dirlookup read");
80102234:	83 ec 0c             	sub    $0xc,%esp
80102237:	68 3f 87 10 80       	push   $0x8010873f
8010223c:	e8 5f e3 ff ff       	call   801005a0 <panic>
    if(de.inum == 0)
80102241:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
80102245:	66 85 c0             	test   %ax,%ax
80102248:	74 47                	je     80102291 <dirlookup+0x9f>
      continue;
    if(namecmp(name, de.name) == 0){
8010224a:	83 ec 08             	sub    $0x8,%esp
8010224d:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102250:	83 c0 02             	add    $0x2,%eax
80102253:	50                   	push   %eax
80102254:	ff 75 0c             	pushl  0xc(%ebp)
80102257:	e8 7b ff ff ff       	call   801021d7 <namecmp>
8010225c:	83 c4 10             	add    $0x10,%esp
8010225f:	85 c0                	test   %eax,%eax
80102261:	75 2f                	jne    80102292 <dirlookup+0xa0>
      // entry matches path element
      if(poff)
80102263:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80102267:	74 08                	je     80102271 <dirlookup+0x7f>
        *poff = off;
80102269:	8b 45 10             	mov    0x10(%ebp),%eax
8010226c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010226f:	89 10                	mov    %edx,(%eax)
      inum = de.inum;
80102271:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
80102275:	0f b7 c0             	movzwl %ax,%eax
80102278:	89 45 f0             	mov    %eax,-0x10(%ebp)
      return iget(dp->dev, inum);
8010227b:	8b 45 08             	mov    0x8(%ebp),%eax
8010227e:	8b 00                	mov    (%eax),%eax
80102280:	83 ec 08             	sub    $0x8,%esp
80102283:	ff 75 f0             	pushl  -0x10(%ebp)
80102286:	50                   	push   %eax
80102287:	e8 5f f6 ff ff       	call   801018eb <iget>
8010228c:	83 c4 10             	add    $0x10,%esp
8010228f:	eb 19                	jmp    801022aa <dirlookup+0xb8>

  for(off = 0; off < dp->size; off += sizeof(de)){
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("dirlookup read");
    if(de.inum == 0)
      continue;
80102291:	90                   	nop
  struct dirent de;

  if(dp->type != T_DIR)
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
80102292:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80102296:	8b 45 08             	mov    0x8(%ebp),%eax
80102299:	8b 40 58             	mov    0x58(%eax),%eax
8010229c:	3b 45 f4             	cmp    -0xc(%ebp),%eax
8010229f:	0f 87 76 ff ff ff    	ja     8010221b <dirlookup+0x29>
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
801022a5:	b8 00 00 00 00       	mov    $0x0,%eax
}
801022aa:	c9                   	leave  
801022ab:	c3                   	ret    

801022ac <dirlink>:

// Write a new directory entry (name, inum) into the directory dp.
int
dirlink(struct inode *dp, char *name, uint inum)
{
801022ac:	55                   	push   %ebp
801022ad:	89 e5                	mov    %esp,%ebp
801022af:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;
  struct inode *ip;

  // Check that name is not present.
  if((ip = dirlookup(dp, name, 0)) != 0){
801022b2:	83 ec 04             	sub    $0x4,%esp
801022b5:	6a 00                	push   $0x0
801022b7:	ff 75 0c             	pushl  0xc(%ebp)
801022ba:	ff 75 08             	pushl  0x8(%ebp)
801022bd:	e8 30 ff ff ff       	call   801021f2 <dirlookup>
801022c2:	83 c4 10             	add    $0x10,%esp
801022c5:	89 45 f0             	mov    %eax,-0x10(%ebp)
801022c8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801022cc:	74 18                	je     801022e6 <dirlink+0x3a>
    iput(ip);
801022ce:	83 ec 0c             	sub    $0xc,%esp
801022d1:	ff 75 f0             	pushl  -0x10(%ebp)
801022d4:	e8 8f f8 ff ff       	call   80101b68 <iput>
801022d9:	83 c4 10             	add    $0x10,%esp
    return -1;
801022dc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801022e1:	e9 9c 00 00 00       	jmp    80102382 <dirlink+0xd6>
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
801022e6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801022ed:	eb 39                	jmp    80102328 <dirlink+0x7c>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801022ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
801022f2:	6a 10                	push   $0x10
801022f4:	50                   	push   %eax
801022f5:	8d 45 e0             	lea    -0x20(%ebp),%eax
801022f8:	50                   	push   %eax
801022f9:	ff 75 08             	pushl  0x8(%ebp)
801022fc:	e8 f7 fb ff ff       	call   80101ef8 <readi>
80102301:	83 c4 10             	add    $0x10,%esp
80102304:	83 f8 10             	cmp    $0x10,%eax
80102307:	74 0d                	je     80102316 <dirlink+0x6a>
      panic("dirlink read");
80102309:	83 ec 0c             	sub    $0xc,%esp
8010230c:	68 4e 87 10 80       	push   $0x8010874e
80102311:	e8 8a e2 ff ff       	call   801005a0 <panic>
    if(de.inum == 0)
80102316:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
8010231a:	66 85 c0             	test   %ax,%ax
8010231d:	74 18                	je     80102337 <dirlink+0x8b>
    iput(ip);
    return -1;
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
8010231f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102322:	83 c0 10             	add    $0x10,%eax
80102325:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102328:	8b 45 08             	mov    0x8(%ebp),%eax
8010232b:	8b 50 58             	mov    0x58(%eax),%edx
8010232e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102331:	39 c2                	cmp    %eax,%edx
80102333:	77 ba                	ja     801022ef <dirlink+0x43>
80102335:	eb 01                	jmp    80102338 <dirlink+0x8c>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("dirlink read");
    if(de.inum == 0)
      break;
80102337:	90                   	nop
  }

  strncpy(de.name, name, DIRSIZ);
80102338:	83 ec 04             	sub    $0x4,%esp
8010233b:	6a 0e                	push   $0xe
8010233d:	ff 75 0c             	pushl  0xc(%ebp)
80102340:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102343:	83 c0 02             	add    $0x2,%eax
80102346:	50                   	push   %eax
80102347:	e8 43 30 00 00       	call   8010538f <strncpy>
8010234c:	83 c4 10             	add    $0x10,%esp
  de.inum = inum;
8010234f:	8b 45 10             	mov    0x10(%ebp),%eax
80102352:	66 89 45 e0          	mov    %ax,-0x20(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102356:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102359:	6a 10                	push   $0x10
8010235b:	50                   	push   %eax
8010235c:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010235f:	50                   	push   %eax
80102360:	ff 75 08             	pushl  0x8(%ebp)
80102363:	e8 e7 fc ff ff       	call   8010204f <writei>
80102368:	83 c4 10             	add    $0x10,%esp
8010236b:	83 f8 10             	cmp    $0x10,%eax
8010236e:	74 0d                	je     8010237d <dirlink+0xd1>
    panic("dirlink");
80102370:	83 ec 0c             	sub    $0xc,%esp
80102373:	68 5b 87 10 80       	push   $0x8010875b
80102378:	e8 23 e2 ff ff       	call   801005a0 <panic>

  return 0;
8010237d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102382:	c9                   	leave  
80102383:	c3                   	ret    

80102384 <skipelem>:
//   skipelem("a", name) = "", setting name = "a"
//   skipelem("", name) = skipelem("////", name) = 0
//
static char*
skipelem(char *path, char *name)
{
80102384:	55                   	push   %ebp
80102385:	89 e5                	mov    %esp,%ebp
80102387:	83 ec 18             	sub    $0x18,%esp
  char *s;
  int len;

  while(*path == '/')
8010238a:	eb 04                	jmp    80102390 <skipelem+0xc>
    path++;
8010238c:	83 45 08 01          	addl   $0x1,0x8(%ebp)
skipelem(char *path, char *name)
{
  char *s;
  int len;

  while(*path == '/')
80102390:	8b 45 08             	mov    0x8(%ebp),%eax
80102393:	0f b6 00             	movzbl (%eax),%eax
80102396:	3c 2f                	cmp    $0x2f,%al
80102398:	74 f2                	je     8010238c <skipelem+0x8>
    path++;
  if(*path == 0)
8010239a:	8b 45 08             	mov    0x8(%ebp),%eax
8010239d:	0f b6 00             	movzbl (%eax),%eax
801023a0:	84 c0                	test   %al,%al
801023a2:	75 07                	jne    801023ab <skipelem+0x27>
    return 0;
801023a4:	b8 00 00 00 00       	mov    $0x0,%eax
801023a9:	eb 7b                	jmp    80102426 <skipelem+0xa2>
  s = path;
801023ab:	8b 45 08             	mov    0x8(%ebp),%eax
801023ae:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(*path != '/' && *path != 0)
801023b1:	eb 04                	jmp    801023b7 <skipelem+0x33>
    path++;
801023b3:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
    path++;
  if(*path == 0)
    return 0;
  s = path;
  while(*path != '/' && *path != 0)
801023b7:	8b 45 08             	mov    0x8(%ebp),%eax
801023ba:	0f b6 00             	movzbl (%eax),%eax
801023bd:	3c 2f                	cmp    $0x2f,%al
801023bf:	74 0a                	je     801023cb <skipelem+0x47>
801023c1:	8b 45 08             	mov    0x8(%ebp),%eax
801023c4:	0f b6 00             	movzbl (%eax),%eax
801023c7:	84 c0                	test   %al,%al
801023c9:	75 e8                	jne    801023b3 <skipelem+0x2f>
    path++;
  len = path - s;
801023cb:	8b 55 08             	mov    0x8(%ebp),%edx
801023ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
801023d1:	29 c2                	sub    %eax,%edx
801023d3:	89 d0                	mov    %edx,%eax
801023d5:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(len >= DIRSIZ)
801023d8:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
801023dc:	7e 15                	jle    801023f3 <skipelem+0x6f>
    memmove(name, s, DIRSIZ);
801023de:	83 ec 04             	sub    $0x4,%esp
801023e1:	6a 0e                	push   $0xe
801023e3:	ff 75 f4             	pushl  -0xc(%ebp)
801023e6:	ff 75 0c             	pushl  0xc(%ebp)
801023e9:	e8 b5 2e 00 00       	call   801052a3 <memmove>
801023ee:	83 c4 10             	add    $0x10,%esp
801023f1:	eb 26                	jmp    80102419 <skipelem+0x95>
  else {
    memmove(name, s, len);
801023f3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801023f6:	83 ec 04             	sub    $0x4,%esp
801023f9:	50                   	push   %eax
801023fa:	ff 75 f4             	pushl  -0xc(%ebp)
801023fd:	ff 75 0c             	pushl  0xc(%ebp)
80102400:	e8 9e 2e 00 00       	call   801052a3 <memmove>
80102405:	83 c4 10             	add    $0x10,%esp
    name[len] = 0;
80102408:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010240b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010240e:	01 d0                	add    %edx,%eax
80102410:	c6 00 00             	movb   $0x0,(%eax)
  }
  while(*path == '/')
80102413:	eb 04                	jmp    80102419 <skipelem+0x95>
    path++;
80102415:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    memmove(name, s, DIRSIZ);
  else {
    memmove(name, s, len);
    name[len] = 0;
  }
  while(*path == '/')
80102419:	8b 45 08             	mov    0x8(%ebp),%eax
8010241c:	0f b6 00             	movzbl (%eax),%eax
8010241f:	3c 2f                	cmp    $0x2f,%al
80102421:	74 f2                	je     80102415 <skipelem+0x91>
    path++;
  return path;
80102423:	8b 45 08             	mov    0x8(%ebp),%eax
}
80102426:	c9                   	leave  
80102427:	c3                   	ret    

80102428 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
80102428:	55                   	push   %ebp
80102429:	89 e5                	mov    %esp,%ebp
8010242b:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip, *next;

  if(*path == '/')
8010242e:	8b 45 08             	mov    0x8(%ebp),%eax
80102431:	0f b6 00             	movzbl (%eax),%eax
80102434:	3c 2f                	cmp    $0x2f,%al
80102436:	75 17                	jne    8010244f <namex+0x27>
    ip = iget(ROOTDEV, ROOTINO);
80102438:	83 ec 08             	sub    $0x8,%esp
8010243b:	6a 01                	push   $0x1
8010243d:	6a 01                	push   $0x1
8010243f:	e8 a7 f4 ff ff       	call   801018eb <iget>
80102444:	83 c4 10             	add    $0x10,%esp
80102447:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010244a:	e9 ba 00 00 00       	jmp    80102509 <namex+0xe1>
  else
    ip = idup(myproc()->cwd);
8010244f:	e8 30 1e 00 00       	call   80104284 <myproc>
80102454:	8b 40 70             	mov    0x70(%eax),%eax
80102457:	83 ec 0c             	sub    $0xc,%esp
8010245a:	50                   	push   %eax
8010245b:	e8 6d f5 ff ff       	call   801019cd <idup>
80102460:	83 c4 10             	add    $0x10,%esp
80102463:	89 45 f4             	mov    %eax,-0xc(%ebp)

  while((path = skipelem(path, name)) != 0){
80102466:	e9 9e 00 00 00       	jmp    80102509 <namex+0xe1>
    ilock(ip);
8010246b:	83 ec 0c             	sub    $0xc,%esp
8010246e:	ff 75 f4             	pushl  -0xc(%ebp)
80102471:	e8 91 f5 ff ff       	call   80101a07 <ilock>
80102476:	83 c4 10             	add    $0x10,%esp
    if(ip->type != T_DIR){
80102479:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010247c:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80102480:	66 83 f8 01          	cmp    $0x1,%ax
80102484:	74 18                	je     8010249e <namex+0x76>
      iunlockput(ip);
80102486:	83 ec 0c             	sub    $0xc,%esp
80102489:	ff 75 f4             	pushl  -0xc(%ebp)
8010248c:	e8 a7 f7 ff ff       	call   80101c38 <iunlockput>
80102491:	83 c4 10             	add    $0x10,%esp
      return 0;
80102494:	b8 00 00 00 00       	mov    $0x0,%eax
80102499:	e9 a7 00 00 00       	jmp    80102545 <namex+0x11d>
    }
    if(nameiparent && *path == '\0'){
8010249e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801024a2:	74 20                	je     801024c4 <namex+0x9c>
801024a4:	8b 45 08             	mov    0x8(%ebp),%eax
801024a7:	0f b6 00             	movzbl (%eax),%eax
801024aa:	84 c0                	test   %al,%al
801024ac:	75 16                	jne    801024c4 <namex+0x9c>
      // Stop one level early.
      iunlock(ip);
801024ae:	83 ec 0c             	sub    $0xc,%esp
801024b1:	ff 75 f4             	pushl  -0xc(%ebp)
801024b4:	e8 61 f6 ff ff       	call   80101b1a <iunlock>
801024b9:	83 c4 10             	add    $0x10,%esp
      return ip;
801024bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801024bf:	e9 81 00 00 00       	jmp    80102545 <namex+0x11d>
    }
    if((next = dirlookup(ip, name, 0)) == 0){
801024c4:	83 ec 04             	sub    $0x4,%esp
801024c7:	6a 00                	push   $0x0
801024c9:	ff 75 10             	pushl  0x10(%ebp)
801024cc:	ff 75 f4             	pushl  -0xc(%ebp)
801024cf:	e8 1e fd ff ff       	call   801021f2 <dirlookup>
801024d4:	83 c4 10             	add    $0x10,%esp
801024d7:	89 45 f0             	mov    %eax,-0x10(%ebp)
801024da:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801024de:	75 15                	jne    801024f5 <namex+0xcd>
      iunlockput(ip);
801024e0:	83 ec 0c             	sub    $0xc,%esp
801024e3:	ff 75 f4             	pushl  -0xc(%ebp)
801024e6:	e8 4d f7 ff ff       	call   80101c38 <iunlockput>
801024eb:	83 c4 10             	add    $0x10,%esp
      return 0;
801024ee:	b8 00 00 00 00       	mov    $0x0,%eax
801024f3:	eb 50                	jmp    80102545 <namex+0x11d>
    }
    iunlockput(ip);
801024f5:	83 ec 0c             	sub    $0xc,%esp
801024f8:	ff 75 f4             	pushl  -0xc(%ebp)
801024fb:	e8 38 f7 ff ff       	call   80101c38 <iunlockput>
80102500:	83 c4 10             	add    $0x10,%esp
    ip = next;
80102503:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102506:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(*path == '/')
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);

  while((path = skipelem(path, name)) != 0){
80102509:	83 ec 08             	sub    $0x8,%esp
8010250c:	ff 75 10             	pushl  0x10(%ebp)
8010250f:	ff 75 08             	pushl  0x8(%ebp)
80102512:	e8 6d fe ff ff       	call   80102384 <skipelem>
80102517:	83 c4 10             	add    $0x10,%esp
8010251a:	89 45 08             	mov    %eax,0x8(%ebp)
8010251d:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102521:	0f 85 44 ff ff ff    	jne    8010246b <namex+0x43>
      return 0;
    }
    iunlockput(ip);
    ip = next;
  }
  if(nameiparent){
80102527:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
8010252b:	74 15                	je     80102542 <namex+0x11a>
    iput(ip);
8010252d:	83 ec 0c             	sub    $0xc,%esp
80102530:	ff 75 f4             	pushl  -0xc(%ebp)
80102533:	e8 30 f6 ff ff       	call   80101b68 <iput>
80102538:	83 c4 10             	add    $0x10,%esp
    return 0;
8010253b:	b8 00 00 00 00       	mov    $0x0,%eax
80102540:	eb 03                	jmp    80102545 <namex+0x11d>
  }
  return ip;
80102542:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102545:	c9                   	leave  
80102546:	c3                   	ret    

80102547 <namei>:

struct inode*
namei(char *path)
{
80102547:	55                   	push   %ebp
80102548:	89 e5                	mov    %esp,%ebp
8010254a:	83 ec 18             	sub    $0x18,%esp
  char name[DIRSIZ];
  return namex(path, 0, name);
8010254d:	83 ec 04             	sub    $0x4,%esp
80102550:	8d 45 ea             	lea    -0x16(%ebp),%eax
80102553:	50                   	push   %eax
80102554:	6a 00                	push   $0x0
80102556:	ff 75 08             	pushl  0x8(%ebp)
80102559:	e8 ca fe ff ff       	call   80102428 <namex>
8010255e:	83 c4 10             	add    $0x10,%esp
}
80102561:	c9                   	leave  
80102562:	c3                   	ret    

80102563 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
80102563:	55                   	push   %ebp
80102564:	89 e5                	mov    %esp,%ebp
80102566:	83 ec 08             	sub    $0x8,%esp
  return namex(path, 1, name);
80102569:	83 ec 04             	sub    $0x4,%esp
8010256c:	ff 75 0c             	pushl  0xc(%ebp)
8010256f:	6a 01                	push   $0x1
80102571:	ff 75 08             	pushl  0x8(%ebp)
80102574:	e8 af fe ff ff       	call   80102428 <namex>
80102579:	83 c4 10             	add    $0x10,%esp
}
8010257c:	c9                   	leave  
8010257d:	c3                   	ret    

8010257e <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
8010257e:	55                   	push   %ebp
8010257f:	89 e5                	mov    %esp,%ebp
80102581:	83 ec 14             	sub    $0x14,%esp
80102584:	8b 45 08             	mov    0x8(%ebp),%eax
80102587:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010258b:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
8010258f:	89 c2                	mov    %eax,%edx
80102591:	ec                   	in     (%dx),%al
80102592:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102595:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102599:	c9                   	leave  
8010259a:	c3                   	ret    

8010259b <insl>:

static inline void
insl(int port, void *addr, int cnt)
{
8010259b:	55                   	push   %ebp
8010259c:	89 e5                	mov    %esp,%ebp
8010259e:	57                   	push   %edi
8010259f:	53                   	push   %ebx
  asm volatile("cld; rep insl" :
801025a0:	8b 55 08             	mov    0x8(%ebp),%edx
801025a3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801025a6:	8b 45 10             	mov    0x10(%ebp),%eax
801025a9:	89 cb                	mov    %ecx,%ebx
801025ab:	89 df                	mov    %ebx,%edi
801025ad:	89 c1                	mov    %eax,%ecx
801025af:	fc                   	cld    
801025b0:	f3 6d                	rep insl (%dx),%es:(%edi)
801025b2:	89 c8                	mov    %ecx,%eax
801025b4:	89 fb                	mov    %edi,%ebx
801025b6:	89 5d 0c             	mov    %ebx,0xc(%ebp)
801025b9:	89 45 10             	mov    %eax,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "memory", "cc");
}
801025bc:	90                   	nop
801025bd:	5b                   	pop    %ebx
801025be:	5f                   	pop    %edi
801025bf:	5d                   	pop    %ebp
801025c0:	c3                   	ret    

801025c1 <outb>:

static inline void
outb(ushort port, uchar data)
{
801025c1:	55                   	push   %ebp
801025c2:	89 e5                	mov    %esp,%ebp
801025c4:	83 ec 08             	sub    $0x8,%esp
801025c7:	8b 55 08             	mov    0x8(%ebp),%edx
801025ca:	8b 45 0c             	mov    0xc(%ebp),%eax
801025cd:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
801025d1:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801025d4:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801025d8:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801025dc:	ee                   	out    %al,(%dx)
}
801025dd:	90                   	nop
801025de:	c9                   	leave  
801025df:	c3                   	ret    

801025e0 <outsl>:
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
}

static inline void
outsl(int port, const void *addr, int cnt)
{
801025e0:	55                   	push   %ebp
801025e1:	89 e5                	mov    %esp,%ebp
801025e3:	56                   	push   %esi
801025e4:	53                   	push   %ebx
  asm volatile("cld; rep outsl" :
801025e5:	8b 55 08             	mov    0x8(%ebp),%edx
801025e8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801025eb:	8b 45 10             	mov    0x10(%ebp),%eax
801025ee:	89 cb                	mov    %ecx,%ebx
801025f0:	89 de                	mov    %ebx,%esi
801025f2:	89 c1                	mov    %eax,%ecx
801025f4:	fc                   	cld    
801025f5:	f3 6f                	rep outsl %ds:(%esi),(%dx)
801025f7:	89 c8                	mov    %ecx,%eax
801025f9:	89 f3                	mov    %esi,%ebx
801025fb:	89 5d 0c             	mov    %ebx,0xc(%ebp)
801025fe:	89 45 10             	mov    %eax,0x10(%ebp)
               "=S" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "cc");
}
80102601:	90                   	nop
80102602:	5b                   	pop    %ebx
80102603:	5e                   	pop    %esi
80102604:	5d                   	pop    %ebp
80102605:	c3                   	ret    

80102606 <idewait>:
static void idestart(struct buf*);

// Wait for IDE disk to become ready.
static int
idewait(int checkerr)
{
80102606:	55                   	push   %ebp
80102607:	89 e5                	mov    %esp,%ebp
80102609:	83 ec 10             	sub    $0x10,%esp
  int r;

  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
8010260c:	90                   	nop
8010260d:	68 f7 01 00 00       	push   $0x1f7
80102612:	e8 67 ff ff ff       	call   8010257e <inb>
80102617:	83 c4 04             	add    $0x4,%esp
8010261a:	0f b6 c0             	movzbl %al,%eax
8010261d:	89 45 fc             	mov    %eax,-0x4(%ebp)
80102620:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102623:	25 c0 00 00 00       	and    $0xc0,%eax
80102628:	83 f8 40             	cmp    $0x40,%eax
8010262b:	75 e0                	jne    8010260d <idewait+0x7>
    ;
  if(checkerr && (r & (IDE_DF|IDE_ERR)) != 0)
8010262d:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102631:	74 11                	je     80102644 <idewait+0x3e>
80102633:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102636:	83 e0 21             	and    $0x21,%eax
80102639:	85 c0                	test   %eax,%eax
8010263b:	74 07                	je     80102644 <idewait+0x3e>
    return -1;
8010263d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102642:	eb 05                	jmp    80102649 <idewait+0x43>
  return 0;
80102644:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102649:	c9                   	leave  
8010264a:	c3                   	ret    

8010264b <ideinit>:

void
ideinit(void)
{
8010264b:	55                   	push   %ebp
8010264c:	89 e5                	mov    %esp,%ebp
8010264e:	83 ec 18             	sub    $0x18,%esp
  int i;

  initlock(&idelock, "ide");
80102651:	83 ec 08             	sub    $0x8,%esp
80102654:	68 63 87 10 80       	push   $0x80108763
80102659:	68 e0 b5 10 80       	push   $0x8010b5e0
8010265e:	e8 e8 28 00 00       	call   80104f4b <initlock>
80102663:	83 c4 10             	add    $0x10,%esp
  ioapicenable(IRQ_IDE, ncpu - 1);
80102666:	a1 80 3d 11 80       	mov    0x80113d80,%eax
8010266b:	83 e8 01             	sub    $0x1,%eax
8010266e:	83 ec 08             	sub    $0x8,%esp
80102671:	50                   	push   %eax
80102672:	6a 0e                	push   $0xe
80102674:	e8 a2 04 00 00       	call   80102b1b <ioapicenable>
80102679:	83 c4 10             	add    $0x10,%esp
  idewait(0);
8010267c:	83 ec 0c             	sub    $0xc,%esp
8010267f:	6a 00                	push   $0x0
80102681:	e8 80 ff ff ff       	call   80102606 <idewait>
80102686:	83 c4 10             	add    $0x10,%esp

  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
80102689:	83 ec 08             	sub    $0x8,%esp
8010268c:	68 f0 00 00 00       	push   $0xf0
80102691:	68 f6 01 00 00       	push   $0x1f6
80102696:	e8 26 ff ff ff       	call   801025c1 <outb>
8010269b:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<1000; i++){
8010269e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801026a5:	eb 24                	jmp    801026cb <ideinit+0x80>
    if(inb(0x1f7) != 0){
801026a7:	83 ec 0c             	sub    $0xc,%esp
801026aa:	68 f7 01 00 00       	push   $0x1f7
801026af:	e8 ca fe ff ff       	call   8010257e <inb>
801026b4:	83 c4 10             	add    $0x10,%esp
801026b7:	84 c0                	test   %al,%al
801026b9:	74 0c                	je     801026c7 <ideinit+0x7c>
      havedisk1 = 1;
801026bb:	c7 05 18 b6 10 80 01 	movl   $0x1,0x8010b618
801026c2:	00 00 00 
      break;
801026c5:	eb 0d                	jmp    801026d4 <ideinit+0x89>
  ioapicenable(IRQ_IDE, ncpu - 1);
  idewait(0);

  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
  for(i=0; i<1000; i++){
801026c7:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801026cb:	81 7d f4 e7 03 00 00 	cmpl   $0x3e7,-0xc(%ebp)
801026d2:	7e d3                	jle    801026a7 <ideinit+0x5c>
      break;
    }
  }

  // Switch back to disk 0.
  outb(0x1f6, 0xe0 | (0<<4));
801026d4:	83 ec 08             	sub    $0x8,%esp
801026d7:	68 e0 00 00 00       	push   $0xe0
801026dc:	68 f6 01 00 00       	push   $0x1f6
801026e1:	e8 db fe ff ff       	call   801025c1 <outb>
801026e6:	83 c4 10             	add    $0x10,%esp
}
801026e9:	90                   	nop
801026ea:	c9                   	leave  
801026eb:	c3                   	ret    

801026ec <idestart>:

// Start the request for b.  Caller must hold idelock.
static void
idestart(struct buf *b)
{
801026ec:	55                   	push   %ebp
801026ed:	89 e5                	mov    %esp,%ebp
801026ef:	83 ec 18             	sub    $0x18,%esp
  if(b == 0)
801026f2:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801026f6:	75 0d                	jne    80102705 <idestart+0x19>
    panic("idestart");
801026f8:	83 ec 0c             	sub    $0xc,%esp
801026fb:	68 67 87 10 80       	push   $0x80108767
80102700:	e8 9b de ff ff       	call   801005a0 <panic>
  if(b->blockno >= FSSIZE)
80102705:	8b 45 08             	mov    0x8(%ebp),%eax
80102708:	8b 40 08             	mov    0x8(%eax),%eax
8010270b:	3d e7 03 00 00       	cmp    $0x3e7,%eax
80102710:	76 0d                	jbe    8010271f <idestart+0x33>
    panic("incorrect blockno");
80102712:	83 ec 0c             	sub    $0xc,%esp
80102715:	68 70 87 10 80       	push   $0x80108770
8010271a:	e8 81 de ff ff       	call   801005a0 <panic>
  int sector_per_block =  BSIZE/SECTOR_SIZE;
8010271f:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
  int sector = b->blockno * sector_per_block;
80102726:	8b 45 08             	mov    0x8(%ebp),%eax
80102729:	8b 50 08             	mov    0x8(%eax),%edx
8010272c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010272f:	0f af c2             	imul   %edx,%eax
80102732:	89 45 f0             	mov    %eax,-0x10(%ebp)
  int read_cmd = (sector_per_block == 1) ? IDE_CMD_READ :  IDE_CMD_RDMUL;
80102735:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
80102739:	75 07                	jne    80102742 <idestart+0x56>
8010273b:	b8 20 00 00 00       	mov    $0x20,%eax
80102740:	eb 05                	jmp    80102747 <idestart+0x5b>
80102742:	b8 c4 00 00 00       	mov    $0xc4,%eax
80102747:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int write_cmd = (sector_per_block == 1) ? IDE_CMD_WRITE : IDE_CMD_WRMUL;
8010274a:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
8010274e:	75 07                	jne    80102757 <idestart+0x6b>
80102750:	b8 30 00 00 00       	mov    $0x30,%eax
80102755:	eb 05                	jmp    8010275c <idestart+0x70>
80102757:	b8 c5 00 00 00       	mov    $0xc5,%eax
8010275c:	89 45 e8             	mov    %eax,-0x18(%ebp)

  if (sector_per_block > 7) panic("idestart");
8010275f:	83 7d f4 07          	cmpl   $0x7,-0xc(%ebp)
80102763:	7e 0d                	jle    80102772 <idestart+0x86>
80102765:	83 ec 0c             	sub    $0xc,%esp
80102768:	68 67 87 10 80       	push   $0x80108767
8010276d:	e8 2e de ff ff       	call   801005a0 <panic>

  idewait(0);
80102772:	83 ec 0c             	sub    $0xc,%esp
80102775:	6a 00                	push   $0x0
80102777:	e8 8a fe ff ff       	call   80102606 <idewait>
8010277c:	83 c4 10             	add    $0x10,%esp
  outb(0x3f6, 0);  // generate interrupt
8010277f:	83 ec 08             	sub    $0x8,%esp
80102782:	6a 00                	push   $0x0
80102784:	68 f6 03 00 00       	push   $0x3f6
80102789:	e8 33 fe ff ff       	call   801025c1 <outb>
8010278e:	83 c4 10             	add    $0x10,%esp
  outb(0x1f2, sector_per_block);  // number of sectors
80102791:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102794:	0f b6 c0             	movzbl %al,%eax
80102797:	83 ec 08             	sub    $0x8,%esp
8010279a:	50                   	push   %eax
8010279b:	68 f2 01 00 00       	push   $0x1f2
801027a0:	e8 1c fe ff ff       	call   801025c1 <outb>
801027a5:	83 c4 10             	add    $0x10,%esp
  outb(0x1f3, sector & 0xff);
801027a8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801027ab:	0f b6 c0             	movzbl %al,%eax
801027ae:	83 ec 08             	sub    $0x8,%esp
801027b1:	50                   	push   %eax
801027b2:	68 f3 01 00 00       	push   $0x1f3
801027b7:	e8 05 fe ff ff       	call   801025c1 <outb>
801027bc:	83 c4 10             	add    $0x10,%esp
  outb(0x1f4, (sector >> 8) & 0xff);
801027bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
801027c2:	c1 f8 08             	sar    $0x8,%eax
801027c5:	0f b6 c0             	movzbl %al,%eax
801027c8:	83 ec 08             	sub    $0x8,%esp
801027cb:	50                   	push   %eax
801027cc:	68 f4 01 00 00       	push   $0x1f4
801027d1:	e8 eb fd ff ff       	call   801025c1 <outb>
801027d6:	83 c4 10             	add    $0x10,%esp
  outb(0x1f5, (sector >> 16) & 0xff);
801027d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801027dc:	c1 f8 10             	sar    $0x10,%eax
801027df:	0f b6 c0             	movzbl %al,%eax
801027e2:	83 ec 08             	sub    $0x8,%esp
801027e5:	50                   	push   %eax
801027e6:	68 f5 01 00 00       	push   $0x1f5
801027eb:	e8 d1 fd ff ff       	call   801025c1 <outb>
801027f0:	83 c4 10             	add    $0x10,%esp
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((sector>>24)&0x0f));
801027f3:	8b 45 08             	mov    0x8(%ebp),%eax
801027f6:	8b 40 04             	mov    0x4(%eax),%eax
801027f9:	83 e0 01             	and    $0x1,%eax
801027fc:	c1 e0 04             	shl    $0x4,%eax
801027ff:	89 c2                	mov    %eax,%edx
80102801:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102804:	c1 f8 18             	sar    $0x18,%eax
80102807:	83 e0 0f             	and    $0xf,%eax
8010280a:	09 d0                	or     %edx,%eax
8010280c:	83 c8 e0             	or     $0xffffffe0,%eax
8010280f:	0f b6 c0             	movzbl %al,%eax
80102812:	83 ec 08             	sub    $0x8,%esp
80102815:	50                   	push   %eax
80102816:	68 f6 01 00 00       	push   $0x1f6
8010281b:	e8 a1 fd ff ff       	call   801025c1 <outb>
80102820:	83 c4 10             	add    $0x10,%esp
  if(b->flags & B_DIRTY){
80102823:	8b 45 08             	mov    0x8(%ebp),%eax
80102826:	8b 00                	mov    (%eax),%eax
80102828:	83 e0 04             	and    $0x4,%eax
8010282b:	85 c0                	test   %eax,%eax
8010282d:	74 35                	je     80102864 <idestart+0x178>
    outb(0x1f7, write_cmd);
8010282f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80102832:	0f b6 c0             	movzbl %al,%eax
80102835:	83 ec 08             	sub    $0x8,%esp
80102838:	50                   	push   %eax
80102839:	68 f7 01 00 00       	push   $0x1f7
8010283e:	e8 7e fd ff ff       	call   801025c1 <outb>
80102843:	83 c4 10             	add    $0x10,%esp
    outsl(0x1f0, b->data, BSIZE/4);
80102846:	8b 45 08             	mov    0x8(%ebp),%eax
80102849:	83 c0 5c             	add    $0x5c,%eax
8010284c:	83 ec 04             	sub    $0x4,%esp
8010284f:	68 80 00 00 00       	push   $0x80
80102854:	50                   	push   %eax
80102855:	68 f0 01 00 00       	push   $0x1f0
8010285a:	e8 81 fd ff ff       	call   801025e0 <outsl>
8010285f:	83 c4 10             	add    $0x10,%esp
  } else {
    outb(0x1f7, read_cmd);
  }
}
80102862:	eb 17                	jmp    8010287b <idestart+0x18f>
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((sector>>24)&0x0f));
  if(b->flags & B_DIRTY){
    outb(0x1f7, write_cmd);
    outsl(0x1f0, b->data, BSIZE/4);
  } else {
    outb(0x1f7, read_cmd);
80102864:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102867:	0f b6 c0             	movzbl %al,%eax
8010286a:	83 ec 08             	sub    $0x8,%esp
8010286d:	50                   	push   %eax
8010286e:	68 f7 01 00 00       	push   $0x1f7
80102873:	e8 49 fd ff ff       	call   801025c1 <outb>
80102878:	83 c4 10             	add    $0x10,%esp
  }
}
8010287b:	90                   	nop
8010287c:	c9                   	leave  
8010287d:	c3                   	ret    

8010287e <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
8010287e:	55                   	push   %ebp
8010287f:	89 e5                	mov    %esp,%ebp
80102881:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  // First queued buffer is the active request.
  acquire(&idelock);
80102884:	83 ec 0c             	sub    $0xc,%esp
80102887:	68 e0 b5 10 80       	push   $0x8010b5e0
8010288c:	e8 dc 26 00 00       	call   80104f6d <acquire>
80102891:	83 c4 10             	add    $0x10,%esp

  if((b = idequeue) == 0){
80102894:	a1 14 b6 10 80       	mov    0x8010b614,%eax
80102899:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010289c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801028a0:	75 15                	jne    801028b7 <ideintr+0x39>
    release(&idelock);
801028a2:	83 ec 0c             	sub    $0xc,%esp
801028a5:	68 e0 b5 10 80       	push   $0x8010b5e0
801028aa:	e8 2c 27 00 00       	call   80104fdb <release>
801028af:	83 c4 10             	add    $0x10,%esp
    return;
801028b2:	e9 9a 00 00 00       	jmp    80102951 <ideintr+0xd3>
  }
  idequeue = b->qnext;
801028b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028ba:	8b 40 58             	mov    0x58(%eax),%eax
801028bd:	a3 14 b6 10 80       	mov    %eax,0x8010b614

  // Read data if needed.
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
801028c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028c5:	8b 00                	mov    (%eax),%eax
801028c7:	83 e0 04             	and    $0x4,%eax
801028ca:	85 c0                	test   %eax,%eax
801028cc:	75 2d                	jne    801028fb <ideintr+0x7d>
801028ce:	83 ec 0c             	sub    $0xc,%esp
801028d1:	6a 01                	push   $0x1
801028d3:	e8 2e fd ff ff       	call   80102606 <idewait>
801028d8:	83 c4 10             	add    $0x10,%esp
801028db:	85 c0                	test   %eax,%eax
801028dd:	78 1c                	js     801028fb <ideintr+0x7d>
    insl(0x1f0, b->data, BSIZE/4);
801028df:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028e2:	83 c0 5c             	add    $0x5c,%eax
801028e5:	83 ec 04             	sub    $0x4,%esp
801028e8:	68 80 00 00 00       	push   $0x80
801028ed:	50                   	push   %eax
801028ee:	68 f0 01 00 00       	push   $0x1f0
801028f3:	e8 a3 fc ff ff       	call   8010259b <insl>
801028f8:	83 c4 10             	add    $0x10,%esp

  // Wake process waiting for this buf.
  b->flags |= B_VALID;
801028fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028fe:	8b 00                	mov    (%eax),%eax
80102900:	83 c8 02             	or     $0x2,%eax
80102903:	89 c2                	mov    %eax,%edx
80102905:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102908:	89 10                	mov    %edx,(%eax)
  b->flags &= ~B_DIRTY;
8010290a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010290d:	8b 00                	mov    (%eax),%eax
8010290f:	83 e0 fb             	and    $0xfffffffb,%eax
80102912:	89 c2                	mov    %eax,%edx
80102914:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102917:	89 10                	mov    %edx,(%eax)
  wakeup(b);
80102919:	83 ec 0c             	sub    $0xc,%esp
8010291c:	ff 75 f4             	pushl  -0xc(%ebp)
8010291f:	e8 10 23 00 00       	call   80104c34 <wakeup>
80102924:	83 c4 10             	add    $0x10,%esp

  // Start disk on next buf in queue.
  if(idequeue != 0)
80102927:	a1 14 b6 10 80       	mov    0x8010b614,%eax
8010292c:	85 c0                	test   %eax,%eax
8010292e:	74 11                	je     80102941 <ideintr+0xc3>
    idestart(idequeue);
80102930:	a1 14 b6 10 80       	mov    0x8010b614,%eax
80102935:	83 ec 0c             	sub    $0xc,%esp
80102938:	50                   	push   %eax
80102939:	e8 ae fd ff ff       	call   801026ec <idestart>
8010293e:	83 c4 10             	add    $0x10,%esp

  release(&idelock);
80102941:	83 ec 0c             	sub    $0xc,%esp
80102944:	68 e0 b5 10 80       	push   $0x8010b5e0
80102949:	e8 8d 26 00 00       	call   80104fdb <release>
8010294e:	83 c4 10             	add    $0x10,%esp
}
80102951:	c9                   	leave  
80102952:	c3                   	ret    

80102953 <iderw>:
// Sync buf with disk.
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
80102953:	55                   	push   %ebp
80102954:	89 e5                	mov    %esp,%ebp
80102956:	83 ec 18             	sub    $0x18,%esp
  struct buf **pp;

  if(!holdingsleep(&b->lock))
80102959:	8b 45 08             	mov    0x8(%ebp),%eax
8010295c:	83 c0 0c             	add    $0xc,%eax
8010295f:	83 ec 0c             	sub    $0xc,%esp
80102962:	50                   	push   %eax
80102963:	e8 74 25 00 00       	call   80104edc <holdingsleep>
80102968:	83 c4 10             	add    $0x10,%esp
8010296b:	85 c0                	test   %eax,%eax
8010296d:	75 0d                	jne    8010297c <iderw+0x29>
    panic("iderw: buf not locked");
8010296f:	83 ec 0c             	sub    $0xc,%esp
80102972:	68 82 87 10 80       	push   $0x80108782
80102977:	e8 24 dc ff ff       	call   801005a0 <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
8010297c:	8b 45 08             	mov    0x8(%ebp),%eax
8010297f:	8b 00                	mov    (%eax),%eax
80102981:	83 e0 06             	and    $0x6,%eax
80102984:	83 f8 02             	cmp    $0x2,%eax
80102987:	75 0d                	jne    80102996 <iderw+0x43>
    panic("iderw: nothing to do");
80102989:	83 ec 0c             	sub    $0xc,%esp
8010298c:	68 98 87 10 80       	push   $0x80108798
80102991:	e8 0a dc ff ff       	call   801005a0 <panic>
  if(b->dev != 0 && !havedisk1)
80102996:	8b 45 08             	mov    0x8(%ebp),%eax
80102999:	8b 40 04             	mov    0x4(%eax),%eax
8010299c:	85 c0                	test   %eax,%eax
8010299e:	74 16                	je     801029b6 <iderw+0x63>
801029a0:	a1 18 b6 10 80       	mov    0x8010b618,%eax
801029a5:	85 c0                	test   %eax,%eax
801029a7:	75 0d                	jne    801029b6 <iderw+0x63>
    panic("iderw: ide disk 1 not present");
801029a9:	83 ec 0c             	sub    $0xc,%esp
801029ac:	68 ad 87 10 80       	push   $0x801087ad
801029b1:	e8 ea db ff ff       	call   801005a0 <panic>

  acquire(&idelock);  //DOC:acquire-lock
801029b6:	83 ec 0c             	sub    $0xc,%esp
801029b9:	68 e0 b5 10 80       	push   $0x8010b5e0
801029be:	e8 aa 25 00 00       	call   80104f6d <acquire>
801029c3:	83 c4 10             	add    $0x10,%esp

  // Append b to idequeue.
  b->qnext = 0;
801029c6:	8b 45 08             	mov    0x8(%ebp),%eax
801029c9:	c7 40 58 00 00 00 00 	movl   $0x0,0x58(%eax)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
801029d0:	c7 45 f4 14 b6 10 80 	movl   $0x8010b614,-0xc(%ebp)
801029d7:	eb 0b                	jmp    801029e4 <iderw+0x91>
801029d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801029dc:	8b 00                	mov    (%eax),%eax
801029de:	83 c0 58             	add    $0x58,%eax
801029e1:	89 45 f4             	mov    %eax,-0xc(%ebp)
801029e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801029e7:	8b 00                	mov    (%eax),%eax
801029e9:	85 c0                	test   %eax,%eax
801029eb:	75 ec                	jne    801029d9 <iderw+0x86>
    ;
  *pp = b;
801029ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
801029f0:	8b 55 08             	mov    0x8(%ebp),%edx
801029f3:	89 10                	mov    %edx,(%eax)

  // Start disk if necessary.
  if(idequeue == b)
801029f5:	a1 14 b6 10 80       	mov    0x8010b614,%eax
801029fa:	3b 45 08             	cmp    0x8(%ebp),%eax
801029fd:	75 23                	jne    80102a22 <iderw+0xcf>
    idestart(b);
801029ff:	83 ec 0c             	sub    $0xc,%esp
80102a02:	ff 75 08             	pushl  0x8(%ebp)
80102a05:	e8 e2 fc ff ff       	call   801026ec <idestart>
80102a0a:	83 c4 10             	add    $0x10,%esp

  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102a0d:	eb 13                	jmp    80102a22 <iderw+0xcf>
    sleep(b, &idelock);
80102a0f:	83 ec 08             	sub    $0x8,%esp
80102a12:	68 e0 b5 10 80       	push   $0x8010b5e0
80102a17:	ff 75 08             	pushl  0x8(%ebp)
80102a1a:	e8 2c 21 00 00       	call   80104b4b <sleep>
80102a1f:	83 c4 10             	add    $0x10,%esp
  // Start disk if necessary.
  if(idequeue == b)
    idestart(b);

  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102a22:	8b 45 08             	mov    0x8(%ebp),%eax
80102a25:	8b 00                	mov    (%eax),%eax
80102a27:	83 e0 06             	and    $0x6,%eax
80102a2a:	83 f8 02             	cmp    $0x2,%eax
80102a2d:	75 e0                	jne    80102a0f <iderw+0xbc>
    sleep(b, &idelock);
  }


  release(&idelock);
80102a2f:	83 ec 0c             	sub    $0xc,%esp
80102a32:	68 e0 b5 10 80       	push   $0x8010b5e0
80102a37:	e8 9f 25 00 00       	call   80104fdb <release>
80102a3c:	83 c4 10             	add    $0x10,%esp
}
80102a3f:	90                   	nop
80102a40:	c9                   	leave  
80102a41:	c3                   	ret    

80102a42 <ioapicread>:
  uint data;
};

static uint
ioapicread(int reg)
{
80102a42:	55                   	push   %ebp
80102a43:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102a45:	a1 b4 36 11 80       	mov    0x801136b4,%eax
80102a4a:	8b 55 08             	mov    0x8(%ebp),%edx
80102a4d:	89 10                	mov    %edx,(%eax)
  return ioapic->data;
80102a4f:	a1 b4 36 11 80       	mov    0x801136b4,%eax
80102a54:	8b 40 10             	mov    0x10(%eax),%eax
}
80102a57:	5d                   	pop    %ebp
80102a58:	c3                   	ret    

80102a59 <ioapicwrite>:

static void
ioapicwrite(int reg, uint data)
{
80102a59:	55                   	push   %ebp
80102a5a:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102a5c:	a1 b4 36 11 80       	mov    0x801136b4,%eax
80102a61:	8b 55 08             	mov    0x8(%ebp),%edx
80102a64:	89 10                	mov    %edx,(%eax)
  ioapic->data = data;
80102a66:	a1 b4 36 11 80       	mov    0x801136b4,%eax
80102a6b:	8b 55 0c             	mov    0xc(%ebp),%edx
80102a6e:	89 50 10             	mov    %edx,0x10(%eax)
}
80102a71:	90                   	nop
80102a72:	5d                   	pop    %ebp
80102a73:	c3                   	ret    

80102a74 <ioapicinit>:

void
ioapicinit(void)
{
80102a74:	55                   	push   %ebp
80102a75:	89 e5                	mov    %esp,%ebp
80102a77:	83 ec 18             	sub    $0x18,%esp
  int i, id, maxintr;

  ioapic = (volatile struct ioapic*)IOAPIC;
80102a7a:	c7 05 b4 36 11 80 00 	movl   $0xfec00000,0x801136b4
80102a81:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
80102a84:	6a 01                	push   $0x1
80102a86:	e8 b7 ff ff ff       	call   80102a42 <ioapicread>
80102a8b:	83 c4 04             	add    $0x4,%esp
80102a8e:	c1 e8 10             	shr    $0x10,%eax
80102a91:	25 ff 00 00 00       	and    $0xff,%eax
80102a96:	89 45 f0             	mov    %eax,-0x10(%ebp)
  id = ioapicread(REG_ID) >> 24;
80102a99:	6a 00                	push   $0x0
80102a9b:	e8 a2 ff ff ff       	call   80102a42 <ioapicread>
80102aa0:	83 c4 04             	add    $0x4,%esp
80102aa3:	c1 e8 18             	shr    $0x18,%eax
80102aa6:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(id != ioapicid)
80102aa9:	0f b6 05 e0 37 11 80 	movzbl 0x801137e0,%eax
80102ab0:	0f b6 c0             	movzbl %al,%eax
80102ab3:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80102ab6:	74 10                	je     80102ac8 <ioapicinit+0x54>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
80102ab8:	83 ec 0c             	sub    $0xc,%esp
80102abb:	68 cc 87 10 80       	push   $0x801087cc
80102ac0:	e8 3b d9 ff ff       	call   80100400 <cprintf>
80102ac5:	83 c4 10             	add    $0x10,%esp

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
80102ac8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102acf:	eb 3f                	jmp    80102b10 <ioapicinit+0x9c>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
80102ad1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ad4:	83 c0 20             	add    $0x20,%eax
80102ad7:	0d 00 00 01 00       	or     $0x10000,%eax
80102adc:	89 c2                	mov    %eax,%edx
80102ade:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ae1:	83 c0 08             	add    $0x8,%eax
80102ae4:	01 c0                	add    %eax,%eax
80102ae6:	83 ec 08             	sub    $0x8,%esp
80102ae9:	52                   	push   %edx
80102aea:	50                   	push   %eax
80102aeb:	e8 69 ff ff ff       	call   80102a59 <ioapicwrite>
80102af0:	83 c4 10             	add    $0x10,%esp
    ioapicwrite(REG_TABLE+2*i+1, 0);
80102af3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102af6:	83 c0 08             	add    $0x8,%eax
80102af9:	01 c0                	add    %eax,%eax
80102afb:	83 c0 01             	add    $0x1,%eax
80102afe:	83 ec 08             	sub    $0x8,%esp
80102b01:	6a 00                	push   $0x0
80102b03:	50                   	push   %eax
80102b04:	e8 50 ff ff ff       	call   80102a59 <ioapicwrite>
80102b09:	83 c4 10             	add    $0x10,%esp
  if(id != ioapicid)
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
80102b0c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102b10:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b13:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80102b16:	7e b9                	jle    80102ad1 <ioapicinit+0x5d>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
    ioapicwrite(REG_TABLE+2*i+1, 0);
  }
}
80102b18:	90                   	nop
80102b19:	c9                   	leave  
80102b1a:	c3                   	ret    

80102b1b <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
80102b1b:	55                   	push   %ebp
80102b1c:	89 e5                	mov    %esp,%ebp
  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
80102b1e:	8b 45 08             	mov    0x8(%ebp),%eax
80102b21:	83 c0 20             	add    $0x20,%eax
80102b24:	89 c2                	mov    %eax,%edx
80102b26:	8b 45 08             	mov    0x8(%ebp),%eax
80102b29:	83 c0 08             	add    $0x8,%eax
80102b2c:	01 c0                	add    %eax,%eax
80102b2e:	52                   	push   %edx
80102b2f:	50                   	push   %eax
80102b30:	e8 24 ff ff ff       	call   80102a59 <ioapicwrite>
80102b35:	83 c4 08             	add    $0x8,%esp
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
80102b38:	8b 45 0c             	mov    0xc(%ebp),%eax
80102b3b:	c1 e0 18             	shl    $0x18,%eax
80102b3e:	89 c2                	mov    %eax,%edx
80102b40:	8b 45 08             	mov    0x8(%ebp),%eax
80102b43:	83 c0 08             	add    $0x8,%eax
80102b46:	01 c0                	add    %eax,%eax
80102b48:	83 c0 01             	add    $0x1,%eax
80102b4b:	52                   	push   %edx
80102b4c:	50                   	push   %eax
80102b4d:	e8 07 ff ff ff       	call   80102a59 <ioapicwrite>
80102b52:	83 c4 08             	add    $0x8,%esp
}
80102b55:	90                   	nop
80102b56:	c9                   	leave  
80102b57:	c3                   	ret    

80102b58 <kinit1>:
// the pages mapped by entrypgdir on free list.
// 2. main() calls kinit2() with the rest of the physical pages
// after installing a full page table that maps them on all cores.
void
kinit1(void *vstart, void *vend)
{
80102b58:	55                   	push   %ebp
80102b59:	89 e5                	mov    %esp,%ebp
80102b5b:	83 ec 08             	sub    $0x8,%esp
  initlock(&kmem.lock, "kmem");
80102b5e:	83 ec 08             	sub    $0x8,%esp
80102b61:	68 fe 87 10 80       	push   $0x801087fe
80102b66:	68 c0 36 11 80       	push   $0x801136c0
80102b6b:	e8 db 23 00 00       	call   80104f4b <initlock>
80102b70:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 0;
80102b73:	c7 05 f4 36 11 80 00 	movl   $0x0,0x801136f4
80102b7a:	00 00 00 
  freerange(vstart, vend);
80102b7d:	83 ec 08             	sub    $0x8,%esp
80102b80:	ff 75 0c             	pushl  0xc(%ebp)
80102b83:	ff 75 08             	pushl  0x8(%ebp)
80102b86:	e8 2a 00 00 00       	call   80102bb5 <freerange>
80102b8b:	83 c4 10             	add    $0x10,%esp
}
80102b8e:	90                   	nop
80102b8f:	c9                   	leave  
80102b90:	c3                   	ret    

80102b91 <kinit2>:

void
kinit2(void *vstart, void *vend)
{
80102b91:	55                   	push   %ebp
80102b92:	89 e5                	mov    %esp,%ebp
80102b94:	83 ec 08             	sub    $0x8,%esp
  freerange(vstart, vend);
80102b97:	83 ec 08             	sub    $0x8,%esp
80102b9a:	ff 75 0c             	pushl  0xc(%ebp)
80102b9d:	ff 75 08             	pushl  0x8(%ebp)
80102ba0:	e8 10 00 00 00       	call   80102bb5 <freerange>
80102ba5:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 1;
80102ba8:	c7 05 f4 36 11 80 01 	movl   $0x1,0x801136f4
80102baf:	00 00 00 
}
80102bb2:	90                   	nop
80102bb3:	c9                   	leave  
80102bb4:	c3                   	ret    

80102bb5 <freerange>:

void
freerange(void *vstart, void *vend)
{
80102bb5:	55                   	push   %ebp
80102bb6:	89 e5                	mov    %esp,%ebp
80102bb8:	83 ec 18             	sub    $0x18,%esp
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
80102bbb:	8b 45 08             	mov    0x8(%ebp),%eax
80102bbe:	05 ff 0f 00 00       	add    $0xfff,%eax
80102bc3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80102bc8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102bcb:	eb 15                	jmp    80102be2 <freerange+0x2d>
    kfree(p);
80102bcd:	83 ec 0c             	sub    $0xc,%esp
80102bd0:	ff 75 f4             	pushl  -0xc(%ebp)
80102bd3:	e8 1a 00 00 00       	call   80102bf2 <kfree>
80102bd8:	83 c4 10             	add    $0x10,%esp
void
freerange(void *vstart, void *vend)
{
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102bdb:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80102be2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102be5:	05 00 10 00 00       	add    $0x1000,%eax
80102bea:	3b 45 0c             	cmp    0xc(%ebp),%eax
80102bed:	76 de                	jbe    80102bcd <freerange+0x18>
    kfree(p);
}
80102bef:	90                   	nop
80102bf0:	c9                   	leave  
80102bf1:	c3                   	ret    

80102bf2 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
80102bf2:	55                   	push   %ebp
80102bf3:	89 e5                	mov    %esp,%ebp
80102bf5:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if((uint)v % PGSIZE || v < end || V2P(v) >= PHYSTOP)
80102bf8:	8b 45 08             	mov    0x8(%ebp),%eax
80102bfb:	25 ff 0f 00 00       	and    $0xfff,%eax
80102c00:	85 c0                	test   %eax,%eax
80102c02:	75 18                	jne    80102c1c <kfree+0x2a>
80102c04:	81 7d 08 74 6a 11 80 	cmpl   $0x80116a74,0x8(%ebp)
80102c0b:	72 0f                	jb     80102c1c <kfree+0x2a>
80102c0d:	8b 45 08             	mov    0x8(%ebp),%eax
80102c10:	05 00 00 00 80       	add    $0x80000000,%eax
80102c15:	3d ff ff ff 0d       	cmp    $0xdffffff,%eax
80102c1a:	76 0d                	jbe    80102c29 <kfree+0x37>
    panic("kfree");
80102c1c:	83 ec 0c             	sub    $0xc,%esp
80102c1f:	68 03 88 10 80       	push   $0x80108803
80102c24:	e8 77 d9 ff ff       	call   801005a0 <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80102c29:	83 ec 04             	sub    $0x4,%esp
80102c2c:	68 00 10 00 00       	push   $0x1000
80102c31:	6a 01                	push   $0x1
80102c33:	ff 75 08             	pushl  0x8(%ebp)
80102c36:	e8 a9 25 00 00       	call   801051e4 <memset>
80102c3b:	83 c4 10             	add    $0x10,%esp

  if(kmem.use_lock)
80102c3e:	a1 f4 36 11 80       	mov    0x801136f4,%eax
80102c43:	85 c0                	test   %eax,%eax
80102c45:	74 10                	je     80102c57 <kfree+0x65>
    acquire(&kmem.lock);
80102c47:	83 ec 0c             	sub    $0xc,%esp
80102c4a:	68 c0 36 11 80       	push   $0x801136c0
80102c4f:	e8 19 23 00 00       	call   80104f6d <acquire>
80102c54:	83 c4 10             	add    $0x10,%esp
  r = (struct run*)v;
80102c57:	8b 45 08             	mov    0x8(%ebp),%eax
80102c5a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  r->next = kmem.freelist;
80102c5d:	8b 15 f8 36 11 80    	mov    0x801136f8,%edx
80102c63:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c66:	89 10                	mov    %edx,(%eax)
  kmem.freelist = r;
80102c68:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c6b:	a3 f8 36 11 80       	mov    %eax,0x801136f8
  if(kmem.use_lock)
80102c70:	a1 f4 36 11 80       	mov    0x801136f4,%eax
80102c75:	85 c0                	test   %eax,%eax
80102c77:	74 10                	je     80102c89 <kfree+0x97>
    release(&kmem.lock);
80102c79:	83 ec 0c             	sub    $0xc,%esp
80102c7c:	68 c0 36 11 80       	push   $0x801136c0
80102c81:	e8 55 23 00 00       	call   80104fdb <release>
80102c86:	83 c4 10             	add    $0x10,%esp
}
80102c89:	90                   	nop
80102c8a:	c9                   	leave  
80102c8b:	c3                   	ret    

80102c8c <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
80102c8c:	55                   	push   %ebp
80102c8d:	89 e5                	mov    %esp,%ebp
80102c8f:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if(kmem.use_lock)
80102c92:	a1 f4 36 11 80       	mov    0x801136f4,%eax
80102c97:	85 c0                	test   %eax,%eax
80102c99:	74 10                	je     80102cab <kalloc+0x1f>
    acquire(&kmem.lock);
80102c9b:	83 ec 0c             	sub    $0xc,%esp
80102c9e:	68 c0 36 11 80       	push   $0x801136c0
80102ca3:	e8 c5 22 00 00       	call   80104f6d <acquire>
80102ca8:	83 c4 10             	add    $0x10,%esp
  r = kmem.freelist;
80102cab:	a1 f8 36 11 80       	mov    0x801136f8,%eax
80102cb0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(r)
80102cb3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102cb7:	74 0a                	je     80102cc3 <kalloc+0x37>
    kmem.freelist = r->next;
80102cb9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102cbc:	8b 00                	mov    (%eax),%eax
80102cbe:	a3 f8 36 11 80       	mov    %eax,0x801136f8
  if(kmem.use_lock)
80102cc3:	a1 f4 36 11 80       	mov    0x801136f4,%eax
80102cc8:	85 c0                	test   %eax,%eax
80102cca:	74 10                	je     80102cdc <kalloc+0x50>
    release(&kmem.lock);
80102ccc:	83 ec 0c             	sub    $0xc,%esp
80102ccf:	68 c0 36 11 80       	push   $0x801136c0
80102cd4:	e8 02 23 00 00       	call   80104fdb <release>
80102cd9:	83 c4 10             	add    $0x10,%esp
  return (char*)r;
80102cdc:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102cdf:	c9                   	leave  
80102ce0:	c3                   	ret    

80102ce1 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80102ce1:	55                   	push   %ebp
80102ce2:	89 e5                	mov    %esp,%ebp
80102ce4:	83 ec 14             	sub    $0x14,%esp
80102ce7:	8b 45 08             	mov    0x8(%ebp),%eax
80102cea:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102cee:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102cf2:	89 c2                	mov    %eax,%edx
80102cf4:	ec                   	in     (%dx),%al
80102cf5:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102cf8:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102cfc:	c9                   	leave  
80102cfd:	c3                   	ret    

80102cfe <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
80102cfe:	55                   	push   %ebp
80102cff:	89 e5                	mov    %esp,%ebp
80102d01:	83 ec 10             	sub    $0x10,%esp
  static uchar *charcode[4] = {
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
80102d04:	6a 64                	push   $0x64
80102d06:	e8 d6 ff ff ff       	call   80102ce1 <inb>
80102d0b:	83 c4 04             	add    $0x4,%esp
80102d0e:	0f b6 c0             	movzbl %al,%eax
80102d11:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((st & KBS_DIB) == 0)
80102d14:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102d17:	83 e0 01             	and    $0x1,%eax
80102d1a:	85 c0                	test   %eax,%eax
80102d1c:	75 0a                	jne    80102d28 <kbdgetc+0x2a>
    return -1;
80102d1e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102d23:	e9 23 01 00 00       	jmp    80102e4b <kbdgetc+0x14d>
  data = inb(KBDATAP);
80102d28:	6a 60                	push   $0x60
80102d2a:	e8 b2 ff ff ff       	call   80102ce1 <inb>
80102d2f:	83 c4 04             	add    $0x4,%esp
80102d32:	0f b6 c0             	movzbl %al,%eax
80102d35:	89 45 fc             	mov    %eax,-0x4(%ebp)

  if(data == 0xE0){
80102d38:	81 7d fc e0 00 00 00 	cmpl   $0xe0,-0x4(%ebp)
80102d3f:	75 17                	jne    80102d58 <kbdgetc+0x5a>
    shift |= E0ESC;
80102d41:	a1 1c b6 10 80       	mov    0x8010b61c,%eax
80102d46:	83 c8 40             	or     $0x40,%eax
80102d49:	a3 1c b6 10 80       	mov    %eax,0x8010b61c
    return 0;
80102d4e:	b8 00 00 00 00       	mov    $0x0,%eax
80102d53:	e9 f3 00 00 00       	jmp    80102e4b <kbdgetc+0x14d>
  } else if(data & 0x80){
80102d58:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102d5b:	25 80 00 00 00       	and    $0x80,%eax
80102d60:	85 c0                	test   %eax,%eax
80102d62:	74 45                	je     80102da9 <kbdgetc+0xab>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
80102d64:	a1 1c b6 10 80       	mov    0x8010b61c,%eax
80102d69:	83 e0 40             	and    $0x40,%eax
80102d6c:	85 c0                	test   %eax,%eax
80102d6e:	75 08                	jne    80102d78 <kbdgetc+0x7a>
80102d70:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102d73:	83 e0 7f             	and    $0x7f,%eax
80102d76:	eb 03                	jmp    80102d7b <kbdgetc+0x7d>
80102d78:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102d7b:	89 45 fc             	mov    %eax,-0x4(%ebp)
    shift &= ~(shiftcode[data] | E0ESC);
80102d7e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102d81:	05 20 90 10 80       	add    $0x80109020,%eax
80102d86:	0f b6 00             	movzbl (%eax),%eax
80102d89:	83 c8 40             	or     $0x40,%eax
80102d8c:	0f b6 c0             	movzbl %al,%eax
80102d8f:	f7 d0                	not    %eax
80102d91:	89 c2                	mov    %eax,%edx
80102d93:	a1 1c b6 10 80       	mov    0x8010b61c,%eax
80102d98:	21 d0                	and    %edx,%eax
80102d9a:	a3 1c b6 10 80       	mov    %eax,0x8010b61c
    return 0;
80102d9f:	b8 00 00 00 00       	mov    $0x0,%eax
80102da4:	e9 a2 00 00 00       	jmp    80102e4b <kbdgetc+0x14d>
  } else if(shift & E0ESC){
80102da9:	a1 1c b6 10 80       	mov    0x8010b61c,%eax
80102dae:	83 e0 40             	and    $0x40,%eax
80102db1:	85 c0                	test   %eax,%eax
80102db3:	74 14                	je     80102dc9 <kbdgetc+0xcb>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
80102db5:	81 4d fc 80 00 00 00 	orl    $0x80,-0x4(%ebp)
    shift &= ~E0ESC;
80102dbc:	a1 1c b6 10 80       	mov    0x8010b61c,%eax
80102dc1:	83 e0 bf             	and    $0xffffffbf,%eax
80102dc4:	a3 1c b6 10 80       	mov    %eax,0x8010b61c
  }

  shift |= shiftcode[data];
80102dc9:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102dcc:	05 20 90 10 80       	add    $0x80109020,%eax
80102dd1:	0f b6 00             	movzbl (%eax),%eax
80102dd4:	0f b6 d0             	movzbl %al,%edx
80102dd7:	a1 1c b6 10 80       	mov    0x8010b61c,%eax
80102ddc:	09 d0                	or     %edx,%eax
80102dde:	a3 1c b6 10 80       	mov    %eax,0x8010b61c
  shift ^= togglecode[data];
80102de3:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102de6:	05 20 91 10 80       	add    $0x80109120,%eax
80102deb:	0f b6 00             	movzbl (%eax),%eax
80102dee:	0f b6 d0             	movzbl %al,%edx
80102df1:	a1 1c b6 10 80       	mov    0x8010b61c,%eax
80102df6:	31 d0                	xor    %edx,%eax
80102df8:	a3 1c b6 10 80       	mov    %eax,0x8010b61c
  c = charcode[shift & (CTL | SHIFT)][data];
80102dfd:	a1 1c b6 10 80       	mov    0x8010b61c,%eax
80102e02:	83 e0 03             	and    $0x3,%eax
80102e05:	8b 14 85 20 95 10 80 	mov    -0x7fef6ae0(,%eax,4),%edx
80102e0c:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102e0f:	01 d0                	add    %edx,%eax
80102e11:	0f b6 00             	movzbl (%eax),%eax
80102e14:	0f b6 c0             	movzbl %al,%eax
80102e17:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(shift & CAPSLOCK){
80102e1a:	a1 1c b6 10 80       	mov    0x8010b61c,%eax
80102e1f:	83 e0 08             	and    $0x8,%eax
80102e22:	85 c0                	test   %eax,%eax
80102e24:	74 22                	je     80102e48 <kbdgetc+0x14a>
    if('a' <= c && c <= 'z')
80102e26:	83 7d f8 60          	cmpl   $0x60,-0x8(%ebp)
80102e2a:	76 0c                	jbe    80102e38 <kbdgetc+0x13a>
80102e2c:	83 7d f8 7a          	cmpl   $0x7a,-0x8(%ebp)
80102e30:	77 06                	ja     80102e38 <kbdgetc+0x13a>
      c += 'A' - 'a';
80102e32:	83 6d f8 20          	subl   $0x20,-0x8(%ebp)
80102e36:	eb 10                	jmp    80102e48 <kbdgetc+0x14a>
    else if('A' <= c && c <= 'Z')
80102e38:	83 7d f8 40          	cmpl   $0x40,-0x8(%ebp)
80102e3c:	76 0a                	jbe    80102e48 <kbdgetc+0x14a>
80102e3e:	83 7d f8 5a          	cmpl   $0x5a,-0x8(%ebp)
80102e42:	77 04                	ja     80102e48 <kbdgetc+0x14a>
      c += 'a' - 'A';
80102e44:	83 45 f8 20          	addl   $0x20,-0x8(%ebp)
  }
  return c;
80102e48:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80102e4b:	c9                   	leave  
80102e4c:	c3                   	ret    

80102e4d <kbdintr>:

void
kbdintr(void)
{
80102e4d:	55                   	push   %ebp
80102e4e:	89 e5                	mov    %esp,%ebp
80102e50:	83 ec 08             	sub    $0x8,%esp
  consoleintr(kbdgetc);
80102e53:	83 ec 0c             	sub    $0xc,%esp
80102e56:	68 fe 2c 10 80       	push   $0x80102cfe
80102e5b:	e8 cc d9 ff ff       	call   8010082c <consoleintr>
80102e60:	83 c4 10             	add    $0x10,%esp
}
80102e63:	90                   	nop
80102e64:	c9                   	leave  
80102e65:	c3                   	ret    

80102e66 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80102e66:	55                   	push   %ebp
80102e67:	89 e5                	mov    %esp,%ebp
80102e69:	83 ec 14             	sub    $0x14,%esp
80102e6c:	8b 45 08             	mov    0x8(%ebp),%eax
80102e6f:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102e73:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102e77:	89 c2                	mov    %eax,%edx
80102e79:	ec                   	in     (%dx),%al
80102e7a:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102e7d:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102e81:	c9                   	leave  
80102e82:	c3                   	ret    

80102e83 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80102e83:	55                   	push   %ebp
80102e84:	89 e5                	mov    %esp,%ebp
80102e86:	83 ec 08             	sub    $0x8,%esp
80102e89:	8b 55 08             	mov    0x8(%ebp),%edx
80102e8c:	8b 45 0c             	mov    0xc(%ebp),%eax
80102e8f:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80102e93:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102e96:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80102e9a:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80102e9e:	ee                   	out    %al,(%dx)
}
80102e9f:	90                   	nop
80102ea0:	c9                   	leave  
80102ea1:	c3                   	ret    

80102ea2 <lapicw>:
volatile uint *lapic;  // Initialized in mp.c

//PAGEBREAK!
static void
lapicw(int index, int value)
{
80102ea2:	55                   	push   %ebp
80102ea3:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
80102ea5:	a1 fc 36 11 80       	mov    0x801136fc,%eax
80102eaa:	8b 55 08             	mov    0x8(%ebp),%edx
80102ead:	c1 e2 02             	shl    $0x2,%edx
80102eb0:	01 c2                	add    %eax,%edx
80102eb2:	8b 45 0c             	mov    0xc(%ebp),%eax
80102eb5:	89 02                	mov    %eax,(%edx)
  lapic[ID];  // wait for write to finish, by reading
80102eb7:	a1 fc 36 11 80       	mov    0x801136fc,%eax
80102ebc:	83 c0 20             	add    $0x20,%eax
80102ebf:	8b 00                	mov    (%eax),%eax
}
80102ec1:	90                   	nop
80102ec2:	5d                   	pop    %ebp
80102ec3:	c3                   	ret    

80102ec4 <lapicinit>:

void
lapicinit(void)
{
80102ec4:	55                   	push   %ebp
80102ec5:	89 e5                	mov    %esp,%ebp
  if(!lapic)
80102ec7:	a1 fc 36 11 80       	mov    0x801136fc,%eax
80102ecc:	85 c0                	test   %eax,%eax
80102ece:	0f 84 0b 01 00 00    	je     80102fdf <lapicinit+0x11b>
    return;

  // Enable local APIC; set spurious interrupt vector.
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
80102ed4:	68 3f 01 00 00       	push   $0x13f
80102ed9:	6a 3c                	push   $0x3c
80102edb:	e8 c2 ff ff ff       	call   80102ea2 <lapicw>
80102ee0:	83 c4 08             	add    $0x8,%esp

  // The timer repeatedly counts down at bus frequency
  // from lapic[TICR] and then issues an interrupt.
  // If xv6 cared more about precise timekeeping,
  // TICR would be calibrated using an external time source.
  lapicw(TDCR, X1);
80102ee3:	6a 0b                	push   $0xb
80102ee5:	68 f8 00 00 00       	push   $0xf8
80102eea:	e8 b3 ff ff ff       	call   80102ea2 <lapicw>
80102eef:	83 c4 08             	add    $0x8,%esp
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
80102ef2:	68 20 00 02 00       	push   $0x20020
80102ef7:	68 c8 00 00 00       	push   $0xc8
80102efc:	e8 a1 ff ff ff       	call   80102ea2 <lapicw>
80102f01:	83 c4 08             	add    $0x8,%esp
  lapicw(TICR, 10000000);
80102f04:	68 80 96 98 00       	push   $0x989680
80102f09:	68 e0 00 00 00       	push   $0xe0
80102f0e:	e8 8f ff ff ff       	call   80102ea2 <lapicw>
80102f13:	83 c4 08             	add    $0x8,%esp

  // Disable logical interrupt lines.
  lapicw(LINT0, MASKED);
80102f16:	68 00 00 01 00       	push   $0x10000
80102f1b:	68 d4 00 00 00       	push   $0xd4
80102f20:	e8 7d ff ff ff       	call   80102ea2 <lapicw>
80102f25:	83 c4 08             	add    $0x8,%esp
  lapicw(LINT1, MASKED);
80102f28:	68 00 00 01 00       	push   $0x10000
80102f2d:	68 d8 00 00 00       	push   $0xd8
80102f32:	e8 6b ff ff ff       	call   80102ea2 <lapicw>
80102f37:	83 c4 08             	add    $0x8,%esp

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
80102f3a:	a1 fc 36 11 80       	mov    0x801136fc,%eax
80102f3f:	83 c0 30             	add    $0x30,%eax
80102f42:	8b 00                	mov    (%eax),%eax
80102f44:	c1 e8 10             	shr    $0x10,%eax
80102f47:	0f b6 c0             	movzbl %al,%eax
80102f4a:	83 f8 03             	cmp    $0x3,%eax
80102f4d:	76 12                	jbe    80102f61 <lapicinit+0x9d>
    lapicw(PCINT, MASKED);
80102f4f:	68 00 00 01 00       	push   $0x10000
80102f54:	68 d0 00 00 00       	push   $0xd0
80102f59:	e8 44 ff ff ff       	call   80102ea2 <lapicw>
80102f5e:	83 c4 08             	add    $0x8,%esp

  // Map error interrupt to IRQ_ERROR.
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
80102f61:	6a 33                	push   $0x33
80102f63:	68 dc 00 00 00       	push   $0xdc
80102f68:	e8 35 ff ff ff       	call   80102ea2 <lapicw>
80102f6d:	83 c4 08             	add    $0x8,%esp

  // Clear error status register (requires back-to-back writes).
  lapicw(ESR, 0);
80102f70:	6a 00                	push   $0x0
80102f72:	68 a0 00 00 00       	push   $0xa0
80102f77:	e8 26 ff ff ff       	call   80102ea2 <lapicw>
80102f7c:	83 c4 08             	add    $0x8,%esp
  lapicw(ESR, 0);
80102f7f:	6a 00                	push   $0x0
80102f81:	68 a0 00 00 00       	push   $0xa0
80102f86:	e8 17 ff ff ff       	call   80102ea2 <lapicw>
80102f8b:	83 c4 08             	add    $0x8,%esp

  // Ack any outstanding interrupts.
  lapicw(EOI, 0);
80102f8e:	6a 00                	push   $0x0
80102f90:	6a 2c                	push   $0x2c
80102f92:	e8 0b ff ff ff       	call   80102ea2 <lapicw>
80102f97:	83 c4 08             	add    $0x8,%esp

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
80102f9a:	6a 00                	push   $0x0
80102f9c:	68 c4 00 00 00       	push   $0xc4
80102fa1:	e8 fc fe ff ff       	call   80102ea2 <lapicw>
80102fa6:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, BCAST | INIT | LEVEL);
80102fa9:	68 00 85 08 00       	push   $0x88500
80102fae:	68 c0 00 00 00       	push   $0xc0
80102fb3:	e8 ea fe ff ff       	call   80102ea2 <lapicw>
80102fb8:	83 c4 08             	add    $0x8,%esp
  while(lapic[ICRLO] & DELIVS)
80102fbb:	90                   	nop
80102fbc:	a1 fc 36 11 80       	mov    0x801136fc,%eax
80102fc1:	05 00 03 00 00       	add    $0x300,%eax
80102fc6:	8b 00                	mov    (%eax),%eax
80102fc8:	25 00 10 00 00       	and    $0x1000,%eax
80102fcd:	85 c0                	test   %eax,%eax
80102fcf:	75 eb                	jne    80102fbc <lapicinit+0xf8>
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
80102fd1:	6a 00                	push   $0x0
80102fd3:	6a 20                	push   $0x20
80102fd5:	e8 c8 fe ff ff       	call   80102ea2 <lapicw>
80102fda:	83 c4 08             	add    $0x8,%esp
80102fdd:	eb 01                	jmp    80102fe0 <lapicinit+0x11c>

void
lapicinit(void)
{
  if(!lapic)
    return;
80102fdf:	90                   	nop
  while(lapic[ICRLO] & DELIVS)
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
}
80102fe0:	c9                   	leave  
80102fe1:	c3                   	ret    

80102fe2 <lapicid>:

int
lapicid(void)
{
80102fe2:	55                   	push   %ebp
80102fe3:	89 e5                	mov    %esp,%ebp
  if (!lapic)
80102fe5:	a1 fc 36 11 80       	mov    0x801136fc,%eax
80102fea:	85 c0                	test   %eax,%eax
80102fec:	75 07                	jne    80102ff5 <lapicid+0x13>
    return 0;
80102fee:	b8 00 00 00 00       	mov    $0x0,%eax
80102ff3:	eb 0d                	jmp    80103002 <lapicid+0x20>
  return lapic[ID] >> 24;
80102ff5:	a1 fc 36 11 80       	mov    0x801136fc,%eax
80102ffa:	83 c0 20             	add    $0x20,%eax
80102ffd:	8b 00                	mov    (%eax),%eax
80102fff:	c1 e8 18             	shr    $0x18,%eax
}
80103002:	5d                   	pop    %ebp
80103003:	c3                   	ret    

80103004 <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
80103004:	55                   	push   %ebp
80103005:	89 e5                	mov    %esp,%ebp
  if(lapic)
80103007:	a1 fc 36 11 80       	mov    0x801136fc,%eax
8010300c:	85 c0                	test   %eax,%eax
8010300e:	74 0c                	je     8010301c <lapiceoi+0x18>
    lapicw(EOI, 0);
80103010:	6a 00                	push   $0x0
80103012:	6a 2c                	push   $0x2c
80103014:	e8 89 fe ff ff       	call   80102ea2 <lapicw>
80103019:	83 c4 08             	add    $0x8,%esp
}
8010301c:	90                   	nop
8010301d:	c9                   	leave  
8010301e:	c3                   	ret    

8010301f <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
8010301f:	55                   	push   %ebp
80103020:	89 e5                	mov    %esp,%ebp
}
80103022:	90                   	nop
80103023:	5d                   	pop    %ebp
80103024:	c3                   	ret    

80103025 <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
80103025:	55                   	push   %ebp
80103026:	89 e5                	mov    %esp,%ebp
80103028:	83 ec 14             	sub    $0x14,%esp
8010302b:	8b 45 08             	mov    0x8(%ebp),%eax
8010302e:	88 45 ec             	mov    %al,-0x14(%ebp)
  ushort *wrv;

  // "The BSP must initialize CMOS shutdown code to 0AH
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(CMOS_PORT, 0xF);  // offset 0xF is shutdown code
80103031:	6a 0f                	push   $0xf
80103033:	6a 70                	push   $0x70
80103035:	e8 49 fe ff ff       	call   80102e83 <outb>
8010303a:	83 c4 08             	add    $0x8,%esp
  outb(CMOS_PORT+1, 0x0A);
8010303d:	6a 0a                	push   $0xa
8010303f:	6a 71                	push   $0x71
80103041:	e8 3d fe ff ff       	call   80102e83 <outb>
80103046:	83 c4 08             	add    $0x8,%esp
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
80103049:	c7 45 f8 67 04 00 80 	movl   $0x80000467,-0x8(%ebp)
  wrv[0] = 0;
80103050:	8b 45 f8             	mov    -0x8(%ebp),%eax
80103053:	66 c7 00 00 00       	movw   $0x0,(%eax)
  wrv[1] = addr >> 4;
80103058:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010305b:	83 c0 02             	add    $0x2,%eax
8010305e:	8b 55 0c             	mov    0xc(%ebp),%edx
80103061:	c1 ea 04             	shr    $0x4,%edx
80103064:	66 89 10             	mov    %dx,(%eax)

  // "Universal startup algorithm."
  // Send INIT (level-triggered) interrupt to reset other CPU.
  lapicw(ICRHI, apicid<<24);
80103067:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
8010306b:	c1 e0 18             	shl    $0x18,%eax
8010306e:	50                   	push   %eax
8010306f:	68 c4 00 00 00       	push   $0xc4
80103074:	e8 29 fe ff ff       	call   80102ea2 <lapicw>
80103079:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
8010307c:	68 00 c5 00 00       	push   $0xc500
80103081:	68 c0 00 00 00       	push   $0xc0
80103086:	e8 17 fe ff ff       	call   80102ea2 <lapicw>
8010308b:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
8010308e:	68 c8 00 00 00       	push   $0xc8
80103093:	e8 87 ff ff ff       	call   8010301f <microdelay>
80103098:	83 c4 04             	add    $0x4,%esp
  lapicw(ICRLO, INIT | LEVEL);
8010309b:	68 00 85 00 00       	push   $0x8500
801030a0:	68 c0 00 00 00       	push   $0xc0
801030a5:	e8 f8 fd ff ff       	call   80102ea2 <lapicw>
801030aa:	83 c4 08             	add    $0x8,%esp
  microdelay(100);    // should be 10ms, but too slow in Bochs!
801030ad:	6a 64                	push   $0x64
801030af:	e8 6b ff ff ff       	call   8010301f <microdelay>
801030b4:	83 c4 04             	add    $0x4,%esp
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
801030b7:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801030be:	eb 3d                	jmp    801030fd <lapicstartap+0xd8>
    lapicw(ICRHI, apicid<<24);
801030c0:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
801030c4:	c1 e0 18             	shl    $0x18,%eax
801030c7:	50                   	push   %eax
801030c8:	68 c4 00 00 00       	push   $0xc4
801030cd:	e8 d0 fd ff ff       	call   80102ea2 <lapicw>
801030d2:	83 c4 08             	add    $0x8,%esp
    lapicw(ICRLO, STARTUP | (addr>>12));
801030d5:	8b 45 0c             	mov    0xc(%ebp),%eax
801030d8:	c1 e8 0c             	shr    $0xc,%eax
801030db:	80 cc 06             	or     $0x6,%ah
801030de:	50                   	push   %eax
801030df:	68 c0 00 00 00       	push   $0xc0
801030e4:	e8 b9 fd ff ff       	call   80102ea2 <lapicw>
801030e9:	83 c4 08             	add    $0x8,%esp
    microdelay(200);
801030ec:	68 c8 00 00 00       	push   $0xc8
801030f1:	e8 29 ff ff ff       	call   8010301f <microdelay>
801030f6:	83 c4 04             	add    $0x4,%esp
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
801030f9:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801030fd:	83 7d fc 01          	cmpl   $0x1,-0x4(%ebp)
80103101:	7e bd                	jle    801030c0 <lapicstartap+0x9b>
    lapicw(ICRHI, apicid<<24);
    lapicw(ICRLO, STARTUP | (addr>>12));
    microdelay(200);
  }
}
80103103:	90                   	nop
80103104:	c9                   	leave  
80103105:	c3                   	ret    

80103106 <cmos_read>:
#define DAY     0x07
#define MONTH   0x08
#define YEAR    0x09

static uint cmos_read(uint reg)
{
80103106:	55                   	push   %ebp
80103107:	89 e5                	mov    %esp,%ebp
  outb(CMOS_PORT,  reg);
80103109:	8b 45 08             	mov    0x8(%ebp),%eax
8010310c:	0f b6 c0             	movzbl %al,%eax
8010310f:	50                   	push   %eax
80103110:	6a 70                	push   $0x70
80103112:	e8 6c fd ff ff       	call   80102e83 <outb>
80103117:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
8010311a:	68 c8 00 00 00       	push   $0xc8
8010311f:	e8 fb fe ff ff       	call   8010301f <microdelay>
80103124:	83 c4 04             	add    $0x4,%esp

  return inb(CMOS_RETURN);
80103127:	6a 71                	push   $0x71
80103129:	e8 38 fd ff ff       	call   80102e66 <inb>
8010312e:	83 c4 04             	add    $0x4,%esp
80103131:	0f b6 c0             	movzbl %al,%eax
}
80103134:	c9                   	leave  
80103135:	c3                   	ret    

80103136 <fill_rtcdate>:

static void fill_rtcdate(struct rtcdate *r)
{
80103136:	55                   	push   %ebp
80103137:	89 e5                	mov    %esp,%ebp
  r->second = cmos_read(SECS);
80103139:	6a 00                	push   $0x0
8010313b:	e8 c6 ff ff ff       	call   80103106 <cmos_read>
80103140:	83 c4 04             	add    $0x4,%esp
80103143:	89 c2                	mov    %eax,%edx
80103145:	8b 45 08             	mov    0x8(%ebp),%eax
80103148:	89 10                	mov    %edx,(%eax)
  r->minute = cmos_read(MINS);
8010314a:	6a 02                	push   $0x2
8010314c:	e8 b5 ff ff ff       	call   80103106 <cmos_read>
80103151:	83 c4 04             	add    $0x4,%esp
80103154:	89 c2                	mov    %eax,%edx
80103156:	8b 45 08             	mov    0x8(%ebp),%eax
80103159:	89 50 04             	mov    %edx,0x4(%eax)
  r->hour   = cmos_read(HOURS);
8010315c:	6a 04                	push   $0x4
8010315e:	e8 a3 ff ff ff       	call   80103106 <cmos_read>
80103163:	83 c4 04             	add    $0x4,%esp
80103166:	89 c2                	mov    %eax,%edx
80103168:	8b 45 08             	mov    0x8(%ebp),%eax
8010316b:	89 50 08             	mov    %edx,0x8(%eax)
  r->day    = cmos_read(DAY);
8010316e:	6a 07                	push   $0x7
80103170:	e8 91 ff ff ff       	call   80103106 <cmos_read>
80103175:	83 c4 04             	add    $0x4,%esp
80103178:	89 c2                	mov    %eax,%edx
8010317a:	8b 45 08             	mov    0x8(%ebp),%eax
8010317d:	89 50 0c             	mov    %edx,0xc(%eax)
  r->month  = cmos_read(MONTH);
80103180:	6a 08                	push   $0x8
80103182:	e8 7f ff ff ff       	call   80103106 <cmos_read>
80103187:	83 c4 04             	add    $0x4,%esp
8010318a:	89 c2                	mov    %eax,%edx
8010318c:	8b 45 08             	mov    0x8(%ebp),%eax
8010318f:	89 50 10             	mov    %edx,0x10(%eax)
  r->year   = cmos_read(YEAR);
80103192:	6a 09                	push   $0x9
80103194:	e8 6d ff ff ff       	call   80103106 <cmos_read>
80103199:	83 c4 04             	add    $0x4,%esp
8010319c:	89 c2                	mov    %eax,%edx
8010319e:	8b 45 08             	mov    0x8(%ebp),%eax
801031a1:	89 50 14             	mov    %edx,0x14(%eax)
}
801031a4:	90                   	nop
801031a5:	c9                   	leave  
801031a6:	c3                   	ret    

801031a7 <cmostime>:

// qemu seems to use 24-hour GWT and the values are BCD encoded
void cmostime(struct rtcdate *r)
{
801031a7:	55                   	push   %ebp
801031a8:	89 e5                	mov    %esp,%ebp
801031aa:	83 ec 48             	sub    $0x48,%esp
  struct rtcdate t1, t2;
  int sb, bcd;

  sb = cmos_read(CMOS_STATB);
801031ad:	6a 0b                	push   $0xb
801031af:	e8 52 ff ff ff       	call   80103106 <cmos_read>
801031b4:	83 c4 04             	add    $0x4,%esp
801031b7:	89 45 f4             	mov    %eax,-0xc(%ebp)

  bcd = (sb & (1 << 2)) == 0;
801031ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
801031bd:	83 e0 04             	and    $0x4,%eax
801031c0:	85 c0                	test   %eax,%eax
801031c2:	0f 94 c0             	sete   %al
801031c5:	0f b6 c0             	movzbl %al,%eax
801031c8:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // make sure CMOS doesn't modify time while we read it
  for(;;) {
    fill_rtcdate(&t1);
801031cb:	8d 45 d8             	lea    -0x28(%ebp),%eax
801031ce:	50                   	push   %eax
801031cf:	e8 62 ff ff ff       	call   80103136 <fill_rtcdate>
801031d4:	83 c4 04             	add    $0x4,%esp
    if(cmos_read(CMOS_STATA) & CMOS_UIP)
801031d7:	6a 0a                	push   $0xa
801031d9:	e8 28 ff ff ff       	call   80103106 <cmos_read>
801031de:	83 c4 04             	add    $0x4,%esp
801031e1:	25 80 00 00 00       	and    $0x80,%eax
801031e6:	85 c0                	test   %eax,%eax
801031e8:	75 27                	jne    80103211 <cmostime+0x6a>
        continue;
    fill_rtcdate(&t2);
801031ea:	8d 45 c0             	lea    -0x40(%ebp),%eax
801031ed:	50                   	push   %eax
801031ee:	e8 43 ff ff ff       	call   80103136 <fill_rtcdate>
801031f3:	83 c4 04             	add    $0x4,%esp
    if(memcmp(&t1, &t2, sizeof(t1)) == 0)
801031f6:	83 ec 04             	sub    $0x4,%esp
801031f9:	6a 18                	push   $0x18
801031fb:	8d 45 c0             	lea    -0x40(%ebp),%eax
801031fe:	50                   	push   %eax
801031ff:	8d 45 d8             	lea    -0x28(%ebp),%eax
80103202:	50                   	push   %eax
80103203:	e8 43 20 00 00       	call   8010524b <memcmp>
80103208:	83 c4 10             	add    $0x10,%esp
8010320b:	85 c0                	test   %eax,%eax
8010320d:	74 05                	je     80103214 <cmostime+0x6d>
8010320f:	eb ba                	jmp    801031cb <cmostime+0x24>

  // make sure CMOS doesn't modify time while we read it
  for(;;) {
    fill_rtcdate(&t1);
    if(cmos_read(CMOS_STATA) & CMOS_UIP)
        continue;
80103211:	90                   	nop
    fill_rtcdate(&t2);
    if(memcmp(&t1, &t2, sizeof(t1)) == 0)
      break;
  }
80103212:	eb b7                	jmp    801031cb <cmostime+0x24>
    fill_rtcdate(&t1);
    if(cmos_read(CMOS_STATA) & CMOS_UIP)
        continue;
    fill_rtcdate(&t2);
    if(memcmp(&t1, &t2, sizeof(t1)) == 0)
      break;
80103214:	90                   	nop
  }

  // convert
  if(bcd) {
80103215:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103219:	0f 84 b4 00 00 00    	je     801032d3 <cmostime+0x12c>
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
8010321f:	8b 45 d8             	mov    -0x28(%ebp),%eax
80103222:	c1 e8 04             	shr    $0x4,%eax
80103225:	89 c2                	mov    %eax,%edx
80103227:	89 d0                	mov    %edx,%eax
80103229:	c1 e0 02             	shl    $0x2,%eax
8010322c:	01 d0                	add    %edx,%eax
8010322e:	01 c0                	add    %eax,%eax
80103230:	89 c2                	mov    %eax,%edx
80103232:	8b 45 d8             	mov    -0x28(%ebp),%eax
80103235:	83 e0 0f             	and    $0xf,%eax
80103238:	01 d0                	add    %edx,%eax
8010323a:	89 45 d8             	mov    %eax,-0x28(%ebp)
    CONV(minute);
8010323d:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103240:	c1 e8 04             	shr    $0x4,%eax
80103243:	89 c2                	mov    %eax,%edx
80103245:	89 d0                	mov    %edx,%eax
80103247:	c1 e0 02             	shl    $0x2,%eax
8010324a:	01 d0                	add    %edx,%eax
8010324c:	01 c0                	add    %eax,%eax
8010324e:	89 c2                	mov    %eax,%edx
80103250:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103253:	83 e0 0f             	and    $0xf,%eax
80103256:	01 d0                	add    %edx,%eax
80103258:	89 45 dc             	mov    %eax,-0x24(%ebp)
    CONV(hour  );
8010325b:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010325e:	c1 e8 04             	shr    $0x4,%eax
80103261:	89 c2                	mov    %eax,%edx
80103263:	89 d0                	mov    %edx,%eax
80103265:	c1 e0 02             	shl    $0x2,%eax
80103268:	01 d0                	add    %edx,%eax
8010326a:	01 c0                	add    %eax,%eax
8010326c:	89 c2                	mov    %eax,%edx
8010326e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103271:	83 e0 0f             	and    $0xf,%eax
80103274:	01 d0                	add    %edx,%eax
80103276:	89 45 e0             	mov    %eax,-0x20(%ebp)
    CONV(day   );
80103279:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010327c:	c1 e8 04             	shr    $0x4,%eax
8010327f:	89 c2                	mov    %eax,%edx
80103281:	89 d0                	mov    %edx,%eax
80103283:	c1 e0 02             	shl    $0x2,%eax
80103286:	01 d0                	add    %edx,%eax
80103288:	01 c0                	add    %eax,%eax
8010328a:	89 c2                	mov    %eax,%edx
8010328c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010328f:	83 e0 0f             	and    $0xf,%eax
80103292:	01 d0                	add    %edx,%eax
80103294:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    CONV(month );
80103297:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010329a:	c1 e8 04             	shr    $0x4,%eax
8010329d:	89 c2                	mov    %eax,%edx
8010329f:	89 d0                	mov    %edx,%eax
801032a1:	c1 e0 02             	shl    $0x2,%eax
801032a4:	01 d0                	add    %edx,%eax
801032a6:	01 c0                	add    %eax,%eax
801032a8:	89 c2                	mov    %eax,%edx
801032aa:	8b 45 e8             	mov    -0x18(%ebp),%eax
801032ad:	83 e0 0f             	and    $0xf,%eax
801032b0:	01 d0                	add    %edx,%eax
801032b2:	89 45 e8             	mov    %eax,-0x18(%ebp)
    CONV(year  );
801032b5:	8b 45 ec             	mov    -0x14(%ebp),%eax
801032b8:	c1 e8 04             	shr    $0x4,%eax
801032bb:	89 c2                	mov    %eax,%edx
801032bd:	89 d0                	mov    %edx,%eax
801032bf:	c1 e0 02             	shl    $0x2,%eax
801032c2:	01 d0                	add    %edx,%eax
801032c4:	01 c0                	add    %eax,%eax
801032c6:	89 c2                	mov    %eax,%edx
801032c8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801032cb:	83 e0 0f             	and    $0xf,%eax
801032ce:	01 d0                	add    %edx,%eax
801032d0:	89 45 ec             	mov    %eax,-0x14(%ebp)
#undef     CONV
  }

  *r = t1;
801032d3:	8b 45 08             	mov    0x8(%ebp),%eax
801032d6:	8b 55 d8             	mov    -0x28(%ebp),%edx
801032d9:	89 10                	mov    %edx,(%eax)
801032db:	8b 55 dc             	mov    -0x24(%ebp),%edx
801032de:	89 50 04             	mov    %edx,0x4(%eax)
801032e1:	8b 55 e0             	mov    -0x20(%ebp),%edx
801032e4:	89 50 08             	mov    %edx,0x8(%eax)
801032e7:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801032ea:	89 50 0c             	mov    %edx,0xc(%eax)
801032ed:	8b 55 e8             	mov    -0x18(%ebp),%edx
801032f0:	89 50 10             	mov    %edx,0x10(%eax)
801032f3:	8b 55 ec             	mov    -0x14(%ebp),%edx
801032f6:	89 50 14             	mov    %edx,0x14(%eax)
  r->year += 2000;
801032f9:	8b 45 08             	mov    0x8(%ebp),%eax
801032fc:	8b 40 14             	mov    0x14(%eax),%eax
801032ff:	8d 90 d0 07 00 00    	lea    0x7d0(%eax),%edx
80103305:	8b 45 08             	mov    0x8(%ebp),%eax
80103308:	89 50 14             	mov    %edx,0x14(%eax)
}
8010330b:	90                   	nop
8010330c:	c9                   	leave  
8010330d:	c3                   	ret    

8010330e <initlog>:
static void recover_from_log(void);
static void commit();

void
initlog(int dev)
{
8010330e:	55                   	push   %ebp
8010330f:	89 e5                	mov    %esp,%ebp
80103311:	83 ec 28             	sub    $0x28,%esp
  if (sizeof(struct logheader) >= BSIZE)
    panic("initlog: too big logheader");

  struct superblock sb;
  initlock(&log.lock, "log");
80103314:	83 ec 08             	sub    $0x8,%esp
80103317:	68 09 88 10 80       	push   $0x80108809
8010331c:	68 00 37 11 80       	push   $0x80113700
80103321:	e8 25 1c 00 00       	call   80104f4b <initlock>
80103326:	83 c4 10             	add    $0x10,%esp
  readsb(dev, &sb);
80103329:	83 ec 08             	sub    $0x8,%esp
8010332c:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010332f:	50                   	push   %eax
80103330:	ff 75 08             	pushl  0x8(%ebp)
80103333:	e8 a3 e0 ff ff       	call   801013db <readsb>
80103338:	83 c4 10             	add    $0x10,%esp
  log.start = sb.logstart;
8010333b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010333e:	a3 34 37 11 80       	mov    %eax,0x80113734
  log.size = sb.nlog;
80103343:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103346:	a3 38 37 11 80       	mov    %eax,0x80113738
  log.dev = dev;
8010334b:	8b 45 08             	mov    0x8(%ebp),%eax
8010334e:	a3 44 37 11 80       	mov    %eax,0x80113744
  recover_from_log();
80103353:	e8 b2 01 00 00       	call   8010350a <recover_from_log>
}
80103358:	90                   	nop
80103359:	c9                   	leave  
8010335a:	c3                   	ret    

8010335b <install_trans>:

// Copy committed blocks from log to their home location
static void
install_trans(void)
{
8010335b:	55                   	push   %ebp
8010335c:	89 e5                	mov    %esp,%ebp
8010335e:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103361:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103368:	e9 95 00 00 00       	jmp    80103402 <install_trans+0xa7>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
8010336d:	8b 15 34 37 11 80    	mov    0x80113734,%edx
80103373:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103376:	01 d0                	add    %edx,%eax
80103378:	83 c0 01             	add    $0x1,%eax
8010337b:	89 c2                	mov    %eax,%edx
8010337d:	a1 44 37 11 80       	mov    0x80113744,%eax
80103382:	83 ec 08             	sub    $0x8,%esp
80103385:	52                   	push   %edx
80103386:	50                   	push   %eax
80103387:	e8 42 ce ff ff       	call   801001ce <bread>
8010338c:	83 c4 10             	add    $0x10,%esp
8010338f:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
80103392:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103395:	83 c0 10             	add    $0x10,%eax
80103398:	8b 04 85 0c 37 11 80 	mov    -0x7feec8f4(,%eax,4),%eax
8010339f:	89 c2                	mov    %eax,%edx
801033a1:	a1 44 37 11 80       	mov    0x80113744,%eax
801033a6:	83 ec 08             	sub    $0x8,%esp
801033a9:	52                   	push   %edx
801033aa:	50                   	push   %eax
801033ab:	e8 1e ce ff ff       	call   801001ce <bread>
801033b0:	83 c4 10             	add    $0x10,%esp
801033b3:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
801033b6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801033b9:	8d 50 5c             	lea    0x5c(%eax),%edx
801033bc:	8b 45 ec             	mov    -0x14(%ebp),%eax
801033bf:	83 c0 5c             	add    $0x5c,%eax
801033c2:	83 ec 04             	sub    $0x4,%esp
801033c5:	68 00 02 00 00       	push   $0x200
801033ca:	52                   	push   %edx
801033cb:	50                   	push   %eax
801033cc:	e8 d2 1e 00 00       	call   801052a3 <memmove>
801033d1:	83 c4 10             	add    $0x10,%esp
    bwrite(dbuf);  // write dst to disk
801033d4:	83 ec 0c             	sub    $0xc,%esp
801033d7:	ff 75 ec             	pushl  -0x14(%ebp)
801033da:	e8 28 ce ff ff       	call   80100207 <bwrite>
801033df:	83 c4 10             	add    $0x10,%esp
    brelse(lbuf);
801033e2:	83 ec 0c             	sub    $0xc,%esp
801033e5:	ff 75 f0             	pushl  -0x10(%ebp)
801033e8:	e8 63 ce ff ff       	call   80100250 <brelse>
801033ed:	83 c4 10             	add    $0x10,%esp
    brelse(dbuf);
801033f0:	83 ec 0c             	sub    $0xc,%esp
801033f3:	ff 75 ec             	pushl  -0x14(%ebp)
801033f6:	e8 55 ce ff ff       	call   80100250 <brelse>
801033fb:	83 c4 10             	add    $0x10,%esp
static void
install_trans(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
801033fe:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103402:	a1 48 37 11 80       	mov    0x80113748,%eax
80103407:	3b 45 f4             	cmp    -0xc(%ebp),%eax
8010340a:	0f 8f 5d ff ff ff    	jg     8010336d <install_trans+0x12>
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    bwrite(dbuf);  // write dst to disk
    brelse(lbuf);
    brelse(dbuf);
  }
}
80103410:	90                   	nop
80103411:	c9                   	leave  
80103412:	c3                   	ret    

80103413 <read_head>:

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
80103413:	55                   	push   %ebp
80103414:	89 e5                	mov    %esp,%ebp
80103416:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
80103419:	a1 34 37 11 80       	mov    0x80113734,%eax
8010341e:	89 c2                	mov    %eax,%edx
80103420:	a1 44 37 11 80       	mov    0x80113744,%eax
80103425:	83 ec 08             	sub    $0x8,%esp
80103428:	52                   	push   %edx
80103429:	50                   	push   %eax
8010342a:	e8 9f cd ff ff       	call   801001ce <bread>
8010342f:	83 c4 10             	add    $0x10,%esp
80103432:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *lh = (struct logheader *) (buf->data);
80103435:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103438:	83 c0 5c             	add    $0x5c,%eax
8010343b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  log.lh.n = lh->n;
8010343e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103441:	8b 00                	mov    (%eax),%eax
80103443:	a3 48 37 11 80       	mov    %eax,0x80113748
  for (i = 0; i < log.lh.n; i++) {
80103448:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010344f:	eb 1b                	jmp    8010346c <read_head+0x59>
    log.lh.block[i] = lh->block[i];
80103451:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103454:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103457:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
8010345b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010345e:	83 c2 10             	add    $0x10,%edx
80103461:	89 04 95 0c 37 11 80 	mov    %eax,-0x7feec8f4(,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *lh = (struct logheader *) (buf->data);
  int i;
  log.lh.n = lh->n;
  for (i = 0; i < log.lh.n; i++) {
80103468:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010346c:	a1 48 37 11 80       	mov    0x80113748,%eax
80103471:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103474:	7f db                	jg     80103451 <read_head+0x3e>
    log.lh.block[i] = lh->block[i];
  }
  brelse(buf);
80103476:	83 ec 0c             	sub    $0xc,%esp
80103479:	ff 75 f0             	pushl  -0x10(%ebp)
8010347c:	e8 cf cd ff ff       	call   80100250 <brelse>
80103481:	83 c4 10             	add    $0x10,%esp
}
80103484:	90                   	nop
80103485:	c9                   	leave  
80103486:	c3                   	ret    

80103487 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
80103487:	55                   	push   %ebp
80103488:	89 e5                	mov    %esp,%ebp
8010348a:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
8010348d:	a1 34 37 11 80       	mov    0x80113734,%eax
80103492:	89 c2                	mov    %eax,%edx
80103494:	a1 44 37 11 80       	mov    0x80113744,%eax
80103499:	83 ec 08             	sub    $0x8,%esp
8010349c:	52                   	push   %edx
8010349d:	50                   	push   %eax
8010349e:	e8 2b cd ff ff       	call   801001ce <bread>
801034a3:	83 c4 10             	add    $0x10,%esp
801034a6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *hb = (struct logheader *) (buf->data);
801034a9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801034ac:	83 c0 5c             	add    $0x5c,%eax
801034af:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  hb->n = log.lh.n;
801034b2:	8b 15 48 37 11 80    	mov    0x80113748,%edx
801034b8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801034bb:	89 10                	mov    %edx,(%eax)
  for (i = 0; i < log.lh.n; i++) {
801034bd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801034c4:	eb 1b                	jmp    801034e1 <write_head+0x5a>
    hb->block[i] = log.lh.block[i];
801034c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801034c9:	83 c0 10             	add    $0x10,%eax
801034cc:	8b 0c 85 0c 37 11 80 	mov    -0x7feec8f4(,%eax,4),%ecx
801034d3:	8b 45 ec             	mov    -0x14(%ebp),%eax
801034d6:	8b 55 f4             	mov    -0xc(%ebp),%edx
801034d9:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
  for (i = 0; i < log.lh.n; i++) {
801034dd:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801034e1:	a1 48 37 11 80       	mov    0x80113748,%eax
801034e6:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801034e9:	7f db                	jg     801034c6 <write_head+0x3f>
    hb->block[i] = log.lh.block[i];
  }
  bwrite(buf);
801034eb:	83 ec 0c             	sub    $0xc,%esp
801034ee:	ff 75 f0             	pushl  -0x10(%ebp)
801034f1:	e8 11 cd ff ff       	call   80100207 <bwrite>
801034f6:	83 c4 10             	add    $0x10,%esp
  brelse(buf);
801034f9:	83 ec 0c             	sub    $0xc,%esp
801034fc:	ff 75 f0             	pushl  -0x10(%ebp)
801034ff:	e8 4c cd ff ff       	call   80100250 <brelse>
80103504:	83 c4 10             	add    $0x10,%esp
}
80103507:	90                   	nop
80103508:	c9                   	leave  
80103509:	c3                   	ret    

8010350a <recover_from_log>:

static void
recover_from_log(void)
{
8010350a:	55                   	push   %ebp
8010350b:	89 e5                	mov    %esp,%ebp
8010350d:	83 ec 08             	sub    $0x8,%esp
  read_head();
80103510:	e8 fe fe ff ff       	call   80103413 <read_head>
  install_trans(); // if committed, copy from log to disk
80103515:	e8 41 fe ff ff       	call   8010335b <install_trans>
  log.lh.n = 0;
8010351a:	c7 05 48 37 11 80 00 	movl   $0x0,0x80113748
80103521:	00 00 00 
  write_head(); // clear the log
80103524:	e8 5e ff ff ff       	call   80103487 <write_head>
}
80103529:	90                   	nop
8010352a:	c9                   	leave  
8010352b:	c3                   	ret    

8010352c <begin_op>:

// called at the start of each FS system call.
void
begin_op(void)
{
8010352c:	55                   	push   %ebp
8010352d:	89 e5                	mov    %esp,%ebp
8010352f:	83 ec 08             	sub    $0x8,%esp
  acquire(&log.lock);
80103532:	83 ec 0c             	sub    $0xc,%esp
80103535:	68 00 37 11 80       	push   $0x80113700
8010353a:	e8 2e 1a 00 00       	call   80104f6d <acquire>
8010353f:	83 c4 10             	add    $0x10,%esp
  while(1){
    if(log.committing){
80103542:	a1 40 37 11 80       	mov    0x80113740,%eax
80103547:	85 c0                	test   %eax,%eax
80103549:	74 17                	je     80103562 <begin_op+0x36>
      sleep(&log, &log.lock);
8010354b:	83 ec 08             	sub    $0x8,%esp
8010354e:	68 00 37 11 80       	push   $0x80113700
80103553:	68 00 37 11 80       	push   $0x80113700
80103558:	e8 ee 15 00 00       	call   80104b4b <sleep>
8010355d:	83 c4 10             	add    $0x10,%esp
80103560:	eb e0                	jmp    80103542 <begin_op+0x16>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
80103562:	8b 0d 48 37 11 80    	mov    0x80113748,%ecx
80103568:	a1 3c 37 11 80       	mov    0x8011373c,%eax
8010356d:	8d 50 01             	lea    0x1(%eax),%edx
80103570:	89 d0                	mov    %edx,%eax
80103572:	c1 e0 02             	shl    $0x2,%eax
80103575:	01 d0                	add    %edx,%eax
80103577:	01 c0                	add    %eax,%eax
80103579:	01 c8                	add    %ecx,%eax
8010357b:	83 f8 1e             	cmp    $0x1e,%eax
8010357e:	7e 17                	jle    80103597 <begin_op+0x6b>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
80103580:	83 ec 08             	sub    $0x8,%esp
80103583:	68 00 37 11 80       	push   $0x80113700
80103588:	68 00 37 11 80       	push   $0x80113700
8010358d:	e8 b9 15 00 00       	call   80104b4b <sleep>
80103592:	83 c4 10             	add    $0x10,%esp
80103595:	eb ab                	jmp    80103542 <begin_op+0x16>
    } else {
      log.outstanding += 1;
80103597:	a1 3c 37 11 80       	mov    0x8011373c,%eax
8010359c:	83 c0 01             	add    $0x1,%eax
8010359f:	a3 3c 37 11 80       	mov    %eax,0x8011373c
      release(&log.lock);
801035a4:	83 ec 0c             	sub    $0xc,%esp
801035a7:	68 00 37 11 80       	push   $0x80113700
801035ac:	e8 2a 1a 00 00       	call   80104fdb <release>
801035b1:	83 c4 10             	add    $0x10,%esp
      break;
801035b4:	90                   	nop
    }
  }
}
801035b5:	90                   	nop
801035b6:	c9                   	leave  
801035b7:	c3                   	ret    

801035b8 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
801035b8:	55                   	push   %ebp
801035b9:	89 e5                	mov    %esp,%ebp
801035bb:	83 ec 18             	sub    $0x18,%esp
  int do_commit = 0;
801035be:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&log.lock);
801035c5:	83 ec 0c             	sub    $0xc,%esp
801035c8:	68 00 37 11 80       	push   $0x80113700
801035cd:	e8 9b 19 00 00       	call   80104f6d <acquire>
801035d2:	83 c4 10             	add    $0x10,%esp
  log.outstanding -= 1;
801035d5:	a1 3c 37 11 80       	mov    0x8011373c,%eax
801035da:	83 e8 01             	sub    $0x1,%eax
801035dd:	a3 3c 37 11 80       	mov    %eax,0x8011373c
  if(log.committing)
801035e2:	a1 40 37 11 80       	mov    0x80113740,%eax
801035e7:	85 c0                	test   %eax,%eax
801035e9:	74 0d                	je     801035f8 <end_op+0x40>
    panic("log.committing");
801035eb:	83 ec 0c             	sub    $0xc,%esp
801035ee:	68 0d 88 10 80       	push   $0x8010880d
801035f3:	e8 a8 cf ff ff       	call   801005a0 <panic>
  if(log.outstanding == 0){
801035f8:	a1 3c 37 11 80       	mov    0x8011373c,%eax
801035fd:	85 c0                	test   %eax,%eax
801035ff:	75 13                	jne    80103614 <end_op+0x5c>
    do_commit = 1;
80103601:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
    log.committing = 1;
80103608:	c7 05 40 37 11 80 01 	movl   $0x1,0x80113740
8010360f:	00 00 00 
80103612:	eb 10                	jmp    80103624 <end_op+0x6c>
  } else {
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
80103614:	83 ec 0c             	sub    $0xc,%esp
80103617:	68 00 37 11 80       	push   $0x80113700
8010361c:	e8 13 16 00 00       	call   80104c34 <wakeup>
80103621:	83 c4 10             	add    $0x10,%esp
  }
  release(&log.lock);
80103624:	83 ec 0c             	sub    $0xc,%esp
80103627:	68 00 37 11 80       	push   $0x80113700
8010362c:	e8 aa 19 00 00       	call   80104fdb <release>
80103631:	83 c4 10             	add    $0x10,%esp

  if(do_commit){
80103634:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103638:	74 3f                	je     80103679 <end_op+0xc1>
    // call commit w/o holding locks, since not allowed
    // to sleep with locks.
    commit();
8010363a:	e8 f5 00 00 00       	call   80103734 <commit>
    acquire(&log.lock);
8010363f:	83 ec 0c             	sub    $0xc,%esp
80103642:	68 00 37 11 80       	push   $0x80113700
80103647:	e8 21 19 00 00       	call   80104f6d <acquire>
8010364c:	83 c4 10             	add    $0x10,%esp
    log.committing = 0;
8010364f:	c7 05 40 37 11 80 00 	movl   $0x0,0x80113740
80103656:	00 00 00 
    wakeup(&log);
80103659:	83 ec 0c             	sub    $0xc,%esp
8010365c:	68 00 37 11 80       	push   $0x80113700
80103661:	e8 ce 15 00 00       	call   80104c34 <wakeup>
80103666:	83 c4 10             	add    $0x10,%esp
    release(&log.lock);
80103669:	83 ec 0c             	sub    $0xc,%esp
8010366c:	68 00 37 11 80       	push   $0x80113700
80103671:	e8 65 19 00 00       	call   80104fdb <release>
80103676:	83 c4 10             	add    $0x10,%esp
  }
}
80103679:	90                   	nop
8010367a:	c9                   	leave  
8010367b:	c3                   	ret    

8010367c <write_log>:

// Copy modified blocks from cache to log.
static void
write_log(void)
{
8010367c:	55                   	push   %ebp
8010367d:	89 e5                	mov    %esp,%ebp
8010367f:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103682:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103689:	e9 95 00 00 00       	jmp    80103723 <write_log+0xa7>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
8010368e:	8b 15 34 37 11 80    	mov    0x80113734,%edx
80103694:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103697:	01 d0                	add    %edx,%eax
80103699:	83 c0 01             	add    $0x1,%eax
8010369c:	89 c2                	mov    %eax,%edx
8010369e:	a1 44 37 11 80       	mov    0x80113744,%eax
801036a3:	83 ec 08             	sub    $0x8,%esp
801036a6:	52                   	push   %edx
801036a7:	50                   	push   %eax
801036a8:	e8 21 cb ff ff       	call   801001ce <bread>
801036ad:	83 c4 10             	add    $0x10,%esp
801036b0:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
801036b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801036b6:	83 c0 10             	add    $0x10,%eax
801036b9:	8b 04 85 0c 37 11 80 	mov    -0x7feec8f4(,%eax,4),%eax
801036c0:	89 c2                	mov    %eax,%edx
801036c2:	a1 44 37 11 80       	mov    0x80113744,%eax
801036c7:	83 ec 08             	sub    $0x8,%esp
801036ca:	52                   	push   %edx
801036cb:	50                   	push   %eax
801036cc:	e8 fd ca ff ff       	call   801001ce <bread>
801036d1:	83 c4 10             	add    $0x10,%esp
801036d4:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(to->data, from->data, BSIZE);
801036d7:	8b 45 ec             	mov    -0x14(%ebp),%eax
801036da:	8d 50 5c             	lea    0x5c(%eax),%edx
801036dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801036e0:	83 c0 5c             	add    $0x5c,%eax
801036e3:	83 ec 04             	sub    $0x4,%esp
801036e6:	68 00 02 00 00       	push   $0x200
801036eb:	52                   	push   %edx
801036ec:	50                   	push   %eax
801036ed:	e8 b1 1b 00 00       	call   801052a3 <memmove>
801036f2:	83 c4 10             	add    $0x10,%esp
    bwrite(to);  // write the log
801036f5:	83 ec 0c             	sub    $0xc,%esp
801036f8:	ff 75 f0             	pushl  -0x10(%ebp)
801036fb:	e8 07 cb ff ff       	call   80100207 <bwrite>
80103700:	83 c4 10             	add    $0x10,%esp
    brelse(from);
80103703:	83 ec 0c             	sub    $0xc,%esp
80103706:	ff 75 ec             	pushl  -0x14(%ebp)
80103709:	e8 42 cb ff ff       	call   80100250 <brelse>
8010370e:	83 c4 10             	add    $0x10,%esp
    brelse(to);
80103711:	83 ec 0c             	sub    $0xc,%esp
80103714:	ff 75 f0             	pushl  -0x10(%ebp)
80103717:	e8 34 cb ff ff       	call   80100250 <brelse>
8010371c:	83 c4 10             	add    $0x10,%esp
static void
write_log(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
8010371f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103723:	a1 48 37 11 80       	mov    0x80113748,%eax
80103728:	3b 45 f4             	cmp    -0xc(%ebp),%eax
8010372b:	0f 8f 5d ff ff ff    	jg     8010368e <write_log+0x12>
    memmove(to->data, from->data, BSIZE);
    bwrite(to);  // write the log
    brelse(from);
    brelse(to);
  }
}
80103731:	90                   	nop
80103732:	c9                   	leave  
80103733:	c3                   	ret    

80103734 <commit>:

static void
commit()
{
80103734:	55                   	push   %ebp
80103735:	89 e5                	mov    %esp,%ebp
80103737:	83 ec 08             	sub    $0x8,%esp
  if (log.lh.n > 0) {
8010373a:	a1 48 37 11 80       	mov    0x80113748,%eax
8010373f:	85 c0                	test   %eax,%eax
80103741:	7e 1e                	jle    80103761 <commit+0x2d>
    write_log();     // Write modified blocks from cache to log
80103743:	e8 34 ff ff ff       	call   8010367c <write_log>
    write_head();    // Write header to disk -- the real commit
80103748:	e8 3a fd ff ff       	call   80103487 <write_head>
    install_trans(); // Now install writes to home locations
8010374d:	e8 09 fc ff ff       	call   8010335b <install_trans>
    log.lh.n = 0;
80103752:	c7 05 48 37 11 80 00 	movl   $0x0,0x80113748
80103759:	00 00 00 
    write_head();    // Erase the transaction from the log
8010375c:	e8 26 fd ff ff       	call   80103487 <write_head>
  }
}
80103761:	90                   	nop
80103762:	c9                   	leave  
80103763:	c3                   	ret    

80103764 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
80103764:	55                   	push   %ebp
80103765:	89 e5                	mov    %esp,%ebp
80103767:	83 ec 18             	sub    $0x18,%esp
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
8010376a:	a1 48 37 11 80       	mov    0x80113748,%eax
8010376f:	83 f8 1d             	cmp    $0x1d,%eax
80103772:	7f 12                	jg     80103786 <log_write+0x22>
80103774:	a1 48 37 11 80       	mov    0x80113748,%eax
80103779:	8b 15 38 37 11 80    	mov    0x80113738,%edx
8010377f:	83 ea 01             	sub    $0x1,%edx
80103782:	39 d0                	cmp    %edx,%eax
80103784:	7c 0d                	jl     80103793 <log_write+0x2f>
    panic("too big a transaction");
80103786:	83 ec 0c             	sub    $0xc,%esp
80103789:	68 1c 88 10 80       	push   $0x8010881c
8010378e:	e8 0d ce ff ff       	call   801005a0 <panic>
  if (log.outstanding < 1)
80103793:	a1 3c 37 11 80       	mov    0x8011373c,%eax
80103798:	85 c0                	test   %eax,%eax
8010379a:	7f 0d                	jg     801037a9 <log_write+0x45>
    panic("log_write outside of trans");
8010379c:	83 ec 0c             	sub    $0xc,%esp
8010379f:	68 32 88 10 80       	push   $0x80108832
801037a4:	e8 f7 cd ff ff       	call   801005a0 <panic>

  acquire(&log.lock);
801037a9:	83 ec 0c             	sub    $0xc,%esp
801037ac:	68 00 37 11 80       	push   $0x80113700
801037b1:	e8 b7 17 00 00       	call   80104f6d <acquire>
801037b6:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < log.lh.n; i++) {
801037b9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801037c0:	eb 1d                	jmp    801037df <log_write+0x7b>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
801037c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801037c5:	83 c0 10             	add    $0x10,%eax
801037c8:	8b 04 85 0c 37 11 80 	mov    -0x7feec8f4(,%eax,4),%eax
801037cf:	89 c2                	mov    %eax,%edx
801037d1:	8b 45 08             	mov    0x8(%ebp),%eax
801037d4:	8b 40 08             	mov    0x8(%eax),%eax
801037d7:	39 c2                	cmp    %eax,%edx
801037d9:	74 10                	je     801037eb <log_write+0x87>
    panic("too big a transaction");
  if (log.outstanding < 1)
    panic("log_write outside of trans");

  acquire(&log.lock);
  for (i = 0; i < log.lh.n; i++) {
801037db:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801037df:	a1 48 37 11 80       	mov    0x80113748,%eax
801037e4:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801037e7:	7f d9                	jg     801037c2 <log_write+0x5e>
801037e9:	eb 01                	jmp    801037ec <log_write+0x88>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
      break;
801037eb:	90                   	nop
  }
  log.lh.block[i] = b->blockno;
801037ec:	8b 45 08             	mov    0x8(%ebp),%eax
801037ef:	8b 40 08             	mov    0x8(%eax),%eax
801037f2:	89 c2                	mov    %eax,%edx
801037f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801037f7:	83 c0 10             	add    $0x10,%eax
801037fa:	89 14 85 0c 37 11 80 	mov    %edx,-0x7feec8f4(,%eax,4)
  if (i == log.lh.n)
80103801:	a1 48 37 11 80       	mov    0x80113748,%eax
80103806:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103809:	75 0d                	jne    80103818 <log_write+0xb4>
    log.lh.n++;
8010380b:	a1 48 37 11 80       	mov    0x80113748,%eax
80103810:	83 c0 01             	add    $0x1,%eax
80103813:	a3 48 37 11 80       	mov    %eax,0x80113748
  b->flags |= B_DIRTY; // prevent eviction
80103818:	8b 45 08             	mov    0x8(%ebp),%eax
8010381b:	8b 00                	mov    (%eax),%eax
8010381d:	83 c8 04             	or     $0x4,%eax
80103820:	89 c2                	mov    %eax,%edx
80103822:	8b 45 08             	mov    0x8(%ebp),%eax
80103825:	89 10                	mov    %edx,(%eax)
  release(&log.lock);
80103827:	83 ec 0c             	sub    $0xc,%esp
8010382a:	68 00 37 11 80       	push   $0x80113700
8010382f:	e8 a7 17 00 00       	call   80104fdb <release>
80103834:	83 c4 10             	add    $0x10,%esp
}
80103837:	90                   	nop
80103838:	c9                   	leave  
80103839:	c3                   	ret    

8010383a <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
8010383a:	55                   	push   %ebp
8010383b:	89 e5                	mov    %esp,%ebp
8010383d:	83 ec 10             	sub    $0x10,%esp
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80103840:	8b 55 08             	mov    0x8(%ebp),%edx
80103843:	8b 45 0c             	mov    0xc(%ebp),%eax
80103846:	8b 4d 08             	mov    0x8(%ebp),%ecx
80103849:	f0 87 02             	lock xchg %eax,(%edx)
8010384c:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
8010384f:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80103852:	c9                   	leave  
80103853:	c3                   	ret    

80103854 <main>:
// Bootstrap processor starts running C code here.
// Allocate a real stack and switch to it, first
// doing some setup required for memory allocator to work.
int
main(void)
{
80103854:	8d 4c 24 04          	lea    0x4(%esp),%ecx
80103858:	83 e4 f0             	and    $0xfffffff0,%esp
8010385b:	ff 71 fc             	pushl  -0x4(%ecx)
8010385e:	55                   	push   %ebp
8010385f:	89 e5                	mov    %esp,%ebp
80103861:	51                   	push   %ecx
80103862:	83 ec 04             	sub    $0x4,%esp
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
80103865:	83 ec 08             	sub    $0x8,%esp
80103868:	68 00 00 40 80       	push   $0x80400000
8010386d:	68 74 6a 11 80       	push   $0x80116a74
80103872:	e8 e1 f2 ff ff       	call   80102b58 <kinit1>
80103877:	83 c4 10             	add    $0x10,%esp
  kvmalloc();      // kernel page table
8010387a:	e8 b3 43 00 00       	call   80107c32 <kvmalloc>
  mpinit();        // detect other processors
8010387f:	e8 bf 03 00 00       	call   80103c43 <mpinit>
  lapicinit();     // interrupt controller
80103884:	e8 3b f6 ff ff       	call   80102ec4 <lapicinit>
  seginit();       // segment descriptors
80103889:	e8 8f 3e 00 00       	call   8010771d <seginit>
  picinit();       // disable pic
8010388e:	e8 01 05 00 00       	call   80103d94 <picinit>
  ioapicinit();    // another interrupt controller
80103893:	e8 dc f1 ff ff       	call   80102a74 <ioapicinit>
  consoleinit();   // console hardware
80103898:	e8 ae d2 ff ff       	call   80100b4b <consoleinit>
  uartinit();      // serial port
8010389d:	e8 14 32 00 00       	call   80106ab6 <uartinit>
  pinit();         // process table
801038a2:	e8 26 09 00 00       	call   801041cd <pinit>
  shminit();       // shared memory
801038a7:	e8 3e 4c 00 00       	call   801084ea <shminit>
  tvinit();        // trap vectors
801038ac:	e8 66 2d 00 00       	call   80106617 <tvinit>
  binit();         // buffer cache
801038b1:	e8 7e c7 ff ff       	call   80100034 <binit>
  fileinit();      // file table
801038b6:	e8 11 d7 ff ff       	call   80100fcc <fileinit>
  ideinit();       // disk 
801038bb:	e8 8b ed ff ff       	call   8010264b <ideinit>
  startothers();   // start other processors
801038c0:	e8 80 00 00 00       	call   80103945 <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
801038c5:	83 ec 08             	sub    $0x8,%esp
801038c8:	68 00 00 00 8e       	push   $0x8e000000
801038cd:	68 00 00 40 80       	push   $0x80400000
801038d2:	e8 ba f2 ff ff       	call   80102b91 <kinit2>
801038d7:	83 c4 10             	add    $0x10,%esp
  userinit();      // first user process
801038da:	e8 d7 0a 00 00       	call   801043b6 <userinit>
  mpmain();        // finish this processor's setup
801038df:	e8 1a 00 00 00       	call   801038fe <mpmain>

801038e4 <mpenter>:
}

// Other CPUs jump here from entryother.S.
static void
mpenter(void)
{
801038e4:	55                   	push   %ebp
801038e5:	89 e5                	mov    %esp,%ebp
801038e7:	83 ec 08             	sub    $0x8,%esp
  switchkvm();
801038ea:	e8 5b 43 00 00       	call   80107c4a <switchkvm>
  seginit();
801038ef:	e8 29 3e 00 00       	call   8010771d <seginit>
  lapicinit();
801038f4:	e8 cb f5 ff ff       	call   80102ec4 <lapicinit>
  mpmain();
801038f9:	e8 00 00 00 00       	call   801038fe <mpmain>

801038fe <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
801038fe:	55                   	push   %ebp
801038ff:	89 e5                	mov    %esp,%ebp
80103901:	53                   	push   %ebx
80103902:	83 ec 04             	sub    $0x4,%esp
  cprintf("cpu%d: starting %d\n", cpuid(), cpuid());
80103905:	e8 e1 08 00 00       	call   801041eb <cpuid>
8010390a:	89 c3                	mov    %eax,%ebx
8010390c:	e8 da 08 00 00       	call   801041eb <cpuid>
80103911:	83 ec 04             	sub    $0x4,%esp
80103914:	53                   	push   %ebx
80103915:	50                   	push   %eax
80103916:	68 4d 88 10 80       	push   $0x8010884d
8010391b:	e8 e0 ca ff ff       	call   80100400 <cprintf>
80103920:	83 c4 10             	add    $0x10,%esp
  idtinit();       // load idt register
80103923:	e8 65 2e 00 00       	call   8010678d <idtinit>
  xchg(&(mycpu()->started), 1); // tell startothers() we're up
80103928:	e8 df 08 00 00       	call   8010420c <mycpu>
8010392d:	05 a0 00 00 00       	add    $0xa0,%eax
80103932:	83 ec 08             	sub    $0x8,%esp
80103935:	6a 01                	push   $0x1
80103937:	50                   	push   %eax
80103938:	e8 fd fe ff ff       	call   8010383a <xchg>
8010393d:	83 c4 10             	add    $0x10,%esp
  scheduler();     // start running processes
80103940:	e8 10 10 00 00       	call   80104955 <scheduler>

80103945 <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
80103945:	55                   	push   %ebp
80103946:	89 e5                	mov    %esp,%ebp
80103948:	83 ec 18             	sub    $0x18,%esp
  char *stack;

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = P2V(0x7000);
8010394b:	c7 45 f0 00 70 00 80 	movl   $0x80007000,-0x10(%ebp)
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
80103952:	b8 8a 00 00 00       	mov    $0x8a,%eax
80103957:	83 ec 04             	sub    $0x4,%esp
8010395a:	50                   	push   %eax
8010395b:	68 ec b4 10 80       	push   $0x8010b4ec
80103960:	ff 75 f0             	pushl  -0x10(%ebp)
80103963:	e8 3b 19 00 00       	call   801052a3 <memmove>
80103968:	83 c4 10             	add    $0x10,%esp

  for(c = cpus; c < cpus+ncpu; c++){
8010396b:	c7 45 f4 00 38 11 80 	movl   $0x80113800,-0xc(%ebp)
80103972:	eb 79                	jmp    801039ed <startothers+0xa8>
    if(c == mycpu())  // We've started already.
80103974:	e8 93 08 00 00       	call   8010420c <mycpu>
80103979:	3b 45 f4             	cmp    -0xc(%ebp),%eax
8010397c:	74 67                	je     801039e5 <startothers+0xa0>
      continue;

    // Tell entryother.S what stack to use, where to enter, and what
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
8010397e:	e8 09 f3 ff ff       	call   80102c8c <kalloc>
80103983:	89 45 ec             	mov    %eax,-0x14(%ebp)
    *(void**)(code-4) = stack + KSTACKSIZE;
80103986:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103989:	83 e8 04             	sub    $0x4,%eax
8010398c:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010398f:	81 c2 00 10 00 00    	add    $0x1000,%edx
80103995:	89 10                	mov    %edx,(%eax)
    *(void**)(code-8) = mpenter;
80103997:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010399a:	83 e8 08             	sub    $0x8,%eax
8010399d:	c7 00 e4 38 10 80    	movl   $0x801038e4,(%eax)
    *(int**)(code-12) = (void *) V2P(entrypgdir);
801039a3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801039a6:	83 e8 0c             	sub    $0xc,%eax
801039a9:	ba 00 a0 10 80       	mov    $0x8010a000,%edx
801039ae:	81 c2 00 00 00 80    	add    $0x80000000,%edx
801039b4:	89 10                	mov    %edx,(%eax)

    lapicstartap(c->apicid, V2P(code));
801039b6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801039b9:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
801039bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801039c2:	0f b6 00             	movzbl (%eax),%eax
801039c5:	0f b6 c0             	movzbl %al,%eax
801039c8:	83 ec 08             	sub    $0x8,%esp
801039cb:	52                   	push   %edx
801039cc:	50                   	push   %eax
801039cd:	e8 53 f6 ff ff       	call   80103025 <lapicstartap>
801039d2:	83 c4 10             	add    $0x10,%esp

    // wait for cpu to finish mpmain()
    while(c->started == 0)
801039d5:	90                   	nop
801039d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801039d9:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
801039df:	85 c0                	test   %eax,%eax
801039e1:	74 f3                	je     801039d6 <startothers+0x91>
801039e3:	eb 01                	jmp    801039e6 <startothers+0xa1>
  code = P2V(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);

  for(c = cpus; c < cpus+ncpu; c++){
    if(c == mycpu())  // We've started already.
      continue;
801039e5:	90                   	nop
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = P2V(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);

  for(c = cpus; c < cpus+ncpu; c++){
801039e6:	81 45 f4 b0 00 00 00 	addl   $0xb0,-0xc(%ebp)
801039ed:	a1 80 3d 11 80       	mov    0x80113d80,%eax
801039f2:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
801039f8:	05 00 38 11 80       	add    $0x80113800,%eax
801039fd:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103a00:	0f 87 6e ff ff ff    	ja     80103974 <startothers+0x2f>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
      ;
  }
}
80103a06:	90                   	nop
80103a07:	c9                   	leave  
80103a08:	c3                   	ret    

80103a09 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80103a09:	55                   	push   %ebp
80103a0a:	89 e5                	mov    %esp,%ebp
80103a0c:	83 ec 14             	sub    $0x14,%esp
80103a0f:	8b 45 08             	mov    0x8(%ebp),%eax
80103a12:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80103a16:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80103a1a:	89 c2                	mov    %eax,%edx
80103a1c:	ec                   	in     (%dx),%al
80103a1d:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80103a20:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80103a24:	c9                   	leave  
80103a25:	c3                   	ret    

80103a26 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80103a26:	55                   	push   %ebp
80103a27:	89 e5                	mov    %esp,%ebp
80103a29:	83 ec 08             	sub    $0x8,%esp
80103a2c:	8b 55 08             	mov    0x8(%ebp),%edx
80103a2f:	8b 45 0c             	mov    0xc(%ebp),%eax
80103a32:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80103a36:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103a39:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103a3d:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103a41:	ee                   	out    %al,(%dx)
}
80103a42:	90                   	nop
80103a43:	c9                   	leave  
80103a44:	c3                   	ret    

80103a45 <sum>:
int ncpu;
uchar ioapicid;

static uchar
sum(uchar *addr, int len)
{
80103a45:	55                   	push   %ebp
80103a46:	89 e5                	mov    %esp,%ebp
80103a48:	83 ec 10             	sub    $0x10,%esp
  int i, sum;

  sum = 0;
80103a4b:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
  for(i=0; i<len; i++)
80103a52:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80103a59:	eb 15                	jmp    80103a70 <sum+0x2b>
    sum += addr[i];
80103a5b:	8b 55 fc             	mov    -0x4(%ebp),%edx
80103a5e:	8b 45 08             	mov    0x8(%ebp),%eax
80103a61:	01 d0                	add    %edx,%eax
80103a63:	0f b6 00             	movzbl (%eax),%eax
80103a66:	0f b6 c0             	movzbl %al,%eax
80103a69:	01 45 f8             	add    %eax,-0x8(%ebp)
sum(uchar *addr, int len)
{
  int i, sum;

  sum = 0;
  for(i=0; i<len; i++)
80103a6c:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80103a70:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103a73:	3b 45 0c             	cmp    0xc(%ebp),%eax
80103a76:	7c e3                	jl     80103a5b <sum+0x16>
    sum += addr[i];
  return sum;
80103a78:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80103a7b:	c9                   	leave  
80103a7c:	c3                   	ret    

80103a7d <mpsearch1>:

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uint a, int len)
{
80103a7d:	55                   	push   %ebp
80103a7e:	89 e5                	mov    %esp,%ebp
80103a80:	83 ec 18             	sub    $0x18,%esp
  uchar *e, *p, *addr;

  addr = P2V(a);
80103a83:	8b 45 08             	mov    0x8(%ebp),%eax
80103a86:	05 00 00 00 80       	add    $0x80000000,%eax
80103a8b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  e = addr+len;
80103a8e:	8b 55 0c             	mov    0xc(%ebp),%edx
80103a91:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103a94:	01 d0                	add    %edx,%eax
80103a96:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(p = addr; p < e; p += sizeof(struct mp))
80103a99:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103a9c:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103a9f:	eb 36                	jmp    80103ad7 <mpsearch1+0x5a>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
80103aa1:	83 ec 04             	sub    $0x4,%esp
80103aa4:	6a 04                	push   $0x4
80103aa6:	68 64 88 10 80       	push   $0x80108864
80103aab:	ff 75 f4             	pushl  -0xc(%ebp)
80103aae:	e8 98 17 00 00       	call   8010524b <memcmp>
80103ab3:	83 c4 10             	add    $0x10,%esp
80103ab6:	85 c0                	test   %eax,%eax
80103ab8:	75 19                	jne    80103ad3 <mpsearch1+0x56>
80103aba:	83 ec 08             	sub    $0x8,%esp
80103abd:	6a 10                	push   $0x10
80103abf:	ff 75 f4             	pushl  -0xc(%ebp)
80103ac2:	e8 7e ff ff ff       	call   80103a45 <sum>
80103ac7:	83 c4 10             	add    $0x10,%esp
80103aca:	84 c0                	test   %al,%al
80103acc:	75 05                	jne    80103ad3 <mpsearch1+0x56>
      return (struct mp*)p;
80103ace:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ad1:	eb 11                	jmp    80103ae4 <mpsearch1+0x67>
{
  uchar *e, *p, *addr;

  addr = P2V(a);
  e = addr+len;
  for(p = addr; p < e; p += sizeof(struct mp))
80103ad3:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80103ad7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ada:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80103add:	72 c2                	jb     80103aa1 <mpsearch1+0x24>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
      return (struct mp*)p;
  return 0;
80103adf:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103ae4:	c9                   	leave  
80103ae5:	c3                   	ret    

80103ae6 <mpsearch>:
// 1) in the first KB of the EBDA;
// 2) in the last KB of system base memory;
// 3) in the BIOS ROM between 0xE0000 and 0xFFFFF.
static struct mp*
mpsearch(void)
{
80103ae6:	55                   	push   %ebp
80103ae7:	89 e5                	mov    %esp,%ebp
80103ae9:	83 ec 18             	sub    $0x18,%esp
  uchar *bda;
  uint p;
  struct mp *mp;

  bda = (uchar *) P2V(0x400);
80103aec:	c7 45 f4 00 04 00 80 	movl   $0x80000400,-0xc(%ebp)
  if((p = ((bda[0x0F]<<8)| bda[0x0E]) << 4)){
80103af3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103af6:	83 c0 0f             	add    $0xf,%eax
80103af9:	0f b6 00             	movzbl (%eax),%eax
80103afc:	0f b6 c0             	movzbl %al,%eax
80103aff:	c1 e0 08             	shl    $0x8,%eax
80103b02:	89 c2                	mov    %eax,%edx
80103b04:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b07:	83 c0 0e             	add    $0xe,%eax
80103b0a:	0f b6 00             	movzbl (%eax),%eax
80103b0d:	0f b6 c0             	movzbl %al,%eax
80103b10:	09 d0                	or     %edx,%eax
80103b12:	c1 e0 04             	shl    $0x4,%eax
80103b15:	89 45 f0             	mov    %eax,-0x10(%ebp)
80103b18:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103b1c:	74 21                	je     80103b3f <mpsearch+0x59>
    if((mp = mpsearch1(p, 1024)))
80103b1e:	83 ec 08             	sub    $0x8,%esp
80103b21:	68 00 04 00 00       	push   $0x400
80103b26:	ff 75 f0             	pushl  -0x10(%ebp)
80103b29:	e8 4f ff ff ff       	call   80103a7d <mpsearch1>
80103b2e:	83 c4 10             	add    $0x10,%esp
80103b31:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103b34:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103b38:	74 51                	je     80103b8b <mpsearch+0xa5>
      return mp;
80103b3a:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103b3d:	eb 61                	jmp    80103ba0 <mpsearch+0xba>
  } else {
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
80103b3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b42:	83 c0 14             	add    $0x14,%eax
80103b45:	0f b6 00             	movzbl (%eax),%eax
80103b48:	0f b6 c0             	movzbl %al,%eax
80103b4b:	c1 e0 08             	shl    $0x8,%eax
80103b4e:	89 c2                	mov    %eax,%edx
80103b50:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b53:	83 c0 13             	add    $0x13,%eax
80103b56:	0f b6 00             	movzbl (%eax),%eax
80103b59:	0f b6 c0             	movzbl %al,%eax
80103b5c:	09 d0                	or     %edx,%eax
80103b5e:	c1 e0 0a             	shl    $0xa,%eax
80103b61:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((mp = mpsearch1(p-1024, 1024)))
80103b64:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b67:	2d 00 04 00 00       	sub    $0x400,%eax
80103b6c:	83 ec 08             	sub    $0x8,%esp
80103b6f:	68 00 04 00 00       	push   $0x400
80103b74:	50                   	push   %eax
80103b75:	e8 03 ff ff ff       	call   80103a7d <mpsearch1>
80103b7a:	83 c4 10             	add    $0x10,%esp
80103b7d:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103b80:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103b84:	74 05                	je     80103b8b <mpsearch+0xa5>
      return mp;
80103b86:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103b89:	eb 15                	jmp    80103ba0 <mpsearch+0xba>
  }
  return mpsearch1(0xF0000, 0x10000);
80103b8b:	83 ec 08             	sub    $0x8,%esp
80103b8e:	68 00 00 01 00       	push   $0x10000
80103b93:	68 00 00 0f 00       	push   $0xf0000
80103b98:	e8 e0 fe ff ff       	call   80103a7d <mpsearch1>
80103b9d:	83 c4 10             	add    $0x10,%esp
}
80103ba0:	c9                   	leave  
80103ba1:	c3                   	ret    

80103ba2 <mpconfig>:
// Check for correct signature, calculate the checksum and,
// if correct, check the version.
// To do: check extended table checksum.
static struct mpconf*
mpconfig(struct mp **pmp)
{
80103ba2:	55                   	push   %ebp
80103ba3:	89 e5                	mov    %esp,%ebp
80103ba5:	83 ec 18             	sub    $0x18,%esp
  struct mpconf *conf;
  struct mp *mp;

  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
80103ba8:	e8 39 ff ff ff       	call   80103ae6 <mpsearch>
80103bad:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103bb0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103bb4:	74 0a                	je     80103bc0 <mpconfig+0x1e>
80103bb6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bb9:	8b 40 04             	mov    0x4(%eax),%eax
80103bbc:	85 c0                	test   %eax,%eax
80103bbe:	75 07                	jne    80103bc7 <mpconfig+0x25>
    return 0;
80103bc0:	b8 00 00 00 00       	mov    $0x0,%eax
80103bc5:	eb 7a                	jmp    80103c41 <mpconfig+0x9f>
  conf = (struct mpconf*) P2V((uint) mp->physaddr);
80103bc7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bca:	8b 40 04             	mov    0x4(%eax),%eax
80103bcd:	05 00 00 00 80       	add    $0x80000000,%eax
80103bd2:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(memcmp(conf, "PCMP", 4) != 0)
80103bd5:	83 ec 04             	sub    $0x4,%esp
80103bd8:	6a 04                	push   $0x4
80103bda:	68 69 88 10 80       	push   $0x80108869
80103bdf:	ff 75 f0             	pushl  -0x10(%ebp)
80103be2:	e8 64 16 00 00       	call   8010524b <memcmp>
80103be7:	83 c4 10             	add    $0x10,%esp
80103bea:	85 c0                	test   %eax,%eax
80103bec:	74 07                	je     80103bf5 <mpconfig+0x53>
    return 0;
80103bee:	b8 00 00 00 00       	mov    $0x0,%eax
80103bf3:	eb 4c                	jmp    80103c41 <mpconfig+0x9f>
  if(conf->version != 1 && conf->version != 4)
80103bf5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103bf8:	0f b6 40 06          	movzbl 0x6(%eax),%eax
80103bfc:	3c 01                	cmp    $0x1,%al
80103bfe:	74 12                	je     80103c12 <mpconfig+0x70>
80103c00:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c03:	0f b6 40 06          	movzbl 0x6(%eax),%eax
80103c07:	3c 04                	cmp    $0x4,%al
80103c09:	74 07                	je     80103c12 <mpconfig+0x70>
    return 0;
80103c0b:	b8 00 00 00 00       	mov    $0x0,%eax
80103c10:	eb 2f                	jmp    80103c41 <mpconfig+0x9f>
  if(sum((uchar*)conf, conf->length) != 0)
80103c12:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c15:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80103c19:	0f b7 c0             	movzwl %ax,%eax
80103c1c:	83 ec 08             	sub    $0x8,%esp
80103c1f:	50                   	push   %eax
80103c20:	ff 75 f0             	pushl  -0x10(%ebp)
80103c23:	e8 1d fe ff ff       	call   80103a45 <sum>
80103c28:	83 c4 10             	add    $0x10,%esp
80103c2b:	84 c0                	test   %al,%al
80103c2d:	74 07                	je     80103c36 <mpconfig+0x94>
    return 0;
80103c2f:	b8 00 00 00 00       	mov    $0x0,%eax
80103c34:	eb 0b                	jmp    80103c41 <mpconfig+0x9f>
  *pmp = mp;
80103c36:	8b 45 08             	mov    0x8(%ebp),%eax
80103c39:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103c3c:	89 10                	mov    %edx,(%eax)
  return conf;
80103c3e:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80103c41:	c9                   	leave  
80103c42:	c3                   	ret    

80103c43 <mpinit>:

void
mpinit(void)
{
80103c43:	55                   	push   %ebp
80103c44:	89 e5                	mov    %esp,%ebp
80103c46:	83 ec 28             	sub    $0x28,%esp
  struct mp *mp;
  struct mpconf *conf;
  struct mpproc *proc;
  struct mpioapic *ioapic;

  if((conf = mpconfig(&mp)) == 0)
80103c49:	83 ec 0c             	sub    $0xc,%esp
80103c4c:	8d 45 dc             	lea    -0x24(%ebp),%eax
80103c4f:	50                   	push   %eax
80103c50:	e8 4d ff ff ff       	call   80103ba2 <mpconfig>
80103c55:	83 c4 10             	add    $0x10,%esp
80103c58:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103c5b:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103c5f:	75 0d                	jne    80103c6e <mpinit+0x2b>
    panic("Expect to run on an SMP");
80103c61:	83 ec 0c             	sub    $0xc,%esp
80103c64:	68 6e 88 10 80       	push   $0x8010886e
80103c69:	e8 32 c9 ff ff       	call   801005a0 <panic>
  ismp = 1;
80103c6e:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
  lapic = (uint*)conf->lapicaddr;
80103c75:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103c78:	8b 40 24             	mov    0x24(%eax),%eax
80103c7b:	a3 fc 36 11 80       	mov    %eax,0x801136fc
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103c80:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103c83:	83 c0 2c             	add    $0x2c,%eax
80103c86:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103c89:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103c8c:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80103c90:	0f b7 d0             	movzwl %ax,%edx
80103c93:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103c96:	01 d0                	add    %edx,%eax
80103c98:	89 45 e8             	mov    %eax,-0x18(%ebp)
80103c9b:	eb 7b                	jmp    80103d18 <mpinit+0xd5>
    switch(*p){
80103c9d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ca0:	0f b6 00             	movzbl (%eax),%eax
80103ca3:	0f b6 c0             	movzbl %al,%eax
80103ca6:	83 f8 04             	cmp    $0x4,%eax
80103ca9:	77 65                	ja     80103d10 <mpinit+0xcd>
80103cab:	8b 04 85 a8 88 10 80 	mov    -0x7fef7758(,%eax,4),%eax
80103cb2:	ff e0                	jmp    *%eax
    case MPPROC:
      proc = (struct mpproc*)p;
80103cb4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103cb7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      if(ncpu < NCPU) {
80103cba:	a1 80 3d 11 80       	mov    0x80113d80,%eax
80103cbf:	83 f8 07             	cmp    $0x7,%eax
80103cc2:	7f 28                	jg     80103cec <mpinit+0xa9>
        cpus[ncpu].apicid = proc->apicid;  // apicid may differ from ncpu
80103cc4:	8b 15 80 3d 11 80    	mov    0x80113d80,%edx
80103cca:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103ccd:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103cd1:	69 d2 b0 00 00 00    	imul   $0xb0,%edx,%edx
80103cd7:	81 c2 00 38 11 80    	add    $0x80113800,%edx
80103cdd:	88 02                	mov    %al,(%edx)
        ncpu++;
80103cdf:	a1 80 3d 11 80       	mov    0x80113d80,%eax
80103ce4:	83 c0 01             	add    $0x1,%eax
80103ce7:	a3 80 3d 11 80       	mov    %eax,0x80113d80
      }
      p += sizeof(struct mpproc);
80103cec:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
      continue;
80103cf0:	eb 26                	jmp    80103d18 <mpinit+0xd5>
    case MPIOAPIC:
      ioapic = (struct mpioapic*)p;
80103cf2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103cf5:	89 45 e0             	mov    %eax,-0x20(%ebp)
      ioapicid = ioapic->apicno;
80103cf8:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103cfb:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103cff:	a2 e0 37 11 80       	mov    %al,0x801137e0
      p += sizeof(struct mpioapic);
80103d04:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103d08:	eb 0e                	jmp    80103d18 <mpinit+0xd5>
    case MPBUS:
    case MPIOINTR:
    case MPLINTR:
      p += 8;
80103d0a:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103d0e:	eb 08                	jmp    80103d18 <mpinit+0xd5>
    default:
      ismp = 0;
80103d10:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
      break;
80103d17:	90                   	nop

  if((conf = mpconfig(&mp)) == 0)
    panic("Expect to run on an SMP");
  ismp = 1;
  lapic = (uint*)conf->lapicaddr;
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103d18:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d1b:	3b 45 e8             	cmp    -0x18(%ebp),%eax
80103d1e:	0f 82 79 ff ff ff    	jb     80103c9d <mpinit+0x5a>
    default:
      ismp = 0;
      break;
    }
  }
  if(!ismp)
80103d24:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103d28:	75 0d                	jne    80103d37 <mpinit+0xf4>
    panic("Didn't find a suitable machine");
80103d2a:	83 ec 0c             	sub    $0xc,%esp
80103d2d:	68 88 88 10 80       	push   $0x80108888
80103d32:	e8 69 c8 ff ff       	call   801005a0 <panic>

  if(mp->imcrp){
80103d37:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103d3a:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
80103d3e:	84 c0                	test   %al,%al
80103d40:	74 30                	je     80103d72 <mpinit+0x12f>
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
80103d42:	83 ec 08             	sub    $0x8,%esp
80103d45:	6a 70                	push   $0x70
80103d47:	6a 22                	push   $0x22
80103d49:	e8 d8 fc ff ff       	call   80103a26 <outb>
80103d4e:	83 c4 10             	add    $0x10,%esp
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
80103d51:	83 ec 0c             	sub    $0xc,%esp
80103d54:	6a 23                	push   $0x23
80103d56:	e8 ae fc ff ff       	call   80103a09 <inb>
80103d5b:	83 c4 10             	add    $0x10,%esp
80103d5e:	83 c8 01             	or     $0x1,%eax
80103d61:	0f b6 c0             	movzbl %al,%eax
80103d64:	83 ec 08             	sub    $0x8,%esp
80103d67:	50                   	push   %eax
80103d68:	6a 23                	push   $0x23
80103d6a:	e8 b7 fc ff ff       	call   80103a26 <outb>
80103d6f:	83 c4 10             	add    $0x10,%esp
  }
}
80103d72:	90                   	nop
80103d73:	c9                   	leave  
80103d74:	c3                   	ret    

80103d75 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80103d75:	55                   	push   %ebp
80103d76:	89 e5                	mov    %esp,%ebp
80103d78:	83 ec 08             	sub    $0x8,%esp
80103d7b:	8b 55 08             	mov    0x8(%ebp),%edx
80103d7e:	8b 45 0c             	mov    0xc(%ebp),%eax
80103d81:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80103d85:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103d88:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103d8c:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103d90:	ee                   	out    %al,(%dx)
}
80103d91:	90                   	nop
80103d92:	c9                   	leave  
80103d93:	c3                   	ret    

80103d94 <picinit>:
#define IO_PIC2         0xA0    // Slave (IRQs 8-15)

// Don't use the 8259A interrupt controllers.  Xv6 assumes SMP hardware.
void
picinit(void)
{
80103d94:	55                   	push   %ebp
80103d95:	89 e5                	mov    %esp,%ebp
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
80103d97:	68 ff 00 00 00       	push   $0xff
80103d9c:	6a 21                	push   $0x21
80103d9e:	e8 d2 ff ff ff       	call   80103d75 <outb>
80103da3:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, 0xFF);
80103da6:	68 ff 00 00 00       	push   $0xff
80103dab:	68 a1 00 00 00       	push   $0xa1
80103db0:	e8 c0 ff ff ff       	call   80103d75 <outb>
80103db5:	83 c4 08             	add    $0x8,%esp
}
80103db8:	90                   	nop
80103db9:	c9                   	leave  
80103dba:	c3                   	ret    

80103dbb <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
80103dbb:	55                   	push   %ebp
80103dbc:	89 e5                	mov    %esp,%ebp
80103dbe:	83 ec 18             	sub    $0x18,%esp
  struct pipe *p;

  p = 0;
80103dc1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  *f0 = *f1 = 0;
80103dc8:	8b 45 0c             	mov    0xc(%ebp),%eax
80103dcb:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
80103dd1:	8b 45 0c             	mov    0xc(%ebp),%eax
80103dd4:	8b 10                	mov    (%eax),%edx
80103dd6:	8b 45 08             	mov    0x8(%ebp),%eax
80103dd9:	89 10                	mov    %edx,(%eax)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
80103ddb:	e8 0a d2 ff ff       	call   80100fea <filealloc>
80103de0:	89 c2                	mov    %eax,%edx
80103de2:	8b 45 08             	mov    0x8(%ebp),%eax
80103de5:	89 10                	mov    %edx,(%eax)
80103de7:	8b 45 08             	mov    0x8(%ebp),%eax
80103dea:	8b 00                	mov    (%eax),%eax
80103dec:	85 c0                	test   %eax,%eax
80103dee:	0f 84 cb 00 00 00    	je     80103ebf <pipealloc+0x104>
80103df4:	e8 f1 d1 ff ff       	call   80100fea <filealloc>
80103df9:	89 c2                	mov    %eax,%edx
80103dfb:	8b 45 0c             	mov    0xc(%ebp),%eax
80103dfe:	89 10                	mov    %edx,(%eax)
80103e00:	8b 45 0c             	mov    0xc(%ebp),%eax
80103e03:	8b 00                	mov    (%eax),%eax
80103e05:	85 c0                	test   %eax,%eax
80103e07:	0f 84 b2 00 00 00    	je     80103ebf <pipealloc+0x104>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
80103e0d:	e8 7a ee ff ff       	call   80102c8c <kalloc>
80103e12:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103e15:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103e19:	0f 84 9f 00 00 00    	je     80103ebe <pipealloc+0x103>
    goto bad;
  p->readopen = 1;
80103e1f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e22:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
80103e29:	00 00 00 
  p->writeopen = 1;
80103e2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e2f:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
80103e36:	00 00 00 
  p->nwrite = 0;
80103e39:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e3c:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
80103e43:	00 00 00 
  p->nread = 0;
80103e46:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e49:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
80103e50:	00 00 00 
  initlock(&p->lock, "pipe");
80103e53:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e56:	83 ec 08             	sub    $0x8,%esp
80103e59:	68 bc 88 10 80       	push   $0x801088bc
80103e5e:	50                   	push   %eax
80103e5f:	e8 e7 10 00 00       	call   80104f4b <initlock>
80103e64:	83 c4 10             	add    $0x10,%esp
  (*f0)->type = FD_PIPE;
80103e67:	8b 45 08             	mov    0x8(%ebp),%eax
80103e6a:	8b 00                	mov    (%eax),%eax
80103e6c:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
80103e72:	8b 45 08             	mov    0x8(%ebp),%eax
80103e75:	8b 00                	mov    (%eax),%eax
80103e77:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
80103e7b:	8b 45 08             	mov    0x8(%ebp),%eax
80103e7e:	8b 00                	mov    (%eax),%eax
80103e80:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
80103e84:	8b 45 08             	mov    0x8(%ebp),%eax
80103e87:	8b 00                	mov    (%eax),%eax
80103e89:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103e8c:	89 50 0c             	mov    %edx,0xc(%eax)
  (*f1)->type = FD_PIPE;
80103e8f:	8b 45 0c             	mov    0xc(%ebp),%eax
80103e92:	8b 00                	mov    (%eax),%eax
80103e94:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
80103e9a:	8b 45 0c             	mov    0xc(%ebp),%eax
80103e9d:	8b 00                	mov    (%eax),%eax
80103e9f:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
80103ea3:	8b 45 0c             	mov    0xc(%ebp),%eax
80103ea6:	8b 00                	mov    (%eax),%eax
80103ea8:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
80103eac:	8b 45 0c             	mov    0xc(%ebp),%eax
80103eaf:	8b 00                	mov    (%eax),%eax
80103eb1:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103eb4:	89 50 0c             	mov    %edx,0xc(%eax)
  return 0;
80103eb7:	b8 00 00 00 00       	mov    $0x0,%eax
80103ebc:	eb 4e                	jmp    80103f0c <pipealloc+0x151>
  p = 0;
  *f0 = *f1 = 0;
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
    goto bad;
80103ebe:	90                   	nop
  (*f1)->pipe = p;
  return 0;

//PAGEBREAK: 20
 bad:
  if(p)
80103ebf:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103ec3:	74 0e                	je     80103ed3 <pipealloc+0x118>
    kfree((char*)p);
80103ec5:	83 ec 0c             	sub    $0xc,%esp
80103ec8:	ff 75 f4             	pushl  -0xc(%ebp)
80103ecb:	e8 22 ed ff ff       	call   80102bf2 <kfree>
80103ed0:	83 c4 10             	add    $0x10,%esp
  if(*f0)
80103ed3:	8b 45 08             	mov    0x8(%ebp),%eax
80103ed6:	8b 00                	mov    (%eax),%eax
80103ed8:	85 c0                	test   %eax,%eax
80103eda:	74 11                	je     80103eed <pipealloc+0x132>
    fileclose(*f0);
80103edc:	8b 45 08             	mov    0x8(%ebp),%eax
80103edf:	8b 00                	mov    (%eax),%eax
80103ee1:	83 ec 0c             	sub    $0xc,%esp
80103ee4:	50                   	push   %eax
80103ee5:	e8 be d1 ff ff       	call   801010a8 <fileclose>
80103eea:	83 c4 10             	add    $0x10,%esp
  if(*f1)
80103eed:	8b 45 0c             	mov    0xc(%ebp),%eax
80103ef0:	8b 00                	mov    (%eax),%eax
80103ef2:	85 c0                	test   %eax,%eax
80103ef4:	74 11                	je     80103f07 <pipealloc+0x14c>
    fileclose(*f1);
80103ef6:	8b 45 0c             	mov    0xc(%ebp),%eax
80103ef9:	8b 00                	mov    (%eax),%eax
80103efb:	83 ec 0c             	sub    $0xc,%esp
80103efe:	50                   	push   %eax
80103eff:	e8 a4 d1 ff ff       	call   801010a8 <fileclose>
80103f04:	83 c4 10             	add    $0x10,%esp
  return -1;
80103f07:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80103f0c:	c9                   	leave  
80103f0d:	c3                   	ret    

80103f0e <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
80103f0e:	55                   	push   %ebp
80103f0f:	89 e5                	mov    %esp,%ebp
80103f11:	83 ec 08             	sub    $0x8,%esp
  acquire(&p->lock);
80103f14:	8b 45 08             	mov    0x8(%ebp),%eax
80103f17:	83 ec 0c             	sub    $0xc,%esp
80103f1a:	50                   	push   %eax
80103f1b:	e8 4d 10 00 00       	call   80104f6d <acquire>
80103f20:	83 c4 10             	add    $0x10,%esp
  if(writable){
80103f23:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80103f27:	74 23                	je     80103f4c <pipeclose+0x3e>
    p->writeopen = 0;
80103f29:	8b 45 08             	mov    0x8(%ebp),%eax
80103f2c:	c7 80 40 02 00 00 00 	movl   $0x0,0x240(%eax)
80103f33:	00 00 00 
    wakeup(&p->nread);
80103f36:	8b 45 08             	mov    0x8(%ebp),%eax
80103f39:	05 34 02 00 00       	add    $0x234,%eax
80103f3e:	83 ec 0c             	sub    $0xc,%esp
80103f41:	50                   	push   %eax
80103f42:	e8 ed 0c 00 00       	call   80104c34 <wakeup>
80103f47:	83 c4 10             	add    $0x10,%esp
80103f4a:	eb 21                	jmp    80103f6d <pipeclose+0x5f>
  } else {
    p->readopen = 0;
80103f4c:	8b 45 08             	mov    0x8(%ebp),%eax
80103f4f:	c7 80 3c 02 00 00 00 	movl   $0x0,0x23c(%eax)
80103f56:	00 00 00 
    wakeup(&p->nwrite);
80103f59:	8b 45 08             	mov    0x8(%ebp),%eax
80103f5c:	05 38 02 00 00       	add    $0x238,%eax
80103f61:	83 ec 0c             	sub    $0xc,%esp
80103f64:	50                   	push   %eax
80103f65:	e8 ca 0c 00 00       	call   80104c34 <wakeup>
80103f6a:	83 c4 10             	add    $0x10,%esp
  }
  if(p->readopen == 0 && p->writeopen == 0){
80103f6d:	8b 45 08             	mov    0x8(%ebp),%eax
80103f70:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80103f76:	85 c0                	test   %eax,%eax
80103f78:	75 2c                	jne    80103fa6 <pipeclose+0x98>
80103f7a:	8b 45 08             	mov    0x8(%ebp),%eax
80103f7d:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80103f83:	85 c0                	test   %eax,%eax
80103f85:	75 1f                	jne    80103fa6 <pipeclose+0x98>
    release(&p->lock);
80103f87:	8b 45 08             	mov    0x8(%ebp),%eax
80103f8a:	83 ec 0c             	sub    $0xc,%esp
80103f8d:	50                   	push   %eax
80103f8e:	e8 48 10 00 00       	call   80104fdb <release>
80103f93:	83 c4 10             	add    $0x10,%esp
    kfree((char*)p);
80103f96:	83 ec 0c             	sub    $0xc,%esp
80103f99:	ff 75 08             	pushl  0x8(%ebp)
80103f9c:	e8 51 ec ff ff       	call   80102bf2 <kfree>
80103fa1:	83 c4 10             	add    $0x10,%esp
80103fa4:	eb 0f                	jmp    80103fb5 <pipeclose+0xa7>
  } else
    release(&p->lock);
80103fa6:	8b 45 08             	mov    0x8(%ebp),%eax
80103fa9:	83 ec 0c             	sub    $0xc,%esp
80103fac:	50                   	push   %eax
80103fad:	e8 29 10 00 00       	call   80104fdb <release>
80103fb2:	83 c4 10             	add    $0x10,%esp
}
80103fb5:	90                   	nop
80103fb6:	c9                   	leave  
80103fb7:	c3                   	ret    

80103fb8 <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
80103fb8:	55                   	push   %ebp
80103fb9:	89 e5                	mov    %esp,%ebp
80103fbb:	83 ec 18             	sub    $0x18,%esp
  int i;

  acquire(&p->lock);
80103fbe:	8b 45 08             	mov    0x8(%ebp),%eax
80103fc1:	83 ec 0c             	sub    $0xc,%esp
80103fc4:	50                   	push   %eax
80103fc5:	e8 a3 0f 00 00       	call   80104f6d <acquire>
80103fca:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++){
80103fcd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103fd4:	e9 ac 00 00 00       	jmp    80104085 <pipewrite+0xcd>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
      if(p->readopen == 0 || myproc()->killed){
80103fd9:	8b 45 08             	mov    0x8(%ebp),%eax
80103fdc:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80103fe2:	85 c0                	test   %eax,%eax
80103fe4:	74 0c                	je     80103ff2 <pipewrite+0x3a>
80103fe6:	e8 99 02 00 00       	call   80104284 <myproc>
80103feb:	8b 40 2c             	mov    0x2c(%eax),%eax
80103fee:	85 c0                	test   %eax,%eax
80103ff0:	74 19                	je     8010400b <pipewrite+0x53>
        release(&p->lock);
80103ff2:	8b 45 08             	mov    0x8(%ebp),%eax
80103ff5:	83 ec 0c             	sub    $0xc,%esp
80103ff8:	50                   	push   %eax
80103ff9:	e8 dd 0f 00 00       	call   80104fdb <release>
80103ffe:	83 c4 10             	add    $0x10,%esp
        return -1;
80104001:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104006:	e9 a8 00 00 00       	jmp    801040b3 <pipewrite+0xfb>
      }
      wakeup(&p->nread);
8010400b:	8b 45 08             	mov    0x8(%ebp),%eax
8010400e:	05 34 02 00 00       	add    $0x234,%eax
80104013:	83 ec 0c             	sub    $0xc,%esp
80104016:	50                   	push   %eax
80104017:	e8 18 0c 00 00       	call   80104c34 <wakeup>
8010401c:	83 c4 10             	add    $0x10,%esp
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
8010401f:	8b 45 08             	mov    0x8(%ebp),%eax
80104022:	8b 55 08             	mov    0x8(%ebp),%edx
80104025:	81 c2 38 02 00 00    	add    $0x238,%edx
8010402b:	83 ec 08             	sub    $0x8,%esp
8010402e:	50                   	push   %eax
8010402f:	52                   	push   %edx
80104030:	e8 16 0b 00 00       	call   80104b4b <sleep>
80104035:	83 c4 10             	add    $0x10,%esp
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
80104038:	8b 45 08             	mov    0x8(%ebp),%eax
8010403b:	8b 90 38 02 00 00    	mov    0x238(%eax),%edx
80104041:	8b 45 08             	mov    0x8(%ebp),%eax
80104044:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
8010404a:	05 00 02 00 00       	add    $0x200,%eax
8010404f:	39 c2                	cmp    %eax,%edx
80104051:	74 86                	je     80103fd9 <pipewrite+0x21>
        return -1;
      }
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
80104053:	8b 45 08             	mov    0x8(%ebp),%eax
80104056:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
8010405c:	8d 48 01             	lea    0x1(%eax),%ecx
8010405f:	8b 55 08             	mov    0x8(%ebp),%edx
80104062:	89 8a 38 02 00 00    	mov    %ecx,0x238(%edx)
80104068:	25 ff 01 00 00       	and    $0x1ff,%eax
8010406d:	89 c1                	mov    %eax,%ecx
8010406f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104072:	8b 45 0c             	mov    0xc(%ebp),%eax
80104075:	01 d0                	add    %edx,%eax
80104077:	0f b6 10             	movzbl (%eax),%edx
8010407a:	8b 45 08             	mov    0x8(%ebp),%eax
8010407d:	88 54 08 34          	mov    %dl,0x34(%eax,%ecx,1)
pipewrite(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
80104081:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104085:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104088:	3b 45 10             	cmp    0x10(%ebp),%eax
8010408b:	7c ab                	jl     80104038 <pipewrite+0x80>
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
8010408d:	8b 45 08             	mov    0x8(%ebp),%eax
80104090:	05 34 02 00 00       	add    $0x234,%eax
80104095:	83 ec 0c             	sub    $0xc,%esp
80104098:	50                   	push   %eax
80104099:	e8 96 0b 00 00       	call   80104c34 <wakeup>
8010409e:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
801040a1:	8b 45 08             	mov    0x8(%ebp),%eax
801040a4:	83 ec 0c             	sub    $0xc,%esp
801040a7:	50                   	push   %eax
801040a8:	e8 2e 0f 00 00       	call   80104fdb <release>
801040ad:	83 c4 10             	add    $0x10,%esp
  return n;
801040b0:	8b 45 10             	mov    0x10(%ebp),%eax
}
801040b3:	c9                   	leave  
801040b4:	c3                   	ret    

801040b5 <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
801040b5:	55                   	push   %ebp
801040b6:	89 e5                	mov    %esp,%ebp
801040b8:	53                   	push   %ebx
801040b9:	83 ec 14             	sub    $0x14,%esp
  int i;

  acquire(&p->lock);
801040bc:	8b 45 08             	mov    0x8(%ebp),%eax
801040bf:	83 ec 0c             	sub    $0xc,%esp
801040c2:	50                   	push   %eax
801040c3:	e8 a5 0e 00 00       	call   80104f6d <acquire>
801040c8:	83 c4 10             	add    $0x10,%esp
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
801040cb:	eb 3e                	jmp    8010410b <piperead+0x56>
    if(myproc()->killed){
801040cd:	e8 b2 01 00 00       	call   80104284 <myproc>
801040d2:	8b 40 2c             	mov    0x2c(%eax),%eax
801040d5:	85 c0                	test   %eax,%eax
801040d7:	74 19                	je     801040f2 <piperead+0x3d>
      release(&p->lock);
801040d9:	8b 45 08             	mov    0x8(%ebp),%eax
801040dc:	83 ec 0c             	sub    $0xc,%esp
801040df:	50                   	push   %eax
801040e0:	e8 f6 0e 00 00       	call   80104fdb <release>
801040e5:	83 c4 10             	add    $0x10,%esp
      return -1;
801040e8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801040ed:	e9 bf 00 00 00       	jmp    801041b1 <piperead+0xfc>
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
801040f2:	8b 45 08             	mov    0x8(%ebp),%eax
801040f5:	8b 55 08             	mov    0x8(%ebp),%edx
801040f8:	81 c2 34 02 00 00    	add    $0x234,%edx
801040fe:	83 ec 08             	sub    $0x8,%esp
80104101:	50                   	push   %eax
80104102:	52                   	push   %edx
80104103:	e8 43 0a 00 00       	call   80104b4b <sleep>
80104108:	83 c4 10             	add    $0x10,%esp
piperead(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
8010410b:	8b 45 08             	mov    0x8(%ebp),%eax
8010410e:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
80104114:	8b 45 08             	mov    0x8(%ebp),%eax
80104117:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
8010411d:	39 c2                	cmp    %eax,%edx
8010411f:	75 0d                	jne    8010412e <piperead+0x79>
80104121:	8b 45 08             	mov    0x8(%ebp),%eax
80104124:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
8010412a:	85 c0                	test   %eax,%eax
8010412c:	75 9f                	jne    801040cd <piperead+0x18>
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
8010412e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104135:	eb 49                	jmp    80104180 <piperead+0xcb>
    if(p->nread == p->nwrite)
80104137:	8b 45 08             	mov    0x8(%ebp),%eax
8010413a:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
80104140:	8b 45 08             	mov    0x8(%ebp),%eax
80104143:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80104149:	39 c2                	cmp    %eax,%edx
8010414b:	74 3d                	je     8010418a <piperead+0xd5>
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
8010414d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104150:	8b 45 0c             	mov    0xc(%ebp),%eax
80104153:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80104156:	8b 45 08             	mov    0x8(%ebp),%eax
80104159:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
8010415f:	8d 48 01             	lea    0x1(%eax),%ecx
80104162:	8b 55 08             	mov    0x8(%ebp),%edx
80104165:	89 8a 34 02 00 00    	mov    %ecx,0x234(%edx)
8010416b:	25 ff 01 00 00       	and    $0x1ff,%eax
80104170:	89 c2                	mov    %eax,%edx
80104172:	8b 45 08             	mov    0x8(%ebp),%eax
80104175:	0f b6 44 10 34       	movzbl 0x34(%eax,%edx,1),%eax
8010417a:	88 03                	mov    %al,(%ebx)
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
8010417c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104180:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104183:	3b 45 10             	cmp    0x10(%ebp),%eax
80104186:	7c af                	jl     80104137 <piperead+0x82>
80104188:	eb 01                	jmp    8010418b <piperead+0xd6>
    if(p->nread == p->nwrite)
      break;
8010418a:	90                   	nop
    addr[i] = p->data[p->nread++ % PIPESIZE];
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
8010418b:	8b 45 08             	mov    0x8(%ebp),%eax
8010418e:	05 38 02 00 00       	add    $0x238,%eax
80104193:	83 ec 0c             	sub    $0xc,%esp
80104196:	50                   	push   %eax
80104197:	e8 98 0a 00 00       	call   80104c34 <wakeup>
8010419c:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
8010419f:	8b 45 08             	mov    0x8(%ebp),%eax
801041a2:	83 ec 0c             	sub    $0xc,%esp
801041a5:	50                   	push   %eax
801041a6:	e8 30 0e 00 00       	call   80104fdb <release>
801041ab:	83 c4 10             	add    $0x10,%esp
  return i;
801041ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801041b1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801041b4:	c9                   	leave  
801041b5:	c3                   	ret    

801041b6 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
801041b6:	55                   	push   %ebp
801041b7:	89 e5                	mov    %esp,%ebp
801041b9:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
801041bc:	9c                   	pushf  
801041bd:	58                   	pop    %eax
801041be:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
801041c1:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801041c4:	c9                   	leave  
801041c5:	c3                   	ret    

801041c6 <sti>:
  asm volatile("cli");
}

static inline void
sti(void)
{
801041c6:	55                   	push   %ebp
801041c7:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
801041c9:	fb                   	sti    
}
801041ca:	90                   	nop
801041cb:	5d                   	pop    %ebp
801041cc:	c3                   	ret    

801041cd <pinit>:

static void wakeup1(void *chan);

void
pinit(void)
{
801041cd:	55                   	push   %ebp
801041ce:	89 e5                	mov    %esp,%ebp
801041d0:	83 ec 08             	sub    $0x8,%esp
  initlock(&ptable.lock, "ptable");
801041d3:	83 ec 08             	sub    $0x8,%esp
801041d6:	68 c4 88 10 80       	push   $0x801088c4
801041db:	68 a0 3d 11 80       	push   $0x80113da0
801041e0:	e8 66 0d 00 00       	call   80104f4b <initlock>
801041e5:	83 c4 10             	add    $0x10,%esp
}
801041e8:	90                   	nop
801041e9:	c9                   	leave  
801041ea:	c3                   	ret    

801041eb <cpuid>:

// Must be called with interrupts disabled
int
cpuid() {
801041eb:	55                   	push   %ebp
801041ec:	89 e5                	mov    %esp,%ebp
801041ee:	83 ec 08             	sub    $0x8,%esp
  return mycpu()-cpus;
801041f1:	e8 16 00 00 00       	call   8010420c <mycpu>
801041f6:	89 c2                	mov    %eax,%edx
801041f8:	b8 00 38 11 80       	mov    $0x80113800,%eax
801041fd:	29 c2                	sub    %eax,%edx
801041ff:	89 d0                	mov    %edx,%eax
80104201:	c1 f8 04             	sar    $0x4,%eax
80104204:	69 c0 a3 8b 2e ba    	imul   $0xba2e8ba3,%eax,%eax
}
8010420a:	c9                   	leave  
8010420b:	c3                   	ret    

8010420c <mycpu>:

// Must be called with interrupts disabled to avoid the caller being
// rescheduled between reading lapicid and running through the loop.
struct cpu*
mycpu(void)
{
8010420c:	55                   	push   %ebp
8010420d:	89 e5                	mov    %esp,%ebp
8010420f:	83 ec 18             	sub    $0x18,%esp
  int apicid, i;
  
  if(readeflags()&FL_IF)
80104212:	e8 9f ff ff ff       	call   801041b6 <readeflags>
80104217:	25 00 02 00 00       	and    $0x200,%eax
8010421c:	85 c0                	test   %eax,%eax
8010421e:	74 0d                	je     8010422d <mycpu+0x21>
    panic("mycpu called with interrupts enabled\n");
80104220:	83 ec 0c             	sub    $0xc,%esp
80104223:	68 cc 88 10 80       	push   $0x801088cc
80104228:	e8 73 c3 ff ff       	call   801005a0 <panic>
  
  apicid = lapicid();
8010422d:	e8 b0 ed ff ff       	call   80102fe2 <lapicid>
80104232:	89 45 f0             	mov    %eax,-0x10(%ebp)
  // APIC IDs are not guaranteed to be contiguous. Maybe we should have
  // a reverse map, or reserve a register to store &cpus[i].
  for (i = 0; i < ncpu; ++i) {
80104235:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010423c:	eb 2d                	jmp    8010426b <mycpu+0x5f>
    if (cpus[i].apicid == apicid)
8010423e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104241:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
80104247:	05 00 38 11 80       	add    $0x80113800,%eax
8010424c:	0f b6 00             	movzbl (%eax),%eax
8010424f:	0f b6 c0             	movzbl %al,%eax
80104252:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80104255:	75 10                	jne    80104267 <mycpu+0x5b>
      return &cpus[i];
80104257:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010425a:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
80104260:	05 00 38 11 80       	add    $0x80113800,%eax
80104265:	eb 1b                	jmp    80104282 <mycpu+0x76>
    panic("mycpu called with interrupts enabled\n");
  
  apicid = lapicid();
  // APIC IDs are not guaranteed to be contiguous. Maybe we should have
  // a reverse map, or reserve a register to store &cpus[i].
  for (i = 0; i < ncpu; ++i) {
80104267:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010426b:	a1 80 3d 11 80       	mov    0x80113d80,%eax
80104270:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80104273:	7c c9                	jl     8010423e <mycpu+0x32>
    if (cpus[i].apicid == apicid)
      return &cpus[i];
  }
  panic("unknown apicid\n");
80104275:	83 ec 0c             	sub    $0xc,%esp
80104278:	68 f2 88 10 80       	push   $0x801088f2
8010427d:	e8 1e c3 ff ff       	call   801005a0 <panic>
}
80104282:	c9                   	leave  
80104283:	c3                   	ret    

80104284 <myproc>:

// Disable interrupts so that we are not rescheduled
// while reading proc from the cpu structure
struct proc*
myproc(void) {
80104284:	55                   	push   %ebp
80104285:	89 e5                	mov    %esp,%ebp
80104287:	83 ec 18             	sub    $0x18,%esp
  struct cpu *c;
  struct proc *p;
  pushcli();
8010428a:	e8 49 0e 00 00       	call   801050d8 <pushcli>
  c = mycpu();
8010428f:	e8 78 ff ff ff       	call   8010420c <mycpu>
80104294:	89 45 f4             	mov    %eax,-0xc(%ebp)
  p = c->proc;
80104297:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010429a:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
801042a0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  popcli();
801042a3:	e8 7e 0e 00 00       	call   80105126 <popcli>
  return p;
801042a8:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
801042ab:	c9                   	leave  
801042ac:	c3                   	ret    

801042ad <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
801042ad:	55                   	push   %ebp
801042ae:	89 e5                	mov    %esp,%ebp
801042b0:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
801042b3:	83 ec 0c             	sub    $0xc,%esp
801042b6:	68 a0 3d 11 80       	push   $0x80113da0
801042bb:	e8 ad 0c 00 00       	call   80104f6d <acquire>
801042c0:	83 c4 10             	add    $0x10,%esp

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801042c3:	c7 45 f4 d4 3d 11 80 	movl   $0x80113dd4,-0xc(%ebp)
801042ca:	eb 11                	jmp    801042dd <allocproc+0x30>
    if(p->state == UNUSED)
801042cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042cf:	8b 40 14             	mov    0x14(%eax),%eax
801042d2:	85 c0                	test   %eax,%eax
801042d4:	74 2a                	je     80104300 <allocproc+0x53>
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801042d6:	81 45 f4 84 00 00 00 	addl   $0x84,-0xc(%ebp)
801042dd:	81 7d f4 d4 5e 11 80 	cmpl   $0x80115ed4,-0xc(%ebp)
801042e4:	72 e6                	jb     801042cc <allocproc+0x1f>
    if(p->state == UNUSED)
      goto found;

  release(&ptable.lock);
801042e6:	83 ec 0c             	sub    $0xc,%esp
801042e9:	68 a0 3d 11 80       	push   $0x80113da0
801042ee:	e8 e8 0c 00 00       	call   80104fdb <release>
801042f3:	83 c4 10             	add    $0x10,%esp
  return 0;
801042f6:	b8 00 00 00 00       	mov    $0x0,%eax
801042fb:	e9 b4 00 00 00       	jmp    801043b4 <allocproc+0x107>

  acquire(&ptable.lock);

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
    if(p->state == UNUSED)
      goto found;
80104300:	90                   	nop

  release(&ptable.lock);
  return 0;

found:
  p->state = EMBRYO;
80104301:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104304:	c7 40 14 01 00 00 00 	movl   $0x1,0x14(%eax)
  p->pid = nextpid++;
8010430b:	a1 00 b0 10 80       	mov    0x8010b000,%eax
80104310:	8d 50 01             	lea    0x1(%eax),%edx
80104313:	89 15 00 b0 10 80    	mov    %edx,0x8010b000
80104319:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010431c:	89 42 18             	mov    %eax,0x18(%edx)

  release(&ptable.lock);
8010431f:	83 ec 0c             	sub    $0xc,%esp
80104322:	68 a0 3d 11 80       	push   $0x80113da0
80104327:	e8 af 0c 00 00       	call   80104fdb <release>
8010432c:	83 c4 10             	add    $0x10,%esp

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
8010432f:	e8 58 e9 ff ff       	call   80102c8c <kalloc>
80104334:	89 c2                	mov    %eax,%edx
80104336:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104339:	89 50 10             	mov    %edx,0x10(%eax)
8010433c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010433f:	8b 40 10             	mov    0x10(%eax),%eax
80104342:	85 c0                	test   %eax,%eax
80104344:	75 11                	jne    80104357 <allocproc+0xaa>
    p->state = UNUSED;
80104346:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104349:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
    return 0;
80104350:	b8 00 00 00 00       	mov    $0x0,%eax
80104355:	eb 5d                	jmp    801043b4 <allocproc+0x107>
  }
  sp = p->kstack + KSTACKSIZE;
80104357:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010435a:	8b 40 10             	mov    0x10(%eax),%eax
8010435d:	05 00 10 00 00       	add    $0x1000,%eax
80104362:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // Leave room for trap frame.
  sp -= sizeof *p->tf;
80104365:	83 6d f0 4c          	subl   $0x4c,-0x10(%ebp)
  p->tf = (struct trapframe*)sp;
80104369:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010436c:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010436f:	89 50 20             	mov    %edx,0x20(%eax)

  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
80104372:	83 6d f0 04          	subl   $0x4,-0x10(%ebp)
  *(uint*)sp = (uint)trapret;
80104376:	ba d1 65 10 80       	mov    $0x801065d1,%edx
8010437b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010437e:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *p->context;
80104380:	83 6d f0 14          	subl   $0x14,-0x10(%ebp)
  p->context = (struct context*)sp;
80104384:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104387:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010438a:	89 50 24             	mov    %edx,0x24(%eax)
  memset(p->context, 0, sizeof *p->context);
8010438d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104390:	8b 40 24             	mov    0x24(%eax),%eax
80104393:	83 ec 04             	sub    $0x4,%esp
80104396:	6a 14                	push   $0x14
80104398:	6a 00                	push   $0x0
8010439a:	50                   	push   %eax
8010439b:	e8 44 0e 00 00       	call   801051e4 <memset>
801043a0:	83 c4 10             	add    $0x10,%esp
  p->context->eip = (uint)forkret;
801043a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043a6:	8b 40 24             	mov    0x24(%eax),%eax
801043a9:	ba 05 4b 10 80       	mov    $0x80104b05,%edx
801043ae:	89 50 10             	mov    %edx,0x10(%eax)

  return p;
801043b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801043b4:	c9                   	leave  
801043b5:	c3                   	ret    

801043b6 <userinit>:

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
801043b6:	55                   	push   %ebp
801043b7:	89 e5                	mov    %esp,%ebp
801043b9:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];

  p = allocproc();
801043bc:	e8 ec fe ff ff       	call   801042ad <allocproc>
801043c1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  initproc = p;
801043c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043c7:	a3 20 b6 10 80       	mov    %eax,0x8010b620
  if((p->pgdir = setupkvm()) == 0)
801043cc:	e8 c8 37 00 00       	call   80107b99 <setupkvm>
801043d1:	89 c2                	mov    %eax,%edx
801043d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043d6:	89 50 0c             	mov    %edx,0xc(%eax)
801043d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043dc:	8b 40 0c             	mov    0xc(%eax),%eax
801043df:	85 c0                	test   %eax,%eax
801043e1:	75 0d                	jne    801043f0 <userinit+0x3a>
    panic("userinit: out of memory?");
801043e3:	83 ec 0c             	sub    $0xc,%esp
801043e6:	68 02 89 10 80       	push   $0x80108902
801043eb:	e8 b0 c1 ff ff       	call   801005a0 <panic>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
801043f0:	ba 2c 00 00 00       	mov    $0x2c,%edx
801043f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043f8:	8b 40 0c             	mov    0xc(%eax),%eax
801043fb:	83 ec 04             	sub    $0x4,%esp
801043fe:	52                   	push   %edx
801043ff:	68 c0 b4 10 80       	push   $0x8010b4c0
80104404:	50                   	push   %eax
80104405:	e8 f7 39 00 00       	call   80107e01 <inituvm>
8010440a:	83 c4 10             	add    $0x10,%esp
  p->sz = PGSIZE;
8010440d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104410:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  memset(p->tf, 0, sizeof(*p->tf));
80104416:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104419:	8b 40 20             	mov    0x20(%eax),%eax
8010441c:	83 ec 04             	sub    $0x4,%esp
8010441f:	6a 4c                	push   $0x4c
80104421:	6a 00                	push   $0x0
80104423:	50                   	push   %eax
80104424:	e8 bb 0d 00 00       	call   801051e4 <memset>
80104429:	83 c4 10             	add    $0x10,%esp
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
8010442c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010442f:	8b 40 20             	mov    0x20(%eax),%eax
80104432:	66 c7 40 3c 1b 00    	movw   $0x1b,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
80104438:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010443b:	8b 40 20             	mov    0x20(%eax),%eax
8010443e:	66 c7 40 2c 23 00    	movw   $0x23,0x2c(%eax)
  p->tf->es = p->tf->ds;
80104444:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104447:	8b 40 20             	mov    0x20(%eax),%eax
8010444a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010444d:	8b 52 20             	mov    0x20(%edx),%edx
80104450:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80104454:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
80104458:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010445b:	8b 40 20             	mov    0x20(%eax),%eax
8010445e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104461:	8b 52 20             	mov    0x20(%edx),%edx
80104464:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80104468:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
8010446c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010446f:	8b 40 20             	mov    0x20(%eax),%eax
80104472:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
80104479:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010447c:	8b 40 20             	mov    0x20(%eax),%eax
8010447f:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
80104486:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104489:	8b 40 20             	mov    0x20(%eax),%eax
8010448c:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
80104493:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104496:	83 c0 74             	add    $0x74,%eax
80104499:	83 ec 04             	sub    $0x4,%esp
8010449c:	6a 10                	push   $0x10
8010449e:	68 1b 89 10 80       	push   $0x8010891b
801044a3:	50                   	push   %eax
801044a4:	e8 3e 0f 00 00       	call   801053e7 <safestrcpy>
801044a9:	83 c4 10             	add    $0x10,%esp
  p->cwd = namei("/");
801044ac:	83 ec 0c             	sub    $0xc,%esp
801044af:	68 24 89 10 80       	push   $0x80108924
801044b4:	e8 8e e0 ff ff       	call   80102547 <namei>
801044b9:	83 c4 10             	add    $0x10,%esp
801044bc:	89 c2                	mov    %eax,%edx
801044be:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044c1:	89 50 70             	mov    %edx,0x70(%eax)

  // this assignment to p->state lets other cores
  // run this process. the acquire forces the above
  // writes to be visible, and the lock is also needed
  // because the assignment might not be atomic.
  acquire(&ptable.lock);
801044c4:	83 ec 0c             	sub    $0xc,%esp
801044c7:	68 a0 3d 11 80       	push   $0x80113da0
801044cc:	e8 9c 0a 00 00       	call   80104f6d <acquire>
801044d1:	83 c4 10             	add    $0x10,%esp

  p->state = RUNNABLE;
801044d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044d7:	c7 40 14 03 00 00 00 	movl   $0x3,0x14(%eax)

  release(&ptable.lock);
801044de:	83 ec 0c             	sub    $0xc,%esp
801044e1:	68 a0 3d 11 80       	push   $0x80113da0
801044e6:	e8 f0 0a 00 00       	call   80104fdb <release>
801044eb:	83 c4 10             	add    $0x10,%esp
}
801044ee:	90                   	nop
801044ef:	c9                   	leave  
801044f0:	c3                   	ret    

801044f1 <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
801044f1:	55                   	push   %ebp
801044f2:	89 e5                	mov    %esp,%ebp
801044f4:	83 ec 18             	sub    $0x18,%esp
  uint sz;
  struct proc *curproc = myproc();
801044f7:	e8 88 fd ff ff       	call   80104284 <myproc>
801044fc:	89 45 f0             	mov    %eax,-0x10(%ebp)

  sz = curproc->sz;
801044ff:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104502:	8b 00                	mov    (%eax),%eax
80104504:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(n > 0){
80104507:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010450b:	7e 2e                	jle    8010453b <growproc+0x4a>
    if((sz = allocuvm(curproc->pgdir, sz, sz + n)) == 0)
8010450d:	8b 55 08             	mov    0x8(%ebp),%edx
80104510:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104513:	01 c2                	add    %eax,%edx
80104515:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104518:	8b 40 0c             	mov    0xc(%eax),%eax
8010451b:	83 ec 04             	sub    $0x4,%esp
8010451e:	52                   	push   %edx
8010451f:	ff 75 f4             	pushl  -0xc(%ebp)
80104522:	50                   	push   %eax
80104523:	e8 16 3a 00 00       	call   80107f3e <allocuvm>
80104528:	83 c4 10             	add    $0x10,%esp
8010452b:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010452e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104532:	75 3b                	jne    8010456f <growproc+0x7e>
      return -1;
80104534:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104539:	eb 4f                	jmp    8010458a <growproc+0x99>
  } else if(n < 0){
8010453b:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010453f:	79 2e                	jns    8010456f <growproc+0x7e>
    if((sz = deallocuvm(curproc->pgdir, sz, sz + n)) == 0)
80104541:	8b 55 08             	mov    0x8(%ebp),%edx
80104544:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104547:	01 c2                	add    %eax,%edx
80104549:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010454c:	8b 40 0c             	mov    0xc(%eax),%eax
8010454f:	83 ec 04             	sub    $0x4,%esp
80104552:	52                   	push   %edx
80104553:	ff 75 f4             	pushl  -0xc(%ebp)
80104556:	50                   	push   %eax
80104557:	e8 00 3b 00 00       	call   8010805c <deallocuvm>
8010455c:	83 c4 10             	add    $0x10,%esp
8010455f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104562:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104566:	75 07                	jne    8010456f <growproc+0x7e>
      return -1;
80104568:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010456d:	eb 1b                	jmp    8010458a <growproc+0x99>
  }
  curproc->sz = sz;
8010456f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104572:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104575:	89 10                	mov    %edx,(%eax)
  switchuvm(curproc);
80104577:	83 ec 0c             	sub    $0xc,%esp
8010457a:	ff 75 f0             	pushl  -0x10(%ebp)
8010457d:	e8 e1 36 00 00       	call   80107c63 <switchuvm>
80104582:	83 c4 10             	add    $0x10,%esp
  return 0;
80104585:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010458a:	c9                   	leave  
8010458b:	c3                   	ret    

8010458c <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
8010458c:	55                   	push   %ebp
8010458d:	89 e5                	mov    %esp,%ebp
8010458f:	57                   	push   %edi
80104590:	56                   	push   %esi
80104591:	53                   	push   %ebx
80104592:	83 ec 1c             	sub    $0x1c,%esp
  int i, pid;
  struct proc *np;
  struct proc *curproc = myproc();
80104595:	e8 ea fc ff ff       	call   80104284 <myproc>
8010459a:	89 45 e0             	mov    %eax,-0x20(%ebp)

  // Allocate process.
  if((np = allocproc()) == 0){
8010459d:	e8 0b fd ff ff       	call   801042ad <allocproc>
801045a2:	89 45 dc             	mov    %eax,-0x24(%ebp)
801045a5:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
801045a9:	75 0a                	jne    801045b5 <fork+0x29>
    return -1;
801045ab:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801045b0:	e9 55 01 00 00       	jmp    8010470a <fork+0x17e>
  }

  // Copy process state from proc.
  if((np->pgdir = copyuvm(curproc->pgdir, curproc->sz)) == 0){
801045b5:	8b 45 e0             	mov    -0x20(%ebp),%eax
801045b8:	8b 10                	mov    (%eax),%edx
801045ba:	8b 45 e0             	mov    -0x20(%ebp),%eax
801045bd:	8b 40 0c             	mov    0xc(%eax),%eax
801045c0:	83 ec 08             	sub    $0x8,%esp
801045c3:	52                   	push   %edx
801045c4:	50                   	push   %eax
801045c5:	e8 30 3c 00 00       	call   801081fa <copyuvm>
801045ca:	83 c4 10             	add    $0x10,%esp
801045cd:	89 c2                	mov    %eax,%edx
801045cf:	8b 45 dc             	mov    -0x24(%ebp),%eax
801045d2:	89 50 0c             	mov    %edx,0xc(%eax)
801045d5:	8b 45 dc             	mov    -0x24(%ebp),%eax
801045d8:	8b 40 0c             	mov    0xc(%eax),%eax
801045db:	85 c0                	test   %eax,%eax
801045dd:	75 30                	jne    8010460f <fork+0x83>
    kfree(np->kstack);
801045df:	8b 45 dc             	mov    -0x24(%ebp),%eax
801045e2:	8b 40 10             	mov    0x10(%eax),%eax
801045e5:	83 ec 0c             	sub    $0xc,%esp
801045e8:	50                   	push   %eax
801045e9:	e8 04 e6 ff ff       	call   80102bf2 <kfree>
801045ee:	83 c4 10             	add    $0x10,%esp
    np->kstack = 0;
801045f1:	8b 45 dc             	mov    -0x24(%ebp),%eax
801045f4:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
    np->state = UNUSED;
801045fb:	8b 45 dc             	mov    -0x24(%ebp),%eax
801045fe:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
    return -1;
80104605:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010460a:	e9 fb 00 00 00       	jmp    8010470a <fork+0x17e>
  }
  np->sz = curproc->sz;
8010460f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104612:	8b 10                	mov    (%eax),%edx
80104614:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104617:	89 10                	mov    %edx,(%eax)
  np->stackSize = curproc->stackSize;
80104619:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010461c:	8b 50 08             	mov    0x8(%eax),%edx
8010461f:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104622:	89 50 08             	mov    %edx,0x8(%eax)
  np->parent = curproc;
80104625:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104628:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010462b:	89 50 1c             	mov    %edx,0x1c(%eax)
  *np->tf = *curproc->tf;
8010462e:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104631:	8b 50 20             	mov    0x20(%eax),%edx
80104634:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104637:	8b 40 20             	mov    0x20(%eax),%eax
8010463a:	89 c3                	mov    %eax,%ebx
8010463c:	b8 13 00 00 00       	mov    $0x13,%eax
80104641:	89 d7                	mov    %edx,%edi
80104643:	89 de                	mov    %ebx,%esi
80104645:	89 c1                	mov    %eax,%ecx
80104647:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
80104649:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010464c:	8b 40 20             	mov    0x20(%eax),%eax
8010464f:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for(i = 0; i < NOFILE; i++)
80104656:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
8010465d:	eb 3a                	jmp    80104699 <fork+0x10d>
    if(curproc->ofile[i])
8010465f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104662:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104665:	83 c2 0c             	add    $0xc,%edx
80104668:	8b 04 90             	mov    (%eax,%edx,4),%eax
8010466b:	85 c0                	test   %eax,%eax
8010466d:	74 26                	je     80104695 <fork+0x109>
      np->ofile[i] = filedup(curproc->ofile[i]);
8010466f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104672:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104675:	83 c2 0c             	add    $0xc,%edx
80104678:	8b 04 90             	mov    (%eax,%edx,4),%eax
8010467b:	83 ec 0c             	sub    $0xc,%esp
8010467e:	50                   	push   %eax
8010467f:	e8 d3 c9 ff ff       	call   80101057 <filedup>
80104684:	83 c4 10             	add    $0x10,%esp
80104687:	89 c1                	mov    %eax,%ecx
80104689:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010468c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010468f:	83 c2 0c             	add    $0xc,%edx
80104692:	89 0c 90             	mov    %ecx,(%eax,%edx,4)
  *np->tf = *curproc->tf;

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;

  for(i = 0; i < NOFILE; i++)
80104695:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80104699:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
8010469d:	7e c0                	jle    8010465f <fork+0xd3>
    if(curproc->ofile[i])
      np->ofile[i] = filedup(curproc->ofile[i]);
  np->cwd = idup(curproc->cwd);
8010469f:	8b 45 e0             	mov    -0x20(%ebp),%eax
801046a2:	8b 40 70             	mov    0x70(%eax),%eax
801046a5:	83 ec 0c             	sub    $0xc,%esp
801046a8:	50                   	push   %eax
801046a9:	e8 1f d3 ff ff       	call   801019cd <idup>
801046ae:	83 c4 10             	add    $0x10,%esp
801046b1:	89 c2                	mov    %eax,%edx
801046b3:	8b 45 dc             	mov    -0x24(%ebp),%eax
801046b6:	89 50 70             	mov    %edx,0x70(%eax)

  safestrcpy(np->name, curproc->name, sizeof(curproc->name));
801046b9:	8b 45 e0             	mov    -0x20(%ebp),%eax
801046bc:	8d 50 74             	lea    0x74(%eax),%edx
801046bf:	8b 45 dc             	mov    -0x24(%ebp),%eax
801046c2:	83 c0 74             	add    $0x74,%eax
801046c5:	83 ec 04             	sub    $0x4,%esp
801046c8:	6a 10                	push   $0x10
801046ca:	52                   	push   %edx
801046cb:	50                   	push   %eax
801046cc:	e8 16 0d 00 00       	call   801053e7 <safestrcpy>
801046d1:	83 c4 10             	add    $0x10,%esp

  pid = np->pid;
801046d4:	8b 45 dc             	mov    -0x24(%ebp),%eax
801046d7:	8b 40 18             	mov    0x18(%eax),%eax
801046da:	89 45 d8             	mov    %eax,-0x28(%ebp)

  acquire(&ptable.lock);
801046dd:	83 ec 0c             	sub    $0xc,%esp
801046e0:	68 a0 3d 11 80       	push   $0x80113da0
801046e5:	e8 83 08 00 00       	call   80104f6d <acquire>
801046ea:	83 c4 10             	add    $0x10,%esp

  np->state = RUNNABLE;
801046ed:	8b 45 dc             	mov    -0x24(%ebp),%eax
801046f0:	c7 40 14 03 00 00 00 	movl   $0x3,0x14(%eax)

  release(&ptable.lock);
801046f7:	83 ec 0c             	sub    $0xc,%esp
801046fa:	68 a0 3d 11 80       	push   $0x80113da0
801046ff:	e8 d7 08 00 00       	call   80104fdb <release>
80104704:	83 c4 10             	add    $0x10,%esp

  return pid;
80104707:	8b 45 d8             	mov    -0x28(%ebp),%eax
}
8010470a:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010470d:	5b                   	pop    %ebx
8010470e:	5e                   	pop    %esi
8010470f:	5f                   	pop    %edi
80104710:	5d                   	pop    %ebp
80104711:	c3                   	ret    

80104712 <exit>:
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
80104712:	55                   	push   %ebp
80104713:	89 e5                	mov    %esp,%ebp
80104715:	83 ec 18             	sub    $0x18,%esp
  struct proc *curproc = myproc();
80104718:	e8 67 fb ff ff       	call   80104284 <myproc>
8010471d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct proc *p;
  int fd;

  if(curproc == initproc)
80104720:	a1 20 b6 10 80       	mov    0x8010b620,%eax
80104725:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80104728:	75 0d                	jne    80104737 <exit+0x25>
    panic("init exiting");
8010472a:	83 ec 0c             	sub    $0xc,%esp
8010472d:	68 26 89 10 80       	push   $0x80108926
80104732:	e8 69 be ff ff       	call   801005a0 <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80104737:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
8010473e:	eb 3c                	jmp    8010477c <exit+0x6a>
    if(curproc->ofile[fd]){
80104740:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104743:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104746:	83 c2 0c             	add    $0xc,%edx
80104749:	8b 04 90             	mov    (%eax,%edx,4),%eax
8010474c:	85 c0                	test   %eax,%eax
8010474e:	74 28                	je     80104778 <exit+0x66>
      fileclose(curproc->ofile[fd]);
80104750:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104753:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104756:	83 c2 0c             	add    $0xc,%edx
80104759:	8b 04 90             	mov    (%eax,%edx,4),%eax
8010475c:	83 ec 0c             	sub    $0xc,%esp
8010475f:	50                   	push   %eax
80104760:	e8 43 c9 ff ff       	call   801010a8 <fileclose>
80104765:	83 c4 10             	add    $0x10,%esp
      curproc->ofile[fd] = 0;
80104768:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010476b:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010476e:	83 c2 0c             	add    $0xc,%edx
80104771:	c7 04 90 00 00 00 00 	movl   $0x0,(%eax,%edx,4)

  if(curproc == initproc)
    panic("init exiting");

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80104778:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
8010477c:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
80104780:	7e be                	jle    80104740 <exit+0x2e>
      fileclose(curproc->ofile[fd]);
      curproc->ofile[fd] = 0;
    }
  }

  begin_op();
80104782:	e8 a5 ed ff ff       	call   8010352c <begin_op>
  iput(curproc->cwd);
80104787:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010478a:	8b 40 70             	mov    0x70(%eax),%eax
8010478d:	83 ec 0c             	sub    $0xc,%esp
80104790:	50                   	push   %eax
80104791:	e8 d2 d3 ff ff       	call   80101b68 <iput>
80104796:	83 c4 10             	add    $0x10,%esp
  end_op();
80104799:	e8 1a ee ff ff       	call   801035b8 <end_op>
  curproc->cwd = 0;
8010479e:	8b 45 ec             	mov    -0x14(%ebp),%eax
801047a1:	c7 40 70 00 00 00 00 	movl   $0x0,0x70(%eax)

  acquire(&ptable.lock);
801047a8:	83 ec 0c             	sub    $0xc,%esp
801047ab:	68 a0 3d 11 80       	push   $0x80113da0
801047b0:	e8 b8 07 00 00       	call   80104f6d <acquire>
801047b5:	83 c4 10             	add    $0x10,%esp

  // Parent might be sleeping in wait().
  wakeup1(curproc->parent);
801047b8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801047bb:	8b 40 1c             	mov    0x1c(%eax),%eax
801047be:	83 ec 0c             	sub    $0xc,%esp
801047c1:	50                   	push   %eax
801047c2:	e8 2b 04 00 00       	call   80104bf2 <wakeup1>
801047c7:	83 c4 10             	add    $0x10,%esp

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801047ca:	c7 45 f4 d4 3d 11 80 	movl   $0x80113dd4,-0xc(%ebp)
801047d1:	eb 3a                	jmp    8010480d <exit+0xfb>
    if(p->parent == curproc){
801047d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047d6:	8b 40 1c             	mov    0x1c(%eax),%eax
801047d9:	3b 45 ec             	cmp    -0x14(%ebp),%eax
801047dc:	75 28                	jne    80104806 <exit+0xf4>
      p->parent = initproc;
801047de:	8b 15 20 b6 10 80    	mov    0x8010b620,%edx
801047e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047e7:	89 50 1c             	mov    %edx,0x1c(%eax)
      if(p->state == ZOMBIE)
801047ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047ed:	8b 40 14             	mov    0x14(%eax),%eax
801047f0:	83 f8 05             	cmp    $0x5,%eax
801047f3:	75 11                	jne    80104806 <exit+0xf4>
        wakeup1(initproc);
801047f5:	a1 20 b6 10 80       	mov    0x8010b620,%eax
801047fa:	83 ec 0c             	sub    $0xc,%esp
801047fd:	50                   	push   %eax
801047fe:	e8 ef 03 00 00       	call   80104bf2 <wakeup1>
80104803:	83 c4 10             	add    $0x10,%esp

  // Parent might be sleeping in wait().
  wakeup1(curproc->parent);

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104806:	81 45 f4 84 00 00 00 	addl   $0x84,-0xc(%ebp)
8010480d:	81 7d f4 d4 5e 11 80 	cmpl   $0x80115ed4,-0xc(%ebp)
80104814:	72 bd                	jb     801047d3 <exit+0xc1>
        wakeup1(initproc);
    }
  }

  // Jump into the scheduler, never to return.
  curproc->state = ZOMBIE;
80104816:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104819:	c7 40 14 05 00 00 00 	movl   $0x5,0x14(%eax)
  sched();
80104820:	e8 eb 01 00 00       	call   80104a10 <sched>
  panic("zombie exit");
80104825:	83 ec 0c             	sub    $0xc,%esp
80104828:	68 33 89 10 80       	push   $0x80108933
8010482d:	e8 6e bd ff ff       	call   801005a0 <panic>

80104832 <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
80104832:	55                   	push   %ebp
80104833:	89 e5                	mov    %esp,%ebp
80104835:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int havekids, pid;
  struct proc *curproc = myproc();
80104838:	e8 47 fa ff ff       	call   80104284 <myproc>
8010483d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  
  acquire(&ptable.lock);
80104840:	83 ec 0c             	sub    $0xc,%esp
80104843:	68 a0 3d 11 80       	push   $0x80113da0
80104848:	e8 20 07 00 00       	call   80104f6d <acquire>
8010484d:	83 c4 10             	add    $0x10,%esp
  for(;;){
    // Scan through table looking for exited children.
    havekids = 0;
80104850:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104857:	c7 45 f4 d4 3d 11 80 	movl   $0x80113dd4,-0xc(%ebp)
8010485e:	e9 a4 00 00 00       	jmp    80104907 <wait+0xd5>
      if(p->parent != curproc)
80104863:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104866:	8b 40 1c             	mov    0x1c(%eax),%eax
80104869:	3b 45 ec             	cmp    -0x14(%ebp),%eax
8010486c:	0f 85 8d 00 00 00    	jne    801048ff <wait+0xcd>
        continue;
      havekids = 1;
80104872:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
80104879:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010487c:	8b 40 14             	mov    0x14(%eax),%eax
8010487f:	83 f8 05             	cmp    $0x5,%eax
80104882:	75 7c                	jne    80104900 <wait+0xce>
        // Found one.
        pid = p->pid;
80104884:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104887:	8b 40 18             	mov    0x18(%eax),%eax
8010488a:	89 45 e8             	mov    %eax,-0x18(%ebp)
        kfree(p->kstack);
8010488d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104890:	8b 40 10             	mov    0x10(%eax),%eax
80104893:	83 ec 0c             	sub    $0xc,%esp
80104896:	50                   	push   %eax
80104897:	e8 56 e3 ff ff       	call   80102bf2 <kfree>
8010489c:	83 c4 10             	add    $0x10,%esp
        p->kstack = 0;
8010489f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048a2:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        freevm(p->pgdir);
801048a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048ac:	8b 40 0c             	mov    0xc(%eax),%eax
801048af:	83 ec 0c             	sub    $0xc,%esp
801048b2:	50                   	push   %eax
801048b3:	e8 68 38 00 00       	call   80108120 <freevm>
801048b8:	83 c4 10             	add    $0x10,%esp
        p->pid = 0;
801048bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048be:	c7 40 18 00 00 00 00 	movl   $0x0,0x18(%eax)
        p->parent = 0;
801048c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048c8:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
        p->name[0] = 0;
801048cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048d2:	c6 40 74 00          	movb   $0x0,0x74(%eax)
        p->killed = 0;
801048d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048d9:	c7 40 2c 00 00 00 00 	movl   $0x0,0x2c(%eax)
        p->state = UNUSED;
801048e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048e3:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        release(&ptable.lock);
801048ea:	83 ec 0c             	sub    $0xc,%esp
801048ed:	68 a0 3d 11 80       	push   $0x80113da0
801048f2:	e8 e4 06 00 00       	call   80104fdb <release>
801048f7:	83 c4 10             	add    $0x10,%esp
        return pid;
801048fa:	8b 45 e8             	mov    -0x18(%ebp),%eax
801048fd:	eb 54                	jmp    80104953 <wait+0x121>
  for(;;){
    // Scan through table looking for exited children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
      if(p->parent != curproc)
        continue;
801048ff:	90                   	nop
  
  acquire(&ptable.lock);
  for(;;){
    // Scan through table looking for exited children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104900:	81 45 f4 84 00 00 00 	addl   $0x84,-0xc(%ebp)
80104907:	81 7d f4 d4 5e 11 80 	cmpl   $0x80115ed4,-0xc(%ebp)
8010490e:	0f 82 4f ff ff ff    	jb     80104863 <wait+0x31>
        return pid;
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || curproc->killed){
80104914:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104918:	74 0a                	je     80104924 <wait+0xf2>
8010491a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010491d:	8b 40 2c             	mov    0x2c(%eax),%eax
80104920:	85 c0                	test   %eax,%eax
80104922:	74 17                	je     8010493b <wait+0x109>
      release(&ptable.lock);
80104924:	83 ec 0c             	sub    $0xc,%esp
80104927:	68 a0 3d 11 80       	push   $0x80113da0
8010492c:	e8 aa 06 00 00       	call   80104fdb <release>
80104931:	83 c4 10             	add    $0x10,%esp
      return -1;
80104934:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104939:	eb 18                	jmp    80104953 <wait+0x121>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(curproc, &ptable.lock);  //DOC: wait-sleep
8010493b:	83 ec 08             	sub    $0x8,%esp
8010493e:	68 a0 3d 11 80       	push   $0x80113da0
80104943:	ff 75 ec             	pushl  -0x14(%ebp)
80104946:	e8 00 02 00 00       	call   80104b4b <sleep>
8010494b:	83 c4 10             	add    $0x10,%esp
  }
8010494e:	e9 fd fe ff ff       	jmp    80104850 <wait+0x1e>
}
80104953:	c9                   	leave  
80104954:	c3                   	ret    

80104955 <scheduler>:
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
80104955:	55                   	push   %ebp
80104956:	89 e5                	mov    %esp,%ebp
80104958:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  struct cpu *c = mycpu();
8010495b:	e8 ac f8 ff ff       	call   8010420c <mycpu>
80104960:	89 45 f0             	mov    %eax,-0x10(%ebp)
  c->proc = 0;
80104963:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104966:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
8010496d:	00 00 00 
  
  for(;;){
    // Enable interrupts on this processor.
    sti();
80104970:	e8 51 f8 ff ff       	call   801041c6 <sti>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
80104975:	83 ec 0c             	sub    $0xc,%esp
80104978:	68 a0 3d 11 80       	push   $0x80113da0
8010497d:	e8 eb 05 00 00       	call   80104f6d <acquire>
80104982:	83 c4 10             	add    $0x10,%esp
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104985:	c7 45 f4 d4 3d 11 80 	movl   $0x80113dd4,-0xc(%ebp)
8010498c:	eb 64                	jmp    801049f2 <scheduler+0x9d>
      if(p->state != RUNNABLE)
8010498e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104991:	8b 40 14             	mov    0x14(%eax),%eax
80104994:	83 f8 03             	cmp    $0x3,%eax
80104997:	75 51                	jne    801049ea <scheduler+0x95>
        continue;

      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      c->proc = p;
80104999:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010499c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010499f:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
      switchuvm(p);
801049a5:	83 ec 0c             	sub    $0xc,%esp
801049a8:	ff 75 f4             	pushl  -0xc(%ebp)
801049ab:	e8 b3 32 00 00       	call   80107c63 <switchuvm>
801049b0:	83 c4 10             	add    $0x10,%esp
      p->state = RUNNING;
801049b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049b6:	c7 40 14 04 00 00 00 	movl   $0x4,0x14(%eax)

      swtch(&(c->scheduler), p->context);
801049bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049c0:	8b 40 24             	mov    0x24(%eax),%eax
801049c3:	8b 55 f0             	mov    -0x10(%ebp),%edx
801049c6:	83 c2 04             	add    $0x4,%edx
801049c9:	83 ec 08             	sub    $0x8,%esp
801049cc:	50                   	push   %eax
801049cd:	52                   	push   %edx
801049ce:	e8 85 0a 00 00       	call   80105458 <swtch>
801049d3:	83 c4 10             	add    $0x10,%esp
      switchkvm();
801049d6:	e8 6f 32 00 00       	call   80107c4a <switchkvm>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      c->proc = 0;
801049db:	8b 45 f0             	mov    -0x10(%ebp),%eax
801049de:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
801049e5:	00 00 00 
801049e8:	eb 01                	jmp    801049eb <scheduler+0x96>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
      if(p->state != RUNNABLE)
        continue;
801049ea:	90                   	nop
    // Enable interrupts on this processor.
    sti();

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801049eb:	81 45 f4 84 00 00 00 	addl   $0x84,-0xc(%ebp)
801049f2:	81 7d f4 d4 5e 11 80 	cmpl   $0x80115ed4,-0xc(%ebp)
801049f9:	72 93                	jb     8010498e <scheduler+0x39>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      c->proc = 0;
    }
    release(&ptable.lock);
801049fb:	83 ec 0c             	sub    $0xc,%esp
801049fe:	68 a0 3d 11 80       	push   $0x80113da0
80104a03:	e8 d3 05 00 00       	call   80104fdb <release>
80104a08:	83 c4 10             	add    $0x10,%esp

  }
80104a0b:	e9 60 ff ff ff       	jmp    80104970 <scheduler+0x1b>

80104a10 <sched>:
// be proc->intena and proc->ncli, but that would
// break in the few places where a lock is held but
// there's no process.
void
sched(void)
{
80104a10:	55                   	push   %ebp
80104a11:	89 e5                	mov    %esp,%ebp
80104a13:	83 ec 18             	sub    $0x18,%esp
  int intena;
  struct proc *p = myproc();
80104a16:	e8 69 f8 ff ff       	call   80104284 <myproc>
80104a1b:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(!holding(&ptable.lock))
80104a1e:	83 ec 0c             	sub    $0xc,%esp
80104a21:	68 a0 3d 11 80       	push   $0x80113da0
80104a26:	e8 7c 06 00 00       	call   801050a7 <holding>
80104a2b:	83 c4 10             	add    $0x10,%esp
80104a2e:	85 c0                	test   %eax,%eax
80104a30:	75 0d                	jne    80104a3f <sched+0x2f>
    panic("sched ptable.lock");
80104a32:	83 ec 0c             	sub    $0xc,%esp
80104a35:	68 3f 89 10 80       	push   $0x8010893f
80104a3a:	e8 61 bb ff ff       	call   801005a0 <panic>
  if(mycpu()->ncli != 1)
80104a3f:	e8 c8 f7 ff ff       	call   8010420c <mycpu>
80104a44:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104a4a:	83 f8 01             	cmp    $0x1,%eax
80104a4d:	74 0d                	je     80104a5c <sched+0x4c>
    panic("sched locks");
80104a4f:	83 ec 0c             	sub    $0xc,%esp
80104a52:	68 51 89 10 80       	push   $0x80108951
80104a57:	e8 44 bb ff ff       	call   801005a0 <panic>
  if(p->state == RUNNING)
80104a5c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a5f:	8b 40 14             	mov    0x14(%eax),%eax
80104a62:	83 f8 04             	cmp    $0x4,%eax
80104a65:	75 0d                	jne    80104a74 <sched+0x64>
    panic("sched running");
80104a67:	83 ec 0c             	sub    $0xc,%esp
80104a6a:	68 5d 89 10 80       	push   $0x8010895d
80104a6f:	e8 2c bb ff ff       	call   801005a0 <panic>
  if(readeflags()&FL_IF)
80104a74:	e8 3d f7 ff ff       	call   801041b6 <readeflags>
80104a79:	25 00 02 00 00       	and    $0x200,%eax
80104a7e:	85 c0                	test   %eax,%eax
80104a80:	74 0d                	je     80104a8f <sched+0x7f>
    panic("sched interruptible");
80104a82:	83 ec 0c             	sub    $0xc,%esp
80104a85:	68 6b 89 10 80       	push   $0x8010896b
80104a8a:	e8 11 bb ff ff       	call   801005a0 <panic>
  intena = mycpu()->intena;
80104a8f:	e8 78 f7 ff ff       	call   8010420c <mycpu>
80104a94:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80104a9a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  swtch(&p->context, mycpu()->scheduler);
80104a9d:	e8 6a f7 ff ff       	call   8010420c <mycpu>
80104aa2:	8b 40 04             	mov    0x4(%eax),%eax
80104aa5:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104aa8:	83 c2 24             	add    $0x24,%edx
80104aab:	83 ec 08             	sub    $0x8,%esp
80104aae:	50                   	push   %eax
80104aaf:	52                   	push   %edx
80104ab0:	e8 a3 09 00 00       	call   80105458 <swtch>
80104ab5:	83 c4 10             	add    $0x10,%esp
  mycpu()->intena = intena;
80104ab8:	e8 4f f7 ff ff       	call   8010420c <mycpu>
80104abd:	89 c2                	mov    %eax,%edx
80104abf:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104ac2:	89 82 a8 00 00 00    	mov    %eax,0xa8(%edx)
}
80104ac8:	90                   	nop
80104ac9:	c9                   	leave  
80104aca:	c3                   	ret    

80104acb <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
80104acb:	55                   	push   %ebp
80104acc:	89 e5                	mov    %esp,%ebp
80104ace:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
80104ad1:	83 ec 0c             	sub    $0xc,%esp
80104ad4:	68 a0 3d 11 80       	push   $0x80113da0
80104ad9:	e8 8f 04 00 00       	call   80104f6d <acquire>
80104ade:	83 c4 10             	add    $0x10,%esp
  myproc()->state = RUNNABLE;
80104ae1:	e8 9e f7 ff ff       	call   80104284 <myproc>
80104ae6:	c7 40 14 03 00 00 00 	movl   $0x3,0x14(%eax)
  sched();
80104aed:	e8 1e ff ff ff       	call   80104a10 <sched>
  release(&ptable.lock);
80104af2:	83 ec 0c             	sub    $0xc,%esp
80104af5:	68 a0 3d 11 80       	push   $0x80113da0
80104afa:	e8 dc 04 00 00       	call   80104fdb <release>
80104aff:	83 c4 10             	add    $0x10,%esp
}
80104b02:	90                   	nop
80104b03:	c9                   	leave  
80104b04:	c3                   	ret    

80104b05 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
80104b05:	55                   	push   %ebp
80104b06:	89 e5                	mov    %esp,%ebp
80104b08:	83 ec 08             	sub    $0x8,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
80104b0b:	83 ec 0c             	sub    $0xc,%esp
80104b0e:	68 a0 3d 11 80       	push   $0x80113da0
80104b13:	e8 c3 04 00 00       	call   80104fdb <release>
80104b18:	83 c4 10             	add    $0x10,%esp

  if (first) {
80104b1b:	a1 04 b0 10 80       	mov    0x8010b004,%eax
80104b20:	85 c0                	test   %eax,%eax
80104b22:	74 24                	je     80104b48 <forkret+0x43>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot
    // be run from main().
    first = 0;
80104b24:	c7 05 04 b0 10 80 00 	movl   $0x0,0x8010b004
80104b2b:	00 00 00 
    iinit(ROOTDEV);
80104b2e:	83 ec 0c             	sub    $0xc,%esp
80104b31:	6a 01                	push   $0x1
80104b33:	e8 5d cb ff ff       	call   80101695 <iinit>
80104b38:	83 c4 10             	add    $0x10,%esp
    initlog(ROOTDEV);
80104b3b:	83 ec 0c             	sub    $0xc,%esp
80104b3e:	6a 01                	push   $0x1
80104b40:	e8 c9 e7 ff ff       	call   8010330e <initlog>
80104b45:	83 c4 10             	add    $0x10,%esp
  }

  // Return to "caller", actually trapret (see allocproc).
}
80104b48:	90                   	nop
80104b49:	c9                   	leave  
80104b4a:	c3                   	ret    

80104b4b <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
80104b4b:	55                   	push   %ebp
80104b4c:	89 e5                	mov    %esp,%ebp
80104b4e:	83 ec 18             	sub    $0x18,%esp
  struct proc *p = myproc();
80104b51:	e8 2e f7 ff ff       	call   80104284 <myproc>
80104b56:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  if(p == 0)
80104b59:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104b5d:	75 0d                	jne    80104b6c <sleep+0x21>
    panic("sleep");
80104b5f:	83 ec 0c             	sub    $0xc,%esp
80104b62:	68 7f 89 10 80       	push   $0x8010897f
80104b67:	e8 34 ba ff ff       	call   801005a0 <panic>

  if(lk == 0)
80104b6c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104b70:	75 0d                	jne    80104b7f <sleep+0x34>
    panic("sleep without lk");
80104b72:	83 ec 0c             	sub    $0xc,%esp
80104b75:	68 85 89 10 80       	push   $0x80108985
80104b7a:	e8 21 ba ff ff       	call   801005a0 <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
80104b7f:	81 7d 0c a0 3d 11 80 	cmpl   $0x80113da0,0xc(%ebp)
80104b86:	74 1e                	je     80104ba6 <sleep+0x5b>
    acquire(&ptable.lock);  //DOC: sleeplock1
80104b88:	83 ec 0c             	sub    $0xc,%esp
80104b8b:	68 a0 3d 11 80       	push   $0x80113da0
80104b90:	e8 d8 03 00 00       	call   80104f6d <acquire>
80104b95:	83 c4 10             	add    $0x10,%esp
    release(lk);
80104b98:	83 ec 0c             	sub    $0xc,%esp
80104b9b:	ff 75 0c             	pushl  0xc(%ebp)
80104b9e:	e8 38 04 00 00       	call   80104fdb <release>
80104ba3:	83 c4 10             	add    $0x10,%esp
  }
  // Go to sleep.
  p->chan = chan;
80104ba6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ba9:	8b 55 08             	mov    0x8(%ebp),%edx
80104bac:	89 50 28             	mov    %edx,0x28(%eax)
  p->state = SLEEPING;
80104baf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bb2:	c7 40 14 02 00 00 00 	movl   $0x2,0x14(%eax)

  sched();
80104bb9:	e8 52 fe ff ff       	call   80104a10 <sched>

  // Tidy up.
  p->chan = 0;
80104bbe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bc1:	c7 40 28 00 00 00 00 	movl   $0x0,0x28(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
80104bc8:	81 7d 0c a0 3d 11 80 	cmpl   $0x80113da0,0xc(%ebp)
80104bcf:	74 1e                	je     80104bef <sleep+0xa4>
    release(&ptable.lock);
80104bd1:	83 ec 0c             	sub    $0xc,%esp
80104bd4:	68 a0 3d 11 80       	push   $0x80113da0
80104bd9:	e8 fd 03 00 00       	call   80104fdb <release>
80104bde:	83 c4 10             	add    $0x10,%esp
    acquire(lk);
80104be1:	83 ec 0c             	sub    $0xc,%esp
80104be4:	ff 75 0c             	pushl  0xc(%ebp)
80104be7:	e8 81 03 00 00       	call   80104f6d <acquire>
80104bec:	83 c4 10             	add    $0x10,%esp
  }
}
80104bef:	90                   	nop
80104bf0:	c9                   	leave  
80104bf1:	c3                   	ret    

80104bf2 <wakeup1>:
//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
80104bf2:	55                   	push   %ebp
80104bf3:	89 e5                	mov    %esp,%ebp
80104bf5:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104bf8:	c7 45 fc d4 3d 11 80 	movl   $0x80113dd4,-0x4(%ebp)
80104bff:	eb 27                	jmp    80104c28 <wakeup1+0x36>
    if(p->state == SLEEPING && p->chan == chan)
80104c01:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104c04:	8b 40 14             	mov    0x14(%eax),%eax
80104c07:	83 f8 02             	cmp    $0x2,%eax
80104c0a:	75 15                	jne    80104c21 <wakeup1+0x2f>
80104c0c:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104c0f:	8b 40 28             	mov    0x28(%eax),%eax
80104c12:	3b 45 08             	cmp    0x8(%ebp),%eax
80104c15:	75 0a                	jne    80104c21 <wakeup1+0x2f>
      p->state = RUNNABLE;
80104c17:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104c1a:	c7 40 14 03 00 00 00 	movl   $0x3,0x14(%eax)
static void
wakeup1(void *chan)
{
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104c21:	81 45 fc 84 00 00 00 	addl   $0x84,-0x4(%ebp)
80104c28:	81 7d fc d4 5e 11 80 	cmpl   $0x80115ed4,-0x4(%ebp)
80104c2f:	72 d0                	jb     80104c01 <wakeup1+0xf>
    if(p->state == SLEEPING && p->chan == chan)
      p->state = RUNNABLE;
}
80104c31:	90                   	nop
80104c32:	c9                   	leave  
80104c33:	c3                   	ret    

80104c34 <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
80104c34:	55                   	push   %ebp
80104c35:	89 e5                	mov    %esp,%ebp
80104c37:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);
80104c3a:	83 ec 0c             	sub    $0xc,%esp
80104c3d:	68 a0 3d 11 80       	push   $0x80113da0
80104c42:	e8 26 03 00 00       	call   80104f6d <acquire>
80104c47:	83 c4 10             	add    $0x10,%esp
  wakeup1(chan);
80104c4a:	83 ec 0c             	sub    $0xc,%esp
80104c4d:	ff 75 08             	pushl  0x8(%ebp)
80104c50:	e8 9d ff ff ff       	call   80104bf2 <wakeup1>
80104c55:	83 c4 10             	add    $0x10,%esp
  release(&ptable.lock);
80104c58:	83 ec 0c             	sub    $0xc,%esp
80104c5b:	68 a0 3d 11 80       	push   $0x80113da0
80104c60:	e8 76 03 00 00       	call   80104fdb <release>
80104c65:	83 c4 10             	add    $0x10,%esp
}
80104c68:	90                   	nop
80104c69:	c9                   	leave  
80104c6a:	c3                   	ret    

80104c6b <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
80104c6b:	55                   	push   %ebp
80104c6c:	89 e5                	mov    %esp,%ebp
80104c6e:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;

  acquire(&ptable.lock);
80104c71:	83 ec 0c             	sub    $0xc,%esp
80104c74:	68 a0 3d 11 80       	push   $0x80113da0
80104c79:	e8 ef 02 00 00       	call   80104f6d <acquire>
80104c7e:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104c81:	c7 45 f4 d4 3d 11 80 	movl   $0x80113dd4,-0xc(%ebp)
80104c88:	eb 48                	jmp    80104cd2 <kill+0x67>
    if(p->pid == pid){
80104c8a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c8d:	8b 40 18             	mov    0x18(%eax),%eax
80104c90:	3b 45 08             	cmp    0x8(%ebp),%eax
80104c93:	75 36                	jne    80104ccb <kill+0x60>
      p->killed = 1;
80104c95:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c98:	c7 40 2c 01 00 00 00 	movl   $0x1,0x2c(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
80104c9f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ca2:	8b 40 14             	mov    0x14(%eax),%eax
80104ca5:	83 f8 02             	cmp    $0x2,%eax
80104ca8:	75 0a                	jne    80104cb4 <kill+0x49>
        p->state = RUNNABLE;
80104caa:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104cad:	c7 40 14 03 00 00 00 	movl   $0x3,0x14(%eax)
      release(&ptable.lock);
80104cb4:	83 ec 0c             	sub    $0xc,%esp
80104cb7:	68 a0 3d 11 80       	push   $0x80113da0
80104cbc:	e8 1a 03 00 00       	call   80104fdb <release>
80104cc1:	83 c4 10             	add    $0x10,%esp
      return 0;
80104cc4:	b8 00 00 00 00       	mov    $0x0,%eax
80104cc9:	eb 25                	jmp    80104cf0 <kill+0x85>
kill(int pid)
{
  struct proc *p;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104ccb:	81 45 f4 84 00 00 00 	addl   $0x84,-0xc(%ebp)
80104cd2:	81 7d f4 d4 5e 11 80 	cmpl   $0x80115ed4,-0xc(%ebp)
80104cd9:	72 af                	jb     80104c8a <kill+0x1f>
        p->state = RUNNABLE;
      release(&ptable.lock);
      return 0;
    }
  }
  release(&ptable.lock);
80104cdb:	83 ec 0c             	sub    $0xc,%esp
80104cde:	68 a0 3d 11 80       	push   $0x80113da0
80104ce3:	e8 f3 02 00 00       	call   80104fdb <release>
80104ce8:	83 c4 10             	add    $0x10,%esp
  return -1;
80104ceb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104cf0:	c9                   	leave  
80104cf1:	c3                   	ret    

80104cf2 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
80104cf2:	55                   	push   %ebp
80104cf3:	89 e5                	mov    %esp,%ebp
80104cf5:	83 ec 48             	sub    $0x48,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104cf8:	c7 45 f0 d4 3d 11 80 	movl   $0x80113dd4,-0x10(%ebp)
80104cff:	e9 da 00 00 00       	jmp    80104dde <procdump+0xec>
    if(p->state == UNUSED)
80104d04:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104d07:	8b 40 14             	mov    0x14(%eax),%eax
80104d0a:	85 c0                	test   %eax,%eax
80104d0c:	0f 84 c4 00 00 00    	je     80104dd6 <procdump+0xe4>
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80104d12:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104d15:	8b 40 14             	mov    0x14(%eax),%eax
80104d18:	83 f8 05             	cmp    $0x5,%eax
80104d1b:	77 23                	ja     80104d40 <procdump+0x4e>
80104d1d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104d20:	8b 40 14             	mov    0x14(%eax),%eax
80104d23:	8b 04 85 08 b0 10 80 	mov    -0x7fef4ff8(,%eax,4),%eax
80104d2a:	85 c0                	test   %eax,%eax
80104d2c:	74 12                	je     80104d40 <procdump+0x4e>
      state = states[p->state];
80104d2e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104d31:	8b 40 14             	mov    0x14(%eax),%eax
80104d34:	8b 04 85 08 b0 10 80 	mov    -0x7fef4ff8(,%eax,4),%eax
80104d3b:	89 45 ec             	mov    %eax,-0x14(%ebp)
80104d3e:	eb 07                	jmp    80104d47 <procdump+0x55>
    else
      state = "???";
80104d40:	c7 45 ec 96 89 10 80 	movl   $0x80108996,-0x14(%ebp)
    cprintf("%d %s %s", p->pid, state, p->name);
80104d47:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104d4a:	8d 50 74             	lea    0x74(%eax),%edx
80104d4d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104d50:	8b 40 18             	mov    0x18(%eax),%eax
80104d53:	52                   	push   %edx
80104d54:	ff 75 ec             	pushl  -0x14(%ebp)
80104d57:	50                   	push   %eax
80104d58:	68 9a 89 10 80       	push   $0x8010899a
80104d5d:	e8 9e b6 ff ff       	call   80100400 <cprintf>
80104d62:	83 c4 10             	add    $0x10,%esp
    if(p->state == SLEEPING){
80104d65:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104d68:	8b 40 14             	mov    0x14(%eax),%eax
80104d6b:	83 f8 02             	cmp    $0x2,%eax
80104d6e:	75 54                	jne    80104dc4 <procdump+0xd2>
      getcallerpcs((uint*)p->context->ebp+2, pc);
80104d70:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104d73:	8b 40 24             	mov    0x24(%eax),%eax
80104d76:	8b 40 0c             	mov    0xc(%eax),%eax
80104d79:	83 c0 08             	add    $0x8,%eax
80104d7c:	89 c2                	mov    %eax,%edx
80104d7e:	83 ec 08             	sub    $0x8,%esp
80104d81:	8d 45 c4             	lea    -0x3c(%ebp),%eax
80104d84:	50                   	push   %eax
80104d85:	52                   	push   %edx
80104d86:	e8 a2 02 00 00       	call   8010502d <getcallerpcs>
80104d8b:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
80104d8e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104d95:	eb 1c                	jmp    80104db3 <procdump+0xc1>
        cprintf(" %p", pc[i]);
80104d97:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d9a:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104d9e:	83 ec 08             	sub    $0x8,%esp
80104da1:	50                   	push   %eax
80104da2:	68 a3 89 10 80       	push   $0x801089a3
80104da7:	e8 54 b6 ff ff       	call   80100400 <cprintf>
80104dac:	83 c4 10             	add    $0x10,%esp
    else
      state = "???";
    cprintf("%d %s %s", p->pid, state, p->name);
    if(p->state == SLEEPING){
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
80104daf:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104db3:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
80104db7:	7f 0b                	jg     80104dc4 <procdump+0xd2>
80104db9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104dbc:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104dc0:	85 c0                	test   %eax,%eax
80104dc2:	75 d3                	jne    80104d97 <procdump+0xa5>
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
80104dc4:	83 ec 0c             	sub    $0xc,%esp
80104dc7:	68 a7 89 10 80       	push   $0x801089a7
80104dcc:	e8 2f b6 ff ff       	call   80100400 <cprintf>
80104dd1:	83 c4 10             	add    $0x10,%esp
80104dd4:	eb 01                	jmp    80104dd7 <procdump+0xe5>
  char *state;
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->state == UNUSED)
      continue;
80104dd6:	90                   	nop
  int i;
  struct proc *p;
  char *state;
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104dd7:	81 45 f0 84 00 00 00 	addl   $0x84,-0x10(%ebp)
80104dde:	81 7d f0 d4 5e 11 80 	cmpl   $0x80115ed4,-0x10(%ebp)
80104de5:	0f 82 19 ff ff ff    	jb     80104d04 <procdump+0x12>
      for(i=0; i<10 && pc[i] != 0; i++)
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
  }
}
80104deb:	90                   	nop
80104dec:	c9                   	leave  
80104ded:	c3                   	ret    

80104dee <initsleeplock>:
#include "spinlock.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
80104dee:	55                   	push   %ebp
80104def:	89 e5                	mov    %esp,%ebp
80104df1:	83 ec 08             	sub    $0x8,%esp
  initlock(&lk->lk, "sleep lock");
80104df4:	8b 45 08             	mov    0x8(%ebp),%eax
80104df7:	83 c0 04             	add    $0x4,%eax
80104dfa:	83 ec 08             	sub    $0x8,%esp
80104dfd:	68 d3 89 10 80       	push   $0x801089d3
80104e02:	50                   	push   %eax
80104e03:	e8 43 01 00 00       	call   80104f4b <initlock>
80104e08:	83 c4 10             	add    $0x10,%esp
  lk->name = name;
80104e0b:	8b 45 08             	mov    0x8(%ebp),%eax
80104e0e:	8b 55 0c             	mov    0xc(%ebp),%edx
80104e11:	89 50 38             	mov    %edx,0x38(%eax)
  lk->locked = 0;
80104e14:	8b 45 08             	mov    0x8(%ebp),%eax
80104e17:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
80104e1d:	8b 45 08             	mov    0x8(%ebp),%eax
80104e20:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
}
80104e27:	90                   	nop
80104e28:	c9                   	leave  
80104e29:	c3                   	ret    

80104e2a <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
80104e2a:	55                   	push   %ebp
80104e2b:	89 e5                	mov    %esp,%ebp
80104e2d:	83 ec 08             	sub    $0x8,%esp
  acquire(&lk->lk);
80104e30:	8b 45 08             	mov    0x8(%ebp),%eax
80104e33:	83 c0 04             	add    $0x4,%eax
80104e36:	83 ec 0c             	sub    $0xc,%esp
80104e39:	50                   	push   %eax
80104e3a:	e8 2e 01 00 00       	call   80104f6d <acquire>
80104e3f:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
80104e42:	eb 15                	jmp    80104e59 <acquiresleep+0x2f>
    sleep(lk, &lk->lk);
80104e44:	8b 45 08             	mov    0x8(%ebp),%eax
80104e47:	83 c0 04             	add    $0x4,%eax
80104e4a:	83 ec 08             	sub    $0x8,%esp
80104e4d:	50                   	push   %eax
80104e4e:	ff 75 08             	pushl  0x8(%ebp)
80104e51:	e8 f5 fc ff ff       	call   80104b4b <sleep>
80104e56:	83 c4 10             	add    $0x10,%esp

void
acquiresleep(struct sleeplock *lk)
{
  acquire(&lk->lk);
  while (lk->locked) {
80104e59:	8b 45 08             	mov    0x8(%ebp),%eax
80104e5c:	8b 00                	mov    (%eax),%eax
80104e5e:	85 c0                	test   %eax,%eax
80104e60:	75 e2                	jne    80104e44 <acquiresleep+0x1a>
    sleep(lk, &lk->lk);
  }
  lk->locked = 1;
80104e62:	8b 45 08             	mov    0x8(%ebp),%eax
80104e65:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  lk->pid = myproc()->pid;
80104e6b:	e8 14 f4 ff ff       	call   80104284 <myproc>
80104e70:	8b 50 18             	mov    0x18(%eax),%edx
80104e73:	8b 45 08             	mov    0x8(%ebp),%eax
80104e76:	89 50 3c             	mov    %edx,0x3c(%eax)
  release(&lk->lk);
80104e79:	8b 45 08             	mov    0x8(%ebp),%eax
80104e7c:	83 c0 04             	add    $0x4,%eax
80104e7f:	83 ec 0c             	sub    $0xc,%esp
80104e82:	50                   	push   %eax
80104e83:	e8 53 01 00 00       	call   80104fdb <release>
80104e88:	83 c4 10             	add    $0x10,%esp
}
80104e8b:	90                   	nop
80104e8c:	c9                   	leave  
80104e8d:	c3                   	ret    

80104e8e <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
80104e8e:	55                   	push   %ebp
80104e8f:	89 e5                	mov    %esp,%ebp
80104e91:	83 ec 08             	sub    $0x8,%esp
  acquire(&lk->lk);
80104e94:	8b 45 08             	mov    0x8(%ebp),%eax
80104e97:	83 c0 04             	add    $0x4,%eax
80104e9a:	83 ec 0c             	sub    $0xc,%esp
80104e9d:	50                   	push   %eax
80104e9e:	e8 ca 00 00 00       	call   80104f6d <acquire>
80104ea3:	83 c4 10             	add    $0x10,%esp
  lk->locked = 0;
80104ea6:	8b 45 08             	mov    0x8(%ebp),%eax
80104ea9:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
80104eaf:	8b 45 08             	mov    0x8(%ebp),%eax
80104eb2:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
  wakeup(lk);
80104eb9:	83 ec 0c             	sub    $0xc,%esp
80104ebc:	ff 75 08             	pushl  0x8(%ebp)
80104ebf:	e8 70 fd ff ff       	call   80104c34 <wakeup>
80104ec4:	83 c4 10             	add    $0x10,%esp
  release(&lk->lk);
80104ec7:	8b 45 08             	mov    0x8(%ebp),%eax
80104eca:	83 c0 04             	add    $0x4,%eax
80104ecd:	83 ec 0c             	sub    $0xc,%esp
80104ed0:	50                   	push   %eax
80104ed1:	e8 05 01 00 00       	call   80104fdb <release>
80104ed6:	83 c4 10             	add    $0x10,%esp
}
80104ed9:	90                   	nop
80104eda:	c9                   	leave  
80104edb:	c3                   	ret    

80104edc <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
80104edc:	55                   	push   %ebp
80104edd:	89 e5                	mov    %esp,%ebp
80104edf:	83 ec 18             	sub    $0x18,%esp
  int r;
  
  acquire(&lk->lk);
80104ee2:	8b 45 08             	mov    0x8(%ebp),%eax
80104ee5:	83 c0 04             	add    $0x4,%eax
80104ee8:	83 ec 0c             	sub    $0xc,%esp
80104eeb:	50                   	push   %eax
80104eec:	e8 7c 00 00 00       	call   80104f6d <acquire>
80104ef1:	83 c4 10             	add    $0x10,%esp
  r = lk->locked;
80104ef4:	8b 45 08             	mov    0x8(%ebp),%eax
80104ef7:	8b 00                	mov    (%eax),%eax
80104ef9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&lk->lk);
80104efc:	8b 45 08             	mov    0x8(%ebp),%eax
80104eff:	83 c0 04             	add    $0x4,%eax
80104f02:	83 ec 0c             	sub    $0xc,%esp
80104f05:	50                   	push   %eax
80104f06:	e8 d0 00 00 00       	call   80104fdb <release>
80104f0b:	83 c4 10             	add    $0x10,%esp
  return r;
80104f0e:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104f11:	c9                   	leave  
80104f12:	c3                   	ret    

80104f13 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80104f13:	55                   	push   %ebp
80104f14:	89 e5                	mov    %esp,%ebp
80104f16:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80104f19:	9c                   	pushf  
80104f1a:	58                   	pop    %eax
80104f1b:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80104f1e:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104f21:	c9                   	leave  
80104f22:	c3                   	ret    

80104f23 <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
80104f23:	55                   	push   %ebp
80104f24:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80104f26:	fa                   	cli    
}
80104f27:	90                   	nop
80104f28:	5d                   	pop    %ebp
80104f29:	c3                   	ret    

80104f2a <sti>:

static inline void
sti(void)
{
80104f2a:	55                   	push   %ebp
80104f2b:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80104f2d:	fb                   	sti    
}
80104f2e:	90                   	nop
80104f2f:	5d                   	pop    %ebp
80104f30:	c3                   	ret    

80104f31 <xchg>:

static inline uint
xchg(volatile uint *addr, uint newval)
{
80104f31:	55                   	push   %ebp
80104f32:	89 e5                	mov    %esp,%ebp
80104f34:	83 ec 10             	sub    $0x10,%esp
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80104f37:	8b 55 08             	mov    0x8(%ebp),%edx
80104f3a:	8b 45 0c             	mov    0xc(%ebp),%eax
80104f3d:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104f40:	f0 87 02             	lock xchg %eax,(%edx)
80104f43:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80104f46:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104f49:	c9                   	leave  
80104f4a:	c3                   	ret    

80104f4b <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
80104f4b:	55                   	push   %ebp
80104f4c:	89 e5                	mov    %esp,%ebp
  lk->name = name;
80104f4e:	8b 45 08             	mov    0x8(%ebp),%eax
80104f51:	8b 55 0c             	mov    0xc(%ebp),%edx
80104f54:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
80104f57:	8b 45 08             	mov    0x8(%ebp),%eax
80104f5a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
80104f60:	8b 45 08             	mov    0x8(%ebp),%eax
80104f63:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80104f6a:	90                   	nop
80104f6b:	5d                   	pop    %ebp
80104f6c:	c3                   	ret    

80104f6d <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
80104f6d:	55                   	push   %ebp
80104f6e:	89 e5                	mov    %esp,%ebp
80104f70:	53                   	push   %ebx
80104f71:	83 ec 04             	sub    $0x4,%esp
  pushcli(); // disable interrupts to avoid deadlock.
80104f74:	e8 5f 01 00 00       	call   801050d8 <pushcli>
  if(holding(lk))
80104f79:	8b 45 08             	mov    0x8(%ebp),%eax
80104f7c:	83 ec 0c             	sub    $0xc,%esp
80104f7f:	50                   	push   %eax
80104f80:	e8 22 01 00 00       	call   801050a7 <holding>
80104f85:	83 c4 10             	add    $0x10,%esp
80104f88:	85 c0                	test   %eax,%eax
80104f8a:	74 0d                	je     80104f99 <acquire+0x2c>
    panic("acquire");
80104f8c:	83 ec 0c             	sub    $0xc,%esp
80104f8f:	68 de 89 10 80       	push   $0x801089de
80104f94:	e8 07 b6 ff ff       	call   801005a0 <panic>

  // The xchg is atomic.
  while(xchg(&lk->locked, 1) != 0)
80104f99:	90                   	nop
80104f9a:	8b 45 08             	mov    0x8(%ebp),%eax
80104f9d:	83 ec 08             	sub    $0x8,%esp
80104fa0:	6a 01                	push   $0x1
80104fa2:	50                   	push   %eax
80104fa3:	e8 89 ff ff ff       	call   80104f31 <xchg>
80104fa8:	83 c4 10             	add    $0x10,%esp
80104fab:	85 c0                	test   %eax,%eax
80104fad:	75 eb                	jne    80104f9a <acquire+0x2d>
    ;

  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that the critical section's memory
  // references happen after the lock is acquired.
  __sync_synchronize();
80104faf:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Record info about lock acquisition for debugging.
  lk->cpu = mycpu();
80104fb4:	8b 5d 08             	mov    0x8(%ebp),%ebx
80104fb7:	e8 50 f2 ff ff       	call   8010420c <mycpu>
80104fbc:	89 43 08             	mov    %eax,0x8(%ebx)
  getcallerpcs(&lk, lk->pcs);
80104fbf:	8b 45 08             	mov    0x8(%ebp),%eax
80104fc2:	83 c0 0c             	add    $0xc,%eax
80104fc5:	83 ec 08             	sub    $0x8,%esp
80104fc8:	50                   	push   %eax
80104fc9:	8d 45 08             	lea    0x8(%ebp),%eax
80104fcc:	50                   	push   %eax
80104fcd:	e8 5b 00 00 00       	call   8010502d <getcallerpcs>
80104fd2:	83 c4 10             	add    $0x10,%esp
}
80104fd5:	90                   	nop
80104fd6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104fd9:	c9                   	leave  
80104fda:	c3                   	ret    

80104fdb <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
80104fdb:	55                   	push   %ebp
80104fdc:	89 e5                	mov    %esp,%ebp
80104fde:	83 ec 08             	sub    $0x8,%esp
  if(!holding(lk))
80104fe1:	83 ec 0c             	sub    $0xc,%esp
80104fe4:	ff 75 08             	pushl  0x8(%ebp)
80104fe7:	e8 bb 00 00 00       	call   801050a7 <holding>
80104fec:	83 c4 10             	add    $0x10,%esp
80104fef:	85 c0                	test   %eax,%eax
80104ff1:	75 0d                	jne    80105000 <release+0x25>
    panic("release");
80104ff3:	83 ec 0c             	sub    $0xc,%esp
80104ff6:	68 e6 89 10 80       	push   $0x801089e6
80104ffb:	e8 a0 b5 ff ff       	call   801005a0 <panic>

  lk->pcs[0] = 0;
80105000:	8b 45 08             	mov    0x8(%ebp),%eax
80105003:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
8010500a:	8b 45 08             	mov    0x8(%ebp),%eax
8010500d:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that all the stores in the critical
  // section are visible to other cores before the lock is released.
  // Both the C compiler and the hardware may re-order loads and
  // stores; __sync_synchronize() tells them both not to.
  __sync_synchronize();
80105014:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Release the lock, equivalent to lk->locked = 0.
  // This code can't use a C assignment, since it might
  // not be atomic. A real OS would use C atomics here.
  asm volatile("movl $0, %0" : "+m" (lk->locked) : );
80105019:	8b 45 08             	mov    0x8(%ebp),%eax
8010501c:	8b 55 08             	mov    0x8(%ebp),%edx
8010501f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  popcli();
80105025:	e8 fc 00 00 00       	call   80105126 <popcli>
}
8010502a:	90                   	nop
8010502b:	c9                   	leave  
8010502c:	c3                   	ret    

8010502d <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
8010502d:	55                   	push   %ebp
8010502e:	89 e5                	mov    %esp,%ebp
80105030:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
80105033:	8b 45 08             	mov    0x8(%ebp),%eax
80105036:	83 e8 08             	sub    $0x8,%eax
80105039:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
8010503c:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80105043:	eb 38                	jmp    8010507d <getcallerpcs+0x50>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80105045:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
80105049:	74 53                	je     8010509e <getcallerpcs+0x71>
8010504b:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
80105052:	76 4a                	jbe    8010509e <getcallerpcs+0x71>
80105054:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
80105058:	74 44                	je     8010509e <getcallerpcs+0x71>
      break;
    pcs[i] = ebp[1];     // saved %eip
8010505a:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010505d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80105064:	8b 45 0c             	mov    0xc(%ebp),%eax
80105067:	01 c2                	add    %eax,%edx
80105069:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010506c:	8b 40 04             	mov    0x4(%eax),%eax
8010506f:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
80105071:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105074:	8b 00                	mov    (%eax),%eax
80105076:	89 45 fc             	mov    %eax,-0x4(%ebp)
{
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
  for(i = 0; i < 10; i++){
80105079:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
8010507d:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80105081:	7e c2                	jle    80105045 <getcallerpcs+0x18>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
80105083:	eb 19                	jmp    8010509e <getcallerpcs+0x71>
    pcs[i] = 0;
80105085:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105088:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010508f:	8b 45 0c             	mov    0xc(%ebp),%eax
80105092:	01 d0                	add    %edx,%eax
80105094:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
8010509a:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
8010509e:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
801050a2:	7e e1                	jle    80105085 <getcallerpcs+0x58>
    pcs[i] = 0;
}
801050a4:	90                   	nop
801050a5:	c9                   	leave  
801050a6:	c3                   	ret    

801050a7 <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
801050a7:	55                   	push   %ebp
801050a8:	89 e5                	mov    %esp,%ebp
801050aa:	53                   	push   %ebx
801050ab:	83 ec 04             	sub    $0x4,%esp
  return lock->locked && lock->cpu == mycpu();
801050ae:	8b 45 08             	mov    0x8(%ebp),%eax
801050b1:	8b 00                	mov    (%eax),%eax
801050b3:	85 c0                	test   %eax,%eax
801050b5:	74 16                	je     801050cd <holding+0x26>
801050b7:	8b 45 08             	mov    0x8(%ebp),%eax
801050ba:	8b 58 08             	mov    0x8(%eax),%ebx
801050bd:	e8 4a f1 ff ff       	call   8010420c <mycpu>
801050c2:	39 c3                	cmp    %eax,%ebx
801050c4:	75 07                	jne    801050cd <holding+0x26>
801050c6:	b8 01 00 00 00       	mov    $0x1,%eax
801050cb:	eb 05                	jmp    801050d2 <holding+0x2b>
801050cd:	b8 00 00 00 00       	mov    $0x0,%eax
}
801050d2:	83 c4 04             	add    $0x4,%esp
801050d5:	5b                   	pop    %ebx
801050d6:	5d                   	pop    %ebp
801050d7:	c3                   	ret    

801050d8 <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
801050d8:	55                   	push   %ebp
801050d9:	89 e5                	mov    %esp,%ebp
801050db:	83 ec 18             	sub    $0x18,%esp
  int eflags;

  eflags = readeflags();
801050de:	e8 30 fe ff ff       	call   80104f13 <readeflags>
801050e3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  cli();
801050e6:	e8 38 fe ff ff       	call   80104f23 <cli>
  if(mycpu()->ncli == 0)
801050eb:	e8 1c f1 ff ff       	call   8010420c <mycpu>
801050f0:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
801050f6:	85 c0                	test   %eax,%eax
801050f8:	75 15                	jne    8010510f <pushcli+0x37>
    mycpu()->intena = eflags & FL_IF;
801050fa:	e8 0d f1 ff ff       	call   8010420c <mycpu>
801050ff:	89 c2                	mov    %eax,%edx
80105101:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105104:	25 00 02 00 00       	and    $0x200,%eax
80105109:	89 82 a8 00 00 00    	mov    %eax,0xa8(%edx)
  mycpu()->ncli += 1;
8010510f:	e8 f8 f0 ff ff       	call   8010420c <mycpu>
80105114:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
8010511a:	83 c2 01             	add    $0x1,%edx
8010511d:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
}
80105123:	90                   	nop
80105124:	c9                   	leave  
80105125:	c3                   	ret    

80105126 <popcli>:

void
popcli(void)
{
80105126:	55                   	push   %ebp
80105127:	89 e5                	mov    %esp,%ebp
80105129:	83 ec 08             	sub    $0x8,%esp
  if(readeflags()&FL_IF)
8010512c:	e8 e2 fd ff ff       	call   80104f13 <readeflags>
80105131:	25 00 02 00 00       	and    $0x200,%eax
80105136:	85 c0                	test   %eax,%eax
80105138:	74 0d                	je     80105147 <popcli+0x21>
    panic("popcli - interruptible");
8010513a:	83 ec 0c             	sub    $0xc,%esp
8010513d:	68 ee 89 10 80       	push   $0x801089ee
80105142:	e8 59 b4 ff ff       	call   801005a0 <panic>
  if(--mycpu()->ncli < 0)
80105147:	e8 c0 f0 ff ff       	call   8010420c <mycpu>
8010514c:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
80105152:	83 ea 01             	sub    $0x1,%edx
80105155:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
8010515b:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80105161:	85 c0                	test   %eax,%eax
80105163:	79 0d                	jns    80105172 <popcli+0x4c>
    panic("popcli");
80105165:	83 ec 0c             	sub    $0xc,%esp
80105168:	68 05 8a 10 80       	push   $0x80108a05
8010516d:	e8 2e b4 ff ff       	call   801005a0 <panic>
  if(mycpu()->ncli == 0 && mycpu()->intena)
80105172:	e8 95 f0 ff ff       	call   8010420c <mycpu>
80105177:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
8010517d:	85 c0                	test   %eax,%eax
8010517f:	75 14                	jne    80105195 <popcli+0x6f>
80105181:	e8 86 f0 ff ff       	call   8010420c <mycpu>
80105186:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
8010518c:	85 c0                	test   %eax,%eax
8010518e:	74 05                	je     80105195 <popcli+0x6f>
    sti();
80105190:	e8 95 fd ff ff       	call   80104f2a <sti>
}
80105195:	90                   	nop
80105196:	c9                   	leave  
80105197:	c3                   	ret    

80105198 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
80105198:	55                   	push   %ebp
80105199:	89 e5                	mov    %esp,%ebp
8010519b:	57                   	push   %edi
8010519c:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
8010519d:	8b 4d 08             	mov    0x8(%ebp),%ecx
801051a0:	8b 55 10             	mov    0x10(%ebp),%edx
801051a3:	8b 45 0c             	mov    0xc(%ebp),%eax
801051a6:	89 cb                	mov    %ecx,%ebx
801051a8:	89 df                	mov    %ebx,%edi
801051aa:	89 d1                	mov    %edx,%ecx
801051ac:	fc                   	cld    
801051ad:	f3 aa                	rep stos %al,%es:(%edi)
801051af:	89 ca                	mov    %ecx,%edx
801051b1:	89 fb                	mov    %edi,%ebx
801051b3:	89 5d 08             	mov    %ebx,0x8(%ebp)
801051b6:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
801051b9:	90                   	nop
801051ba:	5b                   	pop    %ebx
801051bb:	5f                   	pop    %edi
801051bc:	5d                   	pop    %ebp
801051bd:	c3                   	ret    

801051be <stosl>:

static inline void
stosl(void *addr, int data, int cnt)
{
801051be:	55                   	push   %ebp
801051bf:	89 e5                	mov    %esp,%ebp
801051c1:	57                   	push   %edi
801051c2:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
801051c3:	8b 4d 08             	mov    0x8(%ebp),%ecx
801051c6:	8b 55 10             	mov    0x10(%ebp),%edx
801051c9:	8b 45 0c             	mov    0xc(%ebp),%eax
801051cc:	89 cb                	mov    %ecx,%ebx
801051ce:	89 df                	mov    %ebx,%edi
801051d0:	89 d1                	mov    %edx,%ecx
801051d2:	fc                   	cld    
801051d3:	f3 ab                	rep stos %eax,%es:(%edi)
801051d5:	89 ca                	mov    %ecx,%edx
801051d7:	89 fb                	mov    %edi,%ebx
801051d9:	89 5d 08             	mov    %ebx,0x8(%ebp)
801051dc:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
801051df:	90                   	nop
801051e0:	5b                   	pop    %ebx
801051e1:	5f                   	pop    %edi
801051e2:	5d                   	pop    %ebp
801051e3:	c3                   	ret    

801051e4 <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
801051e4:	55                   	push   %ebp
801051e5:	89 e5                	mov    %esp,%ebp
  if ((int)dst%4 == 0 && n%4 == 0){
801051e7:	8b 45 08             	mov    0x8(%ebp),%eax
801051ea:	83 e0 03             	and    $0x3,%eax
801051ed:	85 c0                	test   %eax,%eax
801051ef:	75 43                	jne    80105234 <memset+0x50>
801051f1:	8b 45 10             	mov    0x10(%ebp),%eax
801051f4:	83 e0 03             	and    $0x3,%eax
801051f7:	85 c0                	test   %eax,%eax
801051f9:	75 39                	jne    80105234 <memset+0x50>
    c &= 0xFF;
801051fb:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
80105202:	8b 45 10             	mov    0x10(%ebp),%eax
80105205:	c1 e8 02             	shr    $0x2,%eax
80105208:	89 c1                	mov    %eax,%ecx
8010520a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010520d:	c1 e0 18             	shl    $0x18,%eax
80105210:	89 c2                	mov    %eax,%edx
80105212:	8b 45 0c             	mov    0xc(%ebp),%eax
80105215:	c1 e0 10             	shl    $0x10,%eax
80105218:	09 c2                	or     %eax,%edx
8010521a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010521d:	c1 e0 08             	shl    $0x8,%eax
80105220:	09 d0                	or     %edx,%eax
80105222:	0b 45 0c             	or     0xc(%ebp),%eax
80105225:	51                   	push   %ecx
80105226:	50                   	push   %eax
80105227:	ff 75 08             	pushl  0x8(%ebp)
8010522a:	e8 8f ff ff ff       	call   801051be <stosl>
8010522f:	83 c4 0c             	add    $0xc,%esp
80105232:	eb 12                	jmp    80105246 <memset+0x62>
  } else
    stosb(dst, c, n);
80105234:	8b 45 10             	mov    0x10(%ebp),%eax
80105237:	50                   	push   %eax
80105238:	ff 75 0c             	pushl  0xc(%ebp)
8010523b:	ff 75 08             	pushl  0x8(%ebp)
8010523e:	e8 55 ff ff ff       	call   80105198 <stosb>
80105243:	83 c4 0c             	add    $0xc,%esp
  return dst;
80105246:	8b 45 08             	mov    0x8(%ebp),%eax
}
80105249:	c9                   	leave  
8010524a:	c3                   	ret    

8010524b <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
8010524b:	55                   	push   %ebp
8010524c:	89 e5                	mov    %esp,%ebp
8010524e:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;

  s1 = v1;
80105251:	8b 45 08             	mov    0x8(%ebp),%eax
80105254:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
80105257:	8b 45 0c             	mov    0xc(%ebp),%eax
8010525a:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
8010525d:	eb 30                	jmp    8010528f <memcmp+0x44>
    if(*s1 != *s2)
8010525f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105262:	0f b6 10             	movzbl (%eax),%edx
80105265:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105268:	0f b6 00             	movzbl (%eax),%eax
8010526b:	38 c2                	cmp    %al,%dl
8010526d:	74 18                	je     80105287 <memcmp+0x3c>
      return *s1 - *s2;
8010526f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105272:	0f b6 00             	movzbl (%eax),%eax
80105275:	0f b6 d0             	movzbl %al,%edx
80105278:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010527b:	0f b6 00             	movzbl (%eax),%eax
8010527e:	0f b6 c0             	movzbl %al,%eax
80105281:	29 c2                	sub    %eax,%edx
80105283:	89 d0                	mov    %edx,%eax
80105285:	eb 1a                	jmp    801052a1 <memcmp+0x56>
    s1++, s2++;
80105287:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
8010528b:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
{
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
8010528f:	8b 45 10             	mov    0x10(%ebp),%eax
80105292:	8d 50 ff             	lea    -0x1(%eax),%edx
80105295:	89 55 10             	mov    %edx,0x10(%ebp)
80105298:	85 c0                	test   %eax,%eax
8010529a:	75 c3                	jne    8010525f <memcmp+0x14>
    if(*s1 != *s2)
      return *s1 - *s2;
    s1++, s2++;
  }

  return 0;
8010529c:	b8 00 00 00 00       	mov    $0x0,%eax
}
801052a1:	c9                   	leave  
801052a2:	c3                   	ret    

801052a3 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
801052a3:	55                   	push   %ebp
801052a4:	89 e5                	mov    %esp,%ebp
801052a6:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
801052a9:	8b 45 0c             	mov    0xc(%ebp),%eax
801052ac:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
801052af:	8b 45 08             	mov    0x8(%ebp),%eax
801052b2:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
801052b5:	8b 45 fc             	mov    -0x4(%ebp),%eax
801052b8:	3b 45 f8             	cmp    -0x8(%ebp),%eax
801052bb:	73 54                	jae    80105311 <memmove+0x6e>
801052bd:	8b 55 fc             	mov    -0x4(%ebp),%edx
801052c0:	8b 45 10             	mov    0x10(%ebp),%eax
801052c3:	01 d0                	add    %edx,%eax
801052c5:	3b 45 f8             	cmp    -0x8(%ebp),%eax
801052c8:	76 47                	jbe    80105311 <memmove+0x6e>
    s += n;
801052ca:	8b 45 10             	mov    0x10(%ebp),%eax
801052cd:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
801052d0:	8b 45 10             	mov    0x10(%ebp),%eax
801052d3:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
801052d6:	eb 13                	jmp    801052eb <memmove+0x48>
      *--d = *--s;
801052d8:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
801052dc:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
801052e0:	8b 45 fc             	mov    -0x4(%ebp),%eax
801052e3:	0f b6 10             	movzbl (%eax),%edx
801052e6:	8b 45 f8             	mov    -0x8(%ebp),%eax
801052e9:	88 10                	mov    %dl,(%eax)
  s = src;
  d = dst;
  if(s < d && s + n > d){
    s += n;
    d += n;
    while(n-- > 0)
801052eb:	8b 45 10             	mov    0x10(%ebp),%eax
801052ee:	8d 50 ff             	lea    -0x1(%eax),%edx
801052f1:	89 55 10             	mov    %edx,0x10(%ebp)
801052f4:	85 c0                	test   %eax,%eax
801052f6:	75 e0                	jne    801052d8 <memmove+0x35>
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
801052f8:	eb 24                	jmp    8010531e <memmove+0x7b>
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
      *d++ = *s++;
801052fa:	8b 45 f8             	mov    -0x8(%ebp),%eax
801052fd:	8d 50 01             	lea    0x1(%eax),%edx
80105300:	89 55 f8             	mov    %edx,-0x8(%ebp)
80105303:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105306:	8d 4a 01             	lea    0x1(%edx),%ecx
80105309:	89 4d fc             	mov    %ecx,-0x4(%ebp)
8010530c:	0f b6 12             	movzbl (%edx),%edx
8010530f:	88 10                	mov    %dl,(%eax)
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
80105311:	8b 45 10             	mov    0x10(%ebp),%eax
80105314:	8d 50 ff             	lea    -0x1(%eax),%edx
80105317:	89 55 10             	mov    %edx,0x10(%ebp)
8010531a:	85 c0                	test   %eax,%eax
8010531c:	75 dc                	jne    801052fa <memmove+0x57>
      *d++ = *s++;

  return dst;
8010531e:	8b 45 08             	mov    0x8(%ebp),%eax
}
80105321:	c9                   	leave  
80105322:	c3                   	ret    

80105323 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
80105323:	55                   	push   %ebp
80105324:	89 e5                	mov    %esp,%ebp
  return memmove(dst, src, n);
80105326:	ff 75 10             	pushl  0x10(%ebp)
80105329:	ff 75 0c             	pushl  0xc(%ebp)
8010532c:	ff 75 08             	pushl  0x8(%ebp)
8010532f:	e8 6f ff ff ff       	call   801052a3 <memmove>
80105334:	83 c4 0c             	add    $0xc,%esp
}
80105337:	c9                   	leave  
80105338:	c3                   	ret    

80105339 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
80105339:	55                   	push   %ebp
8010533a:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
8010533c:	eb 0c                	jmp    8010534a <strncmp+0x11>
    n--, p++, q++;
8010533e:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80105342:	83 45 08 01          	addl   $0x1,0x8(%ebp)
80105346:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, uint n)
{
  while(n > 0 && *p && *p == *q)
8010534a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010534e:	74 1a                	je     8010536a <strncmp+0x31>
80105350:	8b 45 08             	mov    0x8(%ebp),%eax
80105353:	0f b6 00             	movzbl (%eax),%eax
80105356:	84 c0                	test   %al,%al
80105358:	74 10                	je     8010536a <strncmp+0x31>
8010535a:	8b 45 08             	mov    0x8(%ebp),%eax
8010535d:	0f b6 10             	movzbl (%eax),%edx
80105360:	8b 45 0c             	mov    0xc(%ebp),%eax
80105363:	0f b6 00             	movzbl (%eax),%eax
80105366:	38 c2                	cmp    %al,%dl
80105368:	74 d4                	je     8010533e <strncmp+0x5>
    n--, p++, q++;
  if(n == 0)
8010536a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010536e:	75 07                	jne    80105377 <strncmp+0x3e>
    return 0;
80105370:	b8 00 00 00 00       	mov    $0x0,%eax
80105375:	eb 16                	jmp    8010538d <strncmp+0x54>
  return (uchar)*p - (uchar)*q;
80105377:	8b 45 08             	mov    0x8(%ebp),%eax
8010537a:	0f b6 00             	movzbl (%eax),%eax
8010537d:	0f b6 d0             	movzbl %al,%edx
80105380:	8b 45 0c             	mov    0xc(%ebp),%eax
80105383:	0f b6 00             	movzbl (%eax),%eax
80105386:	0f b6 c0             	movzbl %al,%eax
80105389:	29 c2                	sub    %eax,%edx
8010538b:	89 d0                	mov    %edx,%eax
}
8010538d:	5d                   	pop    %ebp
8010538e:	c3                   	ret    

8010538f <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
8010538f:	55                   	push   %ebp
80105390:	89 e5                	mov    %esp,%ebp
80105392:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
80105395:	8b 45 08             	mov    0x8(%ebp),%eax
80105398:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
8010539b:	90                   	nop
8010539c:	8b 45 10             	mov    0x10(%ebp),%eax
8010539f:	8d 50 ff             	lea    -0x1(%eax),%edx
801053a2:	89 55 10             	mov    %edx,0x10(%ebp)
801053a5:	85 c0                	test   %eax,%eax
801053a7:	7e 2c                	jle    801053d5 <strncpy+0x46>
801053a9:	8b 45 08             	mov    0x8(%ebp),%eax
801053ac:	8d 50 01             	lea    0x1(%eax),%edx
801053af:	89 55 08             	mov    %edx,0x8(%ebp)
801053b2:	8b 55 0c             	mov    0xc(%ebp),%edx
801053b5:	8d 4a 01             	lea    0x1(%edx),%ecx
801053b8:	89 4d 0c             	mov    %ecx,0xc(%ebp)
801053bb:	0f b6 12             	movzbl (%edx),%edx
801053be:	88 10                	mov    %dl,(%eax)
801053c0:	0f b6 00             	movzbl (%eax),%eax
801053c3:	84 c0                	test   %al,%al
801053c5:	75 d5                	jne    8010539c <strncpy+0xd>
    ;
  while(n-- > 0)
801053c7:	eb 0c                	jmp    801053d5 <strncpy+0x46>
    *s++ = 0;
801053c9:	8b 45 08             	mov    0x8(%ebp),%eax
801053cc:	8d 50 01             	lea    0x1(%eax),%edx
801053cf:	89 55 08             	mov    %edx,0x8(%ebp)
801053d2:	c6 00 00             	movb   $0x0,(%eax)
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    ;
  while(n-- > 0)
801053d5:	8b 45 10             	mov    0x10(%ebp),%eax
801053d8:	8d 50 ff             	lea    -0x1(%eax),%edx
801053db:	89 55 10             	mov    %edx,0x10(%ebp)
801053de:	85 c0                	test   %eax,%eax
801053e0:	7f e7                	jg     801053c9 <strncpy+0x3a>
    *s++ = 0;
  return os;
801053e2:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801053e5:	c9                   	leave  
801053e6:	c3                   	ret    

801053e7 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
801053e7:	55                   	push   %ebp
801053e8:	89 e5                	mov    %esp,%ebp
801053ea:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
801053ed:	8b 45 08             	mov    0x8(%ebp),%eax
801053f0:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
801053f3:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801053f7:	7f 05                	jg     801053fe <safestrcpy+0x17>
    return os;
801053f9:	8b 45 fc             	mov    -0x4(%ebp),%eax
801053fc:	eb 31                	jmp    8010542f <safestrcpy+0x48>
  while(--n > 0 && (*s++ = *t++) != 0)
801053fe:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80105402:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105406:	7e 1e                	jle    80105426 <safestrcpy+0x3f>
80105408:	8b 45 08             	mov    0x8(%ebp),%eax
8010540b:	8d 50 01             	lea    0x1(%eax),%edx
8010540e:	89 55 08             	mov    %edx,0x8(%ebp)
80105411:	8b 55 0c             	mov    0xc(%ebp),%edx
80105414:	8d 4a 01             	lea    0x1(%edx),%ecx
80105417:	89 4d 0c             	mov    %ecx,0xc(%ebp)
8010541a:	0f b6 12             	movzbl (%edx),%edx
8010541d:	88 10                	mov    %dl,(%eax)
8010541f:	0f b6 00             	movzbl (%eax),%eax
80105422:	84 c0                	test   %al,%al
80105424:	75 d8                	jne    801053fe <safestrcpy+0x17>
    ;
  *s = 0;
80105426:	8b 45 08             	mov    0x8(%ebp),%eax
80105429:	c6 00 00             	movb   $0x0,(%eax)
  return os;
8010542c:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010542f:	c9                   	leave  
80105430:	c3                   	ret    

80105431 <strlen>:

int
strlen(const char *s)
{
80105431:	55                   	push   %ebp
80105432:	89 e5                	mov    %esp,%ebp
80105434:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
80105437:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
8010543e:	eb 04                	jmp    80105444 <strlen+0x13>
80105440:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105444:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105447:	8b 45 08             	mov    0x8(%ebp),%eax
8010544a:	01 d0                	add    %edx,%eax
8010544c:	0f b6 00             	movzbl (%eax),%eax
8010544f:	84 c0                	test   %al,%al
80105451:	75 ed                	jne    80105440 <strlen+0xf>
    ;
  return n;
80105453:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105456:	c9                   	leave  
80105457:	c3                   	ret    

80105458 <swtch>:
# Save current register context in old
# and then load register context from new.

.globl swtch
swtch:
  movl 4(%esp), %eax
80105458:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
8010545c:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
80105460:	55                   	push   %ebp
  pushl %ebx
80105461:	53                   	push   %ebx
  pushl %esi
80105462:	56                   	push   %esi
  pushl %edi
80105463:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
80105464:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
80105466:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
80105468:	5f                   	pop    %edi
  popl %esi
80105469:	5e                   	pop    %esi
  popl %ebx
8010546a:	5b                   	pop    %ebx
  popl %ebp
8010546b:	5d                   	pop    %ebp
  ret
8010546c:	c3                   	ret    

8010546d <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
8010546d:	55                   	push   %ebp
8010546e:	89 e5                	mov    %esp,%ebp
  //struct proc *curproc = myproc();
  //if(addr >= curproc->sz || addr+4 > curproc->sz)
  if (addr >= STACK_TOP || addr+4 > STACK_TOP)
80105470:	81 7d 08 fb ff ff 7f 	cmpl   $0x7ffffffb,0x8(%ebp)
80105477:	77 0d                	ja     80105486 <fetchint+0x19>
80105479:	8b 45 08             	mov    0x8(%ebp),%eax
8010547c:	83 c0 04             	add    $0x4,%eax
8010547f:	3d fc ff ff 7f       	cmp    $0x7ffffffc,%eax
80105484:	76 07                	jbe    8010548d <fetchint+0x20>
    return -1;
80105486:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010548b:	eb 0f                	jmp    8010549c <fetchint+0x2f>
  *ip = *(int*)(addr);
8010548d:	8b 45 08             	mov    0x8(%ebp),%eax
80105490:	8b 10                	mov    (%eax),%edx
80105492:	8b 45 0c             	mov    0xc(%ebp),%eax
80105495:	89 10                	mov    %edx,(%eax)
  return 0;
80105497:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010549c:	5d                   	pop    %ebp
8010549d:	c3                   	ret    

8010549e <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
8010549e:	55                   	push   %ebp
8010549f:	89 e5                	mov    %esp,%ebp
801054a1:	83 ec 10             	sub    $0x10,%esp
  char *s, *ep;

  //if(addr >= curproc->sz)
  if (addr >= STACK_TOP)
801054a4:	81 7d 08 fb ff ff 7f 	cmpl   $0x7ffffffb,0x8(%ebp)
801054ab:	76 07                	jbe    801054b4 <fetchstr+0x16>
    return -1;
801054ad:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801054b2:	eb 42                	jmp    801054f6 <fetchstr+0x58>
  *pp = (char*)addr;
801054b4:	8b 55 08             	mov    0x8(%ebp),%edx
801054b7:	8b 45 0c             	mov    0xc(%ebp),%eax
801054ba:	89 10                	mov    %edx,(%eax)
  ep = (char*)STACK_TOP;
801054bc:	c7 45 f8 fc ff ff 7f 	movl   $0x7ffffffc,-0x8(%ebp)
  for(s = *pp; s < ep; s++){
801054c3:	8b 45 0c             	mov    0xc(%ebp),%eax
801054c6:	8b 00                	mov    (%eax),%eax
801054c8:	89 45 fc             	mov    %eax,-0x4(%ebp)
801054cb:	eb 1c                	jmp    801054e9 <fetchstr+0x4b>
    if(*s == 0)
801054cd:	8b 45 fc             	mov    -0x4(%ebp),%eax
801054d0:	0f b6 00             	movzbl (%eax),%eax
801054d3:	84 c0                	test   %al,%al
801054d5:	75 0e                	jne    801054e5 <fetchstr+0x47>
      return s - *pp;
801054d7:	8b 55 fc             	mov    -0x4(%ebp),%edx
801054da:	8b 45 0c             	mov    0xc(%ebp),%eax
801054dd:	8b 00                	mov    (%eax),%eax
801054df:	29 c2                	sub    %eax,%edx
801054e1:	89 d0                	mov    %edx,%eax
801054e3:	eb 11                	jmp    801054f6 <fetchstr+0x58>
  //if(addr >= curproc->sz)
  if (addr >= STACK_TOP)
    return -1;
  *pp = (char*)addr;
  ep = (char*)STACK_TOP;
  for(s = *pp; s < ep; s++){
801054e5:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801054e9:	8b 45 fc             	mov    -0x4(%ebp),%eax
801054ec:	3b 45 f8             	cmp    -0x8(%ebp),%eax
801054ef:	72 dc                	jb     801054cd <fetchstr+0x2f>
    if(*s == 0)
      return s - *pp;
  }
  return -1;
801054f1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801054f6:	c9                   	leave  
801054f7:	c3                   	ret    

801054f8 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
801054f8:	55                   	push   %ebp
801054f9:	89 e5                	mov    %esp,%ebp
801054fb:	83 ec 08             	sub    $0x8,%esp
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
801054fe:	e8 81 ed ff ff       	call   80104284 <myproc>
80105503:	8b 40 20             	mov    0x20(%eax),%eax
80105506:	8b 40 44             	mov    0x44(%eax),%eax
80105509:	8b 55 08             	mov    0x8(%ebp),%edx
8010550c:	c1 e2 02             	shl    $0x2,%edx
8010550f:	01 d0                	add    %edx,%eax
80105511:	83 c0 04             	add    $0x4,%eax
80105514:	83 ec 08             	sub    $0x8,%esp
80105517:	ff 75 0c             	pushl  0xc(%ebp)
8010551a:	50                   	push   %eax
8010551b:	e8 4d ff ff ff       	call   8010546d <fetchint>
80105520:	83 c4 10             	add    $0x10,%esp
}
80105523:	c9                   	leave  
80105524:	c3                   	ret    

80105525 <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
80105525:	55                   	push   %ebp
80105526:	89 e5                	mov    %esp,%ebp
80105528:	83 ec 18             	sub    $0x18,%esp
  int i;
  //struct proc *curproc = myproc();
 
  if(argint(n, &i) < 0)
8010552b:	83 ec 08             	sub    $0x8,%esp
8010552e:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105531:	50                   	push   %eax
80105532:	ff 75 08             	pushl  0x8(%ebp)
80105535:	e8 be ff ff ff       	call   801054f8 <argint>
8010553a:	83 c4 10             	add    $0x10,%esp
8010553d:	85 c0                	test   %eax,%eax
8010553f:	79 07                	jns    80105548 <argptr+0x23>
    return -1;
80105541:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105546:	eb 37                	jmp    8010557f <argptr+0x5a>
  //if(size < 0 || (uint)i >= curproc->sz || (uint)i+size > curproc->sz)
  if (size < 0 || (uint)i >= STACK_TOP || (uint)i+size > STACK_TOP)
80105548:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010554c:	78 1b                	js     80105569 <argptr+0x44>
8010554e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105551:	3d fb ff ff 7f       	cmp    $0x7ffffffb,%eax
80105556:	77 11                	ja     80105569 <argptr+0x44>
80105558:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010555b:	89 c2                	mov    %eax,%edx
8010555d:	8b 45 10             	mov    0x10(%ebp),%eax
80105560:	01 d0                	add    %edx,%eax
80105562:	3d fc ff ff 7f       	cmp    $0x7ffffffc,%eax
80105567:	76 07                	jbe    80105570 <argptr+0x4b>
    return -1;
80105569:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010556e:	eb 0f                	jmp    8010557f <argptr+0x5a>
  *pp = (char*)i;
80105570:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105573:	89 c2                	mov    %eax,%edx
80105575:	8b 45 0c             	mov    0xc(%ebp),%eax
80105578:	89 10                	mov    %edx,(%eax)
  return 0;
8010557a:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010557f:	c9                   	leave  
80105580:	c3                   	ret    

80105581 <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
80105581:	55                   	push   %ebp
80105582:	89 e5                	mov    %esp,%ebp
80105584:	83 ec 18             	sub    $0x18,%esp
  int addr;
  if(argint(n, &addr) < 0)
80105587:	83 ec 08             	sub    $0x8,%esp
8010558a:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010558d:	50                   	push   %eax
8010558e:	ff 75 08             	pushl  0x8(%ebp)
80105591:	e8 62 ff ff ff       	call   801054f8 <argint>
80105596:	83 c4 10             	add    $0x10,%esp
80105599:	85 c0                	test   %eax,%eax
8010559b:	79 07                	jns    801055a4 <argstr+0x23>
    return -1;
8010559d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801055a2:	eb 12                	jmp    801055b6 <argstr+0x35>
  return fetchstr(addr, pp);
801055a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055a7:	83 ec 08             	sub    $0x8,%esp
801055aa:	ff 75 0c             	pushl  0xc(%ebp)
801055ad:	50                   	push   %eax
801055ae:	e8 eb fe ff ff       	call   8010549e <fetchstr>
801055b3:	83 c4 10             	add    $0x10,%esp
}
801055b6:	c9                   	leave  
801055b7:	c3                   	ret    

801055b8 <syscall>:
[SYS_shm_close] sys_shm_close
};

void
syscall(void)
{
801055b8:	55                   	push   %ebp
801055b9:	89 e5                	mov    %esp,%ebp
801055bb:	53                   	push   %ebx
801055bc:	83 ec 14             	sub    $0x14,%esp
  int num;
  struct proc *curproc = myproc();
801055bf:	e8 c0 ec ff ff       	call   80104284 <myproc>
801055c4:	89 45 f4             	mov    %eax,-0xc(%ebp)

  num = curproc->tf->eax;
801055c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055ca:	8b 40 20             	mov    0x20(%eax),%eax
801055cd:	8b 40 1c             	mov    0x1c(%eax),%eax
801055d0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
801055d3:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801055d7:	7e 2d                	jle    80105606 <syscall+0x4e>
801055d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801055dc:	83 f8 17             	cmp    $0x17,%eax
801055df:	77 25                	ja     80105606 <syscall+0x4e>
801055e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801055e4:	8b 04 85 20 b0 10 80 	mov    -0x7fef4fe0(,%eax,4),%eax
801055eb:	85 c0                	test   %eax,%eax
801055ed:	74 17                	je     80105606 <syscall+0x4e>
    curproc->tf->eax = syscalls[num]();
801055ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055f2:	8b 58 20             	mov    0x20(%eax),%ebx
801055f5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801055f8:	8b 04 85 20 b0 10 80 	mov    -0x7fef4fe0(,%eax,4),%eax
801055ff:	ff d0                	call   *%eax
80105601:	89 43 1c             	mov    %eax,0x1c(%ebx)
80105604:	eb 2b                	jmp    80105631 <syscall+0x79>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            curproc->pid, curproc->name, num);
80105606:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105609:	8d 50 74             	lea    0x74(%eax),%edx

  num = curproc->tf->eax;
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    curproc->tf->eax = syscalls[num]();
  } else {
    cprintf("%d %s: unknown sys call %d\n",
8010560c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010560f:	8b 40 18             	mov    0x18(%eax),%eax
80105612:	ff 75 f0             	pushl  -0x10(%ebp)
80105615:	52                   	push   %edx
80105616:	50                   	push   %eax
80105617:	68 0c 8a 10 80       	push   $0x80108a0c
8010561c:	e8 df ad ff ff       	call   80100400 <cprintf>
80105621:	83 c4 10             	add    $0x10,%esp
            curproc->pid, curproc->name, num);
    curproc->tf->eax = -1;
80105624:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105627:	8b 40 20             	mov    0x20(%eax),%eax
8010562a:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
80105631:	90                   	nop
80105632:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80105635:	c9                   	leave  
80105636:	c3                   	ret    

80105637 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
80105637:	55                   	push   %ebp
80105638:	89 e5                	mov    %esp,%ebp
8010563a:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
8010563d:	83 ec 08             	sub    $0x8,%esp
80105640:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105643:	50                   	push   %eax
80105644:	ff 75 08             	pushl  0x8(%ebp)
80105647:	e8 ac fe ff ff       	call   801054f8 <argint>
8010564c:	83 c4 10             	add    $0x10,%esp
8010564f:	85 c0                	test   %eax,%eax
80105651:	79 07                	jns    8010565a <argfd+0x23>
    return -1;
80105653:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105658:	eb 50                	jmp    801056aa <argfd+0x73>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
8010565a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010565d:	85 c0                	test   %eax,%eax
8010565f:	78 21                	js     80105682 <argfd+0x4b>
80105661:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105664:	83 f8 0f             	cmp    $0xf,%eax
80105667:	7f 19                	jg     80105682 <argfd+0x4b>
80105669:	e8 16 ec ff ff       	call   80104284 <myproc>
8010566e:	89 c2                	mov    %eax,%edx
80105670:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105673:	83 c0 0c             	add    $0xc,%eax
80105676:	8b 04 82             	mov    (%edx,%eax,4),%eax
80105679:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010567c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105680:	75 07                	jne    80105689 <argfd+0x52>
    return -1;
80105682:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105687:	eb 21                	jmp    801056aa <argfd+0x73>
  if(pfd)
80105689:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
8010568d:	74 08                	je     80105697 <argfd+0x60>
    *pfd = fd;
8010568f:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105692:	8b 45 0c             	mov    0xc(%ebp),%eax
80105695:	89 10                	mov    %edx,(%eax)
  if(pf)
80105697:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010569b:	74 08                	je     801056a5 <argfd+0x6e>
    *pf = f;
8010569d:	8b 45 10             	mov    0x10(%ebp),%eax
801056a0:	8b 55 f4             	mov    -0xc(%ebp),%edx
801056a3:	89 10                	mov    %edx,(%eax)
  return 0;
801056a5:	b8 00 00 00 00       	mov    $0x0,%eax
}
801056aa:	c9                   	leave  
801056ab:	c3                   	ret    

801056ac <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
801056ac:	55                   	push   %ebp
801056ad:	89 e5                	mov    %esp,%ebp
801056af:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct proc *curproc = myproc();
801056b2:	e8 cd eb ff ff       	call   80104284 <myproc>
801056b7:	89 45 f0             	mov    %eax,-0x10(%ebp)

  for(fd = 0; fd < NOFILE; fd++){
801056ba:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801056c1:	eb 28                	jmp    801056eb <fdalloc+0x3f>
    if(curproc->ofile[fd] == 0){
801056c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801056c6:	8b 55 f4             	mov    -0xc(%ebp),%edx
801056c9:	83 c2 0c             	add    $0xc,%edx
801056cc:	8b 04 90             	mov    (%eax,%edx,4),%eax
801056cf:	85 c0                	test   %eax,%eax
801056d1:	75 14                	jne    801056e7 <fdalloc+0x3b>
      curproc->ofile[fd] = f;
801056d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801056d6:	8b 55 f4             	mov    -0xc(%ebp),%edx
801056d9:	8d 4a 0c             	lea    0xc(%edx),%ecx
801056dc:	8b 55 08             	mov    0x8(%ebp),%edx
801056df:	89 14 88             	mov    %edx,(%eax,%ecx,4)
      return fd;
801056e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801056e5:	eb 0f                	jmp    801056f6 <fdalloc+0x4a>
fdalloc(struct file *f)
{
  int fd;
  struct proc *curproc = myproc();

  for(fd = 0; fd < NOFILE; fd++){
801056e7:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801056eb:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
801056ef:	7e d2                	jle    801056c3 <fdalloc+0x17>
    if(curproc->ofile[fd] == 0){
      curproc->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
801056f1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801056f6:	c9                   	leave  
801056f7:	c3                   	ret    

801056f8 <sys_dup>:

int
sys_dup(void)
{
801056f8:	55                   	push   %ebp
801056f9:	89 e5                	mov    %esp,%ebp
801056fb:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int fd;

  if(argfd(0, 0, &f) < 0)
801056fe:	83 ec 04             	sub    $0x4,%esp
80105701:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105704:	50                   	push   %eax
80105705:	6a 00                	push   $0x0
80105707:	6a 00                	push   $0x0
80105709:	e8 29 ff ff ff       	call   80105637 <argfd>
8010570e:	83 c4 10             	add    $0x10,%esp
80105711:	85 c0                	test   %eax,%eax
80105713:	79 07                	jns    8010571c <sys_dup+0x24>
    return -1;
80105715:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010571a:	eb 31                	jmp    8010574d <sys_dup+0x55>
  if((fd=fdalloc(f)) < 0)
8010571c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010571f:	83 ec 0c             	sub    $0xc,%esp
80105722:	50                   	push   %eax
80105723:	e8 84 ff ff ff       	call   801056ac <fdalloc>
80105728:	83 c4 10             	add    $0x10,%esp
8010572b:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010572e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105732:	79 07                	jns    8010573b <sys_dup+0x43>
    return -1;
80105734:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105739:	eb 12                	jmp    8010574d <sys_dup+0x55>
  filedup(f);
8010573b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010573e:	83 ec 0c             	sub    $0xc,%esp
80105741:	50                   	push   %eax
80105742:	e8 10 b9 ff ff       	call   80101057 <filedup>
80105747:	83 c4 10             	add    $0x10,%esp
  return fd;
8010574a:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010574d:	c9                   	leave  
8010574e:	c3                   	ret    

8010574f <sys_read>:

int
sys_read(void)
{
8010574f:	55                   	push   %ebp
80105750:	89 e5                	mov    %esp,%ebp
80105752:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105755:	83 ec 04             	sub    $0x4,%esp
80105758:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010575b:	50                   	push   %eax
8010575c:	6a 00                	push   $0x0
8010575e:	6a 00                	push   $0x0
80105760:	e8 d2 fe ff ff       	call   80105637 <argfd>
80105765:	83 c4 10             	add    $0x10,%esp
80105768:	85 c0                	test   %eax,%eax
8010576a:	78 2e                	js     8010579a <sys_read+0x4b>
8010576c:	83 ec 08             	sub    $0x8,%esp
8010576f:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105772:	50                   	push   %eax
80105773:	6a 02                	push   $0x2
80105775:	e8 7e fd ff ff       	call   801054f8 <argint>
8010577a:	83 c4 10             	add    $0x10,%esp
8010577d:	85 c0                	test   %eax,%eax
8010577f:	78 19                	js     8010579a <sys_read+0x4b>
80105781:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105784:	83 ec 04             	sub    $0x4,%esp
80105787:	50                   	push   %eax
80105788:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010578b:	50                   	push   %eax
8010578c:	6a 01                	push   $0x1
8010578e:	e8 92 fd ff ff       	call   80105525 <argptr>
80105793:	83 c4 10             	add    $0x10,%esp
80105796:	85 c0                	test   %eax,%eax
80105798:	79 07                	jns    801057a1 <sys_read+0x52>
    return -1;
8010579a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010579f:	eb 17                	jmp    801057b8 <sys_read+0x69>
  return fileread(f, p, n);
801057a1:	8b 4d f0             	mov    -0x10(%ebp),%ecx
801057a4:	8b 55 ec             	mov    -0x14(%ebp),%edx
801057a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801057aa:	83 ec 04             	sub    $0x4,%esp
801057ad:	51                   	push   %ecx
801057ae:	52                   	push   %edx
801057af:	50                   	push   %eax
801057b0:	e8 32 ba ff ff       	call   801011e7 <fileread>
801057b5:	83 c4 10             	add    $0x10,%esp
}
801057b8:	c9                   	leave  
801057b9:	c3                   	ret    

801057ba <sys_write>:

int
sys_write(void)
{
801057ba:	55                   	push   %ebp
801057bb:	89 e5                	mov    %esp,%ebp
801057bd:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
801057c0:	83 ec 04             	sub    $0x4,%esp
801057c3:	8d 45 f4             	lea    -0xc(%ebp),%eax
801057c6:	50                   	push   %eax
801057c7:	6a 00                	push   $0x0
801057c9:	6a 00                	push   $0x0
801057cb:	e8 67 fe ff ff       	call   80105637 <argfd>
801057d0:	83 c4 10             	add    $0x10,%esp
801057d3:	85 c0                	test   %eax,%eax
801057d5:	78 2e                	js     80105805 <sys_write+0x4b>
801057d7:	83 ec 08             	sub    $0x8,%esp
801057da:	8d 45 f0             	lea    -0x10(%ebp),%eax
801057dd:	50                   	push   %eax
801057de:	6a 02                	push   $0x2
801057e0:	e8 13 fd ff ff       	call   801054f8 <argint>
801057e5:	83 c4 10             	add    $0x10,%esp
801057e8:	85 c0                	test   %eax,%eax
801057ea:	78 19                	js     80105805 <sys_write+0x4b>
801057ec:	8b 45 f0             	mov    -0x10(%ebp),%eax
801057ef:	83 ec 04             	sub    $0x4,%esp
801057f2:	50                   	push   %eax
801057f3:	8d 45 ec             	lea    -0x14(%ebp),%eax
801057f6:	50                   	push   %eax
801057f7:	6a 01                	push   $0x1
801057f9:	e8 27 fd ff ff       	call   80105525 <argptr>
801057fe:	83 c4 10             	add    $0x10,%esp
80105801:	85 c0                	test   %eax,%eax
80105803:	79 07                	jns    8010580c <sys_write+0x52>
    return -1;
80105805:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010580a:	eb 17                	jmp    80105823 <sys_write+0x69>
  return filewrite(f, p, n);
8010580c:	8b 4d f0             	mov    -0x10(%ebp),%ecx
8010580f:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105812:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105815:	83 ec 04             	sub    $0x4,%esp
80105818:	51                   	push   %ecx
80105819:	52                   	push   %edx
8010581a:	50                   	push   %eax
8010581b:	e8 7f ba ff ff       	call   8010129f <filewrite>
80105820:	83 c4 10             	add    $0x10,%esp
}
80105823:	c9                   	leave  
80105824:	c3                   	ret    

80105825 <sys_close>:

int
sys_close(void)
{
80105825:	55                   	push   %ebp
80105826:	89 e5                	mov    %esp,%ebp
80105828:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argfd(0, &fd, &f) < 0)
8010582b:	83 ec 04             	sub    $0x4,%esp
8010582e:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105831:	50                   	push   %eax
80105832:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105835:	50                   	push   %eax
80105836:	6a 00                	push   $0x0
80105838:	e8 fa fd ff ff       	call   80105637 <argfd>
8010583d:	83 c4 10             	add    $0x10,%esp
80105840:	85 c0                	test   %eax,%eax
80105842:	79 07                	jns    8010584b <sys_close+0x26>
    return -1;
80105844:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105849:	eb 28                	jmp    80105873 <sys_close+0x4e>
  myproc()->ofile[fd] = 0;
8010584b:	e8 34 ea ff ff       	call   80104284 <myproc>
80105850:	89 c2                	mov    %eax,%edx
80105852:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105855:	83 c0 0c             	add    $0xc,%eax
80105858:	c7 04 82 00 00 00 00 	movl   $0x0,(%edx,%eax,4)
  fileclose(f);
8010585f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105862:	83 ec 0c             	sub    $0xc,%esp
80105865:	50                   	push   %eax
80105866:	e8 3d b8 ff ff       	call   801010a8 <fileclose>
8010586b:	83 c4 10             	add    $0x10,%esp
  return 0;
8010586e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105873:	c9                   	leave  
80105874:	c3                   	ret    

80105875 <sys_fstat>:

int
sys_fstat(void)
{
80105875:	55                   	push   %ebp
80105876:	89 e5                	mov    %esp,%ebp
80105878:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  struct stat *st;

  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
8010587b:	83 ec 04             	sub    $0x4,%esp
8010587e:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105881:	50                   	push   %eax
80105882:	6a 00                	push   $0x0
80105884:	6a 00                	push   $0x0
80105886:	e8 ac fd ff ff       	call   80105637 <argfd>
8010588b:	83 c4 10             	add    $0x10,%esp
8010588e:	85 c0                	test   %eax,%eax
80105890:	78 17                	js     801058a9 <sys_fstat+0x34>
80105892:	83 ec 04             	sub    $0x4,%esp
80105895:	6a 14                	push   $0x14
80105897:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010589a:	50                   	push   %eax
8010589b:	6a 01                	push   $0x1
8010589d:	e8 83 fc ff ff       	call   80105525 <argptr>
801058a2:	83 c4 10             	add    $0x10,%esp
801058a5:	85 c0                	test   %eax,%eax
801058a7:	79 07                	jns    801058b0 <sys_fstat+0x3b>
    return -1;
801058a9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801058ae:	eb 13                	jmp    801058c3 <sys_fstat+0x4e>
  return filestat(f, st);
801058b0:	8b 55 f0             	mov    -0x10(%ebp),%edx
801058b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801058b6:	83 ec 08             	sub    $0x8,%esp
801058b9:	52                   	push   %edx
801058ba:	50                   	push   %eax
801058bb:	e8 d0 b8 ff ff       	call   80101190 <filestat>
801058c0:	83 c4 10             	add    $0x10,%esp
}
801058c3:	c9                   	leave  
801058c4:	c3                   	ret    

801058c5 <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
801058c5:	55                   	push   %ebp
801058c6:	89 e5                	mov    %esp,%ebp
801058c8:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
801058cb:	83 ec 08             	sub    $0x8,%esp
801058ce:	8d 45 d8             	lea    -0x28(%ebp),%eax
801058d1:	50                   	push   %eax
801058d2:	6a 00                	push   $0x0
801058d4:	e8 a8 fc ff ff       	call   80105581 <argstr>
801058d9:	83 c4 10             	add    $0x10,%esp
801058dc:	85 c0                	test   %eax,%eax
801058de:	78 15                	js     801058f5 <sys_link+0x30>
801058e0:	83 ec 08             	sub    $0x8,%esp
801058e3:	8d 45 dc             	lea    -0x24(%ebp),%eax
801058e6:	50                   	push   %eax
801058e7:	6a 01                	push   $0x1
801058e9:	e8 93 fc ff ff       	call   80105581 <argstr>
801058ee:	83 c4 10             	add    $0x10,%esp
801058f1:	85 c0                	test   %eax,%eax
801058f3:	79 0a                	jns    801058ff <sys_link+0x3a>
    return -1;
801058f5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801058fa:	e9 68 01 00 00       	jmp    80105a67 <sys_link+0x1a2>

  begin_op();
801058ff:	e8 28 dc ff ff       	call   8010352c <begin_op>
  if((ip = namei(old)) == 0){
80105904:	8b 45 d8             	mov    -0x28(%ebp),%eax
80105907:	83 ec 0c             	sub    $0xc,%esp
8010590a:	50                   	push   %eax
8010590b:	e8 37 cc ff ff       	call   80102547 <namei>
80105910:	83 c4 10             	add    $0x10,%esp
80105913:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105916:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010591a:	75 0f                	jne    8010592b <sys_link+0x66>
    end_op();
8010591c:	e8 97 dc ff ff       	call   801035b8 <end_op>
    return -1;
80105921:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105926:	e9 3c 01 00 00       	jmp    80105a67 <sys_link+0x1a2>
  }

  ilock(ip);
8010592b:	83 ec 0c             	sub    $0xc,%esp
8010592e:	ff 75 f4             	pushl  -0xc(%ebp)
80105931:	e8 d1 c0 ff ff       	call   80101a07 <ilock>
80105936:	83 c4 10             	add    $0x10,%esp
  if(ip->type == T_DIR){
80105939:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010593c:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105940:	66 83 f8 01          	cmp    $0x1,%ax
80105944:	75 1d                	jne    80105963 <sys_link+0x9e>
    iunlockput(ip);
80105946:	83 ec 0c             	sub    $0xc,%esp
80105949:	ff 75 f4             	pushl  -0xc(%ebp)
8010594c:	e8 e7 c2 ff ff       	call   80101c38 <iunlockput>
80105951:	83 c4 10             	add    $0x10,%esp
    end_op();
80105954:	e8 5f dc ff ff       	call   801035b8 <end_op>
    return -1;
80105959:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010595e:	e9 04 01 00 00       	jmp    80105a67 <sys_link+0x1a2>
  }

  ip->nlink++;
80105963:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105966:	0f b7 40 56          	movzwl 0x56(%eax),%eax
8010596a:	83 c0 01             	add    $0x1,%eax
8010596d:	89 c2                	mov    %eax,%edx
8010596f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105972:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
80105976:	83 ec 0c             	sub    $0xc,%esp
80105979:	ff 75 f4             	pushl  -0xc(%ebp)
8010597c:	e8 a9 be ff ff       	call   8010182a <iupdate>
80105981:	83 c4 10             	add    $0x10,%esp
  iunlock(ip);
80105984:	83 ec 0c             	sub    $0xc,%esp
80105987:	ff 75 f4             	pushl  -0xc(%ebp)
8010598a:	e8 8b c1 ff ff       	call   80101b1a <iunlock>
8010598f:	83 c4 10             	add    $0x10,%esp

  if((dp = nameiparent(new, name)) == 0)
80105992:	8b 45 dc             	mov    -0x24(%ebp),%eax
80105995:	83 ec 08             	sub    $0x8,%esp
80105998:	8d 55 e2             	lea    -0x1e(%ebp),%edx
8010599b:	52                   	push   %edx
8010599c:	50                   	push   %eax
8010599d:	e8 c1 cb ff ff       	call   80102563 <nameiparent>
801059a2:	83 c4 10             	add    $0x10,%esp
801059a5:	89 45 f0             	mov    %eax,-0x10(%ebp)
801059a8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801059ac:	74 71                	je     80105a1f <sys_link+0x15a>
    goto bad;
  ilock(dp);
801059ae:	83 ec 0c             	sub    $0xc,%esp
801059b1:	ff 75 f0             	pushl  -0x10(%ebp)
801059b4:	e8 4e c0 ff ff       	call   80101a07 <ilock>
801059b9:	83 c4 10             	add    $0x10,%esp
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
801059bc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059bf:	8b 10                	mov    (%eax),%edx
801059c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059c4:	8b 00                	mov    (%eax),%eax
801059c6:	39 c2                	cmp    %eax,%edx
801059c8:	75 1d                	jne    801059e7 <sys_link+0x122>
801059ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059cd:	8b 40 04             	mov    0x4(%eax),%eax
801059d0:	83 ec 04             	sub    $0x4,%esp
801059d3:	50                   	push   %eax
801059d4:	8d 45 e2             	lea    -0x1e(%ebp),%eax
801059d7:	50                   	push   %eax
801059d8:	ff 75 f0             	pushl  -0x10(%ebp)
801059db:	e8 cc c8 ff ff       	call   801022ac <dirlink>
801059e0:	83 c4 10             	add    $0x10,%esp
801059e3:	85 c0                	test   %eax,%eax
801059e5:	79 10                	jns    801059f7 <sys_link+0x132>
    iunlockput(dp);
801059e7:	83 ec 0c             	sub    $0xc,%esp
801059ea:	ff 75 f0             	pushl  -0x10(%ebp)
801059ed:	e8 46 c2 ff ff       	call   80101c38 <iunlockput>
801059f2:	83 c4 10             	add    $0x10,%esp
    goto bad;
801059f5:	eb 29                	jmp    80105a20 <sys_link+0x15b>
  }
  iunlockput(dp);
801059f7:	83 ec 0c             	sub    $0xc,%esp
801059fa:	ff 75 f0             	pushl  -0x10(%ebp)
801059fd:	e8 36 c2 ff ff       	call   80101c38 <iunlockput>
80105a02:	83 c4 10             	add    $0x10,%esp
  iput(ip);
80105a05:	83 ec 0c             	sub    $0xc,%esp
80105a08:	ff 75 f4             	pushl  -0xc(%ebp)
80105a0b:	e8 58 c1 ff ff       	call   80101b68 <iput>
80105a10:	83 c4 10             	add    $0x10,%esp

  end_op();
80105a13:	e8 a0 db ff ff       	call   801035b8 <end_op>

  return 0;
80105a18:	b8 00 00 00 00       	mov    $0x0,%eax
80105a1d:	eb 48                	jmp    80105a67 <sys_link+0x1a2>
  ip->nlink++;
  iupdate(ip);
  iunlock(ip);

  if((dp = nameiparent(new, name)) == 0)
    goto bad;
80105a1f:	90                   	nop
  end_op();

  return 0;

bad:
  ilock(ip);
80105a20:	83 ec 0c             	sub    $0xc,%esp
80105a23:	ff 75 f4             	pushl  -0xc(%ebp)
80105a26:	e8 dc bf ff ff       	call   80101a07 <ilock>
80105a2b:	83 c4 10             	add    $0x10,%esp
  ip->nlink--;
80105a2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a31:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105a35:	83 e8 01             	sub    $0x1,%eax
80105a38:	89 c2                	mov    %eax,%edx
80105a3a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a3d:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
80105a41:	83 ec 0c             	sub    $0xc,%esp
80105a44:	ff 75 f4             	pushl  -0xc(%ebp)
80105a47:	e8 de bd ff ff       	call   8010182a <iupdate>
80105a4c:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
80105a4f:	83 ec 0c             	sub    $0xc,%esp
80105a52:	ff 75 f4             	pushl  -0xc(%ebp)
80105a55:	e8 de c1 ff ff       	call   80101c38 <iunlockput>
80105a5a:	83 c4 10             	add    $0x10,%esp
  end_op();
80105a5d:	e8 56 db ff ff       	call   801035b8 <end_op>
  return -1;
80105a62:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105a67:	c9                   	leave  
80105a68:	c3                   	ret    

80105a69 <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
80105a69:	55                   	push   %ebp
80105a6a:	89 e5                	mov    %esp,%ebp
80105a6c:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105a6f:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
80105a76:	eb 40                	jmp    80105ab8 <isdirempty+0x4f>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105a78:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a7b:	6a 10                	push   $0x10
80105a7d:	50                   	push   %eax
80105a7e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105a81:	50                   	push   %eax
80105a82:	ff 75 08             	pushl  0x8(%ebp)
80105a85:	e8 6e c4 ff ff       	call   80101ef8 <readi>
80105a8a:	83 c4 10             	add    $0x10,%esp
80105a8d:	83 f8 10             	cmp    $0x10,%eax
80105a90:	74 0d                	je     80105a9f <isdirempty+0x36>
      panic("isdirempty: readi");
80105a92:	83 ec 0c             	sub    $0xc,%esp
80105a95:	68 28 8a 10 80       	push   $0x80108a28
80105a9a:	e8 01 ab ff ff       	call   801005a0 <panic>
    if(de.inum != 0)
80105a9f:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
80105aa3:	66 85 c0             	test   %ax,%ax
80105aa6:	74 07                	je     80105aaf <isdirempty+0x46>
      return 0;
80105aa8:	b8 00 00 00 00       	mov    $0x0,%eax
80105aad:	eb 1b                	jmp    80105aca <isdirempty+0x61>
isdirempty(struct inode *dp)
{
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105aaf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ab2:	83 c0 10             	add    $0x10,%eax
80105ab5:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105ab8:	8b 45 08             	mov    0x8(%ebp),%eax
80105abb:	8b 50 58             	mov    0x58(%eax),%edx
80105abe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ac1:	39 c2                	cmp    %eax,%edx
80105ac3:	77 b3                	ja     80105a78 <isdirempty+0xf>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("isdirempty: readi");
    if(de.inum != 0)
      return 0;
  }
  return 1;
80105ac5:	b8 01 00 00 00       	mov    $0x1,%eax
}
80105aca:	c9                   	leave  
80105acb:	c3                   	ret    

80105acc <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
80105acc:	55                   	push   %ebp
80105acd:	89 e5                	mov    %esp,%ebp
80105acf:	83 ec 38             	sub    $0x38,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
80105ad2:	83 ec 08             	sub    $0x8,%esp
80105ad5:	8d 45 cc             	lea    -0x34(%ebp),%eax
80105ad8:	50                   	push   %eax
80105ad9:	6a 00                	push   $0x0
80105adb:	e8 a1 fa ff ff       	call   80105581 <argstr>
80105ae0:	83 c4 10             	add    $0x10,%esp
80105ae3:	85 c0                	test   %eax,%eax
80105ae5:	79 0a                	jns    80105af1 <sys_unlink+0x25>
    return -1;
80105ae7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105aec:	e9 bc 01 00 00       	jmp    80105cad <sys_unlink+0x1e1>

  begin_op();
80105af1:	e8 36 da ff ff       	call   8010352c <begin_op>
  if((dp = nameiparent(path, name)) == 0){
80105af6:	8b 45 cc             	mov    -0x34(%ebp),%eax
80105af9:	83 ec 08             	sub    $0x8,%esp
80105afc:	8d 55 d2             	lea    -0x2e(%ebp),%edx
80105aff:	52                   	push   %edx
80105b00:	50                   	push   %eax
80105b01:	e8 5d ca ff ff       	call   80102563 <nameiparent>
80105b06:	83 c4 10             	add    $0x10,%esp
80105b09:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105b0c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105b10:	75 0f                	jne    80105b21 <sys_unlink+0x55>
    end_op();
80105b12:	e8 a1 da ff ff       	call   801035b8 <end_op>
    return -1;
80105b17:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b1c:	e9 8c 01 00 00       	jmp    80105cad <sys_unlink+0x1e1>
  }

  ilock(dp);
80105b21:	83 ec 0c             	sub    $0xc,%esp
80105b24:	ff 75 f4             	pushl  -0xc(%ebp)
80105b27:	e8 db be ff ff       	call   80101a07 <ilock>
80105b2c:	83 c4 10             	add    $0x10,%esp

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
80105b2f:	83 ec 08             	sub    $0x8,%esp
80105b32:	68 3a 8a 10 80       	push   $0x80108a3a
80105b37:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105b3a:	50                   	push   %eax
80105b3b:	e8 97 c6 ff ff       	call   801021d7 <namecmp>
80105b40:	83 c4 10             	add    $0x10,%esp
80105b43:	85 c0                	test   %eax,%eax
80105b45:	0f 84 4a 01 00 00    	je     80105c95 <sys_unlink+0x1c9>
80105b4b:	83 ec 08             	sub    $0x8,%esp
80105b4e:	68 3c 8a 10 80       	push   $0x80108a3c
80105b53:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105b56:	50                   	push   %eax
80105b57:	e8 7b c6 ff ff       	call   801021d7 <namecmp>
80105b5c:	83 c4 10             	add    $0x10,%esp
80105b5f:	85 c0                	test   %eax,%eax
80105b61:	0f 84 2e 01 00 00    	je     80105c95 <sys_unlink+0x1c9>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
80105b67:	83 ec 04             	sub    $0x4,%esp
80105b6a:	8d 45 c8             	lea    -0x38(%ebp),%eax
80105b6d:	50                   	push   %eax
80105b6e:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105b71:	50                   	push   %eax
80105b72:	ff 75 f4             	pushl  -0xc(%ebp)
80105b75:	e8 78 c6 ff ff       	call   801021f2 <dirlookup>
80105b7a:	83 c4 10             	add    $0x10,%esp
80105b7d:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105b80:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105b84:	0f 84 0a 01 00 00    	je     80105c94 <sys_unlink+0x1c8>
    goto bad;
  ilock(ip);
80105b8a:	83 ec 0c             	sub    $0xc,%esp
80105b8d:	ff 75 f0             	pushl  -0x10(%ebp)
80105b90:	e8 72 be ff ff       	call   80101a07 <ilock>
80105b95:	83 c4 10             	add    $0x10,%esp

  if(ip->nlink < 1)
80105b98:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b9b:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105b9f:	66 85 c0             	test   %ax,%ax
80105ba2:	7f 0d                	jg     80105bb1 <sys_unlink+0xe5>
    panic("unlink: nlink < 1");
80105ba4:	83 ec 0c             	sub    $0xc,%esp
80105ba7:	68 3f 8a 10 80       	push   $0x80108a3f
80105bac:	e8 ef a9 ff ff       	call   801005a0 <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
80105bb1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105bb4:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105bb8:	66 83 f8 01          	cmp    $0x1,%ax
80105bbc:	75 25                	jne    80105be3 <sys_unlink+0x117>
80105bbe:	83 ec 0c             	sub    $0xc,%esp
80105bc1:	ff 75 f0             	pushl  -0x10(%ebp)
80105bc4:	e8 a0 fe ff ff       	call   80105a69 <isdirempty>
80105bc9:	83 c4 10             	add    $0x10,%esp
80105bcc:	85 c0                	test   %eax,%eax
80105bce:	75 13                	jne    80105be3 <sys_unlink+0x117>
    iunlockput(ip);
80105bd0:	83 ec 0c             	sub    $0xc,%esp
80105bd3:	ff 75 f0             	pushl  -0x10(%ebp)
80105bd6:	e8 5d c0 ff ff       	call   80101c38 <iunlockput>
80105bdb:	83 c4 10             	add    $0x10,%esp
    goto bad;
80105bde:	e9 b2 00 00 00       	jmp    80105c95 <sys_unlink+0x1c9>
  }

  memset(&de, 0, sizeof(de));
80105be3:	83 ec 04             	sub    $0x4,%esp
80105be6:	6a 10                	push   $0x10
80105be8:	6a 00                	push   $0x0
80105bea:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105bed:	50                   	push   %eax
80105bee:	e8 f1 f5 ff ff       	call   801051e4 <memset>
80105bf3:	83 c4 10             	add    $0x10,%esp
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105bf6:	8b 45 c8             	mov    -0x38(%ebp),%eax
80105bf9:	6a 10                	push   $0x10
80105bfb:	50                   	push   %eax
80105bfc:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105bff:	50                   	push   %eax
80105c00:	ff 75 f4             	pushl  -0xc(%ebp)
80105c03:	e8 47 c4 ff ff       	call   8010204f <writei>
80105c08:	83 c4 10             	add    $0x10,%esp
80105c0b:	83 f8 10             	cmp    $0x10,%eax
80105c0e:	74 0d                	je     80105c1d <sys_unlink+0x151>
    panic("unlink: writei");
80105c10:	83 ec 0c             	sub    $0xc,%esp
80105c13:	68 51 8a 10 80       	push   $0x80108a51
80105c18:	e8 83 a9 ff ff       	call   801005a0 <panic>
  if(ip->type == T_DIR){
80105c1d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c20:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105c24:	66 83 f8 01          	cmp    $0x1,%ax
80105c28:	75 21                	jne    80105c4b <sys_unlink+0x17f>
    dp->nlink--;
80105c2a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c2d:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105c31:	83 e8 01             	sub    $0x1,%eax
80105c34:	89 c2                	mov    %eax,%edx
80105c36:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c39:	66 89 50 56          	mov    %dx,0x56(%eax)
    iupdate(dp);
80105c3d:	83 ec 0c             	sub    $0xc,%esp
80105c40:	ff 75 f4             	pushl  -0xc(%ebp)
80105c43:	e8 e2 bb ff ff       	call   8010182a <iupdate>
80105c48:	83 c4 10             	add    $0x10,%esp
  }
  iunlockput(dp);
80105c4b:	83 ec 0c             	sub    $0xc,%esp
80105c4e:	ff 75 f4             	pushl  -0xc(%ebp)
80105c51:	e8 e2 bf ff ff       	call   80101c38 <iunlockput>
80105c56:	83 c4 10             	add    $0x10,%esp

  ip->nlink--;
80105c59:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c5c:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105c60:	83 e8 01             	sub    $0x1,%eax
80105c63:	89 c2                	mov    %eax,%edx
80105c65:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c68:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
80105c6c:	83 ec 0c             	sub    $0xc,%esp
80105c6f:	ff 75 f0             	pushl  -0x10(%ebp)
80105c72:	e8 b3 bb ff ff       	call   8010182a <iupdate>
80105c77:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
80105c7a:	83 ec 0c             	sub    $0xc,%esp
80105c7d:	ff 75 f0             	pushl  -0x10(%ebp)
80105c80:	e8 b3 bf ff ff       	call   80101c38 <iunlockput>
80105c85:	83 c4 10             	add    $0x10,%esp

  end_op();
80105c88:	e8 2b d9 ff ff       	call   801035b8 <end_op>

  return 0;
80105c8d:	b8 00 00 00 00       	mov    $0x0,%eax
80105c92:	eb 19                	jmp    80105cad <sys_unlink+0x1e1>
  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
    goto bad;
80105c94:	90                   	nop
  end_op();

  return 0;

bad:
  iunlockput(dp);
80105c95:	83 ec 0c             	sub    $0xc,%esp
80105c98:	ff 75 f4             	pushl  -0xc(%ebp)
80105c9b:	e8 98 bf ff ff       	call   80101c38 <iunlockput>
80105ca0:	83 c4 10             	add    $0x10,%esp
  end_op();
80105ca3:	e8 10 d9 ff ff       	call   801035b8 <end_op>
  return -1;
80105ca8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105cad:	c9                   	leave  
80105cae:	c3                   	ret    

80105caf <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
80105caf:	55                   	push   %ebp
80105cb0:	89 e5                	mov    %esp,%ebp
80105cb2:	83 ec 38             	sub    $0x38,%esp
80105cb5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80105cb8:	8b 55 10             	mov    0x10(%ebp),%edx
80105cbb:	8b 45 14             	mov    0x14(%ebp),%eax
80105cbe:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
80105cc2:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
80105cc6:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
80105cca:	83 ec 08             	sub    $0x8,%esp
80105ccd:	8d 45 de             	lea    -0x22(%ebp),%eax
80105cd0:	50                   	push   %eax
80105cd1:	ff 75 08             	pushl  0x8(%ebp)
80105cd4:	e8 8a c8 ff ff       	call   80102563 <nameiparent>
80105cd9:	83 c4 10             	add    $0x10,%esp
80105cdc:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105cdf:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105ce3:	75 0a                	jne    80105cef <create+0x40>
    return 0;
80105ce5:	b8 00 00 00 00       	mov    $0x0,%eax
80105cea:	e9 90 01 00 00       	jmp    80105e7f <create+0x1d0>
  ilock(dp);
80105cef:	83 ec 0c             	sub    $0xc,%esp
80105cf2:	ff 75 f4             	pushl  -0xc(%ebp)
80105cf5:	e8 0d bd ff ff       	call   80101a07 <ilock>
80105cfa:	83 c4 10             	add    $0x10,%esp

  if((ip = dirlookup(dp, name, &off)) != 0){
80105cfd:	83 ec 04             	sub    $0x4,%esp
80105d00:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105d03:	50                   	push   %eax
80105d04:	8d 45 de             	lea    -0x22(%ebp),%eax
80105d07:	50                   	push   %eax
80105d08:	ff 75 f4             	pushl  -0xc(%ebp)
80105d0b:	e8 e2 c4 ff ff       	call   801021f2 <dirlookup>
80105d10:	83 c4 10             	add    $0x10,%esp
80105d13:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105d16:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105d1a:	74 50                	je     80105d6c <create+0xbd>
    iunlockput(dp);
80105d1c:	83 ec 0c             	sub    $0xc,%esp
80105d1f:	ff 75 f4             	pushl  -0xc(%ebp)
80105d22:	e8 11 bf ff ff       	call   80101c38 <iunlockput>
80105d27:	83 c4 10             	add    $0x10,%esp
    ilock(ip);
80105d2a:	83 ec 0c             	sub    $0xc,%esp
80105d2d:	ff 75 f0             	pushl  -0x10(%ebp)
80105d30:	e8 d2 bc ff ff       	call   80101a07 <ilock>
80105d35:	83 c4 10             	add    $0x10,%esp
    if(type == T_FILE && ip->type == T_FILE)
80105d38:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
80105d3d:	75 15                	jne    80105d54 <create+0xa5>
80105d3f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d42:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105d46:	66 83 f8 02          	cmp    $0x2,%ax
80105d4a:	75 08                	jne    80105d54 <create+0xa5>
      return ip;
80105d4c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d4f:	e9 2b 01 00 00       	jmp    80105e7f <create+0x1d0>
    iunlockput(ip);
80105d54:	83 ec 0c             	sub    $0xc,%esp
80105d57:	ff 75 f0             	pushl  -0x10(%ebp)
80105d5a:	e8 d9 be ff ff       	call   80101c38 <iunlockput>
80105d5f:	83 c4 10             	add    $0x10,%esp
    return 0;
80105d62:	b8 00 00 00 00       	mov    $0x0,%eax
80105d67:	e9 13 01 00 00       	jmp    80105e7f <create+0x1d0>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
80105d6c:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
80105d70:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d73:	8b 00                	mov    (%eax),%eax
80105d75:	83 ec 08             	sub    $0x8,%esp
80105d78:	52                   	push   %edx
80105d79:	50                   	push   %eax
80105d7a:	e8 d4 b9 ff ff       	call   80101753 <ialloc>
80105d7f:	83 c4 10             	add    $0x10,%esp
80105d82:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105d85:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105d89:	75 0d                	jne    80105d98 <create+0xe9>
    panic("create: ialloc");
80105d8b:	83 ec 0c             	sub    $0xc,%esp
80105d8e:	68 60 8a 10 80       	push   $0x80108a60
80105d93:	e8 08 a8 ff ff       	call   801005a0 <panic>

  ilock(ip);
80105d98:	83 ec 0c             	sub    $0xc,%esp
80105d9b:	ff 75 f0             	pushl  -0x10(%ebp)
80105d9e:	e8 64 bc ff ff       	call   80101a07 <ilock>
80105da3:	83 c4 10             	add    $0x10,%esp
  ip->major = major;
80105da6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105da9:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
80105dad:	66 89 50 52          	mov    %dx,0x52(%eax)
  ip->minor = minor;
80105db1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105db4:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
80105db8:	66 89 50 54          	mov    %dx,0x54(%eax)
  ip->nlink = 1;
80105dbc:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105dbf:	66 c7 40 56 01 00    	movw   $0x1,0x56(%eax)
  iupdate(ip);
80105dc5:	83 ec 0c             	sub    $0xc,%esp
80105dc8:	ff 75 f0             	pushl  -0x10(%ebp)
80105dcb:	e8 5a ba ff ff       	call   8010182a <iupdate>
80105dd0:	83 c4 10             	add    $0x10,%esp

  if(type == T_DIR){  // Create . and .. entries.
80105dd3:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
80105dd8:	75 6a                	jne    80105e44 <create+0x195>
    dp->nlink++;  // for ".."
80105dda:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ddd:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105de1:	83 c0 01             	add    $0x1,%eax
80105de4:	89 c2                	mov    %eax,%edx
80105de6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105de9:	66 89 50 56          	mov    %dx,0x56(%eax)
    iupdate(dp);
80105ded:	83 ec 0c             	sub    $0xc,%esp
80105df0:	ff 75 f4             	pushl  -0xc(%ebp)
80105df3:	e8 32 ba ff ff       	call   8010182a <iupdate>
80105df8:	83 c4 10             	add    $0x10,%esp
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
80105dfb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105dfe:	8b 40 04             	mov    0x4(%eax),%eax
80105e01:	83 ec 04             	sub    $0x4,%esp
80105e04:	50                   	push   %eax
80105e05:	68 3a 8a 10 80       	push   $0x80108a3a
80105e0a:	ff 75 f0             	pushl  -0x10(%ebp)
80105e0d:	e8 9a c4 ff ff       	call   801022ac <dirlink>
80105e12:	83 c4 10             	add    $0x10,%esp
80105e15:	85 c0                	test   %eax,%eax
80105e17:	78 1e                	js     80105e37 <create+0x188>
80105e19:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e1c:	8b 40 04             	mov    0x4(%eax),%eax
80105e1f:	83 ec 04             	sub    $0x4,%esp
80105e22:	50                   	push   %eax
80105e23:	68 3c 8a 10 80       	push   $0x80108a3c
80105e28:	ff 75 f0             	pushl  -0x10(%ebp)
80105e2b:	e8 7c c4 ff ff       	call   801022ac <dirlink>
80105e30:	83 c4 10             	add    $0x10,%esp
80105e33:	85 c0                	test   %eax,%eax
80105e35:	79 0d                	jns    80105e44 <create+0x195>
      panic("create dots");
80105e37:	83 ec 0c             	sub    $0xc,%esp
80105e3a:	68 6f 8a 10 80       	push   $0x80108a6f
80105e3f:	e8 5c a7 ff ff       	call   801005a0 <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
80105e44:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e47:	8b 40 04             	mov    0x4(%eax),%eax
80105e4a:	83 ec 04             	sub    $0x4,%esp
80105e4d:	50                   	push   %eax
80105e4e:	8d 45 de             	lea    -0x22(%ebp),%eax
80105e51:	50                   	push   %eax
80105e52:	ff 75 f4             	pushl  -0xc(%ebp)
80105e55:	e8 52 c4 ff ff       	call   801022ac <dirlink>
80105e5a:	83 c4 10             	add    $0x10,%esp
80105e5d:	85 c0                	test   %eax,%eax
80105e5f:	79 0d                	jns    80105e6e <create+0x1bf>
    panic("create: dirlink");
80105e61:	83 ec 0c             	sub    $0xc,%esp
80105e64:	68 7b 8a 10 80       	push   $0x80108a7b
80105e69:	e8 32 a7 ff ff       	call   801005a0 <panic>

  iunlockput(dp);
80105e6e:	83 ec 0c             	sub    $0xc,%esp
80105e71:	ff 75 f4             	pushl  -0xc(%ebp)
80105e74:	e8 bf bd ff ff       	call   80101c38 <iunlockput>
80105e79:	83 c4 10             	add    $0x10,%esp

  return ip;
80105e7c:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80105e7f:	c9                   	leave  
80105e80:	c3                   	ret    

80105e81 <sys_open>:

int
sys_open(void)
{
80105e81:	55                   	push   %ebp
80105e82:	89 e5                	mov    %esp,%ebp
80105e84:	83 ec 28             	sub    $0x28,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
80105e87:	83 ec 08             	sub    $0x8,%esp
80105e8a:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105e8d:	50                   	push   %eax
80105e8e:	6a 00                	push   $0x0
80105e90:	e8 ec f6 ff ff       	call   80105581 <argstr>
80105e95:	83 c4 10             	add    $0x10,%esp
80105e98:	85 c0                	test   %eax,%eax
80105e9a:	78 15                	js     80105eb1 <sys_open+0x30>
80105e9c:	83 ec 08             	sub    $0x8,%esp
80105e9f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105ea2:	50                   	push   %eax
80105ea3:	6a 01                	push   $0x1
80105ea5:	e8 4e f6 ff ff       	call   801054f8 <argint>
80105eaa:	83 c4 10             	add    $0x10,%esp
80105ead:	85 c0                	test   %eax,%eax
80105eaf:	79 0a                	jns    80105ebb <sys_open+0x3a>
    return -1;
80105eb1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105eb6:	e9 61 01 00 00       	jmp    8010601c <sys_open+0x19b>

  begin_op();
80105ebb:	e8 6c d6 ff ff       	call   8010352c <begin_op>

  if(omode & O_CREATE){
80105ec0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105ec3:	25 00 02 00 00       	and    $0x200,%eax
80105ec8:	85 c0                	test   %eax,%eax
80105eca:	74 2a                	je     80105ef6 <sys_open+0x75>
    ip = create(path, T_FILE, 0, 0);
80105ecc:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105ecf:	6a 00                	push   $0x0
80105ed1:	6a 00                	push   $0x0
80105ed3:	6a 02                	push   $0x2
80105ed5:	50                   	push   %eax
80105ed6:	e8 d4 fd ff ff       	call   80105caf <create>
80105edb:	83 c4 10             	add    $0x10,%esp
80105ede:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip == 0){
80105ee1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105ee5:	75 75                	jne    80105f5c <sys_open+0xdb>
      end_op();
80105ee7:	e8 cc d6 ff ff       	call   801035b8 <end_op>
      return -1;
80105eec:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ef1:	e9 26 01 00 00       	jmp    8010601c <sys_open+0x19b>
    }
  } else {
    if((ip = namei(path)) == 0){
80105ef6:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105ef9:	83 ec 0c             	sub    $0xc,%esp
80105efc:	50                   	push   %eax
80105efd:	e8 45 c6 ff ff       	call   80102547 <namei>
80105f02:	83 c4 10             	add    $0x10,%esp
80105f05:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105f08:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105f0c:	75 0f                	jne    80105f1d <sys_open+0x9c>
      end_op();
80105f0e:	e8 a5 d6 ff ff       	call   801035b8 <end_op>
      return -1;
80105f13:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f18:	e9 ff 00 00 00       	jmp    8010601c <sys_open+0x19b>
    }
    ilock(ip);
80105f1d:	83 ec 0c             	sub    $0xc,%esp
80105f20:	ff 75 f4             	pushl  -0xc(%ebp)
80105f23:	e8 df ba ff ff       	call   80101a07 <ilock>
80105f28:	83 c4 10             	add    $0x10,%esp
    if(ip->type == T_DIR && omode != O_RDONLY){
80105f2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f2e:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105f32:	66 83 f8 01          	cmp    $0x1,%ax
80105f36:	75 24                	jne    80105f5c <sys_open+0xdb>
80105f38:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105f3b:	85 c0                	test   %eax,%eax
80105f3d:	74 1d                	je     80105f5c <sys_open+0xdb>
      iunlockput(ip);
80105f3f:	83 ec 0c             	sub    $0xc,%esp
80105f42:	ff 75 f4             	pushl  -0xc(%ebp)
80105f45:	e8 ee bc ff ff       	call   80101c38 <iunlockput>
80105f4a:	83 c4 10             	add    $0x10,%esp
      end_op();
80105f4d:	e8 66 d6 ff ff       	call   801035b8 <end_op>
      return -1;
80105f52:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f57:	e9 c0 00 00 00       	jmp    8010601c <sys_open+0x19b>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
80105f5c:	e8 89 b0 ff ff       	call   80100fea <filealloc>
80105f61:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105f64:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105f68:	74 17                	je     80105f81 <sys_open+0x100>
80105f6a:	83 ec 0c             	sub    $0xc,%esp
80105f6d:	ff 75 f0             	pushl  -0x10(%ebp)
80105f70:	e8 37 f7 ff ff       	call   801056ac <fdalloc>
80105f75:	83 c4 10             	add    $0x10,%esp
80105f78:	89 45 ec             	mov    %eax,-0x14(%ebp)
80105f7b:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80105f7f:	79 2e                	jns    80105faf <sys_open+0x12e>
    if(f)
80105f81:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105f85:	74 0e                	je     80105f95 <sys_open+0x114>
      fileclose(f);
80105f87:	83 ec 0c             	sub    $0xc,%esp
80105f8a:	ff 75 f0             	pushl  -0x10(%ebp)
80105f8d:	e8 16 b1 ff ff       	call   801010a8 <fileclose>
80105f92:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
80105f95:	83 ec 0c             	sub    $0xc,%esp
80105f98:	ff 75 f4             	pushl  -0xc(%ebp)
80105f9b:	e8 98 bc ff ff       	call   80101c38 <iunlockput>
80105fa0:	83 c4 10             	add    $0x10,%esp
    end_op();
80105fa3:	e8 10 d6 ff ff       	call   801035b8 <end_op>
    return -1;
80105fa8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105fad:	eb 6d                	jmp    8010601c <sys_open+0x19b>
  }
  iunlock(ip);
80105faf:	83 ec 0c             	sub    $0xc,%esp
80105fb2:	ff 75 f4             	pushl  -0xc(%ebp)
80105fb5:	e8 60 bb ff ff       	call   80101b1a <iunlock>
80105fba:	83 c4 10             	add    $0x10,%esp
  end_op();
80105fbd:	e8 f6 d5 ff ff       	call   801035b8 <end_op>

  f->type = FD_INODE;
80105fc2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105fc5:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
80105fcb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105fce:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105fd1:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
80105fd4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105fd7:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
80105fde:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105fe1:	83 e0 01             	and    $0x1,%eax
80105fe4:	85 c0                	test   %eax,%eax
80105fe6:	0f 94 c0             	sete   %al
80105fe9:	89 c2                	mov    %eax,%edx
80105feb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105fee:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
80105ff1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105ff4:	83 e0 01             	and    $0x1,%eax
80105ff7:	85 c0                	test   %eax,%eax
80105ff9:	75 0a                	jne    80106005 <sys_open+0x184>
80105ffb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105ffe:	83 e0 02             	and    $0x2,%eax
80106001:	85 c0                	test   %eax,%eax
80106003:	74 07                	je     8010600c <sys_open+0x18b>
80106005:	b8 01 00 00 00       	mov    $0x1,%eax
8010600a:	eb 05                	jmp    80106011 <sys_open+0x190>
8010600c:	b8 00 00 00 00       	mov    $0x0,%eax
80106011:	89 c2                	mov    %eax,%edx
80106013:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106016:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
80106019:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
8010601c:	c9                   	leave  
8010601d:	c3                   	ret    

8010601e <sys_mkdir>:

int
sys_mkdir(void)
{
8010601e:	55                   	push   %ebp
8010601f:	89 e5                	mov    %esp,%ebp
80106021:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
80106024:	e8 03 d5 ff ff       	call   8010352c <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
80106029:	83 ec 08             	sub    $0x8,%esp
8010602c:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010602f:	50                   	push   %eax
80106030:	6a 00                	push   $0x0
80106032:	e8 4a f5 ff ff       	call   80105581 <argstr>
80106037:	83 c4 10             	add    $0x10,%esp
8010603a:	85 c0                	test   %eax,%eax
8010603c:	78 1b                	js     80106059 <sys_mkdir+0x3b>
8010603e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106041:	6a 00                	push   $0x0
80106043:	6a 00                	push   $0x0
80106045:	6a 01                	push   $0x1
80106047:	50                   	push   %eax
80106048:	e8 62 fc ff ff       	call   80105caf <create>
8010604d:	83 c4 10             	add    $0x10,%esp
80106050:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106053:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106057:	75 0c                	jne    80106065 <sys_mkdir+0x47>
    end_op();
80106059:	e8 5a d5 ff ff       	call   801035b8 <end_op>
    return -1;
8010605e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106063:	eb 18                	jmp    8010607d <sys_mkdir+0x5f>
  }
  iunlockput(ip);
80106065:	83 ec 0c             	sub    $0xc,%esp
80106068:	ff 75 f4             	pushl  -0xc(%ebp)
8010606b:	e8 c8 bb ff ff       	call   80101c38 <iunlockput>
80106070:	83 c4 10             	add    $0x10,%esp
  end_op();
80106073:	e8 40 d5 ff ff       	call   801035b8 <end_op>
  return 0;
80106078:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010607d:	c9                   	leave  
8010607e:	c3                   	ret    

8010607f <sys_mknod>:

int
sys_mknod(void)
{
8010607f:	55                   	push   %ebp
80106080:	89 e5                	mov    %esp,%ebp
80106082:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
80106085:	e8 a2 d4 ff ff       	call   8010352c <begin_op>
  if((argstr(0, &path)) < 0 ||
8010608a:	83 ec 08             	sub    $0x8,%esp
8010608d:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106090:	50                   	push   %eax
80106091:	6a 00                	push   $0x0
80106093:	e8 e9 f4 ff ff       	call   80105581 <argstr>
80106098:	83 c4 10             	add    $0x10,%esp
8010609b:	85 c0                	test   %eax,%eax
8010609d:	78 4f                	js     801060ee <sys_mknod+0x6f>
     argint(1, &major) < 0 ||
8010609f:	83 ec 08             	sub    $0x8,%esp
801060a2:	8d 45 ec             	lea    -0x14(%ebp),%eax
801060a5:	50                   	push   %eax
801060a6:	6a 01                	push   $0x1
801060a8:	e8 4b f4 ff ff       	call   801054f8 <argint>
801060ad:	83 c4 10             	add    $0x10,%esp
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
  if((argstr(0, &path)) < 0 ||
801060b0:	85 c0                	test   %eax,%eax
801060b2:	78 3a                	js     801060ee <sys_mknod+0x6f>
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
801060b4:	83 ec 08             	sub    $0x8,%esp
801060b7:	8d 45 e8             	lea    -0x18(%ebp),%eax
801060ba:	50                   	push   %eax
801060bb:	6a 02                	push   $0x2
801060bd:	e8 36 f4 ff ff       	call   801054f8 <argint>
801060c2:	83 c4 10             	add    $0x10,%esp
  char *path;
  int major, minor;

  begin_op();
  if((argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
801060c5:	85 c0                	test   %eax,%eax
801060c7:	78 25                	js     801060ee <sys_mknod+0x6f>
     argint(2, &minor) < 0 ||
     (ip = create(path, T_DEV, major, minor)) == 0){
801060c9:	8b 45 e8             	mov    -0x18(%ebp),%eax
801060cc:	0f bf c8             	movswl %ax,%ecx
801060cf:	8b 45 ec             	mov    -0x14(%ebp),%eax
801060d2:	0f bf d0             	movswl %ax,%edx
801060d5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  int major, minor;

  begin_op();
  if((argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
801060d8:	51                   	push   %ecx
801060d9:	52                   	push   %edx
801060da:	6a 03                	push   $0x3
801060dc:	50                   	push   %eax
801060dd:	e8 cd fb ff ff       	call   80105caf <create>
801060e2:	83 c4 10             	add    $0x10,%esp
801060e5:	89 45 f4             	mov    %eax,-0xc(%ebp)
801060e8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801060ec:	75 0c                	jne    801060fa <sys_mknod+0x7b>
     (ip = create(path, T_DEV, major, minor)) == 0){
    end_op();
801060ee:	e8 c5 d4 ff ff       	call   801035b8 <end_op>
    return -1;
801060f3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801060f8:	eb 18                	jmp    80106112 <sys_mknod+0x93>
  }
  iunlockput(ip);
801060fa:	83 ec 0c             	sub    $0xc,%esp
801060fd:	ff 75 f4             	pushl  -0xc(%ebp)
80106100:	e8 33 bb ff ff       	call   80101c38 <iunlockput>
80106105:	83 c4 10             	add    $0x10,%esp
  end_op();
80106108:	e8 ab d4 ff ff       	call   801035b8 <end_op>
  return 0;
8010610d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106112:	c9                   	leave  
80106113:	c3                   	ret    

80106114 <sys_chdir>:

int
sys_chdir(void)
{
80106114:	55                   	push   %ebp
80106115:	89 e5                	mov    %esp,%ebp
80106117:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;
  struct proc *curproc = myproc();
8010611a:	e8 65 e1 ff ff       	call   80104284 <myproc>
8010611f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  begin_op();
80106122:	e8 05 d4 ff ff       	call   8010352c <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
80106127:	83 ec 08             	sub    $0x8,%esp
8010612a:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010612d:	50                   	push   %eax
8010612e:	6a 00                	push   $0x0
80106130:	e8 4c f4 ff ff       	call   80105581 <argstr>
80106135:	83 c4 10             	add    $0x10,%esp
80106138:	85 c0                	test   %eax,%eax
8010613a:	78 18                	js     80106154 <sys_chdir+0x40>
8010613c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010613f:	83 ec 0c             	sub    $0xc,%esp
80106142:	50                   	push   %eax
80106143:	e8 ff c3 ff ff       	call   80102547 <namei>
80106148:	83 c4 10             	add    $0x10,%esp
8010614b:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010614e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106152:	75 0c                	jne    80106160 <sys_chdir+0x4c>
    end_op();
80106154:	e8 5f d4 ff ff       	call   801035b8 <end_op>
    return -1;
80106159:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010615e:	eb 68                	jmp    801061c8 <sys_chdir+0xb4>
  }
  ilock(ip);
80106160:	83 ec 0c             	sub    $0xc,%esp
80106163:	ff 75 f0             	pushl  -0x10(%ebp)
80106166:	e8 9c b8 ff ff       	call   80101a07 <ilock>
8010616b:	83 c4 10             	add    $0x10,%esp
  if(ip->type != T_DIR){
8010616e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106171:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80106175:	66 83 f8 01          	cmp    $0x1,%ax
80106179:	74 1a                	je     80106195 <sys_chdir+0x81>
    iunlockput(ip);
8010617b:	83 ec 0c             	sub    $0xc,%esp
8010617e:	ff 75 f0             	pushl  -0x10(%ebp)
80106181:	e8 b2 ba ff ff       	call   80101c38 <iunlockput>
80106186:	83 c4 10             	add    $0x10,%esp
    end_op();
80106189:	e8 2a d4 ff ff       	call   801035b8 <end_op>
    return -1;
8010618e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106193:	eb 33                	jmp    801061c8 <sys_chdir+0xb4>
  }
  iunlock(ip);
80106195:	83 ec 0c             	sub    $0xc,%esp
80106198:	ff 75 f0             	pushl  -0x10(%ebp)
8010619b:	e8 7a b9 ff ff       	call   80101b1a <iunlock>
801061a0:	83 c4 10             	add    $0x10,%esp
  iput(curproc->cwd);
801061a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801061a6:	8b 40 70             	mov    0x70(%eax),%eax
801061a9:	83 ec 0c             	sub    $0xc,%esp
801061ac:	50                   	push   %eax
801061ad:	e8 b6 b9 ff ff       	call   80101b68 <iput>
801061b2:	83 c4 10             	add    $0x10,%esp
  end_op();
801061b5:	e8 fe d3 ff ff       	call   801035b8 <end_op>
  curproc->cwd = ip;
801061ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
801061bd:	8b 55 f0             	mov    -0x10(%ebp),%edx
801061c0:	89 50 70             	mov    %edx,0x70(%eax)
  return 0;
801061c3:	b8 00 00 00 00       	mov    $0x0,%eax
}
801061c8:	c9                   	leave  
801061c9:	c3                   	ret    

801061ca <sys_exec>:

int
sys_exec(void)
{
801061ca:	55                   	push   %ebp
801061cb:	89 e5                	mov    %esp,%ebp
801061cd:	81 ec 98 00 00 00    	sub    $0x98,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
801061d3:	83 ec 08             	sub    $0x8,%esp
801061d6:	8d 45 f0             	lea    -0x10(%ebp),%eax
801061d9:	50                   	push   %eax
801061da:	6a 00                	push   $0x0
801061dc:	e8 a0 f3 ff ff       	call   80105581 <argstr>
801061e1:	83 c4 10             	add    $0x10,%esp
801061e4:	85 c0                	test   %eax,%eax
801061e6:	78 18                	js     80106200 <sys_exec+0x36>
801061e8:	83 ec 08             	sub    $0x8,%esp
801061eb:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
801061f1:	50                   	push   %eax
801061f2:	6a 01                	push   $0x1
801061f4:	e8 ff f2 ff ff       	call   801054f8 <argint>
801061f9:	83 c4 10             	add    $0x10,%esp
801061fc:	85 c0                	test   %eax,%eax
801061fe:	79 0a                	jns    8010620a <sys_exec+0x40>
    return -1;
80106200:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106205:	e9 c6 00 00 00       	jmp    801062d0 <sys_exec+0x106>
  }
  memset(argv, 0, sizeof(argv));
8010620a:	83 ec 04             	sub    $0x4,%esp
8010620d:	68 80 00 00 00       	push   $0x80
80106212:	6a 00                	push   $0x0
80106214:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
8010621a:	50                   	push   %eax
8010621b:	e8 c4 ef ff ff       	call   801051e4 <memset>
80106220:	83 c4 10             	add    $0x10,%esp
  for(i=0;; i++){
80106223:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
8010622a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010622d:	83 f8 1f             	cmp    $0x1f,%eax
80106230:	76 0a                	jbe    8010623c <sys_exec+0x72>
      return -1;
80106232:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106237:	e9 94 00 00 00       	jmp    801062d0 <sys_exec+0x106>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
8010623c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010623f:	c1 e0 02             	shl    $0x2,%eax
80106242:	89 c2                	mov    %eax,%edx
80106244:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
8010624a:	01 c2                	add    %eax,%edx
8010624c:	83 ec 08             	sub    $0x8,%esp
8010624f:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
80106255:	50                   	push   %eax
80106256:	52                   	push   %edx
80106257:	e8 11 f2 ff ff       	call   8010546d <fetchint>
8010625c:	83 c4 10             	add    $0x10,%esp
8010625f:	85 c0                	test   %eax,%eax
80106261:	79 07                	jns    8010626a <sys_exec+0xa0>
      return -1;
80106263:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106268:	eb 66                	jmp    801062d0 <sys_exec+0x106>
    if(uarg == 0){
8010626a:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80106270:	85 c0                	test   %eax,%eax
80106272:	75 27                	jne    8010629b <sys_exec+0xd1>
      argv[i] = 0;
80106274:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106277:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
8010627e:	00 00 00 00 
      break;
80106282:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
80106283:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106286:	83 ec 08             	sub    $0x8,%esp
80106289:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
8010628f:	52                   	push   %edx
80106290:	50                   	push   %eax
80106291:	e8 00 a9 ff ff       	call   80100b96 <exec>
80106296:	83 c4 10             	add    $0x10,%esp
80106299:	eb 35                	jmp    801062d0 <sys_exec+0x106>
      return -1;
    if(uarg == 0){
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
8010629b:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
801062a1:	8b 55 f4             	mov    -0xc(%ebp),%edx
801062a4:	c1 e2 02             	shl    $0x2,%edx
801062a7:	01 c2                	add    %eax,%edx
801062a9:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
801062af:	83 ec 08             	sub    $0x8,%esp
801062b2:	52                   	push   %edx
801062b3:	50                   	push   %eax
801062b4:	e8 e5 f1 ff ff       	call   8010549e <fetchstr>
801062b9:	83 c4 10             	add    $0x10,%esp
801062bc:	85 c0                	test   %eax,%eax
801062be:	79 07                	jns    801062c7 <sys_exec+0xfd>
      return -1;
801062c0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801062c5:	eb 09                	jmp    801062d0 <sys_exec+0x106>

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
    return -1;
  }
  memset(argv, 0, sizeof(argv));
  for(i=0;; i++){
801062c7:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
801062cb:	e9 5a ff ff ff       	jmp    8010622a <sys_exec+0x60>
  return exec(path, argv);
}
801062d0:	c9                   	leave  
801062d1:	c3                   	ret    

801062d2 <sys_pipe>:

int
sys_pipe(void)
{
801062d2:	55                   	push   %ebp
801062d3:	89 e5                	mov    %esp,%ebp
801062d5:	83 ec 28             	sub    $0x28,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
801062d8:	83 ec 04             	sub    $0x4,%esp
801062db:	6a 08                	push   $0x8
801062dd:	8d 45 ec             	lea    -0x14(%ebp),%eax
801062e0:	50                   	push   %eax
801062e1:	6a 00                	push   $0x0
801062e3:	e8 3d f2 ff ff       	call   80105525 <argptr>
801062e8:	83 c4 10             	add    $0x10,%esp
801062eb:	85 c0                	test   %eax,%eax
801062ed:	79 0a                	jns    801062f9 <sys_pipe+0x27>
    return -1;
801062ef:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801062f4:	e9 af 00 00 00       	jmp    801063a8 <sys_pipe+0xd6>
  if(pipealloc(&rf, &wf) < 0)
801062f9:	83 ec 08             	sub    $0x8,%esp
801062fc:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801062ff:	50                   	push   %eax
80106300:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106303:	50                   	push   %eax
80106304:	e8 b2 da ff ff       	call   80103dbb <pipealloc>
80106309:	83 c4 10             	add    $0x10,%esp
8010630c:	85 c0                	test   %eax,%eax
8010630e:	79 0a                	jns    8010631a <sys_pipe+0x48>
    return -1;
80106310:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106315:	e9 8e 00 00 00       	jmp    801063a8 <sys_pipe+0xd6>
  fd0 = -1;
8010631a:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
80106321:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106324:	83 ec 0c             	sub    $0xc,%esp
80106327:	50                   	push   %eax
80106328:	e8 7f f3 ff ff       	call   801056ac <fdalloc>
8010632d:	83 c4 10             	add    $0x10,%esp
80106330:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106333:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106337:	78 18                	js     80106351 <sys_pipe+0x7f>
80106339:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010633c:	83 ec 0c             	sub    $0xc,%esp
8010633f:	50                   	push   %eax
80106340:	e8 67 f3 ff ff       	call   801056ac <fdalloc>
80106345:	83 c4 10             	add    $0x10,%esp
80106348:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010634b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010634f:	79 3f                	jns    80106390 <sys_pipe+0xbe>
    if(fd0 >= 0)
80106351:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106355:	78 14                	js     8010636b <sys_pipe+0x99>
      myproc()->ofile[fd0] = 0;
80106357:	e8 28 df ff ff       	call   80104284 <myproc>
8010635c:	89 c2                	mov    %eax,%edx
8010635e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106361:	83 c0 0c             	add    $0xc,%eax
80106364:	c7 04 82 00 00 00 00 	movl   $0x0,(%edx,%eax,4)
    fileclose(rf);
8010636b:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010636e:	83 ec 0c             	sub    $0xc,%esp
80106371:	50                   	push   %eax
80106372:	e8 31 ad ff ff       	call   801010a8 <fileclose>
80106377:	83 c4 10             	add    $0x10,%esp
    fileclose(wf);
8010637a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010637d:	83 ec 0c             	sub    $0xc,%esp
80106380:	50                   	push   %eax
80106381:	e8 22 ad ff ff       	call   801010a8 <fileclose>
80106386:	83 c4 10             	add    $0x10,%esp
    return -1;
80106389:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010638e:	eb 18                	jmp    801063a8 <sys_pipe+0xd6>
  }
  fd[0] = fd0;
80106390:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106393:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106396:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
80106398:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010639b:	8d 50 04             	lea    0x4(%eax),%edx
8010639e:	8b 45 f0             	mov    -0x10(%ebp),%eax
801063a1:	89 02                	mov    %eax,(%edx)
  return 0;
801063a3:	b8 00 00 00 00       	mov    $0x0,%eax
}
801063a8:	c9                   	leave  
801063a9:	c3                   	ret    

801063aa <sys_shm_open>:
#include "param.h"
#include "memlayout.h"
#include "mmu.h"
#include "proc.h"

int sys_shm_open(void) {
801063aa:	55                   	push   %ebp
801063ab:	89 e5                	mov    %esp,%ebp
801063ad:	83 ec 18             	sub    $0x18,%esp
  int id;
  char **pointer;

  if(argint(0, &id) < 0)
801063b0:	83 ec 08             	sub    $0x8,%esp
801063b3:	8d 45 f4             	lea    -0xc(%ebp),%eax
801063b6:	50                   	push   %eax
801063b7:	6a 00                	push   $0x0
801063b9:	e8 3a f1 ff ff       	call   801054f8 <argint>
801063be:	83 c4 10             	add    $0x10,%esp
801063c1:	85 c0                	test   %eax,%eax
801063c3:	79 07                	jns    801063cc <sys_shm_open+0x22>
    return -1;
801063c5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801063ca:	eb 31                	jmp    801063fd <sys_shm_open+0x53>

  if(argptr(1, (char **) (&pointer),4)<0)
801063cc:	83 ec 04             	sub    $0x4,%esp
801063cf:	6a 04                	push   $0x4
801063d1:	8d 45 f0             	lea    -0x10(%ebp),%eax
801063d4:	50                   	push   %eax
801063d5:	6a 01                	push   $0x1
801063d7:	e8 49 f1 ff ff       	call   80105525 <argptr>
801063dc:	83 c4 10             	add    $0x10,%esp
801063df:	85 c0                	test   %eax,%eax
801063e1:	79 07                	jns    801063ea <sys_shm_open+0x40>
    return -1;
801063e3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801063e8:	eb 13                	jmp    801063fd <sys_shm_open+0x53>
  return shm_open(id, pointer);
801063ea:	8b 55 f0             	mov    -0x10(%ebp),%edx
801063ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
801063f0:	83 ec 08             	sub    $0x8,%esp
801063f3:	52                   	push   %edx
801063f4:	50                   	push   %eax
801063f5:	e8 86 21 00 00       	call   80108580 <shm_open>
801063fa:	83 c4 10             	add    $0x10,%esp
}
801063fd:	c9                   	leave  
801063fe:	c3                   	ret    

801063ff <sys_shm_close>:

int sys_shm_close(void) {
801063ff:	55                   	push   %ebp
80106400:	89 e5                	mov    %esp,%ebp
80106402:	83 ec 18             	sub    $0x18,%esp
  int id;

  if(argint(0, &id) < 0)
80106405:	83 ec 08             	sub    $0x8,%esp
80106408:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010640b:	50                   	push   %eax
8010640c:	6a 00                	push   $0x0
8010640e:	e8 e5 f0 ff ff       	call   801054f8 <argint>
80106413:	83 c4 10             	add    $0x10,%esp
80106416:	85 c0                	test   %eax,%eax
80106418:	79 07                	jns    80106421 <sys_shm_close+0x22>
    return -1;
8010641a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010641f:	eb 0f                	jmp    80106430 <sys_shm_close+0x31>

  
  return shm_close(id);
80106421:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106424:	83 ec 0c             	sub    $0xc,%esp
80106427:	50                   	push   %eax
80106428:	e8 5d 21 00 00       	call   8010858a <shm_close>
8010642d:	83 c4 10             	add    $0x10,%esp
}
80106430:	c9                   	leave  
80106431:	c3                   	ret    

80106432 <sys_fork>:

int
sys_fork(void)
{
80106432:	55                   	push   %ebp
80106433:	89 e5                	mov    %esp,%ebp
80106435:	83 ec 08             	sub    $0x8,%esp
  return fork();
80106438:	e8 4f e1 ff ff       	call   8010458c <fork>
}
8010643d:	c9                   	leave  
8010643e:	c3                   	ret    

8010643f <sys_exit>:

int
sys_exit(void)
{
8010643f:	55                   	push   %ebp
80106440:	89 e5                	mov    %esp,%ebp
80106442:	83 ec 08             	sub    $0x8,%esp
  exit();
80106445:	e8 c8 e2 ff ff       	call   80104712 <exit>
  return 0;  // not reached
8010644a:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010644f:	c9                   	leave  
80106450:	c3                   	ret    

80106451 <sys_wait>:

int
sys_wait(void)
{
80106451:	55                   	push   %ebp
80106452:	89 e5                	mov    %esp,%ebp
80106454:	83 ec 08             	sub    $0x8,%esp
  return wait();
80106457:	e8 d6 e3 ff ff       	call   80104832 <wait>
}
8010645c:	c9                   	leave  
8010645d:	c3                   	ret    

8010645e <sys_kill>:

int
sys_kill(void)
{
8010645e:	55                   	push   %ebp
8010645f:	89 e5                	mov    %esp,%ebp
80106461:	83 ec 18             	sub    $0x18,%esp
  int pid;

  if(argint(0, &pid) < 0)
80106464:	83 ec 08             	sub    $0x8,%esp
80106467:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010646a:	50                   	push   %eax
8010646b:	6a 00                	push   $0x0
8010646d:	e8 86 f0 ff ff       	call   801054f8 <argint>
80106472:	83 c4 10             	add    $0x10,%esp
80106475:	85 c0                	test   %eax,%eax
80106477:	79 07                	jns    80106480 <sys_kill+0x22>
    return -1;
80106479:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010647e:	eb 0f                	jmp    8010648f <sys_kill+0x31>
  return kill(pid);
80106480:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106483:	83 ec 0c             	sub    $0xc,%esp
80106486:	50                   	push   %eax
80106487:	e8 df e7 ff ff       	call   80104c6b <kill>
8010648c:	83 c4 10             	add    $0x10,%esp
}
8010648f:	c9                   	leave  
80106490:	c3                   	ret    

80106491 <sys_getpid>:

int
sys_getpid(void)
{
80106491:	55                   	push   %ebp
80106492:	89 e5                	mov    %esp,%ebp
80106494:	83 ec 08             	sub    $0x8,%esp
  return myproc()->pid;
80106497:	e8 e8 dd ff ff       	call   80104284 <myproc>
8010649c:	8b 40 18             	mov    0x18(%eax),%eax
}
8010649f:	c9                   	leave  
801064a0:	c3                   	ret    

801064a1 <sys_sbrk>:

int
sys_sbrk(void)
{
801064a1:	55                   	push   %ebp
801064a2:	89 e5                	mov    %esp,%ebp
801064a4:	83 ec 18             	sub    $0x18,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
801064a7:	83 ec 08             	sub    $0x8,%esp
801064aa:	8d 45 f0             	lea    -0x10(%ebp),%eax
801064ad:	50                   	push   %eax
801064ae:	6a 00                	push   $0x0
801064b0:	e8 43 f0 ff ff       	call   801054f8 <argint>
801064b5:	83 c4 10             	add    $0x10,%esp
801064b8:	85 c0                	test   %eax,%eax
801064ba:	79 07                	jns    801064c3 <sys_sbrk+0x22>
    return -1;
801064bc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801064c1:	eb 27                	jmp    801064ea <sys_sbrk+0x49>
  addr = myproc()->sz;
801064c3:	e8 bc dd ff ff       	call   80104284 <myproc>
801064c8:	8b 00                	mov    (%eax),%eax
801064ca:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
801064cd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801064d0:	83 ec 0c             	sub    $0xc,%esp
801064d3:	50                   	push   %eax
801064d4:	e8 18 e0 ff ff       	call   801044f1 <growproc>
801064d9:	83 c4 10             	add    $0x10,%esp
801064dc:	85 c0                	test   %eax,%eax
801064de:	79 07                	jns    801064e7 <sys_sbrk+0x46>
    return -1;
801064e0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801064e5:	eb 03                	jmp    801064ea <sys_sbrk+0x49>
  return addr;
801064e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801064ea:	c9                   	leave  
801064eb:	c3                   	ret    

801064ec <sys_sleep>:

int
sys_sleep(void)
{
801064ec:	55                   	push   %ebp
801064ed:	89 e5                	mov    %esp,%ebp
801064ef:	83 ec 18             	sub    $0x18,%esp
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
801064f2:	83 ec 08             	sub    $0x8,%esp
801064f5:	8d 45 f0             	lea    -0x10(%ebp),%eax
801064f8:	50                   	push   %eax
801064f9:	6a 00                	push   $0x0
801064fb:	e8 f8 ef ff ff       	call   801054f8 <argint>
80106500:	83 c4 10             	add    $0x10,%esp
80106503:	85 c0                	test   %eax,%eax
80106505:	79 07                	jns    8010650e <sys_sleep+0x22>
    return -1;
80106507:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010650c:	eb 76                	jmp    80106584 <sys_sleep+0x98>
  acquire(&tickslock);
8010650e:	83 ec 0c             	sub    $0xc,%esp
80106511:	68 e0 5e 11 80       	push   $0x80115ee0
80106516:	e8 52 ea ff ff       	call   80104f6d <acquire>
8010651b:	83 c4 10             	add    $0x10,%esp
  ticks0 = ticks;
8010651e:	a1 20 67 11 80       	mov    0x80116720,%eax
80106523:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
80106526:	eb 38                	jmp    80106560 <sys_sleep+0x74>
    if(myproc()->killed){
80106528:	e8 57 dd ff ff       	call   80104284 <myproc>
8010652d:	8b 40 2c             	mov    0x2c(%eax),%eax
80106530:	85 c0                	test   %eax,%eax
80106532:	74 17                	je     8010654b <sys_sleep+0x5f>
      release(&tickslock);
80106534:	83 ec 0c             	sub    $0xc,%esp
80106537:	68 e0 5e 11 80       	push   $0x80115ee0
8010653c:	e8 9a ea ff ff       	call   80104fdb <release>
80106541:	83 c4 10             	add    $0x10,%esp
      return -1;
80106544:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106549:	eb 39                	jmp    80106584 <sys_sleep+0x98>
    }
    sleep(&ticks, &tickslock);
8010654b:	83 ec 08             	sub    $0x8,%esp
8010654e:	68 e0 5e 11 80       	push   $0x80115ee0
80106553:	68 20 67 11 80       	push   $0x80116720
80106558:	e8 ee e5 ff ff       	call   80104b4b <sleep>
8010655d:	83 c4 10             	add    $0x10,%esp

  if(argint(0, &n) < 0)
    return -1;
  acquire(&tickslock);
  ticks0 = ticks;
  while(ticks - ticks0 < n){
80106560:	a1 20 67 11 80       	mov    0x80116720,%eax
80106565:	2b 45 f4             	sub    -0xc(%ebp),%eax
80106568:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010656b:	39 d0                	cmp    %edx,%eax
8010656d:	72 b9                	jb     80106528 <sys_sleep+0x3c>
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
8010656f:	83 ec 0c             	sub    $0xc,%esp
80106572:	68 e0 5e 11 80       	push   $0x80115ee0
80106577:	e8 5f ea ff ff       	call   80104fdb <release>
8010657c:	83 c4 10             	add    $0x10,%esp
  return 0;
8010657f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106584:	c9                   	leave  
80106585:	c3                   	ret    

80106586 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
80106586:	55                   	push   %ebp
80106587:	89 e5                	mov    %esp,%ebp
80106589:	83 ec 18             	sub    $0x18,%esp
  uint xticks;

  acquire(&tickslock);
8010658c:	83 ec 0c             	sub    $0xc,%esp
8010658f:	68 e0 5e 11 80       	push   $0x80115ee0
80106594:	e8 d4 e9 ff ff       	call   80104f6d <acquire>
80106599:	83 c4 10             	add    $0x10,%esp
  xticks = ticks;
8010659c:	a1 20 67 11 80       	mov    0x80116720,%eax
801065a1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
801065a4:	83 ec 0c             	sub    $0xc,%esp
801065a7:	68 e0 5e 11 80       	push   $0x80115ee0
801065ac:	e8 2a ea ff ff       	call   80104fdb <release>
801065b1:	83 c4 10             	add    $0x10,%esp
  return xticks;
801065b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801065b7:	c9                   	leave  
801065b8:	c3                   	ret    

801065b9 <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
801065b9:	1e                   	push   %ds
  pushl %es
801065ba:	06                   	push   %es
  pushl %fs
801065bb:	0f a0                	push   %fs
  pushl %gs
801065bd:	0f a8                	push   %gs
  pushal
801065bf:	60                   	pusha  
  
  # Set up data segments.
  movw $(SEG_KDATA<<3), %ax
801065c0:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
801065c4:	8e d8                	mov    %eax,%ds
  movw %ax, %es
801065c6:	8e c0                	mov    %eax,%es

  # Call trap(tf), where tf=%esp
  pushl %esp
801065c8:	54                   	push   %esp
  call trap
801065c9:	e8 d7 01 00 00       	call   801067a5 <trap>
  addl $4, %esp
801065ce:	83 c4 04             	add    $0x4,%esp

801065d1 <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
801065d1:	61                   	popa   
  popl %gs
801065d2:	0f a9                	pop    %gs
  popl %fs
801065d4:	0f a1                	pop    %fs
  popl %es
801065d6:	07                   	pop    %es
  popl %ds
801065d7:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
801065d8:	83 c4 08             	add    $0x8,%esp
  iret
801065db:	cf                   	iret   

801065dc <lidt>:

struct gatedesc;

static inline void
lidt(struct gatedesc *p, int size)
{
801065dc:	55                   	push   %ebp
801065dd:	89 e5                	mov    %esp,%ebp
801065df:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
801065e2:	8b 45 0c             	mov    0xc(%ebp),%eax
801065e5:	83 e8 01             	sub    $0x1,%eax
801065e8:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
801065ec:	8b 45 08             	mov    0x8(%ebp),%eax
801065ef:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
801065f3:	8b 45 08             	mov    0x8(%ebp),%eax
801065f6:	c1 e8 10             	shr    $0x10,%eax
801065f9:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lidt (%0)" : : "r" (pd));
801065fd:	8d 45 fa             	lea    -0x6(%ebp),%eax
80106600:	0f 01 18             	lidtl  (%eax)
}
80106603:	90                   	nop
80106604:	c9                   	leave  
80106605:	c3                   	ret    

80106606 <rcr2>:
  return result;
}

static inline uint
rcr2(void)
{
80106606:	55                   	push   %ebp
80106607:	89 e5                	mov    %esp,%ebp
80106609:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
8010660c:	0f 20 d0             	mov    %cr2,%eax
8010660f:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return val;
80106612:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80106615:	c9                   	leave  
80106616:	c3                   	ret    

80106617 <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
80106617:	55                   	push   %ebp
80106618:	89 e5                	mov    %esp,%ebp
8010661a:	83 ec 18             	sub    $0x18,%esp
  int i;

  for(i = 0; i < 256; i++)
8010661d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106624:	e9 c3 00 00 00       	jmp    801066ec <tvinit+0xd5>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
80106629:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010662c:	8b 04 85 80 b0 10 80 	mov    -0x7fef4f80(,%eax,4),%eax
80106633:	89 c2                	mov    %eax,%edx
80106635:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106638:	66 89 14 c5 20 5f 11 	mov    %dx,-0x7feea0e0(,%eax,8)
8010663f:	80 
80106640:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106643:	66 c7 04 c5 22 5f 11 	movw   $0x8,-0x7feea0de(,%eax,8)
8010664a:	80 08 00 
8010664d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106650:	0f b6 14 c5 24 5f 11 	movzbl -0x7feea0dc(,%eax,8),%edx
80106657:	80 
80106658:	83 e2 e0             	and    $0xffffffe0,%edx
8010665b:	88 14 c5 24 5f 11 80 	mov    %dl,-0x7feea0dc(,%eax,8)
80106662:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106665:	0f b6 14 c5 24 5f 11 	movzbl -0x7feea0dc(,%eax,8),%edx
8010666c:	80 
8010666d:	83 e2 1f             	and    $0x1f,%edx
80106670:	88 14 c5 24 5f 11 80 	mov    %dl,-0x7feea0dc(,%eax,8)
80106677:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010667a:	0f b6 14 c5 25 5f 11 	movzbl -0x7feea0db(,%eax,8),%edx
80106681:	80 
80106682:	83 e2 f0             	and    $0xfffffff0,%edx
80106685:	83 ca 0e             	or     $0xe,%edx
80106688:	88 14 c5 25 5f 11 80 	mov    %dl,-0x7feea0db(,%eax,8)
8010668f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106692:	0f b6 14 c5 25 5f 11 	movzbl -0x7feea0db(,%eax,8),%edx
80106699:	80 
8010669a:	83 e2 ef             	and    $0xffffffef,%edx
8010669d:	88 14 c5 25 5f 11 80 	mov    %dl,-0x7feea0db(,%eax,8)
801066a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801066a7:	0f b6 14 c5 25 5f 11 	movzbl -0x7feea0db(,%eax,8),%edx
801066ae:	80 
801066af:	83 e2 9f             	and    $0xffffff9f,%edx
801066b2:	88 14 c5 25 5f 11 80 	mov    %dl,-0x7feea0db(,%eax,8)
801066b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801066bc:	0f b6 14 c5 25 5f 11 	movzbl -0x7feea0db(,%eax,8),%edx
801066c3:	80 
801066c4:	83 ca 80             	or     $0xffffff80,%edx
801066c7:	88 14 c5 25 5f 11 80 	mov    %dl,-0x7feea0db(,%eax,8)
801066ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
801066d1:	8b 04 85 80 b0 10 80 	mov    -0x7fef4f80(,%eax,4),%eax
801066d8:	c1 e8 10             	shr    $0x10,%eax
801066db:	89 c2                	mov    %eax,%edx
801066dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801066e0:	66 89 14 c5 26 5f 11 	mov    %dx,-0x7feea0da(,%eax,8)
801066e7:	80 
void
tvinit(void)
{
  int i;

  for(i = 0; i < 256; i++)
801066e8:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801066ec:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
801066f3:	0f 8e 30 ff ff ff    	jle    80106629 <tvinit+0x12>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
801066f9:	a1 80 b1 10 80       	mov    0x8010b180,%eax
801066fe:	66 a3 20 61 11 80    	mov    %ax,0x80116120
80106704:	66 c7 05 22 61 11 80 	movw   $0x8,0x80116122
8010670b:	08 00 
8010670d:	0f b6 05 24 61 11 80 	movzbl 0x80116124,%eax
80106714:	83 e0 e0             	and    $0xffffffe0,%eax
80106717:	a2 24 61 11 80       	mov    %al,0x80116124
8010671c:	0f b6 05 24 61 11 80 	movzbl 0x80116124,%eax
80106723:	83 e0 1f             	and    $0x1f,%eax
80106726:	a2 24 61 11 80       	mov    %al,0x80116124
8010672b:	0f b6 05 25 61 11 80 	movzbl 0x80116125,%eax
80106732:	83 c8 0f             	or     $0xf,%eax
80106735:	a2 25 61 11 80       	mov    %al,0x80116125
8010673a:	0f b6 05 25 61 11 80 	movzbl 0x80116125,%eax
80106741:	83 e0 ef             	and    $0xffffffef,%eax
80106744:	a2 25 61 11 80       	mov    %al,0x80116125
80106749:	0f b6 05 25 61 11 80 	movzbl 0x80116125,%eax
80106750:	83 c8 60             	or     $0x60,%eax
80106753:	a2 25 61 11 80       	mov    %al,0x80116125
80106758:	0f b6 05 25 61 11 80 	movzbl 0x80116125,%eax
8010675f:	83 c8 80             	or     $0xffffff80,%eax
80106762:	a2 25 61 11 80       	mov    %al,0x80116125
80106767:	a1 80 b1 10 80       	mov    0x8010b180,%eax
8010676c:	c1 e8 10             	shr    $0x10,%eax
8010676f:	66 a3 26 61 11 80    	mov    %ax,0x80116126

  initlock(&tickslock, "time");
80106775:	83 ec 08             	sub    $0x8,%esp
80106778:	68 8c 8a 10 80       	push   $0x80108a8c
8010677d:	68 e0 5e 11 80       	push   $0x80115ee0
80106782:	e8 c4 e7 ff ff       	call   80104f4b <initlock>
80106787:	83 c4 10             	add    $0x10,%esp
}
8010678a:	90                   	nop
8010678b:	c9                   	leave  
8010678c:	c3                   	ret    

8010678d <idtinit>:

void
idtinit(void)
{
8010678d:	55                   	push   %ebp
8010678e:	89 e5                	mov    %esp,%ebp
  lidt(idt, sizeof(idt));
80106790:	68 00 08 00 00       	push   $0x800
80106795:	68 20 5f 11 80       	push   $0x80115f20
8010679a:	e8 3d fe ff ff       	call   801065dc <lidt>
8010679f:	83 c4 08             	add    $0x8,%esp
}
801067a2:	90                   	nop
801067a3:	c9                   	leave  
801067a4:	c3                   	ret    

801067a5 <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
801067a5:	55                   	push   %ebp
801067a6:	89 e5                	mov    %esp,%ebp
801067a8:	57                   	push   %edi
801067a9:	56                   	push   %esi
801067aa:	53                   	push   %ebx
801067ab:	83 ec 2c             	sub    $0x2c,%esp
  if(tf->trapno == T_SYSCALL){
801067ae:	8b 45 08             	mov    0x8(%ebp),%eax
801067b1:	8b 40 30             	mov    0x30(%eax),%eax
801067b4:	83 f8 40             	cmp    $0x40,%eax
801067b7:	75 3d                	jne    801067f6 <trap+0x51>
    if(myproc()->killed)
801067b9:	e8 c6 da ff ff       	call   80104284 <myproc>
801067be:	8b 40 2c             	mov    0x2c(%eax),%eax
801067c1:	85 c0                	test   %eax,%eax
801067c3:	74 05                	je     801067ca <trap+0x25>
      exit();
801067c5:	e8 48 df ff ff       	call   80104712 <exit>
    myproc()->tf = tf;
801067ca:	e8 b5 da ff ff       	call   80104284 <myproc>
801067cf:	89 c2                	mov    %eax,%edx
801067d1:	8b 45 08             	mov    0x8(%ebp),%eax
801067d4:	89 42 20             	mov    %eax,0x20(%edx)
    syscall();
801067d7:	e8 dc ed ff ff       	call   801055b8 <syscall>
    if(myproc()->killed)
801067dc:	e8 a3 da ff ff       	call   80104284 <myproc>
801067e1:	8b 40 2c             	mov    0x2c(%eax),%eax
801067e4:	85 c0                	test   %eax,%eax
801067e6:	0f 84 85 02 00 00    	je     80106a71 <trap+0x2cc>
      exit();
801067ec:	e8 21 df ff ff       	call   80104712 <exit>
    return;
801067f1:	e9 7b 02 00 00       	jmp    80106a71 <trap+0x2cc>
  }

  switch(tf->trapno){
801067f6:	8b 45 08             	mov    0x8(%ebp),%eax
801067f9:	8b 40 30             	mov    0x30(%eax),%eax
801067fc:	83 e8 0e             	sub    $0xe,%eax
801067ff:	83 f8 31             	cmp    $0x31,%eax
80106802:	0f 87 33 01 00 00    	ja     8010693b <trap+0x196>
80106808:	8b 04 85 40 8b 10 80 	mov    -0x7fef74c0(,%eax,4),%eax
8010680f:	ff e0                	jmp    *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpuid() == 0){
80106811:	e8 d5 d9 ff ff       	call   801041eb <cpuid>
80106816:	85 c0                	test   %eax,%eax
80106818:	75 3d                	jne    80106857 <trap+0xb2>
      acquire(&tickslock);
8010681a:	83 ec 0c             	sub    $0xc,%esp
8010681d:	68 e0 5e 11 80       	push   $0x80115ee0
80106822:	e8 46 e7 ff ff       	call   80104f6d <acquire>
80106827:	83 c4 10             	add    $0x10,%esp
      ticks++;
8010682a:	a1 20 67 11 80       	mov    0x80116720,%eax
8010682f:	83 c0 01             	add    $0x1,%eax
80106832:	a3 20 67 11 80       	mov    %eax,0x80116720
      wakeup(&ticks);
80106837:	83 ec 0c             	sub    $0xc,%esp
8010683a:	68 20 67 11 80       	push   $0x80116720
8010683f:	e8 f0 e3 ff ff       	call   80104c34 <wakeup>
80106844:	83 c4 10             	add    $0x10,%esp
      release(&tickslock);
80106847:	83 ec 0c             	sub    $0xc,%esp
8010684a:	68 e0 5e 11 80       	push   $0x80115ee0
8010684f:	e8 87 e7 ff ff       	call   80104fdb <release>
80106854:	83 c4 10             	add    $0x10,%esp
    }
    lapiceoi();
80106857:	e8 a8 c7 ff ff       	call   80103004 <lapiceoi>
    break;
8010685c:	e9 90 01 00 00       	jmp    801069f1 <trap+0x24c>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
80106861:	e8 18 c0 ff ff       	call   8010287e <ideintr>
    lapiceoi();
80106866:	e8 99 c7 ff ff       	call   80103004 <lapiceoi>
    break;
8010686b:	e9 81 01 00 00       	jmp    801069f1 <trap+0x24c>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
80106870:	e8 d8 c5 ff ff       	call   80102e4d <kbdintr>
    lapiceoi();
80106875:	e8 8a c7 ff ff       	call   80103004 <lapiceoi>
    break;
8010687a:	e9 72 01 00 00       	jmp    801069f1 <trap+0x24c>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
8010687f:	e8 c1 03 00 00       	call   80106c45 <uartintr>
    lapiceoi();
80106884:	e8 7b c7 ff ff       	call   80103004 <lapiceoi>
    break;
80106889:	e9 63 01 00 00       	jmp    801069f1 <trap+0x24c>
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
8010688e:	8b 45 08             	mov    0x8(%ebp),%eax
80106891:	8b 70 38             	mov    0x38(%eax),%esi
            cpuid(), tf->cs, tf->eip);
80106894:	8b 45 08             	mov    0x8(%ebp),%eax
80106897:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
8010689b:	0f b7 d8             	movzwl %ax,%ebx
8010689e:	e8 48 d9 ff ff       	call   801041eb <cpuid>
801068a3:	56                   	push   %esi
801068a4:	53                   	push   %ebx
801068a5:	50                   	push   %eax
801068a6:	68 94 8a 10 80       	push   $0x80108a94
801068ab:	e8 50 9b ff ff       	call   80100400 <cprintf>
801068b0:	83 c4 10             	add    $0x10,%esp
            cpuid(), tf->cs, tf->eip);
    lapiceoi();
801068b3:	e8 4c c7 ff ff       	call   80103004 <lapiceoi>
    break;
801068b8:	e9 34 01 00 00       	jmp    801069f1 <trap+0x24c>

  case T_PGFLT: ;
    uint addr = rcr2();
801068bd:	e8 44 fd ff ff       	call   80106606 <rcr2>
801068c2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    struct proc * curproc = myproc();
801068c5:	e8 ba d9 ff ff       	call   80104284 <myproc>
801068ca:	89 45 e0             	mov    %eax,-0x20(%ebp)
    //uint sp = curproc->tf->esp;
    uint stack_addr = STACK_TOP - (curproc->stackSize * PGSIZE);
801068cd:	8b 45 e0             	mov    -0x20(%ebp),%eax
801068d0:	8b 40 08             	mov    0x8(%eax),%eax
801068d3:	c1 e0 0c             	shl    $0xc,%eax
801068d6:	ba fc ff ff 7f       	mov    $0x7ffffffc,%edx
801068db:	29 c2                	sub    %eax,%edx
801068dd:	89 d0                	mov    %edx,%eax
801068df:	89 45 dc             	mov    %eax,-0x24(%ebp)
    //cprintf("Bot Address: %x, Faulty Addr: %x\n", stack_addr, addr);
    if (PGROUNDDOWN(addr) <= stack_addr) {
801068e2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801068e5:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801068ea:	3b 45 dc             	cmp    -0x24(%ebp),%eax
801068ed:	0f 87 fd 00 00 00    	ja     801069f0 <trap+0x24b>
      pde_t *pgdir;
      pgdir = curproc->pgdir;
801068f3:	8b 45 e0             	mov    -0x20(%ebp),%eax
801068f6:	8b 40 0c             	mov    0xc(%eax),%eax
801068f9:	89 45 d8             	mov    %eax,-0x28(%ebp)
      //cprintf("Allocating\n");
      if (allocuvm(pgdir, PGROUNDDOWN(addr), stack_addr) == 0) {
801068fc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801068ff:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80106904:	83 ec 04             	sub    $0x4,%esp
80106907:	ff 75 dc             	pushl  -0x24(%ebp)
8010690a:	50                   	push   %eax
8010690b:	ff 75 d8             	pushl  -0x28(%ebp)
8010690e:	e8 2b 16 00 00       	call   80107f3e <allocuvm>
80106913:	83 c4 10             	add    $0x10,%esp
80106916:	85 c0                	test   %eax,%eax
80106918:	75 0d                	jne    80106927 <trap+0x182>
        panic("Messed Up\n");
8010691a:	83 ec 0c             	sub    $0xc,%esp
8010691d:	68 b8 8a 10 80       	push   $0x80108ab8
80106922:	e8 79 9c ff ff       	call   801005a0 <panic>
      }
      curproc->stackSize += 1;
80106927:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010692a:	8b 40 08             	mov    0x8(%eax),%eax
8010692d:	8d 50 01             	lea    0x1(%eax),%edx
80106930:	8b 45 e0             	mov    -0x20(%ebp),%eax
80106933:	89 50 08             	mov    %edx,0x8(%eax)
      //cprintf("Stack Size: %d\n", curproc->stackSize); 
    }
    break;
80106936:	e9 b5 00 00 00       	jmp    801069f0 <trap+0x24b>

  //PAGEBREAK: 13
  default:
    if(myproc() == 0 || (tf->cs&3) == 0){
8010693b:	e8 44 d9 ff ff       	call   80104284 <myproc>
80106940:	85 c0                	test   %eax,%eax
80106942:	74 11                	je     80106955 <trap+0x1b0>
80106944:	8b 45 08             	mov    0x8(%ebp),%eax
80106947:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
8010694b:	0f b7 c0             	movzwl %ax,%eax
8010694e:	83 e0 03             	and    $0x3,%eax
80106951:	85 c0                	test   %eax,%eax
80106953:	75 3b                	jne    80106990 <trap+0x1eb>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80106955:	e8 ac fc ff ff       	call   80106606 <rcr2>
8010695a:	89 c6                	mov    %eax,%esi
8010695c:	8b 45 08             	mov    0x8(%ebp),%eax
8010695f:	8b 58 38             	mov    0x38(%eax),%ebx
80106962:	e8 84 d8 ff ff       	call   801041eb <cpuid>
80106967:	89 c2                	mov    %eax,%edx
80106969:	8b 45 08             	mov    0x8(%ebp),%eax
8010696c:	8b 40 30             	mov    0x30(%eax),%eax
8010696f:	83 ec 0c             	sub    $0xc,%esp
80106972:	56                   	push   %esi
80106973:	53                   	push   %ebx
80106974:	52                   	push   %edx
80106975:	50                   	push   %eax
80106976:	68 c4 8a 10 80       	push   $0x80108ac4
8010697b:	e8 80 9a ff ff       	call   80100400 <cprintf>
80106980:	83 c4 20             	add    $0x20,%esp
              tf->trapno, cpuid(), tf->eip, rcr2());
      panic("trap");
80106983:	83 ec 0c             	sub    $0xc,%esp
80106986:	68 f6 8a 10 80       	push   $0x80108af6
8010698b:	e8 10 9c ff ff       	call   801005a0 <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106990:	e8 71 fc ff ff       	call   80106606 <rcr2>
80106995:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80106998:	8b 45 08             	mov    0x8(%ebp),%eax
8010699b:	8b 78 38             	mov    0x38(%eax),%edi
8010699e:	e8 48 d8 ff ff       	call   801041eb <cpuid>
801069a3:	89 45 d0             	mov    %eax,-0x30(%ebp)
801069a6:	8b 45 08             	mov    0x8(%ebp),%eax
801069a9:	8b 70 34             	mov    0x34(%eax),%esi
801069ac:	8b 45 08             	mov    0x8(%ebp),%eax
801069af:	8b 58 30             	mov    0x30(%eax),%ebx
            "eip 0x%x addr 0x%x--kill proc\n",
            myproc()->pid, myproc()->name, tf->trapno,
801069b2:	e8 cd d8 ff ff       	call   80104284 <myproc>
801069b7:	8d 48 74             	lea    0x74(%eax),%ecx
801069ba:	89 4d cc             	mov    %ecx,-0x34(%ebp)
801069bd:	e8 c2 d8 ff ff       	call   80104284 <myproc>
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpuid(), tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
801069c2:	8b 40 18             	mov    0x18(%eax),%eax
801069c5:	ff 75 d4             	pushl  -0x2c(%ebp)
801069c8:	57                   	push   %edi
801069c9:	ff 75 d0             	pushl  -0x30(%ebp)
801069cc:	56                   	push   %esi
801069cd:	53                   	push   %ebx
801069ce:	ff 75 cc             	pushl  -0x34(%ebp)
801069d1:	50                   	push   %eax
801069d2:	68 fc 8a 10 80       	push   $0x80108afc
801069d7:	e8 24 9a ff ff       	call   80100400 <cprintf>
801069dc:	83 c4 20             	add    $0x20,%esp
            "eip 0x%x addr 0x%x--kill proc\n",
            myproc()->pid, myproc()->name, tf->trapno,
            tf->err, cpuid(), tf->eip, rcr2());
    myproc()->killed = 1;
801069df:	e8 a0 d8 ff ff       	call   80104284 <myproc>
801069e4:	c7 40 2c 01 00 00 00 	movl   $0x1,0x2c(%eax)
801069eb:	eb 04                	jmp    801069f1 <trap+0x24c>
    ideintr();
    lapiceoi();
    break;
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
801069ed:	90                   	nop
801069ee:	eb 01                	jmp    801069f1 <trap+0x24c>
        panic("Messed Up\n");
      }
      curproc->stackSize += 1;
      //cprintf("Stack Size: %d\n", curproc->stackSize); 
    }
    break;
801069f0:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running
  // until it gets to the regular system call return.)
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
801069f1:	e8 8e d8 ff ff       	call   80104284 <myproc>
801069f6:	85 c0                	test   %eax,%eax
801069f8:	74 23                	je     80106a1d <trap+0x278>
801069fa:	e8 85 d8 ff ff       	call   80104284 <myproc>
801069ff:	8b 40 2c             	mov    0x2c(%eax),%eax
80106a02:	85 c0                	test   %eax,%eax
80106a04:	74 17                	je     80106a1d <trap+0x278>
80106a06:	8b 45 08             	mov    0x8(%ebp),%eax
80106a09:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106a0d:	0f b7 c0             	movzwl %ax,%eax
80106a10:	83 e0 03             	and    $0x3,%eax
80106a13:	83 f8 03             	cmp    $0x3,%eax
80106a16:	75 05                	jne    80106a1d <trap+0x278>
    exit();
80106a18:	e8 f5 dc ff ff       	call   80104712 <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(myproc() && myproc()->state == RUNNING &&
80106a1d:	e8 62 d8 ff ff       	call   80104284 <myproc>
80106a22:	85 c0                	test   %eax,%eax
80106a24:	74 1d                	je     80106a43 <trap+0x29e>
80106a26:	e8 59 d8 ff ff       	call   80104284 <myproc>
80106a2b:	8b 40 14             	mov    0x14(%eax),%eax
80106a2e:	83 f8 04             	cmp    $0x4,%eax
80106a31:	75 10                	jne    80106a43 <trap+0x29e>
     tf->trapno == T_IRQ0+IRQ_TIMER)
80106a33:	8b 45 08             	mov    0x8(%ebp),%eax
80106a36:	8b 40 30             	mov    0x30(%eax),%eax
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
    exit();

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(myproc() && myproc()->state == RUNNING &&
80106a39:	83 f8 20             	cmp    $0x20,%eax
80106a3c:	75 05                	jne    80106a43 <trap+0x29e>
     tf->trapno == T_IRQ0+IRQ_TIMER)
    yield();
80106a3e:	e8 88 e0 ff ff       	call   80104acb <yield>

  // Check if the process has been killed since we yielded
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80106a43:	e8 3c d8 ff ff       	call   80104284 <myproc>
80106a48:	85 c0                	test   %eax,%eax
80106a4a:	74 26                	je     80106a72 <trap+0x2cd>
80106a4c:	e8 33 d8 ff ff       	call   80104284 <myproc>
80106a51:	8b 40 2c             	mov    0x2c(%eax),%eax
80106a54:	85 c0                	test   %eax,%eax
80106a56:	74 1a                	je     80106a72 <trap+0x2cd>
80106a58:	8b 45 08             	mov    0x8(%ebp),%eax
80106a5b:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106a5f:	0f b7 c0             	movzwl %ax,%eax
80106a62:	83 e0 03             	and    $0x3,%eax
80106a65:	83 f8 03             	cmp    $0x3,%eax
80106a68:	75 08                	jne    80106a72 <trap+0x2cd>
    exit();
80106a6a:	e8 a3 dc ff ff       	call   80104712 <exit>
80106a6f:	eb 01                	jmp    80106a72 <trap+0x2cd>
      exit();
    myproc()->tf = tf;
    syscall();
    if(myproc()->killed)
      exit();
    return;
80106a71:	90                   	nop
    yield();

  // Check if the process has been killed since we yielded
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
    exit();
}
80106a72:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106a75:	5b                   	pop    %ebx
80106a76:	5e                   	pop    %esi
80106a77:	5f                   	pop    %edi
80106a78:	5d                   	pop    %ebp
80106a79:	c3                   	ret    

80106a7a <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80106a7a:	55                   	push   %ebp
80106a7b:	89 e5                	mov    %esp,%ebp
80106a7d:	83 ec 14             	sub    $0x14,%esp
80106a80:	8b 45 08             	mov    0x8(%ebp),%eax
80106a83:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80106a87:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80106a8b:	89 c2                	mov    %eax,%edx
80106a8d:	ec                   	in     (%dx),%al
80106a8e:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80106a91:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80106a95:	c9                   	leave  
80106a96:	c3                   	ret    

80106a97 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80106a97:	55                   	push   %ebp
80106a98:	89 e5                	mov    %esp,%ebp
80106a9a:	83 ec 08             	sub    $0x8,%esp
80106a9d:	8b 55 08             	mov    0x8(%ebp),%edx
80106aa0:	8b 45 0c             	mov    0xc(%ebp),%eax
80106aa3:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80106aa7:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80106aaa:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80106aae:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80106ab2:	ee                   	out    %al,(%dx)
}
80106ab3:	90                   	nop
80106ab4:	c9                   	leave  
80106ab5:	c3                   	ret    

80106ab6 <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
80106ab6:	55                   	push   %ebp
80106ab7:	89 e5                	mov    %esp,%ebp
80106ab9:	83 ec 18             	sub    $0x18,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
80106abc:	6a 00                	push   $0x0
80106abe:	68 fa 03 00 00       	push   $0x3fa
80106ac3:	e8 cf ff ff ff       	call   80106a97 <outb>
80106ac8:	83 c4 08             	add    $0x8,%esp

  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
80106acb:	68 80 00 00 00       	push   $0x80
80106ad0:	68 fb 03 00 00       	push   $0x3fb
80106ad5:	e8 bd ff ff ff       	call   80106a97 <outb>
80106ada:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
80106add:	6a 0c                	push   $0xc
80106adf:	68 f8 03 00 00       	push   $0x3f8
80106ae4:	e8 ae ff ff ff       	call   80106a97 <outb>
80106ae9:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
80106aec:	6a 00                	push   $0x0
80106aee:	68 f9 03 00 00       	push   $0x3f9
80106af3:	e8 9f ff ff ff       	call   80106a97 <outb>
80106af8:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
80106afb:	6a 03                	push   $0x3
80106afd:	68 fb 03 00 00       	push   $0x3fb
80106b02:	e8 90 ff ff ff       	call   80106a97 <outb>
80106b07:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
80106b0a:	6a 00                	push   $0x0
80106b0c:	68 fc 03 00 00       	push   $0x3fc
80106b11:	e8 81 ff ff ff       	call   80106a97 <outb>
80106b16:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0x01);    // Enable receive interrupts.
80106b19:	6a 01                	push   $0x1
80106b1b:	68 f9 03 00 00       	push   $0x3f9
80106b20:	e8 72 ff ff ff       	call   80106a97 <outb>
80106b25:	83 c4 08             	add    $0x8,%esp

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
80106b28:	68 fd 03 00 00       	push   $0x3fd
80106b2d:	e8 48 ff ff ff       	call   80106a7a <inb>
80106b32:	83 c4 04             	add    $0x4,%esp
80106b35:	3c ff                	cmp    $0xff,%al
80106b37:	74 61                	je     80106b9a <uartinit+0xe4>
    return;
  uart = 1;
80106b39:	c7 05 24 b6 10 80 01 	movl   $0x1,0x8010b624
80106b40:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
80106b43:	68 fa 03 00 00       	push   $0x3fa
80106b48:	e8 2d ff ff ff       	call   80106a7a <inb>
80106b4d:	83 c4 04             	add    $0x4,%esp
  inb(COM1+0);
80106b50:	68 f8 03 00 00       	push   $0x3f8
80106b55:	e8 20 ff ff ff       	call   80106a7a <inb>
80106b5a:	83 c4 04             	add    $0x4,%esp
  ioapicenable(IRQ_COM1, 0);
80106b5d:	83 ec 08             	sub    $0x8,%esp
80106b60:	6a 00                	push   $0x0
80106b62:	6a 04                	push   $0x4
80106b64:	e8 b2 bf ff ff       	call   80102b1b <ioapicenable>
80106b69:	83 c4 10             	add    $0x10,%esp

  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80106b6c:	c7 45 f4 08 8c 10 80 	movl   $0x80108c08,-0xc(%ebp)
80106b73:	eb 19                	jmp    80106b8e <uartinit+0xd8>
    uartputc(*p);
80106b75:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b78:	0f b6 00             	movzbl (%eax),%eax
80106b7b:	0f be c0             	movsbl %al,%eax
80106b7e:	83 ec 0c             	sub    $0xc,%esp
80106b81:	50                   	push   %eax
80106b82:	e8 16 00 00 00       	call   80106b9d <uartputc>
80106b87:	83 c4 10             	add    $0x10,%esp
  inb(COM1+2);
  inb(COM1+0);
  ioapicenable(IRQ_COM1, 0);

  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80106b8a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106b8e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b91:	0f b6 00             	movzbl (%eax),%eax
80106b94:	84 c0                	test   %al,%al
80106b96:	75 dd                	jne    80106b75 <uartinit+0xbf>
80106b98:	eb 01                	jmp    80106b9b <uartinit+0xe5>
  outb(COM1+4, 0);
  outb(COM1+1, 0x01);    // Enable receive interrupts.

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
    return;
80106b9a:	90                   	nop
  ioapicenable(IRQ_COM1, 0);

  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
    uartputc(*p);
}
80106b9b:	c9                   	leave  
80106b9c:	c3                   	ret    

80106b9d <uartputc>:

void
uartputc(int c)
{
80106b9d:	55                   	push   %ebp
80106b9e:	89 e5                	mov    %esp,%ebp
80106ba0:	83 ec 18             	sub    $0x18,%esp
  int i;

  if(!uart)
80106ba3:	a1 24 b6 10 80       	mov    0x8010b624,%eax
80106ba8:	85 c0                	test   %eax,%eax
80106baa:	74 53                	je     80106bff <uartputc+0x62>
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106bac:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106bb3:	eb 11                	jmp    80106bc6 <uartputc+0x29>
    microdelay(10);
80106bb5:	83 ec 0c             	sub    $0xc,%esp
80106bb8:	6a 0a                	push   $0xa
80106bba:	e8 60 c4 ff ff       	call   8010301f <microdelay>
80106bbf:	83 c4 10             	add    $0x10,%esp
{
  int i;

  if(!uart)
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106bc2:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106bc6:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
80106bca:	7f 1a                	jg     80106be6 <uartputc+0x49>
80106bcc:	83 ec 0c             	sub    $0xc,%esp
80106bcf:	68 fd 03 00 00       	push   $0x3fd
80106bd4:	e8 a1 fe ff ff       	call   80106a7a <inb>
80106bd9:	83 c4 10             	add    $0x10,%esp
80106bdc:	0f b6 c0             	movzbl %al,%eax
80106bdf:	83 e0 20             	and    $0x20,%eax
80106be2:	85 c0                	test   %eax,%eax
80106be4:	74 cf                	je     80106bb5 <uartputc+0x18>
    microdelay(10);
  outb(COM1+0, c);
80106be6:	8b 45 08             	mov    0x8(%ebp),%eax
80106be9:	0f b6 c0             	movzbl %al,%eax
80106bec:	83 ec 08             	sub    $0x8,%esp
80106bef:	50                   	push   %eax
80106bf0:	68 f8 03 00 00       	push   $0x3f8
80106bf5:	e8 9d fe ff ff       	call   80106a97 <outb>
80106bfa:	83 c4 10             	add    $0x10,%esp
80106bfd:	eb 01                	jmp    80106c00 <uartputc+0x63>
uartputc(int c)
{
  int i;

  if(!uart)
    return;
80106bff:	90                   	nop
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
    microdelay(10);
  outb(COM1+0, c);
}
80106c00:	c9                   	leave  
80106c01:	c3                   	ret    

80106c02 <uartgetc>:

static int
uartgetc(void)
{
80106c02:	55                   	push   %ebp
80106c03:	89 e5                	mov    %esp,%ebp
  if(!uart)
80106c05:	a1 24 b6 10 80       	mov    0x8010b624,%eax
80106c0a:	85 c0                	test   %eax,%eax
80106c0c:	75 07                	jne    80106c15 <uartgetc+0x13>
    return -1;
80106c0e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106c13:	eb 2e                	jmp    80106c43 <uartgetc+0x41>
  if(!(inb(COM1+5) & 0x01))
80106c15:	68 fd 03 00 00       	push   $0x3fd
80106c1a:	e8 5b fe ff ff       	call   80106a7a <inb>
80106c1f:	83 c4 04             	add    $0x4,%esp
80106c22:	0f b6 c0             	movzbl %al,%eax
80106c25:	83 e0 01             	and    $0x1,%eax
80106c28:	85 c0                	test   %eax,%eax
80106c2a:	75 07                	jne    80106c33 <uartgetc+0x31>
    return -1;
80106c2c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106c31:	eb 10                	jmp    80106c43 <uartgetc+0x41>
  return inb(COM1+0);
80106c33:	68 f8 03 00 00       	push   $0x3f8
80106c38:	e8 3d fe ff ff       	call   80106a7a <inb>
80106c3d:	83 c4 04             	add    $0x4,%esp
80106c40:	0f b6 c0             	movzbl %al,%eax
}
80106c43:	c9                   	leave  
80106c44:	c3                   	ret    

80106c45 <uartintr>:

void
uartintr(void)
{
80106c45:	55                   	push   %ebp
80106c46:	89 e5                	mov    %esp,%ebp
80106c48:	83 ec 08             	sub    $0x8,%esp
  consoleintr(uartgetc);
80106c4b:	83 ec 0c             	sub    $0xc,%esp
80106c4e:	68 02 6c 10 80       	push   $0x80106c02
80106c53:	e8 d4 9b ff ff       	call   8010082c <consoleintr>
80106c58:	83 c4 10             	add    $0x10,%esp
}
80106c5b:	90                   	nop
80106c5c:	c9                   	leave  
80106c5d:	c3                   	ret    

80106c5e <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
80106c5e:	6a 00                	push   $0x0
  pushl $0
80106c60:	6a 00                	push   $0x0
  jmp alltraps
80106c62:	e9 52 f9 ff ff       	jmp    801065b9 <alltraps>

80106c67 <vector1>:
.globl vector1
vector1:
  pushl $0
80106c67:	6a 00                	push   $0x0
  pushl $1
80106c69:	6a 01                	push   $0x1
  jmp alltraps
80106c6b:	e9 49 f9 ff ff       	jmp    801065b9 <alltraps>

80106c70 <vector2>:
.globl vector2
vector2:
  pushl $0
80106c70:	6a 00                	push   $0x0
  pushl $2
80106c72:	6a 02                	push   $0x2
  jmp alltraps
80106c74:	e9 40 f9 ff ff       	jmp    801065b9 <alltraps>

80106c79 <vector3>:
.globl vector3
vector3:
  pushl $0
80106c79:	6a 00                	push   $0x0
  pushl $3
80106c7b:	6a 03                	push   $0x3
  jmp alltraps
80106c7d:	e9 37 f9 ff ff       	jmp    801065b9 <alltraps>

80106c82 <vector4>:
.globl vector4
vector4:
  pushl $0
80106c82:	6a 00                	push   $0x0
  pushl $4
80106c84:	6a 04                	push   $0x4
  jmp alltraps
80106c86:	e9 2e f9 ff ff       	jmp    801065b9 <alltraps>

80106c8b <vector5>:
.globl vector5
vector5:
  pushl $0
80106c8b:	6a 00                	push   $0x0
  pushl $5
80106c8d:	6a 05                	push   $0x5
  jmp alltraps
80106c8f:	e9 25 f9 ff ff       	jmp    801065b9 <alltraps>

80106c94 <vector6>:
.globl vector6
vector6:
  pushl $0
80106c94:	6a 00                	push   $0x0
  pushl $6
80106c96:	6a 06                	push   $0x6
  jmp alltraps
80106c98:	e9 1c f9 ff ff       	jmp    801065b9 <alltraps>

80106c9d <vector7>:
.globl vector7
vector7:
  pushl $0
80106c9d:	6a 00                	push   $0x0
  pushl $7
80106c9f:	6a 07                	push   $0x7
  jmp alltraps
80106ca1:	e9 13 f9 ff ff       	jmp    801065b9 <alltraps>

80106ca6 <vector8>:
.globl vector8
vector8:
  pushl $8
80106ca6:	6a 08                	push   $0x8
  jmp alltraps
80106ca8:	e9 0c f9 ff ff       	jmp    801065b9 <alltraps>

80106cad <vector9>:
.globl vector9
vector9:
  pushl $0
80106cad:	6a 00                	push   $0x0
  pushl $9
80106caf:	6a 09                	push   $0x9
  jmp alltraps
80106cb1:	e9 03 f9 ff ff       	jmp    801065b9 <alltraps>

80106cb6 <vector10>:
.globl vector10
vector10:
  pushl $10
80106cb6:	6a 0a                	push   $0xa
  jmp alltraps
80106cb8:	e9 fc f8 ff ff       	jmp    801065b9 <alltraps>

80106cbd <vector11>:
.globl vector11
vector11:
  pushl $11
80106cbd:	6a 0b                	push   $0xb
  jmp alltraps
80106cbf:	e9 f5 f8 ff ff       	jmp    801065b9 <alltraps>

80106cc4 <vector12>:
.globl vector12
vector12:
  pushl $12
80106cc4:	6a 0c                	push   $0xc
  jmp alltraps
80106cc6:	e9 ee f8 ff ff       	jmp    801065b9 <alltraps>

80106ccb <vector13>:
.globl vector13
vector13:
  pushl $13
80106ccb:	6a 0d                	push   $0xd
  jmp alltraps
80106ccd:	e9 e7 f8 ff ff       	jmp    801065b9 <alltraps>

80106cd2 <vector14>:
.globl vector14
vector14:
  pushl $14
80106cd2:	6a 0e                	push   $0xe
  jmp alltraps
80106cd4:	e9 e0 f8 ff ff       	jmp    801065b9 <alltraps>

80106cd9 <vector15>:
.globl vector15
vector15:
  pushl $0
80106cd9:	6a 00                	push   $0x0
  pushl $15
80106cdb:	6a 0f                	push   $0xf
  jmp alltraps
80106cdd:	e9 d7 f8 ff ff       	jmp    801065b9 <alltraps>

80106ce2 <vector16>:
.globl vector16
vector16:
  pushl $0
80106ce2:	6a 00                	push   $0x0
  pushl $16
80106ce4:	6a 10                	push   $0x10
  jmp alltraps
80106ce6:	e9 ce f8 ff ff       	jmp    801065b9 <alltraps>

80106ceb <vector17>:
.globl vector17
vector17:
  pushl $17
80106ceb:	6a 11                	push   $0x11
  jmp alltraps
80106ced:	e9 c7 f8 ff ff       	jmp    801065b9 <alltraps>

80106cf2 <vector18>:
.globl vector18
vector18:
  pushl $0
80106cf2:	6a 00                	push   $0x0
  pushl $18
80106cf4:	6a 12                	push   $0x12
  jmp alltraps
80106cf6:	e9 be f8 ff ff       	jmp    801065b9 <alltraps>

80106cfb <vector19>:
.globl vector19
vector19:
  pushl $0
80106cfb:	6a 00                	push   $0x0
  pushl $19
80106cfd:	6a 13                	push   $0x13
  jmp alltraps
80106cff:	e9 b5 f8 ff ff       	jmp    801065b9 <alltraps>

80106d04 <vector20>:
.globl vector20
vector20:
  pushl $0
80106d04:	6a 00                	push   $0x0
  pushl $20
80106d06:	6a 14                	push   $0x14
  jmp alltraps
80106d08:	e9 ac f8 ff ff       	jmp    801065b9 <alltraps>

80106d0d <vector21>:
.globl vector21
vector21:
  pushl $0
80106d0d:	6a 00                	push   $0x0
  pushl $21
80106d0f:	6a 15                	push   $0x15
  jmp alltraps
80106d11:	e9 a3 f8 ff ff       	jmp    801065b9 <alltraps>

80106d16 <vector22>:
.globl vector22
vector22:
  pushl $0
80106d16:	6a 00                	push   $0x0
  pushl $22
80106d18:	6a 16                	push   $0x16
  jmp alltraps
80106d1a:	e9 9a f8 ff ff       	jmp    801065b9 <alltraps>

80106d1f <vector23>:
.globl vector23
vector23:
  pushl $0
80106d1f:	6a 00                	push   $0x0
  pushl $23
80106d21:	6a 17                	push   $0x17
  jmp alltraps
80106d23:	e9 91 f8 ff ff       	jmp    801065b9 <alltraps>

80106d28 <vector24>:
.globl vector24
vector24:
  pushl $0
80106d28:	6a 00                	push   $0x0
  pushl $24
80106d2a:	6a 18                	push   $0x18
  jmp alltraps
80106d2c:	e9 88 f8 ff ff       	jmp    801065b9 <alltraps>

80106d31 <vector25>:
.globl vector25
vector25:
  pushl $0
80106d31:	6a 00                	push   $0x0
  pushl $25
80106d33:	6a 19                	push   $0x19
  jmp alltraps
80106d35:	e9 7f f8 ff ff       	jmp    801065b9 <alltraps>

80106d3a <vector26>:
.globl vector26
vector26:
  pushl $0
80106d3a:	6a 00                	push   $0x0
  pushl $26
80106d3c:	6a 1a                	push   $0x1a
  jmp alltraps
80106d3e:	e9 76 f8 ff ff       	jmp    801065b9 <alltraps>

80106d43 <vector27>:
.globl vector27
vector27:
  pushl $0
80106d43:	6a 00                	push   $0x0
  pushl $27
80106d45:	6a 1b                	push   $0x1b
  jmp alltraps
80106d47:	e9 6d f8 ff ff       	jmp    801065b9 <alltraps>

80106d4c <vector28>:
.globl vector28
vector28:
  pushl $0
80106d4c:	6a 00                	push   $0x0
  pushl $28
80106d4e:	6a 1c                	push   $0x1c
  jmp alltraps
80106d50:	e9 64 f8 ff ff       	jmp    801065b9 <alltraps>

80106d55 <vector29>:
.globl vector29
vector29:
  pushl $0
80106d55:	6a 00                	push   $0x0
  pushl $29
80106d57:	6a 1d                	push   $0x1d
  jmp alltraps
80106d59:	e9 5b f8 ff ff       	jmp    801065b9 <alltraps>

80106d5e <vector30>:
.globl vector30
vector30:
  pushl $0
80106d5e:	6a 00                	push   $0x0
  pushl $30
80106d60:	6a 1e                	push   $0x1e
  jmp alltraps
80106d62:	e9 52 f8 ff ff       	jmp    801065b9 <alltraps>

80106d67 <vector31>:
.globl vector31
vector31:
  pushl $0
80106d67:	6a 00                	push   $0x0
  pushl $31
80106d69:	6a 1f                	push   $0x1f
  jmp alltraps
80106d6b:	e9 49 f8 ff ff       	jmp    801065b9 <alltraps>

80106d70 <vector32>:
.globl vector32
vector32:
  pushl $0
80106d70:	6a 00                	push   $0x0
  pushl $32
80106d72:	6a 20                	push   $0x20
  jmp alltraps
80106d74:	e9 40 f8 ff ff       	jmp    801065b9 <alltraps>

80106d79 <vector33>:
.globl vector33
vector33:
  pushl $0
80106d79:	6a 00                	push   $0x0
  pushl $33
80106d7b:	6a 21                	push   $0x21
  jmp alltraps
80106d7d:	e9 37 f8 ff ff       	jmp    801065b9 <alltraps>

80106d82 <vector34>:
.globl vector34
vector34:
  pushl $0
80106d82:	6a 00                	push   $0x0
  pushl $34
80106d84:	6a 22                	push   $0x22
  jmp alltraps
80106d86:	e9 2e f8 ff ff       	jmp    801065b9 <alltraps>

80106d8b <vector35>:
.globl vector35
vector35:
  pushl $0
80106d8b:	6a 00                	push   $0x0
  pushl $35
80106d8d:	6a 23                	push   $0x23
  jmp alltraps
80106d8f:	e9 25 f8 ff ff       	jmp    801065b9 <alltraps>

80106d94 <vector36>:
.globl vector36
vector36:
  pushl $0
80106d94:	6a 00                	push   $0x0
  pushl $36
80106d96:	6a 24                	push   $0x24
  jmp alltraps
80106d98:	e9 1c f8 ff ff       	jmp    801065b9 <alltraps>

80106d9d <vector37>:
.globl vector37
vector37:
  pushl $0
80106d9d:	6a 00                	push   $0x0
  pushl $37
80106d9f:	6a 25                	push   $0x25
  jmp alltraps
80106da1:	e9 13 f8 ff ff       	jmp    801065b9 <alltraps>

80106da6 <vector38>:
.globl vector38
vector38:
  pushl $0
80106da6:	6a 00                	push   $0x0
  pushl $38
80106da8:	6a 26                	push   $0x26
  jmp alltraps
80106daa:	e9 0a f8 ff ff       	jmp    801065b9 <alltraps>

80106daf <vector39>:
.globl vector39
vector39:
  pushl $0
80106daf:	6a 00                	push   $0x0
  pushl $39
80106db1:	6a 27                	push   $0x27
  jmp alltraps
80106db3:	e9 01 f8 ff ff       	jmp    801065b9 <alltraps>

80106db8 <vector40>:
.globl vector40
vector40:
  pushl $0
80106db8:	6a 00                	push   $0x0
  pushl $40
80106dba:	6a 28                	push   $0x28
  jmp alltraps
80106dbc:	e9 f8 f7 ff ff       	jmp    801065b9 <alltraps>

80106dc1 <vector41>:
.globl vector41
vector41:
  pushl $0
80106dc1:	6a 00                	push   $0x0
  pushl $41
80106dc3:	6a 29                	push   $0x29
  jmp alltraps
80106dc5:	e9 ef f7 ff ff       	jmp    801065b9 <alltraps>

80106dca <vector42>:
.globl vector42
vector42:
  pushl $0
80106dca:	6a 00                	push   $0x0
  pushl $42
80106dcc:	6a 2a                	push   $0x2a
  jmp alltraps
80106dce:	e9 e6 f7 ff ff       	jmp    801065b9 <alltraps>

80106dd3 <vector43>:
.globl vector43
vector43:
  pushl $0
80106dd3:	6a 00                	push   $0x0
  pushl $43
80106dd5:	6a 2b                	push   $0x2b
  jmp alltraps
80106dd7:	e9 dd f7 ff ff       	jmp    801065b9 <alltraps>

80106ddc <vector44>:
.globl vector44
vector44:
  pushl $0
80106ddc:	6a 00                	push   $0x0
  pushl $44
80106dde:	6a 2c                	push   $0x2c
  jmp alltraps
80106de0:	e9 d4 f7 ff ff       	jmp    801065b9 <alltraps>

80106de5 <vector45>:
.globl vector45
vector45:
  pushl $0
80106de5:	6a 00                	push   $0x0
  pushl $45
80106de7:	6a 2d                	push   $0x2d
  jmp alltraps
80106de9:	e9 cb f7 ff ff       	jmp    801065b9 <alltraps>

80106dee <vector46>:
.globl vector46
vector46:
  pushl $0
80106dee:	6a 00                	push   $0x0
  pushl $46
80106df0:	6a 2e                	push   $0x2e
  jmp alltraps
80106df2:	e9 c2 f7 ff ff       	jmp    801065b9 <alltraps>

80106df7 <vector47>:
.globl vector47
vector47:
  pushl $0
80106df7:	6a 00                	push   $0x0
  pushl $47
80106df9:	6a 2f                	push   $0x2f
  jmp alltraps
80106dfb:	e9 b9 f7 ff ff       	jmp    801065b9 <alltraps>

80106e00 <vector48>:
.globl vector48
vector48:
  pushl $0
80106e00:	6a 00                	push   $0x0
  pushl $48
80106e02:	6a 30                	push   $0x30
  jmp alltraps
80106e04:	e9 b0 f7 ff ff       	jmp    801065b9 <alltraps>

80106e09 <vector49>:
.globl vector49
vector49:
  pushl $0
80106e09:	6a 00                	push   $0x0
  pushl $49
80106e0b:	6a 31                	push   $0x31
  jmp alltraps
80106e0d:	e9 a7 f7 ff ff       	jmp    801065b9 <alltraps>

80106e12 <vector50>:
.globl vector50
vector50:
  pushl $0
80106e12:	6a 00                	push   $0x0
  pushl $50
80106e14:	6a 32                	push   $0x32
  jmp alltraps
80106e16:	e9 9e f7 ff ff       	jmp    801065b9 <alltraps>

80106e1b <vector51>:
.globl vector51
vector51:
  pushl $0
80106e1b:	6a 00                	push   $0x0
  pushl $51
80106e1d:	6a 33                	push   $0x33
  jmp alltraps
80106e1f:	e9 95 f7 ff ff       	jmp    801065b9 <alltraps>

80106e24 <vector52>:
.globl vector52
vector52:
  pushl $0
80106e24:	6a 00                	push   $0x0
  pushl $52
80106e26:	6a 34                	push   $0x34
  jmp alltraps
80106e28:	e9 8c f7 ff ff       	jmp    801065b9 <alltraps>

80106e2d <vector53>:
.globl vector53
vector53:
  pushl $0
80106e2d:	6a 00                	push   $0x0
  pushl $53
80106e2f:	6a 35                	push   $0x35
  jmp alltraps
80106e31:	e9 83 f7 ff ff       	jmp    801065b9 <alltraps>

80106e36 <vector54>:
.globl vector54
vector54:
  pushl $0
80106e36:	6a 00                	push   $0x0
  pushl $54
80106e38:	6a 36                	push   $0x36
  jmp alltraps
80106e3a:	e9 7a f7 ff ff       	jmp    801065b9 <alltraps>

80106e3f <vector55>:
.globl vector55
vector55:
  pushl $0
80106e3f:	6a 00                	push   $0x0
  pushl $55
80106e41:	6a 37                	push   $0x37
  jmp alltraps
80106e43:	e9 71 f7 ff ff       	jmp    801065b9 <alltraps>

80106e48 <vector56>:
.globl vector56
vector56:
  pushl $0
80106e48:	6a 00                	push   $0x0
  pushl $56
80106e4a:	6a 38                	push   $0x38
  jmp alltraps
80106e4c:	e9 68 f7 ff ff       	jmp    801065b9 <alltraps>

80106e51 <vector57>:
.globl vector57
vector57:
  pushl $0
80106e51:	6a 00                	push   $0x0
  pushl $57
80106e53:	6a 39                	push   $0x39
  jmp alltraps
80106e55:	e9 5f f7 ff ff       	jmp    801065b9 <alltraps>

80106e5a <vector58>:
.globl vector58
vector58:
  pushl $0
80106e5a:	6a 00                	push   $0x0
  pushl $58
80106e5c:	6a 3a                	push   $0x3a
  jmp alltraps
80106e5e:	e9 56 f7 ff ff       	jmp    801065b9 <alltraps>

80106e63 <vector59>:
.globl vector59
vector59:
  pushl $0
80106e63:	6a 00                	push   $0x0
  pushl $59
80106e65:	6a 3b                	push   $0x3b
  jmp alltraps
80106e67:	e9 4d f7 ff ff       	jmp    801065b9 <alltraps>

80106e6c <vector60>:
.globl vector60
vector60:
  pushl $0
80106e6c:	6a 00                	push   $0x0
  pushl $60
80106e6e:	6a 3c                	push   $0x3c
  jmp alltraps
80106e70:	e9 44 f7 ff ff       	jmp    801065b9 <alltraps>

80106e75 <vector61>:
.globl vector61
vector61:
  pushl $0
80106e75:	6a 00                	push   $0x0
  pushl $61
80106e77:	6a 3d                	push   $0x3d
  jmp alltraps
80106e79:	e9 3b f7 ff ff       	jmp    801065b9 <alltraps>

80106e7e <vector62>:
.globl vector62
vector62:
  pushl $0
80106e7e:	6a 00                	push   $0x0
  pushl $62
80106e80:	6a 3e                	push   $0x3e
  jmp alltraps
80106e82:	e9 32 f7 ff ff       	jmp    801065b9 <alltraps>

80106e87 <vector63>:
.globl vector63
vector63:
  pushl $0
80106e87:	6a 00                	push   $0x0
  pushl $63
80106e89:	6a 3f                	push   $0x3f
  jmp alltraps
80106e8b:	e9 29 f7 ff ff       	jmp    801065b9 <alltraps>

80106e90 <vector64>:
.globl vector64
vector64:
  pushl $0
80106e90:	6a 00                	push   $0x0
  pushl $64
80106e92:	6a 40                	push   $0x40
  jmp alltraps
80106e94:	e9 20 f7 ff ff       	jmp    801065b9 <alltraps>

80106e99 <vector65>:
.globl vector65
vector65:
  pushl $0
80106e99:	6a 00                	push   $0x0
  pushl $65
80106e9b:	6a 41                	push   $0x41
  jmp alltraps
80106e9d:	e9 17 f7 ff ff       	jmp    801065b9 <alltraps>

80106ea2 <vector66>:
.globl vector66
vector66:
  pushl $0
80106ea2:	6a 00                	push   $0x0
  pushl $66
80106ea4:	6a 42                	push   $0x42
  jmp alltraps
80106ea6:	e9 0e f7 ff ff       	jmp    801065b9 <alltraps>

80106eab <vector67>:
.globl vector67
vector67:
  pushl $0
80106eab:	6a 00                	push   $0x0
  pushl $67
80106ead:	6a 43                	push   $0x43
  jmp alltraps
80106eaf:	e9 05 f7 ff ff       	jmp    801065b9 <alltraps>

80106eb4 <vector68>:
.globl vector68
vector68:
  pushl $0
80106eb4:	6a 00                	push   $0x0
  pushl $68
80106eb6:	6a 44                	push   $0x44
  jmp alltraps
80106eb8:	e9 fc f6 ff ff       	jmp    801065b9 <alltraps>

80106ebd <vector69>:
.globl vector69
vector69:
  pushl $0
80106ebd:	6a 00                	push   $0x0
  pushl $69
80106ebf:	6a 45                	push   $0x45
  jmp alltraps
80106ec1:	e9 f3 f6 ff ff       	jmp    801065b9 <alltraps>

80106ec6 <vector70>:
.globl vector70
vector70:
  pushl $0
80106ec6:	6a 00                	push   $0x0
  pushl $70
80106ec8:	6a 46                	push   $0x46
  jmp alltraps
80106eca:	e9 ea f6 ff ff       	jmp    801065b9 <alltraps>

80106ecf <vector71>:
.globl vector71
vector71:
  pushl $0
80106ecf:	6a 00                	push   $0x0
  pushl $71
80106ed1:	6a 47                	push   $0x47
  jmp alltraps
80106ed3:	e9 e1 f6 ff ff       	jmp    801065b9 <alltraps>

80106ed8 <vector72>:
.globl vector72
vector72:
  pushl $0
80106ed8:	6a 00                	push   $0x0
  pushl $72
80106eda:	6a 48                	push   $0x48
  jmp alltraps
80106edc:	e9 d8 f6 ff ff       	jmp    801065b9 <alltraps>

80106ee1 <vector73>:
.globl vector73
vector73:
  pushl $0
80106ee1:	6a 00                	push   $0x0
  pushl $73
80106ee3:	6a 49                	push   $0x49
  jmp alltraps
80106ee5:	e9 cf f6 ff ff       	jmp    801065b9 <alltraps>

80106eea <vector74>:
.globl vector74
vector74:
  pushl $0
80106eea:	6a 00                	push   $0x0
  pushl $74
80106eec:	6a 4a                	push   $0x4a
  jmp alltraps
80106eee:	e9 c6 f6 ff ff       	jmp    801065b9 <alltraps>

80106ef3 <vector75>:
.globl vector75
vector75:
  pushl $0
80106ef3:	6a 00                	push   $0x0
  pushl $75
80106ef5:	6a 4b                	push   $0x4b
  jmp alltraps
80106ef7:	e9 bd f6 ff ff       	jmp    801065b9 <alltraps>

80106efc <vector76>:
.globl vector76
vector76:
  pushl $0
80106efc:	6a 00                	push   $0x0
  pushl $76
80106efe:	6a 4c                	push   $0x4c
  jmp alltraps
80106f00:	e9 b4 f6 ff ff       	jmp    801065b9 <alltraps>

80106f05 <vector77>:
.globl vector77
vector77:
  pushl $0
80106f05:	6a 00                	push   $0x0
  pushl $77
80106f07:	6a 4d                	push   $0x4d
  jmp alltraps
80106f09:	e9 ab f6 ff ff       	jmp    801065b9 <alltraps>

80106f0e <vector78>:
.globl vector78
vector78:
  pushl $0
80106f0e:	6a 00                	push   $0x0
  pushl $78
80106f10:	6a 4e                	push   $0x4e
  jmp alltraps
80106f12:	e9 a2 f6 ff ff       	jmp    801065b9 <alltraps>

80106f17 <vector79>:
.globl vector79
vector79:
  pushl $0
80106f17:	6a 00                	push   $0x0
  pushl $79
80106f19:	6a 4f                	push   $0x4f
  jmp alltraps
80106f1b:	e9 99 f6 ff ff       	jmp    801065b9 <alltraps>

80106f20 <vector80>:
.globl vector80
vector80:
  pushl $0
80106f20:	6a 00                	push   $0x0
  pushl $80
80106f22:	6a 50                	push   $0x50
  jmp alltraps
80106f24:	e9 90 f6 ff ff       	jmp    801065b9 <alltraps>

80106f29 <vector81>:
.globl vector81
vector81:
  pushl $0
80106f29:	6a 00                	push   $0x0
  pushl $81
80106f2b:	6a 51                	push   $0x51
  jmp alltraps
80106f2d:	e9 87 f6 ff ff       	jmp    801065b9 <alltraps>

80106f32 <vector82>:
.globl vector82
vector82:
  pushl $0
80106f32:	6a 00                	push   $0x0
  pushl $82
80106f34:	6a 52                	push   $0x52
  jmp alltraps
80106f36:	e9 7e f6 ff ff       	jmp    801065b9 <alltraps>

80106f3b <vector83>:
.globl vector83
vector83:
  pushl $0
80106f3b:	6a 00                	push   $0x0
  pushl $83
80106f3d:	6a 53                	push   $0x53
  jmp alltraps
80106f3f:	e9 75 f6 ff ff       	jmp    801065b9 <alltraps>

80106f44 <vector84>:
.globl vector84
vector84:
  pushl $0
80106f44:	6a 00                	push   $0x0
  pushl $84
80106f46:	6a 54                	push   $0x54
  jmp alltraps
80106f48:	e9 6c f6 ff ff       	jmp    801065b9 <alltraps>

80106f4d <vector85>:
.globl vector85
vector85:
  pushl $0
80106f4d:	6a 00                	push   $0x0
  pushl $85
80106f4f:	6a 55                	push   $0x55
  jmp alltraps
80106f51:	e9 63 f6 ff ff       	jmp    801065b9 <alltraps>

80106f56 <vector86>:
.globl vector86
vector86:
  pushl $0
80106f56:	6a 00                	push   $0x0
  pushl $86
80106f58:	6a 56                	push   $0x56
  jmp alltraps
80106f5a:	e9 5a f6 ff ff       	jmp    801065b9 <alltraps>

80106f5f <vector87>:
.globl vector87
vector87:
  pushl $0
80106f5f:	6a 00                	push   $0x0
  pushl $87
80106f61:	6a 57                	push   $0x57
  jmp alltraps
80106f63:	e9 51 f6 ff ff       	jmp    801065b9 <alltraps>

80106f68 <vector88>:
.globl vector88
vector88:
  pushl $0
80106f68:	6a 00                	push   $0x0
  pushl $88
80106f6a:	6a 58                	push   $0x58
  jmp alltraps
80106f6c:	e9 48 f6 ff ff       	jmp    801065b9 <alltraps>

80106f71 <vector89>:
.globl vector89
vector89:
  pushl $0
80106f71:	6a 00                	push   $0x0
  pushl $89
80106f73:	6a 59                	push   $0x59
  jmp alltraps
80106f75:	e9 3f f6 ff ff       	jmp    801065b9 <alltraps>

80106f7a <vector90>:
.globl vector90
vector90:
  pushl $0
80106f7a:	6a 00                	push   $0x0
  pushl $90
80106f7c:	6a 5a                	push   $0x5a
  jmp alltraps
80106f7e:	e9 36 f6 ff ff       	jmp    801065b9 <alltraps>

80106f83 <vector91>:
.globl vector91
vector91:
  pushl $0
80106f83:	6a 00                	push   $0x0
  pushl $91
80106f85:	6a 5b                	push   $0x5b
  jmp alltraps
80106f87:	e9 2d f6 ff ff       	jmp    801065b9 <alltraps>

80106f8c <vector92>:
.globl vector92
vector92:
  pushl $0
80106f8c:	6a 00                	push   $0x0
  pushl $92
80106f8e:	6a 5c                	push   $0x5c
  jmp alltraps
80106f90:	e9 24 f6 ff ff       	jmp    801065b9 <alltraps>

80106f95 <vector93>:
.globl vector93
vector93:
  pushl $0
80106f95:	6a 00                	push   $0x0
  pushl $93
80106f97:	6a 5d                	push   $0x5d
  jmp alltraps
80106f99:	e9 1b f6 ff ff       	jmp    801065b9 <alltraps>

80106f9e <vector94>:
.globl vector94
vector94:
  pushl $0
80106f9e:	6a 00                	push   $0x0
  pushl $94
80106fa0:	6a 5e                	push   $0x5e
  jmp alltraps
80106fa2:	e9 12 f6 ff ff       	jmp    801065b9 <alltraps>

80106fa7 <vector95>:
.globl vector95
vector95:
  pushl $0
80106fa7:	6a 00                	push   $0x0
  pushl $95
80106fa9:	6a 5f                	push   $0x5f
  jmp alltraps
80106fab:	e9 09 f6 ff ff       	jmp    801065b9 <alltraps>

80106fb0 <vector96>:
.globl vector96
vector96:
  pushl $0
80106fb0:	6a 00                	push   $0x0
  pushl $96
80106fb2:	6a 60                	push   $0x60
  jmp alltraps
80106fb4:	e9 00 f6 ff ff       	jmp    801065b9 <alltraps>

80106fb9 <vector97>:
.globl vector97
vector97:
  pushl $0
80106fb9:	6a 00                	push   $0x0
  pushl $97
80106fbb:	6a 61                	push   $0x61
  jmp alltraps
80106fbd:	e9 f7 f5 ff ff       	jmp    801065b9 <alltraps>

80106fc2 <vector98>:
.globl vector98
vector98:
  pushl $0
80106fc2:	6a 00                	push   $0x0
  pushl $98
80106fc4:	6a 62                	push   $0x62
  jmp alltraps
80106fc6:	e9 ee f5 ff ff       	jmp    801065b9 <alltraps>

80106fcb <vector99>:
.globl vector99
vector99:
  pushl $0
80106fcb:	6a 00                	push   $0x0
  pushl $99
80106fcd:	6a 63                	push   $0x63
  jmp alltraps
80106fcf:	e9 e5 f5 ff ff       	jmp    801065b9 <alltraps>

80106fd4 <vector100>:
.globl vector100
vector100:
  pushl $0
80106fd4:	6a 00                	push   $0x0
  pushl $100
80106fd6:	6a 64                	push   $0x64
  jmp alltraps
80106fd8:	e9 dc f5 ff ff       	jmp    801065b9 <alltraps>

80106fdd <vector101>:
.globl vector101
vector101:
  pushl $0
80106fdd:	6a 00                	push   $0x0
  pushl $101
80106fdf:	6a 65                	push   $0x65
  jmp alltraps
80106fe1:	e9 d3 f5 ff ff       	jmp    801065b9 <alltraps>

80106fe6 <vector102>:
.globl vector102
vector102:
  pushl $0
80106fe6:	6a 00                	push   $0x0
  pushl $102
80106fe8:	6a 66                	push   $0x66
  jmp alltraps
80106fea:	e9 ca f5 ff ff       	jmp    801065b9 <alltraps>

80106fef <vector103>:
.globl vector103
vector103:
  pushl $0
80106fef:	6a 00                	push   $0x0
  pushl $103
80106ff1:	6a 67                	push   $0x67
  jmp alltraps
80106ff3:	e9 c1 f5 ff ff       	jmp    801065b9 <alltraps>

80106ff8 <vector104>:
.globl vector104
vector104:
  pushl $0
80106ff8:	6a 00                	push   $0x0
  pushl $104
80106ffa:	6a 68                	push   $0x68
  jmp alltraps
80106ffc:	e9 b8 f5 ff ff       	jmp    801065b9 <alltraps>

80107001 <vector105>:
.globl vector105
vector105:
  pushl $0
80107001:	6a 00                	push   $0x0
  pushl $105
80107003:	6a 69                	push   $0x69
  jmp alltraps
80107005:	e9 af f5 ff ff       	jmp    801065b9 <alltraps>

8010700a <vector106>:
.globl vector106
vector106:
  pushl $0
8010700a:	6a 00                	push   $0x0
  pushl $106
8010700c:	6a 6a                	push   $0x6a
  jmp alltraps
8010700e:	e9 a6 f5 ff ff       	jmp    801065b9 <alltraps>

80107013 <vector107>:
.globl vector107
vector107:
  pushl $0
80107013:	6a 00                	push   $0x0
  pushl $107
80107015:	6a 6b                	push   $0x6b
  jmp alltraps
80107017:	e9 9d f5 ff ff       	jmp    801065b9 <alltraps>

8010701c <vector108>:
.globl vector108
vector108:
  pushl $0
8010701c:	6a 00                	push   $0x0
  pushl $108
8010701e:	6a 6c                	push   $0x6c
  jmp alltraps
80107020:	e9 94 f5 ff ff       	jmp    801065b9 <alltraps>

80107025 <vector109>:
.globl vector109
vector109:
  pushl $0
80107025:	6a 00                	push   $0x0
  pushl $109
80107027:	6a 6d                	push   $0x6d
  jmp alltraps
80107029:	e9 8b f5 ff ff       	jmp    801065b9 <alltraps>

8010702e <vector110>:
.globl vector110
vector110:
  pushl $0
8010702e:	6a 00                	push   $0x0
  pushl $110
80107030:	6a 6e                	push   $0x6e
  jmp alltraps
80107032:	e9 82 f5 ff ff       	jmp    801065b9 <alltraps>

80107037 <vector111>:
.globl vector111
vector111:
  pushl $0
80107037:	6a 00                	push   $0x0
  pushl $111
80107039:	6a 6f                	push   $0x6f
  jmp alltraps
8010703b:	e9 79 f5 ff ff       	jmp    801065b9 <alltraps>

80107040 <vector112>:
.globl vector112
vector112:
  pushl $0
80107040:	6a 00                	push   $0x0
  pushl $112
80107042:	6a 70                	push   $0x70
  jmp alltraps
80107044:	e9 70 f5 ff ff       	jmp    801065b9 <alltraps>

80107049 <vector113>:
.globl vector113
vector113:
  pushl $0
80107049:	6a 00                	push   $0x0
  pushl $113
8010704b:	6a 71                	push   $0x71
  jmp alltraps
8010704d:	e9 67 f5 ff ff       	jmp    801065b9 <alltraps>

80107052 <vector114>:
.globl vector114
vector114:
  pushl $0
80107052:	6a 00                	push   $0x0
  pushl $114
80107054:	6a 72                	push   $0x72
  jmp alltraps
80107056:	e9 5e f5 ff ff       	jmp    801065b9 <alltraps>

8010705b <vector115>:
.globl vector115
vector115:
  pushl $0
8010705b:	6a 00                	push   $0x0
  pushl $115
8010705d:	6a 73                	push   $0x73
  jmp alltraps
8010705f:	e9 55 f5 ff ff       	jmp    801065b9 <alltraps>

80107064 <vector116>:
.globl vector116
vector116:
  pushl $0
80107064:	6a 00                	push   $0x0
  pushl $116
80107066:	6a 74                	push   $0x74
  jmp alltraps
80107068:	e9 4c f5 ff ff       	jmp    801065b9 <alltraps>

8010706d <vector117>:
.globl vector117
vector117:
  pushl $0
8010706d:	6a 00                	push   $0x0
  pushl $117
8010706f:	6a 75                	push   $0x75
  jmp alltraps
80107071:	e9 43 f5 ff ff       	jmp    801065b9 <alltraps>

80107076 <vector118>:
.globl vector118
vector118:
  pushl $0
80107076:	6a 00                	push   $0x0
  pushl $118
80107078:	6a 76                	push   $0x76
  jmp alltraps
8010707a:	e9 3a f5 ff ff       	jmp    801065b9 <alltraps>

8010707f <vector119>:
.globl vector119
vector119:
  pushl $0
8010707f:	6a 00                	push   $0x0
  pushl $119
80107081:	6a 77                	push   $0x77
  jmp alltraps
80107083:	e9 31 f5 ff ff       	jmp    801065b9 <alltraps>

80107088 <vector120>:
.globl vector120
vector120:
  pushl $0
80107088:	6a 00                	push   $0x0
  pushl $120
8010708a:	6a 78                	push   $0x78
  jmp alltraps
8010708c:	e9 28 f5 ff ff       	jmp    801065b9 <alltraps>

80107091 <vector121>:
.globl vector121
vector121:
  pushl $0
80107091:	6a 00                	push   $0x0
  pushl $121
80107093:	6a 79                	push   $0x79
  jmp alltraps
80107095:	e9 1f f5 ff ff       	jmp    801065b9 <alltraps>

8010709a <vector122>:
.globl vector122
vector122:
  pushl $0
8010709a:	6a 00                	push   $0x0
  pushl $122
8010709c:	6a 7a                	push   $0x7a
  jmp alltraps
8010709e:	e9 16 f5 ff ff       	jmp    801065b9 <alltraps>

801070a3 <vector123>:
.globl vector123
vector123:
  pushl $0
801070a3:	6a 00                	push   $0x0
  pushl $123
801070a5:	6a 7b                	push   $0x7b
  jmp alltraps
801070a7:	e9 0d f5 ff ff       	jmp    801065b9 <alltraps>

801070ac <vector124>:
.globl vector124
vector124:
  pushl $0
801070ac:	6a 00                	push   $0x0
  pushl $124
801070ae:	6a 7c                	push   $0x7c
  jmp alltraps
801070b0:	e9 04 f5 ff ff       	jmp    801065b9 <alltraps>

801070b5 <vector125>:
.globl vector125
vector125:
  pushl $0
801070b5:	6a 00                	push   $0x0
  pushl $125
801070b7:	6a 7d                	push   $0x7d
  jmp alltraps
801070b9:	e9 fb f4 ff ff       	jmp    801065b9 <alltraps>

801070be <vector126>:
.globl vector126
vector126:
  pushl $0
801070be:	6a 00                	push   $0x0
  pushl $126
801070c0:	6a 7e                	push   $0x7e
  jmp alltraps
801070c2:	e9 f2 f4 ff ff       	jmp    801065b9 <alltraps>

801070c7 <vector127>:
.globl vector127
vector127:
  pushl $0
801070c7:	6a 00                	push   $0x0
  pushl $127
801070c9:	6a 7f                	push   $0x7f
  jmp alltraps
801070cb:	e9 e9 f4 ff ff       	jmp    801065b9 <alltraps>

801070d0 <vector128>:
.globl vector128
vector128:
  pushl $0
801070d0:	6a 00                	push   $0x0
  pushl $128
801070d2:	68 80 00 00 00       	push   $0x80
  jmp alltraps
801070d7:	e9 dd f4 ff ff       	jmp    801065b9 <alltraps>

801070dc <vector129>:
.globl vector129
vector129:
  pushl $0
801070dc:	6a 00                	push   $0x0
  pushl $129
801070de:	68 81 00 00 00       	push   $0x81
  jmp alltraps
801070e3:	e9 d1 f4 ff ff       	jmp    801065b9 <alltraps>

801070e8 <vector130>:
.globl vector130
vector130:
  pushl $0
801070e8:	6a 00                	push   $0x0
  pushl $130
801070ea:	68 82 00 00 00       	push   $0x82
  jmp alltraps
801070ef:	e9 c5 f4 ff ff       	jmp    801065b9 <alltraps>

801070f4 <vector131>:
.globl vector131
vector131:
  pushl $0
801070f4:	6a 00                	push   $0x0
  pushl $131
801070f6:	68 83 00 00 00       	push   $0x83
  jmp alltraps
801070fb:	e9 b9 f4 ff ff       	jmp    801065b9 <alltraps>

80107100 <vector132>:
.globl vector132
vector132:
  pushl $0
80107100:	6a 00                	push   $0x0
  pushl $132
80107102:	68 84 00 00 00       	push   $0x84
  jmp alltraps
80107107:	e9 ad f4 ff ff       	jmp    801065b9 <alltraps>

8010710c <vector133>:
.globl vector133
vector133:
  pushl $0
8010710c:	6a 00                	push   $0x0
  pushl $133
8010710e:	68 85 00 00 00       	push   $0x85
  jmp alltraps
80107113:	e9 a1 f4 ff ff       	jmp    801065b9 <alltraps>

80107118 <vector134>:
.globl vector134
vector134:
  pushl $0
80107118:	6a 00                	push   $0x0
  pushl $134
8010711a:	68 86 00 00 00       	push   $0x86
  jmp alltraps
8010711f:	e9 95 f4 ff ff       	jmp    801065b9 <alltraps>

80107124 <vector135>:
.globl vector135
vector135:
  pushl $0
80107124:	6a 00                	push   $0x0
  pushl $135
80107126:	68 87 00 00 00       	push   $0x87
  jmp alltraps
8010712b:	e9 89 f4 ff ff       	jmp    801065b9 <alltraps>

80107130 <vector136>:
.globl vector136
vector136:
  pushl $0
80107130:	6a 00                	push   $0x0
  pushl $136
80107132:	68 88 00 00 00       	push   $0x88
  jmp alltraps
80107137:	e9 7d f4 ff ff       	jmp    801065b9 <alltraps>

8010713c <vector137>:
.globl vector137
vector137:
  pushl $0
8010713c:	6a 00                	push   $0x0
  pushl $137
8010713e:	68 89 00 00 00       	push   $0x89
  jmp alltraps
80107143:	e9 71 f4 ff ff       	jmp    801065b9 <alltraps>

80107148 <vector138>:
.globl vector138
vector138:
  pushl $0
80107148:	6a 00                	push   $0x0
  pushl $138
8010714a:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
8010714f:	e9 65 f4 ff ff       	jmp    801065b9 <alltraps>

80107154 <vector139>:
.globl vector139
vector139:
  pushl $0
80107154:	6a 00                	push   $0x0
  pushl $139
80107156:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
8010715b:	e9 59 f4 ff ff       	jmp    801065b9 <alltraps>

80107160 <vector140>:
.globl vector140
vector140:
  pushl $0
80107160:	6a 00                	push   $0x0
  pushl $140
80107162:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
80107167:	e9 4d f4 ff ff       	jmp    801065b9 <alltraps>

8010716c <vector141>:
.globl vector141
vector141:
  pushl $0
8010716c:	6a 00                	push   $0x0
  pushl $141
8010716e:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
80107173:	e9 41 f4 ff ff       	jmp    801065b9 <alltraps>

80107178 <vector142>:
.globl vector142
vector142:
  pushl $0
80107178:	6a 00                	push   $0x0
  pushl $142
8010717a:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
8010717f:	e9 35 f4 ff ff       	jmp    801065b9 <alltraps>

80107184 <vector143>:
.globl vector143
vector143:
  pushl $0
80107184:	6a 00                	push   $0x0
  pushl $143
80107186:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
8010718b:	e9 29 f4 ff ff       	jmp    801065b9 <alltraps>

80107190 <vector144>:
.globl vector144
vector144:
  pushl $0
80107190:	6a 00                	push   $0x0
  pushl $144
80107192:	68 90 00 00 00       	push   $0x90
  jmp alltraps
80107197:	e9 1d f4 ff ff       	jmp    801065b9 <alltraps>

8010719c <vector145>:
.globl vector145
vector145:
  pushl $0
8010719c:	6a 00                	push   $0x0
  pushl $145
8010719e:	68 91 00 00 00       	push   $0x91
  jmp alltraps
801071a3:	e9 11 f4 ff ff       	jmp    801065b9 <alltraps>

801071a8 <vector146>:
.globl vector146
vector146:
  pushl $0
801071a8:	6a 00                	push   $0x0
  pushl $146
801071aa:	68 92 00 00 00       	push   $0x92
  jmp alltraps
801071af:	e9 05 f4 ff ff       	jmp    801065b9 <alltraps>

801071b4 <vector147>:
.globl vector147
vector147:
  pushl $0
801071b4:	6a 00                	push   $0x0
  pushl $147
801071b6:	68 93 00 00 00       	push   $0x93
  jmp alltraps
801071bb:	e9 f9 f3 ff ff       	jmp    801065b9 <alltraps>

801071c0 <vector148>:
.globl vector148
vector148:
  pushl $0
801071c0:	6a 00                	push   $0x0
  pushl $148
801071c2:	68 94 00 00 00       	push   $0x94
  jmp alltraps
801071c7:	e9 ed f3 ff ff       	jmp    801065b9 <alltraps>

801071cc <vector149>:
.globl vector149
vector149:
  pushl $0
801071cc:	6a 00                	push   $0x0
  pushl $149
801071ce:	68 95 00 00 00       	push   $0x95
  jmp alltraps
801071d3:	e9 e1 f3 ff ff       	jmp    801065b9 <alltraps>

801071d8 <vector150>:
.globl vector150
vector150:
  pushl $0
801071d8:	6a 00                	push   $0x0
  pushl $150
801071da:	68 96 00 00 00       	push   $0x96
  jmp alltraps
801071df:	e9 d5 f3 ff ff       	jmp    801065b9 <alltraps>

801071e4 <vector151>:
.globl vector151
vector151:
  pushl $0
801071e4:	6a 00                	push   $0x0
  pushl $151
801071e6:	68 97 00 00 00       	push   $0x97
  jmp alltraps
801071eb:	e9 c9 f3 ff ff       	jmp    801065b9 <alltraps>

801071f0 <vector152>:
.globl vector152
vector152:
  pushl $0
801071f0:	6a 00                	push   $0x0
  pushl $152
801071f2:	68 98 00 00 00       	push   $0x98
  jmp alltraps
801071f7:	e9 bd f3 ff ff       	jmp    801065b9 <alltraps>

801071fc <vector153>:
.globl vector153
vector153:
  pushl $0
801071fc:	6a 00                	push   $0x0
  pushl $153
801071fe:	68 99 00 00 00       	push   $0x99
  jmp alltraps
80107203:	e9 b1 f3 ff ff       	jmp    801065b9 <alltraps>

80107208 <vector154>:
.globl vector154
vector154:
  pushl $0
80107208:	6a 00                	push   $0x0
  pushl $154
8010720a:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
8010720f:	e9 a5 f3 ff ff       	jmp    801065b9 <alltraps>

80107214 <vector155>:
.globl vector155
vector155:
  pushl $0
80107214:	6a 00                	push   $0x0
  pushl $155
80107216:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
8010721b:	e9 99 f3 ff ff       	jmp    801065b9 <alltraps>

80107220 <vector156>:
.globl vector156
vector156:
  pushl $0
80107220:	6a 00                	push   $0x0
  pushl $156
80107222:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
80107227:	e9 8d f3 ff ff       	jmp    801065b9 <alltraps>

8010722c <vector157>:
.globl vector157
vector157:
  pushl $0
8010722c:	6a 00                	push   $0x0
  pushl $157
8010722e:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
80107233:	e9 81 f3 ff ff       	jmp    801065b9 <alltraps>

80107238 <vector158>:
.globl vector158
vector158:
  pushl $0
80107238:	6a 00                	push   $0x0
  pushl $158
8010723a:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
8010723f:	e9 75 f3 ff ff       	jmp    801065b9 <alltraps>

80107244 <vector159>:
.globl vector159
vector159:
  pushl $0
80107244:	6a 00                	push   $0x0
  pushl $159
80107246:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
8010724b:	e9 69 f3 ff ff       	jmp    801065b9 <alltraps>

80107250 <vector160>:
.globl vector160
vector160:
  pushl $0
80107250:	6a 00                	push   $0x0
  pushl $160
80107252:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
80107257:	e9 5d f3 ff ff       	jmp    801065b9 <alltraps>

8010725c <vector161>:
.globl vector161
vector161:
  pushl $0
8010725c:	6a 00                	push   $0x0
  pushl $161
8010725e:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
80107263:	e9 51 f3 ff ff       	jmp    801065b9 <alltraps>

80107268 <vector162>:
.globl vector162
vector162:
  pushl $0
80107268:	6a 00                	push   $0x0
  pushl $162
8010726a:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
8010726f:	e9 45 f3 ff ff       	jmp    801065b9 <alltraps>

80107274 <vector163>:
.globl vector163
vector163:
  pushl $0
80107274:	6a 00                	push   $0x0
  pushl $163
80107276:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
8010727b:	e9 39 f3 ff ff       	jmp    801065b9 <alltraps>

80107280 <vector164>:
.globl vector164
vector164:
  pushl $0
80107280:	6a 00                	push   $0x0
  pushl $164
80107282:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
80107287:	e9 2d f3 ff ff       	jmp    801065b9 <alltraps>

8010728c <vector165>:
.globl vector165
vector165:
  pushl $0
8010728c:	6a 00                	push   $0x0
  pushl $165
8010728e:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
80107293:	e9 21 f3 ff ff       	jmp    801065b9 <alltraps>

80107298 <vector166>:
.globl vector166
vector166:
  pushl $0
80107298:	6a 00                	push   $0x0
  pushl $166
8010729a:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
8010729f:	e9 15 f3 ff ff       	jmp    801065b9 <alltraps>

801072a4 <vector167>:
.globl vector167
vector167:
  pushl $0
801072a4:	6a 00                	push   $0x0
  pushl $167
801072a6:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
801072ab:	e9 09 f3 ff ff       	jmp    801065b9 <alltraps>

801072b0 <vector168>:
.globl vector168
vector168:
  pushl $0
801072b0:	6a 00                	push   $0x0
  pushl $168
801072b2:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
801072b7:	e9 fd f2 ff ff       	jmp    801065b9 <alltraps>

801072bc <vector169>:
.globl vector169
vector169:
  pushl $0
801072bc:	6a 00                	push   $0x0
  pushl $169
801072be:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
801072c3:	e9 f1 f2 ff ff       	jmp    801065b9 <alltraps>

801072c8 <vector170>:
.globl vector170
vector170:
  pushl $0
801072c8:	6a 00                	push   $0x0
  pushl $170
801072ca:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
801072cf:	e9 e5 f2 ff ff       	jmp    801065b9 <alltraps>

801072d4 <vector171>:
.globl vector171
vector171:
  pushl $0
801072d4:	6a 00                	push   $0x0
  pushl $171
801072d6:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
801072db:	e9 d9 f2 ff ff       	jmp    801065b9 <alltraps>

801072e0 <vector172>:
.globl vector172
vector172:
  pushl $0
801072e0:	6a 00                	push   $0x0
  pushl $172
801072e2:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
801072e7:	e9 cd f2 ff ff       	jmp    801065b9 <alltraps>

801072ec <vector173>:
.globl vector173
vector173:
  pushl $0
801072ec:	6a 00                	push   $0x0
  pushl $173
801072ee:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
801072f3:	e9 c1 f2 ff ff       	jmp    801065b9 <alltraps>

801072f8 <vector174>:
.globl vector174
vector174:
  pushl $0
801072f8:	6a 00                	push   $0x0
  pushl $174
801072fa:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
801072ff:	e9 b5 f2 ff ff       	jmp    801065b9 <alltraps>

80107304 <vector175>:
.globl vector175
vector175:
  pushl $0
80107304:	6a 00                	push   $0x0
  pushl $175
80107306:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
8010730b:	e9 a9 f2 ff ff       	jmp    801065b9 <alltraps>

80107310 <vector176>:
.globl vector176
vector176:
  pushl $0
80107310:	6a 00                	push   $0x0
  pushl $176
80107312:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
80107317:	e9 9d f2 ff ff       	jmp    801065b9 <alltraps>

8010731c <vector177>:
.globl vector177
vector177:
  pushl $0
8010731c:	6a 00                	push   $0x0
  pushl $177
8010731e:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
80107323:	e9 91 f2 ff ff       	jmp    801065b9 <alltraps>

80107328 <vector178>:
.globl vector178
vector178:
  pushl $0
80107328:	6a 00                	push   $0x0
  pushl $178
8010732a:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
8010732f:	e9 85 f2 ff ff       	jmp    801065b9 <alltraps>

80107334 <vector179>:
.globl vector179
vector179:
  pushl $0
80107334:	6a 00                	push   $0x0
  pushl $179
80107336:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
8010733b:	e9 79 f2 ff ff       	jmp    801065b9 <alltraps>

80107340 <vector180>:
.globl vector180
vector180:
  pushl $0
80107340:	6a 00                	push   $0x0
  pushl $180
80107342:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
80107347:	e9 6d f2 ff ff       	jmp    801065b9 <alltraps>

8010734c <vector181>:
.globl vector181
vector181:
  pushl $0
8010734c:	6a 00                	push   $0x0
  pushl $181
8010734e:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
80107353:	e9 61 f2 ff ff       	jmp    801065b9 <alltraps>

80107358 <vector182>:
.globl vector182
vector182:
  pushl $0
80107358:	6a 00                	push   $0x0
  pushl $182
8010735a:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
8010735f:	e9 55 f2 ff ff       	jmp    801065b9 <alltraps>

80107364 <vector183>:
.globl vector183
vector183:
  pushl $0
80107364:	6a 00                	push   $0x0
  pushl $183
80107366:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
8010736b:	e9 49 f2 ff ff       	jmp    801065b9 <alltraps>

80107370 <vector184>:
.globl vector184
vector184:
  pushl $0
80107370:	6a 00                	push   $0x0
  pushl $184
80107372:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
80107377:	e9 3d f2 ff ff       	jmp    801065b9 <alltraps>

8010737c <vector185>:
.globl vector185
vector185:
  pushl $0
8010737c:	6a 00                	push   $0x0
  pushl $185
8010737e:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
80107383:	e9 31 f2 ff ff       	jmp    801065b9 <alltraps>

80107388 <vector186>:
.globl vector186
vector186:
  pushl $0
80107388:	6a 00                	push   $0x0
  pushl $186
8010738a:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
8010738f:	e9 25 f2 ff ff       	jmp    801065b9 <alltraps>

80107394 <vector187>:
.globl vector187
vector187:
  pushl $0
80107394:	6a 00                	push   $0x0
  pushl $187
80107396:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
8010739b:	e9 19 f2 ff ff       	jmp    801065b9 <alltraps>

801073a0 <vector188>:
.globl vector188
vector188:
  pushl $0
801073a0:	6a 00                	push   $0x0
  pushl $188
801073a2:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
801073a7:	e9 0d f2 ff ff       	jmp    801065b9 <alltraps>

801073ac <vector189>:
.globl vector189
vector189:
  pushl $0
801073ac:	6a 00                	push   $0x0
  pushl $189
801073ae:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
801073b3:	e9 01 f2 ff ff       	jmp    801065b9 <alltraps>

801073b8 <vector190>:
.globl vector190
vector190:
  pushl $0
801073b8:	6a 00                	push   $0x0
  pushl $190
801073ba:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
801073bf:	e9 f5 f1 ff ff       	jmp    801065b9 <alltraps>

801073c4 <vector191>:
.globl vector191
vector191:
  pushl $0
801073c4:	6a 00                	push   $0x0
  pushl $191
801073c6:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
801073cb:	e9 e9 f1 ff ff       	jmp    801065b9 <alltraps>

801073d0 <vector192>:
.globl vector192
vector192:
  pushl $0
801073d0:	6a 00                	push   $0x0
  pushl $192
801073d2:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
801073d7:	e9 dd f1 ff ff       	jmp    801065b9 <alltraps>

801073dc <vector193>:
.globl vector193
vector193:
  pushl $0
801073dc:	6a 00                	push   $0x0
  pushl $193
801073de:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
801073e3:	e9 d1 f1 ff ff       	jmp    801065b9 <alltraps>

801073e8 <vector194>:
.globl vector194
vector194:
  pushl $0
801073e8:	6a 00                	push   $0x0
  pushl $194
801073ea:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
801073ef:	e9 c5 f1 ff ff       	jmp    801065b9 <alltraps>

801073f4 <vector195>:
.globl vector195
vector195:
  pushl $0
801073f4:	6a 00                	push   $0x0
  pushl $195
801073f6:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
801073fb:	e9 b9 f1 ff ff       	jmp    801065b9 <alltraps>

80107400 <vector196>:
.globl vector196
vector196:
  pushl $0
80107400:	6a 00                	push   $0x0
  pushl $196
80107402:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
80107407:	e9 ad f1 ff ff       	jmp    801065b9 <alltraps>

8010740c <vector197>:
.globl vector197
vector197:
  pushl $0
8010740c:	6a 00                	push   $0x0
  pushl $197
8010740e:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
80107413:	e9 a1 f1 ff ff       	jmp    801065b9 <alltraps>

80107418 <vector198>:
.globl vector198
vector198:
  pushl $0
80107418:	6a 00                	push   $0x0
  pushl $198
8010741a:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
8010741f:	e9 95 f1 ff ff       	jmp    801065b9 <alltraps>

80107424 <vector199>:
.globl vector199
vector199:
  pushl $0
80107424:	6a 00                	push   $0x0
  pushl $199
80107426:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
8010742b:	e9 89 f1 ff ff       	jmp    801065b9 <alltraps>

80107430 <vector200>:
.globl vector200
vector200:
  pushl $0
80107430:	6a 00                	push   $0x0
  pushl $200
80107432:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
80107437:	e9 7d f1 ff ff       	jmp    801065b9 <alltraps>

8010743c <vector201>:
.globl vector201
vector201:
  pushl $0
8010743c:	6a 00                	push   $0x0
  pushl $201
8010743e:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
80107443:	e9 71 f1 ff ff       	jmp    801065b9 <alltraps>

80107448 <vector202>:
.globl vector202
vector202:
  pushl $0
80107448:	6a 00                	push   $0x0
  pushl $202
8010744a:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
8010744f:	e9 65 f1 ff ff       	jmp    801065b9 <alltraps>

80107454 <vector203>:
.globl vector203
vector203:
  pushl $0
80107454:	6a 00                	push   $0x0
  pushl $203
80107456:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
8010745b:	e9 59 f1 ff ff       	jmp    801065b9 <alltraps>

80107460 <vector204>:
.globl vector204
vector204:
  pushl $0
80107460:	6a 00                	push   $0x0
  pushl $204
80107462:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
80107467:	e9 4d f1 ff ff       	jmp    801065b9 <alltraps>

8010746c <vector205>:
.globl vector205
vector205:
  pushl $0
8010746c:	6a 00                	push   $0x0
  pushl $205
8010746e:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
80107473:	e9 41 f1 ff ff       	jmp    801065b9 <alltraps>

80107478 <vector206>:
.globl vector206
vector206:
  pushl $0
80107478:	6a 00                	push   $0x0
  pushl $206
8010747a:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
8010747f:	e9 35 f1 ff ff       	jmp    801065b9 <alltraps>

80107484 <vector207>:
.globl vector207
vector207:
  pushl $0
80107484:	6a 00                	push   $0x0
  pushl $207
80107486:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
8010748b:	e9 29 f1 ff ff       	jmp    801065b9 <alltraps>

80107490 <vector208>:
.globl vector208
vector208:
  pushl $0
80107490:	6a 00                	push   $0x0
  pushl $208
80107492:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
80107497:	e9 1d f1 ff ff       	jmp    801065b9 <alltraps>

8010749c <vector209>:
.globl vector209
vector209:
  pushl $0
8010749c:	6a 00                	push   $0x0
  pushl $209
8010749e:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
801074a3:	e9 11 f1 ff ff       	jmp    801065b9 <alltraps>

801074a8 <vector210>:
.globl vector210
vector210:
  pushl $0
801074a8:	6a 00                	push   $0x0
  pushl $210
801074aa:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
801074af:	e9 05 f1 ff ff       	jmp    801065b9 <alltraps>

801074b4 <vector211>:
.globl vector211
vector211:
  pushl $0
801074b4:	6a 00                	push   $0x0
  pushl $211
801074b6:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
801074bb:	e9 f9 f0 ff ff       	jmp    801065b9 <alltraps>

801074c0 <vector212>:
.globl vector212
vector212:
  pushl $0
801074c0:	6a 00                	push   $0x0
  pushl $212
801074c2:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
801074c7:	e9 ed f0 ff ff       	jmp    801065b9 <alltraps>

801074cc <vector213>:
.globl vector213
vector213:
  pushl $0
801074cc:	6a 00                	push   $0x0
  pushl $213
801074ce:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
801074d3:	e9 e1 f0 ff ff       	jmp    801065b9 <alltraps>

801074d8 <vector214>:
.globl vector214
vector214:
  pushl $0
801074d8:	6a 00                	push   $0x0
  pushl $214
801074da:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
801074df:	e9 d5 f0 ff ff       	jmp    801065b9 <alltraps>

801074e4 <vector215>:
.globl vector215
vector215:
  pushl $0
801074e4:	6a 00                	push   $0x0
  pushl $215
801074e6:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
801074eb:	e9 c9 f0 ff ff       	jmp    801065b9 <alltraps>

801074f0 <vector216>:
.globl vector216
vector216:
  pushl $0
801074f0:	6a 00                	push   $0x0
  pushl $216
801074f2:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
801074f7:	e9 bd f0 ff ff       	jmp    801065b9 <alltraps>

801074fc <vector217>:
.globl vector217
vector217:
  pushl $0
801074fc:	6a 00                	push   $0x0
  pushl $217
801074fe:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
80107503:	e9 b1 f0 ff ff       	jmp    801065b9 <alltraps>

80107508 <vector218>:
.globl vector218
vector218:
  pushl $0
80107508:	6a 00                	push   $0x0
  pushl $218
8010750a:	68 da 00 00 00       	push   $0xda
  jmp alltraps
8010750f:	e9 a5 f0 ff ff       	jmp    801065b9 <alltraps>

80107514 <vector219>:
.globl vector219
vector219:
  pushl $0
80107514:	6a 00                	push   $0x0
  pushl $219
80107516:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
8010751b:	e9 99 f0 ff ff       	jmp    801065b9 <alltraps>

80107520 <vector220>:
.globl vector220
vector220:
  pushl $0
80107520:	6a 00                	push   $0x0
  pushl $220
80107522:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
80107527:	e9 8d f0 ff ff       	jmp    801065b9 <alltraps>

8010752c <vector221>:
.globl vector221
vector221:
  pushl $0
8010752c:	6a 00                	push   $0x0
  pushl $221
8010752e:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
80107533:	e9 81 f0 ff ff       	jmp    801065b9 <alltraps>

80107538 <vector222>:
.globl vector222
vector222:
  pushl $0
80107538:	6a 00                	push   $0x0
  pushl $222
8010753a:	68 de 00 00 00       	push   $0xde
  jmp alltraps
8010753f:	e9 75 f0 ff ff       	jmp    801065b9 <alltraps>

80107544 <vector223>:
.globl vector223
vector223:
  pushl $0
80107544:	6a 00                	push   $0x0
  pushl $223
80107546:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
8010754b:	e9 69 f0 ff ff       	jmp    801065b9 <alltraps>

80107550 <vector224>:
.globl vector224
vector224:
  pushl $0
80107550:	6a 00                	push   $0x0
  pushl $224
80107552:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
80107557:	e9 5d f0 ff ff       	jmp    801065b9 <alltraps>

8010755c <vector225>:
.globl vector225
vector225:
  pushl $0
8010755c:	6a 00                	push   $0x0
  pushl $225
8010755e:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
80107563:	e9 51 f0 ff ff       	jmp    801065b9 <alltraps>

80107568 <vector226>:
.globl vector226
vector226:
  pushl $0
80107568:	6a 00                	push   $0x0
  pushl $226
8010756a:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
8010756f:	e9 45 f0 ff ff       	jmp    801065b9 <alltraps>

80107574 <vector227>:
.globl vector227
vector227:
  pushl $0
80107574:	6a 00                	push   $0x0
  pushl $227
80107576:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
8010757b:	e9 39 f0 ff ff       	jmp    801065b9 <alltraps>

80107580 <vector228>:
.globl vector228
vector228:
  pushl $0
80107580:	6a 00                	push   $0x0
  pushl $228
80107582:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
80107587:	e9 2d f0 ff ff       	jmp    801065b9 <alltraps>

8010758c <vector229>:
.globl vector229
vector229:
  pushl $0
8010758c:	6a 00                	push   $0x0
  pushl $229
8010758e:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
80107593:	e9 21 f0 ff ff       	jmp    801065b9 <alltraps>

80107598 <vector230>:
.globl vector230
vector230:
  pushl $0
80107598:	6a 00                	push   $0x0
  pushl $230
8010759a:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
8010759f:	e9 15 f0 ff ff       	jmp    801065b9 <alltraps>

801075a4 <vector231>:
.globl vector231
vector231:
  pushl $0
801075a4:	6a 00                	push   $0x0
  pushl $231
801075a6:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
801075ab:	e9 09 f0 ff ff       	jmp    801065b9 <alltraps>

801075b0 <vector232>:
.globl vector232
vector232:
  pushl $0
801075b0:	6a 00                	push   $0x0
  pushl $232
801075b2:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
801075b7:	e9 fd ef ff ff       	jmp    801065b9 <alltraps>

801075bc <vector233>:
.globl vector233
vector233:
  pushl $0
801075bc:	6a 00                	push   $0x0
  pushl $233
801075be:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
801075c3:	e9 f1 ef ff ff       	jmp    801065b9 <alltraps>

801075c8 <vector234>:
.globl vector234
vector234:
  pushl $0
801075c8:	6a 00                	push   $0x0
  pushl $234
801075ca:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
801075cf:	e9 e5 ef ff ff       	jmp    801065b9 <alltraps>

801075d4 <vector235>:
.globl vector235
vector235:
  pushl $0
801075d4:	6a 00                	push   $0x0
  pushl $235
801075d6:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
801075db:	e9 d9 ef ff ff       	jmp    801065b9 <alltraps>

801075e0 <vector236>:
.globl vector236
vector236:
  pushl $0
801075e0:	6a 00                	push   $0x0
  pushl $236
801075e2:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
801075e7:	e9 cd ef ff ff       	jmp    801065b9 <alltraps>

801075ec <vector237>:
.globl vector237
vector237:
  pushl $0
801075ec:	6a 00                	push   $0x0
  pushl $237
801075ee:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
801075f3:	e9 c1 ef ff ff       	jmp    801065b9 <alltraps>

801075f8 <vector238>:
.globl vector238
vector238:
  pushl $0
801075f8:	6a 00                	push   $0x0
  pushl $238
801075fa:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
801075ff:	e9 b5 ef ff ff       	jmp    801065b9 <alltraps>

80107604 <vector239>:
.globl vector239
vector239:
  pushl $0
80107604:	6a 00                	push   $0x0
  pushl $239
80107606:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
8010760b:	e9 a9 ef ff ff       	jmp    801065b9 <alltraps>

80107610 <vector240>:
.globl vector240
vector240:
  pushl $0
80107610:	6a 00                	push   $0x0
  pushl $240
80107612:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
80107617:	e9 9d ef ff ff       	jmp    801065b9 <alltraps>

8010761c <vector241>:
.globl vector241
vector241:
  pushl $0
8010761c:	6a 00                	push   $0x0
  pushl $241
8010761e:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
80107623:	e9 91 ef ff ff       	jmp    801065b9 <alltraps>

80107628 <vector242>:
.globl vector242
vector242:
  pushl $0
80107628:	6a 00                	push   $0x0
  pushl $242
8010762a:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
8010762f:	e9 85 ef ff ff       	jmp    801065b9 <alltraps>

80107634 <vector243>:
.globl vector243
vector243:
  pushl $0
80107634:	6a 00                	push   $0x0
  pushl $243
80107636:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
8010763b:	e9 79 ef ff ff       	jmp    801065b9 <alltraps>

80107640 <vector244>:
.globl vector244
vector244:
  pushl $0
80107640:	6a 00                	push   $0x0
  pushl $244
80107642:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
80107647:	e9 6d ef ff ff       	jmp    801065b9 <alltraps>

8010764c <vector245>:
.globl vector245
vector245:
  pushl $0
8010764c:	6a 00                	push   $0x0
  pushl $245
8010764e:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
80107653:	e9 61 ef ff ff       	jmp    801065b9 <alltraps>

80107658 <vector246>:
.globl vector246
vector246:
  pushl $0
80107658:	6a 00                	push   $0x0
  pushl $246
8010765a:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
8010765f:	e9 55 ef ff ff       	jmp    801065b9 <alltraps>

80107664 <vector247>:
.globl vector247
vector247:
  pushl $0
80107664:	6a 00                	push   $0x0
  pushl $247
80107666:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
8010766b:	e9 49 ef ff ff       	jmp    801065b9 <alltraps>

80107670 <vector248>:
.globl vector248
vector248:
  pushl $0
80107670:	6a 00                	push   $0x0
  pushl $248
80107672:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
80107677:	e9 3d ef ff ff       	jmp    801065b9 <alltraps>

8010767c <vector249>:
.globl vector249
vector249:
  pushl $0
8010767c:	6a 00                	push   $0x0
  pushl $249
8010767e:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
80107683:	e9 31 ef ff ff       	jmp    801065b9 <alltraps>

80107688 <vector250>:
.globl vector250
vector250:
  pushl $0
80107688:	6a 00                	push   $0x0
  pushl $250
8010768a:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
8010768f:	e9 25 ef ff ff       	jmp    801065b9 <alltraps>

80107694 <vector251>:
.globl vector251
vector251:
  pushl $0
80107694:	6a 00                	push   $0x0
  pushl $251
80107696:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
8010769b:	e9 19 ef ff ff       	jmp    801065b9 <alltraps>

801076a0 <vector252>:
.globl vector252
vector252:
  pushl $0
801076a0:	6a 00                	push   $0x0
  pushl $252
801076a2:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
801076a7:	e9 0d ef ff ff       	jmp    801065b9 <alltraps>

801076ac <vector253>:
.globl vector253
vector253:
  pushl $0
801076ac:	6a 00                	push   $0x0
  pushl $253
801076ae:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
801076b3:	e9 01 ef ff ff       	jmp    801065b9 <alltraps>

801076b8 <vector254>:
.globl vector254
vector254:
  pushl $0
801076b8:	6a 00                	push   $0x0
  pushl $254
801076ba:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
801076bf:	e9 f5 ee ff ff       	jmp    801065b9 <alltraps>

801076c4 <vector255>:
.globl vector255
vector255:
  pushl $0
801076c4:	6a 00                	push   $0x0
  pushl $255
801076c6:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
801076cb:	e9 e9 ee ff ff       	jmp    801065b9 <alltraps>

801076d0 <lgdt>:

struct segdesc;

static inline void
lgdt(struct segdesc *p, int size)
{
801076d0:	55                   	push   %ebp
801076d1:	89 e5                	mov    %esp,%ebp
801076d3:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
801076d6:	8b 45 0c             	mov    0xc(%ebp),%eax
801076d9:	83 e8 01             	sub    $0x1,%eax
801076dc:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
801076e0:	8b 45 08             	mov    0x8(%ebp),%eax
801076e3:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
801076e7:	8b 45 08             	mov    0x8(%ebp),%eax
801076ea:	c1 e8 10             	shr    $0x10,%eax
801076ed:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lgdt (%0)" : : "r" (pd));
801076f1:	8d 45 fa             	lea    -0x6(%ebp),%eax
801076f4:	0f 01 10             	lgdtl  (%eax)
}
801076f7:	90                   	nop
801076f8:	c9                   	leave  
801076f9:	c3                   	ret    

801076fa <ltr>:
  asm volatile("lidt (%0)" : : "r" (pd));
}

static inline void
ltr(ushort sel)
{
801076fa:	55                   	push   %ebp
801076fb:	89 e5                	mov    %esp,%ebp
801076fd:	83 ec 04             	sub    $0x4,%esp
80107700:	8b 45 08             	mov    0x8(%ebp),%eax
80107703:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
80107707:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
8010770b:	0f 00 d8             	ltr    %ax
}
8010770e:	90                   	nop
8010770f:	c9                   	leave  
80107710:	c3                   	ret    

80107711 <lcr3>:
  return val;
}

static inline void
lcr3(uint val)
{
80107711:	55                   	push   %ebp
80107712:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
80107714:	8b 45 08             	mov    0x8(%ebp),%eax
80107717:	0f 22 d8             	mov    %eax,%cr3
}
8010771a:	90                   	nop
8010771b:	5d                   	pop    %ebp
8010771c:	c3                   	ret    

8010771d <seginit>:

// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
8010771d:	55                   	push   %ebp
8010771e:	89 e5                	mov    %esp,%ebp
80107720:	83 ec 18             	sub    $0x18,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpuid()];
80107723:	e8 c3 ca ff ff       	call   801041eb <cpuid>
80107728:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
8010772e:	05 00 38 11 80       	add    $0x80113800,%eax
80107733:	89 45 f4             	mov    %eax,-0xc(%ebp)
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
80107736:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107739:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
8010773f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107742:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
80107748:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010774b:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
8010774f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107752:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107756:	83 e2 f0             	and    $0xfffffff0,%edx
80107759:	83 ca 0a             	or     $0xa,%edx
8010775c:	88 50 7d             	mov    %dl,0x7d(%eax)
8010775f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107762:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107766:	83 ca 10             	or     $0x10,%edx
80107769:	88 50 7d             	mov    %dl,0x7d(%eax)
8010776c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010776f:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107773:	83 e2 9f             	and    $0xffffff9f,%edx
80107776:	88 50 7d             	mov    %dl,0x7d(%eax)
80107779:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010777c:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107780:	83 ca 80             	or     $0xffffff80,%edx
80107783:	88 50 7d             	mov    %dl,0x7d(%eax)
80107786:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107789:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
8010778d:	83 ca 0f             	or     $0xf,%edx
80107790:	88 50 7e             	mov    %dl,0x7e(%eax)
80107793:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107796:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
8010779a:	83 e2 ef             	and    $0xffffffef,%edx
8010779d:	88 50 7e             	mov    %dl,0x7e(%eax)
801077a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077a3:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801077a7:	83 e2 df             	and    $0xffffffdf,%edx
801077aa:	88 50 7e             	mov    %dl,0x7e(%eax)
801077ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077b0:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801077b4:	83 ca 40             	or     $0x40,%edx
801077b7:	88 50 7e             	mov    %dl,0x7e(%eax)
801077ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077bd:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801077c1:	83 ca 80             	or     $0xffffff80,%edx
801077c4:	88 50 7e             	mov    %dl,0x7e(%eax)
801077c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077ca:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
801077ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077d1:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
801077d8:	ff ff 
801077da:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077dd:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
801077e4:	00 00 
801077e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077e9:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
801077f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077f3:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801077fa:	83 e2 f0             	and    $0xfffffff0,%edx
801077fd:	83 ca 02             	or     $0x2,%edx
80107800:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107806:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107809:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107810:	83 ca 10             	or     $0x10,%edx
80107813:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107819:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010781c:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107823:	83 e2 9f             	and    $0xffffff9f,%edx
80107826:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
8010782c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010782f:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107836:	83 ca 80             	or     $0xffffff80,%edx
80107839:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
8010783f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107842:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107849:	83 ca 0f             	or     $0xf,%edx
8010784c:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107852:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107855:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
8010785c:	83 e2 ef             	and    $0xffffffef,%edx
8010785f:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107865:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107868:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
8010786f:	83 e2 df             	and    $0xffffffdf,%edx
80107872:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107878:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010787b:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107882:	83 ca 40             	or     $0x40,%edx
80107885:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
8010788b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010788e:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107895:	83 ca 80             	or     $0xffffff80,%edx
80107898:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
8010789e:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078a1:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
801078a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078ab:	66 c7 80 88 00 00 00 	movw   $0xffff,0x88(%eax)
801078b2:	ff ff 
801078b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078b7:	66 c7 80 8a 00 00 00 	movw   $0x0,0x8a(%eax)
801078be:	00 00 
801078c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078c3:	c6 80 8c 00 00 00 00 	movb   $0x0,0x8c(%eax)
801078ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078cd:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
801078d4:	83 e2 f0             	and    $0xfffffff0,%edx
801078d7:	83 ca 0a             	or     $0xa,%edx
801078da:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
801078e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078e3:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
801078ea:	83 ca 10             	or     $0x10,%edx
801078ed:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
801078f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078f6:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
801078fd:	83 ca 60             	or     $0x60,%edx
80107900:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107906:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107909:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107910:	83 ca 80             	or     $0xffffff80,%edx
80107913:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107919:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010791c:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107923:	83 ca 0f             	or     $0xf,%edx
80107926:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
8010792c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010792f:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107936:	83 e2 ef             	and    $0xffffffef,%edx
80107939:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
8010793f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107942:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107949:	83 e2 df             	and    $0xffffffdf,%edx
8010794c:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107952:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107955:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
8010795c:	83 ca 40             	or     $0x40,%edx
8010795f:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107965:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107968:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
8010796f:	83 ca 80             	or     $0xffffff80,%edx
80107972:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107978:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010797b:	c6 80 8f 00 00 00 00 	movb   $0x0,0x8f(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
80107982:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107985:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
8010798c:	ff ff 
8010798e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107991:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
80107998:	00 00 
8010799a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010799d:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
801079a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079a7:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
801079ae:	83 e2 f0             	and    $0xfffffff0,%edx
801079b1:	83 ca 02             	or     $0x2,%edx
801079b4:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801079ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079bd:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
801079c4:	83 ca 10             	or     $0x10,%edx
801079c7:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801079cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079d0:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
801079d7:	83 ca 60             	or     $0x60,%edx
801079da:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801079e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079e3:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
801079ea:	83 ca 80             	or     $0xffffff80,%edx
801079ed:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801079f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079f6:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801079fd:	83 ca 0f             	or     $0xf,%edx
80107a00:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107a06:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a09:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107a10:	83 e2 ef             	and    $0xffffffef,%edx
80107a13:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107a19:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a1c:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107a23:	83 e2 df             	and    $0xffffffdf,%edx
80107a26:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107a2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a2f:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107a36:	83 ca 40             	or     $0x40,%edx
80107a39:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107a3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a42:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107a49:	83 ca 80             	or     $0xffffff80,%edx
80107a4c:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107a52:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a55:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  lgdt(c->gdt, sizeof(c->gdt));
80107a5c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a5f:	83 c0 70             	add    $0x70,%eax
80107a62:	83 ec 08             	sub    $0x8,%esp
80107a65:	6a 30                	push   $0x30
80107a67:	50                   	push   %eax
80107a68:	e8 63 fc ff ff       	call   801076d0 <lgdt>
80107a6d:	83 c4 10             	add    $0x10,%esp
}
80107a70:	90                   	nop
80107a71:	c9                   	leave  
80107a72:	c3                   	ret    

80107a73 <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
80107a73:	55                   	push   %ebp
80107a74:	89 e5                	mov    %esp,%ebp
80107a76:	83 ec 18             	sub    $0x18,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
80107a79:	8b 45 0c             	mov    0xc(%ebp),%eax
80107a7c:	c1 e8 16             	shr    $0x16,%eax
80107a7f:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107a86:	8b 45 08             	mov    0x8(%ebp),%eax
80107a89:	01 d0                	add    %edx,%eax
80107a8b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
80107a8e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107a91:	8b 00                	mov    (%eax),%eax
80107a93:	83 e0 01             	and    $0x1,%eax
80107a96:	85 c0                	test   %eax,%eax
80107a98:	74 14                	je     80107aae <walkpgdir+0x3b>
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
80107a9a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107a9d:	8b 00                	mov    (%eax),%eax
80107a9f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107aa4:	05 00 00 00 80       	add    $0x80000000,%eax
80107aa9:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107aac:	eb 42                	jmp    80107af0 <walkpgdir+0x7d>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
80107aae:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80107ab2:	74 0e                	je     80107ac2 <walkpgdir+0x4f>
80107ab4:	e8 d3 b1 ff ff       	call   80102c8c <kalloc>
80107ab9:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107abc:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107ac0:	75 07                	jne    80107ac9 <walkpgdir+0x56>
      return 0;
80107ac2:	b8 00 00 00 00       	mov    $0x0,%eax
80107ac7:	eb 3e                	jmp    80107b07 <walkpgdir+0x94>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
80107ac9:	83 ec 04             	sub    $0x4,%esp
80107acc:	68 00 10 00 00       	push   $0x1000
80107ad1:	6a 00                	push   $0x0
80107ad3:	ff 75 f4             	pushl  -0xc(%ebp)
80107ad6:	e8 09 d7 ff ff       	call   801051e4 <memset>
80107adb:	83 c4 10             	add    $0x10,%esp
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table
    // entries, if necessary.
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
80107ade:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ae1:	05 00 00 00 80       	add    $0x80000000,%eax
80107ae6:	83 c8 07             	or     $0x7,%eax
80107ae9:	89 c2                	mov    %eax,%edx
80107aeb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107aee:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
80107af0:	8b 45 0c             	mov    0xc(%ebp),%eax
80107af3:	c1 e8 0c             	shr    $0xc,%eax
80107af6:	25 ff 03 00 00       	and    $0x3ff,%eax
80107afb:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107b02:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b05:	01 d0                	add    %edx,%eax
}
80107b07:	c9                   	leave  
80107b08:	c3                   	ret    

80107b09 <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
80107b09:	55                   	push   %ebp
80107b0a:	89 e5                	mov    %esp,%ebp
80107b0c:	83 ec 18             	sub    $0x18,%esp
  char *a, *last;
  pte_t *pte;

  a = (char*)PGROUNDDOWN((uint)va);
80107b0f:	8b 45 0c             	mov    0xc(%ebp),%eax
80107b12:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107b17:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80107b1a:	8b 55 0c             	mov    0xc(%ebp),%edx
80107b1d:	8b 45 10             	mov    0x10(%ebp),%eax
80107b20:	01 d0                	add    %edx,%eax
80107b22:	83 e8 01             	sub    $0x1,%eax
80107b25:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107b2a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80107b2d:	83 ec 04             	sub    $0x4,%esp
80107b30:	6a 01                	push   $0x1
80107b32:	ff 75 f4             	pushl  -0xc(%ebp)
80107b35:	ff 75 08             	pushl  0x8(%ebp)
80107b38:	e8 36 ff ff ff       	call   80107a73 <walkpgdir>
80107b3d:	83 c4 10             	add    $0x10,%esp
80107b40:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107b43:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107b47:	75 07                	jne    80107b50 <mappages+0x47>
      return -1;
80107b49:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107b4e:	eb 47                	jmp    80107b97 <mappages+0x8e>
    if(*pte & PTE_P)
80107b50:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107b53:	8b 00                	mov    (%eax),%eax
80107b55:	83 e0 01             	and    $0x1,%eax
80107b58:	85 c0                	test   %eax,%eax
80107b5a:	74 0d                	je     80107b69 <mappages+0x60>
      panic("remap");
80107b5c:	83 ec 0c             	sub    $0xc,%esp
80107b5f:	68 10 8c 10 80       	push   $0x80108c10
80107b64:	e8 37 8a ff ff       	call   801005a0 <panic>
    *pte = pa | perm | PTE_P;
80107b69:	8b 45 18             	mov    0x18(%ebp),%eax
80107b6c:	0b 45 14             	or     0x14(%ebp),%eax
80107b6f:	83 c8 01             	or     $0x1,%eax
80107b72:	89 c2                	mov    %eax,%edx
80107b74:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107b77:	89 10                	mov    %edx,(%eax)
    if(a == last)
80107b79:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b7c:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80107b7f:	74 10                	je     80107b91 <mappages+0x88>
      break;
    a += PGSIZE;
80107b81:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
80107b88:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
  }
80107b8f:	eb 9c                	jmp    80107b2d <mappages+0x24>
      return -1;
    if(*pte & PTE_P)
      panic("remap");
    *pte = pa | perm | PTE_P;
    if(a == last)
      break;
80107b91:	90                   	nop
    a += PGSIZE;
    pa += PGSIZE;
  }
  return 0;
80107b92:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107b97:	c9                   	leave  
80107b98:	c3                   	ret    

80107b99 <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
80107b99:	55                   	push   %ebp
80107b9a:	89 e5                	mov    %esp,%ebp
80107b9c:	53                   	push   %ebx
80107b9d:	83 ec 14             	sub    $0x14,%esp
  pde_t *pgdir;
  struct kmap *k;

  if((pgdir = (pde_t*)kalloc()) == 0)
80107ba0:	e8 e7 b0 ff ff       	call   80102c8c <kalloc>
80107ba5:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107ba8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107bac:	75 07                	jne    80107bb5 <setupkvm+0x1c>
    return 0;
80107bae:	b8 00 00 00 00       	mov    $0x0,%eax
80107bb3:	eb 78                	jmp    80107c2d <setupkvm+0x94>
  memset(pgdir, 0, PGSIZE);
80107bb5:	83 ec 04             	sub    $0x4,%esp
80107bb8:	68 00 10 00 00       	push   $0x1000
80107bbd:	6a 00                	push   $0x0
80107bbf:	ff 75 f0             	pushl  -0x10(%ebp)
80107bc2:	e8 1d d6 ff ff       	call   801051e4 <memset>
80107bc7:	83 c4 10             	add    $0x10,%esp
  if (P2V(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80107bca:	c7 45 f4 80 b4 10 80 	movl   $0x8010b480,-0xc(%ebp)
80107bd1:	eb 4e                	jmp    80107c21 <setupkvm+0x88>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
80107bd3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bd6:	8b 48 0c             	mov    0xc(%eax),%ecx
                (uint)k->phys_start, k->perm) < 0) {
80107bd9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bdc:	8b 50 04             	mov    0x4(%eax),%edx
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (P2V(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
80107bdf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107be2:	8b 58 08             	mov    0x8(%eax),%ebx
80107be5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107be8:	8b 40 04             	mov    0x4(%eax),%eax
80107beb:	29 c3                	sub    %eax,%ebx
80107bed:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bf0:	8b 00                	mov    (%eax),%eax
80107bf2:	83 ec 0c             	sub    $0xc,%esp
80107bf5:	51                   	push   %ecx
80107bf6:	52                   	push   %edx
80107bf7:	53                   	push   %ebx
80107bf8:	50                   	push   %eax
80107bf9:	ff 75 f0             	pushl  -0x10(%ebp)
80107bfc:	e8 08 ff ff ff       	call   80107b09 <mappages>
80107c01:	83 c4 20             	add    $0x20,%esp
80107c04:	85 c0                	test   %eax,%eax
80107c06:	79 15                	jns    80107c1d <setupkvm+0x84>
                (uint)k->phys_start, k->perm) < 0) {
      freevm(pgdir);
80107c08:	83 ec 0c             	sub    $0xc,%esp
80107c0b:	ff 75 f0             	pushl  -0x10(%ebp)
80107c0e:	e8 0d 05 00 00       	call   80108120 <freevm>
80107c13:	83 c4 10             	add    $0x10,%esp
      return 0;
80107c16:	b8 00 00 00 00       	mov    $0x0,%eax
80107c1b:	eb 10                	jmp    80107c2d <setupkvm+0x94>
  if((pgdir = (pde_t*)kalloc()) == 0)
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (P2V(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80107c1d:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80107c21:	81 7d f4 c0 b4 10 80 	cmpl   $0x8010b4c0,-0xc(%ebp)
80107c28:	72 a9                	jb     80107bd3 <setupkvm+0x3a>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
                (uint)k->phys_start, k->perm) < 0) {
      freevm(pgdir);
      return 0;
    }
  return pgdir;
80107c2a:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80107c2d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80107c30:	c9                   	leave  
80107c31:	c3                   	ret    

80107c32 <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
80107c32:	55                   	push   %ebp
80107c33:	89 e5                	mov    %esp,%ebp
80107c35:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
80107c38:	e8 5c ff ff ff       	call   80107b99 <setupkvm>
80107c3d:	a3 24 67 11 80       	mov    %eax,0x80116724
  switchkvm();
80107c42:	e8 03 00 00 00       	call   80107c4a <switchkvm>
}
80107c47:	90                   	nop
80107c48:	c9                   	leave  
80107c49:	c3                   	ret    

80107c4a <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
80107c4a:	55                   	push   %ebp
80107c4b:	89 e5                	mov    %esp,%ebp
  lcr3(V2P(kpgdir));   // switch to the kernel page table
80107c4d:	a1 24 67 11 80       	mov    0x80116724,%eax
80107c52:	05 00 00 00 80       	add    $0x80000000,%eax
80107c57:	50                   	push   %eax
80107c58:	e8 b4 fa ff ff       	call   80107711 <lcr3>
80107c5d:	83 c4 04             	add    $0x4,%esp
}
80107c60:	90                   	nop
80107c61:	c9                   	leave  
80107c62:	c3                   	ret    

80107c63 <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
80107c63:	55                   	push   %ebp
80107c64:	89 e5                	mov    %esp,%ebp
80107c66:	56                   	push   %esi
80107c67:	53                   	push   %ebx
80107c68:	83 ec 10             	sub    $0x10,%esp
  if(p == 0)
80107c6b:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80107c6f:	75 0d                	jne    80107c7e <switchuvm+0x1b>
    panic("switchuvm: no process");
80107c71:	83 ec 0c             	sub    $0xc,%esp
80107c74:	68 16 8c 10 80       	push   $0x80108c16
80107c79:	e8 22 89 ff ff       	call   801005a0 <panic>
  if(p->kstack == 0)
80107c7e:	8b 45 08             	mov    0x8(%ebp),%eax
80107c81:	8b 40 10             	mov    0x10(%eax),%eax
80107c84:	85 c0                	test   %eax,%eax
80107c86:	75 0d                	jne    80107c95 <switchuvm+0x32>
    panic("switchuvm: no kstack");
80107c88:	83 ec 0c             	sub    $0xc,%esp
80107c8b:	68 2c 8c 10 80       	push   $0x80108c2c
80107c90:	e8 0b 89 ff ff       	call   801005a0 <panic>
  if(p->pgdir == 0)
80107c95:	8b 45 08             	mov    0x8(%ebp),%eax
80107c98:	8b 40 0c             	mov    0xc(%eax),%eax
80107c9b:	85 c0                	test   %eax,%eax
80107c9d:	75 0d                	jne    80107cac <switchuvm+0x49>
    panic("switchuvm: no pgdir");
80107c9f:	83 ec 0c             	sub    $0xc,%esp
80107ca2:	68 41 8c 10 80       	push   $0x80108c41
80107ca7:	e8 f4 88 ff ff       	call   801005a0 <panic>

  pushcli();
80107cac:	e8 27 d4 ff ff       	call   801050d8 <pushcli>
  mycpu()->gdt[SEG_TSS] = SEG16(STS_T32A, &mycpu()->ts,
80107cb1:	e8 56 c5 ff ff       	call   8010420c <mycpu>
80107cb6:	89 c3                	mov    %eax,%ebx
80107cb8:	e8 4f c5 ff ff       	call   8010420c <mycpu>
80107cbd:	83 c0 08             	add    $0x8,%eax
80107cc0:	89 c6                	mov    %eax,%esi
80107cc2:	e8 45 c5 ff ff       	call   8010420c <mycpu>
80107cc7:	83 c0 08             	add    $0x8,%eax
80107cca:	c1 e8 10             	shr    $0x10,%eax
80107ccd:	88 45 f7             	mov    %al,-0x9(%ebp)
80107cd0:	e8 37 c5 ff ff       	call   8010420c <mycpu>
80107cd5:	83 c0 08             	add    $0x8,%eax
80107cd8:	c1 e8 18             	shr    $0x18,%eax
80107cdb:	89 c2                	mov    %eax,%edx
80107cdd:	66 c7 83 98 00 00 00 	movw   $0x67,0x98(%ebx)
80107ce4:	67 00 
80107ce6:	66 89 b3 9a 00 00 00 	mov    %si,0x9a(%ebx)
80107ced:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
80107cf1:	88 83 9c 00 00 00    	mov    %al,0x9c(%ebx)
80107cf7:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80107cfe:	83 e0 f0             	and    $0xfffffff0,%eax
80107d01:	83 c8 09             	or     $0x9,%eax
80107d04:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80107d0a:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80107d11:	83 c8 10             	or     $0x10,%eax
80107d14:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80107d1a:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80107d21:	83 e0 9f             	and    $0xffffff9f,%eax
80107d24:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80107d2a:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80107d31:	83 c8 80             	or     $0xffffff80,%eax
80107d34:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80107d3a:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107d41:	83 e0 f0             	and    $0xfffffff0,%eax
80107d44:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107d4a:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107d51:	83 e0 ef             	and    $0xffffffef,%eax
80107d54:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107d5a:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107d61:	83 e0 df             	and    $0xffffffdf,%eax
80107d64:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107d6a:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107d71:	83 c8 40             	or     $0x40,%eax
80107d74:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107d7a:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107d81:	83 e0 7f             	and    $0x7f,%eax
80107d84:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107d8a:	88 93 9f 00 00 00    	mov    %dl,0x9f(%ebx)
                                sizeof(mycpu()->ts)-1, 0);
  mycpu()->gdt[SEG_TSS].s = 0;
80107d90:	e8 77 c4 ff ff       	call   8010420c <mycpu>
80107d95:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107d9c:	83 e2 ef             	and    $0xffffffef,%edx
80107d9f:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
  mycpu()->ts.ss0 = SEG_KDATA << 3;
80107da5:	e8 62 c4 ff ff       	call   8010420c <mycpu>
80107daa:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  mycpu()->ts.esp0 = (uint)p->kstack + KSTACKSIZE;
80107db0:	e8 57 c4 ff ff       	call   8010420c <mycpu>
80107db5:	89 c2                	mov    %eax,%edx
80107db7:	8b 45 08             	mov    0x8(%ebp),%eax
80107dba:	8b 40 10             	mov    0x10(%eax),%eax
80107dbd:	05 00 10 00 00       	add    $0x1000,%eax
80107dc2:	89 42 0c             	mov    %eax,0xc(%edx)
  // setting IOPL=0 in eflags *and* iomb beyond the tss segment limit
  // forbids I/O instructions (e.g., inb and outb) from user space
  mycpu()->ts.iomb = (ushort) 0xFFFF;
80107dc5:	e8 42 c4 ff ff       	call   8010420c <mycpu>
80107dca:	66 c7 40 6e ff ff    	movw   $0xffff,0x6e(%eax)
  ltr(SEG_TSS << 3);
80107dd0:	83 ec 0c             	sub    $0xc,%esp
80107dd3:	6a 28                	push   $0x28
80107dd5:	e8 20 f9 ff ff       	call   801076fa <ltr>
80107dda:	83 c4 10             	add    $0x10,%esp
  lcr3(V2P(p->pgdir));  // switch to process's address space
80107ddd:	8b 45 08             	mov    0x8(%ebp),%eax
80107de0:	8b 40 0c             	mov    0xc(%eax),%eax
80107de3:	05 00 00 00 80       	add    $0x80000000,%eax
80107de8:	83 ec 0c             	sub    $0xc,%esp
80107deb:	50                   	push   %eax
80107dec:	e8 20 f9 ff ff       	call   80107711 <lcr3>
80107df1:	83 c4 10             	add    $0x10,%esp
  popcli();
80107df4:	e8 2d d3 ff ff       	call   80105126 <popcli>
}
80107df9:	90                   	nop
80107dfa:	8d 65 f8             	lea    -0x8(%ebp),%esp
80107dfd:	5b                   	pop    %ebx
80107dfe:	5e                   	pop    %esi
80107dff:	5d                   	pop    %ebp
80107e00:	c3                   	ret    

80107e01 <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
80107e01:	55                   	push   %ebp
80107e02:	89 e5                	mov    %esp,%ebp
80107e04:	83 ec 18             	sub    $0x18,%esp
  char *mem;

  if(sz >= PGSIZE)
80107e07:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
80107e0e:	76 0d                	jbe    80107e1d <inituvm+0x1c>
    panic("inituvm: more than a page");
80107e10:	83 ec 0c             	sub    $0xc,%esp
80107e13:	68 55 8c 10 80       	push   $0x80108c55
80107e18:	e8 83 87 ff ff       	call   801005a0 <panic>
  mem = kalloc();
80107e1d:	e8 6a ae ff ff       	call   80102c8c <kalloc>
80107e22:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
80107e25:	83 ec 04             	sub    $0x4,%esp
80107e28:	68 00 10 00 00       	push   $0x1000
80107e2d:	6a 00                	push   $0x0
80107e2f:	ff 75 f4             	pushl  -0xc(%ebp)
80107e32:	e8 ad d3 ff ff       	call   801051e4 <memset>
80107e37:	83 c4 10             	add    $0x10,%esp
  mappages(pgdir, 0, PGSIZE, V2P(mem), PTE_W|PTE_U);
80107e3a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e3d:	05 00 00 00 80       	add    $0x80000000,%eax
80107e42:	83 ec 0c             	sub    $0xc,%esp
80107e45:	6a 06                	push   $0x6
80107e47:	50                   	push   %eax
80107e48:	68 00 10 00 00       	push   $0x1000
80107e4d:	6a 00                	push   $0x0
80107e4f:	ff 75 08             	pushl  0x8(%ebp)
80107e52:	e8 b2 fc ff ff       	call   80107b09 <mappages>
80107e57:	83 c4 20             	add    $0x20,%esp
  memmove(mem, init, sz);
80107e5a:	83 ec 04             	sub    $0x4,%esp
80107e5d:	ff 75 10             	pushl  0x10(%ebp)
80107e60:	ff 75 0c             	pushl  0xc(%ebp)
80107e63:	ff 75 f4             	pushl  -0xc(%ebp)
80107e66:	e8 38 d4 ff ff       	call   801052a3 <memmove>
80107e6b:	83 c4 10             	add    $0x10,%esp
}
80107e6e:	90                   	nop
80107e6f:	c9                   	leave  
80107e70:	c3                   	ret    

80107e71 <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
80107e71:	55                   	push   %ebp
80107e72:	89 e5                	mov    %esp,%ebp
80107e74:	83 ec 18             	sub    $0x18,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
80107e77:	8b 45 0c             	mov    0xc(%ebp),%eax
80107e7a:	25 ff 0f 00 00       	and    $0xfff,%eax
80107e7f:	85 c0                	test   %eax,%eax
80107e81:	74 0d                	je     80107e90 <loaduvm+0x1f>
    panic("loaduvm: addr must be page aligned");
80107e83:	83 ec 0c             	sub    $0xc,%esp
80107e86:	68 70 8c 10 80       	push   $0x80108c70
80107e8b:	e8 10 87 ff ff       	call   801005a0 <panic>
  for(i = 0; i < sz; i += PGSIZE){
80107e90:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107e97:	e9 8f 00 00 00       	jmp    80107f2b <loaduvm+0xba>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
80107e9c:	8b 55 0c             	mov    0xc(%ebp),%edx
80107e9f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ea2:	01 d0                	add    %edx,%eax
80107ea4:	83 ec 04             	sub    $0x4,%esp
80107ea7:	6a 00                	push   $0x0
80107ea9:	50                   	push   %eax
80107eaa:	ff 75 08             	pushl  0x8(%ebp)
80107ead:	e8 c1 fb ff ff       	call   80107a73 <walkpgdir>
80107eb2:	83 c4 10             	add    $0x10,%esp
80107eb5:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107eb8:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107ebc:	75 0d                	jne    80107ecb <loaduvm+0x5a>
      panic("loaduvm: address should exist");
80107ebe:	83 ec 0c             	sub    $0xc,%esp
80107ec1:	68 93 8c 10 80       	push   $0x80108c93
80107ec6:	e8 d5 86 ff ff       	call   801005a0 <panic>
    pa = PTE_ADDR(*pte);
80107ecb:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107ece:	8b 00                	mov    (%eax),%eax
80107ed0:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107ed5:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
80107ed8:	8b 45 18             	mov    0x18(%ebp),%eax
80107edb:	2b 45 f4             	sub    -0xc(%ebp),%eax
80107ede:	3d ff 0f 00 00       	cmp    $0xfff,%eax
80107ee3:	77 0b                	ja     80107ef0 <loaduvm+0x7f>
      n = sz - i;
80107ee5:	8b 45 18             	mov    0x18(%ebp),%eax
80107ee8:	2b 45 f4             	sub    -0xc(%ebp),%eax
80107eeb:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107eee:	eb 07                	jmp    80107ef7 <loaduvm+0x86>
    else
      n = PGSIZE;
80107ef0:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, P2V(pa), offset+i, n) != n)
80107ef7:	8b 55 14             	mov    0x14(%ebp),%edx
80107efa:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107efd:	01 d0                	add    %edx,%eax
80107eff:	8b 55 e8             	mov    -0x18(%ebp),%edx
80107f02:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80107f08:	ff 75 f0             	pushl  -0x10(%ebp)
80107f0b:	50                   	push   %eax
80107f0c:	52                   	push   %edx
80107f0d:	ff 75 10             	pushl  0x10(%ebp)
80107f10:	e8 e3 9f ff ff       	call   80101ef8 <readi>
80107f15:	83 c4 10             	add    $0x10,%esp
80107f18:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80107f1b:	74 07                	je     80107f24 <loaduvm+0xb3>
      return -1;
80107f1d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107f22:	eb 18                	jmp    80107f3c <loaduvm+0xcb>
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
    panic("loaduvm: addr must be page aligned");
  for(i = 0; i < sz; i += PGSIZE){
80107f24:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107f2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f2e:	3b 45 18             	cmp    0x18(%ebp),%eax
80107f31:	0f 82 65 ff ff ff    	jb     80107e9c <loaduvm+0x2b>
    else
      n = PGSIZE;
    if(readi(ip, P2V(pa), offset+i, n) != n)
      return -1;
  }
  return 0;
80107f37:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107f3c:	c9                   	leave  
80107f3d:	c3                   	ret    

80107f3e <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80107f3e:	55                   	push   %ebp
80107f3f:	89 e5                	mov    %esp,%ebp
80107f41:	83 ec 18             	sub    $0x18,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
80107f44:	8b 45 10             	mov    0x10(%ebp),%eax
80107f47:	85 c0                	test   %eax,%eax
80107f49:	79 0a                	jns    80107f55 <allocuvm+0x17>
    return 0;
80107f4b:	b8 00 00 00 00       	mov    $0x0,%eax
80107f50:	e9 05 01 00 00       	jmp    8010805a <allocuvm+0x11c>
  if(newsz < oldsz)
80107f55:	8b 45 10             	mov    0x10(%ebp),%eax
80107f58:	3b 45 0c             	cmp    0xc(%ebp),%eax
80107f5b:	73 08                	jae    80107f65 <allocuvm+0x27>
    return oldsz;
80107f5d:	8b 45 0c             	mov    0xc(%ebp),%eax
80107f60:	e9 f5 00 00 00       	jmp    8010805a <allocuvm+0x11c>

  a = PGROUNDUP(oldsz);
80107f65:	8b 45 0c             	mov    0xc(%ebp),%eax
80107f68:	05 ff 0f 00 00       	add    $0xfff,%eax
80107f6d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107f72:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
80107f75:	e9 d1 00 00 00       	jmp    8010804b <allocuvm+0x10d>
    mem = kalloc();
80107f7a:	e8 0d ad ff ff       	call   80102c8c <kalloc>
80107f7f:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
80107f82:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107f86:	75 47                	jne    80107fcf <allocuvm+0x91>
      cprintf("allocuvm out of memory\n");
80107f88:	83 ec 0c             	sub    $0xc,%esp
80107f8b:	68 b1 8c 10 80       	push   $0x80108cb1
80107f90:	e8 6b 84 ff ff       	call   80100400 <cprintf>
80107f95:	83 c4 10             	add    $0x10,%esp
      cprintf("Stack Size: %d\n", myproc()->stackSize);
80107f98:	e8 e7 c2 ff ff       	call   80104284 <myproc>
80107f9d:	8b 40 08             	mov    0x8(%eax),%eax
80107fa0:	83 ec 08             	sub    $0x8,%esp
80107fa3:	50                   	push   %eax
80107fa4:	68 c9 8c 10 80       	push   $0x80108cc9
80107fa9:	e8 52 84 ff ff       	call   80100400 <cprintf>
80107fae:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
80107fb1:	83 ec 04             	sub    $0x4,%esp
80107fb4:	ff 75 0c             	pushl  0xc(%ebp)
80107fb7:	ff 75 10             	pushl  0x10(%ebp)
80107fba:	ff 75 08             	pushl  0x8(%ebp)
80107fbd:	e8 9a 00 00 00       	call   8010805c <deallocuvm>
80107fc2:	83 c4 10             	add    $0x10,%esp
      return 0;
80107fc5:	b8 00 00 00 00       	mov    $0x0,%eax
80107fca:	e9 8b 00 00 00       	jmp    8010805a <allocuvm+0x11c>
    }
    memset(mem, 0, PGSIZE);
80107fcf:	83 ec 04             	sub    $0x4,%esp
80107fd2:	68 00 10 00 00       	push   $0x1000
80107fd7:	6a 00                	push   $0x0
80107fd9:	ff 75 f0             	pushl  -0x10(%ebp)
80107fdc:	e8 03 d2 ff ff       	call   801051e4 <memset>
80107fe1:	83 c4 10             	add    $0x10,%esp
    if(mappages(pgdir, (char*)a, PGSIZE, V2P(mem), PTE_W|PTE_U) < 0){
80107fe4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107fe7:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80107fed:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ff0:	83 ec 0c             	sub    $0xc,%esp
80107ff3:	6a 06                	push   $0x6
80107ff5:	52                   	push   %edx
80107ff6:	68 00 10 00 00       	push   $0x1000
80107ffb:	50                   	push   %eax
80107ffc:	ff 75 08             	pushl  0x8(%ebp)
80107fff:	e8 05 fb ff ff       	call   80107b09 <mappages>
80108004:	83 c4 20             	add    $0x20,%esp
80108007:	85 c0                	test   %eax,%eax
80108009:	79 39                	jns    80108044 <allocuvm+0x106>
      cprintf("allocuvm out of memory (2)\n");
8010800b:	83 ec 0c             	sub    $0xc,%esp
8010800e:	68 d9 8c 10 80       	push   $0x80108cd9
80108013:	e8 e8 83 ff ff       	call   80100400 <cprintf>
80108018:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
8010801b:	83 ec 04             	sub    $0x4,%esp
8010801e:	ff 75 0c             	pushl  0xc(%ebp)
80108021:	ff 75 10             	pushl  0x10(%ebp)
80108024:	ff 75 08             	pushl  0x8(%ebp)
80108027:	e8 30 00 00 00       	call   8010805c <deallocuvm>
8010802c:	83 c4 10             	add    $0x10,%esp
      kfree(mem);
8010802f:	83 ec 0c             	sub    $0xc,%esp
80108032:	ff 75 f0             	pushl  -0x10(%ebp)
80108035:	e8 b8 ab ff ff       	call   80102bf2 <kfree>
8010803a:	83 c4 10             	add    $0x10,%esp
      return 0;
8010803d:	b8 00 00 00 00       	mov    $0x0,%eax
80108042:	eb 16                	jmp    8010805a <allocuvm+0x11c>
    return 0;
  if(newsz < oldsz)
    return oldsz;

  a = PGROUNDUP(oldsz);
  for(; a < newsz; a += PGSIZE){
80108044:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010804b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010804e:	3b 45 10             	cmp    0x10(%ebp),%eax
80108051:	0f 82 23 ff ff ff    	jb     80107f7a <allocuvm+0x3c>
      deallocuvm(pgdir, newsz, oldsz);
      kfree(mem);
      return 0;
    }
  }
  return newsz;
80108057:	8b 45 10             	mov    0x10(%ebp),%eax
}
8010805a:	c9                   	leave  
8010805b:	c3                   	ret    

8010805c <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
8010805c:	55                   	push   %ebp
8010805d:	89 e5                	mov    %esp,%ebp
8010805f:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
80108062:	8b 45 10             	mov    0x10(%ebp),%eax
80108065:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108068:	72 08                	jb     80108072 <deallocuvm+0x16>
    return oldsz;
8010806a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010806d:	e9 ac 00 00 00       	jmp    8010811e <deallocuvm+0xc2>

  a = PGROUNDUP(newsz);
80108072:	8b 45 10             	mov    0x10(%ebp),%eax
80108075:	05 ff 0f 00 00       	add    $0xfff,%eax
8010807a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010807f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
80108082:	e9 88 00 00 00       	jmp    8010810f <deallocuvm+0xb3>
    pte = walkpgdir(pgdir, (char*)a, 0);
80108087:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010808a:	83 ec 04             	sub    $0x4,%esp
8010808d:	6a 00                	push   $0x0
8010808f:	50                   	push   %eax
80108090:	ff 75 08             	pushl  0x8(%ebp)
80108093:	e8 db f9 ff ff       	call   80107a73 <walkpgdir>
80108098:	83 c4 10             	add    $0x10,%esp
8010809b:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
8010809e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801080a2:	75 16                	jne    801080ba <deallocuvm+0x5e>
      a = PGADDR(PDX(a) + 1, 0, 0) - PGSIZE;
801080a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080a7:	c1 e8 16             	shr    $0x16,%eax
801080aa:	83 c0 01             	add    $0x1,%eax
801080ad:	c1 e0 16             	shl    $0x16,%eax
801080b0:	2d 00 10 00 00       	sub    $0x1000,%eax
801080b5:	89 45 f4             	mov    %eax,-0xc(%ebp)
801080b8:	eb 4e                	jmp    80108108 <deallocuvm+0xac>
    else if((*pte & PTE_P) != 0){
801080ba:	8b 45 f0             	mov    -0x10(%ebp),%eax
801080bd:	8b 00                	mov    (%eax),%eax
801080bf:	83 e0 01             	and    $0x1,%eax
801080c2:	85 c0                	test   %eax,%eax
801080c4:	74 42                	je     80108108 <deallocuvm+0xac>
      pa = PTE_ADDR(*pte);
801080c6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801080c9:	8b 00                	mov    (%eax),%eax
801080cb:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801080d0:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
801080d3:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801080d7:	75 0d                	jne    801080e6 <deallocuvm+0x8a>
        panic("kfree");
801080d9:	83 ec 0c             	sub    $0xc,%esp
801080dc:	68 f5 8c 10 80       	push   $0x80108cf5
801080e1:	e8 ba 84 ff ff       	call   801005a0 <panic>
      char *v = P2V(pa);
801080e6:	8b 45 ec             	mov    -0x14(%ebp),%eax
801080e9:	05 00 00 00 80       	add    $0x80000000,%eax
801080ee:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
801080f1:	83 ec 0c             	sub    $0xc,%esp
801080f4:	ff 75 e8             	pushl  -0x18(%ebp)
801080f7:	e8 f6 aa ff ff       	call   80102bf2 <kfree>
801080fc:	83 c4 10             	add    $0x10,%esp
      *pte = 0;
801080ff:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108102:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  if(newsz >= oldsz)
    return oldsz;

  a = PGROUNDUP(newsz);
  for(; a  < oldsz; a += PGSIZE){
80108108:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010810f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108112:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108115:	0f 82 6c ff ff ff    	jb     80108087 <deallocuvm+0x2b>
      char *v = P2V(pa);
      kfree(v);
      *pte = 0;
    }
  }
  return newsz;
8010811b:	8b 45 10             	mov    0x10(%ebp),%eax
}
8010811e:	c9                   	leave  
8010811f:	c3                   	ret    

80108120 <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
80108120:	55                   	push   %ebp
80108121:	89 e5                	mov    %esp,%ebp
80108123:	83 ec 18             	sub    $0x18,%esp
  uint i;

  if(pgdir == 0)
80108126:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010812a:	75 0d                	jne    80108139 <freevm+0x19>
    panic("freevm: no pgdir");
8010812c:	83 ec 0c             	sub    $0xc,%esp
8010812f:	68 fb 8c 10 80       	push   $0x80108cfb
80108134:	e8 67 84 ff ff       	call   801005a0 <panic>
  deallocuvm(pgdir, KERNBASE, 0);
80108139:	83 ec 04             	sub    $0x4,%esp
8010813c:	6a 00                	push   $0x0
8010813e:	68 00 00 00 80       	push   $0x80000000
80108143:	ff 75 08             	pushl  0x8(%ebp)
80108146:	e8 11 ff ff ff       	call   8010805c <deallocuvm>
8010814b:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
8010814e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108155:	eb 48                	jmp    8010819f <freevm+0x7f>
    if(pgdir[i] & PTE_P){
80108157:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010815a:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108161:	8b 45 08             	mov    0x8(%ebp),%eax
80108164:	01 d0                	add    %edx,%eax
80108166:	8b 00                	mov    (%eax),%eax
80108168:	83 e0 01             	and    $0x1,%eax
8010816b:	85 c0                	test   %eax,%eax
8010816d:	74 2c                	je     8010819b <freevm+0x7b>
      char * v = P2V(PTE_ADDR(pgdir[i]));
8010816f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108172:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108179:	8b 45 08             	mov    0x8(%ebp),%eax
8010817c:	01 d0                	add    %edx,%eax
8010817e:	8b 00                	mov    (%eax),%eax
80108180:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108185:	05 00 00 00 80       	add    $0x80000000,%eax
8010818a:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
8010818d:	83 ec 0c             	sub    $0xc,%esp
80108190:	ff 75 f0             	pushl  -0x10(%ebp)
80108193:	e8 5a aa ff ff       	call   80102bf2 <kfree>
80108198:	83 c4 10             	add    $0x10,%esp
  uint i;

  if(pgdir == 0)
    panic("freevm: no pgdir");
  deallocuvm(pgdir, KERNBASE, 0);
  for(i = 0; i < NPDENTRIES; i++){
8010819b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010819f:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
801081a6:	76 af                	jbe    80108157 <freevm+0x37>
    if(pgdir[i] & PTE_P){
      char * v = P2V(PTE_ADDR(pgdir[i]));
      kfree(v);
    }
  }
  kfree((char*)pgdir);
801081a8:	83 ec 0c             	sub    $0xc,%esp
801081ab:	ff 75 08             	pushl  0x8(%ebp)
801081ae:	e8 3f aa ff ff       	call   80102bf2 <kfree>
801081b3:	83 c4 10             	add    $0x10,%esp
}
801081b6:	90                   	nop
801081b7:	c9                   	leave  
801081b8:	c3                   	ret    

801081b9 <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
801081b9:	55                   	push   %ebp
801081ba:	89 e5                	mov    %esp,%ebp
801081bc:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
801081bf:	83 ec 04             	sub    $0x4,%esp
801081c2:	6a 00                	push   $0x0
801081c4:	ff 75 0c             	pushl  0xc(%ebp)
801081c7:	ff 75 08             	pushl  0x8(%ebp)
801081ca:	e8 a4 f8 ff ff       	call   80107a73 <walkpgdir>
801081cf:	83 c4 10             	add    $0x10,%esp
801081d2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
801081d5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801081d9:	75 0d                	jne    801081e8 <clearpteu+0x2f>
    panic("clearpteu");
801081db:	83 ec 0c             	sub    $0xc,%esp
801081de:	68 0c 8d 10 80       	push   $0x80108d0c
801081e3:	e8 b8 83 ff ff       	call   801005a0 <panic>
  *pte &= ~PTE_U;
801081e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081eb:	8b 00                	mov    (%eax),%eax
801081ed:	83 e0 fb             	and    $0xfffffffb,%eax
801081f0:	89 c2                	mov    %eax,%edx
801081f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081f5:	89 10                	mov    %edx,(%eax)
}
801081f7:	90                   	nop
801081f8:	c9                   	leave  
801081f9:	c3                   	ret    

801081fa <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
801081fa:	55                   	push   %ebp
801081fb:	89 e5                	mov    %esp,%ebp
801081fd:	83 ec 28             	sub    $0x28,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
80108200:	e8 94 f9 ff ff       	call   80107b99 <setupkvm>
80108205:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108208:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010820c:	75 0a                	jne    80108218 <copyuvm+0x1e>
    return 0;
8010820e:	b8 00 00 00 00       	mov    $0x0,%eax
80108213:	e9 df 01 00 00       	jmp    801083f7 <copyuvm+0x1fd>
  for(i = 0; i < sz; i += PGSIZE){
80108218:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010821f:	e9 bf 00 00 00       	jmp    801082e3 <copyuvm+0xe9>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
80108224:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108227:	83 ec 04             	sub    $0x4,%esp
8010822a:	6a 00                	push   $0x0
8010822c:	50                   	push   %eax
8010822d:	ff 75 08             	pushl  0x8(%ebp)
80108230:	e8 3e f8 ff ff       	call   80107a73 <walkpgdir>
80108235:	83 c4 10             	add    $0x10,%esp
80108238:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010823b:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010823f:	75 0d                	jne    8010824e <copyuvm+0x54>
      panic("copyuvm: pte should exist");
80108241:	83 ec 0c             	sub    $0xc,%esp
80108244:	68 16 8d 10 80       	push   $0x80108d16
80108249:	e8 52 83 ff ff       	call   801005a0 <panic>
    if(!(*pte & PTE_P))
8010824e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108251:	8b 00                	mov    (%eax),%eax
80108253:	83 e0 01             	and    $0x1,%eax
80108256:	85 c0                	test   %eax,%eax
80108258:	75 0d                	jne    80108267 <copyuvm+0x6d>
      panic("copyuvm: page not present");
8010825a:	83 ec 0c             	sub    $0xc,%esp
8010825d:	68 30 8d 10 80       	push   $0x80108d30
80108262:	e8 39 83 ff ff       	call   801005a0 <panic>
    pa = PTE_ADDR(*pte);
80108267:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010826a:	8b 00                	mov    (%eax),%eax
8010826c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108271:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
80108274:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108277:	8b 00                	mov    (%eax),%eax
80108279:	25 ff 0f 00 00       	and    $0xfff,%eax
8010827e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
80108281:	e8 06 aa ff ff       	call   80102c8c <kalloc>
80108286:	89 45 e0             	mov    %eax,-0x20(%ebp)
80108289:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
8010828d:	0f 84 47 01 00 00    	je     801083da <copyuvm+0x1e0>
      goto bad;
    memmove(mem, (char*)P2V(pa), PGSIZE);
80108293:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108296:	05 00 00 00 80       	add    $0x80000000,%eax
8010829b:	83 ec 04             	sub    $0x4,%esp
8010829e:	68 00 10 00 00       	push   $0x1000
801082a3:	50                   	push   %eax
801082a4:	ff 75 e0             	pushl  -0x20(%ebp)
801082a7:	e8 f7 cf ff ff       	call   801052a3 <memmove>
801082ac:	83 c4 10             	add    $0x10,%esp
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0)
801082af:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801082b2:	8b 45 e0             	mov    -0x20(%ebp),%eax
801082b5:	8d 88 00 00 00 80    	lea    -0x80000000(%eax),%ecx
801082bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082be:	83 ec 0c             	sub    $0xc,%esp
801082c1:	52                   	push   %edx
801082c2:	51                   	push   %ecx
801082c3:	68 00 10 00 00       	push   $0x1000
801082c8:	50                   	push   %eax
801082c9:	ff 75 f0             	pushl  -0x10(%ebp)
801082cc:	e8 38 f8 ff ff       	call   80107b09 <mappages>
801082d1:	83 c4 20             	add    $0x20,%esp
801082d4:	85 c0                	test   %eax,%eax
801082d6:	0f 88 01 01 00 00    	js     801083dd <copyuvm+0x1e3>
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
801082dc:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801082e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082e6:	3b 45 0c             	cmp    0xc(%ebp),%eax
801082e9:	0f 82 35 ff ff ff    	jb     80108224 <copyuvm+0x2a>
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0)
      goto bad;
  }

  //Lab 2 addition
  for(i = STACK_TOP; i > (STACK_TOP - (myproc()->stackSize * PGSIZE)); i -= PGSIZE){
801082ef:	c7 45 f4 fc ff ff 7f 	movl   $0x7ffffffc,-0xc(%ebp)
801082f6:	e9 bd 00 00 00       	jmp    801083b8 <copyuvm+0x1be>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
801082fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082fe:	83 ec 04             	sub    $0x4,%esp
80108301:	6a 00                	push   $0x0
80108303:	50                   	push   %eax
80108304:	ff 75 08             	pushl  0x8(%ebp)
80108307:	e8 67 f7 ff ff       	call   80107a73 <walkpgdir>
8010830c:	83 c4 10             	add    $0x10,%esp
8010830f:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108312:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108316:	75 0d                	jne    80108325 <copyuvm+0x12b>
      panic("copyuvm: pte should exist");
80108318:	83 ec 0c             	sub    $0xc,%esp
8010831b:	68 16 8d 10 80       	push   $0x80108d16
80108320:	e8 7b 82 ff ff       	call   801005a0 <panic>
    if(!(*pte & PTE_P))
80108325:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108328:	8b 00                	mov    (%eax),%eax
8010832a:	83 e0 01             	and    $0x1,%eax
8010832d:	85 c0                	test   %eax,%eax
8010832f:	75 0d                	jne    8010833e <copyuvm+0x144>
      panic("copyuvm: page not present");
80108331:	83 ec 0c             	sub    $0xc,%esp
80108334:	68 30 8d 10 80       	push   $0x80108d30
80108339:	e8 62 82 ff ff       	call   801005a0 <panic>
    pa = PTE_ADDR(*pte);
8010833e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108341:	8b 00                	mov    (%eax),%eax
80108343:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108348:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
8010834b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010834e:	8b 00                	mov    (%eax),%eax
80108350:	25 ff 0f 00 00       	and    $0xfff,%eax
80108355:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
80108358:	e8 2f a9 ff ff       	call   80102c8c <kalloc>
8010835d:	89 45 e0             	mov    %eax,-0x20(%ebp)
80108360:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80108364:	74 7a                	je     801083e0 <copyuvm+0x1e6>
      goto bad;
    memmove(mem, (char*)P2V(pa), PGSIZE);
80108366:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108369:	05 00 00 00 80       	add    $0x80000000,%eax
8010836e:	83 ec 04             	sub    $0x4,%esp
80108371:	68 00 10 00 00       	push   $0x1000
80108376:	50                   	push   %eax
80108377:	ff 75 e0             	pushl  -0x20(%ebp)
8010837a:	e8 24 cf ff ff       	call   801052a3 <memmove>
8010837f:	83 c4 10             	add    $0x10,%esp
    if(mappages(d, (void*)PGROUNDDOWN(i), PGSIZE, V2P(mem), flags) < 0)
80108382:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108385:	8b 55 e0             	mov    -0x20(%ebp),%edx
80108388:	81 c2 00 00 00 80    	add    $0x80000000,%edx
8010838e:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80108391:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
80108397:	83 ec 0c             	sub    $0xc,%esp
8010839a:	50                   	push   %eax
8010839b:	52                   	push   %edx
8010839c:	68 00 10 00 00       	push   $0x1000
801083a1:	51                   	push   %ecx
801083a2:	ff 75 f0             	pushl  -0x10(%ebp)
801083a5:	e8 5f f7 ff ff       	call   80107b09 <mappages>
801083aa:	83 c4 20             	add    $0x20,%esp
801083ad:	85 c0                	test   %eax,%eax
801083af:	78 32                	js     801083e3 <copyuvm+0x1e9>
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0)
      goto bad;
  }

  //Lab 2 addition
  for(i = STACK_TOP; i > (STACK_TOP - (myproc()->stackSize * PGSIZE)); i -= PGSIZE){
801083b1:	81 6d f4 00 10 00 00 	subl   $0x1000,-0xc(%ebp)
801083b8:	e8 c7 be ff ff       	call   80104284 <myproc>
801083bd:	8b 40 08             	mov    0x8(%eax),%eax
801083c0:	c1 e0 0c             	shl    $0xc,%eax
801083c3:	ba fc ff ff 7f       	mov    $0x7ffffffc,%edx
801083c8:	29 c2                	sub    %eax,%edx
801083ca:	89 d0                	mov    %edx,%eax
801083cc:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801083cf:	0f 82 26 ff ff ff    	jb     801082fb <copyuvm+0x101>
      goto bad;
    memmove(mem, (char*)P2V(pa), PGSIZE);
    if(mappages(d, (void*)PGROUNDDOWN(i), PGSIZE, V2P(mem), flags) < 0)
      goto bad;
  }
  return d;
801083d5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801083d8:	eb 1d                	jmp    801083f7 <copyuvm+0x1fd>
    if(!(*pte & PTE_P))
      panic("copyuvm: page not present");
    pa = PTE_ADDR(*pte);
    flags = PTE_FLAGS(*pte);
    if((mem = kalloc()) == 0)
      goto bad;
801083da:	90                   	nop
801083db:	eb 07                	jmp    801083e4 <copyuvm+0x1ea>
    memmove(mem, (char*)P2V(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0)
      goto bad;
801083dd:	90                   	nop
801083de:	eb 04                	jmp    801083e4 <copyuvm+0x1ea>
    if(!(*pte & PTE_P))
      panic("copyuvm: page not present");
    pa = PTE_ADDR(*pte);
    flags = PTE_FLAGS(*pte);
    if((mem = kalloc()) == 0)
      goto bad;
801083e0:	90                   	nop
801083e1:	eb 01                	jmp    801083e4 <copyuvm+0x1ea>
    memmove(mem, (char*)P2V(pa), PGSIZE);
    if(mappages(d, (void*)PGROUNDDOWN(i), PGSIZE, V2P(mem), flags) < 0)
      goto bad;
801083e3:	90                   	nop
  }
  return d;

bad:
  freevm(d);
801083e4:	83 ec 0c             	sub    $0xc,%esp
801083e7:	ff 75 f0             	pushl  -0x10(%ebp)
801083ea:	e8 31 fd ff ff       	call   80108120 <freevm>
801083ef:	83 c4 10             	add    $0x10,%esp
  return 0;
801083f2:	b8 00 00 00 00       	mov    $0x0,%eax
}
801083f7:	c9                   	leave  
801083f8:	c3                   	ret    

801083f9 <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
801083f9:	55                   	push   %ebp
801083fa:	89 e5                	mov    %esp,%ebp
801083fc:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
801083ff:	83 ec 04             	sub    $0x4,%esp
80108402:	6a 00                	push   $0x0
80108404:	ff 75 0c             	pushl  0xc(%ebp)
80108407:	ff 75 08             	pushl  0x8(%ebp)
8010840a:	e8 64 f6 ff ff       	call   80107a73 <walkpgdir>
8010840f:	83 c4 10             	add    $0x10,%esp
80108412:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
80108415:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108418:	8b 00                	mov    (%eax),%eax
8010841a:	83 e0 01             	and    $0x1,%eax
8010841d:	85 c0                	test   %eax,%eax
8010841f:	75 07                	jne    80108428 <uva2ka+0x2f>
    return 0;
80108421:	b8 00 00 00 00       	mov    $0x0,%eax
80108426:	eb 22                	jmp    8010844a <uva2ka+0x51>
  if((*pte & PTE_U) == 0)
80108428:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010842b:	8b 00                	mov    (%eax),%eax
8010842d:	83 e0 04             	and    $0x4,%eax
80108430:	85 c0                	test   %eax,%eax
80108432:	75 07                	jne    8010843b <uva2ka+0x42>
    return 0;
80108434:	b8 00 00 00 00       	mov    $0x0,%eax
80108439:	eb 0f                	jmp    8010844a <uva2ka+0x51>
  return (char*)P2V(PTE_ADDR(*pte));
8010843b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010843e:	8b 00                	mov    (%eax),%eax
80108440:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108445:	05 00 00 00 80       	add    $0x80000000,%eax
}
8010844a:	c9                   	leave  
8010844b:	c3                   	ret    

8010844c <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
8010844c:	55                   	push   %ebp
8010844d:	89 e5                	mov    %esp,%ebp
8010844f:	83 ec 18             	sub    $0x18,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
80108452:	8b 45 10             	mov    0x10(%ebp),%eax
80108455:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
80108458:	eb 7f                	jmp    801084d9 <copyout+0x8d>
    va0 = (uint)PGROUNDDOWN(va);
8010845a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010845d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108462:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
80108465:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108468:	83 ec 08             	sub    $0x8,%esp
8010846b:	50                   	push   %eax
8010846c:	ff 75 08             	pushl  0x8(%ebp)
8010846f:	e8 85 ff ff ff       	call   801083f9 <uva2ka>
80108474:	83 c4 10             	add    $0x10,%esp
80108477:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
8010847a:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
8010847e:	75 07                	jne    80108487 <copyout+0x3b>
      return -1;
80108480:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108485:	eb 61                	jmp    801084e8 <copyout+0x9c>
    n = PGSIZE - (va - va0);
80108487:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010848a:	2b 45 0c             	sub    0xc(%ebp),%eax
8010848d:	05 00 10 00 00       	add    $0x1000,%eax
80108492:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
80108495:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108498:	3b 45 14             	cmp    0x14(%ebp),%eax
8010849b:	76 06                	jbe    801084a3 <copyout+0x57>
      n = len;
8010849d:	8b 45 14             	mov    0x14(%ebp),%eax
801084a0:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
801084a3:	8b 45 0c             	mov    0xc(%ebp),%eax
801084a6:	2b 45 ec             	sub    -0x14(%ebp),%eax
801084a9:	89 c2                	mov    %eax,%edx
801084ab:	8b 45 e8             	mov    -0x18(%ebp),%eax
801084ae:	01 d0                	add    %edx,%eax
801084b0:	83 ec 04             	sub    $0x4,%esp
801084b3:	ff 75 f0             	pushl  -0x10(%ebp)
801084b6:	ff 75 f4             	pushl  -0xc(%ebp)
801084b9:	50                   	push   %eax
801084ba:	e8 e4 cd ff ff       	call   801052a3 <memmove>
801084bf:	83 c4 10             	add    $0x10,%esp
    len -= n;
801084c2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801084c5:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
801084c8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801084cb:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
801084ce:	8b 45 ec             	mov    -0x14(%ebp),%eax
801084d1:	05 00 10 00 00       	add    $0x1000,%eax
801084d6:	89 45 0c             	mov    %eax,0xc(%ebp)
{
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
  while(len > 0){
801084d9:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
801084dd:	0f 85 77 ff ff ff    	jne    8010845a <copyout+0xe>
    memmove(pa0 + (va - va0), buf, n);
    len -= n;
    buf += n;
    va = va0 + PGSIZE;
  }
  return 0;
801084e3:	b8 00 00 00 00       	mov    $0x0,%eax
}
801084e8:	c9                   	leave  
801084e9:	c3                   	ret    

801084ea <shminit>:
    char *frame;
    int refcnt;
  } shm_pages[64];
} shm_table;

void shminit() {
801084ea:	55                   	push   %ebp
801084eb:	89 e5                	mov    %esp,%ebp
801084ed:	83 ec 18             	sub    $0x18,%esp
  int i;
  initlock(&(shm_table.lock), "SHM lock");
801084f0:	83 ec 08             	sub    $0x8,%esp
801084f3:	68 4a 8d 10 80       	push   $0x80108d4a
801084f8:	68 40 67 11 80       	push   $0x80116740
801084fd:	e8 49 ca ff ff       	call   80104f4b <initlock>
80108502:	83 c4 10             	add    $0x10,%esp
  acquire(&(shm_table.lock));
80108505:	83 ec 0c             	sub    $0xc,%esp
80108508:	68 40 67 11 80       	push   $0x80116740
8010850d:	e8 5b ca ff ff       	call   80104f6d <acquire>
80108512:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i< 64; i++) {
80108515:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010851c:	eb 49                	jmp    80108567 <shminit+0x7d>
    shm_table.shm_pages[i].id =0;
8010851e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108521:	89 d0                	mov    %edx,%eax
80108523:	01 c0                	add    %eax,%eax
80108525:	01 d0                	add    %edx,%eax
80108527:	c1 e0 02             	shl    $0x2,%eax
8010852a:	05 74 67 11 80       	add    $0x80116774,%eax
8010852f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    shm_table.shm_pages[i].frame =0;
80108535:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108538:	89 d0                	mov    %edx,%eax
8010853a:	01 c0                	add    %eax,%eax
8010853c:	01 d0                	add    %edx,%eax
8010853e:	c1 e0 02             	shl    $0x2,%eax
80108541:	05 78 67 11 80       	add    $0x80116778,%eax
80108546:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    shm_table.shm_pages[i].refcnt =0;
8010854c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010854f:	89 d0                	mov    %edx,%eax
80108551:	01 c0                	add    %eax,%eax
80108553:	01 d0                	add    %edx,%eax
80108555:	c1 e0 02             	shl    $0x2,%eax
80108558:	05 7c 67 11 80       	add    $0x8011677c,%eax
8010855d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

void shminit() {
  int i;
  initlock(&(shm_table.lock), "SHM lock");
  acquire(&(shm_table.lock));
  for (i = 0; i< 64; i++) {
80108563:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108567:	83 7d f4 3f          	cmpl   $0x3f,-0xc(%ebp)
8010856b:	7e b1                	jle    8010851e <shminit+0x34>
    shm_table.shm_pages[i].id =0;
    shm_table.shm_pages[i].frame =0;
    shm_table.shm_pages[i].refcnt =0;
  }
  release(&(shm_table.lock));
8010856d:	83 ec 0c             	sub    $0xc,%esp
80108570:	68 40 67 11 80       	push   $0x80116740
80108575:	e8 61 ca ff ff       	call   80104fdb <release>
8010857a:	83 c4 10             	add    $0x10,%esp
}
8010857d:	90                   	nop
8010857e:	c9                   	leave  
8010857f:	c3                   	ret    

80108580 <shm_open>:

int shm_open(int id, char **pointer) {
80108580:	55                   	push   %ebp
80108581:	89 e5                	mov    %esp,%ebp
//you write this




return 0; //added to remove compiler warning -- you should decide what to return
80108583:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108588:	5d                   	pop    %ebp
80108589:	c3                   	ret    

8010858a <shm_close>:


int shm_close(int id) {
8010858a:	55                   	push   %ebp
8010858b:	89 e5                	mov    %esp,%ebp
//you write this too!




return 0; //added to remove compiler warning -- you should decide what to return
8010858d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108592:	5d                   	pop    %ebp
80108593:	c3                   	ret    
