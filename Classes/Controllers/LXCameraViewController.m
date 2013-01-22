//
//  luxeysCameraViewController.m
//  Latte
//
//  Created by Xuan Dung Bui on 7/20/12.
//  Copyright (c) 2012 LUXEYS. All rights reserved.
//

#import "LXCameraViewController.h"
#import "LXAppDelegate.h"

#define kAccelerometerFrequency        10.0 //Hz

@interface LXCameraViewController ()

@end

@implementation LXCameraViewController

@synthesize scrollEffect;
@synthesize viewCamera;
@synthesize viewTimer;
@synthesize buttonCapture;
@synthesize buttonYes;
@synthesize buttonNo;
@synthesize buttonTimer;
@synthesize buttonFlash;
@synthesize buttonFlash35;
@synthesize buttonFlip;
@synthesize buttonReset;
@synthesize buttonPickTop;

@synthesize gesturePan;
@synthesize viewBottomBar;
@synthesize imageAutoFocus;
@synthesize buttonPick;
@synthesize delegate;
@synthesize buttonSetNoTimer;
@synthesize buttonSetTimer5s;
@synthesize tapFocus;
@synthesize tapCloseHelp;

@synthesize buttonToggleFocus;
@synthesize buttonToggleEffect;
@synthesize buttonToggleBasic;
@synthesize buttonToggleLens;
@synthesize buttonToggleText;

@synthesize buttonBackgroundNatual;
@synthesize switchGain;

@synthesize buttonBlurNone;
@synthesize buttonBlurNormal;
@synthesize buttonBlurStrong;
@synthesize buttonBlurWeak;

@synthesize buttonLensNormal;
@synthesize buttonLensWide;
@synthesize buttonLensFish;

@synthesize buttonClose;
@synthesize viewHelp;
@synthesize viewPopupHelp;
@synthesize viewCameraWraper;
@synthesize viewDraw;
@synthesize scrollFont;

@synthesize viewBasicControl;
@synthesize viewFocusControl;
@synthesize viewLensControl;
@synthesize viewTextControl;
@synthesize viewEffectControl;

@synthesize viewCanvas;

@synthesize viewTopBar;
@synthesize viewTopBar35;

@synthesize sliderExposure;
@synthesize sliderVignette;
@synthesize sliderSharpness;
@synthesize sliderClear;
@synthesize sliderSaturation;
@synthesize sliderFeather;
@synthesize sliderEffectIntensity;

@synthesize textText;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        isEditing = false;
        
        viewDraw.isEmpty = YES;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // LAShare
    laSharekit = [[LXShare alloc] init];
    laSharekit.controller = self;
    
    // COMPLETION BLOCKS
    [laSharekit setCompletionDone:^{
        TFLog(@"Share OK");
    }];
    [laSharekit setCompletionCanceled:^{
        TFLog(@"Share Canceled");
    }];
    [laSharekit setCompletionFailed:^{
        TFLog(@"Share Failed");
    }];
    [laSharekit setCompletionSaved:^{
        TFLog(@"Share Saved");
    }];
    
    isKeyboard = NO;
    
    UIImage *imageCanvas = [[UIImage imageNamed:@"bg_canvas.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(8, 8, 8, 8)];
    viewCanvas.image = imageCanvas;
    
    viewPopupHelp.layer.cornerRadius = 10.0;
    viewPopupHelp.layer.borderWidth = 1.0;
    viewPopupHelp.layer.borderColor = [[UIColor colorWithWhite:1.0 alpha:0.25] CGColor];
    
    viewCameraWraper.layer.masksToBounds = NO;
    viewCameraWraper.layer.shadowColor = [UIColor blackColor].CGColor;
    viewCameraWraper.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
    viewCameraWraper.layer.shadowOpacity = 1.0;
    viewCameraWraper.layer.shadowRadius = 5.0;
    
    isSaved = true;
    viewDraw.delegate = self;
    viewDraw.lineWidth = 10.0;
    currentTab = kTabPreview;
    currentEffect = 0;
    currentLens = 0;
    currentTimer = kTimerNone;
    
    HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:HUD];
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(keyboardWillShow:) name: UIKeyboardWillShowNotification object:nil];
    [nc addObserver:self selector:@selector(keyboardWillHide:) name: UIKeyboardWillHideNotification object:nil];
    [nc addObserver:self selector:@selector(appBecomeActive:) name: @"BecomeActive" object:nil];
    [nc addObserver:self selector:@selector(appResignActive:) name: @"ResignActive" object:nil];
    
	// Do any additional setup after loading the view.
    // Setup filter
    uiWrap = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 480, 640)];
    timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 600, 600)];
    timeLabel.textAlignment = UITextAlignmentCenter;
    timeLabel.backgroundColor = [UIColor clearColor];
    timeLabel.textColor = [UIColor whiteColor];
    timeLabel.shadowColor = [UIColor blackColor];
    timeLabel.shadowOffset = CGSizeMake(0, 1);
    [uiWrap addSubview:timeLabel];
    
    pipe = [[GPUImageFilterPipeline alloc] init];
    pipe.filters = [[NSMutableArray alloc] init];
    pipe.output = viewCamera;
    filter = [[LXFilterDetail alloc] init];
    filterSharpen = [[GPUImageSharpenFilter alloc] init];
    pictureDOF = [[GPUImageRawDataInput alloc] initWithBytes:nil size:CGSizeMake(0, 0)];
    filterText = [[GPUImageAlphaBlendFilter alloc] init];
    filterText.mix = 1.0;
    filterCrop = [[GPUImageCropFilter alloc] init];
    filterDistord = [[GPUImagePinchDistortionFilter alloc] init];
    filterIntensity = [[GPUImageAlphaBlendFilter alloc] init];
    
