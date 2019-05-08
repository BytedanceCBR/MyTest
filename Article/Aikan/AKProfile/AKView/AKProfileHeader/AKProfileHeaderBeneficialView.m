//
//  AKProfileHeaderBeneficialView.m
//  Article
//
//  Created by chenjiesheng on 2018/3/6.
//

#import "AKProfileBenefitModel.h"
#import "AKProfileHeaderViewDefine.h"
#import "AKProfileHeaderBeneficialView.h"
#import "AKProfileHeaderBeneficialButton.h"
@interface AKProfileHeaderBeneficialView ()

@property (nonatomic, copy)NSArray<AKProfileHeaderBeneficialButton *> *beneficialButtons;

@end

@implementation AKProfileHeaderBeneficialView

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
    __block NSInteger buttonCount = 0;
    [self.beneficialButtons enumerateObjectsUsingBlock:^(AKProfileHeaderBeneficialButton * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (!obj.hidden) {
            buttonCount += 1;
        }
    }];
    CGFloat buttonWidth = self.width / buttonCount;
    CGFloat buttonHeight = self.height;
    CGFloat buttonLeft = 0;
    for (AKProfileHeaderBeneficialButton *btn in self.beneficialButtons) {
        if (btn.hidden) {
            continue;
        }
        btn.frame = CGRectMake(buttonLeft, 0, buttonWidth, buttonHeight);
        buttonLeft = btn.right;
    }
}

- (void)createComponent
{
    NSArray<NSString *> *buttonTypes = [self supportButtonTypes];
    NSMutableArray *buttonArray = [NSMutableArray arrayWithCapacity:buttonTypes.count];
    for (NSString *type in buttonTypes) {
        AKProfileHeaderBeneficialButton *button = [AKProfileHeaderBeneficialButton buttonWithBeneficialButtonType:type];
        [button addTarget:self action:@selector(beneficalButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        NSString *des = [self supportButtonDesKeyMapperWithType:type];
        [button setupDesLabelText:des];
        [self addSubview:button];
        [buttonArray addObject:button];
    }
    self.beneficialButtons = [buttonArray copy];
}

- (NSArray<NSString *> *)supportButtonTypes
{
    return @[@"score",
             @"cash",
             @"apprentice",
             ];
}

- (NSString *)supportButtonDesKeyMapperWithType:(NSString *)type
{
    NSDictionary *dict = @{@"score": @"金币收益",
                           @"cash": @"现金收益",
                           @"apprentice" : @"收徒人数",
                           };
    return [dict stringValueForKey:type defaultValue:@""];
}

- (AKProfileHeaderBeneficialButton *)buttonWithType:(NSString *)type
{
    AKProfileHeaderBeneficialButton *button = nil;
    for (AKProfileHeaderBeneficialButton *btn in self.beneficialButtons) {
        if (!isEmptyString(type) && [btn.benefitType isEqualToString:type]) {
            button = btn;
            break;
        }
    }
    return button;
}

- (void)beneficalButtonClicked:(AKProfileHeaderBeneficialButton *)button
{
    if ([self.delegate respondsToSelector:@selector(beneficalButtonClickedWithModel:beneficButton:)]) {
        [self.delegate beneficalButtonClickedWithModel:button.model beneficButton:button];
    }
}

- (void)refreshBenefitInfoWithModels:(NSArray<AKProfileBenefitModel *> *)models
{
    NSMutableArray *types = [NSMutableArray arrayWithCapacity:models.count];
    [models enumerateObjectsUsingBlock:^(AKProfileBenefitModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (!isEmptyString(obj.type)) {
            [types addObject:obj.type];
        }
    }];
    [self.beneficialButtons enumerateObjectsUsingBlock:^(AKProfileHeaderBeneficialButton * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([types indexOfObject:obj.benefitType] == NSNotFound) {
            obj.hidden = YES;
        }
    }];
    [models enumerateObjectsUsingBlock:^(AKProfileBenefitModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        AKProfileHeaderBeneficialButton *button = [self buttonWithType:obj.type];
        button.hidden = NO;
        if (!button) {
            button = [AKProfileHeaderBeneficialButton buttonWithBeneficialButtonType:obj.type];
            [self addSubview:button];
            NSMutableArray *buttons = [NSMutableArray arrayWithArray:self.beneficialButtons];
            [buttons addObject:button];
        }
        [button refreshContentWithModel:obj];
    }];
    [self setNeedsLayout];
}


@end
