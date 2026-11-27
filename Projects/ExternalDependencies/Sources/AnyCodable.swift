// Helper for dynamic types in dictionaries
public struct AnyCodable: Codable {
    public let value: Any
    
    public init(_ value: Any) {
        self.value = value
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let intValue = try? container.decode(Int.self) {
            self.value = intValue
        } else if let doubleValue = try? container.decode(Double.self) {
            self.value = doubleValue
        } else if let stringValue = try? container.decode(String.self) {
            self.value = stringValue
        } else if let boolValue = try? container.decode(Bool.self) {
            self.value = boolValue
        } else if let arrayValue = try? container.decode([AnyCodable].self) {
            self.value = arrayValue.map { $0.value }
        } else if let dictionaryValue = try? container.decode([String: AnyCodable].self) {
            self.value = dictionaryValue.mapValues { $0.value }
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Value cannot be decoded")
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        if let intValue = value as? Int {
            try container.encode(intValue)
        } else if let doubleValue = value as? Double {
            try container.encode(doubleValue)
        } else if let stringValue = value as? String {
            try container.encode(stringValue)
        } else if let boolValue = value as? Bool {
            try container.encode(boolValue)
        } else if let arrayValue = value as? [Any] {
            try container.encode(arrayValue.map { AnyCodable($0) })
        } else if let dictionaryValue = value as? [String: Any] {
            try container.encode(dictionaryValue.mapValues { AnyCodable($0) })
        } else {
            throw EncodingError.invalidValue(value, EncodingError.Context(codingPath: container.codingPath, debugDescription: "Value cannot be encoded"))
        }
    }
}
