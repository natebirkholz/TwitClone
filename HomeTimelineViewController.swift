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
    enum timeLineType {
        case home, user
    }
    var timeLine : timeLineType?
    var networkController : NetworkController!
    
    var printCount : Int = 0
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var timelineLabel: UILabel!
    
    override func viewDidLoad() {
            super.viewDidLoad()
        
        var appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        self.networkController = appDelegate.networkController
        
        

        
        self.tableView.delegate = self
        
        self.tableView.estimatedRowHeight = 80.0
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        
        
        getHomeTimeline()
        
        

        
    }
    
    func getUserTimeline() {
        let url = NSURL(string: "https://api.twitter.com/1.1/statuses/user_timeline.json")
        let parameters : NSDictionary = ["count" : "50"]
        self.networkController.getAnyTimeLine(url, parameters: parameters, completionHandler: { (errorDescription, tweets) -> (Void) in
            if errorDescription != nil {
                println("HOUSTON BLAH BLAH BLAH")
            } else {
                self.tweets = tweets
                self.tableView.reloadData()
            }
        })
        
        timeLine = timeLineType.user
        timelineLabel.text = "User Timeline"

    }
    
    func getHomeTimeline() {
        let url = NSURL(string: "https://api.twitter.com/1.1/statuses/home_timeline.json")
        let parameters : NSDictionary = ["count" : "50"]
        self.networkController.getAnyTimeLine(url, parameters: parameters, completionHandler: { (errorDescription, tweets) -> (Void) in
            if errorDescription != nil {
                println("HOUSTON BLAH BLAH BLAH")
            } else {
                self.tweets = tweets
                self.tableView.reloadData()
            }
        })
        
        timeLine = timeLineType.home
        timelineLabel.text = "Home Timeline"

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if self.tweets != nil {
            println("count is \(tweets!.count)")
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
        if tweetForRow?.userImage == nil {
            printCount += 1
            println("nil picture \(printCount)")
            tweetForRow?.userImage = networkController.getUserImage(tweetForRow!.tweetDictionary)
        }
        cell.userView?.image = tweetForRow?.userImage

        
        return cell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if segue.identifier == "singleTweetVCSegue" {
            
            let cell = sender as UITableViewCell
            let indexPath = tableView.indexPathForCell(cell)
            let tweetForRow = self.tweets?[indexPath!.row]
            let id = tweetForRow?.tweetID
            println("id is >>>>>>>><><><><><> \(id!)")
            
            println("I AM TRYING TO SEGUE")
            
            let goToVC = segue.destinationViewController as SingleTweetViewController
            println("I AM TRYING TO SEGUE 2 \(goToVC)")
            var selectedTweet: Tweet?
            println("I AM TRYING TO SEGUE")
            
            self.networkController.getTweetJSONForID(id!, completionHandler: { (errorDescription, tweet) -> (Void) in
                println(":::::::::::::::::::::::::::::::::::::::::::::")
                println(tweet!)
                
                if errorDescription != nil {
                    println("HOUSTON BLAH BLAH BLAH")
                } else {

                    selectedTweet = tweet!
                }
            })
            println("I AM TRYING TO SEGUE")
            println(selectedTweet)
            goToVC.selectedTweet = selectedTweet
            
            println("I AM TRYING TO SEGUE")

            
            
        } else {
            //println("create")
        }
    }
    

    
    @IBAction func changeTimeline(sender: UIButton) {
        if timeLine == timeLineType.user
        {
            getHomeTimeline()
        } else if timeLine == timeLineType.home {
            getUserTimeline()
        } else {
            println("Something went terribly wrong and I don't know what timeline to view")
        }
    }
    
    @IBAction func comeHome(segue : UIStoryboardSegue) {
        UIView.animateWithDuration(0.5, delay: 0.0, options: UIViewAnimationOptions.TransitionFlipFromBottom, animations: { () -> Void in
            println("")
        }, completion: nil)
        println("welcome home")
    }


}
