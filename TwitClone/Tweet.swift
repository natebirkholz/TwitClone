//
//  Tweet.swift
//  TwitClone
//
//  Created by Nathan Birkholz on 10/6/14.
//  Copyright (c) 2014 Nate Birkholz. All rights reserved.
//

import UIKit

class Tweet {
    
    var text : String
    var userImageSmall : UIImage?
    var userImageLarge : UIImage?
    var userName : String
    var screenName : String
    var tweetDictionary : NSDictionary
    var tweetID : Int
    var tweetFavorites : Int?
    var tweetRetweets : Int?
    
    
    init (tweetDictionary : NSDictionary) {
        let tweetDictionary = tweetDictionary
        self.tweetDictionary = tweetDictionary
        self.text = tweetDictionary["text"] as String
        self.tweetID = tweetDictionary["id"] as Int
        
        var userDictionary = tweetDictionary["user"] as NSDictionary
        
        self.tweetFavorites = tweetDictionary["favorite_count"] as? Int
        self.tweetRetweets = tweetDictionary["retweet_count"] as? Int
        
        self.userName = userDictionary["name"] as String
        self.screenName = userDictionary["screen_name"] as String


    }
    
    class func parseJSONDataIntoTweets(rawJSONData : NSData) -> [Tweet]? {
        var error : NSError?
        
        if let JSONArray = NSJSONSerialization.JSONObjectWithData(rawJSONData, options: nil, error: &error) as? NSArray {
            
            var tweets = [Tweet]()
            
            for JSONDictionary in JSONArray {
                if let tweetDictionary = JSONDictionary as? NSDictionary {
                    var newTweet = Tweet(tweetDictionary : tweetDictionary)
                    
                    tweets.append(newTweet)


                    
                }
                
            }
            
//            tweets.sort { $0.date < $1.date }
            
            return tweets
            
        }
        
        
        
        return nil
    }
    
//    class func makeJSONDataIntoTweet(rawJSONData : NSData) -> Tweet {
//        var error : NSError?
//        
//        if let tweetDictionary = NSJSONSerialization.JSONObjectWithData(rawJSONData, options: nil, error: &error) as? NSDictionary {
//            
//            var tweet = Tweet(tweetDictionary: tweetDictionary)
//            
//            println("the alternative tweet is \(tweet)")
//            
//            return tweet
//
//            
//            }
//            
//        
//        
//
//    
//}

}