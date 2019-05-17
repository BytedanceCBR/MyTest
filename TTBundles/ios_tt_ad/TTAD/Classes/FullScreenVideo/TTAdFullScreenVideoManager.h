//
//  TTAdFullScreenVideoManager.h
//  Article
//
//  Created by matrixzk on 24/07/2017.
//
//

#import <Foundation/Foundation.h>

@interface TTAdFullScreenVideoManager : NSObject

+ (instancetype)sharedManager;
@property (nonatomic, assign) CGRect selectedFeedAdCoverFrame;

@end
