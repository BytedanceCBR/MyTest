//
//  FHUGCVoteDatePickerView.h
//  FHHouseUGC
//
//  Created by wangzhizhou on 2019/12/27.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

// 本控件不支持扩展
@interface FHUGCVoteDatePickerView : UIPickerView

// 当前日期
@property (nonatomic, strong) NSDate *date;


/// 初始化日期选择器
/// @param frame 视图大小
/// @param minimumDate 最小日期
/// @param maximumDate 最大日期
- (instancetype)initWithFrame:(CGRect)frame minimumDate: (NSDate *)minimumDate maximumDate: (NSDate *)maximumDate;

@end

NS_ASSUME_NONNULL_END
