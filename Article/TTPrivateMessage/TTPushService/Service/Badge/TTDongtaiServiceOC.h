//
//  TTDongtaiServiceOC.h
//  TTPushManager
//
//  Created by gaohaidong on 7/13/16.
//  Copyright © 2016 bytedance. All rights reserved.
//

#include <string>
#include <map>
#include <stdint.h>
#include <memory>

class TTDongtaiServiceOC {
public:
    static void onDongtai(const std::string &payloadEncoding, const std::string &payloadType, const std::string &payload, const uint64_t seqid, const uint64_t logid, std::shared_ptr<std::map<std::string, std::string> > headers);
};
