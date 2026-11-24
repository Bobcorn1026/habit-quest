import sys, math, re, json
sys.path.insert(0, sys.argv[1])
from spritepng import png
N=32
def wood():
    g=[['3']*N for _ in range(N)]
    for y in range(N):
        for x in range(N):
            plank=(x//8)%2
            g[y][x]='4' if plank else '3'
            if x%8==0: g[y][x]='1'
            elif x%8==1: g[y][x]='2'
            # grain
            if (x*7+y*3+ (x//8)*5)%23==0 and x%8>1: g[y][x]='2' if plank==0 else '3'
            if (x*5+y*11)%29==0 and x%8>2: g[y][x]='5' if plank else '4'
    return g
def shield_icon(bg=True):
    g=wood() if bg else [['.']*N for _ in range(N)]
    cx=15.5
    def half(y):
        if y<5 or y>27: return -1
        if y<=16: return 9.6
        t=(y-16)/11.5
        return 9.6*math.sqrt(max(0,1-t*t))
    inside=lambda x,y: abs(x+0.5-cx)<half(y) if half(y)>0 else False
    # drop shadow
    for y in range(N):
        for x in range(N):
            if inside(x-1,y-1) and not inside(x,y): g[y][x]='0'
    for y in range(N):
        for x in range(N):
            if not inside(x,y): continue
            edge = not (inside(x-1,y) and inside(x+1,y) and inside(x,y-1) and inside(x,y+1))
            edge2 = not all(inside(x+dx,y+dy) for dx in (-2,-1,0,1,2) for dy in (-2,-1,0,1,2) if abs(dx)+abs(dy)<=2)
            if edge: g[y][x]='k'
            elif edge2: g[y][x]='g' if (x<cx and y<16) else ('G' if x<cx else 'o')
            else:
                g[y][x]='V' if x>=cx+3 else 'v' if (x<cx-4 and y<12) else 'V' if y>20 else 'v'
                g[y][x]='i' if x>=cx+5 or y>23 else ('v' if (x<cx and y<14) else 'V')
    # check mark (2px thick), gold with dark outline
    pts=[]
    def line(x0,y0,x1,y1):
        n=max(abs(x1-x0),abs(y1-y0))
        for i in range(n+1):
            pts.append((round(x0+(x1-x0)*i/n), round(y0+(y1-y0)*i/n)))
    line(10,16,14,20); line(14,20,21,11)
    thick=set()
    for x,y in pts:
        for dx,dy in ((0,0),(1,0),(0,1),(1,1)): thick.add((x+dx,y+dy))
    for x,y in thick:
        for dx in (-1,0,1):
            for dy in (-1,0,1):
                p=(x+dx,y+dy)
                if p not in thick and inside(*p) and g[p[1]][p[0]] not in 'k': g[p[1]][p[0]]='k'
    for x,y in thick: g[y][x]='g' if (x+y)%5 else 'w'
    # rivets
    for x,y in ((10,8),(21,8)): g[y][x]='w'
    return [''.join(r) for r in g]
def note_icon():
    g=wood()
    x0,x1,y0,y1=6,25,6,27
    for y in range(y0+1,y1+2):
        for x in range(x0+1,x1+2):
            g[y][x]='0'
    for y in range(y0,y1+1):
        for x in range(x0,x1+1):
            border = x in (x0,x1) or y in (y0,y1)
            g[y][x]='k' if border else ('p' if (x<x0+3 or y<y0+3) else 'q' if (x>x1-3 or y>y1-3) else 'P')
    # corner curl
    g[y1-1][x1-1]='Q'; g[y1-1][x1-2]='q'; g[y1-2][x1-1]='q'
    # tack
    for (dx,dy,c) in [(0,-1,'k'),(-1,0,'k'),(1,0,'k'),(0,1,'k'),(0,0,'h'),(1,1,'R'),(-1,-1,'k'),(1,-1,'k'),(-1,1,'k'),(2,0,'k'),(0,2,'k')]:
        g[y0+1+dy][15+dx]=c
    g[y0+1][15]='h'; g[y0+1][16]='r'; g[y0+2][15]='r'; g[y0+2][16]='R'
    # sword diagonal from (10,23) to (21,11)
    for i in range(0,10):
        x,y=11+i,22-i
        g[y][x]='e'; g[y-1][x]='E' if i<9 else 'e'; g[y][x+1]='a'
    for (x,y) in [(9,21),(10,22),(12,24),(13,25)]: g[y][x]='o'
    g[23][11]='b'; g[24][10]='b'; g[25][9]='G'
    # red seal bottom-right
    for (dx,dy) in [(0,0),(1,0),(0,1),(1,1),(-1,0),(2,0),(0,-1),(1,-1),(0,2),(1,2),(-1,1),(2,1)]:
        g[22+dy][20+dx]='r'
    g[22][20]='h'; g[23][21]='R'
    return [''.join(r) for r in g]
def mentor_icon():
    src=open(sys.argv[1]+'/../../lib/ui/pixel/sprites/mentor_frames.dart').read()
    def frame(name): return re.findall(r"^\s*'([^']+)',$", src.split('static const '+name+' ')[1].split(']);')[0], re.M)
    rows=[list(r) for r in frame('idle')]
    for j,r in enumerate(frame('zBig')):
        for i,c in enumerate(r):
            if c!='.': rows[2+j][40+i]=c
    n=len(rows); g=wood()
    return [''.join(g[y*32//n][x*32//n] if c=='.' else c for x,c in enumerate(r)) for y,r in enumerate(rows)]
icons={'shield_only':shield_icon(False),'a_shield':shield_icon(),'b_note':note_icon(),'c_mentor':mentor_icon()}
for k,v in icons.items():
    if k=='shield_only': continue
    assert all(len(r)==len(v) for r in v), k
    png([v], f'{sys.argv[1]}/{k}.png', scale=32, gap=0)
json.dump(icons, open(sys.argv[1]+'/icons.json','w'))
png([v for k,v in icons.items() if k!='shield_only'], f'{sys.argv[1]}/preview.png', scale=8, gap=4)
