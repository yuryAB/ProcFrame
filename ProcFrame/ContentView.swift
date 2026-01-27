//
//  ContentView.swift
//  ProcFrame
//
//  Created by yury antony on 24/01/25.
//

import SwiftUI
import SpriteKit
import AppKit

struct ContentView: View {
    @StateObject private var viewModel = ProcFrameViewModel()
    @State private var showLogConsole: Bool = false
    @State private var actionTimelineHeight: CGFloat = 250
    
    let mediaPanelWidth: CGFloat = 200
    let procEditionPanelWidth: CGFloat = 250
    let spriteCanvasWidth: CGFloat = 750
    
    var baseWidth: CGFloat {
        mediaPanelWidth + procEditionPanelWidth + spriteCanvasWidth
    }
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 2) {
                PanelView(color: Color(nsColor: .controlColor))
                    .frame(height: 40)
                    .frame(maxWidth: baseWidth + 500)
                
                HStack(spacing: 0) {
                    MediaPanelView(color: Color(nsColor: .controlColor))
                        .frame(width: mediaPanelWidth)
                    Spacer()
                    SpriteCanvasView()
                    Spacer()
                    ProcEditionPanel()
                        .frame(width: procEditionPanelWidth)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 5)
                
                VStack(spacing: 0) {
                    Rectangle()
                        .frame(height: 5)
                        .foregroundColor(.gray)
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    let newHeight = actionTimelineHeight - value.translation.height
                                    actionTimelineHeight = max(100, min(newHeight, 500))
                                }
                        )
                    
                    ActionTimelinePanelView()
                        .frame(height: actionTimelineHeight)
                        .frame(minWidth: baseWidth, maxWidth: baseWidth + 500)
                }
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
        } .onAppear(){
            for family in NSFontManager.shared.availableFontFamilies {
                print("Font Family: \(family)")
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
