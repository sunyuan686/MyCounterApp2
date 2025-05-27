//
//  ContentView.swift
//  MyCounterApp2
//
//  Created by sunyuan on 2025/5/25.
//

import SwiftUI
import WidgetKit
import Combine

// 创建一个ObservableObject来管理计数器状态和通知
class CounterViewModel: ObservableObject {
    @Published var counter: Int
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // 初始化时从SharedUserDefaults读取计数值
        counter = SharedUserDefaults.shared.getCounter()
        print("[CounterViewModel] 初始化，counter=\(counter)")
        
        // 监听应用进入前台通知
        NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)
            .sink { [weak self] _ in
                print("[CounterViewModel] 应用进入前台，刷新数据")
                self?.refreshCounterFromSharedDefaults()
            }
            .store(in: &cancellables)
        
        // 监听应用变为活跃状态通知
        NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)
            .sink { [weak self] _ in
                print("[CounterViewModel] 应用变为活跃状态，刷新数据")
                self?.refreshCounterFromSharedDefaults()
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
    
    // 递增计数器
    func increment() {
        print("[CounterViewModel] + 按钮点击，当前counter=\(counter)")
        counter += 1
        print("[CounterViewModel] counter递增后=\(counter)")
        SharedUserDefaults.shared.setCounter(counter)
        // 刷新小组件
        WidgetCenter.shared.reloadTimelines(ofKind: "myWidget")
    }
    
    // 递减计数器
    func decrement() {
        print("[CounterViewModel] - 按钮点击，当前counter=\(counter)")
        counter -= 1
        print("[CounterViewModel] counter递减后=\(counter)")
        SharedUserDefaults.shared.setCounter(counter)
        // 刷新小组件
        WidgetCenter.shared.reloadTimelines(ofKind: "myWidget")
    }
    
    // 重置计数器
    func reset() {
        print("[CounterViewModel] 重置按钮点击")
        counter = 0
        print("[CounterViewModel] counter已重置为0")
        SharedUserDefaults.shared.resetCounter()
        // 刷新小组件
        WidgetCenter.shared.reloadTimelines(ofKind: "myWidget")
    }
}

struct ContentView: View {
    // 使用StateObject确保视图模型在视图的生命周期内保持一致
    @StateObject private var viewModel = CounterViewModel()
    
    var body: some View {
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
        }
        .padding()
        .onAppear {
            print("[ContentView] onAppear，刷新数据")
            viewModel.refreshCounterFromSharedDefaults()
        }
        // 添加刷新按钮
        .toolbar {
            Button("刷新") {
                print("[ContentView] 手动刷新按钮点击")
                viewModel.refreshCounterFromSharedDefaults()
            }
        }
    }
}

#Preview {
    ContentView()
}
