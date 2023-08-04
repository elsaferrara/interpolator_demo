package body Interpolator is
   
   Interp_Periph : RP.Interpolator.INTERP_Peripheral renames RP.Device.INTERP_0;
   
   procedure Set_Ctrl_Lane (Num_Lane : Ctrl_Lane;
                            SHIFT          : UInt5;
                            MASK_LSB       : UInt5;
                            MASK_MSB       : UInt5;
                            SIGNED         : Boolean;
                            CROSS_INPUT    : Boolean;
                            CROSS_RESULT   : Boolean;
                            ADD_RAW        : Boolean)
   is
   begin
      Interp_Periph.CTRL (Num_Lane) := (SHIFT => SHIFT,
                          MASK_LSB => MASK_LSB,
                          MASK_MSB => MASK_MSB,
                          SIGNED => SIGNED,
                          CROSS_INPUT => CROSS_INPUT,
                          CROSS_RESULT => CROSS_RESULT,
                                 ADD_RAW => ADD_RAW,
                                others => <>);
   end Set_Ctrl_Lane;
   
   procedure Set_Base (Num_Lane : Lane;
                       Value : HAL.UInt32)
   is
   begin
      Interp_Periph.BASE (Num_Lane) := Value;
   end Set_Base;
   
   procedure Set_Accum (Num_Lane : Ctrl_Lane;
                          Value : HAL.UInt32)
   is
   begin
      Interp_Periph.ACCUM (Num_Lane) := Value;
   end Set_Accum;
   
   function Peek (Num_Lane : Lane) 
                    return UInt32 is
   begin
      return Interp_Periph.PEEK (Num_Lane);
   end Peek;
   
   procedure Pop (Num_Lane : Lane;
                    Result : out UInt32) is
   begin
      Result := Interp_Periph.POP (Num_Lane);
   end Pop;

end Interpolator;
