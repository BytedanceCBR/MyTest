//
//  TTLCSNotificationOC.h
//  Article
//
//  Created by gaohaidong on 13/06/2017.
//
//

#include <string>
#include <map>
#include <stdint.h>
#include <memory>

class TTLCSNotificationOC {
public:
    static void onGetDomainUpdated(const std::string &payloadEncoding, const std::string &payloadType, const std::string &payload, const uint64_t seqid, const uint64_t logid, std::shared_ptr<std::map<std::string, std::string> > headers);
    
    static void onTestURL(const std::string &payloadEncoding, const std::string &payloadType, const std::string &payload, const uint64_t seqid, const uint64_t logid, std::shared_ptr<std::map<std::string, std::string> > headers);
};
