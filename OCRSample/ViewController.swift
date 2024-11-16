//
//  ViewController.swift
//  OCRSample
//
//  Created by 김호성 on 2024.11.15.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var lbMain: UILabel!
    @IBOutlet weak var drawingView: DrawingView!
    
    @IBOutlet weak var ivTset: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        drawingView.delegate = self
    }
    @IBAction func onClickBack(_ sender: Any) {
        drawingView.undo()
    }
    @IBAction func onClickClear(_ sender: Any) {
        drawingView.clear()
    }
}

extension ViewController: DrawingViewDelegate {
    func didExtractText(text: String?) {
        let text: String = text ?? "인식 결과가 없습니다."
        lbMain.text = text
    }
    func setImage(image: UIImage?) {
        ivTset.image = image
    }
}
