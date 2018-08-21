//
//  TTUGCMessageServiceOC.mm
//  TTUGCMessageServiceOC
//
//  Created by chaisong on 10/29/17.
//  Copyright © 2017 bytedance. All rights reserved.
//

#import "TTUGCMessageServiceOC.h"

void TTUGCMessageServiceOC::onMessage(const std::string &payloadEncoding, const std::string &payloadType, const std::string &payload, const uint64_t seqid, const uint64_t logid, std::shared_ptr<std::map<std::string, std::string> > headers) {
    // NOTE! NSNotification is not in MAIN thread!
    [[NSNotificationCenter defaultCenter] postNotificationName:@"kTTUGCMessageUpdateMessage" object:nil userInfo:nil];
}
