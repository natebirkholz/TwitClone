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
    @IBOutlet weak var retweetLabel: UILabel!
    @IBOutlet weak var backButton: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.userImageView.image = selectedTweet.userImageLarge
        self.nameLabel.text = selectedTweet.userName
        self.tweetLabel.text = selectedTweet.text

        let favText = String(selectedTweet.tweetFavorites!)
        let retweetText = String(selectedTweet.tweetRetweets!)
        self.favoriteLabel.text = favText as String
        self.retweetLabel.text = retweetText as String

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
//        var backImg: UIImage = UIImage(named: "imgBack")
//        backButton.setBackgroundImage(backImg, forState: .Normal, barMetrics: .Default)
    }

    @IBAction func didTap(sender: UITapGestureRecognizer) {
        let timeLineView = self.storyboard?.instantiateViewControllerWithIdentifier("TWEET_LIST`") as HomeTimelineViewController

        timeLineView.timeLineType = 2
        timeLineView.selectedUser = self.selectedTweet!.screenName
        
        
        
        self.navigationController?.pushViewController(timeLineView, animated: true)
    }


    


}
