#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <time.h>
#include <stdarg.h>
#include "Settings.h"
#include "CL.h"

#ifdef _WIN32 // Windows
#include <windows.h>
#endif

#if OPENCL == 1
#include "CL/cl.h"
//Holds a context for a specific OpenCL device,
//Contexts manage an OpenCL device eg. command queues, memory objects or kernels.
cl_context context;
//Properties for creating a device context
// Must be 0 terminated, specifies the platform, to use.
cl_context_properties properties[3];
//kernel from the program to execute
cl_kernel kernelFeedForward, kernelNeuronSynapses;
// Stores the command queue for a specific device
cl_command_queue command_queue;
// program object for a context, loaded source code
cl_program program;
//Used to return errors from OpenCl functions
cl_int err;
// Returned from clGetPlatformIDs, hold the number of platforms found
cl_uint num_of_platforms = 0;
// Returned from clGetPlatformIDs, holds the available platforms
cl_platform_id *platform_id;
// Returned from clGetDeviceIDs, holds the available devices
cl_device_id device_id;
// Returned from clGetDeviceIDs, holds the total number of devices available
cl_uint num_of_devices = 0;

//buffers for the input and output data
cl_mem input, output;
// Number of work items for the kernel
size_t global;

cl_mem cl_mem_neuronTpye, cl_mem_V, cl_mem_U, cl_mem_P, cl_mem_SynapseWeights, cl_mem_SynapseS;


#endif


// Neuron states
bool neuronType[NUMBER_OF_NEURONS];
float v[NUMBER_OF_NEURONS];
float u[NUMBER_OF_NEURONS];

//Inputs into the network
bool p[NEURONS_PER_LAYER]; //wether each synapse fires

// Interconnection between nurons in the network
float SynapseWeights[NUMBER_OF_NEURONS * NEURONS_PER_LAYER];
float SynapseS[NUMBER_OF_NEURONS];

// Results arrays
bool firings[NUMBER_OF_NEURONS * RUN_STEPS];
float vNeuron[RUN_STEPS];


float pRate = TIMESTEP_MS * FIRING_RATE_IN * 1e-3; // Chance for input to fire


void InitNetwork() {

	//Store plot data
	for (int x = 0; x < NUMBER_OF_NEURONS; x++) neuronType[x] = get_random() < PROBABILITY_INHIBITORY_NEURON;

	for (int x = 0; x < NUMBER_OF_NEURONS; x++) v[x] = -70; //resting potential
	for (int x = 0; x < NUMBER_OF_NEURONS; x++) u[x] = -14;//steady state

	// Setup weights
	for (int x = 0; x < NUMBER_OF_NEURONS * NEURONS_PER_LAYER; x++) {
		if (x < NEURONS_PER_LAYER) {
			// Input weights
			if (get_random() <= INPUT_SYNAPSE_PROBABILITY)
				SynapseWeights[x] = INPUT_SYNAPSE_WEIGHT;
			else
				SynapseWeights[x] = 0; // not connected
		} else {
			// Neuron connectivity weights
			if (get_random() <= INTER_NEURON_CONNECTION_PROBABILITY) {
				SynapseWeights[x] = SYNAPSE_WEIGHT;
				if (neuronType[(int)(x / NEURONS_PER_LAYER)] == INHIBITORY_NEURON)
					SynapseWeights[x] *= 2;
			}
			else
				SynapseWeights[x] = 0; // not connected
		}
	}

	for (int x = 0; x < NUMBER_OF_NEURONS; x++) SynapseS[x] = 0;
}

#if OPENCL == 1
void cleanUpCL() {

	if (cl_mem_neuronTpye)
		clReleaseMemObject(cl_mem_neuronTpye);
	if (cl_mem_V)
		clReleaseMemObject(cl_mem_V);
	if (cl_mem_U)
		clReleaseMemObject(cl_mem_U);
	if (cl_mem_P)
		clReleaseMemObject(cl_mem_P);
	if (cl_mem_SynapseWeights)
		clReleaseMemObject(cl_mem_SynapseWeights);
	if (cl_mem_SynapseS)
		clReleaseMemObject(cl_mem_SynapseS);
	if (kernelFeedForward)
		clReleaseKernel(kernelFeedForward);
	if (kernelNeuronSynapses)
		clReleaseKernel(kernelNeuronSynapses);

}
#endif

