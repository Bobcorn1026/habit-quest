import sys
sys.path.insert(0, sys.argv[1])
from spritepng import png
rows = [
"................................",
".............kkkkkk.............",
"...kkk.....kkffggfffkk..........",
"..kTttk...kfffgggffffRk.........",
"..kTtTTkkkffggffffffffRk........",
"...kTTuGkfffffffffffffRRk.......",
"..kTtuukffffffffffffffffRk......",
"..kTuukffRffRfffRfffRffRRk......",
"...kkk.kfRRsRfsssRsssRfRRk......",
".......kfRssssssssssssRfRRk.....",
".......kfRskkssssskkssRRfRk.....",
".......kfRswTssssswTssSRfRk.....",
".......kffRshssssssshsSRffRk....",
".......kffRsssssRSsssSSRffRk....",
".......kfRRRssssssssSSRRffRk....",
".......kfRfRRRssssSSRRRfffRk....",
"......kffRffRRRkSSSkRRffffRRk...",
"......kfRRffkkkkSSSkkkffRRRRk...",
".....kffRRfkwwwSSSwwwkffRRxRk...",
".....kfRRfkwwwwwwwwwwwkfRRxxk...",
"....kfRRRkTwwwwwGwwwwwTkRxxk....",
"....kRRxkTTTwwwwGwwwwTTTkxk.....",
"...kkxxkTTTTTwwwwwwwTTTTTkkk....",
"..kTTkkTTTTTTTuwwwuTTTTTTTTTk...",
".kTTTTTTTTTTTTuGGGuTTTTTTTTTTk..",
".kTTTTTTTTTTTTTuGuTTTTTTTTTTuuk.",
"kTTTTtTTTTTTTTTuGuTTTTTTTTTuuuk.",
"kTTTttTTTTTTTTTuGuTTTTTTTTuuuuuk",
"kTTtttTTTTTTTTuuGuuTTTTTTuuuuuuk",
"kTTttTTTTTTTTTuuGuuTTTTTuuuuuuuk",
"kTTtTTTTTTTTTTuGGGuTTTTuuuuuuuuk",
"kTTTTTTTTTTTTTuGGGuTTTuuuuuuuuuk",
]
for i,r in enumerate(rows):
    if len(r)!=32: print('row',i,'len',len(r))
png([rows], sys.argv[2], scale=12)
