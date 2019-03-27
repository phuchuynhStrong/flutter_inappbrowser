//
//  RNURLCache.swift
//  hasBrain
//
//  Created by Chuong Huynh on 6/19/18.
//  Copyright © 2018 Facebook. All rights reserved.
//

import Foundation
import WebKit

let maximumParallelCache = 5
let MAXIMUM_OLD_CACHE = 60 * 60 * 24 * 15 // 15 days to clear

@objc(SwiftURLCache)
class SwiftURLCache: NSObject {
    public static let shared = SwiftURLCache()
    private var notCached = [String]()
    let cachedQueue = DispatchQueue(label: "com.hasbrain.urlcache")
    var currentCaching = 0
    let urlCached = URLCache(memoryCapacity: Int(2e+7), diskCapacity: Int(2e+8), diskPath: nil)
    let urlSession = URLSession(configuration: URLSessionConfiguration.default)
    var cacheFolderPath: URL? = nil
    var cacheManager = NSCache<NSString, NSString>()
    let fileManager = FileManager.default
    
    private override init() {
        super.init()
        cacheManager.name = "com.hasbrain.webcache"
        cacheManager.totalCostLimit = Int(1e+8)
        deleteOldFiles()
    }
    
    private func deleteOldFiles() {
        DispatchQueue.global().async {
            let currentDate = Date()
            do {
                if let documentPath = self.getCacheFolderPath() {
                    let fileNames = try self.fileManager.contentsOfDirectory(at: documentPath, includingPropertiesForKeys: [URLResourceKey.contentAccessDateKey], options: FileManager.DirectoryEnumerationOptions.skipsHiddenFiles)
                    for fileName in fileNames {
                        let resourceValue = try? fileName.resourceValues(forKeys: [URLResourceKey.contentAccessDateKey])
                        if let accessDate = resourceValue?.contentAccessDate{
                            if currentDate.timeIntervalSince(accessDate) > Double(MAXIMUM_OLD_CACHE) {
                                try self.fileManager.removeItem(at: fileName)
                            }
                        }
                    }
                }
                
            } catch {
                print("Could not clear temp folder: \(error)")
            }
        }
    }
    
    public func cache(URL urlStr: String) {
        guard let url = URL(string: urlStr) else {return}
        
        let request = URLRequest(url: url, cachePolicy: URLRequest.CachePolicy.returnCacheDataElseLoad)
        cachedQueue.async {
            
            if let _ = URLCache.shared.cachedResponse(for: request) {
                print("Already cached \(urlStr)")
                return
            }
            if (self.currentCaching >= maximumParallelCache) {
                self.notCached.append(urlStr)
                return
            }
            self.currentCaching += 1
            let task = self.urlSession.dataTask(with: request, completionHandler: { (data, response, error) in
                print("Done cached \(urlStr)")
                if let _ = data, let _ = response {
                    self.urlCached.storeCachedResponse(CachedURLResponse(response: response!, data: data!) , for: request)
                    self.cachedQueue.async {
                        self.currentCaching -= 1
                        if let _ = self.notCached.first {
                            let lastUrl = self.notCached.removeFirst()
                            self.cache(URL: lastUrl)
                        }
                    }
                }
            })
            task.resume()
        }
    }
    
    
    // MARK: - File management
    
    /// Get cache folder path
    ///
    /// - Returns: folder path that already created
    private func getCacheFolderPath() -> URL? {
        if let _ = cacheFolderPath {
            return cacheFolderPath
        }
        
        guard let documentPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        
        var isDir : ObjCBool = false
        let dirPath = documentPath.appendingPathComponent("cacheWebview")
        if fileManager.fileExists(atPath: dirPath.absoluteString , isDirectory:&isDir) {
            if isDir.boolValue {
                cacheFolderPath = dirPath
                return dirPath
            }
        }
        do {
            try fileManager.createDirectory(at: dirPath, withIntermediateDirectories: true, attributes: nil)
        } catch{
            return nil
        }
        
        cacheFolderPath = dirPath
        return dirPath
    }
    
    /// Get HTML with uuid
    ///
    /// - Parameter uuid: uuid of html
    /// - Returns: HTML content
    private func getHTML(_ uuid: String) -> String? {
        
        if let cachedHTML = cacheManager.object(forKey: uuid as NSString) {
            return cachedHTML as String
        }
        var html: String? = nil
        guard let documentPath = getCacheFolderPath() else { return nil }
        let fileURL = documentPath.appendingPathComponent(uuid)
        html = try? String(contentsOf: fileURL, encoding: .utf8)
        if html != nil {
            cacheManager.setObject(html! as NSString, forKey: uuid as NSString)
        }
        return html
    }
    
    /// Store HTML to file
    ///
    /// - Parameters:
    ///   - html: html string
    ///   - filename: filename to store
    private func storeHTML(html: String, forUuid filename: String) {
        if let documentPath = getCacheFolderPath() {
            let fileURL = documentPath.appendingPathComponent(filename)
            try? html.write(to: fileURL, atomically: true, encoding: .utf8)
            cacheManager.setObject(html as NSString, forKey: filename as NSString, cost: html.utf8.count)
        }
    }
    
    
    
    /// Cache HTML content to disk
    ///
    /// - Parameters:
    ///   - html: html string
    ///   - url: base url of html
    ///   - customKey: key to store
    public func cache(html: String, url: URL, customKey: String) {
        var dict: [String: Any] = UserDefaults.standard.dictionary(forKey: customKey) ?? [:]
        let uuid: String = (dict[url.absoluteString] as? String) ?? UUID().uuidString
        dict.updateValue(uuid, forKey: url.absoluteString)
        UserDefaults.standard.setValue(dict, forKey: customKey)
        UserDefaults.standard.synchronize()
        self.storeHTML(html: html, forUuid: uuid)
    }
    
    /// Get HTML content
    ///
    /// - Parameters:
    ///   - url: base url
    ///   - customKey: key to store
    /// - Returns: cached HTML content
    public func getHTML(url: URL, customKey: String) -> String? {
        if let dict = UserDefaults.standard.dictionary(forKey: customKey) {
            if let uuid = dict[url.absoluteString] as? String {
                return getHTML(uuid)
            }
        }
        return nil
    }
}
