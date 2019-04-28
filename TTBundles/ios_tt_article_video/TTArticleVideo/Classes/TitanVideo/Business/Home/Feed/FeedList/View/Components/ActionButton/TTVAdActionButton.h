//
//  TTVAdActionButton.h
//  Article
//
//  Created by pei yun on 2017/3/31.
//
//

#import <UIKit/UIKit.h>
#import "TTAlphaThemedButton.h"
#import "TTTouchContext.h"
#import "TTVAdActionButtonCommand.h"

@interface TTVAdActionButton : TTAlphaThemedButton

@property (nonatomic, strong, readonly) TTTouchContext *lastTouchContext;
@property (nonatomic, strong) id <TTVAdActionButtonCommandProtocol> ttv_command;
@property (nonatomic, assign) BOOL showIcon;
@end

@interface TTVAdActionTypeAppButton : TTVAdActionButton

@end

@interface TTVAdActionTypeWebButton : TTVAdActionButton

@end

@interface TTVAdActionTypePhoneButton : TTVAdActionButton

@end

@interface TTVAdActionTypeFormButton : TTVAdActionButton

@end

@interface TTVAdActionTypeCounselButton : TTVAdActionButton

@end

@interface TTVAdActionTypeNormalButton : TTVAdActionButton

@end

