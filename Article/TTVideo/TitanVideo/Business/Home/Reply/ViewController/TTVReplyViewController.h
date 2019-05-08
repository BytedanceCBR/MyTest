//
//  TTVReplyViewController.h
//  Article
//
//  Created by lijun.thinker on 2017/6/1.
//
//

#import "SSViewControllerBase.h"
#import "TTGroupModel.h"
#import "TTVCommentModelProtocol.h"
#import "TTCommentDetailModelProtocol.h"

@protocol TTVReplyModelProtocol;
@class TTVReplyViewController;
@protocol TTVReplyViewControllerDelegate <NSObject>

@optional
- (void)videoDetailFloatCommentViewControllerDidDimiss:(TTVReplyViewController *)vc;
- (void)videoDetailFloatCommentViewControllerDidChangeDigCount;
- (void)videoDetailFloatCommentViewCellDidDigg:(BOOL) digged withModel:(id<TTVReplyModelProtocol>)model;

@end

@interface TTVReplyViewController : SSViewControllerBase

@property (nonatomic, assign) CGRect viewFrame;
@property (nonatomic, assign) BOOL showWriteComment;
@property (nonatomic, weak) id<TTVReplyViewControllerDelegate> vcDelegate;
@property (nonatomic, strong) id<TTVReplyModelProtocol> replyMomentCommentModel;
@property (nonatomic, assign) BOOL isAdVideo;
@property (nonatomic, strong) NSString *categoryID;
@property (nonatomic, strong) NSString *enterFromStr;
@property (nonatomic, strong) NSDictionary *logPb;
@property (nonatomic, assign) BOOL isBanEmoji;

- (instancetype)initWithViewFrame:(CGRect)viewFrame comment:(id<TTVCommentModelProtocol, TTCommentDetailModelProtocol>)commentModel showWriteComment:(BOOL)showWriteComment;
- (id <TTVCommentModelProtocol, TTCommentDetailModelProtocol>)commentModel;
@end
