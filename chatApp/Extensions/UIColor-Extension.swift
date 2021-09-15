//
//  UIColor-Extension.swift
//  chatApp
//
//  Created by ShoIwasaki on 2021/08/01.
//

import UIKit
//色をRGBで指定できるよう作成
extension UIColor {
    static func rgb(red:CGFloat, green:CGFloat, bule:CGFloat) -> UIColor{
        return self.init(red: red/255, green: green/255, blue: bule/255, alpha: 1)
    }
}
