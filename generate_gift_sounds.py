import math
import struct
import wave
import os

SAMPLE_RATE = 44100

def write_wav(filename, samples):
    filepath = os.path.join('assets', 'sounds', filename)
    with wave.open(filepath, 'w') as wav:
        wav.setnchannels(1)  # Mono
        wav.setsampwidth(2)  # 16-bit
        wav.setframerate(SAMPLE_RATE)
        
        # Normalize and convert to 16-bit PCM
        max_amp = max(abs(s) for s in samples) if samples else 1.0
        if max_amp == 0:
            max_amp = 1.0
        scale = 32767.0 * 0.90 / max_amp
        
        raw_bytes = bytearray()
        for s in samples:
            val = int(max(-32767, min(32767, s * scale)))
            raw_bytes.extend(struct.pack('<h', val))
        wav.writeframes(raw_bytes)
    print(f"Generated {filepath} ({len(samples)/SAMPLE_RATE:.2f}s)")

def make_noise():
    state = 1234567
    while True:
        state = (1103515245 * state + 12345) & 0x7FFFFFFF
        yield (state / 0x3FFFFFFF) - 1.0

noise_gen = make_noise()

# 1. HORSE: Galloping hoofbeats + whinny/neigh
def gen_horse():
    duration = 4.4
    total_samples = int(SAMPLE_RATE * duration)
    samples = [0.0] * total_samples
    
    # Galloping hoofbeats (4-beat rhythm repeated, accelerating then cresting)
    gallop_times = [
        0.15, 0.23, 0.32, 0.40,
        0.65, 0.72, 0.80, 0.88,
        1.10, 1.17, 1.25, 1.32,
        1.55, 1.62, 1.69, 1.76,
        1.98, 2.05, 2.12, 2.19,
        2.40, 2.47, 2.54, 2.61,
        2.85, 2.92, 2.99, 3.06,
        3.30, 3.37, 3.44, 3.51,
        3.72, 3.79, 3.86, 3.93
    ]
    
    for t_strike in gallop_times:
        start_idx = int(t_strike * SAMPLE_RATE)
        strike_dur = int(SAMPLE_RATE * 0.08)
        for i in range(strike_dur):
            if start_idx + i < total_samples:
                t = i / SAMPLE_RATE
                env = math.exp(-t * 60)
                thump = (math.sin(2 * math.pi * 180 * t) * 0.7 + 
                         math.sin(2 * math.pi * 320 * t) * 0.3)
                click = next(noise_gen) * math.exp(-t * 150) * 0.4
                samples[start_idx + i] += (thump + click) * env * 0.85
                
    # Center Climax: Horse Neigh / Whinny (starts at 1.4s, lasts ~1.6s)
    neigh_start = int(1.4 * SAMPLE_RATE)
    neigh_len = int(1.6 * SAMPLE_RATE)
    for i in range(neigh_len):
        if neigh_start + i < total_samples:
            t = i / SAMPLE_RATE
            p = i / neigh_len
            
            if p < 0.15:
                env = p / 0.15
            elif p > 0.70:
                env = (1.0 - p) / 0.30
            else:
                env = 1.0
                
            base_freq = 950 + 500 * math.sin(p * math.pi * 0.8) - (p * 400)
            flutter = math.sin(2 * math.pi * 22 * t) * 120 * (1.0 - p * 0.4)
            freq = max(300, base_freq + flutter)
            
            phase = 2 * math.pi * freq * t
            whinny = (math.sin(phase) * 0.5 + 
                      math.sin(phase * 2) * 0.3 + 
                      math.sin(phase * 3) * 0.15 +
                      math.sin(phase * 4) * 0.08)
            whinny += next(noise_gen) * 0.08
            samples[neigh_start + i] += whinny * env * 0.95

    return samples

