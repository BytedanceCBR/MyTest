//
//  TTVPlayerMacro.h
//  Article
//
//  Created by panxiang on 2018/12/11.
//

#import <Foundation/Foundation.h>

#ifndef TTVPlayerFont
#define TTVPlayerFont(fontName, fontSize) ([UIFont fontWithName:fontName size:fontSize] ?: [UIFont systemFontOfSize:fontSize])
#endif

#ifndef TTVLPlayerBoldFont
#define TTVLPlayerBoldFont(fontName, fontSize) ([UIFont fontWithName:fontName size:fontSize] ?: [UIFont boldSystemFontOfSize:fontSize])
#endif

