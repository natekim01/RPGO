//
//  BattleViewController.swift
//  RPGo
//
//  Created by Nathanael Kim on 12/11/17.
//  Copyright © 2017 Nathanael Kim. All rights reserved.
//

import UIKit
import SpriteKit

// VC to manage battles
class BattleViewController: ViewController {
    
    @IBOutlet weak var monsterProgress: UIProgressView!
    @IBOutlet weak var playerProgress: UIProgressView!
    @IBOutlet weak var attackButton: UIButton!
    @IBOutlet weak var defendButton: UIButton!
    @IBOutlet weak var healButton: UIButton!
    @IBOutlet weak var forfeitButton: UIButton!
    
    @IBOutlet weak var playerButton: UIButton!
    @IBOutlet weak var monsterButton: UIButton!
    
    // keep track of stats:
    var playerHealth = 0
    var playerDefense = 0
    var monsterHealth = Int(arc4random_uniform(10) + 25)
    var monsterMax = 0
    var monsterAttack = Int(arc4random_uniform(6) + 3)
    var monsterDefense = Int(arc4random_uniform(3) + 0)
    var monsterSpeed = Int(arc4random_uniform(3) + 2)
    
    // tells you if the battle is over
    var battleOver: Bool {
        if monsterHealth <= 0 || playerHealth <= 0 {
            return true
        }
        return false
    }
    
    // used for animations:
    var monsterIdleImg : [UIImage] = []
    var monsterAttackImg : [UIImage] = []
    var monsterDieImg : [UIImage] = []
    var playerIdleImg : [UIImage] = []
    var playerAttackImg : [UIImage] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // store some impotant stats
        monsterMax = monsterHealth
        playerHealth = player.health
        playerDefense = player.defense
//        monsterHealth = player.health + Int(arc4random_uniform(6) - 3)
//        monsterAttack = player.attack + Int(arc4random_uniform(4) - 2)
//        monsterDefense = player.defense + Int(arc4random_uniform(4) - 2)
//        monsterSpeed = player.speed + Int(arc4random_uniform(4) - 2)
        
        // set up character animations
        monsterIdleImg = [
            UIImage(named: "goblin-idle-1")!,
            UIImage(named: "goblin-idle-2")!,
            UIImage(named: "goblin-idle-3")!,
        ]
        monsterAttackImg = [
            UIImage(named: "goblin-attack-0")!,
            UIImage(named: "goblin-attack-1")!,
            UIImage(named: "goblin-attack-2")!,
            UIImage(named: "goblin-attack-3")!,
            UIImage(named: "goblin-attack-4")!,
            UIImage(named: "goblin-attack-5")!,
            UIImage(named: "goblin-attack-6")!,
        ]
        monsterDieImg = [
            UIImage(named: "goblin-die.000")!,
            UIImage(named: "goblin-die.001")!,
            UIImage(named: "goblin-die.002")!,
            UIImage(named: "goblin-die.003")!,
            UIImage(named: "goblin-die.004")!,
            UIImage(named: "goblin-die.005")!,
            UIImage(named: "goblin-die.006")!,
            UIImage(named: "goblin-die.007")!,
        ]
        
        playerIdleImg = [
            UIImage(named: "rogue-idle-0")!,
            UIImage(named: "rogue-idle-1")!,
            UIImage(named: "rogue-idle-2")!,
        ]
        playerAttackImg = [
            UIImage(named: "rogue-att-1")!,
            UIImage(named: "rogue-att-2")!,
            UIImage(named: "rogue-att-3")!,
            UIImage(named: "rogue-att-4")!,
        ]
        
        monsterButton.imageView!.animationImages = monsterIdleImg
        monsterButton.imageView!.animationDuration = 0.6
        monsterButton.imageView!.animationRepeatCount = 0
        monsterButton.imageView!.startAnimating()
        
        playerButton.imageView!.animationImages = playerIdleImg
        playerButton.imageView!.animationDuration = 0.6
        playerButton.imageView!.animationRepeatCount = 0
        playerButton.imageView!.startAnimating()
        
        update()
        
