import UIKit

protocol PhotoDeleteDelegate{
  var photos: [Photo] {set get }
}

final class ImagesListService: PhotoDeleteDelegate {
    
    private var lastLoadedPage: Int?
    var photos: [Photo] = []
    private let oAuth2TokenStorage = OAuth2TokenStorage.shared
    private let urlSession = URLSession.shared
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    
    func fetchPhotosNextPage() {
        guard let token = oAuth2TokenStorage.token else { return}
        let nextPage = (self.lastLoadedPage ?? 0) + 1
        print("next page: \(nextPage)")
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.unsplash.com"
        components.path = "/photos"
        components.queryItems = [
            URLQueryItem(name: "page", value: "\(nextPage)"),
            URLQueryItem(name: "per_page", value: "10")
        ]
        
        guard let url = components.url else {
            print("[fetchPhotosNextPage] - Ошибка нет верного url для запроса ")
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.get.rawValue
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<[PhotoResult], Error>) in
            switch result {
            case.success(let photoResults):
                let newPhotos = photoResults.map {result -> Photo in
                    let size = CGSize(width: result.width, height: result.height)
                    return Photo(id: result.id,
                                 size: size,
                                 createdAt: result.createdAt,
                                 welcomeDescription: result.description,
                                 thumbImageURL: result.urls.thumb,
                                 largeImageURL: result.urls.regular,
                                 fullUmageUrl: result.urls.full,
                                 isLiked: result.likedByUser)
                }
                print("[photoResults] -  получены фотографии")
                
                DispatchQueue.main.async {
                    self?.photos.append(contentsOf: newPhotos)
                    NotificationCenter.default.post(name: ImagesListService.didChangeNotification, object: nil)
                    self?.lastLoadedPage = nextPage
                }
                
            case.failure(let error):
                print("[fetchProfileImageURL] - Ошибка декодирования JSON: \(error.localizedDescription)")
            }
        }
        task.resume()
    }
    
    func changeLike(photoId: String, indexPatch: IndexPath, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {
        
        guard let token = oAuth2TokenStorage.token else { return}
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.unsplash.com"
        components.path = "/photos/\(photoId)/like"
        
        guard let url = components.url else {
            print("[changeLike] - Нет верного запроса url ")
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = isLike ? HTTPMethod.post.rawValue : HTTPMethod.delete.rawValue
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let task = urlSession.dataTask(with: request) { data, response, error in
            if let error = error {
                print("[changeLike] - Ошибка сети: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("[changeLike] - Код ответа: \(httpResponse.statusCode)")
            }
            
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                if let data = data, let responseBody = String(data: data, encoding: .utf8) {
                    print("[changeLike] - Ошибка сервера: \(responseBody)")
                }
                completion(.failure(NSError(domain: "Invalid response", code: 500, userInfo: nil)))
                return
            }
            DispatchQueue.main.async {
                if let index = self.photos.firstIndex(where: { $0.id == photoId }) {
                    let photo = self.photos[index]
                    let newPhoto = Photo(
                        id: photo.id,
                        size: photo.size,
                        createdAt: photo.createdAt,
                        welcomeDescription: photo.welcomeDescription,
                        thumbImageURL: photo.thumbImageURL,
                        largeImageURL: photo.largeImageURL,
                        fullUmageUrl: photo.fullUmageUrl,
                        isLiked: !photo.isLiked
                    )
                    self.photos[index] = newPhoto
                }
            }
            completion(.success(()))
        }
        task.resume()
    }
}
