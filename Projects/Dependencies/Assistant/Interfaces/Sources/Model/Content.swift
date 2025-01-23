public struct Content: Codable {
    var type: `Type`
    var text: Text
    
    public enum `Type`: String, Codable {
        case text = "text"
        // TODO: Support `image_file`, `image_url`, `refusal`
    }
    
    public struct Text: Codable {
        var value: String
        var annotations: [Annotations]
        
        public struct Annotations: Codable { }
    }
    
}