#if OPENCL == 1

void copyNetworkToDevice() {
	/*
	cl_mem_V, cl_mem_U, cl_mem_P, cl_mem_SynapseWeights, cl_mem_SynapseS

	*/
	cl_mem_neuronTpye = clCreateBuffer(context, CL_MEM_READ_WRITE, sizeof(bool) *  NUMBER_OF_NEURONS, NULL, &err);
	checkError(err, "Unable to create input buffer");
	cl_mem_V = clCreateBuffer(context, CL_MEM_READ_WRITE, sizeof(float) *  NUMBER_OF_NEURONS, NULL, &err);
	checkError(err, "Unable to create input buffer");
	cl_mem_U = clCreateBuffer(context, CL_MEM_READ_WRITE, sizeof(float) *  NUMBER_OF_NEURONS, NULL, &err);
	checkError(err, "Unable to create input buffer");
	cl_mem_P = clCreateBuffer(context, CL_MEM_READ_WRITE, sizeof(bool) *  NEURONS_PER_LAYER, NULL, &err);
	checkError(err, "Unable to create input buffer");
	cl_mem_SynapseWeights = clCreateBuffer(context, CL_MEM_READ_WRITE, sizeof(float) *  NUMBER_OF_NEURONS * NEURONS_PER_LAYER, NULL, &err);
	checkError(err, "Unable to create input buffer");
	cl_mem_SynapseS = clCreateBuffer(context, CL_MEM_READ_WRITE, sizeof(float) *  NUMBER_OF_NEURONS, NULL, &err);
	checkError(err, "Unable to create input buffer");

	err = clEnqueueWriteBuffer(command_queue, cl_mem_neuronTpye, CL_TRUE, 0, sizeof(bool) * NUMBER_OF_NEURONS, neuronType, 0, NULL, NULL);
	checkError(err, "Unable to enqueue write buffer.");
	err = clEnqueueWriteBuffer(command_queue, cl_mem_V, CL_TRUE, 0, sizeof(float) * NUMBER_OF_NEURONS, v, 0, NULL, NULL);
	checkError(err, "Unable to enqueue write buffer.");
	err = clEnqueueWriteBuffer(command_queue, cl_mem_U, CL_TRUE, 0, sizeof(float) * NUMBER_OF_NEURONS, u, 0, NULL, NULL);
	checkError(err, "Unable to enqueue write buffer.");
	err = clEnqueueWriteBuffer(command_queue, cl_mem_P, CL_TRUE, 0, sizeof(bool) * NEURONS_PER_LAYER, p, 0, NULL, NULL);
	checkError(err, "Unable to enqueue write buffer.");
	err = clEnqueueWriteBuffer(command_queue, cl_mem_SynapseWeights, CL_TRUE, 0, sizeof(float) * NUMBER_OF_NEURONS * NEURONS_PER_LAYER, SynapseWeights, 0, NULL, NULL);
	checkError(err, "Unable to enqueue write buffer.");
	err = clEnqueueWriteBuffer(command_queue, cl_mem_SynapseS, CL_TRUE, 0, sizeof(float) * NUMBER_OF_NEURONS, SynapseS, 0, NULL, NULL);
	checkError(err, "Unable to enqueue write buffer.");

	kernelFeedForward = clCreateKernel(program, "feedForward", &err);
	checkError(err, "Unable to create kernel.");
	kernelNeuronSynapses = clCreateKernel(program, "inputSynapses", &err);
	checkError(err, "Unable to create kernel.");

	clFinish(command_queue);

}

#endif


