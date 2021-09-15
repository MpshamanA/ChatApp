//
//  SignUpViewController.swift
//  chatApp
//
//  Created by ShoIwasaki on 2021/08/12.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

class SignUpViewController:UIViewController{
    
    @IBOutlet weak var profileImageButton: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var alreadyHaveAcountButton: UIButton!
    @IBAction func emailTextFieldAction(_ sender: UITextField) {
        emailTextField.text = sender.text
    }
    @IBAction func passwordTextFieldAction(_ sender: UITextField) {
        passwordTextField.text = sender.text
    }
    @IBAction func usernameTextFieldAction(_ sender: UITextField) {
        userNameTextField.text = sender.text
    }
    @IBAction func tappedProfileImageButton(_ sender: Any) {
        //写真へのサクセス
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
            
        //trueにすると写真を開いたときに編集できるようになる
        imagePickerController.allowsEditing = true
        
        self.present(imagePickerController, animated: true, completion: nil)
    }
    @IBAction func tappedRegisterButton(_ sender: Any) {
        guard let image = profileImageButton.imageView?.image else {return}
        //そのまま画像を保存すると容量が大きい場合があるため0.3倍する
        guard let uplodeImage = image.jpegData(compressionQuality: 0.3) else{return}
        
        //ファイルの名前を指定
        let fileName = NSUUID().uuidString
        //child内に記載するのがフォルダ名
        let storegeRef = Storage.storage().reference().child("profile_image").child(fileName)
        
        storegeRef.putData(uplodeImage, metadata: nil){(metadate,err) in
            if let err = err{
                print("Firestoregeへの画像の保存に失敗しました：\(err)")
            }
            storegeRef.downloadURL{(url,err) in
                if let err = err{
                    print("FirestoregeからのURLのダウンロードに失敗しました：\(err)")
                    return
                }
                guard let urlString = url?.absoluteString else{return}
                self.createdUserToFirebase(profireImageUrl: urlString)
                
            }
        }
    }
    
    private func createdUserToFirebase(profireImageUrl:String){
        guard let email = emailTextField.text else {return}
        guard let password = passwordTextField.text else {return}
        
        //Authenticationへの登録(認証機能)
        Auth.auth().createUser(withEmail: email, password: password){
            (res,err) in
            if let err = err{
                print("認証失敗:\(err)")
                return
            }
            //認証に成功したらFirestoreへの登録
            guard let uid = res?.user.uid else{return}
            
            guard let username = self.userNameTextField.text else{return}
            let docDate = [
                "email":email,
                "username":username,
                "createdAt":Timestamp(),
                "profileImageUrl":profireImageUrl
            ] as [String : Any]
            
            Firestore.firestore().collection("users").document(uid).setData(docDate){(err) in
                if let err = err{
                    print("Firestoreへの情報の登録に失敗:\(err)")
                    return
                }
                //認証に成功したら認証画面を閉じる
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        profileImageButton.layer.cornerRadius = 85
        profileImageButton.layer.borderWidth = 1
        profileImageButton.layer.borderColor = UIColor.rgb(red: 240, green: 240, bule: 240).cgColor
        registerButton.layer.cornerRadius = 10
        
        emailTextField.delegate = self
        passwordTextField.delegate = self
        userNameTextField.delegate = self
        registerButton.isEnabled = false
        registerButton.backgroundColor = .rgb(red: 100, green: 100, bule: 100)
        
    }
    
}

extension SignUpViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    //    写真を選択した後の処理を記載
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        //写真を編集した場合はeditImageに写真が代入されprofileImageButtonのimageにsetされる
        if let editImage = info[.editedImage] as? UIImage{
            profileImageButton.setImage(editImage.withRenderingMode(.alwaysOriginal), for: .normal)
            //写真がオリジナルの場合はoriginalImageに写真が代入されprofileImageButtonのimageにsetされる
        }else if let originalImage = info[.originalImage] as? UIImage{
            profileImageButton.setImage(originalImage.withRenderingMode(.alwaysOriginal), for: .normal)
        }
        
        profileImageButton.setTitle("", for: .normal)
        /*scaleAspectFit*/
        //ImageViewのサイズ比率そのままで、ImageViewに空白ができないように表示する。
        //ImageViewと画像の比率が違う場合、ImageViewをはみ出す
        //画像の中心とImageViewの中心は同じになる
        profileImageButton.imageView?.contentMode = .scaleAspectFit
        /*contentHorizontalAlignment contentVerticalAlignment*/
        //上記をセットしない場合、 画像はオリジナルのサイズまでしか拡大できない
        profileImageButton.contentHorizontalAlignment = .fill
        profileImageButton.contentVerticalAlignment = .fill
        /*clipsToBounds*/
        //Viewにセットしたコンテンツが、領域boundsの外を描画するかどうかを決定する
        profileImageButton.clipsToBounds = true
        //写真の編集画面を閉じる
        dismiss(animated: true, completion: nil)
    }
}

extension SignUpViewController: UITextFieldDelegate{
        //指定されたテキストフィールドでテキスト選択が変更されたときにデリゲートに通知するメソッド
    func textFieldDidChangeSelection(_ textField: UITextField) {
        //それぞれ、TextFieldがisEmptyだったらfalseを代入する
        let emailIsEmpty = emailTextField.text?.isEmpty ?? false
        let passwordEmpty = passwordTextField.text?.isEmpty ?? false
        let usernameEmpty = userNameTextField.text?.isEmpty ?? false
        
        if emailIsEmpty || passwordEmpty || usernameEmpty{
            registerButton.isEnabled = false
            registerButton.backgroundColor = .rgb(red: 100, green: 100, bule: 100)
        }else{
            registerButton.isEnabled = true
            registerButton.backgroundColor = .rgb(red: 0, green: 185, bule: 0)
        }
    }
    
}
