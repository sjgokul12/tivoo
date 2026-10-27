"""Generates the premium animal gift sounds (stereo, 44.1 kHz, 16-bit).

    python tools/generate_animal_gift_sounds.py

Writes into assets/sounds/gift/:
    sound_lion.wav           lion: deep roar + grunt series, savanna reverb
    sound_horse.wav          horse: gallop approaching from the left, whinny, snort
    sound_ocean_dolphin.wav  dolphin: whistles + click trains under water, splash

Each track is 7 s long to match the premium gift animation (see _Tier.premium in
active_gift_animation_overlay.dart), and its loudest moment lines up with the
animation's impact (~1.6 s). Pure Python, no extra packages.

These are synthesized from physical models (vocal pulse source -> formant filters ->
reverb). To use studio recordings instead, drop licensed WAV/MP3 files at the same paths.
"""

import math
import os
import random
import struct
import wave

SR = 44100
DUR = 7.0
N = int(SR * DUR)
OUT_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'assets', 'sounds', 'gift')

rng = random.Random(20261026)


# --------------------------------------------------------------------------- DSP
class Biquad:
    """RBJ cookbook biquad. kind: lowpass, highpass, bandpass, peak."""

    def __init__(self, kind, freq, q=0.707, gain_db=0.0):
        self.x1 = self.x2 = self.y1 = self.y2 = 0.0
        self.set(kind, freq, q, gain_db)

    def set(self, kind, freq, q=0.707, gain_db=0.0):
        freq = min(max(freq, 10.0), SR * 0.45)
        w = 2 * math.pi * freq / SR
        cw, sw = math.cos(w), math.sin(w)
        alpha = sw / (2 * q)
        if kind == 'lowpass':
            b0, b1, b2 = (1 - cw) / 2, 1 - cw, (1 - cw) / 2
            a0, a1, a2 = 1 + alpha, -2 * cw, 1 - alpha
        elif kind == 'highpass':
            b0, b1, b2 = (1 + cw) / 2, -(1 + cw), (1 + cw) / 2
            a0, a1, a2 = 1 + alpha, -2 * cw, 1 - alpha
        elif kind == 'bandpass':
            b0, b1, b2 = alpha, 0.0, -alpha
            a0, a1, a2 = 1 + alpha, -2 * cw, 1 - alpha
        else:  # peak
            a = 10 ** (gain_db / 40)
            b0, b1, b2 = 1 + alpha * a, -2 * cw, 1 - alpha * a
            a0, a1, a2 = 1 + alpha / a, -2 * cw, 1 - alpha / a
        self.b0, self.b1, self.b2 = b0 / a0, b1 / a0, b2 / a0
        self.a1, self.a2 = a1 / a0, a2 / a0

    def __call__(self, x):
        y = self.b0 * x + self.b1 * self.x1 + self.b2 * self.x2 - self.a1 * self.y1 - self.a2 * self.y2
        self.x2, self.x1, self.y2, self.y1 = self.x1, x, self.y1, y
        return y


def filt(signal, *filters):
    out = []
    for x in signal:
        for f in filters:
            x = f(x)
        out.append(x)
    return out


def noise():
    return rng.uniform(-1.0, 1.0)


def env_adsr(t, start, attack, hold, release):
    """0 → 1 over attack, hold, then exponential-ish release."""
    t -= start
    if t < 0:
        return 0.0
    if t < attack:
        return math.sin(0.5 * math.pi * t / attack)
    t -= attack
    if t < hold:
        return 1.0
    t -= hold
    if t < release:
        return (1 - t / release) ** 2
    return 0.0


def reverb(signal, room=0.82, damp=0.35, wet=0.3, spread=0):
    """Schroeder/Freeverb-style reverb; [spread] offsets delays for the other channel."""
    comb_delays = [1557, 1617, 1491, 1422, 1277, 1356]
    ap_delays = [225, 556, 441]
    combs = [[0.0] * (d + spread) for d in comb_delays]
    comb_idx = [0] * len(combs)
    comb_lp = [0.0] * len(combs)
    aps = [[0.0] * (d + spread) for d in ap_delays]
    ap_idx = [0] * len(aps)
    out = []
    for x in signal:
        acc = 0.0
        for k, buf in enumerate(combs):
            i = comb_idx[k]
            y = buf[i]
            comb_lp[k] = y * (1 - damp) + comb_lp[k] * damp
            buf[i] = x * 0.015 + comb_lp[k] * room
            comb_idx[k] = (i + 1) % len(buf)
            acc += y
        for k, buf in enumerate(aps):
            i = ap_idx[k]
            b = buf[i]
            buf[i] = acc + b * 0.5
            acc = b - acc
            ap_idx[k] = (i + 1) % len(buf)
        out.append(x * (1 - wet) + acc * wet)
    return out


