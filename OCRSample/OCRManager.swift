//
//  OCRManager.swift
//  OCRSample
//
//  Created by 김호성 on 2024.11.15.
//

import Foundation
import VisionKit
import Vision

class OCRManager {
    
    public static let shared = OCRManager()
    
    private init() {
        
    }
    
    func extractText(from image: UIImage, completion: @escaping (String?) -> Void) {
        guard let cgImage: CGImage = image.cgImage else { return completion(nil) }
        let requestHandler = VNImageRequestHandler(cgImage: cgImage)
        let request = VNRecognizeTextRequest { request, error in
            
            guard let observations = request.results as? [VNRecognizedTextObservation] else { return completion(nil) }
            let recognizedStrings = observations.compactMap { observation in
                // Return the string of the top VNRecognizedText instance.
                return observation.topCandidates(1).first?.string
            }
            completion(recognizedStrings.first)
        }
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = false
        request.recognitionLanguages = ["ja-JP"]
        request.customWords = [
            "あ", "い", "う", "え", "お",
            "か", "き", "く", "け", "こ",
            "さ", "し", "す", "せ", "そ",
            "た", "ち", "つ", "て", "と",
            "な", "に", "ぬ", "ね", "の",
            "は", "ひ", "ふ", "へ", "ほ",
            "ま", "み", "む", "め", "も",
            "や",      "ゆ",       "よ",
            "ら", "り", "る", "れ", "ろ",
            "わ",                 "を",
            "ん",
            
            "ア", "イ", "ウ", "エ", "オ",
            "カ", "キ", "ク", "ケ", "コ",
            "サ", "シ", "ス", "セ", "ソ",
            "タ", "チ", "ツ", "テ", "ト",
            "ナ", "ニ", "ヌ", "ネ", "ノ",
            "ハ", "ヒ", "フ", "ヘ", "ホ",
            "マ", "ミ", "ム", "メ", "モ",
            "ヤ",      "ユ",       "ヨ",
            "ラ", "リ", "ル", "レ", "ロ",
            "ワ",                 "ヲ",
            "ン",
        ]
        
        do {
            try requestHandler.perform([request])
        } catch {
            print("OCR Error: \(error)")
        }
    }
}
