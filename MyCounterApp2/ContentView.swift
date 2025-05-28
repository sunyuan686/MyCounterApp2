//
//  ContentView.swift
//  MyCounterApp2
//
//  Created by sunyuan on 2025/5/25.
//

import SwiftUI
import WidgetKit
import Combine
import AVFoundation

// 创建一个ObservableObject来管理计数器状态和通知
class CounterViewModel: ObservableObject {
    @Published var counter: Int
    @Published var settings: CounterSettings
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // 初始化时从SharedUserDefaults读取计数值和设置
        counter = SharedUserDefaults.shared.getCounter()
        settings = SharedUserDefaults.shared.getSettings()
        print("[CounterViewModel] 初始化，counter=\(counter)，settings=\(settings)")
        
        // 监听应用进入前台通知
        NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)
            .sink { [weak self] _ in
                print("[CounterViewModel] 应用进入前台，刷新数据")
                self?.refreshCounterFromSharedDefaults()
                self?.refreshSettings()
            }
            .store(in: &cancellables)
        
        // 监听应用变为活跃状态通知
        NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)
            .sink { [weak self] _ in
                print("[CounterViewModel] 应用变为活跃状态，刷新数据")
                self?.refreshCounterFromSharedDefaults()
                self?.refreshSettings()
            }
            .store(in: &cancellables)
    }
    
    // 从SharedUserDefaults刷新计数器
    func refreshCounterFromSharedDefaults() {
        let updatedValue = SharedUserDefaults.shared.getCounter()
        print("[CounterViewModel] 从SharedUserDefaults刷新计数器，旧值：\(counter)，新值：\(updatedValue)")
        if counter != updatedValue {
            counter = updatedValue
        }
    }
    
    // 从SharedUserDefaults刷新设置
    func refreshSettings() {
        let updatedSettings = SharedUserDefaults.shared.getSettings()
        print("[CounterViewModel] 从SharedUserDefaults刷新设置")
        settings = updatedSettings
    }
    
    // 递增计数器
    func increment() {
        print("[CounterViewModel] + 按钮点击，当前counter=\(counter)，步长=\(settings.stepValue)")
        
        let newValue = counter + settings.stepValue
        
        // 检查最大值限制
        if let maxValue = settings.maxValue, newValue > maxValue {
            counter = maxValue
            print("[CounterViewModel] 达到最大值限制: \(maxValue)")
        } else {
            counter = newValue
            print("[CounterViewModel] counter递增后=\(counter)")
        }
        
        // 触发反馈
        provideFeedback()
        
        SharedUserDefaults.shared.setCounter(counter)
        // 刷新小组件
        WidgetCenter.shared.reloadTimelines(ofKind: "myWidget")
    }
    
    // 递减计数器
    func decrement() {
        print("[CounterViewModel] - 按钮点击，当前counter=\(counter)，步长=\(settings.stepValue)")
        
        let newValue = counter - settings.stepValue
        
        // 检查最小值限制和负数限制
        if let minValue = settings.minValue, newValue < minValue {
            counter = minValue
            print("[CounterViewModel] 达到最小值限制: \(minValue)")
        } else if !settings.allowNegative && newValue < 0 {
            counter = 0
            print("[CounterViewModel] 不允许负数，设置为0")
        } else {
            counter = newValue
            print("[CounterViewModel] counter递减后=\(counter)")
        }
        
        // 触发反馈
        provideFeedback()
        
        SharedUserDefaults.shared.setCounter(counter)
        // 刷新小组件
        WidgetCenter.shared.reloadTimelines(ofKind: "myWidget")
    }
    
    // 重置计数器
    func reset() {
        print("[CounterViewModel] 重置按钮点击，默认值=\(settings.defaultValue)")
        counter = settings.defaultValue
        print("[CounterViewModel] counter已重置为\(counter)")
        
        // 触发反馈
        provideFeedback()
        
        SharedUserDefaults.shared.resetCounter()
        // 刷新小组件
        WidgetCenter.shared.reloadTimelines(ofKind: "myWidget")
    }
    
    // 提供反馈（振动和声音）
    private func provideFeedback() {
        if settings.hapticEnabled {
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
            print("[CounterViewModel] 触发振动反馈")
        }
        
        if settings.soundEnabled {
            AudioServicesPlaySystemSound(1104) // 标准的iOS点击音效
            print("[CounterViewModel] 触发声音反馈")
        }
    }
}

struct ContentView: View {
    // 使用StateObject确保视图模型在视图的生命周期内保持一致
    @StateObject private var viewModel = CounterViewModel()
    @State private var showingSettings = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Text("计数器")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("\(viewModel.counter)")
                    .font(.system(size: 80, weight: .bold))
                    .foregroundColor(.blue)
                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: viewModel.counter)
                
                HStack(spacing: 20) {
                    Button("-") {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            viewModel.decrement()
                        }
                    }
                    .font(.title)
                    .frame(width: 60, height: 60)
                    .background(Color.red)
                    .foregroundColor(.white)
                    .clipShape(Circle())
                    .scaleEffect(viewModel.counter < 0 ? 1.1 : 1.0)
                    
                    Button("+") {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            viewModel.increment()
                        }
                    }
                    .font(.title)
                    .frame(width: 60, height: 60)
                    .background(Color.green)
                    .foregroundColor(.white)
                    .clipShape(Circle())
                    .scaleEffect(viewModel.counter > 0 ? 1.1 : 1.0)
                }
                
                Button("重置") {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        viewModel.reset()
                    }
                }
                .font(.headline)
                .padding(.horizontal, 30)
                .padding(.vertical, 12)
                .background(Color.gray)
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                
                // 当前步长信息
                Text("当前步长: \(viewModel.settings.stepValue)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.top, 10)
                
                // 最大值/最小值信息（如果设置）
                Group {
                    if let maxValue = viewModel.settings.maxValue {
                        Text("最大值: \(maxValue)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    if let minValue = viewModel.settings.minValue {
                        Text("最小值: \(minValue)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding()
            .onAppear {
                print("[ContentView] onAppear，刷新数据")
                viewModel.refreshCounterFromSharedDefaults()
                viewModel.refreshSettings()
            }
            .navigationBarTitle("我的计数器", displayMode: .inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        print("[ContentView] 设置按钮点击")
                        showingSettings = true
                    }) {
                        Image(systemName: "gear")
                    }
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("刷新") {
                        print("[ContentView] 手动刷新按钮点击")
                        viewModel.refreshCounterFromSharedDefaults()
                        viewModel.refreshSettings()
                    }
                }
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
                    .onDisappear {
                        // 设置页面关闭后刷新设置和计数器
                        print("[ContentView] 设置页面关闭，刷新设置和计数器")
                        viewModel.refreshSettings()
                        viewModel.refreshCounterFromSharedDefaults()
                    }
            }
        }
    }
}

#Preview {
    ContentView()
}
