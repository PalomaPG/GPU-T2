#include <GL/gl.h>
#include <GL/glu.h>
#include <GL/glut.h>
#include <ctime>

#include "SeqGoL.hpp"

#include <iostream>

#define WHITE 1.0, 1.0, 1.0
#define BLACK 0.0, 0.0, 0.0

// values are read from "game.config"
GLint FPS = 24;
GLint window_width = 600;
GLint window_height = 600;
GLfloat left = 0.0;
GLfloat right = 1.0;
GLfloat bottom = 0.0;
GLfloat top = 1.0;
GLint game_width = 100;
GLint game_height = 100;

SeqGoL *game;

void closeprogram(unsigned char key, int x, int y){
	if(key==27)
		exit(0);
}

void display() {
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
	glLoadIdentity();
	
    GLfloat xSize = (right - left) / game_width;
	GLfloat ySize = (top - bottom) / game_height;
	
	glBegin(GL_QUADS);
	for (GLint x = 0; x < game_width; ++x) {
		for (GLint y = 0; y < game_height; ++y) {
            game->organismAt(x, y)?glColor3f(BLACK):glColor3f(WHITE);
            
			glVertex2f(    x*xSize+left,    y*ySize+bottom);
			glVertex2f((x+1)*xSize+left,    y*ySize+bottom);
			glVertex2f((x+1)*xSize+left,(y+1)*ySize+bottom);
			glVertex2f(    x*xSize+left,(y+1)*ySize+bottom);
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
	gluOrtho2D(left, right, bottom, top);

	glMatrixMode(GL_MODELVIEW);
	glLoadIdentity();

	glutPostRedisplay();
}

void update(int value) {

	clock_t begin = clock();
	game->iterate();
	clock_t end = clock();
	double elapsed_secs = double(end - begin) / CLOCKS_PER_SEC;
	fprintf(stderr, "%f\n", elapsed_secs);
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
	glutReshapeFunc(reshape);
	glutDisplayFunc(display);
	
	game = new SeqGoL(game_width, game_height);
	
		
	update(0);
	glutMainLoop();
		
  	return 0;
}
