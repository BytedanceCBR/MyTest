//
//  TTXiguaLiveRecommendBaseCell.h
//  Article
//
//  Created by lipeilun on 2017/12/6.
//

#import <UIKit/UIKit.h>
#import "TTXiguaLiveModel.h"

@interface TTXiguaLiveRecommendBaseCell : UICollectionViewCell
- (void)configWithModel:(TTXiguaLiveModel *)model;


/**
 如果有动画组件，开始
 */
- (void)tryBeginAnimation;

/**
 如果有动画组件，停止
 */
- (void)tryStopAnimation;
@end
