#pragma once

#include "libtfcc.h"

#ifdef  __cplusplus
#include <string>
namespace tfcc
{
    inline std::string build_request(tfcc_handler_t h, const void* plain, size_t plain_len)
    {
        size_t cipher_len = tfcc_request_bound(plain_len);
        std::string cipher;
        cipher.resize(cipher_len);
        bool r = tfcc_build_request(h, plain, plain_len, &cipher[0], &cipher_len);
        if (r && cipher_len <= cipher.size())
        {
            cipher.resize(cipher_len);
            return cipher;
        }

        return "";
    }

    inline std::string parse_response(tfcc_handler_t h, const void* cipher, size_t cipher_len)
    {
        size_t plain_len = tfcc_response_bound(cipher_len);
        std::string plain;
        plain.resize(plain_len);
        bool r = tfcc_parse_response(h, cipher, cipher_len, &plain[0], &plain_len);
        if (r && plain_len <= plain.size())
        {
            plain.resize(plain_len);
            return plain;
        }

        return "";
    }

    class Handler
    {
    public:
        Handler()
        {
            h_ = tfcc_create_handler();
        }

        ~Handler()
        {
            tfcc_destroy_handler(h_);
            h_ = NULL;
        }

        bool AddPublicKey(int public_key_id, const void *public_key, const char* nonce)
        {
            return tfcc_add_public_key(h_, public_key_id, public_key, nonce);
        }

        bool AddSymmetricKey(int symmetric_encrypt_method, int symmetric_key_id, const void *symmetric_key, size_t symmetric_key_len, int64_t expired_timestamp)
        {
            return tfcc_add_symmetric_key(h_, symmetric_encrypt_method, symmetric_key_id, symmetric_key, symmetric_key_len, expired_timestamp);
        }

        void SetNetMethod(int method)
        {
            tfcc_set_net_method(h_, method);
        }

        void SetCompressMethod(int method) {
            tfcc_set_compress_method(h_, method);
        }

        std::string Encrypt(const void* plain, size_t plain_len)
        {
            return build_request(h_, plain, plain_len);
        }

        std::string Decrypt(const void* cipher, size_t cipher_len)
        {
            return parse_response(h_, cipher, cipher_len);
        }

        int GetLastError()
        {
            return tfcc_error_code(h_);
        }

    public:
        static size_t CipherBound(size_t plain_len)
        {
            return tfcc_request_bound(plain_len);
        }

    private:
        tfcc_handler_t h_;
    };

}
#endif // end of #ifdef  __cplusplus

