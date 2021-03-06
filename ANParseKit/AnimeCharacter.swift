//
//  AnimeCharacter.swift
//  AnimeNow
//
//  Created by Paul Chavarria Podoliako on 6/11/15.
//  Copyright (c) 2015 AnyTap. All rights reserved.
//

import Foundation
import Parse

public class AnimeCharacter: PFObject, PFSubclassing {
    override public class func initialize() {
        struct Static {
            static var onceToken : dispatch_once_t = 0;
        }
        dispatch_once(&Static.onceToken) {
            self.registerSubclass()
        }
    }
    
    public class func parseClassName() -> String {
        return "AnimeCharacter"
    }
    
    @NSManaged public var characters: [[String:AnyObject]]
    
    public struct Character {
        public var characterID: Int
        public var image: String
        public var name: String
        public var role: String
        public var japaneseActor: Person?
        
    }
    
    public struct Person {
        public var personID: Int = 0
        public var image: String = ""
        public var name: String = ""
        public var job: String = ""
    }
    
    public func characterAtIndex(index: Int) -> Character {
        let data = characters[index]
        
        var japaneseVoiceActor: Person?
        
        if let voiceActorsData = data["actors"] as? [AnyObject] {
            for voiceActor in voiceActorsData where (voiceActor["language"] as! String) == "Japanese" {
                japaneseVoiceActor = Person(
                    personID: (voiceActor["id"] as! Int),
                    image: (voiceActor["image"] as! String),
                    name: (voiceActor["name"] as! String),
                    job: (voiceActor["language"] as! String))
            }
        }
        
        
        return Character(
            characterID: (data["id"] as! Int),
            image: (data["image"] as! String),
            name: (data["name"] as! String),
            role: (data["role"] as! String),
            japaneseActor: japaneseVoiceActor)
    }
    
    
}