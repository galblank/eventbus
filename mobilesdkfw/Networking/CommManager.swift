//
//  CommManager.swift
//  mobilesdkfw
//
//  Created by Gal Blank on 2/4/16.
//  Copyright © 2016 Gal Blank. All rights reserved.
//

import UIKit

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
    
    public var isInitialized = false
    
    public var ROOT_API:String?
    
    public let imagesDownloadQueue = [NSObject : AnyObject]()
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
            self.getAPI(paramsDict["api"] as! String, andParams: payload, callbackpoint: callbackpoint,authtoken: authtoken, passThruAPI: passThruAPI,passThruParams:  msg.passthruParams)
        }
        else if msg.httpMethod.caseInsensitiveCompare("post") == NSComparisonResult.OrderedSame {
            self.postAPI(paramsDict["api"] as! String, andParams: payload, callbackpoint: callbackpoint,authtoken: authtoken, passThruAPI: passThruAPI,passThruParams: msg.passthruParams)
        }
        else if msg.httpMethod.caseInsensitiveCompare("fullpost") == NSComparisonResult.OrderedSame {
            self.postFullAPI(paramsDict["api"] as! String, andParams: payload, passThruAPI:passThruAPI)
        }
        msg.selfDestruct()
    }
    
    
    func postFullAPI(api: String, andParams params:AnyObject?, passThruAPI:String) {
        let headers = [
            //"Authorization": "Basic QWxhZGRpbjpvcGVuIHNlc2FtZQ==",
            "Accept": "application/json"
        ]
        Alamofire.sharedInstance.request(.POST, api, parameters: params as? [String:AnyObject], encoding: .JSON, headers: headers).responseJSON { (responseObject) in
            if(responseObject.result.error != nil){
                print("Error:\(responseObject.result.error)")
            }
            else{
                let msg: Message = Message(routKey: "internal.apiresponse")
                msg.params = ["api":api, "data":responseObject.data!]
                msg.passthruAPI = passThruAPI
                MessageDispatcher.sharedDispacherInstance.addMessageToBus(msg)
            }
        }
        
    }
    
    
    func getAPI(api: String, andParams params:AnyObject?, callbackpoint:String, authtoken:String, passThruAPI:String, passThruParams:AnyObject?) {
        
        var headers = [
            "Accept": "application/json"
        ]
        
        
        
        if(authtoken.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > 0){
            let hdr = "Bearer \(authtoken)"
            headers["AUTHORIZATION"] = hdr
        }
        
        let fullAPI: String = String(format: "%@/%@",ROOT_API!,api)
        Alamofire.sharedInstance.request(.GET, fullAPI, parameters: params as? [String:AnyObject], encoding: .JSON, headers: headers).responseJSON { (responseObject) in
            if(responseObject.response == nil){
                let msg: Message = Message(routKey: "internal.apierror")
                msg.params = ["title":"Error", "message":"Server is down","errno":0]
                msg.callBackPoint = callbackpoint
                msg.passthruAPI = passThruAPI
                if(passThruParams != nil){
                    msg.passthruParams = passThruParams
                }
                MessageDispatcher.sharedDispacherInstance.addMessageToBus(msg)
            }
            else{
                if(responseObject.response?.statusCode !=  HTTPERRORCODES.FTHTTPCodesNo200OK.rawValue){
                    print("Error:\(responseObject.result.error)")
                    responseObject.result.error?.code
                    
                    let err:Int = Int((responseObject.response?.statusCode)!)
                    print("%d",err)
                    if(err == HTTPERRORCODES.FTHTTPCodesNo404NotFound.rawValue)
                    {
                        let msg: Message = Message(routKey: "internal.apierror")
                        msg.params = ["title":"Error", "message":"Invalid Endpoint","errno":err]
                        msg.callBackPoint = callbackpoint
                        msg.passthruAPI = passThruAPI
                        if(passThruParams != nil){
                            msg.passthruParams = passThruParams
                        }
                        MessageDispatcher.sharedDispacherInstance.addMessageToBus(msg)
                    }
                }
            }
            self.returnResponse(api, callbackpoint:callbackpoint, passThruAPI: passThruAPI, passThruParams: passThruParams,responseObject: responseObject)
        }
    }
    
    
    func returnResponse(api:String, callbackpoint:String, passThruAPI:String, passThruParams:AnyObject?, responseObject:Response<AnyObject,NSError>)
    {
        let msg: Message = Message(routKey: "internal.apiresponse")
        msg.callBackPoint = callbackpoint
        if(passThruParams != nil){
            msg.passthruParams = passThruParams
        }
        
        if(responseObject.response == nil || responseObject.response!.statusCode == HTTPERRORCODES.FTHTTPCodesNo404NotFound.rawValue)
        {
            msg.params = ["api":api, "error":"notfound"]
        }
        else if(responseObject.result.value != nil)
        {
            if((responseObject.result.value?.isKindOfClass(NSDictionary)) == true){
                msg.params = ["api":api, "data":responseObject.result.value as! NSDictionary]
            }
            else if((responseObject.result.value?.isKindOfClass(NSArray)) == true){
                msg.params = ["api":api, "data":responseObject.result.value as! NSArray]
            }
        }
        else{
            msg.params = ["api":api]
        }
        msg.passthruAPI = passThruAPI
        MessageDispatcher.sharedDispacherInstance.addMessageToBus(msg)
    }
    
    func postAPI(api: String, andParams params:AnyObject?, callbackpoint:String, authtoken:String, passThruAPI:String, passThruParams:AnyObject?) {
        
        var headers = [
            "Accept": "application/json"
        ]
        
        if(authtoken.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > 0){
            let hdr = "Bearer \(authtoken)"
            headers["AUTHORIZATION"] = hdr
        }
        
        let fullAPI: String = String(format: "%@/%@",ROOT_API!,api)
        
        Alamofire.sharedInstance.request(.POST, fullAPI, parameters: params as? [String:AnyObject], encoding: .JSON, headers: headers).responseJSON { (responseObject) in
            if(responseObject.response == nil){
                let msg: Message = Message(routKey: "internal.apierror")
                msg.params = ["title":"Error", "message":"Server is down","errno":0]
                msg.callBackPoint = callbackpoint
                msg.passthruAPI = passThruAPI
                if(passThruParams != nil){
                    msg.passthruParams = passThruParams
                }
                MessageDispatcher.sharedDispacherInstance.addMessageToBus(msg)
            }
            else{
                if(responseObject.result.error != nil){
                    print("Error:\(responseObject.result.error)")
                    let err:Int = Int((responseObject.response?.statusCode)!)
                    print("%d",err)
                    if(err == HTTPERRORCODES.FTHTTPCodesNo404NotFound.rawValue)
                    {
                        let msg: Message = Message(routKey: "internal.apierror")
                        msg.params = ["title":"Error", "message":"Invalid Endpoint","errno":err]
                        msg.callBackPoint = callbackpoint
                        msg.passthruAPI = passThruAPI
                        if(passThruParams != nil){
                            msg.passthruParams = passThruParams
                        }
                        MessageDispatcher.sharedDispacherInstance.addMessageToBus(msg)
                    }
                    else if(err >= HTTPERRORCODES.FTHTTPCodesNo200OK.rawValue && err < HTTPERRORCODES.FTHTTPCodesNo400BadRequest.rawValue){
                        self.returnResponse(api, callbackpoint:callbackpoint, passThruAPI: passThruAPI, passThruParams: passThruParams,responseObject: responseObject)
                    }
                }
                else{
                    self.returnResponse(api, callbackpoint:callbackpoint, passThruAPI: passThruAPI, passThruParams: passThruParams,responseObject: responseObject)
                }
            }
            
        }
    }
}