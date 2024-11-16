//
//  DrawingView.swift
//  OCRSample
//
//  Created by 김호성 on 2024.11.15.
//

import UIKit

class DrawingView: UIView {
    public var strokeWidth: Float = 10
    public var strokeColor: UIColor = .label
    private var lines: [Line] = []
    weak var delegate: DrawingViewDelegate?
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        lines.append(Line.init(strokeWidth: strokeWidth, color: strokeColor, points: []))
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("moved")
        guard let point = touches.first?.location(in: self) else { return }
        guard var lastLine = lines.popLast() else { return }
        lastLine.points.append(point)
        lines.append(lastLine)
        setNeedsDisplay()
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let image = self.toImage()
        let mergedImage = mergeImagesVertically(image1: image, image2: UIImage(named: "hgtable.png")!)
        delegate?.setImage(image: mergedImage!)
        OCRManager.shared.extractText(from: mergedImage!, completion: { [weak self] result in
            self?.delegate?.didExtractText(text: result)
            print(result)
        })
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
        // 두 이미지의 너비 중 더 넓은 값을 사용
        let width = max(image1.size.width, image2.size.width)
        // 두 이미지의 높이를 합산
        let height = image1.size.height + image2.size.height

        // 새로운 캔버스 크기 설정
        let size = CGSize(width: width, height: height)

        // 새로운 이미지를 생성하기 위해 그래픽 컨텍스트 시작
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)

        // image1을 상단에 그리기
        image1.draw(in: CGRect(x: 0, y: 0, width: image1.size.width, height: image1.size.height))
        // image2를 하단에 그리기
        image2.draw(in: CGRect(x: 0, y: image1.size.height, width: image2.size.width, height: image2.size.height))

        // 결합된 이미지 가져오기
        let mergedImage = UIGraphicsGetImageFromCurrentImageContext()

        // 그래픽 컨텍스트 종료
        UIGraphicsEndImageContext()

        return mergedImage
    }
}

protocol DrawingViewDelegate: AnyObject {
    func didExtractText(text: String?)
    func setImage(image: UIImage)
}
