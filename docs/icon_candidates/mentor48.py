# 莉娜 at 48×48 with her animation frames (idle, blink, yawn).
# Writes lib/ui/pixel/sprites/mentor_frames.dart and mentor48_preview.png.
#   python3 docs/icon_candidates/mentor48.py
import math, os, sys
here = os.path.dirname(os.path.abspath(__file__))
root = os.path.abspath(os.path.join(here, '../..'))
sys.path.insert(0, here)
from spritepng import png

N, CX = 48, 24
def inell(x, y, cx, cy, rx, ry): return ((x + .5 - cx) / rx) ** 2 + ((y + .5 - cy) / ry) ** 2 <= 1

# ---------------------------------------------------------------- shapes
FACE = {15: 9.0, 16: 9.4, 17: 9.6, 18: 9.7, 19: 9.7, 20: 9.7, 21: 9.6, 22: 9.5,
        23: 9.2, 24: 8.8, 25: 8.2, 26: 7.4, 27: 6.4, 28: 5.0, 29: 3.4}
def face(x, y): return y in FACE and abs(x + .5 - CX) <= FACE[y]
def neck(x, y): return 29 <= y <= 34 and abs(x + .5 - CX) <= 3.2
def hair_back(x, y):
    if y >= 3 and inell(x, y, CX, 17.5, 15.2, 14.5): return True
    if 18 <= y <= 41:  # long hair falling behind the shoulders
        w = 3.6 - max(0, y - 31) * 0.3
        return abs(x + .5 - (CX - 12.5)) <= w or abs(x + .5 - (CX + 12.5)) <= w
    return False
def body(x, y):
    if y < 33: return False
    half = 7 + (y - 33) * 2.6 if y <= 35 else 11.5 + ((y - 35) ** .5) * 4.0
    return abs(x + .5 - CX) <= half
def collar(x, y):
    return inell(x, y, CX - 4.2, 34.2, 5.0, 2.6) or inell(x, y, CX + 4.2, 34.2, 5.0, 2.6)
# side locks hang in front of the cheeks so the face reads slimmer
LOCK_IN = {**{y: 15 for y in range(13, 22)}, **{y: 16 for y in range(22, 28)}, 28: 16, 29: 15, 30: 14, 31: 13}
def lock_left(x, y): return y in LOCK_IN and 10 <= x <= LOCK_IN[y] and hair_back(x, y)
def lock_right(x, y): return lock_left(N - 1 - x, y)
# bangs: strands hanging from the hairline, (centre x, tip y, half width)
BANGS = [(13.5, 17, 2.4), (16.5, 19, 2.2), (19.5, 18, 2.2), (22.5, 20, 2.0),
         (25.5, 17, 2.2), (28.5, 19, 2.2), (31.5, 18, 2.2), (34.5, 16, 2.4)]
def bang(x, y):
    for cx, tip, hw in BANGS:
        if 10 <= y <= tip:
            t = (y - 10) / max(1, tip - 10)
            if abs(x + .5 - cx) <= hw * (1 - t) + 0.45: return (cx, tip)
    return None

