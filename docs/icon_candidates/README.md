# App icon candidates

The icon and launch image are 32×32 pixel art drawn with the app's palette
(`lib/ui/pixel/palette.dart`). `c_mentor` (莉娜) is installed, chosen 2026-11-07; `a_shield` and `b_note`
are the alternatives. `mentor_v2.txt` is a sleepier, more anime 莉娜 drawn
by `mentor_v2.py`, waiting for a verdict (`mentor_compare.png`).

| file | idea |
|---|---|
| `a_shield.png` | a hero's shield with a gold check mark, on the quest-board wood |
| `b_note.png` | a quest note pinned to the board, with a sword and a red seal |
| `c_mentor.png` | 莉娜, the guild receptionist |

Regenerate (from this folder; needs only Python 3):

```bash
python3 icons.py .                                   # candidates + preview.png
python3 write_icons.py . ../../ios/Runner/Assets.xcassets/AppIcon.appiconset a_shield
python3 launch.py . ../../ios/Runner/Assets.xcassets/LaunchImage.imageset
```

Pass `b_note` or `c_mentor` to `write_icons.py` to switch the icon.
