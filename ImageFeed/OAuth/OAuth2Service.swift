import UIKit

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

final class OAuth2Service {
    static let shared = OAuth2Service()
    private init() {}
    
    // MARK: - Setup Methods
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
            print("нет верного url для запроса")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.post.rawValue
        return request
    }
    func fetchOAuthToken ( code: String, completion: @escaping (Result<String, Error>)-> Void) {
        guard let request = makeOAuthTokenRequest(code: code) else {
            completion(.failure(NSError(domain: "Ошибка URL", code: 0, userInfo: nil)))
            print("Ошибка при созданий URLRequest")
            return
        }
        let task = URLSession.shared.data(for: request) { result in
            switch result {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let response = try decoder.decode(OAuthTokenResponseBody.self, from: data)
                    completion(.success(response.accessToken))
                    print("Декодирование JSON прошло успешно")
                } catch {
                    completion(.failure(NetworkError.urlSessionError))
                    print("Ошибка не удалось декодировть JSON: \(error.localizedDescription)")
                }
            case .failure(let error):
                completion(.failure(error))
                print("Ошибка при получении запроса URLSession.shared.data: \(error.localizedDescription)")
            }
        }
        
        task.resume()
    }
}
