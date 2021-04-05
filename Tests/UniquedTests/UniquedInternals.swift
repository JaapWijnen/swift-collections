//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift Collections open source project
//
// Copyright (c) 2021 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

import CollectionsTestSupport
@_spi(Testing) import UniquedModule

struct UniquedLayout: Hashable, CustomStringConvertible {
  let scale: Int
  let bias: Int
  let count: Int

  var description: String {
    "UniquedLayout(scale: \(scale), bias: \(bias), count: \(count))"
  }
}

func withUniquedLayouts(
  scales: [Int],
  file: StaticString = #file,
  line: UInt = #line,
  run body: (UniquedLayout) throws -> Void
) rethrows {
  for scale in scales {
    for count in _interestingCounts(forScale: scale) {
      for bias in _interestingBiases(forScale: scale) {
        let layout = UniquedLayout(scale: scale, bias: bias, count: count)
        let entry = TestContext.current.push("layout: \(layout)")
        defer { TestContext.current.pop(entry) }
        try body(layout)
      }
    }
  }
}

func _interestingCounts(forScale scale: Int) -> [Int] {
  precondition(scale == 0 || scale >= _UnsafeHashTable.minimumScale)
  let min = _UnsafeHashTable.minimumCapacity(forScale: scale)
  let max = _UnsafeHashTable.maximumCapacity(forScale: scale)
  return [min, min + (max - min) / 2, max]
}

func _interestingBiases(forScale scale: Int) -> [Int] {
  // If we have no hash table, we can only use a bias of 0.
  if scale < _UnsafeHashTable.minimumScale { return [0] }
  let range = _UnsafeHashTable.biasRange(scale: scale)
  // For the minimum scale, try all biases.
  if scale == _UnsafeHashTable.minimumScale { return Array(range) }
  // Otherwise try 3 biases each from the start, middle, and end of range.
  var result: [Int] = []
  result += range.prefix(3)
  result += range.prefix(range.count / 2 + 1).suffix(3)
  result += range.suffix(3)
  return result
}

extension Uniqued {
  init(layout: UniquedLayout, contents: Base) {
    self.init(_scale: layout.scale, bias: layout.bias, contents: contents)
  }
}

extension Uniqued where Base: RangeReplaceableCollection {
  init<C: Collection>(layout: UniquedLayout, contents: C)
  where C.Element == Element {
    self.init(_scale: layout.scale, bias: layout.bias, contents: contents)
  }
}

extension Uniqued where Element == Int, Base: RangeReplaceableCollection {
  init(layout: UniquedLayout) {
    self.init(layout: layout, contents: 0 ..< layout.count)
  }
}
