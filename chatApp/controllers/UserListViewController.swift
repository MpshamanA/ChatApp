//
//  UserListViewController.swift
//  chatApp
//
//  Created by ShoIwasaki on 2021/08/19.
//

import UIKit
import Firebase

class UserListViewController: UIViewController{
    
    private let cellId = "cellId"
    private var users = [User]()
    private var selectedUser:User?
    
    @IBOutlet weak var userListTableView: UITableView!
    @IBOutlet weak var startChatButton: UIButton!
    @IBAction func tappedStartChatButton(_ sender: Any) {
        guard let uid = Auth.auth().currentUser?.uid else {return}
        guard let selectdUid = self.selectedUser?.uid else {return}
        let members = [uid,selectdUid]
        let docData = [
            "members":members,
            "latestMessageId":"",
            "createdId":Timestamp()
        ] as [String : Any]
        
        Firestore.firestore().collection("ChatRooms").addDocument(data: docData) { err in
            if let err = err{
                print("ユーザー情報の取得に失敗しました。",err)
                return
            }
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userListTableView.tableFooterView = UIView()
        userListTableView.delegate = self
        userListTableView.dataSource = self
        startChatButton.layer.cornerRadius = 12
       
        //ナビゲーションバーの色指定
        navigationController?.navigationBar.barTintColor = .rgb(red: 39, green: 49, bule: 69)
        //ナビゲーションバーのタイトル指定
        navigationItem.title = "フレンド"
        //ナビゲーションバーのタイトル文字の色指定
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        
        startChatButton.isEnabled = false
        
        fetchUserInfoFromFirebase()
        //新しいセルをつくることをテーブルビューに伝えます。指定されたタイプのセルが現在再利用キューにない場合、テーブルビューは提供された情報を使用して新しいセルオブジェクトを自動的に作成します。
        //        userListTableView.register(UITableViewCell.self, forCellReuseIdentifier: cellId)
        
        
    }
    private func fetchUserInfoFromFirebase(){
        Firestore.firestore().collection("users").getDocuments{(snapShots,err) in
            if let err = err{
                print("ユーザー情報の取得に失敗しました：\(err)")
                return
            }
            snapShots?.documents.forEach({(snapShot) in
                let dic = snapShot.data()
                let user = User.init(dic: dic)
                user.uid = snapShot.documentID
                
                guard let uid = Auth.auth().currentUser?.uid else{return}
                if uid == snapShot.documentID{
                    return
                }
                
                self.users.append(user)
                self.userListTableView.reloadData()
            })
        }
    }
}
extension UserListViewController:UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = userListTableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! UserTableViewCell
        cell.user = users[indexPath.row]
        return cell
    }
    //どのセルが選択されてるか判断するメソッド
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = users[indexPath.row]
        self.selectedUser = user
        startChatButton.isEnabled = true
    }
    
}
