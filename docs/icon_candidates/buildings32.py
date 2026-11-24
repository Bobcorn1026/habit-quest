# The town's buildings at 32×32 for the town tab, plus the 16×16 tab icon.
# Light from the top left, outlines added around each silhouette.
# Writes lib/ui/pixel/sprites/buildings.dart and buildings32_preview.png.
#   python3 docs/icon_candidates/buildings32.py
import os, sys
here = os.path.dirname(os.path.abspath(__file__))
root = os.path.abspath(os.path.join(here, '../..'))
sys.path.insert(0, here)
from spritepng import png


class Canvas:
    def __init__(s, n=32):
        s.n = n
        s.g = [['.'] * n for _ in range(n)]

    def put(s, x, y, c):
        if 0 <= x < s.n and 0 <= y < s.n:
            s.g[y][x] = c

    def get(s, x, y):
        return s.g[y][x] if 0 <= x < s.n and 0 <= y < s.n else '.'

    def rect(s, x0, y0, x1, y1, c):
        for y in range(y0, y1 + 1):
            for x in range(x0, x1 + 1):
                s.put(x, y, c)

    def hline(s, x0, x1, y, c): s.rect(x0, y, x1, y, c)
    def vline(s, x, y0, y1, c): s.rect(x, y0, x, y1, c)

    def stamp(s, x0, y0, rows):
        for j, r in enumerate(rows):
            for i, c in enumerate(r):
                if c != '.':
                    s.put(x0 + i, y0 + j, c)

    def outline(s):
        hits = [(x, y) for y in range(s.n) for x in range(s.n)
                if s.g[y][x] == '.' and any(s.get(x + dx, y + dy) not in '.k'
                                            for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)))]
        for x, y in hits:
            s.g[y][x] = 'k'

    def rows(s): return [''.join(r) for r in s.g]


def tri_roof(c, top, bottom, step, light, base, shade, cx=16):
    """A gable seen from the front: apex two pixels wide at [top], widening
    by [step] pixels on each side per row down to [bottom]."""
    for y in range(top, bottom + 1):
        half = 1 + int((y - top) * step)
        x0, x1 = cx - half, cx + half - 1
        for x in range(x0, x1 + 1):
            edge = x - x0
            c.put(x, y, light if edge < 2 else shade if x1 - x < 2 else base)


# ---------------------------------------------------------------- 修練場
def dojo():
    c = Canvas()
    # Tiled roof: courses alternate, lit on the left, upturned gold ends.
    for i, y in enumerate(range(5, 12)):
        x0, x1 = 7 - i, 24 + i
        for x in range(x0, x1 + 1):
            tone = 'r' if i % 2 == 0 else 'R'
            if x - x0 < 2:
                tone = 'h' if i % 2 == 0 else 'r'
            elif x1 - x < 2:
                tone = 'R' if i % 2 == 0 else 'x'
            c.put(x, y, tone)
    c.hline(6, 25, 4, 'x')
    c.stamp(5, 2, ['G..', 'oG.', '.o.'])
    c.stamp(24, 2, ['..G', '.Go', '.o.'])
    c.hline(1, 30, 12, 'k')
    # Timber hall.
    c.rect(3, 13, 28, 27, '4')
    for x in range(5, 27, 4):
        c.vline(x, 15, 27, '3')
    c.vline(4, 15, 27, '5')
    c.rect(3, 13, 28, 14, '2')
    c.hline(3, 28, 13, '3')
    c.vline(3, 13, 27, '2')
    c.vline(28, 13, 27, '1')
    c.vline(27, 15, 27, '3')
    # Doorway with a straw dummy inside.
    c.rect(11, 20, 20, 27, 'k')
    c.rect(12, 21, 19, 27, 'd')
    c.stamp(14, 22, ['.GG.', 'GooG', '.Go.', '.o..'])
    c.vline(15, 26, 27, '2')
    c.vline(16, 26, 27, '1')
    # Target sign over the door.
    c.stamp(12, 13, [
        '..kkkk..',
        '.khrrrk.',
        'khwwwwRk',
        'krwrrwRk',
        'krwrRwRk',
        'kRwwwwRk',
        '.kRRRRk.',
        '..kkkk..',
    ])
    # Lanterns either side.
    for x in (7, 23):
        c.stamp(x, 17, ['k.k', 'gGo', 'GGo', 'k.k'])
    c.hline(2, 29, 28, '2')
    c.outline()
    return c.rows()


