//
//  TTProfileFillViewController.h
//  Article
//
//  Created by tyh on 2017/5/25.
//
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    TTProfileFillFromComment,
    TTProfileFillFromWeitoutiao
} TTProfileFillFrom;

typedef NS_ENUM(NSUInteger, TTProfileFillExpandDirection)
{
    TTProfileFillExpandDirectionDown = 0,
    TTProfileFillExpandDirectionUp,
};

#define kProfileFillHeight [TTDeviceUIUtils tt_newPadding:283.0f + 7.0f + 7.0f]

@interface TTProfileFillViewController : UIViewController

- (void)presentExpandLocation:(CGPoint)expandLocation direction:(TTProfileFillExpandDirection)direction;

@property (nonatomic,copy)dispatch_block_t completeBlock;

@property (nonatomic,copy)dispatch_block_t dissmissBlock;

- (void)closeAction:(BOOL)animated;

@end
