//
//  ItemTableViewController.swift
//  RPGo
//
//  Created by Felix Plajer on 12/10/17.
//  Copyright © 2017 Felix Plajer. All rights reserved.
//

import UIKit

// VC for the item inventory screen (from character page)
class ItemTableViewController: ViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var cellList = [Int:ItemTableViewCell]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return player.items.count
    }

    // return the items in order for the cells
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "itemCell", for: indexPath) as! ItemTableViewCell

        let item = player.items[indexPath.row]
        cell.item = item
        cell.player = player
        
        cellList[indexPath.row] = cell

        return cell
    }

    
    // when selected, equip item and show checkmark
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if cellList[indexPath.row]?.item.type != .Health {
            cellList[indexPath.row]?.accessoryType = .checkmark
            cellList[indexPath.row]?.item.equipped = true
        }
    }
    
    // unequip item
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if cellList[indexPath.row]?.item.type != .Health {
            cellList[indexPath.row]?.accessoryType = .none
            cellList[indexPath.row]?.item.equipped = false
        }
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

}
