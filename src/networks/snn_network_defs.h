#ifndef _SNN_NETWORK_DEFS_H
#define _SNN_NETWORK_DEFS_H

#include "../snn_config.h"
#include "../common/snn_types.h"
#include "../common/snn_network.h"

#if APP_TYPE == APP_RANDOM
/*****************************************************************************
 *                               APP_RANDOM	        	                     *
 *****************************************************************************/

#define NETWORK_SIZE			100
#define SIZE_LAYERS				NETWORK_SIZE
#define SIZE_NEURONS_PER_LAYER	NETWORK_SIZE
#define NEURON_TO_PLOT			((NETWORK_SIZE*NETWORK_SIZE)/2)

// Simulation defines
#if RUN_TYPE == HLS_SYNTHESIS
#define RUNTIME_MS 				1800
#else
#define RUNTIME_MS 				1400
#endif
#if RUN_TYPE == HLS_SYNTHESIS
#define INPUT_FIRINGS_OFFSET	150
#else
#define INPUT_FIRINGS_OFFSET	400
#endif /* RUN_TYPE */
#define	INPUT_FIRING_RATE		(SIM_TIMESTEP_MS * FIRING_RATE_IN * 1e-3)

// Synapses definitions
#define INPUT_SYNAPSE_WEIGHT 	0.06982422f//0.07f		//The weight for each synaptic input
#define SYNAPSE_WEIGHT 			(get_random() / 100) 	//The Weight for each excitatory neuron
#define INPUT_SYNAPSE_PROBABILITY 		0.1f	// 0.1	//Input connection probability, 0.0f to 1.0f
#define INTER_CONNECTION_PROBABILITY 	1.0 	// 0.8	//Probability of neurons connected to next layer's neurons, 0.0f to 1.0f

#elif APP_TYPE == APP_XOR
/*****************************************************************************
 *                               APP_XOR	        	                     *
 *****************************************************************************/
#define NUM_TRAINING_TRIALS		2000

// Network structure
#define HIDDEN_LAYERS			1 // 1
#define SIZE_LAYERS				(HIDDEN_LAYERS + 1)
#define OUTPUT_LAYER 			HIDDEN_LAYERS
#define SIZE_NEURONS_PER_LAYER	6
#define OUTPUT_NEURON			(OUTPUT_LAYER*SIZE_NEURONS_PER_LAYER)
#define NUM_INPUTS				3
#define NUM_OUTPUTS				1

// Learning defines
#define ALPHA_PLUS				0.020f
#define ALPHA_MINUS				-0.015f
#define TAU_PLUS				14 // 12
#define TAU_MINUS				14 // 12
#define W_MAX					10
#define W_MIN					-10
#define INHIBITORY_NEURON_PERC	0.20f // 0.20
#define LEARNING_RATE(progress)	(progress < 0.40f ? 0.14f: (\
								 progress < 0.60f ? 0.11f : (\
								 progress < 0.70f ? 0.08f : (\
								 progress < 0.80f ? 0.05f : (\
								 progress < 0.90f ? 0.02f : (\
								 progress < 0.99f ? 0.001f : 0.000f)))))) // 0.12 // 40-50, 60-100, 80-500, 90-1000

// Delays
#define TRIAL_TIME_MS			45 // 100
#define DELAY_REFERENCE			0
#define DELAY_INPUT_LOW_MS		0
#define DELAY_INPUT_HIGH_MS		6 // 5
#define DELAY_OUTPUT_LOW_MS		11 // 7
#define DELAY_OUTPUT_HIGH_MS	(11 + 6) // 7 + 6
#define THRESHOLD_FREQ			((DELAY_OUTPUT_HIGH_MS - DELAY_OUTPUT_LOW_MS) / 2)

// Misc
#define RUNTIME_MS 				(NUM_TRAINING_TRIALS * TRIAL_TIME_MS)

#define PERSIST_APP_RESULTS
#define NEURON_TO_PLOT			OUTPUT_NEURON

#elif APP_TYPE == APP_SINGLE
/*****************************************************************************
 *                               APP_SINGLE	        	                     *
 *****************************************************************************/
#define NUM_TRAINING_TRIALS		1000

// Network structure
#define HIDDEN_LAYERS			1
#define SIZE_LAYERS				(HIDDEN_LAYERS + 1)
#define OUTPUT_LAYER 			HIDDEN_LAYERS
#define SIZE_NEURONS_PER_LAYER	4
#define OUTPUT_NEURON			SIZE_NEURONS_PER_LAYER
#define NUM_INPUTS				1
#define NUM_OUTPUTS				1

// Learning defines
#define ALPHA_PLUS				0.02f
#define ALPHA_MINUS				-0.02f
#define TAU_PLUS				18
#define TAU_MINUS				18
#define W_MAX					5
#define W_MIN					-5
#define INHIBITORY_NEURON_PERC	0.2f
#define LEARNING_RATE			0.2//0.05

