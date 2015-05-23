//
//  SortedCollection.swift
//
//  Created by Nate Cook on 2/23/15.
//  Copyright (c) 2015 Nate Cook. Available under the MIT license.
//


// MARK: - SortedCollectionType

/// A *collection* whose elements are guaranteed to always be
/// in ascending order.
public protocol SortedCollectionType : Sliceable, Equatable {
    typealias Element : Comparable

    /// Create an empty `SortedCollection`.
    init()
    
    /// Create a new `SortedCollection` with the contents of a given sequence.
    init<S : SequenceType where S.Generator.Element == Element>(_ sequence: S)
    
    /// Returns true iff `value` is found in the collection.
    func contains(value: Element) -> Bool

    /// Quickly find the index of a value.
    ///
    /// :returns: The index of the first instance of `value` in the collection,
    /// or `nil` if `value` isn't found.
    func indexOf(value: Element) -> Int?
    
    /// Inserts one or more new values into the collection in the correct order.
    mutating func insert(values: Element...)
    
    /// Inserts the contents of a sequence into the `SortedCollection`.
    mutating func insert<S: SequenceType where S.Generator.Element == Generator.Element>(values: S)
    
    /// Removes `value` from the collection if it exists.
    ///
    /// :returns: The given value if found, otherwise `nil`.
    mutating func remove(value: Element) -> Element?

    /// Removes and returns the item at `index`. Requires count > 0.
    mutating func removeAtIndex(index: Int) -> Element

    /// Removes all elements from the collection.
    mutating func removeAll(#keepCapacity: Bool)
}


// MARK: - SortedCollection

/// An always-sorted collection of `Comparable` elements. Performance should be O(N log N)
/// when adding to the collection, O(log N) for lookups, and O(1) for iteration.
public struct SortedCollection<T: Comparable> : Printable, SortedCollectionType {
    typealias Element = T
    
    private var contents: [T] = []
    
    /// The number of elements the `SortedCollection` contains.
    public var count: Int {
        return contents.count
    }
    
    /// `true` iff the `SortedCollection` is empty.
    public var isEmpty: Bool {
        return contents.isEmpty
    }
    
    /// A string representation of the `SortedCollection`.
    public var description: String {
        return contents.description
    }
    
    /// Create an empty `SortedCollection`.
    public init() { }
    
    /// Create a new `SortedCollection` with the contents of a given sequence.
    public init<S : SequenceType where S.Generator.Element == T>(_ sequence: S) {
        contents = sorted(sequence)
    }
    
    /// Create a new `SortedCollection` with the given values.
    public init(values: T...) {
        contents = sorted(values)
    }
    
    /// Quickly find the index of a value.
    ///
    /// :returns: The index of the first instance of `value` in the collection,
    /// or `nil` if `value` isn't found.
    public func indexOf(value: T) -> Int? {
        let index = _insertionIndex(contents, forValue: value)
        if index == count {
            return nil
        }
        return contents[index] == value ? index : nil
    }
    
    /// Returns true iff `value` is found in the collection.
    public func contains(value: T) -> Bool {
        return indexOf(value) != nil
    }
    
    /// Returns a new `SortedCollection` with the combined contents of `self` and the given values.
    public func merge(values: T...) -> SortedCollection<T> {
        return merge(values)
    }
    
    /// Returns a new `SortedCollection` with the combined contents of `self` and the given values.
    public func merge<S: SequenceType where S.Generator.Element == T>(values: S) -> SortedCollection<T> {
        return SortedCollection(contents + values)
    }
    
    /// Inserts one or more new values into the collection in the correct order.
    public mutating func insert(values: T...) {
        for value in values {
            contents.insert(value, atIndex: _insertionIndex(contents, forValue: value))
        }
    }
    
    /// Inserts the contents of a sequence into the `SortedCollection`.
    public mutating func insert<S: SequenceType where S.Generator.Element == T>(values: S) {
        contents = sorted(contents + values)
    }
    
