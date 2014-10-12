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
    
    var tweets : [Tweet]?
    var twitterAccount : ACAccount?
    var userFor : User?
//    enum timeLineType {
//        case home, user
//    }
    var timeLineType = 1
    var networkController : NetworkController!
    
    var refreshControl : UIRefreshControl?
    
    var selectedUser : String?
    
    var imageCache = [String : UIImage]()
    
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var userForImage: UIImageView!
    @IBOutlet weak var userForHandle: UILabel!
    @IBOutlet weak var userForName: UILabel!
    


    
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
        
        
        println("User name is now \(self.userFor?.userName)")
        
        println("view did load")
        
        getTimeLine()
        
        
        

        
        println("This User name is now \(self.userFor?.userName)")
        
        
    }
    override func viewWillAppear(animated: Bool) {
        self.userForHandle.text = self.userFor?.screenName as String!
        self.userForName.text = self.userFor?.userName as String!
        self.userForImage.image = self.userFor?.userImageSmall as UIImage!
        self.tableView.reloadData()
        
        UINavigationBar.appearance().backIndicatorImage = UIImage(named: "imgBack")
        
//        var backImg: UIImage = UIImage(named: "imgBack")
//        backButton.setBackgroundImage(backImg, forState: .Normal, barMetrics: .Default)

    }
    
    func getTimeLine () {
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
            // TODO: Get this from an enum and pass it from a closure so this is just one function
        let url = NSURL(string: "https://api.twitter.com/1.1/statuses/home_timeline.json")
        let parameters : Dictionary = ["count" : "50"]
        
        self.networkController.getAnyTimeLine(url, parameters: parameters, isRefresh: false, newestTweet: nil, oldestTweet: nil, completionHandler: { (errorDescription, tweets) -> (Void) in
            if errorDescription != nil {
                println("Error Description is \(errorDescription)")
            } else {
                self.tweets = tweets
                
//                println("tweets are now \(self.tweets)")
                
                var tweetForID = self.tweets?.first as Tweet!
                
                println("tweetforid is \(tweetForID.userName)")
                
                
                self.setUserHeader()

                
                self.tableView.reloadData()
            }
        })
            // Store the kind of timeline viewed to be able to operate based on it
        
        self.userForHandle.text = self.userFor?.screenName as String!
        self.userForName.text = self.userFor?.userName as String!
        self.userForImage.image = self.userFor?.userImageSmall as UIImage!
        self.tableView.reloadData()

        self.userForHandle.text = self.userFor?.screenName as String!
        self.userForName.text = self.userFor?.userName as String!
        self.userForImage.image = self.userFor?.userImageSmall as UIImage!
        
        timeLineType = 1


    }
    
    func getUserTimeline() {
            // set the URL and paramters from the Twitter API for the User's timeline
            // TODO: Get this from an enum and pass it from a closure so this is just one function
        let url = NSURL(string: "https://api.twitter.com/1.1/statuses/user_timeline.json")
        let parameters : Dictionary = ["count" : "50", "screen_name" : selectedUser!]
        
            // Call the GET from the Network controller using the properties above
        self.networkController.getAnyTimeLine(url, parameters: parameters, isRefresh: false, newestTweet: nil, oldestTweet: nil, completionHandler: { (errorDescription, tweets) -> (Void) in
            if errorDescription != nil {
                println("Error Description is \(errorDescription)")
            } else {
                    // Store the tweets from the closure in the tweets variable for the VC and relaod the table to populate it
                self.tweets = tweets
                
                self.setUserHeader()
                
                self.tableView.reloadData()
            }
        })
        
            // Store the kind of timeline viewed to be able to operate based on it
        timeLineType = 2

        
    }
    
    func setUserHeader() {
        if self.userFor == nil {
            println("isnil")
            self.networkController.getUserID({ (imageSmall, userName, userHandle, userDict) -> (Void) in
                println("userName from closure is \(userName)")
                self.userFor = User(imageSmall: imageSmall, userName: userName, userHandle: userHandle)
                self.userFor!.userImageSmall = imageSmall as UIImage!
                self.userFor!.screenName = userHandle as String!
                self.userFor!.userName = userName as String!
                println("user name on self is \(self.userFor!.userName)")
                
                self.userForHandle.text = self.userFor?.screenName as String!
                self.userForName.text = self.userFor?.userName as String!
                self.userForImage.image = self.userFor?.userImageSmall as UIImage!
            })
        }
    }
    
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
        cell.tweetLabel?.text = tweetForRow?.text
        cell.nameLabel?.text = tweetForRow?.userName
        cell.handleLabel?.text = tweetForRow?.screenName
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
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let singleTweetView = self.storyboard?.instantiateViewControllerWithIdentifier("SINGLE_TWEET") as SingleTweetViewController
        var selectedTweet = self.tweets![indexPath.row]
        singleTweetView.selectedTweet = selectedTweet
        
        
        self.navigationController?.pushViewController(singleTweetView, animated: true)
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
                    //alert the user that something went wrong
                } else {
                    
                    var interimTweets = tweets!
                    let tweetRemoved = interimTweets.removeAtIndex(0)
                    self.tweets? += interimTweets
                    self.tableView.reloadData()
                }
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
                self.refreshControl?.endRefreshing()
            } else {
                println(self.tweets?.count)
                var tweetsInterim : [Tweet]? = tweets
                tweetsInterim! += self.tweets!
                self.tweets = tweetsInterim!
                println("tweet count is \(self.tweets?.count)")
                                self.refreshControl?.endRefreshing()
                self.tableView.reloadData()

            }
        }

            
        
        
    }

    
        
    
//    @IBAction func changeTimeline(sender: UIButton) {
//        if timeLine == timeLineType.user
//        {
//            getHomeTimeline()
//        } else if timeLine == timeLineType.home {
//            getUserTimeline()
//        } else {
//            println("Something went terribly wrong and I don't know what timeline to view")
//        }
//    }
    



}