void feedForward() {
	
	// Update synapses (last layer corresponds to input synapses)
	for (int x = 0; x < NUMBER_OF_NEURONS; x++) {

		if (x < (NUMBER_OF_NEURONS-NEURONS_PER_LAYER) && v[x] >= 35.0f)
			SynapseS[x] = (((1.0f - (TIMESTEP_MS / TAU_S))*SynapseS[x]) + 1.0f);
		else if (x >= (NUMBER_OF_NEURONS-NEURONS_PER_LAYER) && p[x-(NUMBER_OF_NEURONS-NEURONS_PER_LAYER)] == 1)
			SynapseS[x] = (((1.0f - (TIMESTEP_MS / TAU_S))*SynapseS[x]) + 1.0f);
		else // only decay
			SynapseS[x] = ((1.0f - (TIMESTEP_MS / TAU_S))*SynapseS[x]);
	}

	for (int x = 0; x < NUMBER_OF_NEURONS; x++) {

		float sumInh = 0;
		float sumExh = 0;
		// Get the previous layer (neurons connected to a forward layer)
		int currentLayer = (int)(x/NEURONS_PER_LAYER);
		int lPre = (x < NEURONS_PER_LAYER ? (NUMBER_OF_NEURONS-NEURONS_PER_LAYER): ((currentLayer - 1) * NEURONS_PER_LAYER));
		for (int y = 0; y < NEURONS_PER_LAYER; y++) {
			if(x < NEURONS_PER_LAYER || neuronType[lPre + y] == EXCITATORY_NEURON)
				sumExh += SynapseWeights[x * NEURONS_PER_LAYER + y] * SynapseS[lPre + y];
			else
				sumInh += SynapseWeights[x * NEURONS_PER_LAYER + y] * SynapseS[lPre + y];
		}

		// Update v & u using Izikevich's equations
		float dv, du;
		float vt = v[x];
		float ut = u[x];
		float I = (sumExh * (ES_EXCITATORY - vt)) + (sumInh * (ES_INHIBITORY - vt));
		if (v[x] < 35) { //Not firing
			// First 0.5 ms
			dv = (((0.04f*vt) + 5.0f)*vt) + 140.0f - ut + I;
			vt = vt + (dv * TIMESTEP_MS);
			du = (IZHIKEVICH_A(neuronType[x])) * ((IZHIKEVICH_B * vt) - ut);
			ut = ut + (du * TIMESTEP_MS);
			// Second 0.5 ms
			dv = (((0.04f*vt) + 5.0f)*vt) + 140.0f - ut + I;
			vt = vt + (dv * TIMESTEP_MS);
			du = (IZHIKEVICH_A(neuronType[x])) * ((IZHIKEVICH_B * vt) - ut);
			ut = ut + (du * TIMESTEP_MS);
			// Store and saturate if previous step was over 35.0f
			v[x] =  vt > 35.0f? 35.0f : vt;
			u[x] = ut;
		}
		else { // firing
			v[x] = IZHIKEVICH_C;
			u[x] = ut + (IZHIKEVICH_D((neuronType[x])));
		}
	}
}

#if OPENCL == 1

void feedForwardCL() {

	clFinish(command_queue);

	//Assign new input values to the network
	err = clEnqueueWriteBuffer(command_queue, cl_mem_P, CL_TRUE, 0, sizeof(bool) * NEURONS_PER_LAYER, p, 0, NULL, NULL);
	checkError(err, "Unable to enqueue write buffer.");

	// set the argument list for the kernel command
	clSetKernelArg(kernelNeuronSynapses, 0, sizeof(cl_mem), &cl_mem_SynapseS);
	clSetKernelArg(kernelNeuronSynapses, 1, sizeof(cl_mem), &cl_mem_V);
	clSetKernelArg(kernelNeuronSynapses, 2, sizeof(cl_mem), &cl_mem_P);
	// Number of work items for the kernel
	global = NUMBER_OF_NEURONS;

	err = clEnqueueNDRangeKernel(command_queue, kernelNeuronSynapses, 1, NULL, &global, NULL, 0, NULL, NULL);
	checkError(err, "Unable to enqueue kernel.");
	clFinish(command_queue);
	
	
	// set the argument list for the kernel command
	clSetKernelArg(kernelFeedForward, 0, sizeof(cl_mem), &cl_mem_V);
	clSetKernelArg(kernelFeedForward, 1, sizeof(cl_mem), &cl_mem_SynapseWeights);
	clSetKernelArg(kernelFeedForward, 2, sizeof(cl_mem), &cl_mem_SynapseS);
	clSetKernelArg(kernelFeedForward, 3, sizeof(cl_mem), &cl_mem_U);
	clSetKernelArg(kernelFeedForward, 4, sizeof(cl_mem), &cl_mem_neuronTpye);
	// Number of work items for the kernel
	global = NUMBER_OF_NEURONS;

	err = clEnqueueNDRangeKernel(command_queue, kernelFeedForward, 1, NULL, &global, NULL, 0, NULL, NULL);
	checkError(err, "Unable to enqueue kernel.");

	//Copy results back to HOST
	err = clEnqueueReadBuffer(command_queue, cl_mem_V, CL_TRUE, 0, sizeof(float) * NUMBER_OF_NEURONS, v, 0, NULL, NULL);
	checkError(err, "Unable to create kernel.");

	clFinish(command_queue);

}
#endif

