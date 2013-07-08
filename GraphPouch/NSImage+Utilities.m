//
//  NSImage+Utilities.m
//  GraphPouch
//
//  Created by PATRICK LEE on 7/2/13.
//  Copyright (c) 2013 Patrick Lee. All rights reserved.
//

#import "NSImage+Utilities.h"

@implementation NSImage (Utilities)

- (void) saveAsJpegWithName:(NSString*) fileName
{
    // Cache the reduced image
    NSData *imageData = [self TIFFRepresentation];
    NSBitmapImageRep *imageRep = [NSBitmapImageRep imageRepWithData:imageData];
    NSDictionary *imageProps = [NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:1.0] forKey:NSImageCompressionFactor];
    imageData = [imageRep representationUsingType:NSJPEGFileType properties:imageProps];
    [imageData writeToFile:fileName atomically:NO];
}

@end
