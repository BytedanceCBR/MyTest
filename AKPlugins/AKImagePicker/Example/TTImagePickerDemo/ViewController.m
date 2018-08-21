//
//  ViewController.m
//  TTImagePickerDemo
//
//  Created by SongChai on 31/05/2017.
//  Copyright © 2017 SongChai. All rights reserved.
//

#import "ViewController.h"
#import "TTImagePickerController.h"
#import <SDWebImage/SDWebImageManager.h>

@interface ViewController ()<TTImagePickerControllerDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:@"image" forState:UIControlStateNormal];
    [button setFrame:CGRectMake(20, 40, 60, 30)];
    button.backgroundColor = [UIColor blackColor];
    [self.view addSubview: button];
    [button addTarget:self action:@selector(onClickChooseImage) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton* button1 = [UIButton buttonWithType:UIButtonTypeCustom];
    [button1 setTitle:@"video" forState:UIControlStateNormal];
    [button1 setFrame:CGRectMake(20, 140, 60, 30)];
    button1.backgroundColor = [UIColor blackColor];
    [self.view addSubview: button1];
    [button1 addTarget:self action:@selector(onClickChooseVideo) forControlEvents:UIControlEventTouchUpInside];
    
    
    UIButton* button2 = [UIButton buttonWithType:UIButtonTypeCustom];
    [button2 setTitle:@"all" forState:UIControlStateNormal];
    [button2 setFrame:CGRectMake(20, 240, 60, 30)];
    button2.backgroundColor = [UIColor blackColor];
    [self.view addSubview: button2];
    [button2 addTarget:self action:@selector(onClickChooseAll) forControlEvents:UIControlEventTouchUpInside];
    
}


- (void)onClickChooseImage {
    
    [TTImagePickerManager manager].accessIcloud = YES;
    
    TTImagePickerController *imgPick = [[TTImagePickerController alloc] initWithDelegate:self];
    imgPick.maxImagesCount = 9;
    imgPick.isRequestPhotosBack = NO;
    [imgPick presentOn:self];
}

- (void)onClickChooseVideo {
    
    [TTImagePickerManager manager].accessIcloud = YES;

    TTImagePickerController *picVC = [[TTImagePickerController alloc]initWithDelegate:self];
    picVC.imagePickerMode = TTImagePickerModeVideo;
    picVC.columnNumber = 4;
    picVC.allowTakePicture = YES;
    [picVC presentOn:self];
}

- (void)onClickChooseAll
{
    
    TTImagePickerController *picVC = [[TTImagePickerController alloc]initWithDelegate:self];
    picVC.imagePickerMode = TTImagePickerModeAll;
    picVC.columnNumber = 3;
    picVC.allowTakePicture = NO;
    [picVC presentOn:self];
}

- (void)ttimagePickerController:(TTImagePickerController *)picker didFinishPickingVideo:(UIImage *)coverImage sourceAsset:(TTAssetModel *)assetModel {
    NSAssert(coverImage, @"Conver Image is empty");
    NSAssert(assetModel, @"Asset Model is empty");
}

- (void)ttimagePickerController:(TTImagePickerController *)picker didFinishPickingPhotos:(NSArray<UIImage *> *)photos sourceAssets:(NSArray<TTAssetModel *> *)assets {
    [[TTImagePickerManager manager] getPhotosWithAssets:assets completion:^(NSArray<UIImage *> *photos) {
        UIImage* image = photos.firstObject;
        /**
        for (int i =0; i< 100;i++) {
            [[SDWebImageManager sharedManager] saveImageToCache:image forURL:[NSURL URLWithString:[NSString stringWithFormat:@"frfake://%p.png",image]]];
        }
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            for (int i =0; i< 100;i++) {
                @autoreleasepool {
                  NSData* data = UIImageJPEGRepresentation(image, 1.0);
                  NSLog(@"data size:%d" , data.length);
                }
            }
            
        });
        **/
        for (int i =0; i< 20;i++) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSData* data = UIImageJPEGRepresentation(image, 1.0);
                NSLog(@"data size:%lu" , (unsigned long)data.length);
            });
        }
    }];
}

- (void)ttimagePickerController:(TTImagePickerController *)picker didFinishTakePhoto:(UIImage *)photo selectedAssets:(NSArray<TTAssetModel *> *)assets withInfo:(NSDictionary *)info {
    NSAssert(photo, @"Photo is empty");
}

- (void)ttImagePickerControllerDidCancel:(TTImagePickerController *)picker {
}

- (void)ttimagePickerController:(TTImagePickerController *)picker didFinishPickerPhotosAndVideoWithSourceAssets:(NSArray<TTAssetModel *> *)assets
{
    NSAssert(assets.count, @"Assets is empty");
}

@end
