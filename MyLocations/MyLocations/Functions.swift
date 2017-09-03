//
//  Functions.swift
//  MyLocations
//
//  Created by Gleb on 03.09.17.
//  Copyright © 2017 gleb.maltcev. All rights reserved.
//

import Foundation
import Dispatch

func afterDelay(_ seconds: Double, closure: @escaping () -> ()) {
    DispatchQueue.main.asyncAfter(deadline: .now() + seconds, execute: closure)
}
