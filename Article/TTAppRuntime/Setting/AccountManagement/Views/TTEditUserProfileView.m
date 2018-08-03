//
//  TTEditUserProfileView.m
//  Article
//
//  Created by Zuopeng Liu on 7/15/16.
//
//

#import "TTEditUserProfileView.h"

#import "SSAvatarView.h"
#import "TTThirdPartyAccountsHeader.h"

#import "TTUserProfileInputView.h"
#import <TTIndicatorView.h>
#import "TTSettingConstants.h"




@interface TTEditUserProfileView ()
@property (nonatomic, strong, readwrite) SSThemedTableView *tableView;
@end

@implementation TTEditUserProfileView

- (instancetype)init {
    if ((self = [self initWithFrame:CGRectZero])) {
        
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        [self addSubview:self.tableView];
        
        [self reloadThemeUI];
    }
    return self;
}

- (void)dealloc {
    _tableView.dataSource = nil;
    _tableView.delegate   = nil;
}

- (void)willAppear {
    [super willAppear];
}


#pragma mark - events for notifications

- (void)themeChanged:(NSNotification *)notification {
    [super themeChanged:notification];
    
    self.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground3];
}


#pragma mark - reload 

- (void)reloadData {
    [self.tableView reloadData];
}

#pragma mark - lazied load for properties

- (SSThemedTableView *)tableView {
    if (!_tableView) {
        _tableView = [[SSThemedTableView alloc] initWithFrame:self.bounds style:UITableViewStylePlain];
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.contentInset = UIEdgeInsetsMake([TTDeviceUIUtils tt_padding:kTTSettingInsetTop], 0, 0, 0);
        _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    return _tableView;
}
@end
