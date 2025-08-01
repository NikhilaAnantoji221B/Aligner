//Test to verify RX_LVL and TX_LVL
`ifndef CFS_ALGN_TEST_1FIFO_LVLS_SV
`define CFS_ALGN_TEST_1FIFO_LVLS_SV

class cfs_algn_test_1fifo_lvls extends cfs_algn_test_base;
  `uvm_component_utils(cfs_algn_test_1fifo_lvls)
  function new(string name = "", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual task run_phase(uvm_phase phase);

    cfs_md_sequence_slave_response_forever resp_seq;
    cfs_algn_virtual_sequence_reg_config cfg_seq;
    cfs_algn_virtual_sequence_rx_size4_offset0 rx_seq40;
    cfs_algn_vif vif;
    uvm_reg_data_t irqen_val;
    uvm_reg_data_t control_val;
    uvm_reg_data_t status_val;
    uvm_status_e status;

    phase.raise_objection(this, "TEST_START");

    #(100ns);

    //Fork SLAVE_RESPONSE_FOREVER
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

    //Enable all interupts
    env.model.reg_block.IRQEN.read(status, irqen_val, UVM_FRONTDOOR);
    irqen_val = 32'h0000001f;  // enabling all interupts
    env.model.reg_block.IRQEN.write(status, irqen_val, UVM_FRONTDOOR);
    `uvm_info("1FIFO_LVLS", $sformatf("IRQEN updated: 0x%0h", irqen_val),
              UVM_MEDIUM)  //ensure irqen value=1f

    //Manual CTRL config - offset 2 size 2
    env.model.reg_block.CTRL.write(status, 32'h00000202, UVM_FRONTDOOR);
    #(20ns);
    env.model.reg_block.CTRL.read(status, control_val, UVM_FRONTDOOR);
    `uvm_info("clr_1write1", $sformatf("CTRL register value: 0x%0h yes", control_val), UVM_MEDIUM)

    vif = env.env_config.get_vif();

    repeat (50) @(posedge vif.clk);

    // Send 2 valid RX packets with size 4 and offset0 

    for (int i = 0; i < 2; i++) begin
      rx_seq40 =
          cfs_algn_virtual_sequence_rx_size4_offset0::type_id::create($sformatf("rx_size1_%0d", i));
      rx_seq40.set_sequencer(env.virtual_sequencer);
      void'(rx_seq40.randomize());
      rx_seq40.start(env.virtual_sequencer);
      #(100ns);
      //Read Status Register after every data transfer
      env.model.reg_block.STATUS.read(status, status_val, UVM_FRONTDOOR);
    end

    #(200ns);

    phase.drop_objection(this, "TEST_DONE");

  endtask

endclass

`endif


