import Foundation
import Combine

/// Debounces rapid function calls to prevent excessive updates
/// Useful for auto-save, search, and other frequent operations
final class Debouncer {
    private var subject = PassthroughSubject<Void, Never>()
    private var cancellable: AnyCancellable?
    
    /// Initialize with delay and action
    /// - Parameters:
    ///   - delay: Time to wait before executing action
    ///   - action: Closure to execute after delay
    init(delay: TimeInterval, action: @escaping () -> Void) {
        cancellable = subject
            .debounce(for: .seconds(delay), scheduler: RunLoop.main)
            .sink { _ in action() }
    }
    
    /// Trigger the debounced action
    func call() {
        subject.send()
    }
    
    /// Cancel any pending action
    func cancel() {
        cancellable?.cancel()
    }
}

/// Throttles function calls to a maximum rate
/// Useful for UI updates during drag operations
final class Throttler {
    private var subject = PassthroughSubject<Void, Never>()
    private var cancellable: AnyCancellable?
    
    /// Initialize with interval and action
    /// - Parameters:
    ///   - interval: Minimum time between actions
    ///   - latest: If true, use latest value; if false, use first
    ///   - action: Closure to execute
    init(interval: TimeInterval, latest: Bool = true, action: @escaping () -> Void) {
        cancellable = subject
            .throttle(for: .seconds(interval), scheduler: RunLoop.main, latest: latest)
            .sink { _ in action() }
    }
    
    /// Trigger the throttled action
    func call() {
        subject.send()
    }
    
    /// Cancel any pending action
    func cancel() {
        cancellable?.cancel()
    }
}

/// Generic debouncer that passes a value
final class ValueDebouncer<T> {
    private var subject = PassthroughSubject<T, Never>()
    private var cancellable: AnyCancellable?
    
    init(delay: TimeInterval, action: @escaping (T) -> Void) {
        cancellable = subject
            .debounce(for: .seconds(delay), scheduler: RunLoop.main)
            .sink { value in action(value) }
    }
    
    func call(with value: T) {
        subject.send(value)
    }
    
    func cancel() {
        cancellable?.cancel()
    }
}

/// Async debouncer for SwiftUI
@MainActor
final class AsyncDebouncer: ObservableObject {
    private var task: Task<Void, Never>?
    private let delay: TimeInterval
    
    init(delay: TimeInterval) {
        self.delay = delay
    }
    
    func debounce(action: @escaping () async -> Void) {
        task?.cancel()
        task = Task {
            do {
                try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                guard !Task.isCancelled else { return }
                await action()
            } catch {
                // Task was cancelled
            }
        }
    }
    
    func cancel() {
        task?.cancel()
    }
}
