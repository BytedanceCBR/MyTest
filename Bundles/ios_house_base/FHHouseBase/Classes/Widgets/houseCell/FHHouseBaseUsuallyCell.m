//
//  FHHouseBaseUsuallyCell.m
//  FHHouseBase
//
//  Created by xubinbin on 2020/10/26.
//

#import "FHHouseBaseUsuallyCell.h"

@implementation FHHouseBaseUsuallyCell

@synthesize mainTitleLabel = _mainTitleLabel, pricePerSqmLabel = _pricePerSqmLabel, priceLabel = _priceLabel, houseMainImageBackView = _houseMainImageBackView;

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    NSAssert(![self isMemberOfClass:[FHHouseBaseUsuallyCell class]], @"业务不可直接用基类，请继承基类");
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
    }
    return self;
}

- (void)initUI {
    [self.contentView addSubview:self.houseCellBackView];
    [self.contentView addSubview:self.houseMainImageBackView];
    [self.contentView addSubview:self.mainImageView];
    [self.houseMainImageBackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.mainImageView);
        make.left.top.equalTo(self.mainImageView);
        make.bottom.equalTo(self.mainImageView).offset(-1);
        make.right.equalTo(self.mainImageView).offset(-1);
    }];
    [self.mainImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(10);
        make.left.equalTo(self.contentView).offset(15);
        make.size.mas_equalTo(CGSizeMake(85, 64));
    }];
    [self.contentView addSubview:self.houseVideoImageView];
    [self.houseVideoImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mainImageView).offset(12);
        make.bottom.equalTo(self.mainImageView).offset(-10);
        make.size.mas_equalTo(CGSizeMake(16, 16));
    }];
    [self.contentView addSubview:self.vrLoadingView];
    [self.vrLoadingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mainImageView).offset(6);
        make.bottom.equalTo(self.mainImageView).offset(-6);
        make.size.mas_equalTo(CGSizeMake(16, 16));
    }];
    [self.contentView addSubview:self.mainTitleLabel];
    [self.mainTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mainImageView.mas_right).offset(12);
        make.top.equalTo(self.mainImageView).offset(-2);
        make.right.equalTo(self.contentView).offset(-15);
    }];
    [self.contentView addSubview:self.subTitleLabel];
    [self.subTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mainTitleLabel);
        make.top.equalTo(self.mainTitleLabel.mas_bottom).offset(2);
    }];
    [self.contentView addSubview:self.pricePerSqmLabel];
    [self.pricePerSqmLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_greaterThanOrEqualTo(self.subTitleLabel.mas_right).offset(2);
        make.top.equalTo(self.subTitleLabel);
        make.right.equalTo(self.contentView).offset(-15);
    }];
    [self.pricePerSqmLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [self.pricePerSqmLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [self.contentView addSubview:self.priceLabel];
    [self.priceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.pricePerSqmLabel.mas_right);
        make.top.equalTo(self.pricePerSqmLabel.mas_bottom).offset(4);
    }];
    [self.contentView addSubview:self.tagLabel];
    [self.tagLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mainTitleLabel);
        make.top.equalTo(self.subTitleLabel.mas_bottom).offset(7);
        make.right.mas_lessThanOrEqualTo(self.priceLabel.mas_left).offset(-2);
    }];
}

- (void)refreshWithData:(id)data {
    self.currentData = data;
    if([data isKindOfClass:[FHHouseListBaseItemModel class]]) {
        FHHouseListBaseItemModel *model = (FHHouseListBaseItemModel *)data;
        FHImageModel *imageModel = model.houseImage.firstObject;
        [self updateMainImageWithUrl:imageModel.url];
        self.mainTitleLabel.text = model.title;
        self.subTitleLabel.text = model.displaySubtitle;
        if (model.originPrice) {
            self.pricePerSqmLabel.attributedText = [self originPriceAttr:model.originPrice];
        }else{
            self.pricePerSqmLabel.attributedText = [[NSMutableAttributedString alloc]initWithString:model.displayPricePerSqm attributes:@{}];
        }
        self.priceLabel.text = model.displayPrice;
        self.houseVideoImageView.hidden = !model.houseVideo.hasVideo;
        if (model.reasonTags.count>0) {
            self.tagLabel.attributedText = model.recommendReasonStr;
        }else {
            self.tagLabel.attributedText = model.tagString;
        }
        if (model.vrInfo.hasVr) {
            self.houseVideoImageView.hidden = YES;
            self.vrLoadingView.hidden = NO;
            [self.vrLoadingView play];
        } else {
            self.vrLoadingView.hidden = YES;
            [self.vrLoadingView stop];
        }
    }
}

