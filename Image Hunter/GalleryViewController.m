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
#import "UILazyImageView.h"
#import "GoogleSearcher.h"




@implementation GalleryViewController
@synthesize requestData, spinner, query;

-(void)viewDidLoad
{
    
    
    [super viewDidLoad];
    
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;

    
    currentIndex = 0;
    
    UIBarButtonItem *editButton = self.editButtonItem;
    editButton.title = NSLocalizedString(@"Select", @"Select");
    selectionActive = NO;
    [editButton setTarget:self];
    [editButton setAction:@selector(switchSelectionMode:)];
    
    self.navigationItem.rightBarButtonItem = editButton;
    
    
    
    [(UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout setFooterReferenceSize:CGSizeMake(self.view.frame.size.width , 44)];
    
    
    saveButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(beginDownload:)];
    
    if (@available(iOS 13.0, *)) {
        busy = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleMedium];
    } else {
        // Fallback on earlier versions
    }
    busy.hidesWhenStopped = YES;
    
    busyIndicator =[[UIBarButtonItem alloc] initWithCustomView: busy];
    
    selectedCells = [[NSMutableArray alloc] init];
     
}

/*
-(UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    
    UICollectionReusableView *cell = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"MediaCell" forIndexPath:indexPath];
    return cell;
}
 */


#pragma mark - UICollectionView Datasource
// 1

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    
    return [self.requestData count];
}

// 2
- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView {
    return 1;
}
// 3



- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {

    static NSString *CellIdentifier = @"MediaCell";
    
    ImageInfo *mediaItem = [self.requestData objectAtIndex: indexPath.row ];
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[UICollectionViewCell alloc] init];
    }
    
    cell.backgroundColor = [UIColor blackColor];

    UILazyImageView *lv = [[UILazyImageView alloc] init]; //WithImage:[UIImage imageNamed:@"empty-frame.png"]];
    lv.contentMode = UIViewContentModeScaleToFill;
    lv.frame = cell.bounds;
    lv.url = mediaItem.ThumbURL;
    
    [cell addSubview:lv];
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if(selectionActive)
    {
        UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
        if([selectedCells containsObject:indexPath])
        {
            cell.alpha = 1;
            [selectedCells removeObject:indexPath];
        }
        else
        {
            cell.alpha = 0.5;
            [selectedCells addObject:indexPath];
        }
        
    }
    else
        [self performSegueWithIdentifier:@"segueToPreview" sender:[requestData objectAtIndex: indexPath.row]];
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    PreviewController *dest = [segue destinationViewController];
    ImageInfo *info = (ImageInfo *)sender;
    dest.imageUrl = info.ImageURL;
}


// 4
/*- (UICollectionReusableView *)collectionView:
 (UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
 {
 return [[UICollectionReusableView alloc] init];
 }*/
- (IBAction)switchSelectionMode:(id)sender {
//    UIBarButtonItem *button = (UIBarButtonItem *)sender;

    if(selectionActive)
    {
        self.navigationItem.rightBarButtonItem.title = NSLocalizedString(@"Select", @"Select");
        self.navigationItem.rightBarButtonItem.style = UIBarButtonSystemItemEdit;
        selectionActive = NO;
        
        for (NSIndexPath *cellIndex in selectedCells) {
            [self.collectionView cellForItemAtIndexPath:cellIndex].alpha = 1;
        }
        
        self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:self.navigationItem.rightBarButtonItem, nil];
    }
    else
    {
        self.navigationItem.rightBarButtonItem.title = NSLocalizedString(@"Done", @"Done");
        self.navigationItem.rightBarButtonItem.style = UIBarButtonSystemItemDone;
        
        
        selectionActive = YES;
        for (NSIndexPath *cellIndex in selectedCells) {
            [self.collectionView cellForItemAtIndexPath:cellIndex].alpha = 0.5;
        }
        self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects: self.navigationItem.rightBarButtonItem, saveButton, busyIndicator, nil];
    }
}

#if TARGET_OS_MACCATALYST

-(IBAction)beginDownload:(id)sender
{
    __block NSInteger downloadCount = 0;
    __block NSInteger totalCount = 0;
    

    //Start spinner
    dispatch_async(dispatch_get_main_queue(), ^{
        [self->busy startAnimating];
    });

    //Iterate through the selected files
    for (NSIndexPath *index in selectedCells) {
        
        NSURL *url = [NSURL URLWithString: ((ImageInfo *)[requestData objectAtIndex:index.item]).ImageURL];

        
        [[[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if ( !error )
            {
                
                bool success = [self saveImageData:data as: url.lastPathComponent toFolder:self.title];
                totalCount++;
                if (!success) {
                    //An error occurred
                    NSLog(@"Failed to save image. %@", index);
                }
                else
                {
                    //The files was saved succesfully
                    downloadCount++;
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.collectionView cellForItemAtIndexPath:index].alpha = 1;
                });
                
                //Clear alpha marking
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.collectionView cellForItemAtIndexPath:index].alpha = 1;
                });
                
                //All done, so inform user
                if(totalCount == self->selectedCells.count)
                {
                    //Clear the selected images
                    [self->selectedCells removeAllObjects];
                    
                    //Show alert box when all done. Inform user how many images were actually saved
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Done" message:[NSString stringWithFormat:@"Succeded to download %ld images.", (long)downloadCount] preferredStyle:UIAlertControllerStyleAlert];
                        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                                              handler:^(UIAlertAction * action) {}];
                        [alert addAction:defaultAction];
                        
                        //Once the user press OK stop spinner
                        [self presentViewController:alert animated:YES completion:^{
                            
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [self->busy stopAnimating];
                            });
                        }];
                    });
                }
            } else {
                NSLog(@"Error download an image");
            }
        }] resume];
    }

}
#else


