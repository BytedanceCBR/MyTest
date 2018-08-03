//
//  TTPersonalHomeHorizontalPagingView.m
//  Article
//
//  Created by wangdi on 2017/3/18.
//
//

#import "TTPersonalHomeHorizontalPagingView.h"
#import "TTThemeManager.h"

@interface TTPersonalHomeHorizontalPagingView ()

@end

@implementation TTPersonalHomeHorizontalPagingView

- (instancetype)initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame]) {
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(themedChange) name:TTThemeManagerThemeModeChangedNotification object:nil];
        [self themedChange];
    }
    return self;
}

- (void)reloadHeaderViewHeight:(CGFloat)height
{
    if(self.headerViewHeight == height) return;
    CGFloat delta = self.headerViewHeight - height;
    CGFloat offsetY = self.currentContentView.contentOffset.y + delta;
    [self setValue:@(height) forKeyPath:@"headerViewHeight"];
    self.headerView.height = height;
    self.currentContentView.contentOffset = CGPointMake(0,offsetY);
    self.currentContentView.contentInset = UIEdgeInsetsMake(self.headerViewHeight + self.segmentViewHeight, 0, self.currentContentView.contentInset.bottom, 0);
}

- (void)themedChange
{
    if([TTThemeManager sharedInstance_tt].currentThemeMode == TTThemeModeDay){
        self.horizontalCollectionView.backgroundColor = [UIColor whiteColor];
    } else {
        self.horizontalCollectionView.backgroundColor = [UIColor colorWithHexString:@"#252525"];
    }
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
