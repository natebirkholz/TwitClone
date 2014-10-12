//
//  NetworkController.swift
//  TwitClone
//
//  Created by Nathan Birkholz on 10/8/14.
//  Copyright (c) 2014 Nate Birkholz. All rights reserved.
//

import Foundation
import Accounts
import Social
import UIKit

class NetworkController {
    var twitterAccount : ACAccount?
    var tweets : [Tweet]?
    var imageQueue = NSOperationQueue()
    
    
    init() {
        self.imageQueue.maxConcurrentOperationCount = 6
//        self.imageQueue.cancelAllOperations()
    }
    
    func getAnyTimeLine(url : NSURL, parameters : Dictionary<String, String>, isRefresh: Bool, newestTweet : Tweet?, oldestTweet: Tweet?, completionHandler : (errorDescription : String?, tweets : [Tweet]?) -> (Void)) {
        
        let accountStore = ACAccountStore()
        let accountType = accountStore.accountTypeWithAccountTypeIdentifier(ACAccountTypeIdentifierTwitter)
        
        accountStore.requestAccessToAccountsWithType(accountType, options: nil) { (granted, error : NSError!) -> Void in

            if granted {
                let accounts = accountStore.accountsWithAccountType(accountType)
                self.twitterAccount = accounts.first as? ACAccount
                
                var url = url as NSURL?
                var parameters = parameters as Dictionary?
                var newestTweet = newestTweet as Tweet?
                var oldestTweet = oldestTweet as Tweet?
                
                if newestTweet != nil {
                    parameters!["since_id"] = String(newestTweet!.tweetID)
                }

                if oldestTweet != nil {
                    parameters!["max_id"] = String(oldestTweet!.tweetID)
                }
                
                let twitterRequest = SLRequest(forServiceType: SLServiceTypeTwitter, requestMethod: SLRequestMethod.GET, URL: url, parameters: parameters)
                twitterRequest.account = self.twitterAccount
                
                twitterRequest.performRequestWithHandler({ (data, httpResponse, error) -> Void in
                    
                    if error != nil {
                        println(error.localizedDescription)
                    }
                    
                    println(httpResponse)
                    
                    switch httpResponse.statusCode {
                    case 200...299:
                        let tweets = Tweet.parseJSONDataIntoTweets(data)
                        self.tweets = tweets!
                        println("Did that")
                        println(tweets?.count)
                        
                        NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                            completionHandler(errorDescription: nil, tweets: tweets)
                        })
                        
                    case 400...499:
                        println("client's fault")
                        println(httpResponse.description)
                        completionHandler(errorDescription: "Bad request to server", tweets: nil)
                        
                    case 500...599:
                        println("server's fault")
                        completionHandler(errorDescription: "Unable to contact server", tweets: nil)
                    default:
                        println("Something bad happened, code not found")
                    }
                    
                })
            }
        }
    }
    
    func getUserID(completionHandler : (imageSmall : UIImage, userName: String, userHandle: String, userDict: NSDictionary) -> (Void)) ->Void {
        let url = NSURL(string: "https://api.twitter.com/1.1/statuses/user_timeline.json")
        
        let twitterRequest = SLRequest(forServiceType: SLServiceTypeTwitter, requestMethod: SLRequestMethod.GET, URL: url, parameters: nil)
        twitterRequest.account = self.twitterAccount
        
        twitterRequest.performRequestWithHandler({ (data, httpResponse, error) -> Void in
            
            let tweets = Tweet.parseJSONDataIntoTweets(data)
            let tweetForID = tweets?.first as Tweet!
            
            let tweetDictionary = tweetForID.tweetDictionary
            var userDictionary = tweetDictionary["user"] as NSDictionary
            
            let avatarStringSmall = userDictionary["profile_image_url"] as String
            let imageURLSmall = NSURL(string: avatarStringSmall as String)
            let imageDataSmall = NSData(contentsOfURL: imageURLSmall)
            let userImageSmall = UIImage(data: imageDataSmall)
            
            let userName = userDictionary["name"] as String
            let userHandle = userDictionary["screen_name"] as String
            let userDict = tweetDictionary
            
            NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                completionHandler(imageSmall: userImageSmall, userName: userName, userHandle: userHandle, userDict: userDict)                })
            
        })
    }
    
    func getUserImage (tweet : Tweet, tweetDictionary : NSDictionary!, completionHandler : (imageSmall : UIImage, imageLarge : UIImage) -> (Void)) {
        
        self.imageQueue.addOperationWithBlock { () -> Void in
            var userDictionary = tweetDictionary["user"] as NSDictionary
            let avatarStringSmall = userDictionary["profile_image_url"] as String
            
            let normalRange = avatarStringSmall.rangeOfString("_normal", options: nil, range: nil, locale: nil)
            let newString = avatarStringSmall.stringByReplacingCharactersInRange(normalRange!, withString: "")
            
            let imageURLSmall = NSURL(string: avatarStringSmall as String)
            let imageDataSmall = NSData(contentsOfURL: imageURLSmall)
            let userImageSmall = UIImage(data: imageDataSmall)
            
            let imageURLLarge = NSURL(string: newString as String)
            let imageDataLarge = NSData(contentsOfURL: imageURLLarge)
            let userImageLarge = UIImage(data: imageDataLarge)
            
            NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                completionHandler(imageSmall: userImageSmall, imageLarge: userImageLarge)
 
            })
        }
    }
    

}