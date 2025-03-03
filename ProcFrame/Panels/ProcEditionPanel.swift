//
//  ProcEditionPanel.swift
//  ProcFrame
//
//  Created by yury antony on 06/02/25.
//

import SwiftUI

struct ProcEditionPanel: View {
    @EnvironmentObject var viewModel: ProcFrameViewModel
    
    var body: some View {
        Group {
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    Image(systemName: viewModel.editionType == .selection ? "cursorarrow.click" :
                            viewModel.editionType == .rotation ? "arrow.trianglehead.2.clockwise.rotate.90" :
                            "link")
                    .foregroundColor(viewModel.editionType == .selection ? .green :
                                        viewModel.editionType == .rotation ? .blue :
                            .purple)
                    
                    Text(viewModel.editionType == .selection ? "Modo: Seleção" :
                            viewModel.editionType == .rotation ? "Modo: Rotação" :
                            "Modo: Parentalidade")
                    .font(.headline)
                    .foregroundColor(.primary)
                }
                .padding()
                .background(Color(nsColor: .controlBackgroundColor))
                .cornerRadius(8)
                if let nodeBinding = selectedProcNode() {
                    if let message = viewModel.notificationMessage, let type = viewModel.notificationType {
                        Text(message)
                            .foregroundColor(type == .error ? .red : (type == .warning ? .yellow : .green))
                            .padding()
                            .background(Color.black.opacity(0.8))
                            .cornerRadius(8)
                            .transition(.opacity)
                            .animation(.easeInOut)
                    }
                    HStack {
                        HStack(alignment: .center, spacing: 16) {
                            Image(systemName: "arrow.up.left.and.down.right.and.arrow.up.right.and.down.left")
                                .frame(width: 24)
                            
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Text("X:")
                                        .frame(width: 30, alignment: .leading)
                                    TextField("", value: bindingForX(nodeBinding: nodeBinding), formatter: numberFormatter)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                }
                                HStack {
                                    Text("Y:")
                                        .frame(width: 30, alignment: .leading)
                                    TextField("", value: bindingForY(nodeBinding: nodeBinding), formatter: numberFormatter)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                }
                            }
                        }
                        
                        HStack(alignment: .center) {
                            Image(systemName: "dot.scope")
                                .frame(width: 24)
                            
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Text("X:")
                                        .frame(alignment: .leading)
                                    TextField("", value: bindingForAnchorX(nodeBinding: nodeBinding), formatter: numberFormatter)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                }
                                HStack {
                                    Text("Y:")
                                        .frame(alignment: .leading)
                                    TextField("", value: bindingForAnchorY(nodeBinding: nodeBinding), formatter: numberFormatter)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                }
                            }
                        }
                    }
                    
                    
                    HStack {
                        
                        HStack(alignment: .center, spacing: 16) {
                            Image(systemName: "square.stack")
                                .frame(width: 24)
                            HStack {
                                Text("Z:")
                                    .frame(width: 30, alignment: .leading)
                                TextField("", value: bindingForZ(nodeBinding: nodeBinding), formatter: numberFormatter)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                            }
                        }
                        
                        HStack(alignment: .center, spacing: 16) {
                            Button(action: {
                                viewModel.editionType = .rotation
                            }) {
                                Image(systemName: "arrow.trianglehead.2.clockwise.rotate.90.circle.fill")
                                    .frame(width: 24)
                                    .foregroundColor(viewModel.editionType == .rotation ? .blue : .primary)
                            }
                            
                            TextField("", value: bindingForRotation(nodeBinding: nodeBinding), formatter: numberFormatter)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .frame(width: 80)
                        }
                    }
                    Spacer()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding()
            .background(Color(nsColor: .controlColor))
            .cornerRadius(8)
            
            
        }
    }
    
    // MARK: - Bindings
    
    private func selectedProcNode() -> Binding<ProcNode>? {
        guard let selectedID = viewModel.selectedNodeID,
              let index = viewModel.nodes.firstIndex(where: { $0.id == selectedID })
        else { return nil }
        return $viewModel.nodes[index]
    }
    
    private var numberFormatter: NumberFormatter {
        let nf = NumberFormatter()
        nf.numberStyle = .decimal
        return nf
    }
    
    private func bindingForX(nodeBinding: Binding<ProcNode>) -> Binding<CGFloat> {
        Binding<CGFloat>(
            get: { nodeBinding.wrappedValue.position.x },
            set: { newValue in
                var node = nodeBinding.wrappedValue
                node.position.x = newValue
                nodeBinding.wrappedValue = node
            }
        )
    }
    
    private func bindingForY(nodeBinding: Binding<ProcNode>) -> Binding<CGFloat> {
        Binding<CGFloat>(
            get: { nodeBinding.wrappedValue.position.y },
            set: { newValue in
                var node = nodeBinding.wrappedValue
                node.position.y = newValue
                nodeBinding.wrappedValue = node
            }
        )
    }
    
    private func bindingForZ(nodeBinding: Binding<ProcNode>) -> Binding<CGFloat> {
        Binding<CGFloat>(
            get: { nodeBinding.wrappedValue.zPosition },
            set: { newValue in
                var node = nodeBinding.wrappedValue
                node.zPosition = newValue
                nodeBinding.wrappedValue = node
            }
        )
    }
    
    private func bindingForAnchorX(nodeBinding: Binding<ProcNode>) -> Binding<CGFloat> {
        Binding<CGFloat>(
            get: { nodeBinding.wrappedValue.anchorPoint.x },
            set: { newValue in
                var node = nodeBinding.wrappedValue
                node.anchorPoint.x = newValue
                nodeBinding.wrappedValue = node
            }
        )
    }
    
    private func bindingForAnchorY(nodeBinding: Binding<ProcNode>) -> Binding<CGFloat> {
        Binding<CGFloat>(
            get: { nodeBinding.wrappedValue.anchorPoint.y },
            set: { newValue in
                var node = nodeBinding.wrappedValue
                node.anchorPoint.y = newValue
                nodeBinding.wrappedValue = node
            }
        )
    }
    
    private func bindingForRotation(nodeBinding: Binding<ProcNode>) -> Binding<CGFloat> {
        Binding<CGFloat>(
            get: { nodeBinding.wrappedValue.rotation },
            set: { newValue in
                var node = nodeBinding.wrappedValue
                node.rotation = newValue
                nodeBinding.wrappedValue = node
            }
        )
    }
}
