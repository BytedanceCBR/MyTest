//
//  ComplicationController.m
//  iWatchTest WatchKit Extension
//
//  Created by 邱鑫玥 on 16/8/16.
//  Copyright © 2016年 qiu. All rights reserved.
//

#import "ComplicationController.h"
#import "TTWatchFetchDataManager.h"
#import "TTWatchItemModel.h"
#import "TTWatchMacroDefine.h"

@interface ComplicationController ()

@end

@implementation ComplicationController

#pragma mark - Timeline Configuration

//目前没有支持time travel
- (void)getSupportedTimeTravelDirectionsForComplication:(CLKComplication *)complication withHandler:(void(^)(CLKComplicationTimeTravelDirections directions))handler {
    //handler(CLKComplicationTimeTravelDirectionForward|CLKComplicationTimeTravelDirectionBackward);
    handler(CLKComplicationTimeTravelDirectionNone);
}

//对于time travel来说才有用，相当于表明数据的有用的时间范围，超过范围的话，complication变暗
- (void)getTimelineStartDateForComplication:(CLKComplication *)complication withHandler:(void(^)(NSDate * __nullable date))handler {
    handler([NSDate date]);
}

- (void)getTimelineEndDateForComplication:(CLKComplication *)complication withHandler:(void(^)(NSDate * __nullable date))handler {
    handler([NSDate date]);
}

- (void)getPrivacyBehaviorForComplication:(CLKComplication *)complication withHandler:(void(^)(CLKComplicationPrivacyBehavior privacyBehavior))handler {
    handler(CLKComplicationPrivacyBehaviorShowOnLockScreen);
}

#pragma mark - Timeline Population
- (void)getCurrentTimelineEntryForComplication:(CLKComplication *)complication withHandler:(void(^)(CLKComplicationTimelineEntry * __nullable))handler {
    CLKComplicationTimelineEntry* entry = nil;
    
    NSDate  *now = [NSDate date];
    
    // Create the template and timeline entry.
    if (complication.family == CLKComplicationFamilyModularLarge) {
        NSError *error;
        NSData  *data = [[TTWatchFetchDataManager sharedInstance] getStoredData];
        NSArray *array = nil;
        if(data){
            NSDictionary * responseDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
            
            if(!error){
                array = [responseDict objectForKey:@"data"];
            }
        }

        __block NSString *title;
        [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                TTWatchItemModel *model = [[TTWatchItemModel alloc] initWithDict:obj];
                if(!isEmptyString(model.title)){
                    title = model.title;
                    *stop = true;
                }
        }];
        if(isEmptyString(title)){
            title = @"越看越爱看";
        }
        
        CLKComplicationTemplateModularLargeStandardBody* template =
        [[CLKComplicationTemplateModularLargeStandardBody alloc] init];
        template.headerTextProvider = [CLKTextProvider textProviderWithFormat:@"%@",@"爱看"];
        template.body1TextProvider = [CLKTextProvider textProviderWithFormat:@"%@",title];
        entry = [CLKComplicationTimelineEntry entryWithDate:now
                                       complicationTemplate:template];
    }
    else if(complication.family == CLKComplicationFamilyModularSmall){
        CLKComplicationTemplateModularSmallSimpleImage *template = [[CLKComplicationTemplateModularSmallSimpleImage alloc] init];
        template.imageProvider = [CLKImageProvider imageProviderWithOnePieceImage:[UIImage imageNamed:@"Complication/Modular"]];
        entry = [CLKComplicationTimelineEntry entryWithDate:now complicationTemplate:template];
    }
    else if(complication.family == CLKComplicationFamilyUtilitarianSmall){
        CLKComplicationTemplateUtilitarianSmallSquare *template = [[CLKComplicationTemplateUtilitarianSmallSquare alloc] init];
        template.imageProvider = [CLKImageProvider imageProviderWithOnePieceImage:[UIImage imageNamed:@"Complication/Utilitarian"]];
        entry = [CLKComplicationTimelineEntry entryWithDate:now complicationTemplate:template];
    }
    else if(complication.family == CLKComplicationFamilyUtilitarianLarge){
        CLKComplicationTemplateUtilitarianLargeFlat *template = [[CLKComplicationTemplateUtilitarianLargeFlat alloc] init];
        template.textProvider = [CLKTextProvider textProviderWithFormat:@"爱看"];
        entry = [CLKComplicationTimelineEntry entryWithDate:now
        complicationTemplate:template];
    }
    else if(complication.family == CLKComplicationFamilyCircularSmall){
        CLKComplicationTemplateCircularSmallSimpleImage *template = [[CLKComplicationTemplateCircularSmallSimpleImage alloc] init];
        template.imageProvider = [CLKImageProvider imageProviderWithOnePieceImage:[UIImage imageNamed:@"Complication/Circular"]];
        entry = [CLKComplicationTimelineEntry entryWithDate:now
                                       complicationTemplate:template];
    }
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability"
    else if(complication.family == CLKComplicationFamilyExtraLarge){
#pragma clang diagnostic pop
        Class cls = NSClassFromString(@"CLKComplicationTemplateExtraLargeSimpleImage");
        if(cls){
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability"
            CLKComplicationTemplateExtraLargeSimpleImage *template = [[cls alloc] init];
#pragma clang diagnostic pop
            template.imageProvider = [CLKImageProvider imageProviderWithOnePieceImage:[UIImage imageNamed:@"Extra"]];
            entry = [CLKComplicationTimelineEntry entryWithDate:now
                                           complicationTemplate:template];
        }
    }
    else {
        // ...configure entries for other complication families.
    }
    
    handler(entry);
}


