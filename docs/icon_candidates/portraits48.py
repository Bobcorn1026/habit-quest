# The five class portraits at 48×48, in the same look as 莉娜 (mentor48.py):
# shared anime face, side shading from the top-left, gear drawn in layers.
# Writes lib/ui/pixel/sprites/portrait_art.dart and portraits48_preview.png.
#   python3 docs/icon_candidates/portraits48.py
import math, os, sys
here = os.path.dirname(os.path.abspath(__file__))
root = os.path.abspath(os.path.join(here, '../..'))
sys.path.insert(0, here)
from spritepng import png

N, CX = 48, 24
def inell(x, y, cx, cy, rx, ry): return ((x + .5 - cx) / rx) ** 2 + ((y + .5 - cy) / ry) ** 2 <= 1
def ell(cx, cy, rx, ry): return lambda x, y: inell(x, y, cx, cy, rx, ry)
def seg_dist(x, y, a, b):
    (ax, ay), (bx, by) = a, b
    px, py = x + .5, y + .5
    t = max(0, min(1, ((px - ax) * (bx - ax) + (py - ay) * (by - ay)) / ((bx - ax) ** 2 + (by - ay) ** 2)))
    return math.hypot(px - ax - t * (bx - ax), py - ay - t * (by - ay))

class Canvas:
    def __init__(s):
        s.g = [['.'] * N for _ in range(N)]
        s.tag = [['.'] * N for _ in range(N)]
    def put(s, x, y, c, tag=None):
        if 0 <= x < N and 0 <= y < N:
            s.g[y][x] = c
            if tag: s.tag[y][x] = tag
    def fill(s, name, mask, shader, only=None):
        for y in range(N):
            for x in range(N):
                if mask(x, y) and (only is None or s.tag[y][x] in only):
                    s.g[y][x] = shader(x, y); s.tag[y][x] = name
    def seam(s, upper, lower, c='k'):
        hits = []
        for y in range(N):
            for x in range(N):
                if s.tag[y][x] == upper and any(0 <= x + dx < N and 0 <= y + dy < N and s.tag[y + dy][x + dx] in lower
                                                for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1))):
                    hits.append((x, y))
        for x, y in hits: s.g[y][x] = c
    def stamp(s, x0, y0, rows, tag=None):
        for j, r in enumerate(rows):
            for i, c in enumerate(r):
                if c != '.': s.put(x0 + i, y0 + j, c, tag)
    def outline(s):
        hits = [(x, y) for y in range(N) for x in range(N) if s.g[y][x] == '.' and any(
            0 <= x + dx < N and 0 <= y + dy < N and s.g[y + dy][x + dx] != '.' for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)))]
        for x, y in hits: s.g[y][x] = 'k'
    def rows(s): return [''.join(r) for r in s.g]

def lit(x, y, cx, cy, rx, ry):  # light from the top-left, about -1.2 .. 1.2
    return -(((x + .5 - cx) / rx) * .6 + ((y + .5 - cy) / ry) * .8)
def pick(ramp, l):
    n = len(ramp)
    cuts = {2: [0], 3: [-.35, .35], 4: [-.55, 0, .55]}[n]
    return ramp[sum(l > c for c in cuts)]
def shader(ramp, cx, cy, rx, ry, bias=0, folds=None):
    def f(x, y):
        l = lit(x, y, cx, cy, rx, ry) + bias
        if folds:  # cloth folds / hair clumps fanning from a point
            ox, oy, w = folds
            u = (math.atan2(x + .5 - ox, y + .5 - oy) / w) % 1
            l += -.45 if (u < .15 or u > .88) else .3 if u < .45 else 0
        return pick(ramp, l)
    return f

# ---------------------------------------------------------------- shared pieces
FACE = {15: 9.0, 16: 9.4, 17: 9.6, 18: 9.7, 19: 9.7, 20: 9.7, 21: 9.6, 22: 9.5,
        23: 9.2, 24: 8.8, 25: 8.2, 26: 7.4, 27: 6.4, 28: 5.0, 29: 3.4}
def face_mask(x, y): return y in FACE and abs(x + .5 - CX) <= FACE[y]
def neck_mask(x, y): return 29 <= y <= 35 and abs(x + .5 - CX) <= 3.2
def body_mask(x, y, top=33):
    if y < top: return False
    half = 7 + (y - top) * 2.6 if y <= top + 2 else 12.2 + ((y - top - 2) ** .5) * 4.2
    return abs(x + .5 - CX) <= half

