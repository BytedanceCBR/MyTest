//
//  NewsDetailFunctionView.h
//  Article
//
//  Created by Dianwei on 14-3-19.
//
//

#import "SSViewBase.h"

@interface NewsDetailFunctionView : SSViewBase
@property(nonatomic, readonly)BOOL isDisplay;
@property(nonatomic, retain)NSString * umengEventName;//default is "detail"
@property(nonatomic, assign)BOOL dismissAfterChangeSetting; //default is NO

- (void)showInView:(UIView*)view atPoint:(CGPoint)point;
- (void)dismiss;
@end
