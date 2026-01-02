import SwiftUI

struct WaveformView: View {
    let power: Float

    private var normalizedPower: CGFloat {
        let minDb: Float = -60
        let clampedPower = max(power, minDb)
        return CGFloat((clampedPower - minDb) / (-minDb))
    }

    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 4) {
                ForEach(0..<20, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(.blue.opacity(0.7))
                        .frame(width: (geometry.size.width - 76) / 20)
                        .frame(height: barHeight(for: index, in: geometry.size.height))
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    private func barHeight(for index: Int, in maxHeight: CGFloat) -> CGFloat {
        let baseHeight = maxHeight * 0.2
        let variation = sin(Double(index) * 0.5 + Double(power) * 0.1) * 0.5 + 0.5
        let powerHeight = maxHeight * normalizedPower * CGFloat(variation)
        return max(baseHeight, powerHeight)
    }
}

#Preview {
    WaveformView(power: -30)
        .frame(height: 100)
        .padding()
}