    /// Removes `value` from the collection if it exists.
    ///
    /// :returns: The given value if found, otherwise `nil`.
    public mutating func remove(value: T) -> T? {
        if let index = indexOf(value) {
            return contents.removeAtIndex(index)
        }
        return nil
    }
    
    /// Removes and returns the item at `index`. Requires count > 0.
    public mutating func removeAtIndex(index: Int) -> T {
        return contents.removeAtIndex(index)
    }
    
    /// Removes all elements from the collection.
    public mutating func removeAll(keepCapacity: Bool = true) {
        contents.removeAll(keepCapacity: keepCapacity)
    }
}

// MARK: SequenceType

extension SortedCollection : SequenceType {
    typealias Generator = GeneratorOf<T>
    
    /// Returns a generator of the elements of the collection.
    public func generate() -> Generator {
        return GeneratorOf(contents.generate())
    }
}

// MARK: CollectionType

extension SortedCollection : CollectionType {
    typealias Index = Int
    
    /// The position of the first element in the collection. (Always zero.)
    public var startIndex: Int {
        return 0
    }
    
    /// One greater than the position of the last element in the collection. Zero when the collection is empty.
    public var endIndex: Int {
        return count
    }
    
    /// Accesses the element at index `i`.
    ///
    /// Read-only to ensure sorting - use `insert` to add new elements.
    public subscript(i: Int) -> T {
        return contents[i]
    }
}

extension SortedCollection {
    /// The first element, or `nil` if empty.
    public var first: Element? {
        if isEmpty {
            return nil
        }
        
        return contents[startIndex]
    }
    
    /// The last element, or `nil` if empty.
    public var last: Element? {
        if isEmpty {
            return nil
        }
        
        return contents[endIndex - 1]
    }
}

// MARK: ArrayLiteralConvertible

extension SortedCollection : ArrayLiteralConvertible {
    public init(arrayLiteral elements: T...) {
        self.contents = sorted(elements)
    }
}

// MARK: Sliceable

extension SortedCollection : Sliceable {
    typealias SubSlice = SortedSlice<T>
    
    /// Access the elements in the given range.
    public subscript(range: Range<Int>) -> SortedSlice<T> {
        return SortedSlice(contents[range])
    }
}



// MARK: - SortedSlice

/// A slice of a `SortedCollection`.
public struct SortedSlice<T: Comparable> : Printable, SortedCollectionType {
    private var contents: ArraySlice<T> = []
    
    /// The number of elements the `SortedSlice` contains.
    public var count: Int {
        return contents.count
    }
    
    /// A string representation of the `SortedSlice`.
    public var description: String {
        return contents.description
    }
    
    /// Create an empty `SortedSlice`.
    public init() { }
    
    /// Create a new `SortedSlice` with the contents of a given sequence.
    public init<S : SequenceType where S.Generator.Element == T>(_ sequence: S) {
        contents = ArraySlice(sorted(sequence))
    }
    
    /// Create a new `SortedSlice` with the given values.
    public init(values: T...) {
        contents = ArraySlice(sorted(values))
    }
    
    /// Create a new `SortedSlice` using a slice of a parent `SortedCollection`s backing array.
    private init(sortedSlice: ArraySlice<T>) {
        contents = sortedSlice
    }
    
    /// Quickly find the index of a value.
    ///
    /// :returns: The index of the first instance of `value` in the collection,
    /// or `nil` if `value` isn't found.
    public func indexOf(value: T) -> Int? {
        let index = _insertionIndex(contents, forValue: value)
        if index == count {
            return nil
        }
        return contents[index] == value ? index : nil
    }
    
    /// Returns true iff `value` is found in the collection.
    public func contains(value: T) -> Bool {
        return indexOf(value) != nil
    }
    
    /// Returns a new `SortedCollection` with the combined contents of `self` and the given values.
    public func merge(values: T...) -> SortedCollection<T> {
        return merge(values)
    }
    
