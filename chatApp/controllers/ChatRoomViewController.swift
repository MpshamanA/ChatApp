//
//  chatRoomViewContoller.swift
//  chatApp
//
//  Created by ShoIwasaki on 2021/08/02.
//

import UIKit
import Firebase

class ChatRoomViewController: UIViewController {
    
    var user: User?
    
    private let cellId = "cellId"
    private var messages = [Message]()
    
    public var chatRoom:ChatRoom?
    
    //あとで調べる
    //lazyはselfにアクセスするために付与
    private lazy var chatInputAccessoryView: ChatInputAccessoryView = {
        let view = ChatInputAccessoryView()
        view.frame = .init(x: 0, y: 0, width: view.frame.width, height: 110)
        view.delegate = self
        return view
    }()
    
    @IBOutlet weak var chatRoomTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        chatRoomTableView.backgroundColor = .rgb(red: 118, green: 140, bule: 180)
        chatRoomTableView.delegate = self
        chatRoomTableView.dataSource = self
        //        別ファイルで作成した際は以下を必ず指定する
        chatRoomTableView.register(UINib(nibName: "ChatRoomTableViewCell", bundle: nil), forCellReuseIdentifier: cellId)
        fetchMessages()
    }
    
    override var inputAccessoryView: UIView?{
        get{
            return chatInputAccessoryView
        }
    }
    //あとで調べる
    override var canBecomeFirstResponder: Bool{
        return true
    }
    
    private func fetchMessages(){
        guard let chatRoomDocId = chatRoom?.documentId else{return}
        
        Firestore.firestore().collection("ChatRooms").document(chatRoomDocId).collection("messages").addSnapshotListener{
            snapshots ,err in
            if let err = err {
                print("メッセージの取得に失敗しました",err)
                return
            }
            snapshots?.documentChanges.forEach({ (documentChange) in
                       switch documentChange.type {
                       case .added:
                        let dic = documentChange.document.data()
                        let message = Message(dic: dic)
                        message.partnerUser = self.chatRoom?.partnerUser
                        self.messages.append(message)
                           self.chatRoomTableView.reloadData()
                           
                       case .modified, .removed:
                           print("nothing to do")
                       }
                   })
        }
    }
}

extension ChatRoomViewController:ChatInputAccessoryViewDelegate{
    func tappedSendButton(text: String) {
        guard let chatRoomDocId = chatRoom?.documentId else { return }
        guard let name = user?.username else { return }
        //現在ログイン中のユーザのuidを取得
        guard let uid = Auth.auth().currentUser?.uid else { return }
        //textを登録したら削除する
        chatInputAccessoryView.removeText()
        let docData = [
            "name": name,
            "createdAt": Timestamp(),
            "uid": uid,
            "message": text
        ] as [String : Any]
        
        Firestore.firestore().collection("ChatRooms").document(chatRoomDocId).collection("messages").document().setData(docData) { (err) in
            if let err = err {
                print("メッセージ情報の保存に失敗しました。\(err)")
                return
            }
            
        }
    }
}

extension ChatRoomViewController: UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        //最小のheightを指定する
        chatRoomTableView.estimatedRowHeight = 20
        //メッセージの幅に合わせてセルの大きさを変更する
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = chatRoomTableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! ChatRoomTableViewCell
        cell.message = messages[indexPath.row]
        return cell
    }
    
    
}
