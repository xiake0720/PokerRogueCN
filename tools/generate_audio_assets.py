#!/usr/bin/env python3
from __future__ import annotations

import json
import math
import os
import random
import shutil
import subprocess
import wave
from pathlib import Path

import numpy as np


ROOT = Path(__file__).resolve().parents[1]
AUDIO_DIR = ROOT / "assets" / "audio"
BGM_DIR = AUDIO_DIR / "bgm"
SFX_DIR = AUDIO_DIR / "sfx"
SR = 44_100


def ensure_dirs() -> None:
    BGM_DIR.mkdir(parents=True, exist_ok=True)
    SFX_DIR.mkdir(parents=True, exist_ok=True)


def midi(note: int) -> float:
    return 440.0 * (2 ** ((note - 69) / 12))


def sine(freq: float, dur: float, phase: float = 0.0) -> np.ndarray:
    t = np.arange(int(SR * dur)) / SR
    return np.sin(2 * np.pi * freq * t + phase)


def tri(freq: float, dur: float) -> np.ndarray:
    t = np.arange(int(SR * dur)) / SR
    return 2 * np.abs(2 * ((freq * t) % 1) - 1) - 1


def pulse(freq: float, dur: float, width: float = 0.48) -> np.ndarray:
    t = np.arange(int(SR * dur)) / SR
    return np.where((freq * t) % 1 < width, 1.0, -1.0)


def noise(dur: float, amount: float = 1.0) -> np.ndarray:
    return np.random.uniform(-1.0, 1.0, int(SR * dur)) * amount


def adsr(length: int, attack: float, decay: float, sustain: float, release: float) -> np.ndarray:
    a = max(1, int(SR * attack))
    d = max(1, int(SR * decay))
    r = max(1, int(SR * release))
    s = max(0, length - a - d - r)
    env = np.concatenate(
        [
            np.linspace(0.0, 1.0, a, endpoint=False),
            np.linspace(1.0, sustain, d, endpoint=False),
            np.full(s, sustain),
            np.linspace(sustain, 0.0, r, endpoint=True),
        ]
    )
    if len(env) < length:
        env = np.pad(env, (0, length - len(env)))
    return env[:length]


def exp_env(dur: float, start: float = 1.0, end: float = 0.001) -> np.ndarray:
    n = int(SR * dur)
    return np.geomspace(start, end, max(1, n))


def soft_clip(x: np.ndarray, drive: float = 1.0) -> np.ndarray:
    return np.tanh(x * drive)


def one_pole_lowpass(x: np.ndarray, cutoff: float) -> np.ndarray:
    rc = 1.0 / (2 * math.pi * cutoff)
    dt = 1.0 / SR
    alpha = dt / (rc + dt)
    y = np.zeros_like(x)
    for i in range(1, len(x)):
        y[i] = y[i - 1] + alpha * (x[i] - y[i - 1])
    return y


def one_pole_highpass(x: np.ndarray, cutoff: float) -> np.ndarray:
    return x - one_pole_lowpass(x, cutoff)


def pad_or_mix(base: np.ndarray, sound: np.ndarray, start: int) -> None:
    end = min(len(base), start + len(sound))
    if start >= len(base) or end <= start:
        return
    base[start:end] += sound[: end - start]


def mix_sounds(*sounds: np.ndarray) -> np.ndarray:
    length = max((len(sound) for sound in sounds), default=0)
    out = np.zeros(length)
    for sound in sounds:
        out[: len(sound)] += sound
    return out


def write_wav(path: Path, audio: np.ndarray, peak: float = 0.92) -> None:
    if audio.size == 0:
        return
    audio = np.nan_to_num(audio)
    max_abs = float(np.max(np.abs(audio)))
    if max_abs > 0:
        audio = audio / max_abs * peak
    audio = np.clip(audio, -1.0, 1.0)
    data = (audio * 32767).astype(np.int16)
    with wave.open(str(path), "wb") as f:
        f.setnchannels(1)
        f.setsampwidth(2)
        f.setframerate(SR)
        f.writeframes(data.tobytes())


