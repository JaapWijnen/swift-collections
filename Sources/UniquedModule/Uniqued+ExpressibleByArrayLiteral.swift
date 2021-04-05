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

extension Uniqued: ExpressibleByArrayLiteral where Base: RangeReplaceableCollection
{
  // Note: we need the `RangeReplaceableCollection` conformance to be able to
  // de-dupe contents & convert the input array into `Base`.

  public init(arrayLiteral elements: Element...) {
    self.init(elements)
  }
}
