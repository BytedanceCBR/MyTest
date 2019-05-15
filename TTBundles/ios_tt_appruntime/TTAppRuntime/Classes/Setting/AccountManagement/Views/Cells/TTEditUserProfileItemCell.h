//
//  TTEditUserProfileItemCell.h
//  Article
//
//  Created by Zuopeng Liu on 7/15/16.
//
//

#import <UIKit/UIKit.h>
#import "TTBaseUserProfileCell.h"
#import "SSAvatarView.h"


@interface TTUserProfileItem : NSObject
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, copy) NSString *titleThemeKey;   // default is kColorText1
@property (nonatomic, copy) NSString *contentThemeKey;// default is kColorText3
/**
 个人主页native新增
 */
@property (nonatomic, copy) NSString *birthday;
@property (nonatomic, copy) NSString *area;
@property (nonatomic, copy) NSString *industry;
@property (nonatomic, strong) NSNumber *gender;

@property (nonatomic,   copy) NSString *imageURLName;
@property (nonatomic, strong) UIImage  *image;
@property (nonatomic, assign) SSAvatarViewStyle avatarStyle; //default is SSAvatarViewStyleRound

@property (nonatomic, assign) BOOL isAuditing;    // default is NO
@property (nonatomic, assign) BOOL hiddenContent; // default is NO;
@property (nonatomic, assign) BOOL animating;     // default is NO
@property (nonatomic, assign) BOOL editEnabled;   // default is YES
@end


@interface TTEditUserProfileItemCell : TTBaseUserProfileCell
- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier;

- (void)reloadWithProfileItem:(TTUserProfileItem *)item;

- (void)startAnimating;
- (void)stopAnimating;
- (void)hiddenArrowImage;
@end
