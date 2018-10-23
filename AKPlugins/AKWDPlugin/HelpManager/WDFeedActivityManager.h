//
//  WDFeedActivityManager.h
//  Article
//
//  Created by 延晋 张 on 2017/8/1.
//
//

#import <Foundation/Foundation.h>

@interface WDFeedActivityManager : NSObject

@property (nonatomic, readonly, strong) UIImage *image;
@property (nonatomic, readonly, copy) NSString *openURL;

+ (instancetype)sharedInstance;

- (void)refreshActivityWithDict:(NSDictionary *)dit;

- (BOOL)isValidDate;


- (BOOL)isCurrentVersionHasShown;
- (void)setCurrentVersionHasShown:(BOOL)shown;

- (BOOL)isCurrentVersionHasClosed;
- (void)setCurrentVersionHasClosed:(BOOL)closed;

@end
