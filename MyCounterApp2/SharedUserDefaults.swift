//
//  SharedUserDefaults.swift
//  MyCounterApp2
//
//  Created by sunyuan on 2025/5/25.
//

import Foundation

class SharedUserDefaults {
    static let shared = SharedUserDefaults()
    private let userDefaults: UserDefaults
    
    private init() {
        guard let userDefaults = UserDefaults(suiteName: "group.com.sunyuan.MyCounterApp2") else {
            fatalError("无法创建共享UserDefaults")
        }
        self.userDefaults = userDefaults
    }
    
    private enum Keys {
        static let counter = "counter"
    }
    
    var counter: Int {
        get {
            userDefaults.integer(forKey: Keys.counter)
        }
        set {
            userDefaults.set(newValue, forKey: Keys.counter)
        }
    }
}
