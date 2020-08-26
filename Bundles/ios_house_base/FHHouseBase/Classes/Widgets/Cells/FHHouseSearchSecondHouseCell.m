//
//  FHHouseSearchSecondHouseCell.m
//  FHHouseBase
//
//  Created by xubinbin on 2020/8/24.
//

#import "FHHouseSearchSecondHouseCell.h"
#import "Masonry.h"
#import <FHCommonUI/UIColor+Theme.h>
#import <FHCommonUI/UIFont+House.h>
#import "UIButton+TTAdditions.h"
#import <BDWebImage/UIImageView+BDWebImage.h>
#import "FHCommonDefines.h"
#import "FHHomeHouseModel.h"
#import <lottie-ios/Lottie/LOTAnimationView.h>
#import "UIImage+FIconFont.h"
#import "FHCornerView.h"

@interface FHHouseSearchSecondHouseCell()

@property (nonatomic, strong) UIView *containerView;

@property (nonatomic, strong) UIView *leftInfoView;
@property(nonatomic, strong) UIView *maskVRImageView;
@property (nonatomic, strong) UIImageView *mainImageView;
@property (nonatomic, strong) LOTAnimationView *vrLoadingView;

@property (nonatomic, strong) UIView *rightInfoView;

@property (nonatomic, strong) UIView *mainTitleView;
@property (nonatomic, strong) UILabel *subTitleLabel;
@property (nonatomic, strong) UIView *tagContainerView;

@property (nonatomic, strong) UIView *priceInfoView;
@property (nonatomic, strong) UILabel *priceLabel;
@property (nonatomic, strong) UILabel *pricePerSqmLabel;
@property (nonatomic, strong) UIButton *closeBtn;

@property (nonatomic, strong) UIView *bottomView;
@property (nonatomic, strong) UIImageView *bottomIconImageView;
@property (nonatomic, strong) UILabel *bottomRecommendLabel;

@property (nonatomic, strong) FHSearchHouseItemModel *model;

@end

@implementation FHHouseSearchSecondHouseCell

+ (UIImage *)placeholderImage
{
    static UIImage *placeholderImage = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        placeholderImage = [UIImage imageNamed: @"default_image"];
    });
    return placeholderImage;
}

+ (CGFloat)heightForData:(id)data {
    if ([data isKindOfClass:[FHSearchHouseItemModel class]]) {
        FHSearchHouseItemModel *model = (FHSearchHouseItemModel *)data;
        CGFloat height = 124;
        FHHouseListHouseAdvantageTagModel *adModel = model.advantageDescription;
        if ([adModel.text length] > 0 || (adModel.icon && [adModel.icon.url length] > 0)) {
            height += 25;
        }
        height += [self getMaintitleHeight:model] - 22;
        return height;
    }
    return 124;
}

+ (CGFloat)getWidthFromText:(NSString *)text textFont:(UIFont *)font {
    UILabel *label = [[UILabel alloc] init];
    label.font = font;
    label.text = text;
    CGSize size = [label sizeThatFits:CGSizeZero];
    return size.width;
}

+ (CGFloat)getMaintitleHeight:(FHSearchHouseItemModel *)model {
    CGFloat height = 22;
    CGFloat width = SCREEN_WIDTH - 45 - 107;
    if ([model.titleTags count] > 0) {
        for (NSInteger i = 0; i < [model.titleTags count]; i++) {
            FHSearchHouseItemTitleTagModel *tag = model.titleTags[i];
            CGFloat tagWidth = [self getWidthFromText:tag.text textFont:[UIFont themeFontMedium:10]];
            tagWidth += 6;
            if (i == 0) {
                tagWidth += 4;
            } else {
                tagWidth += 2;
            }
            width -= tagWidth;
        }
    }
    width -= [self getWidthFromText:model.displayTitle textFont:[UIFont themeFontSemibold:16]];
    if (width < 0) {
        height += 22;
    }
    return height;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        if ([reuseIdentifier isEqualToString:@"FHHouseSearchSecondHouseCell"]) {
            [self initUI];
        }
    }
    return self;
}