//    uiElement = [[GPUImageUIElement alloc] initWithView:uiWrap];
    filterIntensity.mix = 0.0;

    filterFish = [[LXFilterFish alloc] init];
    filterDOF = [[LXFilterDOF alloc] init];
    
    effectManager = [[FilterManager alloc] init];
    
    videoCamera = [[GPUImageStillCamera alloc] initWithSessionPreset:AVCaptureSessionPresetPhoto cameraPosition:AVCaptureDevicePositionBack];
    [videoCamera setOutputImageOrientation:UIInterfaceOrientationPortrait];
    
    imagePicker = [[UIImagePickerController alloc]init];
    [imagePicker.navigationBar setBackgroundImage:[UIImage imageNamed: @"bg_head.png"] forBarMetrics:UIBarMetricsDefault];
    
    imagePicker.delegate = (id)self;
    
    // GPS Info
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [locationManager startUpdatingLocation];
    [self performSelector:@selector(stopUpdatingLocation:) withObject:nil afterDelay:45];
    
    for (int i=0; i < 16; i++) {
        UILabel *labelEffect = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 50, 10)];
        labelEffect.backgroundColor = [UIColor clearColor];
        labelEffect.textColor = [UIColor whiteColor];
        labelEffect.font = [UIFont fontWithName:@"AvenirNextCondensed-Regular" size:9];
        UIButton *buttonEffect = [[UIButton alloc] initWithFrame:CGRectMake(5+55*i, 5, 50, 50)];
        labelEffect.center = CGPointMake(buttonEffect.center.x, 63);
        labelEffect.textAlignment = NSTextAlignmentCenter;
        UIImage *preview = [UIImage imageNamed:[NSString stringWithFormat:@"sample%d.jpg", i]];
        if (preview != nil) {
            [buttonEffect setImage:preview forState:UIControlStateNormal];
        } else {
            [buttonEffect setBackgroundColor:[UIColor grayColor]];
        }
        
        [buttonEffect addTarget:self action:@selector(setEffect:) forControlEvents:UIControlEventTouchUpInside];
        buttonEffect.layer.cornerRadius = 5;
        buttonEffect.clipsToBounds = YES;
        buttonEffect.tag = i;
        switch (i) {
            case 1:
                labelEffect.text = @"Classic";
                break;
            case 2:
                labelEffect.text = @"Gummy";
                break;
            case 3:
                labelEffect.text = @"Maccha";
                break;
            case 4:
                labelEffect.text = @"Forest";
                break;
            case 5:
                labelEffect.text = @"Electrocute";
                break;
            case 6:
                labelEffect.text = @"Glory";
                break;
            case 7:
                labelEffect.text = @"Big time";
                break;
            case 8:
                labelEffect.text = @"Cozy";
                break;
            case 9:
                labelEffect.text = @"Haze";
                break;
            case 10:
                labelEffect.text = @"Autumn";
                break;
            case 11:
                labelEffect.text = @"Dreamy";
                break;
            case 12:
                labelEffect.text = @"Purple";
                break;
            case 13:
                labelEffect.text = @"Dorian";
                break;
            case 14:
                labelEffect.text = @"Stingray";
                break;
            case 15:
                labelEffect.text = @"Aussie";
                break;

            default:
                labelEffect.text = @"Original";
                break;
        }

        [scrollEffect addSubview:buttonEffect];
        [scrollEffect addSubview:labelEffect];
    }
    scrollEffect.contentSize = CGSizeMake(16*55+10, 60);
    
    
    // get font family
    
    // loop

     
//     NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"fonts" ofType:@"plist"];
//     NSDictionary *fonts = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
//    NSInteger i = 0;
//
//    for (NSDictionary *dictFont in [fonts objectForKey:@"fonts"]) {
//        CGRect frame = CGRectMake(10, i * 30, 300, 30);
//        UIButton *buttonFont = [[UIButton alloc] initWithFrame:frame];
//        buttonFont.titleLabel.text = [dictFont objectForKey:@"name"];
//        buttonFont.titleLabel.textAlignment = NSTextAlignmentLeft;
//        buttonFont.titleLabel.font = [UIFont fontWithName:[dictFont objectForKey:@"name"] size:20];
//        [buttonFont setTitle:[dictFont objectForKey:@"name"] forState:UIControlStateNormal];
//        buttonFont.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
//        [buttonFont addTarget:self action:@selector(selectFont:) forControlEvents:UIControlEventTouchUpInside];
//        
//        i++;
//        [scrollFont addSubview:buttonFont];
//
//    }
//    scrollFont.contentSize = CGSizeMake(320, i * 30);
    
    [self resizeCameraViewWithAnimation:NO];
    [self preparePipe];
}

- (void)appBecomeActive:(id)sender {
    [videoCamera resumeCameraCapture];
}

- (void)appResignActive:(id)sender {
    [videoCamera pauseCameraCapture];
}


