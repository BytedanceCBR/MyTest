//
//  FHNewHouseDetailRelatedCell.m
//  FHHouseDetail
//
//  Created by xubinbin on 2020/9/9.
//

#import "FHNewHouseDetailRelatedCollectionCell.h"
#import <FHHouseBase/FHHouseBaseItemCell.h>
#import "FHDetailRelatedCourtModel.h"
#import <FHHouseBase/FHHouseListBaseItemCell.h>
#import <lottie-ios/Lottie/LOTAnimationView.h>
#import <YYText/YYLabel.h>
#import <BDWebImage/UIImageView+BDWebImage.h>

@interface FHNewHouseDetailRelatedCollectionCell()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, weak) UIImageView *shadowImage;
@property (nonatomic, strong)   UIView       *containerView;
@property (nonatomic, weak)   UITableView       *tableView;

@property (nonatomic, strong , nullable) NSArray<FHHouseListBaseItemModel *> *items;

@property (nonatomic, strong) UILabel *totalPrice;
@property (nonatomic, strong) UILabel *unitPrice;
@property (nonatomic, strong) UIView *houseMainImageBackView;
@property (nonatomic, strong) UIImageView *mainIma;
@property (nonatomic, strong) LOTAnimationView *vrLoadingView;
@property (nonatomic, strong) UILabel *maintitle;
@property (nonatomic, strong) UILabel *positionInformation;
@property (nonatomic, strong) YYLabel *tagInformation;
@property (nonatomic, weak) UIImageView *houseVideoImageView;

@end

@implementation FHNewHouseDetailRelatedCollectionCell

+ (CGSize)cellSizeWithData:(id)data width:(CGFloat)width {
    if (data && [data isKindOfClass:[FHHouseListBaseItemModel class]]) {
        return CGSizeMake(width, 104);
    }
    return CGSizeZero;
}

+ (UIImage *)placeholderImage {
    static UIImage *placeholderImage = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        placeholderImage = [UIImage imageNamed: @"default_image"];
    });
    return placeholderImage;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI
{
    UILabel *unitPrice = [[UILabel alloc]init];
    unitPrice.font = [UIFont themeFontRegular:12];
    unitPrice.textColor = [UIColor themeGray1];
    [self.contentView addSubview:unitPrice];
    _unitPrice = unitPrice;
    self.unitPrice.font = [UIFont themeFontMedium:16];
    self.unitPrice.textColor = [UIColor themeOrange1];
    
    UIView *houseMainImageBackView = [[UIView alloc] init];
    CALayer * layer = houseMainImageBackView.layer;
    layer.shadowOffset = CGSizeMake(0, 4);
    layer.shadowRadius = 6;
    layer.shadowColor = [UIColor blackColor].CGColor;;
    layer.shadowOpacity = 0.2;
    [self.contentView addSubview:houseMainImageBackView];
    _houseMainImageBackView = houseMainImageBackView;
    [self.houseMainImageBackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.mainIma);
        make.left.top.equalTo(self.mainIma);
        make.size.mas_equalTo(CGSizeMake(107, 81));
    }];
    
    UIImageView *mainIma = [[UIImageView alloc]init];
    mainIma.layer.cornerRadius = 4;
    mainIma.layer.masksToBounds = YES;
    [self.contentView addSubview:mainIma];
    _mainIma = mainIma;
    [self.mainIma mas_makeConstraints:^(MASConstraintMaker *make) {
         make.top.mas_equalTo(0);
         make.left.equalTo(self.contentView).offset(15);
         make.size.mas_equalTo(CGSizeMake(106, 80));
     }];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"VRImageLoading" ofType:@"json"];
    LOTAnimationView *vrLoadingView = [LOTAnimationView animationWithFilePath:path];
    vrLoadingView.loopAnimation = YES;
    [self.contentView addSubview:vrLoadingView];
    _vrLoadingView = vrLoadingView;
    [self.vrLoadingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mainIma).offset(12);
        make.bottom.equalTo(self.mainIma).offset(-10);
        make.size.mas_equalTo(CGSizeMake(16, 16));
    }];
    
    UILabel *maintitle = [[UILabel alloc]init];
    maintitle.font = [UIFont themeFontSemibold:18];
    maintitle.textColor = [UIColor themeGray1];
    [self.contentView addSubview:maintitle];
    _maintitle = maintitle;
    [self.maintitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mainIma.mas_right).offset(12);
        make.top.equalTo(self.mainIma);
        make.right.equalTo(self.contentView).offset(-15);
        make.height.mas_equalTo(20);
    }];
    
    [self.unitPrice mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.maintitle);
        make.right.equalTo(self.contentView).offset(-15);
        make.top.equalTo(self.maintitle.mas_bottom);
    }];
    
    UILabel *positionInformation = [[UILabel alloc]init];
    positionInformation.font = [UIFont themeFontRegular:12];
    positionInformation.textColor = [UIColor themeGray1];
    [self.contentView addSubview:positionInformation];
    _positionInformation = positionInformation;
    [self.positionInformation mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.maintitle);
        make.top.equalTo(self.unitPrice.mas_bottom);
        make.right.equalTo(self.contentView).offset(-15);
    }];
    
    YYLabel *tagInformation = [[YYLabel alloc]init];
    tagInformation.font = [UIFont themeFontRegular:12];
    tagInformation.textColor = [UIColor themeOrange1];
    [self.contentView addSubview:tagInformation];
    _tagInformation = tagInformation;
    [self.tagInformation mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.maintitle);
        make.top.equalTo(self.positionInformation.mas_bottom).offset(5);
        make.right.equalTo(self.contentView).offset(-15);
    }];
}

