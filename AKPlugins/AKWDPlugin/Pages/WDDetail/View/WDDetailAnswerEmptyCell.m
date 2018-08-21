//
//  WDDetailAnswerEmptyCell.m
//  Article
//
//  Created by wangqi.kaisa on 2017/6/21.
//
//

#import "WDDetailAnswerEmptyCell.h"
#import "UIView+Refresh_ErrorHandler.h"
#import "NetworkUtilities.h"

@interface WDDetailAnswerEmptyCell ()<UIViewControllerErrorHandler>

@property (nonatomic, strong) UIView *bgView;
@property (nonatomic, assign) BOOL deleted;

@end

@implementation WDDetailAnswerEmptyCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColorThemeKey = kColorBackground4;
    }
    return self;
}

- (void)setNetworkProblem {
    _deleted = NO;
    NSString *tips = TTNetworkConnected() ? @"加载失败" : @"没有网络连接";
    [self tt_endUpdataData:NO error:[NSError errorWithDomain:tips code:-3 userInfo:@{@"errmsg":tips}]];
}

- (void)setHasBeenDeletedWithError:(NSError *)error {
    _deleted = YES;
    [self tt_endUpdataData:NO error:error];
}

#pragma mark - UIViewControllerErrorHandler

- (BOOL)tt_hasValidateData {
    if (_deleted) {
        self.ttViewType = TTFullScreenErrorViewTypeDeleted;
    }
    return NO;
}

- (void)refreshData {
    if (_deleted) return;
    if (_delegate && [_delegate respondsToSelector:@selector(wd_detailAnswerEmptyCellReloadContent)]) {
        [_delegate wd_detailAnswerEmptyCellReloadContent];
    }
}

@end
