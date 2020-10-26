//
//  FHHouseBaseCell.h
//  FHHouseBase
//
//  Created by xubinbin on 2020/10/21.
//

#import <UIKit/UIKit.h>
#import <YYText/YYLabel.h>
#import <lottie-ios/Lottie/LOTAnimationView.h>
#import "FHHouseRecommendReasonView.h"
#import "FHCornerView.h"
#import <FHCommonUI/UIColor+Theme.h>
#import <FHCommonUI/UIFont+House.h>
#import "UIButton+TTAdditions.h"
#import <lottie-ios/Lottie/LOTAnimationView.h>
#import "Masonry.h"
#import "UIButton+TTAdditions.h"
#import <UIDevice+BTDAdditions.h>
#import <BDWebImage/UIImageView+BDWebImage.h>
#import <HTSVideoPlay/Yoga.h>
#import <HTSVideoPlay/UIView+Yoga.h>

NS_ASSUME_NONNULL_BEGIN
//房源卡片基类
@interface FHHouseBaseCell : UITableViewCell

@property (nonatomic, strong) UIView *leftInfoView;
@property (nonatomic, strong) UIImageView *mainImageView;
@property (nonatomic, strong) UIImageView *videoImageView;
@property (nonatomic, strong) UIView *houseMainImageBackView;
@property (nonatomic, strong) FHCornerView *imageTagLabelBgView;
@property (nonatomic, strong) UILabel *imageTagLabel;
@property (nonatomic, strong) UIImageView *houseVideoImageView;
@property (nonatomic, strong) UIView *rightInfoView;
@property (nonatomic, strong) UIView *priceBgView; //底部 包含 价格 分享
@property (nonatomic, strong) UILabel *mainTitleLabel;
@property (nonatomic, strong) UILabel *subTitleLabel;
@property (nonatomic, strong) YYLabel *tagLabel;
@property (nonatomic, strong) UILabel *priceLabel;
@property (nonatomic, strong) UILabel *pricePerSqmLabel; // 价格/平米
@property (nonatomic, strong) UILabel *originPriceLabel;
@property (nonatomic, strong) LOTAnimationView *vrLoadingView;
@property (nonatomic, strong) UIView *houseCellBackView; //背景
@property (nonatomic, strong) FHHouseRecommendReasonView *recReasonView; //榜单
@property (nonatomic, strong) FHCornerItemLabel *tagTitleLabel; //降 新 榜等标签
@property (nonatomic, strong) id currentData;

- (void)refreshWithData:(id)data;

+ (CGFloat)heightForData:(id)data;

+ (UIImage *)placeholderImage;

- (void)initUI;

- (void)resumeVRIcon;

- (void)updateMainImageWithUrl:(NSString *)url;

- (void)refreshIndexCorner:(BOOL)isFirst andLast:(BOOL)isLast;

- (void)hideRecommendReason;

@end

NS_ASSUME_NONNULL_END
