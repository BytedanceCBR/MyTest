//
//  TTRelationFooterView.h
//  Article
//
//  Created by liuzuopeng on 9/5/16.
//
//

#import "SSThemed.h"



@interface TTRelationFooterView : TTThemedSplitView
/*
 *刷新footer上的文案
 */
- (void)reloadLabelText:(NSString *)text;
+ (CGFloat)height;
@end
