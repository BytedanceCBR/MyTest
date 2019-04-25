//
//  TTEditUserProfileCell.h
//  Article
//
//  Created by Zuopeng Liu on 7/14/16.
//
//

#import <UIKit/UIKit.h>
#import "SSThemed.h"


@class SSThemedView;

/**
 * old class
 */
@interface TTEditUserProfileCell : SSThemedTableViewCell

@property(nonatomic, assign)BOOL shouldHighlight; // default YES
@property(nonatomic, strong)SSThemedView *bgView;

@property(nonatomic, strong)SSThemedView *topLine;
@property(nonatomic, strong)SSThemedView *bottomLine;


+ (CGFloat)heightOfAccountCell;
+ (CGFloat)heightOfLogoutCell;
+ (CGFloat)fontSizeOfCellLeftLabel;
+ (CGFloat)fontSizeOfCellRightLabel;

@end