//
//  TTVVideoDetailContainerScrollView.m
//  Article
//
//  Created by pei yun on 2017/5/21.
//
//

#import "TTVVideoDetailContainerScrollView.h"
#import "TTDetailNatantViewBase.h"
#import "TTUserSettingsManager+FontSettings.h"

@implementation TTVVideoDetailContainerScrollView

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.contentOffsetWhenLeave = NSNotFound;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_fontChanged:) name:kSettingFontSizeChangedNotification object:nil];
    }
    return self;
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    [super willMoveToSuperview:newSuperview];
    if (_contentOffsetWhenLeave != NSNotFound) {
        [self checkVisibleAtContentOffset:self.contentOffsetWhenLeave referViewHeight:self.referHeight];
    }
}

- (void)_fontChanged:(NSNotification *)notify{
    for(TTDetailNatantViewBase * view in self.contentView.subviews){
        if ([view isKindOfClass:[TTDetailNatantViewBase class]]) {
            [view fontChanged];
        }
    }
}

- (void)checkVisibleAtContentOffset:(CGFloat)contentOffset referViewHeight:(CGFloat)referHeight
{
    for(TTDetailNatantViewBase<TTDetailNatantViewBase> * view in self.contentView.subviews){
        if ([view isKindOfClass:[TTDetailNatantViewBase class]] && [view conformsToProtocol:@protocol(TTDetailNatantViewBase)]) {
            [view checkVisableRelatedArticlesAtContentOffset:contentOffset referViewHeight:referHeight];
        }
    }
}

- (void)sendNatantItemsShowEventWithContentOffset:(CGFloat)natantContentoffsetY scrollView:(UIScrollView*)scrollView isScrollUp:(BOOL)isScrollUp
{
    [self sendNatantItemsShowEventWithContentOffset:natantContentoffsetY isScrollUp: isScrollUp scrollView: scrollView shouldSendShowTrack:YES];
}

- (void)sendNatantItemsShowEventWithContentOffset:(CGFloat)natantContentoffsetY isScrollUp:(BOOL)isScrollUp scrollView:(UIScrollView*)scrollView shouldSendShowTrack:(BOOL)shouldSend
{
    if (isScrollUp) {
        for(TTDetailNatantViewBase<TTDetailNatantViewBase> * view in self.contentView.subviews){
            if ([view isKindOfClass:[TTDetailNatantViewBase class]] && [view conformsToProtocol:@protocol(TTDetailNatantViewBase)]) {
                if (view && natantContentoffsetY + scrollView.height > view.top) {
                    if (shouldSend) {
                        [view trackEventIfNeeded];
                    }
                    if (view.scrollInOrOutBlock) {
                        view.scrollInOrOutBlock(YES);
                    }
                }else{
                    if (view.scrollInOrOutBlock) {
                        view.scrollInOrOutBlock(NO);
                    }
                }
            }
        }
    }else{
        for(TTDetailNatantViewBase<TTDetailNatantViewBase> * view in self.contentView.subviews){
            if ([view isKindOfClass:[TTDetailNatantViewBase class]] && [view conformsToProtocol:@protocol(TTDetailNatantViewBase)]) {
                if (view && natantContentoffsetY > view.top) {
                    if (shouldSend) {
                        [view trackEventIfNeeded];
                    }
                    if (view.scrollInOrOutBlock) {
                        view.scrollInOrOutBlock(YES);
                    }
                }else{
                    if (view.scrollInOrOutBlock) {
                        view.scrollInOrOutBlock(NO);
                    }
                }
            }
        }
    }
}

@end
