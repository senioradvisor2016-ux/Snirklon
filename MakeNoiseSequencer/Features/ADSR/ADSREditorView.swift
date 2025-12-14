import SwiftUI

/// Visual ADSR Envelope Editor
struct ADSREditorView: View {
    @Binding var envelope: ADSREnvelope
    var height: CGFloat = 120
    var showLabels: Bool = true
    
    var body: some View {
        VStack(spacing: DS.Space.s) {
            // Envelope visualization
            envelopeGraph
            
            // ADSR sliders
            if showLabels {
                adsrControls
            }
        }
    }
    
    // MARK: - Envelope Graph
    
    private var envelopeGraph: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottomLeading) {
                // Background grid
                envelopeGrid(in: geometry.size)
                
                // Envelope shape
                envelopePath(in: geometry.size)
                    .stroke(DS.Color.led, lineWidth: 2)
                    .shadow(color: DS.Color.led.opacity(0.5), radius: 4)
                
                // Envelope fill
                envelopePath(in: geometry.size)
                    .fill(
                        LinearGradient(
                            colors: [DS.Color.led.opacity(0.3), DS.Color.led.opacity(0.05)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                
                // Phase markers
                phaseMarkers(in: geometry.size)
                
                // Draggable control points
                controlPoints(in: geometry.size)
            }
        }
        .frame(height: height)
        .background(
            RoundedRectangle(cornerRadius: DS.Radius.s)
                .fill(DS.Color.cutout)
        )
        .overlay(
            RoundedRectangle(cornerRadius: DS.Radius.s)
                .stroke(DS.Color.etchedLine, lineWidth: DS.Stroke.hairline)
        )
    }
    
    private func envelopeGrid(in size: CGSize) -> some View {
        Canvas { context, canvasSize in
            let gridColor = DS.Color.etchedLineSoft
            
            // Vertical lines (time divisions)
            for i in 1..<4 {
                let x = canvasSize.width * CGFloat(i) / 4
                var path = Path()
                path.move(to: CGPoint(x: x, y: 0))
                path.addLine(to: CGPoint(x: x, y: canvasSize.height))
                context.stroke(path, with: .color(gridColor), lineWidth: 0.5)
            }
            
            // Horizontal lines (level divisions)
            for i in 1..<4 {
                let y = canvasSize.height * CGFloat(i) / 4
                var path = Path()
                path.move(to: CGPoint(x: 0, y: y))
                path.addLine(to: CGPoint(x: canvasSize.width, y: y))
                context.stroke(path, with: .color(gridColor), lineWidth: 0.5)
            }
        }
    }
    
    private func envelopePath(in size: CGSize) -> Path {
        let points = envelope.generatePoints(resolution: 100)
        var path = Path()
        
        let padding: CGFloat = 8
        let drawWidth = size.width - padding * 2
        let drawHeight = size.height - padding * 2
        
        for (index, point) in points.enumerated() {
            let x = padding + point.x * drawWidth
            let y = padding + (1 - point.y) * drawHeight
            
            if index == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }
        
        return path
    }
    
    private func phaseMarkers(in size: CGSize) -> some View {
        let totalTime = envelope.attack + envelope.decay + (envelope.totalTime * 0.3) + envelope.release
        let padding: CGFloat = 8
        let drawWidth = size.width - padding * 2
        
        let attackEnd = padding + (envelope.attack / totalTime) * drawWidth
        let decayEnd = padding + ((envelope.attack + envelope.decay) / totalTime) * drawWidth
        let sustainEnd = padding + ((envelope.attack + envelope.decay + envelope.totalTime * 0.3) / totalTime) * drawWidth
        
        return ZStack(alignment: .bottom) {
            // Phase labels
            HStack(spacing: 0) {
                Text("A")
                    .frame(width: attackEnd - padding)
                Text("D")
                    .frame(width: decayEnd - attackEnd)
                Text("S")
                    .frame(width: sustainEnd - decayEnd)
                Text("R")
                    .frame(maxWidth: .infinity)
            }
            .font(DS.Font.monoXS)
            .foregroundStyle(DS.Color.textMuted)
            .padding(.horizontal, padding)
            .padding(.bottom, 2)
        }
    }
    
    private func controlPoints(in size: CGSize) -> some View {
        let totalTime = envelope.attack + envelope.decay + (envelope.totalTime * 0.3) + envelope.release
        let padding: CGFloat = 8
        let drawWidth = size.width - padding * 2
        let drawHeight = size.height - padding * 2
        
        // Calculate positions
        let attackX = padding + (envelope.attack / totalTime) * drawWidth
        let attackY = padding  // Peak at top
        
        let decayX = padding + ((envelope.attack + envelope.decay) / totalTime) * drawWidth
        let decayY = padding + (1 - envelope.sustain) * drawHeight
        
        let sustainX = padding + ((envelope.attack + envelope.decay + envelope.totalTime * 0.3) / totalTime) * drawWidth
        let sustainY = decayY
        
        return ZStack {
            // Attack point
            controlPoint(at: CGPoint(x: attackX, y: attackY), label: "A", color: .orange)
            
            // Decay/Sustain point
            controlPoint(at: CGPoint(x: decayX, y: decayY), label: "D", color: .yellow)
            
            // Sustain end point
            controlPoint(at: CGPoint(x: sustainX, y: sustainY), label: "S", color: .green)
        }
    }
    
    private func controlPoint(at position: CGPoint, label: String, color: Color) -> some View {
        Circle()
            .fill(color)
            .frame(width: 10, height: 10)
            .shadow(color: color.opacity(0.6), radius: 4)
            .position(position)
    }
    
    // MARK: - ADSR Controls
    
    private var adsrControls: some View {
        VStack(spacing: DS.Space.s) {
            // Attack & Decay row
            HStack(spacing: DS.Space.m) {
                ADSRKnob(
                    label: "ATTACK",
                    value: $envelope.attack,
                    range: 1...10000,
                    unit: "ms",
                    isLogarithmic: true
                )
                
                ADSRKnob(
                    label: "DECAY",
                    value: $envelope.decay,
                    range: 1...10000,
                    unit: "ms",
                    isLogarithmic: true
                )
            }
            
            // Sustain & Release row
            HStack(spacing: DS.Space.m) {
                ADSRKnob(
                    label: "SUSTAIN",
                    value: $envelope.sustain,
                    range: 0...1,
                    unit: "%",
                    displayMultiplier: 100
                )
                
                ADSRKnob(
                    label: "RELEASE",
                    value: $envelope.release,
                    range: 1...10000,
                    unit: "ms",
                    isLogarithmic: true
                )
            }
        }
    }
}

