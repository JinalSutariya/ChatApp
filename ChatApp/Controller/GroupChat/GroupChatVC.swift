//
//  GroupChatVC.swift
//  ChatApp
//
//  Created by CubezyTech on 03/07/24.
//

import UIKit
import PusherSwift
import AVFoundation

class GroupChatVC: UIViewController, PusherDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, AVAudioPlayerDelegate, UITextFieldDelegate, AVAudioRecorderDelegate {
    
    // MARK: - OUTLET
    
    @IBOutlet weak var sentBtn: UIButton!
    @IBOutlet weak var recordingBtn: UIButton!
    @IBOutlet weak var musicBtn: UIButton!
    @IBOutlet weak var mediabtn: UIButton!
    @IBOutlet weak var userNameLbl: UILabel!
    @IBOutlet weak var messageTxt: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageTextFieldBottomConstraint: NSLayoutConstraint!
    
    // MARK: - PROPERTY
    
    var groupID: Int = 0
    var groupMessages: [GroupMessage] = []
    var groupName: String?
    var currentPage = 1
    var totalPages = 1
    var isLoading = false
    var pusher: Pusher!
    var name: String?
    var status: String?
    
    var audioRecorder: AVAudioRecorder?
    var audioPlayer: AVAudioPlayer?
    var audioFilename: URL?
    
    var isPlaying = false
    
    var currentPlayingButton: UIButton?
    var currentPlaybackTime: TimeInterval = 0
    var progressUpdateTimer: Timer?
    
    // MARK: - LIFE CYCLE
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        messageTxt.delegate = self // Set the delegate for the UITextField
        messageTxt.returnKeyType = UIReturnKeyType.done
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        
        tableView.register(UINib(nibName: "SendMessageTableViewCell", bundle: nil), forCellReuseIdentifier: "SenderCell")
        tableView.register(UINib(nibName: "ReceiveMessageTableViewCell", bundle: nil), forCellReuseIdentifier: "ReceiverCell")
        tableView.register(UINib(nibName: "ReceiveImageTableViewCell", bundle: nil), forCellReuseIdentifier: "imgReceiveCell")
        tableView.register(UINib(nibName: "SendImageTableViewCell", bundle: nil), forCellReuseIdentifier: "imgSendCell")
        tableView.register(UINib(nibName: "SendAudioTableViewCell", bundle: nil), forCellReuseIdentifier: "sendAudio")
        tableView.register(UINib(nibName: "ReceiveAudioTableViewCell", bundle: nil), forCellReuseIdentifier: "receiveAudio")
        
        setupAudioSession()
        
        sentBtn.isHidden = true
        userNameLbl.text = groupName
        tableView.delegate = self
        tableView.dataSource = self
        setOnlineStatus()
        setPusher()
        getChat()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    // MARK: - BUTTON CLICK
    
    @IBAction func groupDetailTap(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "groupDetail") as? GroupDetailVC
        vc?.groupID = groupID
        vc?.groupNameText = groupName
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    @IBAction func sendAudiioTap(_ sender: Any) {
        let picker = UIDocumentPickerViewController(documentTypes: ["public.audio"], in: .import)
        picker.delegate = self
        picker.modalPresentationStyle = .formSheet
        present(picker, animated: true, completion: nil)
    }
    
    @IBAction func recordingTap(_ sender: Any) {
        if audioRecorder == nil {
            startRecording()
        } else {
            stopRecording(success: true)
        }
    }
    
    @IBAction func backTap(_ sender: Any){
        performSegueToReturnBack()
        
    }
    
    @IBAction func sentBtn(_ sender: Any){
        guard let messageText = messageTxt.text, !messageText.isEmpty else {
            // Optionally, handle the case where there's no text to send
            return
        }
        
        self.messageTxt.resignFirstResponder()
        
        groupSendMessage(message: messageTxt.text!, groupId: groupID)
        
        self.messageTxt.text = ""
        recordingBtn.isHidden = false
        mediabtn.isHidden = false
        musicBtn.isHidden = false
        sentBtn.isHidden = true
        adjustTextFieldBottomConstraint(with: 0)
    }
    
