//
//  ViewController.swift
//  Core Motion
//
//  Created by DANIEL DURBIN on 3/12/16.
//  Copyright © 2016 DANIEL DURBIN. All rights reserved.
//

import UIKit
import CoreMotion
import CoreData

class ViewController: UIViewController {
    //MARK: IBOutlets
    @IBOutlet weak var stepsLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var floorsLabel: UILabel!
    @IBOutlet weak var allActivitiesButton: UIButton!
    @IBOutlet weak var newActivityButton: UIBarButtonItem!
    
    //MARK: Fields
    var manager:CMMotionActivityManager = CMMotionActivityManager()
    var pedometer:CMPedometer = CMPedometer()
    var context: NSManagedObjectContext?
    
    
    //MARK: UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        //setup UI
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.backgroundColor = UIColor.red
        allActivitiesButton.backgroundColor = UIColor.red
        allActivitiesButton.layer.cornerRadius = 10
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //check from CM compatibility
        if isCoreMotionCompatible(){
            //Query Data for total steps
            queryTodayPedometerData()
        }else {
            self.allActivitiesButton.isEnabled = false
            self.newActivityButton.isEnabled = false
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //Stop updates
        self.pedometer.stopUpdates()
        if segue.identifier == "newActivity" {
            let activityVC = segue.destination as! ActivityViewController
            activityVC.context = self.context!
        }else if segue.identifier == "showActivities" {
            print("Show Activities")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        self.pedometer.stopUpdates()
    }
    
    //MARK Pedometer
    func reset() {
        //reset pedometer and clear UILables
        self.pedometer.stopUpdates()
        self.stepsLabel.text = ""
        self.distanceLabel.text = ""
        self.floorsLabel.text = ""
    }
    
    func isCoreMotionCompatible() ->Bool {
        if CMMotionActivityManager.isActivityAvailable() {
            return true
        }else {
            //alert user
            let alert = UIAlertController(title: "Error", message: "This device does not support Core Motion.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: { action in
                switch action.style {
                case .default:
                    break
                default:
                    break
                }
            }))
            self.present(alert, animated: true, completion: nil)
            return false
        }
    }
    
    func queryTodayPedometerData() {
        //track steps from Today
        var units = NSCalendar.Unit()
        units.insert(NSCalendar.Unit.year)
        units.insert(NSCalendar.Unit.month)
        units.insert(NSCalendar.Unit.day)
        units.insert(NSCalendar.Unit.hour)
        units.insert(NSCalendar.Unit.minute)
        units.insert(NSCalendar.Unit.second)
        let cal = Calendar.current
        var calComps = (cal as NSCalendar).components(units, from: Foundation.Date())
        calComps.hour = 0
        calComps.minute = 0
        calComps.second = 0
        let timezone = TimeZone.current
        (calComps as NSDateComponents).timeZone = timezone
        
        //NSDate from today at mignight
        let todayAtMidnight = cal.date(from: calComps)
        
        //Start pedometer updates
        self.pedometer.startUpdates(from: todayAtMidnight!, withHandler: { (data, error) -> Void in
            if error != nil {
                print("Error obtaining Pedestrian data.")
                self.pedometer.stopUpdates()
            }else {
                let steps = data?.numberOfSteps
                let distance = data?.distance
                let floors = data?.floorsAscended
                DispatchQueue.main.async(execute: { () -> Void in
                    if (steps != nil) {
                        self.stepsLabel.text = "\(steps!)"
                    }
                    if (distance != nil) {
                        let miles = (Double)(distance!.doubleValue/1609.0)
                        self.distanceLabel.text = String(format: "%.2f", miles) + " miles"
                    }
                    if (floors != nil) {
                        self.floorsLabel.text = "\(floors!)"
                    }
                })
            }
        })
    }
    
    //MARK: IBActions
    @IBAction func unwindToMainViewController(_ sender: UIStoryboardSegue) {
        //no functionality at this time
    }
}