- (void)refreshWithData:(id)data {
    self.currentData = data;
    if([data isKindOfClass:[FHHouseListBaseItemModel class]]){
        FHHouseListBaseItemModel *model = (FHHouseListBaseItemModel *)data;
        FHImageModel *imageModel = model.houseImage.firstObject;
        [self.mainIma bd_setImageWithURL:[NSURL URLWithString:imageModel.url] placeholder:[[self class] placeholderImage]];
        self.maintitle.text = model.title;
        self.positionInformation.text = model.displaySubtitle;
        if (model.originPrice) {
            self.unitPrice.attributedText = [self originPriceAttr:model.originPrice];
        }else{
            self.unitPrice.attributedText = [[NSMutableAttributedString alloc]initWithString:model.displayPricePerSqm attributes:@{}];
        }
        
        self.totalPrice.text = model.displayPrice;
        self.houseVideoImageView.hidden = !model.houseVideo.hasVideo;
        if (model.reasonTags.count>0) {
            self.tagInformation.attributedText = model.recommendReasonStr;
        }else {
            self.tagInformation.attributedText = model.tagString;
        }
        [self updateContentWithModel:model];
        if (model.vrInfo.hasVr) {
            self.houseVideoImageView.hidden = YES;
            self.vrLoadingView.hidden = NO;
            [self.vrLoadingView play];
        }else {
            self.vrLoadingView.hidden = YES;
            [self.vrLoadingView stop];
        }

    };
}

- (void)updateContentWithModel:(FHHouseListBaseItemModel *)model {
    switch (model.houseType ) {
        case FHHouseTypeRentHouse:
            self.tagInformation.text = model.addrData;
            self.tagInformation.font = [UIFont themeFontRegular:12];
            [self.tagInformation setTextColor:[UIColor themeGray2]];
            break;
        case FHHouseTypeNeighborhood:
            self.tagInformation.text = model.salesInfo;
            self.tagInformation.font = [UIFont themeFontRegular:12];
            [self.tagInformation setTextColor:[UIColor themeGray2]];
        case FHHouseTypeNewHouse:

        default:
            break;
    }
}

#pragma mark 字符串处理
- (NSAttributedString *)originPriceAttr:(NSString *)originPrice {
    if (originPrice.length < 1) {
        return nil;
    }
    NSMutableAttributedString *attri = [[NSMutableAttributedString alloc] initWithString:originPrice];
    [attri addAttribute:NSStrikethroughStyleAttributeName value:@(NSUnderlineStyleSingle) range:NSMakeRange(0, originPrice.length)];
    [attri addAttribute:NSStrikethroughColorAttributeName value:[UIColor themeGray1] range:NSMakeRange(0, originPrice.length)];
    return attri;
}

- (UIImageView *)houseVideoImageView
{
    if (!_houseVideoImageView) {
        UIImageView *houseVideoImageView = [[UIImageView alloc]init];
        houseVideoImageView.image = [UIImage imageNamed:@"icon_list_house_video"];
        houseVideoImageView.backgroundColor = [UIColor clearColor];
        houseVideoImageView.hidden = YES;
        [self.contentView addSubview:houseVideoImageView];
        _houseVideoImageView = houseVideoImageView;
    }
    return _houseVideoImageView;
}

- (NSString *)elementTypeString:(FHHouseType)houseType {
    return @"related";// 周边房源
}

@end

@implementation FHNewHouseDetailTRelatedCollectionCellModel

@end
