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
    var fortuneData: HomeController.FortuneData?
    
    @IBOutlet weak var inputLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var fortuneLabel: UILabel!
    
    

        
        override func viewDidLoad() {
            super.viewDidLoad()
            inputLabel.text = "입력: \(userInput ?? "")"
            guard let data = fortuneData else { return }
            
            fortuneLabel.text = data.message
            
            if data.type == "special" && data.value == "fortune" {
                    imageView.image = UIImage(named: "fortune")  // fortune.png
                } else {
                    let imageName = "\(data.type)_\(data.value)" // 예: mood_행복, situation_직장
                    if let image = UIImage(named: imageName) {
                        imageView.image = image
                    } else {
                        imageView.image = UIImage(named: "default") // 없을 경우 대체 이미지
                    }
                }
        }



}
 
