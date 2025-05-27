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
        let value = defaults?.integer(forKey: counterKey) ?? 0
        print("[SharedUserDefaults] getCounter called, return value: \(value)")
        return value
    }
    
    // 设置计数器值
    func setCounter(_ value: Int) {
        print("[SharedUserDefaults] setCounter called, set value: \(value)")
        defaults?.set(value, forKey: counterKey)
    }
    
    // 递增计数器
    func incrementCounter() {
        let currentValue = getCounter()
        let newValue = currentValue + 1
        print("[SharedUserDefaults] incrementCounter called, current: \(currentValue), new: \(newValue)")
        setCounter(newValue)
    }
    
    // 递减计数器
    func decrementCounter() {
        let currentValue = getCounter()
        let newValue = currentValue - 1
        print("[SharedUserDefaults] decrementCounter called, current: \(currentValue), new: \(newValue)")
        setCounter(newValue)
    }
    
    // 重置计数器
    func resetCounter() {
        print("[SharedUserDefaults] resetCounter called")
        setCounter(0)
    }
}
