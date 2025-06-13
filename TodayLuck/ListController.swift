import UIKit
import FirebaseFirestore

class ListController: UIViewController, UITableViewDelegate, UITableViewDataSource {

   
    @IBOutlet weak var tableView: UITableView!
    
    struct FortuneRecord {
        let id: String
        let input: String
        let type: String
        let value: String
        let message: String
        let timestamp: Timestamp
    }
    
    var fortuneList: [FortuneRecord] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        fetchFortunes()
    }

    func fetchFortunes() {
        Firestore.firestore().collection("fortunes")
            .order(by: "timestamp", descending: true)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("데이터 불러오기 오류: \(error)")
                    return
                }
                guard let documents = snapshot?.documents else { return }

                self.fortuneList = documents.compactMap { doc in
                    let data = doc.data()
                    guard let input = data["input"] as? String,
                          let type = data["type"] as? String,
                          let value = data["value"] as? String,
                          let message = data["message"] as? String,
                          let timestamp = data["timestamp"] as? Timestamp else {
                        return nil
                    }
                    return FortuneRecord(id: doc.documentID, input: input, type: type, value: value, message: message, timestamp: timestamp)
                }
                self.tableView.reloadData()
            }
    }

    // MARK: - UITableView Data Source

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fortuneList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FortuneCell", for: indexPath)
        let fortune = fortuneList[indexPath.row]
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        let dateString = dateFormatter.string(from: fortune.timestamp.dateValue())
        
        cell.textLabel?.text = dateString
        cell.detailTextLabel?.text = fortune.input
        return cell
    }

    // MARK: - UITableView Delegate

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let fortune = fortuneList[indexPath.row]
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let resultVC = storyboard.instantiateViewController(withIdentifier: "ResultController") as? ResultController {
            
            let fortuneData = HomeController.FortuneData(type: fortune.type, value: fortune.value, message: fortune.message)
            resultVC.userInput = fortune.input
            resultVC.fortuneData = fortuneData
            resultVC.source = .list
            
            self.navigationController?.pushViewController(resultVC, animated: true)
        }
    }
}
