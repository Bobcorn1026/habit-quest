"""Writes the training ground's 8-bit sound effects to assets/sfx/.

Square waves only, like an old handheld. Standard library only:

    python3 docs/sfx/sfx.py

Each cue in lib/app/sfx.dart (SfxCue) has a file named after it in
snake_case: start.wav, stop.wav, break_over.wav.
"""

import math
import struct
import wave
from pathlib import Path

RATE = 22050
VOLUME = 0.32  # of full scale; square waves are loud
OUT = Path(__file__).resolve().parents[2] / "assets" / "sfx"

NOTES = {"C": -9, "D": -7, "E": -5, "F": -4, "G": -2, "A": 0, "B": 2}


def freq(note):
    """'C5' -> Hz (A4 = 440)."""
    name, octave = note[0], int(note[1:])
    return 440.0 * 2 ** ((NOTES[name] + 12 * (octave - 4)) / 12)


def tone(note, ms, duty=0.5, decay=0.0):
    """One square-wave note; `decay` fades it towards the end (0..1)."""
    n = int(RATE * ms / 1000)
    period = RATE / freq(note)
    edge = int(RATE * 0.004)  # 4 ms ramps so notes do not click
    out = []
    for i in range(n):
        level = 1.0 if (i % period) / period < duty else -1.0
        env = min(1.0, i / edge, (n - i) / edge)
        env *= 1.0 - decay * (i / n)
        out.append(level * env)
    return out


def rest(ms):
    return [0.0] * int(RATE * ms / 1000)


CUES = {
    # A rising arpeggio: off you go.
    "start": tone("C5", 60) + tone("E5", 60) + tone("G5", 60)
    + tone("C6", 160, decay=0.8),
    # Two notes down: done for now.
    "stop": tone("G5", 90, duty=0.25) + rest(20)
    + tone("C5", 200, duty=0.25, decay=0.8),
    # A little fanfare, twice, so it is heard across the room.
    "break_over": (
        tone("G5", 70) + tone("C6", 70) + tone("E6", 70)
        + tone("G6", 220, decay=0.7) + rest(90)
    ) * 2,
}


def write(name, samples):
    OUT.mkdir(parents=True, exist_ok=True)
    path = OUT / f"{name}.wav"
    peak = 32767 * VOLUME
    with wave.open(str(path), "wb") as f:
        f.setnchannels(1)
        f.setsampwidth(2)
        f.setframerate(RATE)
        f.writeframes(
            b"".join(struct.pack("<h", int(round(s * peak))) for s in samples)
        )
    ms = math.ceil(len(samples) * 1000 / RATE)
    print(f"{path.relative_to(OUT.parents[1])}: {ms} ms")


if __name__ == "__main__":
    for cue, samples in CUES.items():
        write(cue, samples)
