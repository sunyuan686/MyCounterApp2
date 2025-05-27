//
//  ContentView.swift
//  MyCounterApp2
//
//  Created by sunyuan on 2025/5/25.
//

import SwiftUI
import WidgetKit

struct ContentView: View {
    @State private var counter: Int = SharedUserDefaults.shared.getCounter()
    
    var body: some View {
        VStack(spacing: 30) {
            Text("计数器")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("\(counter)")
                .font(.system(size: 80, weight: .bold))
                .foregroundColor(.blue)
                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: counter)
            
            HStack(spacing: 20) {
                Button("-") {
                    print("[ContentView] - 按钮点击，当前counter=\(counter)")
                    withAnimation(.easeInOut(duration: 0.2)) {
                        counter -= 1
                        print("[ContentView] counter递减后=\(counter)")
                        SharedUserDefaults.shared.setCounter(counter)
                    }
                    // 刷新小组件
                    WidgetCenter.shared.reloadTimelines(ofKind: "myWidget")
                }
                .font(.title)
                .frame(width: 60, height: 60)
                .background(Color.red)
                .foregroundColor(.white)
                .clipShape(Circle())
                .scaleEffect(counter < 0 ? 1.1 : 1.0)
                
                Button("+") {
                    print("[ContentView] + 按钮点击，当前counter=\(counter)")
                    withAnimation(.easeInOut(duration: 0.2)) {
                        counter += 1
                        print("[ContentView] counter递增后=\(counter)")
                        SharedUserDefaults.shared.setCounter(counter)
                    }
                    // 刷新小组件
                    WidgetCenter.shared.reloadTimelines(ofKind: "myWidget")
                }
                .font(.title)
                .frame(width: 60, height: 60)
                .background(Color.green)
                .foregroundColor(.white)
                .clipShape(Circle())
                .scaleEffect(counter > 0 ? 1.1 : 1.0)
            }
            
            Button("重置") {
                print("[ContentView] 重置按钮点击")
                withAnimation(.easeInOut(duration: 0.3)) {
                    counter = 0
                    print("[ContentView] counter已重置为0")
                    SharedUserDefaults.shared.resetCounter()
                }
                // 刷新小组件
                WidgetCenter.shared.reloadTimelines(ofKind: "myWidget")
            }
            .font(.headline)
            .padding(.horizontal, 30)
            .padding(.vertical, 12)
            .background(Color.gray)
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
