//
//  FHFakeInputNavbar.h
//  FHCommonUI
//
//  Created by 谷春晖 on 2018/11/22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger , FHFakeInputNavbarType){
    FHFakeInputNavbarTypeDefault = 0,
    FHFakeInputNavbarTypeMap = 1
} ;

@interface FHFakeInputNavbar : UIView

+(CGFloat)perferredHeight;

-(instancetype)initWithType:(FHFakeInputNavbarType)type;

@property(nonatomic , strong) NSString *placeHolder;
@property(nonatomic , strong) NSString *inputText;
@property(nonatomic , copy) void (^defaultBackAction)();
@property(nonatomic , copy) void (^showMapAction)();
@property(nonatomic , copy) void (^tapInputBar)();

-(void)addRightItem:(UIView *)itemView;

-(void)addLeftItem:(UIView *)itemView;

-(void)refreshNavbarType:(FHFakeInputNavbarType)type;

@end

NS_ASSUME_NONNULL_END
