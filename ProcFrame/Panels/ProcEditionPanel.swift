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
            if let nodeBinding = selectedProcNode() {
                VStack(alignment: .leading, spacing: 20) {
                    // MARK: - Position Section
                    Text("Position")
                        .font(.headline)
                    
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
                    
                    // Linha para Z
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
                    
                    // MARK: - Anchor Point Section
                    Text("Anchor Point")
                        .font(.headline)
                    
                    HStack(alignment: .center, spacing: 16) {
                        Image(systemName: "dot.scope")
                            .frame(width: 24)
                        
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("X:")
                                    .frame(width: 60, alignment: .leading)
                                TextField("", value: bindingForAnchorX(nodeBinding: nodeBinding), formatter: numberFormatter)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                            }
                            HStack {
                                Text("Y:")
                                    .frame(width: 60, alignment: .leading)
                                TextField("", value: bindingForAnchorY(nodeBinding: nodeBinding), formatter: numberFormatter)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                            }
                        }
                    }
                    
                    // MARK: - Rotation Section
                    Text("Rotation")
                        .font(.headline)
                    
                    HStack(alignment: .center, spacing: 16) {
                        Button(action: {
                            let currentRotation = bindingForRotation(nodeBinding: nodeBinding).wrappedValue
                            bindingForRotation(nodeBinding: nodeBinding).wrappedValue = currentRotation - 5.0
                        }) {
                            Image(systemName: "arrow.trianglehead.2.counterclockwise.rotate.90")
                                .frame(width: 24)
                        }
                        
                        TextField("", value: bindingForRotation(nodeBinding: nodeBinding), formatter: numberFormatter)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(width: 80)
                        
                        Button(action: {
                            let currentRotation = bindingForRotation(nodeBinding: nodeBinding).wrappedValue
                            bindingForRotation(nodeBinding: nodeBinding).wrappedValue = currentRotation + 5.0
                        }) {
                            Image(systemName: "arrow.trianglehead.2.clockwise.rotate.90.circle.fill")
                                .frame(width: 24)
                        }
                    }
                    
                    Spacer()
                }
                .padding()
                .background(Color(nsColor: .controlColor))
                .cornerRadius(8)
            } else {
                VStack {
                    Spacer()
                    Text("No node selected")
                        .foregroundColor(.secondary)
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
                .background(Color(nsColor: .controlColor))
                .cornerRadius(8)
            }
                
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