def add_note(track: np.ndarray, start_s: float, note: int, dur: float, amp: float, kind: str = "rhodes") -> None:
    length = int(SR * dur)
    f = midi(note)
    if kind == "bass":
        sig = 0.7 * tri(f, dur) + 0.25 * sine(f * 2, dur)
        env = adsr(length, 0.004, 0.08, 0.35, 0.08)
        sig = one_pole_lowpass(sig * env, 420)
    elif kind == "bell":
        sig = sine(f, dur) + 0.45 * sine(f * 2.01, dur) + 0.22 * sine(f * 3.98, dur)
        env = adsr(length, 0.002, 0.1, 0.0, 0.5)
        sig = sig * env
    else:
        sig = 0.52 * sine(f, dur) + 0.28 * sine(f * 2.01, dur) + 0.12 * sine(f * 3.01, dur)
        env = adsr(length, 0.008, 0.12, 0.36, 0.18)
        sig = one_pole_lowpass(sig * env, 1800)
    pad_or_mix(track, sig * amp, int(start_s * SR))


def drum_kick() -> np.ndarray:
    dur = 0.24
    t = np.arange(int(SR * dur)) / SR
    freq = 88 * np.exp(-t * 15) + 34
    phase = 2 * np.pi * np.cumsum(freq) / SR
    sig = np.sin(phase) * exp_env(dur, 1.0, 0.005)
    return soft_clip(sig, 1.6)


def drum_hat(dur: float = 0.07) -> np.ndarray:
    sig = one_pole_highpass(noise(dur), 5200)
    return sig * exp_env(dur, 1.0, 0.01)


def drum_snare() -> np.ndarray:
    dur = 0.16
    sig = one_pole_highpass(noise(dur), 1200) * exp_env(dur, 1.0, 0.02)
    sig += sine(185, dur) * exp_env(dur, 0.55, 0.005)
    return soft_clip(sig, 1.2)


def make_bgm(name: str, bpm: int, bars: int, progression: list[list[int]], bass: list[int], vibe: str) -> Path:
    beat = 60.0 / bpm
    total = bars * 4 * beat
    track = np.zeros(int(total * SR))
    random.seed(12 + bpm)
    np.random.seed(12 + bpm)

    for bar in range(bars):
        bar_start = bar * 4 * beat
        chord = progression[bar % len(progression)]
        for n in chord:
            add_note(track, bar_start, n, beat * 3.7, 0.11, "rhodes")
        for step, offset in enumerate([0, 1.5, 2.5, 3.25]):
            add_note(track, bar_start + offset * beat, bass[(bar + step) % len(bass)], beat * 0.62, 0.18, "bass")
        if vibe != "menu":
            for step in range(8):
                if step % 2 == 0 or random.random() > 0.35:
                    pad_or_mix(track, drum_hat() * 0.045, int((bar_start + step * 0.5 * beat) * SR))
            pad_or_mix(track, drum_kick() * 0.12, int(bar_start * SR))
            pad_or_mix(track, drum_kick() * 0.08, int((bar_start + 2.5 * beat) * SR))
            pad_or_mix(track, drum_snare() * 0.06, int((bar_start + 2 * beat) * SR))
        else:
            for step in [0.5, 2.5, 3.5]:
                add_note(track, bar_start + step * beat, chord[-1] + 12, beat * 0.18, 0.045, "bell")

    if vibe == "shop":
        for bar in range(bars):
            bar_start = bar * 4 * beat
            for step in [0.75, 1.75, 2.75, 3.75]:
                add_note(track, bar_start + step * beat, 84 + (bar % 3) * 2, beat * 0.12, 0.035, "bell")

    bed = one_pole_lowpass(noise(total, 0.018), 7000)
    slow = sine(0.08, total) * 0.012
    track = soft_clip(track + bed + slow, 1.08)
    wav_path = BGM_DIR / f"{name}.wav"
    ogg_path = BGM_DIR / f"{name}.ogg"
    write_wav(wav_path, track, 0.86)

    if shutil.which("ffmpeg"):
        subprocess.run(
            ["ffmpeg", "-y", "-loglevel", "error", "-i", str(wav_path), "-q:a", "5", str(ogg_path)],
            check=True,
        )
        wav_path.unlink()
        return ogg_path
    return wav_path