//对于time travel来说才有用
- (void)getTimelineEntriesForComplication:(CLKComplication *)complication beforeDate:(NSDate *)date limit:(NSUInteger)limit withHandler:(void(^)(NSArray<CLKComplicationTimelineEntry *> * __nullable entries))handler {
    handler(nil);
}

//对于time travel来说才有用
- (void)getTimelineEntriesForComplication:(CLKComplication *)complication afterDate:(NSDate *)date limit:(NSUInteger)limit withHandler:(void(^)(NSArray<CLKComplicationTimelineEntry *> * __nullable entries))handler {
    handler(nil);
}

#pragma mark - Placeholder Templates
//针对watch os2
- (void)getPlaceholderTemplateForComplication:(CLKComplication *)complication withHandler:(void(^)(CLKComplicationTemplate * __nullable complicationTemplate))handler {
    // This method will be called once per supported complication, and the results will be cached
    if(complication.family == CLKComplicationFamilyModularLarge){
        CLKComplicationTemplateModularLargeStandardBody *template = [[CLKComplicationTemplateModularLargeStandardBody alloc] init];
        template.headerTextProvider = [CLKTextProvider textProviderWithFormat:@"爱看"];
        template.body1TextProvider = [CLKTextProvider textProviderWithFormat:@"越看越爱看"];
        handler(template);
    }
    else if(complication.family == CLKComplicationFamilyModularSmall){
        CLKComplicationTemplateModularSmallSimpleImage *template = [[CLKComplicationTemplateModularSmallSimpleImage alloc] init];
        template.imageProvider = [CLKImageProvider imageProviderWithOnePieceImage:[UIImage imageNamed:@"Complication/Modular"]];
        handler(template);
    }
    else if(complication.family == CLKComplicationFamilyUtilitarianSmall){
        CLKComplicationTemplateUtilitarianSmallSquare *template = [[CLKComplicationTemplateUtilitarianSmallSquare alloc] init];
        template.imageProvider = [CLKImageProvider imageProviderWithOnePieceImage:[UIImage imageNamed:@"Complication/Utilitarian"]];
        handler(template);
    }
    else if(complication.family == CLKComplicationFamilyUtilitarianLarge){
        CLKComplicationTemplateUtilitarianLargeFlat *template = [[CLKComplicationTemplateUtilitarianLargeFlat alloc] init];
        template.textProvider = [CLKTextProvider textProviderWithFormat:@"爱看"];
        handler(template);
    }
    else if(complication.family == CLKComplicationFamilyCircularSmall){
        CLKComplicationTemplateCircularSmallSimpleImage *template = [[CLKComplicationTemplateCircularSmallSimpleImage alloc] init];
        template.imageProvider = [CLKImageProvider imageProviderWithOnePieceImage:[UIImage imageNamed:@"Complication/Circular"]];
        handler(template);
    }
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability"
    else if(complication.family == CLKComplicationFamilyExtraLarge){
#pragma clang diagnostic pop
        Class cls = NSClassFromString(@"CLKComplicationTemplateExtraLargeSimpleImage");
        if(cls){
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability"
            CLKComplicationTemplateExtraLargeSimpleImage *template = [[cls alloc] init];
#pragma clang diagnostic pop
            template.imageProvider = [CLKImageProvider imageProviderWithOnePieceImage:[UIImage imageNamed:@"Extra"]];
            handler(template);
        }
        else{
            handler(nil);
        }
    }
    else{
        handler(nil);
    }
}
//针对watch os3
- (void)getLocalizableSampleTemplateForComplication:(CLKComplication *)complication withHandler:(void (^)(CLKComplicationTemplate * _Nullable))handler{
    if(complication.family == CLKComplicationFamilyModularLarge){
        CLKComplicationTemplateModularLargeStandardBody *template = [[CLKComplicationTemplateModularLargeStandardBody alloc] init];
        template.headerTextProvider = [CLKTextProvider textProviderWithFormat:@"爱看"];
        template.body1TextProvider = [CLKTextProvider textProviderWithFormat:@"越看越爱看"];
        handler(template);
    }
    else if(complication.family == CLKComplicationFamilyModularSmall){
        CLKComplicationTemplateModularSmallSimpleImage *template = [[CLKComplicationTemplateModularSmallSimpleImage alloc] init];
        template.imageProvider = [CLKImageProvider imageProviderWithOnePieceImage:[UIImage imageNamed:@"Complication/Modular"]];
        handler(template);
    }
    else if(complication.family == CLKComplicationFamilyUtilitarianSmall){
        CLKComplicationTemplateUtilitarianSmallSquare *template = [[CLKComplicationTemplateUtilitarianSmallSquare alloc] init];
        template.imageProvider = [CLKImageProvider imageProviderWithOnePieceImage:[UIImage imageNamed:@"Complication/Utilitarian"]];
        handler(template);
    }
    else if(complication.family == CLKComplicationFamilyUtilitarianLarge){
        CLKComplicationTemplateUtilitarianLargeFlat *template = [[CLKComplicationTemplateUtilitarianLargeFlat alloc] init];
        template.textProvider = [CLKTextProvider textProviderWithFormat:@"爱看"];
        handler(template);
    }
    else if(complication.family == CLKComplicationFamilyCircularSmall){
        CLKComplicationTemplateCircularSmallSimpleImage *template = [[CLKComplicationTemplateCircularSmallSimpleImage alloc] init];
        template.imageProvider = [CLKImageProvider imageProviderWithOnePieceImage:[UIImage imageNamed:@"Complication/Circular"]];
        handler(template);
    }
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability"
    else if(complication.family == CLKComplicationFamilyExtraLarge){
#pragma clang diagnostic pop
        Class cls = NSClassFromString(@"CLKComplicationTemplateExtraLargeSimpleImage");
        if(cls){
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability"
            CLKComplicationTemplateExtraLargeSimpleImage *template = [[cls alloc] init];
#pragma clang diagnostic pop
            template.imageProvider = [CLKImageProvider imageProviderWithOnePieceImage:[UIImage imageNamed:@"Extra"]];
            handler(template);
        }
        else{
            handler(nil);
        }
    }
    else{
        handler(nil);
    }
}

//#pragma mark Update Scheduling
//
//- (void)getNextRequestedUpdateDateWithHandler:(void(^)(NSDate * __nullable updateDate))handler {
//    NSDate *date = [NSDate dateWithTimeIntervalSinceNow:30*60];
//    handler(date);
//}
//
//- (void)requestedUpdateDidBegin{
//    [[CLKComplicationServer sharedInstance].activeComplications enumerateObjectsUsingBlock:^(CLKComplication * _Nonnull each, NSUInteger idx, BOOL * _Nonnull stop) {
//        [[CLKComplicationServer sharedInstance] reloadTimelineForComplication: each];
//    }];
//}
//
//- (void)requestedUpdateBudgetExhausted{
//    [[CLKComplicationServer sharedInstance].activeComplications enumerateObjectsUsingBlock:^(CLKComplication * _Nonnull each, NSUInteger idx, BOOL * _Nonnull stop) {
//        [[CLKComplicationServer sharedInstance] reloadTimelineForComplication: each];
//    }];
//}

@end
