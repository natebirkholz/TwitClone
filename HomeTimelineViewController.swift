//
//  HomeTimelineViewController.swift
//  TwitClone
//
//  Created by Nathan Birkholz on 10/6/14.
//  Copyright (c) 2014 Nate Birkholz. All rights reserved.
//

import UIKit
import Accounts
import Social


class HomeTimelineViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    // ---------------------------------------------
    // #MARK: Variables
    // ---------------------------------------------

    
    var tweets : [Tweet]? // Array of tweets downloaded
    var twitterAccount : ACAccount? // User account
    var userFor : User? // The user who owns the account
    var timeLineType = 1 // 1 for home, 2 for user timelines. Couldn't seem to acces an enum across vc's
    var networkController : NetworkController!
    var refreshControl : UIRefreshControl? // refresh control
    var selectedUser : String? // Where i get the screenname for sepcifying a user in the user timeline
    var imageCache = [String : UIImage]() // cache for images downloaded
    let masterInterval : NSTimeInterval = 0.3
    
    // ---------------------------------------------
    // #MARK: Outlets
    // ---------------------------------------------
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var userForImage: UIImageView!
    @IBOutlet weak var userForHandle: UILabel!
    @IBOutlet weak var userForName: UILabel!
    

    // ---------------------------------------------
    // #MARK: Lifecycle
    // ---------------------------------------------

    
    override func viewDidLoad() {
            super.viewDidLoad()
        
        self.tableView.registerNib(UINib(nibName: "TweetCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "TWEET_CELL")
        
        var appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        self.networkController = appDelegate.networkController
        
        self.tableView.delegate = self
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.refreshControl?.addTarget(self, action: "refreshTweets:", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(self.refreshControl!)
        
        getTimeLine()
        
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        self.userForHandle.text = self.userFor?.screenName as String!
        self.userForName.text = self.userFor?.userName as String!
        self.userForImage.image = self.userFor?.userImageSmall as UIImage!

//        self.tableView.reloadData()
        
        reloadIt()

        
    }
    
    // ---------------------------------------------
    // #MARK: Network Interaction
    // ---------------------------------------------
    
    func getTimeLine () { // Choose a function dependent on the type of timeline
        if self.timeLineType == 1 {
            getHomeTimeline()
        } else if timeLineType == 2 {
            getUserTimeline()
        } else {
            println("Unknown timeline type")
        }
    }
    
    func getHomeTimeline() {
            // set the URL and add its parameters from the Twitter API for the Home timeline
        let url = NSURL(string: "https://api.twitter.com/1.1/statuses/home_timeline.json")
        let parameters : Dictionary = ["count" : "50"]
        
        self.networkController.getAnyTimeLine(url, parameters: parameters, isRefresh: false, newestTweet: nil, oldestTweet: nil, completionHandler: { (errorDescription, tweets) -> (Void) in
            if errorDescription != nil {
                println("Error Description is \(errorDescription)")
                println("ERROROROROROR")
                var alert = UIAlertController(title: "Error", message: "Server has denied your request, please try again later.", preferredStyle: UIAlertControllerStyle.Alert)
                
                let defaultAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
                alert.addAction(defaultAction)
                
                self.presentViewController(alert, animated: true, completion: nil)
            } else {
                self.tweets = tweets
                var tweetForID = self.tweets?.first as Tweet!
                self.setUserHeader()
                
                self.reloadIt()
            }
        })
        

        self.userForHandle.text = self.userFor?.screenName as String!
        self.userForName.text = self.userFor?.userName as String!
        self.userForImage.image = self.userFor?.userImageSmall as UIImage!
        
        self.reloadIt()
        
        timeLineType = 1


    }
    
    func getUserTimeline() {
        let url = NSURL(string: "https://api.twitter.com/1.1/statuses/user_timeline.json")
        let parameters : Dictionary = ["count" : "50", "screen_name" : selectedUser!]
        
        self.networkController.getAnyTimeLine(url, parameters: parameters, isRefresh: false, newestTweet: nil, oldestTweet: nil, completionHandler: { (errorDescription, tweets) -> (Void) in
            if errorDescription != nil {
                println("Error Description is \(errorDescription)")
                println("ERROROROROROR")
                var alert = UIAlertController(title: "Error", message: "Server has denied your request, please try again later.", preferredStyle: UIAlertControllerStyle.Alert)
                
                let defaultAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
                alert.addAction(defaultAction)
                
                self.presentViewController(alert, animated: true, completion: nil)
            } else {
                self.tweets = tweets
                self.setUserHeader()
                
                self.reloadIt()
                
            }
        })
        
        timeLineType = 2
        
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == self.tweets!.count - 3 {
            
            var url : NSURL?
            var parameters : Dictionary<String, String>?
            
            if timeLineType == 2 {
                url = NSURL(string: "https://api.twitter.com/1.1/statuses/user_timeline.json")
                parameters = ["count" : "20", "screen_name" : selectedUser!]
            } else if timeLineType == 1 {
                url = NSURL(string: "https://api.twitter.com/1.1/statuses/home_timeline.json")
                parameters = ["count" : "20"]
            } else {
                println("No timeline type set currently")
            }
            
            self.networkController.getAnyTimeLine(url!, parameters: parameters!, isRefresh: true, newestTweet: nil, oldestTweet: self.tweets?.last, completionHandler: { (errorDescription, tweets) -> (Void) in
                
                if errorDescription != nil {
                    println("ERROROROROROR")
                    var alert = UIAlertController(title: "Error", message: "Server has denied your request, please try again later.", preferredStyle: UIAlertControllerStyle.Alert)
                    
                    let defaultAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
                    alert.addAction(defaultAction)
                    
                    self.presentViewController(alert, animated: true, completion: nil)
                    
                } else {
                    
                    var interimTweets = tweets!
                    let tweetRemoved = interimTweets.removeAtIndex(0)
                    self.tweets? += interimTweets
                    
                    self.reloadIt()
                    
                }
            })
        }
    }
    
    func refreshTweets (sender: AnyObject) {
        
        var url : NSURL?
        var parameters : Dictionary<String, String>?
        
        if timeLineType == 2 {
            url = NSURL(string: "https://api.twitter.com/1.1/statuses/user_timeline.json")
            parameters = ["count" : "25", "screen_name" : selectedUser!]
        } else if timeLineType == 1 {
            url = NSURL(string: "https://api.twitter.com/1.1/statuses/home_timeline.json")
            parameters = ["count" : "25"]
        } else {
            println("No timeline type set currently")
        }
        
        let isRefresh = true
        
        self.networkController.getAnyTimeLine(url!, parameters: parameters!, isRefresh: true, newestTweet: self.tweets?[0], oldestTweet: nil) { (errorDescription, tweets) -> (Void) in
            
            if errorDescription != nil {
                //alert the user that something went wrong
                println("ERROROROROROR")
                var alert = UIAlertController(title: "Error", message: "Server has denied your request, please try again later.", preferredStyle: UIAlertControllerStyle.Alert)
                
                let defaultAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
                alert.addAction(defaultAction)
                
                self.presentViewController(alert, animated: true, completion: nil)
                self.refreshControl?.endRefreshing()
            } else {
                println(self.tweets?.count)
                var tweetsInterim : [Tweet]? = tweets
                tweetsInterim! += self.tweets!
                self.tweets = tweetsInterim!
                println("tweet count is \(self.tweets?.count)")
                self.refreshControl?.endRefreshing()
                
                self.reloadIt()
                
            }
        }
    }
    
    // ---------------------------------------------
    // #MARK: Table Header
    // ---------------------------------------------
    
    func setUserHeader() { // Set up the header on the tableview with the user's image and information
        if self.userFor == nil {

            self.networkController.getUserID({ (imageSmall, userName, userHandle, userDict) -> (Void) in
                self.userFor = User(imageSmall: imageSmall, userName: userName, userHandle: userHandle)
                
                let interval : NSTimeInterval = self.masterInterval
                UIView.transitionWithView(self.userForImage, duration: interval, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: { () -> Void in
                    self.userForImage.image = self.userFor?.userImageSmall as UIImage!
                    }, completion: nil)
                UIView.transitionWithView(self.userForHandle, duration: interval, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: { () -> Void in
                    self.userForHandle.text = self.userFor?.screenName as String!
                    }, completion: nil)
                UIView.transitionWithView(self.userForName, duration: interval, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: { () -> Void in
                    self.userForName.text = self.userFor?.userName as String!
                    }, completion: nil)
                
                println("user name on self is \(self.userFor!.userName)")
                
            })
        }
    }
    
    @IBAction func didTapUserSelf(sender: AnyObject) {
        
        let timeLineView = self.storyboard?.instantiateViewControllerWithIdentifier("TWEET_LIST`") as HomeTimelineViewController
        
        timeLineView.timeLineType = 2
        timeLineView.selectedUser = self.userFor!.screenName
        
        self.navigationController?.pushViewController(timeLineView, animated: true)
        
    }
    
    @IBAction func didTapHomeButton(sender: UITapGestureRecognizer) {
        
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    // ---------------------------------------------
    // #MARK: TableView
    // ---------------------------------------------
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if self.tweets != nil {
            return tweets!.count

        } else {
            return 0
        }

    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cellIdentifier = "TWEET_CELL"

        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as TweetCell
        let tweetForRow = self.tweets?[indexPath.row]
        let interval : NSTimeInterval = self.masterInterval
        
        UIView.transitionWithView(cell, duration: interval, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: { () -> Void in

            cell.tweetLabel.text = tweetForRow?.text
            cell.nameLabel.text = tweetForRow?.userName
            cell.handleLabel.text = tweetForRow?.screenName
            
            cell.tweetLabel.preferredMaxLayoutWidth = cell.frame.size.width - 50 - 20
            
            if self.imageCache[tweetForRow!.userName] != nil {
                cell.userView?.image = self.imageCache[tweetForRow!.userName]
            } else {
                
                self.networkController.getUserImage(tweetForRow!, tweetDictionary: tweetForRow!.tweetDictionary, completionHandler: { (imageSmall, imageLarge) -> (Void) in
                    tweetForRow?.userImageSmall = imageSmall
                    tweetForRow?.userImageLarge = imageLarge
                    
                    cell.userView?.image = tweetForRow?.userImageSmall
                    self.imageCache[tweetForRow!.userName] = tweetForRow!.userImageSmall
                })
                
                
            }
            
        }, completion: nil)
        
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let singleTweetView = self.storyboard?.instantiateViewControllerWithIdentifier("SINGLE_TWEET") as SingleTweetViewController
        var selectedTweet = self.tweets![indexPath.row]
        singleTweetView.selectedTweet = selectedTweet
        
        self.navigationController?.pushViewController(singleTweetView, animated: true)
    }
    
    func reloadIt () {
        // Experimenting with straight reloads of TableView or crossfade reloads of tableview
        // pluses and minuses to each
        
        //        self.tableView.reloadData()
        
        let interval : NSTimeInterval = self.masterInterval
        UIView.transitionWithView(self.tableView, duration: interval, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: { () -> Void in
            self.tableView.reloadData()
            }, completion: nil)
    }


}
