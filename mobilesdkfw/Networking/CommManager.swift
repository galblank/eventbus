import UIKit

//
//  CommMamanger.m
//  Created by Gal Blank on 5/21/14.
//  Copyright (c) 2014 Gal Blank. All rights reserved.
//

public class CommManager : NSObject {
    
    public static let sharedCommSingletonDelegate = CommManager()
    
    let ROOT_API:String = NSBundle.mainBundle().infoDictionary!["rootapi"] as! String
    
    let imagesDownloadQueue = [NSObject : AnyObject]()
    override init() {
        super.init()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "consumeMessage:", name: "api.*", object: nil)
    }
    
    
    func consumeMessage(notification: NSNotification) {
        let msg: Message = (notification.userInfo!["message"] as! Message)
        
        var paramsDict = msg.params as! [NSObject : AnyObject]
        let payload = msg.params!["payload"]
        
        if msg.httpMethod.caseInsensitiveCompare("get") == NSComparisonResult.OrderedSame {
            self.getAPI(paramsDict["api"] as! String, andParams: payload)
        }
        else if msg.httpMethod.caseInsensitiveCompare("post") == NSComparisonResult.OrderedSame {
            self.postAPI(paramsDict["api"] as! String, andParams: payload)
        } else if msg.httpMethod.caseInsensitiveCompare("batchPost") == NSComparisonResult.OrderedSame {
            self.batchPostAPI(paramsDict["api"] as! String, andParams: payload)
        }
        
        msg.selfDestruct()
    }
    
    func getAPI(api: String, andParams params:AnyObject?) {
        let manager: AFHTTPRequestOperationManager = AFHTTPRequestOperationManager()
        manager.responseSerializer.acceptableContentTypes = NSSet(array: ["text/plain","application/json"]) as Set<NSObject>
        
        let fullAPI: String = String(format: "%@/%@",ROOT_API,api)

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
        let fullAPI: String = String(format: "%@/%@",ROOT_API,api)
        manager.POST(fullAPI, parameters: params, success: {(operation: AFHTTPRequestOperation, responseObject: AnyObject) -> Void in
            let msg: Message = Message(routKey: "internal.apiresponse")
            msg.params = ["api":api, "data":responseObject]
//            print("msg.params: \(msg.params)")
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
        let params = paramsList as! [[NSObject : AnyObject]]
        if let requestOperations: [AFHTTPRequestOperation] = buildRequestOperationsForApi(api, withParamsList: params)! {
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
                        let responseObject: NSData = afReqObject.responseObject! as! NSData
                        let responseDict: [NSObject : AnyObject] = try! NSJSONSerialization.JSONObjectWithData(responseObject, options: NSJSONReadingOptions.AllowFragments) as! [NSObject : AnyObject]
                        
//                        print("Operation: \(afReqObject.responseString!)")
                        
                        responseList.append(responseDict["data"] as! [NSObject : AnyObject])
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
            // FORM DATA AF REQUEST
            let request:NSURLRequest = AFHTTPRequestSerializer().multipartFormRequestWithMethod("POST", URLString: fullAPI, parameters: nil, constructingBodyWithBlock: { (formData:AFMultipartFormData) -> Void in
                for (key, value) in params {
                    NSLog("key: %@", key)
                    NSLog("value: %@", value.dataUsingEncoding(NSUTF8StringEncoding)!)
                    formData.appendPartWithFormData(value.dataUsingEncoding(NSUTF8StringEncoding)!, name: key as! String)
                }

            }, error: nil)
            
            let operation:AFHTTPRequestOperation = AFHTTPRequestOperation(request: request)
            mutableOperations?.append(operation)
        }
        
        return mutableOperations
    }

}