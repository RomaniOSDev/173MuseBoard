#!/usr/bin/swift
import AppKit
import Foundation

let assetsRoot = CommandLine.arguments.count > 1
    ? CommandLine.arguments[1]
    : FileManager.default.currentDirectoryPath

let width = 600
let height = 800

let palettes: [(NSColor, NSColor, NSColor)] = [
    (NSColor(red: 0.95, green: 0.75, blue: 0.82, alpha: 1), NSColor(red: 0.55, green: 0.72, blue: 0.90, alpha: 1), NSColor(red: 0.98, green: 0.94, blue: 0.96, alpha: 1)),
    (NSColor(red: 0.88, green: 0.70, blue: 0.78, alpha: 1), NSColor(red: 0.40, green: 0.55, blue: 0.75, alpha: 1), NSColor(red: 0.96, green: 0.90, blue: 0.93, alpha: 1)),
    (NSColor(red: 0.92, green: 0.80, blue: 0.70, alpha: 1), NSColor(red: 0.65, green: 0.45, blue: 0.55, alpha: 1), NSColor(red: 0.98, green: 0.95, blue: 0.90, alpha: 1)),
    (NSColor(red: 0.75, green: 0.85, blue: 0.90, alpha: 1), NSColor(red: 0.35, green: 0.50, blue: 0.68, alpha: 1), NSColor(red: 0.92, green: 0.96, blue: 0.98, alpha: 1)),
    (NSColor(red: 0.90, green: 0.65, blue: 0.72, alpha: 1), NSColor(red: 0.50, green: 0.35, blue: 0.55, alpha: 1), NSColor(red: 0.97, green: 0.88, blue: 0.91, alpha: 1)),
    (NSColor(red: 0.82, green: 0.88, blue: 0.78, alpha: 1), NSColor(red: 0.45, green: 0.62, blue: 0.58, alpha: 1), NSColor(red: 0.94, green: 0.97, blue: 0.93, alpha: 1)),
    (NSColor(red: 0.95, green: 0.82, blue: 0.65, alpha: 1), NSColor(red: 0.70, green: 0.50, blue: 0.40, alpha: 1), NSColor(red: 0.99, green: 0.94, blue: 0.88, alpha: 1)),
    (NSColor(red: 0.78, green: 0.72, blue: 0.92, alpha: 1), NSColor(red: 0.42, green: 0.38, blue: 0.70, alpha: 1), NSColor(red: 0.93, green: 0.91, blue: 0.98, alpha: 1)),
    (NSColor(red: 0.90, green: 0.78, blue: 0.88, alpha: 1), NSColor(red: 0.55, green: 0.48, blue: 0.72, alpha: 1), NSColor(red: 0.97, green: 0.93, blue: 0.96, alpha: 1)),
    (NSColor(red: 0.72, green: 0.82, blue: 0.95, alpha: 1), NSColor(red: 0.30, green: 0.45, blue: 0.72, alpha: 1), NSColor(red: 0.91, green: 0.95, blue: 0.99, alpha: 1)),
    (NSColor(red: 0.94, green: 0.68, blue: 0.75, alpha: 1), NSColor(red: 0.60, green: 0.40, blue: 0.50, alpha: 1), NSColor(red: 0.98, green: 0.90, blue: 0.92, alpha: 1)),
    (NSColor(red: 0.85, green: 0.90, blue: 0.82, alpha: 1), NSColor(red: 0.48, green: 0.58, blue: 0.52, alpha: 1), NSColor(red: 0.95, green: 0.97, blue: 0.94, alpha: 1)),
    (NSColor(red: 0.88, green: 0.75, blue: 0.90, alpha: 1), NSColor(red: 0.52, green: 0.42, blue: 0.68, alpha: 1), NSColor(red: 0.96, green: 0.92, blue: 0.97, alpha: 1)),
    (NSColor(red: 0.80, green: 0.70, blue: 0.85, alpha: 1), NSColor(red: 0.38, green: 0.32, blue: 0.62, alpha: 1), NSColor(red: 0.94, green: 0.90, blue: 0.96, alpha: 1)),
    (NSColor(red: 0.92, green: 0.85, blue: 0.78, alpha: 1), NSColor(red: 0.58, green: 0.48, blue: 0.42, alpha: 1), NSColor(red: 0.98, green: 0.95, blue: 0.92, alpha: 1)),
    (NSColor(red: 0.76, green: 0.88, blue: 0.92, alpha: 1), NSColor(red: 0.35, green: 0.55, blue: 0.65, alpha: 1), NSColor(red: 0.92, green: 0.96, blue: 0.98, alpha: 1)),
    (NSColor(red: 0.93, green: 0.72, blue: 0.80, alpha: 1), NSColor(red: 0.48, green: 0.38, blue: 0.58, alpha: 1), NSColor(red: 0.97, green: 0.91, blue: 0.94, alpha: 1)),
    (NSColor(red: 0.84, green: 0.78, blue: 0.94, alpha: 1), NSColor(red: 0.45, green: 0.40, blue: 0.75, alpha: 1), NSColor(red: 0.95, green: 0.93, blue: 0.98, alpha: 1)),
    (NSColor(red: 0.90, green: 0.80, blue: 0.72, alpha: 1), NSColor(red: 0.55, green: 0.42, blue: 0.48, alpha: 1), NSColor(red: 0.97, green: 0.93, blue: 0.90, alpha: 1)),
    (NSColor(red: 0.74, green: 0.80, blue: 0.96, alpha: 1), NSColor(red: 0.32, green: 0.42, blue: 0.78, alpha: 1), NSColor(red: 0.91, green: 0.94, blue: 0.99, alpha: 1))
]

