//
//  TTRealnameAuthProgressStepView.h
//  Article
//
//  Created by lizhuoli on 16/12/18.
//
//

#import <UIKit/UIKit.h>
#import "SSThemed.h"

@interface TTRealnameAuthProgressStepView : SSThemedView

/** 是否高亮 */
@property (nonatomic, assign) BOOL highlight;
/** 进度标题 */
@property (nonatomic, copy) NSString *title;

@end
