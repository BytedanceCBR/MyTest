//
//  TTEditUserLogoutCell.m
//  Article
//
//  Created by Zuopeng Liu on 7/15/16.
//
//

#import "TTEditUserLogoutCell.h"
#import "TTUserLogoutView.h"
#import "SSThemed.h"


@interface TTEditUserLogoutCell ()
@property (nonatomic, strong) TTUserLogoutView *logoutView;
@end



@implementation TTEditUserLogoutCell
- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithReuseIdentifier:reuseIdentifier])) {
        [self.contentView addSubview:self.logoutView];
        
        [self.logoutView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.bottom.right.equalTo(self.contentView);
        }];
    }
    return self;
}

- (void)reloadWithTitle:(NSString *)title themeKey:(NSString *)titleTextThemeKey {
    [self.logoutView reloadWithTitle:title themeKey:titleTextThemeKey];
}

#pragma mark - lazied load for setter/getter properties

- (TTUserLogoutView *)logoutView {
    if (!_logoutView) {
        _logoutView = [[TTUserLogoutView alloc] init];
        _logoutView.backgroundColor = [UIColor clearColor];
    }
    return _logoutView;
}
@end