- (void)configTopLeftTagWithTagImages:(NSArray<FHImageModel> *)tagImages {
    if (tagImages.count > 0) {
        FHImageModel *tagImageModel = tagImages.firstObject;
        if (!tagImageModel.url.length) {
            return;
        }
        NSURL *imageUrl = [NSURL URLWithString:tagImageModel.url];
        [self.topLeftTagImageView bd_setImageWithURL:imageUrl];
        CGFloat width = [tagImageModel.width floatValue];
        CGFloat height = [tagImageModel.height floatValue];
        [self.topLeftTagImageView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(width > 0.0 ? width : 48);
            make.height.mas_equalTo(height > 0.0 ? height : 18);
        }];
        self.topLeftTagImageView.hidden = NO;
        [self layoutIfNeeded];
    } else {
        self.topLeftTagImageView.hidden = YES;
    }
}

- (void)layoutTopLeftTagImageView {
    //图片圆角
    if (!CGRectEqualToRect(self.topLeftTagImageView.frame, CGRectZero)) {
        if (!_topLeftTagMaskLayer || !CGSizeEqualToSize(_topLeftTagMaskLayer.frame.size, self.topLeftTagImageView.frame.size)) {
            UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.topLeftTagImageView.bounds
                                                           byRoundingCorners:UIRectCornerTopLeft | UIRectCornerBottomRight
                                                                 cornerRadii:CGSizeMake(4, 4)];
            _topLeftTagMaskLayer = [[CAShapeLayer alloc] init];
            _topLeftTagMaskLayer.frame = self.topLeftTagImageView.bounds;
            _topLeftTagMaskLayer.path = maskPath.CGPath;
            self.topLeftTagImageView.layer.mask = _topLeftTagMaskLayer;
        }
    }
}

- (NSAttributedString *)originPriceAttr:(NSString *)originPrice {
    if (originPrice.length < 1) {
        return nil;
    }
    NSMutableAttributedString *attri = [[NSMutableAttributedString alloc] initWithString:originPrice];
    [attri addAttribute:NSStrikethroughStyleAttributeName value:@(NSUnderlineStyleSingle) range:NSMakeRange(0, originPrice.length)];
    [attri addAttribute:NSStrikethroughColorAttributeName value:[UIColor themeGray1] range:NSMakeRange(0, originPrice.length)];
    return attri;
}

///把左上角的标签放在最上面，防止被VC蒙层遮挡
- (void)bringTagImageToTopIfExist {
    if (self.topLeftTagImageView) {
        [self.mainImageView bringSubviewToFront:self.topLeftTagImageView];
    }
}

- (UILabel *)mainTitleLabel {
    if (!_mainTitleLabel) {
        _mainTitleLabel = [[UILabel alloc] init];
        _mainTitleLabel.font = [UIFont themeFontSemibold:18];
        _mainTitleLabel.textColor = [UIColor themeGray1];
    }
    return _mainTitleLabel;
}

- (UILabel *)pricePerSqmLabel {
    if (!_pricePerSqmLabel) {
        _pricePerSqmLabel = [[UILabel alloc] init];
        _pricePerSqmLabel.font = [UIFont themeFontRegular:12];
        _pricePerSqmLabel.textColor = [UIColor themeGray1];
    }
    return _pricePerSqmLabel;
}

- (UILabel *)priceLabel {
    if (!_priceLabel) {
        _priceLabel = [[UILabel alloc] init];
        _priceLabel.font = [UIFont themeFontMedium:16];
        _priceLabel.textColor = [UIColor themeOrange1];
    }
    return _priceLabel;
}

- (UIView *)houseMainImageBackView {
    if (!_houseMainImageBackView) {
        _houseMainImageBackView = [[UIView alloc] init];
        CALayer * layer = _houseMainImageBackView.layer;
        layer.shadowOffset = CGSizeMake(0, 4);
        layer.shadowRadius = 6;
        layer.shadowColor = [UIColor blackColor].CGColor;;
        layer.shadowOpacity = 0.2;
    }
    return _houseMainImageBackView;
}

@end
