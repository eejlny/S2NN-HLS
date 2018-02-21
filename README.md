# S2NN-HLS

This work presents a high-performance architecture for spiking neural networks that optimizes data precision and streaming of configuration data stored in main memory. The neural network is based on the Izhikevich model and mapped to a CPU-FPGA hybrid device using a high-level synthesis flow. The active area of the network is configurable and this feature is used to create an energy proportional system. Voltage and frequency scaling are applied to the processing hardware and memory system to deliver enough processing and memory bandwidth to maintain real-time performance at minimum power and energy levels. The experiments show that the application of voltage and frequency scaling to DDR memory and programmable logic can reduce its energy requirements by up to 77% and 76% respectively. The performance evaluation show that the solution is superior to competing high-performance hardware, while voltage and frequency scaling reduces overall energy requirements to less than 2% of a software-only implementation at the same level of performance.


If you find this work useful please cite our paper: 

Felipe Galindo Sanchez, Jose Nunez-Yanez, Energy proportional streaming spiking neural network in a reconfigurable system, Microprocessors and Microsystems, Volume 53, 2017, Pages 57-67, ISSN 0141-9331, http://dx.doi.org/10.1016/j.micpro.2017.06.018.  
