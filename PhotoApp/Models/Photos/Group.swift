//
//  Group.swift
//
//  Created by Alaattin Bedir on 14.08.2018
//  Copyright (c) . All rights reserved.
//

import Foundation
import ObjectMapper

public class Group: Mappable {

  // MARK: Declaration for string constants to be used to decode and also serialize.
  private struct SerializationKeys {
    static let name = "name"
    static let id = "id"
    static let phone = "phone"
  }

  // MARK: Properties
  public var name: String?
  public var id: Int?
  public var phone: String?

  // MARK: ObjectMapper Initializers
  /// Map a JSON object to this class using ObjectMapper.
  ///
  /// - parameter map: A mapping from ObjectMapper.
  public required init?(map: Map){

  }

  /// Map a JSON object to this class using ObjectMapper.
  ///
  /// - parameter map: A mapping from ObjectMapper.
  public func mapping(map: Map) {
    name <- map[SerializationKeys.name]
    id <- map[SerializationKeys.id]
    phone <- map[SerializationKeys.phone]
  }

  /// Generates description of the object in the form of a NSDictionary.
  ///
  /// - returns: A Key value pair containing all valid values in the object.
  public func dictionaryRepresentation() -> [String: Any] {
    var dictionary: [String: Any] = [:]
    if let value = name { dictionary[SerializationKeys.name] = value }
    if let value = id { dictionary[SerializationKeys.id] = value }
    if let value = phone { dictionary[SerializationKeys.phone] = value }
    return dictionary
  }

}
