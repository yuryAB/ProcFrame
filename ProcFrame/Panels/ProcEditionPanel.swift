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
                Form {
                    Section(header: Text("Position")) {
                        TextField("X", value: bindingForX(nodeBinding: nodeBinding), formatter: numberFormatter)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        TextField("Y", value: bindingForY(nodeBinding: nodeBinding), formatter: numberFormatter)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        TextField("Z", value: bindingForZ(nodeBinding: nodeBinding), formatter: numberFormatter)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    Section(header: Text("Anchor Point")) {
                        TextField("Anchor X", value: bindingForAnchorX(nodeBinding: nodeBinding), formatter: numberFormatter)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        TextField("Anchor Y", value: bindingForAnchorY(nodeBinding: nodeBinding), formatter: numberFormatter)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                    }
                    
                    Section(header: Text("Rotation")) {
                        TextField("Rotation", value: bindingForRotation(nodeBinding: nodeBinding), formatter: numberFormatter)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                }
                .padding()
            } else {
                VStack {
                    Spacer()
                    Text("No node selected")
                        .foregroundColor(.secondary)
                    Spacer()
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(nsColor: .controlColor))
        .cornerRadius(8)
    }
    
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
        return Binding<CGFloat>(
            get: { nodeBinding.wrappedValue.position.x },
            set: { newValue in
                var node = nodeBinding.wrappedValue
                node.position.x = newValue
                nodeBinding.wrappedValue = node
            }
        )
    }
    
    private func bindingForY(nodeBinding: Binding<ProcNode>) -> Binding<CGFloat> {
        return Binding<CGFloat>(
            get: { nodeBinding.wrappedValue.position.y },
            set: { newValue in
                var node = nodeBinding.wrappedValue
                node.position.y = newValue
                nodeBinding.wrappedValue = node
            }
        )
    }
    
    private func bindingForZ(nodeBinding: Binding<ProcNode>) -> Binding<CGFloat> {
        return Binding<CGFloat>(
            get: { nodeBinding.wrappedValue.zPosition },
            set: { newValue in
                var node = nodeBinding.wrappedValue
                node.zPosition = newValue
                nodeBinding.wrappedValue = node
            }
        )
    }
    
    private func bindingForAnchorX(nodeBinding: Binding<ProcNode>) -> Binding<CGFloat> {
        return Binding<CGFloat>(
            get: { nodeBinding.wrappedValue.anchorPoint.x },
            set: { newValue in
                var node = nodeBinding.wrappedValue
                node.anchorPoint.x = newValue
                nodeBinding.wrappedValue = node
            }
        )
    }
    
    private func bindingForAnchorY(nodeBinding: Binding<ProcNode>) -> Binding<CGFloat> {
        return Binding<CGFloat>(
            get: { nodeBinding.wrappedValue.anchorPoint.y },
            set: { newValue in
                var node = nodeBinding.wrappedValue
                node.anchorPoint.y = newValue
                nodeBinding.wrappedValue = node
            }
        )
    }
    
    private func bindingForRotation(nodeBinding: Binding<ProcNode>) -> Binding<CGFloat> {
        return Binding<CGFloat>(
            get: { nodeBinding.wrappedValue.rotation },
            set: { newValue in
                var node = nodeBinding.wrappedValue
                node.rotation = newValue
                nodeBinding.wrappedValue = node
            }
        )
    }
}
