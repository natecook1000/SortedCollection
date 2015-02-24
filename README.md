# SortedCollection

This Swift framework provides two types and a protocol, built to demonstrate [Swift collection protocols](http://nshipster.com/swift-collection-protocols).


## Included Types

- `SortedCollection`: An always-sorted collection of `Comparable` elements. Performance should be *O(N log N)* when adding to the collection, *O(log N)* for lookups, and *O(1)* for iteration or random element access.
- `SortedSlice`: A slice of a `SortedCollection`.
- `SortedCollectionType`: A protocol describing a collection whose elements are guaranteed to always be in ascending order.


## License

SwiftSets is (c) 2015 Nate Cook and available under the MIT license.
