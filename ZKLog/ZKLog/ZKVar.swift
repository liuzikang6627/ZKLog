//
//  ZKVar.swift
//  ZKLog
//
//  Created by 刘子康 on 2024/1/2.
//

import Foundation
import UIKit

typealias ZKCompleteHandler = ()->()

class ZKVar: NSObject {
    public var logsWindow: UIWindow?
    public var logsBtnWindow: UIWindow?
    public var logView: ZKLogView?
    
    public var isInited: Bool = false
    
    public var outFd: Int32 = 0
    public var errFd: Int32 = 0
    
    // swift单例
    static let shared = ZKVar()
    private override
    init() {
        
    }
}
let kVar = ZKVar.shared

