

#ifndef _TOUTIAO_HPP_
#define _TOUTIAO_HPP_

#include <string>
#include <map>
#include <memory>
#include <stdint.h>

namespace smlc{

//product
namespace toutiao {

    static const int32_t FPID = 1;

    static const int32_t APPID_NEWS_ARTICLE = 13;
    static const int32_t APPID_NEWS_ARTICLE_SOCIAL = 19;
    static const int32_t APPID_EXPLORE_ARTICLE = 26;

    int32_t dispatch(const int32_t service, const int32_t method, const std::string &payloadEncoding, const std::string &payloadType, const std::string &payload, const uint64_t seqid, const uint64_t logid, std::shared_ptr<std::map<std::string, std::string> > headers);
    
    //service
    class Badge {
    public:
        static const int32_t ServiceId =  1;
        static int32_t dispatch(const int32_t method, const std::string &payloadEncoding, const std::string &payloadType, const std::string &payload, const uint64_t seqid, const uint64_t logid, std::shared_ptr<std::map<std::string, std::string> > headers);
    
        static const int32_t MethodIdDongtai = 1;
        static int32_t onDongtai(const std::string &payloadEncoding, const std::string &payloadType, const std::string &payload, const uint64_t seqid, const uint64_t logid, std::shared_ptr<std::map<std::string, std::string> > headers);
    };

    //service
    class Im {
    public:
        static const int32_t ServiceId =  2;
        static int32_t dispatch(const int32_t method, const std::string &payloadEncoding, const std::string &payloadType, const std::string &payload, const uint64_t seqid, const uint64_t logid, std::shared_ptr<std::map<std::string, std::string> > headers);
    
        static const int32_t MethodIdSendmsg = 1;
        static int32_t onSendmsg(const std::string &payloadEncoding, const std::string &payloadType, const std::string &payload, const uint64_t seqid, const uint64_t logid, std::shared_ptr<std::map<std::string, std::string> > headers);
    };
    
    class Notification {
    public:
        static const int32_t ServiceId =  3;
        static int32_t dispatch(const int32_t method, const std::string &payloadEncoding, const std::string &payloadType, const std::string &payload, const uint64_t seqid, const uint64_t logid, std::shared_ptr<std::map<std::string, std::string> > headers);
        
        static const int32_t MethodIdGetDomain = 1;
        static int32_t onGetDomainUpdated(const std::string &payloadEncoding, const std::string &payloadType, const std::string &payload, const uint64_t seqid, const uint64_t logid, std::shared_ptr<std::map<std::string, std::string> > headers);
        
        static const int32_t MethodIdTestURL = 3;
        static int32_t onTestURL(const std::string &payloadEncoding, const std::string &payloadType, const std::string &payload, const uint64_t seqid, const uint64_t logid, std::shared_ptr<std::map<std::string, std::string> > headers);
    };
    
    class UGCMessage {
    public:
        static const int32_t ServiceId =  4;
        static int32_t dispatch(const int32_t method, const std::string &payloadEncoding, const std::string &payloadType, const std::string &payload, const uint64_t seqid, const uint64_t logid, std::shared_ptr<std::map<std::string, std::string> > headers);
        
        static const int32_t MethodIdUGCMessage = 1;
        static int32_t onMessage(const std::string &payloadEncoding, const std::string &payloadType, const std::string &payload, const uint64_t seqid, const uint64_t logid, std::shared_ptr<std::map<std::string, std::string> > headers);
    };
    
}

}

#endif
