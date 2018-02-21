#include "Settings.h"

#if OPENCL == 1

#include "CL.h"

#include <stdio.h>
#include <stdarg.h>
#include <stdlib.h>
#include <string>
#include "../common/inc/AOCL_Utils.h"

#ifdef _WIN32 // Windows
#include <windows.h>
#include <stdio.h>
#else         // Linux
#include <stdio.h> 
#include <unistd.h> // readlink, chdir
#endif


extern cl_context context;
extern cl_context_properties properties[3];
//extern cl_kernel kernel;
extern cl_command_queue command_queue;
extern cl_program program;
extern cl_int err;
extern cl_uint num_of_platforms;
extern cl_platform_id *platform_id;
extern cl_device_id device_id;
extern cl_uint num_of_devices;
extern cl_mem input, output;
extern size_t global;


bool OpenCLSetup() {
	int i;

#ifdef _WIN32 // Windows
	ConsoleOutput("Running on windows!\n");
#else         // Linux
	ConsoleOutput("Running on Linux!\n");
#endif

	ConsoleOutput("Initializing OpenCL\n");


	ConsoleOutput("Changing working directory...");
	//Change the current working directory to the execution directory
	// For finding kernel programs
	if (!setCwdToExeDir()) {
		ConsoleOutput("\nUnable to change working directory\n");
		return false;
	}
	ConsoleOutput("Done\n");

	//Get the number of available platforms
	ConsoleOutput("Getting number of platforms...");
	err = clGetPlatformIDs(0, NULL, &num_of_platforms);
	checkError(err, "Query for number of platforms failed");
	ConsoleOutput(" %d\n", num_of_platforms);

	// retrieves a list of platforms available
	// Only return one entry
	ConsoleOutput("Getting Platform IDs...");
	int tmp = num_of_platforms;
	platform_id = (cl_platform_id*)calloc((size_t)tmp, sizeof(cl_platform_id));
	err = clGetPlatformIDs(tmp, platform_id, &num_of_platforms);
	checkError(err, "Unable to get Platform IDs");
	ConsoleOutput("Done\n");

	//List the names of all the available platforms
	ConsoleOutput("Platforms:\n");
	for (i = 0; i < tmp; i++) {
		size_t sz;
		err = clGetPlatformInfo(platform_id[i], CL_PLATFORM_NAME, 0, NULL, &sz);
		checkError(err, "Query for platform name size failed");
		char * tmpStr = (char*)calloc(sz, sizeof(char));
		err = clGetPlatformInfo(platform_id[i], CL_PLATFORM_NAME, sz, tmpStr, NULL);
		checkError(err, "Query for platform name failed");
		ConsoleOutput("%d. %s\n", i + 1, tmpStr);
		if (!tmpStr)
			free(tmpStr);
	}
	ConsoleOutput("Using platform 1:\n");
	printPlatoformInformation(platform_id[0]);

	// try to get a supported GPU device
	// Get the number of devices
	ConsoleOutput("Getting number of devices...");
	err = clGetDeviceIDs(platform_id[0], CL_DEVICE_TYPE_ALL, 0, NULL, &num_of_devices);
	checkError(err, "Query for number of devices failed");
	ConsoleOutput("Done\n");
	// Get an array of all the devices
	ConsoleOutput("Getting Device IDs...");
	cl_device_id *dids = new cl_device_id[num_of_devices];
	err = clGetDeviceIDs(platform_id[0], CL_DEVICE_TYPE_ALL, num_of_devices, dids, NULL);
	checkError(err, "Query for device ids");
	ConsoleOutput("Done\n");
	ConsoleOutput("Devices:\n");
	//Print the devices to screen
	for (i = 0; i < (int)num_of_devices; i++) {
		size_t sz;
		err = clGetDeviceInfo(dids[i], CL_DEVICE_NAME, 0, NULL, &sz);
		checkError(err, "Query for device name size failed");
		char * tmpStr = (char*)calloc(sz, sizeof(char));
		err = clGetDeviceInfo(dids[i], CL_DEVICE_NAME, sz, tmpStr, NULL);
		checkError(err, "Query for device name failed");
		ConsoleOutput("%d. %s\n", i + 1, tmpStr);
		if (!tmpStr)
			free(tmpStr);
	}
	ConsoleOutput("Using Device 1:\n");
	display_device_info(dids[0]);

	// context properties list - must be terminated with 0
	// Specifies the platform to create a device context from
	properties[0] = CL_CONTEXT_PLATFORM;
	properties[1] = (cl_context_properties)platform_id[0];
	properties[2] = 0;
	ConsoleOutput("\nCreating device context...");
	// create a context with the device
	context = clCreateContext(properties, 1, dids, NULL, NULL, &err);
	checkError(err, "Unable to create device context");
	ConsoleOutput("Done\n");

	// create command queue using the context and device
	// No properties specified, defaults In-order execution and no profiling
	command_queue = clCreateCommandQueue(context, dids[0], 0, &err);
	checkError(err, "Unable to create device command queue. ");



#ifdef _WIN32 // Windows
	// Load the openCL source file
	char* cSourceCL = NULL;
	size_t szKernelLength;
	cSourceCL = oclLoadProgSource("kernels.cl", "", &szKernelLength);
	if (cSourceCL == NULL) {
		ConsoleOutput("Failed to load kernel source file.\n");
		return 1;
	}
	//Create program from source file
	program = clCreateProgramWithSource(context, 1, (const char **)&cSourceCL, &szKernelLength, &err);
	checkError(err, "Unable to create program with source. ");


#else         // Linux

	// create a program from the kernel source code
	// Creates a program object for a context, and loads the source code 
	std::string binary_file = aocl_utils::getBoardBinaryFile("kernels", dids[0]);
	ConsoleOutput("Using AOCX: %s\n", binary_file.c_str());
	program = aocl_utils::createProgramFromBinary(context, binary_file.c_str(), dids, num_of_devices);

#endif

	// compile the program, check for build error
	if (clBuildProgram(program, 0, NULL, NULL, NULL, NULL) != CL_SUCCESS)
	{
		//Error building the program, display the build error
		ConsoleOutput("Error building program\n");
		char buffer[4096];
		size_t length = 0;
		clGetProgramBuildInfo(
			program, // valid program object
			device_id, // valid device_id that executable was built
			CL_PROGRAM_BUILD_LOG, // indicate to retrieve build log
			sizeof(buffer), // size of the buffer to write log to
			buffer, // the actual buffer to write log to
			&length // the actual size in bytes of data copied to buffer
			);
		ConsoleOutput("Log: %s\n", buffer);
		exit(1);
	}

	//// specify which kernel from the program to execute
	//// Kernel name is kernel / function name
	//kernel = clCreateKernel(program, "nuronPulse", &err);
	//checkError(err, "Unable to create kernel.");
	return true;
}


