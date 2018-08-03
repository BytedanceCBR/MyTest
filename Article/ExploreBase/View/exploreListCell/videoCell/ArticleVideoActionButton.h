//
//  ArticleVideoActionButton.h
//  Article
//
//  Created by Chen Hong on 15/5/19.
//
//

#import "ActionButton.h"

@interface ArticleVideoActionButton : ActionButton
@property (nonatomic, assign) CGFloat minWidth;
@property (nonatomic, assign) CGFloat minHeight;
@property (nonatomic, assign) CGFloat maxWidth;
@property (nonatomic, assign) BOOL centerAlignImage;
@property (nonatomic, assign) BOOL centerVertically;
@property (nonatomic, assign) BOOL disableRedHighlight;
@property (nonatomic, assign) BOOL verticalLayout;      // 图标在上，文字在下布局
@property (nonatomic, assign) CGSize imageSize;

- (UIEdgeInsets)contentEdgeInset;

@end
