//
//  ArticleAccountLoginView.h
//  Article
//
//  Created by Dianwei on 13-5-7.
//
//

#import <UIKit/UIKit.h>
#import <SSViewBase.h>
#import "ArticleMobileViewController.h"



@class NewAuthorityView;
@protocol NewAuthorityViewDelegate <NSObject>
@optional
- (void)introduceViewLoginFinished:(NewAuthorityView*)introdceView;
- (void)introduceViewLoginFailed:(NewAuthorityView*)introdceView;
- (void)introduceViewLoginCancelled:(NewAuthorityView*)introduceView;

@end

@interface NewAuthorityView : SSViewBase

typedef NS_ENUM(NSUInteger, NewAuthorityViewType)
{
    AuthorityViewNormal = 0,
    AuthorityViewIntroduce = 1
};

@property(nonatomic, retain)NSString * umengEventName;//default is @"login"

@property(nonatomic, weak)NSObject<NewAuthorityViewDelegate> *delegate;

@property(nonatomic, assign)BOOL showLoginIndicator;//default is NO

- (id)initWithFrame:(CGRect)frame type:(NewAuthorityViewType)type;

@property (nonatomic, copy) ArticleMobilePiplineCompletion  completion;

@end
