import Foundation

class SharedUserDefaults {
    static let shared = SharedUserDefaults()
    
    // 使用正确的 App Group ID
    static let appGroupID = "group.com.sunyuan.counter"
    
    private let defaults: UserDefaults?
    
    private init() {
        self.defaults = UserDefaults(suiteName: Self.appGroupID)
    }
    
    // 计数器值的键
    private let counterKey = "counter"
    
    // 获取计数器值
    func getCounter() -> Int {
        return defaults?.integer(forKey: counterKey) ?? 0
    }
    
    // 设置计数器值
    func setCounter(_ value: Int) {
        defaults?.set(value, forKey: counterKey)
    }
    
    // 递增计数器
    func incrementCounter() {
        let currentValue = getCounter()
        setCounter(currentValue + 1)
    }
    
    // 递减计数器
    func decrementCounter() {
        let currentValue = getCounter()
        setCounter(currentValue - 1)
    }
    
    // 重置计数器
    func resetCounter() {
        setCounter(0)
    }
}
