//
//  TTVAdActionButtonCommand.h
//  Article
//
//  Created by pei yun on 2017/4/1.
//
//

#import <Foundation/Foundation.h>
#import "TTAdAction.h"
@class TTVFeedItem;
@class TTVFeedCellAction;

@interface TTVADWebModel : NSObject<TTAdDetailAction, TTAd>
@property (nonatomic, copy) NSString *web_url;
@property (nonatomic, copy) NSString *open_url;
@property (nonatomic, copy) NSString *web_title;
@property (nonatomic, copy) NSString *ad_id;
@property (nonatomic, copy) NSString *log_extra;
@end

@protocol TTVAdActionButtonCommandProtocol <NSObject>
@property (nonatomic, strong) TTVFeedItem *feedItem;
@property (nonatomic, copy) NSString *categoryId;
@property (nonatomic, assign)NSUInteger refer;
@property (nonatomic, strong) TTVFeedCellAction *cellAction;
- (void)executeAction;
- (void)playerControlFinishAdAction;
- (void)playerControlLogoTappedAction;

@optional
@property (nonatomic, assign) BOOL showAlert;

@end

@interface TTVAdActionButtonCommand : NSObject<TTVAdActionButtonCommandProtocol>
@property (nonatomic, strong) TTVFeedItem *feedItem;
@property (nonatomic, copy) NSString *categoryId;
@property (nonatomic, assign)NSUInteger refer;
@property (nonatomic, strong) TTVFeedCellAction *cellAction;
- (void)executeAction;
- (void)playerControlFinishAdAction;
@end

@interface TTVAdActionTypeAppButtonCommand : TTVAdActionButtonCommand<TTVAdActionButtonCommandProtocol>
- (void)executeAction;
- (void)playerControlFinishAdAction;
@end

@interface TTVAdActionTypeWebButtonCommand : TTVAdActionButtonCommand<TTVAdActionButtonCommandProtocol>

- (void)executeAction;
- (void)playerControlFinishAdAction;
@end

@interface TTVAdActionTypePhoneButtonCommand : TTVAdActionButtonCommand<TTVAdActionButtonCommandProtocol>

- (void)executeAction;
- (void)playerControlFinishAdAction;
@end

@interface TTVAdActionTypeFormButtonCommand : TTVAdActionButtonCommand<TTVAdActionButtonCommandProtocol>

- (void)executeAction;
- (void)playerControlFinishAdAction;
@end

@interface TTVAdActionTypeCounselButtonCommand : TTVAdActionButtonCommand<TTVAdActionButtonCommandProtocol>

- (void)executeAction;
- (void)playerControlFinishAdAction;
@end

@interface TTVAdActionTypeNormalButtonCommand : TTVAdActionButtonCommand<TTVAdActionButtonCommandProtocol>

- (void)executeAction;
- (void)playerControlFinishAdAction;

@end

