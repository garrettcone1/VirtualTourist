//
//  GCDBlackBox.swift
//  Virtual Tourist
//
//  Created by Garrett Cone on 1/6/18.
//  Copyright © 2018 Garrett Cone. All rights reserved.
//

import Foundation
import UIKit

func performUIUpdatesOnMain(_ updates: @escaping () -> Void ) {
    
    DispatchQueue.main.async {
        updates()
    }
}