# 2. CAR: V10 Engine rev, turbo spool, tire screech
def gen_car():
    duration = 4.4
    total_samples = int(SAMPLE_RATE * duration)
    samples = [0.0] * total_samples
    
    for i in range(total_samples):
        t = i / SAMPLE_RATE
        p = i / total_samples
        
        if p < 0.30:
            rpm = 130 + (p / 0.30) * 350
            env = p / 0.10 if p < 0.10 else 1.0
        elif p < 0.40:
            rpm = 320 - (p - 0.30) * 200
            env = 0.8
        else:
            p2 = (p - 0.40) / 0.60
            rpm = 250 + (p2 * 450)
            env = 1.0 if p < 0.85 else (1.0 - p) / 0.15
            
        phase = 2 * math.pi * rpm * t
        engine = (math.sin(phase) * 0.4 + 
                  math.sin(phase * 2) * 0.3 + 
                  math.sin(phase * 3) * 0.15 + 
                  math.sin(phase * 5) * 0.1 +
                  math.sin(phase * 8) * 0.05)
        sub = math.sin(phase * 0.5) * 0.3
        
        turbo_freq = 2500 + (rpm * 4.0)
        turbo = math.sin(2 * math.pi * turbo_freq * t) * 0.12 * min(1.0, p * 2)
        
        screech = 0.0
        if 1.8 <= t <= 2.6:
            screech_t = (t - 1.8) / 0.8
            screech_env = math.sin(screech_t * math.pi)
            screech_freq = 1800 + math.sin(t * 80) * 400
            screech = (math.sin(2 * math.pi * screech_freq * t) + next(noise_gen) * 0.6) * 0.25 * screech_env
            
        samples[i] = (engine + sub + turbo + screech) * env

    for pop_time in [1.28, 1.35, 1.42]:
        idx = int(pop_time * SAMPLE_RATE)
        for j in range(int(SAMPLE_RATE * 0.04)):
            if idx + j < total_samples:
                samples[idx + j] += next(noise_gen) * math.exp(-j / (SAMPLE_RATE * 0.008)) * 0.7

    return samples

# 3. LION: Deep guttural roar
def gen_lion():
    duration = 4.4
    total_samples = int(SAMPLE_RATE * duration)
    samples = [0.0] * total_samples
    
    for i in range(total_samples):
        t = i / SAMPLE_RATE
        p = i / total_samples
        
        if p < 0.25:
            env = p / 0.25
            freq = 65 + (p * 40)
            rasp = 20
        elif p < 0.75:
            roar_p = (p - 0.25) / 0.50
            env = math.sin(roar_p * math.pi) * 1.2
            freq = 95 - (roar_p * 35) + math.sin(t * 15) * 10
            rasp = 30 + math.sin(t * 12) * 8
        else:
            decay_p = (p - 0.75) / 0.25
            env = (1.0 - decay_p) * 0.5
            freq = 60
            rasp = 18
            
        phase = 2 * math.pi * freq * t
        amp_mod = 0.5 + 0.5 * math.sin(2 * math.pi * rasp * t)
        throat = (math.sin(phase) * 0.5 + 
                  math.sin(phase * 2) * 0.35 + 
                  math.sin(phase * 3) * 0.2 + 
                  math.sin(phase * 4) * 0.15)
        wind = next(noise_gen) * 0.45 * amp_mod
        samples[i] = (throat * amp_mod + wind) * min(1.0, env)

    return samples

# 4. ROCKET: Ignition rumble and ascent
def gen_rocket():
    duration = 4.4
    total_samples = int(SAMPLE_RATE * duration)
    samples = [0.0] * total_samples
    
    for i in range(total_samples):
        t = i / SAMPLE_RATE
        p = i / total_samples
        env = min(1.0, p / 0.15) * (1.0 if p < 0.85 else (1.0 - p) / 0.15)
        sub = math.sin(2 * math.pi * (40 + p * 30) * t) * 0.4
        noise = next(noise_gen) * 0.65
        whine_freq = 400 + (p * 1800)
        whine = math.sin(2 * math.pi * whine_freq * t) * 0.15 * p
        samples[i] = (sub + noise + whine) * env

    return samples