func drawPortrait(index: Int, colors: (NSColor, NSColor, NSColor)) -> NSImage {
    let image = NSImage(size: NSSize(width: width, height: height))
    image.lockFocus()

    let top = colors.0
    let bottom = colors.1
    let accent = colors.2

    let gradient = NSGradient(starting: top, ending: bottom)!
    gradient.draw(in: NSRect(x: 0, y: 0, width: CGFloat(width), height: CGFloat(height)), angle: 90)

    let centerX = CGFloat(width) * 0.5
    let headY = CGFloat(height) * 0.68
    let headRadius = CGFloat(width) * 0.14

    accent.setFill()
    NSBezierPath(ovalIn: NSRect(
        x: centerX - headRadius,
        y: headY - headRadius,
        width: headRadius * 2,
        height: headRadius * 2
    )).fill()

    let bodyWidth = CGFloat(width) * 0.42
    let bodyHeight = CGFloat(height) * 0.38
    let bodyRect = NSRect(
        x: centerX - bodyWidth / 2,
        y: CGFloat(height) * 0.22,
        width: bodyWidth,
        height: bodyHeight
    )
    let bodyPath = NSBezierPath(roundedRect: bodyRect, xRadius: bodyWidth * 0.35, yRadius: bodyWidth * 0.2)
    bottom.withAlphaComponent(0.85).setFill()
    bodyPath.fill()

    let overlay = NSColor.white.withAlphaComponent(0.12)
    overlay.setFill()
    NSBezierPath(rect: NSRect(x: 0, y: 0, width: CGFloat(width), height: CGFloat(height) * 0.18)).fill()

    let label = "Look \(index)"
    let attrs: [NSAttributedString.Key: Any] = [
        .font: NSFont.systemFont(ofSize: 22, weight: .semibold),
        .foregroundColor: NSColor.white.withAlphaComponent(0.9)
    ]
    let size = label.size(withAttributes: attrs)
    label.draw(
        at: NSPoint(x: 20, y: CGFloat(height) - size.height - 24),
        withAttributes: attrs
    )

    image.unlockFocus()
    return image
}

func writePNG(_ image: NSImage, to url: URL) throws {
    guard let tiff = image.tiffRepresentation,
          let rep = NSBitmapImageRep(data: tiff),
          let data = rep.representation(using: .png, properties: [:]) else {
        throw NSError(domain: "GenerateGirlAssets", code: 1)
    }
    try data.write(to: url)
}

for i in 1...20 {
    let folder = URL(fileURLWithPath: assetsRoot).appendingPathComponent("girl\(i).imageset")
    try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)

    let palette = palettes[(i - 1) % palettes.count]
    let portrait = drawPortrait(index: i, colors: palette)
    let pngURL = folder.appendingPathComponent("girl\(i).png")
    try writePNG(portrait, to: pngURL)

    let contents: [String: Any] = [
        "images": [
            ["filename": "girl\(i).png", "idiom": "universal", "scale": "1x"],
            ["idiom": "universal", "scale": "2x"],
            ["idiom": "universal", "scale": "3x"]
        ],
        "info": ["author": "xcode", "version": 1]
    ]
    let jsonData = try JSONSerialization.data(withJSONObject: contents, options: [.prettyPrinted, .sortedKeys])
    try jsonData.write(to: folder.appendingPathComponent("Contents.json"))
    print("Created girl\(i).png")
}

print("Done.")
