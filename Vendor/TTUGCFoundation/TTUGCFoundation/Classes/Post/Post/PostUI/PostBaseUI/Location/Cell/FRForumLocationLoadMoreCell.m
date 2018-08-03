//
//  FRForumLocationLoadMoreCell.m
//  Article
//
//  Created by 王霖 on 15/7/16.
//
//

#import "FRForumLocationLoadMoreCell.h"
#import "TTWaitingView.h"
#import "TTDeviceHelper.h"
#import "View+MASAdditions.h"

@interface FRForumLocationLoadMoreCell ()

@property (nonatomic, strong)SSThemedLabel *stateLabel;
@property (nonatomic, strong)TTWaitingView * loadMoreIndicator;

@end

@implementation FRForumLocationLoadMoreCell


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.separatorThemeInsetLeft = 15;
        self.separatorColorThemeKey = kColorLine1;
        self.backgroundColorThemeKey = kColorBackground4;
        self.separatorAtTOP = YES;
        [self createSubView];
    }
    return self;
}
- (void)createSubView {

    self.stateLabel = [[SSThemedLabel alloc] init];
    _stateLabel.translatesAutoresizingMaskIntoConstraints = NO;
    if ([TTDeviceHelper is667Screen] || [TTDeviceHelper is736Screen] || [TTDeviceHelper isIPhoneXDevice]) {
        _stateLabel.font = [UIFont systemFontOfSize:14];
    }else {
        _stateLabel.font = [UIFont systemFontOfSize:13];
    }
    _stateLabel.textColorThemeKey = kColorText2;
    [self.contentView addSubview:_stateLabel];
    [_stateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(@0);
        make.centerY.equalTo(@0);
    }];
    
    self.loadMoreIndicator = [[TTWaitingView alloc] initWithFrame:CGRectZero];
    _loadMoreIndicator.imageView.imageName = @"loading";
    [self.contentView addSubview:_loadMoreIndicator];
    [_loadMoreIndicator mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@12);
        make.height.equalTo(@12);
        make.centerY.equalTo(@0);
        make.left.equalTo(self.stateLabel.mas_right).equalTo(@5);
    }];
}

- (void)setState:(FRForumLocationLoadMoreCellState)state {
    _state = state;
    switch (_state) {
        case FRForumLocationLoadMoreCellStateLoading:{
            _stateLabel.text = NSLocalizedString(@"正在搜索附近的位置", nil);
            [_loadMoreIndicator startAnimating];
        }
            break;
        case FRForumLocationLoadMoreCellStateFailed:{
            _stateLabel.text = NSLocalizedString(@"点击搜索附近的位置", nil);
            [_loadMoreIndicator stopAnimating];
        }
            break;
        case FRForumLocationLoadMoreCellStateNoMore:{
            _stateLabel.text = NSLocalizedString(@"没有更多附近的位置", nil);
            [_loadMoreIndicator stopAnimating];
        }
            break;
        default:
            break;
    }
}

- (void)startAnimating {
    [self.loadMoreIndicator startAnimating];
}
- (void)stopAnimating {
    [self.loadMoreIndicator stopAnimating];
}

@end
