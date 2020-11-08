//
//  FHBrowsingHistorySecondCell.m
//  FHHouseMine
//
//  Created by xubinbin on 2020/11/6.
//

#import "FHBrowsingHistorySecondCell.h"
#import "FHHouseListBaseItemModel.h"
#import "FHSingleImageInfoCellModel.h"

@interface FHBrowsingHistorySecondCell()

@property(nonatomic, strong) UIView *opView; //蒙层
@property(nonatomic, strong) UILabel *offShelfLabel; //下架

@end

@implementation FHBrowsingHistorySecondCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initUI];
    }
    return self;
}

- (void)refreshWithData:(id)data {
    if (![data isKindOfClass:[FHSearchHouseItemModel class]]) {
        return;
    }
    FHSearchHouseItemModel *commonModel = (FHSearchHouseItemModel *)data;
    self.closeBtn.hidden = YES;
    
    self.priceLabel.text = commonModel.pricePerSqmNum;
    self.pricePerSqmLabel.text = commonModel.pricePerSqmUnit;
    self.pricePerSqmLabel.hidden = NO;
    
    self.houseVideoImageView.hidden = !commonModel.houseVideo.hasVideo;
    self.mainTitleLabel.text = commonModel.displayTitle;
    self.subTitleLabel.text = commonModel.displayDescription;
    NSAttributedString * attributeString = nil;
    if (commonModel.reasonTags.count > 0) {
        FHHouseTagsModel *element = commonModel.reasonTags.firstObject;
        if (element.content && element.textColor && element.backgroundColor) {
            UIColor *textColor = [UIColor colorWithHexString:element.textColor] ? : [UIColor themeRed4];
            UIColor *backgroundColor = [UIColor colorWithHexString:element.backgroundColor] ? : [UIColor whiteColor];
            attributeString = [FHSingleImageInfoCellModel createTagAttrString:element.content textColor:textColor backgroundColor:backgroundColor];
            self.tagLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        }
    }else {
        CGFloat maxWidth = [self contentSmallImageMaxWidth] - 70;
        attributeString = [FHSingleImageInfoCellModel newTagsStringWithTagList:commonModel.tags maxWidth:maxWidth];
        self.tagLabel.lineBreakMode = NSLineBreakByWordWrapping;
    }
    self.priceLabel.font = [UIFont themeFontSemibold:[UIDevice btd_isScreenWidthLarge320] ? 16 : 15];
    self.pricePerSqmLabel.textColor = [UIColor themeGray1];
    self.pricePerSqmLabel.font = [UIFont themeFontRegular:12];
    
    self.tagLabel.attributedText =  attributeString;
    
    FHImageModel *imageModel = commonModel.houseImage.firstObject;
    [self updateMainImageWithUrl:imageModel.url];
    self.subTitleLabel.text = commonModel.displaySubtitle;
    self.priceLabel.text = commonModel.displayPrice;
    if (commonModel.originPrice) {
        self.pricePerSqmLabel.attributedText = [self originPriceAttr:commonModel.originPrice];
    }else{
        if (commonModel.displayPricePerSqm.length>0) {
             self.pricePerSqmLabel.attributedText = [[NSAttributedString alloc]initWithString:commonModel.displayPricePerSqm attributes:@{NSStrikethroughStyleAttributeName:@(NSUnderlineStyleNone)}];
        }
    }
    CGSize priceSize = [self.priceLabel sizeThatFits:CGSizeMake(SCREEN_WIDTH, 30)];
     [self.priceLabel configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
        layout.maxWidth = YGPointValue(100);
        layout.width = YGPointValue(priceSize.width + 2);
    }];

    if (commonModel.houseImageTag.text && commonModel.houseImageTag.backgroundColor && commonModel.houseImageTag.textColor) {
        self.imageTagLabel.textColor = [UIColor colorWithHexString:commonModel.houseImageTag.textColor];
        self.imageTagLabel.text = commonModel.houseImageTag.text;
        self.imageTagLabelBgView.backgroundColor = [UIColor colorWithHexString:commonModel.houseImageTag.backgroundColor];
        self.imageTagLabelBgView.hidden = NO;
    }else {
        
        self.imageTagLabelBgView.hidden = YES;
    }
    if (self.maskVRImageView) {
        [self.maskVRImageView removeFromSuperview];
        self.maskVRImageView = nil;
    }
    
    if (commonModel.vrInfo.hasVr) {
        if (![self.leftInfoView.subviews containsObject:self.vrLoadingView]) {
            [self.leftInfoView addSubview:self.vrLoadingView];
            self.vrLoadingView.hidden = YES;
            //    [self.vrLoadingView setBackgroundColor:[UIColor redColor]];
            [self.vrLoadingView configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
                layout.isEnabled = YES;
                layout.position = YGPositionTypeAbsolute;
                layout.top = YGPointValue(64 - 10);
                layout.left = YGPointValue(12);
                layout.width = YGPointValue(16);
                layout.height = YGPointValue(16);
            }];
        }
        
        self.vrLoadingView.hidden = NO;
        [self.vrLoadingView play];
        self.houseVideoImageView.hidden = YES;
        
        self.maskVRImageView = [UIView new];
        self.maskVRImageView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.1];
        [self.mainImageView addSubview:self.maskVRImageView];
        [self.maskVRImageView setFrame:CGRectMake(0.0f, 0.0f, 114, 85)];
        [self bringTagImageToTopIfExist];
    }else
    {
        if (self.vrLoadingView) {
            self.vrLoadingView.hidden = YES;
        }
    }
  //处理标签
     BOOL imageTagHidden = self.imageTagLabelBgView.hidden;
     CGSize titleSize = [self.mainTitleLabel sizeThatFits:CGSizeMake(100, 22)];
     if (commonModel.houseTitleTag.text.length > 0) {
         self.imageTagLabelBgView.hidden = YES;
         self.tagTitleLabel.hidden = NO;
         [self.mainTitleLabel configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
             layout.width = YGPointValue(titleSize.width+3);
             layout.maxWidth = YGPointValue([self contentSmallImageMaxWidth] - 20);
         }];
         self.tagTitleLabel.text = commonModel.houseTitleTag.text;
         self.tagTitleLabel.backgroundColor = [UIColor colorWithHexString:commonModel.houseTitleTag.backgroundColor];
         self.tagTitleLabel.textColor = [UIColor colorWithHexString:commonModel.houseTitleTag.textColor];
         //修改两字标签
         [self.tagTitleLabel configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
                      layout.isEnabled = YES;
                      layout.marginTop = YGPointValue(1.5);
                      layout.marginLeft = YGPointValue(2);
                      layout.height = YGPointValue(16);
                layout.width = YGPointValue(commonModel.houseTitleTag.text.length > 1 ? 28 : 16);
         }];
     } else {
         self.imageTagLabelBgView.hidden = imageTagHidden;
         self.tagTitleLabel.hidden = YES;
         [self.mainTitleLabel configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
             layout.width = YGPointValue([self contentSmallImageMaxWidth]);
         }];
     }
    
    [self.subTitleLabel configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
        layout.maxWidth = YGPointValue([self contentSmallImageMaxWidth] - 80);
    }];
    
    [self.pricePerSqmLabel configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
        layout.maxWidth = YGPointValue(72 + 5);
    }];
    
    self.tagLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    [self.tagLabel configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
         layout.width = YGPointValue([self contentSmallImageTagMaxWidth] + 10);
    }];
    
    self.tagLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    [self.tagLabel configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
         layout.width = YGPointValue([self contentSmallImageTagMaxWidth] + 10);
    }];
    
     [self.mainTitleLabel.yoga markDirty];
     [self.tagLabel.yoga markDirty];
     [self.subTitleLabel.yoga markDirty];
     [self.pricePerSqmLabel.yoga markDirty];
     [self.tagTitleLabel.yoga markDirty];
    
    
    //异常单价,百万级别单价处理
    if (self.pricePerSqmLabel.text.length >= 10) {
       self.pricePerSqmLabel.font = [UIFont themeFontRegular:10];
    }
    
    //企业担保标签，tag_image字段下发
    [self configTopLeftTagWithTagImages:commonModel.tagImage];
}

