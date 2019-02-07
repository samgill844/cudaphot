#include<stdlib.h>
#include<stdio.h>
#include<math.h>

void sum_arrays_xy(double * xref, double * yref, int Nx, int Ny, long int * axes, float * image)
{
    // i is the x axis (row)
    // j is the y axis (col)
    int i, j;
    double mean=0.;
    for (i=0; i < Nx; i++)
    {
        if (i < axes[1]) 
        {
            for (j=0; j < axes[0]; j++)
            {
                xref[i] +=  (double) image[j*i + j];
                mean += (double) image[j*i + j];
            }
        }
        else xref[i] = 0.; // zero padding
    }
    for (j=0; j < axes[1]; j++)
        xref[j] = xref[j] - mean/axes[0];
    
    printf("\nMean 1 : %f", mean/axes[1]);
    mean = 0.;
    for (j=0; j < Ny ; j++)
    {
        if (j < axes[0]) 
        {
            for (i=0; i < axes[1]; i++)
            {
                yref[j] +=  (double) image[j*i + j];
                mean += (double) image[j*i + j];
            }
        }
        else yref[j] = 0.; // zero padding
    }
    for (i=0; i < axes[0]; i++)
        yref[i] = yref[i] - mean/axes[0];
    printf("Mean 2 : %f", mean/axes[1]);

}