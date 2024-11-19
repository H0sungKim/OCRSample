//
//  DrawingView.swift
//  OCRSample
//
//  Created by 김호성 on 2024.11.15.
//

import UIKit
import Combine

class DrawingView: UIView {
    public var strokeWidth: Float = 10
    public var strokeColor: UIColor = .label
    private var lines: [Line] = []
    private var cancellable: Set<AnyCancellable> = Set<AnyCancellable>()
    private let hiraganaKatakanaSample: UIImage = UIImage(resource: .hksamplew)
    
    weak var delegate: DrawingViewDelegate?
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        lines.append(Line.init(strokeWidth: strokeWidth, color: strokeColor, points: []))
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let point = touches.first?.location(in: self) else { return }
        guard var lastLine = lines.popLast() else { return }
        lastLine.points.append(point)
        lines.append(lastLine)
        setNeedsDisplay()
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        requestExtractText()
    }
    
    private func requestExtractText() {
        // UIGraphicsImageRenderer가 main에서 실행돼서 좀 끊김
        createDrawingImageAsync()
            .flatMap({ [weak self] image in
                DispatchQueue.main.async {
                    self?.delegate?.setImage(image: image)
                }
                return OCRManager.shared.extractText(from: image ?? UIImage())
            })
            .subscribe(on: DispatchQueue.global())
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] value in
                self?.delegate?.didExtractText(text: value)
            })
            .store(in: &cancellable)
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        lines.forEach { (line) in
            context.setStrokeColor(line.color.cgColor)
            context.setLineWidth(CGFloat(line.strokeWidth))
            for (index, point) in line.points.enumerated() {
                if index == 0 {
                    context.move(to: point)
                } else {
                    context.addLine(to: point)
                }
            }
            context.strokePath()
        }
    }
    
    func undo() {
        _ = lines.popLast()
        setNeedsDisplay()
        requestExtractText()
    }
    func clear() {
        lines.removeAll()
        setNeedsDisplay()
        self.delegate?.didExtractText(text: nil)
    }
    
    private func toProcessedImage() -> UIImage? {
        let width = max(self.bounds.size.width, hiraganaKatakanaSample.size.width)
        let height = self.bounds.size.height + hiraganaKatakanaSample.size.height
        let size = CGSize(width: width, height: height)
        
        let renderer = UIGraphicsImageRenderer(size: size)
        
        return renderer.image { context in
            layer.render(in: context.cgContext)
            hiraganaKatakanaSample.draw(in: CGRect(x: 0, y: self.bounds.size.height, width: hiraganaKatakanaSample.size.width, height: hiraganaKatakanaSample.size.height))
        }
    }
    
    func toImage() -> UIImage? {
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image { context in
            layer.render(in: context.cgContext)
        }
    }
    
    private func createDrawingImageAsync() -> Future<UIImage?, Never> {
        return Future { [weak self] promise in
            guard let self = self else { return promise(.success(nil)) }
            return promise(.success(self.toProcessedImage()))
        }
    }
}

protocol DrawingViewDelegate: AnyObject {
    func didExtractText(text: String?)
    func setImage(image: UIImage?)
}
