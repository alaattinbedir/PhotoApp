//
//  Photos.swift
//
//  Created by Alaattin Bedir on 14.08.2018
//  Copyright (c) . All rights reserved.
//

import Foundation
import ObjectMapper


public class Photo: Mappable {

  // MARK: Declaration for string constants to be used to decode and also serialize.
  private struct SerializationKeys {
    static let name = "name"
    static let startsat = "startsat"
    static let modified = "modified"
    static let premium = "premium"
    static let id = "id"
    static let timezone = "timezone"
    static let created = "created"
    static let group = "group"
    static let endsat = "endsat"
  }

  // MARK: Properties
  public var name: String?
  public var startsat: String?
  public var modified: String?
  public var premium: Bool? = false
  public var id: Int?
  public var timezone: Int?
  public var created: String?
  public var group: Group?
  public var endsat: String?

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
    startsat <- map[SerializationKeys.startsat]
    modified <- map[SerializationKeys.modified]
    premium <- map[SerializationKeys.premium]
    id <- map[SerializationKeys.id]
    timezone <- map[SerializationKeys.timezone]
    created <- map[SerializationKeys.created]
    group <- map[SerializationKeys.group]
    endsat <- map[SerializationKeys.endsat]
  }

  /// Generates description of the object in the form of a NSDictionary.
  ///
  /// - returns: A Key value pair containing all valid values in the object.
  public func dictionaryRepresentation() -> [String: Any] {
    var dictionary: [String: Any] = [:]
    if let value = name { dictionary[SerializationKeys.name] = value }
    if let value = startsat { dictionary[SerializationKeys.startsat] = value }
    if let value = modified { dictionary[SerializationKeys.modified] = value }
    dictionary[SerializationKeys.premium] = premium
    if let value = id { dictionary[SerializationKeys.id] = value }
    if let value = timezone { dictionary[SerializationKeys.timezone] = value }
    if let value = created { dictionary[SerializationKeys.created] = value }
    if let value = group { dictionary[SerializationKeys.group] = value.dictionaryRepresentation() }
    if let value = endsat { dictionary[SerializationKeys.endsat] = value }
    return dictionary
  }

}
