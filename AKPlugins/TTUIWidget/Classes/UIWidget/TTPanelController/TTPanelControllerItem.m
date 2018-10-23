//
//  FRPanelControllerItem.m
//  Article
//
//  Created by zhaopengwei on 15/7/26.
//
//

#import "TTPanelControllerItem.h"

@implementation TTPanelControllerItem

- (instancetype)initWithIcon:(NSString *)icon title:(NSString *)title
{
    self = [super init];
    if (self) {
        self.iconKey = icon;
        self.title = title;
        self.itemType = TTPanelControllerItemTypeIcon;
    }
    
    return self;
}

- (instancetype)initSelectedTypeIcon:(NSString *)icon title:(NSString *)title
{
    self = [self initWithIcon:icon title:title];
    self.itemType = TTPanelControllerItemTypeSelectedIcon;
    
    return self;
}

- (instancetype)initWithIcon:(NSString *)icon title:(NSString *)title block:(TTPanelButtonClick)block
{
    self = [self initWithIcon:icon title:title];
    if (self) {
        self.clickAction = block;
    }
    
    return self;
}

- (instancetype)initWithAvatar:(NSString *)url title:(NSString *)title showBorder:(BOOL)showBorder
{
    self = [super init];
    if (self) {
        self.iconKey = url;
        self.title = title;
        if (showBorder) {
            self.itemType = TTPanelControllerItemTypeAvatar;
        }else {
            self.itemType = TTPanelControllerItemTypeAvatarNoBorder;
        }
    }
    
    return self;
}

- (instancetype)initWithAvatar:(NSString *)url title:(NSString *)title showBorder:(BOOL)showBorder block:(TTPanelButtonClick)block
{
    self = [self initWithAvatar:url title:title showBorder:showBorder];
    if (self) {
        self.clickAction = block;
    }
    
    return self;
}

@end