void GenerateInputs(int t) {
	//Set input between 200ms and 700ms
	// 200ms = 400 as timestep = 0.5
	//Possion distribution of firing inputs
	if (t > 100 && t < 1600) {
		for (int x = 0; x < INPUT_SYNAPSES; x++) {
			// Input Poisson spikes
			p[x] = get_random() < pRate;
		}
	} else {
		for (int x = 0; x < INPUT_SYNAPSES; x++)
			p[x] = 0;
	}
}

void SaveResults() {
#if OPENCL == 1
		FILE * file = fopen("AllNeuronsCL.csv", "w");
#else
		FILE * file = fopen("AllNeurons.csv", "w");
#endif

		if (file) {
			for (int t = 0; t < RUN_STEPS - 1; t++) {
				for (int x = 0; x < NUMBER_OF_NEURONS; x++) {
					if (firings[t * NUMBER_OF_NEURONS + x]) {
						if (neuronType[x] == INHIBITORY_NEURON)
							fprintf(file, "%d,,%d\n", t, x);
						else
							fprintf(file, "%d,%d,\n", t, x);
					}
				}
			}
		}
		fclose(file);
#if OPENCL == 1
		FILE * file2 = fopen("SingleNeuronCL.csv", "w");
#else
		FILE * file2 = fopen("SingleNeuron.csv", "w");
#endif

		if (file2) {
			for (int t = 0; t < RUN_STEPS - 1; t++) {
				fprintf(file2, "%d,%f\n", t, vNeuron[t]);
			}
		}
		fclose(file2);

}

#if OPENCL != 1
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

int main() {
	srand(1);
	//Create the spiking netowrk and init variables
	ConsoleOutput("Init Network...\n");
	InitNetwork();

	// copy the netowrk to the Device
#if OPENCL == 1
	OpenCLSetup();
	copyNetworkToDevice();
#endif

	ConsoleOutput("Starting simulation...\n");
	clock_t startTime = clock();

	// Simulate for a periof of time
	for (int t = 0; t < RUN_STEPS - 1; t++) {

		//Create a list of inputs into the network
		GenerateInputs(t);

		// Calculate the spikes in the network for this time step
#if OPENCL == 1
		feedForwardCL();
#else
		feedForward();
#endif
		//Collect results
		for (int x = 0; x < NUMBER_OF_NEURONS; x++) firings[t * NUMBER_OF_NEURONS + x] = (v[x] >= 35.0f);
		vNeuron[t] = v[NUMBER_OF_NEURONS/2];
	}

	clock_t runtime = clock() - startTime;
	float a = (float)runtime / (float)CLOCKS_PER_SEC;
	ConsoleOutput("\n\nExecution Time: %f\n\n", (float)runtime / (float)CLOCKS_PER_SEC);

	// Saves the neuron spikes to file
	SaveResults();

	//Free up memory allocated on the Device
#if OPENCL == 1
	cleanUpCL();
#endif

	return 1;
}