# 5. YACHT: Horn + waves
def gen_yacht():
    duration = 4.4
    total_samples = int(SAMPLE_RATE * duration)
    samples = [0.0] * total_samples
    
    for i in range(total_samples):
        t = i / SAMPLE_RATE
        horn_env = 0.0
        if 0.3 <= t <= 1.8:
            hp = (t - 0.3) / 1.5
            horn_env = min(1.0, hp / 0.1) * (1.0 if hp < 0.85 else (1.0 - hp) / 0.15)
        elif 2.2 <= t <= 3.6:
            hp = (t - 2.2) / 1.4
            horn_env = min(1.0, hp / 0.1) * (1.0 if hp < 0.85 else (1.0 - hp) / 0.15) * 0.85
            
        horn = 0.0
        if horn_env > 0.0:
            p1 = 2 * math.pi * 130 * t
            p2 = 2 * math.pi * 195 * t
            horn = ((math.sin(p1) + 0.6 * math.sin(p1 * 2) + 0.3 * math.sin(p1 * 3)) * 0.5 + 
                    (math.sin(p2) + 0.5 * math.sin(p2 * 2) + 0.25 * math.sin(p2 * 3)) * 0.4) * horn_env
                    
        swell = (math.sin(2 * math.pi * 0.4 * t) * 0.5 + 0.5)
        wave_surf = next(noise_gen) * 0.22 * swell
        samples[i] = horn + wave_surf

    return samples

# 6. WHALE: Whale call + splash
def gen_whale():
    duration = 4.4
    total_samples = int(SAMPLE_RATE * duration)
    samples = [0.0] * total_samples
    
    for i in range(total_samples):
        t = i / SAMPLE_RATE
        whale_env = 0.0
        freq = 400.0
        if 0.2 <= t <= 2.0:
            cp = (t - 0.2) / 1.8
            whale_env = math.sin(cp * math.pi)
            freq = 380 + 320 * math.sin(cp * math.pi)
        elif 2.3 <= t <= 3.9:
            cp = (t - 2.3) / 1.6
            whale_env = math.sin(cp * math.pi) * 0.9
            freq = 450 + 380 * math.sin(cp * math.pi)
            
        whale_tone = 0.0
        if whale_env > 0.0:
            vib = math.sin(2 * math.pi * 5.5 * t) * 15
            phase = 2 * math.pi * (freq + vib) * t
            whale_tone = (math.sin(phase) + 0.35 * math.sin(phase * 2) + 0.15 * math.sin(phase * 3)) * whale_env * 0.75
            
        splash = 0.0
        if 1.15 <= t <= 2.5:
            sp_t = (t - 1.15) / 1.35
            sp_env = math.exp(-sp_t * 4.5)
            splash = next(noise_gen) * sp_env * 0.45
            
        samples[i] = whale_tone + splash

    return samples

# 7. WINGS: Harp & choir
def gen_wings():
    duration = 4.0
    total_samples = int(SAMPLE_RATE * duration)
    samples = [0.0] * total_samples
    notes = [261.63, 329.63, 392.00, 493.88, 587.33, 659.25, 783.99, 1046.50, 1318.51, 1567.98]
    step_duration = 0.14
    
    for idx, f in enumerate(notes):
        note_start = int((0.15 + idx * step_duration) * SAMPLE_RATE)
        for i in range(int(SAMPLE_RATE * 1.6)):
            if note_start + i < total_samples:
                t = i / SAMPLE_RATE
                env = math.exp(-t * 2.8)
                note = (math.sin(2 * math.pi * f * t) * 0.6 + 
                        math.sin(2 * math.pi * f * 2 * t) * 0.25 + 
                        math.sin(2 * math.pi * f * 3 * t) * 0.1)
                samples[note_start + i] += note * env * 0.35

    for i in range(total_samples):
        t = i / SAMPLE_RATE
        p = i / total_samples
        choir_env = math.sin(p * math.pi) * 0.3
        f_choir = 523.25
        choir = (math.sin(2 * math.pi * f_choir * t) + 
                 math.sin(2 * math.pi * (f_choir * 1.5) * t) * 0.6) * choir_env
        samples[i] += choir

    return samples

# 8. CROWN: Royal fanfare
def gen_crown():
    duration = 4.0
    total_samples = int(SAMPLE_RATE * duration)
    samples = [0.0] * total_samples
    fanfare_notes = [
        (0.2, 0.25, 392.0),
        (0.5, 0.25, 523.25),
        (0.8, 0.25, 659.25),
        (1.1, 1.8, 783.99),
    ]
    for start_t, dur, f in fanfare_notes:
        start_idx = int(start_t * SAMPLE_RATE)
        note_len = int(dur * SAMPLE_RATE)
        for i in range(note_len):
            if start_idx + i < total_samples:
                t = i / SAMPLE_RATE
                env = min(1.0, i / (SAMPLE_RATE * 0.04)) * math.exp(-t * (1.2 if dur > 1.0 else 3.0))
                phase = 2 * math.pi * f * t
                brass = (math.sin(phase) * 0.5 + 
                         math.sin(phase * 2) * 0.35 + 
                         math.sin(phase * 3) * 0.2 + 
                         math.sin(phase * 4) * 0.1)
                bell = math.sin(2 * math.pi * f * 4 * t) * math.exp(-t * 15) * 0.3
                samples[start_idx + i] += (brass + bell) * env * 0.6

    return samples

