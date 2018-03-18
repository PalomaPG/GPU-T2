#define __CL_ENABLE_EXCEPTIONS 

#include <cstdlib>
#include <ctime>
#include <cstdio>
#include <CL/cl.hpp>
#include <iostream>
#include <fstream>
#include <vector>
#include <math.h>

using namespace std;

class CLGoL {

private:

	int* grid;
	size_t bytes;

	cl::Buffer inputGrid;
	cl::Buffer outputGrid;
	cl::Buffer d_width;
	cl::Buffer d_height;
	cl_int err;
    // Enqueue kernel
    cl::CommandQueue queue;
    cl::Kernel kernel;
    cl::Event event;
	int width;
	int height;


public:
	CLGoL(const int w, const int h);
	~CLGoL();
	void readMemory();
	void writeMemory();
	void randomInit(const double probability = 0.4);
	void iterate();
	int organismAt(const int x, const int y);
};