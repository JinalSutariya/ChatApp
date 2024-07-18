//
//  ChatVC.swift
//  ChatApp
//
//  Created by CubezyTech on 27/06/24.
//

import UIKit
import PusherSwift
import AVFoundation

class ChatVC: UIViewController, PusherDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, AVAudioPlayerDelegate, UITextFieldDelegate, AVAudioRecorderDelegate {

    @IBOutlet weak var userNameLbl: UILabel!
    
    @IBOutlet weak var addMediaBtn: UIButton!
    @IBOutlet weak var statusLbl: UILabel!
    @IBOutlet weak var messageTxt: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var sentBtn: UIButton!
    @IBOutlet weak var audioBtn: UIButton!
    @IBOutlet weak var recorderBtn: UIButton!
    @IBOutlet weak var messageTextFieldBottomConstraint: NSLayoutConstraint!
    
    
    var name: String?
        var status: String?
        var receiverID: String?
        var audioPlayer: AVAudioPlayer?
        var progressUpdateTimer: Timer?
        
        var chatMessages: [Message] = []
        var currentPage = 1
        var totalPages = 1
        
        var isLoading = false
        
        var pusher: Pusher!
        var audioRecorder: AVAudioRecorder?
        var audioFilename: URL?
        
        var isPlaying = false
        
