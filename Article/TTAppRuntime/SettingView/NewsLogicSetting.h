//
//  NewsLogicSetting.h
//  Article
//
//  Created by Hu Dianwei on 6/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

typedef enum FontType
{
    FontTypeNormal = 0,
    FontTypeLarge,
    FontTypeSmall
}FontType;

typedef enum ReadMode
{
    ReadModeTitle,
    ReadModeAbstract
}ReadMode;

@interface NewsLogicSetting: NSObject{
    
}

+ (ReadMode)userSetReadMode;
+ (void)setReadMode:(ReadMode)mode;

+ (BOOL)shouldDisplayNewIndicator;
+ (BOOL)shouldDisplayNewIndicatorForPad;
+ (BOOL)hasSetReadModeForPad;
+ (void)setHasSetReadModeForPad:(BOOL)value;

+ (BOOL)hasDisplayChannelGuide;
+ (void)setHasDisplayChannelGuide:(BOOL)has;


@end
