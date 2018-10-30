//
//  WDWendaListFooterView.m
//  Article
//
//  Created by ZhangLeonardo on 15/12/14.
//
//

#import "WDWendaListFooterView.h"
#import "WDFontDefines.h"
#import "WDUIHelper.h"

@interface WDWendaListFooterView()
@property(nonatomic, copy)WDWendaListFooterViewClickedBlock clickedBlock;
@property(nonatomic, strong)SSThemedLabel * tipLabel;
@property(nonatomic, strong)SSThemedImageView * rightArrowImgV;
@property(nonatomic, strong)SSThemedButton * bgButton;
@end

@implementation WDWendaListFooterView

- (void)dealloc
{
    self.clickedBlock = nil;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.bgButton = [SSThemedButton buttonWithType:UIButtonTypeCustom];
        _bgButton.frame = self.bounds;
        _bgButton.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [_bgButton addTarget:self action:@selector(bgButtonClicked) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_bgButton];
        
        self.backgroundColorThemeKey = kColorBackground14;
        
        CGRect tipFrame = CGRectMake(kWDCellLeftPadding, WDPadding(6), self.width - kWDCellLeftPadding - kWDCellRightPadding, 20);
        self.tipLabel = [[SSThemedLabel alloc] initWithFrame:tipFrame];
        _tipLabel.frame = tipFrame;
        _tipLabel.textColorThemeKey = kFHColorCoolGrey3;
        _tipLabel.font = [UIFont systemFontOfSize:14];
        _tipLabel.textAlignment = NSTextAlignmentLeft;
        _tipLabel.verticalAlignment = ArticleVerticalAlignmentTop;
        [self addSubview:_tipLabel];
        _tipLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        self.rightArrowImgV = [[SSThemedImageView alloc] initWithImage:[UIImage imageNamed:@"all_card_arrow"]];
        _rightArrowImgV.frame = CGRectMake(self.width - 32, _tipLabel.frame.origin.y, 18, 18);
        [self addSubview:_rightArrowImgV];
        
    }
    return self;
}

- (void)bgButtonClicked
{
    if (_clickedBlock) {
        _clickedBlock();
    }
}

- (void)setTitle:(NSString *)title isShowArrow:(BOOL)isShowArrow isNoAnswers:(BOOL)isNoAnswers clickedBlock:(WDWendaListFooterViewClickedBlock)block {
    if (isShowArrow) {
        NSMutableAttributedString *attrTitle = [[NSMutableAttributedString alloc] initWithString:title
                                                                                      attributes:@{
                                                                                                   NSFontAttributeName : [UIFont systemFontOfSize:14],
                                                                                                   NSForegroundColorAttributeName : [UIColor tt_themedColorForKey:kFHColorCoolGrey3]}];
//        NSMutableAttributedString *token = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@" %@",ask_arrow_right]
//                                                                                  attributes:@{NSBaselineOffsetAttributeName:@(1.5),
//                                                                                               NSFontAttributeName : [UIFont fontWithName:wd_iconfont size:10],
//                                                                                               NSForegroundColorAttributeName : [UIColor tt_themedColorForKey:kFHColorCoolGrey3]}
//                                            ];
//
//
//        [attrTitle appendAttributedString:token];
        [_tipLabel setAttributedText:attrTitle];
    } else {
        [_tipLabel setText:title];
    }
    
    [_tipLabel sizeToFit];
    
    // 有回答 6 无回答 12 暂无回答 8
    CGFloat padding = 0;
    if (isNoAnswers) {
        padding = WDPadding(8) ;
        _tipLabel.textColorThemeKey = kFHColorCoolGrey3;
    } else {
        padding = [_viewModel hasNiceAnswers] ? WDPadding(6) : WDPadding(12) ;
        _tipLabel.textColorThemeKey = kFHColorCoolGrey3;
    }
    _tipLabel.origin = CGPointMake(kWDCellLeftPadding, padding);
    self.clickedBlock = block;
}

- (void)setTitle:(NSString *)title isShowArrow:(BOOL)isShowArrow isNoAnswers:(BOOL)isNoAnswers isNew:(BOOL)isNew clickedBlock:(WDWendaListFooterViewClickedBlock)block {
    if (isShowArrow) {
        NSMutableAttributedString *attrTitle = [[NSMutableAttributedString alloc] initWithString:title
                                                                                      attributes:@{
                                                                                                   NSFontAttributeName : [UIFont systemFontOfSize:14],
                                                                                                   NSForegroundColorAttributeName : [UIColor tt_themedColorForKey:kColorText1]}];
        NSMutableAttributedString *token = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@" %@",ask_arrow_right]
                                                                                  attributes:@{NSBaselineOffsetAttributeName:@(1.5),
                                                                                               NSFontAttributeName : [UIFont fontWithName:wd_iconfont size:10],
                                                                                               NSForegroundColorAttributeName : [UIColor tt_themedColorForKey:kColorText1]}
                                            ];
        
        
        [attrTitle appendAttributedString:token];
        [_tipLabel setAttributedText:attrTitle];
    } else {
        [_tipLabel setText:title];
    }
    
    [_tipLabel sizeToFit];
    
    // 有回答 6 无回答 12 暂无回答 120
    CGFloat padding = 0 ;
    if (isNoAnswers) {
        _tipLabel.textColorThemeKey = kFHColorCoolGrey3;
        if (isNew) {
            padding = WDPadding(120);
            _tipLabel.top = padding;
            _tipLabel.centerX = self.width/2.0;
        } else {
            padding = WDPadding(8) ;
            _tipLabel.origin = CGPointMake(kWDCellLeftPadding, padding);
        }
    } else {
        padding = [_viewModel hasNiceAnswers] ? WDPadding(6) : WDPadding(12) ;
        _tipLabel.textColorThemeKey = kFHColorCoolGrey3;
        _tipLabel.origin = CGPointMake(kWDCellLeftPadding, padding);
    }
    self.clickedBlock = block;
}

@end
