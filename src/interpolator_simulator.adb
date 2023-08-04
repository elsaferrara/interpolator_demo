with Interfaces; use Interfaces;
package body Interpolator_Simulator with SPARK_Mode is
 
   procedure Set_Ctrl_Lane (Num_Lane : RP.Interpolator.Ctrl_Lane;
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
                          ADD_RAW => ADD_RAW);
      Update;
   end Set_Ctrl_Lane;
   
   procedure Set_Base (Num_Lane : RP.Interpolator.Lane;
                       Value : HAL.UInt32)
   is
   begin
      Interp.BASE (Num_Lane) := Value;
      Update;
   end Set_Base;
   
   procedure Set_Accum (Num_Lane : RP.Interpolator.Ctrl_Lane;
                          Value : HAL.UInt32)
   is
   begin
      Interp.ACCUM (Num_Lane) := Value;
      Update;
   end Set_Accum;
   
   function Peek (Num_Lane : RP.Interpolator.Lane) 
                    return UInt32 is
   begin
      return Interp.PEEK (Num_Lane);
   end Peek;
   
   procedure Pop (  Num_Lane : RP.Interpolator.Lane;
                    Result : out UInt32) is
   begin
      Result := Peek ( Num_Lane);
      Next_State;
   end Pop;
   
   procedure Update is
      Accum0 : UInt32 := (if Interp.CTRL (0).CROSS_INPUT then Interp.ACCUM (1) else Interp.ACCUM (0));
      Accum1 : UInt32 := (if Interp.CTRL (1).CROSS_INPUT then Interp.ACCUM (0) else Interp.ACCUM (1));
      Sign_extend0 : UInt32 := (if Interp.CTRL (0).SIGNED then Shift_Left (16#FFFFFFFF#, Natural (Interp.CTRL (0).MASK_MSB + 1)) else 16#00000000#);
      Sign_extend1 : UInt32 := (if Interp.CTRL (1).SIGNED then Shift_Left (16#FFFFFFFF#, Natural (Interp.CTRL (1).MASK_MSB + 1)) else 16#00000000#);
      Lane0 : UInt32 := (Shift_Right (Accum0, Natural (Interp.CTRL (0).SHIFT)) and
                           Shift_Left (2 ** Integer (Interp.CTRL (0).MASK_MSB - Interp.CTRL (0).MASK_LSB + 1) - 1, 
                             Natural (Interp.CTRL (0).MASK_LSB))) or Sign_extend0;
      Lane1 : UInt32 := (Shift_Right (Accum1, Natural (Interp.CTRL (1).SHIFT)) and
                           Shift_Left (2 ** Integer (Interp.CTRL (1).MASK_MSB - Interp.CTRL (1).MASK_LSB + 1) - 1, 
                             Natural (Interp.CTRL (1).MASK_LSB))) or Sign_extend1;
   begin
      if Interp.CTRL (0).ADD_RAW then
         Interp.PEEK (0) := Interp.BASE (0) + Accum0;
      else
         Interp.PEEK (0) := Interp.BASE (0) + Lane0;
      end if;
      if Interp.CTRL (1).ADD_RAW then
         Interp.PEEK (1) := Interp.BASE (1) + Accum1;
      else
         Interp.PEEK (1) := Interp.BASE (1) + Lane1;
      end if;
      Interp.PEEK (2) := Interp.BASE (2) + Lane0 + Lane1;
   end Update;
   
   procedure Next_State is 
      Accum0 : UInt32;
      Accum1 : UInt32;
   begin
      if Interp.CTRL (0).CROSS_RESULT then
         Accum0 := Peek (1);
      else 
         Accum0 := Peek (0);
      end if;
      if Interp.CTRL (1).CROSS_RESULT then
         Accum1 := Peek (0);
      else 
         Accum1 := Peek (1);
      end if;
      Set_Accum (0, Accum0);
      Set_Accum (1, Accum1);
   end;
   
end Interpolator_Simulator;
