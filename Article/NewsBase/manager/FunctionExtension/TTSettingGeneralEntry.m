//
//  TTSettingGeneralEntry.m
//  Article
//
//  Created by fengyadong on 16/11/2.
//
//

#import "TTSettingGeneralEntry.h"
#import "ArticleBadgeManager.h"
#import "TTSettingMineTabManager.h"

@implementation TTSettingGeneralEntry

#pragma mark -- Setters

- (void)setShouldBeDisplayed:(BOOL)shouldBeDisplayed {
    if (_shouldBeDisplayed != shouldBeDisplayed) {
        self.modified = YES;
    }
    _shouldBeDisplayed = shouldBeDisplayed;
}

- (void)setHintStyle:(TTSettingHintStyle)hintStyle {
    if (_hintStyle != hintStyle) {
        self.modified = YES;
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:kArticleBadgeManagerRefreshedNotification object:self userInfo:nil];
        });
    }
    _hintStyle = hintStyle;
}

- (void)setHintCount:(long long)hintCount {
    if (_hintCount != hintCount) {
        self.modified = YES;
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:kArticleBadgeManagerRefreshedNotification object:self userInfo:nil];
        });
    }
    _hintCount = hintCount;
}

- (void)setText:(NSString *)text {
    if (!isEmptyString(text) && ![_text isEqualToString:text]) {
        self.modified = YES;
    }
    _text = text;
}

- (void)setAccessoryText:(NSString *)accessoryText {
    if (!isEmptyString(accessoryText) && ![_accessoryText isEqualToString:accessoryText]) {
        self.modified = YES;
    }
    _accessoryText = accessoryText;
}

- (void)setAccessoryTextColor:(NSString *)accessoryTextColor
{
    if (!isEmptyString(accessoryTextColor) && ![_accessoryTextColor isEqualToString:accessoryTextColor]) {
        self.modified = YES;
    }
    _accessoryTextColor = accessoryTextColor;
}

#pragma mark -- NSCoding

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if(self) {
        self.key = [aDecoder decodeObjectForKey:@"key"];
        self.shouldBeDisplayed = [[aDecoder decodeObjectForKey:@"should_be_displayed"] boolValue];
        self.hintStyle = [[aDecoder decodeObjectForKey:@"hint_style"] integerValue];
        self.hintCount = [[aDecoder decodeObjectForKey:@"hint_count"] longLongValue];
        self.urlString = [aDecoder decodeObjectForKey:@"url"];
        self.text = [aDecoder decodeObjectForKey:@"text"];
        self.accessoryText = [aDecoder decodeObjectForKey:@"accessory_text"];
        self.accessoryTextColor = [aDecoder decodeObjectForKey:@"accessory_text_color"];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.key forKey:@"key"];
    [aCoder encodeObject:@(self.shouldBeDisplayed) forKey:@"should_be_displayed"];
    [aCoder encodeObject:@(self.hintStyle) forKey:@"hint_style"];
    [aCoder encodeObject:@(self.hintCount) forKey:@"hint_count"];
    [aCoder encodeObject:self.urlString forKey:@"url"];
    [aCoder encodeObject:self.text forKey:@"text"];
    [aCoder encodeObject:self.accessoryText forKey:@"accessory_text"];
    [aCoder encodeObject:self.accessoryTextColor forKey:@"accessory_text_color"];
}

#pragma mark -- Public Method

- (void)clearHint
{
    self.hintStyle = TTSettingHintStyleNone;
    self.hintCount = 0;
    [[TTSettingMineTabManager sharedInstance_tt] saveMineTabGroups];
}

@end
