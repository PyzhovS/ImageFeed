import UIKit
import Kingfisher



final class ImagesListViewController: UIViewController {
    
    @IBOutlet var tableView: UITableView!
    
    // MARK: - Properties
    private let imagesListService = ImagesListService()
    private let showSingleImageIdentifier = "ShowSingleImage"
    private let currentDate = Date()
    var photos: [Photo] = []
    var image: UIImage?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        imagesListService.fetchPhotosNextPage()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateTableViewAnimated),
            name: ImagesListService.didChangeNotification,
            object: nil
        )
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Setup Methods
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        
        let photo = photos[indexPath.row]
        guard let url = URL(string: photo.thumbImageURL) else { return }
        
        cell.configure(with: url, date: DateFormatter.longStyle.string(from: photo.createdAt), likes: photo.isLiked)
        
        cell.setIsLiked = { [weak self] in
            guard let self = self else { return }
            let isLikes = cell.likeButton.currentImage == cell.noActiveImage
            UIBlockProgressHUD.show()
            imagesListService.changeLike(photoId: photo.id,indexPatch: indexPath, isLike: isLikes) { result in
                let indexPatch = indexPath
                switch result {
                case .success:
                    DispatchQueue.main.async {
                        print("Лайк успешно изменён.")
                        self.photos = self.imagesListService.photos
                        var newLikeImage: UIImage?
                        let likes = self.photos[indexPatch.row].isLiked
                        newLikeImage = likes ? cell.activeImage : cell.noActiveImage
                        cell.likeButton.setImage(newLikeImage, for: .normal)
                        UIBlockProgressHUD.dismiss()
                    }
                case .failure(let error):
                    print("Ошибка изменения лайка: \(error.localizedDescription)")
                    UIBlockProgressHUD.dismiss()
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == showSingleImageIdentifier else {
            super.prepare(for: segue, sender: sender)
            return
        }
        guard
            let viewController = segue.destination as? SingleImageViewController,
            let indexPath = sender as? IndexPath
        else {
            assertionFailure("Invalid segue destination")
            return
        }
        
        imageLoadedFull()
        
        func imageLoadedFull() {
            let photo = photos[indexPath.row]
            let photoSet = UIImage(named:"Stuboff")
            let imageFull = UIImageView()
            UIBlockProgressHUD.show()
            guard let url = URL(string: photo.fullUmageUrl) else { return }
            imageFull.kf.setImage(
                with: url,
                placeholder: photoSet,
                options: [. transition(. fade(0.2))],
                completionHandler: { result in
                    switch result {
                    case .success(let imageFull):
                        viewController.image = imageFull.image
                        print("фотография Full успешна загружена ")
                        UIBlockProgressHUD.dismiss()
                    case .failure(let error):DispatchQueue.main.async {
                        showError()
                    }
                        print("Ошибка загрузки фотографии Full: \(error)")
                        UIBlockProgressHUD.dismiss()
                    }
                }
            )
        }
        
        func showError(){
            let alert = UIAlertController(title: "Что-то пошло не так", message: "Попробовать ещё раз?", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "Не надо", style: .cancel, handler: nil)
            let retryAction = UIAlertAction(title: "Повторить", style: .default) { _ in
                imageLoadedFull()
            }
            alert.addAction(cancelAction)
            alert.addAction(retryAction)
            
            viewController.present(alert, animated: true, completion: nil)
        }
    }
    
    @objc func updateTableViewAnimated() {
        let oldCount = photos.count
        let newCount = imagesListService.photos.count
        photos = imagesListService.photos
        if oldCount != newCount {
            tableView.performBatchUpdates {
                let indexPaths = (oldCount..<newCount).map { i in
                    IndexPath(row: i, section: 0)
                }
                tableView.insertRows(at: indexPaths, with: .automatic)
            } completion: { _ in }
        }
    }
    
}

extension ImagesListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell,forRowAt indexPath: IndexPath) {
        if indexPath.row + 1 == imagesListService.photos.count  {
            imagesListService.fetchPhotosNextPage()
        }
        print("indexPath \(indexPath.row)")
        print(" photos\(imagesListService.photos.count)")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        photos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)
        
        guard let imageListCell = cell as? ImagesListCell else {
            return UITableViewCell()
        }
        
        configCell(for: imageListCell, with: indexPath)
        return imageListCell
    }
}

extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: showSingleImageIdentifier, sender: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat  {
        
        let photo = photos[indexPath.row]
        let imageSet = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let scale = (tableView.bounds.width - imageSet.left - imageSet.right) / photo.size.width
        let cellHeight = photo.size.height * scale + imageSet.top + imageSet.bottom
        return cellHeight
    }
}

extension DateFormatter {
    static let longStyle: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()
}
