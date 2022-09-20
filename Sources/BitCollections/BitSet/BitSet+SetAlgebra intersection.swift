//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift Collections open source project
//
// Copyright (c) 2021-2022 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

extension BitSet {
  /// Returns a new bit set with the elements that are common to both this set
  /// and the given set.
  ///
  ///     let a: BitSet = [1, 2, 3, 4]
  ///     let b: BitSet = [6, 4, 2, 0]
  ///     let c = a.intersection(b)
  ///     // c is now [2, 4]
  ///
  /// - Parameter other: A bit set.
  ///
  /// - Complexity: O(*max*), where *max* is the largest item in either set.
  public __consuming func intersection(_ other: Self) -> Self {
    self._read { first in
      other._read { second in
        Self(
          _combining: (first, second),
          includingTail: false,
          using: { $0.intersection($1) })
      }
    }
  }

  /// Returns a new bit set with the elements that are common to both this set
  /// and the given sequence.
  ///
  ///     let a: BitSet = [1, 2, 3, 4]
  ///     let b = [6, 4, 2, 0]
  ///     let c = a.intersection(b)
  ///     // c is now [2, 4]
  ///
  /// - Parameter other: A sequence of integer values.
  ///
  /// - Complexity: O(*max*) + *k*, where *max* is the largest item in `self`,
  ///    and *k* is the complexity of iterating over all elements in `other`.
  @inlinable
  public __consuming func intersection<S: Sequence>(
    _ other: __owned S
  ) -> Self
  where S.Element == Int
  {
    if S.self == Self.self {
      return intersection(other as! BitSet)
    }
    if S.self == Range<Int>.self {
      return intersection(other as! Range<Int>)
    }
    return intersection(BitSet(_validMembersOf: other))
  }

  /// Returns a new bit set with the elements that are common to both this set
  /// and the given range of integers.
  ///
  ///     let a: BitSet = [1, 2, 3, 4]
  ///     let c = a.intersection(-10 ..< 3)
  ///     // c is now [3, 4]
  ///
  /// - Parameter other: A range of integers.
  ///
  /// - Complexity: O(*max*) + *k*, where *max* is the largest item in `self`,
  ///    and *k* is the complexity of iterating over all elements in `other`.
  public __consuming func intersection(_ other: Range<Int>) -> Self {
    var result = self
    result.formIntersection(other)
    return result
  }
}
