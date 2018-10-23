//
//  ExploreDetailnatantActionButton.m
//  Article
//
//  Created by Zhang Leonardo on 14-10-23.
//
//

#import "ExploreDetailnatantActionButton.h"
#import "DetailActionRequestManager.h"

#import "NewsDetailLogicManager.h"
#import "SSMotionRender.h"
#import "TTIndicatorView.h"
#import "UIImage+TTThemeExtension.h"
#import "TTDeviceHelper.h"
#import <UIColor+TTThemeExtension.h>



@interface ExploreDetailnatantActionButton()

@property(nonatomic, assign)BOOL isDigButton;//yes dig , no bury
@property(nonatomic, retain)DetailActionRequestManager * actionManager;
@property(nonatomic, retain)ExploreOriginalData * article;
@property(nonatomic, retain)NSNumber * adID;

- (void)refresh;
- (void)refreshWithArticle:(ExploreOriginalData *)article adID:(NSNumber *)adID;

@end

@implementation ExploreDetailnatantActionButton

- (void)dealloc
{
    self.adID = nil;
    self.actionManager = nil;
    self.article = nil;
}

- (id)initIsDigButton:(BOOL)digButton;
{
    self = [super init];
    if (self) {
        self.actionManager = [[DetailActionRequestManager alloc] init];
        self.isDigButton = digButton;
        [self.titleLabel setFont:[UIFont systemFontOfSize:12.f]];
        
        [self addTarget:self action:@selector(actionButtonClicked) forControlEvents:UIControlEventTouchUpInside];
        [self refresh];
        
    }
    return self;
}

- (void)actionButtonClicked
{
    if (_article.uniqueID == 0) {
        return;
    }
    
    BOOL userHasActioned = _article.userDigg || _article.userBury;
    if (userHasActioned) {
        if (_article.userDigg) {
            [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:NSLocalizedString(@"您已经赞过", nil) indicatorImage:nil autoDismiss:YES dismissHandler:nil];
        }
        else if(_article.userBury) {
            [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:NSLocalizedString(@"您已经踩过", nil) indicatorImage:nil autoDismiss:YES dismissHandler:nil];
        }
        return;
    }
    TTGroupModel *groupModel = nil;
    if ([_article isKindOfClass:[Article class]]) {
        groupModel = [[TTGroupModel alloc] initWithGroupID:@(_article.uniqueID).stringValue itemID:((Article *)_article).itemID impressionID:nil aggrType:((Article *)_article).aggrType.integerValue];
    } else {
        groupModel = [[TTGroupModel alloc] initWithGroupID:@(_article.uniqueID).stringValue];
    }

    TTDetailActionReuestContext *context = [TTDetailActionReuestContext new];
    context.groupModel = groupModel;
    if (_adID) {
        context.adID = [NSString stringWithFormat:@"%@", _adID];
    }
    [_actionManager setContext:context];
        
    if (_isDigButton) {
        _article.diggCount = _article.diggCount + 1;
        _article.userDigg = YES;
    }
    else {
        _article.buryCount = _article.buryCount + 1;
        _article.userBury = YES;
    }
    [_article save];
    
    if (_isDigButton) {
        [_actionManager startItemActionByType:DetailActionTypeDig];
    }
    else {
        [_actionManager startItemActionByType:DetailActionTypeBury];
    }
    
    NSString * labStr = @"digg_button";
    if (!_isDigButton) {
        labStr = @"bury_button";
    }
    [NewsDetailLogicManager trackEventTag:@"detail" label:labStr value:@(self.article.uniqueID) extValue:_adID  groupModel:groupModel];
    [SSMotionRender motionInView:self.imageView byType:SSMotionTypeZoomInAndDisappear image:[UIImage themedImageNamed:@"add_all_dynamic.png"] offsetPoint:CGPointMake(4.f, -21.f)];
    self.imageView.contentMode = UIViewContentModeCenter;
    self.imageView.transform = CGAffineTransformMakeScale(1.f, 1.f);
    self.imageView.alpha = 1.f;
    [UIView animateWithDuration:0.1f delay:0.f options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.imageView.transform = CGAffineTransformMakeScale(0.6f, 0.6f);
        self.imageView.alpha = 0.f;
    } completion:^(BOOL finished){
        [self refresh];
        self.imageView.alpha = 0.f;
        [UIView animateWithDuration:0.2f delay:0.f options:UIViewAnimationOptionCurveEaseIn animations:^{
            self.imageView.transform = CGAffineTransformMakeScale(1.f, 1.f);
            self.imageView.alpha = 1.f;
        } completion:^(BOOL finished){
            
        }];
    }];
}

