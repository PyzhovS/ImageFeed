import UIKit

struct Profile {
    var userName: String
    var firstName: String
    var lastName: String
    var bio: String
    var name: String
    var loginName: String
    
    init(userName: String, firstName: String, lastName: String, bio: String) {
        self.userName = userName
        self.firstName = firstName
        self.lastName = lastName
        self.bio = bio
        self.name = firstName + " " + lastName
        self.loginName = "@\(self.userName)"
    }
}
