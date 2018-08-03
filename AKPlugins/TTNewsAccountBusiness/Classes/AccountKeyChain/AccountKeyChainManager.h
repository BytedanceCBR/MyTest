//
//  AccountKeyChainManager.h
//  Article
//
//  Created by Dianwei on 13-5-12.
//
//

#import <Foundation/Foundation.h>



@interface AccountKeyChainManager : NSObject

+ (AccountKeyChainManager *)sharedManager;

- (void)start;

- (NSDictionary *)accountFromKeychain;

@end
