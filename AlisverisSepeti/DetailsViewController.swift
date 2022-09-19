//
//  DetailsViewController.swift
//  AlisverisSepeti
//
//  Created by Berke Topcu on 18.09.2022.
//

import UIKit
import CoreData

class DetailsViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var urunAdi: UITextField!
    @IBOutlet weak var urunFiyat: UITextField!
    @IBOutlet weak var urunBeden: UITextField!
    
    @IBOutlet weak var saveButton: UIButton!
    
    var secilenUrunIsmi = ""
    var secilenUrunId : UUID?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if secilenUrunIsmi != "" {
            //Core data seçilen ürünleri göster
            
            saveButton.isHidden = true
            
            
            if let uuidString = secilenUrunId?.uuidString {
                    
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                let context = appDelegate.persistentContainer.viewContext
                
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Alisveris")
                fetchRequest.predicate = NSPredicate(format: "id = %@", uuidString)
                fetchRequest.returnsObjectsAsFaults = false
                
                do {
                    let sonuclar = try context.fetch(fetchRequest)
                    if sonuclar.count > 0 {
                        for sonuc in sonuclar as! [NSManagedObject] {
                            
                            if let isim = sonuc.value(forKey: "isim") as? String {
                                urunAdi.text = isim
                            }
                            
                            if let fiyat = sonuc.value(forKey: "fiyat") as? Int {
                                urunFiyat.text = String(fiyat)
                            }
                            
                            if let beden = sonuc.value(forKey: "beden") as? String {
                                urunBeden.text = beden
                            }
                            
                            if let gorselData = sonuc.value(forKey: "gorsel") as? Data {
                                let image = UIImage(data: gorselData)
                                imageView.image = image
                            }
                        }
                    }
                    
                } catch {
                        print("hata var")
                }
                
            }
            
        } else {
            saveButton.isHidden = false
            saveButton.isEnabled = false
            urunAdi.text = ""
            urunFiyat.text = ""
            urunBeden.text = ""
        }
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(klavyeKapat))
        view.addGestureRecognizer(gestureRecognizer)
        
        imageView.isUserInteractionEnabled = true
        let imageGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(resimEkle))
        imageView.addGestureRecognizer(imageGestureRecognizer)
        // Do any additional setup after loading the view.
    }
    
    @IBAction func kaydetButon(_ sender: Any) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let alisveris = NSEntityDescription.insertNewObject(forEntityName: "Alisveris", into: context)
      
        alisveris.setValue(urunAdi.text!, forKey: "isim")
        alisveris.setValue(urunBeden.text!, forKey: "beden")
        
        if let fiyat = Int(urunFiyat.text!) {
            alisveris.setValue(fiyat, forKey: "fiyat")
        }
        
        alisveris.setValue(UUID(), forKey: "id")
        
        let data = imageView.image!.jpegData(compressionQuality: 0.5)
        
        alisveris.setValue(data, forKey: "gorsel")
        
        do {
            try context.save()
            print("kaydettin gardasim")
        } catch {
            print("hata var dikkat gardasim")
        }
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "veriGirildi"), object: nil)
        self.navigationController?.popViewController(animated: true)
        
    }
    
    @objc func klavyeKapat() {
        view.endEditing(true)
    }
    
    @objc func resimEkle() {
        
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        imageView.image = info[.editedImage] as? UIImage
        saveButton.isEnabled = true
        self.dismiss(animated: true, completion: nil)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
