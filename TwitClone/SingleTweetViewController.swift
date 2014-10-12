//
//  SingleTweetViewController.swift
//  TwitClone
//
//  Created by Nathan Birkholz on 10/8/14.
//  Copyright (c) 2014 Nate Birkholz. All rights reserved.
//

import UIKit

class SingleTweetViewController: UIViewController {
    
    // ---------------------------------------------
    // #MARK: Variables
    // ---------------------------------------------
    
    var selectedTweet : Tweet!
    var networkController : NetworkController!

    // ---------------------------------------------
    // #MARK: Outlets
    // ---------------------------------------------

    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var tweetLabel: UILabel!
    @IBOutlet weak var favoriteLabel: UILabel!
    @IBOutlet weak var retweetLabel: UILabel!
    @IBOutlet weak var loadingImage: UIActivityIndicatorView!

    // ---------------------------------------------
    // #MARK: Lifecycle
    // ---------------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        self.networkController = appDelegate.networkController
        
        if self.selectedTweet.userImageLarge == nil { // Sometime network lag fails to have the image
            self.loadingImage.startAnimating()
            
            self.networkController.getUserImage(selectedTweet!, tweetDictionary: selectedTweet!.tweetDictionary, completionHandler: { (imageSmall, imageLarge) -> (Void) in
                self.selectedTweet?.userImageSmall = imageSmall
                self.selectedTweet?.userImageLarge = imageLarge
                self.userImageView.image = self.selectedTweet.userImageLarge
                self.loadingImage.stopAnimating()

            })

        } else {
            self.userImageView.image = selectedTweet.userImageLarge
        }
        
        self.nameLabel.text = selectedTweet.userName
        self.tweetLabel.text = selectedTweet.text

        let favText = String(selectedTweet.tweetFavorites!)
        let retweetText = String(selectedTweet.tweetRetweets!)
        self.favoriteLabel.text = favText as String
        self.retweetLabel.text = retweetText as String
        
        self.navigationItem.leftBarButtonItem?.image = UIImage(named: "imgBack")

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

    }
    
    // ---------------------------------------------
    // #MARK: Interaction
    // ---------------------------------------------

    @IBAction func didTap(sender: UITapGestureRecognizer) {
        let timeLineView = self.storyboard?.instantiateViewControllerWithIdentifier("TWEET_LIST`") as HomeTimelineViewController

        timeLineView.timeLineType = 2
        timeLineView.selectedUser = self.selectedTweet!.screenName
        
        
        
        self.navigationController?.pushViewController(timeLineView, animated: true)
    }

}
