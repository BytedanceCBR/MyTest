//
//  TTLabel.h
//  Article
//
//  Created by 杨心雨 on 16/8/19.
//
//

#import <UIKit/UIKit.h>

@interface TTLabel : UILabel

@property (nonatomic) CGFloat firstLineIndent;
@property (nonatomic) CGFloat lineHeight;
@property (nonatomic, strong) NSString * _Nullable textColorKey;
@property (nonatomic, strong) NSString * _Nullable backgroundColorKey;
@property (nonatomic, strong) NSString * _Nullable borderColorKey;

- (void)refreshText;
- (void)sizeToFit:(CGFloat)width;

@end
