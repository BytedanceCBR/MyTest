//
//  FHHouseSearchNewHouseCell.m
//  Pods
//
//  Created by xubinbin on 2020/8/27.
//

#import "FHHouseSearchNewHouseCell.h"
#import <YYText/YYLabel.h>
#import "FHCornerView.h"
#import <lottie-ios/Lottie/LOTAnimationView.h>
#import <BDWebImage/UIImageView+BDWebImage.h>
#import "Masonry.h"
#import "UIColor+Theme.h"
#import <FHCommonUI/UIColor+Theme.h>
#import <FHCommonUI/UIFont+House.h>
#import "FHSearchHouseModel.h"
#import "FHSingleImageInfoCellModel.h"

@interface FHHouseSearchNewHouseCell()

@property (nonatomic, strong) UIView *leftInfoView;
@property (nonatomic, strong) UIView *maskVRImageView;
@property (nonatomic, weak) UIImageView *mainImaTag;
@property (nonatomic, strong) UIImageView *mainImageView;
@property (nonatomic, strong) LOTAnimationView *vrLoadingView;

@property (nonatomic, strong) UIView *rightInfoView;
@property (nonatomic, strong) UILabel *mainTitleLabel; //主title lable
@property (nonatomic, strong) UILabel *subTitleLabel; // sub title lable
@property (nonatomic, strong) YYLabel *tagLabel; // 标签 label
@property (nonatomic, strong) UILabel *priceLabel; //总价

@property (nonatomic, strong) UIView *bottomRecommendView;//底部推荐理由
@property (nonatomic, strong) UIImageView *bottomIconImageView; //活动icon
@property (nonatomic, strong) UILabel *bottomRecommendLabel; //活动title
@property (nonatomic, strong) UIView *containerView;//圆角背景
@property (nonatomic, strong) FHCornerItemLabel *tagTitleLabel; //降 新 榜等标签
@property (nonatomic, strong) UILabel *propertyTagLabel;

@end

@implementation FHHouseSearchNewHouseCell

+(UIImage *)placeholderImage
{
    static UIImage *placeholderImage = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        placeholderImage = [UIImage imageNamed:@"house_cell_placeholder_square"];
    });
    return placeholderImage;
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initUI];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

+ (CGFloat)heightForData:(id)data {
    if ([data isKindOfClass:[JSONModel class]]) {
        FHSearchHouseItemModel *itemModel = (FHSearchHouseItemModel *)data;
        if (itemModel.advantageDescription.text) {
            return 146;
        }
    }
    return 124;
}

-(void)initUI
{
    self.contentView.backgroundColor = [UIColor themeGray7];
    [self.contentView addSubview:self.containerView];
    [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
        make.right.mas_equalTo(-15);
        make.top.mas_equalTo(10);
        make.bottom.mas_equalTo(0);
    }];
    
    _leftInfoView = [[UIView alloc] init];
    [self.containerView addSubview:self.leftInfoView];
    [self.leftInfoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.mas_equalTo(15);
        make.height.width.mas_equalTo(84);
    }];
    
    [self.leftInfoView addSubview:self.mainImageView];
    [self.mainImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    
    [self.leftInfoView addSubview:self.mainImaTag];
    [self.mainImaTag mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.mas_equalTo(0);
        make.width.mas_equalTo(26);
        make.height.mas_equalTo(16);
    }];
    self.mainImaTag.hidden = YES;
    
    [self.leftInfoView addSubview:self.vrLoadingView];
    [self.vrLoadingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(8);
        make.bottom.mas_equalTo(-8);
        make.width.height.mas_equalTo(16);
    }];
    self.vrLoadingView.hidden = YES;
    
    _rightInfoView = [[UIView alloc] init];
    [self.containerView addSubview:self.rightInfoView];
    [self.rightInfoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.leftInfoView.mas_right).offset(8);
        make.right.mas_equalTo(-15);
        make.top.mas_equalTo(12);
        make.bottom.mas_equalTo(0);
    }];
    
    [self.rightInfoView addSubview:self.mainTitleLabel];
    [self.mainTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.mas_equalTo(0);
        make.height.mas_equalTo(22);
    }];
    
    [self.rightInfoView addSubview:self.propertyTagLabel];
    [self.propertyTagLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(3);
        make.right.mas_equalTo(0);
        make.height.mas_equalTo(16);
        make.width.mas_equalTo(0);
    }];
    
    [self.rightInfoView addSubview:self.priceLabel];
    [self.priceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.top.mas_equalTo(self.mainTitleLabel.mas_bottom).offset(1);
        make.right.mas_equalTo(0);
        make.height.mas_equalTo(22);
    }];
    
    [self.rightInfoView addSubview:self.subTitleLabel];
    [self.subTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.top.mas_equalTo(self.priceLabel.mas_bottom).offset(2);
        make.right.mas_equalTo(0);
        make.height.mas_equalTo(18);
    }];
    
    [self.rightInfoView addSubview:self.tagLabel];
    [self.tagLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(0);
        make.left.mas_equalTo(-2);
        make.top.mas_equalTo(self.subTitleLabel.mas_bottom).offset(4);
        make.height.mas_equalTo(18);
    }];
    
    [self.containerView addSubview:self.bottomRecommendView];
    [self.bottomRecommendView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.tagLabel.mas_bottom);
        make.left.mas_equalTo(self.leftInfoView.mas_right).offset(4);
        make.right.mas_equalTo(-15);
        make.bottom.mas_equalTo(0);
    }];
}

