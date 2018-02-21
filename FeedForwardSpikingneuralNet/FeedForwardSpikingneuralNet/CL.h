#pragma once
#include "Settings.h"

#if OPENCL == 1

#include "CL/cl.h"

#define checkError(status, ...) _checkError(__LINE__, __FILE__, status, __VA_ARGS__)
#define STRING_BUFFER_LEN 1024


	bool OpenCLSetup();


	static void device_info_ulong(cl_device_id device, cl_device_info param, const char* name);
	static void device_info_uint(cl_device_id device, cl_device_info param, const char* name);
	static void device_info_bool(cl_device_id device, cl_device_info param, const char* name);
	static void device_info_string(cl_device_id device, cl_device_info param, const char* name);
	static void display_device_info(cl_device_id device);
	void printPlatoformInformation(cl_platform_id platform);
	char* oclLoadProgSource(const char* cFilename, const char* cPreamble, size_t* szFinalLength);
	void printError(cl_int error);
	bool setCwdToExeDir();
	void _checkError(int line, const char *file, cl_int error, const char *msg, ...);
	void cleanup();
	void ConsoleOutput(const char* szFormat, ...);

#endif
