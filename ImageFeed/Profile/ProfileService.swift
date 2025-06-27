import UIKit


final class ProfileService {
    static let shared = ProfileService()
       private init () {}
    
    private(set) var profile: Profile?
    
    func fetchProfile( token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        
        guard let request = profileData(with: token) else {
            print("нету запроса URLRequest")
            return
        }
        
        func profileData( with token: String) -> URLRequest? {
            
            var components = URLComponents()
            components.scheme = "https"
            components.host = "api.unsplash.com"
            components.path = "/me"
            
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
                let profileResult = try decoder.decode(ProfileResult.self, from: data)
                
                self.profile = Profile(userName: profileResult.username ?? "Нету данных",
                                      firstName: profileResult.firstName ?? "Гость",
                                      lastName: profileResult.lastName ?? "",
                                      bio: profileResult.bio ?? ""
                )
                guard let profile = self.profile else { return }
                completion(.success(profile))
                print("Профиль успешно загружен.")
            } catch {
                completion(.failure(error))
                print("Ошибка декодирования JSON: \(error.localizedDescription)")
            }
            
        }
        task.resume()
        
    }
    
}

