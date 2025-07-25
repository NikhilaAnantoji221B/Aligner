+UVM_VERBOSITY=UVM_HIGH

+uvm_set_verbosity=uvm_test_top*,_ALL_,UVM_NONE,time,0


+uvm_set_verbosity=*,RX_FIFO,UVM_MEDIUM,time,0

+uvm_set_verbosity=*,REG_PREDICT,UVM_HIGH,time,0 
+uvm_set_verbosity=*md_*agent.monitor*,ITEM_END,UVM_DEBUG,time,0
+uvm_set_verbosity=*md_rx_agent.monitor*,ITEM_END,UVM_DEBUG,time,0
+uvm_set_verbosity=*md_tx_agent.monitor*,ITEM_END,UVM_DEBUG,time,0

//+uvm_set_verbosity=*md_*agent.driver*,ITEM_START,UVM_LOW,time,0
+uvm_set_verbosity=*,RX_FIFO,UVM_HIGH,time,0 
+uvm_set_verbosity=*,TX_FIFO,UVM_HIGH,time,0

+uvm_set_verbosity=*,CNT_DROP,UVM_HIGH,time,0
+uvm_set_verbosity=*,1REG_ACCESS,UVM_MEDIUM,time,0
+uvm_set_verbosity=*,RESET_TEST,UVM_MEDIUM,time,0

+uvm_set_verbosity=*,CLK_TEST,UVM_MEDIUM,time,0

+uvm_set_verbosity=*,SPLIT_INFO,UVM_LOW,time,0

+uvm_set_verbosity=*,MD_TARGET_HIT,UVM_NONE,time,0
      
+uvm_set_verbosity=*,MODEL,UVM_LOW,time,0

+uvm_set_verbosity=*,CTRL_INFO,UVM_DEBUG,time,0

