package body Interpolator with SPARK_Mode is
   
   procedure Set_Ctrl_Lane (Interp : in out INTERP_Peripheral;
                          Num_Lane : Ctrl_Lane;
                            SHIFT          : UInt5;
                            MASK_LSB       : UInt5;
                            MASK_MSB       : UInt5;
                            SIGNED         : Boolean;
                            CROSS_INPUT    : Boolean;
                            CROSS_RESULT   : Boolean;
                            ADD_RAW        : Boolean)
   is
   begin
      Interp.CTRL (Num_Lane) := (SHIFT => SHIFT,
                          MASK_LSB => MASK_LSB,
                          MASK_MSB => MASK_MSB,
                          SIGNED => SIGNED,
                          CROSS_INPUT => CROSS_INPUT,
                          CROSS_RESULT => CROSS_RESULT,
                                 ADD_RAW => ADD_RAW,
                                others => <>);
   end Set_Ctrl_Lane;
   
   procedure Set_Base (Interp : in out INTERP_Peripheral;
                       Num_Lane : Lane;
                       Value : HAL.UInt32)
   is
   begin
      Interp.BASE (Num_Lane) := Value;
   end Set_Base;
   
   procedure Set_Accum (Interp : in out INTERP_Peripheral;
                          Num_Lane : Ctrl_Lane;
                          Value : HAL.UInt32)
   is
   begin
      Interp.ACCUM (Num_Lane) := Value;
   end Set_Accum;
   
   function Peek (Interp : INTERP_Peripheral;
                   Num_Lane : Lane) 
                    return UInt32 is
   begin
      return Interp.PEEK (Num_Lane);
   end Peek;
   
   procedure Pop (Interp : in out INTERP_Peripheral;
                    Num_Lane : Lane;
                    Result : out UInt32) is
   begin
      Result := Interp.POP (Num_Lane);
   end Pop;

end Interpolator;