# ---------------------------------------------------------------- 銀行
def bank():
    c = Canvas()
    tri_roof(c, 3, 9, 2, 'w', 'W', 'E')
    c.stamp(14, 5, ['.gG.', 'gGGo', 'GGoo', '.oo.'])
    c.hline(1, 30, 10, 'k')
    c.hline(1, 30, 11, 'w')
    c.hline(1, 30, 12, 'W')
    c.hline(29, 30, 11, 'W')
    c.hline(29, 30, 12, 'E')
    c.hline(1, 30, 13, 'k')
    # Dark hall behind the columns.
    c.rect(2, 14, 29, 24, 'a')
    c.hline(2, 29, 14, 'k')
    for x0 in (2, 9, 18, 25):
        c.vline(x0, 14, 24, 'k')
        c.vline(x0 + 1, 14, 24, 'w')
        c.vline(x0 + 2, 14, 24, 'W')
        c.vline(x0 + 3, 14, 24, 'E')
        c.vline(x0 + 4, 14, 24, 'k')
        c.hline(x0, x0 + 4, 14, 'W')
        c.put(x0 + 4, 14, 'E')
    # Double door in the middle.
    c.rect(13, 17, 18, 24, 'k')
    c.rect(14, 18, 15, 24, '4')
    c.rect(16, 18, 17, 24, '3')
    c.put(15, 21, 'G')
    c.put(16, 21, 'o')
    # Steps.
    c.hline(1, 30, 25, 'k')
    c.hline(1, 30, 26, 'w')
    c.hline(1, 30, 27, 'E')
    c.hline(0, 31, 28, 'W')
    c.hline(0, 31, 29, 'E')
    c.put(0, 28, '.')
    c.put(31, 28, '.')
    c.put(0, 29, '.')
    c.put(31, 29, '.')
    c.hline(1, 30, 28, 'W')
    c.hline(1, 30, 29, 'E')
    c.outline()
    return c.rows()


# ---------------------------------------------------------------- 賭場
def casino():
    c = Canvas()
    # Pennant on a pole.
    c.vline(16, 0, 4, 'Q')
    c.stamp(17, 0, ['gGG', 'Go.', 'o..'])

    def stripe(x, y, wall):
        band = (x - 1) // 3 % 2 == 0
        light = x < 11
        dark = x > 21
        if band:
            return 'v' if light else 'i' if dark else 'V'
        return 'g' if light else 'o' if dark else 'G'

    for y in range(5, 14):
        half = 1 + int((y - 5) * 1.75)
        for x in range(16 - half, 16 + half):
            c.put(x, y, stripe(x, y, False))
    # Scalloped valance.
    c.hline(2, 29, 14, 'G')
    c.hline(2, 3, 14, 'g')
    c.hline(27, 29, 14, 'o')
    for x in range(2, 30):
        if (x - 2) % 4 in (1, 2):
            c.put(x, 15, 'o' if x > 21 else 'G')
    c.hline(2, 29, 14, 'G')
    # Walls.
    for y in range(16, 28):
        for x in range(4, 28):
            c.put(x, y, stripe(x, y, True))
    c.hline(4, 27, 16, 'k')
    for x in range(2, 30):
        if (x - 2) % 4 in (1, 2):
            c.put(x, 15, 'o' if x > 21 else 'G')
    # Open flaps with treasure inside.
    for j, y in enumerate(range(18, 28)):
        half = 1 + j // 2
        c.hline(16 - half - 1, 16 + half, y, 'k')
        c.hline(16 - half, 15 + half, y, 'd')
    c.stamp(12, 23, ['...g....', '..gGo...', '.GGoGg..', 'GoGGooG.', 'oGooGGoo'])
    c.put(19, 21, 'w')
    c.put(13, 20, 'g')
    c.outline()
    return c.rows()


