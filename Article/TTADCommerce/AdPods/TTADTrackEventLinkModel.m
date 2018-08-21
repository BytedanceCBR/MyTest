//
//  TTADTrackEventLinkModel.m
//  Article
//
//  Created by ranny_90 on 2017/5/19.
//
//

#import "TTADTrackEventLinkModel.h"
#import "TTInstallIDManager.h"
#import "NSStringAdditions.h"
#import <TTBaseLib/JSONAdditions.h>
#import <TTBaseLib/TTBaseMacro.h>

@interface TTADTrackEventLinkModel ()

@property (nonatomic,copy) NSString *showEventID;

@property (nonatomic,copy) NSString *clickEventID;

@property (nonatomic,copy) NSString *clickButtonEventID;

@property (nonatomic,copy) NSString *clickStartEventID;

@property (nonatomic,copy) NSString *clickCounselEventID;

@property (nonatomic,copy) NSString *clickCallEventID;

@property (nonatomic,copy) NSString *openEventID;

@property (nonatomic,copy) NSString *showOverEventID;

@end

@implementation TTADTrackEventLinkModel


-(void)updateShowEventIDWithTag:(NSString *)tag{
    
    self.showEventID = [self createEventMD5IdWithEvent:@"show" WithTag:tag];
}


-(void)updateClickEventIDWithTag:(NSString *)tag{
   self.clickEventID = [self createEventMD5IdWithEvent:@"click" WithTag:tag];
}


-(void)updateClickButtonEventIDWithTag:(NSString *)tag{
   self.clickButtonEventID = [self createEventMD5IdWithEvent:@"click_button" WithTag:tag];
}


-(void)updateClickStartEventIDWithTag:(NSString *)tag{
    
   self.clickStartEventID = [self createEventMD5IdWithEvent:@"click_start" WithTag:tag];
    
}

-(void)updateClickCounselEventIDWithTag:(NSString *)tag{
   self.clickCounselEventID = [self createEventMD5IdWithEvent:@"click_counsel" WithTag:tag];
}

-(void)updateClickCallEventIDWithTag:(NSString *)tag{
    self.clickCallEventID = [self createEventMD5IdWithEvent:@"click_call" WithTag:tag];
}

-(void)updateOpenEventIDWithTag:(NSString *)tag{
   self.openEventID = [self createEventMD5IdWithEvent:@"open" WithTag:tag];
}

-(void)updateShowOverEventIDWithTag:(NSString *)tag{
    self.showOverEventID = [self createEventMD5IdWithEvent:@"show_over" WithTag:tag];
}

-(NSString *)createEventMD5IdWithEvent:(NSString *)event WithTag:(NSString *)tag{
    
    if (isEmptyString(event)) {
        return nil;
    }
    
    NSString *log_extra = self.logExtra ? self.logExtra : @"";
    
    NSString *cid = self.adID ? self.adID : @"";
    
    NSString *did = [[TTInstallIDManager sharedInstance] deviceID];
    did = did ? did : @"";
    
    NSTimeInterval time = [[NSDate date] timeIntervalSince1970];
    NSString *timeString = [NSString stringWithFormat:@"%@",@(time)];
    timeString = timeString ? timeString : @"";
    
    NSString *tagStr = tag ? tag : @"";
    
    NSString *label = event ? event : @"";
    
    NSString *eventCurrentString = [NSString stringWithFormat:@"%@%@%@%@%@%@",log_extra,cid,did,timeString,label,tagStr];
    
    NSString *eventMD5Str = [eventCurrentString MD5HashString];
    
    return eventMD5Str;

}

-(NSString *)currentEventIdWithTag:(NSString *)tag WithLabel:(NSString *)label{
    
    if (isEmptyString(label)) {
        return nil;
    }
    
    NSString *currentEventId = nil;
    
    if ([label isEqualToString:@"show"]) {
        
        [self updateShowEventIDWithTag:tag];
        currentEventId = self.showEventID;
    }
    
    else if ([label isEqualToString:@"click"]){
        
        [self updateClickEventIDWithTag:tag];
        currentEventId = self.clickEventID;
        
    }
    else if ([label isEqualToString:@"click_start"]){
        [self updateClickStartEventIDWithTag:tag];
        currentEventId = self.clickStartEventID;
        
    }
    else if ([label isEqualToString:@"click_call"]){
        [self updateClickCallEventIDWithTag:tag];
        currentEventId = self.clickCallEventID;
        
    }
    else if ([label isEqualToString:@"click_button"]){
        [self updateClickButtonEventIDWithTag:tag];
        currentEventId = self.clickButtonEventID;
        
    }
    else if ([label isEqualToString:@"click_counsel"]){
        [self updateClickCounselEventIDWithTag:tag];
        currentEventId = self.clickCounselEventID;
        
    }
    else if ([label isEqualToString:@"open"]){
        [self updateOpenEventIDWithTag:tag];
        currentEventId = self.openEventID;
        
    }
    else if ([label isEqualToString:@"show_over"]){
        [self updateShowOverEventIDWithTag:tag];
        currentEventId = self.showOverEventID;
    }
    
    return currentEventId;
}