// MARK: - ADSR Knob Control

struct ADSRKnob: View {
    let label: String
    @Binding var value: Double
    let range: ClosedRange<Double>
    var unit: String = ""
    var displayMultiplier: Double = 1
    var isLogarithmic: Bool = false
    
    @State private var isDragging = false
    
    var displayValue: String {
        let displayVal = value * displayMultiplier
        if displayVal >= 1000 {
            return String(format: "%.1fk", displayVal / 1000)
        } else if displayVal >= 100 {
            return String(format: "%.0f", displayVal)
        } else if displayVal >= 10 {
            return String(format: "%.1f", displayVal)
        } else {
            return String(format: "%.2f", displayVal)
        }
    }
    
    var body: some View {
        VStack(spacing: DS.Space.xxs) {
            // Label
            Text(label)
                .font(DS.Font.monoXS)
                .foregroundStyle(DS.Color.textMuted)
            
            // Knob visualization
            ZStack {
                // Background arc
                Circle()
                    .stroke(DS.Color.etchedLine, lineWidth: 4)
                    .frame(width: 44, height: 44)
                
                // Value arc
                Circle()
                    .trim(from: 0, to: normalizedValue)
                    .stroke(
                        isDragging ? DS.Color.led : DS.Color.accent,
                        style: StrokeStyle(lineWidth: 4, lineCap: .round)
                    )
                    .frame(width: 44, height: 44)
                    .rotationEffect(.degrees(-90))
                
                // Center indicator
                Circle()
                    .fill(DS.Color.surface2)
                    .frame(width: 32, height: 32)
                
                // Value display
                Text(displayValue)
                    .font(DS.Font.monoXS)
                    .foregroundStyle(DS.Color.textPrimary)
            }
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { gesture in
                        isDragging = true
                        let delta = -gesture.translation.height / 100
                        updateValue(delta: delta)
                    }
                    .onEnded { _ in
                        isDragging = false
                    }
            )
            
            // Unit
            if !unit.isEmpty {
                Text(unit)
                    .font(DS.Font.monoXS)
                    .foregroundStyle(DS.Color.textMuted)
            }
        }
        .frame(maxWidth: .infinity)
    }
    
    private var normalizedValue: Double {
        if isLogarithmic {
            let logMin = log10(range.lowerBound)
            let logMax = log10(range.upperBound)
            let logValue = log10(value)
            return (logValue - logMin) / (logMax - logMin)
        } else {
            return (value - range.lowerBound) / (range.upperBound - range.lowerBound)
        }
    }
    
    private func updateValue(delta: Double) {
        if isLogarithmic {
            let logMin = log10(range.lowerBound)
            let logMax = log10(range.upperBound)
            let logValue = log10(value)
            let newLogValue = max(logMin, min(logMax, logValue + delta * (logMax - logMin)))
            value = pow(10, newLogValue)
        } else {
            let rangeSize = range.upperBound - range.lowerBound
            value = max(range.lowerBound, min(range.upperBound, value + delta * rangeSize))
        }
    }
}

