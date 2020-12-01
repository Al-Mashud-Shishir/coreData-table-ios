//
//  ViewController.swift
//  ArtBook-CoreDataExample
//
//  Created by Maddi on 30/11/20.
//

import UIKit
import CoreData

class ViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    var selectedPaintingId:UUID?
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return names.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel!.text = names[indexPath.row]
        return cell
    }
    

    @IBOutlet weak var tableView: UITableView!
    var names = [String]()
    var ids = [UUID]()
    
    @objc func getStoredData() {
        names.removeAll()
        ids.removeAll()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Paintings")
        do {
            let results = try  context.fetch(fetchRequest)
            for result in results as! [NSManagedObject] {
                if let name =  result.value(forKey: "name") as? String {
                    self.names.append(name)
                }
                if let id =  result.value(forKey: "id") as? UUID {
                    self.ids.append(id)
                }
                
                self.tableView.reloadData()

            }
            
        } catch  {
            print("Error retrieving data")
        }
       
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(addNew))
        tableView.delegate = self
        tableView.dataSource = self
        getStoredData()
    }
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(getStoredData), name: NSNotification.Name("newDataAdded"), object: nil)
    }
    @objc func addNew(){
        selectedPaintingId = nil
        performSegue(withIdentifier: "secondView", sender: nil)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "secondView"{
            let vc = segue.destination as! SecondViewController
            vc.chosenPaintingId = selectedPaintingId
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedPaintingId = ids[indexPath.row]
        performSegue(withIdentifier: "secondView", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete{
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Paintings")
            let stringUUID = ids[indexPath.row].uuidString
            print(stringUUID)
            fetchRequest.predicate = NSPredicate(format: "id = %@", stringUUID)
            
            do {
                let results = try  context.fetch(fetchRequest) as! [NSManagedObject]
                context.delete(results[0])
                try context.save()
                names.remove(at: indexPath.row)
                ids.remove(at: indexPath.row)
                self.tableView.reloadData()

            } catch  {
                print("Error retrieving data")
            }
        }
        
       
        
    }
}

