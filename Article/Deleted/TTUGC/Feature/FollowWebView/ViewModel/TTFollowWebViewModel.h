//
//  TTFollowWebViewModel.h
//  Article
//
//  Created by 王霖 on 16/8/19.
//
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class TTFollowNotify;

@interface TTFollowWebViewModel : NSObject

@property (nonatomic, copy, readonly) NSURL * url;
@property (nonatomic, copy, readonly, nullable) NSString * html;
@property (nonatomic, assign, readonly) BOOL isRequesting;

- (instancetype)initWithRefreshBlock:(nullable void(^)(NSString * _Nullable html, TTFollowNotify * _Nullable followNotify))refreshBlock
                 willEnterForeground:(nullable void(^)(void))willEnterForegroundBlock
                  didEnterBackground:(nullable void(^)(void))didEnterBackgroundBlock NS_DESIGNATED_INITIALIZER;

- (void)refreshWithCompletion:(nullable void(^)(NSError * _Nullable error, NSString * _Nullable html))completion;

- (void)refreshWithFollowNotify:(TTFollowNotify *)followNotify;

@end

NS_ASSUME_NONNULL_END
