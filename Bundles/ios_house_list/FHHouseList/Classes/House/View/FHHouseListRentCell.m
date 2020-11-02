//
//  FHHouseListRentCell.m
//  FHHouseList
//
//  Created by xubinbin on 2020/10/28.
//

#import "FHHouseListRentCell.h"
#import "FHSingleImageInfoCellModel.h"
#import "FHCommonDefines.h"
#import <UIDevice+BTDAdditions.h>

@interface FHHouseListRentCell()

@property (nonatomic, strong) UILabel *distanceLabel; // 30 分钟到达

@end

@implementation FHHouseListRentCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initUI];
    }
    return self;
}

+ (CGFloat)recommendReasonHeight {
    return 22;
}

+ (CGFloat)heightForData:(id)data {
    BOOL isLastCell = NO;
    if([data isKindOfClass:[FHSearchHouseItemModel class]]) {
        FHSearchHouseItemModel *model = (FHSearchHouseItemModel *)data;
        isLastCell = model.isLastCell;
        CGFloat reasonHeight = [model showRecommendReason] ? [self recommendReasonHeight] : 0;
        return (isLastCell ? 108 : 88) + reasonHeight;
    }
    return 88;
}

- (void)initUI {
    [super initUI];
    [self.mainImageView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(12);
    }];
    [self.houseMainImageBackView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.mainImageView).offset(3);
        make.left.mas_equalTo(self.mainImageView).offset(3);
        make.right.mas_equalTo(self.mainImageView).offset(-3);
        make.bottom.mas_equalTo(self.mainImageView).offset(-3);
    }];
    self.tagInformation.hidden = YES;
    [self.contentView addSubview:self.tagLabel];
    [self.tagLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mainTitleLabel);
        make.top.equalTo(self.subTitleLabel.mas_bottom).offset(7);
        make.right.mas_lessThanOrEqualTo(self.priceLabel.mas_left).offset(-2);
    }];
    [self.contentView addSubview:self.distanceLabel];
    [self.distanceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mainTitleLabel);
        make.top.equalTo(self.subTitleLabel.mas_bottom).offset(7);
        make.right.mas_lessThanOrEqualTo(self.priceLabel.mas_left).offset(-2);
    }];
    self.distanceLabel.hidden = YES;
}

- (void)refreshWithData:(id)data {
    if (![data isKindOfClass:[FHSearchHouseItemModel class]]) {
        return;
    }
    FHSearchHouseItemModel *model = (FHSearchHouseItemModel *)data;
    NSAttributedString *attributeString = nil;
    if (model.reasonTags.count > 0) {
        FHHouseTagsModel *element = model.reasonTags.firstObject;
        if (element.content && element.textColor && element.backgroundColor) {
            UIColor *textColor = [UIColor colorWithHexString:element.textColor] ? : [UIColor themeRed4];
            UIColor *backgroundColor = [UIColor colorWithHexString:element.backgroundColor] ? : [UIColor whiteColor];
            attributeString = [FHSingleImageInfoCellModel createTagAttrString:element.content textColor:textColor backgroundColor:backgroundColor];
            self.tagLabel.lineBreakMode = NSLineBreakByTruncatingTail;
            
        }
    } else {
        self.tagLabel.lineBreakMode = NSLineBreakByWordWrapping;
        CGFloat maxWidth = [self contentSmallImageMaxWidth] - 60;
        attributeString = [FHSingleImageInfoCellModel newTagsStringWithTagList:model.tags maxWidth:maxWidth];
    }
    self.tagLabel.attributedText = attributeString;
    self.priceLabel.font = [UIFont themeFontSemibold:[UIDevice btd_isScreenWidthLarge320] ? 16 : 15];
    
    NSArray *firstRow = [model.bottomText firstObject];
    NSDictionary *bottomText = nil;
    if ([firstRow isKindOfClass:[NSArray class]]) {
        NSDictionary *info = [firstRow firstObject];
        if ([info isKindOfClass:[NSDictionary class]]) {
            bottomText = info;
        }
    }
    if (model.addrData.length > 0) {
        self.tagLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        attributeString = [FHSingleImageInfoCellModel createTagAttrString:model.addrData textColor:[UIColor themeGray2] backgroundColor:[UIColor whiteColor]];
        self.tagLabel.attributedText =  attributeString;
    }
    [self updateBottomText:bottomText];
    self.mainTitleLabel.text = model.title;
    self.subTitleLabel.text = model.subtitle;
    self.pricePerSqmLabel.attributedText = [[NSMutableAttributedString alloc] initWithString:@" " attributes:@{}];
    self.priceLabel.text = model.pricing;
    FHImageModel *imageModel = [model.houseImage firstObject];
    [self updateMainImageWithUrl:imageModel.url];
}

- (void)updateBottomText:(NSDictionary *)bottomText {
    if (![bottomText isKindOfClass:[NSDictionary class]]) {
        return;
    }
    NSString *infoText = bottomText[@"text"];
    if (bottomText && bottomText[@"color"] && !IS_EMPTY_STRING(infoText)) {
        NSMutableAttributedString *commuteAttr = [[NSMutableAttributedString alloc]init];
        UIImage *clockImg =  SYS_IMG(@"clock_small");
        NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
        attachment.image = clockImg;
        attachment.bounds = CGRectMake(0, -1.5, 12, 12);
        NSAttributedString *clockAttr = [NSAttributedString attributedStringWithAttachment:attachment];
        [commuteAttr appendAttributedString:clockAttr];
        UIColor *textColor = [UIColor colorWithHexStr:bottomText[@"color"]]?:[UIColor themeGray3];
        NSDictionary *attr = @{NSFontAttributeName:[UIFont themeFontRegular:12],NSForegroundColorAttributeName:textColor};
        NSAttributedString *timeAttr = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@" %@",infoText] attributes:attr];
        [commuteAttr appendAttributedString:timeAttr];
        self.distanceLabel.attributedText = commuteAttr;
        self.distanceLabel.hidden = NO;
    } else {
        self.distanceLabel.hidden = YES;
    }
}

- (CGFloat)contentSmallImageMaxWidth {
    return  SCREEN_WIDTH + 40 - 72 - 90; //根据UI图 直接计算出来
}

- (UILabel *)distanceLabel {
    if (!_distanceLabel) {
        _distanceLabel = [[UILabel alloc] init];
        _distanceLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _distanceLabel;
}

@end
