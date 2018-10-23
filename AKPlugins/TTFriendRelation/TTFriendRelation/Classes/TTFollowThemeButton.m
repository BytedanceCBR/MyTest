//
//  TTFollowThemeButton.m
//  Article
//
//  Created by chaisong on 2017/08/03.
//
//

#import "TTFollowThemeButton.h"

//平台化需要，所有实现参见主工程的TTFollowThemeButtonImp。
//请所有interface修改同步到TTFollowThemeButtonImp里进行处理。
@implementation TTFollowThemeButton

static Class childImpClass;

- (instancetype)initWithUnfollowedType:(TTUnfollowedType)unfollowedType followedType:(TTFollowedType)followedType {
    if (!childImpClass) {
        childImpClass = NSClassFromString(@"TTFollowThemeButtonImp");
    }
    if (childImpClass) {
        return [[childImpClass alloc] initWithUnfollowedType:unfollowedType followedType:followedType];
    }
    return [super init];
}

- (instancetype)initWithUnfollowedType:(TTUnfollowedType)unfollowedType followedType:(TTFollowedType)followedType followedMutualType:(TTFollowedMutualType)followedMutualType {
    if (!childImpClass) {
        childImpClass = NSClassFromString(@"TTFollowThemeButtonImp");
    }
    if (childImpClass) {
        return [[childImpClass alloc] initWithUnfollowedType:unfollowedType followedType:followedType followedMutualType:followedMutualType];
    }
    return [super init];
}

- (void)startLoading {
}

- (void)stopLoading:(void (^)())finishLoading {
}

- (void)refreshUI {
}

- (void)setForbidNightMode:(BOOL)forbidNightMode {
    if (_forbidNightMode != forbidNightMode) {
        _forbidNightMode = forbidNightMode;
        [self refreshUI];
    }
}

+ (TTUnfollowedType)redpacketButtonUnfollowTypeButtonStyle:(NSInteger)style defaultType:(TTUnfollowedType)defaultType {
    TTUnfollowedType type = defaultType;
    switch (style) {
        case 100:
            type = TTUnfollowedType202;
            break;
        case 101:
            type = TTUnfollowedType201;
            break;
        case 102:
            type = TTUnfollowedType204;
            break;
        case 103:
            type = TTUnfollowedType203;
            break;
        default:
            type = defaultType;
            break;
    }
    
    //保护一下
    if (type < TTUnfollowedType101
        || type > TTUnfollowedType204
        || (type < TTUnfollowedType201 && type > TTUnfollowedType103) ) {
        type = TTUnfollowedType201;
    }
    return type;
}
@end
