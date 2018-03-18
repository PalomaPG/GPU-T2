#include <GL/gl.h>
#include <GL/glu.h>
#include <GL/glut.h>

#include "CLGoL.hpp"

#define WHITE 1.0, 1.0, 1.0
#define BLACK 0.0, 0.0, 0.0


GLint FPS = 24;
GLint window_width = 600;
GLint window_height = 600;
GLfloat p_left = 0.0;
GLfloat p_right = 1.0;
GLfloat bottom = 0.0;
GLfloat top = 1.0;
GLint game_width = 400;
GLint game_height = 400;

CLGoL *game;

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

void update(int value) {

	game->iterate();

	glutPostRedisplay();
	glutTimerFunc(1000 / FPS, update, 0);
}

int main(int argc, char **argv) {
  	glutInit(&argc, argv);
	
	glutInitWindowSize(window_width, window_height);
	glutInitWindowPosition(0, 0);
	glutCreateWindow("Game of Life");
	glClearColor(1, 1, 1, 1);

	glutKeyboardFunc(closeprogram);
	glutDisplayFunc(display);
	glutReshapeFunc(reshape);
	

	game = new CLGoL(game_width, game_height);
	update(0);
	glutMainLoop();
	return 0;
  }