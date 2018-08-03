//
//  TTDetailNatantViewBase.m
//  Article
//
//  Created by Ray on 16/4/11.
//
//

#import "TTDetailNatantViewBase.h"
#import "SSThemed.h"
#import "TTUISettingHelper.h"

@implementation TTDetailNatantViewBase

- (nullable id)initWithWidth:(CGFloat)width
{
    self = [super initWithFrame:CGRectMake(0, 0, width, 0)];
    if (self) {
        self.backgroundColorThemeKey = kColorBackground4;
    }
    return self;
}

- (void)refreshWithWidth:(CGFloat)width
{
    CGRect frame = self.frame;
    frame.size.width = width;
    self.frame = frame;
}

-(void)reloadData:(id)object{
    
}

-(void)trackEventIfNeeded{
    
}

- (void)trackEventIfNeededWithStyle:(NSString *)style {
    
}


- (void)checkVisableRelatedArticlesAtContentOffset:(CGFloat)offsetY referViewHeight:(CGFloat)referHeight{
}

- (void)scrollViewDidEndDraggingAtContentOffset:(CGFloat)offsetY referViewHeight:(CGFloat)referHeight{}

- (void)refreshUI
{}

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
