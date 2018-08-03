//
//  WDLoadMoreCell.m
//  Article
//
//  Created by ZhangLeonardo on 15/12/11.
//
//

#import "WDLoadMoreCell.h"
#import "WDLayoutHelper.h"
#import "WDFontDefines.h"
#import "WDDefines.h"
#import <TTUIWidget/TTLoadingView.h>
#import <TTUIWidget/TTAlphaThemedButton.h>
#import <TTBaseLib/NetworkUtilities.h>
#import "WDUIHelper.h"

@interface WDLoadMoreCell()

@property (nonatomic, strong) SSThemedLabel *titleLabel;
@property (nonatomic, strong) TTLoadingView *loadingView;
@property (nonatomic, strong) TTAlphaThemedButton *retryButton;

@property (nonatomic, assign) WDLoadMoreCellState currentState;

@property (nonatomic, assign) CGFloat cellWidth;

@end

@implementation WDLoadMoreCell

+ (CGFloat)cellHeightForState:(WDLoadMoreCellState)state {
    CGFloat topPadding = ([TTDeviceHelper isPadDevice]) ? WDPadding(15) : WDPadding(9);
    CGFloat contentHeight = (state == WDLoadMoreCellStateFailure) ? 28 : 20;
    return topPadding + contentHeight + WDPadding(15);
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.contentView.backgroundColor = [UIColor clearColor];
        self.currentState = WDLoadMoreCellStateInitial;
        [self addSubView];
    }
    return self;
}

- (void)addSubView {
    self.titleLabel = [[SSThemedLabel alloc] init];
    self.titleLabel.textColorThemeKey = kColorText1;
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.font = [UIFont systemFontOfSize:14];
    self.titleLabel.numberOfLines = 1;
    [self.contentView addSubview:self.titleLabel];
    
    self.retryButton = [[TTAlphaThemedButton alloc] initWithFrame:CGRectMake(0, 0, 58, 28)];
    self.retryButton.backgroundColorThemeKey = kColorBackground8;
    self.retryButton.titleColorThemeKey = kColorText8;
    self.retryButton.titleLabel.font = [UIFont systemFontOfSize:14];
    self.retryButton.layer.cornerRadius = 4.0f;
    [self.retryButton setTitle:@"重试" forState:UIControlStateNormal];
    [self.retryButton addTarget:self action:@selector(retryButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.retryButton];
    
    self.loadingView = [[TTLoadingView alloc] initWithFrame:CGRectMake(0, 0, 15, 15)];
    [self.contentView addSubview:self.loadingView];
}

- (void)refreshCellWithNewState:(WDLoadMoreCellState)state cellWidth:(CGFloat)cellWidth {
    
    if (self.currentState == state) return;
    
    self.cellWidth = cellWidth;
    self.currentState = state;
    self.retryButton.hidden = YES;
    self.loadingView.hidden = YES;
    CGFloat topPadding = ([TTDeviceHelper isPadDevice]) ? WDPadding(15) : WDPadding(9);
    switch (self.currentState) {
        case WDLoadMoreCellStateDefault:
        {
            self.titleLabel.text = @"点击加载更多";
            self.titleLabel.textColorThemeKey = kColorText1;
            [self.titleLabel sizeToFit];
            self.titleLabel.centerX = cellWidth/2.0;
            self.titleLabel.top = topPadding;
            [self.loadingView stopLoading];
        }
            break;
        case WDLoadMoreCellStateLoading:
        {
            self.loadingView.hidden = NO;
            self.titleLabel.text = @"正在加载";
            self.titleLabel.textColorThemeKey = kColorText1;
            [self.titleLabel sizeToFit];
            CGFloat width = self.titleLabel.width + self.loadingView.width + 8;
            CGFloat left = (cellWidth - width)/2;
            self.titleLabel.left = left;
            self.loadingView.left = self.titleLabel.right + 8;
            self.titleLabel.top = topPadding;
            self.loadingView.centerY = self.titleLabel.centerY;
            [self.loadingView startLoading];
        }
            break;
        case WDLoadMoreCellStateFailure:
        {
            self.retryButton.hidden = NO;
            if (!TTNetworkConnected()) {
                self.titleLabel.text = @"网络不给力";
            }
            else {
                self.titleLabel.text = @"加载失败，请稍后重试";
            }
            self.titleLabel.textColorThemeKey = kColorText1;
            [self.titleLabel sizeToFit];
            CGFloat width = self.titleLabel.width + self.retryButton.width + 12;
            CGFloat left = (cellWidth - width)/2;
            self.titleLabel.left = left;
            self.retryButton.left = self.titleLabel.right + 12;
            self.retryButton.top = topPadding;
            self.titleLabel.centerY = self.retryButton.centerY;
            [self.loadingView stopLoading];
        }
            break;
        case WDLoadMoreCellStateNoMore:
        {
            self.titleLabel.text = @"没有更多了";
            self.titleLabel.textColorThemeKey = kColorText3;
            [self.titleLabel sizeToFit];
            self.titleLabel.centerX = cellWidth/2.0;
            self.titleLabel.top = topPadding;
            [self.loadingView stopLoading];
        }
            break;
        default:
            break;
    }
}

- (void)retryButtonClicked {
    if (self.currentState == WDLoadMoreCellStateFailure) {
        [self refreshCellWithNewState:WDLoadMoreCellStateLoading cellWidth:self.cellWidth];
        [self notifyDelegate];
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (self.currentState == WDLoadMoreCellStateDefault) {
        [self refreshCellWithNewState:WDLoadMoreCellStateLoading cellWidth:self.cellWidth];
        [self notifyDelegate];
    }
}

- (void)notifyDelegate {
    if (self.delegate && [self.delegate respondsToSelector:@selector(loadMoreCellRequestTrigger)]) {
        [self.delegate loadMoreCellRequestTrigger];
    }
}

@end
