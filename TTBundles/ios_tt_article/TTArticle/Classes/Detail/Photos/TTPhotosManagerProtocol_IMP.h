//
//  TTPhotosManagerProtocol_IMP.h
//  Article
//
//  Created by chenjiesheng on 2017/7/14.
//
//

#import <Foundation/Foundation.h>
#import <TTServiceKit/TTServiceCenter.h>
#import "TTPhotosManagerProtocol.h"

@interface TTPhotosManagerProtocol_IMP : NSObject <TTPhotosManagerProtocol, TTService>

+ (instancetype)sharedInstance;

@end
