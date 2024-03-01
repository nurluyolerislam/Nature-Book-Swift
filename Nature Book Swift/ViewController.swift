//
//  ViewController.swift
//  Nature Book Swift
//
//  Created by Erislam Nurluyol on 2.03.2024.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    var nameArray: [String] = []
    var idArray: [UUID] = []
    var sourceName = ""
    var sourceID: UUID?
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Nature Book"
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem.init(barButtonSystemItem: .add, target: self, action: #selector(addBarButtonItemTapped))
        tableView.delegate = self
        tableView.dataSource = self
        getData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(getData), name: .init("newData"), object: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toViewController2" {
            let destinationVC = segue.destination as! ViewController2
            destinationVC.targetName = sourceName
            destinationVC.targetID = sourceID
        }
    }
    
    @objc func addBarButtonItemTapped(){
        sourceName = ""
        performSegue(withIdentifier: "toViewController2", sender: nil)
    }
    
    @objc func getData() {
        self.nameArray.removeAll(keepingCapacity: true)
        self.idArray.removeAll(keepingCapacity: true)
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Flower")
        fetchRequest.returnsObjectsAsFaults = false
        do {
            let results = try context.fetch(fetchRequest)
            for result in results as! [NSManagedObject] {
                if let name = result.value(forKey: "name") as? String {
                    self.nameArray.append(name)
                }
                
                if let id = result.value(forKey: "id") as? UUID {
                    self.idArray.append(id)
                }
                
                self.tableView.reloadData()
            }
        } catch {
            print(error.localizedDescription)
        }
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        nameArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = nameArray[indexPath.row]
        return cell
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        sourceName = nameArray[indexPath.row]
        sourceID = idArray[indexPath.row]
        performSegue(withIdentifier: "toViewController2", sender: nil)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Flower")
        let idString = idArray[indexPath.row].uuidString
        fetchRequest.predicate = NSPredicate.init(format: "id = %@", idString)
        fetchRequest.returnsObjectsAsFaults = false
        do {
            let results = try context.fetch(fetchRequest)
            for result in results as! [NSManagedObject] {
                if let _ = result.value(forKey: "id") as? UUID {
                    context.delete(result)
                    nameArray.remove(at: indexPath.row)
                    idArray.remove(at: indexPath.row)
                    tableView.reloadData()
                    
                    do {
                        try context.save()
                    } catch {
                        print(error.localizedDescription)
                    }
                }
            }
        } catch {
            print(error.localizedDescription)
        }
    }
}