def glottal(phase):
    """Rosenberg glottal pulse (0..1 phase) minus its mean: a natural vocal source."""
    if phase < 0.45:
        v = 0.5 * (1 - math.cos(math.pi * phase / 0.45))
    elif phase < 0.6:
        v = math.cos(0.5 * math.pi * (phase - 0.45) / 0.15)
    else:
        v = 0.0
    return v - 0.35


def voice(f0_at, amp_at, start, end, jitter=0.03, subharmonic=0.0, breath=0.15):
    """Pulse-train vocal source with period jitter, shimmer and optional period
    doubling (the rough 'growl' of big cats). Returns (voiced, aspiration) lists."""
    voiced = [0.0] * N
    asp = [0.0] * N
    i = int(start * SR)
    stop = min(N, int(end * SR))
    phase = 0.0
    period_scale = 1.0
    shimmer = 1.0
    odd = False
    while i < stop:
        t = i / SR
        f0 = f0_at(t) * period_scale
        a = amp_at(t)
        phase += f0 / SR
        if phase >= 1.0:
            phase -= 1.0
            period_scale = 1 + rng.gauss(0, jitter)
            shimmer = 1 + rng.gauss(0, jitter * 3)
            odd = not odd
        g = glottal(phase) * shimmer
        if subharmonic and odd:
            g *= 1 - subharmonic
        voiced[i] = g * a
        # Turbulent airflow, strongest at the open phase of each pulse.
        asp[i] = noise() * a * breath * (1.0 if phase < 0.5 else 0.45)
        i += 1
    return voiced, asp


def formants(source, specs):
    """Parallel bandpass bank: specs = [(freq, q, gain)]."""
    banks = [(Biquad('bandpass', f, q), g) for f, q, g in specs]
    out = []
    for x in source:
        out.append(sum(b(x) * g for b, g in banks))
    return out


def pan(signal, pos_at):
    """Constant-power pan; pos -1 (left) .. +1 (right)."""
    left, right = [], []
    for i, x in enumerate(signal):
        p = (pos_at(i / SR) + 1) * math.pi / 4
        left.append(x * math.cos(p))
        right.append(x * math.sin(p))
    return left, right


def mix(*signals):
    out = [0.0] * N
    for s in signals:
        for i, x in enumerate(s[:N]):
            out[i] += x
    return out


def write_stereo(name, left, right, peak=0.92):
    # Gentle tape-style saturation, then normalize.
    left = [math.tanh(x * 1.2) for x in left]
    right = [math.tanh(x * 1.2) for x in right]
    m = max(max(abs(x) for x in left), max(abs(x) for x in right)) or 1.0
    scale = 32767 * peak / m
    # 15 ms fades so the clip never clicks when stopped/started.
    fade = int(0.015 * SR)
    frames = bytearray()
    for i in range(N):
        g = min(1.0, i / fade, (N - 1 - i) / fade)
        frames += struct.pack('<hh', int(left[i] * scale * g), int(right[i] * scale * g))
    path = os.path.normpath(os.path.join(OUT_DIR, name))
    with wave.open(path, 'wb') as w:
        w.setnchannels(2)
        w.setsampwidth(2)
        w.setframerate(SR)
        w.writeframes(bytes(frames))
    print(f'wrote {path}')


