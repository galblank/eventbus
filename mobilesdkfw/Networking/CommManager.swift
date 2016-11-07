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
    case fthttpCodesNo1XXInformationalUnknown = 1
    case fthttpCodesNo100Continue = 100
    case fthttpCodesNo101SwitchingProtocols = 101
    case fthttpCodesNo102Processing = 102
    
    // Success
    case fthttpCodesNo2XXSuccessUnknown = 2
    case fthttpCodesNo200OK = 200
    case fthttpCodesNo201Created = 201
    case fthttpCodesNo202Accepted = 202
    case fthttpCodesNo203NonAuthoritativeInformation = 203
    case fthttpCodesNo204NoContent = 204
    case fthttpCodesNo205ResetContent = 205
    case fthttpCodesNo206PartialContent = 206
    case fthttpCodesNo207MultiStatus = 207
    case fthttpCodesNo208AlreadyReported = 208
    case fthttpCodesNo209IMUsed = 209
    
    // Redirection
    case fthttpCodesNo3XXSuccessUnknown = 3
    case fthttpCodesNo300MultipleChoices = 300
    case fthttpCodesNo301MovedPermanently = 301
    case fthttpCodesNo302Found = 302
    case fthttpCodesNo303SeeOther = 303
    case fthttpCodesNo304NotModified = 304
    case fthttpCodesNo305UseProxy = 305
    case fthttpCodesNo306SwitchProxy = 306
    case fthttpCodesNo307TemporaryRedirect = 307
    case fthttpCodesNo308PermanentRedirect = 308
    
    // Client error
    case fthttpCodesNo4XXSuccessUnknown = 4
    case fthttpCodesNo400BadRequest = 400
    case fthttpCodesNo401Unauthorised = 401
    case fthttpCodesNo402PaymentRequired = 402
    case fthttpCodesNo403Forbidden = 403
    case fthttpCodesNo404NotFound = 404
    case fthttpCodesNo405MethodNotAllowed = 405
    case fthttpCodesNo406NotAcceptable = 406
    case fthttpCodesNo407ProxyAuthenticationRequired = 407
    case fthttpCodesNo408RequestTimeout = 408
    case fthttpCodesNo409Conflict = 409
    case fthttpCodesNo410Gone = 410
    case fthttpCodesNo411LengthRequired = 411
    case fthttpCodesNo412PreconditionFailed = 412
    case fthttpCodesNo413RequestEntityTooLarge = 413
    case fthttpCodesNo414RequestURITooLong = 414
    case fthttpCodesNo415UnsupportedMediaType = 415
    case fthttpCodesNo416RequestedRangeNotSatisfiable = 416
    case fthttpCodesNo417ExpectationFailed = 417
    case fthttpCodesNo418IamATeapot = 418
    case fthttpCodesNo419AuthenticationTimeout = 419
    case fthttpCodesNo420MethodFailureSpringFramework = 420
    case fthttpCodesNo420EnhanceYourCalmTwitter = 4200
    case fthttpCodesNo422UnprocessableEntity = 422
    case fthttpCodesNo423Locked = 423
    case fthttpCodesNo424FailedDependency = 424
    case fthttpCodesNo424MethodFailureWebDaw = 4240
    case fthttpCodesNo425UnorderedCollection = 425
    case fthttpCodesNo426UpgradeRequired = 426
    case fthttpCodesNo428PreconditionRequired = 428
    case fthttpCodesNo429TooManyRequests = 429
    case fthttpCodesNo431RequestHeaderFieldsTooLarge = 431
    case fthttpCodesNo444NoResponseNginx = 444
    case fthttpCodesNo449RetryWithMicrosoft = 449
    case fthttpCodesNo450BlockedByWindowsParentalControls = 450
    case fthttpCodesNo451RedirectMicrosoft = 451
    case fthttpCodesNo451UnavailableForLegalReasons = 4510
    case fthttpCodesNo494RequestHeaderTooLargeNginx = 494
    case fthttpCodesNo495CertErrorNginx = 495
    case fthttpCodesNo496NoCertNginx = 496
    case fthttpCodesNo497HTTPToHTTPSNginx = 497
    case fthttpCodesNo499ClientClosedRequestNginx = 499
    
    
    // Server error
    case fthttpCodesNo5XXSuccessUnknown = 5
    case fthttpCodesNo500InternalServerError = 500
    case fthttpCodesNo501NotImplemented = 501
    case fthttpCodesNo502BadGateway = 502
    case fthttpCodesNo503ServiceUnavailable = 503
    case fthttpCodesNo504GatewayTimeout = 504
    case fthttpCodesNo505HTTPVersionNotSupported = 505
    case fthttpCodesNo506VariantAlsoNegotiates = 506
    case fthttpCodesNo507InsufficientStorage = 507
    case fthttpCodesNo508LoopDetected = 508
    case fthttpCodesNo509BandwidthLimitExceeded = 509
    case fthttpCodesNo510NotExtended = 510
    case fthttpCodesNo511NetworkAuthenticationRequired = 511
    case fthttpCodesNo522ConnectionTimedOut = 522
    case fthttpCodesNo598NetworkReadTimeoutErrorUnknown = 598
    case fthttpCodesNo599NetworkConnectTimeoutErrorUnknown = 599
}

