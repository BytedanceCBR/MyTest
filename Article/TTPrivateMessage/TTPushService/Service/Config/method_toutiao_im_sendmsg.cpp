
#include <string>
#include <map>
#include <memory>
#include <stdint.h>
#include "toutiao.hpp"
#include "TTIMServiceOC.h"

namespace smlc{

namespace toutiao {

    int32_t Im::onSendmsg(const std::string &payloadEncoding, const std::string &payloadType, const std::string &payload, const uint64_t seqid, const uint64_t logid, std::shared_ptr<std::map<std::string, std::string> > headers) {
        
        TTIMServiceOC::onSendmsg(payloadEncoding, payloadType, payload, seqid, logid, headers);

        return 0;
    }
}

}