- (void)keyboardWillShow:(NSNotification *)notification
{
    keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    isKeyboard = YES;
    [self resizeCameraViewWithAnimation:YES];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    isKeyboard = NO;
    [self resizeCameraViewWithAnimation:YES];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

- (void)selectFont:(UIButton*)sender {
    currentFont = sender.titleLabel.text;
    [self newText];
}

- (void)viewDidAppear:(BOOL)animated {    
    [super viewDidAppear:animated];
    
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    UIAccelerometer* a = [UIAccelerometer sharedAccelerometer];
    a.updateInterval = 1 / kAccelerometerFrequency;
    a.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated {
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
    self.navigationController.navigationBarHidden = YES;
    if (!isEditing) {

            [videoCamera startCameraCapture];

    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    if (isEditing) {
        isSaved = false;
        savedData = nil;
        savedPreview = nil;
    }
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated
{
    UIAccelerometer* a = [UIAccelerometer sharedAccelerometer];
    a.delegate = nil;
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
    
    [videoCamera stopCameraCapture];
    
    [super viewWillDisappear:animated];
}

- (void)viewDidUnload {
    [self setViewCamera:nil];
    [self setScrollEffect:nil];
    [self setImageAutoFocus:nil];
    [self setViewTimer:nil];
    
    videoCamera = nil;
    
    [self setButtonSetNoTimer:nil];
    [self setButtonSetTimer5s:nil];
    [self setTapFocus:nil];
    [self setViewFocusControl:nil];
    [self setButtonToggleFocus:nil];
    [self setViewCameraWraper:nil];
    [self setViewDraw:nil];
    [self setButtonBackgroundNatual:nil];
    [self setButtonBlurWeak:nil];
    [self setButtonBlurNormal:nil];
    [self setButtonBlurStrong:nil];
    [self setButtonBlurNone:nil];
    [self setViewHelp:nil];
    [self setViewPopupHelp:nil];
    [self setViewBasicControl:nil];
    [self setButtonClose:nil];
    [self setButtonToggleBasic:nil];
    [self setButtonToggleLens:nil];
    [self setViewLensControl:nil];
    [self setButtonToggleText:nil];
    [self setButtonLensNormal:nil];
    [self setButtonLensWide:nil];
    [self setButtonLensFish:nil];
    [self setViewTopBar:nil];
    [self setTapCloseHelp:nil];
    [self setViewTextControl:nil];
    [self setViewEffectControl:nil];
    [self setViewTopBar35:nil];
    [self setViewCanvas:nil];
    [self setSliderExposure:nil];
    [self setSliderVignette:nil];
    [self setSliderSharpness:nil];
    [self setSliderClear:nil];
    [self setSliderSaturation:nil];
    [self setButtonReset:nil];
    [self setSwitchGain:nil];
    [self setScrollFont:nil];
    [self setTextText:nil];
    [self setButtonPickTop:nil];
    [self setSliderFeather:nil];
    [self setSliderEffectIntensity:nil];
    [self setButtonFlash35:nil];
    [super viewDidUnload];
}

- (void)preparePipe {
    [self preparePipe:nil];
}


- (void)preparePipe:(GPUImageOutput *)picture {
    if (isEditing) {
        [previewFilter removeAllTargets];
        
        if (picture != nil) {
            pipe.input = picture;
        } else {
            pipe.input = previewFilter;
        }
        
        [filter removeAllTargets];
        [filterText removeAllTargets];
        [filterFish removeAllTargets];
        [filterDOF removeAllTargets];
        [filterSharpen removeAllTargets];
        [filterDistord removeAllTargets];
        [filterCrop removeAllTargets];
        [filterIntensity removeAllTargets];
        
        [pictureDOF removeAllTargets];
        [uiElement removeAllTargets];
        
        [pipe removeAllFilters];
        if (sliderSharpness.value > 0) {
            [pipe addFilter:filterSharpen];
        }
        
        [pipe addFilter:filter];
        
        if (!buttonLensFish.enabled) {
            [pipe addFilter:filterDistord];
            [pipe addFilter:filterCrop];
        }

        if (!buttonLensWide.enabled) {
            [pipe addFilter:filterDistord];
        }

        
        if (buttonBlurNone.enabled && (pictureDOF != nil)) {
            [pipe addFilter:filterDOF];
        }
        
        NSInteger mark;
        if (effect != nil) {
            mark = pipe.filters.count-1;
            [pipe addFilter:effect];
            [pipe addFilter:filterIntensity];
        }
        
        if (textText.text.length > 0) {
            [pipe addFilter:filterText];
        }
        
        // AFTER THIS LINE, NO MORE ADDFILTER
        if (effect != nil) {
            GPUImageFilter *tmp = pipe.filters[mark];
            [tmp addTarget:pipe.filters[mark+2]];
        }
        
        // Two input filter has to be setup at last
        GPUImageRotationMode imageViewRotationModeIdx0 = kGPUImageNoRotation;
        GPUImageRotationMode imageViewRotationModeIdx1 = kGPUImageNoRotation;
        switch (imageOrientation) {
            case UIImageOrientationLeft:
                imageViewRotationModeIdx0 = kGPUImageRotateLeft;
                imageViewRotationModeIdx1 = kGPUImageRotateRight;
                break;
            case UIImageOrientationRight:
                imageViewRotationModeIdx0 = kGPUImageRotateRight;
                imageViewRotationModeIdx1 = kGPUImageRotateLeft;
                break;
            case UIImageOrientationDown:
                imageViewRotationModeIdx0 = kGPUImageRotate180;
                imageViewRotationModeIdx1 = kGPUImageRotate180;
                break;
            case UIImageOrientationUp:
                imageViewRotationModeIdx0 = kGPUImageNoRotation;
                imageViewRotationModeIdx1 = kGPUImageNoRotation;
                break;
            default:
                imageViewRotationModeIdx0 = kGPUImageRotateLeft;
                imageViewRotationModeIdx1 = kGPUImageRotateLeft;
                break;
        }
        
        
        if (buttonBlurNone.enabled && (pictureDOF != nil)) {
            [filterDOF setInputRotation:imageViewRotationModeIdx1 atIndex:1];
            [pictureDOF addTarget:filterDOF atTextureLocation:1];
        }
        
        if (textText.text.length > 0) {
            [filterText setInputRotation:imageViewRotationModeIdx1 atIndex:1];
            [uiElement addTarget:filterText];
        }
        
        
        // seems like atIndex is ignored by GPUImageView...
        [viewCamera setInputRotation:imageViewRotationModeIdx0 atIndex:0];
    } else {
        GPUImageFilter *dummy = [[GPUImageFilter alloc] init];
        pipe.input = videoCamera;
        [pipe removeAllFilters];
        [pipe addFilter:dummy];
        [dummy prepareForImageCapture];
    }
}

- (void)applyFilterSetting {
    filter.vignfade = 0.8-sliderVignette.value;
    filter.brightness = sliderExposure.value;
    filter.clearness = sliderClear.value;
    filter.saturation = sliderSaturation.value;
    
    currentSharpness = sliderSharpness.value;
    filterSharpen.sharpness = sliderSharpness.value;
    
    if (effect != nil) {
        filterIntensity.mix = 1.0 - sliderEffectIntensity.value;
    }
    
    if (!buttonLensFish.enabled) {
        filterDistord.scale = -0.2;
        filterDistord.radius = 0.75;
        filterCrop.cropRegion = CGRectMake(0.05, 0.05, 0.9, 0.9);
    }
    
    if (!buttonLensWide.enabled) {
        filterDistord.scale = 0.1;
        filterDistord.radius = 1.0;
    }
    
    if (!buttonBlurNormal.enabled) {
        filterDOF.bias = 0.02;
    }
    
    if (!buttonBlurWeak.enabled) {
        filterDOF.bias = 0.01;
    }
    
    if (!buttonBlurStrong.enabled) {
        filterDOF.bias = 0.03;
    }
    
    if (switchGain.on)
        filterDOF.gain = 1.0;
    else
        filterDOF.gain = 0.0;
}

- (void)processImage {
    isSaved = false;
    savedData = nil;
    savedPreview = nil;

    [previewFilter processImage];
    if (buttonBlurNone.enabled && (pictureDOF != nil)) {
        [pictureDOF processData];
    }
//    if (currentText.length > 0) {
//        [uiElement update];
//    }
}

- (UIImage *)imageFromText:(NSString *)text
{
    // set the font type and size
    UIFont *font = [UIFont fontWithName:currentFont size:200.0];
    CGSize size  = [text sizeWithFont:font];
    
    // shadow
    size.height += 10;
    size.width += 10;
    
    // check if UIGraphicsBeginImageContextWithOptions is available (iOS is 4.0+)
    if (UIGraphicsBeginImageContextWithOptions != NULL)
        UIGraphicsBeginImageContextWithOptions(size,NO,0.0);
    else
        // iOS is < 4.0
        UIGraphicsBeginImageContext(size);
    
    // optional: add a shadow, to avoid clipping the shadow you should make the context size bigger
    //
    // CGContextRef ctx = UIGraphicsGetCurrentContext();
    // CGContextSetShadowWithColor(ctx, CGSizeMake(1.0, 1.0), 5.0, [[UIColor grayColor] CGColor]);
    
    // draw in context, you can use also drawInRect:withFont:
    CGContextRef context = UIGraphicsGetCurrentContext();
    
	CGContextSetShadowWithColor(context, CGSizeMake(0, 3.0f), 2.0f, [UIColor blackColor].CGColor);
    
    CGContextSetRGBFillColor(context, 1.0, 1.0, 1.0, 1);
    
    [text drawAtPoint:CGPointMake(5.0, 5.0) withFont:font];
    
    // transfer image
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}


- (IBAction)setEffect:(id)sender {
    UIButton* buttonEffect = (UIButton*)sender;
    currentEffect = buttonEffect.tag;
    effect = [effectManager getEffect:currentEffect];
    [self preparePipe];
    [self processImage];
}


- (void)updateTargetPoint {
    CGPoint point = CGPointMake(imageAutoFocus.center.x/viewCamera.frame.size.width, imageAutoFocus.center.y/viewCamera.frame.size.height);
    
    
    [self setFocusPoint:point];
    [self setMetteringPoint:point];
    //        imageAutoFocus.hidden = false;
    imageAutoFocus.alpha = 1.0;
    [UIView animateWithDuration:0.3
                          delay:1.0
                        options:UIViewAnimationCurveEaseInOut
                     animations:^{
                         imageAutoFocus.alpha = 0.0;
                     } completion:^(BOOL finished) {
                         //imageAutoFocus.hidden = true;
                     }];
}

- (void)capturePhotoAsync {
    imageOrientation = orientationLast;
    [videoCamera capturePhotoAsSampleBufferWithCompletionHandler:^(CMSampleBufferRef imageSampleBuffer, NSError *error) {
        [videoCamera stopCameraCapture];
        
        [locationManager stopUpdatingLocation];
        
        
        imageMeta = [NSMutableDictionary dictionaryWithDictionary:videoCamera.currentCaptureMetadata];
        
        CGFloat scale = [[UIScreen mainScreen] scale];
        CGFloat width = 300.0;
        
        NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];
        capturedImage = [UIImage imageWithData:imageData];

        NSInteger height = [LXUtils heightFromWidth:width width:capturedImage.size.width height:capturedImage.size.height];
        
        CGSize size;
        
        size = CGSizeMake(height*scale, width*scale);
        if (imageOrientation == UIImageOrientationLeft || imageOrientation == UIImageOrientationRight) {
            picSize = capturedImage.size;
        }
        else {
            picSize = CGSizeMake(capturedImage.size.height, capturedImage.size.width);
        }
        
        previewSize = CGSizeMake(width*scale, height*scale);
        
        UIImage *previewPic = [capturedImage
                               resizedImage: size
                               interpolationQuality:kCGInterpolationHigh];
        
        previewFilter = [[GPUImagePicture alloc] initWithImage:previewPic];
        [self switchEditImage];
        [self resizeCameraViewWithAnimation:NO];
        [self preparePipe];
        [self applyFilterSetting];
        [self processImage];
    }];
}

- (IBAction)cameraTouch:(UITapGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateRecognized) {
        CGPoint location = [sender locationInView:self.viewCamera];

        imageAutoFocus.hidden = false;
        [UIView animateWithDuration:0.1 animations:^{
            imageAutoFocus.alpha = 1;
        }];

        imageAutoFocus.center = location;
        
        [self updateTargetPoint];
    }
}

- (IBAction)openImagePicker:(id)sender {
    if (!isEditing) {
        [locationManager stopUpdatingLocation];
        [videoCamera stopCameraCapture];
    }
    
    [self presentViewController:imagePicker animated:NO completion:nil];
}

- (IBAction)close:(id)sender {
    if (!isSaved) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"photo_hasnt_been_saved", @"写真が保存されていません")
                                                        message:NSLocalizedString(@"stop_camera_confirm", @"カメラを閉じますか？")
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"cancel", @"キャンセル")
                                              otherButtonTitles:NSLocalizedString(@"stop_camera", @"はい"), nil];
        alert.tag = 2;
        [alert show];
    } else {
        LXAppDelegate* app = (LXAppDelegate*)[UIApplication sharedApplication].delegate;
        [app toogleCamera];
    }
}

