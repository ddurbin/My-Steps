//
//  ActivitiesTableViewController.swift
//  Core Motion
//
//  Created by DANIEL DURBIN on 3/14/16.
//  Copyright © 2016 DANIEL DURBIN. All rights reserved.
//

import UIKit
import CoreData

class ActivitiesTableViewController: UITableViewController {
    
    var appDel: AppDelegate = AppDelegate()
    
    var context: NSManagedObjectContext = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.mainQueueConcurrencyType)
    
    var activities = [Activity]()
    
    fileprivate var kEntity = "Activity"

    override func viewDidLoad() {
        super.viewDidLoad()

        appDel = UIApplication.shared.delegate as! AppDelegate
        context = appDel.managedObjectContext
        
        self.clearsSelectionOnViewWillAppear = false
        
        fetchActivities(self.kEntity)
        self.tableView.reloadData()

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        fetchActivities(self.kEntity)
        self.tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return activities.count
    }
    
    func configureCell(_ cell: ActivityTableViewCell, atIndexPath indexPath: IndexPath) {
        let activity = self.activities[(indexPath as NSIndexPath).row]
            cell.dateLabel.text = Date.toString(date: activity.date!) as String
            cell.stepsLabel.text = activity.steps
            cell.distanceLabel.text = "\(activity.distance!) miles"
            cell.floorsLabel.text = activity.floors
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ActivityCell", for: indexPath) as! ActivityTableViewCell
        configureCell(cell, atIndexPath: indexPath)
        return cell
    }

    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return false
    }

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    
    func fetchActivities(_ entity:String) {
        do{
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
            
            request.returnsObjectsAsFaults = false
            
            let results =  try context.fetch(request) as! [Activity]
            
            if results.count > 0 {
                self.activities = results
            }
//            for result in results {
//                if let date = result.valueForKey("date") as? NSDate {
//                    activity.date = date
//                }
//                if let steps = result.valueForKey("steps") as? String {
//                    activity.steps = steps
//                }
//                if let distance = result.valueForKey("distance") as? String {
//                    let miles = Double(distance)!/1609.0
//                    activity.distance = "\(miles)"
//                }
//                if let floors = result.valueForKey("floors") as? String {
//                    activity.floors = floors
//                }
//                self.activities.append(activity)
//            }
        }catch{
            print("Error retrieving: \(entity)")
        }

    }
    
    func clearObjectContext() {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Activity")
        request.returnsObjectsAsFaults = false
        
        do {
            let results = try context.fetch(request)
            if results.count > 0 {
                for result in results {
                    context.delete(result as! NSManagedObject)
                }
            }
        }catch {
            print("Error clearing Object Context")
        }
    }

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }

}
