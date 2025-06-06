
import UIKit

class HomeController: UIViewController {

    @IBOutlet weak var textField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
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

	
