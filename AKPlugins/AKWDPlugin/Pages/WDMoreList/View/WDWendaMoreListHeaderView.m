//
//  WDWendaMoreListHeaderView.m
//  Article
//
//  Created by wangqi.kaisa on 2017/5/10.
//
//

#import "WDWendaMoreListHeaderView.h"
#import "WDUIHelper.h"
#import "WDLayoutHelper.h"
#import "WDDefines.h"
#import <TTBaseLib/UIViewAdditions.h>

@interface WDWendaMoreListHeaderView()

@property (nonatomic, copy)   WDWendaMoreListHeaderViewClickedBlock clickedBlock;
@property (nonatomic, strong) SSThemedLabel * tipLabel;
@property (nonatomic, strong) SSThemedButton * bgButton;

@end

@implementation WDWendaMoreListHeaderView

- (void)dealloc {
    self.clickedBlock = nil;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.bgButton = [SSThemedButton buttonWithType:UIButtonTypeCustom];
        _bgButton.frame = self.bounds;
        _bgButton.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [_bgButton addTarget:self action:@selector(bgButtonClicked) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_bgButton];
        
        self.backgroundColorThemeKey = kColorBackground3;
        CGRect tipFrame = CGRectMake(kWDCellLeftPadding, 10, self.width - kWDCellLeftPadding - kWDCellRightPadding, kWDWendaMoreListHeaderViewHeight - 20);
        self.tipLabel = [[SSThemedLabel alloc] initWithFrame:tipFrame];
        _tipLabel.frame = tipFrame;
        _tipLabel.textColorThemeKey = kColorText1;
        _tipLabel.font = [UIFont systemFontOfSize:[WDUIHelper wdUserSettingFontSizeWithConstraintFontSize:14.0f]];
        _tipLabel.textAlignment = NSTextAlignmentLeft;
        _tipLabel.verticalAlignment = ArticleVerticalAlignmentTop;
        [self addSubview:_tipLabel];
        _tipLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    return self;
}

- (void)bgButtonClicked {
    if (_clickedBlock) {
        _clickedBlock();
    }
}

- (void)setTitle:(NSString *)title clickedBlock:(WDWendaMoreListHeaderViewClickedBlock)block {
    self.clickedBlock = block;
    [_tipLabel setText:title];
}

@end