def skin(c, mask=face_mask, low=28, tones=('c', 's', 'S', 'C')):
    hi, base, shade, deep = tones
    def f(x, y):
        return shade if (x + .5 - CX > 6 or y >= low) else base
    c.fill('F', mask, f)
    c.fill('N', neck_mask, lambda x, y: (deep if abs(x + .5 - CX) < 2 else shade) if y == 30 else shade if x + .5 > CX else base, only='.')
    for (x, y) in ((18, 23), (19, 23), (18, 24)): c.put(x, y, hi)

def shade_under(c, covers):
    """Skin right under hair or gear falls into shadow."""
    for y in range(1, N):
        for x in range(N):
            if c.tag[y][x] == 'F' and c.tag[y - 1][x] in covers and c.g[y][x] in 'sc':
                c.g[y][x] = 'S'
            if c.tag[y][x] == 'F' and c.tag[y - 2][x] in covers and c.g[y][x] == 'S' and c.tag[y - 1][x] in covers:
                pass

def eyes(c, ramp, brow=None):
    d, m, l = ramp
    for x0, left in ((16, True), (27, False)):
        for x in range(x0, x0 + 5): c.put(x, 19, 'k')
        outer, inner = (x0, x0 + 4) if left else (x0 + 4, x0)
        c.put(outer, 20, 'k'); c.put(outer - 1 if left else outer + 1, 18, 'k')
        iris = [x0 + 1, x0 + 2, x0 + 3]
        c.put(iris[0], 20, 'w'); c.put(iris[1], 20, d); c.put(iris[2], 20, d)
        c.put(iris[0], 21, d); c.put(iris[1], 21, m); c.put(iris[2], 21, m)
        c.put(iris[0], 22, m); c.put(iris[1], 22, l); c.put(iris[2], 22, l)
        c.put(inner, 20, 'W'); c.put(inner, 21, 'w'); c.put(inner, 22, 'w')
        for x in iris: c.put(x, 23, 'C')
        if brow:
            for x in iris: c.put(x, 17, brow)
    c.put(24, 25, 'S')

def mouth(c, mode='smile'):
    if mode == 'smile':
        c.put(22, 27, 'S'); c.put(23, 28, 'C'); c.put(24, 28, 'C'); c.put(25, 27, 'S')
    else:
        c.put(23, 27, 'C'); c.put(24, 27, 'C')

def bangs(c, ramp, tips, y0=12, only=('F', 'H', '.')):
    """Strands hanging from y0: tips = [(centre x, tip y, half width)]."""
    which = {}
    for y in range(y0, max(t for _, t, _ in tips) + 1):
        for x in range(N):
            for k, (cx, tip, hw) in enumerate(tips):
                if y > tip: continue
                t = (y - y0) / max(1, tip - y0)
                if abs(x + .5 - cx) <= hw * (1 - t) + .45 and c.tag[y][x] in only:
                    v = (x + .5 - cx) / (hw * (1 - t) + .45)
                    i = 2 if v < -.2 else 1 if v < .45 else 0
                    if y >= tip - 1: i = 0
                    if x > 30: i = max(0, i - 1)
                    c.put(x, y, ramp[i], 'B'); which[(x, y)] = k
                    break
    for (x, y), k in which.items():
        if which.get((x + 1, y), k) != k: c.put(x, y, ramp[0] if ramp[0] != 'k' else 'k')

def finish(c):
    c.outline()
    rows = c.rows()
    assert len(rows) == N and all(len(r) == N for r in rows)
    return rows

