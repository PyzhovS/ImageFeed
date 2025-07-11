import UIKit

struct PhotoResult: Codable {
    let id: String
    let width: Int
    let height: Int
    let createdAt: Date?
    let description: String?
    let urls: UrlsResult
    let likedByUser: Bool
    
    struct UrlsResult: Codable {
        let thumb: String
        let regular: String
        
    }
}
