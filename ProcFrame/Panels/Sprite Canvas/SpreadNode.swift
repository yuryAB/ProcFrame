//
//  SpreadNode.swift
//  ProcFrame
//
//  Created by yury antony on 07/02/25.
//

import SwiftUI

struct SpreadCanvasView: View {
    @EnvironmentObject var viewModel: ProcFrameViewModel
    
    // Modo de manipulação: se true, arrastar altera a rotação; se false, altera a posição.
    @State private var isRotating: Bool = false
    // Armazena a posição atual do ponteiro, para desenhar a linha durante a rotação.
    @State private var pointerPosition: CGPoint? = nil
    
    // Tamanho padrão para os nodes (você pode adaptar para usar um valor dinâmico, se necessário)
    private let defaultNodeSize = CGSize(width: 100, height: 100)
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Fundo (pode ser transparente ou uma cor de sua preferência)
                Color.gray.opacity(0.2)
                    .ignoresSafeArea()
                
                Canvas { context, canvasSize in
                    // Itera sobre os nodes do viewModel
                    for node in viewModel.nodes {
                        // Converte a posição (ProcPosition) para CGPoint
                        let nodePosition = CGPoint(x: node.position.x, y: node.position.y)
                        let nodeSize = defaultNodeSize
                        
                        // Calcula o ponto de origem do desenho com base no anchorPoint
                        // Exemplo: se o anchor for (0.5, 0.5), o desenho fica centralizado.
                        let drawOrigin = CGPoint(
                            x: -nodeSize.width * node.anchorPoint.x,
                            y: -nodeSize.height * node.anchorPoint.y
                        )
                        let drawingRect = CGRect(origin: drawOrigin, size: nodeSize)
                        
                        // Cria a transformação: move para a posição do node e aplica a rotação
                        var transform = CGAffineTransform.identity
                        transform = transform.translatedBy(x: nodePosition.x, y: nodePosition.y)
                        transform = transform.rotated(by: node.rotation)
                        // Se necessário, aqui também poderia ser aplicada a escala (node.scale)
                        
                        // Cria a imagem a partir do ImportedImage (supondo que fullImage seja NSImage)
                        let image = Image(nsImage: node.image.fullImage)
                        let resolvedImage = context.resolve(image)
                        
                        // Desenha a imagem aplicando a transformação
                        context.draw(resolvedImage, in: drawingRect)
                        
                        // Se este node estiver selecionado, desenha o highlight, o indicador de âncora e, se for rotação, a linha indicadora.
                        if viewModel.selectedNodeID == node.id {
                            // 1. Highlight: desenha um retângulo em volta do node
                            var highlightPath = Path(drawingRect)
                            highlightPath = highlightPath.applying(transform)
                            context.stroke(highlightPath, with: .color(.accentColor), lineWidth: 3)
                            
                            // 2. Indicador de Anchor: para este exemplo, usamos o próprio node.position (após a tradução)
                            let anchorRect = CGRect(x: nodePosition.x - 5, y: nodePosition.y - 5, width: 10, height: 10)
                            let anchorPath = Path(ellipseIn: anchorRect)
                            context.fill(anchorPath, with: .color(.brown))
                            
                            // 3. Se estivermos em modo rotação, desenha uma linha do anchor (node.position) até o ponteiro
                            if isRotating, let pointer = pointerPosition {
                                var linePath = Path()
                                linePath.move(to: nodePosition)
                                linePath.addLine(to: pointer)
                                context.stroke(linePath, with: .color(.red), lineWidth: 2)
                            }
                        }
                    }
                }
                // Gesture para manipulação do node selecionado
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            // Se houver um node selecionado, atualiza sua posição ou rotação
                            guard let selectedID = viewModel.selectedNodeID,
                                  let index = viewModel.nodes.firstIndex(where: { $0.id == selectedID }) else { return }
                            
                            if isRotating {
                                // Modo rotação:
                                pointerPosition = value.location
                                let nodeCenter = CGPoint(x: viewModel.nodes[index].position.x,
                                                         y: viewModel.nodes[index].position.y)
                                let dx = value.location.x - nodeCenter.x
                                let dy = value.location.y - nodeCenter.y
                                let angle = atan2(dy, dx)
                                viewModel.nodes[index].rotation = angle
                            } else {
                                // Modo movimentação:
                                viewModel.nodes[index].position.x += value.translation.width
                                viewModel.nodes[index].position.y += value.translation.height
                            }
                        }
                        .onEnded { _ in
                            pointerPosition = nil
                        }
                )
                // Gesture para seleção do node: um tap simples
                .gesture(
                    TapGesture()
                        .onEnded { _ in
                            let tappedLocation = NSEvent.mouseLocation
                            let localLocation = CGPoint(
                                x: tappedLocation.x - geometry.frame(in: .global).minX,
                                y: geometry.frame(in: .global).maxY - tappedLocation.y
                            )

                            if let tappedNode = hitTest(location: localLocation, in: geometry.size) {
                                viewModel.selectedNodeID = tappedNode.id
                            } else {
                                viewModel.selectedNodeID = nil
                            }
                        }
                )
                
                // Botão sobreposto para alternar entre Move e Rotate mode
                VStack {
                    HStack {
                        Spacer()
                        Button(action: {
                            isRotating.toggle()
                        }) {
                            Text(isRotating ? "Rotate Mode" : "Move Mode")
                                .padding(8)
                                .background(Color.white.opacity(0.8))
                                .cornerRadius(8)
                        }
                        .padding()
                    }
                    Spacer()
                }
            }
        }
        // Define as dimensões fixas do canvas
        .frame(width: 650, height: 550)
    }
    
    /// Função auxiliar para testar se um ponto (location) está dentro de algum node.
    /// Aqui, a verificação é feita com base no retângulo do node (sem considerar rotação).
    func hitTest(location: CGPoint, in canvasSize: CGSize) -> ProcNode? {
        for node in viewModel.nodes.reversed() {
            let nodePosition = CGPoint(x: node.position.x, y: node.position.y)
            let nodeSize = defaultNodeSize
            let drawOrigin = CGPoint(
                x: -nodeSize.width * node.anchorPoint.x,
                y: -nodeSize.height * node.anchorPoint.y
            )
            let frame = CGRect(
                origin: CGPoint(x: nodePosition.x + drawOrigin.x, y: nodePosition.y + drawOrigin.y),
                size: nodeSize
            )

            // Transformação para considerar a rotação
            var transform = CGAffineTransform.identity
            transform = transform.translatedBy(x: nodePosition.x, y: nodePosition.y)
            transform = transform.rotated(by: node.rotation)
            transform = transform.translatedBy(x: -nodePosition.x, y: -nodePosition.y)

            let transformedLocation = location.applying(transform.inverted())

            if frame.contains(transformedLocation) {
                return node
            }
        }
        return nil
    }
}
