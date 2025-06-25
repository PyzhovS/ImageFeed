import UIKit

final class ProfileImageService {
    static let shared = ProfileImageService()
    private init () {}
    
    private let oAuth2TokenStorage = OAuth2TokenStorage.shared
    
    
    private (set) var avatarURL: String?
    
    func fetchProfileImageURL(username: String, _ completion: @escaping (Result<String, Error>) -> Void){
        
        guard let token = oAuth2TokenStorage.token else { return}
        guard let request = profileImage(with: token) else {
            print("нету запроса URLRequest")
            return
        }
        
        func profileImage( with token: String) -> URLRequest? {
            
            var components = URLComponents()
            components.scheme = "https"
            components.host = "api.unsplash.com"
            components.path = "/users/:\(username)"
            
            guard let url = components.url else {
                print("нет верного url для запроса")
                return nil
            }
            var request = URLRequest(url: url)
            request.httpMethod = HTTPMethod.get.rawValue
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            return request
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
             
            if let error = error {
                completion(.failure(error))
                print("Ошибка при получении данных: \(error.localizedDescription)")
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                completion(.failure(NetworkError.urlSessionError))
                print("Ошибка: 401 Unauthorized")
                return
            }
            
            guard let data = data else {
                completion(.failure(NetworkError.urlSessionError))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let userResult = try decoder.decode(UserResult.self, from: data)
                
                self.avatarURL = userResult.profileImage ?? "Аватар не загружен"
                
                guard let avatarURL = self.avatarURL else { return }
                completion(.success(avatarURL))
                print("Профиль успешно загружен.")
            } catch {
                completion(.failure(error))
                print("Ошибка декодирования JSON: \(error.localizedDescription)")
            }
        }
        
        task.resume()
    }
}
