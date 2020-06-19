//
//  FHDetailEvaluationListViewHeader.h
//  FHHouseDetail
//
//  Created by liuyu on 2020/6/16.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FHDetailEvaluationListViewHeader : UIView
@property (strong, nonatomic) NSArray *tabInfoArr;
@property (copy, nonatomic, readonly) NSString *selectName;
@property(nonatomic, copy) void (^headerItemSelectAction)(void);
@end

NS_ASSUME_NONNULL_END
