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
    
    self.selectedImage = self.imaegView.image;
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
    self.selectedImage = [info objectForKey:UIImagePickerControllerEditedImage];
    self.imaegView.image = self.selectedImage;
    self.textView.text = nil;
    [self dismissViewControllerAnimated:YES completion:^{
        [self detectAndRecognize];
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark
#pragma mark <UITabBarDelegate>

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
    [self detectAndRecognize];
}

- (void)detectAndRecognize {
    [self.indicator startAnimating];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        // 文字列の検出と着色
        self.detectedImage = [self detectTextImageWithImage:self.selectedImage];
        
        // 文字列の取得
        G8Tesseract *tesseract = [self tesseractWithLanguage:self.selectedlanguagesKey image:self.selectedImage];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            // 着色画像の反映
            self.imaegView.image = self.detectedImage;
            // 文字列の反映
            self.textView.text = tesseract.recognizedText;
            
            [self.indicator stopAnimating];
        });
    });
}

- (NSString *)selectedlanguagesKey {
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
    
    return languagesKey;
}

- (G8Tesseract *)tesseractWithLanguage:(NSString *)language image:(UIImage *)image {
    G8Tesseract *tesseract = [[G8Tesseract alloc] initWithLanguage:language];
    tesseract.image = image;
    [tesseract recognize];
    
    return tesseract;
}

- (UIImage *)detectTextImageWithImage:(UIImage *)image {
    CIImage *ciImage = [CIImage imageWithCGImage:image.CGImage];
    
    CIDetector *icDetector = [CIDetector detectorOfType:CIDetectorTypeText context:nil options:nil];
    NSArray *features = [icDetector featuresInImage:ciImage options:@{CIDetectorReturnSubFeatures: @YES}];
    
    UIGraphicsBeginImageContextWithOptions(image.size, NO, 0);
    [image drawInRect:CGRectMake(0, 0, image.size.width, image.size.height)];
    
    for (CITextFeature *feature in features) {
        CGContextRef drawContext = UIGraphicsGetCurrentContext();
        CGContextSetLineWidth(drawContext, 3.f);
        
        // Y座標が逆になるので変換
        CGRect textRext = feature.bounds;
        textRext.origin.y = image.size.height - (textRext.origin.y + textRext.size.height);
        
        // 線でテキストを囲む
        CGContextSetStrokeColorWithColor(drawContext, [UIColor blueColor].CGColor);
        CGContextStrokeRect(drawContext, textRext);
        
        // subFeaturesのチェック
        CGContextSetStrokeColorWithColor(drawContext, [UIColor greenColor].CGColor);
        for (CITextFeature *subFeature in feature.subFeatures) {
            CGRect subTextRext = subFeature.bounds;
            subTextRext.origin.y = image.size.height - (subTextRext.origin.y + subTextRext.size.height);
            CGContextStrokeRect(drawContext, subTextRext);
        }
    }
    
    UIImage *drawedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return drawedImage;
}

@end
