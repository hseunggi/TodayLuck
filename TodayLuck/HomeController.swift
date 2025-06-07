
import UIKit
import FirebaseFirestore

class HomeController: UIViewController {

    @IBOutlet weak var textField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        let db = Firestore.firestore()
//                db.collection("test").addDocument(data: [
//                    "name": "홍길동",
//                    "created": Timestamp(date: Date())
//                ]) { err in
//                    if let err = err {
//                        print("❌ 에러 발생: \(err)")
//                    } else {
//                        print("✅ Firestore에 데이터 저장 성공!")
//                    }
//                }
        // Do any additional setup after loading the view.
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
        
    }	
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    
    @IBAction func createFortuneButtonTapped(_ sender: UIButton) {
        guard let inputText = textField.text, !inputText.isEmpty else { return }
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let resultVC = storyboard.instantiateViewController(withIdentifier: "ResultController") as? ResultController {
            resultVC.userInput = textField.text ?? ""
            resultVC.source = .home
            self.navigationController?.pushViewController(resultVC, animated: true)
        }

    }
    
}

	