- (IBAction)capture:(id)sender {
    buttonPick.hidden = true;
    if (currentTimer == kTimerNone) {
        [self capturePhotoAsync];
    } else {
        timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(countDown:) userInfo:nil repeats:YES];
    }
}

- (IBAction)changeLens:(UIButton*)sender {
    buttonLensFish.enabled = true;
    buttonLensNormal.enabled = true;
    buttonLensWide.enabled = true;
    
    sender.enabled = false;
    
    currentLens = sender.tag;
    [self preparePipe];
    [self applyFilterSetting];
    [self processImage];
}

- (IBAction)changeFlash:(id)sender {
    buttonFlash.selected = !buttonFlash.selected;
    buttonFlash35.selected = !buttonFlash35.selected;
    [self setFlash:buttonFlash.selected];
}

- (IBAction)touchTimer:(id)sender {
    // wait for time before begin
    [viewTimer setHidden:!viewTimer.isHidden];
}

- (IBAction)touchSave:(id)sender {
    [HUD show:NO];
    
    [self getFinalImage:^{
        [self processSavedData];
    }];
}

- (void)processSavedData {
    LXAppDelegate* app = (LXAppDelegate*)[UIApplication sharedApplication].delegate;
    [HUD hide:YES];
    if (app.currentUser != nil) {
        NSDictionary *info = [[NSDictionary alloc] initWithObjectsAndKeys:
                              savedData, @"data",
                              savedPreview, @"preview",
                              nil];
        if (delegate == nil) {
            [self performSegueWithIdentifier:@"Edit" sender:info];
        } else {
            [delegate imagePickerController:self didFinishPickingMediaWithData:info];
        }
    } else {
        RDActionSheet *actionSheet = [[RDActionSheet alloc] initWithCancelButtonTitle:NSLocalizedString(@"Cancel", @"")
                                                                   primaryButtonTitle:nil
                                                               destructiveButtonTitle:nil
                                                                    otherButtonTitles:@"Email", @"Twitter", @"Facebook", nil];
        
        actionSheet.callbackBlock = ^(RDActionSheetResult result, NSInteger buttonIndex)
        {
            switch (result) {
                case RDActionSheetButtonResultSelected: {
                    laSharekit.imageData = savedData;
                    laSharekit.imagePreview = savedPreview;
                    
                    switch (buttonIndex) {
                        case 0: // email
                            [laSharekit emailIt];
                            break;
                        case 1: // twitter
                            [laSharekit tweet];
                            break;
                        case 2: // facebook
                            [laSharekit facebookPost];
                            break;
                            
                        default:
                            break;
                    }
                }
                    break;
                case RDActionSheetResultResultCancelled:
                    NSLog(@"Sheet cancelled");
            }
        };
        
        [actionSheet showFrom:self.view];
    }
}

