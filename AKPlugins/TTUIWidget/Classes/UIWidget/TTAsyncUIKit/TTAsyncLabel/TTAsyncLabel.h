//
//  TTAsyncLabel.h
//  Article
//
//  Created by zhaoqin on 11/11/2016.
//
//

#import <UIKit/UIKit.h>

typedef void(^TTAsyncTruncationAction)();
typedef void(^TTAsyncPrefixAction)();

@interface TTAsyncLabel : UIView

@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) UIFont *font;
@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic, assign) NSInteger numberOfLines;
@property (nonatomic, assign) NSTextAlignment textAlignment;
@property (nonatomic, assign) NSLineBreakMode lineBreakMode;
@property (nonatomic, assign) CGFloat lineSpacing;
@property (nonatomic, assign) CGFloat lineHeight;
@property (nonatomic, strong) UIColor *linkColor;
@property (nonatomic, assign) NSRange linkRange;
@property (nonatomic, strong) NSAttributedString *linkAttributed;
@property (nonatomic, strong) NSAttributedString *attributedTruncationToken;
@property (nonatomic, strong) TTAsyncTruncationAction truncationAction;
@property (nonatomic, strong) TTAsyncPrefixAction prefixAction;
@property (nonatomic, assign) BOOL displaysAsynchronously;
@property (nonatomic, assign) BOOL clearContentsBeforeAsynchronouslyDisplay;

@end