def tonal_blip(freq: float, dur: float, amp: float = 1.0, glide_to: float | None = None) -> np.ndarray:
    n = int(SR * dur)
    if glide_to is None:
        sig = sine(freq, dur)
    else:
        t = np.arange(n) / SR
        freqs = np.linspace(freq, glide_to, n)
        sig = np.sin(2 * np.pi * np.cumsum(freqs) / SR)
    return sig * exp_env(dur, amp, 0.002)


def card_slide(dur: float, force: float = 1.0) -> np.ndarray:
    sig = one_pole_highpass(noise(dur), 380) * exp_env(dur, 0.8, 0.02)
    chirp = tonal_blip(560 + 90 * force, dur * 0.55, 0.25, 300)
    return soft_clip(mix_sounds(sig, chirp), 0.9) * force


def sfx_click() -> np.ndarray:
    sig = tonal_blip(980, 0.045, 0.8, 680)
    tick = one_pole_highpass(noise(0.045), 5000) * exp_env(0.045, 0.22, 0.01)
    return mix_sounds(sig, tick)


def sfx_success() -> np.ndarray:
    dur = 0.62
    out = np.zeros(int(SR * dur))
    for i, note in enumerate([72, 76, 79, 84]):
        pad_or_mix(out, tonal_blip(midi(note), 0.28, 0.55), int(i * 0.09 * SR))
    return out


def sfx_fail() -> np.ndarray:
    return tonal_blip(180, 0.7, 0.9, 82) + one_pole_lowpass(noise(0.7), 300) * exp_env(0.7, 0.22, 0.01)


