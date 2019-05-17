#ifndef ZZSECURITY_PURE_C_PROJECT_tfcc_H_
#define ZZSECURITY_PURE_C_PROJECT_tfcc_H_

#include <stdint.h>
#include <stdbool.h>
#include <stdio.h>

#ifdef  __cplusplus
extern "C" {
#endif
    /**
     * 这仅仅是一个加解密库，用于客户端。不包括任何网络相关代码。
     * 关于网络相关代码请自行根据情况实现。
     *
     * 纯C版本V1+V5加解密库，使用非对称加密算法 NaclEC 和对称加密算法 AES_128_ECB 实现。
     * 该版本程序会自动处理V1和V5切换问题，也会自动处理秘钥过期问题。
     *
     * 一般调用方式分为如下三个阶段进行：
     *  1. 进程初始化阶段：
     *      tfcc_handler_t h = tfcc_create_handler(); // 为每个线程创建一个加解密对象
     *      bool succ = tfcc_add_public_key(h, 1, g_client_nacl_ec_asymmetric_public_key1, tfcc_nonce); // 使用服务端提供的加密秘钥
     *      assert(succ);
     *
     *  2. 程序运行过程中，可以循环利用 h 对象来做加密和解密，该对象不是线程安全的，如果有多个线程，请为每个线程创建独立的对象：
     *      size_t cipher_len = tfcc_request_bound(plain_len);
     *      char* cipher = (char*)malloc(cipher_len);
     *      tfcc_set_net_method(h, i); // 可选。如有必要，请设置网络接口号
     *      tfcc_set_compress_method(h, kZlibCompress); // 可选。如有必要，请设置压缩方式
     *      bool r = tfcc_build_request(h, plain, plain_len, cipher, &cipher_len);
     *      // check r
     *      // 在这里调用网络客户端相关函数(例如libcurl)将加密数据发送给服务器
     *      // 等待服务器返回数据，例如返回的数据如下：
     *      //  char* response_cipher;
     *      //  size_t response_cipher_len;
     *      size_t response_plain_len = tfcc_response_bound(response_cipher_len);
     *      char* response_plain = (char*)malloc(response_plain_len);
     *      r = tfcc_parse_response(h, response_cipher, response_cipher_len, response_plain, &response_plain_len);
     *      // check r
     *      // use response_plain
     *      free(cipher);
     *      cipher = NULL;
     *      free(response_plain);
     *      response_plain = NULL;
     *
     *  3. 进程结束时进行资源析构：
     *      tfcc_destroy_handler(h);
     *
     */

    enum EnumVXERR
    {
        VXERR_OK = 0,
        VXERR_INVAL_ARGS = -1,
        //VXERR_ENC_REQUEST = -2,	// 加密上行包出错
        VXERR_DEC_RESPONSE = -3,	// 解析返回报文出错
        VXERR_OUTOFMEMORY = -4,// 分配内存不够大，需要针对输入参数分配更多内存
        VXERR_NO_SYMKEY = -5,	// 没有对称密钥，需要先执行V1协商
        VXERR_SYMKEY_EXPIRED = -6,	// 对称密钥过期，需要重新用V1协商	
        VXERR_CANCELED = -7,	// 用户取消
        VXERR_NETQUERY = -8,	// 网络查询失败
        VXERR_ENC_REQUEST_ASYMM = -9,	// 加密上行包出错, 非对称加密失败，有可能是内存大小不够
        VXERR_ENC_REQUEST_SYMM = -10,	// 加密上行包出错, 对称加密失败，有可能是内存大小不够
        VXERR_DEC_DATA_FORMAT = -11, // 返回报文格式错误
        VXERR_COMPRESS_DATA_FAILED = -20, // 压缩数据失败
        VXERR_UNCOMPRESS_DATA_FAILED = -21, // 解压缩数据失败
    };

    enum CompressMethod {
        //     0	不压缩(明文)
        //     2	gzip
        //     其他	保留
        kNoCompress = 0,
        //kZlibCompress = 1,
        kGZipCompress = 2,
        kCompressNum
    };

    enum SymmetricEncryptMethod {
        kNoSymmetricEncrypt = 0,
        kXorSymmetricEncrypt = 1,//not use this
        kIDEA_ECB_SymmetricEncrypt = 2,//IDEA ecb
        kAES_128_ECB_SymmetricEncrypt = 3,//aes128ecb
        kDES_ECB_SymmetricEncrypt = 4,//DES_ECB
        kAES_128_CBC_SymmetricEncrypt = 5,//AES_128_CBC
        kSymmetricEncryptMethodNum,
    };

    // 默认的nonce
    extern const char* tfcc_nonce;

    // 具体实现时用的是这个对象：tfcc_handler_impl_t
    typedef void* tfcc_handler_t;

    // @brief : tfcc_create_handler 创建一个加解密handler，用于的加密和解密。
    //  该对象并非线程安全的，如果是多线程环境的话，请注意为每个线程分别创建独立的实例对象。
    //  该对象使用完毕之后，请调用 tfcc_destroy_handler 进行资源释放；如果该对象与进程生命周期一致，图省事的话也可以让操作系统帮忙回收资源。
    //     另外，当同一个app与多个后端server通信时，请分别为每个业务创建独立的 tfcc_handler_t。关于这一点，后期可以考虑为多业务增加统一接口支持！
    // @return tfcc_handler_t - 
    tfcc_handler_t tfcc_create_handler();
    void tfcc_destroy_handler(tfcc_handler_t h);

    // @brief : tfcc_add_public_key 新增一个公钥到 h 中。
    // @param[IN] h -
    // @param[IN] const void * public_key - naclec公钥，32字节
    // @param[IN] int public_key_id - 公钥ID
    // @param[IN] const char * nonce - 24字节长
    // @return bool - 
    bool tfcc_add_public_key(tfcc_handler_t h, int public_key_id, const void *public_key, const char* nonce);


    // @brief 新增一个对称秘钥到 h 中
    // @param[IN] h -
    // @param[IN] symmetric_encrypt_method -
    //  取值，请参考 SymmetricEncryptMethod
    // @param[IN] symmetric_key_id -
    // @param[IN] symmetric_key -
    // @param[IN] symmetric_key_len -
    // @param[IN] expired_timestamp - 过期的时间戳（UTC）。默认值 -1 表示永不过期
    // @return bool -
    bool tfcc_add_symmetric_key(tfcc_handler_t h, int symmetric_encrypt_method, int symmetric_key_id, const void *symmetric_key, size_t symmetric_key_len, int64_t expired_timestamp);

    // @brief : tfcc_set_net_method 会设置v1/v5包头上的 net_method 字段。
    // 该字段可以理解为某一个接口的细分场景。例如针对某一接口 http://host/scan
    //     net_method=0, 是正常的业务逻辑
    //     net_method=1, 是纯数据上传，不做任何业务逻辑
    // 请在 tfcc_build_request 之前调用。
    // 可以不设置，其默认值为0.
    // @param[IN] tfcc_handler_t h - 
    // @param[IN] int net_method - 
    // @return void - 
    void tfcc_set_net_method(tfcc_handler_t h, int net_method);

    // @brief : tfcc_set_compress_method 会设置v1/v5包头上的 compress_method 字段。
    // 请在 tfcc_build_request 之前调用。可以不设置，其默认值为0.
    // @note 当前仅支持 method=kGZipCompress 的压缩算法，即常见的gzip压缩算法。
    // @param[IN] tfcc_handler_t h - 
    // @param[IN] int net_method - 具体值和含义，请参考 CompressMethod
    // @return void - 
    void tfcc_set_compress_method(tfcc_handler_t h, int method);

    // @brief : tfcc_build_request 加密上行报文。 会将明文数据加密，然后存放到 cipher_buf 指向的内存空间中。
    //     如果加密失败，请给 cipher_buf 分配更大的内存空间来重试。
    // @param[IN] const void * plain - 明文数据内存首地址
    // @param[IN] size_t plain_len - 明文数据长度
    // @param[OUT] char * cipher_buf - 密文数据存放地址，由调用者提前分配好，其最小空间容量应该通过 tfcc_request_bound 函数获取
    // @param[IN,OUT] size_t * cipher_buf_len - 输入时 cipher_buf 空间容量，输出为最终加密的密文数据长度
    // @return bool - true if successfully
    bool tfcc_build_request(tfcc_handler_t h, const void* plain, size_t plain_len, char* cipher_buf, size_t* cipher_buf_len);
    inline bool tfcc_encrypt(tfcc_handler_t h, const void* plain, size_t plain_len, char* cipher_buf, size_t* cipher_buf_len) {
        return tfcc_build_request(h, plain, plain_len, cipher_buf, cipher_buf_len);
    }

    // @brief : tfcc_request_bound 针对一个给定的明文长度，返回加密后的密文最大长度
    // @param[IN] size_t plain_len - 明文长度
    // @return size_t - 
    size_t tfcc_request_bound(size_t plain_len);
    inline size_t tfcc_encrypt_bound(size_t plain_len) {
        return tfcc_request_bound(plain_len);
    }

    // @brief : tfcc_parse_response 解密下行报文。
    //     如果解密失败，请给 plain_buf 分配更大的内存空间来重试。
    // @param[IN] tfcc_handler_t h - 
    // @param[IN] const void * cipher - 
    // @param[IN] size_t cipher_len - 
    // @param[OUT] char * plain_buf - 解密后的数据存放地址，由调用者提前分配好，其最小空间容量应该通过 tfcc_response_bound 函数获取
    // @param[IN,OUT] size_t * plain_buf_len - 输入时 plain_buf 空间容量，输出为最终解密后的明文数据长度
    // @return bool - 
    bool tfcc_parse_response(tfcc_handler_t h, const void* cipher, size_t cipher_len, char* plain_buf, size_t* plain_buf_len);
    inline bool tfcc_decrypt(tfcc_handler_t h, const void* cipher, size_t cipher_len, char* plain_buf, size_t* plain_buf_len) {
        return tfcc_parse_response(h, cipher, cipher_len, plain_buf, plain_buf_len);
    }

    // @brief : tfcc_response_bound 针对一个给定的密文数据长度，返回解密后的明文的最大长度
    // @param[IN] size_t cipher_len - 密文长度
    // @return size_t - 
    size_t tfcc_response_bound(size_t cipher_len);
    inline size_t tfcc_decrypt_bound(size_t cipher_len) {
        return tfcc_response_bound(cipher_len);
    }

    // @brief : tfcc_error_code 当加密或解密失败时，该函数可以返回相关错误码
    // @param[IN] tfcc_handler_t h - 
    // @return int - 返回相关的错误码，具体请参见 EnumVXERR
    int tfcc_error_code(tfcc_handler_t h);

#ifdef  __cplusplus
} // extern "C" {
#endif

#endif
