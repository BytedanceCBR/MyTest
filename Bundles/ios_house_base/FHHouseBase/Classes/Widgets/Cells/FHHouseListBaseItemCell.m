//
//  FHHouseListBaseItemCell.m
//  FHHouseBase
//
//  Created by liuyu on 2020/3/5.
//

#import "FHHouseListBaseItemCell.h"
#import <FHCommonUI/UIColor+Theme.h>
#import <FHCommonUI/UIFont+House.h>
#import "Masonry.h"
#import "FHImageModel.h"
#import <BDWebImage/UIImageView+BDWebImage.h>
#import "FHHouseListBaseItemModel.h"
#import <lottie-ios/Lottie/LOTAnimationView.h>
@interface FHHouseListBaseItemCell()
@property (nonatomic, weak) UIImageView *mainIma;
@property (nonatomic, weak) UIImageView *mainImaShadow;
@property (nonatomic, weak) UILabel *maintitle;
@property (nonatomic, weak) UILabel *positionInformation;
@property (nonatomic, weak) UILabel *unitPrice;
@property (nonatomic, weak) UILabel *totalPrice;
@property (nonatomic, weak) UILabel *tagInformation;
@property (nonatomic, weak) UIView *houseMainImageBackView;
@property(nonatomic, weak) UIImageView *houseVideoImageView;
@property (nonatomic, weak) LOTAnimationView *vrLoadingView;

@property (nonatomic, copy) NSString *reuseIdentifier;
@end
@implementation FHHouseListBaseItemCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.reuseIdentifier = reuseIdentifier;
        [self initUI];
    }
    return self;
}

- (void)initUI {
    [self.houseMainImageBackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.left.equalTo(self.contentView).offset(16);
        make.size.mas_equalTo(CGSizeMake(83, 62));
    }];
    [self.mainIma mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
         make.top.equalTo(self.contentView).offset(10);
        make.left.equalTo(self.contentView).offset(15);
        make.size.mas_equalTo(CGSizeMake(85, 64));
    }];
    [self.houseVideoImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mainIma).offset(12);
        make.bottom.equalTo(self.mainIma).offset(-10);
        make.size.mas_equalTo(CGSizeMake(16, 16));
    }];
    [self.vrLoadingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mainIma).offset(12);
        make.bottom.equalTo(self.mainIma).offset(-10);
        make.size.mas_equalTo(CGSizeMake(16, 16));
    }];
    [self.maintitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mainIma.mas_right).offset(12);
        make.top.equalTo(self.mainIma);
        make.right.equalTo(self.contentView).offset(-15);
    }];
    [self.positionInformation mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.maintitle);
        make.top.equalTo(self.maintitle.mas_bottom).offset(2);
//         make.right.lessThanOrEqualTo(self.unitPrice.mas_left).offset(-10);
    }];

    [self.unitPrice mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_greaterThanOrEqualTo(self.positionInformation.mas_right).offset(10);
        make.top.equalTo(self.positionInformation);
        make.right.equalTo(self.contentView).offset(-15);
    }];
//    [self.unitPrice setContentHuggingPriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
//    [self.positionInformation setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
    [self.unitPrice setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [self.unitPrice setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [self.tagInformation mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.maintitle);
        make.top.equalTo(self.positionInformation.mas_bottom).offset(8);
    }];
    [self.totalPrice mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.unitPrice.mas_right);
        make.top.equalTo(self.unitPrice.mas_bottom).offset(5);
    }];
    if ([self.reuseIdentifier isEqualToString:@"FHNewHouseCell"] || [self.reuseIdentifier isEqualToString:@"FHHouseListBaseItemModel"]) {
            [self updateConstraintsWithNewHouse];
    }    
}
#pragma mark ---------------------- UIInit:初始化控件

+ (UIImage *)placeholderImage {
    static UIImage *placeholderImage = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        placeholderImage = [UIImage imageNamed: @"default_image"];
    });
    return placeholderImage;
}

