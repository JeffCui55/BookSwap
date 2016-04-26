//
//  Textbook.swift
//  BookSwap
//
//  Created by John Zhang on 4/2/16.
//  Copyright © 2016 Jeffery Cui. All rights reserved.
//

import UIKit

class Textbook: NSObject {
    // Fields
    var index:Int!
    var ISBN:String!
    var title:String!
    var author:String!
    var edition:String!
    var date:NSDate!
    var condition:String!
    var price:Double!
    //var GPS:NSDecimalNumber! //fix this in database to get X and Y coords
    var GPSX:Double!
    var GPSY:Double!
    var imageSource:String! //we'll allow null until we can fix it
    var subject:String!
    var itemDescription:String!
    var vendorPhone:String!
    var vendorEmail:String!
    var vendorType:String!
    var sellStatus:Int!
    
}
