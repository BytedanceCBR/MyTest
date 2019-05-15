//
//  TTCollectionButton.h
//  Article
//
//  Created by matrixzk on 28/07/2017.
//
//

#import "TTAlphaThemedButton.h"


typedef NS_ENUM(NSUInteger, TTCollectionButtonType) {
    TTCollectionButtonTypeDark,
    TTCollectionButtonTypeLight
};


@interface TTCollectionButton : TTAlphaThemedButton

@property (nonatomic, copy) void(^didPressedBlock)(BOOL isCollected);
@property (nonatomic, copy) BOOL(^shouldResponsePressedBlock)(void);

+ (instancetype)collectionButtonWithType:(TTCollectionButtonType)type;
+ (instancetype)collectionButtonWithType:(TTCollectionButtonType)type nightModeEnable:(BOOL)nightModeEnable;

@end