// MARK: - Compact ADSR Display

struct ADSRCompactView: View {
    let envelope: ADSREnvelope
    var width: CGFloat = 80
    var height: CGFloat = 40
    
    var body: some View {
        ZStack {
            // Mini envelope shape
            envelopePath
                .stroke(DS.Color.led, lineWidth: 1.5)
            
            envelopePath
                .fill(DS.Color.led.opacity(0.2))
        }
        .frame(width: width, height: height)
        .background(
            RoundedRectangle(cornerRadius: DS.Radius.s)
                .fill(DS.Color.cutout)
        )
    }
    
    private var envelopePath: Path {
        let points = envelope.generatePoints(resolution: 50)
        var path = Path()
        
        let padding: CGFloat = 4
        let drawWidth = width - padding * 2
        let drawHeight = height - padding * 2
        
        for (index, point) in points.enumerated() {
            let x = padding + point.x * drawWidth
            let y = padding + (1 - point.y) * drawHeight
            
            if index == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }
        
        return path
    }
}

// MARK: - Preset Selector

struct ADSRPresetSelector: View {
    @Binding var envelope: ADSREnvelope
    
    var body: some View {
        VStack(alignment: .leading, spacing: DS.Space.xs) {
            Text("PRESETS")
                .font(DS.Font.monoXS)
                .foregroundStyle(DS.Color.textMuted)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: DS.Space.xs) {
                    ForEach(ADSREnvelope.presets, id: \.id) { preset in
                        presetButton(preset)
                    }
                }
            }
        }
    }
    
    private func presetButton(_ preset: ADSREnvelope) -> some View {
        Button(action: {
            withAnimation(DS.Anim.fast) {
                envelope = ADSREnvelope(
                    id: envelope.id,
                    name: preset.name,
                    attack: preset.attack,
                    decay: preset.decay,
                    sustain: preset.sustain,
                    release: preset.release,
                    attackCurve: preset.attackCurve,
                    decayCurve: preset.decayCurve,
                    releaseCurve: preset.releaseCurve
                )
            }
        }) {
            VStack(spacing: 4) {
                ADSRCompactView(envelope: preset, width: 60, height: 30)
                
                Text(preset.name)
                    .font(DS.Font.monoXS)
                    .foregroundStyle(DS.Color.textSecondary)
            }
            .padding(DS.Space.xs)
            .background(
                RoundedRectangle(cornerRadius: DS.Radius.s)
                    .fill(DS.Color.surface)
                    .overlay(
                        RoundedRectangle(cornerRadius: DS.Radius.s)
                            .stroke(DS.Color.etchedLine, lineWidth: DS.Stroke.hairline)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Curve Selector

struct CurveSelector: View {
    let label: String
    @Binding var curve: EnvelopeCurve
    
    var body: some View {
        VStack(alignment: .leading, spacing: DS.Space.xxs) {
            Text(label)
                .font(DS.Font.monoXS)
                .foregroundStyle(DS.Color.textMuted)
            
            HStack(spacing: DS.Space.xxs) {
                ForEach(EnvelopeCurve.allCases, id: \.self) { curveType in
                    Button(action: { curve = curveType }) {
                        Image(systemName: curveType.icon)
                            .font(.system(size: 12))
                            .foregroundStyle(curve == curveType ? DS.Color.led : DS.Color.textSecondary)
                            .frame(width: 28, height: 28)
                            .background(
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(curve == curveType ? DS.Color.surface2 : DS.Color.surface)
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        ADSREditorView(envelope: .constant(ADSREnvelope()))
        
        ADSRPresetSelector(envelope: .constant(ADSREnvelope()))
    }
    .padding()
    .background(DS.Color.background)
}
