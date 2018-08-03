//
//  TTAdCanvasLayoutModel.m
//  Article
//
//  Created by yin on 2017/3/27.
//
//

#import "TTAdCanvasLayoutModel.h"

@implementation TTAdCanvasLayoutModel

+ (JSONKeyMapper *)keyMapper{
    return [[JSONKeyMapper alloc]initWithDictionary:@{@"auto":@"autoplay"}];
}

+ (BOOL)propertyIsOptional:(NSString *)propertyName {
    return YES;
}

- (TTAdCanvasItemType)itemType
{
    if ([self.name isEqualToString:@"RCTParagraphx"]) {
        return TTAdCanvasItemType_Text;
    }
    else if ([self.name isEqualToString:@"RCTPicturex"]) {
        return TTAdCanvasItemType_Image;
    }
    else if ([self.name isEqualToString:@"RCTSliderx"]) {
        return TTAdCanvasItemType_LoopPic;
    }
    else if ([self.name isEqualToString:@"RCTPanoramax"]) {
        return TTAdCanvasItemType_FullPic;
    }
    else if ([self.name isEqualToString:@"RCTVideox"]) {
        return TTAdCanvasItemType_Video;
    }
    else if ([self.name isEqualToString:@"RCTLivex"]) {
        return TTAdCanvasItemType_Live;
    }
    else if ([self.name isEqualToString:@"RCTButtonx"]) {
        return TTAdCanvasItemType_Button;
    }
    else if ([self.name isEqualToString:@"RCTDownloadbuttonx"]) {
        return TTAdCanvasItemType_DownloadButton;
    }
    else if ([self.name isEqualToString:@"RCTTelbuttonx"]) {
        return TTAdCanvasItemType_PhoneButton;
    }
    return TTAdCanvasItemType_Image;
}


- (BOOL)isInValidComponent
{
    NSArray* nameList = @[@"RCTParagraphx", @"RCTPicturex", @"RCTSliderx", @"RCTPanoramax", @"RCTVideox", @"RCTLivex", @"RCTButtonx", @"RCTDownloadbuttonx", @"RCTTelbuttonx"];
    return [nameList containsObject:self.name];
}

@end

@implementation TTAdCanvasLayoutStyleModel

- (NSTextAlignment)textAlignment
{
    if ([self.textAlign isEqualToString:@"center"]) {
        return NSTextAlignmentCenter;
    }
    else if ([self.textAlign isEqualToString:@"left"]) {
        return NSTextAlignmentLeft;
    }
    else if ([self.textAlign isEqualToString:@"right"]) {
        return NSTextAlignmentRight;
    }
    return NSTextAlignmentCenter;
}

@end

@implementation TTAdCanvasLayoutDataModel

- (BOOL)isFullScreen
{
    if ([self.portraitMode isEqualToString:@"vertical"]) {
        return YES;
    }
    return NO;
}

@end


@implementation TTAdCanvasJsonLayoutModel

@end
