//Test to verify the design behaviour when reset is asserted and deasserted
//mid md transfer
`ifndef CFS_ALGN_TEST_4RESET_BEHAVIOUR_SV
`define CFS_ALGN_TEST_4RESET_BEHAVIOUR_SV

class cfs_algn_test_4reset_behaviour extends cfs_algn_test_base;
  `uvm_component_utils(cfs_algn_test_4reset_behaviour)
  function new(string name = "", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual cfs_apb_if apb_vif;
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    // Get APB interface from config DB
    if (!uvm_config_db#(virtual cfs_apb_if)::get(this, "env.apb_agent", "vif", apb_vif)) begin
      `uvm_fatal("NO_APB_VIF", "Couldn't get apb_if from config DB");
    end
  endfunction

  virtual task run_phase(uvm_phase phase);
    cfs_md_sequence_slave_response_forever resp_seq;
    cfs_algn_virtual_sequence_reg_config cfg_seq;
    cfs_algn_virtual_sequence_rx_non_err rx_non_err_seq;
    cfs_algn_vif vif;
    uvm_reg_data_t control_val;
    uvm_reg_data_t status_val;
    uvm_reg_data_t irqen_val;
    uvm_status_e status;
    phase.raise_objection(this, "TEST_START");

    #(100ns);

    //Fork TX ready blocker
    fork
      begin
        resp_seq = cfs_md_sequence_slave_response_forever::type_id::create("resp_seq");
        resp_seq.start(env.md_tx_agent.sequencer);
      end
    join_none

    //Register config
    cfg_seq = cfs_algn_virtual_sequence_reg_config::type_id::create("cfg_seq");
    cfg_seq.set_sequencer(env.virtual_sequencer);
    cfg_seq.start(env.virtual_sequencer);
    //Disable all interrupts
    env.model.reg_block.IRQEN.read(status, irqen_val, UVM_FRONTDOOR);
    irqen_val = 32'h00000000;  // disabling all interupts
    env.model.reg_block.IRQEN.write(status, irqen_val, UVM_FRONTDOOR);
    `uvm_info("1FIFO_LVLS", $sformatf("IRQEN disabled: 0x%0h", irqen_val),
              UVM_MEDIUM)  //ensure irqen value=0

    //Manual CTRL config with size 4 offset 0
    env.model.reg_block.CTRL.write(status, 32'h00000004, UVM_FRONTDOOR);
    env.model.reg_block.CTRL.read(status, control_val, UVM_FRONTDOOR);
    //Wait post reset
    vif = env.env_config.get_vif();
    repeat (50) @(posedge vif.clk);
    //Send random legal RX packets
    for (int i = 0; i < 2; i++) begin
      rx_non_err_seq =
          cfs_algn_virtual_sequence_rx_non_err::type_id::create($sformatf("rx_size1_%0d", i));
      rx_non_err_seq.set_sequencer(env.virtual_sequencer);
      void'(rx_non_err_seq.randomize());
      #(50ns);
      rx_non_err_seq.start(env.virtual_sequencer);
    end

    #(5ns);
    `uvm_info("RESET_TEST", "Asserting reset", UVM_MEDIUM)
    apb_vif.preset_n <= 0;
    #100ns;
    //DEASSERT RESET
    `uvm_info("RESET_TEST", "Releasing reset", UVM_MEDIUM)
    apb_vif.preset_n <= 1;
    repeat (10) @(posedge apb_vif.pclk);  // Wait for DUT to recover

    #(50ns);
    //Read back CTRL after reset
    env.model.reg_block.CTRL.read(status, control_val, UVM_FRONTDOOR);
    `uvm_info("RESET_TEST", $sformatf("CTRL after reset: 0x%0h", control_val), UVM_MEDIUM)

    if (control_val !== 32'h00000000) begin
      `uvm_error("RESET_TEST", $sformatf("CTRL reg not reset! Expected 0, got 0x%0h", control_val))
    end else begin
      `uvm_info("RESET_TEST", "CTRL reset value is correct", UVM_MEDIUM)
    end
    #(50ns);
    env.model.reg_block.CTRL.write(status, 32'h00000001, UVM_FRONTDOOR);

    //STEP 5: Functional check after reset 
    `uvm_info("RESET_TEST", "Sending RX packet after reset", UVM_MEDIUM)
    rx_non_err_seq = cfs_algn_virtual_sequence_rx_non_err::type_id::create("rx_seq_after_reset");
    rx_non_err_seq.set_sequencer(env.virtual_sequencer);
    void'(rx_non_err_seq.randomize());
    rx_non_err_seq.start(env.virtual_sequencer);

    #(200ns);

    phase.drop_objection(this, "TEST_DONE");

  endtask

endclass

`endif


