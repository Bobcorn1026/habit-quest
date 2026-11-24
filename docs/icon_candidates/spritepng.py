import re, sys, zlib, struct
import os
pal_src = open(os.path.join(os.path.dirname(os.path.abspath(__file__)), '../../lib/ui/pixel/palette.dart')).read()
colors = {m[0]: int(m[1],16) for m in re.findall(r'static const (\w+) = Color\(0x([0-9A-Fa-f]{8})\)', pal_src)}
keys = {m[0]: colors[m[1]] for m in re.findall(r"'(.)': (\w+),", pal_src) if m[1] in colors}
def png(rows_list, path, scale=10, bg=0xFF5A3A2A, gap=4):
    h = max(len(r) for r in rows_list); w = sum(len(r[0]) for r in rows_list) + gap*(len(rows_list)-1)
    W, H = w*scale, h*scale
    px = [[bg]*w for _ in range(h)]
    x0 = 0
    for rows in rows_list:
        for y,row in enumerate(rows):
            for x,c in enumerate(row):
                if c in '. ': continue
                if c not in keys: raise SystemExit(f'bad key {c!r} at {x},{y}')
                px[y][x0+x] = keys[c]
        x0 += len(rows[0]) + gap
    raw = b''
    for y in range(H):
        raw += b'\x00'
        for x in range(W):
            c = px[y//scale][x//scale]
            raw += struct.pack('BBB', (c>>16)&255, (c>>8)&255, c&255)
    def chunk(t, d): return struct.pack('>I', len(d)) + t + d + struct.pack('>I', zlib.crc32(t+d) & 0xffffffff)
    open(path,'wb').write(b'\x89PNG\r\n\x1a\n' + chunk(b'IHDR', struct.pack('>IIBBBBB', W, H, 8, 2, 0, 0, 0)) + chunk(b'IDAT', zlib.compress(raw)) + chunk(b'IEND', b''))
