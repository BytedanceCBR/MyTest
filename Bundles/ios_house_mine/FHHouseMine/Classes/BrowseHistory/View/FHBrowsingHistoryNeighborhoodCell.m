//
//  FHBrowsingHistoryNeighborhoodCell.m
//  FHHouseMine
//
//  Created by xubinbin on 2020/11/4.
//

#import "FHBrowsingHistoryNeighborhoodCell.h"

@interface FHBrowsingHistoryNeighborhoodCell()

@property (nonatomic, strong) UIView *opView; //蒙层
@property (nonatomic, strong) UILabel *offShelfLabel; //下架

@end

@implementation FHBrowsingHistoryNeighborhoodCell

@synthesize mainImageView = _mainImageView;

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
    self.houseMainImageBackView.backgroundColor = [UIColor whiteColor];
    [self.houseMainImageBackView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.mainImageView).offset(3);
        make.left.mas_equalTo(self.mainImageView).offset(3);
        make.right.mas_equalTo(self.mainImageView).offset(-3);
        make.bottom.mas_equalTo(self.mainImageView).offset(-3);
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
    self.opView.hidden = (model.houseStatus.integerValue == 0) ? YES : NO;
    self.offShelfLabel.hidden = (model.houseStatus.integerValue == 0) ? YES : NO;
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