    @IBAction func addMedia(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    // MARK: - ALL CUSTOM FUNCTION
    
    func scrollToBottom() {
        guard groupMessages.count > 0 else { return }
        let indexPath = IndexPath(row: groupMessages.count - 1, section: 0)
        tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
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
            sendAudio(fileURL: audioFilename, receiverID: groupID)
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
    
    // MARK: - SET PUSHER

    func setPusher() {
        guard let userId = UserDefaults.standard.string(forKey: "userId") else {
            print("User ID not found in UserDefaults.")
            return
        }
        
        let options = PusherClientOptions(host: .cluster("ap2"))
        
        pusher = Pusher(key: "269da4d263fa1b3bf7f9", options: options)
        pusher.delegate = self
        
        let channelName = "cubezytechgroup\(groupID)"
        print("Subscribing to channel: \(channelName)")
        let channel = pusher.subscribe(channelName)
        
        _ = channel.bind(eventName: "send-message", eventCallback: { [weak self] (event: PusherEvent) in
            guard let self = self else { return }
            if let data = event.data {
                print("Raw Event Data: \(data)")
                if let jsonData = data.data(using: .utf8) {
                    do {
                        let newMessages = try JSONDecoder().decode([GroupMessage].self, from: jsonData)
                        DispatchQueue.main.async {
                            for message in newMessages {
                                if message.senderID != Int(userId){
                                    
                                    print("New Message Received: \(message)")
                                    
                                    let newMessage = GroupMessage(groupID: message.groupID, senderID: message.senderID, message: message.message, type: message.type, updatedAt: message.updatedAt, createdAt: message.createdAt, id: message.id)
                                    
                                    
                                    self.groupMessages.append(newMessage)
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
        
        pusher.connect()
    }
    
    // MARK: - API CALL FOR GETCHAT
    
    func getChat() {
        guard !isLoading else { return }
        
        isLoading = true
        GetAuthService.shared.groupGetChat(page: currentPage, chatID: groupID) { (result: Result<GetGroupMessagesResponse, Error>) in
            switch result {
            case .success(let groupMessagesResponse):
                print("Chat messages fetched successfully")
                
                DispatchQueue.main.async {
                    self.currentPage += 1
                    
                    // Assuming the response contains messages in the correct order
                    let newMessages: [GroupMessage] = groupMessagesResponse.data.data.map { getGroupMessage in
                        return GroupMessage(groupID: getGroupMessage.groupId,
                                            senderID: getGroupMessage.senderId,
                                            message: getGroupMessage.message,
                                            type: getGroupMessage.type,
                                            updatedAt: getGroupMessage.updatedAt,
                                            createdAt: getGroupMessage.createdAt,
                                            id: getGroupMessage.id)
                    }
                    
                    self.groupMessages.insert(contentsOf: newMessages.reversed(), at: 0)
                    
                    let indexPaths: [IndexPath] = (0..<newMessages.count).map { IndexPath(row: $0, section: 0) }
                    
                    self.tableView.insertRows(at: indexPaths, with: .bottom)
                    
                    if self.currentPage == 2 {
                        self.tableView.reloadData()
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
    
    // MARK: - API CALL FOR SEND MESSAGE

    func groupSendMessage(message: String, groupId: Int) {
        guard let sendMessage = messageTxt.text, !sendMessage.isEmpty else { return }
        
        let urlString = "https://fullchatapp.brijeshnavadiya.com/api/send/group/message"
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let parameters: [String: Any] = [
            "group_id": groupId,
            "message": sendMessage,
            "type": "text"
        ]
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        
        if let token = UserDefaults.standard.string(forKey: "token") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            print("Failed to send message: No token found")
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("Error: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                do {
                    let sendMessageResponse = try JSONDecoder().decode(GroupSendMessageResponse.self, from: data)
                    DispatchQueue.main.async {
                        if sendMessageResponse.success == "true" {
                            let newMessage = GroupMessage(groupID: sendMessageResponse.data.groupID, senderID: sendMessageResponse.data.senderID, message: sendMessageResponse.data.message, type: sendMessageResponse.data.type, updatedAt: sendMessageResponse.data.updatedAt, createdAt: sendMessageResponse.data.createdAt, id: sendMessageResponse.data.id)
                            self.groupMessages.append(newMessage)
                            self.tableView.reloadData()
                            self.scrollToBottom()
                        } else {
                            print("Failed to send message: \(sendMessageResponse.message)")
                        }
                    }
                } catch {
                    print("Error decoding JSON response: \(error.localizedDescription)")
                    if let responseData = String(data: data, encoding: .utf8) {
                        print("Response data: \(responseData)")
                    }
                }
            } else {
                print("Error: Status code \((response as? HTTPURLResponse)?.statusCode ?? 0)")
            }
        }.resume()
    }
    
    // MARK: - API CALL FOR SEND IMAGE

    func sendImage(imageData: Data, receiverID: Int) {
        let urlString = "https://fullchatapp.brijeshnavadiya.com/api/send/group/message"
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
        body.append(Data("Content-Disposition: form-data; name=\"group_id\"\r\n\r\n".utf8))
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
                let sendImageResponse = try JSONDecoder().decode(GroupSendMessageResponse.self, from: data)
                DispatchQueue.main.async {
                    if sendImageResponse.success == "true" {
                        // Handle successful image sending
                        let newImageMessage = GroupMessage(groupID: sendImageResponse.data.groupID, senderID: sendImageResponse.data.senderID, message: sendImageResponse.data.message, type: sendImageResponse.data.type, updatedAt: sendImageResponse.data.updatedAt, createdAt: sendImageResponse.data.createdAt, id: sendImageResponse.data.id)
                        self.groupMessages.append(newImageMessage)
                        self.tableView.reloadData()
                        self.scrollToBottom()
                    } else {
                        // Handle failure
                        print("Failed to send image: \(sendImageResponse.message)")
                    }
                }
            } catch {
                print("Failed to decode JSONnnnnn: \(error.localizedDescription)")
            }
        }.resume()
    }
    // MARK: - API CALL FOR SEND AUDIO

    func sendAudio(fileURL: URL, receiverID: Int) {
        let parameters = [
            [
                "key": "group_id",
                "value": "\(receiverID)",
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
        
        var request = URLRequest(url: URL(string: "https://fullchatapp.brijeshnavadiya.com/api/send/group/message")!, timeoutInterval: Double.infinity)
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
                let sendImageResponse = try JSONDecoder().decode(GroupSendMessageResponse.self, from: data)
                DispatchQueue.main.async {
                    if sendImageResponse.success == "true" {
                        // Handle successful image sending
                        let newImageMessage = GroupMessage(groupID: sendImageResponse.data.groupID, senderID: sendImageResponse.data.senderID, message: sendImageResponse.data.message, type: sendImageResponse.data.type, updatedAt: sendImageResponse.data.updatedAt, createdAt: sendImageResponse.data.createdAt, id: sendImageResponse.data.id)
                        self.groupMessages.append(newImageMessage)
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
    
    // MARK: - TEXTFIELD DELEGATE
    
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
    
    func adjustTextFieldBottomConstraint(with height: CGFloat) {
        UIView.animate(withDuration: 0.3) {
            self.messageTextFieldBottomConstraint.constant = height
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        adjustTextFieldBottomConstraint(with: 0)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool{
        guard let currentText = textField.text as NSString? else { return true }
        let newText = currentText.replacingCharacters(in: range, with: string)
        
        // Show or hide buttons based on the new text
        if newText.isEmpty {
            mediabtn.isHidden = false
            musicBtn.isHidden = false
            sentBtn.isHidden = true
            recordingBtn.isHidden = false
        } else {
            mediabtn.isHidden = true
            musicBtn.isHidden = true
            sentBtn.isHidden = false
            recordingBtn.isHidden = true
        }
        
        print(newText)
        return true
    }
    
    // MARK: - IMAGE PICKER

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        if let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage,
           let imageData = selectedImage.jpegData(compressionQuality: 0.8) {
            sendImage(imageData: imageData, receiverID: groupID)
        }
    }
}

// MARK: - TABLEVIEW DELEGATE
 
extension GroupChatVC: UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groupMessages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = groupMessages[indexPath.row]
        let userId = UserDefaults.standard.string(forKey: "userId")
        
        if message.type == "image" {
            if message.senderID == Int(userId ?? "") {
                let cell = tableView.dequeueReusableCell(withIdentifier: "imgSendCell", for: indexPath) as! SendImageTableViewCell
                if let imageURL = URL(string: "https://fullchatapp.brijeshnavadiya.com/public/assets/images/\(message.message)") {
                    ImageLoader.shared.loadImage(from: imageURL) { image in
                        DispatchQueue.main.async {
                            cell.imgView.image = image
                            print("receiveImage",imageURL)
                            
                        }
                    }
                    cell.backView.layer.cornerRadius = 8
                    cell.selectionStyle = .none
                    cell.timeLbl.text = formatTimestamp(message.createdAt)
                    
                }
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "imgReceiveCell", for: indexPath) as! ReceiveImageTableViewCell
                if let imageURL = URL(string: "https://fullchatapp.brijeshnavadiya.com/public/assets/images/\(message.message)") {
                    ImageLoader.shared.loadImage(from: imageURL) { image in
                        DispatchQueue.main.async {
                            cell.imgView.image = image
                            print("SendImageURL",imageURL)
                        }
                    }
                    cell.userName.text = groupName
                    cell.backView.layer.cornerRadius = 8
                    cell.selectionStyle = .none
                    
                    cell.timeLbl.text = formatTimestamp(message.createdAt)
                    
                }
                return cell
            }
        }
        else if message.type == "audio" {
            if message.senderID == Int(userId ?? "") {
                // Configure ReceiveAudioTableViewCell
                let cell = tableView.dequeueReusableCell(withIdentifier: "sendAudio", for: indexPath) as! SendAudioTableViewCell
                if let audioURL = URL(string: "https://fullchatapp.brijeshnavadiya.com/public/assets/audio/\(message.message)") {
                    cell.playBtn.addTarget(self, action: #selector(playAudio(_:)), for: .touchUpInside)
                    cell.playBtn.tag = indexPath.row
                }
                cell.timeLbl.text = formatTimestamp(message.createdAt)
                
                cell.backView.layer.cornerRadius = 10
                cell.selectionStyle = .none
                
                return cell
            } else {
                // Configure SendAudioTableViewCell
                let cell = tableView.dequeueReusableCell(withIdentifier: "receiveAudio", for: indexPath) as! ReceiveAudioTableViewCell
                if let audioURL = URL(string: "https://fullchatapp.brijeshnavadiya.com/public/assets/audio/\(message.message)") {
                    cell.playBtn.addTarget(self, action: #selector(playAudio(_:)), for: .touchUpInside)
                    cell.playBtn.tag = indexPath.row
                }
                cell.timelbl.text = formatTimestamp(message.createdAt)
                cell.userName.text = groupName
                cell.backView.layer.cornerRadius = 10
                cell.selectionStyle = .none
                
                return cell
            }
        }
        else{
            if message.senderID == Int(userId ?? "") {
                let cell = tableView.dequeueReusableCell(withIdentifier: "SenderCell", for: indexPath) as! SendMessageTableViewCell
                cell.msgLbl.text = message.message
                cell.timeLbl.text = formatTimestamp(message.createdAt)
                cell.selectionStyle = .none
                cell.backView.roundCorners(corners: [.topLeft, .bottomLeft, .bottomRight], radius: 8)
                
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "ReceiverCell", for: indexPath) as! ReceiveMessageTableViewCell
                cell.msgLbl.text = message.message
                cell.userName.text = groupName
                cell.timeLbl.text = formatTimestamp(message.createdAt)
                cell.backView.roundCorners(corners: [.topRight, .bottomLeft, .bottomRight], radius: 8)
                cell.selectionStyle = .none
                
                return cell
            }
        }
    }
    
    
    
    @objc func playAudio(_ sender: UIButton) {
        let message = groupMessages[sender.tag]
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
                getChat()
            }
        }
    }
    
}

extension GroupChatVC: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let selectedFileURL = urls.first else { return }
        print("Selected audio file URL: \(selectedFileURL)")
        
        // Send the selected audio file
        sendAudio(fileURL: selectedFileURL, receiverID: groupID)
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        print("Document picker was cancelled.")
    }
}

