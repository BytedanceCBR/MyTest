//
//  TTVideoFloatTopBar.h
//  Article
//
//  Created by panxiang on 16/7/6.
//
//

#import "SSThemed.h"
#import "TTAlphaThemedButton.h"

@interface TTVideoFloatTopBar : SSThemedView
@property(nonatomic, strong ,readonly) UIButton *backButton;
@property(nonatomic, assign) BOOL hiddenTitle;
- (void)hidden:(BOOL)hidden animated:(BOOL)animated;
@end
