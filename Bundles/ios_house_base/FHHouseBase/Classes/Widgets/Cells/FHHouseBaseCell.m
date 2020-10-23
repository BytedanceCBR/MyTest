//
//  FHHouseBaseCell.m
//  FHHouseBase
//
//  Created by xubinbin on 2020/10/21.
//

#import "FHHouseBaseCell.h"

@implementation FHHouseBaseCell

+ (UIImage *)placeholderImage {
    static UIImage *placeholderImage = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        placeholderImage = [UIImage imageNamed: @"default_image"];
    });
    return placeholderImage;
}

+ (CGFloat)heightForData:(id)data {
    return 0;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)initUI {
    
}

- (void)refreshWithData:(id)data {
    
}

- (void)resumeVRIcon {
    if (_vrLoadingView && !self.vrLoadingView.hidden) {
        [self.vrLoadingView play];
    }
}

- (void)updateMainImageWithUrl:(NSString *)url {
    NSURL *imgUrl = [NSURL URLWithString:url];
    if (imgUrl) {
        [self.mainImageView bd_setImageWithURL:imgUrl placeholder:[[self class] placeholderImage]];
    }else{
        self.mainImageView.image = [[self class] placeholderImage];
    }
}

- (void)refreshIndexCorner:(BOOL)isFirst andLast:(BOOL)isLast {
    if (isFirst) {
        UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.houseCellBackView.bounds byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii:CGSizeMake(15, 15)];
        CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
        maskLayer.frame = self.houseCellBackView.bounds;
        maskLayer.path = maskPath.CGPath;
        self.houseCellBackView.layer.mask = maskLayer;
    } else if (isLast) {
        UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.houseCellBackView.bounds byRoundingCorners:UIRectCornerBottomLeft | UIRectCornerBottomRight cornerRadii:CGSizeMake(15, 15)];
        CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
        maskLayer.frame = self.houseCellBackView.bounds;
        maskLayer.path = maskPath.CGPath;
        self.houseCellBackView.layer.mask = maskLayer;
    } else {
        self.houseCellBackView.layer.mask = nil;
    }
}

-(void)hideRecommendReason
{
    if ( _recReasonView && self.recReasonView.yoga.isIncludedInLayout) {
        [self.recReasonView configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
            layout.isIncludedInLayout = NO;
        }];
        self.recReasonView.hidden = YES;
    }
}

- (UILabel *)mainTitleLabel {
    if (!_mainTitleLabel) {
        _mainTitleLabel = [[UILabel alloc]init];
        _mainTitleLabel.font = [UIFont themeFontRegular:16];
        _mainTitleLabel.textColor = [UIColor themeGray1];
    }
    return _mainTitleLabel;
}

- (UILabel *)subTitleLabel {
    if (!_subTitleLabel) {
        _subTitleLabel = [[UILabel alloc]init];
        _subTitleLabel.font = [UIFont themeFontRegular:12];
        _subTitleLabel.textColor = [UIColor themeGray1];
    }
    return _subTitleLabel;
}

- (YYLabel *)tagLabel {
    if (!_tagLabel) {
        _tagLabel = [[YYLabel alloc]init];
        _tagLabel.font = [UIFont themeFontRegular:12];
        _tagLabel.textColor = [UIColor themeGray3];
    }
    return _tagLabel;
}

- (UILabel *)pricePerSqmLabel {
    if (!_pricePerSqmLabel) {
        _pricePerSqmLabel = [[UILabel alloc]init];
        if ([UIDevice btd_isScreenWidthLarge320]) {
            _pricePerSqmLabel.font = [UIFont themeFontRegular:12];
        } else {
            _pricePerSqmLabel.font = [UIFont themeFontRegular:10];
        }
        _pricePerSqmLabel.textColor = [UIColor themeGray1];
    }
    return _pricePerSqmLabel;
}

- (UILabel *)priceLabel {
    if (!_priceLabel) {
        _priceLabel = [[UILabel alloc]init];
        _priceLabel.font = [UIFont themeFontSemibold:16];
        _priceLabel.textColor = [UIColor themeRed4];
    }
    return _priceLabel;
}