- (void)getFinalImage:(void(^)())block {
    if (isSaved) {
        block();
        return;
    }
    
    
    CGImageRef cgImagePreviewFromBytes = [pipe newCGImageFromCurrentFilteredFrameWithOrientation:imageOrientation];
    savedPreview = [UIImage imageWithCGImage:cgImagePreviewFromBytes scale:1.0 orientation:imageOrientation];
    CGImageRelease(cgImagePreviewFromBytes);
    
    GPUImagePicture *picture = [[GPUImagePicture alloc] initWithImage:capturedImage];
    
    [self preparePipe:picture];
    [self applyFilterSetting];
    
    [picture processImage];
    if (buttonBlurNone.enabled && (pictureDOF != nil)) {
        [pictureDOF processData];
    }
    if (textText.text.length > 0) {
        [uiElement update];
    }
    
    CGImageRef cgImageFromBytes = [pipe newCGImageFromCurrentFilteredFrameWithOrientation:imageOrientation];
    picture = nil;
    
    
    // Prepare meta data
    if (imageMeta == nil) {
        imageMeta = [[NSMutableDictionary alloc] init];
    }
    
    NSNumber *orientation = [NSNumber numberWithInteger:[self metadataOrientationForUIImageOrientation:imageOrientation]];
    
    [imageMeta setObject:orientation forKey:(NSString *)kCGImagePropertyOrientation];
    
    // Add GPS
    NSDictionary *location;
    if (bestEffortAtLocation != nil) {
        location = [LXUtils getGPSDictionaryForLocation:bestEffortAtLocation];
        [imageMeta setObject:location forKey:(NSString *)kCGImagePropertyGPSDictionary];
    }
    
    // Add App Info
    NSMutableDictionary *dictForTIFF = [imageMeta objectForKey:(NSString *)kCGImagePropertyTIFFDictionary];
    if (dictForTIFF == nil) {
        dictForTIFF = [[NSMutableDictionary alloc] init];
        [imageMeta setObject:dictForTIFF forKey:(NSString *)kCGImagePropertyTIFFDictionary];
    }
    
    [dictForTIFF setObject:@"Latte camera" forKey:(NSString *)kCGImagePropertyTIFFSoftware];
    
    [imageMeta setObject:dictForTIFF forKey:(NSString *)kCGImagePropertyTIFFDictionary];
    
    // Save now
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    [library writeImageToSavedPhotosAlbum:cgImageFromBytes metadata:imageMeta completionBlock:^(NSURL *assetURL, NSError *error) {
        CGImageRelease(cgImageFromBytes);
        
        // Return to preview mode
        [self preparePipe];
        
        if (!error) {
            [library assetForURL:assetURL
                     resultBlock:^(ALAsset *asset) {
                         ALAssetRepresentation *rep = [asset defaultRepresentation];
                         Byte *buffer = (Byte*)malloc(rep.size);
                         NSUInteger buffered = [rep getBytes:buffer fromOffset:0.0 length:rep.size error:nil];
                         savedData = [NSData dataWithBytesNoCopy:buffer length:buffered freeWhenDone:YES];
                         isSaved = true;
                         block();
                     }
                    failureBlock:^(NSError *error) {
                        TFLog(@"Cannot saved 2");
                    }];

        } else {
            TFLog(@"Cannot saved 1");
        }
    }];
    
}

- (IBAction)toggleControl:(UIButton*)sender {
    // Disable Text
    if (sender.tag == kTabText) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"error", @"Error")
                                                        message:NSLocalizedString(@"feature_not_available", @"Feature Not Available")
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"close", @"Close")
                                               otherButtonTitles: nil];
        [alert show];
        return;
    }
    
    if (sender.tag == currentTab) {
        currentTab = kTabPreview;
        sender.selected = false;
    }
    else {
        currentTab = sender.tag;
        sender.selected = true;
    }

    switch (currentTab) {
        case kTabEffect:
            buttonToggleFocus.selected = false;
            buttonToggleBasic.selected = false;
            buttonToggleLens.selected = false;
            buttonToggleText.selected = false;
            break;
        case kTabBasic:
            buttonToggleFocus.selected = false;
            buttonToggleEffect.selected = false;
            buttonToggleLens.selected = false;
            buttonToggleText.selected = false;
            break;
        case kTabLens:
            buttonToggleFocus.selected = false;
            buttonToggleEffect.selected = false;
            buttonToggleBasic.selected = false;
            buttonToggleText.selected = false;
            break;
        case kTabText:
            buttonToggleFocus.selected = false;
            buttonToggleEffect.selected = false;
            buttonToggleBasic.selected = false;
            buttonToggleLens.selected = false;
            break;
        case kTabBokeh: {
            buttonToggleEffect.selected = false;
            buttonToggleBasic.selected = false;
            buttonToggleLens.selected = false;
            buttonToggleText.selected = false;
            
            // Firsttime
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            if (![defaults objectForKey:@"firstRunBokeh"]) {
                [defaults setObject:[NSDate date] forKey:@"firstRunBokeh"];
                [self touchOpenHelp:nil];
            }
        }
            break;
        default:
            buttonToggleEffect.selected = false;
            buttonToggleFocus.selected = false;
            buttonToggleBasic.selected = false;
            buttonToggleText.selected = false;
            buttonToggleLens.selected = false;
            break;
    }
    
    [self resizeCameraViewWithAnimation:YES];
    
    viewDraw.hidden = currentTab != kTabBokeh;
        
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)resizeCameraViewWithAnimation:(BOOL)animation {
    CGRect screen = [[UIScreen mainScreen] bounds];

    CGRect frame = viewCameraWraper.frame;
    CGRect frameEffect = viewEffectControl.frame;
    CGRect frameBokeh = viewFocusControl.frame;
    CGRect frameBasic = viewBasicControl.frame;
    CGRect frameLens = viewLensControl.frame;
    CGRect frameTopBar = viewTopBar.frame;
    CGRect frameText = viewTextControl.frame;
    CGRect frameCanvas = viewCanvas.frame;

    
    CGFloat posBottom;
    
    if (screen.size.height > 480) {
        posBottom = 568 - 50;
    }
    else {
        posBottom = 480 - 50;
    }
    
    frameEffect.origin.y = frameBokeh.origin.y = frameBasic.origin.y = frameLens.origin.y = frameText.origin.y =  posBottom;
    
    switch (currentTab) {
        case kTabBokeh:
            frameBokeh.origin.y = posBottom - 110;
            break;
        case kTabEffect:
            frameEffect.origin.y = posBottom - 110;
            break;
        case kTabLens:
            frameLens.origin.y = posBottom - 110;
            break;
        case kTabBasic:
            frameBasic.origin.y = posBottom - 110;
            break;
        case kTabText:
            if (isKeyboard)
                frameText.origin.y = posBottom - keyboardSize.height + 20;
            else
                frameText.origin.y = posBottom - 140;
            break;
        case kTabPreview:
            break;
    }
    
    
    if (isEditing) {
        CGFloat height;
        if (screen.size.height > 480) {
            height = 568 - 50 - 40 - 20;
        }
        else {
            height = 480 - 50 - 40 - 20;
        }
        
        if (currentTab != kTabPreview) {
            if ((currentTab == kTabText) && (!isKeyboard))
                height -= 140;
            else if ((currentTab == kTabText) && (isKeyboard)) {
                height -= keyboardSize.height - 20;
            }
            else
                height -= 110;
        }
        
        frameCanvas = CGRectMake(0, 40, 320, height+20);
        
        CGFloat horizontalRatio = 300.0 / picSize.width;
        CGFloat verticalRatio = height / picSize.height;
        CGFloat ratio;
        ratio = MIN(horizontalRatio, verticalRatio);
        
        frame.size = CGSizeMake(picSize.width*ratio, picSize.height*ratio);
        frame.origin = CGPointMake((320-frame.size.width)/2, (height - frame.size.height)/2 + 50.0);
        
        viewTopBar.hidden = false;
        viewTopBar35.hidden = true;

    } else {
        if (screen.size.height > 480) {
            frame = CGRectMake(10, 79, 300, 400);
            frameCanvas = CGRectMake(0, 40, 320, 568-40-50);
        }
        else {
            frame = CGRectMake(10, 15, 300, 400);
            frameCanvas = CGRectMake(0, 0, 320, 430);
        }
        
        if (screen.size.height > 480) {
            viewTopBar.hidden = false;
            viewTopBar35.hidden = true;
        }
        else {
            viewTopBar.hidden = true;
            viewTopBar35.hidden = false;
        }
    }
    
    CABasicAnimation *theAnimation = [CABasicAnimation animationWithKeyPath:@"shadowPath"];
    theAnimation.duration = 0.3;
    theAnimation.toValue = [UIBezierPath bezierPathWithRect:frame];
    [viewCameraWraper.layer addAnimation:theAnimation forKey:@"animateShadowPath"];
    
    [UIView animateWithDuration:animation?0.3:0 animations:^{
        viewFocusControl.frame = frameBokeh;
        viewEffectControl.frame = frameEffect;
        viewBasicControl.frame = frameBasic;
        viewLensControl.frame = frameLens;
        viewCameraWraper.frame = frame;
        viewTextControl.frame = frameText;
        viewTopBar.frame = frameTopBar;
        viewCanvas.frame = frameCanvas;
    } completion:^(BOOL finished) {
        
        
    }];
}