- (void)refreshWithArticle:(ExploreOriginalData *)article adID:(NSNumber *)adID
{
    self.article = article;
    self.adID = adID;
    [self refresh];
}

- (void)refresh
{
    self.backgroundColor = [UIColor clearColor];
    [self setBackgroundImage:[UIImage imageWithSize:CGSizeMake(93, 36) cornerRadius:18 borderWidth:[TTDeviceHelper ssOnePixel] borderColor:[UIColor colorWithDayColorName:@"dddddd" nightColorName:@"303030"] backgroundColor:[UIColor tt_themedColorForKey:kColorBackground4]] forState:UIControlStateNormal];
    [self setAdjustsImageWhenHighlighted:NO];
    
    if (_isDigButton) {
        if (_article.userDigg) {
            [self setImage:[UIImage themedImageNamed:@"digup_video_press.png"] forState:UIControlStateNormal];
            [self setImage:[UIImage themedImageNamed:@"digup_video_press.png"] forState:UIControlStateHighlighted];
            [self setImage:[UIImage themedImageNamed:@"digup_video_press.png"] forState:UIControlStateDisabled];
            [self setTitleColor:[UIColor colorWithDayColorName:@"fe3232" nightColorName:@"935656"] forState:UIControlStateNormal];
        }
        else {
            [self setImage:[UIImage themedImageNamed:@"digup_video.png"] forState:UIControlStateNormal];
            [self setImage:[UIImage themedImageNamed:@"digup_video_press.png"] forState:UIControlStateHighlighted];
            [self setImage:[UIImage themedImageNamed:@"digup_video.png"] forState:UIControlStateDisabled];
            [self setTitleColor:[UIColor colorWithDayColorName:@"999999" nightColorName:@"707070"] forState:UIControlStateNormal];
        }
        [self setTitle:[NSString stringWithFormat:@" %i", _article.diggCount] forState:UIControlStateNormal];
    }
    else {
        if (_article.userBury) {
            [self setImage:[UIImage themedImageNamed:@"digdown_video_press.png"] forState:UIControlStateNormal];
            [self setImage:[UIImage themedImageNamed:@"digdown_video_press.png"] forState:UIControlStateHighlighted];
            [self setImage:[UIImage themedImageNamed:@"digdown_video_press.png"] forState:UIControlStateDisabled];
            [self setTitleColor:[UIColor colorWithDayColorName:@"fe3232" nightColorName:@"935656"] forState:UIControlStateNormal];
        }
        else {
            [self setImage:[UIImage themedImageNamed:@"digdown_video.png"] forState:UIControlStateNormal];
            [self setImage:[UIImage themedImageNamed:@"digdown_video_press.png"] forState:UIControlStateHighlighted];
            [self setImage:[UIImage themedImageNamed:@"digdown_video.png"] forState:UIControlStateDisabled];
            [self setTitleColor:[UIColor colorWithDayColorName:@"999999" nightColorName:@"707070"] forState:UIControlStateNormal];
        }
        [self setTitle:[NSString stringWithFormat:@" %i", _article.buryCount] forState:UIControlStateNormal];
    }
}



@end

