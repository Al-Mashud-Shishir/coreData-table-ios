//
//  SecondViewController.swift
//  ArtBook-CoreDataExample
//
//  Created by Maddi on 30/11/20.
//

import UIKit
import CoreData

class SecondViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var artistText: UITextField!
    @IBOutlet weak var yearText: UITextField!
    
    @IBOutlet weak var saveBtn: UIButton!
    var chosenPaintingId:UUID?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if chosenPaintingId == nil{
            let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
            let imageTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTap))
            view.addGestureRecognizer(gestureRecognizer)
            // Do any additional setup after loading the view.
            imageView.isUserInteractionEnabled = true
            imageView.addGestureRecognizer(imageTapRecognizer)
        }else{
            nameText.text=""
            artistText.text=""
            yearText.text=""
            saveBtn.isHidden = true
//            nameText.allowsEditingTextAttributes = false
//            artistText.allowsEditingTextAttributes = false
//            yearText.allowsEditingTextAttributes = false
            getIdData()
        }
    }
    func getIdData() {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Paintings")
        let stringUUID = chosenPaintingId!.uuidString
        print(stringUUID)
        fetchRequest.predicate = NSPredicate(format: "id = %@", stringUUID)
        
        do {
            let results = try  context.fetch(fetchRequest) as! [NSManagedObject]
            
            if let name =  results[0].value(forKey: "name") as? String {
                nameText.text = name
            }
            if let artist =  results[0].value(forKey: "artist") as? String {
                artistText.text = artist
            }
            if let year =  results[0].value(forKey: "year") as? Int {
                yearText.text = String(year)
            }
            if let image =  results[0].value(forKey: "image") as? Data {
                imageView.image = UIImage(data: image)
            }

        } catch  {
            print("Error retrieving data")
        }
    }

    
    @objc func handleTap(){
        view.endEditing(true)
    }
    @objc func imageTap(){
        print("image tapped")
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageView.image = info[.originalImage] as? UIImage
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveClicked(_ sender: UIButton) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let newPainting = NSEntityDescription.insertNewObject(forEntityName: "Paintings", into: context)
        newPainting.setValue(nameText.text, forKey: "name")
        newPainting.setValue(Int(yearText.text!), forKey: "year")
        newPainting.setValue(artistText.text, forKey: "artist")
        newPainting.setValue(imageView.image!.jpegData(compressionQuality: 1.0), forKey: "image")
        newPainting.setValue(UUID(), forKey: "id")
        
        if context.hasChanges {
            do {
                try context.save()
                print("Success")
                
                NotificationCenter.default.post(name: NSNotification.Name("newDataAdded"), object: nil)
                navigationController?.popViewController(animated: true)
            } catch {
               
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}
