//
//  FRButtonLabel.h
//  Article
//
//  Created by 王霖 on 5/27/16.
//
//

#import "SSThemed.h"

@interface FRButtonLabel : SSThemedLabel

@property (nonatomic, copy, nullable) IBInspectable NSString * highlightedTitleColorThemeKey;
@property (nonatomic, copy, nullable) void(^tapHandle)(void);

@end
