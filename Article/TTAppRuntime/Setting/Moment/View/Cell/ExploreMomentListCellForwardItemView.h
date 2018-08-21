//
//  ExploreMomentListCellForwardItemView.h
//  Article
//
//  Created by Zhang Leonardo on 15-1-18.
//
//  动态cell中的元素, 用于展示转发view

#import "ExploreMomentListCellItemBase.h"
#define kExploreMomentListForwardItemTopPadding [TTDeviceUIUtils tt_paddingForMoment:12]

@interface ExploreMomentListCellForwardItemView : ExploreMomentListCellItemBase
@property(nonatomic, strong)SSTTTAttributedLabel * commentLabel;
+ (CGFloat)preferredTitleSize;

- (BOOL)isForumItemViewShown;
@end
