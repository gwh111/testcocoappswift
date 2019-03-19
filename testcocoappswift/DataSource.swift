//
//  DataSource.swift
//  TableViewTest3
//
//  Created by Su Xiaozhou on 25/04/2017.
//  Copyright © 2017 Su Xiaozhou. All rights reserved.
//

import Cocoa

class DataSource: NSObject {
    class func dataArray() -> [DataModel]{
        let array = [
            DataModel(t: "Ming-Chi Kuo Agrees iPhone 8 Will Launch in September With 'Severe' Shortages Due to Delayed Production", d: "As more alleged design schematics and dummy models of the \"iPhone 8\" leak online, one of the biggest questions remains the smartphone's actual launch date."),
            DataModel(t: "Samsung Galaxy S8 starter guide: 8 tips for your new phone", d: "Samsung's new Galaxy S8 hit stores this past weekend, which means that a lot of people likely received their preorders or were able to pick one up in a store."),
            DataModel(t: "Outlast 2 Review", d: "New Reasons To Fear The Unknown And Check Heart Rates"),
            DataModel(t: "Tim Cook reportedly threatened to pull Uber from App Store", d: "It should come as no surprise to anyone that Apple takes the privacy of its iPhone users very seriously. This is after all the company that famously resisted FBI demands for a backdoor into a terrorist's iPhone."),
            DataModel(t: "How to stop apps from collecting your email data", d: "There's a saying in the tech world: If you're not paying for the product, you are the product."),
            DataModel(t: "Microsoft finds another use for LinkedIn with CRM integration", d: "The moment Salesforce CEO Marc Benioff was dreading has arrived: Microsoft is wielding LinkedIn against Salesforce in the battle for the CRM market."),
            DataModel(t: "Camera Comparison: Galaxy S8 vs. Pixel vs. LG G6", d: "Thinking back to the early days of Android, it's insane to see how far cameras inside of smartphones have come. The innovation doesn't seem to be slowing this year either, as there are many phones available to buyers with very capable and exciting ..."),
            DataModel(t: "Puyo Puyo Tetris Review – Better Together (PS4)", d: "I spent many nights playing puzzle games as a kid, and since I owned a SEGA Genesis growing up, that meant quite a bit of my time was occupied by Dr.")
            
        ]
        
        return array + array + array
    }
}
