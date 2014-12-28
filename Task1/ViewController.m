//
//  ViewController.m
//  Task1
//
//  Created by Saibhan on 12/23/14.
//  Copyright (c) 2014 Saibhan Nadirov. All rights reserved.
//

#import "ViewController.h"
#import "CoreData/CoreData.h"
#import "UIImage+Filters.h"

@interface ViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate>

@property (strong) NSMutableArray *images;
@end

@implementation ViewController

// Using core data to store binary data
- (NSManagedObjectContext *)managedObjectContext {
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)]) {
        context = [delegate managedObjectContext];
    }
    return context;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString* path = [documentsDirectory stringByAppendingPathComponent:@"sourceImage.jpg" ];
    // Loading source image if we loaded it previously
    [self.sourceImage setImage:[UIImage imageWithContentsOfFile:path]];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.tableView.tableFooterView = [[UIView alloc] init]; // Removes separator lines in empty rows, actually just removes empty rows
    [self reloadTable];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)Rotate:(UIButton *)sender
{
    UIImage *rotatedImage = [UIImage imageRotatedByDegrees:self.sourceImage.image deg:90];
    [self saveData:rotatedImage];
    [self reloadTable];
}
- (IBAction)InvertColors:(UIButton *)sender
{
    //using background thread not to block UI
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImage *invertedImage = [UIImage blackAndWhite:self.sourceImage.image];
        [self saveData:invertedImage];
        [self reloadTable];
    });
}
- (IBAction)Mirror:(UIButton *)sender
{
    UIImage *mirroredImage = [UIImage mirrored:self.sourceImage.image];
    [self saveData:mirroredImage];
    [self reloadTable];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return self.images.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
     
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    NSManagedObject *cellObject = [self.images objectAtIndex:indexPath.row];
    UIImageView *finalImage = (UIImageView*)[cell viewWithTag:50]; //using tag for simplicity here
    [finalImage  setImage:[UIImage imageWithData:[cellObject valueForKey:@"image"]]];
    return cell;
 }

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([UIAlertController class]) // If iOS 8.0+
    {

        UIAlertController * alert =  [UIAlertController
                                      alertControllerWithTitle:[NSString stringWithFormat:@"Select Your Option"]
                                      message:nil
                                      preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* one = [UIAlertAction
                                actionWithTitle:[NSString stringWithFormat:@"Save To Gallery"]
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction * action) {
                                    [self SaveToGallery:indexPath.row];
                                    [alert dismissViewControllerAnimated:YES completion:nil]; }];
        UIAlertAction* two = [UIAlertAction
                                actionWithTitle:[NSString stringWithFormat:@"Use as Source Image"]
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction * action) {
                                    [self UseAsSource:indexPath.row];
                                    [alert dismissViewControllerAnimated:YES completion:nil]; }];
        [alert addAction:one];
        [alert addAction:two];
            
        [alert addAction: [UIAlertAction actionWithTitle:[NSString stringWithFormat:@"Cancel"] style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        [alert dismissViewControllerAnimated:YES completion:nil]; }]];
        alert.view.tintColor = [UIColor blueColor];
        [self presentViewController:alert animated:YES completion:nil];
    }
    else
    {
        // Deprecated in iOS 8.0+
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Select Your Option"]
                    message:nil
                    delegate:self
                    cancelButtonTitle:[NSString stringWithFormat:@"Cancel"]  otherButtonTitles:[NSString stringWithFormat:@"Save to Gallery"], [NSString stringWithFormat:@"Use as Source Image"] ,nil];
        alertView.tag = indexPath.row;
        [alertView show];
    }

}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Handling delete action
    NSManagedObjectContext *context = [self managedObjectContext];
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete object from database
        [context deleteObject:[self.images objectAtIndex:indexPath.row]];
        NSError *error = nil;
        if (![context save:&error]) {
            NSLog(@"Can't Delete! %@ %@", error, [error localizedDescription]);
            return;
        }
        // Remove image from table view
        [self.images removeObjectAtIndex:indexPath.row];
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
    }
}

- (void)displayImagePickerWithSourceType:(UIImagePickerControllerSourceType)sourceType {
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    // Settings of imagePickerController
    imagePicker.delegate = self;
    imagePicker.sourceType = sourceType;
    imagePicker.allowsEditing = YES;
    imagePicker.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    imagePicker.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:imagePicker animated:YES completion:nil];
}