open class CommManager : NSObject {
    
    open static let sharedCommSingletonDelegate = CommManager()
    
    open var isInitialized = false
    
    open var ROOT_API:String?
    
    open let imagesDownloadQueue = [AnyHashable: Any]()
    override init() {
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(CommManager.consumeMessage(_:)), name: NSNotification.Name(rawValue: "api.*"), object: nil)
        NotificationCenter.default.addObserver(self, selector:#selector(CommManager.consumeMessage(_:)), name: NSNotification.Name(rawValue: "api.get"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(CommManager.consumeMessage(_:)), name: NSNotification.Name(rawValue: "api.post"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(CommManager.consumeMessage(_:)), name: NSNotification.Name(rawValue: "api.batchPost"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(CommManager.consumeMessage(_:)), name: NSNotification.Name(rawValue: "api.fullpost"), object: nil)
        ROOT_API = Bundle.main.infoDictionary!["rootapi"] as? String
        
        isInitialized = true
    }
    
    
    func consumeMessage(_ notification: Notification) {
        let msg: Message = ((notification as NSNotification).userInfo!["message"] as! Message)
        
        var paramsDict = msg.params as! [AnyHashable: Any]
        let payload = paramsDict["payload"]
        let callbackpoint = msg.callBackPoint
        let passThruAPI = msg.passthruAPI
        var authtoken = ""
        if msg.authtoken.lengthOfBytes(using: String.Encoding.utf8) > 0{
            authtoken = msg.authtoken
        }
        
        if msg.httpMethod.caseInsensitiveCompare("get") == ComparisonResult.orderedSame {
            self.getAPI(paramsDict["api"] as! String, andParams: payload as AnyObject?, callbackpoint: callbackpoint,authtoken: authtoken, passThruAPI: passThruAPI,passThruParams:  msg.passthruParams, shouldAppendRoot: true)
        }
        else if msg.httpMethod.caseInsensitiveCompare("post") == ComparisonResult.orderedSame {
            self.postAPI(paramsDict["api"] as! String, andParams: payload as AnyObject?, callbackpoint: callbackpoint,authtoken: authtoken, passThruAPI: passThruAPI,passThruParams: msg.passthruParams, shouldAppendRoot: true)
        }
        else if msg.httpMethod.caseInsensitiveCompare("fullpost") == ComparisonResult.orderedSame {
            self.postAPI(paramsDict["api"] as! String, andParams: payload as AnyObject?, callbackpoint: callbackpoint,authtoken: authtoken, passThruAPI: passThruAPI,passThruParams: msg.passthruParams, shouldAppendRoot: false)
        }
        else if msg.httpMethod.caseInsensitiveCompare("fullget") == ComparisonResult.orderedSame {
            self.getAPI(paramsDict["api"] as! String, andParams: payload as AnyObject?, callbackpoint: callbackpoint,authtoken: authtoken, passThruAPI: passThruAPI,passThruParams:  msg.passthruParams, shouldAppendRoot: false)
        }
        msg.selfDestruct()
    }

    
    func getAPI(_ api: String, andParams params:AnyObject?, callbackpoint:String, authtoken:String, passThruAPI:String, passThruParams:AnyObject?, shouldAppendRoot:Bool) {
        
        var headers = [
            "Accept": "application/json"
        ]
        
        if(authtoken.lengthOfBytes(using: String.Encoding.utf8) > 0){
            let hdr = "Bearer \(authtoken)"
            headers["AUTHORIZATION"] = hdr
        }
        
        var fullAPI: String = ""
        if(shouldAppendRoot){
            fullAPI = String(format: "%@/%@",ROOT_API!,api)
        }
        else{
            fullAPI = api
        }
        
        Alamofire.sharedInstance.request(.GET, fullAPI, parameters: params as? [String:AnyObject], encoding: .json, headers: headers).responseJSON { (responseObject) in
            self.returnResponse(api, callbackpoint:callbackpoint, passThruAPI: passThruAPI, passThruParams: passThruParams,responseObject: responseObject)
        }
    }
    
    
    func returnResponse(_ api:String, callbackpoint:String, passThruAPI:String, passThruParams:AnyObject?, responseObject:Response)
    {
        let msg: Message = Message(routKey: "internal.apiresponse")
        msg.callBackPoint = callbackpoint
        if(passThruParams != nil){
            msg.passthruParams = passThruParams
        }
        
        if(responseObject.response == nil){
            msg.routingKey = "internal.apierror"
            msg.params = ["api":api, "errno":Int((responseObject.result.error?.code)!)]
        }
        else if(responseObject.response!.statusCode == HTTPERRORCODES.fthttpCodesNo404NotFound.rawValue)
        {
            msg.routingKey = "internal.apierror"
            msg.params = ["api":api, "errno":responseObject.response!.statusCode]
        }
        else if(responseObject.response!.statusCode == HTTPERRORCODES.fthttpCodesNo400BadRequest.rawValue){
            msg.routingKey = "internal.apierror"
            msg.params = ["api":api, "errno":responseObject.response!.statusCode]
        }
        else if(responseObject.result.value != nil)
        {
            if((responseObject.result.value?.isKind(of: NSDictionary)) == true){
                msg.params = ["api":api, "data":responseObject.result.value as! NSDictionary]
            }
            else if((responseObject.result.value?.isKind(of: NSArray)) == true){
                msg.params = ["api":api, "data":responseObject.result.value as! NSArray]
            }
        }
        else{
            msg.params = ["api":api]
        }
        msg.passthruAPI = passThruAPI
        MessageDispatcher.sharedDispacherInstance.addMessageToBus(msg)
    }
    
    func postAPI(_ api: String, andParams params:AnyObject?, callbackpoint:String, authtoken:String, passThruAPI:String, passThruParams:AnyObject?, shouldAppendRoot:Bool) {
        
        var headers = [
            "Accept": "application/json"
        ]
        
        if(authtoken.lengthOfBytes(using: String.Encoding.utf8) > 0){
            let hdr = "Bearer \(authtoken)"
            headers["AUTHORIZATION"] = hdr
        }
        var fullAPI: String = ""
        if(shouldAppendRoot){
            fullAPI = String(format: "%@/%@",ROOT_API!,api)
        }
        else{
            fullAPI = api
        }
        print(fullAPI)
        Alamofire.sharedInstance.request(.POST, fullAPI, parameters: params as? [String:AnyObject], encoding: .json, headers: headers).responseJSON { (responseObject) in
            self.returnResponse(api, callbackpoint:callbackpoint, passThruAPI: passThruAPI, passThruParams: passThruParams,responseObject: responseObject)
        }
    }
}
