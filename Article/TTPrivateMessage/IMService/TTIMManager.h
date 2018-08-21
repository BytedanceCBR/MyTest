//
//  TTIMManager.h
//  Article
//
//  Created by matrixzk on 28/03/2017.
//
//

#import <Foundation/Foundation.h>


@interface TTIMManager : NSObject

+ (instancetype)sharedManager;

- (void)loginIMService;
- (void)logoutIMService;

@end
