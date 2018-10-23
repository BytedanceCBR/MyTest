//
//  ExploreArticleEssayCellCommentView.m
//  Article
//
//  Created by Chen Hong on 14-10-23.
//
//

#import "ExploreArticleEssayCellCommentView.h"
#import "ExploreArticleEssayCellCommentItemView.h"
#import "ExploreArticleEssayCommentObject.h"
#import "ArticleMomentProfileViewController.h"
#import "UIImageAdditions.h"
#import "SSAttributeLabel.h"
#import "SSUserSettingManager.h"
#import "TTDeviceHelper.h"
#import "UIColor+TTThemeExtension.h"
#import "TTThemeConst.h"

#import "TTUserSettings/TTUserSettingsManager+FontSettings.h"

#define kViewLeftMargin 5
#define kViewRightMargin 5
#define kViewTopPadding 0
#define kViewBottomPadding 0
#define kShowCommentMaxNumber 15
#define kBgImgViewArrowH 0//5.f

@interface ExploreArticleEssayCellCommentView()<ExploreArticleEssayCellCommentItemViewDelegate>
@property(nonatomic, strong)NSArray *commentItems;
@property(nonatomic, strong)NSMutableArray *commentViewItems;
@end


#pragma mark - ExploreArticleEssayCellCommentView
@implementation ExploreArticleEssayCellCommentView

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kSettingFontSizeChangedNotification object:nil];
    self.delegate = nil;
    self.commentItems = nil;
    self.commentViewItems = nil;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fontSizeChanged) name:kSettingFontSizeChangedNotification object:nil];
        
        self.commentItems = [NSMutableArray arrayWithCapacity:10];
        self.commentViewItems = [NSMutableArray arrayWithCapacity:10];
        self.layer.borderWidth = [TTDeviceHelper ssOnePixel];
        [self reloadThemeUI];
    }
    return self;
}

- (void)fontSizeChanged {
    [self refreshWithComments:self.commentItems viewWidth:self.frame.size.width];
}

- (void)themeChanged:(NSNotification *)notification {
    self.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground3];
    self.layer.borderColor = [UIColor tt_themedColorForKey:kColorLine1].CGColor;
}

- (void)refreshWithComments:(NSArray *)commentItems viewWidth:(CGFloat)width
{
    self.commentItems = commentItems;
    
    if ([_commentItems count] == 0) {
        CGRect frame = self.frame;
        frame.size.height = 0;
        self.frame = frame;
        return;
    }
    
    //[self.commentViewItems makeObjectsPerformSelector:@selector(removeFromSuperview)];

    CGFloat originY = kViewTopPadding + kBgImgViewArrowH;
    
    NSInteger total = MIN(kShowCommentMaxNumber, _commentItems.count);
    int i = 0;
    for (; i < total; i++) {
        ExploreArticleEssayCellCommentItemView *itemView;
        if (i < self.commentViewItems.count) {
            itemView = self.commentViewItems[i];
            itemView.hidden = NO;
            [itemView reset];
        } else {
            itemView = [[ExploreArticleEssayCellCommentItemView alloc] initWithFrame:CGRectZero];
            [self addSubview:itemView];
            [self.commentViewItems addObject:itemView];
        }
        
        itemView.delegate = self;
        itemView.orderIndex = i;
        
        ExploreArticleEssayCommentObject *commentObj = [_commentItems objectAtIndex:i];
        [itemView refreshWithUserName:commentObj.user.name userComment:commentObj.content cellWidth:width];
        
        itemView.origin = CGPointMake(0, originY);
        originY = CGRectGetMaxY(itemView.frame);
        
//        if (i == total - 1) {
//            itemView.hideBottomLine = YES;
//        }
    }
    
    for (; i < self.commentViewItems.count; ++i) {
        ExploreArticleEssayCellCommentItemView *itemView = self.commentViewItems[i];
        itemView.hidden = YES;
    }
    
    CGRect frame = self.frame;
    frame.size.width = width;
    frame.size.height = originY + kViewBottomPadding;
    self.frame = frame;
}

+ (CGFloat)heightForComments:(NSArray *)commentItems viewWidth:(CGFloat)width
{
    if ([commentItems count] == 0) {
        return 0;
    }
    
    CGFloat height = kViewTopPadding + kBgImgViewArrowH;
    
    for (int i = 0; i < MIN(kShowCommentMaxNumber, commentItems.count); i++) {
        ExploreArticleEssayCommentObject *commentObj = [commentItems objectAtIndex:i];
        
        CGFloat h = [ExploreArticleEssayCellCommentItemView heightForUserName:commentObj.user.name userComment:commentObj.content cellWidth:width];
        height += h;
    }

    height += kViewBottomPadding;
    return height;
}

- (void)updateNormal {
}

- (void)updateHighlight {
}

- (void)updateBackgroudColorWithHighlighted:(BOOL)bHighlighted {
    if (bHighlighted) {
        self.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground3Highlighted];
    } else {
        self.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground3];
    }
    
    for (int i=0; i < self.commentItems.count; i++) {
        if (i < self.commentViewItems.count) {
            ExploreArticleEssayCellCommentItemView *itemView = self.commentViewItems[i];
            if (bHighlighted) {
                [itemView updateContentWithHighlightColor];
            } else {
                [itemView updateContentWithNormalColor];
            }
        }
    }
}

#pragma mark -- ExploreArticleEssayCellCommentItemViewDelegate
- (void)commentItemDidTouchBegan:(ExploreArticleEssayCellCommentItemView *)item
{
    if (item.orderIndex == 0) {
        [self updateHighlight];
    }
}
- (void)commentItemDidTouchEnded:(ExploreArticleEssayCellCommentItemView *)item
{
    if (item.orderIndex == 0) {
        [self updateNormal];
    }
}
- (void)commentItemDidTouchCancelled:(ExploreArticleEssayCellCommentItemView *)item
{
    if (item.orderIndex == 0) {
        [self updateNormal];
    }
}

- (void)commentItemDidSeletedCommentButton:(ExploreArticleEssayCellCommentItemView *)item
{
    if (item.orderIndex < [_commentItems count]) {
        if (item.orderIndex == 0) {
            [self updateHighlight];
            [self performSelector:@selector(updateNormal) withObject:nil afterDelay:0.25];
        }
        
        ExploreArticleEssayCommentObject *commentObj = [_commentItems objectAtIndex:item.orderIndex];
        
        if (_delegate && [_delegate respondsToSelector:@selector(exploreArticleEssayCellCommentView:commentClicked:)]) {
            [_delegate exploreArticleEssayCellCommentView:self commentClicked:commentObj];
        }
    }
}

- (void)commentItemDidSeletedNameButton:(ExploreArticleEssayCellCommentItemView *)item
{
    if (item.orderIndex < [_commentItems count]) {
        if (item.orderIndex == 0) {
            [self updateHighlight];
            [self performSelector:@selector(updateNormal) withObject:nil afterDelay:0.25];
        }
        
        ExploreArticleEssayCommentObject *commentObj = [_commentItems objectAtIndex:item.orderIndex];

        if (!isEmptyString(commentObj.user.ID)) {
            if ([TTDeviceHelper isPadDevice]) {
            } else {
                ArticleMomentProfileViewController * controller = [[ArticleMomentProfileViewController alloc] initWithUserID:commentObj.user.ID];
                controller.from = kFromEssayGodCom;
                UIViewController *topController = [TTUIResponderHelper topViewControllerFor: self];
                [topController.navigationController pushViewController:controller animated:YES];
            }
        }
    }
}

@end

