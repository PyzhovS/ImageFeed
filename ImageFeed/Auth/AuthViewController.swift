import UIKit


class AuthViewController: UIViewController, WebViewViewControllerDelegate {
   
    
    let webViewSegueIdentifier = "ShowWebView"
    let oAuth2Service = OAuth2Service()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == webViewSegueIdentifier {
            guard
                let webViewViewController = segue.destination as? WebViewViewController
            else {
                assertionFailure("Failed to prepare for \(webViewSegueIdentifier)")
                return
            }
            webViewViewController.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        oAuth2Service.fetchOAuthToken(code: code) { result in
            DispatchQueue.main.async {
                switch result {
                case.success(let accessToken):
                    print("Access Token: \(accessToken)")
                 case .failure(let error):
                    print("Ошибка получения токена: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        vc.dismiss(animated: true)
    }
}
