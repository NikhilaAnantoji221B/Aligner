
`ifndef CFS_ALGN_TEST_4CLK_STALL_BEHAVIOUR_SV
`define CFS_ALGN_TEST_4CLK_STALL_BEHAVIOUR_SV

class cfs_algn_test_4clk_stall_behaviour extends cfs_algn_test_base;
  `uvm_component_utils(cfs_algn_test_4clk_stall_behaviour)



  function new(string name = "", uvm_component parent = null);
    super.new(name, parent);
  endfunction



  virtual task run_phase(uvm_phase phase);

    // Handles
    cfs_algn_virtual_sequence_rx_non_err rx_seq;
    cfs_algn_virtual_sequence_reg_config cfg_seq;
    cfs_md_sequence_slave_response_forever resp_seq;
    cfs_algn_vif vif;

    uvm_reg_data_t ctrl_val, status_val, irq_val, irqen_val;
    uvm_status_e status;

    // virtual task run_phase(uvm_phase phase);
    phase.raise_objection(this, "TEST_START");
    #(100ns);
    // Get VIF for clock sync
    vif = env.env_config.get_vif();

    // Step 0: Start slave response sequence
    fork
      resp_seq = cfs_md_sequence_slave_response_forever::type_id::create("resp_seq");
      resp_seq.start(env.md_tx_agent.sequencer);
    join_none

    env.model.reg_block.STATUS.read(status, status_val, UVM_FRONTDOOR);
    env.model.reg_block.IRQ.read(status, irq_val, UVM_FRONTDOOR);
    #(50ns);

    env.model.reg_block.IRQEN.write(status, 32'h0000001f, UVM_FRONTDOOR);
    #(50ns);

    env.model.reg_block.IRQEN.read(status, irqen_val, UVM_FRONTDOOR);
    #(50ns);




    env.model.reg_block.CTRL.write(status, 32'h00000002, UVM_FRONTDOOR);
    #(50ns);

    env.model.reg_block.CTRL.read(status, ctrl_val, UVM_FRONTDOOR);

    // Step 2: Send a valid RX packet (pre-clock stall)
    rx_seq = cfs_algn_virtual_sequence_rx_non_err::type_id::create("rx_seq_pre_stall");
    rx_seq.set_sequencer(env.virtual_sequencer);
    void'(rx_seq.randomize());
    rx_seq.start(env.virtual_sequencer);



    // Step 4: Stall clock using uvm_hdl_force
    `uvm_info("CLK_TEST", "Forcing clock low (simulate stall)", UVM_MEDIUM)
    $display(
        "------------------------------------------------------Stalling Clock @%0t---------------------------------------------------------",
        $time);
    if (!uvm_hdl_force("testbench.clk", 1'b0)) `uvm_fatal("CLK_FORCE", "Failed to force clock")
    #10ns;
    `uvm_info("CLK_TEST", $sformatf("CLK value forced: %0b", vif.clk), UVM_MEDIUM)
    #(50ns);

    // Optional: Try reading CTRL during stall (may hang if DUT is frozen)
    //  env.model.reg_block.CTRL.read(status, ctrl_val, UVM_FRONTDOOR);
    //`uvm_info("CLK_TEST", $sformatf("CTRL during stall: 0x%0h", ctrl_val), UVM_MEDIUM)

    // Step 5: Release clock
    `uvm_info("CLK_TEST", "Releasing clock", UVM_MEDIUM)
    $display(
        "------------------------------------------------------Restarting Clock @%0t---------------------------------------------------------",
        $time);
    if (!uvm_hdl_release("testbench.clk")) `uvm_fatal("CLK_RELEASE", "Failed to release clock")
    `uvm_info("CLK_TEST", $sformatf("CLK value releaseded: %0b", vif.clk), UVM_MEDIUM)
    #(50ns);

    repeat (10) @(posedge vif.clk);

    // Step 6: Send RX packet after clock is resumed
    rx_seq = cfs_algn_virtual_sequence_rx_non_err::type_id::create("rx_seq_post_stall");
    rx_seq.set_sequencer(env.virtual_sequencer);
    void'(rx_seq.randomize());
    rx_seq.start(env.virtual_sequencer);
    #(50ns);
    // Step 7: Final check
    env.model.reg_block.CTRL.read(status, ctrl_val, UVM_FRONTDOOR);
    // `uvm_info("CLK_TEST", $sformatf("CTRL after stall: 0x%0h", ctrl_val), UVM_MEDIUM)
    #(50ns);

    env.model.reg_block.STATUS.read(status, status_val, UVM_FRONTDOOR);
    #(50ns);

    env.model.reg_block.IRQ.read(status, irq_val, UVM_FRONTDOOR);
    #(50ns);

    env.model.reg_block.IRQEN.read(status, irqen_val, UVM_FRONTDOOR);


    #(100ns);
    phase.drop_objection(this, "CLK_STALL_TEST_DONE");
  endtask

endclass

`endif