        // decide who goes first
        if monsterSpeed > player.speed {
            self.monsterTurn()
        } else {
            self.playerTurn()
        }
    }
    
    // decide if player won or lost
    func endBattle() {
        if monsterHealth <= 0 {
            win()
        } else {
            lose()
        }
    }
    
    // show player winning + award exp
    func win() {
        DispatchQueue.main.async {
            self.monsterButton.imageView!.animationImages = self.monsterDieImg
            self.monsterButton.imageView!.animationDuration = 0.8
            self.monsterButton.imageView!.animationRepeatCount = 0
            self.monsterButton.imageView!.startAnimating()
        }
        
        let exp = Int(arc4random_uniform(15) + 10)
        player.exp += Double(exp)
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(800), execute: {
            let alert = UIAlertController(title: "You Won!", message: "You got \(exp) exp", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "won"), style: .`default`, handler: { _ in
                NSLog("won")
                self.player.save()
                self.performSegue(withIdentifier: "battleUnwind", sender: nil)
            }))
            self.present(alert, animated: true, completion: nil)
        })
    }
    
    // show player losing + subtract exp
    func lose() {
        
        let exp = Int(arc4random_uniform(15) + 10)
        if Double(exp) > player.exp {
            player.exp = 0
        } else {
            player.exp -= Double(exp)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(800), execute: {
            let alert = UIAlertController(title: "You Lost!", message: "You lost \(exp) exp", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "lost"), style: .`default`, handler: { _ in
                NSLog("lost")
                self.player.save()
                self.performSegue(withIdentifier: "battleUnwind", sender: nil)
            }))

            self.present(alert, animated: true, completion: nil)
        })
    }
    
    // player forfeits
    @IBAction func playerForfeit(_ sender: Any) {
        DispatchQueue.main.async {
            self.disableButtons()
            self.playerHealth = 0
            self.endBattle()
        }
    }
    
    // player heals themself
    @IBAction func playerHeal(_ sender: Any) {
        DispatchQueue.main.async {
            self.disableButtons()
            self.playerHealth += Int(arc4random_uniform(15) + 6)
            if self.playerHealth > self.player.health {
                self.playerHealth = self.player.health
            }
            self.update()
            self.monsterTurn()
        }
    }
    
    // player attacks monster
    // show animation + halfway through animation update progress bars
    @IBAction func playerAttack(_ sender: Any) {
        DispatchQueue.main.async {
            self.disableButtons()
            
            self.playerButton.imageView!.stopAnimating()
            self.playerButton.imageView!.animationImages = self.playerAttackImg
            self.playerButton.imageView!.animationDuration = 0.4
            self.playerButton.imageView!.animationRepeatCount = 0
            self.playerButton.imageView!.startAnimating()
        }
        
        if monsterDefense < player.effectiveAttack {
            monsterHealth -= player.effectiveAttack - monsterDefense
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(400), execute: {
            self.update()
        })
        
        NSLog("\(playerHealth) \(monsterHealth)")
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(800), execute: {
            self.playerButton.imageView!.animationImages = self.playerIdleImg
            self.playerButton.imageView!.animationDuration = 0.6
            self.playerButton.imageView!.animationRepeatCount = 0
            self.playerButton.imageView!.startAnimating()
            
            if self.battleOver {
                self.endBattle()
                return
            }
            
            self.monsterTurn()
        })

    }
    
    // player increases their defense
    @IBAction func playerDefend(_ sender: Any) {
        DispatchQueue.main.async {
            self.disableButtons()
            self.playerDefense += Int(arc4random_uniform(2) + 1)
            self.monsterTurn()
        }
    }
    
    // monster attacks attacks
    // show animation + halfway through animation update progress bars
    func monsterTurn() {
        NSLog("\n\n\n\n\n MONSTER TURN \n\n\n\n\n")
        usleep(300000)
        disableButtons()
        if playerDefense < monsterAttack {
            playerHealth -= monsterAttack - playerDefense
        }
        
        DispatchQueue.main.async {
            self.monsterButton.imageView!.stopAnimating()
            self.monsterButton.imageView!.animationImages = self.monsterAttackImg
            self.monsterButton.imageView!.animationDuration = 0.7
            self.monsterButton.imageView!.animationRepeatCount = 0
            self.monsterButton.imageView!.startAnimating()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(700), execute: {
            self.update()
        })

        NSLog("\(playerHealth) \(monsterHealth)")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1400), execute: {
            self.monsterButton.imageView!.animationImages = self.monsterIdleImg
            self.monsterButton.imageView!.animationDuration = 0.6
            self.monsterButton.imageView!.animationRepeatCount = 0
            self.monsterButton.imageView!.startAnimating()
            
            if self.battleOver {
                self.endBattle()
                return
            }
            
            self.playerTurn()
        })
    }
    
    func playerTurn() {
        NSLog("\n\n\n\n\n PLAYER TURN \n\n\n\n\n")
        
        DispatchQueue.main.async {
            self.enableButtons()
        }
    }
    
    func disableButtons() {
        attackButton.isEnabled = false;
        defendButton.isEnabled = false;
        defendButton.isEnabled = false;
        forfeitButton.isEnabled = false;
    }
    
    func enableButtons() {
        attackButton.isEnabled = true;
        defendButton.isEnabled = true;
        defendButton.isEnabled = true;
        forfeitButton.isEnabled = true;
    }
    
    // update monster + player health progress bars
    func update() {
        playerProgress.progress = Float(playerHealth) / Float(player.health)
        monsterProgress.progress = Float(monsterHealth) / Float(monsterMax)
        
        // change color as you get closer to 0 health
        if playerProgress.progress > 0.5 {
            playerProgress.progressTintColor = UIColor(red:0.24, green:0.84, blue:0.39, alpha:1.0)
        } else if playerProgress.progress > 0.2 {
            playerProgress.progressTintColor = UIColor(red:0.84, green:0.69, blue:0.24, alpha:1.0)
        } else {
            playerProgress.progressTintColor = UIColor(red:0.84, green:0.39, blue:0.24, alpha:1.0)
        }
        
        if monsterProgress.progress > 0.5 {
            monsterProgress.progressTintColor = UIColor(red:0.24, green:0.84, blue:0.39, alpha:1.0)
        } else if monsterProgress.progress > 0.2 {
            monsterProgress.progressTintColor = UIColor(red:0.84, green:0.69, blue:0.24, alpha:1.0)
        } else {
            monsterProgress.progressTintColor = UIColor(red:0.84, green:0.39, blue:0.24, alpha:1.0)
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
    }

}
