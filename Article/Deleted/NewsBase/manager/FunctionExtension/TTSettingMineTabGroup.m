//
//  TTSettingMineTabGroup.m
//  Article
//
//  Created by fengyadong on 16/11/2.
//
//

#import "TTSettingMineTabGroup.h"
#import "TTSettingMineTabEntry.h"
#import "TTSettingMineTabManager.h"
#import "AKMinePhotoCarouselEntry.h"
@implementation TTSettingMineTabGroup

- (instancetype)initWithArray:(NSArray *)array {
    if (self = [super init]) {
        self.shouldBeDisplayed = YES;
        [array enumerateObjectsUsingBlock:^(TTSettingMineTabEntry * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (([obj isKindOfClass:[TTSettingMineTabEntry class]] ||
                 [obj isKindOfClass:[AKMinePhotoCarouselEntry class]]) && obj.shouldBeDisplayed) {
                [self.items addObject:obj];
            }
        }];
    }
    return self;
}

+ (instancetype)initWithGroupType:(TTSettingMineTabGroupType)type {
    TTSettingMineTabGroup *group = nil;
    switch (type) {
        case TTSettingMineTabGroupTypeiPhoneTopFuction:
            return [[self class] iPhoneTopFunctionGroup];
            break;
        case TTSettingMineTabGroupTypeiPadTopFuction:
            return [[self class] iPadTopFunctionGroup];
            break;
        case TTSettingMineTabGroupTypeMessage:
            return [[self class] messageGroup];
            break;
        case TTSettingMineTabGroupTypeMall:
            return [[self class] mallGroup];
            break;
        case TTSettingMineTabGroupTypeSettings:
            return [[self class] settingsGroup];
            break;
        case TTSettingMineTabGroupTypePhotoCarousel:
            return [[self class] photoCarouselGroup];
        default:
            break;
    }
    return group;
}

+ (instancetype)photoCarouselGroup {
    TTSettingMineTabGroup *group = [[TTSettingMineTabGroup alloc] init];
    group.key = kAKIdenfitierPhotoCarouselKey;
    group.shouldBeDisplayed = YES;
    [[self class] addEntry:TTSettingMineTabEntyTypePhotoCarousel toGroup:group];
    return group;
}

+ (instancetype)iPhoneTopFunctionGroup {
    TTSettingMineTabGroup *group = [[TTSettingMineTabGroup alloc] init];
    group.key = @"iPhoneTopFuction";
    group.shouldBeDisplayed = ![TTDeviceHelper isPadDevice];
    if (group.shouldBeDisplayed) {
    [[self class] addEntry:TTSettingMineTabEntyTypeiPhoneTopFunction toGroup:group];
    }
    
    return group;
}

+ (instancetype)iPadTopFunctionGroup {
    TTSettingMineTabGroup *group = [[TTSettingMineTabGroup alloc] init];
    group.key = @"iPadTopFunction";
    group.shouldBeDisplayed = [TTDeviceHelper isPadDevice];
    if (group.shouldBeDisplayed) {
        [[self class] addEntry:TTSettingMineTabEntyTypeiPadNightMode toGroup:group];
        [[self class] addEntry:TTSettingMineTabEntyTypeiPadFavor toGroup:group];
        [[self class] addEntry:TTSettingMineTabEntyTypeiPadHistory toGroup:group];
    }
    
    return group;
}

+ (instancetype)messageGroup {
    TTSettingMineTabGroup *group = [[TTSettingMineTabGroup alloc] init];
    group.key = @"message";
    group.shouldBeDisplayed = YES;
    [[self class] addEntry:TTSettingMineTabEntyTypeWorkLibrary toGroup:group];
    [[self class] addEntry:TTSettingMineTabEntyTypePrivateLetter toGroup:group];
    
    return group;
}

+ (instancetype)mallGroup {
    TTSettingMineTabGroup *group = [[TTSettingMineTabGroup alloc] init];
    group.key = @"mall";
    group.shouldBeDisplayed = ![TTDeviceHelper isPadDevice];
    if (group.shouldBeDisplayed) {
    [[self class] addEntry:TTSettingMineTabEntyTypeTTMall toGroup:group];
    }
    
    return group;
}

+ (instancetype)settingsGroup {
    TTSettingMineTabGroup *group = [[TTSettingMineTabGroup alloc] init];
    group.key = @"settings";
    group.shouldBeDisplayed = YES;
    [[self class] addEntry:TTSettingMineTabEntyTypeFeedBack toGroup:group];
    [[self class] addEntry:TTSettingMineTabEntyTypeSettings toGroup:group];
    return group;
}

+ (void)addEntry:(TTSettingMineTabEntyType)type toGroup:(TTSettingMineTabGroup *)group {
    TTSettingMineTabEntry *entry = [[TTSettingMineTabManager sharedInstance_tt] getEntryForType:type];
    
    //一些本地的entry无法从服务端数据中取到，只能重新new一个
    if (!entry) {
        entry = [TTSettingMineTabEntry initWithEntryType:type];
        [[TTSettingMineTabManager sharedInstance_tt] setEntry:entry ForType:type];
    }
    
    if (entry && [entry isKindOfClass:[TTSettingMineTabEntry class]]) {
        [TTSettingMineTabEntry setBlockForEntry:(TTSettingMineTabEntry *)entry];
        
        if(entry.shouldBeDisplayed && group.shouldBeDisplayed) {
            [group.items addObject:entry];
        }
    }
}

@end