        var currentPlayingButton: UIButton?
        var currentPlaybackTime: TimeInterval = 0
        
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "SendMessageTableViewCell", bundle: nil), forCellReuseIdentifier: "SenderCell")
        tableView.register(UINib(nibName: "ReceiveMessageTableViewCell", bundle: nil), forCellReuseIdentifier: "ReceiverCell")
        tableView.register(UINib(nibName: "ReceiveImageTableViewCell", bundle: nil), forCellReuseIdentifier: "imgReceiveCell")
        tableView.register(UINib(nibName: "SendImageTableViewCell", bundle: nil), forCellReuseIdentifier: "imgSendCell")
        tableView.register(UINib(nibName: "SendAudioTableViewCell", bundle: nil), forCellReuseIdentifier: "sendAudio")
        tableView.register(UINib(nibName: "ReceiveAudioTableViewCell", bundle: nil), forCellReuseIdentifier: "receiveAudio")
        tableView.register(UINib(nibName: "SendRecordingTableViewCell", bundle: nil), forCellReuseIdentifier: "sendRecordingTableViewCell")

        
        messageTxt.delegate = self // Set the delegate for the UITextField
        messageTxt.returnKeyType = UIReturnKeyType.done
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        statusLbl.text = status
        userNameLbl.text = name
        tableView.delegate = self
        tableView.dataSource = self
        
       
        sentBtn.isHidden = true
       
        setPusher()
        setOnlineStatus()
        getAllChat()
        setupAudioSession()

    }
   
    @IBAction func musicTap(_ sender: Any) {
        let picker = UIDocumentPickerViewController(documentTypes: ["public.audio"], in: .import)
        picker.delegate = self
        picker.modalPresentationStyle = .formSheet
        present(picker, animated: true, completion: nil)
    }
    @IBAction func backTap(_ sender: Any) {
        performSegueToReturnBack()
    }
    
    @IBAction func sentBtn(_ sender: Any) {
        guard let messageText = messageTxt.text, !messageText.isEmpty else {
            return
        }
        self.messageTxt.resignFirstResponder()
        sendMessage(message: messageText, receiverID: receiverID!)
        self.messageTxt.text = ""
        recorderBtn.isHidden = false
        addMediaBtn.isHidden = false
        audioBtn.isHidden = false
        sentBtn.isHidden = true

        adjustTextFieldBottomConstraint(with: 0)
    }
    @IBAction func recordingTap(_ sender: Any) {
        if audioRecorder == nil {
                   startRecording()
               } else {
                   stopRecording(success: true)
               }
    }
    
    func setupAudioSession() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker])
            try audioSession.setActive(true)
        } catch {
            print("Failed to setup audio session: \(error.localizedDescription)")
        }
    }

    func startRecording() {
            let audioFilename = getDocumentsDirectory().appendingPathComponent("recording.m4a")
            self.audioFilename = audioFilename

            let settings = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 12000,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]

            do {
                audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
                audioRecorder?.delegate = self
                audioRecorder?.record()
            } catch {
                stopRecording(success: false)
            }
        }

        func stopRecording(success: Bool) {
            audioRecorder?.stop()
            audioRecorder = nil

            guard let audioFilename = audioFilename else {
                print("Audio filename is nil.")
                return
            }

            if success {
                print("Recording succeeded: \(audioFilename)")
                sendAudio(fileURL: audioFilename, receiverID: receiverID!)
            } else {
                print("Recording failed.")
            }
        }

        func playAudio() {
            guard let fileURL = audioFilename, FileManager.default.fileExists(atPath: fileURL.path) else {
                print("Audio file not found at path: \(String(describing: audioFilename?.path))")
                return
            }

            do {
                audioPlayer = try AVAudioPlayer(contentsOf: fileURL)
                audioPlayer?.delegate = self
                audioPlayer?.prepareToPlay()
                audioPlayer?.play()
            } catch {
                print("Failed to play audio: \(error.localizedDescription)")
            }
        }

        func getDocumentsDirectory() -> URL {
            let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            return paths[0]
        }
    @IBAction func addMediaTap(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        return true
    }
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let keyboardHeight = keyboardSize.height
            adjustTextFieldBottomConstraint(with: keyboardHeight)
        }
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool{
        guard let currentText = textField.text as NSString? else { return true }
        let newText = currentText.replacingCharacters(in: range, with: string)
        
        // Show or hide buttons based on the new text
        if newText.isEmpty {
            addMediaBtn.isHidden = false
            audioBtn.isHidden = false
            sentBtn.isHidden = true
            recorderBtn.isHidden = false
        } else {
            addMediaBtn.isHidden = true
            audioBtn.isHidden = true
            sentBtn.isHidden = false
            recorderBtn.isHidden = true
        }
        
        print(newText)
        return true
    }
    @objc func keyboardWillHide(notification: NSNotification) {
        adjustTextFieldBottomConstraint(with: 0)
    }
    
    func adjustTextFieldBottomConstraint(with height: CGFloat) {
        UIView.animate(withDuration: 0.3) {
            self.messageTextFieldBottomConstraint.constant = height
            self.view.layoutIfNeeded()
        }
    }
    func setPusher() {
        guard let userId = UserDefaults.standard.string(forKey: "userId") else {
            print("User ID not found in UserDefaults.")
            return
        }
        
        let options = PusherClientOptions(
            host: .cluster("ap2")
        )
        
        pusher = Pusher(
            key: "269da4d263fa1b3bf7f9",
            options: options
        )
        
        pusher.delegate = self
        
        let channelName = "cubezytech\(userId)"
        print("Subscribing to channel: \(channelName)")
        let channel = pusher.subscribe(channelName)
        
        _ = channel.bind(eventName: "send-message", eventCallback: { [weak self] (event: PusherEvent) in
            guard let self = self else { return }
            if let data = event.data {
                print("Raw Event Data: \(data)")
                if let jsonData = data.data(using: .utf8) {
                    do {
                        let newMessages = try JSONDecoder().decode([Message].self, from: jsonData)
                        DispatchQueue.main.async {
                            for message in newMessages {
                                print("New Message Received: \(message)")
                                if message.senderID == Int(self.receiverID!) || message.receiverID == Int(self.receiverID!) {
                                    let newMessage = Message(
                                        id: message.id,
                                        converID: message.converID,
                                        senderID: message.senderID,
                                        receiverID: message.receiverID,
                                        message: message.message,
                                        type: message.type,
                                        createdAt: message.createdAt,
                                        updatedAt: message.updatedAt
                                    )
                                    
                                    self.chatMessages.append(newMessage)
                                    self.tableView.reloadData()
                                    self.scrollToBottom()
                                }
                            }
                        }
                    } catch {
                        print("Failed to decode message data: \(error.localizedDescription)")
                        if let jsonString = String(data: jsonData, encoding: .utf8) {
                            print("Raw JSON Data: \(jsonString)")
                        }
                    }
                }
            }
        })
        let statusChannelName = "cubezytech\(receiverID ?? "")"
        print("Subscribing to status channel: \(statusChannelName)")
        let statusChannel = pusher.subscribe(statusChannelName)
        
        _ = statusChannel.bind(eventName: "set-status", eventCallback: { [weak self] (event: PusherEvent) in
            guard let self = self else { return }
            if let data = event.data {
                print("Status Event Data: \(data)")
                if let jsonData = data.data(using: .utf8) {
                    do {
                        let statusUpdate = try JSONDecoder().decode(StatusUpdate.self, from: jsonData)
                        DispatchQueue.main.async {
                            self.statusLbl.text = statusUpdate.status
                        }
                    } catch {
                        print("Failed to decode status data: \(error.localizedDescription)")
                    }
                }
            }
        })
        
        pusher.connect()
    }
    
    func getAllChat() {
        guard !isLoading else { return }
        
        isLoading = true
        
        GetAuthService.shared.getAllChat(page: currentPage, chatID: receiverID!) { result in
            switch result {
            case .success(let chatMessagesResponse):
                print("Chat messages fetched successfully")
                
                DispatchQueue.main.async {
                    // Update pagination
                    self.currentPage += 1
                    self.totalPages = chatMessagesResponse.data.lastPage
                    let newMessages = chatMessagesResponse.data.messages.reversed()
                    self.chatMessages.insert(contentsOf: newMessages, at: 0)
                    let indexPaths = (0..<newMessages.count).map { IndexPath(row: $0, section: 0) }
                    self.tableView.insertRows(at: indexPaths, with: .bottom)
                    if self.currentPage == 2 {
                        self.scrollToBottom()
                    }
                    self.isLoading = false
                }
                
            case .failure(let error):
                print("Failed to fetch chat messages:", error)
                DispatchQueue.main.async {
                    self.isLoading = false
                }
            }
        }
    }
    
    func sendMessage(message: String, receiverID: String) {
        
        guard let sendMessage = messageTxt.text, !sendMessage.isEmpty else { return }
        
        let urlString = "\(Constant.API.BASE_URL)api/send/message"
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let token = UserDefaults.standard.string(forKey: "token") {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            print("No token found")
            return
        }
        
        let messageRequest: [String: Any] = ["receiveruser_id": receiverID, "message": sendMessage, "type": "text"]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: messageRequest, options: .prettyPrinted)
        } catch {
            print("Error creating JSON data: \(error.localizedDescription)")
            return
        }
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let data = data, error == nil else {
                print("Error: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            do {
                let sendMessageResponse = try JSONDecoder().decode(SendMessageResponse.self, from: data)
                DispatchQueue.main.async {
                    if sendMessageResponse.success == "true" {
                        // Handle successful message sending
                        print("Message sent: \(sendMessageResponse.data.message)")
                        // Append the new message to your chat messages array
                        let newMessage = Message(
                            id: sendMessageResponse.data.id,
                            converID: sendMessageResponse.data.converID,
                            senderID: sendMessageResponse.data.senderID,
                            receiverID: sendMessageResponse.data.receiverID,
                            message: sendMessageResponse.data.message,
                            type: sendMessageResponse.data.type,
                            createdAt: sendMessageResponse.data.createdAt,
                            updatedAt: sendMessageResponse.data.updatedAt
                        )
                        self?.chatMessages.append(newMessage)
                        self?.tableView.reloadData()
                        self?.scrollToBottom()
                    } else {
                        // Handle failure
                        print("Failed to send message: \(sendMessageResponse.message)")
                    }
                }
            } catch {
                if let jsonString = String(data: data, encoding: .utf8) {
                    // print("Failed to decode JSON. Raw JSON: \(jsonString)")
                }
                print("Failed to decode JSON: \(error.localizedDescription)")
            }
        }.resume()
    }
    
    func sendImage(imageData: Data, receiverID: String) {
        let urlString = "https://fullchatapp.brijeshnavadiya.com/api/send/message"
        guard let url = URL(string: urlString) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        if let token = UserDefaults.standard.string(forKey: "token") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        var body = Data()
        let boundaryPrefix = "--\(boundary)\r\n"
        
        body.append(Data(boundaryPrefix.utf8))
        body.append(Data("Content-Disposition: form-data; name=\"receiveruser_id\"\r\n\r\n".utf8))
        body.append(Data("\(receiverID)\r\n".utf8))
        
        body.append(Data(boundaryPrefix.utf8))
        body.append(Data("Content-Disposition: form-data; name=\"message\"; filename=\"image.jpg\"\r\n".utf8))
        body.append(Data("Content-Type: image/jpeg\r\n\r\n".utf8))
        body.append(imageData)
        body.append(Data("\r\n".utf8))
        
        body.append(Data(boundaryPrefix.utf8))
        body.append(Data("Content-Disposition: form-data; name=\"type\"\r\n\r\n".utf8))
        body.append(Data("image\r\n".utf8))
        
        body.append(Data("--\(boundary)--\r\n".utf8))
        
        request.httpBody = body
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("Error: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            do {
                let sendImageResponse = try JSONDecoder().decode(SendMessageResponse.self, from: data)
                DispatchQueue.main.async {
                    if sendImageResponse.success == "true" {
                        // Handle successful image sending
                        let newImageMessage = Message(
                            id: sendImageResponse.data.id,
                            converID: sendImageResponse.data.converID,
                            senderID: sendImageResponse.data.senderID,
                            receiverID: sendImageResponse.data.receiverID,
                            message: sendImageResponse.data.message,
                            type: sendImageResponse.data.type,
                            createdAt: sendImageResponse.data.createdAt,
                            updatedAt: sendImageResponse.data.updatedAt
                        )
                        self.chatMessages.append(newImageMessage)
                        self.tableView.reloadData()
                        self.scrollToBottom()
                    } else {
                        // Handle failure
                        print("Failed to send image: \(sendImageResponse.message)")
                    }
                }
            } catch {
                print("Failed to decode JSON: \(error.localizedDescription)")
            }
        }.resume()
    }
    
    func sendAudio(fileURL: URL, receiverID: String) {
        let parameters = [
            [
                "key": "receiveruser_id",
                "value": receiverID,
                "type": "text"
            ],
            [
                "key": "message",
                "src": fileURL.path, // Use the fileURL path
                "type": "file"
            ],
            [
                "key": "type",
                "value": "audio",
                "type": "text"
            ]] as [[String: Any]]
        
        let boundary = "Boundary-\(UUID().uuidString)"
        var body = Data()
        
        for param in parameters {
            let paramName = param["key"]!
            body += Data("--\(boundary)\r\n".utf8)
            body += Data("Content-Disposition:form-data; name=\"\(paramName)\"".utf8)
            
            if param["contentType"] != nil {
                body += Data("\r\nContent-Type: \(param["contentType"] as! String)".utf8)
            }
            
            let paramType = param["type"] as! String
            if paramType == "text" {
                let paramValue = param["value"] as! String
                body += Data("\r\n\r\n\(paramValue)\r\n".utf8)
            } else {
                let paramSrc = param["src"] as! String
                let fileURL = URL(fileURLWithPath: paramSrc)
                if let fileContent = try? Data(contentsOf: fileURL) {
                    body += Data("; filename=\"\(fileURL.lastPathComponent)\"\r\n".utf8)
                    body += Data("Content-Type: audio/mpeg\r\n".utf8)
                    body += Data("\r\n".utf8)
                    body += fileContent
                    body += Data("\r\n".utf8)
                }
            }
        }
        body += Data("--\(boundary)--\r\n".utf8)
        
        var request = URLRequest(url: URL(string: "https://fullchatapp.brijeshnavadiya.com/api/send/message")!, timeoutInterval: Double.infinity)
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        if let token = UserDefaults.standard.string(forKey: "token") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        request.addValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = body
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("Error: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            do {
                let sendImageResponse = try JSONDecoder().decode(SendMessageResponse.self, from: data)
                DispatchQueue.main.async {
                    if sendImageResponse.success == "true" {
                        // Handle successful image sending
                        let newImageMessage = Message(
                            id: sendImageResponse.data.id,
                            converID: sendImageResponse.data.converID,
                            senderID: sendImageResponse.data.senderID,
                            receiverID: sendImageResponse.data.receiverID,
                            message: sendImageResponse.data.message,
                            type: sendImageResponse.data.type,
                            createdAt: sendImageResponse.data.createdAt,
                            updatedAt: sendImageResponse.data.updatedAt
                        )
                        self.chatMessages.append(newImageMessage)
                        self.tableView.reloadData()
                        self.scrollToBottom()
                    } else {
                        // Handle failure
                        print("Failed to send image: \(sendImageResponse.message)")
                    }
                }
            } catch {
                print("Failed to decode JSON: \(error.localizedDescription)")
            }
        }.resume()
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        if let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage,
           let imageData = selectedImage.jpegData(compressionQuality: 0.8) {
            sendImage(imageData: imageData, receiverID: receiverID!)
        }
    }
    
    func scrollToBottom() {
        guard chatMessages.count > 0 else { return }
        let indexPath = IndexPath(row: chatMessages.count - 1, section: 0)
        tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
    }
    
}

