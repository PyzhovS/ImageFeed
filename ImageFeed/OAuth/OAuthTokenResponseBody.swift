import Foundation

struct OAuthTokenResponseBody: Decodable {
    var accessToken: Data
 
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
    }
    
}
