//
//  FHRealtorSecondCell.m
//  FHHouseRealtorDetail
//
//  Created by xubinbin on 2020/11/9.
//

#import "FHRealtorSecondCell.h"
#import "FHHomeHouseModel.h"
#import "FHSingleImageInfoCellModel.h"
#import "FHCommonDefines.h"

@interface FHRealtorSecondCell()

@property(nonatomic, strong) UIView *maskVRImageView;

@end

@implementation FHRealtorSecondCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initUI];
    }
    return self;
}

- (void)initUI {
    [super initUI];
    self.contentView.backgroundColor = [UIColor themeGray7];
    self.houseCellBackView.hidden = NO;
    [self.houseCellBackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
        make.right.mas_equalTo(-15);
        make.top.bottom.mas_equalTo(0);
    }];
    [self.mainImageView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(12);
        make.left.mas_equalTo(26);
    }];
    self.houseMainImageBackView.backgroundColor = [UIColor whiteColor];
    [self.houseMainImageBackView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.mainImageView).offset(3);
        make.left.mas_equalTo(self.mainImageView).offset(3);
        make.right.mas_equalTo(self.mainImageView).offset(-3);
        make.bottom.mas_equalTo(self.mainImageView).offset(-3);
    }];
    [self.contentView addSubview:self.topLeftTagImageView];
    [self.topLeftTagImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.equalTo(self.mainImageView);
        make.size.mas_equalTo(CGSizeMake(48, 18));
    }];
    [self.mainTitleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-40);
    }];
    [self.pricePerSqmLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-23);
    }];
    [self.contentView addSubview:self.tagTitleLabel];
    [self.tagTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.greaterThanOrEqualTo(self.mainTitleLabel.mas_right).offset(2);
        make.height.mas_equalTo(16);
        make.top.mas_equalTo(self.mainTitleLabel).offset(1.5);
    }];
}

- (void)refreshWithData:(id)data {
    if (![data isKindOfClass:[FHHomeHouseDataItemsModel class]]) {
        return;
    }
    FHHomeHouseDataItemsModel *commonModel = (FHHomeHouseDataItemsModel *)data;
    self.houseVideoImageView.hidden = !commonModel.houseVideo.hasVideo;
    self.mainTitleLabel.text = commonModel.displayTitle;
    NSAttributedString *attributeString = nil;
    if (commonModel.reasonTags.count > 0) {
        FHHouseTagsModel *element = commonModel.reasonTags.firstObject;
        if (element.content && element.textColor && element.backgroundColor) {
            UIColor *textColor = [UIColor colorWithHexString:element.textColor] ? : [UIColor themeRed4];
            UIColor *backgroundColor = [UIColor colorWithHexString:element.backgroundColor] ? : [UIColor whiteColor];
            attributeString = [FHSingleImageInfoCellModel createTagAttrString:element.content textColor:textColor backgroundColor:backgroundColor];
            self.tagLabel.lineBreakMode = NSLineBreakByTruncatingTail;
            
        }
    } else {
        self.tagLabel.lineBreakMode = NSLineBreakByWordWrapping;
        CGFloat maxWidth = [self contentSmallImageMaxWidth] - 60;
        attributeString = [FHSingleImageInfoCellModel newTagsStringWithTagList:commonModel.tags maxWidth:maxWidth];
    }
    self.tagLabel.attributedText =  attributeString;
    FHImageModel *imageModel = commonModel.houseImage.firstObject;
    [self updateMainImageWithUrl:imageModel.url];
    self.subTitleLabel.text = commonModel.displaySubtitle;
    self.priceLabel.font = [UIFont themeFontSemibold:[UIDevice btd_isScreenWidthLarge320] ? 16 : 15];
    self.pricePerSqmLabel.textColor = [UIColor themeGray1];
    self.pricePerSqmLabel.font = [UIFont themeFontRegular:12];
    self.priceLabel.text = commonModel.displayPrice;
    if (commonModel.originPrice) {
        self.pricePerSqmLabel.attributedText = [self originPriceAttr:commonModel.originPrice];
    } else {
      self.pricePerSqmLabel.attributedText =  [[NSAttributedString alloc]initWithString:(commonModel.displayPricePerSqm.length>0?commonModel.displayPricePerSqm:@"") attributes:@{NSStrikethroughStyleAttributeName:@(NSUnderlineStyleNone)}];
    }
    if (self.maskVRImageView) {
        [self.maskVRImageView removeFromSuperview];
        self.maskVRImageView = nil;
    }
    
    if (commonModel.vrInfo.hasVr) {
        self.vrLoadingView.hidden = NO;
        [self.vrLoadingView play];
        self.houseVideoImageView.hidden = YES;
        
        self.maskVRImageView = [UIView new];
        self.maskVRImageView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.1];
        [self.mainImageView addSubview:self.maskVRImageView];
        [self.maskVRImageView setFrame:CGRectMake(0.0f, 0.0f, 114, 85)];
        [self bringTagImageToTopIfExist];
    } else {
        if (self.vrLoadingView) {
            self.vrLoadingView.hidden = YES;
        }
    }
    //企业担保标签
    [self configTopLeftTagWithTagImages:commonModel.tagImage];
    CGSize titleSize = [self.mainTitleLabel sizeThatFits:CGSizeMake(100, 22)];
    if (commonModel.titleTag.text.length > 0) {
        self.tagTitleLabel.hidden = NO;
        self.tagTitleLabel.text = commonModel.titleTag.text;
        self.tagTitleLabel.backgroundColor = [UIColor colorWithHexString:commonModel.titleTag.backgroundColor];
        self.tagTitleLabel.textColor = [UIColor colorWithHexString:commonModel.titleTag.textColor];
        [self.mainTitleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(titleSize.width + 3);
        }];
        //修改两字标签
        CGFloat width = commonModel.titleTag.text.length > 1 ? 28 : 16;
        [self.tagTitleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(width);
        }];
     } else {
          self.tagTitleLabel.hidden = YES;
    }
}

///把左上角的标签放在最上面，防止被VC蒙层遮挡
- (void)bringTagImageToTopIfExist {
    if (self.topLeftTagImageView) {
        [self.mainImageView bringSubviewToFront:self.topLeftTagImageView];
    }
}

- (CGFloat)contentSmallImageMaxWidth {
    return  SCREEN_WIDTH - 20 - 72 - 90; //根据UI图 直接计算出来
}

- (void)refreshIndexCorner:(BOOL)isFirst andLast:(BOOL)isLast {
    CGRect frame = CGRectMake(0, 0, SCREEN_WIDTH - 30, 86);
    if (isFirst) {
        UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:frame byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii:CGSizeMake(15, 15)];
        CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
        maskLayer.frame = frame;
        maskLayer.path = maskPath.CGPath;
        self.houseCellBackView.layer.mask = maskLayer;
    } else if (isLast){
        UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:frame byRoundingCorners:UIRectCornerBottomLeft | UIRectCornerBottomRight cornerRadii:CGSizeMake(15, 15)];
        CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
        maskLayer.frame = frame;
        maskLayer.path = maskPath.CGPath;
        self.houseCellBackView.layer.mask = maskLayer;
    }  else {
        self.houseCellBackView.layer.mask = nil;
    }
}

@end