-(NSString *)superEventIdWithLabel:(NSString *)label{
    
    if (isEmptyString(label)) {
        return nil;
    }
    
    //为event关联填充superid与currentid
    NSString *superEventId = nil;
    if ([label isEqualToString:@"show"]) {
        
        superEventId = nil;
    }
    
    else if ([label isEqualToString:@"click"]){
        
        superEventId = self.showEventID;
        
    }
    else if ([label isEqualToString:@"click_start"]){

        superEventId = self.showEventID;
        
    }
    else if ([label isEqualToString:@"click_call"]){
        superEventId = self.showEventID;
        
    }
    else if ([label isEqualToString:@"click_button"]){
        superEventId = self.showEventID;
    }
    else if ([label isEqualToString:@"click_counsel"]){

        superEventId = self.showEventID;
        
    }
    else if ([label isEqualToString:@"open"]){
        superEventId = self.showEventID;
        
    }
    else if ([label isEqualToString:@"show_over"]){
        superEventId = self.showEventID;
    }
    
    return superEventId;
}

-(NSDictionary *)adEventLinkDictionaryWithTag:(NSString *)tag WithLabel:(NSString *)label{
    
    if (isEmptyString(label)) {
        return nil;
    }
    
    NSString *superEventId = nil;
    NSString *currentEventId = nil;

    //为event关联填充superid与currentid

    currentEventId = [self currentEventIdWithTag:tag WithLabel:label];
    superEventId = [self superEventIdWithLabel:label];
    
    if (isEmptyString(currentEventId) && isEmptyString(superEventId)) {
        return nil;
    }
    
    NSMutableDictionary *eventLinkDic = [[NSMutableDictionary alloc] init];
    if (!isEmptyString(currentEventId)) {
        [eventLinkDic setValue:currentEventId forKey:@"event_id"];
    }
    if (!isEmptyString(superEventId)) {
        [eventLinkDic setValue:superEventId forKey:@"super_id"];
    }
    
    if (!SSIsEmptyDictionary(eventLinkDic)) {
        return eventLinkDic;
    }
    
    return nil;
    
}

-(NSString *)adEventLinkJsonStringWithTag:(NSString *)tag WithLabel:(NSString *)label{
    if (isEmptyString(label)) {
        return nil;
    }
    
    NSDictionary *eventLinkDic = [self adEventLinkDictionaryWithTag:tag WithLabel:label];
    if (!SSIsEmptyDictionary(eventLinkDic)) {
    
        NSString *eventLinkJsonString = [eventLinkDic tt_JSONRepresentation];
        
        if (!isEmptyString(eventLinkJsonString)) {
            return eventLinkJsonString;
        }
    }
        
        return nil;
}


-(NSString *)webPageEventLinkLogExtra{
    
    NSString *logExtraString = self.logExtra;
    
    if (!isEmptyString(self.clickEventID)) {
        
        NSString *superEventId = self.clickEventID;
        
        NSMutableDictionary *mutableLogExtraJsonDic = [[NSMutableDictionary alloc] init];
        NSError *error = nil;
        
        if (!isEmptyString(self.logExtra)) {
            
            NSDictionary *logExtraJsonDic = [NSString tt_objectWithJSONString:self.logExtra error:&error];
            if (!SSIsEmptyDictionary(logExtraJsonDic)) {
                [mutableLogExtraJsonDic addEntriesFromDictionary:logExtraJsonDic];
            }
        }
        
        if (!error && !isEmptyString(superEventId)) {
            if (!isEmptyString(superEventId)) {
                
                [mutableLogExtraJsonDic setValue:superEventId forKey:@"super_id"];
            }
            
            if (!SSIsEmptyDictionary(mutableLogExtraJsonDic)) {
                logExtraString = [mutableLogExtraJsonDic tt_JSONRepresentation];
            }
            
            if (isEmptyString(logExtraString)) {
                logExtraString = self.logExtra;
            }
        }
        
        else {
            logExtraString = self.logExtra;
        }
        
    }
    
    else {
        logExtraString = self.logExtra;
    }
    
    return logExtraString;
    
}

-(NSString *)webPageEventLinkExtraData{
    NSString *extraData = nil;
    if (!isEmptyString(self.clickEventID)) {
        
        NSMutableDictionary *eventLinkDic = [[NSMutableDictionary alloc] init];
        [eventLinkDic setValue:self.clickEventID forKey:@"super_id"];
        if (!SSIsEmptyDictionary(eventLinkDic)) {
            extraData = [eventLinkDic tt_JSONRepresentation];
            
            if (!isEmptyString(extraData)) {
                return extraData;
            }
        }
        
    }
    
    return nil;
}



@end
