//
//  SettingsVC.swift
//  SnapchatClone
//
//  Created by Ömer Yılmaz on 17.02.2024.
//

import UIKit
import FirebaseCore
import FirebaseAuth

class SettingsVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func logoutClicked(_ sender: Any) {
        do{
            try Auth.auth().signOut()
            self.performSegue(withIdentifier: "toSignInVC", sender: nil)
        }catch{
            
        }
    }
}