# ---------------------------------------------------------------- 公會商店／旅店
def guild():
    c = Canvas()
    # Chimney behind the roof.
    c.rect(21, 3, 23, 8, 'R')
    c.vline(21, 3, 8, 'r')
    c.hline(20, 24, 2, 'x')
    # Slate roof in courses.
    tri_roof(c, 2, 12, 1.45, 'e', 'E', 'a')
    for y in range(4, 13, 3):
        for x in range(32):
            if c.get(x, y) in 'eE':
                c.put(x, y, 'a' if c.get(x, y) == 'E' else 'E')
    c.hline(1, 30, 13, 'k')
    # Half-timbered walls.
    c.rect(3, 14, 28, 27, 'P')
    c.rect(4, 15, 8, 19, 'p')
    c.rect(23, 15, 27, 19, 'p')
    for x in (3, 9, 22, 28):
        c.vline(x, 14, 27, '2')
    c.hline(3, 28, 14, '2')
    c.hline(3, 28, 20, '2')
    c.vline(27, 21, 27, 'q')
    # Lit windows.
    for x in (5, 24):
        c.rect(x - 1, 15, x + 3, 19, 'k')
        c.rect(x, 16, x + 2, 18, 'G')
        c.hline(x, x + 2, 16, 'g')
        c.vline(x + 1, 16, 18, 'k')
        c.hline(x, x + 2, 18, 'o')
        c.put(x + 1, 18, 'k')
    # Arched door.
    c.rect(12, 21, 19, 27, 'k')
    c.rect(13, 22, 18, 27, '4')
    c.vline(15, 22, 27, '3')
    c.vline(16, 22, 27, '3')
    c.rect(17, 22, 18, 27, '3')
    c.put(12, 21, '2')
    c.put(19, 21, '2')
    c.put(17, 24, 'G')
    # Hanging sign with a coin.
    c.hline(10, 21, 15, '2')
    c.put(12, 16, 'k')
    c.put(19, 16, 'k')
    c.rect(11, 17, 20, 20, 'k')
    c.rect(12, 18, 19, 19, 'p')
    c.hline(12, 19, 19, 'q')
    c.stamp(14, 17, ['.gG.', 'gGGo', 'GGoo', '.oo.'])
    c.hline(2, 29, 28, '2')
    c.outline()
    return c.rows()


# ---------------------------------------------------------------- tab icon
def town():
    return [
        '................',
        '.......kk.......',
        '......khRk......',
        '.....khrrRk.....',
        '....khrrrrRk....',
        '...khrrrrrrRk...',
        '..khrrrrrrrrRk..',
        '.kkkkkkkkkkkkkk.',
        '..kqqqqqqqqqQk..',
        '..kPGGPPPPGGqk..',
        '..kPooPPPPooqk..',
        '..kPPPkkkkPPqk..',
        '..kPPPk32kPPqk..',
        '..kPPPk32kPPqk..',
        '..kkkkkkkkkkkk..',
        '................',
    ]


SPRITES = [('dojo', dojo()), ('bank', bank()), ('casino', casino()), ('guild', guild())]
TOWN = town()

for name, rows in SPRITES + [('town', TOWN)]:
    size = len(rows)
    assert all(len(r) == size for r in rows), name

out_png = sys.argv[1] if len(sys.argv) > 1 else os.path.join(here, 'buildings32_preview.png')
png([r for _, r in SPRITES] + [TOWN], out_png, scale=8, bg=0xFF2F2127)

out = [
    "// Generated by docs/icon_candidates/buildings32.py; edit the script, not this file.",
    "import '../sprite.dart';",
    '',
    "/// 32×32 buildings of the town tab, lit from the top left.",
    'abstract final class PixelBuildings {',
]
for name, rows in SPRITES:
    out.append(f"  static const {name} = PixelSprite('{name}', [")
    out += [f"    '{r}'," for r in rows]
    out.append('  ]);')
    out.append('')
out[-1] = '}'
out += [
    '',
    '/// The 16×16 icon of the town tab.',
    "const kTownIcon = PixelSprite('town', [",
    *[f"  '{r}'," for r in TOWN],
    ']);',
]
open(os.path.join(root, 'lib/ui/pixel/sprites/buildings.dart'), 'w').write('\n'.join(out) + '\n')
print('wrote', out_png)
