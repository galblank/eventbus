//
//  CommManager.swift
//  mobilesdkfw
//
//  Created by Gal Blank on 2/4/16.
//  Copyright © 2016 Goemerchant. All rights reserved.
//

import UIKit
import SwiftyJSON

public enum HTTPERRORCODES: Int {
    // Informational
    case FTHTTPCodesNo1XXInformationalUnknown = 1
    case FTHTTPCodesNo100Continue = 100
    case FTHTTPCodesNo101SwitchingProtocols = 101
    case FTHTTPCodesNo102Processing = 102
    
    // Success
    case FTHTTPCodesNo2XXSuccessUnknown = 2
    case FTHTTPCodesNo200OK = 200
    case FTHTTPCodesNo201Created = 201
    case FTHTTPCodesNo202Accepted = 202
    case FTHTTPCodesNo203NonAuthoritativeInformation = 203
    case FTHTTPCodesNo204NoContent = 204
    case FTHTTPCodesNo205ResetContent = 205
    case FTHTTPCodesNo206PartialContent = 206
    case FTHTTPCodesNo207MultiStatus = 207
    case FTHTTPCodesNo208AlreadyReported = 208
    case FTHTTPCodesNo209IMUsed = 209
    
    // Redirection
    case FTHTTPCodesNo3XXSuccessUnknown = 3
    case FTHTTPCodesNo300MultipleChoices = 300
    case FTHTTPCodesNo301MovedPermanently = 301
    case FTHTTPCodesNo302Found = 302
    case FTHTTPCodesNo303SeeOther = 303
    case FTHTTPCodesNo304NotModified = 304
    case FTHTTPCodesNo305UseProxy = 305
    case FTHTTPCodesNo306SwitchProxy = 306
    case FTHTTPCodesNo307TemporaryRedirect = 307
    case FTHTTPCodesNo308PermanentRedirect = 308
    
    // Client error
    case FTHTTPCodesNo4XXSuccessUnknown = 4
    case FTHTTPCodesNo400BadRequest = 400
    case FTHTTPCodesNo401Unauthorised = 401
    case FTHTTPCodesNo402PaymentRequired = 402
    case FTHTTPCodesNo403Forbidden = 403
    case FTHTTPCodesNo404NotFound = 404
    case FTHTTPCodesNo405MethodNotAllowed = 405
    case FTHTTPCodesNo406NotAcceptable = 406
    case FTHTTPCodesNo407ProxyAuthenticationRequired = 407
    case FTHTTPCodesNo408RequestTimeout = 408
    case FTHTTPCodesNo409Conflict = 409
    case FTHTTPCodesNo410Gone = 410
    case FTHTTPCodesNo411LengthRequired = 411
    case FTHTTPCodesNo412PreconditionFailed = 412
    case FTHTTPCodesNo413RequestEntityTooLarge = 413
    case FTHTTPCodesNo414RequestURITooLong = 414
    case FTHTTPCodesNo415UnsupportedMediaType = 415
    case FTHTTPCodesNo416RequestedRangeNotSatisfiable = 416
    case FTHTTPCodesNo417ExpectationFailed = 417
    case FTHTTPCodesNo418IamATeapot = 418
    case FTHTTPCodesNo419AuthenticationTimeout = 419
    case FTHTTPCodesNo420MethodFailureSpringFramework = 420
    case FTHTTPCodesNo420EnhanceYourCalmTwitter = 4200
    case FTHTTPCodesNo422UnprocessableEntity = 422
    case FTHTTPCodesNo423Locked = 423
    case FTHTTPCodesNo424FailedDependency = 424
    case FTHTTPCodesNo424MethodFailureWebDaw = 4240
    case FTHTTPCodesNo425UnorderedCollection = 425
    case FTHTTPCodesNo426UpgradeRequired = 426
    case FTHTTPCodesNo428PreconditionRequired = 428
    case FTHTTPCodesNo429TooManyRequests = 429
    case FTHTTPCodesNo431RequestHeaderFieldsTooLarge = 431
    case FTHTTPCodesNo444NoResponseNginx = 444
    case FTHTTPCodesNo449RetryWithMicrosoft = 449
    case FTHTTPCodesNo450BlockedByWindowsParentalControls = 450
    case FTHTTPCodesNo451RedirectMicrosoft = 451
    case FTHTTPCodesNo451UnavailableForLegalReasons = 4510
    case FTHTTPCodesNo494RequestHeaderTooLargeNginx = 494
    case FTHTTPCodesNo495CertErrorNginx = 495
    case FTHTTPCodesNo496NoCertNginx = 496
    case FTHTTPCodesNo497HTTPToHTTPSNginx = 497
    case FTHTTPCodesNo499ClientClosedRequestNginx = 499
    
    
    // Server error
    case FTHTTPCodesNo5XXSuccessUnknown = 5
    case FTHTTPCodesNo500InternalServerError = 500
    case FTHTTPCodesNo501NotImplemented = 501
    case FTHTTPCodesNo502BadGateway = 502
    case FTHTTPCodesNo503ServiceUnavailable = 503
    case FTHTTPCodesNo504GatewayTimeout = 504
    case FTHTTPCodesNo505HTTPVersionNotSupported = 505
    case FTHTTPCodesNo506VariantAlsoNegotiates = 506
    case FTHTTPCodesNo507InsufficientStorage = 507
    case FTHTTPCodesNo508LoopDetected = 508
    case FTHTTPCodesNo509BandwidthLimitExceeded = 509
    case FTHTTPCodesNo510NotExtended = 510
    case FTHTTPCodesNo511NetworkAuthenticationRequired = 511
    case FTHTTPCodesNo522ConnectionTimedOut = 522
    case FTHTTPCodesNo598NetworkReadTimeoutErrorUnknown = 598
    case FTHTTPCodesNo599NetworkConnectTimeoutErrorUnknown = 599
}