///把左上角的标签放在最上面，防止被VC蒙层遮挡
- (void)bringTagImageToTopIfExist {
    if (self.topLeftTagImageView) {
        [self.mainImageView bringSubviewToFront:self.topLeftTagImageView];
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
        [self.topLeftTagImageView configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
            layout.width = YGPointValue(width > 0.0 ? width : 48);
        }];
        [self.topLeftTagImageView configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
            layout.height = YGPointValue(height > 0.0 ? height : 18);
        }];
        
        self.topLeftTagImageView.hidden = NO;
        [self.topLeftTagImageView.yoga markDirty];
    }else {
        self.topLeftTagImageView.hidden = YES;
    }
}

- (void)updateHouseStatus:(id)data {
    FHSearchHouseItemModel *model = self.currentData;
    if(model.houseStatus.integerValue != 0) {
        if (self.opView) {
            [self.opView removeFromSuperview];
            self.opView = nil;
        }
        if (self.offShelfLabel) {
            [self.offShelfLabel removeFromSuperview];
            self.offShelfLabel = nil;
        }
        self.opView = [[UIView alloc] init];
        [self.opView setBackgroundColor:[UIColor colorWithRed:170.0/255 green:170.0/255 blue:170.0/255 alpha:0.8]];
        [self.opView setFrame:CGRectMake(0, 0, self.mainImageView.frame.size.width, self.mainImageView.frame.size.height)];
        self.opView.layer.shadowOffset = CGSizeMake(4, 6);
        self.opView.layer.cornerRadius = 4;
        self.opView.clipsToBounds = YES;
        self.opView.layer.shadowColor = [[UIColor colorWithRed:0 green:0 blue:0 alpha:0.1] CGColor];
        [self.mainImageView addSubview:_opView];
        
        self.offShelfLabel = [[UILabel alloc] init];
        self.offShelfLabel.text = @"已下架";
        self.offShelfLabel.font = [UIFont themeFontSemibold:14];
        self.offShelfLabel.textColor = [UIColor whiteColor];
        [self.mainImageView addSubview:_offShelfLabel];
        [self.offShelfLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self.mainImageView);
        }];
    }else {
        if (self.opView) {
                   [self.opView removeFromSuperview];
                   self.opView = nil;
        }
        if (self.offShelfLabel) {
           [self.offShelfLabel removeFromSuperview];
           self.offShelfLabel = nil;
        }
    }
}

@end