-(UILabel *)maintitle
{
    if (!_maintitle) {
        UILabel *maintitle = [[UILabel alloc]init];
        maintitle.font = [UIFont themeFontSemibold:18];
        maintitle.textColor = [UIColor themeGray1];
        [self.contentView addSubview:maintitle];
        _maintitle = maintitle;
    }
    return _maintitle;
}

-(UILabel *)positionInformation
{
    if (!_positionInformation) {
        UILabel *positionInformation = [[UILabel alloc]init];
        positionInformation.font = [UIFont themeFontRegular:12];
        positionInformation.textColor = [UIColor themeGray1];
        [self.contentView addSubview:positionInformation];
        _positionInformation = positionInformation;
    }
    return _positionInformation;
}

-(UILabel *)unitPrice
{
    if (!_unitPrice) {
        UILabel *unitPrice = [[UILabel alloc]init];
        unitPrice.font = [UIFont themeFontRegular:12];
        unitPrice.textColor = [UIColor themeGray1];
        [self.contentView addSubview:unitPrice];
        _unitPrice = unitPrice;
    }
    return _unitPrice;
}

-(UILabel *)totalPrice
{
    if (!_totalPrice) {
        UILabel *totalPrice = [[UILabel alloc]init];
        totalPrice.font = [UIFont themeFontMedium:16];
        totalPrice.textColor = [UIColor themeOrange1];
//        totalPrice.backgroundColor = [UIColor redColor];
        [self.contentView addSubview:totalPrice];
        _totalPrice = totalPrice;
    }
    return _totalPrice;
}

-(UILabel *)tagInformation
{
    if (!_tagInformation) {
        UILabel *tagInformation = [[UILabel alloc]init];
        tagInformation.font = [UIFont themeFontRegular:12];
        tagInformation.textColor = [UIColor themeOrange1];
        [self.contentView addSubview:tagInformation];
        _tagInformation = tagInformation;
    }
    return _tagInformation;
}

- (UIImageView *)mainIma {
    if (!_mainIma) {
        UIImageView *mainIma = [[UIImageView alloc]init];
        mainIma.layer.cornerRadius = 4;
        mainIma.layer.masksToBounds = YES;
        [self.contentView addSubview:mainIma];
        _mainIma = mainIma;
    }
    return _mainIma;
}

-(UIView *)houseMainImageBackView
{
    if (!_houseMainImageBackView) {
        UIView *houseMainImageBackView = [[UIView alloc] init];
        houseMainImageBackView.backgroundColor = [UIColor whiteColor];
        CALayer * layer = houseMainImageBackView.layer;
        layer.shadowOffset = CGSizeMake(0, 4);
        layer.shadowRadius = 6;
        layer.shadowColor = [UIColor blackColor].CGColor;;
        layer.shadowOpacity = 0.2;
        [self.contentView addSubview:houseMainImageBackView];
        _houseMainImageBackView = houseMainImageBackView;
    }
    return _houseMainImageBackView;
}

- (UIImageView *)mainImaShadow {
    if (!_mainImaShadow) {
        UIImageView *mainImaShadow = [[UIImageView alloc]init];
        [self.contentView addSubview:mainImaShadow];
        _mainImaShadow = mainImaShadow;
    }
    return _mainImaShadow;
}

-(UIImageView *)houseVideoImageView
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

