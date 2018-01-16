//
//  HealthManager.swift
//  Core Motion
//
//  Created by DANIEL DURBIN on 3/24/16.
//  Copyright © 2016 DANIEL DURBIN. All rights reserved.
//

import Foundation
import HealthKit

class HealthManager {
    
    let healthKitStore: HKHealthStore = HKHealthStore()
    var isAuthorized = false
    var energyQuantity:HKQuantity?
    
    func authorizeHealthKit(_ completion: ((_ success:Bool, _ error:NSError?) -> Void)!) {
        //types tp read from healthkit
        let healthKitTypesToRead = Set(arrayLiteral:HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyMass)!)
        
        //types to write to healthkit
        let healthKitTypesToWrite = Set(arrayLiteral:
            HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)!,
            HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.distanceWalkingRunning)!,
            HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.flightsClimbed)!,
            HKSampleType.workoutType())
        
        //ensure healthkit supported
        if !HKHealthStore.isHealthDataAvailable()
        {
            let error = NSError(domain: "self.edu.DanielDurbin.Core-Motion", code: 2, userInfo: [NSLocalizedDescriptionKey:"HealthKit is not available on this Device"])
            completion?(false, error)
            return;
        }
        
        //request authorization
        healthKitStore.requestAuthorization(toShare: healthKitTypesToWrite, read: healthKitTypesToRead) { (success, error) in
            if success {
                self.isAuthorized = true
            }
            completion?(false, error as NSError?)
            return
        }

    }
    
    func queryBodyWeight(_ completion: ((HKSample?, NSError?) -> Void)!) {
        // 1. Construct an HKSampleType for Height
        let sampleType = HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyMass)
        //build the predicate
        let past = Foundation.Date.distantPast
        let now = Foundation.Date()
        let mostRecentPredicate = HKQuery.predicateForSamples(withStart: past, end: now, options: HKQueryOptions())
        
        //build the sort descriptor and return the samples in descending order
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        //limit the query to just one object
        let limit = 1
        
        //build the sample query
        let sampleQuery = HKSampleQuery(sampleType: sampleType!, predicate: mostRecentPredicate, limit: limit, sortDescriptors: [sortDescriptor]) { (sampleQuery, results, error) -> Void in
            
            if let queryError = error {
                completion?(nil, queryError as NSError?)
                return
            }
            
            //get first sample
            let mostRecentSample = results?.first as? HKQuantitySample
            if completion != nil {
                completion(mostRecentSample, nil)
            }
        }
        self.healthKitStore.execute(sampleQuery)

    }
    
    func saveNewWorkout(_ stepCount:Int, distanceCount:Double, floorCount:Int, startDate:Foundation.Date, stopDate:Foundation.Date) {
        
        //query user body mass
        queryBodyWeight { (mostRecentSample, error) in
            if error != nil {
                self.energyQuantity = HKQuantity(unit: HKUnit.jouleUnit(with: .kilo), doubleValue: 200)
            }else {
                let mostRecentWeightSample = mostRecentSample as? HKQuantitySample
                let weightInKilograms = mostRecentWeightSample!.quantity.doubleValue(for: HKUnit.gramUnit(with: .kilo))
                let pounds = weightInKilograms * 2.20462 //convert to pounds
                let caloriesBurned = pounds * 0.3 * distanceCount //calculate calories burned
                self.energyQuantity = HKQuantity(unit: HKUnit.jouleUnit(with: .kilo), doubleValue: caloriesBurned)
            }
        }
        
        //distance quantity
        let distanceQuantity = HKQuantity(unit: HKUnit.mile(), doubleValue: distanceCount)

        //calculate calories burned
        //setup new workout
        let walk = HKWorkout(activityType: HKWorkoutActivityType.walking, start: startDate, end: stopDate, workoutEvents: nil, totalEnergyBurned: self.energyQuantity, totalDistance: distanceQuantity, device: nil, metadata: nil)
        
//        let walk = HKWorkout(activityType: HKWorkoutActivityType.Walking, startDate: startDate, endDate: stopDate, duration: 0, totalEnergyBurned: HKQuantity(unit: HKUnit.countUnit(), doubleValue: 0.0), totalDistance: distanceQuantity, metadata: nil)
        
        //save workout
        self.healthKitStore.save(walk, withCompletion: { (success, error) in
            if (error != nil){
                fatalError("*** An error occurred while saving the " +
                    "activity: \(error?.localizedDescription)")
            }
        }) 
        
    }
    
    func isHealthKitAuthorized() -> Bool {
        return self.isAuthorized
    }
}
