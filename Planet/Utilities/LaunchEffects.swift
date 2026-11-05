//
//  LaunchEffects.swift
//  Planet
//
//  Sounds and haptics for a Mission Control launch: countdown beeps, a
//  liftoff rumble, popping stars, and a chime or a "wah-wah" for the result.
//
//  The sounds are synthesised here rather than shipped as audio files, so
//  there's nothing to license or bundle. They use the `.ambient` audio
//  session: silent when the ringer switch is off, and mixed with (not
//  interrupting) anything else that's playing.
//

import AVFoundation
import CoreHaptics
import UIKit

@MainActor
final class LaunchEffects {
    static let shared = LaunchEffects()

    private var cache: [String: Data] = [:]
    /// Players are kept until they finish, or the sound would be cut off.
    private var playing: [AVAudioPlayer] = []
    private var hapticEngine: CHHapticEngine?
    private var sessionReady = false

    private init() {}

    private var soundOn: Bool {
        UserDefaults.standard.object(forKey: SettingsKey.soundEffectsEnabled) as? Bool ?? true
    }

    private var hapticsOn: Bool {
        UserDefaults.standard.object(forKey: SettingsKey.hapticsEnabled) as? Bool ?? true
    }

    // MARK: - Moments

    /// "3", "2", "1": the last beep is higher, like a real countdown.
    func countdown(_ n: Int) {
        play("count\(n)") { Synth.tone(n == 1 ? 1_046 : 784, duration: 0.14) }
        playHaptic(n == 1 ? .medium : .light)
    }

    func liftoff() {
        play("liftoff") { Synth.rumble(duration: 1.4) }
        rumble()
    }

    /// One per star as they pop in, each a step higher.
    func star(_ index: Int) {
        let notes: [Double] = [784, 988, 1_175]
        play("star\(index)") { Synth.tone(notes[min(max(index - 1, 0), 2)], duration: 0.12) }
        playHaptic(.rigid)
    }

    /// A rubber stamp hitting paper: a short thud.
    func stamp() {
        play("stamp") { Synth.thud() }
        playHaptic(.heavy)
    }

    func success() {
        play("success") { Synth.arpeggio([523, 659, 784, 1_046], step: 0.09, hold: 0.35) }
        playNotificationHaptic(.success)
    }

    func miss() {
        play("miss") { Synth.arpeggio([392, 330], step: 0.22, hold: 0.3) }
        playNotificationHaptic(.error)
    }

    // MARK: - Audio

    private func play(_ key: String, make: () -> Data) {
        guard soundOn else { return }
        prepareSession()
        let data: Data
        if let cached = cache[key] {
            data = cached
        } else {
            data = make()
            cache[key] = data
        }
        playing.removeAll { !$0.isPlaying }
        guard let player = try? AVAudioPlayer(data: data) else { return }
        player.volume = 0.6
        player.play()
        playing.append(player)
    }

    private func prepareSession() {
        guard !sessionReady else { return }
        try? AVAudioSession.sharedInstance().setCategory(.ambient, options: [.mixWithOthers])
        sessionReady = true
    }

    // MARK: - Haptics

    /// A building engine rumble that cuts off, like booster separation.
    private func rumble() {
        guard hapticsOn else { return }
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else {
            playHaptic(.heavy)
            return
        }
        do {
            if hapticEngine == nil {
                let engine = try CHHapticEngine()
                engine.resetHandler = { [weak engine] in try? engine?.start() }
                hapticEngine = engine
            }
            try hapticEngine?.start()

            let duration = 1.3
            let event = CHHapticEvent(eventType: .hapticContinuous, parameters: [
                CHHapticEventParameter(parameterID: .hapticIntensity, value: 1),
                CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.25)
            ], relativeTime: 0, duration: duration)
            let ramp = CHHapticParameterCurve(parameterID: .hapticIntensityControl, controlPoints: [
                .init(relativeTime: 0, value: 0.35),
                .init(relativeTime: duration * 0.7, value: 1),
                .init(relativeTime: duration, value: 0.2)
            ], relativeTime: 0)
            let pattern = try CHHapticPattern(events: [event], parameterCurves: [ramp])
            try hapticEngine?.makePlayer(with: pattern).start(atTime: CHHapticTimeImmediate)
        } catch {
            playHaptic(.heavy)
        }
    }
}

// MARK: - Synthesiser

/// Builds tiny mono WAV files in memory.
private enum Synth {
    static let sampleRate = 44_100.0

    /// A soft sine "beep" with a quick attack and an exponential fade.
    static func tone(_ frequency: Double, duration: Double) -> Data {
        wav(samples(count: duration) { t in
            envelope(t, duration: duration) * sin(2 * .pi * frequency * t) * 0.5
        })
    }

    /// Notes one after another, each ringing on under the next.
    static func arpeggio(_ notes: [Double], step: Double, hold: Double) -> Data {
        let total = step * Double(notes.count - 1) + hold
        return wav(samples(count: total) { t in
            var v = 0.0
            for (i, f) in notes.enumerated() {
                let local = t - step * Double(i)
                guard local >= 0, local < hold else { continue }
                v += envelope(local, duration: hold) * (sin(2 * .pi * f * local) + 0.3 * sin(4 * .pi * f * local))
            }
            return v * 0.3
        })
    }

    /// Filtered noise that swells then fades: a rocket engine from far away.
    static func rumble(duration: Double) -> Data {
        var low = 0.0
        var generator = SystemRandomNumberGenerator()
        return wav(samples(count: duration) { t in
            let noise = Double.random(in: -1...1, using: &generator)
            low += (noise - low) * 0.06              // one-pole low-pass
            let swell = min(t / (duration * 0.35), 1) * exp(-max(t - duration * 0.35, 0) * 2.2)
            return low * swell * 2.2
        })
    }

    /// A low knock with a little paper slap on top.
    static func thud() -> Data {
        var generator = SystemRandomNumberGenerator()
        return wav(samples(count: 0.18) { t in
            let body = sin(2 * .pi * 110 * t) * exp(-t * 30)
            let slap = Double.random(in: -1...1, using: &generator) * exp(-t * 90) * 0.5
            return (body + slap) * 0.5
        })
    }

    private static func envelope(_ t: Double, duration: Double) -> Double {
        let attack = min(t / 0.008, 1)
        return attack * exp(-t * 5 / duration)
    }

    private static func samples(count duration: Double, _ value: (Double) -> Double) -> [Int16] {
        let n = Int(duration * sampleRate)
        return (0..<n).map { i in
            let v = max(-1, min(1, value(Double(i) / sampleRate)))
            return Int16(v * Double(Int16.max))
        }
    }

    /// 16-bit PCM mono WAV.
    private static func wav(_ pcm: [Int16]) -> Data {
        let dataSize = UInt32(pcm.count * 2)
        var d = Data()
        func append<T: FixedWidthInteger>(_ v: T) { withUnsafeBytes(of: v.littleEndian) { d.append(contentsOf: $0) } }
        d.append(contentsOf: Array("RIFF".utf8)); append(UInt32(36) + dataSize)
        d.append(contentsOf: Array("WAVE".utf8))
        d.append(contentsOf: Array("fmt ".utf8)); append(UInt32(16)); append(UInt16(1)); append(UInt16(1))
        append(UInt32(sampleRate)); append(UInt32(sampleRate) * 2); append(UInt16(2)); append(UInt16(16))
        d.append(contentsOf: Array("data".utf8)); append(dataSize)
        pcm.forEach { append($0) }
        return d
    }
}
