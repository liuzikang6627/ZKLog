//
//  ZKViews.swift
//  ZKLog
//
//  Created by 刘子康 on 2024/1/2.
//

import Foundation
import UIKit

class ZKLogView: UIView {
    public var logView: UITextView?
    private let logNormalColor: UIColor = .white
    private let logHighLightColor: UIColor = .yellow
    private var logs: Array<ZKLogModel> = Array<ZKLogModel>()
    private let logMaxCount: Int = 10000
    
    public var logDismissHandler: ZKCompleteHandler?
    
    convenience init() {
        let iphoneScreen: CGRect = UIScreen.main.bounds
        let viewSize: CGSize = CGSizeMake(iphoneScreen.width, 280)
        self.init(frame: CGRectMake(0, 0, viewSize.width, viewSize.height))
        self.backgroundColor = .clear
        
        let bg: UIView = UIView(frame: self.frame)
        bg.backgroundColor = .black
        bg.alpha = 0.5
        self.addSubview(bg)
        // 隐藏按钮
        let hideBtn: UIButton = ZKLogShowBtn()
        hideBtn.frame = {
            return CGRectMake(self.frame.width-hideBtn.frame.width, self.frame.height-hideBtn.frame.height,
                              hideBtn.frame.width, hideBtn.frame.height)
        }()
        hideBtn.backgroundColor = .green
        self.addSubview(hideBtn)
        hideBtn.addAction { btn in
            self.window?.isHidden = true
            //self.removeFromSuperview()
        }
        // 清理按钮
        let clearBtn: UIButton = ZKLogClearBtn()
        clearBtn.frame = {
            return CGRectMake(hideBtn.frame.minX-clearBtn.frame.width, hideBtn.frame.maxY-clearBtn.frame.height,
                              clearBtn.frame.width, clearBtn.frame.height)
        }()
        self.addSubview(clearBtn)
        clearBtn.addAction { btn in
            self.logs.removeAll()
            self.refreshLogView()
        }
        // 日志框
        let logView: UITextView = UITextView()
        logView.backgroundColor = .clear
        logView.isEditable = false
        logView.frame = {
            return CGRectMake(0, 0, viewSize.width, viewSize.height-hideBtn.frame.height)
        }()
        self.addSubview(logView)
        self.logView = logView
    }
    
    deinit {
        self.logDismissHandler?()
    }
    
    public
    func addLog(log: ZKLogModel) -> Void {
        self.logs.append(log)
        if self.logs.count > self.logMaxCount {
            self.logs.remove(at: 0)
        }
        refreshLogView()
    }
    
    private
    func refreshLogView() -> Void {
        var hasChanged: Bool = false
        let lastLogs: String = self.logView?.attributedText.string ?? ""
        
        self.logView?.text = ""
        let currentTimestamp: TimeInterval = Date().timeIntervalSince1970
        let attrString: NSMutableAttributedString = NSMutableAttributedString()
        for log in self.logs {
            let message: String = "\(log.message ?? "")"
            let messageColor: UIColor = ((currentTimestamp-(Double(log.timestamp) ?? 0))>0.1) ? self.logNormalColor : self.logHighLightColor
            let logString: NSMutableAttributedString = NSMutableAttributedString(string: message)
            logString.addAttribute(NSAttributedString.Key.foregroundColor,
                                   value: messageColor, range: NSMakeRange(0, logString.length))
            attrString.append(logString)
        }
        if attrString.string != lastLogs {
            hasChanged = true
        }
        // 发生变化后刷新
        if hasChanged {
            self.logView?.attributedText = attrString
            // 自动滚到底部
            if attrString.length > 0 {
                self.logView?.scrollRangeToVisible({
                    return NSMakeRange(attrString.length-1, 1)
                }())
            }
        }
    }
    
}



class ZKLogShowBtn: UIButton {
    convenience init() {
        self.init(type: .custom)
        self.frame = CGRectMake(0, 0, 100, 40)
        self.setTitle("vConsole", for: .normal)
        self.setTitleColor(.white, for: .normal)
        self.backgroundColor = .lightGray
        //self.layer.cornerRadius = 8.0
    }
}


class ZKLogClearBtn: UIButton {
    convenience init() {
        self.init(type: .custom)
        self.frame = CGRectMake(0, 0, 50, 30)
        self.setTitle("clear", for: .normal)
        self.setTitleColor(.white, for: .normal)
        self.backgroundColor = .lightGray
        //self.layer.cornerRadius = 8.0
    }
}



//MARK: -
typealias BtnAction = (UIButton)->()
extension UIButton {
    private
    struct AssociatedKeys{
        static var actionKey = "actionKey"
    }
    
    @objc dynamic
    var action: BtnAction? {
        set {
            objc_setAssociatedObject(self,&AssociatedKeys.actionKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY)
        }
        get {
            if let action = objc_getAssociatedObject(self, &AssociatedKeys.actionKey) as? BtnAction{
                return action
            }
            return nil
        }
    }
    
    func addAction(action: @escaping BtnAction) {
        self.action = action
        self.addTarget(self, action: #selector(touchUpInSideBtnAction), for: .touchUpInside)
    }

    @objc
    func touchUpInSideBtnAction(btn: UIButton) {
         if let action = self.action {
             action(btn)
         }
    }
}
