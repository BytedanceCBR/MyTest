//
//  ExploreDetailNatantUserActionView.h
//  Article
//
//  Created by Zhang Leonardo on 14-10-23.
//
//  详情页顶踩

#import "ExploreDetailNatantHeaderItemBase.h"
#import "ExploreDetailnatantActionButton.h"

@interface ExploreDetailNatantUserActionView : ExploreDetailNatantHeaderItemBase

@property(nonatomic, retain, readonly)ExploreDetailnatantActionButton * digButton;
@property(nonatomic, retain, readonly)ExploreDetailnatantActionButton * buryButton;

+ (CGFloat)heightForView;

@end
