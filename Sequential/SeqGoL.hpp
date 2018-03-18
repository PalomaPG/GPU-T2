#include <cstdlib>
#include <ctime>
#include <vector>

class SeqGoL {
private:

    std::vector<bool> grid;
    std::vector<bool> tempGrid; 

    int *xdom;
    int *ydom;
    
	int width;
	int height;
    int countNeighbors(const int, const int);
public:
    SeqGoL(const int w, const int h);
	~SeqGoL();
	void randomInit(const double probability = 0.4);
	void iterate();
    bool organismAt(const int x, const int y);
};
