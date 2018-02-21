################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
CPP_SRCS += \
C:/Users/fgalind1/Documents/Bristol/Thesis/Workspace/vivado/snn_izikevich/src/main_hls.cpp 

OBJS += \
./testbench/main_hls.o 

CPP_DEPS += \
./testbench/main_hls.d 


# Each subdirectory must supply rules for building sources it contributes
testbench/main_hls.o: C:/Users/fgalind1/Documents/Bristol/Thesis/Workspace/vivado/snn_izikevich/src/main_hls.cpp
	@echo 'Building file: $<'
	@echo 'Invoking: GCC C++ Compiler'
	g++ -DAESL_TB -D__llvm__ -D__llvm__ -IC:/Xilinx/Vivado_HLS/2015.4/include/ap_sysc -IC:/Xilinx/Vivado_HLS/2015.4/include/etc -IC:/Xilinx/Vivado_HLS/2015.4/win64/tools/auto_cc/include -IC:/Xilinx/Vivado_HLS/2015.4/win64/tools/systemc/include -IC:/Users/fgalind1/Documents/Bristol/Thesis/Workspace/vivado/snn_izikevich -IC:/Xilinx/Vivado_HLS/2015.4/include -O0 -g3 -Wall -c -fmessage-length=0 -MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@:%.o=%.d)" -o "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '


