//
//  ViewController2.swift
//  Nature Book Swift
//
//  Created by Erislam Nurluyol on 2.03.2024.
//

import UIKit
import CoreData

class ViewController2: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var placeTextField: UITextField!
    @IBOutlet weak var yearTextField: UITextField!
    var targetName = ""
    var targetID: UUID?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if targetName != "" {
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
            let context = appDelegate.persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Flower")
            if let idString = targetID?.uuidString {
                fetchRequest.predicate = NSPredicate.init(format: "id = %@", idString)
            } else {
                return
            }
            fetchRequest.returnsObjectsAsFaults = false
            
            do {
                let results = try context.fetch(fetchRequest)
                for result in results as! [NSManagedObject] {
                    if let name = result.value(forKey: "name") as? String {
                        nameTextField.text = name
                    }
                    
                    if let place = result.value(forKey: "place") as? String {
                        placeTextField.text = place
                    }
                    
                    if let year = result.value(forKey: "year") as? Int {
                        yearTextField.text = "\(year)"
                    }
                    
                    if let imageData = result.value(forKey: "image") as? Data {
                        let image = UIImage(data: imageData)
                        imageView.image = image
                    }
                }
            } catch {
                print(error.localizedDescription)
            }
        } else {
            
        }
        
        imageView.isUserInteractionEnabled = true
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageViewTapped))
        imageView.addGestureRecognizer(gestureRecognizer)
    }
    
    @objc func imageViewTapped(){
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker, animated: true)
    }
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let dataToSave = NSEntityDescription.insertNewObject(forEntityName: "Flower", into: context)
        
        dataToSave.setValue(nameTextField.text, forKey: "name")
        dataToSave.setValue(placeTextField.text, forKey: "place")
        if let year = Int(yearTextField.text!) {
            dataToSave.setValue(year, forKey: "year")
        }
        
        let imagePress = imageView.image?.jpegData(compressionQuality: 0.5)
        dataToSave.setValue(imagePress, forKey: "image")
        dataToSave.setValue(UUID(), forKey: "id")
        
        do {
            try context.save()
            print("Success")
        } catch {
            print(error.localizedDescription)
        }
        NotificationCenter.default.post(name: .init("newData"), object: nil)
        self.navigationController?.popViewController(animated: true)
    }
}

extension ViewController2: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageView.image = info[.originalImage] as? UIImage
        self.dismiss(animated: true)
    }
}

extension ViewController2: UINavigationControllerDelegate {
    
}
