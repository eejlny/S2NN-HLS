#ifndef _SNN_DEFS_H_
#define _SNN_DEFS_H_

#include "../snn_config.h"
#include "snn_network.h"

#ifndef PRECISION_TYPE
#error PRECISION_TYPE is undefined
#endif
/*****************************************************************************
 *                              Utils Definitions   	                     *
 *****************************************************************************/

#define PRAGMA_SUB(x) 				_Pragma (#x)
#define PRAGMA_HLS(x)				PRAGMA_SUB(x)

#define get_random() 				((float32_t)rand() / (float32_t)RAND_MAX) // random float32_t between 0 and 1
#define round_div_upper(x, y) 		((int32_t)((x + y - 1 ) / y))
#define bits_size(type) 			(sizeof(type) * 8)

/*****************************************************************************/
/*            		         Input/Output Definitions                        */
/*****************************************************************************/
// AXI ports size
#define AXI_SIZE					64
#define AXIL_SIZE					32

// Network (Input)
#define AXI_NEURON_TYPE_LENGTH		round_div_upper(NUMBER_OF_NEURONS, AXI_SIZE)

// Synapses (Input)
#define AXI_INPUT_LENGTH			round_div_upper(INPUT_SYNAPSES, AXIL_SIZE)

// Weights (Input)
#if PRECISION_TYPE == FIXED_POINT
#define POTENTIAL_BITS				32
#define POTENTIAL_BITS_INT 			10
#define POTENTIAL_BITS_FRACTIONAL	(POTENTIAL_BITS - POTENTIAL_BITS_INT - 1)
#define SYNAPSE_BITS				32 //16
#define	SYNAPSE_BITS_INT			5
#define SYNAPSE_BITS_FRACTIONAL		(SYNAPSE_BITS - SYNAPSE_BITS_INT)
#define WEIGHT_BITS					16 //8
#define WEIGHT_SCALE_BITS 			3
#define WEIGHT_SCALE 				8.0f // Equal to 2^WEIGHT_SCALE_BITS
#elif PRECISION_TYPE == FLOATING_POINT
#define WEIGHT_BITS					32
#define WEIGHT_SCALE 				1.0f // No scaling
#endif
#define AXI_WEIGHTS_PORTS			4
#define AXI_WEIGHTS_THROUGHPUT		(AXI_SIZE * AXI_WEIGHTS_PORTS)
#define AXI_WEIGHTS_LINE_LENGHT		round_div_upper(WEIGHT_BITS * NEURONS_PER_LAYER, AXI_WEIGHTS_THROUGHPUT)
#define AXI_WEIGHTS_LINE_BITS		(AXI_WEIGHTS_LINE_LENGHT * AXI_WEIGHTS_THROUGHPUT)
#define AXI_WEIGHTS_LENGTH			(AXI_WEIGHTS_LINE_LENGHT * NUMBER_OF_NEURONS)

// Output
#define AXI_POTENTIAL_OUTPUTS		2
#define AXI_POTENTIAL_OUTPUT_LENGTH	round_div_upper(AXI_POTENTIAL_OUTPUTS * bits_size(vu_dat_t), AXI_SIZE)
#define AXI_FIRINGS_LENGTH			round_div_upper(NUMBER_OF_NEURONS, AXI_SIZE)
#define AXI_OUTPUT_LENGTH			(AXI_POTENTIAL_OUTPUT_LENGTH + AXI_FIRINGS_LENGTH)

/*****************************************************************************/
/*                       	Pipeline II Max-Throughput                       */
/*****************************************************************************/
// MAX_PIPELINE_THROUGHPUT = round_upper(size(w) * NEURONS / AXI_WEIGHTS_THROUGHPUT)
#if PRECISION_TYPE == FIXED_POINT // ~ 25-30 weights/cycle
#if NEURONS_PER_LAYER <= 60
#define MAX_PIPELINE_THROUGHPUT		2
#elif NEURONS_PER_LAYER <= 90
#define MAX_PIPELINE_THROUGHPUT		3
#elif NEURONS_PER_LAYER <= 120
#define MAX_PIPELINE_THROUGHPUT		4
#elif NEURONS_PER_LAYER <= 150
#define MAX_PIPELINE_THROUGHPUT		5
#elif NEURONS_PER_LAYER <= 190
#define MAX_PIPELINE_THROUGHPUT		6
#elif NEURONS_PER_LAYER <= 230
#define MAX_PIPELINE_THROUGHPUT		7
#elif NEURONS_PER_LAYER <= 250
#define MAX_PIPELINE_THROUGHPUT		8
#else
#error Maximum network supported in Fixed-Point mode is NEURONS_PER_LAYER = 250
#endif
#if NEURONS_PER_LAYER <= 60
#define SYNAPSE_PARTITION_FACTOR	25
#else
#define SYNAPSE_PARTITION_FACTOR	30
#endif
#elif PRECISION_TYPE == FLOATING_POINT // ~ 7-8 weights/cycle
#if NEURONS_PER_LAYER <= 50
#define MAX_PIPELINE_THROUGHPUT		7
#elif NEURONS_PER_LAYER <= 60
#define MAX_PIPELINE_THROUGHPUT		8
#elif NEURONS_PER_LAYER <= 70
#define MAX_PIPELINE_THROUGHPUT		9
#elif NEURONS_PER_LAYER <= 80
#define MAX_PIPELINE_THROUGHPUT		10
#elif NEURONS_PER_LAYER <= 90
#define MAX_PIPELINE_THROUGHPUT		12
#elif NEURONS_PER_LAYER <= 100
#define MAX_PIPELINE_THROUGHPUT		13
#elif NEURONS_PER_LAYER <= 110
#define MAX_PIPELINE_THROUGHPUT		14
#elif NEURONS_PER_LAYER <= 120
#define MAX_PIPELINE_THROUGHPUT		15
#elif NEURONS_PER_LAYER <= 130
#define MAX_PIPELINE_THROUGHPUT		17
#elif NEURONS_PER_LAYER <= 140
#define MAX_PIPELINE_THROUGHPUT		18
#elif NEURONS_PER_LAYER <= 150
#define MAX_PIPELINE_THROUGHPUT		19
#elif NEURONS_PER_LAYER <= 160
#define MAX_PIPELINE_THROUGHPUT		20
#elif NEURONS_PER_LAYER <= 170
#define MAX_PIPELINE_THROUGHPUT		22
#elif NEURONS_PER_LAYER <= 180
#define MAX_PIPELINE_THROUGHPUT		23
#elif NEURONS_PER_LAYER <= 190
#define MAX_PIPELINE_THROUGHPUT		24
#elif NEURONS_PER_LAYER <= 200
#define MAX_PIPELINE_THROUGHPUT		25
#else
#error Maximum network supported in Floating-Point mode is NEURONS_PER_LAYER = 200
#endif
#define SYNAPSE_PARTITION_FACTOR	10
#endif

#endif /* _SNN_DEFS_H_ */
