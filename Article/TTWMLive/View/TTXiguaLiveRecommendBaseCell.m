//
//  TTXiguaLiveRecommendBaseCell.m
//  Article
//
//  Created by lipeilun on 2017/12/6.
//

#import "TTXiguaLiveRecommendBaseCell.h"
#import "SSThemed.h"

@implementation TTXiguaLiveRecommendBaseCell


- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground4];
    
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(themeChanged:) name:TTThemeManagerThemeModeChangedNotification object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)themeChanged:(NSNotification *)notification {
    self.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground4];
}

- (void)configWithModel:(TTXiguaLiveModel *)model {
    
}

- (void)tryBeginAnimation {
    
}

- (void)tryStopAnimation {
    
}
@end
