
_init:     file format elf32-i386


Disassembly of section .text:

00001000 <main>:

char *argv[] = { "sh", 0 };

int
main(void)
{
    1000:	8d 4c 24 04          	lea    0x4(%esp),%ecx
    1004:	83 e4 f0             	and    $0xfffffff0,%esp
    1007:	ff 71 fc             	pushl  -0x4(%ecx)
    100a:	55                   	push   %ebp
    100b:	89 e5                	mov    %esp,%ebp
    100d:	51                   	push   %ecx
    100e:	83 ec 14             	sub    $0x14,%esp
  kill(1);
    1011:	83 ec 0c             	sub    $0xc,%esp
    1014:	6a 01                	push   $0x1
    1016:	e8 7a 03 00 00       	call   1395 <kill>
    101b:	83 c4 10             	add    $0x10,%esp
  int pid, wpid;

  if(open("console", O_RDWR) < 0){
    101e:	83 ec 08             	sub    $0x8,%esp
    1021:	6a 02                	push   $0x2
    1023:	68 f4 18 00 00       	push   $0x18f4
    1028:	e8 78 03 00 00       	call   13a5 <open>
    102d:	83 c4 10             	add    $0x10,%esp
    1030:	85 c0                	test   %eax,%eax
    1032:	79 26                	jns    105a <main+0x5a>
    mknod("console", 1, 1);
    1034:	83 ec 04             	sub    $0x4,%esp
    1037:	6a 01                	push   $0x1
    1039:	6a 01                	push   $0x1
    103b:	68 f4 18 00 00       	push   $0x18f4
    1040:	e8 68 03 00 00       	call   13ad <mknod>
    1045:	83 c4 10             	add    $0x10,%esp
    open("console", O_RDWR);
    1048:	83 ec 08             	sub    $0x8,%esp
    104b:	6a 02                	push   $0x2
    104d:	68 f4 18 00 00       	push   $0x18f4
    1052:	e8 4e 03 00 00       	call   13a5 <open>
    1057:	83 c4 10             	add    $0x10,%esp
  }
  dup(0);  // stdout
    105a:	83 ec 0c             	sub    $0xc,%esp
    105d:	6a 00                	push   $0x0
    105f:	e8 79 03 00 00       	call   13dd <dup>
    1064:	83 c4 10             	add    $0x10,%esp
  dup(0);  // stderr
    1067:	83 ec 0c             	sub    $0xc,%esp
    106a:	6a 00                	push   $0x0
    106c:	e8 6c 03 00 00       	call   13dd <dup>
    1071:	83 c4 10             	add    $0x10,%esp

  for(;;){
    printf(1, "init: starting sh\n");
    1074:	83 ec 08             	sub    $0x8,%esp
    1077:	68 fc 18 00 00       	push   $0x18fc
    107c:	6a 01                	push   $0x1
    107e:	e8 69 04 00 00       	call   14ec <printf>
    1083:	83 c4 10             	add    $0x10,%esp
    pid = fork();
    1086:	e8 d2 02 00 00       	call   135d <fork>
    108b:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(pid < 0){
    108e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    1092:	79 17                	jns    10ab <main+0xab>
      printf(1, "init: fork failed\n");
    1094:	83 ec 08             	sub    $0x8,%esp
    1097:	68 0f 19 00 00       	push   $0x190f
    109c:	6a 01                	push   $0x1
    109e:	e8 49 04 00 00       	call   14ec <printf>
    10a3:	83 c4 10             	add    $0x10,%esp
      exit();
    10a6:	e8 ba 02 00 00       	call   1365 <exit>
    }
    if(pid == 0){
    10ab:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    10af:	75 3e                	jne    10ef <main+0xef>
      exec("sh", argv);
    10b1:	83 ec 08             	sub    $0x8,%esp
    10b4:	68 f0 1b 00 00       	push   $0x1bf0
    10b9:	68 f1 18 00 00       	push   $0x18f1
    10be:	e8 da 02 00 00       	call   139d <exec>
    10c3:	83 c4 10             	add    $0x10,%esp
      printf(1, "init: exec sh failed\n");
    10c6:	83 ec 08             	sub    $0x8,%esp
    10c9:	68 22 19 00 00       	push   $0x1922
    10ce:	6a 01                	push   $0x1
    10d0:	e8 17 04 00 00       	call   14ec <printf>
    10d5:	83 c4 10             	add    $0x10,%esp
      exit();
    10d8:	e8 88 02 00 00       	call   1365 <exit>
    }
    while((wpid=wait()) >= 0 && wpid != pid)
      printf(1, "zombie!\n");
    10dd:	83 ec 08             	sub    $0x8,%esp
    10e0:	68 38 19 00 00       	push   $0x1938
    10e5:	6a 01                	push   $0x1
    10e7:	e8 00 04 00 00       	call   14ec <printf>
    10ec:	83 c4 10             	add    $0x10,%esp
    if(pid == 0){
      exec("sh", argv);
      printf(1, "init: exec sh failed\n");
      exit();
    }
    while((wpid=wait()) >= 0 && wpid != pid)
    10ef:	e8 79 02 00 00       	call   136d <wait>
    10f4:	89 45 f0             	mov    %eax,-0x10(%ebp)
    10f7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    10fb:	0f 88 73 ff ff ff    	js     1074 <main+0x74>
    1101:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1104:	3b 45 f4             	cmp    -0xc(%ebp),%eax
    1107:	75 d4                	jne    10dd <main+0xdd>
      printf(1, "zombie!\n");
  }
    1109:	e9 66 ff ff ff       	jmp    1074 <main+0x74>

0000110e <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
    110e:	55                   	push   %ebp
    110f:	89 e5                	mov    %esp,%ebp
    1111:	57                   	push   %edi
    1112:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
    1113:	8b 4d 08             	mov    0x8(%ebp),%ecx
    1116:	8b 55 10             	mov    0x10(%ebp),%edx
    1119:	8b 45 0c             	mov    0xc(%ebp),%eax
    111c:	89 cb                	mov    %ecx,%ebx
    111e:	89 df                	mov    %ebx,%edi
    1120:	89 d1                	mov    %edx,%ecx
    1122:	fc                   	cld    
    1123:	f3 aa                	rep stos %al,%es:(%edi)
    1125:	89 ca                	mov    %ecx,%edx
    1127:	89 fb                	mov    %edi,%ebx
    1129:	89 5d 08             	mov    %ebx,0x8(%ebp)
    112c:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
    112f:	90                   	nop
    1130:	5b                   	pop    %ebx
    1131:	5f                   	pop    %edi
    1132:	5d                   	pop    %ebp
    1133:	c3                   	ret    

00001134 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
    1134:	55                   	push   %ebp
    1135:	89 e5                	mov    %esp,%ebp
    1137:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
    113a:	8b 45 08             	mov    0x8(%ebp),%eax
    113d:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
    1140:	90                   	nop
    1141:	8b 45 08             	mov    0x8(%ebp),%eax
    1144:	8d 50 01             	lea    0x1(%eax),%edx
    1147:	89 55 08             	mov    %edx,0x8(%ebp)
    114a:	8b 55 0c             	mov    0xc(%ebp),%edx
    114d:	8d 4a 01             	lea    0x1(%edx),%ecx
    1150:	89 4d 0c             	mov    %ecx,0xc(%ebp)
    1153:	0f b6 12             	movzbl (%edx),%edx
    1156:	88 10                	mov    %dl,(%eax)
    1158:	0f b6 00             	movzbl (%eax),%eax
    115b:	84 c0                	test   %al,%al
    115d:	75 e2                	jne    1141 <strcpy+0xd>
    ;
  return os;
    115f:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
    1162:	c9                   	leave  
    1163:	c3                   	ret    

00001164 <strcmp>:

int
strcmp(const char *p, const char *q)
{
    1164:	55                   	push   %ebp
    1165:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
    1167:	eb 08                	jmp    1171 <strcmp+0xd>
    p++, q++;
    1169:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    116d:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
    1171:	8b 45 08             	mov    0x8(%ebp),%eax
    1174:	0f b6 00             	movzbl (%eax),%eax
    1177:	84 c0                	test   %al,%al
    1179:	74 10                	je     118b <strcmp+0x27>
    117b:	8b 45 08             	mov    0x8(%ebp),%eax
    117e:	0f b6 10             	movzbl (%eax),%edx
    1181:	8b 45 0c             	mov    0xc(%ebp),%eax
    1184:	0f b6 00             	movzbl (%eax),%eax
    1187:	38 c2                	cmp    %al,%dl
    1189:	74 de                	je     1169 <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
    118b:	8b 45 08             	mov    0x8(%ebp),%eax
    118e:	0f b6 00             	movzbl (%eax),%eax
    1191:	0f b6 d0             	movzbl %al,%edx
    1194:	8b 45 0c             	mov    0xc(%ebp),%eax
    1197:	0f b6 00             	movzbl (%eax),%eax
    119a:	0f b6 c0             	movzbl %al,%eax
    119d:	29 c2                	sub    %eax,%edx
    119f:	89 d0                	mov    %edx,%eax
}
    11a1:	5d                   	pop    %ebp
    11a2:	c3                   	ret    

000011a3 <strlen>:

uint
strlen(char *s)
{
    11a3:	55                   	push   %ebp
    11a4:	89 e5                	mov    %esp,%ebp
    11a6:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
    11a9:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    11b0:	eb 04                	jmp    11b6 <strlen+0x13>
    11b2:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
    11b6:	8b 55 fc             	mov    -0x4(%ebp),%edx
    11b9:	8b 45 08             	mov    0x8(%ebp),%eax
    11bc:	01 d0                	add    %edx,%eax
    11be:	0f b6 00             	movzbl (%eax),%eax
    11c1:	84 c0                	test   %al,%al
    11c3:	75 ed                	jne    11b2 <strlen+0xf>
    ;
  return n;
    11c5:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
    11c8:	c9                   	leave  
    11c9:	c3                   	ret    

000011ca <memset>:

void*
memset(void *dst, int c, uint n)
{
    11ca:	55                   	push   %ebp
    11cb:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
    11cd:	8b 45 10             	mov    0x10(%ebp),%eax
    11d0:	50                   	push   %eax
    11d1:	ff 75 0c             	pushl  0xc(%ebp)
    11d4:	ff 75 08             	pushl  0x8(%ebp)
    11d7:	e8 32 ff ff ff       	call   110e <stosb>
    11dc:	83 c4 0c             	add    $0xc,%esp
  return dst;
    11df:	8b 45 08             	mov    0x8(%ebp),%eax
}
    11e2:	c9                   	leave  
    11e3:	c3                   	ret    

000011e4 <strchr>:

char*
strchr(const char *s, char c)
{
    11e4:	55                   	push   %ebp
    11e5:	89 e5                	mov    %esp,%ebp
    11e7:	83 ec 04             	sub    $0x4,%esp
    11ea:	8b 45 0c             	mov    0xc(%ebp),%eax
    11ed:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
    11f0:	eb 14                	jmp    1206 <strchr+0x22>
    if(*s == c)
    11f2:	8b 45 08             	mov    0x8(%ebp),%eax
    11f5:	0f b6 00             	movzbl (%eax),%eax
    11f8:	3a 45 fc             	cmp    -0x4(%ebp),%al
    11fb:	75 05                	jne    1202 <strchr+0x1e>
      return (char*)s;
    11fd:	8b 45 08             	mov    0x8(%ebp),%eax
    1200:	eb 13                	jmp    1215 <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
    1202:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    1206:	8b 45 08             	mov    0x8(%ebp),%eax
    1209:	0f b6 00             	movzbl (%eax),%eax
    120c:	84 c0                	test   %al,%al
    120e:	75 e2                	jne    11f2 <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
    1210:	b8 00 00 00 00       	mov    $0x0,%eax
}
    1215:	c9                   	leave  
    1216:	c3                   	ret    

00001217 <gets>:

char*
gets(char *buf, int max)
{
    1217:	55                   	push   %ebp
    1218:	89 e5                	mov    %esp,%ebp
    121a:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
    121d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    1224:	eb 42                	jmp    1268 <gets+0x51>
    cc = read(0, &c, 1);
    1226:	83 ec 04             	sub    $0x4,%esp
    1229:	6a 01                	push   $0x1
    122b:	8d 45 ef             	lea    -0x11(%ebp),%eax
    122e:	50                   	push   %eax
    122f:	6a 00                	push   $0x0
    1231:	e8 47 01 00 00       	call   137d <read>
    1236:	83 c4 10             	add    $0x10,%esp
    1239:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
    123c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    1240:	7e 33                	jle    1275 <gets+0x5e>
      break;
    buf[i++] = c;
    1242:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1245:	8d 50 01             	lea    0x1(%eax),%edx
    1248:	89 55 f4             	mov    %edx,-0xc(%ebp)
    124b:	89 c2                	mov    %eax,%edx
    124d:	8b 45 08             	mov    0x8(%ebp),%eax
    1250:	01 c2                	add    %eax,%edx
    1252:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    1256:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
    1258:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    125c:	3c 0a                	cmp    $0xa,%al
    125e:	74 16                	je     1276 <gets+0x5f>
    1260:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    1264:	3c 0d                	cmp    $0xd,%al
    1266:	74 0e                	je     1276 <gets+0x5f>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
    1268:	8b 45 f4             	mov    -0xc(%ebp),%eax
    126b:	83 c0 01             	add    $0x1,%eax
    126e:	3b 45 0c             	cmp    0xc(%ebp),%eax
    1271:	7c b3                	jl     1226 <gets+0xf>
    1273:	eb 01                	jmp    1276 <gets+0x5f>
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    1275:	90                   	nop
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
    1276:	8b 55 f4             	mov    -0xc(%ebp),%edx
    1279:	8b 45 08             	mov    0x8(%ebp),%eax
    127c:	01 d0                	add    %edx,%eax
    127e:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
    1281:	8b 45 08             	mov    0x8(%ebp),%eax
}
    1284:	c9                   	leave  
    1285:	c3                   	ret    

00001286 <stat>:

int
stat(char *n, struct stat *st)
{
    1286:	55                   	push   %ebp
    1287:	89 e5                	mov    %esp,%ebp
    1289:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
    128c:	83 ec 08             	sub    $0x8,%esp
    128f:	6a 00                	push   $0x0
    1291:	ff 75 08             	pushl  0x8(%ebp)
    1294:	e8 0c 01 00 00       	call   13a5 <open>
    1299:	83 c4 10             	add    $0x10,%esp
    129c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
    129f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    12a3:	79 07                	jns    12ac <stat+0x26>
    return -1;
    12a5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
    12aa:	eb 25                	jmp    12d1 <stat+0x4b>
  r = fstat(fd, st);
    12ac:	83 ec 08             	sub    $0x8,%esp
    12af:	ff 75 0c             	pushl  0xc(%ebp)
    12b2:	ff 75 f4             	pushl  -0xc(%ebp)
    12b5:	e8 03 01 00 00       	call   13bd <fstat>
    12ba:	83 c4 10             	add    $0x10,%esp
    12bd:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
    12c0:	83 ec 0c             	sub    $0xc,%esp
    12c3:	ff 75 f4             	pushl  -0xc(%ebp)
    12c6:	e8 c2 00 00 00       	call   138d <close>
    12cb:	83 c4 10             	add    $0x10,%esp
  return r;
    12ce:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
    12d1:	c9                   	leave  
    12d2:	c3                   	ret    

000012d3 <atoi>:

int
atoi(const char *s)
{
    12d3:	55                   	push   %ebp
    12d4:	89 e5                	mov    %esp,%ebp
    12d6:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
    12d9:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
    12e0:	eb 25                	jmp    1307 <atoi+0x34>
    n = n*10 + *s++ - '0';
    12e2:	8b 55 fc             	mov    -0x4(%ebp),%edx
    12e5:	89 d0                	mov    %edx,%eax
    12e7:	c1 e0 02             	shl    $0x2,%eax
    12ea:	01 d0                	add    %edx,%eax
    12ec:	01 c0                	add    %eax,%eax
    12ee:	89 c1                	mov    %eax,%ecx
    12f0:	8b 45 08             	mov    0x8(%ebp),%eax
    12f3:	8d 50 01             	lea    0x1(%eax),%edx
    12f6:	89 55 08             	mov    %edx,0x8(%ebp)
    12f9:	0f b6 00             	movzbl (%eax),%eax
    12fc:	0f be c0             	movsbl %al,%eax
    12ff:	01 c8                	add    %ecx,%eax
    1301:	83 e8 30             	sub    $0x30,%eax
    1304:	89 45 fc             	mov    %eax,-0x4(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
    1307:	8b 45 08             	mov    0x8(%ebp),%eax
    130a:	0f b6 00             	movzbl (%eax),%eax
    130d:	3c 2f                	cmp    $0x2f,%al
    130f:	7e 0a                	jle    131b <atoi+0x48>
    1311:	8b 45 08             	mov    0x8(%ebp),%eax
    1314:	0f b6 00             	movzbl (%eax),%eax
    1317:	3c 39                	cmp    $0x39,%al
    1319:	7e c7                	jle    12e2 <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
    131b:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
    131e:	c9                   	leave  
    131f:	c3                   	ret    

00001320 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
    1320:	55                   	push   %ebp
    1321:	89 e5                	mov    %esp,%ebp
    1323:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;

  dst = vdst;
    1326:	8b 45 08             	mov    0x8(%ebp),%eax
    1329:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
    132c:	8b 45 0c             	mov    0xc(%ebp),%eax
    132f:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
    1332:	eb 17                	jmp    134b <memmove+0x2b>
    *dst++ = *src++;
    1334:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1337:	8d 50 01             	lea    0x1(%eax),%edx
    133a:	89 55 fc             	mov    %edx,-0x4(%ebp)
    133d:	8b 55 f8             	mov    -0x8(%ebp),%edx
    1340:	8d 4a 01             	lea    0x1(%edx),%ecx
    1343:	89 4d f8             	mov    %ecx,-0x8(%ebp)
    1346:	0f b6 12             	movzbl (%edx),%edx
    1349:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;

  dst = vdst;
  src = vsrc;
  while(n-- > 0)
    134b:	8b 45 10             	mov    0x10(%ebp),%eax
    134e:	8d 50 ff             	lea    -0x1(%eax),%edx
    1351:	89 55 10             	mov    %edx,0x10(%ebp)
    1354:	85 c0                	test   %eax,%eax
    1356:	7f dc                	jg     1334 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
    1358:	8b 45 08             	mov    0x8(%ebp),%eax
}
    135b:	c9                   	leave  
    135c:	c3                   	ret    

0000135d <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
    135d:	b8 01 00 00 00       	mov    $0x1,%eax
    1362:	cd 40                	int    $0x40
    1364:	c3                   	ret    

00001365 <exit>:
SYSCALL(exit)
    1365:	b8 02 00 00 00       	mov    $0x2,%eax
    136a:	cd 40                	int    $0x40
    136c:	c3                   	ret    

0000136d <wait>:
SYSCALL(wait)
    136d:	b8 03 00 00 00       	mov    $0x3,%eax
    1372:	cd 40                	int    $0x40
    1374:	c3                   	ret    

00001375 <pipe>:
SYSCALL(pipe)
    1375:	b8 04 00 00 00       	mov    $0x4,%eax
    137a:	cd 40                	int    $0x40
    137c:	c3                   	ret    

0000137d <read>:
SYSCALL(read)
    137d:	b8 05 00 00 00       	mov    $0x5,%eax
    1382:	cd 40                	int    $0x40
    1384:	c3                   	ret    

00001385 <write>:
SYSCALL(write)
    1385:	b8 10 00 00 00       	mov    $0x10,%eax
    138a:	cd 40                	int    $0x40
    138c:	c3                   	ret    

0000138d <close>:
SYSCALL(close)
    138d:	b8 15 00 00 00       	mov    $0x15,%eax
    1392:	cd 40                	int    $0x40
    1394:	c3                   	ret    

00001395 <kill>:
SYSCALL(kill)
    1395:	b8 06 00 00 00       	mov    $0x6,%eax
    139a:	cd 40                	int    $0x40
    139c:	c3                   	ret    

0000139d <exec>:
SYSCALL(exec)
    139d:	b8 07 00 00 00       	mov    $0x7,%eax
    13a2:	cd 40                	int    $0x40
    13a4:	c3                   	ret    

000013a5 <open>:
SYSCALL(open)
    13a5:	b8 0f 00 00 00       	mov    $0xf,%eax
    13aa:	cd 40                	int    $0x40
    13ac:	c3                   	ret    

000013ad <mknod>:
SYSCALL(mknod)
    13ad:	b8 11 00 00 00       	mov    $0x11,%eax
    13b2:	cd 40                	int    $0x40
    13b4:	c3                   	ret    

000013b5 <unlink>:
SYSCALL(unlink)
    13b5:	b8 12 00 00 00       	mov    $0x12,%eax
    13ba:	cd 40                	int    $0x40
    13bc:	c3                   	ret    

000013bd <fstat>:
SYSCALL(fstat)
    13bd:	b8 08 00 00 00       	mov    $0x8,%eax
    13c2:	cd 40                	int    $0x40
    13c4:	c3                   	ret    

000013c5 <link>:
SYSCALL(link)
    13c5:	b8 13 00 00 00       	mov    $0x13,%eax
    13ca:	cd 40                	int    $0x40
    13cc:	c3                   	ret    

000013cd <mkdir>:
SYSCALL(mkdir)
    13cd:	b8 14 00 00 00       	mov    $0x14,%eax
    13d2:	cd 40                	int    $0x40
    13d4:	c3                   	ret    

000013d5 <chdir>:
SYSCALL(chdir)
    13d5:	b8 09 00 00 00       	mov    $0x9,%eax
    13da:	cd 40                	int    $0x40
    13dc:	c3                   	ret    

000013dd <dup>:
SYSCALL(dup)
    13dd:	b8 0a 00 00 00       	mov    $0xa,%eax
    13e2:	cd 40                	int    $0x40
    13e4:	c3                   	ret    

000013e5 <getpid>:
SYSCALL(getpid)
    13e5:	b8 0b 00 00 00       	mov    $0xb,%eax
    13ea:	cd 40                	int    $0x40
    13ec:	c3                   	ret    

000013ed <sbrk>:
SYSCALL(sbrk)
    13ed:	b8 0c 00 00 00       	mov    $0xc,%eax
    13f2:	cd 40                	int    $0x40
    13f4:	c3                   	ret    

000013f5 <sleep>:
SYSCALL(sleep)
    13f5:	b8 0d 00 00 00       	mov    $0xd,%eax
    13fa:	cd 40                	int    $0x40
    13fc:	c3                   	ret    

000013fd <uptime>:
SYSCALL(uptime)
    13fd:	b8 0e 00 00 00       	mov    $0xe,%eax
    1402:	cd 40                	int    $0x40
    1404:	c3                   	ret    

00001405 <shm_open>:
SYSCALL(shm_open)
    1405:	b8 16 00 00 00       	mov    $0x16,%eax
    140a:	cd 40                	int    $0x40
    140c:	c3                   	ret    

0000140d <shm_close>:
SYSCALL(shm_close)	
    140d:	b8 17 00 00 00       	mov    $0x17,%eax
    1412:	cd 40                	int    $0x40
    1414:	c3                   	ret    

00001415 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
    1415:	55                   	push   %ebp
    1416:	89 e5                	mov    %esp,%ebp
    1418:	83 ec 18             	sub    $0x18,%esp
    141b:	8b 45 0c             	mov    0xc(%ebp),%eax
    141e:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
    1421:	83 ec 04             	sub    $0x4,%esp
    1424:	6a 01                	push   $0x1
    1426:	8d 45 f4             	lea    -0xc(%ebp),%eax
    1429:	50                   	push   %eax
    142a:	ff 75 08             	pushl  0x8(%ebp)
    142d:	e8 53 ff ff ff       	call   1385 <write>
    1432:	83 c4 10             	add    $0x10,%esp
}
    1435:	90                   	nop
    1436:	c9                   	leave  
    1437:	c3                   	ret    

00001438 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
    1438:	55                   	push   %ebp
    1439:	89 e5                	mov    %esp,%ebp
    143b:	53                   	push   %ebx
    143c:	83 ec 24             	sub    $0x24,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
    143f:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
    1446:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
    144a:	74 17                	je     1463 <printint+0x2b>
    144c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
    1450:	79 11                	jns    1463 <printint+0x2b>
    neg = 1;
    1452:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
    1459:	8b 45 0c             	mov    0xc(%ebp),%eax
    145c:	f7 d8                	neg    %eax
    145e:	89 45 ec             	mov    %eax,-0x14(%ebp)
    1461:	eb 06                	jmp    1469 <printint+0x31>
  } else {
    x = xx;
    1463:	8b 45 0c             	mov    0xc(%ebp),%eax
    1466:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
    1469:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
    1470:	8b 4d f4             	mov    -0xc(%ebp),%ecx
    1473:	8d 41 01             	lea    0x1(%ecx),%eax
    1476:	89 45 f4             	mov    %eax,-0xc(%ebp)
    1479:	8b 5d 10             	mov    0x10(%ebp),%ebx
    147c:	8b 45 ec             	mov    -0x14(%ebp),%eax
    147f:	ba 00 00 00 00       	mov    $0x0,%edx
    1484:	f7 f3                	div    %ebx
    1486:	89 d0                	mov    %edx,%eax
    1488:	0f b6 80 f8 1b 00 00 	movzbl 0x1bf8(%eax),%eax
    148f:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
    1493:	8b 5d 10             	mov    0x10(%ebp),%ebx
    1496:	8b 45 ec             	mov    -0x14(%ebp),%eax
    1499:	ba 00 00 00 00       	mov    $0x0,%edx
    149e:	f7 f3                	div    %ebx
    14a0:	89 45 ec             	mov    %eax,-0x14(%ebp)
    14a3:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    14a7:	75 c7                	jne    1470 <printint+0x38>
  if(neg)
    14a9:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    14ad:	74 2d                	je     14dc <printint+0xa4>
    buf[i++] = '-';
    14af:	8b 45 f4             	mov    -0xc(%ebp),%eax
    14b2:	8d 50 01             	lea    0x1(%eax),%edx
    14b5:	89 55 f4             	mov    %edx,-0xc(%ebp)
    14b8:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
    14bd:	eb 1d                	jmp    14dc <printint+0xa4>
    putc(fd, buf[i]);
    14bf:	8d 55 dc             	lea    -0x24(%ebp),%edx
    14c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
    14c5:	01 d0                	add    %edx,%eax
    14c7:	0f b6 00             	movzbl (%eax),%eax
    14ca:	0f be c0             	movsbl %al,%eax
    14cd:	83 ec 08             	sub    $0x8,%esp
    14d0:	50                   	push   %eax
    14d1:	ff 75 08             	pushl  0x8(%ebp)
    14d4:	e8 3c ff ff ff       	call   1415 <putc>
    14d9:	83 c4 10             	add    $0x10,%esp
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
    14dc:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
    14e0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    14e4:	79 d9                	jns    14bf <printint+0x87>
    putc(fd, buf[i]);
}
    14e6:	90                   	nop
    14e7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
    14ea:	c9                   	leave  
    14eb:	c3                   	ret    

000014ec <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
    14ec:	55                   	push   %ebp
    14ed:	89 e5                	mov    %esp,%ebp
    14ef:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
    14f2:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
    14f9:	8d 45 0c             	lea    0xc(%ebp),%eax
    14fc:	83 c0 04             	add    $0x4,%eax
    14ff:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
    1502:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    1509:	e9 59 01 00 00       	jmp    1667 <printf+0x17b>
    c = fmt[i] & 0xff;
    150e:	8b 55 0c             	mov    0xc(%ebp),%edx
    1511:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1514:	01 d0                	add    %edx,%eax
    1516:	0f b6 00             	movzbl (%eax),%eax
    1519:	0f be c0             	movsbl %al,%eax
    151c:	25 ff 00 00 00       	and    $0xff,%eax
    1521:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
    1524:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    1528:	75 2c                	jne    1556 <printf+0x6a>
      if(c == '%'){
    152a:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
    152e:	75 0c                	jne    153c <printf+0x50>
        state = '%';
    1530:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
    1537:	e9 27 01 00 00       	jmp    1663 <printf+0x177>
      } else {
        putc(fd, c);
    153c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    153f:	0f be c0             	movsbl %al,%eax
    1542:	83 ec 08             	sub    $0x8,%esp
    1545:	50                   	push   %eax
    1546:	ff 75 08             	pushl  0x8(%ebp)
    1549:	e8 c7 fe ff ff       	call   1415 <putc>
    154e:	83 c4 10             	add    $0x10,%esp
    1551:	e9 0d 01 00 00       	jmp    1663 <printf+0x177>
      }
    } else if(state == '%'){
    1556:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
    155a:	0f 85 03 01 00 00    	jne    1663 <printf+0x177>
      if(c == 'd'){
    1560:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
    1564:	75 1e                	jne    1584 <printf+0x98>
        printint(fd, *ap, 10, 1);
    1566:	8b 45 e8             	mov    -0x18(%ebp),%eax
    1569:	8b 00                	mov    (%eax),%eax
    156b:	6a 01                	push   $0x1
    156d:	6a 0a                	push   $0xa
    156f:	50                   	push   %eax
    1570:	ff 75 08             	pushl  0x8(%ebp)
    1573:	e8 c0 fe ff ff       	call   1438 <printint>
    1578:	83 c4 10             	add    $0x10,%esp
        ap++;
    157b:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
    157f:	e9 d8 00 00 00       	jmp    165c <printf+0x170>
      } else if(c == 'x' || c == 'p'){
    1584:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
    1588:	74 06                	je     1590 <printf+0xa4>
    158a:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
    158e:	75 1e                	jne    15ae <printf+0xc2>
        printint(fd, *ap, 16, 0);
    1590:	8b 45 e8             	mov    -0x18(%ebp),%eax
    1593:	8b 00                	mov    (%eax),%eax
    1595:	6a 00                	push   $0x0
    1597:	6a 10                	push   $0x10
    1599:	50                   	push   %eax
    159a:	ff 75 08             	pushl  0x8(%ebp)
    159d:	e8 96 fe ff ff       	call   1438 <printint>
    15a2:	83 c4 10             	add    $0x10,%esp
        ap++;
    15a5:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
    15a9:	e9 ae 00 00 00       	jmp    165c <printf+0x170>
      } else if(c == 's'){
    15ae:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
    15b2:	75 43                	jne    15f7 <printf+0x10b>
        s = (char*)*ap;
    15b4:	8b 45 e8             	mov    -0x18(%ebp),%eax
    15b7:	8b 00                	mov    (%eax),%eax
    15b9:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
    15bc:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
    15c0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    15c4:	75 25                	jne    15eb <printf+0xff>
          s = "(null)";
    15c6:	c7 45 f4 41 19 00 00 	movl   $0x1941,-0xc(%ebp)
        while(*s != 0){
    15cd:	eb 1c                	jmp    15eb <printf+0xff>
          putc(fd, *s);
    15cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
    15d2:	0f b6 00             	movzbl (%eax),%eax
    15d5:	0f be c0             	movsbl %al,%eax
    15d8:	83 ec 08             	sub    $0x8,%esp
    15db:	50                   	push   %eax
    15dc:	ff 75 08             	pushl  0x8(%ebp)
    15df:	e8 31 fe ff ff       	call   1415 <putc>
    15e4:	83 c4 10             	add    $0x10,%esp
          s++;
    15e7:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
    15eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
    15ee:	0f b6 00             	movzbl (%eax),%eax
    15f1:	84 c0                	test   %al,%al
    15f3:	75 da                	jne    15cf <printf+0xe3>
    15f5:	eb 65                	jmp    165c <printf+0x170>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
    15f7:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
    15fb:	75 1d                	jne    161a <printf+0x12e>
        putc(fd, *ap);
    15fd:	8b 45 e8             	mov    -0x18(%ebp),%eax
    1600:	8b 00                	mov    (%eax),%eax
    1602:	0f be c0             	movsbl %al,%eax
    1605:	83 ec 08             	sub    $0x8,%esp
    1608:	50                   	push   %eax
    1609:	ff 75 08             	pushl  0x8(%ebp)
    160c:	e8 04 fe ff ff       	call   1415 <putc>
    1611:	83 c4 10             	add    $0x10,%esp
        ap++;
    1614:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
    1618:	eb 42                	jmp    165c <printf+0x170>
      } else if(c == '%'){
    161a:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
    161e:	75 17                	jne    1637 <printf+0x14b>
        putc(fd, c);
    1620:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    1623:	0f be c0             	movsbl %al,%eax
    1626:	83 ec 08             	sub    $0x8,%esp
    1629:	50                   	push   %eax
    162a:	ff 75 08             	pushl  0x8(%ebp)
    162d:	e8 e3 fd ff ff       	call   1415 <putc>
    1632:	83 c4 10             	add    $0x10,%esp
    1635:	eb 25                	jmp    165c <printf+0x170>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
    1637:	83 ec 08             	sub    $0x8,%esp
    163a:	6a 25                	push   $0x25
    163c:	ff 75 08             	pushl  0x8(%ebp)
    163f:	e8 d1 fd ff ff       	call   1415 <putc>
    1644:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
    1647:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    164a:	0f be c0             	movsbl %al,%eax
    164d:	83 ec 08             	sub    $0x8,%esp
    1650:	50                   	push   %eax
    1651:	ff 75 08             	pushl  0x8(%ebp)
    1654:	e8 bc fd ff ff       	call   1415 <putc>
    1659:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
    165c:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
    1663:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
    1667:	8b 55 0c             	mov    0xc(%ebp),%edx
    166a:	8b 45 f0             	mov    -0x10(%ebp),%eax
    166d:	01 d0                	add    %edx,%eax
    166f:	0f b6 00             	movzbl (%eax),%eax
    1672:	84 c0                	test   %al,%al
    1674:	0f 85 94 fe ff ff    	jne    150e <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
    167a:	90                   	nop
    167b:	c9                   	leave  
    167c:	c3                   	ret    

0000167d <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
    167d:	55                   	push   %ebp
    167e:	89 e5                	mov    %esp,%ebp
    1680:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
    1683:	8b 45 08             	mov    0x8(%ebp),%eax
    1686:	83 e8 08             	sub    $0x8,%eax
    1689:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    168c:	a1 14 1c 00 00       	mov    0x1c14,%eax
    1691:	89 45 fc             	mov    %eax,-0x4(%ebp)
    1694:	eb 24                	jmp    16ba <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    1696:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1699:	8b 00                	mov    (%eax),%eax
    169b:	3b 45 fc             	cmp    -0x4(%ebp),%eax
    169e:	77 12                	ja     16b2 <free+0x35>
    16a0:	8b 45 f8             	mov    -0x8(%ebp),%eax
    16a3:	3b 45 fc             	cmp    -0x4(%ebp),%eax
    16a6:	77 24                	ja     16cc <free+0x4f>
    16a8:	8b 45 fc             	mov    -0x4(%ebp),%eax
    16ab:	8b 00                	mov    (%eax),%eax
    16ad:	3b 45 f8             	cmp    -0x8(%ebp),%eax
    16b0:	77 1a                	ja     16cc <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    16b2:	8b 45 fc             	mov    -0x4(%ebp),%eax
    16b5:	8b 00                	mov    (%eax),%eax
    16b7:	89 45 fc             	mov    %eax,-0x4(%ebp)
    16ba:	8b 45 f8             	mov    -0x8(%ebp),%eax
    16bd:	3b 45 fc             	cmp    -0x4(%ebp),%eax
    16c0:	76 d4                	jbe    1696 <free+0x19>
    16c2:	8b 45 fc             	mov    -0x4(%ebp),%eax
    16c5:	8b 00                	mov    (%eax),%eax
    16c7:	3b 45 f8             	cmp    -0x8(%ebp),%eax
    16ca:	76 ca                	jbe    1696 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    16cc:	8b 45 f8             	mov    -0x8(%ebp),%eax
    16cf:	8b 40 04             	mov    0x4(%eax),%eax
    16d2:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
    16d9:	8b 45 f8             	mov    -0x8(%ebp),%eax
    16dc:	01 c2                	add    %eax,%edx
    16de:	8b 45 fc             	mov    -0x4(%ebp),%eax
    16e1:	8b 00                	mov    (%eax),%eax
    16e3:	39 c2                	cmp    %eax,%edx
    16e5:	75 24                	jne    170b <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
    16e7:	8b 45 f8             	mov    -0x8(%ebp),%eax
    16ea:	8b 50 04             	mov    0x4(%eax),%edx
    16ed:	8b 45 fc             	mov    -0x4(%ebp),%eax
    16f0:	8b 00                	mov    (%eax),%eax
    16f2:	8b 40 04             	mov    0x4(%eax),%eax
    16f5:	01 c2                	add    %eax,%edx
    16f7:	8b 45 f8             	mov    -0x8(%ebp),%eax
    16fa:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
    16fd:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1700:	8b 00                	mov    (%eax),%eax
    1702:	8b 10                	mov    (%eax),%edx
    1704:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1707:	89 10                	mov    %edx,(%eax)
    1709:	eb 0a                	jmp    1715 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
    170b:	8b 45 fc             	mov    -0x4(%ebp),%eax
    170e:	8b 10                	mov    (%eax),%edx
    1710:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1713:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
    1715:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1718:	8b 40 04             	mov    0x4(%eax),%eax
    171b:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
    1722:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1725:	01 d0                	add    %edx,%eax
    1727:	3b 45 f8             	cmp    -0x8(%ebp),%eax
    172a:	75 20                	jne    174c <free+0xcf>
    p->s.size += bp->s.size;
    172c:	8b 45 fc             	mov    -0x4(%ebp),%eax
    172f:	8b 50 04             	mov    0x4(%eax),%edx
    1732:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1735:	8b 40 04             	mov    0x4(%eax),%eax
    1738:	01 c2                	add    %eax,%edx
    173a:	8b 45 fc             	mov    -0x4(%ebp),%eax
    173d:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
    1740:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1743:	8b 10                	mov    (%eax),%edx
    1745:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1748:	89 10                	mov    %edx,(%eax)
    174a:	eb 08                	jmp    1754 <free+0xd7>
  } else
    p->s.ptr = bp;
    174c:	8b 45 fc             	mov    -0x4(%ebp),%eax
    174f:	8b 55 f8             	mov    -0x8(%ebp),%edx
    1752:	89 10                	mov    %edx,(%eax)
  freep = p;
    1754:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1757:	a3 14 1c 00 00       	mov    %eax,0x1c14
}
    175c:	90                   	nop
    175d:	c9                   	leave  
    175e:	c3                   	ret    

0000175f <morecore>:

static Header*
morecore(uint nu)
{
    175f:	55                   	push   %ebp
    1760:	89 e5                	mov    %esp,%ebp
    1762:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
    1765:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
    176c:	77 07                	ja     1775 <morecore+0x16>
    nu = 4096;
    176e:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
    1775:	8b 45 08             	mov    0x8(%ebp),%eax
    1778:	c1 e0 03             	shl    $0x3,%eax
    177b:	83 ec 0c             	sub    $0xc,%esp
    177e:	50                   	push   %eax
    177f:	e8 69 fc ff ff       	call   13ed <sbrk>
    1784:	83 c4 10             	add    $0x10,%esp
    1787:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
    178a:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
    178e:	75 07                	jne    1797 <morecore+0x38>
    return 0;
    1790:	b8 00 00 00 00       	mov    $0x0,%eax
    1795:	eb 26                	jmp    17bd <morecore+0x5e>
  hp = (Header*)p;
    1797:	8b 45 f4             	mov    -0xc(%ebp),%eax
    179a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
    179d:	8b 45 f0             	mov    -0x10(%ebp),%eax
    17a0:	8b 55 08             	mov    0x8(%ebp),%edx
    17a3:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
    17a6:	8b 45 f0             	mov    -0x10(%ebp),%eax
    17a9:	83 c0 08             	add    $0x8,%eax
    17ac:	83 ec 0c             	sub    $0xc,%esp
    17af:	50                   	push   %eax
    17b0:	e8 c8 fe ff ff       	call   167d <free>
    17b5:	83 c4 10             	add    $0x10,%esp
  return freep;
    17b8:	a1 14 1c 00 00       	mov    0x1c14,%eax
}
    17bd:	c9                   	leave  
    17be:	c3                   	ret    

000017bf <malloc>:

void*
malloc(uint nbytes)
{
    17bf:	55                   	push   %ebp
    17c0:	89 e5                	mov    %esp,%ebp
    17c2:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
    17c5:	8b 45 08             	mov    0x8(%ebp),%eax
    17c8:	83 c0 07             	add    $0x7,%eax
    17cb:	c1 e8 03             	shr    $0x3,%eax
    17ce:	83 c0 01             	add    $0x1,%eax
    17d1:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
    17d4:	a1 14 1c 00 00       	mov    0x1c14,%eax
    17d9:	89 45 f0             	mov    %eax,-0x10(%ebp)
    17dc:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    17e0:	75 23                	jne    1805 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
    17e2:	c7 45 f0 0c 1c 00 00 	movl   $0x1c0c,-0x10(%ebp)
    17e9:	8b 45 f0             	mov    -0x10(%ebp),%eax
    17ec:	a3 14 1c 00 00       	mov    %eax,0x1c14
    17f1:	a1 14 1c 00 00       	mov    0x1c14,%eax
    17f6:	a3 0c 1c 00 00       	mov    %eax,0x1c0c
    base.s.size = 0;
    17fb:	c7 05 10 1c 00 00 00 	movl   $0x0,0x1c10
    1802:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    1805:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1808:	8b 00                	mov    (%eax),%eax
    180a:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
    180d:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1810:	8b 40 04             	mov    0x4(%eax),%eax
    1813:	3b 45 ec             	cmp    -0x14(%ebp),%eax
    1816:	72 4d                	jb     1865 <malloc+0xa6>
      if(p->s.size == nunits)
    1818:	8b 45 f4             	mov    -0xc(%ebp),%eax
    181b:	8b 40 04             	mov    0x4(%eax),%eax
    181e:	3b 45 ec             	cmp    -0x14(%ebp),%eax
    1821:	75 0c                	jne    182f <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
    1823:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1826:	8b 10                	mov    (%eax),%edx
    1828:	8b 45 f0             	mov    -0x10(%ebp),%eax
    182b:	89 10                	mov    %edx,(%eax)
    182d:	eb 26                	jmp    1855 <malloc+0x96>
      else {
        p->s.size -= nunits;
    182f:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1832:	8b 40 04             	mov    0x4(%eax),%eax
    1835:	2b 45 ec             	sub    -0x14(%ebp),%eax
    1838:	89 c2                	mov    %eax,%edx
    183a:	8b 45 f4             	mov    -0xc(%ebp),%eax
    183d:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
    1840:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1843:	8b 40 04             	mov    0x4(%eax),%eax
    1846:	c1 e0 03             	shl    $0x3,%eax
    1849:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
    184c:	8b 45 f4             	mov    -0xc(%ebp),%eax
    184f:	8b 55 ec             	mov    -0x14(%ebp),%edx
    1852:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
    1855:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1858:	a3 14 1c 00 00       	mov    %eax,0x1c14
      return (void*)(p + 1);
    185d:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1860:	83 c0 08             	add    $0x8,%eax
    1863:	eb 3b                	jmp    18a0 <malloc+0xe1>
    }
    if(p == freep)
    1865:	a1 14 1c 00 00       	mov    0x1c14,%eax
    186a:	39 45 f4             	cmp    %eax,-0xc(%ebp)
    186d:	75 1e                	jne    188d <malloc+0xce>
      if((p = morecore(nunits)) == 0)
    186f:	83 ec 0c             	sub    $0xc,%esp
    1872:	ff 75 ec             	pushl  -0x14(%ebp)
    1875:	e8 e5 fe ff ff       	call   175f <morecore>
    187a:	83 c4 10             	add    $0x10,%esp
    187d:	89 45 f4             	mov    %eax,-0xc(%ebp)
    1880:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    1884:	75 07                	jne    188d <malloc+0xce>
        return 0;
    1886:	b8 00 00 00 00       	mov    $0x0,%eax
    188b:	eb 13                	jmp    18a0 <malloc+0xe1>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    188d:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1890:	89 45 f0             	mov    %eax,-0x10(%ebp)
    1893:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1896:	8b 00                	mov    (%eax),%eax
    1898:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
    189b:	e9 6d ff ff ff       	jmp    180d <malloc+0x4e>
}
    18a0:	c9                   	leave  
    18a1:	c3                   	ret    

000018a2 <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
    18a2:	55                   	push   %ebp
    18a3:	89 e5                	mov    %esp,%ebp
    18a5:	83 ec 10             	sub    $0x10,%esp
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
    18a8:	8b 55 08             	mov    0x8(%ebp),%edx
    18ab:	8b 45 0c             	mov    0xc(%ebp),%eax
    18ae:	8b 4d 08             	mov    0x8(%ebp),%ecx
    18b1:	f0 87 02             	lock xchg %eax,(%edx)
    18b4:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
    18b7:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
    18ba:	c9                   	leave  
    18bb:	c3                   	ret    

000018bc <uacquire>:
#include "uspinlock.h"
#include "x86.h"

void
uacquire(struct uspinlock *lk)
{
    18bc:	55                   	push   %ebp
    18bd:	89 e5                	mov    %esp,%ebp
  // The xchg is atomic.
  while(xchg(&lk->locked, 1) != 0)
    18bf:	90                   	nop
    18c0:	8b 45 08             	mov    0x8(%ebp),%eax
    18c3:	6a 01                	push   $0x1
    18c5:	50                   	push   %eax
    18c6:	e8 d7 ff ff ff       	call   18a2 <xchg>
    18cb:	83 c4 08             	add    $0x8,%esp
    18ce:	85 c0                	test   %eax,%eax
    18d0:	75 ee                	jne    18c0 <uacquire+0x4>
    ;

  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that the critical section's memory
  // references happen after the lock is acquired.
  __sync_synchronize();
    18d2:	f0 83 0c 24 00       	lock orl $0x0,(%esp)
}
    18d7:	90                   	nop
    18d8:	c9                   	leave  
    18d9:	c3                   	ret    

000018da <urelease>:

void urelease (struct uspinlock *lk) {
    18da:	55                   	push   %ebp
    18db:	89 e5                	mov    %esp,%ebp
  __sync_synchronize();
    18dd:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Release the lock, equivalent to lk->locked = 0.
  // This code can't use a C assignment, since it might
  // not be atomic. A real OS would use C atomics here.
  asm volatile("movl $0, %0" : "+m" (lk->locked) : );
    18e2:	8b 45 08             	mov    0x8(%ebp),%eax
    18e5:	8b 55 08             	mov    0x8(%ebp),%edx
    18e8:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
}
    18ee:	90                   	nop
    18ef:	5d                   	pop    %ebp
    18f0:	c3                   	ret    