# 9. DIAMOND: Crystal chimes
def gen_diamond():
    duration = 4.0
    total_samples = int(SAMPLE_RATE * duration)
    samples = [0.0] * total_samples
    crystal_freqs = [2093.0, 2637.0, 3135.9, 3951.0, 4186.0, 5274.0, 6271.9]
    for idx, f in enumerate(crystal_freqs):
        start_idx = int((0.2 + idx * 0.18) * SAMPLE_RATE)
        for i in range(int(SAMPLE_RATE * 1.5)):
            if start_idx + i < total_samples:
                t = i / SAMPLE_RATE
                env = math.exp(-t * 4.0)
                shimmer = math.sin(2 * math.pi * 12 * t) * 0.2
                tone = math.sin(2 * math.pi * f * t) * (1.0 + shimmer)
                samples[start_idx + i] += tone * env * 0.35

    return samples

# 10. ROSE / FLOWERS: Fairy chimes
def gen_rose():
    duration = 4.0
    total_samples = int(SAMPLE_RATE * duration)
    samples = [0.0] * total_samples
    sparkle_notes = [1046.5, 1174.66, 1318.51, 1567.98, 1760.0, 2093.0, 2349.32, 2637.0]
    for idx, f in enumerate(sparkle_notes):
        start_idx = int((0.15 + idx * 0.15) * SAMPLE_RATE)
        for i in range(int(SAMPLE_RATE * 1.2)):
            if start_idx + i < total_samples:
                t = i / SAMPLE_RATE
                env = math.exp(-t * 3.5)
                tone = (math.sin(2 * math.pi * f * t) * 0.6 + 
                        math.sin(2 * math.pi * f * 2 * t) * 0.2)
                samples[start_idx + i] += tone * env * 0.30

    return samples

# 11. CASTLE: Royal orchestra & fireworks
def gen_castle():
    duration = 4.2
    total_samples = int(SAMPLE_RATE * duration)
    samples = [0.0] * total_samples
    chord_freqs = [261.63, 329.63, 392.00, 523.25]
    for f in chord_freqs:
        for i in range(int(SAMPLE_RATE * 3.5)):
            if i < total_samples:
                t = i / SAMPLE_RATE
                env = min(1.0, t / 0.5) * (1.0 if t < 2.5 else (3.5 - t) / 1.0)
                tone = math.sin(2 * math.pi * f * t) * 0.25
                samples[i] += tone * env * 0.4
                
    for firework_t in [1.0, 1.8, 2.6]:
        idx = int(firework_t * SAMPLE_RATE)
        for j in range(int(SAMPLE_RATE * 0.8)):
            if idx + j < total_samples:
                t = j / SAMPLE_RATE
                boom = math.sin(2 * math.pi * 65 * t) * math.exp(-t * 6) * 0.7
                crackle = next(noise_gen) * math.exp(-t * 4) * 0.35
                samples[idx + j] += (boom + crackle) * 0.65

    return samples

# 12. LOVE: Heartbeat pulse + shimmer
def gen_love():
    duration = 4.0
    total_samples = int(SAMPLE_RATE * duration)
    samples = [0.0] * total_samples
    for beat_t in [0.3, 1.3, 2.3]:
        idx1 = int(beat_t * SAMPLE_RATE)
        for i in range(int(SAMPLE_RATE * 0.18)):
            if idx1 + i < total_samples:
                t = i / SAMPLE_RATE
                env = math.sin((i / (SAMPLE_RATE * 0.18)) * math.pi)
                samples[idx1 + i] += math.sin(2 * math.pi * 55 * t) * env * 0.8
        idx2 = int((beat_t + 0.18) * SAMPLE_RATE)
        for i in range(int(SAMPLE_RATE * 0.22)):
            if idx2 + i < total_samples:
                t = i / SAMPLE_RATE
                env = math.sin((i / (SAMPLE_RATE * 0.22)) * math.pi)
                samples[idx2 + i] += math.sin(2 * math.pi * 50 * t) * env * 0.65

    for idx, f in enumerate([523.25, 659.25, 783.99, 1046.50]):
        start_idx = int((0.6 + idx * 0.3) * SAMPLE_RATE)
        for i in range(int(SAMPLE_RATE * 1.5)):
            if start_idx + i < total_samples:
                t = i / SAMPLE_RATE
                samples[start_idx + i] += math.sin(2 * math.pi * f * t) * math.exp(-t * 2.5) * 0.25

    return samples

