onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -pli "C:/Xilinx/Vivado/2015.4/lib/win64.o/libxil_vsim.dll" -lib xil_defaultlib system_opt

do {wave.do}

view wave
view structure
view signals

do {system.udo}

run -all

quit -force
