#!/usr/bin/env swift

import Cocoa
import CoreGraphics

let size: CGFloat = 1024
let image = NSImage(size: NSSize(width: size, height: size))

image.lockFocus()

guard let context = NSGraphicsContext.current?.cgContext else {
    fatalError("Could not get graphics context")
}

// === BACKGROUND: Rich blue gradient ===
let colorSpace = CGColorSpace(name: CGColorSpace.sRGB)!
let bgGradient = CGGradient(
    colorsSpace: colorSpace,
    colors: [
        CGColor(red: 0.10, green: 0.28, blue: 0.58, alpha: 1.0),
        CGColor(red: 0.20, green: 0.45, blue: 0.78, alpha: 1.0),
        CGColor(red: 0.15, green: 0.35, blue: 0.65, alpha: 1.0)
    ] as CFArray,
    locations: [0.0, 0.5, 1.0]
)!

// Rounded rect clip for iOS icon shape (the OS clips it, but good to fill fully)
let bgRect = CGRect(x: 0, y: 0, width: size, height: size)
context.addRect(bgRect)
context.clip()
context.drawLinearGradient(bgGradient, start: CGPoint(x: 0, y: size), end: CGPoint(x: size, y: 0), options: [])

// === GLOBE: Large circle in center ===
let globeCenter = CGPoint(x: size / 2, y: size / 2 + 20)
let globeRadius: CGFloat = 320

// Globe base - light blue (ocean)
context.setFillColor(CGColor(red: 0.35, green: 0.65, blue: 0.95, alpha: 0.9))
context.addArc(center: globeCenter, radius: globeRadius, startAngle: 0, endAngle: .pi * 2, clockwise: false)
context.fillPath()

// Globe inner glow
let innerGlow = CGGradient(
    colorsSpace: colorSpace,
    colors: [
        CGColor(red: 0.45, green: 0.75, blue: 1.0, alpha: 0.6),
        CGColor(red: 0.25, green: 0.55, blue: 0.85, alpha: 0.0)
    ] as CFArray,
    locations: [0.0, 1.0]
)!
context.saveGState()
context.addArc(center: globeCenter, radius: globeRadius, startAngle: 0, endAngle: .pi * 2, clockwise: false)
context.clip()
context.drawRadialGradient(innerGlow,
    startCenter: CGPoint(x: globeCenter.x - 80, y: globeCenter.y + 80),
    startRadius: 0,
    endCenter: globeCenter,
    endRadius: globeRadius,
    options: [])
context.restoreGState()

// === CONTINENT SHAPES (simplified abstract land masses) ===
context.saveGState()
context.addArc(center: globeCenter, radius: globeRadius - 2, startAngle: 0, endAngle: .pi * 2, clockwise: false)
context.clip()

let landColor = CGColor(red: 0.30, green: 0.75, blue: 0.45, alpha: 0.85)
context.setFillColor(landColor)

// North America (abstract)
let na = CGMutablePath()
na.move(to: CGPoint(x: globeCenter.x - 180, y: globeCenter.y + 200))
na.addCurve(to: CGPoint(x: globeCenter.x - 120, y: globeCenter.y + 280),
            control1: CGPoint(x: globeCenter.x - 200, y: globeCenter.y + 240),
            control2: CGPoint(x: globeCenter.x - 160, y: globeCenter.y + 280))
na.addCurve(to: CGPoint(x: globeCenter.x - 40, y: globeCenter.y + 200),
            control1: CGPoint(x: globeCenter.x - 80, y: globeCenter.y + 280),
            control2: CGPoint(x: globeCenter.x - 40, y: globeCenter.y + 240))
na.addCurve(to: CGPoint(x: globeCenter.x - 60, y: globeCenter.y + 100),
            control1: CGPoint(x: globeCenter.x - 30, y: globeCenter.y + 160),
            control2: CGPoint(x: globeCenter.x - 40, y: globeCenter.y + 120))
na.addCurve(to: CGPoint(x: globeCenter.x - 180, y: globeCenter.y + 200),
            control1: CGPoint(x: globeCenter.x - 100, y: globeCenter.y + 80),
            control2: CGPoint(x: globeCenter.x - 170, y: globeCenter.y + 140))
na.closeSubpath()
context.addPath(na)
context.fillPath()

