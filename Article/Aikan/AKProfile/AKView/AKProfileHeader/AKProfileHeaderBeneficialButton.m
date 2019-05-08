//
//  AKProfileHeaderBeneficialButton.m
//  Article
//
//  Created by chenjiesheng on 2018/3/6.
//

#import "AKProfileBenefitModel.h"
#import "AKProfileBenefitReddotView.h"
#import "AKProfileHeaderBeneficialButton.h"
#import <UIColor+TTThemeExtension.h>

#define kPaddingTopDesLabel             8

@interface AKProfileHeaderBeneficialButton ()

@property (nonatomic, strong)UILabel                                     *digitLabel;
@property (nonatomic, strong)UILabel                                     *desLabel;
@property (nonatomic, strong)UIView                                      *labelContainerView;
@property (nonatomic, strong)UILabel                                     *addLabel;
@property (nonatomic, strong, readwrite)AKProfileBenefitModel            *model;
@property (nonatomic, copy,   readwrite)NSString                         *benefitType;
@property (nonatomic, strong)AKProfileBenefitReddotView                  *reddotView;
@end

@implementation AKProfileHeaderBeneficialButton

+ (instancetype)buttonWithBeneficialButtonType:(NSString *)type
{
    AKProfileHeaderBeneficialButton *btn = [[AKProfileHeaderBeneficialButton alloc] init];
    btn.benefitType = type;
    return btn;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self createComponent];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    //偏移的1、2等数据都属于微调
    self.labelContainerView.width = self.width;
    self.labelContainerView.left = 0;
    self.labelContainerView.centerY = self.height / 2;
    self.desLabel.width = self.width;
    self.digitLabel.top = 0;
    self.digitLabel.centerX = self.width / 2;
    self.addLabel.left = self.digitLabel.right + 1;
    self.addLabel.centerY = self.digitLabel.top + 3.f;
    self.desLabel.top = self.digitLabel.bottom + kPaddingTopDesLabel;
    self.desLabel.centerX = self.width / 2;
    self.reddotView.centerY = self.digitLabel.centerY;
    self.reddotView.left = self.digitLabel.right + 2.f;
    if (!isEmptyString(self.addLabel.text)) {
        self.reddotView.left = self.digitLabel.right + 7.f;
    }
    if (self.reddotView.reddotType == AKProfileBenefitReddotViewTypeSimple) {
        self.reddotView.top = self.digitLabel.top + 2;
        if (!isEmptyString(self.addLabel.text)) {
            self.reddotView.left = self.digitLabel.right + 12.f;
        }
    }
//    [self.reddotView checkFixIfNeedAdjustLabelWidth];
}

- (void)createComponent
{
    _digitLabel = ({
        UILabel *label = [[UILabel alloc] init];
        label.textColor = [UIColor colorWithHexString:@"222222"];
        label.font = [UIFont boldSystemFontOfSize:[TTDeviceUIUtils tt_newFontSize:18.f]];
        label.text = @"0";
        label.textAlignment = NSTextAlignmentCenter;
        label.adjustsFontSizeToFitWidth = YES;
        [label sizeToFit];
        label;
    });
    
    _addLabel = ({
        UILabel *label = [[UILabel alloc] init];
        label.textColor = [UIColor colorWithHexString:@"000000"];
        label.font = [UIFont boldSystemFontOfSize:[TTDeviceUIUtils tt_newFontSize:12.f]];
        label.textAlignment = NSTextAlignmentCenter;
        label.adjustsFontSizeToFitWidth = YES;
        [label sizeToFit];
        label;
    });
    
    _desLabel = ({
        UILabel *label = [[UILabel alloc] init];
        label.textColor = [UIColor colorWithHexString:@"999999"];
        label.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_newFontSize:13.f]];
        label.text = @"金币收益";
        label.textAlignment = NSTextAlignmentCenter;
        label.adjustsFontSizeToFitWidth = YES;
        [label sizeToFit];
        label;
    });
    
    _reddotView = ({
        AKProfileBenefitReddotView *view = [[AKProfileBenefitReddotView alloc] init];
        view.hidden = YES;
        view.userInteractionEnabled = NO;
        view;
    });

    _labelContainerView = ({
        UIView *view = [[UIView alloc] init];
        view.backgroundColor = [UIColor clearColor];
        view.userInteractionEnabled = NO;
        view;
    });
    
    [_labelContainerView addSubview:_desLabel];
    [_labelContainerView addSubview:_digitLabel];
    [_labelContainerView addSubview:_addLabel];
    [_labelContainerView addSubview:_reddotView];
    _labelContainerView.height = _desLabel.height + _digitLabel.height + kPaddingTopDesLabel;
    [self addSubview:_labelContainerView];
}

- (void)setupDesLabelText:(NSString *)text
{
    self.desLabel.text = text;
    [self.desLabel sizeToFit];
    [self setNeedsLayout];
}

- (void)setupDigitLabelTextWithText:(NSString *)text
{
    if ([text rangeOfString:@"+"].location != NSNotFound) {
        text = [text stringByReplacingOccurrencesOfString:@"+" withString:@""];
        self.addLabel.text = @"+";
        [self.addLabel sizeToFit];
    } else {
        self.addLabel.text = nil;
        self.addLabel.width = 0;
    }
    self.digitLabel.text = text;
    [self.digitLabel sizeToFit];
    [self setNeedsLayout];
}

- (void)refreshContentWithModel:(AKProfileBenefitModel *)model
{
    _model = model;
    self.benefitType = model.type;
    [self setupDigitLabelTextWithText:model.digit];
    [self setupDesLabelText:model.benefitName];
    [self refreshReddotWithModel:model];
}

- (void)refreshReddotWithModel:(AKProfileBenefitModel *)model
{
    AKProfileBenefitReddotInfo *reddotInfo = model.reddotInfo;
    if (reddotInfo) {
        [self.reddotView refreshContentWithInfo:reddotInfo];
    }
    self.reddotView.hidden = !reddotInfo.needShow.boolValue;
    [self setNeedsLayout];
}

@end
