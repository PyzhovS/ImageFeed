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
      var view: ImagesListViewProtocol?
    var photos: [Photo] = []
    
    
    
    init(service: ImagesListService) {
        self.service = service
        setupObservers()
        
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
    }
    func calculateCellHeight(for indexPath: IndexPath, tableView: UITableView) -> CGFloat {
        let photo = photos[indexPath.row]
        let imageSet = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let scale = (tableView.bounds.width - imageSet.left - imageSet.right) / photo.size.width
        let cellHeight = photo.size.height * scale + imageSet.top + imageSet.bottom
        return cellHeight
    }
    func changeLike(at indexPath: IndexPath, isLikes: Bool) {
        let photo = self.photos[indexPath.row]
        self.view?.blockProgressHUDOn()
         service.changeLike(photoId: photo.id,indexPatch: indexPath, isLike: isLikes) { result in
             let indexPatch = indexPath
             switch result {
             case .success:
                 DispatchQueue.main.async {
                     self.view?.updatePhoto(at: indexPatch)
                     self.view?.blockProgressHUDOff()
                 }
             case .failure(let error):
                 print("Ошибка изменения лайка: \(error.localizedDescription)")
                 UIBlockProgressHUD.dismiss()
             }
         }
    }
    
}
