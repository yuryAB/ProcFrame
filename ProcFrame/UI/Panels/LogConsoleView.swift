//
//  LogConsoleView.swift
//  ProcFrame
//
//  Created by yury antony on 08/02/25.
//


import SwiftUI

struct LogConsoleView: View {
    @ObservedObject var viewModel: LogConsoleViewModel
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(viewModel.logs, id: \.self) { log in
                        Text(log)
                            .font(.system(.caption, design: .monospaced))
                            .foregroundColor(.primary)
                            .padding(.horizontal, 8)
                    }
                }
                .padding(.vertical, 10)
            }
            .navigationTitle("Logs")
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Button("Limpar") {
                        viewModel.clearLogs()
                    }
                }
                ToolbarItem(placement: .automatic) {
                    Button("Fechar") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
        .frame(minWidth: 400, minHeight: 300)
    }
}
