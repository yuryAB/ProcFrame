//
//  ContentView.swift
//  ProcFrame
//
//  Created by yury antony on 24/01/25.
//

import SwiftUI
import SpriteKit

struct ContentView: View {
    @StateObject private var viewModel = ProcFrameViewModel()
    @State private var showLogConsole: Bool = false
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 2) {
                PanelView(color: Color(nsColor: .controlColor))
                    .frame(height: 40)
                    .frame(maxWidth: .infinity)
                
                HStack(spacing: 0) {
                    MediaPanelView(color: Color(nsColor: .controlColor))
                        .frame(width: 160)
                    
                    Spacer()
                    
                    SpriteCanvasView()
                    
                    Spacer()
                    
                    ProcEditionPanel()
                        .frame(width: 300)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 5)
                
                PanelView(color: Color(nsColor: .controlColor))
                    .frame(height: 120)
                    .frame(maxWidth: .infinity)
            }
            .frame(maxHeight: .infinity)
            .padding()
            
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        showLogConsole.toggle()
                        LogManager.shared.addLog("Log console \(showLogConsole ? "aberta" : "fechada")")
                    }) {
                        Image(systemName: "doc.text.magnifyingglass")
                            .foregroundColor(.white)
                            .padding(8)
                            .background(Color.gray.opacity(0.7))
                            .clipShape(Circle())
                    }
                    .padding()
                }
                Spacer()
            }
            
            if showLogConsole {
                
                HStack {
                    Spacer()
                    LogConsoleView()
                        .environmentObject(LogManager.shared)
                        .frame(width: 400, height: 300)
                        .background(Color.black.opacity(0.8))
                        .cornerRadius(8)
                        .shadow(radius: 10)
                        .padding(.top, 20)
                        .padding(.trailing, 20)
                        .transition(.move(edge: .top))
                }
            }
        }
        .environmentObject(viewModel)
        .environmentObject(LogManager.shared)
    }
}

struct PanelView: View {
    let color: Color
    
    var body: some View {
        Rectangle()
            .fill(color)
            .cornerRadius(8)
            .shadow(radius: 4)
    }
}