extension ChatVC: UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatMessages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = chatMessages[indexPath.row]
        
        if message.type == "image" {
            if message.senderID == Int(receiverID ?? ""){
                let cell = tableView.dequeueReusableCell(withIdentifier: "imgReceiveCell", for: indexPath) as! ReceiveImageTableViewCell
                if let imageURL = URL(string: "https://fullchatapp.brijeshnavadiya.com/public/assets/images/\(message.message)") {
                    ImageLoader.shared.loadImage(from: imageURL) { image in
                        DispatchQueue.main.async {
                            cell.imgView.image = image
                            print("ReceiveImageURL",imageURL)
                            
                        }
                    }
                    cell.backView.layer.cornerRadius = 8
                    cell.backView.roundCorners(corners: [.topRight, .bottomLeft, .bottomRight], radius: 8)
                    cell.selectionStyle = .none
                    cell.timeLbl.text = formatTimestamp(message.createdAt)
                    
                }
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "imgSendCell", for: indexPath) as! SendImageTableViewCell
                if let imageURL = URL(string: "https://fullchatapp.brijeshnavadiya.com/public/assets/images/\(message.message)") {
                    ImageLoader.shared.loadImage(from: imageURL) { image in
                        DispatchQueue.main.async {
                            cell.imgView.image = image
                            print("SendImageURL",imageURL)
                        }
                    }
                    cell.backView.layer.cornerRadius = 8
                    cell.backView.roundCorners(corners: [.topLeft, .bottomLeft, .bottomRight], radius: 8)
                    cell.selectionStyle = .none
                    cell.timeLbl.text = formatTimestamp(message.createdAt)
                    
                }
                return cell
            }
        }
        else if message.type == "audio" {
            if message.senderID == Int(receiverID ?? ""){
                // Configure ReceiveAudioTableViewCell
                let cell = tableView.dequeueReusableCell(withIdentifier: "receiveAudio", for: indexPath) as! ReceiveAudioTableViewCell
                if let audioURL = URL(string: "https://fullchatapp.brijeshnavadiya.com/public/assets/audio/\(message.message)") {
                    cell.playBtn.addTarget(self, action: #selector(playAudio(_:)), for: .touchUpInside)
                    cell.playBtn.tag = indexPath.row
                }
                cell.timelbl.text = formatTimestamp(message.createdAt)
                cell.selectionStyle = .none
                cell.backView.layer.cornerRadius = 10
                return cell
            } else {
                // Configure SendAudioTableViewCell
                let cell = tableView.dequeueReusableCell(withIdentifier: "sendAudio", for: indexPath) as! SendAudioTableViewCell
                if let audioURL = URL(string: "https://fullchatapp.brijeshnavadiya.com/public/assets/audio/\(message.message)") {
                    cell.playBtn.addTarget(self, action: #selector(playAudio(_:)), for: .touchUpInside)
                    cell.playBtn.tag = indexPath.row
                }
                cell.timeLbl.text = formatTimestamp(message.createdAt)
                cell.selectionStyle = .none
                cell.backView.layer.cornerRadius = 10
                return cell
            }
            
        }
        else {
            if message.senderID == Int(receiverID ?? ""){
                let cell = tableView.dequeueReusableCell(withIdentifier: "ReceiverCell", for: indexPath) as! ReceiveMessageTableViewCell
                cell.msgLbl.text = message.message
                cell.userName.text = name
                cell.timeLbl.text = formatTimestamp(message.createdAt)
                cell.selectionStyle = .none
                cell.backView.roundCorners(corners: [.topRight, .bottomLeft, .bottomRight], radius: 8)
                
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "SenderCell", for: indexPath) as! SendMessageTableViewCell
                cell.msgLbl.text = message.message
                cell.timeLbl.text = formatTimestamp(message.createdAt)
                cell.selectionStyle = .none
                cell.backView.roundCorners(corners: [.topLeft, .bottomLeft, .bottomRight], radius: 8)
                
                return cell
            }
        }
    }
    @objc func playAudio(_ sender: UIButton) {
        let message = chatMessages[sender.tag]
        if let cell = tableView.cellForRow(at: IndexPath(row: sender.tag, section: 0)) as? SendAudioTableViewCell {
            AudioManager.shared.playAudio(sender, with: message.message, waveformProgressView: cell.WaveProgressView)
        } else if let cell = tableView.cellForRow(at: IndexPath(row: sender.tag, section: 0)) as? ReceiveAudioTableViewCell {
            AudioManager.shared.playAudio(sender, with: message.message, waveformProgressView: cell.waveProgressView)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        if offsetY < 0 {
            if currentPage <= totalPages && !isLoading {
                getAllChat()
            }
        }
    }
}

extension ChatVC: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let selectedFileURL = urls.first else { return }
        print("Selected audio file URL: \(selectedFileURL)")
        sendAudio(fileURL: selectedFileURL, receiverID: receiverID!)
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        print("Document picker was cancelled.")
    }
    
}
