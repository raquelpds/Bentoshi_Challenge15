//
//  RichTextViewer.swift
//  Bentoshi
//
//  Created by Lizandra Malta on 06/07/26.
//

import SwiftUI
import AppKit

final class PassthroughScrollView: NSScrollView {
    override func hitTest(_ point: NSPoint) -> NSView? {
        nil
    }
}

final class PassthroughTextView: NSTextView {
    override func hitTest(_ point: NSPoint) -> NSView? {
        nil
    }

    override var acceptsFirstResponder: Bool {
        false
    }
}

struct RichTextViewer: NSViewRepresentable {
    
    let text: NSAttributedString
    
    private func blackText(_ attributedText: NSAttributedString) -> NSAttributedString {
        let mutableText = NSMutableAttributedString(attributedString: attributedText)
        
        let fullRange = NSRange(
            location: 0,
            length: mutableText.length
        )
        
        mutableText.addAttribute(
            .foregroundColor,
            value: NSColor.black,
            range: fullRange
        )
        
        return mutableText
    }
    
    func makeNSView(context: Context) -> NSScrollView {
        let scrollView = PassthroughScrollView()
        scrollView.hasVerticalScroller = false
        scrollView.hasHorizontalScroller = false
        scrollView.drawsBackground = false
        scrollView.borderType = .noBorder
        
        let textView = PassthroughTextView()
        textView.isEditable = false
        textView.isSelectable = false
        textView.isRichText = true
        textView.drawsBackground = false
        textView.textContainerInset = NSSize(width: 12, height: 12)
        textView.font = .systemFont(ofSize: 13)
        
        textView.textStorage?.setAttributedString(blackText(text))
        
        textView.isVerticallyResizable = true
        textView.isHorizontallyResizable = false
        textView.autoresizingMask = [.width]
        
        textView.textContainer?.widthTracksTextView = true
        textView.textContainer?.heightTracksTextView = false
        textView.textContainer?.lineFragmentPadding = 0
        
        scrollView.documentView = textView
        
        return scrollView
    }
    
    func updateNSView(_ scrollView: NSScrollView, context: Context) {
        guard let textView = scrollView.documentView as? NSTextView else { return }
        
        let updatedText = blackText(text)
        
        if !textView.attributedString().isEqual(to: updatedText) {
            textView.textStorage?.setAttributedString(updatedText)
        }
    }
}
