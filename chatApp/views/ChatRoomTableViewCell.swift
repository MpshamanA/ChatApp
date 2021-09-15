//
//  chatRoomTableViewCell.swift
//  chatApp
//
//  Created by ShoIwasaki on 2021/08/03.
//

import UIKit
import Firebase
import Nuke

class ChatRoomTableViewCell: UITableViewCell{
    
    //プロパティの監視
    var message: Message?{
        didSet{
//            if let message = message{
//                partnerMessageTextView.text = message.message
//                let width = estimateFrameForTextView(text: message.message).width
//                messageTextViewWidthConstraint.constant = width + 20
//                partnerDateLabel.text = dateFormatterForDateLabel(date: message.createdAd.dateValue())
//            }
        }
    }
    
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var partnerMessageTextView: UITextView!
    @IBOutlet weak var myMessageTextView: UITextView!
    @IBOutlet weak var partnerDateLabel: UILabel!
    @IBOutlet weak var myDateLabel: UILabel!
    @IBOutlet weak var messageTextViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var myMessageTextViewWidthConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        userImageView.layer.cornerRadius = 30
        partnerMessageTextView.layer.cornerRadius = 15
        myMessageTextView.layer.cornerRadius = 15
        //背景を透明に
        backgroundColor = .clear
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        checkWhichMessage()
    }
    
    private func checkWhichMessage(){
        guard  let uid = Auth.auth().currentUser?.uid else {return}
        
        //自分のuidだったら
        if uid == message?.uid{
            partnerMessageTextView.isHidden = true
            partnerDateLabel.isHidden = true
            userImageView.isHidden = true
            
            myMessageTextView.isHidden = false
            myDateLabel.isHidden = false
            
            if let message = message{
                myMessageTextView.text = message.message
                let width = estimateFrameForTextView(text: message.message).width
                myMessageTextViewWidthConstraint.constant = width + 20
                myDateLabel.text = dateFormatterForDateLabel(date: message.createdAd.dateValue())
            }
        }else{
            partnerMessageTextView.isHidden = false
            partnerDateLabel.isHidden = false
            userImageView.isHidden = false
            
            myMessageTextView.isHidden = true
            myDateLabel.isHidden = true
            if let urlString = message?.partnerUser?.profileImageUrl,let url = URL(string: urlString){
                Nuke.loadImage(with: url, into: userImageView)
            }
            
            if let message = message{
                partnerMessageTextView.text = message.message
                let width = estimateFrameForTextView(text: message.message).width
                messageTextViewWidthConstraint.constant = width + 20
                partnerDateLabel.text = dateFormatterForDateLabel(date: message.createdAd.dateValue())
            }
        }
    }
    
    private func estimateFrameForTextView(text:String) -> CGRect{
        let size = CGSize(width: 200, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        //文字列の幅を返す
        //ofSizeは実際のtextのサイズを入れる
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize:16)], context: nil)
    }
    private func dateFormatterForDateLabel(date:Date) -> String{
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "ja_JA")
        return formatter.string(from: date)
    }
    
}
