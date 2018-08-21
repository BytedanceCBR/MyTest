//
//  TTVAdPlayFinnishActionButton.h
//  Article
//
//  Created by panxiang on 2017/5/5.
//
//

#import "TTAlphaThemedButton.h"
#import "TTVAdActionButtonCommand.h"

@class TTTouchContext;
@interface TTVAdPlayFinnishActionButton : TTAlphaThemedButton
@property (nonatomic, strong) TTTouchContext *lastTouchContext;
- (void)setTitle:(NSString *)title;
@end
