import Foundation

enum Constants {
    static let accessKey = "TTI-IzxWS-QjpkzgXMYCa4HwG1XWr3j6TzzTYOS8crA"
    static let secretKey = "5i1BJaeKkLFunchZ37qQAKWKBS5VnFTkzNYmu6PpqQ8"
    static let redirectURI = "urn:ietf:wg:oauth:2.0:oob"
    static let accessScope = "public+read_user+write_likes"
    static let defaultBaseURL = URL(string: "https://api.unsplash.com/")
    static let unsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"
}

struct AuthConfiguration {
    let accessKey: String
    let secretKey: String
    let redirectURI: String
    let accessScope: String
    let defaultBaseURL: URL
    let unsplashAuthorizeURLString: String
    
    init(accessKey: String, secretKey: String, redirectURI: String, accessScope: String, defaultBaseURL: URL, unsplashAuthorizeURLString: String) {
        self.accessKey = accessKey
        self.secretKey = secretKey
        self.redirectURI = redirectURI
        self.accessScope = accessScope
        self.defaultBaseURL = defaultBaseURL
        self.unsplashAuthorizeURLString = unsplashAuthorizeURLString
    }
    
    static var standard: AuthConfiguration {
        return AuthConfiguration(accessKey: Constants.accessKey ,
                                 secretKey: Constants.secretKey,
                                 redirectURI: Constants.redirectURI ,
                                 accessScope: Constants.accessScope,
                                 defaultBaseURL: Constants.defaultBaseURL!,
                                 unsplashAuthorizeURLString: Constants.unsplashAuthorizeURLString)
    }
}
