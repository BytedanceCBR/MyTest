//
//  FHHouseFindResultTopHeader.h
//  AKCommentPlugin
//
//  Created by 谢飞 on 2019/4/1.
//

#import <UIKit/UIKit.h>
#import "FHHouseFindRecommendModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHHouseFindResultTopHeader : UIView

- (void)refreshUI:(FHHouseFindRecommendDataModel *)model;

- (void)setTitleStr:(NSInteger)houseCount;

@end

NS_ASSUME_NONNULL_END
