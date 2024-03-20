//
//  ZKLog.swift
//  ZKLog
//
//  Created by 刘子康 on 2024/1/2.
//

import Foundation
import UIKit

public class ZKLog: NSObject {
    
    @objc public class
    func startRecord() -> Void {
        if !Thread.isMainThread {
            DispatchQueue.main.async {
                ZKLog.startRecord()
            }
            return
        }
        if kVar.isInited { return }
        showLogsBtn()
        kVar.isInited = true
    }
    
    private class
    func showLogsBtn() -> Void {
        let rootWindow: UIWindow = (UIApplication.shared.delegate?.window)!!
        let iphoneScreen: CGRect = UIScreen.main.bounds
        
        let logsBtn: UIButton = ZKLogShowBtn()
        logsBtn.addAction { btn in
            kVar.logsWindow?.isHidden = false
        }
        
        let logsBtnWindow: UIWindow = {
            let window: UIWindow = createWindow(frame: CGRect(x: iphoneScreen.width-logsBtn.frame.width, y: iphoneScreen.height-logsBtn.frame.height, width: logsBtn.frame.width, height: logsBtn.frame.height), addView: logsBtn);
            window.windowLevel = .alert - 2
            window.makeKeyAndVisible()
            return window
        }()
        kVar.logsBtnWindow = logsBtnWindow
        rootWindow.makeKey()
        
        let view: ZKLogView = ZKLogView()
        let logWindow: UIWindow = {
            let window: UIWindow = createWindow(frame: CGRect(x: 0, y: iphoneScreen.height-view.frame.height, width: view.frame.width, height: view.frame.height), addView: view);
            window.windowLevel = .alert - 1
            window.makeKeyAndVisible()
            return window
        }()
        kVar.logsWindow = logWindow
        kVar.logView = view
        rootWindow.makeKey()
        logWindow.isHidden = true
        // 捕捉输出日志
        redirectStandardOutput()
        view.logDismissHandler = {
            recoverStandardOutput()
        }
    }
    
    private class
    func createWindow(frame: CGRect, addView view: UIView) -> UIWindow {
        let window: UIWindow = UIWindow(frame: frame);
        window.rootViewController = {
            let vc: UIViewController = UIViewController()
            vc.view.addSubview(view)
            return vc
        }()
        return window
    }
    
    //MARK: -
    private class
    func redirectStandardOutput() -> Void {
        kVar.outFd = dup(STDOUT_FILENO);
        kVar.errFd = dup(STDERR_FILENO);
        
        //stderr._flags = 10;
        let errPipe: Pipe = Pipe();
        let pipeErrHandle: FileHandle = errPipe.fileHandleForReading;
        dup2(errPipe.fileHandleForWriting.fileDescriptor, STDERR_FILENO);
        pipeErrHandle.readInBackgroundAndNotify();
        
        NotificationCenter.default.addObserver(forName: FileHandle.readCompletionNotification, object: pipeErrHandle, queue: OperationQueue.main) { note in
            let data: Data = note.userInfo![NSFileHandleNotificationDataItem] as! Data
            let str: String = String(data: data, encoding: .utf8)!
            // YOUR CODE HERE... 保存日志并上传或展示
            print(str);
            kVar.logView?.addLog(log: {
                return ZKLogModel.log(message: str)
            }())
            (note.object as AnyObject).readInBackgroundAndNotify();
        }
    }
    
    private class
    func recoverStandardOutput() -> Void {
        dup2(kVar.outFd, STDOUT_FILENO);
        dup2(kVar.errFd, STDERR_FILENO);
        NotificationCenter.default.removeObserver(self);
    }
}
