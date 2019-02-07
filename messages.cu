#include<stdio.h>
#include<stdlib.h>

#if defined (_OPENMP) && !defined(_OPENACC)
#  include <omp.h>
#endif

#ifndef M_PI
    #define M_PI 3.14159265358979323846
#endif

void welcome()
{

    printf("\n-------------------------------------------------");
    printf("\n-              CUDAPHOT V0.1                    -");
    printf("\n-           samgill844@gmail.com                -");
    printf("\n-                                               -");
    int nDevices;
    cudaGetDeviceCount(&nDevices);
    printf("\n- Summary                                       -");
    printf("\n-           GPU acceleration [%s]             -", nDevices ? "True" : "False");
    #if defined (_OPENMP) && !defined(_OPENACC)
        printf("\n-        OpenMP acceleration [True]            -");
    #else
        printf("\n-        OpenMP acceleration [False]            -");
    #endif
    printf("\n-------------------------------------------------");
}

void no_arguments()
{
    printf("\nIncorrect number of arguments specified.");
    printf("\nUsage:");
    printf("\n\tcudaphot [ref image] [files]\n\n\n");
}

void failed_to_load_image(const char * filename)
{
    printf("\n\tUnable to load %s\n\n\n", filename);
}

void failed_to_read_image(const char * filename)
{
    printf("\n\tUnable to read %s\n\n\n", filename);
}

void failed_to_allocate_image(const char * filename, int bitpix)
{
    printf("\n\tUnable to allocate %s with BITPIX: %d\n\n", filename, bitpix);
}


void failed_to_load_reference(const char * filename, long int * naxes, int bitpix, int status)
{
    printf("\nFAILED:  %s (%ld x %ld) with errorcode : %d\n\n", filename, naxes[0], naxes[1], status);
}
