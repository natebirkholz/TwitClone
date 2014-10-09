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
    
    init() {
        
    }
    
    func getAnyTimeLine(url : NSURL, parameters: NSDictionary, completionHandler : (errorDescription : String?, tweets : [Tweet]?) -> (Void)) {
        
        let accountStore = ACAccountStore()
        let accountType = accountStore.accountTypeWithAccountTypeIdentifier(ACAccountTypeIdentifierTwitter)
        
        accountStore.requestAccessToAccountsWithType(accountType, options: nil) { (granted, error : NSError!) -> Void in
            if granted {
                let accounts = accountStore.accountsWithAccountType(accountType)
                self.twitterAccount = accounts.first as? ACAccount
                
                let url = url
                var parameters = parameters
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
    
    func getUserImage (tweetDictionary: NSDictionary) -> (UIImage?) {
        
        var userDictionary = tweetDictionary["user"] as NSDictionary
        let avatarString = userDictionary["profile_image_url"] as String
        println(avatarString)
        let normalRange = avatarString.rangeOfString("_normal", options: nil, range: nil, locale: nil)
        let newString = avatarString.stringByReplacingCharactersInRange(normalRange!, withString: "")
        println(newString)
        let imageURL = NSURL(string: newString as String)
        let imageData = NSData(contentsOfURL: imageURL)
        let userImage = UIImage(data: imageData)
        
        return userImage as UIImage
    }
    
    func getTweetJSONForID(id: Int, completionHandler : (errorDescription : String?, tweet : Tweet?) -> (Void)) {

        let accountStore = ACAccountStore()
        let accountType = accountStore.accountTypeWithAccountTypeIdentifier(ACAccountTypeIdentifierTwitter)

        accountStore.requestAccessToAccountsWithType(accountType, options: nil) { (granted, error : NSError!) -> Void in
            if granted {
                
                let accounts = accountStore.accountsWithAccountType(accountType)
                self.twitterAccount = accounts.first as? ACAccount
                
                let url = NSURL(string: "https://api.twitter.com/1.1/statuses/show.json")
                let parameters : NSDictionary = ["id" : id]
                let twitterRequest = SLRequest(forServiceType: SLServiceTypeTwitter, requestMethod: SLRequestMethod.GET, URL: url, parameters: parameters)
                twitterRequest.account = self.twitterAccount
                
                twitterRequest.performRequestWithHandler({ (data, httpResponse, error) -> Void in
                    
                    if error != nil {
                        println(error.localizedDescription)
                    }
                    
                    println(httpResponse)
                    
                    switch httpResponse.statusCode {
                    case 200...299:
                        let tweet = Tweet.makeJSONDataIntoTweet(data)
                        NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                            completionHandler(errorDescription: nil, tweet: tweet)
                        })
                        
                    case 400...499:
                        println("client's fault")
                        println(httpResponse.description)
                        completionHandler(errorDescription: "Bad request to server", tweet: nil)
                    case 500...599:
                        println("server's fault")
                        completionHandler(errorDescription: "Unable to contact server", tweet: nil)
                    default:
                        println("Something bad happened, code not found")
                    }
                    
                })
                
            } else {
                println("FAILLLLLLLLLLLLL")
            }
        }
        
    }

        

    


//        let tweetDictionary = tweetDictionary
//        let tweetID = tweetDictionary["id"] as Int
//        let url = NSURL(string: "https://api.twitter.com/1.1/statuses/show.json")
//        let parameters : NSDictionary = ["id" : tweetID]




}