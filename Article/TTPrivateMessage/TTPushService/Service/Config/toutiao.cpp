
#include <string>
#include <map>
#include <memory>
#include <stdint.h>
#include "toutiao.hpp"

namespace smlc{

namespace toutiao {

    int32_t dispatch(const int32_t service, const int32_t method, const std::string &payloadEncoding, const std::string &payloadType, const std::string &payload, const uint64_t seqid, const uint64_t logid, std::shared_ptr<std::map<std::string, std::string> > headers){
        int32_t err=0;
        switch (service) {
            case 1:
                err = Badge::dispatch(method, payloadEncoding, payloadType, payload, seqid, logid, headers);
                break;
            case 2:
                err = Im::dispatch(method, payloadEncoding, payloadType, payload, seqid, logid, headers);
                break;
                
            case 3:
                err = Notification::dispatch(method, payloadEncoding, payloadType, payload, seqid, logid, headers);
                break;
            case 4:
                err = UGCMessage::dispatch(method, payloadEncoding, payloadType, payload, seqid, logid, headers);
                break;
            default:
                err = -1;
        }
        return err;
    }

    int32_t Badge::dispatch(const int32_t method, const std::string &payloadEncoding, const std::string &payloadType, const std::string &payload, const uint64_t seqid, const uint64_t logid, std::shared_ptr<std::map<std::string, std::string> > headers) {
        int32_t err=0;
        switch (method) {
            case Badge::MethodIdDongtai:
                err = Badge::onDongtai(payloadEncoding, payloadType, payload, seqid, logid, headers);
                break;
            default:
                err = -1;
        }
        return err;
    }

    int32_t Im::dispatch(const int32_t method, const std::string &payloadEncoding, const std::string &payloadType, const std::string &payload, const uint64_t seqid, const uint64_t logid, std::shared_ptr<std::map<std::string, std::string> > headers) {
        int32_t err=0;
        switch (method) {
            case Im::MethodIdSendmsg:
                err = Im::onSendmsg(payloadEncoding, payloadType, payload, seqid, logid, headers);
                break;
            default:
                err = -1;
        }
        return err;
    }
    
    int32_t Notification::dispatch(const int32_t method, const std::string &payloadEncoding, const std::string &payloadType, const std::string &payload, const uint64_t seqid, const uint64_t logid, std::shared_ptr<std::map<std::string, std::string> > headers) {
        int32_t err=0;
        switch (method) {
            case Notification::MethodIdGetDomain:
                err = Notification::onGetDomainUpdated(payloadEncoding, payloadType, payload, seqid, logid, headers);
                break;
                
            case Notification::MethodIdTestURL:
                err = Notification::onTestURL(payloadEncoding, payloadType, payload, seqid, logid, headers);
                break;
                
            default:
                err = -1;
        }
        return err;
    }
    
    int32_t UGCMessage::dispatch(const int32_t method, const std::string &payloadEncoding, const std::string &payloadType, const std::string &payload, const uint64_t seqid, const uint64_t logid, std::shared_ptr<std::map<std::string, std::string> > headers) {
        int32_t err=0;
        switch (method) {
            case UGCMessage::MethodIdUGCMessage:
                err = UGCMessage::onMessage(payloadEncoding, payloadType, payload, seqid, logid, headers);
                break;
            default:
                err = -1;
        }
        return err;
    }
}

}
