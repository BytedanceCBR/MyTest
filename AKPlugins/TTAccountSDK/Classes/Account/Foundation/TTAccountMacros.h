//
//  TTAccountMacros.h
//  TTAccountSDK
//
//  Created by liuzuopeng on 2/9/17.
//  Copyright © 2017 com.bytedance.news. All rights reserved.
//

#ifndef TTAccountMacros_h
#define TTAccountMacros_h



/***********************************************************
 *                                                         *
 *                  Singleton macros                       *
 *                                                         *
 ***********************************************************/
#define TTAccountSingletonDecl \
    + (instancetype)sharedInstance;

#define TTAccountSingletonImp \
    + (instancetype)sharedInstance { \
        static id sharedInst = nil;     \
        static dispatch_once_t onceToken; \
        dispatch_once(&onceToken, ^{    \
            sharedInst = [self new];    \
        });     \
        return sharedInst;  \
    }



#ifdef TTAccountIsEmptyString
    #undef TTAccountIsEmptyString
#endif
#define TTAccountIsEmptyString(str) \
    (!str || ![str isKindOfClass:[NSString class]] || str.length == 0)



/***********************************************************
 *                                                         *
 *                  dispatch macros                        *
 *                                                         *
 ***********************************************************/
#ifdef tta_dispatch_sync_main_thread_safe
    #undef tta_dispatch_sync_main_thread_safe
#endif
#define tta_dispatch_sync_main_thread_safe(block) \
    ({   \
        typeof (block) _tmpBlockInDispatch = (block); \
        if ([NSThread isMainThread]) { \
            if (_tmpBlockInDispatch) _tmpBlockInDispatch(); \
        } else { \
            dispatch_sync(dispatch_get_main_queue(), ^{if (_tmpBlockInDispatch) _tmpBlockInDispatch();}); \
        }   \
    })



#ifdef tta_dispatch_async_main_thread_safe
    #undef tta_dispatch_async_main_thread_safe
#endif
#define tta_dispatch_async_main_thread_safe(block) \
    ({   \
        typeof (block) _tmpBlockInDispatch = (block); \
        if ([NSThread isMainThread]) { \
            if (_tmpBlockInDispatch) _tmpBlockInDispatch(); \
        } else { \
            dispatch_async(dispatch_get_main_queue(), ^{if (_tmpBlockInDispatch) _tmpBlockInDispatch();}); \
        }   \
    })



/***********************************************************
 *                                                         *
 *                  Color Macros                           *
 *                                                         *
 ***********************************************************/
#define TTAccountUIColorFromHexRGB(rgbValue) \
    [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
                    green:((float)((rgbValue & 0x00FF00) >>  8))/255.0 \
                     blue:((float)((rgbValue & 0x0000FF) >>  0))/255.0 \
                    alpha:1.0]

#define TTAccountUIColorFromHexRGBA(rgbaValue) \
    [UIColor colorWithRed:((float)((rgbaValue & 0xFF000000) >> 24))/255.0 \
                    green:((float)((rgbaValue & 0x00FF0000) >>  16))/255.0 \
                     blue:((float)((rgbaValue & 0x0000FF00) >>  8))/255.0 \
                    alpha:((float)((rgbaValue & 0x000000FF) >>  0))/255.0]



/***********************************************************
 *                                                         *
 *                  Device Context                         *
 *                                                         *
 ***********************************************************/
#define TTACCOUNT_IS_IPAD \
    (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)

#define TTACCOUNT_IS_IPHONE \
    (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)

#define TTACCOUNT_DEVICE_SYS_VERSION \
    ([[[UIDevice currentDevice] systemVersion] floatValue])



#ifdef TTALogD
    #undef TTALogD
#endif
#define TTALogD(format, ...) \
    NSLog(@"TTAccountSDK [DEBUG]>> <func: %s> <line: %d> %@", __FUNCTION__, __LINE__, [NSString stringWithFormat:(format), ##__VA_ARGS__]);

#ifdef TTALogI
    #undef TTALogI
#endif
#define TTALogI(format, ...) \
    NSLog(@"TTAccountSDK [INFO]>> <func: %s> <line: %d> %@", __FUNCTION__, __LINE__, [NSString stringWithFormat:(format), ##__VA_ARGS__]);

#ifdef TTALogW
    #undef TTALogW
#endif
#define TTALogW(format, ...) \
    NSLog(@"TTAccountSDK [WARN]>> <func: %s> <line: %d> %@", __FUNCTION__, __LINE__, [NSString stringWithFormat:(format), ##__VA_ARGS__]);

#ifdef TTALogE
    #undef TTALogE
#endif
#define TTALogE(format, ...) \
    NSLog(@"TTAccountSDK [ERROR]>> <func: %s> <line: %d> %@", __FUNCTION__, __LINE__, [NSString stringWithFormat:(format), ##__VA_ARGS__]);



#endif /* TTAccountMacros_h */
