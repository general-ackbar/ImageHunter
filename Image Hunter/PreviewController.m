//
//  PreviewController.m
//  Image Hunter
//
//  Created by Jonatan Yde on 09/02/13.
//  Copyright (c) 2013 Codeninja. All rights reserved.
//

#import "PreviewController.h"
#import "UIImage+animatedGIF.h"


@implementation PreviewController
@synthesize scrollViewPane, imageUrl, spinner;

-(void)viewDidLoad
{
    [super viewDidLoad];
    com = [[Communicator alloc] init];
    scrollViewPane.delegate = self;
    //scrollViewPane.contentSize = CGSizeMake(1000, 1000);
    scrollViewPane.maximumZoomScale = 8.0f;
    scrollViewPane.minimumZoomScale = .5f;

    
    spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle: UIActivityIndicatorViewStyleMedium];
    [[self spinner] setCenter:CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height/2)];
    [self.view addSubview:spinner];

    

    [spinner startAnimating];

    NSThread *t = [[NSThread alloc] initWithTarget:self selector:@selector(loadImageasynchronous) object:nil];
    [t start];
    
    
    UIBarButtonItem *sendToLED = [[UIBarButtonItem alloc] initWithTitle:@">>" style:UIBarButtonItemStylePlain target:self action:@selector(sendData)];
    
    self.navigationItem.rightBarButtonItems = @[sendToLED];
    
}


-(void)sendData
{

    UIImage *img = [self imageFromView: self.scrollViewPane];
    NSData *imageData = UIImagePNGRepresentation(img);
    
    [com connectToServer:@"ledpi" onPort:8888];
    [com open];
    com.delegate = self;
    
    [com sendMessage:@"FILE=/temp.png"];
    [com sendData: imageData];
}

-(void)didRecieveMessage:(NSString *)message
{
    NSLog(@"%@", message);
    if([message isEqualToString:@"DONE"])
        [com close];
}

-(UIImage *)imageFromView:(UIScrollView *)view
{
    UIGraphicsBeginImageContext(view.frame.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextRotateCTM(context, 2*M_PI); //otherwise it will be upside down due to diffrent coordinate systems
    
    float destRatio = 128.0/96.0;
    float srcRatio = view.frame.size.width / view.frame.size.height;
    CGRect crop;
    if(destRatio < srcRatio)
        crop = CGRectMake((view.frame.size.width - view.frame.size.height*destRatio)/2,0, view.frame.size.height*destRatio, view.frame.size.height  );
    else
        crop = CGRectMake(0,0, view.frame.size.width, view.frame.size.width/destRatio  );
    
    CGPoint offset = view.contentOffset;
    
    CGContextTranslateCTM(context, -offset.x, -offset.y);

    
    [view.layer renderInContext:context];
    
    UIImage *outputImage = [UIImage imageWithCGImage: CGImageCreateWithImageInRect(UIGraphicsGetImageFromCurrentImageContext().CGImage, crop)];
    
    UIGraphicsEndImageContext();

    return outputImage;
}

-(void)loadImageasynchronous
{
    dispatch_async(dispatch_get_main_queue(), ^{

        UIImage *img;
        if([[self.imageUrl.pathExtension lowercaseString] isEqualToString:@"gif"])
        {
            img = [UIImage animatedImageWithAnimatedGIFData:[NSData dataWithContentsOfURL:[NSURL URLWithString:self.imageUrl]]];
        } else {
            img = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:self.imageUrl]]];
        }
        
     
    
    UIImageView *imv = [[UIImageView alloc]initWithImage:img];
    imv.tag = 1;
    imv.userInteractionEnabled = YES;

    self->scrollViewPane.contentSize = img.size;
    imv.frame = self.view.bounds;
    
   imv.contentMode = UIViewContentModeScaleAspectFit;
    
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
    [imv addGestureRecognizer:singleTap];

    dispatch_async(dispatch_get_main_queue(), ^{
        [self->scrollViewPane addSubview: imv];
        [self->spinner stopAnimating];
    });

        });
}


-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return [scrollView viewWithTag:1]; // self.imagePreview;
}


-(void)singleTap:(id *)sender
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

@end
