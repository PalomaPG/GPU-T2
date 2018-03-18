#include "SeqGoL.hpp"

SeqGoL::SeqGoL(const int w, const int h): width(w), height(h), grid(h*w), tempGrid(h*w) {
    
    xdom = new int [3];
    ydom = new int [3];
    
    srand((unsigned)time(NULL));
    SeqGoL::randomInit();
};

SeqGoL::~SeqGoL() {

    grid.clear();
    tempGrid.clear();


    delete [] xdom;
    delete [] ydom;
}

void SeqGoL::randomInit(const double probability) {      

	for(size_t i=0; i<width*height; i++){
		double r = (double)rand() / RAND_MAX;
		grid[i] = (r>probability);
	}
}

void SeqGoL::iterate() {
    for (size_t i = 0; i < width; ++i) {
		for(size_t j = 0; j < height; ++j) {
            int neighbors = countNeighbors(i, j);
			
			if (grid[i*width+j] == true) {
				if (neighbors == 2 || neighbors == 3) {
					tempGrid[i*width+j] = true;
				}
				else {
					tempGrid[i*width+j] = false;
				}
			} 
			else {
				if (neighbors == 3 || neighbors == 6) {
					tempGrid[i*width+j] = true;
				} 
				else {
					tempGrid[i*width+j] = false;
				}
			}
        }
    }
    
    std::vector<bool> t = grid;
    grid = tempGrid;
    tempGrid = t;
}

int SeqGoL::countNeighbors(const int x, const int y) {
	int neighbors = 0;

	xdom[0] = (x == 0 ? width - 1: x - 1);
	xdom[1] = x;
	xdom[2] = (x == width - 1 ? 0 : x + 1);
	
	ydom[0] = (y == 0 ? height - 1: y - 1);
	ydom[1] = y;
	ydom[2] = (y == height - 1 ? 0 : y + 1);
	
	for(size_t i = 0; i < 3; ++i) {
		for(size_t j = 0; j < 3; ++j) {
            if (!(xdom[i] == x && ydom[j] == y)) {
                if (grid[ydom[i]*width+xdom[j]]) {
                    ++neighbors;
                }
            }
		}
	}
	
	return neighbors;
}

bool SeqGoL::organismAt(const int x, const int y) {
    return grid[y*width+x];
}