// Free the resources allocated during initialization
void cleanup() {
	if (input)
		clReleaseMemObject(input);
	if (output)
		clReleaseMemObject(output);
	//if (kernel)
	//	clReleaseKernel(kernel);
	if (command_queue)
		clReleaseCommandQueue(command_queue);
	if (program)
		clReleaseProgram(program);
	if (context)
		clReleaseContext(context);
	if (platform_id)
		free(platform_id);
#ifdef _WIN32
	//Pause on exit
	getchar();
#endif
}

// Helper functions to display parameters returned by OpenCL queries
void device_info_ulong(cl_device_id device, cl_device_info param, const char* name) {
	cl_ulong a;
	clGetDeviceInfo(device, param, sizeof(cl_ulong), &a, NULL);
	ConsoleOutput("%-40s = %lu\n", name, a);
}
void device_info_uint(cl_device_id device, cl_device_info param, const char* name) {
	cl_uint a;
	clGetDeviceInfo(device, param, sizeof(cl_uint), &a, NULL);
	ConsoleOutput("%-40s = %u\n", name, a);
}
void device_info_bool(cl_device_id device, cl_device_info param, const char* name) {
	cl_bool a;
	clGetDeviceInfo(device, param, sizeof(cl_bool), &a, NULL);
	ConsoleOutput("%-40s = %s\n", name, (a ? "true" : "false"));
}
void device_info_string(cl_device_id device, cl_device_info param, const char* name) {
	char a[STRING_BUFFER_LEN];
	clGetDeviceInfo(device, param, STRING_BUFFER_LEN, &a, NULL);
	ConsoleOutput("%-40s = %s\n", name, a);
}