# --------------------------------------------------------------------------- LION
def lion():
    # Main roar 0.35 – 2.75 s: pitch climbs to ~200 Hz then sags; deep, rough, loud.
    def f0(t):
        if t < 2.9:
            u = (t - 0.35) / 2.4
            return 95 + 115 * math.sin(math.pi * min(1.0, max(0.0, u)) ** 0.8) + 6 * math.sin(t * 31)
        return 0

    def amp(t):
        return env_adsr(t, 0.35, 0.28, 1.5, 0.7)

    v1, a1 = voice(f0, amp, 0.3, 2.95, jitter=0.035, subharmonic=0.45, breath=0.35)

    # Grunt series: "uh … uh … uh", slowing down and fading (classic lion roar bout).
    grunt_times = [3.25, 3.85, 4.38, 4.86, 5.30, 5.72, 6.12]
    gv = [0.0] * N
    ga = [0.0] * N
    for k, gt in enumerate(grunt_times):
        level = 0.85 * (0.86 ** k)
        length = 0.34 - k * 0.012

        def gf(t, gt=gt, length=length):
            u = (t - gt) / length
            return 150 - 55 * u

        def gamp(t, gt=gt, level=level, length=length):
            return level * env_adsr(t, gt, 0.05, length * 0.35, length * 0.6)

        v, a = voice(gf, gamp, gt, gt + length + 0.05, jitter=0.04, subharmonic=0.5, breath=0.4)
        for i in range(N):
            gv[i] += v[i]
            ga[i] += a[i]

    src = [v1[i] + gv[i] for i in range(N)]
    breath = [a1[i] + ga[i] for i in range(N)]

    # Inhales between grunts (air rushing in through the throat).
    inhale = [0.0] * N
    for k, gt in enumerate([0.05] + [g - 0.2 for g in grunt_times]):
        lvl = 0.18 if k == 0 else 0.07 * (0.9 ** k)
        for i in range(int(gt * SR), min(N, int((gt + 0.22) * SR))):
            inhale[i] += noise() * lvl * env_adsr(i / SR, gt, 0.1, 0.02, 0.1)
    inhale = filt(inhale, Biquad('bandpass', 1400, 0.9))

    # Large vocal tract: low formants; chest cavity boom.
    tract = [(320, 3.0, 1.0), (780, 4.0, 0.75), (1650, 5.0, 0.38), (2700, 6.0, 0.16)]
    roar = formants([src[i] + breath[i] for i in range(N)], tract)
    chest = filt(src, Biquad('lowpass', 180, 0.9))
    body = [roar[i] * 1.6 + chest[i] * 0.9 + inhale[i] for i in range(N)]
    body = filt(body, Biquad('peak', 95, 1.0, 6.0), Biquad('lowpass', 5200, 0.7), Biquad('highpass', 35, 0.7))

    left = reverb(body, room=0.86, damp=0.45, wet=0.32)
    right = reverb(body, room=0.86, damp=0.45, wet=0.32, spread=23)
    write_stereo('sound_lion.wav', left, right)


# --------------------------------------------------------------------------- HORSE
def hoof(buf, at, level, bright=1.0):
    """One hoof strike on packed dirt: low thump + dirt crunch + tiny click."""
    start = int(at * SR)
    for j in range(int(0.12 * SR)):
        i = start + j
        if i >= N:
            break
        t = j / SR
        f = 70 + 60 * math.exp(-t * 60)
        thump = math.sin(2 * math.pi * f * t) * math.exp(-t * 38)
        crunch = noise() * math.exp(-t * 55) * 0.55 * bright
        click = noise() * math.exp(-t * 600) * 0.4 * bright
        buf[i] += (thump + crunch + click) * level


def horse():
    hooves = [0.0] * N
    # Transverse gallop (4 beats, then a moment of suspension), ~2 strides / second.
    stride = 0.5
    t = 0.0
    while t < DUR - 0.2:
        for k, off in enumerate((0.0, 0.075, 0.16, 0.23)):
            at = t + off + rng.gauss(0, 0.004)
            # Approaches (louder), passes the camera (~1.6 – 5 s), then moves away.
            dist = 1.0 if 1.4 < at < 5.2 else (0.25 + 0.75 * at / 1.4 if at <= 1.4 else max(0.2, 1 - (at - 5.2) / 1.8))
            hoof(hooves, at, dist * (1.0 if k == 0 else 0.78) * rng.uniform(0.85, 1.1), bright=dist)
        t += stride * rng.uniform(0.97, 1.03)
    hooves = filt(hooves, Biquad('lowpass', 3800, 0.7), Biquad('peak', 110, 1.2, 4.0))

    # Whinny 1.7 – 3.3 s: jumps high, then shakes downward with fast vibrato, ends in a nicker.
    ws, we = 1.7, 3.3

    def wf0(t):
        u = (t - ws) / (we - ws)
        if u < 0.1:
            base = 520 + 620 * (u / 0.1)
        elif u < 0.8:
            base = 1140 - 700 * ((u - 0.1) / 0.7) ** 0.9
        else:
            base = 210 - 80 * ((u - 0.8) / 0.2)
        vib = 0.07 * math.sin(2 * math.pi * 19 * t) if u < 0.8 else 0.0
        return base * (1 + vib)

    def wamp(t):
        u = (t - ws) / (we - ws)
        trem = 0.65 + 0.35 * math.sin(2 * math.pi * 19 * t) if u < 0.8 else 0.6 + 0.4 * math.sin(2 * math.pi * 11 * t)
        return env_adsr(t, ws, 0.06, (we - ws) * 0.62, (we - ws) * 0.34) * trem

    v, a = voice(wf0, wamp, ws, we, jitter=0.02, subharmonic=0.15, breath=0.22)
    nasal = [(950, 4.0, 1.0), (1900, 5.0, 0.7), (3100, 6.0, 0.35), (4300, 7.0, 0.15)]
    whinny = formants([v[i] + a[i] for i in range(N)], nasal)
    whinny = filt(whinny, Biquad('highpass', 160, 0.7))

    # Snort / blow at 4.7 s: two puffs of air through the nostrils.
    snort = [0.0] * N
    for st, lvl in ((4.7, 1.0), (4.95, 0.6)):
        for i in range(int(st * SR), int((st + 0.3) * SR)):
            tt = i / SR
            flutter = 0.6 + 0.4 * math.sin(2 * math.pi * 38 * tt)
            snort[i] += noise() * lvl * env_adsr(tt, st, 0.015, 0.06, 0.2) * flutter
    snort = formants(snort, [(650, 1.6, 1.0), (1800, 2.0, 0.5)])

    # Horse moves left → right; the voice follows it.
    def pos(t):
        return max(-0.9, min(0.9, -0.9 + 1.8 * (t / DUR)))

    hl, hr = pan(hooves, pos)
    vl, vr = pan([whinny[i] * 1.9 + snort[i] * 0.9 for i in range(N)], pos)
    left = reverb([hl[i] * 0.9 + vl[i] for i in range(N)], room=0.7, damp=0.5, wet=0.18)
    right = reverb([hr[i] * 0.9 + vr[i] for i in range(N)], room=0.7, damp=0.5, wet=0.18, spread=19)
    write_stereo('sound_horse.wav', left, right)


