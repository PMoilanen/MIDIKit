//
//  UInt4.swift
//  MIDIKit • https://github.com/orchetect/MIDIKit
//

extension MIDI {
    
    /// A 4-bit unsigned integer value type used in `MIDIKit`.
    public struct UInt4: MIDIKitIntegerProtocol {
        
        // MARK: Storage
        
        public typealias Storage = UInt8
        public internal(set) var value: Storage
        
        // MARK: Inits
        
        public init() {
            value = 0
        }
        
        public init<T: BinaryInteger>(_ source: T) {
            if source < Self.min(Storage.self) {
                Exception.underflow.raise(reason: "UInt4 integer underflowed")
            }
            if source > Self.max(Storage.self) {
                Exception.overflow.raise(reason: "UInt4 integer overflowed")
            }
            value = Storage(source)
        }
        
        public init<T: BinaryFloatingPoint>(_ source: T) {
            // it should be safe to cast as T.self since it's virtually impossible that we will encounter a BinaryFloatingPoint type less than the largest MIDIKitIntegerProtocol concrete type we're using (UInt14).
            // the smallest floating point number in the Swift standard library is Float16 which can hold UInt14.max fine.
            if source < Self.min(T.self) {
                Exception.underflow.raise(reason: "UInt4 integer underflowed")
            }
            if source > Self.max(T.self) {
                Exception.overflow.raise(reason: "UInt4 integer overflowed")
            }
            value = Storage(source)
        }
        
        // MARK: Constants
        
        public static let bitWidth: Int = 4
        
        public static func min<T: BinaryInteger>(_ ofType: T.Type) -> T { 0 }
        public static func min<T: BinaryFloatingPoint>(_ ofType: T.Type) -> T { 0 }
        
        public static func max<T: BinaryInteger>(_ ofType: T.Type) -> T { 0b1111 }
        public static func max<T: BinaryFloatingPoint>(_ ofType: T.Type) -> T { 0b1111 }
        
        // MARK: Computed properties
        
        /// Returns the integer as a `UInt8` instance
        public var uInt8Value: UInt8 { value }
        
    }
    
}

extension MIDI.UInt4: ExpressibleByIntegerLiteral {
    
    public typealias IntegerLiteralType = Storage
    
    public init(integerLiteral value: Storage) {
        self.init(value)
    }
    
}

extension MIDI.UInt4: Equatable, Comparable {
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.value == rhs.value
    }
    
    public static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.value < rhs.value
    }
    
}

extension MIDI.UInt4: Hashable {
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(value)
    }
    
}

extension MIDI.UInt4: Codable {
    
    enum CodingKeys: String, CodingKey {
        case value = "UInt4"
    }
    
}

extension MIDI.UInt4: CustomStringConvertible {
    
    public var description: String {
        "\(value)"
    }
    
}

// MARK: - Standard library extensions

extension BinaryInteger {
    
    /// Convenience initializer for `MIDI.UInt4`.
    public var toMIDIUInt4: MIDI.UInt4 {
        MIDI.UInt4(self)
    }
    
    /// Convenience initializer for `MIDI.UInt4(exactly:)`.
    public var toMIDIUInt4Exactly: MIDI.UInt4? {
        MIDI.UInt4(exactly: self)
    }
    
}

extension BinaryFloatingPoint {
    
    /// Convenience initializer for `MIDI.UInt4`.
    public var toMIDIUInt4: MIDI.UInt4 {
        MIDI.UInt4(self)
    }
    
    /// Convenience initializer for `MIDI.UInt4(exactly:)`.
    public var toMIDIUInt4Exactly: MIDI.UInt4? {
        MIDI.UInt4(exactly: self)
    }
    
}