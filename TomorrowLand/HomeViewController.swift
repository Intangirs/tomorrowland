//
//  HomeViewController.swift
//  TomorrowLand
//
//  Created by Yusuke Ohashi on 2018/09/23.
//  Copyright © 2018 Yusuke Ohashi. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {

    @IBOutlet weak var instanceHostLabel: UITextField!
    @IBOutlet weak var authorizeButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    @IBAction func startAuthorization(_ sender: Any) {
        let web = WebViewController()
        web.hostName = instanceHostLabel.text ?? ""
        present(web, animated: false, completion: nil)
    }
    
}