- (void)refreshWithData:(id)data {
    if ([data isKindOfClass:[FHSearchHouseItemModel class]]) {
        FHSearchHouseItemModel *model = (FHSearchHouseItemModel *)data;
        FHImageModel *imageModel = model.images.firstObject;
        [self updateMainImageWithUrl:imageModel.url];
        if (model.tagImage) {
            self.mainImaTag.hidden = NO;
            FHImageModel *tagimageModel = model.tagImage.firstObject;
            [self.mainImaTag bd_setImageWithURL:[NSURL URLWithString:tagimageModel.url]];
        }
        self.mainTitleLabel.text = model.displayTitle;
        if (model.propertyTag && [model.propertyTag.content length] > 0) {
            self.propertyTagLabel.hidden = NO;
            self.propertyTagLabel.text = model.propertyTag.content;
            self.propertyTagLabel.layer.borderColor = [UIColor colorWithHexStr:model.propertyTag.borderColor].CGColor;
            UILabel *label = [[UILabel alloc] init];
            label.font = [UIFont themeFontRegular:10];
            label.text = model.propertyTag.content;
            CGFloat width = [label sizeThatFits:CGSizeZero].width + 6;
            [self.propertyTagLabel mas_updateConstraints:^(MASConstraintMaker *make) {
                make.width.mas_equalTo(width);
            }];
            [self.mainTitleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
                make.right.mas_equalTo(-width - 1);
            }];
        } else {
            self.propertyTagLabel.hidden = YES;
            [self.mainTitleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
                make.right.mas_equalTo(0);
            }];
        }
        self.priceLabel.text = model.displayPricePerSqm;
        self.subTitleLabel.text = model.displayDescription;
        NSAttributedString *attributeString =  [FHSingleImageInfoCellModel tagsStringWithTagList:model.tags];
        self.tagLabel.attributedText = attributeString;
        if ([model.displayPricePerSqm isKindOfClass:[NSString class]] && [model.displayPricePerSqm isEqualToString:@"暂无报价"]) {
            self.priceLabel.textColor = [UIColor themeGray3];
        } else {
            self.priceLabel.textColor = [UIColor themeOrange1];
        }
        [self updateAdvantage:model];
        [self updateVRInfo:model];
    }
}

- (void)resumeVRIcon
{
    if (_vrLoadingView && !self.vrLoadingView.hidden) {
        [self.vrLoadingView play];
    }
}

- (void)updateVRInfo:(FHSearchHouseItemModel *)model {
    if (self.maskVRImageView) {
        [self.maskVRImageView removeFromSuperview];
        self.maskVRImageView = nil;
    }
    if (model.vrInfo.hasVr) {
        self.vrLoadingView.hidden = NO;
        [self.vrLoadingView play];
        self.maskVRImageView = [UIView new];
        self.maskVRImageView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.1];
        [self.mainImageView addSubview:self.maskVRImageView];
        [self.maskVRImageView setFrame:CGRectMake(0.0f, 0.0f, 84, 84)];
    } else {
        self.vrLoadingView.hidden = YES;
    }
}

- (void)updateAdvantage:(FHSearchHouseItemModel *)model {
    FHHouseListHouseAdvantageTagModel *adModel = model.advantageDescription;
    if (adModel && ([adModel.text length] > 0 || (adModel.icon && [adModel.icon.url length] > 0))) {
        UIView *bottomLine = [[UIView alloc] init];
        bottomLine.backgroundColor = [UIColor themeGray7];
        [self.bottomRecommendView addSubview:bottomLine];
        [bottomLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(0);
            make.left.mas_equalTo(4);
            make.bottom.mas_equalTo(-28);
            make.height.mas_equalTo(1);
        }];
        if (adModel.icon && [adModel.icon.url length] > 0) {
            [self.bottomRecommendView addSubview:self.bottomIconImageView];
            [self.bottomIconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.bottom.mas_equalTo(-4);
                make.left.mas_equalTo(0);
                make.height.width.mas_equalTo(20);
            }];
            [self.bottomIconImageView bd_setImageWithURL:[NSURL URLWithString:adModel.icon.url]];
        }
        if ([adModel.text length] > 0) {
            [self.bottomRecommendView addSubview:self.bottomRecommendLabel];
            [self.bottomRecommendLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(20);
                make.bottom.mas_equalTo(-9);
                make.height.mas_equalTo(10);
                make.right.mas_equalTo(0);
            }];
            self.bottomRecommendLabel.text = adModel.text;
        }
    }
}