void display_device_info(cl_device_id device) {
	device_info_string(device, CL_DEVICE_NAME, "CL_DEVICE_NAME");
	device_info_string(device, CL_DEVICE_VENDOR, "CL_DEVICE_VENDOR");
	device_info_uint(device, CL_DEVICE_VENDOR_ID, "CL_DEVICE_VENDOR_ID");
	device_info_string(device, CL_DEVICE_VERSION, "CL_DEVICE_VERSION");
	device_info_string(device, CL_DRIVER_VERSION, "CL_DRIVER_VERSION");
	device_info_uint(device, CL_DEVICE_ADDRESS_BITS, "CL_DEVICE_ADDRESS_BITS");
	/*device_info_bool(device, CL_DEVICE_AVAILABLE, "CL_DEVICE_AVAILABLE");
	device_info_bool(device, CL_DEVICE_ENDIAN_LITTLE, "CL_DEVICE_ENDIAN_LITTLE");
	device_info_ulong(device, CL_DEVICE_GLOBAL_MEM_CACHE_SIZE, "CL_DEVICE_GLOBAL_MEM_CACHE_SIZE");
	device_info_ulong(device, CL_DEVICE_GLOBAL_MEM_CACHELINE_SIZE, "CL_DEVICE_GLOBAL_MEM_CACHELINE_SIZE");
	device_info_ulong(device, CL_DEVICE_GLOBAL_MEM_SIZE, "CL_DEVICE_GLOBAL_MEM_SIZE");
	device_info_bool(device, CL_DEVICE_IMAGE_SUPPORT, "CL_DEVICE_IMAGE_SUPPORT");
	device_info_ulong(device, CL_DEVICE_LOCAL_MEM_SIZE, "CL_DEVICE_LOCAL_MEM_SIZE");
	device_info_ulong(device, CL_DEVICE_MAX_CLOCK_FREQUENCY, "CL_DEVICE_MAX_CLOCK_FREQUENCY");
	device_info_ulong(device, CL_DEVICE_MAX_COMPUTE_UNITS, "CL_DEVICE_MAX_COMPUTE_UNITS");
	device_info_ulong(device, CL_DEVICE_MAX_CONSTANT_ARGS, "CL_DEVICE_MAX_CONSTANT_ARGS");
	device_info_ulong(device, CL_DEVICE_MAX_CONSTANT_BUFFER_SIZE, "CL_DEVICE_MAX_CONSTANT_BUFFER_SIZE");
	device_info_uint(device, CL_DEVICE_MAX_WORK_ITEM_DIMENSIONS, "CL_DEVICE_MAX_WORK_ITEM_DIMENSIONS");
	device_info_uint(device, CL_DEVICE_MAX_WORK_GROUP_SIZE, "CL_DEVICE_MAX_WORK_GROUP_SIZE");
	device_info_uint(device, CL_DEVICE_MEM_BASE_ADDR_ALIGN, "CL_DEVICE_MAX_WORK_ITEM_DIMENSIONS");
	device_info_uint(device, CL_DEVICE_MIN_DATA_TYPE_ALIGN_SIZE, "CL_DEVICE_MIN_DATA_TYPE_ALIGN_SIZE");
	device_info_uint(device, CL_DEVICE_PREFERRED_VECTOR_WIDTH_CHAR, "CL_DEVICE_PREFERRED_VECTOR_WIDTH_CHAR");
	device_info_uint(device, CL_DEVICE_PREFERRED_VECTOR_WIDTH_SHORT, "CL_DEVICE_PREFERRED_VECTOR_WIDTH_SHORT");
	device_info_uint(device, CL_DEVICE_PREFERRED_VECTOR_WIDTH_INT, "CL_DEVICE_PREFERRED_VECTOR_WIDTH_INT");
	device_info_uint(device, CL_DEVICE_PREFERRED_VECTOR_WIDTH_LONG, "CL_DEVICE_PREFERRED_VECTOR_WIDTH_LONG");
	device_info_uint(device, CL_DEVICE_PREFERRED_VECTOR_WIDTH_FLOAT, "CL_DEVICE_PREFERRED_VECTOR_WIDTH_FLOAT");
	device_info_uint(device, CL_DEVICE_PREFERRED_VECTOR_WIDTH_DOUBLE, "CL_DEVICE_PREFERRED_VECTOR_WIDTH_DOUBLE");*/

	{
		cl_command_queue_properties ccp;
		clGetDeviceInfo(device, CL_DEVICE_QUEUE_PROPERTIES, sizeof(cl_command_queue_properties), &ccp, NULL);
		ConsoleOutput("%-40s = %s\n", "Command queue out of order? ", ((ccp & CL_QUEUE_OUT_OF_ORDER_EXEC_MODE_ENABLE) ? "true" : "false"));
		ConsoleOutput("%-40s = %s\n", "Command queue profiling enabled? ", ((ccp & CL_QUEUE_PROFILING_ENABLE) ? "true" : "false"));
	}
}

