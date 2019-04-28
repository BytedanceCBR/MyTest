//
//  TTScoreView.h
//  Article
//
//  Created by 杨心雨 on 16/8/18.
//
//

#import "SSThemed.h"
#import "LiveMatch.h"

@interface TTScoreView : UIView

- (void)updateScore:(LiveMatch *)match status:(NSInteger)status;

@end
