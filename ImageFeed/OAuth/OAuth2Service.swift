import UIKit

class OAuth2Service {
  
    func makeOAuthTokenRequest( code: String ) -> URLRequest? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "unsplash.com"
        components.path = "/oauth/token"
        
        components.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "client_secret", value: Constants.secretKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "grant_type", value: "authorization_code")
        ]
        
        guard let url = components.url else {
            return nil
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        return request
    }
    func fetchOAuthToken ( code: String, completion: @escaping (Result<Data, Error>)-> Void) {
        guard let reguest = makeOAuthTokenRequest(code: code) else {
            completion(.failure(NSError(domain: "Ошибка URL", code: 0, userInfo: nil)))
            return
        }
        let task = URLSession.shared.data(for: reguest ) { result in
            completion(result)
        }
        task.resume()
    }
}
