//
//  DragAndDropZone.swift
//  PocReferenciaArquivos+VIP
//
//  Created by Lizandra Malta on 16/06/26.
//

import SwiftUI

struct DragAndDropZoneModifier<T: Transferable>: ViewModifier {
    
    var onAction: ([T]) -> Void
    var isHovering: (Bool) -> Void
    
    func body(content: Content) -> some View {
        content
            .dropDestination(
                for: T.self,
                action: {
                    items, _ in
                        onAction(items)
                        return true
                },
                isTargeted: isHovering
            )
    }
}

extension View {
    func dragAndDropZone<T: Transferable>(onAction: @escaping ([T]) -> Void, isHovering: @escaping ((Bool) -> Void) = { _ in }) -> some View {
        modifier(DragAndDropZoneModifier<T>(onAction: onAction, isHovering: isHovering))
    }
}
