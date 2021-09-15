//
//  chatInputAccessoryView.swift
//  chatApp
//
//  Created by ShoIwasaki on 2021/08/04.
//

import UIKit

//循環参照を防ぐためにclass(AnyObject?)を継承？する
protocol ChatInputAccessoryViewDelegate:AnyObject{
    func tappedSendButton(text:String)
}

class ChatInputAccessoryView: UIView{
    
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var chatTextView: UITextView!
    @IBAction func tappedSendButton(_ sender: Any) {
        guard let text = chatTextView.text else {return}
        delegate?.tappedSendButton(text: text)
    }
    weak var delegate: ChatInputAccessoryViewDelegate?
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        nivInit()
        setUpView()
        autoresizingMask = .flexibleHeight
        
    }
    
    private func setUpView(){
        chatTextView.layer.cornerRadius = 15
        chatTextView.layer.borderColor = UIColor.rgb(red: 230, green: 230, bule: 230).cgColor
        chatTextView.layer.borderWidth = 1
        chatTextView.text = ""
        chatTextView.delegate = self
        
        sendButton.layer.cornerRadius = 15
        sendButton.imageView?.contentMode = .scaleAspectFill
        sendButton.contentHorizontalAlignment = .fill
        sendButton.contentVerticalAlignment = .fill
        sendButton.isEnabled = false
    }
    
    override var intrinsicContentSize: CGSize {
        return .zero
    }
    
    private func nivInit(){
        //UINibはロードする際に使う
        let nib = UINib(nibName: "ChatInputAccessoryView", bundle: nil)
        guard let view = nib.instantiate(withOwner: self, options: nil).first as? UIView else{return}
        
        view.frame = self.bounds
        view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        self.addSubview(view)
        
    }
    
    func removeText() {
        chatTextView.text = ""
        sendButton.isEnabled = false
    }
        
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//テキストに今何が入ってるか監視してるメソッド
extension ChatInputAccessoryView: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        
        //テキストが空だったらボタンを無効,違ったら有効
        if textView.text.isEmpty{
            sendButton.isEnabled = false
        }else{
            sendButton.isEnabled = true
        }
    }
}