# ---------------------------------------------------------------- base drawing
def draw():
    g = [['.'] * N for _ in range(N)]
    tag = [['.'] * N for _ in range(N)]
    for y in range(N):
        for x in range(N):
            t = '.'
            if hair_back(x, y): t = 'H'
            if body(x, y): t = 'B'
            if neck(x, y): t = 'N'
            if face(x, y): t = 'F'
            if collar(x, y) and y >= 32: t = 'L'
            if face(x, y) or (hair_back(x, y) and y < 31):
                if lock_left(x, y) or lock_right(x, y): t = 'K'
                if y <= 20 and bang(x, y) and t in 'FH': t = 'G'
            tag[y][x] = t
    # outline against the background
    for y in range(N):
        for x in range(N):
            if tag[y][x] == '.' and any(0 <= x + dx < N and 0 <= y + dy < N and tag[y + dy][x + dx] != '.'
                                        for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1))):
                g[y][x] = 'k'
    def light(x, y):  # light from the top-left
        dx, dy = (x + .5 - CX) / 15.2, (y + .5 - 17.5) / 14.5
        return -(dx * .6 + dy * .8)
    hair_ramp = ['x', 'R', 'z', 'f', 'F']
    for y in range(N):
        for x in range(N):
            t = tag[y][x]
            base = {'F': 's', 'N': 'S', 'B': 'T', 'L': 'w'}.get(t)
            if base: g[y][x] = base
            if t not in 'HKG': continue
            l = light(x, y)
            i = 4 if l > .6 else 3 if l > -.1 else 2 if l > -.6 else 1
            if t == 'H':  # locks of hair fanning out from the crown
                th = math.atan2(x + .5 - CX, y + .5 - 3.5)
                u = (th / .3) % 1
                if math.hypot(x + .5 - CX, y + .5 - 3.5) > 5:
                    i += -1 if (u < .16 or u > .86) else 1 if u < .46 else 0
                if y >= 31: i = min(i, 2)
                i = min(i, 4)
            elif t == 'K':  # side locks: lit outer edge, dark seam on the cheek side
                left = x < CX
                edge_out = not (lock_left(x - 1, y) if left else lock_right(x + 1, y))
                edge_in = not (lock_left(x + 1, y) if left else lock_right(x - 1, y))
                i = (3 if left else 2) + (1 if edge_out and left else 0) - (1 if edge_in else 0)
            else:  # bangs: each strand lit on its left, shaded on its right and tip
                cx, tip = bang(x, y)
                hw = [b[2] for b in BANGS if b[0] == cx][0]
                tt = (y - 10) / max(1, tip - 10)
                v = (x + .5 - cx) / (hw * (1 - tt) + .45)
                i = (4 if x < 22 else 3) if v < -.2 else 3 if v < .45 else 2
                if y >= tip - 1: i = min(i, 2)
                if x >= 30: i -= 1
            g[y][x] = hair_ramp[max(0, min(4, i))]
    for y in range(10, 21):  # dark line between neighbouring bang strands
        for x in range(N - 1):
            if tag[y][x] == 'G' and tag[y][x + 1] == 'G' and bang(x, y) != bang(x + 1, y): g[y][x] = 'R'
    # angel ring and sparkle on the crown
    for y in range(6, 11):
        for x in range(N):
            if tag[y][x] == 'H' and inell(x, y, CX - 1, 15, 12.5, 7.6) and not inell(x, y, CX - 1, 15, 11.6, 6.6) and x < 29:
                g[y][x] = 'g' if (x + y) % 4 == 0 and x < 22 else 'F'
    # dark seams between parts
    def seam(a, b, c='k'):
        for y in range(N):
            for x in range(N):
                if tag[y][x] == a and any(0 <= x + dx < N and 0 <= y + dy < N and tag[y + dy][x + dx] in b
                                          for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1))):
                    g[y][x] = c
    seam('H', 'BN')                 # hair over the shoulders
    seam('B', 'L')                  # collar edge
    seam('K', 'F', 'R')             # locks over the cheeks
    for (cx, tip) in [(b[0], b[1]) for b in BANGS]:  # bang tips
        x = int(cx); y = tip
        if tag[y][x] == 'G': g[y][x] = 'z'
    # skin shading
    for y in range(N):
        for x in range(N):
            if tag[y][x] != 'F': continue
            above = tag[y - 1][x]
            if above in 'GH': g[y][x] = 'S'                       # under the bangs
            elif tag[y][x - 1] == 'K': g[y][x] = 'S'              # beside the left lock
            elif tag[y][x + 1] == 'K': g[y][x] = 'C'              # in the right lock's shadow
            elif x >= CX + 6 or y >= 28: g[y][x] = 'S'
    for y in (23, 24):
        for x in (18, 19): g[y][x] = 'c'                           # lit cheek
    for y in range(29, 34):  # neck: shadow under the chin, lit left
        for x in range(N):
            if tag[y][x] == 'N':
                d = x + .5 - CX
                g[y][x] = ('C' if abs(d) < 2 else 'S') if y == 30 else 'S' if d > .5 else 's'
    # jaw line where the face meets hair or neck
    for y in range(24, 31):
        for x in range(N):
            if tag[y][x] == 'F' and y + 1 < N and tag[y + 1][x] in 'HN' and g[y + 1][x] not in 'k':
                if tag[y + 1][x] == 'H': g[y + 1][x] = 'k'
    # body: teal vest, lit left, white shirt in a V, gold brooch
    for y in range(33, N):
        for x in range(N):
            if tag[y][x] != 'B': continue
            d = x + .5 - CX
            c = 'T'
            if d < -7 and (tag[y - 1][x] != 'B' or tag[y - 2][x] != 'B'): c = 't'  # lit shoulder
            if d > 9: c = 'u'
            if abs(abs(d) - 15.5) < .6 and y >= 39: c = 'u'                         # arm creases
            v = 4 - (y - 35) * .45
            if y >= 35 and abs(d) <= v: c = 'w' if d < 1 else 'W'
            elif 35 <= y <= 44 and abs(abs(d) - v) < .8: c = 'G' if d < 0 else 'o'  # gold-trimmed lapels
            g[y][x] = c
    for y in range(N):
        for x in range(N):
            if tag[y][x] == 'L' and (x > CX + 3 or y >= 36): g[y][x] = 'W'
    for (x, y, c) in ((23, 34, 'g'), (24, 34, 'G'), (23, 35, 'G'), (24, 35, 'o'), (22, 34, 'k'), (25, 34, 'k'),
                      (22, 35, 'k'), (25, 35, 'k'), (23, 36, 'o'), (24, 36, 'O'), (23, 33, 'k'), (24, 33, 'k')):
        g[y][x] = c
    for j, r in enumerate(["kGGk", "kgok", "kGok", ".kk."]):         # guild badge
        for i, c in enumerate(r):
            if c != '.': g[40 + j][13 + i] = c
    for x in range(14, 34):                                          # shoulder seam
        if tag[33][x] == 'B' and g[33][x] == 'T': g[33][x] = 'u'
    # nose and blush
    g[25][24] = 'S'
    for x in (16, 17, 18): g[25][x] = 'h' if x != 17 else 'c'
    for x in (29, 30, 31): g[25][x] = 'h' if x != 30 else 's'
    # ahoge
    for (x, y, c) in ((24, 3, 'f'), (25, 2, 'f'), (26, 1, 'F'), (27, 1, 'f'), (28, 2, 'z'),
                      (24, 2, 'k'), (25, 1, 'k'), (26, 0, 'k'), (27, 0, 'k'), (28, 1, 'k'), (29, 2, 'k'),
                      (28, 3, 'k'), (25, 3, 'k'), (26, 2, 'k'), (27, 2, 'k')):
        g[y][x] = c
    # ribbon on the left
    bow = [".kk...kk.",
           "ktTk.kTuk",
           "ktTTkTTuk",
           "ktTkGkTuk",
           "ktTTkTTuk",
           "kTuk.kuuk",
           ".kk...kk."]
    for j, r in enumerate(bow):
        for i, c in enumerate(r):
            if c != '.': g[6 + j][3 + i] = c
    g[9][7] = 'G'
    return g