- (IBAction)beginDownload:(id)sender
{
    __block NSInteger downloadCount = 0;
    __block NSInteger totalCount = 0;
    

    //Start spinner
    dispatch_async(dispatch_get_main_queue(), ^{
        [self->busy startAnimating];
    });

    //Iterate through the selected files
    for (NSIndexPath *index in selectedCells) {
        
        //Get URL
        /*
        NSInteger item = index.item;
        ImageInfo *info = [requestData objectAtIndex:item];
        NSURL *url = [NSURL URLWithString: info.ImageURL];
        */
        NSURL *url = [NSURL URLWithString: ((ImageInfo *)[requestData objectAtIndex:index.item]).ImageURL];
        
        //Start asynchronous download of image
        [self downloadImageWithURL:url completionBlock:^(BOOL succeeded, UIImage *image) {
            
            if(succeeded)
            {
            //save image once downloaded
            [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^
             {
                 PHAssetChangeRequest *changeRequest = [PHAssetChangeRequest  creationRequestForAssetFromImage:image];
                 changeRequest.creationDate = [NSDate date];
             }
             completionHandler:^(BOOL success, NSError * _Nullable error) {
                //Keep track of files processed
                totalCount++;
                if (!success) {
                    //An error occurred
                    NSLog(@"Failed to save image. %@", index);
                } else {
                    //The files was saved succesfully
                    downloadCount++;
                }
                //Clear alpha marking
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.collectionView cellForItemAtIndexPath:index].alpha = 1;
                });
                
                //All done, so inform user
                if(totalCount == self->selectedCells.count)
                {
                    //Clear the selected images
                    [self->selectedCells removeAllObjects];
                    
                    //Show alert box when all done. Inform user how many images were actually saved
                    dispatch_async(dispatch_get_main_queue(), ^{
        
                        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Done" message:[NSString stringWithFormat:@"Succeded to download %ld images.", (long)downloadCount] preferredStyle:UIAlertControllerStyleAlert];
                                                          UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                                          handler:^(UIAlertAction * action) {}];
                        [alert addAction:defaultAction];

                        //Once the user press OK stop spinner
                        [self presentViewController:alert animated:YES completion:^{
                                                              
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self->busy stopAnimating];
                        });
                                                              
                                                              
                    }];
                });
               }
              }
             
             ] ;
            } else { NSLog(@"Error download an image"); }
        }];
        
        
    }

}

#endif


- (void)downloadImageWithURL:(NSURL *)url completionBlock:(void (^)(BOOL succeeded, UIImage *image))completionBlock
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:  ^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if ( !error )
        {
            UIImage *image = [[UIImage alloc] initWithData:data];
            completionBlock(YES,image);
        } else{
            completionBlock(NO,nil);
        }

    }];
    [task resume];
}



- (void)downloadImagesAsynchronous
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self->spinner stopAnimating];
    });
    
}

- (IBAction)buttonLoadMore:(id)sender {
    
    currentIndex += 100;
    
    NSString *url = [NSString stringWithFormat:@"https://www.google.dk/search?%@&start=%d", query, currentIndex];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]  initWithURL:[NSURL URLWithString: url]];
    
    //Pretend we are a desktop browser
    NSString* userAgent = @"Mozilla/5.0 (Macintosh; Intel Mac OS X 10.10; rv:43.0) Gecko/20100101 Firefox/43.0";
    [request setValue:userAgent forHTTPHeaderField:@"User-Agent"];
    
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:  ^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if(error)
        {
            NSLog(@"%@", error.description);
        }
        
        NSString *responseBody = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
        NSArray *links = [GoogleSearcher ParseResultsFrom:responseBody];
        
        [self->requestData addObjectsFromArray:links];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.collectionView reloadData];
        });
    }] resume];
}

-(BOOL) saveImageData: (NSData *)data as:(NSString *)name toFolder:(NSString *)folder {
    NSURL *downloadFolder = [[[NSFileManager defaultManager] URLsForDirectory:NSDownloadsDirectory inDomains:NSUserDomainMask] firstObject];
    NSURL *subFolder = [downloadFolder URLByAppendingPathComponent:folder];
    NSError *error;
    if(![[NSFileManager defaultManager] fileExistsAtPath:subFolder.absoluteString])
    {
        [[NSFileManager defaultManager] createDirectoryAtURL:subFolder withIntermediateDirectories:YES attributes:nil error:&error];
        if(error)
            NSLog(@"%@", error.description);
    }
        
    NSURL *fileURL = [subFolder URLByAppendingPathComponent:name];
    int counter = 1;
    
    while([[NSFileManager defaultManager] fileExistsAtPath:fileURL.path ])
    {
        fileURL = [subFolder URLByAppendingPathComponent: [NSString stringWithFormat: @"%@_%d.%@", [name stringByDeletingPathExtension], counter, [name pathExtension]]];
        counter++;
    }
    // Save image data to file.
    [data writeToURL:fileURL options:NSDataWritingAtomic error:&error];

    if(error){
        NSLog(@"%@", error.description);
        return false;
    }
    else
    {
        return true;
    }
}

@end