- (void)initUI {
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
        make.width.height.mas_equalTo(84);
    }];
    
    [self.leftInfoView addSubview:self.mainImageView];
    [self.mainImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.leftInfoView);
    }];
    
    _rightInfoView = [[UIView alloc] init];
    [self.containerView addSubview:self.rightInfoView];
    [self.rightInfoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.leftInfoView.mas_right).offset(4);
        make.right.mas_equalTo(-15);
        make.top.bottom.mas_equalTo(0);
    }];
    
    _mainTitleView = [[UIView alloc] init];
    [self.rightInfoView addSubview:self.mainTitleView];
    [self.mainTitleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(0);
        make.left.mas_equalTo(4);
        make.height.mas_equalTo(22);
        make.top.mas_equalTo(12);
    }];
    
    [self.rightInfoView addSubview:self.subTitleLabel];
    [self.subTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(0);
        make.left.mas_equalTo(4);
        make.height.mas_equalTo(18);
        make.top.mas_equalTo(self.mainTitleView.mas_bottom).offset(4);
    }];
    
    _tagContainerView = [[UIView alloc] init];
    [self.rightInfoView addSubview:self.tagContainerView];
    [self.tagContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(0);
        make.left.mas_equalTo(4);
        make.height.mas_equalTo(18);
        make.top.mas_equalTo(self.subTitleLabel.mas_bottom).offset(4);
    }];
    
    _priceInfoView = [[UIView alloc] init];
    [self.rightInfoView addSubview:self.priceInfoView];
    [self.priceInfoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(0);
        make.left.mas_equalTo(4);
        make.height.mas_equalTo(22);
        make.top.mas_equalTo(self.tagContainerView.mas_bottom).offset(4);
    }];
    
    [self.priceInfoView addSubview:self.priceLabel];
    [self.priceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.mas_equalTo(0);
        make.height.mas_equalTo(22);
        make.width.mas_equalTo(45);
    }];
    
    [self.priceInfoView addSubview:self.pricePerSqmLabel];
    [self.pricePerSqmLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(4);
        make.bottom.mas_equalTo(-1);
        make.left.mas_equalTo(self.priceLabel.mas_right).offset(4);
        make.right.mas_equalTo(-18);
    }];
    
    [self.priceInfoView addSubview:self.closeBtn];
    [self.closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(0);
        make.top.mas_equalTo(4);
        make.height.width.mas_equalTo(16);
    }];
    
    _bottomView = [[UIView alloc] init];
    [self.rightInfoView addSubview:self.bottomView];
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.priceInfoView.mas_bottom);
        make.left.right.bottom.mas_equalTo(0);
        make.height.mas_equalTo(10);
    }];
    
}

- (void)refreshWithData:(id)data {
    if ([data isKindOfClass:[FHSearchHouseItemModel class]]) {
        self.model = data;
        FHSearchHouseItemModel *model = (FHSearchHouseItemModel *)data;
        [self updateMainTitleView:model];
        [self updateTagContainerView:model];
        [self updateBottomView:model];
        self.subTitleLabel.text = model.displaySubtitle;
        [self resetPriceFrame];
        self.pricePerSqmLabel.text = self.model.displayPricePerSqm;
        FHImageModel *imageModel = self.model.houseImage.firstObject;
        [self updateMainImageWithUrl:imageModel.url];
        if (self.maskVRImageView) {
            [self.maskVRImageView removeFromSuperview];
            self.maskVRImageView = nil;
        }
        if (self.model.vrInfo.hasVr) {
            if (![self.leftInfoView.subviews containsObject:self.vrLoadingView]) {
                [self.leftInfoView addSubview:self.vrLoadingView];
                self.vrLoadingView.hidden = YES;
                [self.vrLoadingView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.left.mas_equalTo(8);
                    make.bottom.mas_equalTo(-8);
                    make.width.height.mas_equalTo(16);
                }];
            }
            _vrLoadingView.hidden = NO;
            [_vrLoadingView play];
            self.maskVRImageView = [UIView new];
            self.maskVRImageView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.1];
            [self.mainImageView addSubview:self.maskVRImageView];
            [self.maskVRImageView setFrame:CGRectMake(0.0f, 0.0f, 84, 84)];
        } else {
            if (_vrLoadingView) {
                _vrLoadingView.hidden = YES;
            }
        }
    }
}

