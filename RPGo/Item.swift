//
//  Item.swift
//  RPGo
//
//  Created by Nathanael Kim on 12/11/17.
//  Copyright © 2017 Nathanael Kim. All rights reserved.
//

import UIKit
import os.log

// represents an Item
class Item: NSObject, NSCoding {
    
    convenience init(image: String, type: ItemType, value: Int, rarity: Int) {
        let im = UIImage(named: image)
        self.init(image: im!, type: type, value: value, equipped: false, rarity: 0)
    }
    
    init(image: UIImage, type: ItemType, value: Int, equipped: Bool, rarity: Int) {
        self.image = image
        self.type = type
        self.value = value
        self.equipped = equipped
        self.rarity = rarity
    }

    var image: UIImage
    var type: ItemType
    var value: Int
    var equipped: Bool
    var rarity: Int
    
    enum ItemType: String, Codable {
        case Attack
        case Defense
        case Health
    }
    
    struct ItemKey {
        static let image = "image"
        static let type = "type"
        static let value = "value"
        static let equipped = "equipped"
        static let rarity = "rarity"
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(image, forKey: ItemKey.image)
        try? (aCoder as! NSKeyedArchiver).encodeEncodable(type, forKey: ItemKey.type)
        aCoder.encode(value, forKey: ItemKey.value)
        aCoder.encode(equipped, forKey: ItemKey.equipped)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let image = aDecoder.decodeObject(forKey: ItemKey.image) as! UIImage
        let type = (aDecoder as! NSKeyedUnarchiver).decodeDecodable(ItemType.self, forKey: ItemKey.type)!
        let value = aDecoder.decodeInteger(forKey: ItemKey.value)
        let equipped = aDecoder.decodeBool(forKey: ItemKey.equipped)
        let rarity = aDecoder.decodeInteger(forKey: ItemKey.rarity)
        self.init(image: image, type: type, value: value, equipped: equipped , rarity: rarity)
    }
    
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("items")
    
}
