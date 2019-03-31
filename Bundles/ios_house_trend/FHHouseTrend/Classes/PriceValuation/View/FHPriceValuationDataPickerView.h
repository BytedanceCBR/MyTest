//
//  FHPriceValuationDataPickerView.h
//  AKCommentPlugin
//
//  Created by 谢思铭 on 2019/3/25.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FHPriceValuationDataPickerView : UIView

/*
 数据格式
 @[
 @[@"1",@"2",@"3"],
 @[@"4",@"5",@"6"],
 @[@"7",@"8",@"9"],
 ];
 */
@property(nonatomic, strong) NSArray *titleSource;
@property(nonatomic, strong) NSArray *dataSource;
@property(nonatomic, strong) NSArray *defaultSelection;
@property(nonatomic, assign) BOOL hideWhenCompletion;
//didSelected
@property(nonatomic, copy) void(^didSelectedBlock)(UIPickerView *pickerView, NSInteger row, NSInteger component);

- (void)showWithHeight:(CGFloat)pickerViewHeight completion:(void (^)(NSDictionary *resultDic))completion;

- (void)coverViewTapClick;

@end

NS_ASSUME_NONNULL_END
