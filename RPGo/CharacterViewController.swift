//
//  CharacterViewController.swift
//  RPGo
//
//  Created by Nathanael Kim on 12/11/17.
//  Copyright © 2017 Nathanael Kim. All rights reserved..
//

import UIKit

// VC for character detail view
class CharacterViewController: ViewController {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var levelLabel: UILabel!
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var expLabel: UILabel!
    @IBOutlet weak var stepLabel: UILabel!
    @IBOutlet weak var distLabel: UILabel!
    @IBOutlet weak var attackLabel: UILabel!
    @IBOutlet weak var defenseLabel: UILabel!
    @IBOutlet weak var speedLabel: UILabel!
    @IBOutlet weak var healthLabel: UILabel!
    
    // update character info
    func updatePlayerDisplay() {
        DispatchQueue.main.async {
            self.nameLabel.text = self.player.name
            self.levelLabel.text = "Level \(self.player.level)"
            self.expLabel.text = "EXP: \(self.player.expInt()) / \(self.player.expNeeded)"
            self.progressBar.progress = Float(self.player.exp) / Float(self.player.expNeeded)
            self.distLabel.text = String(format: "%.2f miles", self.player.dateMiles)
            self.stepLabel.text = "\(self.player.dateSteps) steps"
            
            self.attackLabel.text = "\(self.player.attack) + \(self.player.addedAttack)"
            self.defenseLabel.text = "\(self.player.defense) + \(self.player.addedDefense)"
            self.speedLabel.text = "\(self.player.speed)"
            self.healthLabel.text = "\(self.player.health)"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.updatePlayerDisplay()
    }
    
    // update info every time view appears again (not just on loading)
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.updatePlayerDisplay()
        for item in player.items {
            NSLog("item is \(item.equipped)")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Navigation

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
        if let vc = segue.source as? ItemTableViewController {
            vc.player.save()
            self.player = vc.player
        }
    }

}
