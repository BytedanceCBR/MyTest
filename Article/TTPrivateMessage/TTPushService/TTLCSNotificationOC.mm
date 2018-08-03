//
//  TTLCSNotificationOC.m
//  Article
//
//  Created by gaohaidong on 13/06/2017.
//
//

#import "TTLCSNotificationOC.h"
#import "TTNetworkManager.h"

void TTLCSNotificationOC::onGetDomainUpdated(const std::string &payloadEncoding, const std::string &payloadType, const std::string &payload, const uint64_t seqid, const uint64_t logid, std::shared_ptr<std::map<std::string, std::string> > headers) {
    
    [[TTNetworkManager shareInstance] doRouteSelection];
    
}

void TTLCSNotificationOC::onTestURL(const std::string &payloadEncoding, const std::string &payloadType, const std::string &payload, const uint64_t seqid, const uint64_t logid, std::shared_ptr<std::map<std::string, std::string> > headers) {
    
    [[TTNetworkManager shareInstance] doCommand:@(payload.c_str())];
}
