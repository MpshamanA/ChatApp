import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore
import Nuke

class ChatListViewController:UIViewController{
    
    //　↓chatList.storyboardのchatListTableViewCellのidentifierに記載する変数
    private let cellId = "cellId"
    private var user:User?{
        didSet{
            navigationItem.title = user?.username
        }
    }
    private var chatRooms = [ChatRoom]()
    @IBOutlet weak var chatListTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpViews()
        fetchLoginUserinfo()
        conformlogindInUser()
        fetchChatRoomInfoForFirebase()
    }
    
    @objc private func tappedNavRightBerButton(){
        let storyboard: UIStoryboard = UIStoryboard.init(name: "UserList", bundle: nil)//遷移先のStoryboardを設定
        let userListViewController = storyboard.instantiateViewController(withIdentifier: "UserListViewController") as! UserListViewController//遷移先のViewControllerを設定
        let nav = UINavigationController(rootViewController: userListViewController)
        self.present(nav, animated: true, completion: nil)
    }

    private func fetchChatRoomInfoForFirebase(){
        //リアルタイムで情報を取得.addSnapshotListener
        Firestore.firestore().collection("ChatRooms").addSnapshotListener{snapshots,err in
            //            .getDocuments{snapshots,err in
            if let err = err{
                print("チャットの情報取得に失敗しました",err)
                return
            }
            snapshots?.documentChanges.forEach({documentChanges in
                switch documentChanges.type{
                //ChatRoomに追加された時だけ走る
                case .added:
                    self.handleAddedDocumentChange(documentChanges: documentChanges)
                case .modified, .removed: break
                        
                        
                }
            })
        }
    }
    
    private func handleAddedDocumentChange(documentChanges:DocumentChange){
        let dic = documentChanges.document.data()
        let chatRoom = ChatRoom(dic: dic)
        chatRoom.documentId = documentChanges.document.documentID
        guard let uid = Auth.auth().currentUser?.uid else{return}
        guard let isContain = chatRoom.members?.contains(uid) else {return}
        
        if !isContain{return}
        
        chatRoom.members?.forEach({memberUid in
            if memberUid != uid{
                Firestore.firestore().collection("users").document(memberUid).getDocument{snapshot,err in
                    if let err = err{
                        print("ユーザー情報の取得に失敗しました",err)
                        return
                    }
                    guard let dic = snapshot?.data() else {return}
                    let user = User(dic: dic)
                    user.uid = snapshot?.documentID
                    chatRoom.partnerUser = user
                    
                    self.chatRooms.append(chatRoom)
                    self.chatListTableView.reloadData()
                }
            }
        })
    }
    private func fetchLoginUserinfo(){
        guard let uid = Auth.auth().currentUser?.uid else {return}
        
        Firestore.firestore().collection("users").document(uid).getDocument{(snapshot,err) in
            if let err = err{
                print("ユーザー情報の取得に失敗しました：",err)
                return
            }
            //            snapshotのnilチェック
            guard let snapshot = snapshot ,let dic = snapshot.data()else {return}
            let user = User(dic: dic)
            self.user = user
            
        }
    }
    private func conformlogindInUser(){
        //端末情報にログイン履歴が残っていなければ
        if Auth.auth().currentUser?.uid == nil{
            //最初にSignUpの画面を表示
            let storyboad = UIStoryboard(name: "SignUp", bundle: nil)
            let signUpViewController = storyboad.instantiateViewController(identifier: "SignUpViewController") as! SignUpViewController
            signUpViewController.modalPresentationStyle = .fullScreen
            self.present(signUpViewController, animated: true, completion: nil)
        }
    }
    private func setUpViews(){
        chatListTableView.tableFooterView = UIView()
        chatListTableView.delegate = self
        chatListTableView.dataSource = self
        
        //ナビゲーションバーの色指定
        navigationController?.navigationBar.barTintColor = .rgb(red: 39, green: 49, bule: 69)
        //ナビゲーションバーのタイトル指定
        navigationItem.title = "ユーザー名"
        //ナビゲーションバーのタイトル文字の色指定
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        
        let rightBerButton = UIBarButtonItem(title: "新規チャット開始", style: .plain, target: self, action: #selector(tappedNavRightBerButton))
        navigationItem.rightBarButtonItem = rightBerButton
        navigationItem.rightBarButtonItem?.tintColor = .white
    }
}




extension ChatListViewController:UITableViewDelegate,UITableViewDataSource{
    
    //セルの高さを指定
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    //セルの個数を指定するデリゲートメソッド(必須)
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatRooms.count
    }
    
    //セルに値を設定するデータソースメソッド(必須)
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // セルを取得する
        let cell = chatListTableView.dequeueReusableCell(withIdentifier: cellId, for:indexPath) as! ChatListTableViewCell
        cell.chatRoom = chatRooms[indexPath.row]
        
        
        return cell
    }
    //セルをクリックした時に反応するメソッド
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard.init(name: "ChatRoom", bundle: nil)
        let chatRoomViewController = storyboard.instantiateViewController(identifier: "ChatRoomViewController") as! ChatRoomViewController
        chatRoomViewController.user = user
        chatRoomViewController.chatRoom = chatRooms[indexPath.row]
        navigationController?.pushViewController(chatRoomViewController, animated: true)
    }
}

class ChatListTableViewCell: UITableViewCell {
    var user:User?{
        didSet{
            partonerLabel.text = user?.username
            
        }
    }
    var chatRoom:ChatRoom?{
        didSet{
            if let chatRoom = chatRoom{
                partonerLabel.text = chatRoom.partnerUser?.username
                let url = URL(string: chatRoom.partnerUser?.profileImageUrl ?? "")
                Nuke.loadImage(with: url, into: userImageView)
                dateLabel.text = dateFormatterForDateLabel(date: chatRoom.createdId.dateValue())
                
            }
        }
    }
    
    
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var latestMessageLabel: UILabel!
    @IBOutlet weak var partonerLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        //imageViewの角を丸くする　imageの横幅の半分にすると丸になる
        userImageView.layer.cornerRadius = 30
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    private func dateFormatterForDateLabel(date:Date) -> String{
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "ja_JA")
        return formatter.string(from: date)
    }
}
