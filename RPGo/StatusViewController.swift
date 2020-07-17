//
//  StatusViewController.swift
//  RPGo
//
//  Created by Nathanael Kim on 12/11/17.
//  Copyright © 2017 Nathanael Kim. All rights reserved..
//

import UIKit
import HealthKit
import os.log

// VS for the main app screen
class StatusViewController: ViewController {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var distLabel: UILabel!
    @IBOutlet weak var stepLabel: UILabel!
    @IBOutlet weak var levelLabel: UILabel!
    @IBOutlet weak var progressLabel: UIProgressView!
    @IBOutlet weak var expLabel: UILabel!
    var healthStore: HKHealthStore?
    
    // update player info
    func updatePlayerDisplay() {
        DispatchQueue.main.async {
            self.nameLabel.text = self.player.name
            self.levelLabel.text = "Level \(self.player.level)"
            self.expLabel.text = "EXP: \(self.player.expInt()) / \(self.player.expNeeded)"
            self.progressLabel.progress = Float(self.player.exp) / Float(self.player.expNeeded)
            self.distLabel.text = String(format: "%.2f miles", self.player.dateMiles)
            self.stepLabel.text = "\(self.player.dateSteps) steps"
        }
    }
    
    // level the player up
    func handleLevelUp() { // alert player to the level up
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "You Leveled Up!", message: "", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "level up"), style: .`default`, handler: { _ in
                NSLog("Levelled up")
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    // get EXP from new steps + distance
    func handleStepDistance(steps: Int, miles: Double) {
        var expGain = 0.0
        let now = Date()
        var stepGain = 0
        
        if Calendar.current.compare(now, to: player.date, toGranularity: .day) == .orderedSame {
            if steps > player.dateSteps {
                expGain += Double((steps - player.dateSteps) / 100)
                stepGain = steps - player.dateSteps
                NSLog("\(steps) vs prev \(player.dateSteps)")
                player.dateSteps = steps
            }
            if miles > player.dateMiles {
                expGain += (miles - player.dateMiles) * 5
                NSLog("\(miles) vs prev \(player.dateMiles)")
                player.dateMiles = miles
            }
        } else if Calendar.current.compare(now, to: player.date, toGranularity: .day) == .orderedDescending {
            expGain += Double(steps / 100)
            expGain += miles * 5
            stepGain = steps
            player.dateSteps = steps
            player.dateMiles = miles
            NSLog("\(miles) mi and \(steps) steps on new day")
        }
        
        NSLog("got \(expGain) exp")
        player.date = now
        
        let prevLevel = player.level
        player.exp += expGain
        let newLevel = player.level
        
        // display new info + possible level up alert
        self.updatePlayerDisplay()
        if prevLevel != newLevel { // has levelled up
            self.handleLevelUp()
        }
        
        // battles!
        // (do something where probability increases as closer to 1000 steps since last monster)
        let chance = stepGain
        let rand = arc4random_uniform(1000)
        if rand < chance {
            self.goToBattle()
        }
    }
    
    // start a battle
    func goToBattle() {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "You encountered a Monster!", message: "", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "battle"), style: .`default`, handler: { _ in
                NSLog("battle")
                self.player.save()
                self.performSegue(withIdentifier: "battleSegue", sender: nil)
            }))
            
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    
    // get new step data
    func fetchSteps(healthStore: HKHealthStore){
        let startDate = Calendar.current.startOfDay(for: Date())
        
        let endDate = Date()
        
        let sampleType = HKQuantityType.quantityType(forIdentifier:
            HKQuantityTypeIdentifier.stepCount)!
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        
        let query = HKStatisticsQuery(quantityType: sampleType,
                                      quantitySamplePredicate: predicate,
                                      options: .cumulativeSum) { query, result, error in
                                        if result != nil {
                                            if let quantity = result!.sumQuantity() {
                                                let unit = HKUnit.count()
                                                let steps = Int(quantity.doubleValue(for: unit))
                                                self.handleStepDistance(steps: steps, miles: 0)
                                            }
                                            return
                                        }
        }
        
        healthStore.execute(query)
    }
    
    // get new distance data
    func fetchDistance(healthStore: HKHealthStore){
        let startDate = Calendar.current.startOfDay(for: Date())
        
        let endDate = Date()
        
        let sampleType = HKQuantityType.quantityType(forIdentifier:
            HKQuantityTypeIdentifier.distanceWalkingRunning)!
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        
        let query = HKStatisticsQuery(quantityType: sampleType,
                                      quantitySamplePredicate: predicate,
                                      options: .cumulativeSum) { query, result, error in
                                        if result != nil {
                                            if let quantity = result!.sumQuantity() {
                                                let unit = HKUnit.mile()
                                                let miles = quantity.doubleValue(for: unit)
                                                self.handleStepDistance(steps: 0, miles: miles)
                                            }
                                            return
                                        }
        }
        
        healthStore.execute(query)
    }
    
    // set up observer to notify upon new step + distance data
    func observeStepsAndDistance(healthStore: HKHealthStore){
        let stepSampleType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)!
        let stepQuery = HKObserverQuery(sampleType: stepSampleType, predicate: nil) {
            query, completionHandler, error in
            
            if error != nil {
                NSLog("an error occurred")
            }

            self.fetchSteps(healthStore: healthStore)
        }
        healthStore.execute(stepQuery)
        
        let distSampleType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.distanceWalkingRunning)!
        let distQuery = HKObserverQuery(sampleType: distSampleType, predicate: nil) {
            query, completionHandler, error in
            
            if error != nil {
                NSLog("an error occurred")
            }
            
            self.fetchDistance(healthStore: healthStore)
        }
        healthStore.execute(distQuery)
    }
    
    
    // Actually do the things
    override func viewDidLoad() {
        self.updatePlayerDisplay()
        NSLog("Num items: \(player.items.count)")
        
        super.viewDidLoad()
        
        // get healthkit permission + data
        if HKHealthStore.isHealthDataAvailable() {
            healthStore = HKHealthStore()
            
            var readTypes = Set<HKSampleType>()
            readTypes.insert(HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)!)
            readTypes.insert(HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.distanceWalkingRunning)!)
            
            healthStore?.requestAuthorization(toShare: nil, read: readTypes) { (success, error) in
                if !success {
                    NSLog("wompwompwomp an error occured!")
                    // show an error message or something
                } else {
                    self.observeStepsAndDistance(healthStore: self.healthStore!)
                }
            }
            
            self.observeStepsAndDistance(healthStore: healthStore!)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.updatePlayerDisplay()
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        player.save()
        if let dest = segue.destination as? ViewController {
            dest.player = player
        }
        
        if let dest = segue.destination as? ItemTableViewController {
            dest.player = player
        }

    }
    
    @IBAction func unwindWithPlayer(segue: UIStoryboardSegue) {
        if let vc = segue.source as? CharacterViewController {
            vc.player.save()
            self.player = vc.player
        }
    }
 
}