- (int) metadataOrientationForUIImageOrientation:(UIImageOrientation)orientation
{
	switch (orientation) {
		case UIImageOrientationUp: // the picture was taken with the home button is placed right
			return 1;
		case UIImageOrientationRight: // bottom (portrait)
			return 6;
		case UIImageOrientationDown: // left
			return 3;
		case UIImageOrientationLeft: // top
			return 8;
		default:
			return 1;
	}
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [locationManager stopUpdatingLocation];
    
    ALAssetsLibraryAssetForURLResultBlock resultblock = ^(ALAsset *myasset)
    {
        bestEffortAtLocation = nil;
        imageMeta = [NSMutableDictionary dictionaryWithDictionary:myasset.defaultRepresentation.metadata];
    
        capturedImage = [info objectForKey:UIImagePickerControllerOriginalImage];
        imageOrientation = capturedImage.imageOrientation;
        
        CGFloat scale = [[UIScreen mainScreen] scale];
        
        NSInteger height = [LXUtils heightFromWidth:300.0 width:capturedImage.size.width height:capturedImage.size.height];
        picSize = capturedImage.size;
        
        //
        CGSize size;
        
        if (imageOrientation == UIImageOrientationLeft || imageOrientation == UIImageOrientationRight) {
            size = CGSizeMake(height*scale, 300.0*scale);
        }
        else {
            size = CGSizeMake(300.0*scale, height*scale);
        }
//        previewSize = CGSizeMake(300.0*scale, height*scale);
        
        UIImage *previewPic = [capturedImage
                               resizedImage: size
                               interpolationQuality:kCGInterpolationHigh];
        
        previewFilter = [[GPUImagePicture alloc] initWithImage:previewPic];

        [self switchEditImage];
        
        [imagePicker dismissViewControllerAnimated:NO completion:nil];
        
        [self resizeCameraViewWithAnimation:NO];
        [self preparePipe];
        [self applyFilterSetting];
        [self processImage];
    };
    
    //
    ALAssetsLibraryAccessFailureBlock failureblock  = ^(NSError *myerror)
    {
        TFLog(@"booya, cant get image - %@",[myerror localizedDescription]);
    };
    
    ALAssetsLibrary* assetslibrary = [[ALAssetsLibrary alloc] init];
    [assetslibrary assetForURL:[info objectForKey:UIImagePickerControllerReferenceURL]
                   resultBlock:resultblock
                  failureBlock:failureblock];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:NO completion:nil];
    if (!isEditing) {
        [self switchCamera];
    }
}

- (void)switchCamera {
    isSaved = true;
    savedData = nil;
    savedPreview = nil;
    // Clear memory/blur mode
    previewFilter = nil;
    capturedImage = nil;
    
    // Set to normal lens
    currentLens = 0;
    currentTab = kTabPreview;
    viewDraw.hidden = true;
    viewDraw.isEmpty = true;
    
    buttonBlurNone.enabled = false;
    
    [textText resignFirstResponder];
    [locationManager startUpdatingLocation];
    

        [videoCamera startCameraCapture];


    buttonNo.hidden = YES;
    buttonYes.hidden = YES;
    buttonCapture.hidden = NO;
    buttonFlash.hidden = NO;
    buttonTimer.hidden = NO;
    buttonFlip.hidden = NO;
    imageAutoFocus.hidden = NO;
    buttonReset.hidden = YES;
    buttonPickTop.hidden = YES;
    
    buttonPick.hidden = NO;
    tapFocus.enabled = true;
    
    scrollEffect.hidden = false;
    buttonPick.hidden = NO;
    
    buttonToggleEffect.hidden = YES;
    buttonToggleFocus.hidden = YES;
    buttonToggleBasic.hidden = YES;
    buttonToggleLens.hidden = YES;
    buttonToggleText.hidden = YES;
    
    buttonClose.hidden = NO;
    isEditing = NO;
    
    [self resizeCameraViewWithAnimation:NO];
    [self preparePipe];
}

