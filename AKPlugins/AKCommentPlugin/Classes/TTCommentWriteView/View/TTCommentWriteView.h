//
//  TTCommentWriteView.h
//  Article
//
//  Created by ranny_90 on 2018/1/4.
//

#import "SSThemed.h"
#import "TTUGCTextView.h"
#import <sys/time.h>
#import "Article.h"
#import "TTCommentWriteViewDefine.h"
#import "TTCommentWriteManager.h"
#import "TTCommentDetailReplyWriteManager.h"

@class TTCommentWriteManager,TTCommentDetailReplyWriteManager;


@interface TTCommentWriteView : SSThemedView

@property (nonatomic, strong) TTUGCTextView * inputTextView;

@property (nonatomic, assign) BOOL banCommentRepost;

@property (nonatomic, assign) BOOL banEmojiInput;

@property (nonatomic, assign) BOOL emojiInputViewVisible;

@property (nonatomic, strong) NSString *repostButtonTitle;

@property (nonatomic, assign) BOOL isDismiss;

@property (nonatomic, assign) BOOL isNeedTips;

//外部接口
- (instancetype)initWithCommentManager:(id<TTCommentManagerProtocol>)commentManager;

- (void)showInView:(UIView *)view animated:(BOOL)animated;

- (void)dismissAnimated:(BOOL) animated;



//以下为内部使用接口
- (void)configureDraftContent:(NSString *)draftContent withDraftContentRichSpan:(NSString *)draftContentRichSpan withDefaultTextPosition:(NSInteger)defaultTextPosition;

- (void)setTextViewPlaceholder:(NSString *)placeholder;

- (void)configurePublishButtonEnable:(BOOL)enable;

- (void)showContentTooLongTip:(NSString *)tips;

- (BOOL)isCommentRepostedChecked;

- (struct timeval)commentTimeval;

@end


