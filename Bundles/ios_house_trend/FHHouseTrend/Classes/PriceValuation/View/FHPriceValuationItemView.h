//
//  FHPriceValuationItemView.h
//  FHHouseTrend
//
//  Created by 谢思铭 on 2019/3/19.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, FHPriceValuationItemViewType) {
    FHPriceValuationItemViewTypeNormal,     //左边标题，副标题，右边图片，默认图片为箭头
    FHPriceValuationItemViewTypeTextField,  //左边标题，文本录入，右边图片，默认图片为箭头
};

NS_ASSUME_NONNULL_BEGIN

@interface FHPriceValuationItemView : UIView

@property(nonatomic, assign) FHPriceValuationItemViewType type;
@property(nonatomic, strong) UILabel *titleLabel;
@property(nonatomic, strong) UILabel *contentLabel;
@property(nonatomic, strong) UITextField *textField;
@property(nonatomic, strong) UIView *bottomLine;
@property(nonatomic, assign) CGFloat titleWidth;
@property(nonatomic, strong) NSString *rightText;

//点击事件
@property(nonatomic, copy) void(^tapBlock)(void);

- (instancetype)initWithFrame:(CGRect)frame type:(FHPriceValuationItemViewType)type;


@end

NS_ASSUME_NONNULL_END
