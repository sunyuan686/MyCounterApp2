//
//  ContentView.swift
//  MyCounterApp2
//
//  Created by sunyuan on 2025/5/25.
//

import SwiftUI
import WidgetKit

struct ContentView: View {
    @AppStorage("counter", store: UserDefaults(suiteName: "group.com.sunyuan.MyCounterApp2")) 
    private var counter: Int = 0
    
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
                    withAnimation(.easeInOut(duration: 0.2)) {
                        counter -= 1
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
                    withAnimation(.easeInOut(duration: 0.2)) {
                        counter += 1
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
                withAnimation(.easeInOut(duration: 0.3)) {
                    counter = 0
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
