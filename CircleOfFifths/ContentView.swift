import AudioKit
import SwiftUI

class MIDIPlayer: ObservableObject {
    var engine = AudioEngine()
    var sequencer: AppleSequencer
    var sampler: MIDISampler
    
    init() {
        sequencer = AppleSequencer()
        sampler = MIDISampler()
        
        // Настройка MIDI инструмента (Sampler)
        do {
            // Загрузите ваш SoundFont файл
            if let soundFontURL = Bundle.main.url(forResource: "RLNDGM", withExtension: "dls") {
                try sampler.loadSoundFont(soundFontURL.path, preset: 0, bank: 0)
            }
        } catch {
            print("Ошибка при загрузке SoundFont: \(error.localizedDescription)")
        }
        
        // Настройка секвенсора
        if let midiFileURL = Bundle.main.url(forResource: "Cchord", withExtension: "mid") {
            sequencer.loadMIDIFile(fromURL: midiFileURL)
            sequencer.setGlobalMIDIOutput(sampler.midiIn)
            //sequencer.enableLooping()
            
        }
        
        engine.output = sampler
        do {
            try engine.start()
        } catch {
            print("Ошибка при запуске AudioKit: \(error.localizedDescription)")
        }
    }
    
    func play() {
        sequencer.rewind()
        sequencer.play()
    }
    
    // Загрузка и проигрывание MIDI файла
    func loadAndPlayMIDIFile(named midiFileName: String) {
        
        if let midiFileURL = Bundle.main.url(forResource: midiFileName, withExtension: "mid") {
            sequencer.loadMIDIFile(fromURL: midiFileURL)
            sequencer.setGlobalMIDIOutput(sampler.midiIn)
            sequencer.rewind()
            sequencer.play()
        }
        
    }
    func stop() {
        sequencer.stop()
        sequencer.preroll()
    }
}


struct ContentView: View {
    @StateObject private var midiPlayer = MIDIPlayer()
    
    var body: some View {
        ZStack {
            ForEach(0..<12) { i in
                // Внешние сектора
                Button(action: {
                    print("Outer sector \(i + 1) tapped")
                    midiPlayer.stop() // Останавливаем текущую сессию
                    midiPlayer.loadAndPlayMIDIFile(named: outerMIDIArray[i]) // Инициализируем новую сессию
                }) {
                    Sector(startAngle: .degrees(Double(i) * sectorDegrees + 15),
                           endAngle: .degrees(Double(i + 1) * sectorDegrees + 15),
                           innerRadiusRatio: 0.7)
                    .fill(Color(hue: Double(i) / 12, saturation: 1, brightness: 1))
                    .frame(width: 350, height: 350)
                    .overlay(
                        Text(outerArray[i])
                            .foregroundColor(.black)
                            .position(x: getTextXPosition(i: i),
                                      y: getTextYPosition(i: i))
                    )
                }
                .contentShape(Sector(startAngle: .degrees(Double(i) * sectorDegrees + 15),
                                     endAngle: .degrees(Double(i + 1) * sectorDegrees + 15),
                                     innerRadiusRatio: 0.5))
                .buttonStyle(PlainButtonStyle())
                Text("Circle \nof fifths")
            }
            
            ForEach(0..<12) { i in
                // Внутренние сектора
                Button(action: {
                    print("Inner sector \(i + 1) tapped")
                    midiPlayer.stop()
                    midiPlayer.loadAndPlayMIDIFile(named: innerMIDIArray[i])
                }) {
                    Sector(startAngle: .degrees(Double(i) * sectorDegrees + 15),
                           endAngle: .degrees(Double(i + 1) * sectorDegrees + 15),
                           innerRadiusRatio: 0.6)
                    .fill(Color(hue: Double(i+3) / 12, saturation: 1, brightness: 1))
                    .frame(width: 250, height: 250) // Изменена размерность для внутреннего сектора
                    .overlay(
                        Text(innerArray[i])
                            .foregroundColor(.black)
                            .position(x: getTextXPositionInner(i: i) - 75,
                                      y: getTextYPositionInner(i: i) - 75)
                    )
                }
                .contentShape(Sector(startAngle: .degrees(Double(i) * sectorDegrees + 15),
                                     endAngle: .degrees(Double(i + 1) * sectorDegrees + 15),
                                     innerRadiusRatio: 0))
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
    
    var sectorDegrees: Double = 30
    var outerArray = ["E", "B", "G♭", "D♭", "A♭", "E♭", "B♭", "F", "C", "G", "D", "A"]
    var innerArray = ["C♯m", "G♯m", "E♭m", "B♭m", "Fm", "Cm", "Gm", "Dm", "Am", "Em", "Bm", "F♯m"]
    
    // Массивы для хранения названий MIDI файлов
    var outerMIDIArray = ["E", "B", "Gb", "Db", "Ab", "Eb", "Bb", "F", "C", "G", "D", "A"]
    var innerMIDIArray = ["C#m", "G#m", "Ebm", "Bbm", "Fm", "Cm", "Gm", "Dm", "Am", "Em", "Bm", "F#m"]
    
    func buttonTapped(index: Int) {
        print("Sector \(index) tapped!")
    }
    
    func getTextXPosition(i: Int) -> Double {
        let xPosition = 175 + 150 * cos(CGFloat((Double(i) * 30 + 30) * Double.pi / 180))
        //x: 150 + 37.5 * cos(CGFloat((Double(i) * 60 + 30) * Double.pi / 180))
        return xPosition
    }
    
    func getTextYPosition(i: Int) -> Double {
        let yPosition = 175 + 150 * sin(CGFloat((Double(i) * 30 + 30) * Double.pi / 180))
        return yPosition
    }
    
    func getTextXPositionInner(i: Int) -> Double {
        let xPosition = 200 + 100 * cos(CGFloat((Double(i) * 30 + 30) * Double.pi / 180))
        return xPosition
    }
    
    func getTextYPositionInner(i: Int) -> Double {
        let yPosition = 200 + 100 * sin(CGFloat((Double(i) * 30 + 30) * Double.pi / 180))
        return yPosition
    }
    
}

#Preview {
    ContentView()
}
