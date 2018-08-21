//
//  TTCommentDetailHeader.h
//  Article
//
//  Created by zhaoqin on 05/01/2017.
//
//

#import <TTThemed/SSThemed.h>
#import <TTImpression/UIScrollView+Impression.h>
#import "TTCommentDetailModel.h"

@class TTCommentDetailHeader;

@protocol TTCommentDetailHeaderDelegate <NSObject>

@optional
- (void)dynamicDetailHeader:(TTCommentDetailHeader *)header avatarViewOnClick:(id)sender;
- (void)dynamicDetailHeader:(TTCommentDetailHeader *)header nameViewOnClick:(id)sender;
- (void)dynamicDetailHeader:(TTCommentDetailHeader *)header digButtonOnClick:(id)sender;
- (void)dynamicDetailHeader:(TTCommentDetailHeader *)header replyButtonOnClick:(id)sender;
- (void)dynamicDetailHeader:(TTCommentDetailHeader *)header reportButtonOnClick:(id)sender;
- (void)dynamicDetailHeader:(TTCommentDetailHeader *)header followButtonOnClick:(id)sender;
- (void)dynamicDetailHeader:(TTCommentDetailHeader *)header blockButtonOnClick:(id)sender;
- (void)dynamicDetailHeader:(TTCommentDetailHeader *)header deleteButtonOnClick:(id)sender;
- (void)dynamicDetailHeader:(TTCommentDetailHeader *)header quotedNameViewOnClick:(id)sender;
- (void)dynamicDetailHeader:(TTCommentDetailHeader *)header diggedUserAvatarOnClick:(SSUserModel *)user;
- (void)dynamicDetailHeader:(TTCommentDetailHeader *)header diggCountLabelOnClick:(id)sender;

@end

@interface TTCommentDetailHeader : SSThemedView <TTImpressionViewProtocol>

@property (nonatomic, weak) id<TTCommentDetailHeaderDelegate> delegate;
@property (nonatomic, strong) NSString *trackTag;

- (instancetype)initWithModel:(TTCommentDetailModel *)model frame:(CGRect)frame needShowGroupItem:(BOOL)showGroup;
+ (CGFloat)heightWithModel:(TTCommentDetailModel *)model width:(CGFloat)width;
- (void)refreshWithModel:(TTCommentDetailModel *)model;

// 实现 TTImpressionViewProtocol 协议

@property (nonatomic,copy) dispatch_block_t willAppearBlock;
@property (nonatomic,copy) dispatch_block_t willDisAppearBlock;
@property (nonatomic,assign) NSInteger viewState;

@end
