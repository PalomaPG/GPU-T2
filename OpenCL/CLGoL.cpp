#include "CLGoL.hpp"

CLGoL::CLGoL(const int w, const int h): width(w), height(h), bytes(w*h*sizeof(int)){

	grid = new int[w*h];

    srand((unsigned)time(NULL));
    CLGoL::randomInit();
    cl::Program program_;

    try {
 
        // Query platforms
        std::vector<cl::Platform> platforms;
        cl::Platform::get(&platforms);
        if (platforms.size() == 0) {
            std::cout << "Platform size 0\n";
            exit(0);
         }
 
        cl_context_properties properties[] =
           { CL_CONTEXT_PLATFORM, (cl_context_properties)(platforms[0])(), 0};
        cl::Context context(CL_DEVICE_TYPE_GPU, properties);
        std::vector<cl::Device> devices = context.getInfo<CL_CONTEXT_DEVICES>();
 
        // Create command queue for first device
        queue=cl::CommandQueue(context, devices[0], 0, &err);

                // Create device memory buffers
        inputGrid = cl::Buffer(context, CL_MEM_READ_ONLY, bytes);
        d_width = cl::Buffer(context, CL_MEM_READ_ONLY, sizeof(int));
        d_height = cl::Buffer(context, CL_MEM_READ_ONLY, sizeof(int));

        outputGrid = cl::Buffer(context, CL_MEM_WRITE_ONLY, bytes);
		std::ifstream sourceFile("golTest.cl");
	// lire fichier source
		std::string sourceCode(
						std::istreambuf_iterator<char>(sourceFile), //start
						(std::istreambuf_iterator<char>()) //eof
		);
		const char *cstr = sourceCode.c_str();


       	//Build kernel from source string
        cl::Program::Sources source(1,
            std::make_pair(cstr,strlen(cstr)));
        program_ = cl::Program(context, source);

       	program_.build(devices);
        // Create kernel object
        kernel=cl::Kernel(program_, "gol", &err);

    } catch (cl::Error ferr) {

    		
         std::cerr
            << "ERROR: "<<ferr.what()<<"("<<ferr.err()<<")"<<std::endl;
            exit(0);
    }


}

void CLGoL::randomInit(const double probability) {      

	for(size_t i=0; i<width*height; i++){
		double r = (double)rand() / RAND_MAX;
		grid[i] = (r>probability);
	}
}

void CLGoL::readMemory(){

	queue.enqueueReadBuffer(outputGrid, CL_TRUE, 0, bytes, grid);
		
}

void CLGoL::writeMemory(){
	try{
		queue.enqueueWriteBuffer(inputGrid, CL_TRUE, 0, bytes, grid);
        queue.enqueueWriteBuffer(d_width, CL_TRUE, 0, sizeof(int), &width);
        queue.enqueueWriteBuffer(d_height, CL_TRUE, 0,sizeof(int), &height);

        kernel.setArg(0, inputGrid);
        kernel.setArg(1, outputGrid);

        kernel.setArg(2, d_width);
        kernel.setArg(3, d_height);
        
       	int n =  height*width;
        // Number of work items in each local work group
        cl::NDRange localSize(1024);
        // Number of total work items - localSize must be divisor
        cl::NDRange globalSize((int)(ceil(n/(float)1024)*1024));
        clock_t begin = clock();
        err = queue.enqueueNDRangeKernel(
            kernel,
            cl::NullRange,
            globalSize,
            localSize,
            NULL,
            &event);
        // Block until kernel completion
        clock_t end = clock();
        event.wait();
        
        double elapsed_secs = double(end - begin) / CLOCKS_PER_SEC;
        fprintf(stderr, "%f\n", elapsed_secs);
    }catch(cl::Error ferr){
    	         std::cerr
            << "ERROR: "<<ferr.what()<<"("<<ferr.err()<<")"<<std::endl;
            exit(0);
    }
}

void CLGoL::iterate(){
	CLGoL::writeMemory();
	CLGoL::readMemory();
}

int CLGoL::organismAt(const int col, const int row) {
	    return grid[row*width+col];
}

CLGoL::~CLGoL(){
	delete grid;
	queue.finish();
	queue.flush();
}

