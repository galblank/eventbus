//
//  CommManager.swift
//  mobilesdkfw
//
//  Created by Gal Blank on 2/4/16.
//  Copyright © 2016 Goemerchant. All rights reserved.
//

import UIKit

//
//  CommMamanger.m
//  Created by Gal Blank on 5/21/14.
//  Copyright (c) 2014 Gal Blank. All rights reserved.
//

public class CommManager : NSObject {
    
    public static let sharedCommSingletonDelegate = CommManager()
    
    var ROOT_API:String?
    
    let imagesDownloadQueue = [NSObject : AnyObject]()
    override init() {
        super.init()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(CommManager.consumeMessage(_:)), name: "api.*", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(CommManager.consumeMessage(_:)), name: "api.get", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(CommManager.consumeMessage(_:)), name: "api.post", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(CommManager.consumeMessage(_:)), name: "api.batchPost", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(CommManager.consumeMessage(_:)), name: "api.fullpost", object: nil)
        ROOT_API = NSBundle.mainBundle().infoDictionary!["rootapi"] as? String
    }
    
    
    func consumeMessage(notification: NSNotification) {
        let msg: Message = (notification.userInfo!["message"] as! Message)
        
        var paramsDict = msg.params as! [NSObject : AnyObject]
        let payload = paramsDict["payload"]

        let passThruAPI = msg.passthruAPI

        if msg.httpMethod.caseInsensitiveCompare("get") == NSComparisonResult.OrderedSame {
            self.getAPI(paramsDict["api"] as! String, andParams: payload)
        }
        else if msg.httpMethod.caseInsensitiveCompare("post") == NSComparisonResult.OrderedSame {
            self.postAPI(paramsDict["api"] as! String, andParams: payload)
        }
        else if msg.httpMethod.caseInsensitiveCompare("batchPost") == NSComparisonResult.OrderedSame {
            self.batchPostAPI(paramsDict["api"] as! String, andParams: payload)
        }
        else if msg.httpMethod.caseInsensitiveCompare("fullpost") == NSComparisonResult.OrderedSame {
            self.postFullAPI(paramsDict["api"] as! String, andParams: payload, passThruAPI:passThruAPI)
        }
        msg.selfDestruct()
    }
    
    
    func postFullAPI(api: String, andParams params:AnyObject?, passThruAPI:String) {
        let manager: AFHTTPRequestOperationManager = AFHTTPRequestOperationManager()
        manager.requestSerializer = AFJSONRequestSerializer()
        manager.responseSerializer = AFJSONResponseSerializer()
        manager.responseSerializer.acceptableContentTypes = NSSet(array: ["text/plain","application/json"]) as Set<NSObject>
        manager.POST(api, parameters:params, success: {(operation: AFHTTPRequestOperation, responseObject: AnyObject) -> Void in
            let msg: Message = Message(routKey: "internal.apiresponse")
            msg.params = ["api":api, "data":responseObject]
            msg.passthruAPI = passThruAPI
            MessageDispatcher.sharedDispacherInstance.addMessageToBus(msg)
            }, failure: {(operation, error: NSError) -> Void in
                NSLog("Error: %@", error)
        })
    }
    
    
    func getAPI(api: String, andParams params:AnyObject?) {
        let manager: AFHTTPRequestOperationManager = AFHTTPRequestOperationManager()
        manager.responseSerializer.acceptableContentTypes = NSSet(array: ["text/plain","application/json","text/html"]) as Set<NSObject>
        
        let fullAPI: String = String(format: "%@/%@",ROOT_API!,api)

        manager.GET(fullAPI, parameters: params, success: {(operation: AFHTTPRequestOperation, responseObject: AnyObject) -> Void in
            let msg: Message = Message(routKey: "internal.apiresponse")
            msg.params = ["api":api, "data":responseObject]
            var _:AFHTTPRequestOperation?
            MessageDispatcher.sharedDispacherInstance.addMessageToBus(msg)
            }, failure: {(operation, error: NSError) -> Void in
                NSLog("Error: %@", error)
        })
    }
    
    func postAPI(api: String, andParams params:AnyObject?) {
        let manager: AFHTTPRequestOperationManager = AFHTTPRequestOperationManager()

        manager.responseSerializer.acceptableContentTypes = NSSet(array: ["text/plain","application/json"]) as Set<NSObject>
        let fullAPI: String = String(format: "%@/%@",ROOT_API!,api)
        manager.POST(fullAPI, parameters: params, success: {(operation: AFHTTPRequestOperation, responseObject: AnyObject) -> Void in
            let msg: Message = Message(routKey: "internal.apiresponse")
            msg.params = ["api":api, "data":responseObject]
            MessageDispatcher.sharedDispacherInstance.addMessageToBus(msg)
            }, failure: {(operation, error: NSError) -> Void in
                NSLog("Error: %@", error)
        })
    }
    
    /**
    Handle Batch POSTs
    
    - Parameter api:   The API endpoint.
    - Parameter params:   The message parameter list.
    */

    func batchPostAPI(api: String, andParams paramsList: AnyObject?) {
        let manager: AFHTTPRequestOperationManager = AFHTTPRequestOperationManager()
        manager.responseSerializer.acceptableContentTypes = NSSet(objects: "text/plain") as Set<NSObject>
        manager.responseSerializer.acceptableContentTypes = NSSet(objects: "application/json") as Set<NSObject>
        if let params = paramsList as? [[NSObject : AnyObject]] {
//            print("params: \(params)")
            if let requestOperations = buildRequestOperationsForApi(api, withParamsList: params) {
//             print("\(requestOperations.count)")
                
                let batchOperations:[AnyObject] = AFURLConnectionOperation.batchOfRequestOperations(requestOperations,
                    progressBlock: { (numberOfFinishedOperations: UInt, totalNumberOfOperations: UInt) -> Void in
                        //                    print("\(numberOfFinishedOperations) of \(totalNumberOfOperations) completed");
                    }) { (ops:[AnyObject]) -> Void in
                        //                    print("")
                        
                        var responseList:[[NSObject : AnyObject]] = [[NSObject : AnyObject]]();
                        //
                        let opsArray = ops as! [AFHTTPRequestOperation]
                        for op in opsArray {
                            let afReqObject: AFHTTPRequestOperation = op
                           
                            if let responseObject = afReqObject.responseObject as? NSData {
                                let responseDict: [NSObject : AnyObject] = try! NSJSONSerialization.JSONObjectWithData(responseObject, options: NSJSONReadingOptions.AllowFragments) as! [NSObject : AnyObject]
                                
                                //                        print("Operation: \(afReqObject.responseString!)")
                                
                                responseList.append(responseDict["data"] as! [NSObject : AnyObject])
                            }

                        }
                        
                        // Send Array of response dictionaries on message bus
                        if responseList.count > 0 {
                            let msg: Message = Message(routKey: "internal.apiresponse")
                            msg.params = ["api":api,"data":responseList]
                            MessageDispatcher.sharedDispacherInstance.addMessageToBus(msg)
                        }
                        
                        
                }
                
                NSOperationQueue.mainQueue().addOperations(batchOperations as! [NSOperation], waitUntilFinished: false)
            }
        } else {
            print("do nothing!!")
        }

    }

    /**
    Build a set of request operations for AFNetworking.
    Need to format these request as form data (not JSON) since implementing the older WS model.
    NOTE: When new API implemented, use JSON.
    
    - Parameter api:   The API endpoint.
    - Parameter params:   The message parameter list.
    */
    func buildRequestOperationsForApi(api: String, withParamsList paramsList: [[NSObject : AnyObject]]) -> [AFHTTPRequestOperation]? {
        var mutableOperations: [AFHTTPRequestOperation]?
        let fullAPI: String = api

        for params: [NSObject : AnyObject] in paramsList {
//            print("params:\(params)")
            // FORM DATA AF REQUEST
            let request:NSURLRequest = AFHTTPRequestSerializer().multipartFormRequestWithMethod("POST", URLString: fullAPI, parameters: nil, constructingBodyWithBlock: { (formData:AFMultipartFormData) -> Void in
                for (key, value) in params {
//                    NSLog("key: %@", key)
//                    if  (value.isKindOfClass(NSNumber)) {
//                        NSLog("value: %@", value.stringValue.dataUsingEncoding(NSUTF8StringEncoding)!)
//                    } else {
//                       NSLog("value: %@", value.dataUsingEncoding(NSUTF8StringEncoding)!)
//                    }
                    
                    formData.appendPartWithFormData(value.stringValue.dataUsingEncoding(NSUTF8StringEncoding)!, name: key as! String)
                }

            }, error: nil)
            
            // add a nil check and create the array if it is nil
            if mutableOperations == nil {
                mutableOperations = []
            }
            
//            print("request: \(request)")

            let operation:AFHTTPRequestOperation = AFHTTPRequestOperation.init(request: request)

            mutableOperations?.append(operation)
//            print("count: \(mutableOperations?.count)")

        }
        
        return mutableOperations
    }

}