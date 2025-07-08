import UIKit

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

enum AuthServiceError: Error {
    case invalidRequest
}

final class OAuth2Service {
    private let urlSession = URLSession.shared
    static let shared = OAuth2Service()
    private var task: URLSessionTask?
    private var lastCode: String?
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
            print("[makeOAuthTokenRequest] - Ошибка запроса не верный URl ")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.post.rawValue
        return request
    }
    func fetchOAuthToken ( code: String, completion: @escaping (Result<String, Error>)-> Void) {
        assert(Thread.isMainThread)
        guard lastCode != code else {
            completion(.failure(AuthServiceError.invalidRequest))
            print("[fetchOAuthToken] - Ошибка запроса повторный код \(code) ")
            return
            
        }
        task?.cancel()
        lastCode = code
        
        guard let request = makeOAuthTokenRequest(code: code) else {
            completion(.failure(AuthServiceError.invalidRequest))
            print("[fetchOAuthToken] - Ошибка запроса, не удалось создать запрос с кодом \(code)")
            
            return
        }
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<OAuthTokenResponseBody, Error>) in defer {
            self?.task = nil
            self?.lastCode = nil
        }
            switch result {
            case .success(let response):
                completion(.success(response.accessToken))
                
            case .failure(let error):
                completion(.failure(error))
                print("[fetchOAuthToken] - Ошибка сети - \(error.localizedDescription)с кодом: \(code)")
            }
        }        
        self.task = task
        task.resume()
    }
}
