
_test:     file format elf32-i386


Disassembly of section .text:

00001000 <testFunc>:
#include "types.h"
#include "user.h"

void testFunc()
{
    1000:	55                   	push   %ebp
    1001:	89 e5                	mov    %esp,%ebp
    1003:	83 ec 18             	sub    $0x18,%esp
  char a = 0;
    1006:	c6 45 f7 00          	movb   $0x0,-0x9(%ebp)
  int b = 0;
    100a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  uint c = 0;
    1011:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int d = 0;
    1018:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)


  a += 1;
    101f:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
    1023:	83 c0 01             	add    $0x1,%eax
    1026:	88 45 f7             	mov    %al,-0x9(%ebp)
  b -= 1;
    1029:	83 6d f0 01          	subl   $0x1,-0x10(%ebp)
  c += 1;
    102d:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
  d -= 1;
    1031:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)


  testFunc();
    1035:	e8 c6 ff ff ff       	call   1000 <testFunc>

}
    103a:	90                   	nop
    103b:	c9                   	leave  
    103c:	c3                   	ret    

0000103d <main>:

int main()
{
    103d:	8d 4c 24 04          	lea    0x4(%esp),%ecx
    1041:	83 e4 f0             	and    $0xfffffff0,%esp
    1044:	ff 71 fc             	pushl  -0x4(%ecx)
    1047:	55                   	push   %ebp
    1048:	89 e5                	mov    %esp,%ebp
    104a:	51                   	push   %ecx
    104b:	83 ec 04             	sub    $0x4,%esp
  testFunc();
    104e:	e8 ad ff ff ff       	call   1000 <testFunc>
  exit();
    1053:	e8 57 02 00 00       	call   12af <exit>

00001058 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
    1058:	55                   	push   %ebp
    1059:	89 e5                	mov    %esp,%ebp
    105b:	57                   	push   %edi
    105c:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
    105d:	8b 4d 08             	mov    0x8(%ebp),%ecx
    1060:	8b 55 10             	mov    0x10(%ebp),%edx
    1063:	8b 45 0c             	mov    0xc(%ebp),%eax
    1066:	89 cb                	mov    %ecx,%ebx
    1068:	89 df                	mov    %ebx,%edi
    106a:	89 d1                	mov    %edx,%ecx
    106c:	fc                   	cld    
    106d:	f3 aa                	rep stos %al,%es:(%edi)
    106f:	89 ca                	mov    %ecx,%edx
    1071:	89 fb                	mov    %edi,%ebx
    1073:	89 5d 08             	mov    %ebx,0x8(%ebp)
    1076:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
    1079:	90                   	nop
    107a:	5b                   	pop    %ebx
    107b:	5f                   	pop    %edi
    107c:	5d                   	pop    %ebp
    107d:	c3                   	ret    

0000107e <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
    107e:	55                   	push   %ebp
    107f:	89 e5                	mov    %esp,%ebp
    1081:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
    1084:	8b 45 08             	mov    0x8(%ebp),%eax
    1087:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
    108a:	90                   	nop
    108b:	8b 45 08             	mov    0x8(%ebp),%eax
    108e:	8d 50 01             	lea    0x1(%eax),%edx
    1091:	89 55 08             	mov    %edx,0x8(%ebp)
    1094:	8b 55 0c             	mov    0xc(%ebp),%edx
    1097:	8d 4a 01             	lea    0x1(%edx),%ecx
    109a:	89 4d 0c             	mov    %ecx,0xc(%ebp)
    109d:	0f b6 12             	movzbl (%edx),%edx
    10a0:	88 10                	mov    %dl,(%eax)
    10a2:	0f b6 00             	movzbl (%eax),%eax
    10a5:	84 c0                	test   %al,%al
    10a7:	75 e2                	jne    108b <strcpy+0xd>
    ;
  return os;
    10a9:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
    10ac:	c9                   	leave  
    10ad:	c3                   	ret    

000010ae <strcmp>:

int
strcmp(const char *p, const char *q)
{
    10ae:	55                   	push   %ebp
    10af:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
    10b1:	eb 08                	jmp    10bb <strcmp+0xd>
    p++, q++;
    10b3:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    10b7:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
    10bb:	8b 45 08             	mov    0x8(%ebp),%eax
    10be:	0f b6 00             	movzbl (%eax),%eax
    10c1:	84 c0                	test   %al,%al
    10c3:	74 10                	je     10d5 <strcmp+0x27>
    10c5:	8b 45 08             	mov    0x8(%ebp),%eax
    10c8:	0f b6 10             	movzbl (%eax),%edx
    10cb:	8b 45 0c             	mov    0xc(%ebp),%eax
    10ce:	0f b6 00             	movzbl (%eax),%eax
    10d1:	38 c2                	cmp    %al,%dl
    10d3:	74 de                	je     10b3 <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
    10d5:	8b 45 08             	mov    0x8(%ebp),%eax
    10d8:	0f b6 00             	movzbl (%eax),%eax
    10db:	0f b6 d0             	movzbl %al,%edx
    10de:	8b 45 0c             	mov    0xc(%ebp),%eax
    10e1:	0f b6 00             	movzbl (%eax),%eax
    10e4:	0f b6 c0             	movzbl %al,%eax
    10e7:	29 c2                	sub    %eax,%edx
    10e9:	89 d0                	mov    %edx,%eax
}
    10eb:	5d                   	pop    %ebp
    10ec:	c3                   	ret    

000010ed <strlen>:

uint
strlen(char *s)
{
    10ed:	55                   	push   %ebp
    10ee:	89 e5                	mov    %esp,%ebp
    10f0:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
    10f3:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    10fa:	eb 04                	jmp    1100 <strlen+0x13>
    10fc:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
    1100:	8b 55 fc             	mov    -0x4(%ebp),%edx
    1103:	8b 45 08             	mov    0x8(%ebp),%eax
    1106:	01 d0                	add    %edx,%eax
    1108:	0f b6 00             	movzbl (%eax),%eax
    110b:	84 c0                	test   %al,%al
    110d:	75 ed                	jne    10fc <strlen+0xf>
    ;
  return n;
    110f:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
    1112:	c9                   	leave  
    1113:	c3                   	ret    

00001114 <memset>:

void*
memset(void *dst, int c, uint n)
{
    1114:	55                   	push   %ebp
    1115:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
    1117:	8b 45 10             	mov    0x10(%ebp),%eax
    111a:	50                   	push   %eax
    111b:	ff 75 0c             	pushl  0xc(%ebp)
    111e:	ff 75 08             	pushl  0x8(%ebp)
    1121:	e8 32 ff ff ff       	call   1058 <stosb>
    1126:	83 c4 0c             	add    $0xc,%esp
  return dst;
    1129:	8b 45 08             	mov    0x8(%ebp),%eax
}
    112c:	c9                   	leave  
    112d:	c3                   	ret    

0000112e <strchr>:

char*
strchr(const char *s, char c)
{
    112e:	55                   	push   %ebp
    112f:	89 e5                	mov    %esp,%ebp
    1131:	83 ec 04             	sub    $0x4,%esp
    1134:	8b 45 0c             	mov    0xc(%ebp),%eax
    1137:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
    113a:	eb 14                	jmp    1150 <strchr+0x22>
    if(*s == c)
    113c:	8b 45 08             	mov    0x8(%ebp),%eax
    113f:	0f b6 00             	movzbl (%eax),%eax
    1142:	3a 45 fc             	cmp    -0x4(%ebp),%al
    1145:	75 05                	jne    114c <strchr+0x1e>
      return (char*)s;
    1147:	8b 45 08             	mov    0x8(%ebp),%eax
    114a:	eb 13                	jmp    115f <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
    114c:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    1150:	8b 45 08             	mov    0x8(%ebp),%eax
    1153:	0f b6 00             	movzbl (%eax),%eax
    1156:	84 c0                	test   %al,%al
    1158:	75 e2                	jne    113c <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
    115a:	b8 00 00 00 00       	mov    $0x0,%eax
}
    115f:	c9                   	leave  
    1160:	c3                   	ret    

00001161 <gets>:

char*
gets(char *buf, int max)
{
    1161:	55                   	push   %ebp
    1162:	89 e5                	mov    %esp,%ebp
    1164:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
    1167:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    116e:	eb 42                	jmp    11b2 <gets+0x51>
    cc = read(0, &c, 1);
    1170:	83 ec 04             	sub    $0x4,%esp
    1173:	6a 01                	push   $0x1
    1175:	8d 45 ef             	lea    -0x11(%ebp),%eax
    1178:	50                   	push   %eax
    1179:	6a 00                	push   $0x0
    117b:	e8 47 01 00 00       	call   12c7 <read>
    1180:	83 c4 10             	add    $0x10,%esp
    1183:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
    1186:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    118a:	7e 33                	jle    11bf <gets+0x5e>
      break;
    buf[i++] = c;
    118c:	8b 45 f4             	mov    -0xc(%ebp),%eax
    118f:	8d 50 01             	lea    0x1(%eax),%edx
    1192:	89 55 f4             	mov    %edx,-0xc(%ebp)
    1195:	89 c2                	mov    %eax,%edx
    1197:	8b 45 08             	mov    0x8(%ebp),%eax
    119a:	01 c2                	add    %eax,%edx
    119c:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    11a0:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
    11a2:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    11a6:	3c 0a                	cmp    $0xa,%al
    11a8:	74 16                	je     11c0 <gets+0x5f>
    11aa:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    11ae:	3c 0d                	cmp    $0xd,%al
    11b0:	74 0e                	je     11c0 <gets+0x5f>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
    11b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
    11b5:	83 c0 01             	add    $0x1,%eax
    11b8:	3b 45 0c             	cmp    0xc(%ebp),%eax
    11bb:	7c b3                	jl     1170 <gets+0xf>
    11bd:	eb 01                	jmp    11c0 <gets+0x5f>
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    11bf:	90                   	nop
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
    11c0:	8b 55 f4             	mov    -0xc(%ebp),%edx
    11c3:	8b 45 08             	mov    0x8(%ebp),%eax
    11c6:	01 d0                	add    %edx,%eax
    11c8:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
    11cb:	8b 45 08             	mov    0x8(%ebp),%eax
}
    11ce:	c9                   	leave  
    11cf:	c3                   	ret    

000011d0 <stat>:

int
stat(char *n, struct stat *st)
{
    11d0:	55                   	push   %ebp
    11d1:	89 e5                	mov    %esp,%ebp
    11d3:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
    11d6:	83 ec 08             	sub    $0x8,%esp
    11d9:	6a 00                	push   $0x0
    11db:	ff 75 08             	pushl  0x8(%ebp)
    11de:	e8 0c 01 00 00       	call   12ef <open>
    11e3:	83 c4 10             	add    $0x10,%esp
    11e6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
    11e9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    11ed:	79 07                	jns    11f6 <stat+0x26>
    return -1;
    11ef:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
    11f4:	eb 25                	jmp    121b <stat+0x4b>
  r = fstat(fd, st);
    11f6:	83 ec 08             	sub    $0x8,%esp
    11f9:	ff 75 0c             	pushl  0xc(%ebp)
    11fc:	ff 75 f4             	pushl  -0xc(%ebp)
    11ff:	e8 03 01 00 00       	call   1307 <fstat>
    1204:	83 c4 10             	add    $0x10,%esp
    1207:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
    120a:	83 ec 0c             	sub    $0xc,%esp
    120d:	ff 75 f4             	pushl  -0xc(%ebp)
    1210:	e8 c2 00 00 00       	call   12d7 <close>
    1215:	83 c4 10             	add    $0x10,%esp
  return r;
    1218:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
    121b:	c9                   	leave  
    121c:	c3                   	ret    

0000121d <atoi>:

int
atoi(const char *s)
{
    121d:	55                   	push   %ebp
    121e:	89 e5                	mov    %esp,%ebp
    1220:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
    1223:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
    122a:	eb 25                	jmp    1251 <atoi+0x34>
    n = n*10 + *s++ - '0';
    122c:	8b 55 fc             	mov    -0x4(%ebp),%edx
    122f:	89 d0                	mov    %edx,%eax
    1231:	c1 e0 02             	shl    $0x2,%eax
    1234:	01 d0                	add    %edx,%eax
    1236:	01 c0                	add    %eax,%eax
    1238:	89 c1                	mov    %eax,%ecx
    123a:	8b 45 08             	mov    0x8(%ebp),%eax
    123d:	8d 50 01             	lea    0x1(%eax),%edx
    1240:	89 55 08             	mov    %edx,0x8(%ebp)
    1243:	0f b6 00             	movzbl (%eax),%eax
    1246:	0f be c0             	movsbl %al,%eax
    1249:	01 c8                	add    %ecx,%eax
    124b:	83 e8 30             	sub    $0x30,%eax
    124e:	89 45 fc             	mov    %eax,-0x4(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
    1251:	8b 45 08             	mov    0x8(%ebp),%eax
    1254:	0f b6 00             	movzbl (%eax),%eax
    1257:	3c 2f                	cmp    $0x2f,%al
    1259:	7e 0a                	jle    1265 <atoi+0x48>
    125b:	8b 45 08             	mov    0x8(%ebp),%eax
    125e:	0f b6 00             	movzbl (%eax),%eax
    1261:	3c 39                	cmp    $0x39,%al
    1263:	7e c7                	jle    122c <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
    1265:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
    1268:	c9                   	leave  
    1269:	c3                   	ret    

0000126a <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
    126a:	55                   	push   %ebp
    126b:	89 e5                	mov    %esp,%ebp
    126d:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;

  dst = vdst;
    1270:	8b 45 08             	mov    0x8(%ebp),%eax
    1273:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
    1276:	8b 45 0c             	mov    0xc(%ebp),%eax
    1279:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
    127c:	eb 17                	jmp    1295 <memmove+0x2b>
    *dst++ = *src++;
    127e:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1281:	8d 50 01             	lea    0x1(%eax),%edx
    1284:	89 55 fc             	mov    %edx,-0x4(%ebp)
    1287:	8b 55 f8             	mov    -0x8(%ebp),%edx
    128a:	8d 4a 01             	lea    0x1(%edx),%ecx
    128d:	89 4d f8             	mov    %ecx,-0x8(%ebp)
    1290:	0f b6 12             	movzbl (%edx),%edx
    1293:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;

  dst = vdst;
  src = vsrc;
  while(n-- > 0)
    1295:	8b 45 10             	mov    0x10(%ebp),%eax
    1298:	8d 50 ff             	lea    -0x1(%eax),%edx
    129b:	89 55 10             	mov    %edx,0x10(%ebp)
    129e:	85 c0                	test   %eax,%eax
    12a0:	7f dc                	jg     127e <memmove+0x14>
    *dst++ = *src++;
  return vdst;
    12a2:	8b 45 08             	mov    0x8(%ebp),%eax
}
    12a5:	c9                   	leave  
    12a6:	c3                   	ret    

000012a7 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
    12a7:	b8 01 00 00 00       	mov    $0x1,%eax
    12ac:	cd 40                	int    $0x40
    12ae:	c3                   	ret    

000012af <exit>:
SYSCALL(exit)
    12af:	b8 02 00 00 00       	mov    $0x2,%eax
    12b4:	cd 40                	int    $0x40
    12b6:	c3                   	ret    

000012b7 <wait>:
SYSCALL(wait)
    12b7:	b8 03 00 00 00       	mov    $0x3,%eax
    12bc:	cd 40                	int    $0x40
    12be:	c3                   	ret    

000012bf <pipe>:
SYSCALL(pipe)
    12bf:	b8 04 00 00 00       	mov    $0x4,%eax
    12c4:	cd 40                	int    $0x40
    12c6:	c3                   	ret    

000012c7 <read>:
SYSCALL(read)
    12c7:	b8 05 00 00 00       	mov    $0x5,%eax
    12cc:	cd 40                	int    $0x40
    12ce:	c3                   	ret    

000012cf <write>:
SYSCALL(write)
    12cf:	b8 10 00 00 00       	mov    $0x10,%eax
    12d4:	cd 40                	int    $0x40
    12d6:	c3                   	ret    

000012d7 <close>:
SYSCALL(close)
    12d7:	b8 15 00 00 00       	mov    $0x15,%eax
    12dc:	cd 40                	int    $0x40
    12de:	c3                   	ret    

000012df <kill>:
SYSCALL(kill)
    12df:	b8 06 00 00 00       	mov    $0x6,%eax
    12e4:	cd 40                	int    $0x40
    12e6:	c3                   	ret    

000012e7 <exec>:
SYSCALL(exec)
    12e7:	b8 07 00 00 00       	mov    $0x7,%eax
    12ec:	cd 40                	int    $0x40
    12ee:	c3                   	ret    

000012ef <open>:
SYSCALL(open)
    12ef:	b8 0f 00 00 00       	mov    $0xf,%eax
    12f4:	cd 40                	int    $0x40
    12f6:	c3                   	ret    

000012f7 <mknod>:
SYSCALL(mknod)
    12f7:	b8 11 00 00 00       	mov    $0x11,%eax
    12fc:	cd 40                	int    $0x40
    12fe:	c3                   	ret    

000012ff <unlink>:
SYSCALL(unlink)
    12ff:	b8 12 00 00 00       	mov    $0x12,%eax
    1304:	cd 40                	int    $0x40
    1306:	c3                   	ret    

00001307 <fstat>:
SYSCALL(fstat)
    1307:	b8 08 00 00 00       	mov    $0x8,%eax
    130c:	cd 40                	int    $0x40
    130e:	c3                   	ret    

0000130f <link>:
SYSCALL(link)
    130f:	b8 13 00 00 00       	mov    $0x13,%eax
    1314:	cd 40                	int    $0x40
    1316:	c3                   	ret    

00001317 <mkdir>:
SYSCALL(mkdir)
    1317:	b8 14 00 00 00       	mov    $0x14,%eax
    131c:	cd 40                	int    $0x40
    131e:	c3                   	ret    

0000131f <chdir>:
SYSCALL(chdir)
    131f:	b8 09 00 00 00       	mov    $0x9,%eax
    1324:	cd 40                	int    $0x40
    1326:	c3                   	ret    

00001327 <dup>:
SYSCALL(dup)
    1327:	b8 0a 00 00 00       	mov    $0xa,%eax
    132c:	cd 40                	int    $0x40
    132e:	c3                   	ret    

0000132f <getpid>:
SYSCALL(getpid)
    132f:	b8 0b 00 00 00       	mov    $0xb,%eax
    1334:	cd 40                	int    $0x40
    1336:	c3                   	ret    

00001337 <sbrk>:
SYSCALL(sbrk)
    1337:	b8 0c 00 00 00       	mov    $0xc,%eax
    133c:	cd 40                	int    $0x40
    133e:	c3                   	ret    

0000133f <sleep>:
SYSCALL(sleep)
    133f:	b8 0d 00 00 00       	mov    $0xd,%eax
    1344:	cd 40                	int    $0x40
    1346:	c3                   	ret    

00001347 <uptime>:
SYSCALL(uptime)
    1347:	b8 0e 00 00 00       	mov    $0xe,%eax
    134c:	cd 40                	int    $0x40
    134e:	c3                   	ret    

0000134f <shm_open>:
SYSCALL(shm_open)
    134f:	b8 16 00 00 00       	mov    $0x16,%eax
    1354:	cd 40                	int    $0x40
    1356:	c3                   	ret    

00001357 <shm_close>:
SYSCALL(shm_close)	
    1357:	b8 17 00 00 00       	mov    $0x17,%eax
    135c:	cd 40                	int    $0x40
    135e:	c3                   	ret    

0000135f <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
    135f:	55                   	push   %ebp
    1360:	89 e5                	mov    %esp,%ebp
    1362:	83 ec 18             	sub    $0x18,%esp
    1365:	8b 45 0c             	mov    0xc(%ebp),%eax
    1368:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
    136b:	83 ec 04             	sub    $0x4,%esp
    136e:	6a 01                	push   $0x1
    1370:	8d 45 f4             	lea    -0xc(%ebp),%eax
    1373:	50                   	push   %eax
    1374:	ff 75 08             	pushl  0x8(%ebp)
    1377:	e8 53 ff ff ff       	call   12cf <write>
    137c:	83 c4 10             	add    $0x10,%esp
}
    137f:	90                   	nop
    1380:	c9                   	leave  
    1381:	c3                   	ret    

00001382 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
    1382:	55                   	push   %ebp
    1383:	89 e5                	mov    %esp,%ebp
    1385:	53                   	push   %ebx
    1386:	83 ec 24             	sub    $0x24,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
    1389:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
    1390:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
    1394:	74 17                	je     13ad <printint+0x2b>
    1396:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
    139a:	79 11                	jns    13ad <printint+0x2b>
    neg = 1;
    139c:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
    13a3:	8b 45 0c             	mov    0xc(%ebp),%eax
    13a6:	f7 d8                	neg    %eax
    13a8:	89 45 ec             	mov    %eax,-0x14(%ebp)
    13ab:	eb 06                	jmp    13b3 <printint+0x31>
  } else {
    x = xx;
    13ad:	8b 45 0c             	mov    0xc(%ebp),%eax
    13b0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
    13b3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
    13ba:	8b 4d f4             	mov    -0xc(%ebp),%ecx
    13bd:	8d 41 01             	lea    0x1(%ecx),%eax
    13c0:	89 45 f4             	mov    %eax,-0xc(%ebp)
    13c3:	8b 5d 10             	mov    0x10(%ebp),%ebx
    13c6:	8b 45 ec             	mov    -0x14(%ebp),%eax
    13c9:	ba 00 00 00 00       	mov    $0x0,%edx
    13ce:	f7 f3                	div    %ebx
    13d0:	89 d0                	mov    %edx,%eax
    13d2:	0f b6 80 0c 1b 00 00 	movzbl 0x1b0c(%eax),%eax
    13d9:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
    13dd:	8b 5d 10             	mov    0x10(%ebp),%ebx
    13e0:	8b 45 ec             	mov    -0x14(%ebp),%eax
    13e3:	ba 00 00 00 00       	mov    $0x0,%edx
    13e8:	f7 f3                	div    %ebx
    13ea:	89 45 ec             	mov    %eax,-0x14(%ebp)
    13ed:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    13f1:	75 c7                	jne    13ba <printint+0x38>
  if(neg)
    13f3:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    13f7:	74 2d                	je     1426 <printint+0xa4>
    buf[i++] = '-';
    13f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
    13fc:	8d 50 01             	lea    0x1(%eax),%edx
    13ff:	89 55 f4             	mov    %edx,-0xc(%ebp)
    1402:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
    1407:	eb 1d                	jmp    1426 <printint+0xa4>
    putc(fd, buf[i]);
    1409:	8d 55 dc             	lea    -0x24(%ebp),%edx
    140c:	8b 45 f4             	mov    -0xc(%ebp),%eax
    140f:	01 d0                	add    %edx,%eax
    1411:	0f b6 00             	movzbl (%eax),%eax
    1414:	0f be c0             	movsbl %al,%eax
    1417:	83 ec 08             	sub    $0x8,%esp
    141a:	50                   	push   %eax
    141b:	ff 75 08             	pushl  0x8(%ebp)
    141e:	e8 3c ff ff ff       	call   135f <putc>
    1423:	83 c4 10             	add    $0x10,%esp
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
    1426:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
    142a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    142e:	79 d9                	jns    1409 <printint+0x87>
    putc(fd, buf[i]);
}
    1430:	90                   	nop
    1431:	8b 5d fc             	mov    -0x4(%ebp),%ebx
    1434:	c9                   	leave  
    1435:	c3                   	ret    

00001436 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
    1436:	55                   	push   %ebp
    1437:	89 e5                	mov    %esp,%ebp
    1439:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
    143c:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
    1443:	8d 45 0c             	lea    0xc(%ebp),%eax
    1446:	83 c0 04             	add    $0x4,%eax
    1449:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
    144c:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    1453:	e9 59 01 00 00       	jmp    15b1 <printf+0x17b>
    c = fmt[i] & 0xff;
    1458:	8b 55 0c             	mov    0xc(%ebp),%edx
    145b:	8b 45 f0             	mov    -0x10(%ebp),%eax
    145e:	01 d0                	add    %edx,%eax
    1460:	0f b6 00             	movzbl (%eax),%eax
    1463:	0f be c0             	movsbl %al,%eax
    1466:	25 ff 00 00 00       	and    $0xff,%eax
    146b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
    146e:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    1472:	75 2c                	jne    14a0 <printf+0x6a>
      if(c == '%'){
    1474:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
    1478:	75 0c                	jne    1486 <printf+0x50>
        state = '%';
    147a:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
    1481:	e9 27 01 00 00       	jmp    15ad <printf+0x177>
      } else {
        putc(fd, c);
    1486:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    1489:	0f be c0             	movsbl %al,%eax
    148c:	83 ec 08             	sub    $0x8,%esp
    148f:	50                   	push   %eax
    1490:	ff 75 08             	pushl  0x8(%ebp)
    1493:	e8 c7 fe ff ff       	call   135f <putc>
    1498:	83 c4 10             	add    $0x10,%esp
    149b:	e9 0d 01 00 00       	jmp    15ad <printf+0x177>
      }
    } else if(state == '%'){
    14a0:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
    14a4:	0f 85 03 01 00 00    	jne    15ad <printf+0x177>
      if(c == 'd'){
    14aa:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
    14ae:	75 1e                	jne    14ce <printf+0x98>
        printint(fd, *ap, 10, 1);
    14b0:	8b 45 e8             	mov    -0x18(%ebp),%eax
    14b3:	8b 00                	mov    (%eax),%eax
    14b5:	6a 01                	push   $0x1
    14b7:	6a 0a                	push   $0xa
    14b9:	50                   	push   %eax
    14ba:	ff 75 08             	pushl  0x8(%ebp)
    14bd:	e8 c0 fe ff ff       	call   1382 <printint>
    14c2:	83 c4 10             	add    $0x10,%esp
        ap++;
    14c5:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
    14c9:	e9 d8 00 00 00       	jmp    15a6 <printf+0x170>
      } else if(c == 'x' || c == 'p'){
    14ce:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
    14d2:	74 06                	je     14da <printf+0xa4>
    14d4:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
    14d8:	75 1e                	jne    14f8 <printf+0xc2>
        printint(fd, *ap, 16, 0);
    14da:	8b 45 e8             	mov    -0x18(%ebp),%eax
    14dd:	8b 00                	mov    (%eax),%eax
    14df:	6a 00                	push   $0x0
    14e1:	6a 10                	push   $0x10
    14e3:	50                   	push   %eax
    14e4:	ff 75 08             	pushl  0x8(%ebp)
    14e7:	e8 96 fe ff ff       	call   1382 <printint>
    14ec:	83 c4 10             	add    $0x10,%esp
        ap++;
    14ef:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
    14f3:	e9 ae 00 00 00       	jmp    15a6 <printf+0x170>
      } else if(c == 's'){
    14f8:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
    14fc:	75 43                	jne    1541 <printf+0x10b>
        s = (char*)*ap;
    14fe:	8b 45 e8             	mov    -0x18(%ebp),%eax
    1501:	8b 00                	mov    (%eax),%eax
    1503:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
    1506:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
    150a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    150e:	75 25                	jne    1535 <printf+0xff>
          s = "(null)";
    1510:	c7 45 f4 3b 18 00 00 	movl   $0x183b,-0xc(%ebp)
        while(*s != 0){
    1517:	eb 1c                	jmp    1535 <printf+0xff>
          putc(fd, *s);
    1519:	8b 45 f4             	mov    -0xc(%ebp),%eax
    151c:	0f b6 00             	movzbl (%eax),%eax
    151f:	0f be c0             	movsbl %al,%eax
    1522:	83 ec 08             	sub    $0x8,%esp
    1525:	50                   	push   %eax
    1526:	ff 75 08             	pushl  0x8(%ebp)
    1529:	e8 31 fe ff ff       	call   135f <putc>
    152e:	83 c4 10             	add    $0x10,%esp
          s++;
    1531:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
    1535:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1538:	0f b6 00             	movzbl (%eax),%eax
    153b:	84 c0                	test   %al,%al
    153d:	75 da                	jne    1519 <printf+0xe3>
    153f:	eb 65                	jmp    15a6 <printf+0x170>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
    1541:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
    1545:	75 1d                	jne    1564 <printf+0x12e>
        putc(fd, *ap);
    1547:	8b 45 e8             	mov    -0x18(%ebp),%eax
    154a:	8b 00                	mov    (%eax),%eax
    154c:	0f be c0             	movsbl %al,%eax
    154f:	83 ec 08             	sub    $0x8,%esp
    1552:	50                   	push   %eax
    1553:	ff 75 08             	pushl  0x8(%ebp)
    1556:	e8 04 fe ff ff       	call   135f <putc>
    155b:	83 c4 10             	add    $0x10,%esp
        ap++;
    155e:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
    1562:	eb 42                	jmp    15a6 <printf+0x170>
      } else if(c == '%'){
    1564:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
    1568:	75 17                	jne    1581 <printf+0x14b>
        putc(fd, c);
    156a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    156d:	0f be c0             	movsbl %al,%eax
    1570:	83 ec 08             	sub    $0x8,%esp
    1573:	50                   	push   %eax
    1574:	ff 75 08             	pushl  0x8(%ebp)
    1577:	e8 e3 fd ff ff       	call   135f <putc>
    157c:	83 c4 10             	add    $0x10,%esp
    157f:	eb 25                	jmp    15a6 <printf+0x170>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
    1581:	83 ec 08             	sub    $0x8,%esp
    1584:	6a 25                	push   $0x25
    1586:	ff 75 08             	pushl  0x8(%ebp)
    1589:	e8 d1 fd ff ff       	call   135f <putc>
    158e:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
    1591:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    1594:	0f be c0             	movsbl %al,%eax
    1597:	83 ec 08             	sub    $0x8,%esp
    159a:	50                   	push   %eax
    159b:	ff 75 08             	pushl  0x8(%ebp)
    159e:	e8 bc fd ff ff       	call   135f <putc>
    15a3:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
    15a6:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
    15ad:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
    15b1:	8b 55 0c             	mov    0xc(%ebp),%edx
    15b4:	8b 45 f0             	mov    -0x10(%ebp),%eax
    15b7:	01 d0                	add    %edx,%eax
    15b9:	0f b6 00             	movzbl (%eax),%eax
    15bc:	84 c0                	test   %al,%al
    15be:	0f 85 94 fe ff ff    	jne    1458 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
    15c4:	90                   	nop
    15c5:	c9                   	leave  
    15c6:	c3                   	ret    

000015c7 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
    15c7:	55                   	push   %ebp
    15c8:	89 e5                	mov    %esp,%ebp
    15ca:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
    15cd:	8b 45 08             	mov    0x8(%ebp),%eax
    15d0:	83 e8 08             	sub    $0x8,%eax
    15d3:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    15d6:	a1 28 1b 00 00       	mov    0x1b28,%eax
    15db:	89 45 fc             	mov    %eax,-0x4(%ebp)
    15de:	eb 24                	jmp    1604 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    15e0:	8b 45 fc             	mov    -0x4(%ebp),%eax
    15e3:	8b 00                	mov    (%eax),%eax
    15e5:	3b 45 fc             	cmp    -0x4(%ebp),%eax
    15e8:	77 12                	ja     15fc <free+0x35>
    15ea:	8b 45 f8             	mov    -0x8(%ebp),%eax
    15ed:	3b 45 fc             	cmp    -0x4(%ebp),%eax
    15f0:	77 24                	ja     1616 <free+0x4f>
    15f2:	8b 45 fc             	mov    -0x4(%ebp),%eax
    15f5:	8b 00                	mov    (%eax),%eax
    15f7:	3b 45 f8             	cmp    -0x8(%ebp),%eax
    15fa:	77 1a                	ja     1616 <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    15fc:	8b 45 fc             	mov    -0x4(%ebp),%eax
    15ff:	8b 00                	mov    (%eax),%eax
    1601:	89 45 fc             	mov    %eax,-0x4(%ebp)
    1604:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1607:	3b 45 fc             	cmp    -0x4(%ebp),%eax
    160a:	76 d4                	jbe    15e0 <free+0x19>
    160c:	8b 45 fc             	mov    -0x4(%ebp),%eax
    160f:	8b 00                	mov    (%eax),%eax
    1611:	3b 45 f8             	cmp    -0x8(%ebp),%eax
    1614:	76 ca                	jbe    15e0 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    1616:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1619:	8b 40 04             	mov    0x4(%eax),%eax
    161c:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
    1623:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1626:	01 c2                	add    %eax,%edx
    1628:	8b 45 fc             	mov    -0x4(%ebp),%eax
    162b:	8b 00                	mov    (%eax),%eax
    162d:	39 c2                	cmp    %eax,%edx
    162f:	75 24                	jne    1655 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
    1631:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1634:	8b 50 04             	mov    0x4(%eax),%edx
    1637:	8b 45 fc             	mov    -0x4(%ebp),%eax
    163a:	8b 00                	mov    (%eax),%eax
    163c:	8b 40 04             	mov    0x4(%eax),%eax
    163f:	01 c2                	add    %eax,%edx
    1641:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1644:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
    1647:	8b 45 fc             	mov    -0x4(%ebp),%eax
    164a:	8b 00                	mov    (%eax),%eax
    164c:	8b 10                	mov    (%eax),%edx
    164e:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1651:	89 10                	mov    %edx,(%eax)
    1653:	eb 0a                	jmp    165f <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
    1655:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1658:	8b 10                	mov    (%eax),%edx
    165a:	8b 45 f8             	mov    -0x8(%ebp),%eax
    165d:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
    165f:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1662:	8b 40 04             	mov    0x4(%eax),%eax
    1665:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
    166c:	8b 45 fc             	mov    -0x4(%ebp),%eax
    166f:	01 d0                	add    %edx,%eax
    1671:	3b 45 f8             	cmp    -0x8(%ebp),%eax
    1674:	75 20                	jne    1696 <free+0xcf>
    p->s.size += bp->s.size;
    1676:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1679:	8b 50 04             	mov    0x4(%eax),%edx
    167c:	8b 45 f8             	mov    -0x8(%ebp),%eax
    167f:	8b 40 04             	mov    0x4(%eax),%eax
    1682:	01 c2                	add    %eax,%edx
    1684:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1687:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
    168a:	8b 45 f8             	mov    -0x8(%ebp),%eax
    168d:	8b 10                	mov    (%eax),%edx
    168f:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1692:	89 10                	mov    %edx,(%eax)
    1694:	eb 08                	jmp    169e <free+0xd7>
  } else
    p->s.ptr = bp;
    1696:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1699:	8b 55 f8             	mov    -0x8(%ebp),%edx
    169c:	89 10                	mov    %edx,(%eax)
  freep = p;
    169e:	8b 45 fc             	mov    -0x4(%ebp),%eax
    16a1:	a3 28 1b 00 00       	mov    %eax,0x1b28
}
    16a6:	90                   	nop
    16a7:	c9                   	leave  
    16a8:	c3                   	ret    

000016a9 <morecore>:

static Header*
morecore(uint nu)
{
    16a9:	55                   	push   %ebp
    16aa:	89 e5                	mov    %esp,%ebp
    16ac:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
    16af:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
    16b6:	77 07                	ja     16bf <morecore+0x16>
    nu = 4096;
    16b8:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
    16bf:	8b 45 08             	mov    0x8(%ebp),%eax
    16c2:	c1 e0 03             	shl    $0x3,%eax
    16c5:	83 ec 0c             	sub    $0xc,%esp
    16c8:	50                   	push   %eax
    16c9:	e8 69 fc ff ff       	call   1337 <sbrk>
    16ce:	83 c4 10             	add    $0x10,%esp
    16d1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
    16d4:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
    16d8:	75 07                	jne    16e1 <morecore+0x38>
    return 0;
    16da:	b8 00 00 00 00       	mov    $0x0,%eax
    16df:	eb 26                	jmp    1707 <morecore+0x5e>
  hp = (Header*)p;
    16e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
    16e4:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
    16e7:	8b 45 f0             	mov    -0x10(%ebp),%eax
    16ea:	8b 55 08             	mov    0x8(%ebp),%edx
    16ed:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
    16f0:	8b 45 f0             	mov    -0x10(%ebp),%eax
    16f3:	83 c0 08             	add    $0x8,%eax
    16f6:	83 ec 0c             	sub    $0xc,%esp
    16f9:	50                   	push   %eax
    16fa:	e8 c8 fe ff ff       	call   15c7 <free>
    16ff:	83 c4 10             	add    $0x10,%esp
  return freep;
    1702:	a1 28 1b 00 00       	mov    0x1b28,%eax
}
    1707:	c9                   	leave  
    1708:	c3                   	ret    

00001709 <malloc>:

void*
malloc(uint nbytes)
{
    1709:	55                   	push   %ebp
    170a:	89 e5                	mov    %esp,%ebp
    170c:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
    170f:	8b 45 08             	mov    0x8(%ebp),%eax
    1712:	83 c0 07             	add    $0x7,%eax
    1715:	c1 e8 03             	shr    $0x3,%eax
    1718:	83 c0 01             	add    $0x1,%eax
    171b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
    171e:	a1 28 1b 00 00       	mov    0x1b28,%eax
    1723:	89 45 f0             	mov    %eax,-0x10(%ebp)
    1726:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    172a:	75 23                	jne    174f <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
    172c:	c7 45 f0 20 1b 00 00 	movl   $0x1b20,-0x10(%ebp)
    1733:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1736:	a3 28 1b 00 00       	mov    %eax,0x1b28
    173b:	a1 28 1b 00 00       	mov    0x1b28,%eax
    1740:	a3 20 1b 00 00       	mov    %eax,0x1b20
    base.s.size = 0;
    1745:	c7 05 24 1b 00 00 00 	movl   $0x0,0x1b24
    174c:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    174f:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1752:	8b 00                	mov    (%eax),%eax
    1754:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
    1757:	8b 45 f4             	mov    -0xc(%ebp),%eax
    175a:	8b 40 04             	mov    0x4(%eax),%eax
    175d:	3b 45 ec             	cmp    -0x14(%ebp),%eax
    1760:	72 4d                	jb     17af <malloc+0xa6>
      if(p->s.size == nunits)
    1762:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1765:	8b 40 04             	mov    0x4(%eax),%eax
    1768:	3b 45 ec             	cmp    -0x14(%ebp),%eax
    176b:	75 0c                	jne    1779 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
    176d:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1770:	8b 10                	mov    (%eax),%edx
    1772:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1775:	89 10                	mov    %edx,(%eax)
    1777:	eb 26                	jmp    179f <malloc+0x96>
      else {
        p->s.size -= nunits;
    1779:	8b 45 f4             	mov    -0xc(%ebp),%eax
    177c:	8b 40 04             	mov    0x4(%eax),%eax
    177f:	2b 45 ec             	sub    -0x14(%ebp),%eax
    1782:	89 c2                	mov    %eax,%edx
    1784:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1787:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
    178a:	8b 45 f4             	mov    -0xc(%ebp),%eax
    178d:	8b 40 04             	mov    0x4(%eax),%eax
    1790:	c1 e0 03             	shl    $0x3,%eax
    1793:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
    1796:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1799:	8b 55 ec             	mov    -0x14(%ebp),%edx
    179c:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
    179f:	8b 45 f0             	mov    -0x10(%ebp),%eax
    17a2:	a3 28 1b 00 00       	mov    %eax,0x1b28
      return (void*)(p + 1);
    17a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
    17aa:	83 c0 08             	add    $0x8,%eax
    17ad:	eb 3b                	jmp    17ea <malloc+0xe1>
    }
    if(p == freep)
    17af:	a1 28 1b 00 00       	mov    0x1b28,%eax
    17b4:	39 45 f4             	cmp    %eax,-0xc(%ebp)
    17b7:	75 1e                	jne    17d7 <malloc+0xce>
      if((p = morecore(nunits)) == 0)
    17b9:	83 ec 0c             	sub    $0xc,%esp
    17bc:	ff 75 ec             	pushl  -0x14(%ebp)
    17bf:	e8 e5 fe ff ff       	call   16a9 <morecore>
    17c4:	83 c4 10             	add    $0x10,%esp
    17c7:	89 45 f4             	mov    %eax,-0xc(%ebp)
    17ca:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    17ce:	75 07                	jne    17d7 <malloc+0xce>
        return 0;
    17d0:	b8 00 00 00 00       	mov    $0x0,%eax
    17d5:	eb 13                	jmp    17ea <malloc+0xe1>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    17d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
    17da:	89 45 f0             	mov    %eax,-0x10(%ebp)
    17dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
    17e0:	8b 00                	mov    (%eax),%eax
    17e2:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
    17e5:	e9 6d ff ff ff       	jmp    1757 <malloc+0x4e>
}
    17ea:	c9                   	leave  
    17eb:	c3                   	ret    

000017ec <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
    17ec:	55                   	push   %ebp
    17ed:	89 e5                	mov    %esp,%ebp
    17ef:	83 ec 10             	sub    $0x10,%esp
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
    17f2:	8b 55 08             	mov    0x8(%ebp),%edx
    17f5:	8b 45 0c             	mov    0xc(%ebp),%eax
    17f8:	8b 4d 08             	mov    0x8(%ebp),%ecx
    17fb:	f0 87 02             	lock xchg %eax,(%edx)
    17fe:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
    1801:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
    1804:	c9                   	leave  
    1805:	c3                   	ret    

00001806 <uacquire>:
#include "uspinlock.h"
#include "x86.h"

void
uacquire(struct uspinlock *lk)
{
    1806:	55                   	push   %ebp
    1807:	89 e5                	mov    %esp,%ebp
  // The xchg is atomic.
  while(xchg(&lk->locked, 1) != 0)
    1809:	90                   	nop
    180a:	8b 45 08             	mov    0x8(%ebp),%eax
    180d:	6a 01                	push   $0x1
    180f:	50                   	push   %eax
    1810:	e8 d7 ff ff ff       	call   17ec <xchg>
    1815:	83 c4 08             	add    $0x8,%esp
    1818:	85 c0                	test   %eax,%eax
    181a:	75 ee                	jne    180a <uacquire+0x4>
    ;

  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that the critical section's memory
  // references happen after the lock is acquired.
  __sync_synchronize();
    181c:	f0 83 0c 24 00       	lock orl $0x0,(%esp)
}
    1821:	90                   	nop
    1822:	c9                   	leave  
    1823:	c3                   	ret    

00001824 <urelease>:

void urelease (struct uspinlock *lk) {
    1824:	55                   	push   %ebp
    1825:	89 e5                	mov    %esp,%ebp
  __sync_synchronize();
    1827:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Release the lock, equivalent to lk->locked = 0.
  // This code can't use a C assignment, since it might
  // not be atomic. A real OS would use C atomics here.
  asm volatile("movl $0, %0" : "+m" (lk->locked) : );
    182c:	8b 45 08             	mov    0x8(%ebp),%eax
    182f:	8b 55 08             	mov    0x8(%ebp),%edx
    1832:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
}
    1838:	90                   	nop
    1839:	5d                   	pop    %ebp
    183a:	c3                   	ret    
