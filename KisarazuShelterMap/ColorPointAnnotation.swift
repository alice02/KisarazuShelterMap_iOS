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
    var pinColor: UIColor
    
    init(pinColor: UIColor) {
        self.pinColor = pinColor
        super.init()
    }
}