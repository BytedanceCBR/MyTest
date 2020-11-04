//
//  FHHouseListNeighborhoodCell.m
//  FHHouseList
//
//  Created by xubinbin on 2020/11/4.
//

#import "FHHouseListNeighborhoodCell.h"

@implementation FHHouseListNeighborhoodCell

@synthesize mainImageView = _mainImageView;

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
}

- (void)refreshWithData:(id)data {
    if (![data isKindOfClass:[FHSearchHouseItemModel class]]) {
        return;
    }
    FHSearchHouseItemModel *model = (FHSearchHouseItemModel *)data;
    self.houseVideoImageView.hidden = !model.houseVideo.hasVideo;
    FHImageModel *imageModel = model.images.firstObject;
    [self updateMainImageWithUrl:imageModel.url];
    self.priceLabel.font = [UIFont themeFontDINAlternateBold:[UIDevice btd_isScreenWidthLarge320] ? 16 : 15];
    self.pricePerSqmLabel.attributedText = [[NSMutableAttributedString alloc] initWithString:@" " attributes:@{}];
    self.mainTitleLabel.text = model.displayTitle;
    self.subTitleLabel.text = model.displaySubtitle;
    self.tagLabel.textColor = [UIColor themeGray2];
    self.tagLabel.text = model.displayStatsInfo;
    self.priceLabel.text = model.displayPrice;
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

@end
