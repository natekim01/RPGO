//
//  ViewController.swift
//  RPGo
//
//  Created by Nathanael Kim on 12/11/17.
//  Copyright © 2017 Nathanael Kim. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    // every VC in the app keeps track of the Player
    var player: Player
    
    required init?(coder aDecoder: NSCoder) {
        self.player = Player.init(coder: aDecoder)!
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

