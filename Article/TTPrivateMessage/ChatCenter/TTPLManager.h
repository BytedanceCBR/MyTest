//
//  TTPLManager.h
//  Article
//
//  Created by 杨心雨 on 2017/1/18.
//
//

#import <Foundation/Foundation.h>
#import "TTIMSDKService.h"
#import "TTIMChatCenterViewModel.h"

extern NSString * const kPrivateLetterGetUnreadNumberFinishNofication;

@interface TTPLManager : NSObject

+ (instancetype)sharedManager;

@property (nonatomic, strong) TTIMChatCenterViewModel *chatCenterViewModel;
@property (nonatomic, assign) NSUInteger unreadNumber;
@property (nonatomic, assign) BOOL needShowTip;
@property (nonatomic, assign, readonly) BOOL hasShowTip;

- (void)setHasShowTip;
- (void)refreshUnreadNumber;
- (void)removeUnreadNumberWithSessionName:(NSString *)sessionName;

- (void)setDraft:(NSString *)draft withSessionId:(NSString *)sessionId;
- (NSString *)getDraftWithSessionId:(NSString *)sessionId;

- (void)refreshChatCenterModel;

- (void)resetIMServerEnabled:(BOOL)enable;

@end
