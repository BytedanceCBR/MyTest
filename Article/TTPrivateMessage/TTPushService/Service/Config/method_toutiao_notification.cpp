
#include <string>
#include <map>
#include <memory>
#include <stdint.h>
#include "toutiao.hpp"
#include "TTLCSNotificationOC.h"

namespace smlc {
    
    namespace toutiao {
        
        int32_t Notification::onGetDomainUpdated(const std::string &payloadEncoding, const std::string &payloadType, const std::string &payload, const uint64_t seqid, const uint64_t logid, std::shared_ptr<std::map<std::string, std::string> > headers) {
            
            TTLCSNotificationOC::onGetDomainUpdated(payloadEncoding, payloadType, payload, seqid, logid, headers);
            
            return 0;
        }
        
        int32_t Notification::onTestURL(const std::string &payloadEncoding, const std::string &payloadType, const std::string &payload, const uint64_t seqid, const uint64_t logid, std::shared_ptr<std::map<std::string, std::string> > headers) {
            
            TTLCSNotificationOC::onTestURL(payloadEncoding, payloadType, payload, seqid, logid, headers);
            
            return 0;
        }
    }
    
}
