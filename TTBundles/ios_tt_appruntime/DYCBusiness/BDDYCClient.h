//
//  BDDYCClient.h
//  BDDynamically
//
//  Created by zuopengliu on 21/5/2018.
//

#import <Foundation/Foundation.h>
#if __has_include("BDDYCMain.h")
#import "BDDYCMain.h"
#define BDDYC_ENABLED 1
#elif __has_include(<BDDynamically/BDDYCMain.h>)
#import <BDDynamically/BDDYCMain.h>
#define BDDYC_ENABLED 1
#endif



NS_ASSUME_NONNULL_BEGIN


@interface BDDYCClient : NSObject
+ (void)start;
+ (void)close;
+ (void)unloadWithName:(NSString *)modName;
@end



@interface BDDYCClient (OnlyForDebug)
+ (void)startAsDebug;
+ (void)loadAtPath:(NSString *)path; // only for DEBUG
+ (void)loadZipAtPath:(NSString *)zipPath; // only for DEBUG
@end



@interface BDDYCClient (SchemeLaunch)

@end


NS_ASSUME_NONNULL_END
