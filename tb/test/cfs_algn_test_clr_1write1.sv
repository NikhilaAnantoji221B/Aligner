//Test to verify the functionality of CLR Bit - Write i
`ifndef CFS_ALGN_TEST_CLR_1WRITE1_SV
`define CFS_ALGN_TEST_CLR_1WRITE1_SV
class cfs_algn_test_clr_1write1 extends cfs_algn_test_base;
  `uvm_component_utils(cfs_algn_test_clr_1write1)

  function new(string name = "", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual task run_phase(uvm_phase phase);

    cfs_md_sequence_slave_response_forever resp_seq;
    cfs_algn_virtual_sequence_reg_config cfg_seq;
    cfs_algn_virtual_sequence_rx_err rx_err_seq;

    cfs_algn_vif vif;
    uvm_reg_data_t irqen_val;
    uvm_reg_data_t cnt_val;
    uvm_reg_data_t clr_val;
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

    //Enable MAX_DROP interrupt bit IRQEN Register
    env.model.reg_block.IRQEN.read(status, irqen_val, UVM_FRONTDOOR);
    irqen_val[4] = 1'b1;  // MAX_DROP
    env.model.reg_block.IRQEN.write(status, irqen_val, UVM_FRONTDOOR);
    `uvm_info("1WRITE1", $sformatf("IRQEN updated: 0x%0h", irqen_val),
              UVM_MEDIUM)  //ensure irqen_val[4]=1

    //Manual CTRL config - offset 0 size 4 
    env.model.reg_block.CTRL.write(status, 32'h00000004, UVM_FRONTDOOR);
    env.model.reg_block.CTRL.read(status, cnt_val, UVM_FRONTDOOR);
    `uvm_info("clr_1write1", $sformatf("CTRL register value: 0x%0h yes", cnt_val), UVM_MEDIUM)

    //Wait
    vif = env.env_config.get_vif();

    repeat (50) @(posedge vif.clk);

    // Step 4: Send 255 illegal RX packets
    for (int i = 0; i < 277; i++) begin
      rx_err_seq = cfs_algn_virtual_sequence_rx_err::type_id::create($sformatf("rx_size1"));
      rx_err_seq.set_sequencer(env.virtual_sequencer);
      void'(rx_err_seq.randomize());
      rx_err_seq.start(env.virtual_sequencer);
    end
    repeat (50) @(posedge vif.clk);

    //Read cnt_drp value and clr bit value
    env.model.reg_block.STATUS.read(status, cnt_val, UVM_FRONTDOOR);
    env.model.reg_block.CTRL.read(status, clr_val, UVM_FRONTDOOR);
    env.model.reg_block.CTRL.write(status, 32'h00010000, UVM_FRONTDOOR);  //write 0 to clr
    env.model.reg_block.CTRL.read(status, clr_val, UVM_FRONTDOOR);
    env.model.reg_block.STATUS.read(status, cnt_val,
                                    UVM_FRONTDOOR);  //read cnt_drp value should read ff
    env.model.reg_block.CTRL.write(status, 32'h00000001, UVM_FRONTDOOR);  //write 0 to clr
    env.model.reg_block.CTRL.write(status, 32'h00010001, UVM_FRONTDOOR);  //write 1 to clr
    #(100ns);
    env.model.reg_block.STATUS.read(status, clr_val, UVM_FRONTDOOR);
    #(200ns);

    phase.drop_objection(this, "TEST_DONE");

  endtask

endclass

`endif


