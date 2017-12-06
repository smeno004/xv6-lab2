
_test:     file format elf32-i386


Disassembly of section .text:

00001000 <testFunc>:
#include "types.h"
#include "user.h"
#include "memlayout.h"
void testFunc(int n)
{
    1000:	55                   	push   %ebp
    1001:	89 e5                	mov    %esp,%ebp
    1003:	83 ec 28             	sub    $0x28,%esp
  int a = n;
    1006:	8b 45 08             	mov    0x8(%ebp),%eax
    1009:	89 45 f4             	mov    %eax,-0xc(%ebp)
  int b = 1;
    100c:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
  float c = 2;
    1013:	d9 05 70 18 00 00    	flds   0x1870
    1019:	d9 5d ec             	fstps  -0x14(%ebp)
  char d = '3';
    101c:	c6 45 eb 33          	movb   $0x33,-0x15(%ebp)
  int e = 3;
    1020:	c7 45 e4 03 00 00 00 	movl   $0x3,-0x1c(%ebp)

  a += 1;
    1027:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  b += 2;
    102b:	83 45 f0 02          	addl   $0x2,-0x10(%ebp)
  c += 3;
    102f:	d9 45 ec             	flds   -0x14(%ebp)
    1032:	d9 05 74 18 00 00    	flds   0x1874
    1038:	de c1                	faddp  %st,%st(1)
    103a:	d9 5d ec             	fstps  -0x14(%ebp)
  e += 4;
    103d:	83 45 e4 04          	addl   $0x4,-0x1c(%ebp)
  d += 1;
    1041:	0f b6 45 eb          	movzbl -0x15(%ebp),%eax
    1045:	83 c0 01             	add    $0x1,%eax
    1048:	88 45 eb             	mov    %al,-0x15(%ebp)

  //printf(1, "hellow world: %d\n", n);
  if (a >= 100000) {
    104b:	81 7d f4 9f 86 01 00 	cmpl   $0x1869f,-0xc(%ebp)
    1052:	7f 10                	jg     1064 <testFunc+0x64>
    return;
  }
  testFunc(a);
    1054:	83 ec 0c             	sub    $0xc,%esp
    1057:	ff 75 f4             	pushl  -0xc(%ebp)
    105a:	e8 a1 ff ff ff       	call   1000 <testFunc>
    105f:	83 c4 10             	add    $0x10,%esp
    1062:	eb 01                	jmp    1065 <testFunc+0x65>
  e += 4;
  d += 1;

  //printf(1, "hellow world: %d\n", n);
  if (a >= 100000) {
    return;
    1064:	90                   	nop
  }
  testFunc(a);

}
    1065:	c9                   	leave  
    1066:	c3                   	ret    

00001067 <main>:

