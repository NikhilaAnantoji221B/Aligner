coverage exclude -scope /testbench/dut -togglenode {prdata[20]} {prdata[21]} {prdata[22]} {prdata[23]} {prdata[24]} {prdata[25]} {prdata[26]} {prdata[27]} {prdata[28]} {prdata[29]}
coverage exclude -scope /testbench/dut -togglenode {prdata[30]} {prdata[31]}
coverage exclude -scope /testbench/dut -togglenode {prdata[12]} {prdata[13]} {prdata[14]} {prdata[15]}
coverage exclude -scope /testbench/dut/core -togglenode {prdata[20]} {prdata[21]} {prdata[22]} {prdata[23]} {prdata[24]} {prdata[25]} {prdata[26]} {prdata[27]} {prdata[28]} {prdata[29]}
coverage exclude -scope /testbench/dut/core -togglenode {prdata[30]} {prdata[31]}
coverage exclude -scope /testbench/dut/core -togglenode {prdata[12]} {prdata[13]} {prdata[14]} {prdata[15]}
coverage exclude -scope /testbench/dut/core/regs -togglenode {addr_aligned[0]} {addr_aligned[1]} {prdata[20]} {prdata[21]} {prdata[22]} {prdata[23]} {prdata[24]} {prdata[25]} {prdata[26]} {prdata[27]}
coverage exclude -scope /testbench/dut/core/regs -togglenode {prdata[28]} {prdata[29]} {prdata[30]} {prdata[31]}
coverage exclude -scope /testbench/dut/core/regs -togglenode {prdata[12]} {prdata[13]} {prdata[14]} {prdata[15]}
coverage exclude -scope /testbench/dut/core/regs -togglenode {status_rd_val[20]} {status_rd_val[21]} {status_rd_val[22]} {status_rd_val[23]} {status_rd_val[24]} {status_rd_val[25]} {status_rd_val[26]} {status_rd_val[27]} {status_rd_val[28]} {status_rd_val[29]} {status_rd_val[30]} {status_rd_val[31]}
coverage exclude -scope /testbench/dut/core/regs -togglenode {status_rd_val[12]} {status_rd_val[13]} {status_rd_val[14]} {status_rd_val[15]}
coverage exclude -scope /testbench/dut/core/regs -togglenode {ctrl_rd_val[20]} {ctrl_rd_val[21]} {ctrl_rd_val[22]} {ctrl_rd_val[23]} {ctrl_rd_val[24]} {ctrl_rd_val[25]} {ctrl_rd_val[26]} {ctrl_rd_val[27]} {ctrl_rd_val[28]} {ctrl_rd_val[29]} {ctrl_rd_val[30]} {ctrl_rd_val[31]}
coverage exclude -scope /testbench/dut/core/regs -togglenode {ctrl_rd_val[10]} {ctrl_rd_val[11]} {ctrl_rd_val[12]} {ctrl_rd_val[13]} {ctrl_rd_val[14]} {ctrl_rd_val[15]} {ctrl_rd_val[16]} {ctrl_rd_val[17]} {ctrl_rd_val[18]} {ctrl_rd_val[19]}
coverage exclude -scope /testbench/dut/core/regs -togglenode {ctrl_rd_val[3]} {ctrl_rd_val[4]} {ctrl_rd_val[5]} {ctrl_rd_val[6]} {ctrl_rd_val[7]}
coverage exclude -scope /testbench/dut/core/regs -togglenode {irq_rd_val[20]} {irq_rd_val[21]} {irq_rd_val[22]} {irq_rd_val[23]} {irq_rd_val[24]} {irq_rd_val[25]} {irq_rd_val[26]} {irq_rd_val[27]} {irq_rd_val[28]} {irq_rd_val[29]} {irq_rd_val[30]} {irq_rd_val[31]}
coverage exclude -scope /testbench/dut/core/regs -togglenode {irq_rd_val[10]} {irq_rd_val[11]} {irq_rd_val[12]} {irq_rd_val[13]} {irq_rd_val[14]} {irq_rd_val[15]} {irq_rd_val[16]} {irq_rd_val[17]} {irq_rd_val[18]} {irq_rd_val[19]}
coverage exclude -scope /testbench/dut/core/regs -togglenode {irq_rd_val[8]} {irq_rd_val[9]} {irq_rd_val[5]} {irq_rd_val[6]} {irq_rd_val[7]}
coverage exclude -scope /testbench/dut/core/regs -togglenode {irqen_rd_val[20]} {irqen_rd_val[21]} {irqen_rd_val[22]} {irqen_rd_val[23]} {irqen_rd_val[24]} {irqen_rd_val[25]} {irqen_rd_val[26]} {irqen_rd_val[27]} {irqen_rd_val[28]} {irqen_rd_val[29]} {irqen_rd_val[30]} {irqen_rd_val[31]}
coverage exclude -scope /testbench/dut/core/regs -togglenode {irqen_rd_val[10]} {irqen_rd_val[11]} {irqen_rd_val[12]} {irqen_rd_val[13]} {irqen_rd_val[14]} {irqen_rd_val[15]} {irqen_rd_val[16]} {irqen_rd_val[17]} {irqen_rd_val[18]} {irqen_rd_val[19]}
coverage exclude -scope /testbench/dut/core/regs -togglenode {irqen_rd_val[8]} {irqen_rd_val[9]} {irqen_rd_val[5]} {irqen_rd_val[6]} {irqen_rd_val[7]}

