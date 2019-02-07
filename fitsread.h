int check();
int read_fits(const char * filename);
int get_image_dimensions(const char * filename, int * ndim);
int get_image_axis(const char * filename, long * naxis);
int get_image_parameters(const char * filename, int * naxis, long * naxes, int * bitpix);
int read_image(const char * filename, long * naxes, int bitpix, float ** image);