//
//  SSTitlePopOverView.h
//  Gallery
//
//  Created by Zhang Leonardo on 12-8-15.
//
//

#import <UIKit/UIKit.h>
#import "SSViewBase.h"

@interface SSTitlePopOverButton : UIButton

+ (id)initPopOverButton;

@end

@interface SSTitlePopOverView : SSViewBase

@property(nonatomic, retain, readonly)NSArray * popOverButtons;
@property(nonatomic, retain, readonly)UIImageView * foregroundImageView;
@property(nonatomic, retain, readonly)UIImageView * backgroundImageView;
@property(nonatomic, retain, readonly)UIImageView * contentImageView;
@property(nonatomic, retain, readonly)UILabel * titleLabel;
@property(nonatomic, retain, readonly)UIImageView * popArrowView;
@property(nonatomic, retain)NSMutableArray *separators;

@property(nonatomic, retain)NSArray * titleImages;

- (void)selectButtonContentItem:(id)sender;

- (id)initWithPopOverButtons:(NSArray *)buttons;
//- (id)initWithPopOverButtons:(NSArray *)buttons currentInterfaceOrientation:(UIInterfaceOrientation)orientation;

- (id)initWithPopOverButtons:(NSArray *)buttons titleImages:(NSArray *)images;
//- (id)initWithPopOverButtons:(NSArray *)buttons titleImages:(NSArray *)images currentInterfaceOrientation:(UIInterfaceOrientation)orientation;

@end