    /// Returns a new `SortedCollection` with the combined contents of `self` and the given values.
    public func merge<S: SequenceType where S.Generator.Element == T>(values: S) -> SortedCollection<T> {
        return SortedCollection(contents + values)
    }
    
    /// Inserts one or more new values into the collection in the correct order.
    public mutating func insert(values: T...) {
        for value in values {
            contents.insert(value, atIndex: _insertionIndex(contents, forValue: value))
        }
    }
    
    /// Inserts the contents of a sequence into the `SortedSlice`.
    public mutating func insert<S: SequenceType where S.Generator.Element == T>(values: S) {
        contents = ArraySlice(sorted(contents + values))
    }
    
    /// Removes `value` from the collection if it exists.
    ///
    /// :returns: The given value if found, otherwise `nil`.
    public mutating func remove(value: T) -> T? {
        if let index = indexOf(value) {
            return contents.removeAtIndex(index)
        }
        return nil
    }
    
    /// Removes and returns the item at `index`. Requires count > 0.
    public mutating func removeAtIndex(index: Int) -> T {
        return contents.removeAtIndex(index)
    }
    
    /// Removes all elements from the collection.
    public mutating func removeAll(keepCapacity: Bool = true) {
        contents.removeAll(keepCapacity: keepCapacity)
    }
}

// MARK: SequenceType

extension SortedSlice : SequenceType {
    typealias Generator = GeneratorOf<T>
    
    /// Returns a generator of the elements of the collection.
    public func generate() -> Generator {
        return GeneratorOf(contents.generate())
    }
}

// MARK: CollectionType

extension SortedSlice : CollectionType {
    typealias Index = Int
    
    /// The position of the first element in the collection. (Always zero.)
    public var startIndex: Int {
        return 0
    }
    
    /// One greater than the position of the last element in the collection. Zero when the collection is empty.
    public var endIndex: Int {
        return count
    }
    
    /// Accesses the element at index `i`.
    ///
    /// Read-only to ensure sorting - use `insert` to add new elements.
    public subscript(i: Int) -> T {
        return contents[i]
    }
}

// MARK: ArrayLiteralConvertible

extension SortedSlice : ArrayLiteralConvertible {
    public init(arrayLiteral elements: T...) {
        self.contents = ArraySlice(sorted(elements))
    }
}

// MARK: Sliceable

extension SortedSlice : Sliceable {
    typealias SubSlice = SortedSlice<T>
    
    /// Access the elements in the given range.
    public subscript(range: Range<Int>) -> SortedSlice<T> {
        return SortedSlice(sortedSlice: contents[range])
    }
}


// MARK: Equatable

public func ==<S: SortedCollectionType where S.Generator.Element : Equatable>(lhs: S, rhs: S) -> Bool {
    if count(lhs) != count(rhs) {
        return false
    }
    
    for (lhs, rhs) in zip(lhs, rhs) {
        if lhs != rhs {
            return false
        }
    }
    
    return true
}


// MARK: - Private helper functions

/// Returns the insertion point for `value` in the collection `c`.
///
/// Precondition: The collection `c` is sorted in ascending order.
///
/// If `value` exists at least once in `c`, the returned index will point to the
/// first instance of `value`. Otherwise, it will point to the location where `value`
/// could be inserted, keeping `c` in order.
///
/// :returns: An index in the range `0...countElements(c)` where `value` can be inserted.
private func _insertionIndex<C: CollectionType, T: Comparable
    where C.Generator.Element == T, C.Index == Int>(c: C, forValue value: T) -> Int
{
    if isEmpty(c) {
        return 0
    }
    
    var (low, high) = (0, c.endIndex - 1)
    var mid = 0
    
    while low < high {
        mid = (high - low) / 2 + low
        if c[mid] < value {
            low = mid + 1
        } else {
            high = mid
        }
    }
    
    if c[low] >= value {
        return low
    }
    
    return c.endIndex
}
