# AES_DATAFLOW_SDSOC

Implements the Advanced Encryption Standard (AES) using DATAFLOW between all the processing blocks of the AES encryption algorithm. The following results are based on SDSOC V2017.4. Part of the ENEAC EPSRC project at Bristol University.

ZYNQ

Performance on the ZED board with a Zynq 7020 is ~ 190Mbytes per s with a 100 MHz clock. This is 56x faster than the performance of the AES C version on the Cortex A9 processor (600MHz) present in the Zynq SOC. 

The microarchitecture consists of a single compute unit that achieves an initiation interval (II) of 2. Higher initiation inverval doubles the memory requirements and it does not fit in the Zynq 7020. Utilization in the device by the AES core is 57% BlockRAM, 16% FF and 86% LUT.    

The core uses 1 HP/AFI port with a 64-bit width. This means that 2 thansfers are needed to fetch 1 16-byte AES block which is suitably balanced with the II of 2 of the processing pipeline.

ZYNQ ULTRASCALE

The Zynq Ultrascale version uses a ZCU102 board. This device has enough resources to achieve an initiation inverval of 1 and it also fits 4 compute units working in parallel. Performance increases to 1726Mbytes per second with a 100 MHz clock. 
This is 300x faster than the speed of the Cortex A53 (1.2 GHz) present in the SoC.  The implementation with 1 CU achieves 665 MBytes per second. Utilization in the device by 1 AES CU is 17% BlockRAM, 3% FF and 17% LUT so the configuration with 4 CU reaches aproximately the 68% utilization of BlockRAM and LUT.    


The Zynq ultrascale uses the 4 HP/AFI ports available with a width of 128-bit so that each CU uses its own HP/AFI port. The optimal width is 128-bit so that a whole 16 byte block encrypted by AES can be input into the pipeline in each clock cycle. However this assumes that 4*16 bytes of data can be brought to the core per clock cycle from external memory to keep the 4 CUs busy. 

NOTE 1: Notice that a Zynq Ultrascale device with a 100 MHz hardware clock and a II of 1 should be able to process a 16-byte block per clock cycle with a theoretical troughput of 100*16 = 1600 MBytes/second per CU. The theoretical troughput for 4 CU is therefore 6400 MBytes/second. The lower speed of the real hardware is probably due to memory bandwidth limitations since the data must be brought from DDR.

NOTE 2: Increasing the data motion frequency and core frequency to 300 MHz increases performance to just 2190Mbytes/second which also indicates that the system is memory bound and performance is limited by DDR bandwidth.        
