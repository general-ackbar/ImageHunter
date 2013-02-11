//
//  GalleryViewController.m
//  Image Hunter
//
//  Created by Jonatan Yde on 07/02/13.
//  Copyright (c) 2013 Codeninja. All rights reserved.
//

#import "GalleryViewController.h"
#import "ImageInfo.h"
#import "PreviewController.h"


@implementation GalleryViewController
@synthesize data;

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;

}

#pragma mark - UICollectionView Datasource
// 1

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    
    return [self.data count];
}

// 2
- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView {
    return 1;
}
// 3



- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {

    static NSString *CellIdentifier = @"MediaCell";


    
    ImageInfo *mediaItem = [self.data objectAtIndex: indexPath.row ];
    
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[UICollectionViewCell alloc] init];
    }
    
//    UICollectionViewCell *cell = [cv dequeueReusableCellWithReuseIdentifier:@"FlickrCell " forIndexPath:indexPath];
    cell.backgroundColor = [UIColor whiteColor];

    

    UIImageView *iv = [[UIImageView alloc] initWithImage:[UIImage imageWithData:[NSData dataWithContentsOfURL: [NSURL URLWithString: mediaItem.ThumbURL]]]];
    
    [cell addSubview:iv];
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"segueToPreview" sender:[data objectAtIndex: indexPath.row]];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    PreviewController *dest = [segue destinationViewController];
    ImageInfo *info = (ImageInfo *)sender;
    dest.ImagePreview.image = [UIImage imageWithData:[NSData dataWithContentsOfURL: [NSURL URLWithString: info.ImageURL]]];
    
}


// 4
/*- (UICollectionReusableView *)collectionView:
 (UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
 {
 return [[UICollectionReusableView alloc] init];
 }*/
@end
