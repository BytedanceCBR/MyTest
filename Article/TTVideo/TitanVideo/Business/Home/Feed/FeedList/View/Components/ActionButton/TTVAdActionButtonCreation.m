//
//  TTVAdActionButtonCreation.m
//  Article
//
//  Created by pei yun on 2017/4/5.
//
//

#import "TTVAdActionButtonCreation.h"

TTVAdActionButton *getAdActionButtonInstance(TTVVideoBusinessType type) {
    TTVAdActionButton *button = nil;
    switch (type) {
        case TTVVideoBusinessType_PicAdapp:
        case TTVVideoBusinessType_VideoAdapp:
            button = [[TTVAdActionTypeAppButton alloc] init];
            button.ttv_command = [[TTVAdActionTypeAppButtonCommand alloc] init];
            break;
        case TTVVideoBusinessType_PicAdweb:
        case TTVVideoBusinessType_VideoAdweb:
            button = [[TTVAdActionTypeWebButton alloc] init];
            button.ttv_command = [[TTVAdActionTypeWebButtonCommand alloc] init];
            break;
        case TTVVideoBusinessType_PicAdphone:
        case TTVVideoBusinessType_VideoAdphone:
            button = [[TTVAdActionTypePhoneButton alloc] init];
            button.ttv_command = [[TTVAdActionTypePhoneButtonCommand alloc] init];
            break;
        case TTVVideoBusinessType_PicAdform:
        case TTVVideoBusinessType_VideoAdform:
            button = [[TTVAdActionTypeFormButton alloc] init];
            button.ttv_command = [[TTVAdActionTypeFormButtonCommand alloc] init];
            break;

        case TTVVideoBusinessType_PicAdcounsel:
        case TTVVideoBusinessType_VideoAdcounsel:
            button = [[TTVAdActionTypeCounselButton alloc] init];
            button.ttv_command = [[TTVAdActionTypeCounselButtonCommand alloc] init];
            break;
        case TTVVideoBusinessType_Adnormal:
            button = [[TTVAdActionTypeNormalButton alloc] init];
            button.ttv_command = [[TTVAdActionTypeNormalButtonCommand alloc] init];
            break;
        default:
            button = [[TTVAdActionTypeAppButton alloc] init];
            button.ttv_command = [[TTVAdActionTypeAppButtonCommand alloc] init];
            break;
    }
    return button;
}

extern id <TTVAdActionButtonCommandProtocol> getCommandInstance(TTVVideoBusinessType type)
{
    id <TTVAdActionButtonCommandProtocol> command = nil;
    switch (type) {
        case TTVVideoBusinessType_PicAdapp:
        case TTVVideoBusinessType_VideoAdapp:
            command = [[TTVAdActionTypeAppButtonCommand alloc] init];
            break;
        case TTVVideoBusinessType_PicAdweb:
        case TTVVideoBusinessType_VideoAdweb:
            command = [[TTVAdActionTypeWebButtonCommand alloc] init];
            break;
        case TTVVideoBusinessType_PicAdphone:
        case TTVVideoBusinessType_VideoAdphone:
            command = [[TTVAdActionTypePhoneButtonCommand alloc] init];
            break;
        case TTVVideoBusinessType_PicAdform:
        case TTVVideoBusinessType_VideoAdform:
            command = [[TTVAdActionTypeFormButtonCommand alloc] init];
            break;

        case TTVVideoBusinessType_PicAdcounsel:
        case TTVVideoBusinessType_VideoAdcounsel:
            command = [[TTVAdActionTypeCounselButtonCommand alloc] init];
            break;
        case TTVVideoBusinessType_Adnormal:
            command = [[TTVAdActionTypeNormalButtonCommand alloc] init];
            break;
        default:
            command = [[TTVAdActionTypeAppButtonCommand alloc] init];
            break;
    }
    return command;
}
