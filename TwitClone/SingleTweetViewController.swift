//
//  SingleTweetViewController.swift
//  TwitClone
//
//  Created by Nathan Birkholz on 10/8/14.
//  Copyright (c) 2014 Nate Birkholz. All rights reserved.
//

import UIKit

class SingleTweetViewController: UIViewController {
    
    var selectedTweet : Tweet!


    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var tweetLabel: UILabel!
    @IBOutlet weak var favoriteLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        println("VIEW LOADED >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>")
        
        self.userImageView.image = selectedTweet.userImage
        self.nameLabel.text = selectedTweet.userName
        self.tweetLabel.text = selectedTweet.text
        let x = selectedTweet.tweetFavorites
        var idText = String(x!)
        self.favoriteLabel.text = idText as String

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func goBack(sender: UIButton) {
        println("---------------------------------------------------------------------------------------------------")
        self.performSegueWithIdentifier("comeHome", sender: self)
        println("---------------------------------------------------------------------------------------------------")
    }
    
//    @IBAction func unwindToMainMenu(sender : UIStoryboardSegue) {
//        
//    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