# ---------------------------------------------------------------- knight
def knight():
    c = Canvas()
    steel = ['a', 'E', 'e', 'w']
    red = ['x', 'R', 'r', 'h']
    # plume falling down the back
    path = [(27, 3.5), (31, 2.4), (35, 3.2), (38.5, 5.8), (40.5, 9.5), (41.5, 13.5), (41.5, 18)]
    rad = [2.2, 2.7, 2.8, 2.6, 2.3, 2.0, 1.6]
    def plume(x, y):
        for i in range(len(path) - 1):
            for s in range(10):
                t = s / 10
                px = path[i][0] + (path[i + 1][0] - path[i][0]) * t
                py = path[i][1] + (path[i + 1][1] - path[i][1]) * t
                r = rad[i] + (rad[i + 1] - rad[i]) * t
                if (x + .5 - px) ** 2 + (y + .5 - py) ** 2 <= r * r: return True
        return False
    c.fill('P', plume, shader(red, 33, 6, 8, 8, folds=(27, 2, .35)))
    # body: chest plate, tabard, pauldrons
    c.fill('Bd', lambda x, y: body_mask(x, y, 34), shader(steel, 24, 36, 16, 12))
    def tabard(x, y): return y >= 37 and abs(x + .5 - CX) <= 6.5
    c.fill('T', tabard, shader(red, 22, 38, 9, 12))
    for y in range(37, N):
        c.put(17, y, 'G', 'T'); c.put(30, y, 'o', 'T')
    for x in range(17, 31): c.put(x, 37, 'G' if x < 26 else 'o', 'T')
    c.stamp(21, 39, ["..gG..", "..Go..", "gGGGGo", "GGGooO", "..Go..", "..Go..", "..Go..", "..oO.."], 'X')
    for cx in (10.5, 37.5):
        m = ell(cx, 39.5, 10.5, 6.5)
        c.fill('Pa' + str(cx), lambda x, y, m=m: m(x, y) and y >= 33, shader(steel, cx - 2, 36, 9, 6))
        for y in (38, 41):  # overlapping lames
            for x in range(N):
                if c.tag[y][x] == 'Pa' + str(cx): c.put(x, y, 'a')
        c.put(int(cx) - 4, 36, 'w'); c.put(int(cx) + 3, 36, 'w')
    c.seam('Pa10.5', ('Bd', 'T')); c.seam('Pa37.5', ('Bd', 'T'))
    # gorget
    c.fill('Go', lambda x, y: 31 <= y <= 35 and abs(x + .5 - CX) <= 7 - (35 - y) * .6, shader(steel, 21, 31, 6, 4))
    for x in range(N):
        if c.tag[33][x] == 'Go': c.put(x, 33, 'a')
    # face
    skin(c)
    eyes(c, ('u', 'T', 't'))
    mouth(c, 'smile')
    # helmet: dome, cheek plates, brow band, raised visor, crest
    dome = ell(24, 15.5, 13.6, 13)
    def helm(x, y):
        if y <= 16 and dome(x, y): return True
        if 15 <= y <= 31:
            inset = max(0, y - 26) * .9
            return (10.6 + inset <= x + .5 <= 17.3) or (30.7 <= x + .5 <= 37.4 - inset)
        return False
    c.fill('Hm', helm, shader(steel, 21, 10, 14, 14))
    for y in range(15, 18):
        for x in range(11, 37):
            if c.tag[y][x] in ('F', 'Hm', '.') and dome(x, y - 2) or (c.tag[y][x] == 'Hm'):
                pass
    c.fill('Br', lambda x, y: 15 <= y <= 17 and 11 <= x <= 36, lambda x, y: 'G' if y == 15 and x < 30 else 'o' if y == 15 else ('e' if x < 20 else 'E' if x < 30 else 'a'))
    def visor(x, y): return 7 <= y <= 14 and dome(x, y) and 12 <= x <= 35
    c.fill('V', visor, shader(steel, 20, 8, 12, 6, bias=.2))
    for y in (10, 12):
        for x in range(15, 34, 3): c.put(x, y, 'k'); c.put(x + 1, y, 'k')
    for x in range(12, 36):
        if c.tag[14][x] == 'V': c.put(x, 14, 'a')
        if c.tag[7][x] == 'V': c.put(x, 7, 'k')
    for y in range(2, 8): c.put(23, y, 'g' if y < 5 else 'G', 'Cr'); c.put(24, y, 'o', 'Cr')
    for (x, y) in ((12, 19), (12, 23), (12, 27), (35, 19), (35, 23), (35, 27)):
        c.put(x, y, 'w'); c.put(x, y + 1, 'a')
    c.seam('Hm', ('F',)); c.seam('Br', ('F',))
    shade_under(c, ('Hm', 'Br', 'V'))
    bangs(c, ['o', 'G', 'g'], [(20.5, 19, 1.6), (23.5, 20, 1.8), (26.5, 19, 1.6)], y0=18, only=('F',))
    return finish(c)

# ---------------------------------------------------------------- mage
# Her own face: a softer oval, eyes a row lower and taller, an open smile;
# silver bob with a braid over the shoulder. GLASSES adds round spectacles.
MAGE_FACE = {15: 8.8, 16: 9.2, 17: 9.4, 18: 9.5, 19: 9.5, 20: 9.5, 21: 9.4, 22: 9.3,
             23: 9.1, 24: 8.8, 25: 8.4, 26: 7.8, 27: 7.0, 28: 5.8, 29: 4.4, 30: 2.6}

