import os, sys, re, math
HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
from spritepng import png
v1 = re.findall(r'^"(.{32})",$', open(os.path.join(HERE, 'mentor.py')).read(), re.M)
N=32
g=[['.']*N for _ in range(N)]
def inell(x,y,cx,cy,rx,ry): return ((x+0.5-cx)/rx)**2+((y+0.5-cy)/ry)**2<=1
def hair(x,y):
    if inell(x,y,16,11.5,10.2,9.6) and y>=2: return True
    # long hair falling to the shoulders
    if 13<=y<=24 and (6<=x<=9 or 22<=x<=25): return True
    return False
_half={8:5.5,9:6,10:6.2,11:6.4,12:6.4,13:6.4,14: 6.4, 15: 6.3, 16: 6.0, 17: 5.4, 18: 4.4,19:2.2}
def face(x,y): return y in _half and abs(x+0.5-16)<=_half[y]
# Body (collar + vest) from the earlier design
body = [
"................................",
".....kkkkwwkSSSSkwwkkkk.........",
"....kfRkwwwwwwwwwwwwwwkfk.......",
"...kfRkTwwwwwwGwwwwwwwTkRk......",
"..kfRkTTTwwwwwGwwwwwwTTTkRk.....",
"..kkkTTTTTwwwwwwwwwwTTTTTkkk....",
"..kTTTTTTTTTuwwwwwuTTTTTTTTk....",
".kTTTTTTTTTTTuGGGuTTTTTTTTTTk...",
"kTTTttTTTTTTTuGGGuTTTTTTTTTuuk..",
"kTTtttTTTTTTTuGGGuTTTTTTTTuuuk..",
"kTTttTTTTTTTuuGGGuuTTTTTTuuuuuk.",
"kTTtTTTTTTTTuuuGuuuTTTTTuuuuuuk.",
]
# shift body right by 1 so it's centred under the head
body=['.'+r[:-1] for r in body]
for y in range(N):
    for x in range(N):
        if hair(x,y) or face(x,y): g[y][x]='H'
# outline
out=[[c for c in r] for r in g]
for y in range(N):
    for x in range(N):
        if g[y][x]=='.' and any(0<=x+dx<N and 0<=y+dy<N and g[y+dy][x+dx]=='H' for dx,dy in ((1,0),(-1,0),(0,1),(0,-1))):
            out[y][x]='k'
g=out
# colour hair: highlight top-left, shade right/bottom
for y in range(N):
    for x in range(N):
        if g[y][x]!='H': continue
        c='f'
        if y<8 and x<14 and (x+y)%3!=0 and y>2: c='g' if y<6 else 'f'
        if x>=21 or y>=19: c='R'
        if y>=23 or (x>=24 and y>=15): c='x'
        g[y][x]=c
# face
for y in range(N):
    for x in range(N):
        if face(x,y) and y>=10:
            g[y][x]='S' if (x>=21 or (y>=17 and x>=18) or y>=19) else 's'
# jaw and chin outline against the hair behind
for y in range(14,20):
    for x in range(N):
        if face(x,y) and y>=10:
            for dx,dy in ((0,1),(1,0),(-1,0)):
                nx,ny=x+dx,y+dy
                if not face(nx,ny) and g[ny][nx] in 'fRxg': g[ny][nx]='k'
# bangs: strands dipping into the face
for x in range(10,23):
    depth = 10 + (1 if x%3==1 else 0) + (1 if x in (15,16) else 0)
    for y in range(8,depth):
        g[y][x] = 'R' if x%3==0 else 'f'
    if x%3==1: g[depth-1][x]='R'
# sides of the face next to the hair
for y in range(10,19):
    for x in (9,22):
        if g[y][x] in 'sS': g[y][x]='R'
# eyes: heavy lids, iris strip below, lash at the outer corner
for (x0,outer) in ((10,10),(18,21)):
    for x in range(x0,x0+4): g[12][x]='k'
    g[13][outer]='k'
    xs=[x0+1,x0+2] if outer==10 else [x0,x0+1]
    g[13][xs[0]]='T'; g[13][xs[1]]='t' if outer==10 else 'T'
    if outer==21: g[13][x0+1]='t'
# a few strands so the hair isn't one flat mass
for y in range(11,18):
    if g[y][23] in 'R': g[y][23]='f' if y%3 else 'R'
for y in range(19,23):
    if g[y][8] in 'fR': g[y][8]='f'
# yawn tear
g[13][22]='w'
# blush
for x in (10,11,20,21): g[14][x]='h'
# yawning mouth
g[16][15]='R'; g[16][16]='R'; g[17][15]='x'; g[17][16]='x'
# ahoge
for (x,y,c) in ((16,1,'k'),(17,0,'k'),(18,0,'k'),(16,2,'f'),(17,1,'f'),(19,1,'k'),(15,2,'k'),(17,2,'k')):
    g[y][x]=c
# bow (left)
bow={(3,4):'k',(4,4):'k',(2,5):'k',(3,5):'T',(4,5):'t',(5,5):'k',(2,6):'k',(3,6):'T',(4,6):'T',(5,6):'u',(6,6):'G',(2,7):'k',(3,7):'T',(4,7):'u',(5,7):'k',(3,8):'k',(4,8):'k',
     (6,5):'k',(7,6):'k',(6,7):'u',(7,7):'k'}
for (x,y),c in bow.items(): g[y][x]=c
# floating z
for (x,y) in ((26,0),(27,0),(28,0),(29,0),(28,1),(27,2),(26,3),(27,3),(28,3),(29,3)): g[y][x]='w'
# paste body rows 20..31 over
for i,r in enumerate(body):
    y=20+i
    for x,c in enumerate(r):
        if c!='.': g[y][x]=c
rows=[''.join(r) for r in g]
open(sys.argv[2],'w').write('\n'.join(rows))
png([v1, rows], sys.argv[1], scale=10)
