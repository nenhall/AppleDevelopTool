//
//  CocoaSecurity.swift
//  AppleDevelopTool
//
//  Created by nenhall on 2020/6/15.
//  Copyright © 2020 nenhall. All rights reserved.
//

import Cocoa


public let Sign_InfoPlistEntries = "41"
public let Sign_TeamIdentifier = "YZC2***ZDX"
public let Sign_Identifier = "com.xxxxxx.app"
public let Sign_Authority = "Apple Worldwide Developer Relations Certification Authority"

enum MachOFormat {
    case appBundleMachO
    case normalMachO
}

public struct SignInfo {
    var size: String?
    var sealedResourcesVersion: String?
    var identifier: String?
    var format: MachOFormat = .normalMachO
    var internalRequirementsCount: String?
    var teamIdentifier: String?
    var timestamp: String?

    /**
     @authority7:
     官网下载的：Apple Root CA
     AppStore下载的：Apple Root CA
     */
    var authority7: String?
    
    /**
     @authority6:
     官网下载的：Developer ID Certification Authority
     AppStore下载的：Apple Worldwide Developer Relations Certification Authority
     */
    var authority6: String?
    
    /**
     @authority:
     官网下载的：Developer ID Application: Wondershare Software Co., Ltd (YZC2T44ZDX)
     AppStore下载的：Apple Mac OS Application Signing
     */
    var authority: String?
    var executable: String?
    var codeDirectoryV: String?
    var infoPlistEntries: String?
    var orgDict: [String : Any]?
    
    public init(dict: [String : Any]) {
        size = changed(obj: dict["Signature size"] ?? -1)
        sealedResourcesVersion = changed(obj: dict["Sealed Resources version"] ?? "")
        identifier = changed(obj: dict["Identifier"] ?? "")
        let _format: String = changed(obj: dict["Format"] ?? "")
        if _format.contains("app bundle with Mach-O thin") {
            format = .appBundleMachO
        } else {
            format = .normalMachO
        }
        internalRequirementsCount = changed(obj: dict["Internal requirements count"] ?? "")
        teamIdentifier = changed(obj: dict["TeamIdentifier"] ?? "")
        authority7 = changed(obj: dict["Authority7"] ?? "")
        timestamp = changed(obj: dict["Timestamp"] ?? "")
        authority6 = changed(obj: dict["Authority6"] ?? "")
        authority = changed(obj: dict["Authority"] ?? "")
        executable = changed(obj: dict["Executable"] ?? "")
        codeDirectoryV = changed(obj: dict["CodeDirectory v"] ?? "")
        infoPlistEntries = changed(obj: dict["Info.plist entries"] ?? -1)
        orgDict = dict
    }
    
    private func changed(obj: Any) -> String {
        var value: String = ""
        switch obj {
        case let someInt as Int:
            value = String(someInt)
        case let someInt as Double:
            value = String(someInt)
        case let someString as String:
            value = someString
        default:
            return value
        }
        return value
    }
}


/// 验证签名类
class CocoaSign: NSObject {
    
    /// 验证签名
    /// - Parameter path: app路径
    /// - Returns: 签名信息
    static func command(path: String) -> SignInfo? {
        let certTask = Process()
        certTask.launchPath = "/usr/bin/codesign"
        certTask.arguments = ["-vv","-d",path]
        
        let pipe = Pipe()
        certTask.standardOutput = pipe
        certTask.standardError = pipe
        
        let handle = pipe.fileHandleForReading
        certTask.launch()
        
        let data = handle.readDataToEndOfFile()
        let _dataString = String(data: data, encoding: .utf8)
        guard let dataString = _dataString else {
            debugPrint("调用签名命令失败！")
            return nil
        }
        
        let dataArr = dataString.components(separatedBy: "\n")
        var dict: [String : String]?

        for (index, element) in dataArr.enumerated() {
            let keyValue = element.components(separatedBy: "=")
            if keyValue.count > 1 {
                if dict == nil {
                    dict = [String : String]()
                }
                let key = keyValue[0]
                let authority = dict?["Authority"]
                if key == "Authority", let _ = authority {
                    dict?.updateValue(keyValue[1], forKey: keyValue[0]+String(index))
                } else {
                    dict?.updateValue(keyValue[1], forKey: keyValue[0])
                }
            }
        }
        guard let _dict = dict else {
            return nil
        }
        let info = SignInfo.init(dict: _dict)
        return info
    }
}


