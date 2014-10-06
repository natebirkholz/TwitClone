//
//  HomeTimelineViewController.swift
//  TwitClone
//
//  Created by Nathan Birkholz on 10/6/14.
//  Copyright (c) 2014 Nate Birkholz. All rights reserved.
//

import UIKit

class HomeTimelineViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var tableView: UITableView!
    
    var tweets : [Tweet]?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        if let path = NSBundle.mainBundle().pathForResource("tweet", ofType: "json") {
            var error : NSError?
            
            let jsonData = NSData(contentsOfFile: path)
            self.tweets = Tweet.parseJSONDataIntoTweets(jsonData)
            
            println(tweets?.count)

        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        println("numberOfRows")
        println("tweets are \(self.tweets?)")
        
        if self.tweets != nil {
            println("count is \(tweets!.count)")
            return tweets!.count

        } else {
            println("got a nil")
            return 0
        }

    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        

        let cell = tableView.dequeueReusableCellWithIdentifier("TWEET_CELL", forIndexPath: indexPath) as UITableViewCell
        let tweetForRow = self.tweets?[indexPath.row]
        cell.textLabel?.text = tweetForRow?.text
        
        return cell
    }
    


}
