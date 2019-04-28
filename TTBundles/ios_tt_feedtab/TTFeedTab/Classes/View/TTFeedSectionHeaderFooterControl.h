//
//  TTFeedSectionHeaderFooterControl.h
//  Article
//
//  Created by fengyadong on 16/11/11.
//
//

#import "SSThemed.h"

@interface TTFeedSectionHeaderFooterControl : UIControl

@property (nonatomic, copy) void (^didSelect)(BOOL isSelected);
@property (nonatomic, copy) NSString *backgroudColorThemedKey;
@property (nonatomic, strong) SSThemedButton *editButton;
@property (nonatomic, strong) SSThemedLabel *headerLabel;

- (void)hideBorderLineAtBottom:(BOOL)atBottom;

@end
