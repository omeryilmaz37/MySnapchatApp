//
//  UserSingleton.swift
//  SnapchatClone
//
//  Created by Ömer Yılmaz on 18.02.2024.
//

import Foundation

class UserSingleton {
    // Singleton örneğine erişmek için kullanılacak statik bir özellik tanımlanır.
    static let sharedUser = UserSingleton()
    
    // Kullanıcının e-posta ve kullanıcı adı gibi özellikleri tanımlanır.
    var email = ""
    var username = ""
    
    // Dışarıdan örnek oluşturulmasını engellemek için özel bir init() metodu tanımlanır.
    private init() {
        // Özel bir işlem yapılması gerekmiyorsa, bu metot boş bırakılabilir.
    }
}


//Bu kod, UserSingleton adında bir sınıf tanımlar. Bu sınıf, bir kullanıcının e-posta ve kullanıcı adı gibi bilgilerini saklamak için kullanılır. Singleton deseni kullanılarak oluşturulduğundan, bu sınıfın yalnızca bir örneği olabilir ve bu örneğe sharedUser özelliği üzerinden erişilebilir.
//
//email ve username değişkenleri, kullanıcının e-posta adresi ve kullanıcı adını saklamak için kullanılır.
//
//private init() metodu, bu sınıfın dışında bir örneğin oluşturulmasını engellemek için özel olarak tanımlanmıştır. Bu sayede, yalnızca bu sınıfın içinde bir örneği oluşturulabilir ve Singleton deseni sağlanmış olur. Bu durumda, UserSingleton.sharedUser özelliği aracılığıyla bu tek örneğe erişilebilir.