- (IBAction)ChoosePicture:(UIButton *)sender {
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] && [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) // If device has both camera and gallery available
     {
         if ([UIAlertController class]) { // If iOS 8.0+
            UIAlertController * alert =  [UIAlertController
                                          alertControllerWithTitle:[NSString stringWithFormat:@"Select Your Option"]
                                          message:nil
                                          preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* one = [UIAlertAction
                                  actionWithTitle:[NSString stringWithFormat:@"Take a Picture"]
                                  style:UIAlertActionStyleDefault
                                  handler:^(UIAlertAction * action)
                                  {
                                      [self displayImagePickerWithSourceType:UIImagePickerControllerSourceTypeCamera];
                                      [alert dismissViewControllerAnimated:YES completion:nil];
                                      
                                  }];
            UIAlertAction* two = [UIAlertAction
                                  actionWithTitle:[NSString stringWithFormat:@"Choose from Gallery"]
                                  style:UIAlertActionStyleDefault
                                  handler:^(UIAlertAction * action)
                                  {
                                      [self displayImagePickerWithSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
                                      [alert dismissViewControllerAnimated:YES completion:nil];
                                      
                                  }];
            [alert addAction:one];
            [alert addAction:two];
            [alert addAction: [UIAlertAction actionWithTitle:[NSString stringWithFormat:@"Cancel"] style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            [alert dismissViewControllerAnimated:YES completion:nil]; }]];
            alert.view.tintColor = [UIColor blueColor];
            [self presentViewController:alert animated:YES completion:nil]; }
         
         else { // Deprecated in iOS 8.0
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Select Your Option"]
                                     message:nil
                                     delegate:self
                                     cancelButtonTitle:[NSString stringWithFormat:@"Cancel"]  otherButtonTitles:[NSString stringWithFormat:@"Take a Picture"], [NSString stringWithFormat:@"Choose from Gallery"] ,nil];
             [alertView show];
            alertView.tag = 1; // Putting tag here because alertViewController is used twice
         }
    }
    else if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
        {
            [self displayImagePickerWithSourceType:UIImagePickerControllerSourceTypeCamera];
        }
    else if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
        {
            [self displayImagePickerWithSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
        }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    // Using two AlertViewContollers
    // Used in < iOS 8.0
    if (buttonIndex == alertView.cancelButtonIndex) {
        return; }
    else if (alertView.tag == 1) // putting tag on first one
    {
        if (buttonIndex == 1) {
            [self displayImagePickerWithSourceType:UIImagePickerControllerSourceTypeCamera];
            return;}
        else {
            [self displayImagePickerWithSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
            return;}
    }
    else
    {
        if (buttonIndex == 1)
        {
            [self SaveToGallery:alertView.tag]; // alertView.tag = indexPath.row
            return;
        }
        else {
            [self UseAsSource:alertView.tag]; // alertView.tag = indexPath.row
            return;
        }
    }
}

#pragma mark - Image picker delegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [self dismissViewControllerAnimated:YES completion:nil];
    
    UIImage  *image = info[UIImagePickerControllerEditedImage];
    NSData *imageData = UIImageJPEGRepresentation(image, 1.0);
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *savedImagePath = [documentsDirectory stringByAppendingPathComponent:@"sourceImage.jpg"];
    [imageData writeToFile:savedImagePath atomically:NO];
    [self.sourceImage setImage:[UIImage imageWithContentsOfFile:savedImagePath]]; // Showing chosen picture as Source Image
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)reloadTable
{
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"EditedImage"];
    self.images = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
    [self.tableView reloadData];
    [self.tableView setContentOffset:CGPointMake(0, self.tableView.contentSize.height-self.tableView.frame.size.height) animated:YES]; // Will scroll to the latest added image
}

- (void)saveData:(UIImage*)image
{
    NSData *imageData = UIImageJPEGRepresentation(image, 1.0);
    NSManagedObjectContext *context = [self managedObjectContext];
    NSManagedObject *newObject = [NSEntityDescription insertNewObjectForEntityForName:@"EditedImage" inManagedObjectContext:context];
    [newObject setValue:imageData forKey:@"image"];
    NSError *error = nil;
    // Save the object to persistent store
    if (![context save:&error]) {
        NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
    }
}

- (UIImage*)selectedRowImage:(NSInteger)hitIndexRow // hitIndexRow = indexPath.row
{
    NSManagedObject *cellObject = [self.images objectAtIndex:hitIndexRow];
    return [UIImage imageWithData:[cellObject valueForKey:@"image"]];
}

- (void)UseAsSource:(NSInteger)hitIndexRow // hitIndexRow = indexPath.row
{
    [self.sourceImage  setImage:[self selectedRowImage:hitIndexRow]];
}

- (void)SaveToGallery:(NSInteger)hitIndexRow // hitIndexRow = indexPath.row
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImageWriteToSavedPhotosAlbum([self selectedRowImage:hitIndexRow], nil, nil, nil);
    });
}

@end
