//
//  WDDetailNatantViewBase.m
//  Article
//
//  Created by Ray on 16/4/11.
//
//

#import "WDDetailNatantViewBase.h"
#import "SSThemed.h"
#import "WDDefines.h"

@implementation WDDetailNatantViewBase

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

- (void)refreshUI
{}

- (void)sendShowTrackIfNeededForGroup:(nullable NSString *)groupID withLabel:(nullable NSString *)label
{
    if (!self.hasShow) {
        if (!isEmptyString(groupID)) {
            [TTTracker category:@"umeng"
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