# 13. KITTY / TEDDY: Cute meow & pops
def gen_kitty():
    duration = 3.5
    total_samples = int(SAMPLE_RATE * duration)
    samples = [0.0] * total_samples
    meow_start = int(0.3 * SAMPLE_RATE)
    meow_len = int(0.9 * SAMPLE_RATE)
    for i in range(meow_len):
        if meow_start + i < total_samples:
            p = i / meow_len
            t = i / SAMPLE_RATE
            env = math.sin(p * math.pi)
            freq = 650 + 500 * math.sin(p * math.pi * 0.9)
            phase = 2 * math.pi * freq * t
            tone = (math.sin(phase) + 0.4 * math.sin(phase * 2) + 0.2 * math.sin(phase * 3))
            samples[meow_start + i] += tone * env * 0.65

    for pop_t in [1.4, 1.8, 2.2]:
        idx = int(pop_t * SAMPLE_RATE)
        for j in range(int(SAMPLE_RATE * 0.08)):
            if idx + j < total_samples:
                t = j / SAMPLE_RATE
                pop_freq = 900 + t * 4000
                samples[idx + j] += math.sin(2 * math.pi * pop_freq * t) * math.exp(-t * 45) * 0.5

    return samples

# 14. CAKE: Celebration party horn & bells
def gen_cake():
    duration = 3.8
    total_samples = int(SAMPLE_RATE * duration)
    samples = [0.0] * total_samples
    for i in range(int(SAMPLE_RATE * 0.6)):
        t = i / SAMPLE_RATE
        env = min(1.0, t / 0.08) * math.exp(-t * 2.5)
        freq = 550 + (t / 0.6) * 300
        samples[int(0.2 * SAMPLE_RATE) + i] += math.sin(2 * math.pi * freq * t) * env * 0.6
        
    for idx, f in enumerate([523.25, 659.25, 783.99, 1046.5]):
        idx_start = int((0.8 + idx * 0.25) * SAMPLE_RATE)
        for j in range(int(SAMPLE_RATE * 1.2)):
            if idx_start + j < total_samples:
                t = j / SAMPLE_RATE
                samples[idx_start + j] += math.sin(2 * math.pi * f * t) * math.exp(-t * 3) * 0.35

    return samples

# 15. GENERIC: Celebration whoosh
def gen_generic():
    duration = 3.5
    total_samples = int(SAMPLE_RATE * duration)
    samples = [0.0] * total_samples
    for i in range(total_samples):
        t = i / SAMPLE_RATE
        p = i / total_samples
        env = math.sin(p * math.pi)
        whoosh = next(noise_gen) * 0.25 * math.sin(p * math.pi)
        chime = math.sin(2 * math.pi * (880 + 440 * math.sin(p * 4 * math.pi)) * t) * 0.2
        samples[i] = (whoosh + chime) * env

    return samples

print("Generating all high-fidelity gift sound effects...")
write_wav('sound_horse.wav', gen_horse())
write_wav('sound_car.wav', gen_car())
write_wav('sound_lion.wav', gen_lion())
write_wav('sound_rocket.wav', gen_rocket())
write_wav('sound_yacht.wav', gen_yacht())
write_wav('sound_whale.wav', gen_whale())
write_wav('sound_wings.wav', gen_wings())
write_wav('sound_crown.wav', gen_crown())
write_wav('sound_diamond.wav', gen_diamond())
write_wav('sound_rose.wav', gen_rose())
write_wav('sound_castle.wav', gen_castle())
write_wav('sound_love.wav', gen_love())
write_wav('sound_kitty.wav', gen_kitty())
write_wav('sound_cake.wav', gen_cake())
write_wav('sound_generic.wav', gen_generic())
print("All sound effects generated successfully!")