- (void)switchEditImage {
    // Reset to normal lens
    currentFont = @"Arial";
    posText = CGPointMake(0.1, 0.5);
    textText.text = @"";
    currentText = @"";
    
//    uiWrap.frame = CGRectMake(0, 0, previewSize.width, previewSize.height);
    timeLabel.center = uiWrap.center;

    
    mCurrentScale = 1.0;
    mLastScale = 1.0;

    currentLens = 0;
    currentSharpness = 0.0;
    currentMask = kMaskBlurNone;
    
    isEditing = YES;
    buttonCapture.hidden = YES;
    buttonNo.hidden = NO;
    buttonYes.hidden = NO;
    buttonFlash.hidden = YES;
    buttonTimer.hidden = YES;
    buttonFlip.hidden = YES;
    buttonPick.hidden = YES;
    buttonPickTop.hidden = NO;
    
    buttonToggleFocus.hidden = NO;
    buttonToggleBasic.hidden = NO;
    buttonToggleLens.hidden = NO;
    buttonToggleText.hidden = NO;
    buttonToggleEffect.hidden = NO;
    
    buttonClose.hidden = YES;
    imageAutoFocus.hidden = YES;
    viewTimer.hidden = YES;
    tapFocus.enabled = false;
    isSaved = FALSE;
    
    // Clear depth mask
    [viewDraw.drawImageView setImage:nil];
    viewDraw.currentColor = [UIColor redColor];
    viewDraw.isEmpty = YES;

    // Default Brush
    [self setUIMask:kMaskBlurNone];

    buttonToggleFocus.selected = false;
    buttonToggleBasic.selected = false;
    buttonToggleEffect.selected = false;
    buttonToggleLens.selected = false;
    buttonToggleText.selected = false;
    
    buttonReset.hidden = false;
    currentTab = kTabPreview;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(NSDictionary *)info {
    if ([segue.identifier isEqualToString:@"Edit"]) {
        LXPicEditViewController *controllerPicEdit = segue.destinationViewController;
        [controllerPicEdit setData:[info objectForKey:@"data"]];
        [controllerPicEdit setPreview:[info objectForKey:@"preview"]];
    }
}

- (IBAction)touchNo:(id)sender {
    if (!isSaved) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"photo_hasnt_been_saved", @"写真が保存されていません")
                                                        message:NSLocalizedString(@"stop_camera_confirm", @"カメラを閉じますか？")
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"cancel", @"キャンセル")
                                              otherButtonTitles:NSLocalizedString(@"stop_camera", @"はい"), nil];
        alert.tag = 1;
        [alert show];
    } else
        [self switchCamera];
}

- (IBAction)touchReset:(id)sender {
    sliderExposure.value = 0.0;
    sliderClear.value = 0.0;
    sliderSaturation.value = 1.0;
    sliderSharpness.value = 0.0;
    sliderVignette.value = 0.0;
    sliderFeather.value = 10.0;
    [self setUIMask:kMaskBlurNone];
    
    effect = nil;
    buttonLensFish.enabled = true;
    buttonLensWide.enabled = true;
    buttonLensNormal.enabled = false;
    textText.text = @"";
    currentText = @"";
    
    [self preparePipe];
    [self applyFilterSetting];
    [self processImage];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (alertView.tag) {
        case 1: //Touch No
            if (buttonIndex == 1)
                [self switchCamera];
            break;
        case 2:
            if (buttonIndex == 1) {
                LXAppDelegate* app = (LXAppDelegate*)[UIApplication sharedApplication].delegate;                
                [app toogleCamera];
            }
            break;
        default:
            break;
    }
}


- (IBAction)flipCamera:(id)sender {
    [videoCamera rotateCamera];
}

- (IBAction)panTarget:(UIPanGestureRecognizer *)sender {
    CGPoint translation = [sender translationInView:viewCamera];
    CGPoint center = CGPointMake(sender.view.center.x + translation.x,
                                         sender.view.center.y + translation.y);
    center.x = center.x<0?0:(center.x>320?320:center.x);
    center.y = center.y<0?0:(center.y>viewCamera.frame.size.height?viewCamera.frame.size.height:center.y);
    sender.view.center = center;
    [sender setTranslation:CGPointMake(0, 0) inView:viewCamera];
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        [self updateTargetPoint];
    }
}

- (IBAction)setTimer:(UIButton *)sender {
    buttonSetNoTimer.enabled = true;
    buttonSetTimer5s.enabled = true;
    buttonSetNoTimer.alpha = 0.4;
    buttonSetTimer5s.alpha = 0.4;
    
    sender.enabled = false;
    sender.alpha = 0.9;
    
    switch (sender.tag) {
        case 0:
            timerCount = 0;
            currentTimer = kTimerNone;
            break;
        case 1:
            currentTimer = kTimer5s;
            timerCount = 5;
            break;
        case 2:
            timerCount = 10;
            currentTimer = kTimer10s;
            break;
        case 3:
            currentTimer = kTimerContinuous;
            break;
        default:
            break;
    }
}


- (IBAction)setMask:(UIButton*)sender {
    [self setUIMask:sender.tag];
    [self applyFilterSetting];
    [self processImage];
}

- (IBAction)toggleMaskNatual:(UISwitch*)sender {
    if (sender.on) {
        viewDraw.backgroundType = kBackgroundNatual;
    } else {
        viewDraw.backgroundType = kBackgroundNone;
    }
}

- (IBAction)touchCloseHelp:(id)sender {
    [UIView animateWithDuration:0.3 animations:^{
        viewHelp.alpha = 0.0;
    } completion:^(BOOL finished) {
        viewHelp.hidden = true;
        tapCloseHelp.enabled = false;
    }];

}

- (IBAction)touchOpenHelp:(id)sender {
    viewHelp.hidden = false;
    [UIView animateWithDuration:0.3 animations:^{
        viewHelp.alpha = 1.0;
    } completion:^(BOOL finished) {
        tapCloseHelp.enabled = true;
    }];
}

- (IBAction)toggleGain:(UISwitch*)sender {
    [self applyFilterSetting];
    [self processImage];
}

- (void)setUIMask:(NSInteger)tag {
    buttonBlurStrong.enabled = true;
    buttonBlurWeak.enabled = true;
    buttonBlurNormal.enabled = true;
    buttonBlurNone.enabled = true;
    
    switch (tag) {
        case kMaskBlurNone:
            buttonBlurNone.enabled = false;
            break;
        case kMaskBlurWeak:
            buttonBlurWeak.enabled = false;
            break;
        case kMaskBlurNormal:
            buttonBlurNormal.enabled = false;
            break;
        case kMaskBlurStrong:
            buttonBlurStrong.enabled = false;
            break;
        default:
            break;
    }
    
    if ((currentMask == kMaskBlurNone) != (tag == kMaskBlurNone)) {
        [self preparePipe];
    }
    currentMask = tag;
}


- (IBAction)changePen:(UISlider *)sender {
    viewDraw.lineWidth = sender.value;
    [viewDraw redraw];
}

- (IBAction)updateFilter:(id)sender {
    if ((currentSharpness > 0) != (sliderSharpness.value > 0)) {
        [self preparePipe];
    }
    [self applyFilterSetting];
    [self processImage];
}

- (IBAction)textChange:(UITextField *)sender {
    [self newText];
}

- (IBAction)doubleTapEdit:(UITapGestureRecognizer *)sender {
}

- (IBAction)pinchCamera:(UIPinchGestureRecognizer *)sender {
    if (textText.text.length > 0) {
        mCurrentScale += [sender scale] - mLastScale;
        mLastScale = [sender scale];
        
        if (sender.state == UIGestureRecognizerStateEnded)
        {
            mLastScale = 1.0;
        }
        
        timeLabel.layer.transform = CATransform3DMakeScale(mCurrentScale, mCurrentScale, 1.0);
        
//        filterText.scale = mCurrentScale-0.7;
        [self applyFilterSetting];
        [self processImage];
    }
}

