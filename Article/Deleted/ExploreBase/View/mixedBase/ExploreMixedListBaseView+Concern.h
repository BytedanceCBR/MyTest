//
//  ExploreMixedListBaseView+Concern.h
//  Article
//
//  Created by Chen Hong on 16/5/25.
//
//

#import "ExploreMixedListBaseView.h"

@interface ExploreMixedListBaseView (Concern)

// 发帖
- (void)postThreadSendingNotification:(NSNotification *)notification;

// 发帖失败
- (void)postThreadFailNotification:(NSNotification *)notification;

// 发帖成功
- (void)postThreadSuccessNotification:(NSNotification *)notification;

//删除发送失败的帖子
- (void)deleteFakeThreadNotification:(NSNotification *)notification;

//删除帖子
- (void)deleteThreadNotification:(NSNotification *)notification;

- (void)deleteVideoNotification:(NSNotification *)notification;

- (void)deleteShortVideoNotification:(NSNotification *)notification;

- (void)insertThreadsAndVideosToFeedIfNeededWithIsFromRemote:(BOOL)isFromRemote;

@end
