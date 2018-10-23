//
//  HTSPanelControllerItem.m
//  Article
//
//  Created by 王霖 on 16/6/24.
//
//

#import "HTSPanelControllerItem.h"

@implementation HTSPanelControllerItem

- (instancetype)initWithIcon:(NSString *)icon title:(NSString *)title
{
    self = [super init];
    if (self) {
        self.iconKey = icon;
        self.title = title;
        self.itemType = HTSPanelControllerItemTypeIcon;
    }
    
    return self;
}

- (instancetype)initSelectedTypeIcon:(NSString *)icon title:(NSString *)title
{
    self = [self initWithIcon:icon title:title];
    self.itemType = HTSPanelControllerItemTypeSelectedIcon;
    
    return self;
}

- (instancetype)initWithIcon:(NSString *)icon title:(NSString *)title block:(HTSPanelButtonClick)block
{
    self = [self initWithIcon:icon title:title];
    if (self) {
        self.clickAction = block;
    }
    
    return self;
}

- (instancetype)initWithAvatar:(NSString *)url title:(NSString *)title
{
    self = [super init];
    if (self) {
        self.iconKey = url;
        self.title = title;
        self.itemType = HTSPanelControllerItemTypeAvatar;
    }
    
    return self;
}

- (instancetype)initWithAvatar:(NSString *)url title:(NSString *)title block:(HTSPanelButtonClick)block
{
    self = [self initWithAvatar:url title:title];
    if (self) {
        self.clickAction = block;
    }
    
    return self;
}

@end
