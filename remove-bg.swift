import Vision
import AppKit
import CoreImage

let args = CommandLine.arguments
guard args.count >= 3 else {
    fputs("Usage: remove-bg <input> <output>\n", stderr)
    exit(1)
}

let inputPath = args[1]
let outputPath = args[2]

guard let nsImage = NSImage(contentsOfFile: inputPath),
      let cgImage = nsImage.cgImage(forProposedRect: nil, context: nil, hints: nil)
else {
    fputs("Error: cannot load \(inputPath)\n", stderr)
    exit(1)
}

let request = VNGenerateForegroundInstanceMaskRequest()
let handler = VNImageRequestHandler(cgImage: cgImage)

do {
    try handler.perform([request])

    guard let result = request.results?.first else {
        fputs("Error: no foreground mask\n", stderr)
        exit(1)
    }

    let maskPixelBuffer = try result.generateScaledMaskForImage(forInstances: result.allInstances, from: handler)

    // Convert to CGImage via CIImage + CIContext
    let ciMask = CIImage(cvPixelBuffer: maskPixelBuffer)
    let ciInput = CIImage(cgImage: cgImage)
    let context = CIContext()

    // Create transparent background
    let clear = CIImage(color: CIColor(red: 0, green: 0, blue: 0, alpha: 0)).cropped(to: ciInput.extent)

    guard let blend = CIFilter(name: "CIBlendWithMask", parameters: [
        kCIInputImageKey: ciInput,
        kCIInputMaskImageKey: ciMask,
        kCIInputBackgroundImageKey: clear,
    ])?.outputImage else {
        fputs("Error: blend filter failed\n", stderr)
        exit(1)
    }

    guard let outCG = context.createCGImage(blend, from: blend.extent) else {
        fputs("Error: cannot create output CGImage\n", stderr)
        exit(1)
    }

    let rep = NSBitmapImageRep(cgImage: outCG)
    guard let png = rep.representation(using: NSBitmapImageRep.FileType.png, properties: [:]) else {
        fputs("Error: cannot encode PNG\n", stderr)
        exit(1)
    }

    try png.write(to: URL(fileURLWithPath: outputPath))
    print(outputPath)

} catch {
    fputs("Error: \(error.localizedDescription)\n", stderr)
    exit(1)
}
