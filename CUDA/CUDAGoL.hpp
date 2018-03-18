#define __CL_ENABLE_EXCEPTIONS 

#include <assert.h>
#include <GL/glew.h>

#include <cuda_gl_interop.h>
#include <cuda_runtime_api.h>
#include <cuda.h>

#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <vector>



class CUDAGoL{

    public:
    	int n;
		int width;
		int height;
    	// Size, in bytes, of each vector
    	size_t bytes;	    // Host input vectors
    	int *h_game;
    	int *d_game;
        int *d_width;
        int *d_height;
    	int blockSize;
    	int gridSize;
    	//Host output vector
    	CUDAGoL(const int w, const int h);
    	~CUDAGoL();
    	void randomInit(const double probability = 0.4);
    	int organismAt(const int x, const int y);


};