coverage exclude -scope /testbench/apb_if -togglenode {prdata[20]} {prdata[21]} {prdata[22]} {prdata[23]} {prdata[24]} {prdata[25]} {prdata[26]} {prdata[27]} {prdata[28]} {prdata[29]}
coverage exclude -scope /testbench/apb_if -togglenode {prdata[30]} {prdata[31]}
coverage exclude -scope /testbench/apb_if -togglenode {prdata[12]} {prdata[13]} {prdata[14]} {prdata[15]}

# Exclude toggle coverage for aligned_bytes_processed[2] in ctrl
coverage exclude \
  -scope /testbench/dut/core/ctrl \
  -togglenode {aligned_bytes_processed[2]} \
  -comment "Excluding toggle coverage for aligned_bytes_processed[2] in ctrl"

coverage exclude -src ../../rtl/cfs_rx_ctrl.v -scope merged:/testbench/dut/core/rx_ctrl -feccondrow 75 1 3
coverage exclude -src ../../rtl/cfs_synch_fifo.v -scope merged:/testbench/dut/core/rx_fifo -feccondrow 128 1
coverage exclude -src ../../rtl/cfs_synch_fifo.v -scope merged:/testbench/dut/core/tx_fifo -feccondrow 128 1
coverage exclude -src ../../rtl/cfs_synch_fifo.v -scope merged:/testbench/dut/core/tx_fifo -feccondrow 154 1
coverage exclude -src ../../rtl/cfs_ctrl.v -scope merged:/testbench/dut/core/ctrl -feccondrow 81 3
coverage exclude -src ../../rtl/cfs_ctrl.v -scope merged:/testbench/dut/core/ctrl -feccondrow 91 2 3 4
coverage exclude -src ../../rtl/cfs_ctrl.v -scope merged:/testbench/dut/core/ctrl -feccondrow 106 1 3
coverage exclude -src ../../rtl/cfs_ctrl.v -scope merged:/testbench/dut/core/ctrl -feccondrow 112 3
coverage exclude -src ../../rtl/cfs_ctrl.v -scope merged:/testbench/dut/core/ctrl -feccondrow 143 2 3 4
coverage exclude -src ../../rtl/cfs_ctrl.v -scope merged:/testbench/dut/core/ctrl -feccondrow 191 1
coverage exclude -src ../../rtl/cfs_ctrl.v -scope merged:/testbench/dut/core/ctrl -feccondrow 194 3
coverage exclude -src ../../rtl/cfs_ctrl.v -scope merged:/testbench/dut/core/ctrl -feccondrow 198 3
coverage exclude -src ../../rtl/cfs_ctrl.v -scope merged:/testbench/dut/core/ctrl -feccondrow 228 2 3 4
coverage exclude -src ../../rtl/cfs_ctrl.v -scope merged:/testbench/dut/core/ctrl -feccondrow 238 1 2
coverage exclude -src ../../rtl/cfs_ctrl.v -scope merged:/testbench/dut/core/ctrl -feccondrow 248 1 2
coverage exclude -src ../../rtl/cfs_ctrl.v -scope /testbench/dut/core/ctrl -line 91 -code b
coverage exclude -src ../../rtl/cfs_ctrl.v -scope /testbench/dut/core/ctrl -line 143 -code b
coverage exclude -src ../../rtl/cfs_ctrl.v -scope /testbench/dut/core/ctrl -line 235 -code b
coverage exclude -src ../../rtl/cfs_ctrl.v -scope /testbench/dut/core/ctrl -line 228 -code b
coverage exclude -src ../../rtl/cfs_ctrl.v -scope /testbench/dut/core/ctrl -line 254 -code b
coverage exclude -src ../../rtl/cfs_ctrl.v -scope /testbench/dut/core/ctrl -line 251 -code b
coverage exclude -src ../../rtl/cfs_ctrl.v -scope /testbench/dut/core/ctrl -line 258 -code b
coverage exclude -src ../../rtl/cfs_ctrl.v -scope /testbench/dut/core/ctrl -line 238 -code b
coverage exclude -src ../../rtl/cfs_ctrl.v -scope /testbench/dut/core/ctrl -line 248 -code b
coverage exclude -src ../../rtl/cfs_ctrl.v -scope /testbench/dut/core/ctrl -line 94 -code s
coverage exclude -src ../../rtl/cfs_ctrl.v -scope /testbench/dut/core/ctrl -line 146 -code s
coverage exclude -src ../../rtl/cfs_ctrl.v -scope /testbench/dut/core/ctrl -line 147 -code s
coverage exclude -src ../../rtl/cfs_ctrl.v -scope /testbench/dut/core/ctrl -line 148 -code s
coverage exclude -src ../../rtl/cfs_ctrl.v -scope /testbench/dut/core/ctrl -line 149 -code s
coverage exclude -src ../../rtl/cfs_ctrl.v -scope /testbench/dut/core/ctrl -line 230 -code s
coverage exclude -src ../../rtl/cfs_ctrl.v -scope /testbench/dut/core/ctrl -line 241 -code s
coverage exclude -src ../../rtl/cfs_ctrl.v -scope /testbench/dut/core/ctrl -line 242 -code s
coverage exclude -src ../../rtl/cfs_ctrl.v -scope /testbench/dut/core/ctrl -line 243 -code s
coverage exclude -src ../../rtl/cfs_ctrl.v -scope /testbench/dut/core/ctrl -line 244 -code s
coverage exclude -src ../../rtl/cfs_ctrl.v -scope /testbench/dut/core/ctrl -line 246 -code s
coverage exclude -src ../../rtl/cfs_ctrl.v -scope /testbench/dut/core/ctrl -line 250 -code s
coverage exclude -src ../../rtl/cfs_ctrl.v -scope /testbench/dut/core/ctrl -line 252 -code s
coverage exclude -src ../../rtl/cfs_ctrl.v -scope /testbench/dut/core/ctrl -line 257 -code s
coverage exclude -src ../../rtl/cfs_ctrl.v -scope /testbench/dut/core/ctrl -line 258 -code s
coverage exclude -src ../../rtl/cfs_ctrl.v -scope /testbench/dut/core/ctrl -line 259 -code s
coverage exclude -src ../../rtl/cfs_ctrl.v -scope /testbench/dut/core/ctrl -line 261 -code s
coverage exclude -src ../../rtl/cfs_ctrl.v -scope /testbench/dut/core/ctrl -line 264 -code s


