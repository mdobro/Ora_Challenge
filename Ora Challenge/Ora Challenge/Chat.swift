//
//  Chat.swift
//  Ora Challenge
//
//  Created by Mike Dobrowolski on 9/18/17.
//  Copyright © 2017 Ora. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class Chat {
    
    let baseURL = "https://private-e46dd-orachallenge.apiary-mock.com/api/v1/"
    var headers = [ "Content-Type" : "application/vnd.api+json", "Accept" : "application/vnd.api+json"]
    
    var delegate:ViewController!
    
    var username:String!
    var messages = [Message]()
    
    //called when the app starts to begin a session
    func startSession() {
        Alamofire.request(baseURL+"sessions", method: .post, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            switch(response.result) {
            case .success(let value):
                let json = JSON(value)
                //print(json)
                let responseHeaders = response.response!.allHeaderFields
                self.headers["Authorization"] = (responseHeaders["Authorization"] as! String)
                self.username = json["included"][0]["attributes"]["username"].stringValue
                self.delegate.updateUserName(username: self.username)
                self.getMessage(url: self.baseURL + "messages?page[number]=1&page[size]=10")
            case .failure(let error):
                print(error)
                //TODO: alert user
            }
        }
    }
    
    //called when the app has a successful session connection to gather messages from the server
    //in production, this functions would either need to be run every few seconds to poll for new messages or, preferably, some type of notification service would be employed
    private func getMessage(url:String) {
        Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            switch(response.result) {
            case .success(let value):
                let json = JSON(value)
                //print(json)
                let date = json["data"][0]["attributes"]["created_at"].stringValue
                let formattedDate = self.formatISODate(isoDateString: date)
                let user = json["included"][0]["attributes"]["username"].stringValue
                let message = json["data"][0]["attributes"]["message"].stringValue
                self.messages.append(Message(user: user, date: formattedDate.0, time: formattedDate.1, message: message))
                self.messages.sort { ($0.date, $0.time) < ($1.date, $1.time) }
                self.delegate.reloadChat()
                //call again if there is another message
                //TODO: Test with production API
                if let nextLink = json["links"]["next"].string {
                    self.getMessage(url: nextLink)
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    //called to send a message to the server
    func sendMessage(message:String) {
        let parameters : [String : Any] = [
            "data" : [
                "type" : "messages",
                "attributes": [
                    "message": message
                ]
            ]
        ]
        Alamofire.request(self.baseURL + "messages", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            switch(response.result) {
            case .success(let value):
                let json = JSON(value)
                //print(json)
                //ideally, we'd use info returned from the server, but for now I'll use local info to make the app feel better to use
                let formattedDate = self.formatDate(date: Date())
                self.messages.append(Message(user: self.username, date: formattedDate.0, time: formattedDate.1, message: message))
                self.messages.sort { ($0.date, $0.time) < ($1.date, $1.time) }
                self.delegate.reloadChat()
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func formatDate(date:Date) -> (String, String) {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.dateFormat = "MMM d"
        let dateString = dateFormatter.string(from: date) + ","
        dateFormatter.dateFormat = "hh:mma"
        let timeString = dateFormatter.string(from: date)
        return (dateString, timeString)
    }
    
    func formatISODate(isoDateString:String) -> (String, String) {
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.timeZone = TimeZone(abbreviation: "UTC")
        if let date = isoFormatter.date(from: isoDateString) {
            return formatDate(date: date)
        }
        return ("", "")
    }
}
