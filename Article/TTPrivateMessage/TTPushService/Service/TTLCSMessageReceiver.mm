//
//  TTLCSMessageReceiver.m
//  Article
//
//  Created by gaohaidong on 1/20/17.
//
//

#import "TTLCSMessageReceiver.h"
#import "toutiao.hpp"

@implementation TTLCSMessageReceiver

// return < 0 means unknown message
- (int32_t)dispatch:(const int32_t)service
             method:(const int32_t)method
    payloadEncoding:(const std::string &)payloadEncoding
        payloadType:(const std::string &)payloadType
            payload:(const std::string &)payload
              seqid:(const uint64_t)seqid
              logid:(const uint64_t)logid
            headers:(std::shared_ptr<std::map<std::string, std::string> >)headers {
    
    int32_t ret = smlc::toutiao::dispatch(service, method, payloadEncoding, payloadType, payload, seqid, logid, headers);
    return ret;
}

@end
