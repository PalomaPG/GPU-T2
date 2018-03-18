UNAME = $(shell uname)
CC = nvcc
SRC = main.cu CUDAGoL.cpp
EXEC = game
LDFLAGS	= -lGL -lglut -lGLEW -lGLU -lOpenCL

all: compile run clean

compile: 
	$(CC) $(LDFLAGS) $(SRC) -o $(EXEC)

clean:
	rm -rf $(EXEC) *~

run:
	./$(EXEC)