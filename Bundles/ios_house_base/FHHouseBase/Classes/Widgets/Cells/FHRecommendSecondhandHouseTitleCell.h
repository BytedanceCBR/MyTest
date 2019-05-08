//
//  FHRecommendSecondhandHouseTitleCell.h
//  AFgzipRequestSerializer
//
//  Created by 郑识途 on 2019/1/7.
//

#import <UIKit/UIKit.h>
#import "FHRecommendSecondhandHouseTitleModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHRecommendSecondhandHouseTitleCell : UITableViewCell

-(void) bindData: (FHRecommendSecondhandHouseTitleModel *) model;

- (void)hideSeprateLine:(BOOL)isFirstCell;

@end

NS_ASSUME_NONNULL_END
