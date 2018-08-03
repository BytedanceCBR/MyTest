//
//  TTBaseUserProfileCell.h
//  Article
//
//  Created by Zuopeng Liu on 7/15/16.
//
//

#import <UIKit/UIKit.h>
#import "SSThemed.h"
#import "TTDeviceUIUtils.h"



/**
 * position of cell in section
 */
typedef NS_ENUM(NSUInteger, TTCellPositionType) {
    kTTCellPositionTypeFirst,
    kTTCellPositionTypeLast,
    kTTCellPositionTypeMiddle,
    kTTCellPositionTypeFirstAndLast,
};

/**
 * Full: left spacing is 0
 * Part: left spacing isn't 0
 */
typedef NS_ENUM(NSUInteger, TTCellSeparatorStyle) {
    kTTCellSeparatorStyleBothNone,
    kTTCellSeparatorStyleTopFull,
    kTTCellSeparatorStyleTopPart,
    kTTCellSeparatorStyleBottomFull,
    kTTCellSeparatorStyleBottomPart,
    kTTCellSeparatorStyleBothFull,
    kTTCellSeparatorStyleBothPart,
    kTTCellSeparatorStyleTopFullBottomPart,
    kTTCellSeparatorStyleTopPartBottomFull,
};

@interface TTBaseUserProfileCell : SSThemedTableViewCell
@property (nonatomic, assign) BOOL shouldHighlight;   // default YES
@property (nonatomic, strong) SSThemedView *bgView;

@property (nonatomic, assign) BOOL topLineEnabled;    // default is YES
@property (nonatomic, assign) BOOL bottomLineEnabled; // default is YES
@property (nonatomic, assign) TTCellSeparatorStyle cellSpearatorStyle; // default is kTTCellSeparatorStyleBothFull

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier;

/**
 *  can be overrided
 *  default is 30.f
 *
 *  @return left spacing of line
 */
- (CGFloat)insetLeftOfSeparator;
+ (NSString *)separatorThemeColorKey; // default is kColorLine1
+ (TTCellSeparatorStyle)separatorStyleForPosition:(TTCellPositionType)position;

+ (CGFloat)cellHeight;
+ (CGFloat)thumbnailHeight;
+ (CGFloat)fontSizeOfTitle;
+ (CGFloat)fontSizeOfContent;

+ (NSString *)titleColorKey;
+ (NSString *)contentColorKey;

+ (CGFloat)spacingToMargin; // spacing: to margin (left or right)
+ (CGFloat)spacingOfText;   // spacing: title and content
+ (CGFloat)spacingOfTextArrow; // spacing: text to arrow
@end
