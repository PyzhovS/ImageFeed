import UIKit
import Kingfisher

final class ProfileImageService {
    static let shared = ProfileImageService()
    private init () {}
    
    static let didChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")
    private let oAuth2TokenStorage = OAuth2TokenStorage.shared
    private (set) var avatarURL: String?
    private let urlSession = URLSession.shared
    var image = UIImage()
    
    func fetchProfileImageURL(username: String, _ completion: @escaping (Result<String, Error>) -> Void){
        print("имя пользователя \(username)")
        
        guard let token = oAuth2TokenStorage.token else { return}
        guard let request = profileImage(with: token) else {
            print("[fetchProfileImageURL] - Ошибка нету запроса URLRequest ")
            return
        }
        
        func profileImage( with token: String) -> URLRequest? {
            
            var components = URLComponents()
            components.scheme = "https"
            components.host = "api.unsplash.com"
            components.path = "/users/\(username)"
            
            guard let url = components.url else {
                print("[fetchProfileImageURL] - Ошибка нет верного url для запроса ")
                return nil
            }
            var request = URLRequest(url: url)
            request.httpMethod = HTTPMethod.get.rawValue
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            return request
        }
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<UserResult, Error>) in
            switch result {
            case.success(let userResult):
                self?.avatarURL = userResult.profileImage.small
                guard let avatarURL = self?.avatarURL else { return }
               
                completion(.success(avatarURL))
                print("[fetchProfileImageURL] - Аватарка успешна загружена.")
                NotificationCenter.default
                    .post(name: ProfileImageService.didChangeNotification,
                          object: self,
                          userInfo: ["URL": avatarURL])
         
                Task { @MainActor in
                    guard let self else {return}
                    self.profileImage()}
                
            case.failure(let error):
                completion(.failure(error))
                print("[fetchProfileImageURL] - Ошибка декодирования JSON: \(error.localizedDescription)")
            }
        }
        task.resume()
    }
    @MainActor func profileImage() {
        let processor = RoundCornerImageProcessor(cornerRadius: 25)
        let rect = CGRect(x: 0, y: 0, width: 350, height: 400)
        let imageView = UIImageView(frame: rect)
        imageView.clipsToBounds = true
        guard let avatarURL = avatarURL, let imageUrl = URL(string: avatarURL) else { return }
        KingfisherManager.shared.cache.clearMemoryCache()
        KingfisherManager.shared.cache.clearDiskCache()
        imageView.kf.setImage(with: imageUrl,
                              placeholder: UIImage(named: "Stub.jpeg"),
                              options: [.processor(processor)]) { result in
            switch result {
            case .success(let value):
                self.image = value.image
                print(value.image)
                print(value.cacheType)
                print(value.source)
                
            case .failure(let error):
                print(error)
                
            }
        }
    }
}
