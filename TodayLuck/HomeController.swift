
import UIKit
import FirebaseFirestore

class HomeController: UIViewController {

    @IBOutlet weak var textField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        let db = Firestore.firestore()

        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
        
    }	
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    
    @IBAction func createFortuneButtonTapped(_ sender: UIButton) {
        
        guard let inputText = textField.text, !inputText.isEmpty else { return }
        
        callChatGPTAPI(userInput: inputText) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let fortuneData):
                    // Firestore 저장
                    let docData: [String: Any] = [
                        "input": inputText,
                        "type": fortuneData.type,
                        "value": fortuneData.value,
                        "message": fortuneData.message,
                        "timestamp": Timestamp(date: Date())
                    ]

                    Firestore.firestore().collection("fortunes").addDocument(data: docData)
                    
                    // 결과 화면 이동
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    if let resultVC = storyboard.instantiateViewController(withIdentifier: "ResultController") as? ResultController {
                        resultVC.userInput = inputText
                        resultVC.source = .home
                        resultVC.fortuneData = fortuneData
                        self.navigationController?.pushViewController(resultVC, animated: true)
                    }
                case .failure(let error):
                    print("API 오류: \(error)")
                }
            }
        }
    }
    
    // MARK: - ChatGPT API 관련 코드
    
    struct FortuneData: Codable {
        let type: String
        let value: String
        let message: String
    }

    
    func callChatGPTAPI(userInput: String, completion: @escaping (Result<FortuneData, Error>) -> Void) {
        guard let url = URL(string: "https://api.openai.com/v1/chat/completions") else { return }
        
        let isDailyFortune = userInput == "오늘의 운세"

        let systemPrompt: String
        let userPrompt: String
        
        if isDailyFortune {
            systemPrompt = "너는 운세 생성 도우미야."
            userPrompt = """
            오늘의 운세를 만들어줘. 다음 형식으로 생성해줘:
            {
              "type": "special",
              "value": "fortune",
              "message": "운세 총평: (사자성어)\\n설명: (따뜻한 메시지,총 80자 제한)"
            }
            """
        } else {
            systemPrompt = """
            사용자의 문장을 읽고 '기분' 또는 '상황' 중 하나를 선택하세요.
            - '기분'인 경우: 행복, 슬픔, 불안, 분노, 피곤, 평온 중 하나
            - '상황'인 경우: 성적, 건강, 금전, 사랑, 직장, 기타 중 하나

            반드시 아래 JSON 형식으로 응답하세요:
            {
              "type": "mood" 또는 "situation",
              "value": "위 목록 중 하나",
              "message": "간단한 운세 메시지"
            }
            """
            userPrompt = userInput
        }

        let messages: [[String: String]] = [
            ["role": "system", "content": systemPrompt],
            ["role": "user", "content": userPrompt]
        ]
        
        let json: [String: Any] = [
            "model": "gpt-3.5-turbo",
            "messages": messages,
            "temperature": 0.9
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        guard let apiKey = getAPIKey() else {
            print("API Key가 없습니다.")
            return
        }

        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: json)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data,
                  let result = try? JSONDecoder().decode(ChatGPTResponse.self, from: data),
                  let content = result.choices.first?.message.content,
                  let jsonData = content.data(using: .utf8),
                  let parsed = try? JSONDecoder().decode(FortuneData.self, from: jsonData) else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "파싱 오류"])))
                return
            }
            completion(.success(parsed))
        }.resume()
    }
    
    struct ChatGPTResponse: Codable {
        struct Choice: Codable {
            struct Message: Codable {
                let content: String
            }
            let message: Message
        }
        let choices: [Choice]
    }
    
   

    
    func getAPIKey() -> String? {
        if let path = Bundle.main.path(forResource: "apikeys", ofType: "plist"),
           let dict = NSDictionary(contentsOfFile: path) as? [String: Any] {
            return dict["OPENAI_API_KEY"] as? String
        }
        return nil
    }
}
