//
//  TTVPlayerAudioController.h
//  Pods
//
//  Created by panxiang on 2017/5/23.
//
//

#import <Foundation/Foundation.h>

@interface TTVPlayerAudioController : NSObject

+ (TTVPlayerAudioController *)sharedInstance;
- (void)setCategory:(NSString *)category;
- (void)setActive:(BOOL)active;
@end
