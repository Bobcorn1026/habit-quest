# The bank's 16×16 account icons: the vault, the casino's pool and the
# envelopes. Drawn without outlines; the outline is added around each
# silhouette, and each icon is centred.
# Writes lib/ui/pixel/sprites/bank_icons.dart and bank16_preview.png.
#   python3 docs/icon_candidates/bank16.py
import os, sys
here = os.path.dirname(os.path.abspath(__file__))
root = os.path.abspath(os.path.join(here, '../..'))
sys.path.insert(0, here)
from spritepng import png

N = 16


def finish(name, art):
    """Centres [art] (rows of any length, '.' clear) on 16×16 and outlines
    it."""
    w = max(len(r) for r in art)
    art = [r.ljust(w, '.') for r in art]
    xs = [x for r in art for x, c in enumerate(r) if c != '.']
    ys = [y for y, r in enumerate(art) for c in r if c != '.']
    x0, x1, y0, y1 = min(xs), max(xs), min(ys), max(ys)
    bw, bh = x1 - x0 + 1, y1 - y0 + 1
    assert bw <= N - 2 and bh <= N - 2, (name, bw, bh)
    ox, oy = (N - bw) // 2, (N - bh) // 2
    g = [['.'] * N for _ in range(N)]
    for y in range(bh):
        for x in range(bw):
            c = art[y0 + y][x0 + x]
            if c != '.':
                g[oy + y][ox + x] = c

    def get(x, y):
        return g[y][x] if 0 <= x < N and 0 <= y < N else '.'

    hits = [(x, y) for y in range(N) for x in range(N)
            if g[y][x] == '.' and any(get(x + dx, y + dy) not in '.k'
                                      for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)))]
    for x, y in hits:
        g[y][x] = 'k'
    return name, [''.join(r) for r in g]