void printPlatoformInformation(cl_platform_id platform) {
	size_t sz;
	char * tmpStr;
	err = clGetPlatformInfo(platform, CL_PLATFORM_NAME, 0, NULL, &sz);
	checkError(err, "Query for platform Profile size failed");
	tmpStr = (char*)calloc(sz, sizeof(char));
	err = clGetPlatformInfo(platform, CL_PLATFORM_NAME, sz, tmpStr, NULL);
	checkError(err, "Query for platform Profile failed");
	ConsoleOutput("  Platform Profile:\t\t%s\n", tmpStr);
	if (!tmpStr)
		free(tmpStr);

	err = clGetPlatformInfo(platform, CL_PLATFORM_VERSION, 0, NULL, &sz);
	checkError(err, "Query for platform Version size failed");
	tmpStr = (char*)calloc(sz, sizeof(char));
	err = clGetPlatformInfo(platform, CL_PLATFORM_VERSION, sz, tmpStr, NULL);
	checkError(err, "Query for platform Version failed");
	ConsoleOutput("  Platform Version:\t\t%s\n", tmpStr);
	if (!tmpStr)
		free(tmpStr);

	err = clGetPlatformInfo(platform, CL_PLATFORM_NAME, 0, NULL, &sz);
	checkError(err, "Query for platform name size failed");
	tmpStr = (char*)calloc(sz, sizeof(char));
	err = clGetPlatformInfo(platform, CL_PLATFORM_NAME, sz, tmpStr, NULL);
	checkError(err, "Query for platform name failed");
	ConsoleOutput("  Platform Name:\t\t%s\n", tmpStr);
	if (!tmpStr)
		free(tmpStr);

	err = clGetPlatformInfo(platform, CL_PLATFORM_VENDOR, 0, NULL, &sz);
	checkError(err, "Query for platform Vender size failed");
	tmpStr = (char*)calloc(sz, sizeof(char));
	err = clGetPlatformInfo(platform, CL_PLATFORM_VENDOR, sz, tmpStr, NULL);
	checkError(err, "Query for platform Vender failed");
	ConsoleOutput("  Platform Vender:\t\t%s\n", tmpStr);
	if (!tmpStr)
		free(tmpStr);

	err = clGetPlatformInfo(platform, CL_PLATFORM_EXTENSIONS, 0, NULL, &sz);
	checkError(err, "Query for platform Extensions size failed");
	tmpStr = (char*)calloc(sz, sizeof(char));
	err = clGetPlatformInfo(platform, CL_PLATFORM_EXTENSIONS, sz, tmpStr, NULL);
	checkError(err, "Query for platform Extensions failed");
	ConsoleOutput("  Platform Extensions:\t\t%s\n", tmpStr);
	if (!tmpStr)
		free(tmpStr);
}

