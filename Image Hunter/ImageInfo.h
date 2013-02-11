//
//  ImageInfo.h
//  Image Hunter
//
//  Created by Jonatan Yde on 08/02/13.
//  Copyright (c) 2013 Codeninja. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ImageInfo : NSObject
{
    NSString *GoogleSource;
    NSString *GoogleID;
    NSString *ImageURL;
    NSString *ImageWidth;
    NSString *ImageHeight;
    NSString *ThumbWidth;
    NSString *ThumbHeight;
    NSString *ThumbURL;
    NSString *Title;
    NSString *Extension;
    NSString *Domain;
    NSString *GoogleURL;
    NSString *Info;
    NSString *Filename;
}

@property (retain) NSString *GoogleSource;
@property (retain) NSString *GoogleID;
@property (retain) NSString *ImageURL;
@property (retain) NSString *ImageWidth;
@property (retain) NSString *ImageHeight;
@property (retain) NSString *ThumbWidth;
@property (retain) NSString *ThumbHeight;
@property (retain) NSString *ThumbURL;
@property (retain) NSString *Title;
@property (retain) NSString *Extension;
@property (retain) NSString *Domain;
@property (retain) NSString *GoogleURL;
@property (retain) NSString *Info;
@property (retain) NSString *Filename;

@end