int main()
{
    1067:	8d 4c 24 04          	lea    0x4(%esp),%ecx
    106b:	83 e4 f0             	and    $0xfffffff0,%esp
    106e:	ff 71 fc             	pushl  -0x4(%ecx)
    1071:	55                   	push   %ebp
    1072:	89 e5                	mov    %esp,%ebp
    1074:	51                   	push   %ecx
    1075:	83 ec 04             	sub    $0x4,%esp
  testFunc(1);
    1078:	83 ec 0c             	sub    $0xc,%esp
    107b:	6a 01                	push   $0x1
    107d:	e8 7e ff ff ff       	call   1000 <testFunc>
    1082:	83 c4 10             	add    $0x10,%esp
  exit();
    1085:	e8 57 02 00 00       	call   12e1 <exit>

0000108a <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
    108a:	55                   	push   %ebp
    108b:	89 e5                	mov    %esp,%ebp
    108d:	57                   	push   %edi
    108e:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
    108f:	8b 4d 08             	mov    0x8(%ebp),%ecx
    1092:	8b 55 10             	mov    0x10(%ebp),%edx
    1095:	8b 45 0c             	mov    0xc(%ebp),%eax
    1098:	89 cb                	mov    %ecx,%ebx
    109a:	89 df                	mov    %ebx,%edi
    109c:	89 d1                	mov    %edx,%ecx
    109e:	fc                   	cld    
    109f:	f3 aa                	rep stos %al,%es:(%edi)
    10a1:	89 ca                	mov    %ecx,%edx
    10a3:	89 fb                	mov    %edi,%ebx
    10a5:	89 5d 08             	mov    %ebx,0x8(%ebp)
    10a8:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
    10ab:	90                   	nop
    10ac:	5b                   	pop    %ebx
    10ad:	5f                   	pop    %edi
    10ae:	5d                   	pop    %ebp
    10af:	c3                   	ret    

000010b0 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
    10b0:	55                   	push   %ebp
    10b1:	89 e5                	mov    %esp,%ebp
    10b3:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
    10b6:	8b 45 08             	mov    0x8(%ebp),%eax
    10b9:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
    10bc:	90                   	nop
    10bd:	8b 45 08             	mov    0x8(%ebp),%eax
    10c0:	8d 50 01             	lea    0x1(%eax),%edx
    10c3:	89 55 08             	mov    %edx,0x8(%ebp)
    10c6:	8b 55 0c             	mov    0xc(%ebp),%edx
    10c9:	8d 4a 01             	lea    0x1(%edx),%ecx
    10cc:	89 4d 0c             	mov    %ecx,0xc(%ebp)
    10cf:	0f b6 12             	movzbl (%edx),%edx
    10d2:	88 10                	mov    %dl,(%eax)
    10d4:	0f b6 00             	movzbl (%eax),%eax
    10d7:	84 c0                	test   %al,%al
    10d9:	75 e2                	jne    10bd <strcpy+0xd>
    ;
  return os;
    10db:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
    10de:	c9                   	leave  
    10df:	c3                   	ret    

000010e0 <strcmp>:

int
strcmp(const char *p, const char *q)
{
    10e0:	55                   	push   %ebp
    10e1:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
    10e3:	eb 08                	jmp    10ed <strcmp+0xd>
    p++, q++;
    10e5:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    10e9:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
    10ed:	8b 45 08             	mov    0x8(%ebp),%eax
    10f0:	0f b6 00             	movzbl (%eax),%eax
    10f3:	84 c0                	test   %al,%al
    10f5:	74 10                	je     1107 <strcmp+0x27>
    10f7:	8b 45 08             	mov    0x8(%ebp),%eax
    10fa:	0f b6 10             	movzbl (%eax),%edx
    10fd:	8b 45 0c             	mov    0xc(%ebp),%eax
    1100:	0f b6 00             	movzbl (%eax),%eax
    1103:	38 c2                	cmp    %al,%dl
    1105:	74 de                	je     10e5 <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
    1107:	8b 45 08             	mov    0x8(%ebp),%eax
    110a:	0f b6 00             	movzbl (%eax),%eax
    110d:	0f b6 d0             	movzbl %al,%edx
    1110:	8b 45 0c             	mov    0xc(%ebp),%eax
    1113:	0f b6 00             	movzbl (%eax),%eax
    1116:	0f b6 c0             	movzbl %al,%eax
    1119:	29 c2                	sub    %eax,%edx
    111b:	89 d0                	mov    %edx,%eax
}
    111d:	5d                   	pop    %ebp
    111e:	c3                   	ret    

0000111f <strlen>:

uint
strlen(char *s)
{
    111f:	55                   	push   %ebp
    1120:	89 e5                	mov    %esp,%ebp
    1122:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
    1125:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    112c:	eb 04                	jmp    1132 <strlen+0x13>
    112e:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
    1132:	8b 55 fc             	mov    -0x4(%ebp),%edx
    1135:	8b 45 08             	mov    0x8(%ebp),%eax
    1138:	01 d0                	add    %edx,%eax
    113a:	0f b6 00             	movzbl (%eax),%eax
    113d:	84 c0                	test   %al,%al
    113f:	75 ed                	jne    112e <strlen+0xf>
    ;
  return n;
    1141:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
    1144:	c9                   	leave  
    1145:	c3                   	ret    

00001146 <memset>:

void*
memset(void *dst, int c, uint n)
{
    1146:	55                   	push   %ebp
    1147:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
    1149:	8b 45 10             	mov    0x10(%ebp),%eax
    114c:	50                   	push   %eax
    114d:	ff 75 0c             	pushl  0xc(%ebp)
    1150:	ff 75 08             	pushl  0x8(%ebp)
    1153:	e8 32 ff ff ff       	call   108a <stosb>
    1158:	83 c4 0c             	add    $0xc,%esp
  return dst;
    115b:	8b 45 08             	mov    0x8(%ebp),%eax
}
    115e:	c9                   	leave  
    115f:	c3                   	ret    

00001160 <strchr>:

char*
strchr(const char *s, char c)
{
    1160:	55                   	push   %ebp
    1161:	89 e5                	mov    %esp,%ebp
    1163:	83 ec 04             	sub    $0x4,%esp
    1166:	8b 45 0c             	mov    0xc(%ebp),%eax
    1169:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
    116c:	eb 14                	jmp    1182 <strchr+0x22>
    if(*s == c)
    116e:	8b 45 08             	mov    0x8(%ebp),%eax
    1171:	0f b6 00             	movzbl (%eax),%eax
    1174:	3a 45 fc             	cmp    -0x4(%ebp),%al
    1177:	75 05                	jne    117e <strchr+0x1e>
      return (char*)s;
    1179:	8b 45 08             	mov    0x8(%ebp),%eax
    117c:	eb 13                	jmp    1191 <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
    117e:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    1182:	8b 45 08             	mov    0x8(%ebp),%eax
    1185:	0f b6 00             	movzbl (%eax),%eax
    1188:	84 c0                	test   %al,%al
    118a:	75 e2                	jne    116e <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
    118c:	b8 00 00 00 00       	mov    $0x0,%eax
}
    1191:	c9                   	leave  
    1192:	c3                   	ret    

00001193 <gets>:

char*
gets(char *buf, int max)
{
    1193:	55                   	push   %ebp
    1194:	89 e5                	mov    %esp,%ebp
    1196:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
    1199:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    11a0:	eb 42                	jmp    11e4 <gets+0x51>
    cc = read(0, &c, 1);
    11a2:	83 ec 04             	sub    $0x4,%esp
    11a5:	6a 01                	push   $0x1
    11a7:	8d 45 ef             	lea    -0x11(%ebp),%eax
    11aa:	50                   	push   %eax
    11ab:	6a 00                	push   $0x0
    11ad:	e8 47 01 00 00       	call   12f9 <read>
    11b2:	83 c4 10             	add    $0x10,%esp
    11b5:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
    11b8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    11bc:	7e 33                	jle    11f1 <gets+0x5e>
      break;
    buf[i++] = c;
    11be:	8b 45 f4             	mov    -0xc(%ebp),%eax
    11c1:	8d 50 01             	lea    0x1(%eax),%edx
    11c4:	89 55 f4             	mov    %edx,-0xc(%ebp)
    11c7:	89 c2                	mov    %eax,%edx
    11c9:	8b 45 08             	mov    0x8(%ebp),%eax
    11cc:	01 c2                	add    %eax,%edx
    11ce:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    11d2:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
    11d4:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    11d8:	3c 0a                	cmp    $0xa,%al
    11da:	74 16                	je     11f2 <gets+0x5f>
    11dc:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    11e0:	3c 0d                	cmp    $0xd,%al
    11e2:	74 0e                	je     11f2 <gets+0x5f>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
    11e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
    11e7:	83 c0 01             	add    $0x1,%eax
    11ea:	3b 45 0c             	cmp    0xc(%ebp),%eax
    11ed:	7c b3                	jl     11a2 <gets+0xf>
    11ef:	eb 01                	jmp    11f2 <gets+0x5f>
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    11f1:	90                   	nop
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
    11f2:	8b 55 f4             	mov    -0xc(%ebp),%edx
    11f5:	8b 45 08             	mov    0x8(%ebp),%eax
    11f8:	01 d0                	add    %edx,%eax
    11fa:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
    11fd:	8b 45 08             	mov    0x8(%ebp),%eax
}
    1200:	c9                   	leave  
    1201:	c3                   	ret    

00001202 <stat>:

int
stat(char *n, struct stat *st)
{
    1202:	55                   	push   %ebp
    1203:	89 e5                	mov    %esp,%ebp
    1205:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
    1208:	83 ec 08             	sub    $0x8,%esp
    120b:	6a 00                	push   $0x0
    120d:	ff 75 08             	pushl  0x8(%ebp)
    1210:	e8 0c 01 00 00       	call   1321 <open>
    1215:	83 c4 10             	add    $0x10,%esp
    1218:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
    121b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    121f:	79 07                	jns    1228 <stat+0x26>
    return -1;
    1221:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
    1226:	eb 25                	jmp    124d <stat+0x4b>
  r = fstat(fd, st);
    1228:	83 ec 08             	sub    $0x8,%esp
    122b:	ff 75 0c             	pushl  0xc(%ebp)
    122e:	ff 75 f4             	pushl  -0xc(%ebp)
    1231:	e8 03 01 00 00       	call   1339 <fstat>
    1236:	83 c4 10             	add    $0x10,%esp
    1239:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
    123c:	83 ec 0c             	sub    $0xc,%esp
    123f:	ff 75 f4             	pushl  -0xc(%ebp)
    1242:	e8 c2 00 00 00       	call   1309 <close>
    1247:	83 c4 10             	add    $0x10,%esp
  return r;
    124a:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
    124d:	c9                   	leave  
    124e:	c3                   	ret    

0000124f <atoi>:

int
atoi(const char *s)
{
    124f:	55                   	push   %ebp
    1250:	89 e5                	mov    %esp,%ebp
    1252:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
    1255:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
    125c:	eb 25                	jmp    1283 <atoi+0x34>
    n = n*10 + *s++ - '0';
    125e:	8b 55 fc             	mov    -0x4(%ebp),%edx
    1261:	89 d0                	mov    %edx,%eax
    1263:	c1 e0 02             	shl    $0x2,%eax
    1266:	01 d0                	add    %edx,%eax
    1268:	01 c0                	add    %eax,%eax
    126a:	89 c1                	mov    %eax,%ecx
    126c:	8b 45 08             	mov    0x8(%ebp),%eax
    126f:	8d 50 01             	lea    0x1(%eax),%edx
    1272:	89 55 08             	mov    %edx,0x8(%ebp)
    1275:	0f b6 00             	movzbl (%eax),%eax
    1278:	0f be c0             	movsbl %al,%eax
    127b:	01 c8                	add    %ecx,%eax
    127d:	83 e8 30             	sub    $0x30,%eax
    1280:	89 45 fc             	mov    %eax,-0x4(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
    1283:	8b 45 08             	mov    0x8(%ebp),%eax
    1286:	0f b6 00             	movzbl (%eax),%eax
    1289:	3c 2f                	cmp    $0x2f,%al
    128b:	7e 0a                	jle    1297 <atoi+0x48>
    128d:	8b 45 08             	mov    0x8(%ebp),%eax
    1290:	0f b6 00             	movzbl (%eax),%eax
    1293:	3c 39                	cmp    $0x39,%al
    1295:	7e c7                	jle    125e <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
    1297:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
    129a:	c9                   	leave  
    129b:	c3                   	ret    

0000129c <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
    129c:	55                   	push   %ebp
    129d:	89 e5                	mov    %esp,%ebp
    129f:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;

  dst = vdst;
    12a2:	8b 45 08             	mov    0x8(%ebp),%eax
    12a5:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
    12a8:	8b 45 0c             	mov    0xc(%ebp),%eax
    12ab:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
    12ae:	eb 17                	jmp    12c7 <memmove+0x2b>
    *dst++ = *src++;
    12b0:	8b 45 fc             	mov    -0x4(%ebp),%eax
    12b3:	8d 50 01             	lea    0x1(%eax),%edx
    12b6:	89 55 fc             	mov    %edx,-0x4(%ebp)
    12b9:	8b 55 f8             	mov    -0x8(%ebp),%edx
    12bc:	8d 4a 01             	lea    0x1(%edx),%ecx
    12bf:	89 4d f8             	mov    %ecx,-0x8(%ebp)
    12c2:	0f b6 12             	movzbl (%edx),%edx
    12c5:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;

  dst = vdst;
  src = vsrc;
  while(n-- > 0)
    12c7:	8b 45 10             	mov    0x10(%ebp),%eax
    12ca:	8d 50 ff             	lea    -0x1(%eax),%edx
    12cd:	89 55 10             	mov    %edx,0x10(%ebp)
    12d0:	85 c0                	test   %eax,%eax
    12d2:	7f dc                	jg     12b0 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
    12d4:	8b 45 08             	mov    0x8(%ebp),%eax
}
    12d7:	c9                   	leave  
    12d8:	c3                   	ret    

000012d9 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
    12d9:	b8 01 00 00 00       	mov    $0x1,%eax
    12de:	cd 40                	int    $0x40
    12e0:	c3                   	ret    

000012e1 <exit>:
SYSCALL(exit)
    12e1:	b8 02 00 00 00       	mov    $0x2,%eax
    12e6:	cd 40                	int    $0x40
    12e8:	c3                   	ret    

000012e9 <wait>:
SYSCALL(wait)
    12e9:	b8 03 00 00 00       	mov    $0x3,%eax
    12ee:	cd 40                	int    $0x40
    12f0:	c3                   	ret    

000012f1 <pipe>:
SYSCALL(pipe)
    12f1:	b8 04 00 00 00       	mov    $0x4,%eax
    12f6:	cd 40                	int    $0x40
    12f8:	c3                   	ret    

000012f9 <read>:
SYSCALL(read)
    12f9:	b8 05 00 00 00       	mov    $0x5,%eax
    12fe:	cd 40                	int    $0x40
    1300:	c3                   	ret    

00001301 <write>:
SYSCALL(write)
    1301:	b8 10 00 00 00       	mov    $0x10,%eax
    1306:	cd 40                	int    $0x40
    1308:	c3                   	ret    

00001309 <close>:
SYSCALL(close)
    1309:	b8 15 00 00 00       	mov    $0x15,%eax
    130e:	cd 40                	int    $0x40
    1310:	c3                   	ret    

00001311 <kill>:
SYSCALL(kill)
    1311:	b8 06 00 00 00       	mov    $0x6,%eax
    1316:	cd 40                	int    $0x40
    1318:	c3                   	ret    

00001319 <exec>:
SYSCALL(exec)
    1319:	b8 07 00 00 00       	mov    $0x7,%eax
    131e:	cd 40                	int    $0x40
    1320:	c3                   	ret    

00001321 <open>:
SYSCALL(open)
    1321:	b8 0f 00 00 00       	mov    $0xf,%eax
    1326:	cd 40                	int    $0x40
    1328:	c3                   	ret    

00001329 <mknod>:
SYSCALL(mknod)
    1329:	b8 11 00 00 00       	mov    $0x11,%eax
    132e:	cd 40                	int    $0x40
    1330:	c3                   	ret    

00001331 <unlink>:
SYSCALL(unlink)
    1331:	b8 12 00 00 00       	mov    $0x12,%eax
    1336:	cd 40                	int    $0x40
    1338:	c3                   	ret    

00001339 <fstat>:
SYSCALL(fstat)
    1339:	b8 08 00 00 00       	mov    $0x8,%eax
    133e:	cd 40                	int    $0x40
    1340:	c3                   	ret    

00001341 <link>:
SYSCALL(link)
    1341:	b8 13 00 00 00       	mov    $0x13,%eax
    1346:	cd 40                	int    $0x40
    1348:	c3                   	ret    

00001349 <mkdir>:
SYSCALL(mkdir)
    1349:	b8 14 00 00 00       	mov    $0x14,%eax
    134e:	cd 40                	int    $0x40
    1350:	c3                   	ret    

00001351 <chdir>:
SYSCALL(chdir)
    1351:	b8 09 00 00 00       	mov    $0x9,%eax
    1356:	cd 40                	int    $0x40
    1358:	c3                   	ret    

00001359 <dup>:
SYSCALL(dup)
    1359:	b8 0a 00 00 00       	mov    $0xa,%eax
    135e:	cd 40                	int    $0x40
    1360:	c3                   	ret    

00001361 <getpid>:
SYSCALL(getpid)
    1361:	b8 0b 00 00 00       	mov    $0xb,%eax
    1366:	cd 40                	int    $0x40
    1368:	c3                   	ret    

00001369 <sbrk>:
SYSCALL(sbrk)
    1369:	b8 0c 00 00 00       	mov    $0xc,%eax
    136e:	cd 40                	int    $0x40
    1370:	c3                   	ret    

00001371 <sleep>:
SYSCALL(sleep)
    1371:	b8 0d 00 00 00       	mov    $0xd,%eax
    1376:	cd 40                	int    $0x40
    1378:	c3                   	ret    

00001379 <uptime>:
SYSCALL(uptime)
    1379:	b8 0e 00 00 00       	mov    $0xe,%eax
    137e:	cd 40                	int    $0x40
    1380:	c3                   	ret    

00001381 <shm_open>:
SYSCALL(shm_open)
    1381:	b8 16 00 00 00       	mov    $0x16,%eax
    1386:	cd 40                	int    $0x40
    1388:	c3                   	ret    

00001389 <shm_close>:
SYSCALL(shm_close)	
    1389:	b8 17 00 00 00       	mov    $0x17,%eax
    138e:	cd 40                	int    $0x40
    1390:	c3                   	ret    

00001391 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
    1391:	55                   	push   %ebp
    1392:	89 e5                	mov    %esp,%ebp
    1394:	83 ec 18             	sub    $0x18,%esp
    1397:	8b 45 0c             	mov    0xc(%ebp),%eax
    139a:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
    139d:	83 ec 04             	sub    $0x4,%esp
    13a0:	6a 01                	push   $0x1
    13a2:	8d 45 f4             	lea    -0xc(%ebp),%eax
    13a5:	50                   	push   %eax
    13a6:	ff 75 08             	pushl  0x8(%ebp)
    13a9:	e8 53 ff ff ff       	call   1301 <write>
    13ae:	83 c4 10             	add    $0x10,%esp
}
    13b1:	90                   	nop
    13b2:	c9                   	leave  
    13b3:	c3                   	ret    

000013b4 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
    13b4:	55                   	push   %ebp
    13b5:	89 e5                	mov    %esp,%ebp
    13b7:	53                   	push   %ebx
    13b8:	83 ec 24             	sub    $0x24,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
    13bb:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
    13c2:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
    13c6:	74 17                	je     13df <printint+0x2b>
    13c8:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
    13cc:	79 11                	jns    13df <printint+0x2b>
    neg = 1;
    13ce:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
    13d5:	8b 45 0c             	mov    0xc(%ebp),%eax
    13d8:	f7 d8                	neg    %eax
    13da:	89 45 ec             	mov    %eax,-0x14(%ebp)
    13dd:	eb 06                	jmp    13e5 <printint+0x31>
  } else {
    x = xx;
    13df:	8b 45 0c             	mov    0xc(%ebp),%eax
    13e2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
    13e5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
    13ec:	8b 4d f4             	mov    -0xc(%ebp),%ecx
    13ef:	8d 41 01             	lea    0x1(%ecx),%eax
    13f2:	89 45 f4             	mov    %eax,-0xc(%ebp)
    13f5:	8b 5d 10             	mov    0x10(%ebp),%ebx
    13f8:	8b 45 ec             	mov    -0x14(%ebp),%eax
    13fb:	ba 00 00 00 00       	mov    $0x0,%edx
    1400:	f7 f3                	div    %ebx
    1402:	89 d0                	mov    %edx,%eax
    1404:	0f b6 80 48 1b 00 00 	movzbl 0x1b48(%eax),%eax
    140b:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
    140f:	8b 5d 10             	mov    0x10(%ebp),%ebx
    1412:	8b 45 ec             	mov    -0x14(%ebp),%eax
    1415:	ba 00 00 00 00       	mov    $0x0,%edx
    141a:	f7 f3                	div    %ebx
    141c:	89 45 ec             	mov    %eax,-0x14(%ebp)
    141f:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    1423:	75 c7                	jne    13ec <printint+0x38>
  if(neg)
    1425:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    1429:	74 2d                	je     1458 <printint+0xa4>
    buf[i++] = '-';
    142b:	8b 45 f4             	mov    -0xc(%ebp),%eax
    142e:	8d 50 01             	lea    0x1(%eax),%edx
    1431:	89 55 f4             	mov    %edx,-0xc(%ebp)
    1434:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
    1439:	eb 1d                	jmp    1458 <printint+0xa4>
    putc(fd, buf[i]);
    143b:	8d 55 dc             	lea    -0x24(%ebp),%edx
    143e:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1441:	01 d0                	add    %edx,%eax
    1443:	0f b6 00             	movzbl (%eax),%eax
    1446:	0f be c0             	movsbl %al,%eax
    1449:	83 ec 08             	sub    $0x8,%esp
    144c:	50                   	push   %eax
    144d:	ff 75 08             	pushl  0x8(%ebp)
    1450:	e8 3c ff ff ff       	call   1391 <putc>
    1455:	83 c4 10             	add    $0x10,%esp
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
    1458:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
    145c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    1460:	79 d9                	jns    143b <printint+0x87>
    putc(fd, buf[i]);
}
    1462:	90                   	nop
    1463:	8b 5d fc             	mov    -0x4(%ebp),%ebx
    1466:	c9                   	leave  
    1467:	c3                   	ret    

00001468 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
    1468:	55                   	push   %ebp
    1469:	89 e5                	mov    %esp,%ebp
    146b:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
    146e:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
    1475:	8d 45 0c             	lea    0xc(%ebp),%eax
    1478:	83 c0 04             	add    $0x4,%eax
    147b:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
    147e:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    1485:	e9 59 01 00 00       	jmp    15e3 <printf+0x17b>
    c = fmt[i] & 0xff;
    148a:	8b 55 0c             	mov    0xc(%ebp),%edx
    148d:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1490:	01 d0                	add    %edx,%eax
    1492:	0f b6 00             	movzbl (%eax),%eax
    1495:	0f be c0             	movsbl %al,%eax
    1498:	25 ff 00 00 00       	and    $0xff,%eax
    149d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
    14a0:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    14a4:	75 2c                	jne    14d2 <printf+0x6a>
      if(c == '%'){
    14a6:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
    14aa:	75 0c                	jne    14b8 <printf+0x50>
        state = '%';
    14ac:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
    14b3:	e9 27 01 00 00       	jmp    15df <printf+0x177>
      } else {
        putc(fd, c);
    14b8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    14bb:	0f be c0             	movsbl %al,%eax
    14be:	83 ec 08             	sub    $0x8,%esp
    14c1:	50                   	push   %eax
    14c2:	ff 75 08             	pushl  0x8(%ebp)
    14c5:	e8 c7 fe ff ff       	call   1391 <putc>
    14ca:	83 c4 10             	add    $0x10,%esp
    14cd:	e9 0d 01 00 00       	jmp    15df <printf+0x177>
      }
    } else if(state == '%'){
    14d2:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
    14d6:	0f 85 03 01 00 00    	jne    15df <printf+0x177>
      if(c == 'd'){
    14dc:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
    14e0:	75 1e                	jne    1500 <printf+0x98>
        printint(fd, *ap, 10, 1);
    14e2:	8b 45 e8             	mov    -0x18(%ebp),%eax
    14e5:	8b 00                	mov    (%eax),%eax
    14e7:	6a 01                	push   $0x1
    14e9:	6a 0a                	push   $0xa
    14eb:	50                   	push   %eax
    14ec:	ff 75 08             	pushl  0x8(%ebp)
    14ef:	e8 c0 fe ff ff       	call   13b4 <printint>
    14f4:	83 c4 10             	add    $0x10,%esp
        ap++;
    14f7:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
    14fb:	e9 d8 00 00 00       	jmp    15d8 <printf+0x170>
      } else if(c == 'x' || c == 'p'){
    1500:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
    1504:	74 06                	je     150c <printf+0xa4>
    1506:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
    150a:	75 1e                	jne    152a <printf+0xc2>
        printint(fd, *ap, 16, 0);
    150c:	8b 45 e8             	mov    -0x18(%ebp),%eax
    150f:	8b 00                	mov    (%eax),%eax
    1511:	6a 00                	push   $0x0
    1513:	6a 10                	push   $0x10
    1515:	50                   	push   %eax
    1516:	ff 75 08             	pushl  0x8(%ebp)
    1519:	e8 96 fe ff ff       	call   13b4 <printint>
    151e:	83 c4 10             	add    $0x10,%esp
        ap++;
    1521:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
    1525:	e9 ae 00 00 00       	jmp    15d8 <printf+0x170>
      } else if(c == 's'){
    152a:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
    152e:	75 43                	jne    1573 <printf+0x10b>
        s = (char*)*ap;
    1530:	8b 45 e8             	mov    -0x18(%ebp),%eax
    1533:	8b 00                	mov    (%eax),%eax
    1535:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
    1538:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
    153c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    1540:	75 25                	jne    1567 <printf+0xff>
          s = "(null)";
    1542:	c7 45 f4 78 18 00 00 	movl   $0x1878,-0xc(%ebp)
        while(*s != 0){
    1549:	eb 1c                	jmp    1567 <printf+0xff>
          putc(fd, *s);
    154b:	8b 45 f4             	mov    -0xc(%ebp),%eax
    154e:	0f b6 00             	movzbl (%eax),%eax
    1551:	0f be c0             	movsbl %al,%eax
    1554:	83 ec 08             	sub    $0x8,%esp
    1557:	50                   	push   %eax
    1558:	ff 75 08             	pushl  0x8(%ebp)
    155b:	e8 31 fe ff ff       	call   1391 <putc>
    1560:	83 c4 10             	add    $0x10,%esp
          s++;
    1563:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
    1567:	8b 45 f4             	mov    -0xc(%ebp),%eax
    156a:	0f b6 00             	movzbl (%eax),%eax
    156d:	84 c0                	test   %al,%al
    156f:	75 da                	jne    154b <printf+0xe3>
    1571:	eb 65                	jmp    15d8 <printf+0x170>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
    1573:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
    1577:	75 1d                	jne    1596 <printf+0x12e>
        putc(fd, *ap);
    1579:	8b 45 e8             	mov    -0x18(%ebp),%eax
    157c:	8b 00                	mov    (%eax),%eax
    157e:	0f be c0             	movsbl %al,%eax
    1581:	83 ec 08             	sub    $0x8,%esp
    1584:	50                   	push   %eax
    1585:	ff 75 08             	pushl  0x8(%ebp)
    1588:	e8 04 fe ff ff       	call   1391 <putc>
    158d:	83 c4 10             	add    $0x10,%esp
        ap++;
    1590:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
    1594:	eb 42                	jmp    15d8 <printf+0x170>
      } else if(c == '%'){
    1596:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
    159a:	75 17                	jne    15b3 <printf+0x14b>
        putc(fd, c);
    159c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    159f:	0f be c0             	movsbl %al,%eax
    15a2:	83 ec 08             	sub    $0x8,%esp
    15a5:	50                   	push   %eax
    15a6:	ff 75 08             	pushl  0x8(%ebp)
    15a9:	e8 e3 fd ff ff       	call   1391 <putc>
    15ae:	83 c4 10             	add    $0x10,%esp
    15b1:	eb 25                	jmp    15d8 <printf+0x170>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
    15b3:	83 ec 08             	sub    $0x8,%esp
    15b6:	6a 25                	push   $0x25
    15b8:	ff 75 08             	pushl  0x8(%ebp)
    15bb:	e8 d1 fd ff ff       	call   1391 <putc>
    15c0:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
    15c3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    15c6:	0f be c0             	movsbl %al,%eax
    15c9:	83 ec 08             	sub    $0x8,%esp
    15cc:	50                   	push   %eax
    15cd:	ff 75 08             	pushl  0x8(%ebp)
    15d0:	e8 bc fd ff ff       	call   1391 <putc>
    15d5:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
    15d8:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
    15df:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
    15e3:	8b 55 0c             	mov    0xc(%ebp),%edx
    15e6:	8b 45 f0             	mov    -0x10(%ebp),%eax
    15e9:	01 d0                	add    %edx,%eax
    15eb:	0f b6 00             	movzbl (%eax),%eax
    15ee:	84 c0                	test   %al,%al
    15f0:	0f 85 94 fe ff ff    	jne    148a <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
    15f6:	90                   	nop
    15f7:	c9                   	leave  
    15f8:	c3                   	ret    

000015f9 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
    15f9:	55                   	push   %ebp
    15fa:	89 e5                	mov    %esp,%ebp
    15fc:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
    15ff:	8b 45 08             	mov    0x8(%ebp),%eax
    1602:	83 e8 08             	sub    $0x8,%eax
    1605:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    1608:	a1 64 1b 00 00       	mov    0x1b64,%eax
    160d:	89 45 fc             	mov    %eax,-0x4(%ebp)
    1610:	eb 24                	jmp    1636 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    1612:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1615:	8b 00                	mov    (%eax),%eax
    1617:	3b 45 fc             	cmp    -0x4(%ebp),%eax
    161a:	77 12                	ja     162e <free+0x35>
    161c:	8b 45 f8             	mov    -0x8(%ebp),%eax
    161f:	3b 45 fc             	cmp    -0x4(%ebp),%eax
    1622:	77 24                	ja     1648 <free+0x4f>
    1624:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1627:	8b 00                	mov    (%eax),%eax
    1629:	3b 45 f8             	cmp    -0x8(%ebp),%eax
    162c:	77 1a                	ja     1648 <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    162e:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1631:	8b 00                	mov    (%eax),%eax
    1633:	89 45 fc             	mov    %eax,-0x4(%ebp)
    1636:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1639:	3b 45 fc             	cmp    -0x4(%ebp),%eax
    163c:	76 d4                	jbe    1612 <free+0x19>
    163e:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1641:	8b 00                	mov    (%eax),%eax
    1643:	3b 45 f8             	cmp    -0x8(%ebp),%eax
    1646:	76 ca                	jbe    1612 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    1648:	8b 45 f8             	mov    -0x8(%ebp),%eax
    164b:	8b 40 04             	mov    0x4(%eax),%eax
    164e:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
    1655:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1658:	01 c2                	add    %eax,%edx
    165a:	8b 45 fc             	mov    -0x4(%ebp),%eax
    165d:	8b 00                	mov    (%eax),%eax
    165f:	39 c2                	cmp    %eax,%edx
    1661:	75 24                	jne    1687 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
    1663:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1666:	8b 50 04             	mov    0x4(%eax),%edx
    1669:	8b 45 fc             	mov    -0x4(%ebp),%eax
    166c:	8b 00                	mov    (%eax),%eax
    166e:	8b 40 04             	mov    0x4(%eax),%eax
    1671:	01 c2                	add    %eax,%edx
    1673:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1676:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
    1679:	8b 45 fc             	mov    -0x4(%ebp),%eax
    167c:	8b 00                	mov    (%eax),%eax
    167e:	8b 10                	mov    (%eax),%edx
    1680:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1683:	89 10                	mov    %edx,(%eax)
    1685:	eb 0a                	jmp    1691 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
    1687:	8b 45 fc             	mov    -0x4(%ebp),%eax
    168a:	8b 10                	mov    (%eax),%edx
    168c:	8b 45 f8             	mov    -0x8(%ebp),%eax
    168f:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
    1691:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1694:	8b 40 04             	mov    0x4(%eax),%eax
    1697:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
    169e:	8b 45 fc             	mov    -0x4(%ebp),%eax
    16a1:	01 d0                	add    %edx,%eax
    16a3:	3b 45 f8             	cmp    -0x8(%ebp),%eax
    16a6:	75 20                	jne    16c8 <free+0xcf>
    p->s.size += bp->s.size;
    16a8:	8b 45 fc             	mov    -0x4(%ebp),%eax
    16ab:	8b 50 04             	mov    0x4(%eax),%edx
    16ae:	8b 45 f8             	mov    -0x8(%ebp),%eax
    16b1:	8b 40 04             	mov    0x4(%eax),%eax
    16b4:	01 c2                	add    %eax,%edx
    16b6:	8b 45 fc             	mov    -0x4(%ebp),%eax
    16b9:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
    16bc:	8b 45 f8             	mov    -0x8(%ebp),%eax
    16bf:	8b 10                	mov    (%eax),%edx
    16c1:	8b 45 fc             	mov    -0x4(%ebp),%eax
    16c4:	89 10                	mov    %edx,(%eax)
    16c6:	eb 08                	jmp    16d0 <free+0xd7>
  } else
    p->s.ptr = bp;
    16c8:	8b 45 fc             	mov    -0x4(%ebp),%eax
    16cb:	8b 55 f8             	mov    -0x8(%ebp),%edx
    16ce:	89 10                	mov    %edx,(%eax)
  freep = p;
    16d0:	8b 45 fc             	mov    -0x4(%ebp),%eax
    16d3:	a3 64 1b 00 00       	mov    %eax,0x1b64
}
    16d8:	90                   	nop
    16d9:	c9                   	leave  
    16da:	c3                   	ret    

000016db <morecore>:

static Header*
morecore(uint nu)
{
    16db:	55                   	push   %ebp
    16dc:	89 e5                	mov    %esp,%ebp
    16de:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
    16e1:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
    16e8:	77 07                	ja     16f1 <morecore+0x16>
    nu = 4096;
    16ea:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
    16f1:	8b 45 08             	mov    0x8(%ebp),%eax
    16f4:	c1 e0 03             	shl    $0x3,%eax
    16f7:	83 ec 0c             	sub    $0xc,%esp
    16fa:	50                   	push   %eax
    16fb:	e8 69 fc ff ff       	call   1369 <sbrk>
    1700:	83 c4 10             	add    $0x10,%esp
    1703:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
    1706:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
    170a:	75 07                	jne    1713 <morecore+0x38>
    return 0;
    170c:	b8 00 00 00 00       	mov    $0x0,%eax
    1711:	eb 26                	jmp    1739 <morecore+0x5e>
  hp = (Header*)p;
    1713:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1716:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
    1719:	8b 45 f0             	mov    -0x10(%ebp),%eax
    171c:	8b 55 08             	mov    0x8(%ebp),%edx
    171f:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
    1722:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1725:	83 c0 08             	add    $0x8,%eax
    1728:	83 ec 0c             	sub    $0xc,%esp
    172b:	50                   	push   %eax
    172c:	e8 c8 fe ff ff       	call   15f9 <free>
    1731:	83 c4 10             	add    $0x10,%esp
  return freep;
    1734:	a1 64 1b 00 00       	mov    0x1b64,%eax
}
    1739:	c9                   	leave  
    173a:	c3                   	ret    

0000173b <malloc>:

void*
malloc(uint nbytes)
{
    173b:	55                   	push   %ebp
    173c:	89 e5                	mov    %esp,%ebp
    173e:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
    1741:	8b 45 08             	mov    0x8(%ebp),%eax
    1744:	83 c0 07             	add    $0x7,%eax
    1747:	c1 e8 03             	shr    $0x3,%eax
    174a:	83 c0 01             	add    $0x1,%eax
    174d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
    1750:	a1 64 1b 00 00       	mov    0x1b64,%eax
    1755:	89 45 f0             	mov    %eax,-0x10(%ebp)
    1758:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    175c:	75 23                	jne    1781 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
    175e:	c7 45 f0 5c 1b 00 00 	movl   $0x1b5c,-0x10(%ebp)
    1765:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1768:	a3 64 1b 00 00       	mov    %eax,0x1b64
    176d:	a1 64 1b 00 00       	mov    0x1b64,%eax
    1772:	a3 5c 1b 00 00       	mov    %eax,0x1b5c
    base.s.size = 0;
    1777:	c7 05 60 1b 00 00 00 	movl   $0x0,0x1b60
    177e:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    1781:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1784:	8b 00                	mov    (%eax),%eax
    1786:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
    1789:	8b 45 f4             	mov    -0xc(%ebp),%eax
    178c:	8b 40 04             	mov    0x4(%eax),%eax
    178f:	3b 45 ec             	cmp    -0x14(%ebp),%eax
    1792:	72 4d                	jb     17e1 <malloc+0xa6>
      if(p->s.size == nunits)
    1794:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1797:	8b 40 04             	mov    0x4(%eax),%eax
    179a:	3b 45 ec             	cmp    -0x14(%ebp),%eax
    179d:	75 0c                	jne    17ab <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
    179f:	8b 45 f4             	mov    -0xc(%ebp),%eax
    17a2:	8b 10                	mov    (%eax),%edx
    17a4:	8b 45 f0             	mov    -0x10(%ebp),%eax
    17a7:	89 10                	mov    %edx,(%eax)
    17a9:	eb 26                	jmp    17d1 <malloc+0x96>
      else {
        p->s.size -= nunits;
    17ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
    17ae:	8b 40 04             	mov    0x4(%eax),%eax
    17b1:	2b 45 ec             	sub    -0x14(%ebp),%eax
    17b4:	89 c2                	mov    %eax,%edx
    17b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
    17b9:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
    17bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
    17bf:	8b 40 04             	mov    0x4(%eax),%eax
    17c2:	c1 e0 03             	shl    $0x3,%eax
    17c5:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
    17c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
    17cb:	8b 55 ec             	mov    -0x14(%ebp),%edx
    17ce:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
    17d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
    17d4:	a3 64 1b 00 00       	mov    %eax,0x1b64
      return (void*)(p + 1);
    17d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
    17dc:	83 c0 08             	add    $0x8,%eax
    17df:	eb 3b                	jmp    181c <malloc+0xe1>
    }
    if(p == freep)
    17e1:	a1 64 1b 00 00       	mov    0x1b64,%eax
    17e6:	39 45 f4             	cmp    %eax,-0xc(%ebp)
    17e9:	75 1e                	jne    1809 <malloc+0xce>
      if((p = morecore(nunits)) == 0)
    17eb:	83 ec 0c             	sub    $0xc,%esp
    17ee:	ff 75 ec             	pushl  -0x14(%ebp)
    17f1:	e8 e5 fe ff ff       	call   16db <morecore>
    17f6:	83 c4 10             	add    $0x10,%esp
    17f9:	89 45 f4             	mov    %eax,-0xc(%ebp)
    17fc:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    1800:	75 07                	jne    1809 <malloc+0xce>
        return 0;
    1802:	b8 00 00 00 00       	mov    $0x0,%eax
    1807:	eb 13                	jmp    181c <malloc+0xe1>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    1809:	8b 45 f4             	mov    -0xc(%ebp),%eax
    180c:	89 45 f0             	mov    %eax,-0x10(%ebp)
    180f:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1812:	8b 00                	mov    (%eax),%eax
    1814:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
    1817:	e9 6d ff ff ff       	jmp    1789 <malloc+0x4e>
}
    181c:	c9                   	leave  
    181d:	c3                   	ret    

0000181e <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
    181e:	55                   	push   %ebp
    181f:	89 e5                	mov    %esp,%ebp
    1821:	83 ec 10             	sub    $0x10,%esp
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
    1824:	8b 55 08             	mov    0x8(%ebp),%edx
    1827:	8b 45 0c             	mov    0xc(%ebp),%eax
    182a:	8b 4d 08             	mov    0x8(%ebp),%ecx
    182d:	f0 87 02             	lock xchg %eax,(%edx)
    1830:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
    1833:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
    1836:	c9                   	leave  
    1837:	c3                   	ret    

00001838 <uacquire>:
#include "uspinlock.h"
#include "x86.h"

void
uacquire(struct uspinlock *lk)
{
    1838:	55                   	push   %ebp
    1839:	89 e5                	mov    %esp,%ebp
  // The xchg is atomic.
  while(xchg(&lk->locked, 1) != 0)
    183b:	90                   	nop
    183c:	8b 45 08             	mov    0x8(%ebp),%eax
    183f:	6a 01                	push   $0x1
    1841:	50                   	push   %eax
    1842:	e8 d7 ff ff ff       	call   181e <xchg>
    1847:	83 c4 08             	add    $0x8,%esp
    184a:	85 c0                	test   %eax,%eax
    184c:	75 ee                	jne    183c <uacquire+0x4>
    ;

  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that the critical section's memory
  // references happen after the lock is acquired.
  __sync_synchronize();
    184e:	f0 83 0c 24 00       	lock orl $0x0,(%esp)
}
    1853:	90                   	nop
    1854:	c9                   	leave  
    1855:	c3                   	ret    

00001856 <urelease>:

void urelease (struct uspinlock *lk) {
    1856:	55                   	push   %ebp
    1857:	89 e5                	mov    %esp,%ebp
  __sync_synchronize();
    1859:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Release the lock, equivalent to lk->locked = 0.
  // This code can't use a C assignment, since it might
  // not be atomic. A real OS would use C atomics here.
  asm volatile("movl $0, %0" : "+m" (lk->locked) : );
    185e:	8b 45 08             	mov    0x8(%ebp),%eax
    1861:	8b 55 08             	mov    0x8(%ebp),%edx
    1864:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
}
    186a:	90                   	nop
    186b:	5d                   	pop    %ebp
    186c:	c3                   	ret    
