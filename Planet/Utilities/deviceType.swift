//
//  deviceType.swift
//  Planet
//
//  Created by itkhld on 2024-11-14.
//

import Foundation
import UIKit

func deviceType() -> String {
    if UIDevice.current.userInterfaceIdiom == .phone {
        return "iPhone"
    } else if UIDevice.current.userInterfaceIdiom == .pad {
        return "iPad"
    } else {
        return "Unknown"
    }
}

