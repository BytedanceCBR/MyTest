//
//  TTLiveFakeNavigationBar.h
//  TTLive
//
//  Created by matrixzk on 7/18/16.
//
//

#import <UIKit/UIKit.h>
#import "SSThemed.h"

typedef NS_ENUM(NSUInteger, TTLiveFakeNavigationBarType) {
    TTLiveFakeNavigationBarTypeNormal,
    TTLiveFakeNavigationBarTypeSlide
};

@protocol TTLiveFakeNavigationBarDelegate <NSObject>

@optional
//- (void)ttLiveFakeNavigationBarEllipsisBtnClicked;
- (void)ttLiveFakeNavigationBarReserve:(BOOL)reserve success:(BOOL)success;
- (void)navigationBarTap;

@end

@class TTLiveTopBannerInfoModel, TTLiveStreamDataModel, TTLiveMainViewController;

@interface TTLiveFakeNavigationBar : SSThemedView

- (instancetype)initWithFrame:(CGRect)frame chatroom:(TTLiveMainViewController *)chatroom;
- (void)setupBarWithModel:(TTLiveTopBannerInfoModel *)model type:(TTLiveFakeNavigationBarType)type;
- (void)refreshBarWithModel:(TTLiveStreamDataModel *)model;
- (void)refreshRightButton;
- (void)hideTitleView:(BOOL)hidden;
- (void)refreshActionButtonHidden:(BOOL)hidden;
- (void)refreshTitleViewHidden:(BOOL)hidden;
- (CGFloat)followButtonCenterxToRight;//关注按钮中心距离最右的距离
//// 待重写
@property (nonatomic, weak) id<TTLiveFakeNavigationBarDelegate> delegate;
- (void)makeShare:(id)sender;
- (void)makeReservationRequestBarType:(TTLiveFakeNavigationBarType)type;

@end
