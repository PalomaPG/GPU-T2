#include "CUDAGoL.hpp"

#include <GL/gl.h>
#include <GL/glu.h>
#include <GL/glut.h>
#include <GL/freeglut_ext.h>
#include <ctime>

#define WHITE 1.0, 1.0, 1.0
#define BLACK 0.0, 0.0, 0.0


GLint FPS = 24;
GLint window_width = 600;
GLint window_height = 600;
GLfloat p_left = 0.0;
GLfloat p_right = 1.0;
GLfloat bottom = 0.0;
GLfloat top = 1.0;
GLint game_width = 100;
GLint game_height = 100;

CUDAGoL *game;

__device__ int countBottomLeft(
					int *grid,
					int width, 
					int height
					)
{

	int sum = 0;
	sum +=grid[1];
	sum +=grid[width]; //y=0
	sum +=grid[width+1];

	sum +=grid[width-1];
	sum +=grid[2*width-1];

	sum +=grid[(height-1)*width];
	sum +=grid[(height-1)*width+1];

	sum +=grid[height*width-1];

	return sum;
}

__device__ int countBottomRight(
					int *grid,
					int width,
					int height
					)
{

	int sum = 0;
	sum +=grid[width-2];
	sum +=grid[width*2-1]; //y=0
	sum +=grid[width*2 -2];

	sum +=grid[0];
	sum +=grid[width];

	sum +=grid[(height*width)-1];
	sum +=grid[(height*width)-2];

	sum += grid[(height-1)*width];

	return sum;	
}

__device__ int countTopLeft(
					int *grid,
					int width, 
					int height
				)
{

	int sum = 0;
	sum += grid[width*(height-1)+1];
	sum += grid[width*(height-2)]; //y=0
	sum += grid[width*(height-2)+1];

	sum += grid[(width*height)-1];
	sum += grid[(width*(height-1))-1];

	sum += grid[0];
	sum += grid[1];

	sum += grid[width-1];
	return sum;	

}

__device__ int countTopRight(
					int *grid,
					int width, 
					int height
				)
{

	int sum = 0;
	sum += grid[width-2];
	sum += grid[2*width-1];
	sum += grid[2*width-2];

	sum += grid[width*height-1];
	sum += grid[width*(height-1)-1];

	sum += grid[width-1];
	sum += grid[width-2];

	sum += grid[0];

	return sum;	
}

__device__ int countLeftEdge(
					int *grid,
					int width, 
					int height,
					int y
				)
{

	int sum = 0;
	sum += grid[(y+1)*width];
	sum += grid[(y+1)*width+1];
	sum += grid[y*width+1];
	sum += grid[(y-1)*width];
	sum += grid[(y-1)*width+1];

	sum += grid[(y+2)*width-1];
	sum += grid[(y+1)*width-1];
	sum += grid[y*width-1];

	return sum;	

}

__device__ int countRightEdge(
					int *grid,
					int width, 
					int height,
					int y
				)
{
	int sum = 0;
	sum += grid[(y+2)*width-1];
	sum += grid[(y+2)*width-2];
	sum += grid[(y+1)*width-2];
	sum += grid[y*width-2];
	sum += grid[y*width-1];

	sum += grid[(y+1)*width];
	sum += grid[y*width];
	sum += grid[(y-1)*width];

	return sum;	

}

__device__ int countBottomEdge(
					int *grid,
					int width, 
					int height,
					int x
				)
{
	int sum = 0;
	sum += grid[x-1];
	sum += grid[x+1];
	sum += grid[(width-1)+x-1];
	sum += grid[(width-1)+x];
	sum += grid[(width-1)+x+1];

	sum +=grid[(height -1)*width + x -1];
	sum +=grid[(height -1)*width + x];
	sum +=grid[(height -1)*width + x + 1];
	return sum;
}

__device__ int countTopEdge(
					int *grid,
					int width, 
					int height,
					int x
				)
{
	int sum = 0;
	sum += grid[((height-1)*width-1)+x-1];
	sum += grid[((height-1)*width-1)+x+1];
	sum += grid[((height-2)*width-1)+x-1];
	sum += grid[((height-2)*width-1)+x];
	sum += grid[((height-2)*width-1)+x+1];

	sum +=grid[x-1];
	sum +=grid[x];
	sum +=grid[x+1];
	return sum;
}

