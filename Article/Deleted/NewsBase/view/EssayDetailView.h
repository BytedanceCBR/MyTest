//
//  EssayDetailView.h
//  Article
//
//  Created by Hua Cao on 13-10-20.
//
//

#import "SSViewBase.h"
#import "EssayData.h"
#import "SSNavigationBar.h"
#import "ExploreCommentView.h"

@interface SSNavigationBar (AASettingButton)

+ (UIButton *) navigationAASettingButtonWithTarget:(id) target action:(SEL) action WithFrame:(CGRect) frame;

@end

@interface EssayDetailView : SSViewBase

@property (nonatomic, retain) ExploreCommentView * essayCommentView;

- (id)initWithFrame:(CGRect)frame
          essayData:(EssayData *)essayData
    scrollToComment:(BOOL)scrollToComment
         trackEvent:(NSString *)trackEvent
         trackLabel:(NSString *)trackLabel;


- (void)openAASettingView:(id)sender;
-(void)reportButtonClicked;
- (void)moreButtonClicked;

@end
