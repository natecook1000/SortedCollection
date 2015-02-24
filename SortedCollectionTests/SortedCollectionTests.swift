//
//  SortedCollectionTests.swift
//
//  Created by Nate Cook on 2/23/15.
//  Copyright (c) 2015 Nate Cook. Available under the MIT license.
//

import SortedCollection
import XCTest

class SortedCollectionTests: XCTestCase {
    
    /// TODO: Add tests :)
    
    func testThings() {
        let attendees = SortedCollection(["Eddie", "Julianne", "J.K.", "Patricia", "Alejandro"])
        
        XCTAssertEqual(attendees[0], "Alejandro")
        XCTAssertEqual(attendees.count, 5)
        
        var sortedNumbers = SortedCollection<Int>()
        sortedNumbers.insert(12)
        sortedNumbers.insert(stride(from: 0, through: 25, by: 5))
        
        XCTAssertEqual(sortedNumbers.count, 7)
        XCTAssert(sortedNumbers.contains(12))
        XCTAssertFalse(sortedNumbers.contains(3))
        
        sortedNumbers.insert(5, 6, 7, 8, 9)
        sortedNumbers.insert(12)
        sortedNumbers.insert(0)
        sortedNumbers.insert(9)
        sortedNumbers.insert(9)
        sortedNumbers.insert(9)
        sortedNumbers.insert(9)
        sortedNumbers.insert(9)
        sortedNumbers.insert(500)
        sortedNumbers.insert(-5)
        
        XCTAssert(isSorted(sortedNumbers))
        XCTAssert(sortedNumbers.contains(9))
        
        while nil != sortedNumbers.remove(9) { }

        XCTAssertFalse(sortedNumbers.contains(9))
    }
    
    func testInsertPerformance() {
        func getRandomArray(count: Int) -> [Int] {
            var result: [Int] = []
            for _ in 0..<count {
                result.append(Int(arc4random_uniform(10000)))
            }
            return result
        }
        
        let size = 1000
        let bigArray = getRandomArray(size)
        var bigSC1 = SortedCollection(getRandomArray(size))

        measureBlock {
            bigSC1.insert(bigArray)
        }
    }
}


/// Returns true iff the sequnce given in `seq` is sorted in ascending order.
private func isSorted<S: SequenceType where S.Generator.Element: Comparable>(seq: S) -> Bool {
    var last: S.Generator.Element?
    for element in seq {
        if element < last {
            return false
        }
        last = element
    }
    
    return true
}

