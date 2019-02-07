#include<stdlib.h>
#include<stdio.h>
#include <glob.h>
#include<math.h>
#include <arrayfire.h>
#include<iostream>
#include <unistd.h>

#include "fitsread.h"
#include "messages.h"
#include "array_arithmetic.h"


using namespace af;
using namespace std;

#define THRESHOLD1 -33000
#define THRESHOLD2 -10000

array threshold(const array &in, float thresholdValue)
{
    int channels = in.dims(2);
    array ret_val = in.copy();
    if (channels>1)
        ret_val = colorSpace(in, AF_GRAY, AF_RGB);
    ret_val = (ret_val<thresholdValue)*0.0f + 255.0f*(ret_val>thresholdValue);
    return ret_val;
}



int main(int argc, char ** argv)
{
    /*************************************
    // Print the welcome message
    // Also check for no arguments
    *************************************/
    welcome();
    if (argc ==1 )
    {
        no_arguments();
        return 0;
    }

    /***************************************************************************
    Now load the reference image
    There will be three images 
    - The reference image (the reference specified by the user)
    - The target image (the iamge we want to alighn and photometry)
    - The workspace image (used for image alignment etc.)

    Parameters:
    naxis : (int) number of dimensions of image (should be 2)
    naxes : (long int) x and y dimensions of image
    bitpix : (int) data type (should be float)
    x_ref : (float * ) array holding the x bins of the ref image
    y_ref : (float * ) array holding the y bins of the ref image
    x_targ : (float * ) array holding the x bins of the target image
    y_targ : (float * ) array holding the y bins of the target image
    x_work : (float * ) array holding the x bins of the workspace
    y_work : (float * ) array holding the x bins of the workspace
    i : (int) counter
    ****************************************************************************/
    printf("\nLoading the reference image %s...", argv[1]);

    int naxis, bitpix;
    long naxes[2];
    if (get_image_parameters(argv[1], &naxis, naxes, &bitpix))
    {
        failed_to_load_image(argv[1]);
        return 0;
    }
    printf("\n\tDimensions: %ld x %ld", naxes[0], naxes[1] );
    printf("\n\tBITPIX: %d", bitpix);
    float *image;
    image = (float *)malloc(naxes[0]*naxes[1]*sizeof(float));

    if (read_image(argv[1], naxes, bitpix, &image ))
    {
        int status = read_image(argv[1], naxes, bitpix, &image );
        failed_to_load_reference(argv[1], naxes, bitpix, status);
        return 0;
    }

    // Then let's initialise an arrayfire window and an array to go in it
    af::info();
    af::Window myWindow(naxes[1],naxes[0], "2D Plot example: ArrayFire");
    array reference_image( naxes[0],naxes[1], image);
    array reference_x = sum(reference_image, 0);
    array reference_y = sum(reference_image, 0);
    array object_x, object_y, convx, convy;

    array ihist = histogram(-reference_image, 1.05*35259.5, 0.05*34901., 1.05*35259.5);
    array inorm = histEqual(-reference_image, ihist) / (1.05*35259.5);
    do 
    {
        //myWindow.image(threshold(array_fire_image, THRESHOLD1), "Reference image"); 
        myWindow.image(inorm, "Reference image"); 

        cout << '\n' << "Press a key to continue...";
    } while (cin.get() != '\n');



    /****************************************************************
    Now search for files matching the second wildcard argument
    This should be of the form a*.fits or some kind of equivelent.

    This uses the glob package.
    Parameters:
    globbuf : (glob obj) the object used to glob
    flag : (int) flag to control globbing. 

    ****************************************************************/
    printf("\n\nSearching for files in folder : %s" , argv[2]);
    glob_t globbuf;
    globbuf.gl_offs = 2;
    int flags = 0;
    int i=1;
    flags |= (i > 1 ? GLOB_APPEND : 0);
    glob(argv[2], flags, NULL, &globbuf);
    if (globbuf.gl_pathc==0)
    {
        printf("\n\tNo files match : %s\n\n", argv[2]);
        return 0;
    }
    printf("\n\t%ld found!", globbuf.gl_pathc);


    float val;
    unsigned max_idx_x, max_idx_y;
    do 
    {  
        
        for (i=0; i < globbuf.gl_pathc; i++)
        {
            if (read_image(globbuf.gl_pathv[i], naxes, bitpix, &image ))
                printf("\nI Failed with error code : %d", read_image(globbuf.gl_pathv[i], naxes, bitpix, &image )); 

            array current_image = array(naxes[0],naxes[1], image);
            object_x = sum(current_image, 0);
            object_y = sum(current_image, 0);
            convx = real(ifft(fft(reference_x)*fft(flip(object_x, 0))));
            convy = real(ifft(fft(reference_y)*fft(flip(object_y, 0))));
            max(&val, &max_idx_x, convx);
            max(&val, &max_idx_y, convy);

            ihist = histogram(-current_image, 1.05*35259.5, 0.05*34901., 1.05*35259.5);
            inorm = histEqual(-current_image, ihist) / (1.05*35259.5);

            myWindow.image(inorm);   
            //usleep(200000); // in microseconds

            printf("\n\tImage : %s with best %d %d", globbuf.gl_pathv[i], max_idx_x, max_idx_y);
 
        }
        cout << '\n' << "Press a key to continue...";

    } while (cin.get() != '\n');

    return 0;

}