def eyes(g, mode):
    """mode: open (sleepy), closed, squeeze."""
    for y in range(19, 24):
        for x in list(range(15, 22)) + list(range(26, 33)):
            if g[y][x] in 'kuTtwWCh' and not (x <= 15 and y <= 21) and not (x >= 32 and y <= 21):
                g[y][x] = 'S' if x >= 31 else 's'
    if mode == 'open':
        for x0, glint_left in ((16, True), (27, False)):
            for x in range(x0, x0 + 5): g[20][x] = 'k'
            iris = (x0 + 1, x0 + 2, x0 + 3) if glint_left else (x0 + 1, x0 + 2, x0 + 3)
            white = x0 + 4 if glint_left else x0
            g[21][iris[0]] = 'w'; g[21][iris[1]] = 'u'; g[21][iris[2]] = 'u'
            g[22][iris[0]] = 'T'; g[22][iris[1]] = 'T'; g[22][iris[2]] = 't'
            g[21][white] = 'W'; g[22][white] = 'w'
            for x in iris: g[23][x] = 'C'
        g[19][16] = 'k'; g[19][31] = 'k'      # lash flicks at the outer corners
        g[21][16] = 'C'; g[21][31] = 'C'
    elif mode == 'closed':
        for x0 in (16, 27):
            for x in range(x0, x0 + 5): g[22][x] = 'k'
            g[21][x0] = 'k' if x0 == 16 else g[21][x0]
            g[21][x0 + 4] = 'k' if x0 == 27 else g[21][x0 + 4]
            for x in range(x0 + 1, x0 + 4): g[23][x] = 'S'
    elif mode == 'squeeze':  # >  < while yawning
        for (x, y) in ((16, 20), (17, 21), (18, 21), (19, 22), (20, 22), (16, 23), (17, 23)):
            g[y][x] = 'k'
        for (x, y) in ((31, 20), (30, 21), (29, 21), (28, 22), (27, 22), (31, 23), (30, 23)):
            g[y][x] = 'k'
        g[21][32] = 't'; g[22][32] = 'w'    # a sleepy tear
    for x in (16, 17, 18): g[25][x] = 'h' if x != 17 else 'c'
    for x in (29, 30, 31): g[25][x] = 'h' if x != 30 else 's'

