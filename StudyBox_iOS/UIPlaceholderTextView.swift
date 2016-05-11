//
//  UIPlaceholderTextView.swift
//  StudyBox_iOS
//
//  Created by Damian Malarczyk on 05.05.2016.
//  Copyright © 2016 BLStream. All rights reserved.
//

import UIKit

class UIPlaceholderTextView: UITextView {
    
    var placeholderLabel: UILabel!
    var placeholder: String?
    
    var placeholderColor = UIColor.sb_DarkGrey()
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        addTextChangeObserver()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        addTextChangeObserver()
    }
    
    private func addTextChangeObserver() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(textChanged), name: UITextViewTextDidChangeNotification, object: self)
    }
  
    func textChanged() {
        guard let _ = placeholder, placeholderLabel = placeholderLabel else {
            return
        }
        
        if text.isEmpty {
            placeholderLabel.alpha = 1
        } else {
            placeholderLabel.alpha = 0
        }
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override var text: String! {
        didSet {
            textChanged()
        }
    }

    override func drawRect(rect: CGRect) {
        if let placeholder = placeholder where !placeholder.isEmpty {
            if placeholderLabel == nil {
                placeholderLabel = UILabel(frame: CGRect(x: 4, y: 8, width: bounds.size.width - 8, height: 0))
                placeholderLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping
                placeholderLabel.numberOfLines = 0
                placeholderLabel.font = UIFont.sbFont(bold: false)
                placeholderLabel.backgroundColor = backgroundColor ?? UIColor.clearColor()
                placeholderLabel.textColor = placeholderColor
                placeholderLabel.alpha = 0
                addSubview(placeholderLabel)
            }
            placeholderLabel.text = placeholder
            placeholderLabel.sizeToFit()
            sendSubviewToBack(placeholderLabel)
        }
        
        if text.isEmpty {
            placeholderLabel.alpha = 1
        }
        super.drawRect(rect)
    }
}
