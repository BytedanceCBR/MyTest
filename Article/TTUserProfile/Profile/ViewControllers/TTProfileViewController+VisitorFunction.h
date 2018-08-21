//
//  TTProfileViewController+VisitorFunction.h
//  Article
//
//  Created by it-test on 8/8/16.
//
//

#import "TTProfileViewController.h"


@class TTProfileHeaderVisitorView;
@interface TTProfileViewController (VisitorFunction)
- (void)visitorView:(TTProfileHeaderVisitorView *)visitorView didSelectButtonAtIndex:(NSUInteger)selectedIndex;
@end
