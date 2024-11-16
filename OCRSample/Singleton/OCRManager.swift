//
//  OCRManager.swift
//  OCRSample
//
//  Created by 김호성 on 2024.11.15.
//

import Foundation
import VisionKit
import Vision
import Combine

class OCRManager {
    
    public static let shared = OCRManager()
    
    private init() {
        
    }
    
    func extractText(from image: UIImage) -> Future<String?, Never> {
        return Future { promise in
            guard let cgImage: CGImage = image.cgImage else { return promise(.success(nil)) }
            let requestHandler = VNImageRequestHandler(cgImage: cgImage)
            let request = VNRecognizeTextRequest { request, error in
                guard let observations = request.results as? [VNRecognizedTextObservation] else { return promise(.success(nil)) }
                var recognizedStrings = observations.compactMap { observation -> String? in
                    guard let observationString = observation.topCandidates(1).first?.string else { return nil }
                    if HiraganaKatakanaManager.shared.hiraganaKatakana.contains(observationString) {
                        return observationString
                    }
                    return nil
                }
                promise(.success(recognizedStrings.first))
            }
            request.recognitionLevel = .accurate
            request.usesLanguageCorrection = false
            request.recognitionLanguages = ["ja-JP"]
            request.customWords = HiraganaKatakanaManager.shared.hiraganaKatakana
            
            do {
                try requestHandler.perform([request])
            } catch {
                print("OCR Error: \(error)")
            }
        }
    }
    
}