// South America (abstract)
let sa = CGMutablePath()
sa.move(to: CGPoint(x: globeCenter.x - 80, y: globeCenter.y + 80))
sa.addCurve(to: CGPoint(x: globeCenter.x - 40, y: globeCenter.y - 120),
            control1: CGPoint(x: globeCenter.x - 100, y: globeCenter.y - 20),
            control2: CGPoint(x: globeCenter.x - 60, y: globeCenter.y - 80))
sa.addCurve(to: CGPoint(x: globeCenter.x - 60, y: globeCenter.y + 40),
            control1: CGPoint(x: globeCenter.x - 20, y: globeCenter.y - 60),
            control2: CGPoint(x: globeCenter.x - 30, y: globeCenter.y + 10))
sa.closeSubpath()
context.addPath(sa)
context.fillPath()

// Europe/Africa (abstract)
let ea = CGMutablePath()
ea.move(to: CGPoint(x: globeCenter.x + 60, y: globeCenter.y + 240))
ea.addCurve(to: CGPoint(x: globeCenter.x + 120, y: globeCenter.y + 160),
            control1: CGPoint(x: globeCenter.x + 80, y: globeCenter.y + 220),
            control2: CGPoint(x: globeCenter.x + 110, y: globeCenter.y + 190))
ea.addCurve(to: CGPoint(x: globeCenter.x + 100, y: globeCenter.y - 80),
            control1: CGPoint(x: globeCenter.x + 130, y: globeCenter.y + 80),
            control2: CGPoint(x: globeCenter.x + 120, y: globeCenter.y - 10))
ea.addCurve(to: CGPoint(x: globeCenter.x + 60, y: globeCenter.y - 160),
            control1: CGPoint(x: globeCenter.x + 80, y: globeCenter.y - 120),
            control2: CGPoint(x: globeCenter.x + 70, y: globeCenter.y - 150))
ea.addCurve(to: CGPoint(x: globeCenter.x + 40, y: globeCenter.y + 100),
            control1: CGPoint(x: globeCenter.x + 40, y: globeCenter.y - 40),
            control2: CGPoint(x: globeCenter.x + 30, y: globeCenter.y + 40))
ea.addCurve(to: CGPoint(x: globeCenter.x + 60, y: globeCenter.y + 240),
            control1: CGPoint(x: globeCenter.x + 50, y: globeCenter.y + 160),
            control2: CGPoint(x: globeCenter.x + 50, y: globeCenter.y + 200))
ea.closeSubpath()
context.addPath(ea)
context.fillPath()

// Asia (abstract)
let asia = CGMutablePath()
asia.move(to: CGPoint(x: globeCenter.x + 140, y: globeCenter.y + 260))
asia.addCurve(to: CGPoint(x: globeCenter.x + 260, y: globeCenter.y + 160),
            control1: CGPoint(x: globeCenter.x + 180, y: globeCenter.y + 260),
            control2: CGPoint(x: globeCenter.x + 240, y: globeCenter.y + 220))
asia.addCurve(to: CGPoint(x: globeCenter.x + 200, y: globeCenter.y + 60),
            control1: CGPoint(x: globeCenter.x + 280, y: globeCenter.y + 120),
            control2: CGPoint(x: globeCenter.x + 250, y: globeCenter.y + 80))
asia.addCurve(to: CGPoint(x: globeCenter.x + 140, y: globeCenter.y + 120),
            control1: CGPoint(x: globeCenter.x + 170, y: globeCenter.y + 50),
            control2: CGPoint(x: globeCenter.x + 150, y: globeCenter.y + 80))
asia.addCurve(to: CGPoint(x: globeCenter.x + 140, y: globeCenter.y + 260),
            control1: CGPoint(x: globeCenter.x + 130, y: globeCenter.y + 160),
            control2: CGPoint(x: globeCenter.x + 130, y: globeCenter.y + 220))
asia.closeSubpath()
context.addPath(asia)
context.fillPath()

context.restoreGState()

// === GLOBE BORDER ===
context.setStrokeColor(CGColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.3))
context.setLineWidth(4)
context.addArc(center: globeCenter, radius: globeRadius, startAngle: 0, endAngle: .pi * 2, clockwise: false)
context.strokePath()

// === LATITUDE/LONGITUDE LINES ===
context.saveGState()
context.addArc(center: globeCenter, radius: globeRadius - 2, startAngle: 0, endAngle: .pi * 2, clockwise: false)
context.clip()
context.setStrokeColor(CGColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.12))
context.setLineWidth(2)

