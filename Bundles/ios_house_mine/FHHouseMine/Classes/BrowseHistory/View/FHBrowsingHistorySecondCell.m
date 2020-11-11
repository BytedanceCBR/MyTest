//
//  FHBrowsingHistorySecondCell.m
//  FHHouseMine
//
//  Created by xubinbin on 2020/11/6.
//

#import "FHBrowsingHistorySecondCell.h"
#import "FHHouseListBaseItemModel.h"
#import "FHSingleImageInfoCellModel.h"
#import "FHCommonDefines.h"

@interface FHBrowsingHistorySecondCell()

@property(nonatomic, strong) UIView *opView; //蒙层
@property(nonatomic, strong) UILabel *offShelfLabel; //下架

@end

@implementation FHBrowsingHistorySecondCell

+ (CGFloat)heightForData:(id)data {
    BOOL isLastCell = NO;
    if([data isKindOfClass:[FHSearchHouseItemModel class]]) {
        FHSearchHouseItemModel *model = (FHSearchHouseItemModel *)data;
        isLastCell = model.isLastCell;
        CGFloat reasonHeight = [model showRecommendReason] ? 22 : 0;
        return (isLastCell ? 108 : 88) + reasonHeight;
    }
    return 88;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initUI];
    }
    return self;
}

- (void)initUI {
    [super initUI];
    [self.mainImageView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(12);
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
    self.opView = [[UIView alloc] init];
    [self.opView setBackgroundColor:[UIColor colorWithRed:170.0/255 green:170.0/255 blue:170.0/255 alpha:0.8]];
    self.opView.layer.shadowOffset = CGSizeMake(4, 6);
    self.opView.layer.cornerRadius = 4;
    self.opView.clipsToBounds = YES;
    self.opView.layer.shadowColor = [[UIColor colorWithRed:0 green:0 blue:0 alpha:0.1] CGColor];
    [self.mainImageView addSubview:_opView];
    [self.opView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    self.opView.hidden = YES;
    
    self.offShelfLabel = [[UILabel alloc] init];
    self.offShelfLabel.text = @"已下架";
    self.offShelfLabel.font = [UIFont themeFontSemibold:14];
    self.offShelfLabel.textColor = [UIColor whiteColor];
    [self.mainImageView addSubview:_offShelfLabel];
    [self.offShelfLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.mainImageView);
    }];
    self.offShelfLabel.hidden = YES;
}

- (void)refreshWithData:(id)data {
    if (![data isKindOfClass:[FHSearchHouseItemModel class]]) {
        return;
    }
    FHSearchHouseItemModel *commonModel = (FHSearchHouseItemModel *)data;
    FHImageModel *imageModel = commonModel.houseImage.firstObject;
    [self updateMainImageWithUrl:imageModel.url];
    self.mainTitleLabel.text = commonModel.displayTitle;
    self.subTitleLabel.text = commonModel.displaySubtitle;
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
    self.tagLabel.attributedText =  attributeString;
    self.priceLabel.font = [UIFont themeFontSemibold:[UIDevice btd_isScreenWidthLarge320] ? 16 : 15];
    self.priceLabel.text = commonModel.displayPrice;
    //异常单价,百万级别单价处理
    if (self.pricePerSqmLabel.text.length >= 10) {
       self.pricePerSqmLabel.font = [UIFont themeFontRegular:10];
    }
    if (commonModel.originPrice) {
        self.pricePerSqmLabel.attributedText = [self originPriceAttr:commonModel.originPrice];
    } else {
        if (commonModel.displayPricePerSqm.length>0) {
             self.pricePerSqmLabel.attributedText = [[NSAttributedString alloc]initWithString:commonModel.displayPricePerSqm attributes:@{NSStrikethroughStyleAttributeName:@(NSUnderlineStyleNone)}];
        }
    }
    if (commonModel.vrInfo.hasVr) {
        self.houseVideoImageView.hidden = YES;
        self.vrLoadingView.hidden = NO;
        [self.vrLoadingView play];
    } else {
        self.vrLoadingView.hidden = YES;
        [self.vrLoadingView stop];
    }
    //企业担保标签，tag_image字段下发
    [self configTopLeftTagWithTagImages:commonModel.tagImage];
    [self updateHouseStatus:commonModel];
}

- (void)updateHouseStatus:(id)data {
    FHSearchHouseItemModel *model = data;
    self.opView.hidden = (model.houseStatus.integerValue == 0) ? YES : NO;
    self.offShelfLabel.hidden = (model.houseStatus.integerValue == 0) ? YES : NO;
}

- (CGFloat)contentSmallImageMaxWidth {
    return  SCREEN_WIDTH  + 40 - 72 - 90; //根据UI图 直接计算出来
}

#pragma mark 字符串处理
-(NSAttributedString *)originPriceAttr:(NSString *)originPrice {
    
    if (originPrice.length < 1) {
        return nil;
    }
    NSAttributedString *attri = [[NSAttributedString alloc]initWithString:originPrice attributes:@{NSStrikethroughStyleAttributeName:@(NSUnderlineStyleSingle),NSStrikethroughColorAttributeName:[UIColor themeGray1]}];
    return attri;
}

@end
