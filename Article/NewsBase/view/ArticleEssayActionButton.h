//
//  ArticleEssayActionButton.h
//  Article
//
//  Created by Yu Tianhang on 13-2-27.
//
//

#import "ActionButton.h"

#define kEssayActionButtonH (/*[TTDeviceHelper isPadDevice] ? 16.f : */52.f)

@interface ArticleEssayActionButton : ActionButton
@property (nonatomic, assign) CGFloat minWidth;
@property (nonatomic, assign) CGFloat minHeight;

@property (nonatomic, assign) CGFloat maxWidth;

@property (nonatomic, assign) BOOL centerAlignImage;
@property (nonatomic, assign) BOOL disableRedHighlight;
@end
