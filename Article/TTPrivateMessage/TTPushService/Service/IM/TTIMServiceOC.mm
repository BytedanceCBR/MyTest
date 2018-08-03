//
//  TTIMServiceOC.m
//  Article
//
//  Created by gaohaidong on 1/20/17.
//
//

#import "TTIMServiceOC.h"
#import <Foundation/Foundation.h>
#import "TTIMReceiveMsg.h"
#import "TTIMSDKManager.h"

void TTIMServiceOC::onSendmsg(const std::string &payloadEncoding, const std::string &payloadType, const std::string &payload, const uint64_t seqid, const uint64_t logid, std::shared_ptr<std::map<std::string, std::string> > headers) {
    
    TTIMReceiveMsg *msg = [[TTIMReceiveMsg alloc] init];
    
    msg.logId = logid;
    msg.sequenceId = seqid;
    msg.payloadType = @(payloadType.c_str());
    msg.payloadEncoding = @(payloadEncoding.c_str());
    msg.payload = [[NSData alloc] initWithBytes:payload.data() length:payload.length()];
    if (headers) {
        NSMutableDictionary *headerDict = [[NSMutableDictionary alloc] init];
        for (const auto &header : *headers) {
            headerDict[@(header.first.c_str())] = @(header.second.c_str());
        }
    }
    
    NSDictionary *userInfo = @{kTTIMSDKServicePushMessage: msg};
    // NOTE! NSNotification is not in MAIN thread!
    [[NSNotificationCenter defaultCenter] postNotificationName:kTTIMSDKServicePushMessage object:nil userInfo:userInfo];
}