-(void)updateMainImageWithUrl:(NSString *)url
{
    NSURL *imgUrl = [NSURL URLWithString:url];
    if (imgUrl) {
        [self.mainImageView bd_setImageWithURL:imgUrl placeholder:[FHHouseSearchNewHouseCell placeholderImage]];
    }else{
        self.mainImageView.image = [FHHouseSearchNewHouseCell placeholderImage];
    }
}

- (void)prepareForReuse {
    [super prepareForReuse];
    for (UIView *view in self.bottomRecommendView.subviews) {
        [view removeFromSuperview];
    }
}

- (UIImageView *)mainImaTag {
    if (!_mainImaTag) {
        UIImageView *mainImaTag = [[UIImageView alloc]init];
        [self.contentView addSubview:mainImaTag];
        _mainImaTag = mainImaTag;
    }
    return _mainImaTag;
}

- (UILabel *)bottomRecommendLabel {
    if (!_bottomRecommendLabel) {
        _bottomRecommendLabel = [[UILabel alloc]init];
        _bottomRecommendLabel.font = [UIFont themeFontRegular:10];
        _bottomRecommendLabel.textColor = [UIColor themeGray1];
    }
    return _bottomRecommendLabel;
}

- (UIImageView *)bottomIconImageView {
    if (!_bottomIconImageView) {
        _bottomIconImageView= [[UIImageView alloc]init];
        _bottomIconImageView.backgroundColor = [UIColor clearColor];
    }
    return _bottomIconImageView;
}

-(UIImageView *)mainImageView
{
    if (!_mainImageView) {
        _mainImageView = [[UIImageView alloc]init];
        _mainImageView.contentMode = UIViewContentModeScaleAspectFill;
        _mainImageView.layer.cornerRadius = 4;
        _mainImageView.clipsToBounds = YES;
        _mainImageView.layer.borderWidth = 0.5;
        _mainImageView.layer.borderColor = [UIColor themeGray7].CGColor;
    }
    return _mainImageView;
}

-(LOTAnimationView *)vrLoadingView
{
    if (!_vrLoadingView) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"VRImageLoading" ofType:@"json"];
        _vrLoadingView = [LOTAnimationView animationWithFilePath:path];
        _vrLoadingView.loopAnimation = YES;
    }
    return _vrLoadingView;
}

-(FHCornerItemLabel *)tagTitleLabel {
    if (!_tagTitleLabel) {
        _tagTitleLabel = [[FHCornerItemLabel alloc] init];
        _tagTitleLabel.textAlignment = NSTextAlignmentCenter;
        _tagTitleLabel.font = [UIFont themeFontMedium:10];
        _tagTitleLabel.textColor = [UIColor themeWhite];
        _tagTitleLabel.frame = CGRectMake(0, 0, 16, 16);
    }
    return _tagTitleLabel;
}

-(UILabel *)mainTitleLabel
{
    if (!_mainTitleLabel) {
        _mainTitleLabel = [[UILabel alloc]init];
        _mainTitleLabel.font = [UIFont themeFontSemibold:16];
        _mainTitleLabel.textColor = [UIColor themeGray1];
    }
    return _mainTitleLabel;
}

- (UIView *)bottomRecommendView
{
    if (!_bottomRecommendView) {
        _bottomRecommendView = [[UIView alloc] init];
    }
    return _bottomRecommendView;
}

-(UILabel *)subTitleLabel
{
    if (!_subTitleLabel) {
        _subTitleLabel = [[UILabel alloc]init];
        _subTitleLabel.font = [UIFont themeFontRegular:12];
        _subTitleLabel.textColor = [UIColor themeGray1];
    }
    return _subTitleLabel;
}

-(YYLabel *)tagLabel
{
    if (!_tagLabel) {
        _tagLabel = [[YYLabel alloc]init];
        _tagLabel.numberOfLines = 0;
        _tagLabel.font = [UIFont themeFontRegular:10];
        _tagLabel.lineBreakMode = NSLineBreakByWordWrapping;
    }
    return _tagLabel;
}

-(UILabel *)priceLabel
{
    if (!_priceLabel) {
        _priceLabel = [[UILabel alloc]init];
        _priceLabel.textColor = [UIColor themeOrange1];
        _priceLabel.font = [UIFont themeFontSemibold:16];
    }
    return _priceLabel;
}

- (UIView *)containerView {
    if (!_containerView) {
        _containerView = [[UIView alloc] init];
        _containerView.backgroundColor = [UIColor whiteColor];
        _containerView.layer.cornerRadius = 10;
        _containerView.layer.masksToBounds = YES;
    }
    return _containerView;
}

- (UILabel *)propertyTagLabel {
    if (!_propertyTagLabel) {
        _propertyTagLabel = [[UILabel alloc] init];
        _propertyTagLabel.font = [UIFont themeFontRegular:10];
        _propertyTagLabel.layer.cornerRadius = 2;
        _propertyTagLabel.textAlignment = NSTextAlignmentCenter;
        _propertyTagLabel.layer.borderWidth = 0.5;
    }
    return _propertyTagLabel;
}

@end
