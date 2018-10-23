//
//  AKTaskSettingSwitchTableViewCell.m
//  Article
//
//  Created by chenjiesheng on 2018/3/1.
//

#import <TTDeviceUIUtils.h>
#import <UIColor+TTThemeExtension.h>

#import "AKTaskSettingDefine.h"
#import "AKTaskSettingCellModel.h"
#import "AKTaskSettingSwitchTableViewCell.h"

@interface AKTaskSettingSwitchTableViewCell ()

@property (nonatomic, strong)UIView         *operationRegion;
@property (nonatomic, strong)UIView         *descRegion;
@property (nonatomic, strong)UISwitch       *switchButton;
@property (nonatomic, strong)UIView         *regionSeparateLine;
@property (nonatomic, strong)UILabel        *descRegionTitleLabel;
@property (nonatomic, strong)UILabel        *operationRegionTitleLabel;
@property (nonatomic, strong)UIImageView    *descRegionImageView;

@property (nonatomic, strong)AKTaskSettingCellModel             *cellModel;

@property (nonatomic, strong)UIView         *cellSeparateView;

@end

@implementation AKTaskSettingSwitchTableViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self createComponent];
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self createComponent];
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.operationRegion.frame = CGRectMake(kAKPaddingLeftContent, 0, self.width - kAKPaddingRightContent - kAKPaddingLeftContent, kAKHeightOperationView);
    self.switchButton.centerY = self.operationRegion.height / 2;
    self.switchButton.right = self.operationRegion.width;
    self.operationRegionTitleLabel.width =  self.switchButton.left - 15; //15为间距
    self.operationRegionTitleLabel.height = self.cellModel.layoutModel.heightOperationRegionTitle;
    self.operationRegionTitleLabel.left = 0;
    self.operationRegionTitleLabel.centerY = self.operationRegion.height / 2;
    
    self.regionSeparateLine.width = self.operationRegion.width;
    self.regionSeparateLine.centerX = self.width / 2;
    self.regionSeparateLine.top = self.operationRegion.bottom;
    
    self.descRegion.frame = CGRectMake(kAKPaddingLeftContent, self.regionSeparateLine.bottom, self.operationRegion.width, self.cellSeparateView.top - self.regionSeparateLine.bottom);
    
    self.descRegionTitleLabel.width = self.descRegion.width;
    self.descRegionTitleLabel.height = self.cellModel.layoutModel.heightDesRegionTitle;
    self.descRegionTitleLabel.left = 0;
    self.descRegionTitleLabel.top = kAKPaddingTopDesRegionComponent;
    self.descRegionImageView.size = self.cellModel.layoutModel.sizeDesRegionImage;
    self.descRegionImageView.left = 0;
    self.descRegionImageView.top = self.descRegionTitleLabel.bottom + kAKPaddingTopDesRegionComponent;
    
}

- (void)createComponent
{
    [self createOperationRegionComponent];
    [self createDesRegionComponent];
    
    [self createOtherComponent];
}

- (void)createOtherComponent
{
    UIView *line = [[UIView alloc] initWithFrame:CGRectZero];
    line.backgroundColor = [UIColor colorWithHexString:@"E9E9E9"];
    line.height = .5;
    [self.contentView addSubview:line];
    self.regionSeparateLine = line;
    
    UIView *separateView = [[UIView alloc] initWithFrame:CGRectMake(0, self.height - kAKHeightSeparateView, self.width, kAKHeightSeparateView)];
    separateView.backgroundColor = [UIColor colorWithHexString:@"F4F5F6"];
    separateView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    [self addSubview:separateView];
    self.cellSeparateView = separateView;
}

- (void)createOperationRegionComponent
{
    UIView *containerView = [[UIView alloc] init];
    containerView.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:containerView];
    self.operationRegion = containerView;
    
    UILabel *label = [[UILabel alloc] init];
    label.textColor = [UIColor blackColor];
    label.font = [UIFont systemFontOfSize:kAKFontOperationRegionTitle];
    [containerView addSubview:label];
    self.operationRegionTitleLabel = label;
    
    UISwitch *switchButton = [[UISwitch alloc] initWithFrame:CGRectZero];
    switchButton.transform = CGAffineTransformMakeScale(40 / switchButton.width, 40 / switchButton.width);
    switchButton.onTintColor = [UIColor colorWithHexString:@"FA6058"];
    [switchButton addTarget:self action:@selector(switchButtonClicked:) forControlEvents:UIControlEventValueChanged];
    [containerView addSubview:switchButton];
    self.switchButton = switchButton;
}

- (void)createDesRegionComponent
{
    UIView *containerView = [[UIView alloc] init];
    containerView.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:containerView];
    self.descRegion = containerView;
    
    UILabel *label = [[UILabel alloc] init];
    label.textColor = [UIColor colorWithHexString:@"666666"];
    label.font = [UIFont systemFontOfSize:kAKFontDesRegionTitle];
    [containerView addSubview:label];
    self.descRegionTitleLabel = label;
    
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    [containerView addSubview:imageView];
    self.descRegionImageView = imageView;
}

#pragma public

- (void)setupContentWith:(AKTaskSettingCellModel *)cellModel
{
    self.cellModel = cellModel;
    self.operationRegionTitleLabel.text = cellModel.operationRegionTitle;
    self.descRegionTitleLabel.text = cellModel.desRegionTitle;
    self.descRegionImageView.image = [UIImage imageNamed:cellModel.desImageName];
    self.cellSeparateView.hidden = !cellModel.layoutModel.showBottomSeparateLine;
    [self.switchButton setOn:cellModel.enable];
    [self setNeedsLayout];
}

#pragma action

- (void)switchButtonClicked:(UISwitch *)switchButton
{
    if (self.switchButtonClickBlock) {
        self.switchButtonClickBlock(self.cellModel,self.switchButton);
    }
}

@end