def flowing_lock(pts, r0, r1):
    """Pixels of a tapered lock along pts: {(x, y): (t along, s across -1..1)}."""
    out = {}
    segs = list(zip(pts, pts[1:]))
    total = sum(math.dist(a, b) for a, b in segs)
    for y in range(N):
        for x in range(N):
            best = None
            run = 0
            for a, b in segs:
                L = math.dist(a, b)
                px, py = x + .5, y + .5
                u = max(0, min(1, ((px - a[0]) * (b[0] - a[0]) + (py - a[1]) * (b[1] - a[1])) / (L * L)))
                cx, cy = a[0] + u * (b[0] - a[0]), a[1] + u * (b[1] - a[1])
                t = (run + u * L) / total
                r = r0 + (r1 - r0) * t
                d = math.hypot(px - cx, py - cy)
                if d <= r and (best is None or d < best[0]):
                    nx = (b[1] - a[1]) / L  # normal pointing right of travel
                    side = ((px - cx) * -nx + (py - cy) * ((b[0] - a[0]) / L)) / max(r, .5)
                    best = (d, t, -side)
                run += L
            if best: out[(x, y)] = (best[1], best[2])
    return out

def paint_lock(c, lock, ramp, shadow=0, tag='K'):
    for (x, y), (t, side) in lock.items():
        i = 2 if side < -.25 else 1 if side < .45 else 0
        if side < -.6 and t < .6: i = 3
        i = max(0, i - shadow)
        if t > .85: i = max(0, i - 1)
        c.put(x, y, ramp[i], tag)
def mage_face(x, y): return y in MAGE_FACE and abs(x + .5 - CX) <= MAGE_FACE[y]

def mage_eyes(c):
    for x0, left in ((16, True), (27, False)):
        outer, inner = (x0, x0 + 4) if left else (x0 + 4, x0)
        iris = [x0 + 1, x0 + 2, x0 + 3]
        for x in iris: c.put(x, 19, 'k')
        c.put(outer, 19, 'k'); c.put(outer - 1 if left else outer + 1, 19, 'k')   # lash sweeping out
        c.put(outer, 20, 'k'); c.put(inner, 20, 'k')
        c.put(iris[0], 20, 'w'); c.put(iris[1], 20, 'i'); c.put(iris[2], 20, 'i')
        c.put(outer, 21, 'k'); c.put(iris[0], 21, 'i'); c.put(iris[1], 21, 'V'); c.put(iris[2], 21, 'V'); c.put(inner, 21, 'W')
        c.put(iris[0], 22, 'V'); c.put(iris[1], 22, 'v'); c.put(iris[2], 22, 'v'); c.put(inner, 22, 'w')
        c.put(iris[0], 23, 'v'); c.put(iris[1], 23, 'w'); c.put(iris[2], 23, 'v')
        for x in iris: c.put(x, 24, 'C')
    c.put(24, 26, 'S')
    c.put(22, 28, 'C'); c.put(23, 29, 'C'); c.put(24, 29, 'C'); c.put(25, 28, 'C')   # gentle closed smile
    for x in (15, 16, 31, 32): c.put(x, 25, 'h')

