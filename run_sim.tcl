# run_sim.tcl - 用于 ModelSim/QuestaSim 自动仿真的 Tcl 脚本

# ----------------------------------------------
# 1. 变量定义 (请根据实际情况修改)
# ----------------------------------------------
# 顶层测试平台模块名 (Testbench Top Module)
# 假设你的 testbench.sv 中定义了顶层模块
set TOP_TB_MODULE "TESTBENCH" 

# ----------------------------------------------
# 2. 初始化工作环境
# ----------------------------------------------
# 退出当前仿真和波形窗口
quit -sim

# 删除并重建 'work' 库
vlib work

# 设置库路径 (ModelSim 默认会将源文件编译到 work 库)
vmap work work

# ----------------------------------------------
# 3. 编译 RTL 和 TB 文件
# ----------------------------------------------

# 切换到工作目录 (如果需要，请自行设置)
# cd /path/to/your/project/EASY_AXI

# 编译 Verilog RTL 文件
vlog -work work rtl/easy_axi_define.v 
vlog -work work rtl/easy_axi_mst.v
vlog -work work rtl/easy_axi_slv.v
vlog -work work rtl/easy_axi_top.v

# 编译 SystemVerilog Testbench 文件 (使用 vopt/vlog -sv)
vlog -sv -work work tb/testbench.sv

# ----------------------------------------------
# 4. 加载仿真 (vsim)
# ----------------------------------------------
# 使用 vsim 命令加载顶层模块进行仿真
vsim -c -novopt work.$TOP_TB_MODULE


# ----------------------------------------------
# 5. 配置波形窗口
# ----------------------------------------------

# 清除所有已有的波形 (确保是干净的窗口)
delete wave *

# 添加顶层模块下所有信号 (包括子模块) 到波形窗口
# ModelSim 的习惯是添加顶层模块的句柄，它会递归地添加所有信号。
add wave -r /*

# 可选：配置波形窗口显示格式 (例如：只显示十进制和十六进制)
config wave -signalnamewidth 1

# 显示波形窗口
view wave
# ----------------------------------------------
# 6. 运行仿真
# ----------------------------------------------
# 运行直到仿真结束，或者运行固定时间 (例如 1000 ns)
run -all 
#run 1000ns 

# 可选：如果希望运行结束后不退出 Tcl 模式，可以注释掉下面一行
# quiet quit