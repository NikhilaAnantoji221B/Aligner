//Test to hit tx fifo empty toggle bin
`ifndef CFS_ALGN_TXEMPTY_TRIGGER2_SV
`define CFS_ALGN_TXEMPTY_TRIGGER2_SV

class cfs_algn_txempty_trigger2 extends cfs_algn_test_base;
  `uvm_component_utils(cfs_algn_txempty_trigger2)

  function new(string name = "", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual task run_phase(uvm_phase phase);
    cfs_md_sequence_slave_response_forever resp_seq;
    cfs_algn_virtual_sequence_reg_config cfg_seq;
    cfs_algn_virtual_sequence_rx_err rx_err_seq;
    cfs_algn_virtual_sequence_rx_size4_offset0 data_40seq;

    cfs_algn_vif vif;
    uvm_reg_data_t irqen_val;
    uvm_reg_data_t cnt_val;
    uvm_reg_data_t clr_val;
    uvm_reg_data_t status_val;
    uvm_reg_data_t irq_val;

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

    // enabling all interrupts
    env.model.reg_block.IRQEN.read(status, irqen_val, UVM_FRONTDOOR);
    irqen_val = 32'h0000001f;
    env.model.reg_block.IRQEN.write(status, irqen_val, UVM_FRONTDOOR);
    #(30ns);
    env.model.reg_block.IRQEN.read(status, irqen_val, UVM_FRONTDOOR);
    //Configure CTRL Reg with size 4,offset 0
    env.model.reg_block.CTRL.write(status, 32'h00000004, UVM_FRONTDOOR);
    env.model.reg_block.CTRL.read(status, cnt_val, UVM_FRONTDOOR);
    //Send valid RX data size 4,offset 0
    data_40seq =
        cfs_algn_virtual_sequence_rx_size4_offset0::type_id::create($sformatf("rx_size1_"));
    data_40seq.set_sequencer(env.virtual_sequencer);
    void'(data_40seq.randomize());
    data_40seq.start(env.virtual_sequencer);
    //wait
    vif = env.env_config.get_vif();
    repeat (50) @(posedge vif.clk);
    //Disable Interrupts
    env.model.reg_block.IRQEN.read(status, irqen_val, UVM_FRONTDOOR);
    irqen_val = 32'h00000000;  // MAX_DROP
    env.model.reg_block.IRQEN.write(status, irqen_val, UVM_FRONTDOOR);
    #(30ns);
    //Send valid RX data size 4,offset 0
    data_40seq =
        cfs_algn_virtual_sequence_rx_size4_offset0::type_id::create($sformatf("rx_size1_"));
    data_40seq.set_sequencer(env.virtual_sequencer);
    void'(data_40seq.randomize());
    data_40seq.start(env.virtual_sequencer);
    //wait
    vif = env.env_config.get_vif();
    repeat (50) @(posedge vif.clk);
    //Disable Interrupts
    env.model.reg_block.IRQEN.read(status, irqen_val, UVM_FRONTDOOR);
    irqen_val = 32'h00000000;  // MAX_DROP
    env.model.reg_block.IRQEN.write(status, irqen_val, UVM_FRONTDOOR);
    #(30ns);
    repeat (50) @(posedge vif.clk);
    data_40seq =
        cfs_algn_virtual_sequence_rx_size4_offset0::type_id::create($sformatf("rx_size1_"));
    data_40seq.set_sequencer(env.virtual_sequencer);
    void'(data_40seq.randomize());
    data_40seq.start(env.virtual_sequencer);
    //wait time 

    #(30ns);
    env.model.reg_block.IRQEN.read(status, irqen_val, UVM_FRONTDOOR);
    #(100ns);
    env.model.reg_block.IRQ.read(status, irq_val, UVM_FRONTDOOR);
    #(100ns);
    $display("------------------Starting RX illegal  -------------------------------------");
    $display("----------------------------------------------------------------------------");
    // sending 258 illegal data from rx
    for (int i = 0; i < 258; i++) begin
      rx_err_seq = cfs_algn_virtual_sequence_rx_err::type_id::create($sformatf("rx_size1_%0d", i));
      rx_err_seq.set_sequencer(env.virtual_sequencer);
      void'(rx_err_seq.randomize());
      rx_err_seq.start(env.virtual_sequencer);
    end
    repeat (50) @(posedge vif.clk);
    //Sending legal RX data
    data_40seq =
        cfs_algn_virtual_sequence_rx_size4_offset0::type_id::create($sformatf("rx_size1_"));
    data_40seq.set_sequencer(env.virtual_sequencer);
    void'(data_40seq.randomize());
    data_40seq.set_sequencer(env.virtual_sequencer);
    data_40seq.start(env.virtual_sequencer);
    repeat (10) @(posedge vif.clk);

    irqen_val = 32'h00000000;  // MAX_DROP
    env.model.reg_block.IRQ.write(status, irqen_val, UVM_FRONTDOOR);
    #(30ns);
    env.model.reg_block.IRQ.read(status, irqen_val, UVM_FRONTDOOR);
    #(5000ns);
    phase.drop_objection(this, "TEST_DONE");

  endtask
endclass
`endif