public class CommManager : NSObject {
    
    public static let sharedCommSingletonDelegate = CommManager()
    
    var isInitialized = false
    
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
        
        isInitialized = true
    }
    
    
    func consumeMessage(notification: NSNotification) {
        let msg: Message = (notification.userInfo!["message"] as! Message)
        
        var paramsDict = msg.params as! [NSObject : AnyObject]
        let payload = paramsDict["payload"]
        let callbackpoint = msg.callBackPoint
        let passThruAPI = msg.passthruAPI
        var authtoken = ""
        if msg.authtoken.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > 0{
            authtoken = msg.authtoken
        }
        
        if msg.httpMethod.caseInsensitiveCompare("get") == NSComparisonResult.OrderedSame {
            self.getAPI(paramsDict["api"] as! String, andParams: payload, callbackpoint: callbackpoint,authtoken: authtoken, passThruAPI: passThruAPI)
        }
        else if msg.httpMethod.caseInsensitiveCompare("post") == NSComparisonResult.OrderedSame {
            self.postAPI(paramsDict["api"] as! String, andParams: payload, callbackpoint: callbackpoint,authtoken: authtoken, passThruAPI: passThruAPI)
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
    
    
    func getAPI(api: String, andParams params:AnyObject?, callbackpoint:String, authtoken:String, passThruAPI:String) {
        let manager: AFHTTPRequestOperationManager = AFHTTPRequestOperationManager()
        manager.responseSerializer.acceptableContentTypes = NSSet(array: ["text/plain","application/json","text/html"]) as Set<NSObject>
        
        if(authtoken.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > 0){
            let hdr = "Bearer \(authtoken)"
            manager.requestSerializer.setValue(hdr, forHTTPHeaderField: "AUTHORIZATION")
        }
        
        let fullAPI: String = String(format: "%@/%@",ROOT_API!,api)

        manager.GET(fullAPI, parameters: params, success: {(operation: AFHTTPRequestOperation, responseObject: AnyObject) -> Void in
            let msg: Message = Message(routKey: "internal.apiresponse")
            msg.callBackPoint = callbackpoint
            msg.params = ["api":api, "data":responseObject]
            msg.passthruAPI = passThruAPI
            var _:AFHTTPRequestOperation?
    
            MessageDispatcher.sharedDispacherInstance.addMessageToBus(msg)
            }, failure: {(operation, error: NSError) -> Void in
                NSLog("Error: %@", error)
                let err:Int = Int((operation?.response?.statusCode)!)
                print("%d",err)
                if(err == HTTPERRORCODES.FTHTTPCodesNo404NotFound.rawValue)
                {
                    let msg: Message = Message(routKey: "internal.apierror")
                    msg.params = ["title":"Error", "message":"User is not recognized","errno":err]
                    msg.callBackPoint = callbackpoint
                    msg.passthruAPI = passThruAPI
                    MessageDispatcher.sharedDispacherInstance.addMessageToBus(msg)
                }
                //let status = error.userInfo["]
        })
    }
    
    func postAPI(api: String, andParams params:AnyObject?, callbackpoint:String, authtoken:String, passThruAPI:String) {
        let manager: AFHTTPRequestOperationManager = AFHTTPRequestOperationManager()

        
        manager.responseSerializer.acceptableContentTypes = NSSet(array: ["text/plain","application/json","text/html"]) as Set<NSObject>
        let muSet = NSMutableIndexSet(index: 400)
        muSet.addIndex(200)
        muSet.addIndex(403)
        muSet.addIndex(404)
        manager.responseSerializer.acceptableStatusCodes = muSet
        manager.requestSerializer = AFJSONRequestSerializer()
        if(authtoken.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > 0){
            let hdr = "Bearer \(authtoken)"
            manager.requestSerializer.setValue(hdr, forHTTPHeaderField: "AUTHORIZATION")
        }
        
        let fullAPI: String = String(format: "%@/%@",ROOT_API!,api)
        
        manager.POST(fullAPI, parameters: params, success: {(operation: AFHTTPRequestOperation, responseObject: AnyObject) -> Void in
            //print(responseObject)
            
            let err:Int = Int((operation.response?.statusCode)!)
            let msg: Message?
            
            if(err == HTTPERRORCODES.FTHTTPCodesNo400BadRequest.rawValue)
            {
                msg = Message(routKey: "internal.displayerror")
                msg!.params = ["title":"Error", "message":responseObject[0]]
                msg!.callBackPoint = callbackpoint
                msg!.passthruAPI = passThruAPI
                MessageDispatcher.sharedDispacherInstance.addMessageToBus(msg!)
            }
            else{
                msg = Message(routKey: "internal.apiresponse")
                msg!.callBackPoint = callbackpoint
                msg!.params = ["api":api, "data":responseObject]
                msg!.passthruAPI = passThruAPI
                MessageDispatcher.sharedDispacherInstance.addMessageToBus(msg!)
            }

            }, failure: {(operation, error: NSError) -> Void in
                print(error);
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