# --------------------------------------------------------------------------- DOLPHIN
def dolphin():
    out_l = [0.0] * N
    out_r = [0.0] * N

    # Underwater ambience: low rumble + random bubbles.
    amb = filt([noise() * 0.25 for _ in range(N)], Biquad('lowpass', 420, 0.7))
    for _ in range(90):
        st = rng.uniform(0, DUR - 0.1)
        f_start = rng.uniform(400, 900)
        length = rng.uniform(0.02, 0.06)
        side = rng.random()
        phase = 0.0
        for j in range(int(length * SR)):
            i = int(st * SR) + j
            if i >= N:
                break
            u = j / (length * SR)
            phase += 2 * math.pi * f_start * (1 + 2.5 * u) / SR
            b = math.sin(phase) * math.sin(math.pi * u) * 0.12
            out_l[i] += b * (1 - side)
            out_r[i] += b * side

    # Signature whistles: smooth up/down sweeps with a harmonic.
    whistles = [(0.4, 0.9, 7000, 13500, -0.4), (1.45, 0.7, 9000, 15000, 0.3), (2.4, 1.1, 6500, 12000, -0.1),
                (3.9, 0.6, 10000, 14500, 0.5), (4.8, 1.0, 7500, 13000, -0.3), (6.0, 0.6, 9000, 12500, 0.2)]
    for st, length, lo, hi, p in whistles:
        phase = 0.0
        for j in range(int(length * SR)):
            i = int(st * SR) + j
            if i >= N:
                break
            u = j / (length * SR)
            f = lo + (hi - lo) * (0.5 - 0.5 * math.cos(2 * math.pi * u * 1.25)) + 300 * math.sin(2 * math.pi * 6 * u)
            phase += 2 * math.pi * f / SR
            s = (math.sin(phase) + 0.25 * math.sin(2 * phase)) * math.sin(math.pi * u) ** 0.6 * 0.32
            out_l[i] += s * (1 - p) / 2
            out_r[i] += s * (1 + p) / 2

    # Echolocation click trains that speed up into a "buzz".
    for st, count, p in ((1.0, 26, 0.4), (3.2, 34, -0.4), (5.4, 22, 0.1)):
        t = st
        for k in range(count):
            gap = 0.06 * (0.92 ** k) + 0.006
            for j in range(int(0.0015 * SR)):
                i = int(t * SR) + j
                if i < N:
                    c = noise() * math.exp(-j / (0.0003 * SR)) * 0.6
                    out_l[i] += c * (1 - p) / 2
                    out_r[i] += c * (1 + p) / 2
            t += gap

    # Breach & splash at the animation impact (1.6 s) and a smaller one at 4.4 s.
    for st, lvl in ((1.55, 1.0), (4.4, 0.6)):
        for i in range(int(st * SR), min(N, int((st + 1.2) * SR))):
            tt = i / SR - st
            s = noise() * lvl * math.exp(-tt * 3.2) * (0.6 + 0.4 * math.sin(tt * 90))
            out_l[i] += s * 0.5
            out_r[i] += s * 0.5

    left = filt([out_l[i] + amb[i] for i in range(N)], Biquad('highpass', 40, 0.7))
    right = filt([out_r[i] + amb[i] for i in range(N)], Biquad('highpass', 40, 0.7))
    write_stereo('sound_ocean_dolphin.wav', reverb(left, room=0.8, wet=0.28), reverb(right, room=0.8, wet=0.28, spread=17))


if __name__ == '__main__':
    lion()
    horse()
    dolphin()
