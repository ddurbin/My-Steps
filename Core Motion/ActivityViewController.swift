//
//  ActivityViewController.swift
//  Core Motion
//
//  Created by DANIEL DURBIN on 3/14/16.
//  Copyright © 2016 DANIEL DURBIN. All rights reserved.
//

import UIKit
import CoreMotion
import CoreData

class ActivityViewController: UIViewController {
    //MARK: IBOutlets
    @IBOutlet weak var stepsLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var floorsLabel: UILabel!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    //MARK: Fields
    var manager:CMMotionActivityManager = CMMotionActivityManager()
    var pedometer:CMPedometer = CMPedometer()
    let healthManager:HealthManager = HealthManager()
    var totalStepCount = 0
    var totalDistanceCount = 0.0 //in miles
    var totalFloorCount = 0
    var startDate = Foundation.Date()
    var stopDate:Foundation.Date?
    var context: NSManagedObjectContext?
    
    //MARK: UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.hidesBackButton = true
        
        saveButton.backgroundColor = UIColor.red
        saveButton.isEnabled = false
        saveButton.alpha = 0.5
        saveButton.layer.cornerRadius = 10
        cancelButton.backgroundColor = UIColor.red
        cancelButton.layer.cornerRadius = 10
        
        authorizeHealthKit()
        startPedometerFromNow()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        self.pedometer.stopUpdates()
    }
    
    //MARK: Pedometer Functions
    func startPedometerFromNow() {
        //track steps from current date
        self.stepsLabel.text = "0"
        self.distanceLabel.text = "0 miles"
        if CMPedometer.isFloorCountingAvailable() {
            self.floorsLabel.text = "0"
        }else {
            self.floorsLabel.text = "No Floor data"
        }
        self.pedometer.startUpdates(from: Foundation.Date()) { (data, error) -> Void in
            if error != nil {
                print("Error obtaining Pedestrian data: \(error?.localizedDescription)")
                self.pedometer.stopUpdates()
            }else {
                let steps = data?.numberOfSteps
                let distance = data?.distance
                let floors = data?.floorsAscended
                DispatchQueue.main.async(execute: { () -> Void in
                    if (steps != nil) {
                        if (!self.saveButton.isEnabled) {
                            self.saveButton.isEnabled = true
                            self.saveButton.alpha = 1.0
                        }
                        
                        self.totalStepCount = steps!.intValue
                        self.stepsLabel.text = "\(steps!)"
                    }
                    if (distance != nil) {
                        let miles = (Double)(distance!.doubleValue/1609.0)
                        self.totalDistanceCount = miles
                        self.distanceLabel.text = String(format: "%.2f", miles) + " miles"
                    }
                    if (floors != nil) {
                        self.totalFloorCount = floors!.intValue
                        self.floorsLabel.text = "\(floors!)"
                    }
                })
            }
        }
    }
    
    func saveNewActivity() {
        let activityMO = NSEntityDescription.insertNewObject(forEntityName: "Activity", into: self.context!) as! Activity
        activityMO.date = Foundation.Date()
        activityMO.steps = "\(self.totalStepCount)"
        activityMO.distance =  String(format: "%.2f", self.totalDistanceCount)
        activityMO.floors =  "\(self.totalFloorCount)"
        
        do {
            try context!.save()
        }catch {
            print("Error saving new activity")
        }
        
        healthManager.saveNewWorkout(self.totalStepCount, distanceCount: self.totalDistanceCount, floorCount: self.totalFloorCount, startDate: self.startDate, stopDate: self.stopDate!)
        
        self.pedometer.stopUpdates()
        self.navigationController?.popViewController(animated: true)
        
    }
    
    
    @IBAction func saveNewActivity(_ sender: UIButton) {
        self.stopDate = Foundation.Date()
        saveNewActivity()
    }
    
    //MARK: HealthKit
    
    func authorizeHealthKit() {
        print("Request HealthKit authorization")
        healthManager.authorizeHealthKit { (authorized, error) -> Void in
            if(authorized){
                print("HealthKit Authorized")
            }else {
                print("HealthKit Authorization denied")
                if(error != nil) {
                    print(error)
                }
            }
        }
    }
    
    //MARK: Utility
    
    func printActivites() {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Activity")
        request.returnsObjectsAsFaults = false
        
        do {
            let results = try context!.fetch(request)
            if results.count > 0 {
                for result in results {
                    if let date = (result as AnyObject).value(forKey: "date") as? Foundation.Date {
                        print("Date: \(date.description)")
                    }
                    if let steps = (result as AnyObject).value(forKey: "steps") as? String {
                        print("Steps: \(steps)")
                    }
                    if let distance = (result as AnyObject).value(forKey: "distance") as? String {
                        print("Distance: \(distance) meters")
                    }
                    if let floors = (result as AnyObject).value(forKey: "floors") as? Foundation.Date {
                        print("Floors: \(floors)")
                    }
                }
            }
        }catch {
            print("Error clearing Object Context")
        }
        
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}

