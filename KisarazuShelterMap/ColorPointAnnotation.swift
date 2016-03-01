//
//  ColorPointAnnotation.swift
//  KisarazuShelterMap
//
//  Created by Kouta on 2016/03/01.
//  Copyright © 2016年 Kouta. All rights reserved.
//
import UIKit
import MapKit

class ColorPointAnnotation: MKPointAnnotation {
    var id: String
    
    init(id: String) {
        self.id = id
        super.init()
    }
}