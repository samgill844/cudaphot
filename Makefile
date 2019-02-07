cc=nvcc
CFITSIOFLAGS= -lcurl -I/home/sam/Documents/Software/cfitsio/include -L/home/sam/Documents/Software/cfitsio/lib -lcfitsio
OPENMPFLAGS=  -Xcompiler  -fopenmp 
GSLFLAGS=   -I/usr/local/include -lgsl -lgslcblas -lm
ARRAYFIREFLAGS = -std=c++11 -I/opt/arrayfire/include/ -L/opt/arrayfire/lib64/ -lafopencl

#PREFIX is environment variable, but if it is not set, then set default value
ifeq ($(PREFIX),)
    PREFIX := /usr/bin
endif


all: cudaphot

cudaphot: fitsread.o messages.o array_arithmetic.o cudaphot.cpp 
	$(cc) $(CFITSIOFLAGS) $(ARRAYFIREFLAGS) -L/opt/lib -O3  -o cudaphot cudaphot.cpp fitsread.o messages.o array_arithmetic.o

fitsread.o: fitsread.cu
	$(cc) $(CFITSIOFLAGS) -O3 -c fitsread.cu 

messages.o: messages.cu
	$(cc) $(OPENMPFLAGS) -O3 -c messages.cu

array_arithmetic.o: array_arithmetic.cu 
	$(cc) -O3 -c array_arithmetic.cu

install: cudaphot
	mv cudaphot $(PREFIX)
	rm *.o

clean:
	rm *.o
	rm cudaphot