// Latitude lines
for i in stride(from: -2, through: 2, by: 1) {
    let y = globeCenter.y + CGFloat(i) * 100
    context.move(to: CGPoint(x: globeCenter.x - globeRadius, y: y))
    context.addLine(to: CGPoint(x: globeCenter.x + globeRadius, y: y))
}
context.strokePath()

// Longitude curves (simplified as arcs)
for i in stride(from: -1, through: 1, by: 1) {
    let offset = CGFloat(i) * 120
    let ellipseRect = CGRect(x: globeCenter.x + offset - 40, y: globeCenter.y - globeRadius, width: 80, height: globeRadius * 2)
    context.addEllipse(in: ellipseRect)
}
context.strokePath()
context.restoreGState()

// === SMALL FLAG-COLORED PINS around the globe ===
struct FlagPin {
    let angle: CGFloat // radians from center
    let distance: CGFloat // from globe center
    let color1: CGColor
    let color2: CGColor
    let color3: CGColor?
}

let pins: [FlagPin] = [
    // Red, white, blue (USA/France)
    FlagPin(angle: -0.8, distance: 280,
            color1: CGColor(red: 0.9, green: 0.2, blue: 0.2, alpha: 1),
            color2: CGColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1),
            color3: CGColor(red: 0.2, green: 0.3, blue: 0.8, alpha: 1)),
    // Green, white, red (Italy/Mexico)
    FlagPin(angle: 0.4, distance: 300,
            color1: CGColor(red: 0.1, green: 0.7, blue: 0.3, alpha: 1),
            color2: CGColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1),
            color3: CGColor(red: 0.9, green: 0.2, blue: 0.2, alpha: 1)),
    // Yellow, blue (Ukraine/Sweden)
    FlagPin(angle: 1.6, distance: 290,
            color1: CGColor(red: 1.0, green: 0.85, blue: 0.0, alpha: 1),
            color2: CGColor(red: 0.2, green: 0.4, blue: 0.9, alpha: 1),
            color3: nil),
    // Orange, white, green (India/Ireland)
    FlagPin(angle: 2.6, distance: 310,
            color1: CGColor(red: 1.0, green: 0.6, blue: 0.1, alpha: 1),
            color2: CGColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1),
            color3: CGColor(red: 0.1, green: 0.7, blue: 0.3, alpha: 1)),
    // Red, yellow (Spain/China)
    FlagPin(angle: -2.0, distance: 295,
            color1: CGColor(red: 0.9, green: 0.15, blue: 0.15, alpha: 1),
            color2: CGColor(red: 1.0, green: 0.85, blue: 0.0, alpha: 1),
            color3: nil),
    // Black, red, gold (Germany)
    FlagPin(angle: 3.8, distance: 285,
            color1: CGColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1),
            color2: CGColor(red: 0.9, green: 0.2, blue: 0.15, alpha: 1),
            color3: CGColor(red: 1.0, green: 0.8, blue: 0.0, alpha: 1)),
]

for pin in pins {
    let px = globeCenter.x + cos(pin.angle) * pin.distance
    let py = globeCenter.y + sin(pin.angle) * pin.distance
    let flagW: CGFloat = 64
    let flagH: CGFloat = 42

    // Small flag rectangle
    let flagRect = CGRect(x: px - flagW/2, y: py - flagH/2, width: flagW, height: flagH)

    // White border
    let borderRect = flagRect.insetBy(dx: -3, dy: -3)
    context.setFillColor(CGColor(red: 1, green: 1, blue: 1, alpha: 0.9))
    let borderPath = CGPath(roundedRect: borderRect, cornerWidth: 6, cornerHeight: 6, transform: nil)
    context.addPath(borderPath)
    context.fillPath()

    // Flag stripes
    context.saveGState()
    let clipPath = CGPath(roundedRect: flagRect, cornerWidth: 4, cornerHeight: 4, transform: nil)
    context.addPath(clipPath)
    context.clip()

    if let c3 = pin.color3 {
        // Three stripes
        let stripeW = flagW / 3
        context.setFillColor(pin.color1)
        context.fill(CGRect(x: flagRect.minX, y: flagRect.minY, width: stripeW, height: flagH))
        context.setFillColor(pin.color2)
        context.fill(CGRect(x: flagRect.minX + stripeW, y: flagRect.minY, width: stripeW, height: flagH))
        context.setFillColor(c3)
        context.fill(CGRect(x: flagRect.minX + stripeW * 2, y: flagRect.minY, width: stripeW, height: flagH))
    } else {
        // Two stripes
        let stripeH = flagH / 2
        context.setFillColor(pin.color1)
        context.fill(CGRect(x: flagRect.minX, y: flagRect.minY, width: flagW, height: stripeH))
        context.setFillColor(pin.color2)
        context.fill(CGRect(x: flagRect.minX, y: flagRect.minY + stripeH, width: flagW, height: stripeH))
    }
    context.restoreGState()

    // Drop shadow for pin
    context.saveGState()
    context.setShadow(offset: CGSize(width: 2, height: -2), blur: 6, color: CGColor(red: 0, green: 0, blue: 0, alpha: 0.3))
    context.restoreGState()
}

