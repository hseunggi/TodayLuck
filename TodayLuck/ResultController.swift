//
//  ResultController.swift
//  TodayLuck
//
//  Created by hong on 2025/06/06.
//
import UIKit

enum SourceController {
    case home
    case list
}

class ResultController: UIViewController {

    var source: SourceController?
    var userInput: String?
    @IBOutlet weak var inputLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var fortuneLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let input = userInput {
                    inputLabel.text = "입력: \(input)"
                    // 예시로 간단한 이미지 조건 분기
                    if input.contains("기쁨") {
                        imageView.image = UIImage(named: "happy")
                    } else {
                        imageView.image = UIImage(named: "default")
                    }

                    // 이후 OpenAI API로 운세 받아오고 label, firestore 저장 등 추가 가능
                }
        
        // Do any additional setup after loading the view.
    }


}
 
