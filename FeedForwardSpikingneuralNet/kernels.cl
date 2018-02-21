#ifdef altera
#include "FeedForwardSpikingneuralNet/Settings.h"
#else
#include "../FeedForwardSpikingneuralNet/Settings.h"
#endif 


__kernel void inputSynapses(
								__global float * restrict SynapseS, 
								__global float * restrict v,
								__global bool * restrict p
								)
{
	size_t id = get_global_id(0);		
	
	if (id < ((NUMBER_OF_NEURONS)-NEURONS_PER_LAYER) && v[id] >= 35.0f)
		SynapseS[id] = (((convert_float(1.0f) - (TIMESTEP_MS / TAU_S))*SynapseS[id]) + convert_float(1.0f));
	else if (id >= ((NUMBER_OF_NEURONS)-NEURONS_PER_LAYER) && p[id-((NUMBER_OF_NEURONS)-NEURONS_PER_LAYER)] == 1)
		SynapseS[id] = (((convert_float(1.0f) - (TIMESTEP_MS / TAU_S))*SynapseS[id]) + convert_float(1.0f));
	else // only decay
		SynapseS[id] = ((convert_float(1.0f) - (TIMESTEP_MS / TAU_S))*SynapseS[id]);
	SynapseS[id] = 1.0;
}


__kernel void feedForward(
							__global float * restrict v,
							__global float * restrict SynapseWeights,
							__global float * restrict SynapseS,
							__global float * restrict u,
							__global bool * restrict neuronType
							)
{
	size_t id = get_global_id(0);		
	//size_t globalSize = get_global_size (0);
	
	
	float sumExh = 0.0f;
	float sumInh = 0.0f;
	// Get the previous layer (neurons connected to a forward layer)
	int currentLayer = (int)(id/NEURONS_PER_LAYER);
	int lPre = (id < NEURONS_PER_LAYER ? ((NUMBER_OF_NEURONS)-NEURONS_PER_LAYER): ((currentLayer - 1) * NEURONS_PER_LAYER));
	for (int y = 0; y < NEURONS_PER_LAYER; y++) {
		if(id < NEURONS_PER_LAYER || neuronType[lPre + y] == EXCITATORY_NEURON)
			sumExh += SynapseWeights[id * NEURONS_PER_LAYER + y] * SynapseS[lPre + y];
		else
			sumInh += SynapseWeights[id * NEURONS_PER_LAYER + y] * SynapseS[lPre + y];
	}

	// Update v & u using Izikevich's equations
	float dv, du;
	float vt = v[id];
	float ut = u[id];
	float I = (sumExh * (ES_EXCITATORY - vt)) + (sumInh * (ES_INHIBITORY - vt));
	if (v[id] < 35) { //Not firing
		// First 0.5 ms
		dv = (((0.04f*vt) + 5.0f)*vt) + 140.0f - ut + I;
		vt = vt + (dv * TIMESTEP_MS);
		du = (IZHIKEVICH_A(neuronType[id])) * ((IZHIKEVICH_B * vt) - ut);
		ut = ut + (du * TIMESTEP_MS);
		// Second 0.5 ms
		dv = (((0.04f*vt) + 5.0f)*vt) + 140.0f - ut + I;
		vt = vt + (dv * TIMESTEP_MS);
		du = (IZHIKEVICH_A(neuronType[id])) * ((IZHIKEVICH_B * vt) - ut);
		ut = ut + (du * TIMESTEP_MS);
		// Store and saturate if previous step was over 35.0f
		v[id] =  vt > 35.0f? 35.0f : vt;
		u[id] = ut;
	}
	else { // firing
		v[id] = IZHIKEVICH_C;
		u[id] = ut + (IZHIKEVICH_D((neuronType[id])));
	}
}
