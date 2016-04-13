//
//  MainViewController.m
//  OCR-Sample
//
//  Created by Arai on 2016/04/13.
//  Copyright © 2016年 masato_arai. All rights reserved.
//

#import "MainViewController.h"
#import <TesseractOCR/TesseractOCR.h>

static NSString *const kG8LanguagesKeyChi_sim = @"chi_sim";
static NSString *const kG8LanguagesKeyChi_tra = @"chi_tra";
static NSString *const kG8LanguagesKeyEnglish = @"eng";
static NSString *const kG8LanguagesKeyJapanese = @"jpn";

@interface MainViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITabBarDelegate>

@end

@implementation MainViewController

- (instancetype)init {
    self = [super init];
    if (self) [self initializator];
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) [self initializator];
    return self;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) [self initializator];
    return self;
}

- (void)initializator {
    // Initialization code
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.languagesTabBar.selectedItem = self.languagesTabBar.items[G8LanguagesEnglish];
    self.languagesTabBar.delegate = self;
    self.languagesTabBar.tag = 1;
    self.languagesTabBar.hidden = YES;
    
    self.OCRTabBar.selectedItem = self.OCRTabBar.items[0];
    self.OCRTabBar.delegate = self;
    self.OCRTabBar.tag = 2;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
}


- (IBAction)cameraButtonDidTouch:(id)sender {
    UIImagePickerController *imagePickerC = [UIImagePickerController new];
    imagePickerC.delegate = self;
    imagePickerC.allowsEditing = YES;
    if ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear]) {
        imagePickerC.sourceType = UIImagePickerControllerSourceTypeCamera;
    } else {
        imagePickerC.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    }
    [self presentViewController:imagePickerC animated:YES completion:nil];
}

#pragma mark
#pragma mark <UIImagePickerControllerDelegate>

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    UIImage *editedImage = [info objectForKey:UIImagePickerControllerEditedImage];
    self.imaegView.image = editedImage;
    self.textView.text = nil;
    [self dismissViewControllerAnimated:YES completion:^{
        // TODO: a
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark
#pragma mark <UITabBarDelegate>

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
    // TODO: a
    [self.indicator startAnimating];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        G8Languages languages = self.languagesTabBar.selectedItem.tag;
        NSString *languagesKey;
        switch (languages) {
            case G8LanguagesChi_sim:
                languagesKey = kG8LanguagesKeyChi_sim;
                break;
            case G8LanguagesChi_tra:
                languagesKey = kG8LanguagesKeyChi_tra;
                break;
            case G8LanguagesEnglish:
                languagesKey = kG8LanguagesKeyEnglish;
                break;
            case G8LanguagesJapanese:
                languagesKey = kG8LanguagesKeyJapanese;
                break;
        }
        
        G8Tesseract *tesseract = [[G8Tesseract alloc] initWithLanguage:languagesKey];
        tesseract.image = self.imaegView.image;
        [tesseract recognize];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.textView.text = tesseract.recognizedText;
            [self.indicator stopAnimating];
        });
    });
}

@end