def mage(glasses=False):
    c = Canvas()
    vio = ['d', 'i', 'V', 'v']
    silver = ['a', 'E', 'e', 'w']
    # silver bob behind the face
    def bob(x, y):  # nothing behind the chin, so the jaw reads clean
        if y >= 28 or (y >= 25 and abs(x + .5 - CX) < 8.6): return False
        return y >= 11 and inell(x, y, 24, 20, 13.8, 12)
    c.fill('H', bob, shader(silver, 22, 16, 14, 13, bias=.25, folds=(24, 8, .3)))
    c.fill('Bd', body_mask, shader(vio, 22, 36, 16, 12, folds=(24, 30, .35)))
    def opening(x, y): return y >= 34 and abs(x + .5 - CX) <= 2 + (y - 34) * .35
    c.fill('U', opening, lambda x, y: 'p' if x + .5 < CX else 'P')
    for y in range(34, N):
        w = 2 + (y - 34) * .35
        c.put(round(CX - w - 1), y, 'G'); c.put(round(CX + w), y, 'o')
    for x in range(15, 34):
        y = round(34.5 + ((x + .5 - CX) / 8) ** 2 * 2)
        if abs(x + .5 - CX) <= 8.5: c.put(x, y, 'G' if x % 2 else 'o')
    c.stamp(22, 36, [".kk.", "ktTk", "kTuk", ".kk."])
    skin(c, mage_face, low=29)
    mage_eyes(c)
    if glasses:
        for x0 in (15, 26):
            for x in range(x0 + 1, x0 + 6): c.put(x, 18, 'O'); c.put(x, 25, 'O')
            for y in range(19, 25): c.put(x0, y, 'O'); c.put(x0 + 6, y, 'O')
            c.put(x0 + 1, 19, 'w')
        for x in (22, 23, 24, 25): c.put(x, 21, 'O')
        c.put(14, 21, 'O'); c.put(33, 21, 'O')
    # side locks that flow and taper instead of hanging like slabs
    for pts, r0, r1, sh in (
            ([(14.5, 13), (12.2, 18), (11.0, 23), (11.4, 28), (12.8, 32.5)], 3.1, .6, 0),
            ([(16.2, 16), (15.2, 21), (15.6, 26.5)], 1.7, .5, 0),
            ([(33.5, 13), (35.8, 18), (37.0, 23), (36.6, 28), (35.2, 32.5)], 3.1, .6, 1),
            ([(31.8, 16), (32.8, 21), (32.4, 26.5)], 1.7, .5, 1)):
        paint_lock(c, flowing_lock(pts, r0, r1), silver, shadow=sh)
    c.seam('K', ('F',), 'a')
    # short bangs swept to one side
    bangs(c, ['a', 'E', 'e'], [(15, 23, 2.4), (18, 19, 2.4), (21, 21, 2.4), (24, 20, 2.4), (27, 21, 2.4), (30, 19, 2.4), (33, 23, 2.4), (35.2, 24, 1.8)], y0=13)
    # braid over the left shoulder, tied with a violet ribbon
    for k, y in enumerate(range(26, 42)):
        x0 = 11 + (k // 3) % 2
        for x in range(x0, x0 + 4):
            c.put(x, y, 'a' if y % 3 == 0 else ('w' if x == x0 + 1 else 'e' if x < x0 + 3 else 'E'), 'Bw')
    c.seam('Bw', ('Bd', 'U', 'F', 'N'))
    c.stamp(10, 41, ["kVVk", "kvVk", ".ii."], 'Bw')
    # hat: wide brim and a cone that leans back, its tip drooping
    # sits a little higher than before so the bangs show under the brim
    brim = ell(24, 12.6, 20.8, 3.3)
    def cone(x, y):
        if y < 1 or y > 11: return False
        cx = 24 + (11 - y) * .6
        w = 10.8 * (y / 11.5) ** 1.1
        return abs(x + .5 - cx) <= w
    def tip(x, y): return inell(x, y, 33.6, 1.9, 2.6, 1.0) or inell(x, y, 35.8, 3.2, 1.3, 1.3)
    c.fill('Ht', lambda x, y: cone(x, y) or tip(x, y), shader(vio, 28, 4, 9, 7, folds=(31, 0, .45)))
    c.fill('Hb', brim, lambda x, y: pick(vio, lit(x, y, 18, 10.2, 21, 3.3) + (.35 if y <= 11 else -.6)))
    for x in range(N):
        for y in (8, 9):
            if c.tag[y][x] == 'Ht': c.put(x, y, 'G' if x < 27 else 'o')
        if c.tag[10][x] == 'Ht': c.put(x, 10, 'O')
    c.stamp(26, 4, [".g.", "gGo", ".o."])
    c.seam('Hb', ('Ht',)); c.seam('Hb', ('F', 'B', 'H'))
    shade_under(c, ('Hb', 'B'))
    return finish(c)

# ---------------------------------------------------------------- hooded classes
def hood(c, ramp, open_rx=10.6, open_ry=11, deep=False):
    outer = ell(24, 18.5, 16.6, 16.8)
    hole = ell(24, 22.2, open_rx, open_ry)
    def back(x, y): return (outer(x, y) and y >= 1) or (28 <= y <= 37 and abs(x + .5 - CX) <= 13 + (y - 28) * .9)
    return outer, hole, back

RANGER_FACE = {15: 9.0, 16: 9.4, 17: 9.6, 18: 9.7, 19: 9.7, 20: 9.7, 21: 9.7, 22: 9.6,
               23: 9.4, 24: 9.1, 25: 8.6, 26: 7.9, 27: 6.9, 28: 5.5, 29: 3.6}
def ranger_face(x, y): return y in RANGER_FACE and abs(x + .5 - CX) <= RANGER_FACE[y]

def ranger_eyes(c):
    """Sharp, narrow green eyes under brows pressed low; a smirk and freckles."""
    for x0, left in ((16, True), (27, False)):
        outer, inner = (x0, x0 + 4) if left else (x0 + 4, x0)
        iris = [x0 + 1, x0 + 2, x0 + 3]
        for x in range(x0, x0 + 5): c.put(x, 20, 'k')
        c.put(outer - 1 if left else outer + 1, 19, 'k')
        c.put(outer, 21, 'k')
        c.put(iris[0], 21, 'w'); c.put(iris[1], 21, 'l'); c.put(iris[2], 21, 'N'); c.put(inner, 21, 'W')
        c.put(iris[0], 22, 'N'); c.put(iris[1], 22, 'n'); c.put(iris[2], 22, 'n'); c.put(inner, 22, 'w')
        for x in iris: c.put(x, 23, 'C')
    for (x, y) in ((16, 17), (17, 17), (18, 18), (19, 18)): c.put(x, y, '2')
    for (x, y) in ((31, 17), (30, 17), (29, 18), (28, 18)): c.put(x, y, '2')
    c.put(24, 25, 'S')
    for (x, y) in ((22, 28), (23, 28), (24, 28), (25, 27)): c.put(x, y, 'C')   # smirk
    for (x, y) in ((16, 25), (18, 25), (17, 24), (30, 24), (31, 25), (32, 24)): c.put(x, y, 'S')  # freckles

def ranger():
    c = Canvas()
    green = ['l', 'N', 'n']
    leather = ['1', 'b', '4']
    outer, hole, back = hood(c, green)
    # quiver behind the right shoulder, stitched, three arrows sticking out
    c.fill('Q', lambda x, y: seg_dist(x, y, (34, 22), (41, 38)) <= 2.8, shader(leather, 36, 26, 4, 8))
    for x in range(N):
        for y in range(N):
            if c.tag[y][x] == 'Q':
                d = seg_dist(x, y, (34, 22), (41, 38))
                if y in (24, 33): c.put(x, y, 'o')
                elif 1.6 < d < 2.3 and y % 2 == 0: c.put(x, y, 'P')
    for (ax, ay) in ((33, 15), (36, 14), (39, 16)):
        for k in range(7): c.put(ax + k // 3, ay + k, 'P', 'A')
        c.stamp(ax - 1, ay - 2, ["hr.", "rhw", ".w."], 'A')
    c.fill('Bd', lambda x, y: body_mask(x, y, 34), shader(green, 20, 36, 16, 12, folds=(24, 27, .3)))
    for y in range(34, N):  # light catching the top of the cloak
        for x in range(N):
            if c.tag[y][x] == 'Bd' and c.tag[y - 1][x] != 'Bd' and x < 30: c.put(x, y, 'n')
    c.fill('U', lambda x, y: y >= 36 and abs(x + .5 - CX) <= 3.5, lambda x, y: '4' if x + .5 < CX else '3')
    for y in range(36, N):
        c.put(20, y, 'l'); c.put(27, y, 'l')
        if y % 2 == 0 and y < 46: c.put(23, y, 'P'); c.put(24, y, '1')   # laces
        elif y < 46: c.put(23, y, '1'); c.put(24, y, 'P')
    for x in range(N):
        for y in range(34, N):
            if c.tag[y][x] in ('Bd', 'U') and seg_dist(x, y, (13, 34), (36, 48)) <= 1.1: c.put(x, y, 'b')
            if c.tag[y][x] in ('Bd', 'U') and .9 < seg_dist(x, y, (13, 34), (36, 48)) <= 1.6 and (x + y) % 2: c.put(x, y, '1')
    c.stamp(28, 42, ["GGo", "GkO", "oOO"])
    c.fill('Hd', back, shader(green, 20, 12, 16, 16, folds=(24, 2, .4)), only=('.',))
    skin(c, ranger_face)
    ranger_eyes(c)
    # messy bangs, a couple of strands sticking out
    bangs(c, ['2', '4', '5'], [(15.5, 21, 2.3), (18, 18, 2.0), (20.5, 20, 2.2), (23, 17, 2.0), (25.5, 20, 2.2), (28, 18, 2.0), (30.5, 21, 2.2), (32.5, 19, 1.6)], y0=12, only=('F', '.', 'Hd'))
    for (x, y) in ((15, 17), (16, 17), (17, 17), (31, 17), (32, 17)):
        if c.tag[y][x] == 'B': c.put(x, y, '1')
    def front(x, y): return outer(x, y) and not hole(x, y) and y <= 31
    c.fill('Hf', front, shader(green, 20, 12, 16, 16, bias=.15, folds=(24, 2, .4)), only=('Hd', 'F', 'B', '.', 'N'))
    rim = []
    for y in range(N):
        for x in range(N):
            if c.tag[y][x] == 'Hf' and (hole(x - 1, y) or hole(x + 1, y) or hole(x, y + 1)): rim.append((x, y))
    for x, y in rim: c.put(x, y, 'l')
    for x, y in rim:  # stitching just inside the rim
        for dx, dy in ((-1, -1), (1, -1), (0, -1)):
            if c.tag[y + dy][x + dx] == 'Hf' and (x + dx, y + dy) not in rim and (x + y) % 2 == 0: c.put(x + dx, y + dy, 'n')
    for y in range(1, N):
        for x in range(N):
            if c.tag[y][x] == 'F' and c.tag[y - 1][x] in ('Hf', 'B') and c.g[y][x] in 'sc': c.put(x, y, 'S')
    c.stamp(21, 34, ["..gGG.", ".gGGo.", "gGGoO.", ".oOO.."], 'Lf')   # leaf clasp
    return finish(c)

def rogue():
    c = Canvas()
    dark = ['d', 'D', 'm', 'M']
    outer, hole, back = hood(c, dark, open_rx=9.8, open_ry=10.4)
    # dagger over the left shoulder
    for k in range(9): c.put(7 + k // 2, 20 + k, 'e' if k % 2 else 'w', 'Dg'); c.put(8 + k // 2, 20 + k, 'E', 'Dg')
    c.stamp(9, 28, ["oGGo", ".bb.", ".b1."], 'Dg')
    c.fill('Bd', lambda x, y: body_mask(x, y, 34), shader(dark, 20, 36, 16, 12, folds=(24, 28, .4)))
    for x in range(N):
        for y in range(34, N):
            if c.tag[y][x] == 'Bd' and seg_dist(x, y, (37, 34), (11, 48)) <= 1.4: c.put(x, y, 'R' if seg_dist(x, y, (37, 34), (11, 48)) > .6 else 'r')
    c.fill('Hd', back, shader(dark, 20, 12, 16, 16, folds=(24, 2, .4)), only=('.',))
    skin(c)
    eyes(c, ('O', 'o', 'G'))
    # cloth mask over nose and mouth
    def cloth(x, y): return 24 <= y <= 31 and hole(x, y) and not (y == 24 and abs(x + .5 - CX) > 7)
    c.fill('M', cloth, shader(['x', 'R', 'r'], 20, 25, 10, 6))
    for x in range(N):
        if c.tag[24][x] == 'M': c.put(x, 24, 'k')
        if c.tag[28][x] == 'M' and x % 3 == 0: c.put(x, 28, 'x')
    bangs(c, ['d', 'm', 'M'], [(16.5, 18, 2.2), (19.5, 19, 2.0), (22.5, 17, 2.2), (25.5, 19, 2.0), (28.5, 18, 2.2), (31.5, 17, 2.0)], y0=13, only=('F', '.', 'Hd'))
    def front(x, y): return outer(x, y) and not hole(x, y) and y <= 31
    c.fill('Hf', front, shader(dark, 20, 12, 16, 16, bias=.1, folds=(24, 2, .4)), only=('Hd', 'F', 'B', '.', 'N', 'M'))
    for y in range(N):
        for x in range(N):
            if c.tag[y][x] == 'Hf' and (hole(x - 1, y) or hole(x + 1, y) or hole(x, y + 1)): c.put(x, y, 'd')
    for y in range(13, 20):  # the hood's shadow over the brow
        for x in range(N):
            if c.tag[y][x] == 'F' and c.g[y][x] in 'sScC': c.put(x, y, 'C' if y < 17 else 'S')
    return finish(c)

CLERIC_FACE = {15: 9.2, 16: 9.6, 17: 9.8, 18: 9.9, 19: 9.9, 20: 9.9, 21: 9.8, 22: 9.7,
               23: 9.5, 24: 9.2, 25: 8.8, 26: 8.1, 27: 7.2, 28: 6.0, 29: 4.2}
def cleric_face(x, y): return y in CLERIC_FACE and abs(x + .5 - CX) <= CLERIC_FACE[y]

def cleric_eyes(c):
    """Gentle drooping eyes with long lashes, blush and a soft smile."""
    for x0, left in ((16, True), (27, False)):
        o = (lambda i: x0 + i) if left else (lambda i: x0 + 4 - i)   # i=0 outer .. 4 inner
        for i in (2, 3, 4): c.put(o(i), 19, 'k')
        c.put(o(0), 20, 'k'); c.put(o(1), 20, 'k'); c.put(o(4), 20, 'k')
        c.put(o(0) - 1 if left else o(0) + 1, 21, 'k')
        c.put(o(0), 21, 'k')
        iris = sorted([o(1), o(2), o(3)])
        c.put(iris[1], 20, 'w') if not left else c.put(iris[1], 20, 'w')
        c.put(iris[2] if left else iris[2], 20, 'u')
        c.put(iris[0], 21, 'u'); c.put(iris[1], 21, 'T'); c.put(iris[2], 21, 'T'); c.put(o(4), 21, 'W')
        c.put(iris[0], 22, 'T'); c.put(iris[1], 22, 't'); c.put(iris[2], 22, 't'); c.put(o(4), 22, 'w')
        for x in iris: c.put(x, 23, 'C')
    c.put(24, 25, 'S')
    c.put(22, 27, 'C'); c.put(23, 28, 'C'); c.put(24, 28, 'C'); c.put(25, 27, 'C')
    for (x, y) in ((15, 24), (16, 25), (17, 24), (30, 24), (31, 25), (32, 24)): c.put(x, y, 'h')

def cleric():
    c = Canvas()
    white = ['E', 'e', 'w']
    gold = ['o', 'G', 'g']
    outer, hole, back = hood(c, white)
    c.fill('Bd', lambda x, y: body_mask(x, y, 34), shader(white, 18, 36, 16, 12, folds=(24, 27, .3)))
    c.fill('Co', lambda x, y: y >= 33 and (inell(x, y, CX - 5, 35, 6, 2.6) or inell(x, y, CX + 5, 35, 6, 2.6)),
           lambda x, y: 'w' if x < CX else 'e')
    c.seam('Co', ('Bd',), 'E')
    for side in (-1, 1):  # teal stole with gold edges and little crosses
        for y in range(36, N):
            for d in range(3, 7):
                x = round(CX - .5 + side * d)
                c.put(x, y, 'G' if d in (3, 6) and side < 0 else 'o' if d in (3, 6) else ('t' if side < 0 else 'T') if d == 4 else 'T' if side < 0 else 'u', 'St')
        cx = round(CX - .5 + side * 4.5)
        for yy in (40, 45):
            c.put(cx, yy - 1, 'g'); c.put(cx - 1 if side < 0 else cx, yy, 'g'); c.put(cx if side < 0 else cx + 1, yy, 'G'); c.put(cx, yy + 1, 'o')
    for k, y in enumerate(range(35, 40)):  # rosary down to the cross
        c.put(23 + (k % 2), y, 'o' if k % 2 else 'G')
    c.stamp(22, 40, [".gG.", "gGGo", ".Go.", ".Go.", ".oO."], 'X')
    c.fill('Hd', back, shader(white, 20, 12, 16, 16, folds=(24, 2, .4)), only=('.',))
    skin(c, cleric_face, low=29)
    cleric_eyes(c)
    # parted bangs and two long golden locks falling onto the chest
    bangs(c, gold, [(15.5, 21, 2.3), (18, 20, 2.2), (20.8, 18, 2.2), (27.2, 18, 2.2), (30, 20, 2.2), (32.5, 21, 2.3)], y0=13, only=('F', '.', 'Hd'))
    for pts, sh in (([(15.5, 20), (14.2, 26), (14.6, 32), (16.4, 38.5)], 0), ([(32.5, 20), (33.8, 26), (33.4, 32), (31.6, 38.5)], 1)):
        paint_lock(c, flowing_lock(pts, 2.4, .6), ['O', 'o', 'G', 'g'], shadow=sh, tag='L')
    c.seam('L', ('Bd', 'Co', 'St'), 'k')
    def front(x, y): return outer(x, y) and not hole(x, y) and y <= 31
    c.fill('Hf', front, shader(white, 20, 12, 16, 16, bias=.15, folds=(24, 2, .4)), only=('Hd', 'F', 'B', '.', 'N', 'L'))
    rim = []
    for y in range(N):
        for x in range(N):
            if c.tag[y][x] == 'Hf' and (hole(x - 1, y) or hole(x + 1, y) or hole(x, y + 1)): rim.append((x, y))
    for x, y in rim: c.put(x, y, 'G' if x < 26 else 'o')
    for x, y in rim:  # embroidered dots inside the trim
        for dx, dy in ((-1, -1), (1, -1)):
            if c.tag[y + dy][x + dx] == 'Hf' and (x + dx, y + dy) not in rim and (x + 2 * y) % 3 == 0: c.put(x + dx, y + dy, 'o')
    c.stamp(22, 8, [".kk.", "ktTk", "kTuk", ".kk."])
    shade_under(c, ('Hf', 'B'))
    return finish(c)

cast = {'knight': knight(), 'mage': mage(glasses=True), 'ranger': ranger(), 'rogue': rogue(), 'cleric': cleric()}
out = ["// Generated by docs/icon_candidates/portraits48.py — edit the script, not this file.",
       "import '../sprite.dart';", "",
       "/// The adventurer portraits at 48×48, drawn to match 莉娜.",
       "abstract final class PortraitArt {"]
for name, rows in cast.items():
    out.append(f"  static const {name} = PixelSprite('{name}', [")
    out += [f"    '{r}'," for r in rows]
    out.append("  ]);")
    out.append("")
out[-1] = "}"
open(os.path.join(root, 'lib/ui/pixel/sprites/portrait_art.dart'), 'w').write('\n'.join(out) + '\n')
png(list(cast.values()), os.path.join(here, 'portraits48_preview.png'), scale=6, gap=3)
print('ok')
