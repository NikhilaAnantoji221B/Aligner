//Test to ensure that md_rx_ready is deasserted once rx fifo is full and
//md_rx_ready is asserted once data is popped out of rx fifo 
`ifndef CFS_ALGN_2BACK_PRESSURE_CONTROL_SV
`define CFS_ALGN_2BACK_PRESSURE_CONTROL_SV
class cfs_algn_2back_pressure_control extends cfs_algn_test_base;
  `uvm_component_utils(cfs_algn_2back_pressure_control)

  function new(string name = "", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual task run_phase(uvm_phase phase);

    cfs_md_sequence_slave_response_forever resp_seq;
    cfs_algn_virtual_sequence_reg_config cfg_seq;
    cfs_algn_virtual_sequence_rx_size4_offset0 rx_seq40;
    cfs_md_sequence_md_tx_ready_block txblock_seq;
    cfs_algn_vif vif;
    uvm_reg_data_t irqen_val;
    uvm_reg_data_t control_val;
    uvm_reg_data_t status_val;
    uvm_reg_data_t irq_val;
    uvm_status_e status;

    phase.raise_objection(this, "TEST_START");
    #(100ns);

    //Fork SLAVE_RESPONSE_FOREVER
    fork
      begin
        txblock_seq = cfs_md_sequence_md_tx_ready_block::type_id::create("txblock_seq");
        txblock_seq.start(env.md_tx_agent.sequencer);
      end
    join_none

    //Register config
    cfg_seq = cfs_algn_virtual_sequence_reg_config::type_id::create("cfg_seq");
    cfg_seq.set_sequencer(env.virtual_sequencer);
    cfg_seq.start(env.virtual_sequencer);

    //Enable all interupts
    env.model.reg_block.IRQEN.read(status, irqen_val, UVM_FRONTDOOR);
    irqen_val = 32'h0000001f;  // enabling all interupts
    env.model.reg_block.IRQEN.write(status, irqen_val, UVM_FRONTDOOR);
    `uvm_info("1FIFO_LVLS", $sformatf("IRQEN updated: 0x%0h", irqen_val),
              UVM_MEDIUM)  //ensure irqen value=1f

    //Manual CTRL config - offset 0 size 1 
    env.model.reg_block.CTRL.write(status, 32'h00000001, UVM_FRONTDOOR);
    env.model.reg_block.CTRL.read(status, control_val, UVM_FRONTDOOR);
    `uvm_info("clr_1write1", $sformatf("CTRL register value: 0x%0h yes", control_val), UVM_MEDIUM)

    vif = env.env_config.get_vif();

    repeat (50) @(posedge vif.clk);

    //Send RX packets 

    for (int i = 0; i < 11; i++) begin
      rx_seq40 =
          cfs_algn_virtual_sequence_rx_size4_offset0::type_id::create($sformatf("rx_size1_%0d", i));
      rx_seq40.set_sequencer(env.virtual_sequencer);
      void'(rx_seq40.randomize());
      rx_seq40.start(env.virtual_sequencer);
    end

    #(20ns);

    // Now stop the forked process
    $display(
        "[%0t]----------------------------------------------------------- Disabling fork-----------------------------------------",
        $time);
    disable fork;
    //Start slave response forever
    fork
      begin
        resp_seq = cfs_md_sequence_slave_response_forever::type_id::create("txblock_seq");
        resp_seq.start(env.md_tx_agent.sequencer);
      end
    join_none
    $display(
        "--------------------------------------------------------------Start sending valid data--------------------------------------------------------------------------------------------time=%0d----",
        $time);
    for (int i = 0; i < 1; i++) begin
      $display(
          "--------------------------------------------------------After relieving new data being sent------------------------------------------------------------------------------------------------time=%0d----",
          $time);

      rx_seq40 =
          cfs_algn_virtual_sequence_rx_size4_offset0::type_id::create($sformatf("rx_size1_%0d", i));
      rx_seq40.set_sequencer(env.virtual_sequencer);
      void'(rx_seq40.randomize());
      rx_seq40.start(env.virtual_sequencer);

      #(20ns);
      env.model.reg_block.IRQ.read(status, irq_val, UVM_FRONTDOOR);
      env.model.reg_block.IRQ.write(status, 32'h00000000, UVM_FRONTDOOR);
      #(50ns);

      #(5000ns);
      $display(
          "[%0t]----------------------------------------------------------- Reading Registers-----------------------------------------",
          $time);
      //Writing 1 and 0 to irq register
      env.model.reg_block.IRQ.read(status, status_val, UVM_FRONTDOOR);
      env.model.reg_block.IRQ.write(status, 32'h0000001f, UVM_FRONTDOOR);
      #(50ns);
      env.model.reg_block.IRQ.write(status, 32'h00000000, UVM_FRONTDOOR);
      #(50ns);
    end
    $display(
        "[%0t]----------------------------------------------------------- ReadinG IRQEN Registers-----------------------------------------",
        $time);
    env.model.reg_block.IRQEN.read(status, irqen_val, UVM_FRONTDOOR);
    env.model.reg_block.IRQEN.write(status, 32'h00000000, UVM_FRONTDOOR);
    #(50ns);
    //Sending valid data
    rx_seq40 = cfs_algn_virtual_sequence_rx_size4_offset0::type_id::create($sformatf("rx_size1"));
    rx_seq40.set_sequencer(env.virtual_sequencer);
    void'(rx_seq40.randomize());
    rx_seq40.start(env.virtual_sequencer);

    #(100ns);
    phase.drop_objection(this, "TEST_DONE");

  endtask

endclass

`endif


