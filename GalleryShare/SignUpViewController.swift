//
//  SignInViewController.swift
//  GalleryShare
//
//  Created by Andre Birsan on 2019-09-07.
//  Copyright © 2019 Andre Birsan. All rights reserved.
//

import UIKit

class SignUpViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func registerOptionOne(_ sender: Any) {
        performSegue(withIdentifier: "Email", sender: self)
    }
    
    @IBOutlet weak var firstImplementation: UIButton!
    
}
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */


