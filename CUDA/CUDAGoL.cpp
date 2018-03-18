#include "CUDAGoL.hpp"

CUDAGoL::CUDAGoL(const int w, const int h):n(w*h), width(w), height(h){

	// Size, in bytes, of each vector
    bytes = n*sizeof(int);
        // Allocate memory for each vector on host
    h_game = (int*)malloc(bytes);

   // Number of threads in each thread block
    blockSize = 1024;
 
    // Number of thread blocks in grid
    gridSize = (int)ceil((float)(n/blockSize));

 	// Initialize vectors on host
   CUDAGoL::randomInit();
    
 
}


void CUDAGoL::randomInit(const double probability) {      

	for(size_t i=0; i<width*height; i++){
		double r = (double)rand() / RAND_MAX;
		h_game[i] = (r>probability);
	}
}


CUDAGoL::~CUDAGoL(){

	delete h_game;
}

int CUDAGoL::organismAt(const int col, const int row) {
	    return h_game[row*width+col];
}


