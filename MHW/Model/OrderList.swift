//
//  OrderList.swift
//  MHW
//
//  Created by Jeff Eom on 2018-04-10.
//  Copyright © 2018 Jeff Eom. All rights reserved.
//

import Foundation

enum OrderList {
  case order1_1, order1_2, order2_1, order2_2, melded, notSet
  func next() -> OrderList?{
    switch self {
    case .order1_1:
      return .order1_2
    case .order1_2:
      return .order2_1
    case .order2_1:
      return .order2_2
    case .order2_2:
      return .order1_1
    case .melded, .notSet:
      return nil
    }
  }
  
  func previous() -> OrderList?{
    switch self {
    case .order1_1:
      return .order2_2
    case .order1_2:
      return .order1_1
    case .order2_1, .order2_2:
      return .order1_2
    case .melded, .notSet:
      return nil
    }
  }
  
  func text() -> String {
    switch self {
    case .order1_1:
      return "1-1"
    case .order1_2:
      return "1-2"
    case .order2_1, .order2_2:
      return "2"
    case .melded:
      return "MELDED"
    case .notSet:
      return "X"
    }
  }
  
  static func from(string: String) -> OrderList {
    switch string {
    case "1-1":
      return .order1_1
    case "1-2":
      return .order1_2
    case "2-1", "2":
      return .order2_1
    case "2-2":
      return .order2_2
    case "MELDED":
      return .melded
    default:
      return .notSet
    }
  }
}