- (void)updateMainTitleView:(FHSearchHouseItemModel *)model {
    CGFloat height = [FHHouseSearchSecondHouseCell getMaintitleHeight:model];
    [self.mainTitleView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(height);
    }];
    CGFloat left = 0;
    if ([model.titleTags count] > 0) {
        for (NSInteger i = 0; i < [model.titleTags count]; i++) {
            FHSearchHouseItemTitleTagModel *tag = model.titleTags[i];
            UILabel *label = [[UILabel alloc] init];
            label.textAlignment = NSTextAlignmentCenter;
            label.text = tag.text;
            label.textColor = [UIColor colorWithHexStr:tag.textColor];
            label.font = [UIFont themeFontMedium:10];
            CGSize size = [label sizeThatFits:CGSizeZero];
            CGFloat width = size.width + 6;
            if (i > 0) {
                left += 2;
            }
            CGRect rect = CGRectMake(left, 4, width, 16);
            UIView *view = [[UIView alloc] initWithFrame:rect];
            [self.mainTitleView addSubview:view];
            label.frame = CGRectMake(0, 0, width, 16);
            [view addSubview:label];
            label.backgroundColor = [UIColor clearColor];
            
            if (tag.isGradient) {
                CAGradientLayer *gradientLayer = [CAGradientLayer layer];
                gradientLayer.colors = @[(__bridge id)[UIColor colorWithHexStr:tag.topBackgroundColor].CGColor, (__bridge id)[UIColor colorWithHexStr:tag.bottomBackgroundColor].CGColor];
                gradientLayer.startPoint = CGPointMake(0, 0.5);
                gradientLayer.endPoint = CGPointMake(1, 0.5);
                gradientLayer.cornerRadius = 2;
                gradientLayer.frame = view.bounds;
                [view.layer insertSublayer:gradientLayer atIndex:0];
            } else {
                view.layer.cornerRadius = 2;
                view.layer.backgroundColor = [UIColor colorWithHexStr:tag.backgroundColor].CGColor;
            }
            left += width;
        }
        left += 4;
        NSTextAttachment *attch = [[NSTextAttachment alloc] init];
        attch.bounds = CGRectMake(0, 0, left, 1);
        attch.image = [[UIImage alloc] init];
        NSAttributedString *string = [NSAttributedString attributedStringWithAttachment:attch];
        NSMutableParagraphStyle *paraStyle = [[NSMutableParagraphStyle alloc] init];
        paraStyle.lineSpacing = 2;
        NSMutableAttributedString *attributedString =  [[NSMutableAttributedString alloc] initWithString:model.displayTitle attributes:@{NSFontAttributeName:[UIFont themeFontSemibold:16], NSParagraphStyleAttributeName:paraStyle}];
        [attributedString insertAttributedString:string atIndex:0];
        UILabel *mainTitleLabel = [[UILabel alloc] init];
        mainTitleLabel.attributedText = attributedString;
        mainTitleLabel.numberOfLines = 0;
        [self.mainTitleView insertSubview:mainTitleLabel atIndex:0];
        [mainTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(0);
            make.left.right.bottom.mas_equalTo(0);
        }];

    } else {
        UILabel *mainTitleLabel = [[UILabel alloc] init];
        mainTitleLabel.text = model.displayTitle;
        mainTitleLabel.font = [UIFont themeFontSemibold:16];
        mainTitleLabel.numberOfLines = 0;
        mainTitleLabel.textAlignment = NSTextAlignmentLeft;
        [self.mainTitleView addSubview:mainTitleLabel];
        [mainTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self.mainTitleView);
        }];
    }
    
}

- (void)updateTagContainerView:(FHSearchHouseItemModel *)model {
    CGFloat left = 0;
    for (NSInteger i = 0; i < [model.tags count]; i++) {
        FHHouseTagsModel *tagModel = model.tags[i];
        UILabel *label = [[UILabel alloc] init];
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont themeFontRegular:10];
        label.text = tagModel.content;
        label.layer.cornerRadius = 2;
        label.textColor = [UIColor colorWithHexStr:tagModel.textColor];
        label.layer.backgroundColor = [UIColor colorWithHexStr:tagModel.backgroundColor].CGColor;
        label.layer.borderColor = [UIColor colorWithHexStr:tagModel.borderColor].CGColor;
        CGFloat width = [FHHouseSearchSecondHouseCell getWidthFromText:tagModel.content textFont:[UIFont themeFontRegular:10]] + 8;
        if (left + width > self.bottomView.frame.size.width) {
            break;
        }
        [self.tagContainerView addSubview:label];
        label.frame = CGRectMake(left, 0, width, 18);
        left += width + 4;
    }
}

- (void)updateBottomView:(FHSearchHouseItemModel *)model {
    FHHouseListHouseAdvantageTagModel *adModel = model.advantageDescription;
    if ([adModel.text length] > 0 || (adModel.icon && [adModel.icon.url length] > 0)) {
        [self.bottomView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(35);
        }];
    
        UIView *bottomLine = [[UIView alloc] init];
        bottomLine.backgroundColor = [UIColor themeGray7];
        bottomLine.layer.shadowColor = [UIColor themeGray7].CGColor;
        bottomLine.layer.shadowOffset = CGSizeMake(0, 0.5);
        [self.bottomView addSubview:bottomLine];
        [bottomLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(0);
            make.left.mas_equalTo(4);
            make.bottom.mas_equalTo(-28);
            make.height.mas_equalTo(1);
        }];
        
        CGFloat left = 0;
        if (adModel.icon && [adModel.icon.url length] > 0) {
            left += 20;
            [self.bottomView addSubview:self.bottomIconImageView];
            [self.bottomIconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.bottom.mas_equalTo(-4);
                make.left.mas_equalTo(0);
                make.height.width.mas_equalTo(20);
            }];
            [self.bottomIconImageView bd_setImageWithURL:[NSURL URLWithString:adModel.icon.url]];
            self.bottomIconImageView.hidden = NO;
        }
        if ([adModel.text length] > 0) {
            [self.bottomView addSubview:self.bottomRecommendLabel];
            [self.bottomRecommendLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(left);
                make.bottom.mas_equalTo(-9);
                make.height.mas_equalTo(10);
                make.right.mas_equalTo(0);
            }];
            self.bottomRecommendLabel.text = adModel.text;
        }
    } else {
        [self.bottomRecommendLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(10);
        }];
    }
}

