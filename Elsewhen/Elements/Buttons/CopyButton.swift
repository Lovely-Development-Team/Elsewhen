//
//  CopyButton.swift
//  CopyButton
//
//  Created by David Stephens on 18/09/2021.
//

import SwiftUI
import UniformTypeIdentifiers

struct CopyButton: View {
    // MARK: Parameters
    let text: String
    let generateText: () -> String
    @Binding var showCopied: Bool
    
    // MARK: State
    #if os(iOS)
    @State private var notificationFeedbackGenerator: UINotificationFeedbackGenerator? = nil
    #endif
    
    var button: some View {
        Button(action: {
            #if os(iOS)
            notificationFeedbackGenerator = UINotificationFeedbackGenerator()
            notificationFeedbackGenerator?.prepare()
            #endif
            EWPasteboard.set(generateText(), forType: UTType.utf8PlainText)
            withAnimation {
                showCopied = true
                #if os(iOS)
                notificationFeedbackGenerator?.notificationOccurred(.success)
                #endif
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                withAnimation {
                    showCopied = false
                }
                #if os(iOS)
                notificationFeedbackGenerator = nil
                #endif
            }
        }) {
            Text(showCopied ? "Copied ✓" : text)
                .font(.headline)
                .foregroundColor(.white)
        }
        .roundedRectangle()
    }
    
    var body: some View {
        button
    }
}

struct CopyButton_Previews: PreviewProvider {
    static var previews: some View {
        CopyButton(text: "Copy", generateText: { "Example text" }, showCopied: .constant(false))
    }
}
