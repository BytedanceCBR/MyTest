//
//  WDDetailSearchTitleView.h
//  Article
//
//  Created by xuzichao on 6/1/17.
//
//

#import "SSThemed.h"

extern const CGFloat kWDDetailSearchTitleViewDefaultHeight;
@class SSThemedButton;

@interface WDDetailSearchTitleView : SSThemedView

@property (nonatomic, copy, nullable) NSString * text;
@property (nonatomic, copy, nullable) void(^tap)(void);

@property (nonatomic, readonly, strong, nonnull) SSThemedButton * searchButton;

@end