// Sets the current working directory to be the same as the directory
// containing the running executable.
bool setCwdToExeDir() {
#ifdef _WIN32 // Windows
	HMODULE hMod = GetModuleHandle(NULL);
	char path[MAX_PATH];
	GetModuleFileNameA(hMod, path, MAX_PATH);

#else         // Linux
	// Get path of executable.
	char path[256];
	if (readlink("/proc/self/exe", path, sizeof(path) / sizeof(path[0])) < 0) {
		return false;
	}
#endif

	// Find the last '\' or '/' and terminate the path there; it is now
	// the directory containing the executable.
	size_t i;
	for (i = strlen(path) - 1; i > 0 && path[i] != '/' && path[i] != '\\'; --i);
	path[i] = '\0';

	// Change the current directory.
#ifdef _WIN32 // Windows
	SetCurrentDirectoryA(path);
#else         // Linux
	chdir(path);
#endif

	ConsoleOutput("\nPath = %s", path);
	return true;
}

char* oclLoadProgSource(const char* cFilename, const char* cPreamble, size_t* szFinalLength)
{
	// locals 
	FILE* pFileStream = NULL;
	size_t szSourceLength;

	// open the OpenCL source code file
	#ifdef _WIN32   // Windows version
	pFileStream = fopen(cFilename, "rb");
	if (pFileStream == 0)
	{
		return NULL;
	}
#else           // Linux version
	pFileStream = fopen(cFilename, "rb");
	if (pFileStream == 0)
	{
		return NULL;
	}
#endif

	size_t szPreambleLength = strlen(cPreamble);

	// get the length of the source code
	fseek(pFileStream, 0, SEEK_END);
	szSourceLength = ftell(pFileStream);
	fseek(pFileStream, 0, SEEK_SET);

	// allocate a buffer for the source code string and read it in
	char* cSourceString = (char *)malloc(szSourceLength + szPreambleLength + 1);
	memcpy(cSourceString, cPreamble, szPreambleLength);
	if (fread((cSourceString)+szPreambleLength, szSourceLength, 1, pFileStream) != 1)
	{
		fclose(pFileStream);
		free(cSourceString);
		return 0;
	}

	// close the file and return the total length of the combined (preamble + source) string
	fclose(pFileStream);
	if (szFinalLength != 0)
	{
		*szFinalLength = szSourceLength + szPreambleLength;
	}
	cSourceString[szSourceLength + szPreambleLength] = '\0';
	return cSourceString;
}

// Print line, file name, and error code if there is an error. Exits the
// application upon error.
void _checkError(int line, const char *file, cl_int error, const char *msg, ...) {
	// If not successful
	if (error != CL_SUCCESS) {
		// Print line and file
		ConsoleOutput("ERROR: ");
		printError(error);
		ConsoleOutput("\nLocation: %s:%d\n", file, line);

		// Print custom message.
		va_list vl;
		va_start(vl, msg);
		//vConsoleOutput(msg, vl);
		ConsoleOutput("\n");
		va_end(vl);

		// Cleanup and bail.
		cleanup();
		exit(error);
	}
}

