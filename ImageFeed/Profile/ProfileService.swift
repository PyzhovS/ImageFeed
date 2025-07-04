import UIKit

final class ProfileService {
    static let shared = ProfileService()
    private init () {}
    
    private(set) var profile: Profile?
    private let urlSession = URLSession.shared
    
    func fetchProfile( token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        
        guard let request = profileData(with: token) else {
            print("[makeOAuthTokenRequest] - Ошибка запроса URLRequest ")
            return
        }
        
        func profileData( with token: String) -> URLRequest? {
            
            var components = URLComponents()
            components.scheme = "https"
            components.host = "api.unsplash.com"
            components.path = "/me"
            
            guard let url = components.url else {
                print("[profileData] - Нет верного запроса url ")
                return nil
            }
            var request = URLRequest(url: url)
            request.httpMethod = HTTPMethod.get.rawValue
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            return request
        }
        
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<ProfileResult, Error>) in
            switch result {
            case .success(let profileResult):
                self?.profile = Profile(userName: profileResult.username ?? "Нету данных",
                                        firstName: profileResult.firstName ?? "Гость",
                                        lastName: profileResult.lastName ?? "",
                                        bio: profileResult.bio ?? ""
                )
                guard let profile = self?.profile else { return }
                completion(.success(profile))
                print("[urlSession] - Профиль получен")
            case.failure(let error):
                completion(.failure(error))
                print("[urlSession] - Ошибка получение профиля: \(error) ")
            }
        }
        task.resume()
    }
}
