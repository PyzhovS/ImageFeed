import UIKit

final class ImagesListService {
    private var lastLoadedPage: Int?
    private(set) var photos: [Photo] = []
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
            URLQueryItem(name: "per_page", value: "1")
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
                                isLiked: result.likedByUser)
                }
                print("[photoResults] -  получены фотографии")
                
                DispatchQueue.main.async {
                    self?.photos.append(contentsOf: newPhotos)
                    NotificationCenter.default.post(name: ImagesListService.didChangeNotification, object: nil)
                    self?.lastLoadedPage = nextPage
                    print(self?.photos[0].isLiked)
                    print(self?.photos[0].id)
                    print(self?.photos[0].largeImageURL)
                    print(self?.photos[0].welcomeDescription)
                    print(self?.photos[0].createdAt)
                    print(self?.photos[0].size)
                }
                
            case.failure(let error):
                print("[fetchProfileImageURL] - Ошибка декодирования JSON: \(error.localizedDescription)")
            }
          
        }
        task.resume()
        
    }
}
