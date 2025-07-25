//Test to verify CNT_DRP interrupt by asserting MAX_DROP
`ifndef CFS_ALGN_TEST_MAX_DRP_SV
`define CFS_ALGN_TEST_MAX_DRP_SV

class cfs_algn_test_max_drp extends cfs_algn_test_base;
  `uvm_component_utils(cfs_algn_test_max_drp)
  function new(string name = "", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual task run_phase(uvm_phase phase);

    cfs_md_sequence_slave_response_forever resp_seq;
    cfs_algn_virtual_sequence_reg_config cfg_seq;
    cfs_algn_virtual_sequence_rx_err rx_err_seq;
    cfs_algn_virtual_sequence_rx_size4_offset0 rx_non_err_seq;
    cfs_algn_vif vif;
    uvm_reg_data_t irqen_val;
    uvm_reg_data_t cnt_val;
    uvm_reg_data_t clr_val;
    uvm_reg_data_t irq_val;
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

    //Enable all interrupts
    env.model.reg_block.IRQEN.read(status, irqen_val, UVM_FRONTDOOR);
    env.model.reg_block.IRQEN.write(status, 32'h0000001f, UVM_FRONTDOOR);
    `uvm_info("1WRITE1", $sformatf("IRQEN updated: 0x%0h", irqen_val),
              UVM_MEDIUM)  //ensure irqen_val[4]=1

    //Manual CTRL config - offset 0 size 1
    env.model.reg_block.CTRL.write(status, 32'h00000001, UVM_FRONTDOOR);
    env.model.reg_block.CTRL.read(status, cnt_val, UVM_FRONTDOOR);
    `uvm_info("clr_1write1", $sformatf("CTRL register value: 0x%0h yes", cnt_val), UVM_MEDIUM)

    //wait
    vif = env.env_config.get_vif();
    repeat (50) @(posedge vif.clk);

    //Send 255 RX illegal packets
    for (int i = 0; i < 256; i++) begin
      rx_err_seq = cfs_algn_virtual_sequence_rx_err::type_id::create($sformatf("rx_size1_%0d", i));
      rx_err_seq.set_sequencer(env.virtual_sequencer);
      void'(rx_err_seq.randomize());
      rx_err_seq.start(env.virtual_sequencer);
    end

    env.model.reg_block.STATUS.read(status, status_val, UVM_FRONTDOOR);
    $display(
        "*********************************************************Reading status register****************************************************");


    //Send RX legal packets with size 4, offset 0
    for (int i = 0; i < 255; i++) begin
      rx_non_err_seq =
          cfs_algn_virtual_sequence_rx_size4_offset0::type_id::create($sformatf("rx_size1_%0d", i));
      rx_non_err_seq.set_sequencer(env.virtual_sequencer);
      void'(rx_non_err_seq.randomize());
      rx_non_err_seq.start(env.virtual_sequencer);
    end
    #(50ns);

    repeat (50) @(posedge vif.clk);
    //Clear interrupts
    env.model.reg_block.IRQ.write(status, 32'h00000000, UVM_FRONTDOOR);
    env.model.reg_block.IRQ.read(status, irq_val, UVM_FRONTDOOR);

    //write 0 to max_drop
    #(50ns);
    env.model.reg_block.IRQ.write(status, 32'h0000001f, UVM_FRONTDOOR);  //write 1f to irq w1c
    #(50ns);
    env.model.reg_block.IRQ.read(status, irq_val, UVM_FRONTDOOR);


    #(50ns);
    env.model.reg_block.IRQEN.read(status, irqen_val, UVM_FRONTDOOR);
    env.model.reg_block.IRQEN.write(status, 32'h0000001f, UVM_FRONTDOOR);
    #(50ns);
    env.model.reg_block.IRQEN.read(status, irqen_val, UVM_FRONTDOOR);
    env.model.reg_block.IRQEN.write(status, 32'h00000000, UVM_FRONTDOOR);
    #(50ns);
    env.model.reg_block.IRQEN.read(status, irqen_val, UVM_FRONTDOOR);
    env.model.reg_block.IRQEN.write(status, 32'h0000001f, UVM_FRONTDOOR);
    #(50ns);
    env.model.reg_block.IRQEN.read(status, irqen_val, UVM_FRONTDOOR);
    env.model.reg_block.STATUS.read(status, status_val, UVM_FRONTDOOR);
    $display(
        "*********************************************************Reading status register****************************************************");

    #(7000ns);

    phase.drop_objection(this, "TEST_DONE");

  endtask

endclass

`endif

