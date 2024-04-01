//
//  UploadVC.swift
//  SnapchatClone
//
//  Created by Ömer Yılmaz on 17.02.2024.
//

import UIKit
import FirebaseCore
import FirebaseStorage
import FirebaseFirestoreInternal

class UploadVC: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    @IBOutlet weak var uploadImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        uploadImageView.isUserInteractionEnabled = true
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(selectedImage))
        uploadImageView.addGestureRecognizer(gestureRecognizer)
    }
    
    @objc func selectedImage() {
        // UIImagePickerController nesnesi oluşturulur.
        let picker = UIImagePickerController()

        // Seçilen resmi işleyecek sınıfın delegesi olarak bu sınıfı ayarlar.
        picker.delegate = self

        // Kullanıcının resim seçebilmesi için fotoğraf kitaplığı kaynağını belirler.
        // Alternatif olarak .camera kullanılarak kamera da kullanılabilir.
        picker.sourceType = .photoLibrary

        // UIImagePickerController nesnesi mevcut ekran üzerinde animasyonlu olarak gösterilir.
        self.present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // Seçilen medya bilgileri 'info' adlı bir sözlükte bulunur.
        // Seçilen medyanın orijinal resmi 'info' sözlüğünden alınır ve 'uploadImageView' adlı UIImageView'e atanır.
        uploadImageView.image = info[.originalImage] as? UIImage
        
        // Resim seçme ekranı kapatılır.
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func uploadClicked(_ sender: Any) {
        // STORAGE STORAGE STORAGE STORAGE STORAGE STORAGE STORAGE STORAGE
        
        // Firebase Storage örneği oluşturuluyor
        let storage = Storage.storage()
        
        // Firebase Storage referansı alınıyor
        let storageReference = storage.reference()
        
        // 'media' adında bir klasör oluşturuluyor veya varsa referans alınıyor
        let mediaFolder = storageReference.child("media")
        
        // Yüklemek için seçilen resmin verisi alınıyor
        if let data = uploadImageView.image?.jpegData(compressionQuality: 0.5) {
            // Resmin adı için rastgele bir UUID oluşturuluyor
            let uuid = UUID().uuidString
            
            // Yüklenen resmin referansı oluşturuluyor ve UUID ile isimlendiriliyor
            let imageReference = mediaFolder.child("\(uuid).jpg")
            
            // Resmin verisi Firebase Storage'a yükleniyor
            imageReference.putData(data, metadata: nil) { (metadata, error) in
                // Yükleme sırasında bir hata olup olmadığı kontrol ediliyor
                if let error = error {
                    // Hata varsa, hata mesajı gösteriliyor
                    self.makeAlert(title: "ERROR", message: error.localizedDescription)
                } else {
                    // Firebase Storage'dan indirme URL'si alınıyor
                    imageReference.downloadURL { (url, error) in
                        // İndirme URL'si başarıyla alındıysa devam ediliyor
                        if let url = url {
                            // İndirme URL'si String olarak alınıyor
                            let imageUrl = url.absoluteString
                            print("Resim URL'si:", url.absoluteString)
                        
                            //FİRESTORE FİRESTORE FİRESTORE FİRESTORE FİRESTORE FİRESTORE FİRESTORE
                            
                            // Firestore veritabanı örneği oluşturuluyor
                            let fireStore = Firestore.firestore()
                            
                            fireStore.collection("Snaps").whereField("snapOwner", isEqualTo: UserSingleton.sharedUser.username).getDocuments { (snapshot, error) in
                                if error != nil {
                                    self.makeAlert(title: "ERROR", message: error?.localizedDescription ?? "ERROR")
                                }else{
                                    if snapshot?.isEmpty == false && snapshot != nil{
                                        for document in snapshot!.documents{
                                            let documentId = document.documentID
                                            if var imageUrlArray = document.get("imageUrlArray") as? [String] {
                                                imageUrlArray.append(imageUrl)
                                                let additionalDictionary = ["imageUrlArray" : imageUrlArray] as [String:Any]
                                                fireStore.collection("Snaps").document(documentId).setData(additionalDictionary, merge: true) { (error) in
                                                    if error == nil {
                                                        self.tabBarController?.selectedIndex = 0
                                                        self.uploadImageView.image = UIImage(named: "selectimage.png")
                                                    }
                                                }
                                            }
                                        }
                                    }else{
                                        // Snap verisi için bir sözlük oluşturuluyor
                                        let snapDictionary: [String: Any] = [
                                            "imageUrlArray": [imageUrl], // Resmin indirme URL'si
                                            "snapOwner": UserSingleton.sharedUser.username, // Snap'in sahibinin kullanıcı adı
                                            "time": FieldValue.serverTimestamp() // Server zamanı
                                        ]
                                        
                                        // Firestore'a Snap verisi ekleniyor
                                        fireStore.collection("Snaps").addDocument(data: snapDictionary) { (error) in
                                            // Eklerken bir hata olup olmadığı kontrol ediliyor
                                            if let error = error {
                                                // Hata varsa, hata mesajı gösteriliyor
                                                self.makeAlert(title: "ERROR", message: error.localizedDescription)
                                            } else {
                                                // Başarılı bir şekilde eklendiyse, ana sekme seçiliyor ve resim görüntüsü sıfırlanıyor
                                                self.tabBarController?.selectedIndex = 0
                                                self.uploadImageView.image = UIImage(named: "selectimage.png")
                                            }
                                        }

                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    /* 
     REFERENCE NEDİR?
     
     Firebase Storage'da "referans" terimi, bulunduğunuz konumu belirtmek için kullanılır. Referanslar, dosyaları sakladığınız konumları ve bu dosyaları belirli bir şekilde işlemek için kullanılır.
     
     Örneğin, let storageReference = storage.reference() satırı Firebase Storage'un ana konumuna bir referans oluşturur. Bu referans, Firebase Storage'daki tüm dosyaları yönetmek için kullanılır.

     Sonra let mediaFolder = storageReference.child("media") satırında, "media" adında bir klasör oluşturulur veya varsa bu klasörün referansı alınır. Bu mediaFolder referansı, "media" adlı alt klasördeki dosyaları yönetmek için kullanılabilir.

     let imageReference = mediaFolder.child("\(uuid).jpg") satırında ise, yüklenen bir resmin spesifik bir dosya adı ve uzantısı ile saklanacağı konumu belirtmek için bir referans oluşturulur. Bu referans, yüklenen her resmin benzersiz bir ad ile "media" klasöründe saklanmasını sağlar.

     Kısacası, referanslar Firebase Storage'daki belirli konumları temsil eder ve bu konumlardaki dosyaları işlemek için kullanılır. Bu sayede, dosyaları yükleyebilir, indirebilir, silinebilir veya diğer işlemleri gerçekleştirebilirsiniz.
     */

    
    func makeAlert(title:String, message:String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        let okButton = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil)
        alert.addAction(okButton)
        self.present(alert, animated: true, completion: nil)
    }
    
}
