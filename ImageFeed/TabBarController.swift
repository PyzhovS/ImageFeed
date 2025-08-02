import UIKit

final class TabBarController: UITabBarController {
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        
      guard let imagesListViewController = storyboard.instantiateViewController(
            withIdentifier: "ImagesListViewController"
      ) as? ImagesListViewController else {
          assertionFailure("Failler to ImagesListViewController ")
          return
      }
        let profileViewController = ProfileViewController()
        let presenter = ProfilePresenter()
        profileViewController.configure(presenter)
        presenter.view = profileViewController        
               let imagesListService = ImagesListService()
               let imagePresenter = ImagesListViewPresenter(service: imagesListService)
             imagesListViewController.configure(imagePresenter)
               imagePresenter.view = imagesListViewController
        profileViewController.tabBarItem = UITabBarItem(
            title: "",
            image: UIImage(named: "tab_profile_active"),
            selectedImage: nil)
        
        self.viewControllers = [imagesListViewController, profileViewController]
    }
}
