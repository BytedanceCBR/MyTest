//
//  TTVAdActionButtonCreation.h
//  Article
//
//  Created by pei yun on 2017/4/5.
//
//

#import "TTVAdActionButton.h"
#import "TTVAdActionButtonCommand.h"
#import <TTVideoService/Enum.pbobjc.h>

extern TTVAdActionButton *getAdActionButtonInstance(TTVVideoBusinessType type);

extern id <TTVAdActionButtonCommandProtocol> getCommandInstance(TTVVideoBusinessType type);
