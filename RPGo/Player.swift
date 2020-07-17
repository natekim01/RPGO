//
//  Player.swift
//  RPGo
//
//  Created by Nathanael Kim on 12/11/17.
//  Copyright © 2017 Nathanael Kim. All rights reserved.
//

import UIKit
import os.log


// Keeps track of all player data (persistant between app sessions)
class Player: NSObject, NSCoding {

    init(name: String, level: Int, exp: Double, attack: Int, defense: Int, health: Int, speed: Int, steps: Int, miles: Double, date: Date) {
        self.name = name
        self.level = level
        self.exp = exp
        self.attack = attack
        self.defense = defense
        self.health = health
        self.speed = speed
        self.dateSteps = steps
        self.dateMiles = miles
        self.date = date
        
        super.init()
    }
    
    var name: String {
        didSet {
            save()
        }
    }
    
    var level: Int {
        didSet {
            save()
        }
    }
    
    var exp: Double {
        didSet {
            while exp > Double(expNeeded) {
                exp -= Double(expNeeded)
                self.levelUp()
            }
            save()
        }
    }
    
    func expInt() -> Int {
        return Int(exp)
    }
    
    var expNeeded: Int {
        if level < 10 {
            return 50 + level * 25
        } else {
            return 200 + Int(30 * (log2(Double(level))))
        }
    }
    
    var items: [Item] = [] {
        didSet {
            save()
        }
    }
    
    var attack: Int {
        didSet {
            save()
        }
    }
    
    var effectiveAttack: Int {
        return attack + addedAttack
    }
    
    var addedAttack: Int {
        var bonus = 0
        for item in self.items {
            if item.equipped && item.type == .Attack {
                bonus += item.value
            }
        }
        return bonus
    }
    
    var defense: Int {
        didSet {
            save()
        }
    }
    
    var effectiveDefense: Int {
        return defense + addedDefense
    }
    
    var addedDefense: Int {
        var bonus = 0
        for item in self.items {
            if item.equipped && item.type == .Defense {
                bonus += item.value
            }
        }
        return bonus
    }
    
    var health: Int {
        didSet {
            save()
        }
    }
    
    var speed: Int {
        didSet {
            save()
        }
    }
    
    var dateSteps: Int {
        didSet {
            save()
        }
    }
    
    var dateMiles: Double {
        didSet {
            save()
        }
    }
    
    var date: Date {
        didSet {
            save()
        }
    }
    
    func levelUp() {
        level += 1
        attack += 2 * level
        defense += 2 * level - 3
        health += 3 * level
        speed += 1 * level
    }
    
    func save() {
        UserDefaults.standard.set(name, forKey: "playerName")
        UserDefaults.standard.set(level, forKey: "playerLevel")
        UserDefaults.standard.set(exp, forKey: "playerExp")
        UserDefaults.standard.set(attack, forKey: "playerAttack")
        UserDefaults.standard.set(defense, forKey: "playerDefense")
        UserDefaults.standard.set(speed, forKey: "playerSpeed")
        UserDefaults.standard.set(health, forKey: "playerHealth")
        UserDefaults.standard.set(dateSteps, forKey: "playerSteps")
        UserDefaults.standard.set(dateMiles, forKey: "playerMiles")
        UserDefaults.standard.set(DateFormatter().string(from: date), forKey: "playerDate")
        saveItems()
        
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(items, toFile: Item.ArchiveURL.path)
        if isSuccessfulSave {
            // os_log("Player date successfully saved.", log: OSLog.default, type: .debug)
        } else {
            os_log("Failed to save date...", log: OSLog.default, type: .error)
        }
    }
    
    func saveItems() {
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(items, toFile: Item.ArchiveURL.path)
        if isSuccessfulSave {
//            os_log("Items successfully saved.", log: OSLog.default, type: .debug)
        } else {
            os_log("Failed to save items...", log: OSLog.default, type: .error)
        }
    }


    struct PlayerKey {
        static let date = "date"
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(date, forKey: PlayerKey.date)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        var date = aDecoder.decodeObject(forKey: PlayerKey.date) as? Date
        if date == nil {
            date = Date()
        }
        
        self.init(date: date!)
    }
    
    convenience init(date: Date) {
        var name = UserDefaults.standard.string(forKey: "playerName")
        var level = UserDefaults.standard.integer(forKey: "playerLevel")
        var exp = UserDefaults.standard.double(forKey: "playerExp")
        var attack = UserDefaults.standard.integer(forKey: "playerAttack")
        var defense = UserDefaults.standard.integer(forKey: "playerDefense")
        var speed = UserDefaults.standard.integer(forKey: "playerSpeed")
        var health = UserDefaults.standard.integer(forKey: "playerHealth")
        var steps = UserDefaults.standard.integer(forKey: "playerSteps")
        var miles = UserDefaults.standard.double(forKey: "playerMiles")
        
        var actualDate = date
        if name == nil {
            name = "Felix"
            level = 1
            exp = 0.0
            attack = 5
            defense = 2
            speed = 5
            health = 10
            steps = 0
            miles = 0.0
            actualDate = Date()
        }
        
        self.init(name: name!, level: level, exp: exp, attack: attack, defense: defense, health: health, speed: speed, steps: steps, miles: miles, date: actualDate)
        
        var items = loadItems()
        if items == nil {
            items = []
        }
        self.items = items!
        
        self.save()
        
        NSLog("got: \(self.dateSteps) st")
        NSLog("got: \(self.dateMiles) mi")
    }
    
    func loadItems() -> [Item]? {
        return NSKeyedUnarchiver.unarchiveObject(withFile: Item.ArchiveURL.path) as? [Item]
    }
    
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("player")
    
}
