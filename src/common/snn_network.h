#ifndef _SNN_NETWORK_H_
#define _SNN_NETWORK_H_

#include "../snn_config.h"

/*
Izhikevich model:
v - membrane potential
u - membrane recovery variable - provides negative feedback to v
I - Synaptic currents - Injected DC currects
a - 0.02 - time scape of recovery variable
b - 0.2 - sensitivity of recovery variable to subthreshold fluctuations of v
c - -65mv - after spike reset value
d - 2.0 - after spike reset of recovery variable

v' = 0.04v^2 + 5v + 140 - u + I    (1)
u' = a(bv - u)  (2)
with the auxiliary after-spike resetting
if v >= 30 mV; then v = c  and u = u + d: (3)

Synaptic Input model
I = sum ( w * s * ( E - v ) )
I - Synaptic currents - Injected DC currects
v - membrane potential
w - synapse connection weight
E - reversal potential - 0 mV for excitatory and -85 mV for inhibitory synapses
s - implements the dynamics of the nth synapse

s' = -s/t
s = s + h, if pre-synaptic neuron spikes

h = 1 - ( 1 + (U - 1) * h ) e ^ - dt * t
U - 0.5
dt - interval between current and previous spike
t - 500ms
*/
// Model time step
#define TIMESTEP_MS 					0.5f
#define SIM_TIMESTEP_MS					(2 * TIMESTEP_MS)

//Neural network dimensions
#define NUMBER_OF_LAYERS 				SIZE_LAYERS
#define NEURONS_PER_LAYER 				SIZE_NEURONS_PER_LAYER
#define NUMBER_OF_NEURONS 				(NUMBER_OF_LAYERS * NEURONS_PER_LAYER)
#define NUMBER_OF_SYNAPSES				(NUMBER_OF_NEURONS * NEURONS_PER_LAYER)

// Probability that the neuron is a inhibitory neuron
#define PROBABILITY_INHIBITORY_NEURON 	0.1f //0.1

//Neuron types excitatory and inhibitory
#define EXCITATORY_NEURON 				0
#define INHIBITORY_NEURON 				1

// Izhikevich model Parameters
#define IZHIKEVICH_A(neuronType) 		(neuronType) == INHIBITORY_NEURON ? 0.1f : 0.02f // 0.1 inhibitory, 0.02 excitatory
#define IZHIKEVICH_B 					0.2f
#define IZHIKEVICH_C 					-65
#define IZHIKEVICH_D(neuronType) 		(neuronType) == INHIBITORY_NEURON ? 2 : 8 // 2 inhibitory, 8 excitatory

//Decay of synapses ms
#define TAU_S 							10.0f
#define S_DECAY_FACTOR					(1.0f - (SIM_TIMESTEP_MS / TAU_S))
//synaptic depression ms
#define TAU_D 							500.0f
//STP parameter
#define STP_U 							0.5f
//Excitatory synapse potential
#define ES_EXCITATORY					0.0f
//Inhibitory synapse potential
#define ES_INHIBITORY					-85.0f
//Input firing rate Hz
#define FIRING_RATE_IN 					20
//Number of inputs
#define INPUT_SYNAPSES 					NEURONS_PER_LAYER		// must be <= NEURONS_PER_LAYER
//Synaptic input offset for weights matrix
#define INPUT_SYNAPSE_OFFSET			(NUMBER_OF_NEURONS-NEURONS_PER_LAYER)


#endif /* _SNN_NETWORK_H_ */
