//
//  SearchDebouncer.swift
//  Bentoshi
//
//  Created by Lizandra Malta on 21/06/26.
//

final class SearchDebouncer {
    private var task: Task<Void, Never>?

    func run(delay: Duration = .milliseconds(400), action: @escaping @Sendable () async -> Void) {
        task?.cancel()

        task = Task {
            try? await Task.sleep(for: delay)

            guard !Task.isCancelled else { return }

            await action()
        }
    }

    func cancel() {
        task?.cancel()
    }
}
