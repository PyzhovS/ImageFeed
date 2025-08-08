import Foundation
import UIKit

protocol ImagesListViewPresenterProtocol {
    var photos: [Photo] {get set}
    func willDisplayCell(at indexPath: IndexPath)
    func viewDidLoad()
    func calculateCellHeight(for indexPath: IndexPath, tableView: UITableView) -> CGFloat
    func changeLike(at indexPath: IndexPath, isLikes: Bool)
}

final class ImagesListViewPresenter: ImagesListViewPresenterProtocol {
    private let service: ImagesListService
    weak var view: ImagesListViewProtocol?
    var photos: [Photo] = []
    
    init(service: ImagesListService, view: ImagesListViewProtocol) {
        self.service = service
        self.view = view
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setupObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleServiceUpdate),
            name: ImagesListService.didChangeNotification,
            object: nil
        )
    }
    @objc private func handleServiceUpdate() {
        let oldCount = photos.count
        let newCount = service.photos.count
        photos = service.photos
        if oldCount != newCount {
            view?.updateTableViewAnimated(oldCount: oldCount, newCount: newCount)
        }
    }
    func willDisplayCell(at indexPath: IndexPath) {
        if indexPath.row + 1 == photos.count {
            service.fetchPhotosNextPage()
        }
    }
    func viewDidLoad() {
        service.fetchPhotosNextPage()
        setupObservers()
    }
    func calculateCellHeight(for indexPath: IndexPath, tableView: UITableView) -> CGFloat {
        let photo = photos[indexPath.row]
        let imageSet = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let scale = (tableView.bounds.width - imageSet.left - imageSet.right) / photo.size.width
        let cellHeight = photo.size.height * scale + imageSet.top + imageSet.bottom
        return cellHeight
    }
    func changeLike(at indexPath: IndexPath, isLikes: Bool) {
        var photo = self.photos[indexPath.row]
        
        photo.isLiked = isLikes
        self.photos[indexPath.row] = photo
        
        self.view?.blockProgressHUDOn()
        
        service.changeLike(photoId: photo.id, indexPatch: indexPath, isLike: isLikes) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self.photos = self.service.photos
                    self.view?.updatePhoto(at: indexPath)
                    
                case .failure:
                    print("ошибка возврат ячейки")
                    photo.isLiked = !isLikes
                    self.photos[indexPath.row] = photo
                }
                
                self.view?.blockProgressHUDOff()
            }
        }
    }
    
}
