//
//  TTRealnameAuthSubmitView.h
//  Article
//
//  Created by lizhuoli on 16/12/20.
//
//

#import <UIKit/UIKit.h>
#import "SSThemed.h"
#import "SSViewControllerBase.h"
#import "TTUserProfileInputView.h"

typedef NS_ENUM(NSInteger, TTRealnameAuthSubmitTextType) {
    TTRealnameAuthSubmitTextName,
    TTRealnameAuthSubmitTextIDNum
};

@interface TTRealnameAuthSubmitView : SSThemedView

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *IDNum;

@property (nonatomic, weak) SSViewControllerBase<TTUserProfileInputViewDelegate> *delegate;

@end

@interface TTRealnameAuthSubmitTipView : SSThemedView

@end