__device__ int countMiddle(
					int *grid,
					int width, 
					int height,
					int x,
					int y
				)
{

	int sum=0;
	int pos = y*width+x;
	sum +=grid[pos+1];
	sum +=grid[pos-1];
	pos = (y-1)*width+x;
	sum +=grid[pos];
	sum +=grid[pos-1];
	sum +=grid[pos+1];
	pos = (y+1)*width+x;
	sum +=grid[pos];
	sum +=grid[pos-1];
	sum +=grid[pos+1];

	return sum;

}
__device__ int countNeighbors(int *grid, int *width, int *height, int id){
	
	if(id==0) return countBottomLeft(grid, *width, *height);
	else if(id==*width-1) return countBottomRight(grid, *width, *height);
	else if(id==*width*(*height-1)) return countTopLeft(grid, *width, *height);
	else if(id==(*width**height)-1) return countTopRight(grid, *width, *height);
	else {

		int row = id/(*width);
		int col = id % *width;

		if( col == 0)
			return countLeftEdge(grid, *width, *height, row);
		
		else if( col == ((*width)-1))
			return countRightEdge(grid, *width, *height, row);
		
		else if(row == 0)
			return countBottomEdge(grid, *width, *height, col);

		else if(row == ((*height)-1))
			return countTopEdge(grid, *width, *height, col);

		else return countMiddle(grid, *width, *height, col, row);


	}
}


__device__ int execRules(int *grid, int *width, int *height, int id){
	
	int sum = countNeighbors(grid, width, height, id);

	if(grid[id]==0) return (sum ==3 || sum == 6)? 1 : 0;
	else return (sum == 2 || sum == 3)? 1 : 0;
}

__global__ void gol(int *grid, int *width, int *height)
{
    // Get our global thread ID
    int id = blockIdx.x*blockDim.x+threadIdx.x;
    grid[id] = execRules(grid, width, height, id);
}


void closeprogram(unsigned char key, int x, int y){
	if(key==27)
		exit(0);
}

void display() {
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
	glLoadIdentity();
	
    GLfloat xSize = (p_right - p_left) / game_width;
	GLfloat ySize = (top - bottom) / game_height;
	
	glBegin(GL_QUADS);
	
	for (GLint x = 0; x < game_width; ++x) {
		for (GLint y = 0; y < game_height; ++y) {
            game->organismAt(x, y)? glColor3f(BLACK):glColor3f(WHITE);
            
			glVertex2f(    x*xSize+p_left,    y*ySize+bottom);
			glVertex2f((x+1)*xSize+p_left,    y*ySize+bottom);
			glVertex2f((x+1)*xSize+p_left,(y+1)*ySize+bottom);
			glVertex2f(    x*xSize+p_left,(y+1)*ySize+bottom);
		}
	}
	glEnd();
    	
	glFlush();
	glutSwapBuffers();
}


void reshape(int w, int h) {
	window_width = w;
	window_height = h;

	glViewport(0, 0, window_width, window_height);

	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();
	gluOrtho2D(p_left, p_right, bottom, top);

	glMatrixMode(GL_MODELVIEW);
	glLoadIdentity();

	glutPostRedisplay();
}

void iterate(){

	// Allocate memory for each vector on GPU
    cudaMalloc(&(game->d_game), game->bytes);
    cudaMalloc(&(game->d_width), sizeof(int));
    cudaMalloc(&(game->d_height), sizeof(int));
    cudaMemcpy( game->d_game, game->h_game, game->bytes, cudaMemcpyHostToDevice);
    cudaMemcpy( game->d_width, &game->width, sizeof(int), cudaMemcpyHostToDevice);
    cudaMemcpy( game->d_height, &game->height,sizeof(int), cudaMemcpyHostToDevice);
    clock_t begin = clock();
 	gol<<<game->gridSize, game->blockSize>>>(game->d_game, game->d_width, game->d_height);
 	clock_t end = clock();
 	double elapsed_secs = double(end - begin) / CLOCKS_PER_SEC;
 	fprintf(stderr, "%f\n", elapsed_secs);
    cudaMemcpy( game->h_game, game->d_game, game->bytes, cudaMemcpyDeviceToHost );
    cudaFree(game->d_game);
    cudaFree(game->d_width);
    cudaFree(game->d_height);


}

void update(int value){
	
	iterate();

	glutPostRedisplay();
	glutTimerFunc(1000 / FPS, update, 0);
}

int main( int argc, char* argv[] )
{

  	glutInit(&argc, argv);
	
	glutInitWindowSize(window_width, window_height);
	glutInitWindowPosition(0, 0);
	glutCreateWindow("Game of Life");
	glClearColor(1, 1, 1, 1);

	glutKeyboardFunc(closeprogram);
	glutDisplayFunc(display);
	glutReshapeFunc(reshape);

	game = new CUDAGoL(window_width, window_height);
	update(0);
	glutMainLoop();
    return 0;
}