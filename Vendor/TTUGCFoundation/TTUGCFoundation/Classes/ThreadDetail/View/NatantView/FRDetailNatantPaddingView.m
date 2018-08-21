//
//  FRDetailNatantPaddingView.m
//  Article
//
//  Created by 王霖 on 4/25/16.
//
//

#import "FRDetailNatantPaddingView.h"
#import <UIViewAdditions.h>
#import <TTDeviceHelper.h>
#import <TTTrackerWrapper.h>

@interface FRDetailNatantPaddingView ()

@property (nonatomic, strong) SSThemedView *topSeparatorLine;
@property (nonatomic, strong) SSThemedView *bottomSeparatorLine;

@end

@implementation FRDetailNatantPaddingView

- (instancetype)initWithWidth:(CGFloat)width {
    self = [super initWithFrame:CGRectMake(0, 0, width, 0)];
    if (self) {
        [self addSubview:self.topSeparatorLine];
        [self addSubview:self.bottomSeparatorLine];
        self.topSeparatorLine.hidden = YES;
        self.bottomSeparatorLine.hidden = YES;
    }
    return self;
}

- (void)setPaddingHeight:(CGFloat)paddingHeight {
    _paddingHeight = paddingHeight;
    [self refreshUI];
}

- (void)reloadData:(id)object {
//    [super reloadData:object];
    [self refreshUI];
}

- (void)refreshUI {
//    [super refreshUI];
    self.topSeparatorLine.frame = CGRectMake(0, 0, self.width, [TTDeviceHelper ssOnePixel]);
    self.bottomSeparatorLine.frame = CGRectMake(0, self.height - [TTDeviceHelper ssOnePixel], self.width, [TTDeviceHelper ssOnePixel]);
    self.height = self.paddingHeight + 2*[TTDeviceHelper ssOnePixel];
}

#pragma mark - accessors

- (SSThemedView *)topSeparatorLine {
    if (!_topSeparatorLine) {
        _topSeparatorLine = [[SSThemedView alloc] init];
        _topSeparatorLine.backgroundColorThemeKey = kColorLine1;
    }
    return _topSeparatorLine;
}

- (SSThemedView *)bottomSeparatorLine {
    if (!_bottomSeparatorLine) {
        _bottomSeparatorLine = [[SSThemedView alloc] init];
        _bottomSeparatorLine.backgroundColorThemeKey = kColorLine1;
    }
    return _bottomSeparatorLine;
}

- (void)refreshWithWidth:(CGFloat)width
{
    CGRect frame = self.frame;
    frame.size.width = width;
    self.frame = frame;
}

-(void)trackEventIfNeeded{
    
}

- (void)trackEventIfNeededWithStyle:(NSString *)style {
    
}


- (void)checkVisableRelatedArticlesAtContentOffset:(CGFloat)offsetY referViewHeight:(CGFloat)referHeight{
}

- (void)scrollViewDidEndDraggingAtContentOffset:(CGFloat)offsetY referViewHeight:(CGFloat)referHeight{}


- (void)sendShowTrackIfNeededForGroup:(nullable NSString *)groupID withLabel:(nullable NSString *)label
{
    if (!self.hasShow) {
        if (!isEmptyString(groupID)) {
            [TTTrackerWrapper category:@"umeng"
                                 event:@"detail"
                                 label:label
                                  dict:@{@"value":groupID}];
            self.hasShow = YES;
        }
    }
}

- (void)fontChanged{
    
}

@end