// Delays
#define TRIAL_TIME_MS			100

#define INPUT_SPIKES			3
#define OUTPUT_SPIKES			3
#define INPUT_MS				(TRIAL_TIME_MS/INPUT_SPIKES)
#define OUTPUT_MS				(TRIAL_TIME_MS/OUTPUT_SPIKES)
#define INPUT_FREQ				(1000/INPUT_MS)
#define OUTPUT_FREQ				(1000/OUTPUT_MS)

#define THRESHOLD_FREQ			5//((OUTPUT_HIGH_FREQ - OUTPUT_LOW_FREQ) / 2)
#define MIDDLE_FREQ				((OUTPUT_HIGH_FREQ + OUTPUT_LOW_FREQ) / 2)

// Misc
#define RUNTIME_MS 				(NUM_TRAINING_TRIALS * TRIAL_TIME_MS)

#define PERSIST_APP_RESULTS
#define NEURON_TO_PLOT			OUTPUT_NEURON

#elif APP_TYPE == APP_ADDER
/*****************************************************************************
 *                               APP_ADDER	        	                     *
 ******************************************************************************/
#define ADDER_BITS				1

#if ADDER_BITS <= 3
#define NUM_TRAINING_TRIALS		20000
#define DELAY_OUTPUT_MS			10 //9
#elif ADDER_BITS <= 5
#define NUM_TRAINING_TRIALS		800
#define DELAY_OUTPUT_MS			8
#elif ADDER_BITS <= 7
#define NUM_TRAINING_TRIALS		1500
#define DELAY_OUTPUT_MS			8
#endif

// Network structure
#define HIDDEN_LAYERS			1
#define SIZE_LAYERS				(HIDDEN_LAYERS + 1)
#define SIZE_NEURONS_PER_LAYER	2
// Input/Outputs
#define NUM_INPUTS				(ADDER_BITS + ADDER_BITS + 1)
#define NUM_OUTPUTS				(ADDER_BITS /*+ 1*/)
// Learning defines
#define ALPHA_POST				0.80f
#define ALPHA_PRE				-0.30f
#define INHIBITORY_NEURON_PERC	0.05f
#define LEARNING_RATE			0.001f //0.05
// Delays
#define TRIAL_TIME_MS			100
#define DELAY_REFERENCE			0
#define DELAY_INPUT_LOW_MS		0
#define DELAY_INPUT_HIGH_MS		6 //4
#define DELAY_OUTPUT_LOW_MS		10
#define DELAY_OUTPUT_HIGH_MS	(10 + 6)
#define PASSING_THRESHOLD		2 // <=round_down(OUTPUT_HIGH - OUTPUT_LOW)/2
// Misc
#define TAU_PARAM				TAU_S
#define RUNTIME_MS 				(NUM_TRAINING_TRIALS * TRIAL_TIME_MS)
#define OUTPUT_NEURONS			(SIZE_NEURONS_PER_LAYER * HIDDEN_LAYERS)
#define OUTPUT_LAYER 			HIDDEN_LAYERS

#define PERSIST_APP_RESULTS
#define NEURON_TO_PLOT			OUTPUT_NEURONS

#elif APP_TYPE == APP_PATTERN
/*****************************************************************************
 *                              APP_PATTERN	        	                     *
 ******************************************************************************/
#define NUM_TRAINING_TRIALS		2000
#define DELAY_OUTPUT_MS			10 //9

// Network structure
#define SIZE_LAYERS				2
#define OUTPUT_LAYER 			1
#define HIDDEN_LAYER			0
#define SIZE_NEURONS_PER_LAYER	10
#define OUTPUT_NEURON			SIZE_NEURONS_PER_LAYER
#define MAX_TRIAL_SPIKES		10

// Learning defines
#define ALPHA_POST				0.80f
#define ALPHA_PRE				-0.30f
#define INHIBITORY_NEURON_PERC	0.05f
#define LEARNING_RATE			0.001f //0.05

// Delays
#define TRIAL_TIME_MS			100
#define DELAY_REFERENCE			0
#define DELAY_INPUT_LOW_MS		0
#define DELAY_INPUT_HIGH_MS		6 //4
#define DELAY_OUTPUT_LOW_MS		10
#define DELAY_OUTPUT_HIGH_MS	(10 + 6)
#define PASSING_THRESHOLD		2 // <=round_down(OUTPUT_HIGH - OUTPUT_LOW)/2
// Misc
#define TAU_PARAM				TAU_S
#define RUNTIME_MS 				(NUM_TRAINING_TRIALS * TRIAL_TIME_MS)

#define PERSIST_APP_RESULTS
#define NEURON_TO_PLOT			OUTPUT_NEURON

#endif /* APP_TYPE */

#define RUN_STEPS 				(int32_t)(RUNTIME_MS / SIM_TIMESTEP_MS)

#endif /* _SNN_NETWORK_DEFS_H */
