//
//  DismissSegue.swift
//  bpproto
//
//  Created by Thiago Peres on 09/03/16.
//  Copyright © 2016 peres. All rights reserved.
//

import UIKit

@objc(DismissSegue) class DismissSegue: UIStoryboardSegue {
    override func perform() {
        let vc = self.sourceViewController.presentingViewController! as UIViewController
        
        vc.dismissViewControllerAnimated(true) { () -> Void in
        }
    }
}
