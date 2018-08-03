//
//  TTVisitorHeaderView.h
//  Article
//
//  Created by liuzuopeng on 8/9/16.
//
//

#import "SSThemed.h"


@interface TTVisitorHeaderView : TTThemedSplitView
/**
 *  重新加载内容
 *
 *  @param allViews    总浏览数
 *  @param latestViews 最近N天浏览数
 */
- (void)reloadWithAllViews:(NSUInteger)allViews latestViews:(NSUInteger)latestViews;

+ (CGFloat)height;
@end
