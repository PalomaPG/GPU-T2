int countBottomLeft(
					__global const int *grid,
					__global const int *width, 
					__global const int *height
					)
{

	int sum = 0;
	sum +=grid[1];
	sum +=grid[(*width)]; //y=0
	sum +=grid[(*width)+1];

	sum +=grid[(*width)-1];
	sum +=grid[2*(*width)-1];

	sum +=grid[((*height)-1)*(*width)];
	sum +=grid[((*height)-1)*(*width)+1];

	sum +=grid[(*height)*(*width)-1];

	return sum;
}

int countBottomRight(
					__global const int *grid,
					__global const int *width,
					__global const int *height
					)
{

	int sum = 0;
	sum +=grid[(*width)-2];
	sum +=grid[(*width)*2-1]; //y=0
	sum +=grid[(*width)*2 -2];

	sum +=grid[0];
	sum +=grid[(*width)];

	sum +=grid[((*height)*(*width))-1];
	sum +=grid[((*height)*(*width))-2];

	sum += grid[((*height)-1)*(*width)];

	return sum;	
}

int countTopLeft(
					__global const int *grid,
					__global const int *width, 
					__global const int *height
				)
{

	int sum = 0;
	sum += grid[(*width)*((*height)-1)+1];
	sum += grid[(*width)*((*height)-2)]; //y=0
	sum += grid[(*width)*((*height)-2)+1];

	sum += grid[((*width)*(*height))-1];
	sum += grid[((*width)*((*height)-1))-1];

	sum += grid[0];
	sum += grid[1];

	sum += grid[(*width)-1];
	return sum;	

}

int countTopRight(
					__global const int *grid,
					__global const int *width, 
					__global const int *height
				)
{

	int sum = 0;
	sum += grid[(*width)-2];
	sum += grid[2*(*width)-1];
	sum += grid[2*(*width)-2];

	sum += grid[(*width)*(*height)-1];
	sum += grid[(*width)*((*height)-1)-1];

	sum += grid[(*width)-1];
	sum += grid[(*width)-2];

	sum += grid[0];

	return sum;	
}

int countLeftEdge(
					__global const int *grid,
					__global const int *width, 
					__global const int *height,
					int y
				)
{

	int sum = 0;
	sum += grid[(y+1)*(*width)];
	sum += grid[(y+1)*(*width)+1];
	sum += grid[y*(*width)+1];
	sum += grid[(y-1)*(*width)];
	sum += grid[(y-1)*(*width)+1];

	sum += grid[(y+2)*(*width)-1];
	sum += grid[(y+1)*(*width)-1];
	sum += grid[y*(*width)-1];

	return sum;	

}

int countRightEdge(
					__global const int *grid,
					__global const int *width, 
					__global const int *height,
					int y
				)
{
	int sum = 0;
	sum += grid[(y+2)*(*width)-1];
	sum += grid[(y+2)*(*width)-2];
	sum += grid[(y+1)*(*width)-2];
	sum += grid[y*(*width)-2];
	sum += grid[y*(*width)-1];

	sum += grid[(y+1)*(*width)];
	sum += grid[y*(*width)];
	sum += grid[(y-1)*(*width)];

	return sum;	

}

int countBottomEdge(
					__global const int *grid,
					__global const int *width, 
					__global const int *height,
					int x
				)
{
	int sum = 0;
	sum += grid[x-1];
	sum += grid[x+1];
	sum += grid[((*width)-1)+x-1];
	sum += grid[((*width)-1)+x];
	sum += grid[((*width)-1)+x+1];

	sum +=grid[((*height) -1)*(*width) + x -1];
	sum +=grid[((*height) -1)*(*width) + x];
	sum +=grid[((*height) -1)*(*width) + x + 1];
	return sum;
}

int countMiddle(
					__global const int *grid,
					__global const int *width, 
					__global const int *height,
					int x,
					int y
				)
{

	int sum=0;
	int pos = y*(*width)+x;
	sum +=grid[pos+1];
	sum +=grid[pos-1];
	pos = (y-1)*(*width)+x;
	sum +=grid[pos];
	sum +=grid[pos-1];
	sum +=grid[pos+1];
	pos = (y+1)*(*width)+x;
	sum +=grid[pos];
	sum +=grid[pos-1];
	sum +=grid[pos+1];

	return sum;

}

int countTopEdge(
					__global const int *grid,
					__global const int *width, 
					__global const int *height,
					int x
				)
{
	int sum = 0;
	sum += grid[(((*height)-1)*(*width)-1)+x-1];
	sum += grid[(((*height)-1)*(*width)-1)+x+1];
	sum += grid[(((*height)-2)*(*width)-1)+x-1];
	sum += grid[(((*height)-2)*(*width)-1)+x];
	sum += grid[(((*height)-2)*(*width)-1)+x+1];

	sum +=grid[x-1];
	sum +=grid[x];
	sum +=grid[x+1];
	return sum;
}

int countNeighbors(
					__global const int *grid, 
					__global const int *width, 
					__global const int *height, 
					int id
					)
{
	if(id==0){
		return countBottomLeft(grid, width, height);
	}
	else if(id==((*width)-1)){
		return countBottomRight(grid, width, height);
	}

	else if(id==((*width)*(*height-1))){
		return countTopLeft(grid, width, height);
	}

	else if(id == ((*width)*(*height)-1)){
		return countTopRight(grid, width, height);
	}
	else {

		int row = id/(*width);
		int col = id % (*width);

		if( col == 0)
			return countLeftEdge(grid, width, height, row);
		
		else if( col == ((*width)-1) )
			return countRightEdge(grid, width, height, row);
		
		else if(row == 0)
			return countBottomEdge(grid, width, height, col);

		else if(row == ((*height)-1))
			return countTopEdge(grid, width, height, col);

		else return countMiddle(grid, width, height, col, row);
	}

}

int execRules(
				__global const int *grid,
				__global const int *width,
				__global const int *height,
				int id
			)
{
	int sum = countNeighbors(grid, width, height, id);

	if(grid[id]==0) return (sum ==3 || sum == 6)? 1 : 0;
	else return (sum == 2 || sum == 3)? 1 : 0;

}
__kernel void gol(__global const int *grid,
				 __global int *tmpGrid,
				 __global const int *width,
				  __global const int *height)
{

	int id = get_global_id(0);
	tmpGrid[id]  = execRules(grid, width, height, id);

}