// Print the error associated with an error code
void printError(cl_int error) {
	// Print error message
	switch (error)
	{
	case -1:
		ConsoleOutput("CL_DEVICE_NOT_FOUND ");
		break;
	case -2:
		ConsoleOutput("CL_DEVICE_NOT_AVAILABLE ");
		break;
	case -3:
		ConsoleOutput("CL_COMPILER_NOT_AVAILABLE ");
		break;
	case -4:
		ConsoleOutput("CL_MEM_OBJECT_ALLOCATION_FAILURE ");
		break;
	case -5:
		ConsoleOutput("CL_OUT_OF_RESOURCES ");
		break;
	case -6:
		ConsoleOutput("CL_OUT_OF_HOST_MEMORY ");
		break;
	case -7:
		ConsoleOutput("CL_PROFILING_INFO_NOT_AVAILABLE ");
		break;
	case -8:
		ConsoleOutput("CL_MEM_COPY_OVERLAP ");
		break;
	case -9:
		ConsoleOutput("CL_IMAGE_FORMAT_MISMATCH ");
		break;
	case -10:
		ConsoleOutput("CL_IMAGE_FORMAT_NOT_SUPPORTED ");
		break;
	case -11:
		ConsoleOutput("CL_BUILD_PROGRAM_FAILURE ");
		break;
	case -12:
		ConsoleOutput("CL_MAP_FAILURE ");
		break;
	case -13:
		ConsoleOutput("CL_MISALIGNED_SUB_BUFFER_OFFSET ");
		break;
	case -14:
		ConsoleOutput("CL_EXEC_STATUS_ERROR_FOR_EVENTS_IN_WAIT_LIST ");
		break;

	case -30:
		ConsoleOutput("CL_INVALID_VALUE ");
		break;
	case -31:
		ConsoleOutput("CL_INVALID_DEVICE_TYPE ");
		break;
	case -32:
		ConsoleOutput("CL_INVALID_PLATFORM ");
		break;
	case -33:
		ConsoleOutput("CL_INVALID_DEVICE ");
		break;
	case -34:
		ConsoleOutput("CL_INVALID_CONTEXT ");
		break;
	case -35:
		ConsoleOutput("CL_INVALID_QUEUE_PROPERTIES ");
		break;
	case -36:
		ConsoleOutput("CL_INVALID_COMMAND_QUEUE ");
		break;
	case -37:
		ConsoleOutput("CL_INVALID_HOST_PTR ");
		break;
	case -38:
		ConsoleOutput("CL_INVALID_MEM_OBJECT ");
		break;
	case -39:
		ConsoleOutput("CL_INVALID_IMAGE_FORMAT_DESCRIPTOR ");
		break;
	case -40:
		ConsoleOutput("CL_INVALID_IMAGE_SIZE ");
		break;
	case -41:
		ConsoleOutput("CL_INVALID_SAMPLER ");
		break;
	case -42:
		ConsoleOutput("CL_INVALID_BINARY ");
		break;
	case -43:
		ConsoleOutput("CL_INVALID_BUILD_OPTIONS ");
		break;
	case -44:
		ConsoleOutput("CL_INVALID_PROGRAM ");
		break;
	case -45:
		ConsoleOutput("CL_INVALID_PROGRAM_EXECUTABLE ");
		break;
	case -46:
		ConsoleOutput("CL_INVALID_KERNEL_NAME ");
		break;
	case -47:
		ConsoleOutput("CL_INVALID_KERNEL_DEFINITION ");
		break;
	case -48:
		ConsoleOutput("CL_INVALID_KERNEL ");
		break;
	case -49:
		ConsoleOutput("CL_INVALID_ARG_INDEX ");
		break;
	case -50:
		ConsoleOutput("CL_INVALID_ARG_VALUE ");
		break;
	case -51:
		ConsoleOutput("CL_INVALID_ARG_SIZE ");
		break;
	case -52:
		ConsoleOutput("CL_INVALID_KERNEL_ARGS ");
		break;
	case -53:
		ConsoleOutput("CL_INVALID_WORK_DIMENSION ");
		break;
	case -54:
		ConsoleOutput("CL_INVALID_WORK_GROUP_SIZE ");
		break;
	case -55:
		ConsoleOutput("CL_INVALID_WORK_ITEM_SIZE ");
		break;
	case -56:
		ConsoleOutput("CL_INVALID_GLOBAL_OFFSET ");
		break;
	case -57:
		ConsoleOutput("CL_INVALID_EVENT_WAIT_LIST ");
		break;
	case -58:
		ConsoleOutput("CL_INVALID_EVENT ");
		break;
	case -59:
		ConsoleOutput("CL_INVALID_OPERATION ");
		break;
	case -60:
		ConsoleOutput("CL_INVALID_GL_OBJECT ");
		break;
	case -61:
		ConsoleOutput("CL_INVALID_BUFFER_SIZE ");
		break;
	case -62:
		ConsoleOutput("CL_INVALID_MIP_LEVEL ");
		break;
	case -63:
		ConsoleOutput("CL_INVALID_GLOBAL_WORK_SIZE ");
		break;
	default:
		ConsoleOutput("UNRECOGNIZED ERROR CODE (%d)", error);
	}
}

void ConsoleOutput(const char* szFormat, ...)
{

#ifdef _WIN32
	char szBuff[1024];
	va_list arg;
	va_start(arg, szFormat);
	_vsnprintf(szBuff, sizeof(szBuff), szFormat, arg);
	va_end(arg);

	OutputDebugString(szBuff);
	printf(szBuff);
#else
	va_list arg;
	va_start(arg, szFormat);
	vfprintf(stdout, szFormat, arg);
	va_end(arg);
#endif
}

#endif