def mouth(g, mode):
    for y in range(26, 30):
        for x in range(21, 28):
            if g[y][x] in 'CRxhk' and face(x, y): g[y][x] = 'S' if (x >= CX + 6 or y >= 28) else 's'
    if mode == 'rest':
        g[27][23] = 'C'; g[27][24] = 'C'
    elif mode == 'half':
        for (x, y, c) in ((23, 26, 'k'), (24, 26, 'k'), (22, 27, 'k'), (23, 27, 'x'), (24, 27, 'x'), (25, 27, 'k'),
                          (23, 28, 'k'), (24, 28, 'k')):
            g[y][x] = c
    elif mode == 'wide':
        for (x, y, c) in ((22, 25, 'k'), (23, 25, 'k'), (24, 25, 'k'), (25, 25, 'k'),
                          (21, 26, 'k'), (22, 26, 'x'), (23, 26, 'x'), (24, 26, 'x'), (25, 26, 'x'), (26, 26, 'k'),
                          (21, 27, 'k'), (22, 27, 'x'), (23, 27, 'R'), (24, 27, 'R'), (25, 27, 'x'), (26, 27, 'k'),
                          (22, 28, 'k'), (23, 28, 'h'), (24, 28, 'h'), (25, 28, 'k'), (23, 29, 'k'), (24, 29, 'k')):
            g[y][x] = c

def frame(eye, mouth_mode):
    g = draw()
    eyes(g, eye)
    mouth(g, mouth_mode)
    rows = [''.join(r) for r in g]
    assert len(rows) == N and all(len(r) == N for r in rows)
    return rows

frames = {
    'idle': frame('open', 'rest'),
    'blink': frame('closed', 'rest'),
    'yawnStart': frame('closed', 'half'),
    'yawn': frame('squeeze', 'wide'),
}
zs = {'zBig': ["wwwww", "...w.", "..w..", ".w...", "wwwww"], 'zSmall': ["wwww", "..w.", ".w..", "wwww"]}

out = ["// Generated by docs/icon_candidates/mentor48.py — edit the script, not this file.",
       "import '../sprite.dart';", "",
       "/// 莉娜 at 48×48 and the frames her idle animation flips between.",
       "abstract final class MentorFrames {"]
for name, rows in {**frames, **zs}.items():
    out.append(f"  static const {name} = PixelSprite('mentor_{name}', [")
    out += [f"    '{r}'," for r in rows]
    out.append("  ]);")
    out.append("")
out[-1] = "}"
open(os.path.join(root, 'lib/ui/pixel/sprites/mentor_frames.dart'), 'w').write('\n'.join(out) + '\n')
png(list(frames.values()), os.path.join(here, 'mentor48_preview.png'), scale=8, gap=4)
print('ok')