// === HIGHLIGHT / SHINE on globe ===
context.saveGState()
context.addArc(center: globeCenter, radius: globeRadius, startAngle: 0, endAngle: .pi * 2, clockwise: false)
context.clip()
let shineGradient = CGGradient(
    colorsSpace: colorSpace,
    colors: [
        CGColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.25),
        CGColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.0)
    ] as CFArray,
    locations: [0.0, 1.0]
)!
context.drawRadialGradient(shineGradient,
    startCenter: CGPoint(x: globeCenter.x - 120, y: globeCenter.y + 140),
    startRadius: 0,
    endCenter: CGPoint(x: globeCenter.x - 60, y: globeCenter.y + 80),
    endRadius: 250,
    options: [])
context.restoreGState()

// === TEXT at bottom: "FLAG" ===
let textAttrs: [NSAttributedString.Key: Any] = [
    .font: NSFont.systemFont(ofSize: 120, weight: .heavy),
    .foregroundColor: NSColor.white,
    .kern: 12
]
let text = "FLAG" as NSString
let textSize = text.size(withAttributes: textAttrs)
let textX = (size - textSize.width) / 2
let textY: CGFloat = 80

// Text shadow
context.saveGState()
context.setShadow(offset: CGSize(width: 0, height: -3), blur: 10, color: CGColor(red: 0, green: 0, blue: 0, alpha: 0.4))
text.draw(at: NSPoint(x: textX, y: textY), withAttributes: textAttrs)
context.restoreGState()

// === Subtle star sparkles ===
context.setFillColor(CGColor(red: 1, green: 1, blue: 1, alpha: 0.7))
let starPositions: [(CGFloat, CGFloat, CGFloat)] = [
    (160, 860, 8), (850, 820, 6), (120, 400, 5),
    (900, 500, 7), (780, 180, 5), (250, 180, 6)
]
for (sx, sy, sr) in starPositions {
    // Simple 4-point star
    let star = CGMutablePath()
    star.move(to: CGPoint(x: sx, y: sy - sr))
    star.addLine(to: CGPoint(x: sx + sr * 0.3, y: sy - sr * 0.3))
    star.addLine(to: CGPoint(x: sx + sr, y: sy))
    star.addLine(to: CGPoint(x: sx + sr * 0.3, y: sy + sr * 0.3))
    star.addLine(to: CGPoint(x: sx, y: sy + sr))
    star.addLine(to: CGPoint(x: sx - sr * 0.3, y: sy + sr * 0.3))
    star.addLine(to: CGPoint(x: sx - sr, y: sy))
    star.addLine(to: CGPoint(x: sx - sr * 0.3, y: sy - sr * 0.3))
    star.closeSubpath()
    context.addPath(star)
    context.fillPath()
}

image.unlockFocus()

// Save as PNG
guard let tiffData = image.tiffRepresentation,
      let bitmapRep = NSBitmapImageRep(data: tiffData),
      let pngData = bitmapRep.representation(using: .png, properties: [:]) else {
    fatalError("Could not create PNG data")
}

let outputPath = "/Users/dancao/Documents/flag_game/FlagGame/FlagGame/Assets.xcassets/AppIcon.appiconset/AppIcon.png"
try! pngData.write(to: URL(fileURLWithPath: outputPath))
print("Icon saved to \(outputPath)")
