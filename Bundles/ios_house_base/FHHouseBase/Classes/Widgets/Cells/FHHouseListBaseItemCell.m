//
//  FHHouseListBaseItemCell.m
//  FHHouseBase
//
//  Created by liuyu on 2020/3/5.
//

#import "FHHouseListBaseItemCell.h"
#import <FHCommonUI/UIColor+Theme.h>
#import <FHCommonUI/UIFont+House.h>
#import <YYText/YYLabel.h>
#import "Masonry.h"
#import "FHImageModel.h"
#import <BDWebImage/UIImageView+BDWebImage.h>
#import "FHHouseListBaseItemModel.h"
#import <lottie-ios/Lottie/LOTAnimationView.h>
#import "FHDetailCommonDefine.h"
@interface FHHouseListBaseItemCell()
@property (nonatomic, weak) UIImageView *mainIma;
@property (nonatomic, weak) UIImageView *mainImaShadow;
@property (nonatomic, weak) UILabel *maintitle;
@property (nonatomic, weak) UILabel *positionInformation;
@property (nonatomic, weak) UILabel *unitPrice;
@property (nonatomic, weak) UILabel *totalPrice;
@property (nonatomic, weak) YYLabel *tagInformation;
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
        if ([self.reuseIdentifier isEqualToString:@"FHNewHouseCell"] ) {
              [self initNewHouseUI];
          }else {
              [self initUI];
          }
        
//        [self initUI];
    }
    return self;
}

- (void)initNewHouseUI
{
    self.totalPrice.hidden = YES;
    self.unitPrice.font = [UIFont themeFontMedium:16];
    self.unitPrice.textColor = [UIColor themeOrange1];
    [self.houseMainImageBackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.mainIma);
        make.left.top.equalTo(self.mainIma);
        make.size.mas_equalTo(CGSizeMake(107, 81));
    }];
    [self.mainIma mas_makeConstraints:^(MASConstraintMaker *make) {
         make.centerY.equalTo(self.contentView);
         make.left.equalTo(self.contentView).offset(15);
         make.size.mas_equalTo(CGSizeMake(106, 80));
     }];
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
    [self.positionInformation mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.maintitle);
        make.top.equalTo(self.unitPrice.mas_bottom);
        make.right.equalTo(self.contentView).offset(-15);
    }];
    [self.tagInformation mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.maintitle);
        make.top.equalTo(self.positionInformation.mas_bottom).offset(5);
        make.right.equalTo(self.contentView).offset(-15);
    }];
}

- (void)initUI {
    [self.houseMainImageBackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.mainIma);
        make.left.top.equalTo(self.mainIma);
        make.bottom.equalTo(self.mainIma).offset(-1);
        make.right.equalTo(self.mainIma).offset(-1);
    }];
    [self.mainIma mas_makeConstraints:^(MASConstraintMaker *make) {
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
        make.top.equalTo(self.mainIma).offset(-2);
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
        make.top.equalTo(self.positionInformation.mas_bottom).offset(7);
    }];
    [self.totalPrice mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.unitPrice.mas_right);
        make.top.equalTo(self.unitPrice.mas_bottom).offset(4);
    }];
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

-(YYLabel *)tagInformation
{
    if (!_tagInformation) {
        YYLabel *tagInformation = [[YYLabel alloc]init];
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
        if (model.originPrice) {
            self.unitPrice.attributedText = [self originPriceAttr:model.originPrice];
        }else{
            self.unitPrice.attributedText = [[NSMutableAttributedString alloc]initWithString:model.displayPricePerSqm attributes:@{}];
        }
        
        self.totalPrice.text = model.displayPrice;
        self.houseVideoImageView.hidden = !model.houseVideo.hasVideo;
        if (model.reasonTags.count>0) {
            self.tagInformation.attributedText = model.recommendReasons;
        }else {
            self.tagInformation.attributedText = model.tagString;
        }
        [self updateContentWithModel:model];
        if (model.vrInfo.hasVr) {
            self.houseVideoImageView.hidden = YES;
            [self.vrLoadingView play];
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
-(NSAttributedString *)originPriceAttr:(NSString *)originPrice {
    
    if (originPrice.length < 1) {
        return nil;
    }
    NSMutableAttributedString *attri = [[NSMutableAttributedString alloc] initWithString:originPrice];
    [attri addAttribute:NSStrikethroughStyleAttributeName value:@(NSUnderlineStyleSingle) range:NSMakeRange(0, originPrice.length)];
    [attri addAttribute:NSStrikethroughColorAttributeName value:[UIColor themeGray1] range:NSMakeRange(0, originPrice.length)];
    return attri;
}

@end
