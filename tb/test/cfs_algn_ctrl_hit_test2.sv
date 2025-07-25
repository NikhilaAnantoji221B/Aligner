//Test to hit md_rx_size 1 and md_rx_offset 2
`ifndef CFS_ALGN_CTRL_HIT_TEST2_SV
`define CFS_ALGN_CTRL_HIT_TEST2_SV

class cfs_algn_ctrl_hit_test2 extends cfs_algn_test_base;
  `uvm_component_utils(cfs_algn_ctrl_hit_test2)
  function new(string name = "", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual task run_phase(uvm_phase phase);

    cfs_md_sequence_slave_response_forever resp_seq;
    cfs_algn_virtual_sequence_reg_config cfg_seq;
    cfs_algn_virtual_sequence_rx_size4_offset0 rx_seq;
    cfs_algn_virtual_sequence_rx_size1_offset2 rx_seq12;
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

    //Enavbling all interrupts
    env.model.reg_block.IRQEN.read(status, irqen_val, UVM_FRONTDOOR);
    irqen_val = 32'h0000001f;  // enabling all interupts
    env.model.reg_block.IRQEN.write(status, irqen_val, UVM_FRONTDOOR);
    `uvm_info("1FIFO_LVLS", $sformatf("IRQEN disabled: 0x%0h", irqen_val),
              UVM_MEDIUM)  //ensure irqen value=1f

    //Manual CTRL config-size 4,offset 0
    env.model.reg_block.CTRL.write(status, 32'h00000004, UVM_FRONTDOOR);
    env.model.reg_block.CTRL.read(status, control_val, UVM_FRONTDOOR);
    `uvm_info("3_2_4", $sformatf("CTRL register value: 0x%0h", control_val), UVM_MEDIUM)

    //Wait post reset
    vif = env.env_config.get_vif();

    repeat (50) @(posedge vif.clk);

    //Send RX packets with SIZE=1 and OFFSET=2
    #(5ns);
    for (int i = 0; i < 10; i++) begin
      rx_seq12 =
          cfs_algn_virtual_sequence_rx_size1_offset2::type_id::create($sformatf("rx_size1_%0d", i));
      rx_seq12.set_sequencer(env.virtual_sequencer);
      void'(rx_seq12.randomize());
      rx_seq12.start(env.virtual_sequencer);
    end

    #(200ns);

    phase.drop_objection(this, "TEST_DONE");

  endtask

endclass

`endif


