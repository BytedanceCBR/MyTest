//
//  TTDongtaiServiceOC.m
//  TTPushManager
//
//  Created by gaohaidong on 7/13/16.
//  Copyright © 2016 bytedance. All rights reserved.
//

#import "TTDongtaiServiceOC.h"
#import "TTBadgeService.h"
#import <Foundation/Foundation.h>

void TTDongtaiServiceOC::onDongtai(const std::string &payloadEncoding, const std::string &payloadType, const std::string &payload, const uint64_t seqid, const uint64_t logid, std::shared_ptr<std::map<std::string, std::string> > headers) {
    
    BadgeUpdateMessage *msg = [[BadgeUpdateMessage alloc] init];
    
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
    
    NSDictionary *userInfo = @{kTTBadgeServiceDongtaiBadgeUpdateMessageUserInfoKey: msg};
    // NOTE! NSNotification is not in MAIN thread!
    [[NSNotificationCenter defaultCenter] postNotificationName:kTTBadgeServiceDongtaiBadgeUpdateMessage object:nil userInfo:userInfo];
}
