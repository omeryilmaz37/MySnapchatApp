//
//  FeedVC.swift
//  SnapchatClone
//
//  Created by Ömer Yılmaz on 17.02.2024.
//

import UIKit
import FirebaseFirestoreInternal
import FirebaseAuth
import SDWebImage

class FeedVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    
    
    let firestoreDatabase = Firestore.firestore()
    var snapArray = [Snap]()
    var chosenSnap :  Snap?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        getSnapsFromFirebase()
        getUserInfo()
    }
    
    
    
    //addSnapshotListener: Her değişiklik olduğunda güncelliyecek
    func getSnapsFromFirebase() {
        firestoreDatabase.collection("Snaps").order(by: "date", descending: true).addSnapshotListener { (snapshot, error) in
            if error != nil {
                self.makeAlert(title: "ERROR", message: error?.localizedDescription ?? "ERROR")
            } else {
                if snapshot?.isEmpty == false && snapshot != nil {
                    self.snapArray.removeAll(keepingCapacity: false)
                    for document in snapshot!.documents {
                        let documentId = document.documentID
                        
                        if let username = document.get("snapOwner") as? String {
                            if let imageUrlArray = document.get("imageUrlArray") as? [String] {
                                if let date = document.get("time") as? Timestamp {
                                    
                                    if let difference = Calendar.current.dateComponents([.hour], from: date.dateValue(), to: Date()).hour {
                                        if difference >= 24 {
                                            self.firestoreDatabase.collection("Snaps").document(documentId).delete { (error) in
                                            
                                            }
                                         }
                                        else{
                                             let snap = Snap(userName: username, imageUrlArray: imageUrlArray, date: date.dateValue(), timeDifference: 24 - difference)
                                             self.snapArray.append(snap)
                                         }
                                    }
                                }
                            }
                        }
                    }
                    self.tableView.reloadData()
                }
            }
        }
    }

    func getUserInfo() {
        // Firestore veritabanından UserInfo koleksiyonunu alır ve bu koleksiyonda kullanıcının e-postasıyla eşleşen belgeleri getirir.
        firestoreDatabase.collection("UserInfo").whereField("email", isEqualTo: Auth.auth().currentUser!.email!).getDocuments { (snapshot, error) in
            // Veritabanı sorgusu tamamlandığında bu kapanış bloğu çalışır. Hata ve snapshot parametrelerini alır.

            // Hata olup olmadığını kontrol eder.
            if error != nil {
                // Eğer bir hata varsa, makeAlert fonksiyonunu kullanarak kullanıcıya bir hata mesajı gösterir.
                self.makeAlert(title: "ERROR", message: error?.localizedDescription ?? "ERROR")
            } else {
                // Hata yoksa ve snapshot boş değilse işlemleri gerçekleştirir.
                if let snapshot = snapshot, !snapshot.isEmpty {
                    // Belge döngüsü içinde her belgeyi dolaşır.
                    for document in snapshot.documents {
                        // Belgeden kullanıcı adını alır.
                        if let username = document.get("username") as? String {
                            // Kullanıcı tekil örneğine (UserSingleton) e-posta ve kullanıcı adı bilgilerini atar.
                            UserSingleton.sharedUser.email = Auth.auth().currentUser!.email!
                            UserSingleton.sharedUser.username = username
                            print("DOCUMENT: \(document)")
                        }
                    }
                }
            }
        }
    }
    
/*  Bu kod, Firestore veritabanından kullanıcının e-postasıyla eşleşen belgeleri alır ve bu belgelerdeki kullanıcı adını alarak UserSingleton adlı bir örnek üzerinde saklar. Eğer bir hata varsa, makeAlert fonksiyonu aracılığıyla kullanıcıya bir hata mesajı gösterir.*/
    
    
    func makeAlert(title:String, message:String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        let okButton = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil)
        alert.addAction(okButton)
        self.present(alert, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return snapArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! FeedCell
        cell.feedUserNameLabel.text = snapArray[indexPath.row].userName
        cell.feedImageView.sd_setImage(with: URL(string: snapArray[indexPath.row].imageUrlArray[0]))
        let imageUrl = snapArray[indexPath.row].imageUrlArray[0]
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toSnapVC"{
            let destinationVC = segue.destination as! SnapVC
            destinationVC.selectedSnap = chosenSnap
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        chosenSnap = self.snapArray[indexPath.row]
        performSegue(withIdentifier: "toSnapVC", sender: nil)
    }
}
