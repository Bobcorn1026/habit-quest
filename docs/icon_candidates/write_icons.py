import sys, json, zlib, struct
sys.path.insert(0, sys.argv[1])
from spritepng import keys
def png_size(rows, path, size):
    n=len(rows)
    raw=b''
    for y in range(size):
        raw+=b'\x00'
        r=rows[y*n//size]
        for x in range(size):
            c=keys[r[x*n//size]]
            raw+=struct.pack('BBB',(c>>16)&255,(c>>8)&255,c&255)
    def chunk(t,d): return struct.pack('>I',len(d))+t+d+struct.pack('>I',zlib.crc32(t+d)&0xffffffff)
    open(path,'wb').write(b'\x89PNG\r\n\x1a\n'+chunk(b'IHDR',struct.pack('>IIBBBBB',size,size,8,2,0,0,0))+chunk(b'IDAT',zlib.compress(raw))+chunk(b'IEND',b''))
icons=json.load(open(sys.argv[1]+'/icons.json'))
rows=icons[sys.argv[3]]
d=sys.argv[2]
contents=json.load(open(d+'/Contents.json'))
for img in contents['images']:
    w=float(img['size'].split('x')[0]); sc=int(img['scale'][0])
    png_size(rows, d+'/'+img['filename'], round(w*sc))
print('wrote', len(contents['images']))
