#include <string.h>
#include <stdio.h>
#include "fitsio.h"

int read_fits(const char * filename)
{
    fitsfile *fptr;         
    char card[FLEN_CARD]; 
    int status = 0,  nkeys, ii;  /* MUST initialize status */

    fits_open_file(&fptr, filename, READONLY, &status);
    fits_get_hdrspace(fptr, &nkeys, NULL, &status);

    for (ii = 1; ii <= nkeys; ii++)  { 
    fits_read_record(fptr, ii, card, &status); /* read keyword */
    printf("%s\n", card);
    }
    printf("END\n\n");  /* terminate listing with END */
    fits_close_file(fptr, &status);

    if (status)          /* print any error messages */
    fits_report_error(stderr, status);
    return(status);
}



int get_image_dimensions(const char * filename, int * ndim)
{
    fitsfile *fptr;         
    int status = 0;
    fits_open_file(&fptr, filename, READONLY, &status);
    fits_get_img_dim( fptr, ndim,  &status);
    return(status);
}



int get_image_axis(const char * filename, long * naxis)
{
    fitsfile *fptr;         
    int status = 0;
    fits_open_file(&fptr, filename, READONLY, &status);
    status =  fits_get_img_size(fptr, 2,  naxis, &status);
    return (status);

}

int get_image_parameters(const char * filename, int * naxis, long * naxes, int * bitpix)
{
    fitsfile *fptr;         
    int status = 0;
    fits_open_file(&fptr, filename, READONLY, &status);
    status = fits_get_img_param(fptr, 2,  bitpix,  naxis, naxes, &status);
    return (status);
}



int read_image(const char * filename, long * naxes, int bitpix, float ** image)
{
    fitsfile *fptr;         
    int status = 0;
    long fpixel[2] = {1,1};
    fits_open_file(&fptr, filename, READONLY, &status);
    *image = (float *)realloc(*image , naxes[0]*naxes[1]*sizeof(float));
    //if(*image!=NULL) {
    //    int i;
    //    for(i=0;i<naxes[0]*naxes[1];i++) (*image)[i] = (float)i;
    //}
    fits_read_pix(fptr, TFLOAT, fpixel, naxes[0]*naxes[1], NULL, *image,  NULL, &status);
    return (status);
}



int check()
{
    return 2;
}