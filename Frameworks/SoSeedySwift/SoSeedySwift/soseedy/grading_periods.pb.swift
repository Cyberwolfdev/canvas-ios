// DO NOT EDIT.
//
// Generated by the Swift generator plugin for the protocol buffer compiler.
// Source: grading_periods.proto
//
// For information on using the generated types, please see the documenation:
//   https://github.com/apple/swift-protobuf/

import Foundation
import SwiftProtobuf

// If the compiler emits an error on this type, it is because this file
// was generated by a version of the `protoc` Swift plug-in that is
// incompatible with the version of SwiftProtobuf to which you are linking.
// Please ensure that your are building against the same version of the API
// that was used to generate this file.
fileprivate struct _GeneratedWithProtocGenSwiftVersion: SwiftProtobuf.ProtobufAPIVersionCheck {
  struct _2: SwiftProtobuf.ProtobufAPIVersion_2 {}
  typealias Version = _2
}

public struct Soseedy_CreateGradingPeriodSetRequest {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  public var enrollmentID: Int64 = 0

  public var unknownFields = SwiftProtobuf.UnknownStorage()

  public init() {}
}

public struct Soseedy_CreateGradingPeriodRequest {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  public var gradingPeriodSetID: Int64 = 0

  public var unknownFields = SwiftProtobuf.UnknownStorage()

  public init() {}
}

public struct Soseedy_GradingPeriodSet {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  public var id: Int64 = 0

  public var unknownFields = SwiftProtobuf.UnknownStorage()

  public init() {}
}

public struct Soseedy_GradingPeriod {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  public var id: Int64 = 0

  public var unknownFields = SwiftProtobuf.UnknownStorage()

  public init() {}
}

// MARK: - Code below here is support for the SwiftProtobuf runtime.

fileprivate let _protobuf_package = "soseedy"

extension Soseedy_CreateGradingPeriodSetRequest: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = _protobuf_package + ".CreateGradingPeriodSetRequest"
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "enrollmentId"),
  ]

  public mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      switch fieldNumber {
      case 1: try decoder.decodeSingularInt64Field(value: &self.enrollmentID)
      default: break
      }
    }
  }

  public func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if self.enrollmentID != 0 {
      try visitor.visitSingularInt64Field(value: self.enrollmentID, fieldNumber: 1)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  public func _protobuf_generated_isEqualTo(other: Soseedy_CreateGradingPeriodSetRequest) -> Bool {
    if self.enrollmentID != other.enrollmentID {return false}
    if unknownFields != other.unknownFields {return false}
    return true
  }
}

extension Soseedy_CreateGradingPeriodRequest: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = _protobuf_package + ".CreateGradingPeriodRequest"
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "gradingPeriodSetId"),
  ]

  public mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      switch fieldNumber {
      case 1: try decoder.decodeSingularInt64Field(value: &self.gradingPeriodSetID)
      default: break
      }
    }
  }

  public func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if self.gradingPeriodSetID != 0 {
      try visitor.visitSingularInt64Field(value: self.gradingPeriodSetID, fieldNumber: 1)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  public func _protobuf_generated_isEqualTo(other: Soseedy_CreateGradingPeriodRequest) -> Bool {
    if self.gradingPeriodSetID != other.gradingPeriodSetID {return false}
    if unknownFields != other.unknownFields {return false}
    return true
  }
}

extension Soseedy_GradingPeriodSet: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = _protobuf_package + ".GradingPeriodSet"
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "id"),
  ]

  public mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      switch fieldNumber {
      case 1: try decoder.decodeSingularInt64Field(value: &self.id)
      default: break
      }
    }
  }

  public func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if self.id != 0 {
      try visitor.visitSingularInt64Field(value: self.id, fieldNumber: 1)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  public func _protobuf_generated_isEqualTo(other: Soseedy_GradingPeriodSet) -> Bool {
    if self.id != other.id {return false}
    if unknownFields != other.unknownFields {return false}
    return true
  }
}

extension Soseedy_GradingPeriod: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = _protobuf_package + ".GradingPeriod"
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "id"),
  ]

  public mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      switch fieldNumber {
      case 1: try decoder.decodeSingularInt64Field(value: &self.id)
      default: break
      }
    }
  }

  public func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if self.id != 0 {
      try visitor.visitSingularInt64Field(value: self.id, fieldNumber: 1)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  public func _protobuf_generated_isEqualTo(other: Soseedy_GradingPeriod) -> Bool {
    if self.id != other.id {return false}
    if unknownFields != other.unknownFields {return false}
    return true
  }
}
