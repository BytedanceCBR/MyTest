//
//  TTRecommendCollectionViewCell.h
//  Article
//
//  Created by zhaoqin on 18/12/2016.
//
//

#import <UIKit/UIKit.h>

@class TTRecommendModel;
@class TTFollowThemeButton;

extern NSString *const TTRecommendCollectionViewCellIdentifier;

@interface TTRecommendCollectionViewCell : UICollectionViewCell
@property (nonatomic, strong) TTRecommendModel *model;
//关注按钮回调
@property (nonatomic, strong) void(^followPressed)();
//关注按钮
@property (nonatomic, strong, readonly) TTFollowThemeButton *subscribeButton;
//配置model以及UI
- (void)configWithModel:(TTRecommendModel *)model;
@end
