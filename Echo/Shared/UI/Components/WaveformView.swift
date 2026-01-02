import SwiftUI

struct WaveformView: View {
    let levels: [Float]
    var barCount: Int = 30
    var barSpacing: CGFloat = 4
    var minBarHeight: CGFloat = 4

    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: barSpacing) {
                ForEach(0..<barCount, id: \.self) { index in
                    WaveformBar(
                        level: levelForIndex(index),
                        maxHeight: geometry.size.height,
                        minHeight: minBarHeight
                    )
                }
            }
        }
    }

    private func levelForIndex(_ index: Int) -> Float {
        guard !levels.isEmpty else { return 0.1 }

        // Map bar index to level index
        let levelIndex = Int(Float(index) / Float(barCount) * Float(levels.count))
        guard levelIndex < levels.count else { return 0.1 }

        return levels[levelIndex]
    }
}

struct WaveformBar: View {
    let level: Float
    let maxHeight: CGFloat
    let minHeight: CGFloat

    var body: some View {
        RoundedRectangle(cornerRadius: 2)
            .fill(Color.blue.opacity(0.7))
            .frame(height: barHeight)
    }

    private var barHeight: CGFloat {
        let height = CGFloat(level) * maxHeight
        return max(minHeight, min(maxHeight, height))
    }
}

#Preview {
    WaveformView(levels: (0..<50).map { _ in Float.random(in: 0.1...1.0) })
        .frame(height: 100)
        .padding()
}