- (UILabel *)originPriceLabel {
    if (!_originPriceLabel) {
        _originPriceLabel = [[UILabel alloc]init];
        if ([UIDevice btd_isScreenWidthLarge320]) {
            _originPriceLabel.font = [UIFont themeFontRegular:12];
        }else {
            _originPriceLabel.font = [UIFont themeFontRegular:10];
        }
        _originPriceLabel.textColor = [UIColor themeGray3];
        _originPriceLabel.hidden = YES;
    }
    return _originPriceLabel;
}

- (LOTAnimationView *)vrLoadingView {
    if (!_vrLoadingView) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"VRImageLoading" ofType:@"json"];
        _vrLoadingView = [LOTAnimationView animationWithFilePath:path];
        _vrLoadingView.loopAnimation = YES;
    }
    return _vrLoadingView;
}

- (UIImageView *)mainImageView {
    if (!_mainImageView) {
        _mainImageView = [[UIImageView alloc]init];
        _mainImageView.contentMode = UIViewContentModeScaleAspectFill;
        _mainImageView.layer.cornerRadius = 4;
        _mainImageView.clipsToBounds = YES;
        _mainImageView.layer.borderWidth = 0.5;
        _mainImageView.layer.borderColor = [UIColor colorWithHexString:@"e1e1e1"].CGColor;
    }
    return _mainImageView;
}

- (UIImageView *)videoImageView {
    if (!_videoImageView) {
        _videoImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"video_image"]];
    }
    return _videoImageView;
}

- (UIView *)leftInfoView {
    if (!_leftInfoView) {
        _leftInfoView = [[UIView alloc] init];
    }
    return _leftInfoView;
}

- (UIView *)rightInfoView {
    if (!_rightInfoView) {
        _rightInfoView = [[UIView alloc] init];
    }
    return _rightInfoView;
}

- (UIView *)houseCellBackView {
    if (!_houseCellBackView) {
        _houseCellBackView = [[UIView alloc] init];
    }
    return _houseCellBackView;
}

- (UIView *)houseMainImageBackView {
    if (!_houseMainImageBackView) {
        _houseMainImageBackView = [[UIView alloc] init];
        _houseMainImageBackView.backgroundColor = [UIColor whiteColor];
        CALayer * layer = _houseMainImageBackView.layer;
        layer.shadowOffset = CGSizeMake(0, 4);
        layer.shadowRadius = 6;
        layer.shadowColor = [UIColor blackColor].CGColor;;
        layer.shadowOpacity = 0.2;
    }
    return _houseMainImageBackView;
}

- (FHCornerView *)imageTagLabelBgView {
    if (!_imageTagLabelBgView) {
        _imageTagLabelBgView = [[FHCornerView alloc]init];
        _imageTagLabelBgView.backgroundColor = [UIColor themeRed3];
        _imageTagLabelBgView.hidden = YES;
    }
    return _imageTagLabelBgView;
}

- (UILabel *)imageTagLabel {
    if (!_imageTagLabel) {
        _imageTagLabel = [[UILabel alloc]init];
        _imageTagLabel.text = @"";
        _imageTagLabel.textAlignment = NSTextAlignmentCenter;
        _imageTagLabel.font = [UIFont themeFontRegular:10];
        _imageTagLabel.textColor = [UIColor whiteColor];
    }
    return _imageTagLabel;
}

- (UIImageView *)houseVideoImageView {
    if (!_houseVideoImageView) {
        _houseVideoImageView = [[UIImageView alloc]init];
        _houseVideoImageView.image = [UIImage imageNamed:@"icon_list_house_video"];
        _houseVideoImageView.backgroundColor = [UIColor clearColor];
    }
    return _houseVideoImageView;
}

- (UIView *)priceBgView {
    if (!_priceBgView) {
        _priceBgView = [[UIView alloc] init];
    }
    return _priceBgView;
}

- (FHHouseRecommendReasonView *)recReasonView {
    
    if (!_recReasonView) {
        _recReasonView = [[FHHouseRecommendReasonView alloc] init];
    }
    return _recReasonView;
}

- (FHCornerItemLabel *)tagTitleLabel {
    if (!_tagTitleLabel) {
        _tagTitleLabel = [[FHCornerItemLabel alloc] init];
        _tagTitleLabel.textAlignment = NSTextAlignmentCenter;
        _tagTitleLabel.font = [UIFont themeFontMedium:10];
        _tagTitleLabel.textColor = [UIColor themeWhite];
        _tagTitleLabel.frame = CGRectMake(0, 0, 16, 16);
    }
    return _tagTitleLabel;
}

@end
