//
//  TTToutiaoFantasyManager.h
//  Article
//
//  Created by 王霖 on 2017/12/25.
//

#import <Foundation/Foundation.h>

@interface TTToutiaoFantasyManager : NSObject

+ (instancetype)sharedManager;

- (void)fantasyConfig;

- (void)updateHProjectSettings:(NSDictionary *)settings;

- (UIImage *)entryIconImage;

@end
