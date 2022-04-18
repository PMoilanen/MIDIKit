/// ------------------------------------------------------------------------------------------
/// ------------------------------------------------------------------------------------------
/// Borrowed from [OTAtomics 1.0.0](https://github.com/orchetect/OTAtomics) under MIT license.
/// Methods herein are unit tested in OTAtomics, so no unit tests are necessary in MIDIKit.
/// ------------------------------------------------------------------------------------------
/// ------------------------------------------------------------------------------------------

import Foundation

extension MIDI {
    
    /// `Atomic`: A property wrapper that ensures thread-safe atomic access to a value.
    /// Multiple read accesses can potentially read at the same time, just not during a write.
    ///
    /// By using `pthread` to do the locking, this safer than using a `DispatchQueue/barrier` as there isn't a chance of priority inversion.
    ///
    /// This is safe to use on collection types (`Array`, `Dictionary`, etc.)
    ///
    /// - Warning: Do not instance this wrapper on a variable declaration inside a function. Only wrap class-bound, struct-bound, or global-bound variables.
    @propertyWrapper
    public final class Atomic<T> {
        
        @inline(__always)
        private var value: T
        
        @inline(__always)
        private let lock: ThreadLock = RWThreadLock()
        
        @inline(__always)
        public init(wrappedValue value: T) {
            
            self.value = value
            
        }
        
        @inline(__always)
        public var wrappedValue: T {
            
            get {
                self.lock.readLock()
                defer { self.lock.unlock() }
                return self.value
            }
            
            set {
                self.lock.writeLock()
                value = newValue
                self.lock.unlock()
            }
            
            // _modify { } is an internal Swift computed setter, similar to set { }
            // however it gives in-place exclusive mutable access
            // which allows get-then-set operations such as collection subscripts
            // to be performed in a single thread-locked operation
            _modify {
                self.lock.writeLock()
                yield &value
                self.lock.unlock()
            }
            
        }
        
    }

    
}

/// Defines a basic signature to which all locks will conform. Provides the basis for atomic access to stuff.
fileprivate protocol ThreadLock {
    
    init()
    
    /// Lock a resource for writing. So only one thing can write, and nothing else can read or write.
    func writeLock()
    
    /// Lock a resource for reading. Other things can also lock for reading at the same time, but nothing else can write at that time.
    func readLock()
    
    /// Unlock a resource
    func unlock()
    
}

fileprivate final class RWThreadLock: ThreadLock {
    
    private var lock = pthread_rwlock_t()
    
    init() {
        guard pthread_rwlock_init(&lock, nil) == 0 else {
            preconditionFailure("Unable to initialize the lock")
        }
    }
    
    deinit {
        pthread_rwlock_destroy(&lock)
    }
    
    func writeLock() {
        pthread_rwlock_wrlock(&lock)
    }
    
    func readLock() {
        pthread_rwlock_rdlock(&lock)
    }
    
    func unlock() {
        pthread_rwlock_unlock(&lock)
    }
    
}
