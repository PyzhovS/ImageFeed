import UIKit
import Kingfisher

protocol ImagesListViewProtocol: AnyObject {
    func updatePhoto (at indexPatch: IndexPath)
    func updateTableViewAnimated(oldCount: Int, newCount: Int)
    func blockProgressHUDOn()
    func blockProgressHUDOff()
    
}

class ImagesListViewController: UIViewController, ImagesListViewProtocol {
    
    @IBOutlet var tableView: UITableView!
    
    // MARK: - Properties
    var presenter: ImagesListViewPresenterProtocol!
    private let imagesListService = ImagesListService()
    private let showSingleImageIdentifier = "ShowSingleImage"
    private let currentDate = Date()
    var image: UIImage?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        presenter.viewDidLoad()

        
    }
    
 
    
    // MARK: - Setup Methods

    
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        
        let photo = presenter.photos[indexPath.row]
        guard let url = URL(string: photo.thumbImageURL) else { return }
        
        cell.configure(with: url, date: DateFormatter.longStyle.string(from: photo.createdAt), likes: photo.isLiked)
        
        cell.setIsLiked = { [weak self] in
            guard let self = self else { return }
            
       let isLikes = cell.likeButton.currentImage == cell.noActiveImage
            presenter.changeLike(at: indexPath, isLikes: isLikes)
        }
    }
    
    func updatePhoto(at indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? ImagesListCell else {
            print("лайк не получился")
            return
        }
        let photo = presenter.photos[indexPath.row]
        
        let newLikeImage = photo.isLiked ? cell.activeImage : cell.noActiveImage
        cell.likeButton.setImage(newLikeImage, for: .normal)
    }
    
    func blockProgressHUDOn() {
        UIBlockProgressHUD.show()
    }
    
    func blockProgressHUDOff() {
        UIBlockProgressHUD.dismiss()
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
            let photo = presenter.photos[indexPath.row]
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
    
    @objc func updateTableViewAnimated(oldCount: Int, newCount: Int) {
 
            tableView.performBatchUpdates {
                let indexPaths = (oldCount..<newCount).map { i in
                    IndexPath(row: i, section: 0)
                }
                tableView.insertRows(at: indexPaths, with: .automatic)
            } completion: { _ in }
        }
    }
    

extension ImagesListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell,forRowAt indexPath: IndexPath) {

        presenter.willDisplayCell(at: indexPath)
        print("indexPath \(indexPath.row)")
        print(" photos\(imagesListService.photos.count)")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        presenter.photos.count
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
        
        presenter.calculateCellHeight(for: indexPath, tableView: tableView)
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
