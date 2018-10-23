//
//  TTVideoDetailFloatCommentViewController.h
//  Article
//
//  Created by songxiangwu on 2016/11/2.
//
//

#import "SSViewControllerBase.h"
#import "TTGroupModel.h"
#import "TTCommentModelProtocol.h"
#import "TTAlphaThemedButton.h"
@class TTVideoDetailFloatCommentViewController;

@interface TTVideoDetailFloatCommentTopBar : SSViewBase

@property (nonatomic, strong) TTAlphaThemedButton *closeBtn;
@property (nonatomic, strong) SSThemedLabel *titleLabel;
//@property (nonatomic, strong) TTAlphaThemedButton *moreBtn;
@property (nonatomic, strong) SSThemedView *lineView;
@property (nonatomic, strong) UIImageView *shadowView;

@end

@protocol TTVideoDetailFloatCommentViewControllerDelegate <NSObject>

@optional
- (void)videoDetailFloatCommentViewControllerDidDimiss:(TTVideoDetailFloatCommentViewController *)vc;
- (void)videoDetailFloatCommentViewControllerDidChangeDigCount;

@end

@interface TTVideoDetailFloatCommentViewController : SSViewControllerBase

@property (nonatomic, strong) TTGroupModel *groupModel;
@property (nonatomic, strong) id<TTCommentModelProtocol> commentModel;
@property (nonatomic, assign) CGRect viewFrame;
@property (nonatomic, assign) BOOL showWriteComment;
@property (nonatomic, assign) BOOL banEmojiInput; // 禁用表情输入
@property (nonatomic, weak) id<ExploreMomentListCellUserActionItemDelegate> delegate;
@property (nonatomic, weak) id<TTVideoDetailFloatCommentViewControllerDelegate> vcDelegate;
@property (nonatomic, assign) BOOL isAdVideo;

- (instancetype)initWithViewFrame:(CGRect)viewFrame
                          comment:(id<TTCommentModelProtocol>)commentModel
                       groupModel:(TTGroupModel *)groupModel
                      momentModel:(ArticleMomentModel *)momentModel
                         delegate:(id<ExploreMomentListCellUserActionItemDelegate>)delegate
                 showWriteComment:(BOOL)showWriteComment
                      fromMessage:(BOOL)fromMessage;

@end