def make_sfx() -> dict[str, str]:
    random.seed(42)
    np.random.seed(42)
    sounds: dict[str, np.ndarray] = {
        "ui_click": sfx_click(),
        "ui_hover_tick": tonal_blip(1450, 0.028, 0.55),
        "ui_error": tonal_blip(190, 0.18, 0.75, 160),
        "modal_open": mix_sounds(tonal_blip(420, 0.22, 0.55, 880), one_pole_highpass(noise(0.22), 1600) * exp_env(0.22, 0.18, 0.01)),
        "modal_close": mix_sounds(tonal_blip(760, 0.18, 0.48, 310), one_pole_highpass(noise(0.18), 1700) * exp_env(0.18, 0.14, 0.01)),
        "deck_switch": card_slide(0.18, 0.95),
        "difficulty_toggle": tonal_blip(660, 0.08, 0.65, 740),
        "deal_card": card_slide(0.12, 0.78),
        "select_card": mix_sounds(tonal_blip(720, 0.055, 0.65, 790), card_slide(0.04, 0.22)),
        "deselect_card": mix_sounds(tonal_blip(560, 0.055, 0.55, 460), card_slide(0.04, 0.18)),
        "play_cards": mix_sounds(card_slide(0.16, 1.0), tonal_blip(260, 0.13, 0.28)),
        "discard_cards": mix_sounds(card_slide(0.23, 0.88), one_pole_highpass(noise(0.23), 1300) * exp_env(0.23, 0.25, 0.02)),
        "flip_card": mix_sounds(card_slide(0.09, 0.68), tonal_blip(920, 0.07, 0.35, 620)),
        "chips_count": mix_sounds(tonal_blip(1180, 0.08, 0.55), tonal_blip(1560, 0.05, 0.24)),
        "multiplier_up": mix_sounds(tonal_blip(420, 0.32, 0.38, 1180), tonal_blip(840, 0.32, 0.26, 1640)),
        "joker_trigger": mix_sounds(tonal_blip(640, 0.18, 0.45, 920), tonal_blip(1280, 0.12, 0.28, 1040)),
        "joker_rare_trigger": mix_sounds(tonal_blip(500, 0.55, 0.52, 1180), tonal_blip(1000, 0.55, 0.32, 1880)),
        "score_target_reached": sfx_success(),
        "round_fail": sfx_fail(),
        "purchase_card": mix_sounds(tonal_blip(980, 0.08, 0.45), tonal_blip(1320, 0.16, 0.4), card_slide(0.12, 0.28)),
        "sell_card": mix_sounds(tonal_blip(780, 0.12, 0.38, 540), tonal_blip(1180, 0.07, 0.25)),
        "shop_reroll": mix_sounds(card_slide(0.34, 0.9), tonal_blip(340, 0.26, 0.28, 620)),
        "booster_open": mix_sounds(one_pole_highpass(noise(0.42), 800) * exp_env(0.42, 0.8, 0.01), tonal_blip(900, 0.34, 0.28, 1500)),
        "tarot_use": mix_sounds(tonal_blip(330, 0.52, 0.42, 660), tonal_blip(990, 0.52, 0.28, 1320)),
        "planet_use": mix_sounds(tonal_blip(260, 0.72, 0.36, 880), tonal_blip(520, 0.72, 0.25, 1760)),
        "spectral_use": mix_sounds(tonal_blip(620, 0.7, 0.26, 180), one_pole_lowpass(noise(0.7), 520) * exp_env(0.7, 0.28, 0.01)),
        "card_upgrade": mix_sounds(tonal_blip(620, 0.16, 0.42, 920), tonal_blip(1240, 0.24, 0.34, 1860)),
        "card_destroy": mix_sounds(one_pole_highpass(noise(0.38), 900) * exp_env(0.38, 0.75, 0.006), tonal_blip(260, 0.32, 0.3, 90)),
        "shuffle_cards": np.zeros(int(SR * 0.72)),
    }

    shuffle = np.zeros(int(SR * 0.72))
    for i in range(9):
        pad_or_mix(shuffle, card_slide(0.12, 0.42 + i * 0.035), int(i * 0.065 * SR))
    sounds["shuffle_cards"] = shuffle

    output: dict[str, str] = {}
    for name, audio in sounds.items():
        path = SFX_DIR / f"{name}.wav"
        write_wav(path, soft_clip(audio, 1.05), 0.9)
        output[name] = f"res://assets/audio/sfx/{name}.wav"
    return output


def main() -> None:
    ensure_dirs()
    bgm = {
        "menu_loop": make_bgm(
            "menu_loop",
            bpm=88,
            bars=12,
            progression=[[57, 60, 64, 67], [55, 59, 62, 65], [52, 55, 59, 62], [54, 57, 60, 64]],
            bass=[45, 43, 40, 42],
            vibe="menu",
        ),
        "game_loop": make_bgm(
            "game_loop",
            bpm=104,
            bars=16,
            progression=[[48, 52, 55, 59], [50, 53, 57, 60], [45, 48, 52, 55], [47, 50, 54, 57]],
            bass=[36, 38, 33, 35],
            vibe="game",
        ),
        "shop_loop": make_bgm(
            "shop_loop",
            bpm=96,
            bars=12,
            progression=[[53, 57, 60, 64], [55, 59, 62, 65], [52, 55, 59, 62], [50, 53, 57, 60]],
            bass=[41, 43, 40, 38],
            vibe="shop",
        ),
    }
    sfx = make_sfx()
    manifest = {
        "copyright": "Original procedural audio generated for PokerRogueCN. Do not use Balatro original audio.",
        "bgm": {k: f"res://assets/audio/bgm/{Path(v).name}" for k, v in bgm.items()},
        "sfx": sfx,
    }
    (AUDIO_DIR / "audio_manifest.json").write_text(json.dumps(manifest, ensure_ascii=False, indent=2), encoding="utf-8")


if __name__ == "__main__":
    main()
