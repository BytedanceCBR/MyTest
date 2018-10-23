#ifndef ZZSECURITY_PURE_C_PROJECT_tfcc_V1_V5_HEADER_H_
#define ZZSECURITY_PURE_C_PROJECT_tfcc_V1_V5_HEADER_H_

#include <stdint.h>

#include "zznacl/zznacl.h"
#include "libtfcc.h"

//#ifndef WIN32
//typedef uint8_t BYTE;
//typedef uint8_t* LPBYTE;
//typedef uint32_t DWORD;
//#endif

#ifdef  __cplusplus
extern "C" {
#endif

    enum { kMD5HexLen = 16 };

    enum ProtoVersion
    {
        kProtoVersionUnknown = 0,
        kProtoVersion1 = 1,
        kProtoVersion5 = 5,
    };

    enum AsymmetricEncryptMethod {
        kOpenSSLRSA0 = 0, // OpenSSL RSA
        kNaclECAsymmetric = 1, // Nacl EC
        kAsymmetricEncryptMethodNum
    };

    enum AsymmetricPublicPrivateMethod {
        kAsymmetricPublicEncrypt = 0,
        kAsymmetricPrivateEncrypt = 1,
        kAsymmetricPublicPrivateMethodNum
    };


    // copy from netproto/include/message.h

#pragma pack(push,1)
    //TODO 大小端有问题

    struct NppRequestHeaderV1
    {
        uint8_t  version_;       //! The protocol version
        union {
            struct {
                uint8_t asymmetric_encrypt_method_ : 4; // low 4 bits
                uint8_t symmetric_encrypt_method_ : 4; // high 4 bits
            };
            uint8_t encrypt_type_;
        };
        union {
            struct {
                uint8_t compress_method_ : 4;
                uint8_t response_symmetrickey_type_ : 4;
            };
            uint8_t response_symmetrickey_compress_type_;
        };
        uint8_t asymmetric_encrypt_key_no_;
        uint8_t  asymmetric_encrypt_data_len_; //! The length of asymmetric encrypted data of symmetric_encrypt_key,  1/8
        uint8_t method_;
        uint32_t crc32_;
    };

    struct NppResponseHeaderV1
    {
        uint8_t  version_;       //! The protocol version
        uint8_t  errno_;
        union {
            struct {
                uint8_t compress_method_ : 4;
                uint8_t reserved : 4;
            };
        };
        uint8_t method_;
        uint32_t crc32_;
        uint16_t session_symmetric_key_id_;
        uint16_t session_symmetric_key_expiry_munites_;
        uint8_t  session_symmetric_key_len_;

    };

    struct NppHeaderV5 {

        uint8_t		version_;
        union {
            struct {
                uint8_t		compress_method_ : 4; // low 4 bits			
                uint8_t		errno_ : 4;// high 3 bits . enum ResponseErrorCode
            };
            uint8_t	compress_;
        };
        uint8_t		encrypt_type_;
        uint16_t	encrypt_keyid_;
        uint8_t	    method_;
        uint32_t	crc32_;

    };

#pragma pack(pop)


#define kMaxPubKey 5 // 最大的key个数
#define kNaclECPubKeyLen 32
#define kNaclECNonceLen 24
#define kSymmetricKeyLen 16

    typedef struct pubkey_info_s
    {
        int		    id;
        nacl_key32_t   key;
        char        nonce[kNaclECNonceLen];
    } pubkey_info_t;

    typedef struct symmkey_info_s
    {
        int64_t expired_timestamp; // UTC时间戳
        uint8_t symm_key[kSymmetricKeyLen];
        int symm_key_type; // 目前只支持3， 即AES_ECB_128
        int symm_key_id;
    } symmkey_info_t;

    // 目前只支持1个公钥key
    typedef struct tfcc_handler_impl_s
    {
        pubkey_info_t public_key;

        symmkey_info_t temp_symm_key; // v1加密时使用。
        symmkey_info_t session_symm_key; // 由v1协商的服务器返回的session对称秘钥
        int error_code;
        int net_method;
        int compress_method;
    } tfcc_handler_impl_t;

    bool tfcc_random_bytes(unsigned char *x, unsigned long xlen);
    void tfcc_init_v1_header(struct NppRequestHeaderV1* hrd, const void* plain, size_t plain_len, const tfcc_handler_impl_t* h);
    bool tfcc_build_v1_request(tfcc_handler_t vh, const void* plain, size_t plain_len, char* cipher_buf, size_t* cipher_buf_len);
    bool tfcc_parse_v1_response(tfcc_handler_t vh, const void* cipher, size_t cipher_len, char* plain_buf, size_t* plain_buf_len);
    bool tfcc_build_v5_request(tfcc_handler_t vh, const void* plain, size_t plain_len, char* cipher_buf, size_t* cipher_buf_len);
    bool tfcc_parse_v5_response(tfcc_handler_t vh, const void* cipher, size_t cipher_len, char* plain_buf, size_t* plain_buf_len);



#ifdef  __cplusplus
}
#endif


#endif