- (IBAction)changeEffectIntensity:(UISlider *)sender {
    [self applyFilterSetting];
    [self processImage];
}

- (IBAction)panCamera:(UIPanGestureRecognizer *)sender {
    if (textText.text.length > 0) {
        CGPoint translation = [sender translationInView:viewCamera];
        
        CGPoint center = CGPointMake(timeLabel.center.x + translation.x, timeLabel.center.y + translation.y);
        timeLabel.center = center;

        [self processImage];        
        [sender setTranslation:CGPointMake(0, 0) inView:viewCamera];
    }
}

- (void)newText {
    if (textText.text.length > 0) {
        timeLabel.text = textText.text;
        timeLabel.font = [UIFont fontWithName:currentFont size:100.0];
    }
    if ((currentText.length > 0) != (textText.text.length > 0)) {
        [self preparePipe:NO];
    }
    currentText = textText.text;
    [self applyFilterSetting];
    [self processImage];
}

- (void)countDown:(id)sender {
    if (timerCount == 0) {
        switch (currentTimer) {
            case kTimerNone:
                timerCount = 0;
                break;
            case kTimer5s:
                timerCount = 5;
                break;
            case kTimer10s:
                timerCount = 10;
                break;
            case kTimerContinuous:
                currentTimer = kTimerContinuous;
                break;
            default:
                break;
        }
        
        [timer invalidate];
        [self capturePhotoAsync];
    } else {
        MBProgressHUD *count = [[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:count];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
        label.text = [NSString stringWithFormat:@"%d", timerCount];
        label.textColor = [UIColor whiteColor];
        label.backgroundColor = [UIColor clearColor];
        label.font = [UIFont systemFontOfSize:100];
        label.textAlignment = NSTextAlignmentCenter;
        count.customView = label;
        count.mode = MBProgressHUDModeCustomView;
        
        [count show:YES];
        [count hide:YES afterDelay:0.5];
        count.removeFromSuperViewOnHide = YES;
    }
    timerCount--;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    NSTimeInterval locationAge = -[newLocation.timestamp timeIntervalSinceNow];
    if (locationAge > 5.0) return;

    if (newLocation.horizontalAccuracy < 0) return;

    if (bestEffortAtLocation == nil || bestEffortAtLocation.horizontalAccuracy > newLocation.horizontalAccuracy) {
        bestEffortAtLocation = newLocation;
        if (newLocation.horizontalAccuracy <= locationManager.desiredAccuracy) {
            [locationManager stopUpdatingLocation];
        }
    }
}

- (void)stopUpdatingLocation:(id)sender {
    [locationManager stopUpdatingLocation];
    locationManager.delegate = nil;
}

- (void)setFlash:(BOOL)flash {
    AVCaptureDevice *device = videoCamera.inputCamera;
    
    NSError *error;
    if ([device lockForConfiguration:&error]) {
        if ([device isFlashAvailable]) {
            if (flash)
                [device setFlashMode:AVCaptureFlashModeOn];
            else
                [device setFlashMode:AVCaptureFlashModeOff];
            [device unlockForConfiguration];
        }
    } else {
        TFLog(@"ERROR = %@", error);
    }
}

- (void)setFocusPoint:(CGPoint)point {
    AVCaptureDevice *device = videoCamera.inputCamera;
    
    CGPoint pointOfInterest;
    
    pointOfInterest = CGPointMake(point.y, 1.0 - point.x);
    
    NSError *error;
    if ([device lockForConfiguration:&error]) {
        if ([device isFocusPointOfInterestSupported] && [device isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
            [device setFocusPointOfInterest:pointOfInterest];
            [device setFocusMode:AVCaptureFocusModeAutoFocus];
            [device unlockForConfiguration];
        }
    } else {
        TFLog(@"ERROR = %@", error);
    }
}


- (void)setMetteringPoint:(CGPoint)point {
    AVCaptureDevice *device = videoCamera.inputCamera;
    
    CGPoint pointOfInterest;
    pointOfInterest = CGPointMake(point.y, 1.0 - point.x);
    
    NSError *error;
    if ([device lockForConfiguration:&error]) {;
        if([device isExposurePointOfInterestSupported] && [device isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure])
        {
            [device setExposurePointOfInterest:pointOfInterest];
            [device setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
        }
        [device unlockForConfiguration];
    } else {
        TFLog(@"ERROR = %@", error);
    }
}

#ifdef DEBUG
+(NSString*)orientationToText:(const UIImageOrientation)ORIENTATION {
    switch (ORIENTATION) {
        case UIImageOrientationUp:
            return @"UIImageOrientationUp";
        case UIImageOrientationDown:
            return @"UIImageOrientationDown";
        case UIImageOrientationLeft:
            return @"UIImageOrientationLeft";
        case UIImageOrientationRight:
            return @"UIImageOrientationRight";
        default:
            return @"Unknown orientation!";
    }
}
#endif

#pragma mark UIAccelerometerDelegate
-(void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration {
    UIImageOrientation orientationNew;
    if (acceleration.x >= 0.75) {
        orientationNew = UIImageOrientationDown;
    }
    else if (acceleration.x <= -0.75) {
        orientationNew = UIImageOrientationUp;
    }
    else if (acceleration.y <= -0.75) {
        orientationNew = UIImageOrientationRight;
    }
    else if (acceleration.y >= 0.75) {
        orientationNew = UIImageOrientationLeft;
    }
    else {
        // Consider same as last time
        return;
    }
    
    if (orientationNew == orientationLast)
        return;
    #ifdef DEBUG
        TFLog(@"Going from %@ to %@!", [[self class] orientationToText:orientationLast], [[self class] orientationToText:orientationNew]);
    #endif
    orientationLast = orientationNew;
}
#pragma mark -

- (void)newMask:(UIImage *)mask {
    if (!buttonBlurNone.enabled) {
        [self setUIMask:kMaskBlurNormal];
    }
    
    GLubyte *imageData = NULL;
    // For resized image, redraw
    imageData = (GLubyte *) calloc(1, (int)mask.size.width * (int)mask.size.height * 4);
    CGColorSpaceRef genericRGBColorspace = CGColorSpaceCreateDeviceRGB();
    CGContextRef imageContext = CGBitmapContextCreate(imageData, (size_t)mask.size.width, (size_t)mask.size.height, 8, (size_t)mask.size.width * 4, genericRGBColorspace,  kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    CGContextDrawImage(imageContext, CGRectMake(0.0, 0.0, mask.size.width, mask.size.height), mask.CGImage);
    CGContextRelease(imageContext);
    CGColorSpaceRelease(genericRGBColorspace);
    
    [pictureDOF updateDataFromBytes:imageData size:mask.size];
    free(imageData);
    
    [self applyFilterSetting];
    [self processImage];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}
@end
