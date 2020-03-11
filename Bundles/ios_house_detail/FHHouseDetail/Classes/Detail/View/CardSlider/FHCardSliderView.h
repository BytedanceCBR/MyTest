//
//  FHCardSliderView.h
//  FHHouseDetail
//
//  Created by 谢思铭 on 2020/3/6.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, FHCardSliderViewType) {
    FHCardSliderViewTypeHorizontal,
    FHCardSliderViewTypeVertical,
};

@interface FHCardSliderView : UIView

@property (nonatomic, strong) NSArray *dataSource;
//是否循环滚动
@property(nonatomic ,assign) BOOL isLoop;
//是否自动播放
@property(nonatomic ,assign) BOOL isAuto;
//埋点信息
@property (nonatomic, strong , nullable) NSDictionary *tracerDic;

- (instancetype)initWithFrame:(CGRect)frame type:(FHCardSliderViewType)type;
- (void)setCardListData:(NSArray *)cardList;
- (void)addTimer;
+ (CGFloat)getViewHeight;
- (void)trackCardShow;
@end

NS_ASSUME_NONNULL_END
