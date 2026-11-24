import sys, json, zlib, struct
sys.path.insert(0, sys.argv[1])
from spritepng import keys
rows=json.load(open(sys.argv[1]+'/icons.json'))['shield_only']
# Crop to the drawn area.
ys=[y for y,r in enumerate(rows) if r.strip('.')]
xs=[x for r in rows for x,c in enumerate(r) if c!='.']
rows=[r[min(xs):max(xs)+1] for r in rows[min(ys):max(ys)+1]]
w,h=len(rows[0]),len(rows)
def rgba(path, scale):
    raw=b''
    for y in range(h*scale):
        raw+=b'\x00'
        r=rows[y//scale]
        for x in range(w*scale):
            c=r[x//scale]
            if c=='.': raw+=b'\x00\x00\x00\x00'
            else:
                v=keys[c]; raw+=struct.pack('BBBB',(v>>16)&255,(v>>8)&255,v&255,255)
    def chunk(t,d): return struct.pack('>I',len(d))+t+d+struct.pack('>I',zlib.crc32(t+d)&0xffffffff)
    open(path,'wb').write(b'\x89PNG\r\n\x1a\n'+chunk(b'IHDR',struct.pack('>IIBBBBB',w*scale,h*scale,8,6,0,0,0))+chunk(b'IDAT',zlib.compress(raw))+chunk(b'IEND',b''))
d=sys.argv[2]
for name,scale in (('LaunchImage.png',4),('LaunchImage@2x.png',8),('LaunchImage@3x.png',12)):
    rgba(d+'/'+name, scale)
print(w,h)