-(void)updateMainImageWithUrl:(NSString *)url
{
    NSURL *imgUrl = [NSURL URLWithString:url];
    if (imgUrl) {
        [self.mainImageView bd_setImageWithURL:imgUrl placeholder:[FHHouseSearchSecondHouseCell placeholderImage]];
    }else{
        self.mainImageView.image = [FHHouseSearchSecondHouseCell placeholderImage];
    }
}

- (void)resetPriceFrame {
    self.priceLabel.text = self.model.displayPrice;
    CGSize size = [self.priceLabel sizeThatFits:CGSizeZero];
    [self.priceLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(size.width);
    }];
}

- (void)dislike {
    
}

- (void)prepareForReuse {
    [super prepareForReuse];
    for (UIView *view in self.mainTitleView.subviews) {
        [view removeFromSuperview];
    }
    for (UIView *view in self.tagContainerView.subviews) {
        [view removeFromSuperview];
    }
    for (UIView *view in self.bottomView.subviews) {
        [view removeFromSuperview];
    }
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

- (UIImageView *)mainImageView {
    if (!_mainImageView) {
        _mainImageView = [[UIImageView alloc] init];
        _mainImageView.contentMode = UIViewContentModeScaleAspectFill;
        _mainImageView.layer.cornerRadius = 4;
        _mainImageView.layer.masksToBounds = YES;
        _mainImageView.layer.borderWidth = 0.5;
        _mainImageView.layer.borderColor = [UIColor themeGray7].CGColor;
    }
    return _mainImageView;
}

- (LOTAnimationView *)vrLoadingView {
    if (!_vrLoadingView) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"VRImageLoading" ofType:@"json"];
        _vrLoadingView = [LOTAnimationView animationWithFilePath:path];
        _vrLoadingView.loopAnimation = YES;
    }
    return  _vrLoadingView;
}

- (UILabel *)subTitleLabel {
    if (!_subTitleLabel) {
        _subTitleLabel = [[UILabel alloc] init];
        _subTitleLabel.font = [UIFont themeFontRegular:12];
        _subTitleLabel.textColor = [UIColor themeGray1];
    }
    return _subTitleLabel;
}

- (UILabel *)priceLabel {
    if (!_priceLabel) {
        _priceLabel = [[UILabel alloc] init];
        _priceLabel.font = [UIFont themeFontSemibold:16];
        _priceLabel.textColor = [UIColor themeRed4];
    }
    return _priceLabel;
}

-(UILabel *)pricePerSqmLabel
{
    if (!_pricePerSqmLabel) {
        _pricePerSqmLabel = [[UILabel alloc]init];
        _pricePerSqmLabel.font = [UIFont themeFontRegular:12];
        _pricePerSqmLabel.textColor = [UIColor themeGray3];
    }
    return _pricePerSqmLabel;
}

-(UIImageView *)bottomIconImageView
{
    if (!_bottomIconImageView) {
        _bottomIconImageView= [[UIImageView alloc]init];
        _bottomIconImageView.backgroundColor = [UIColor clearColor];
    }
    return _bottomIconImageView;
}

-(UILabel *)bottomRecommendLabel
{
    if (!_bottomRecommendLabel) {
        _bottomRecommendLabel = [[UILabel alloc]init];
        _bottomRecommendLabel.font = [UIFont themeFontRegular:10];
        _bottomRecommendLabel.textColor = [UIColor themeGray1];
    }
    return _bottomRecommendLabel;
}

- (UIButton *)closeBtn {
    if (!_closeBtn) {
        _closeBtn = [[UIButton alloc] init];
        //_closeBtn.hidden = YES;
        UIImage *img = ICON_FONT_IMG(16, @"\U0000e673", [UIColor themeGray5]);
        [_closeBtn setImage:img forState:UIControlStateNormal];
        [_closeBtn addTarget:self action:@selector(dislike) forControlEvents:UIControlEventTouchUpInside];
        _closeBtn.hitTestEdgeInsets = UIEdgeInsetsMake(-10, -20, -10, -20);
    }
    return _closeBtn;
}

@end
