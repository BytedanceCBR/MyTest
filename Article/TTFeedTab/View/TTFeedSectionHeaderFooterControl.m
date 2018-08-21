//
//  TTFeedSectionHeaderFooterControl.m
//  Article
//
//  Created by fengyadong on 16/11/11.
//
//

#import "TTFeedSectionHeaderFooterControl.h"
#import "UIColor+TTThemeExtension.h"

@interface TTFeedSectionHeaderFooterControl ()

@property (nonatomic, strong) SSThemedView *topLine;
@property (nonatomic, strong) SSThemedView *bottomLine;

@end

@implementation TTFeedSectionHeaderFooterControl

- (instancetype)init {
    if (self = [super init]) {
        self.selected = NO;
        [self addTarget:self action:@selector(didSelectControl:) forControlEvents:UIControlEventTouchUpInside];
        [self setupBorderLine:YES];
        [self setupBorderLine:NO];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(themeChanged:)
                                                     name:TTThemeManagerThemeModeChangedNotification
                                                   object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setupBorderLine:(BOOL)atBottom {
    SSThemedView *borderLine = [[SSThemedView alloc] init];
    borderLine.backgroundColorThemeKey = kColorLine10;
    [self addSubview:borderLine];
    
    [borderLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(@([TTDeviceHelper ssOnePixel]));
        if (atBottom) {
            make.bottom.equalTo(self.mas_bottom);
        } else {
            make.bottom.equalTo(self.mas_top);
        }
        make.left.right.equalTo(self);
    }];
    
    if (atBottom) {
        if (!_bottomLine) {
            _bottomLine = borderLine;
        }
    } else {
        if (!_topLine) {
            _topLine = borderLine;
        }
    }
}

- (void)setBackgroudColorThemedKey:(NSString *)backgroudColorThemedKey {
    if (!isEmptyString(backgroudColorThemedKey) && _backgroudColorThemedKey != backgroudColorThemedKey) {
        _backgroudColorThemedKey = backgroudColorThemedKey;
        self.backgroundColor = [UIColor tt_themedColorForKey:backgroudColorThemedKey];
    }
}

- (void)didSelectControl:(id)sender {
    self.selected = !self.selected;
    self.editButton.selected = self.selected;
    if(self.didSelect) {
        self.didSelect(self.selected);
    }
}

- (void)themeChanged:(NSNotification *)notification {
    if (!isEmptyString(self.backgroudColorThemedKey)) {
        self.backgroundColor = [UIColor tt_themedColorForKey:self.backgroudColorThemedKey];
    }
}

- (void)hideBorderLineAtBottom:(BOOL)atBottom {
    if (atBottom) {
        self.bottomLine.hidden = YES;
    } else {
        self.topLine.hidden = YES;
    }
}

@end