-(LOTAnimationView *)vrLoadingView
{
    if (!_vrLoadingView) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"VRImageLoading" ofType:@"json"];
        LOTAnimationView *vrLoadingView = [LOTAnimationView animationWithFilePath:path];
        vrLoadingView.loopAnimation = YES;
        [self.contentView addSubview:vrLoadingView];
        _vrLoadingView = vrLoadingView;
    }
    return _vrLoadingView;
}
#pragma mark ----新房UI单独处理
- (void)updateConstraintsWithNewHouse {
    self.totalPrice.hidden = YES;
    self.unitPrice.font = [UIFont themeFontMedium:16];
    self.unitPrice.textColor = [UIColor themeOrange1];
    [self.houseMainImageBackView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.left.equalTo(self.contentView).offset(16);
        make.size.mas_equalTo(CGSizeMake(105, 79));
    }];
    [self.mainIma mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.top.equalTo(self.contentView).offset(10);
        make.left.equalTo(self.contentView).offset(15);
        make.size.mas_equalTo(CGSizeMake(106, 80));
    }];
    [self.unitPrice mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.maintitle);
        make.right.equalTo(self.contentView).offset(-15);
        make.top.equalTo(self.maintitle.mas_bottom).offset(1);
    }];
    [self.positionInformation mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.maintitle);
            make.top.equalTo(self.unitPrice.mas_bottom).offset(1);
            make.right.equalTo(self.contentView).offset(-15);
        }];
}
#pragma mark ---------------------- dataPross:数据加载
- (void)refreshWithData:(id)data {
    self.currentData = data;
//    if ([data isKindOfClass:[FHSingleImageInfoCellModel class]] ) {
//        [self updateWithHouseCellModel:data];
    if([data isKindOfClass:[FHHouseListBaseItemModel class]]){
        FHHouseListBaseItemModel *model = (FHHouseListBaseItemModel *)data;
        FHImageModel *imageModel = model.houseImage.firstObject;
        [self.mainIma bd_setImageWithURL:[NSURL URLWithString:imageModel.url] placeholder:[FHHouseListBaseItemCell placeholderImage]];
        self.maintitle.text = model.title;
        self.positionInformation.text = model.displaySubtitle;
        self.unitPrice.text = model.displayPricePerSqm;
        self.totalPrice.text = model.displayPrice;
        self.houseVideoImageView.hidden = !model.houseVideo.hasVideo;
        if (model.reasonTags.count>0) {
            [self.tagInformation setAttributedText:model.recommendReasons];
        }else {
           [self.tagInformation setAttributedText:model.tagString];
        }
        if (model.houseType == FHHouseTypeRentHouse) {
             [self.tagInformation setText:model.addrData];
            [self.tagInformation setTextColor:[UIColor themeGray2]];
        }
         
        if (model.vrInfo.hasVr) {
            self.houseVideoImageView.hidden = YES;
             [self.vrLoadingView play];
        }
//        self.tagInformation.attributedText = [[NSAttributedString alloc]initWithString:@"11111" attributes:@{ NSFontAttributeName:[UIFont themeFontRegular:12] ,
//        NSForegroundColorAttributeName:self.totalPrice.textColor?self.totalPrice:[UIColor themeOrange1]}];;
//        [self.vrLoadingView play];
//        if ([model.status integerValue] == 1 && model.isMsgCell) {
//            self.maintitle.textColor = [UIColor themeGray3];
//            self.totalPrice.textColor = [UIColor themeGray3];
//        }else {
//            self.maintitle.textColor = [UIColor themeGray1];
//            self.totalPrice.textColor = [UIColor themeRed1];
//        }
    };
}

-(void)updateWithHouseCellModel:(FHSingleImageInfoCellModel *)cellModel
{
    switch (cellModel.houseType) {
        case FHHouseTypeNewHouse:
            break;
        case FHHouseTypeSecondHandHouse:
            [self updateWithSecondHouseModel:cellModel.secondModel];
            break;
        case FHHouseTypeRentHouse:
            break;
        case FHHouseTypeNeighborhood:
          
            break;
        default:
            break;
    }
}
-(void)updateWithSecondHouseModel:(id)data
{
if([data isKindOfClass:[FHHouseListBaseItemModel class]]){
    FHHouseListBaseItemModel *model = (FHHouseListBaseItemModel *)data;
    FHImageModel *imageModel = model.houseImage.firstObject;
    [self.mainIma bd_setImageWithURL:[NSURL URLWithString:imageModel.url] placeholder:[FHHouseListBaseItemCell placeholderImage]];
    self.maintitle.text = model.title;
    self.positionInformation.text = model.displaySubtitle;
    self.unitPrice.text = model.displayPricePerSqm;
    self.totalPrice.text = model.displayPrice;

};
}
@end
