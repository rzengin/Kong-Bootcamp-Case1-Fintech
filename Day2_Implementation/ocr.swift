import Cocoa
import Vision

let args = CommandLine.arguments
guard args.count > 1 else { exit(1) }
let path = args[1]
let url = URL(fileURLWithPath: path)
guard let img = NSImage(contentsOf: url),
      let cgImage = img.cgImage(forProposedRect: nil, context: nil, hints: nil) else { exit(1) }

let request = VNRecognizeTextRequest { (request, error) in
    guard let observations = request.results as? [VNRecognizedTextObservation] else { return }
    for obs in observations {
        if let topCandidate = obs.topCandidates(1).first {
            print(topCandidate.string)
        }
    }
}
request.recognitionLevel = .accurate
let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
try? handler.perform([request])
