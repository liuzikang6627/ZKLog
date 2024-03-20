//
//  ZKModels.swift
//  ZKLog
//
//  Created by 刘子康 on 2024/1/2.
//

import Foundation

class ZKLogModel: NSObject {
    public let timestamp: String = "\(round(Date().timeIntervalSince1970))"
    public var message: String?
    
    public class
    func log(message: String) -> ZKLogModel {
        let log: ZKLogModel = ZKLogModel()
        log.message = message
        return log
    }
}