ICONS = [
    # 中央銀行: a safe with a gold dial.
    finish('vault', [
        'eeeeeeeeeeee',
        'eEEEEEEEEEEa',
        'eEaaaaaaaaEa',
        'eEaeEEEEEaEa',
        'eEaEEgGoEaEa',
        'eEaEgGoOEaEa',
        'eEaEGoOOEaEa',
        'eEaEEOOEEaEa',
        'eEaEEEEEEaEa',
        'eEaaaaaaaaEa',
        'aaaaaaaaaaaa',
        '.aa......aa.',
    ]),
    # 獎池: a heap of gold with a glint.
    finish('pool', [
        '......w......',
        '.....www.....',
        '......w......',
        '.....gGG.....',
        '....gGGGo....',
        '...gGgGGGo...',
        '..gGGGGoGGo..',
        '.gGgGGGGGoGo.',
        'gGGGGoGGGGGOo',
        'GGgGGGGoGGGOo',
        'oGGGOGGGGoOOO',
        '.ooOOooOOOOO.',
    ]),
    # 通用: a cloth purse with a coin on it.
    finish('general', [
        '...pPq....',
        '..pPPPq...',
        '...rrr....',
        '..pPPqQ...',
        '.pPPPPqQ..',
        'pPPGGPPqQ.',
        'pPGgoGPqQQ',
        'pPGooOPqQQ',
        'PPPGOPPqQQ',
        'qPPPPPqQQ.',
        '.qqqqQQQ..',
    ]),
    # 餐費: a bowl of rice with chopsticks.
    finish('meal', [
        '..........3.',
        '.........3..3',
        '........3..3.',
        '..wwwwwww3w..',
        '.wwWwwwww3Ww.',
        'tttttttttttttT',
        'tTTTTTTTTTTTTu',
        '.TTTThhTThhTu.',
        '.tTTTTTTTTTTu.',
        '..TTTTTTTTTu..',
        '...uuuuuuuu...',
        '....uuuuuu....',
    ]),
    # 額外食物: a roast drumstick.
    finish('snack', [
        '..FFFf.......',
        '.FFfffff.....',
        'FFfffffzz....',
        'Ffffffffzz...',
        'Fffffffffz...',
        'ffffffffzz...',
        '.fffffffzz...',
        '..zfffzzz....',
        '....zzzwW....',
        '.......wW....',
        '........wWw..',
        '.......wwWWw.',
        '........wWW..',
        '.........W...',
    ]),
    # 社交: two speech bubbles.
    finish('social', [
        'pppppppp......',
        'pPPPPPPPq.....',
        'PPdPPdPPq.....',
        'PPPPPPPPq.....',
        '.qPqqqqq......',
        '.Pq.ttttttttt.',
        '.q.tTTTTTTTTTu',
        '...TTwTTwTTwTu',
        '...TTTTTTTTTTu',
        '....uuuuuuTuu.',
        '..........Tu..',
        '...........u..',
    ]),
    # 遊戲: a pair of dice.
    finish('game', [
        '.hhhhh........',
        'hrrrrrR.......',
        'rwrrwrR.......',
        'rrrrrrR.......',
        'rwrrwrR.......',
        'RRRRRRR.......',
        '.......ppppp..',
        '......wwwwwwW.',
        '......wdwwwwW.',
        '......wwwdwwW.',
        '......wwwwwdW.',
        '......WWWWWWW.',
    ]),
    # 其他娛樂: two beamed notes.
    finish('fun', [
        '...vVVVVVVVV',
        '...VVVVVVVVi',
        '...V.......i',
        '...V.......i',
        '...V.......i',
        '...V.......i',
        '...V...vVVVi',
        'vVVV..vVVVVi',
        'VVVi..VVVVi.',
        'VVVi...iii..',
        '.ii.........',
    ]),
    # 外表: a hand mirror.
    finish('looks', [
        '..gGGGo..',
        '.gtttTTo.',
        'gtwtTTTTo',
        'gtwTTTTTo',
        'gtTTTTTuo',
        'GTTTTTTuO',
        '.oTTTuuO.',
        '..oOOOO..',
        '...24....',
        '...24....',
        '...24....',
        '...35....',
        '...35....',
    ]),
    # 專案: a hammer.
    finish('project', [
        'eeeeeeeeeE',
        'eEEEEEEEEa',
        'EEEEEEEEaa',
        '.aaa22aaa.',
        '....24....',
        '....24....',
        '....24....',
        '....24....',
        '....35....',
        '....35....',
        '....35....',
        '....55....',
    ]),
    # 投資: a sapling on a stack of coins.
    finish('invest', [
        '....n.......',
        '..nnNn......',
        '.nnNNl.nn...',
        '..lN.lnNNl..',
        '....N.lll...',
        '....N.......',
        '....N.......',
        '.gGGGGGo....',
        '.oOOOOOO....',
        'gGGGGGGGo...',
        'oOOOOOOOO...',
        '.gGGGGGo....',
        '.oOOOOOO....',
    ]),
]

for name, rows in ICONS:
    assert len(rows) == N and all(len(r) == N for r in rows), name

out_png = sys.argv[1] if len(sys.argv) > 1 else os.path.join(here, 'bank16_preview.png')
png([r for _, r in ICONS], out_png, scale=8, bg=0xFF2F2127)

out = [
    "// Generated by docs/icon_candidates/bank16.py; edit the script, not this file.",
    "import '../sprite.dart';",
    '',
    "/// 16×16 icons of the bank's accounts, by the id stored on the account.",
    'abstract final class PixelBankIcons {',
]
for name, rows in ICONS:
    out.append(f"  static const {name} = PixelSprite('bank_{name}', [")
    out += [f"    '{r}'," for r in rows]
    out.append('  ]);')
    out.append('')
out += [
    '  /// The ones an envelope can pick, in the order offered.',
    '  static const all = <String, PixelSprite>{',
    *[f"    '{name}': {name}," for name, _ in ICONS],
    '  };',
    '',
    '  static PixelSprite byId(String id) => all[id] ?? general;',
    '}',
]
open(os.path.join(root, 'lib/ui/pixel/sprites/bank_icons.dart'), 'w').write('\n'.join(out) + '\n')
print('wrote', out_png)
