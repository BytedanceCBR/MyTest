//
//  TTVAudioSessionManager.h
//  Article
//
//  Created by Chen Hong on 16/3/24.
//
//

#import <Foundation/Foundation.h>

@interface TTVAudioSessionManager : NSObject

+ (instancetype)sharedInstance;

- (BOOL)setCategory:(NSString *)category;

- (void)setActive:(BOOL)active;

@end
