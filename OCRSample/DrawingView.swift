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
        createDrawingImageAsync()
            .flatMap({ [weak self] image in
                return OCRManager.shared.extractText(from: image ?? UIImage())
            })
            .subscribe(on: DispatchQueue.global())
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] value in
                self?.delegate?.didExtractText(text: value)
                print(value)
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
    
    func undo(){
        _ = lines.popLast()
        setNeedsDisplay()
    }
    func clear(){
        lines.removeAll()
        setNeedsDisplay()
    }
    private func toImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: self.bounds.size.width, height: self.bounds.size.height))
        return renderer.image { context in
            self.drawHierarchy(in: self.bounds, afterScreenUpdates: true)
        }
    }
    func mergeImagesVertically(image1: UIImage, image2: UIImage) -> UIImage? {
        let width = max(image1.size.width, image2.size.width)
        let height = image1.size.height + image2.size.height
        let size = CGSize(width: width, height: height)
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        image1.draw(in: CGRect(x: 0, y: 0, width: image1.size.width, height: image1.size.height))
        image2.draw(in: CGRect(x: 0, y: image1.size.height, width: image2.size.width, height: image2.size.height))
        let mergedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return mergedImage
    }
    
    private func createDrawingImageAsync() -> Future<UIImage?, Never> {
        return Future { [weak self] promise in
            guard let self = self else { return promise(.success(nil)) }
            let image = self.toImage()
            let mergedImage = self.mergeImagesVertically(image1: image, image2: UIImage(named: "hgtablew.png")!)
            promise(.success(mergedImage))
        }
    }
}

protocol DrawingViewDelegate: AnyObject {
    func didExtractText(text: String?)
    func setImage(image: UIImage?)
}
