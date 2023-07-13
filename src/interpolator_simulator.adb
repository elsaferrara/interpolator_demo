with Interfaces; use Interfaces;
package body Interpolator_Simulator with SPARK_Mode is
   

   procedure Lane_0_Config (Interp : in out Interpolator;
                            SHIFT          : UInt5;
                            MASK_LSB       : UInt5;
                            MASK_MSB       : UInt5;
                            SIGNED         : Boolean;
                            CROSS_INPUT    : Boolean;
                            CROSS_RESULT   : Boolean;
                            ADD_RAW        : Boolean)
   is
   begin
      Interp.CTRL (0) := (SHIFT => SHIFT,
                          MASK_LSB => MASK_LSB,
                          MASK_MSB => MASK_MSB,
                          SIGNED => SIGNED,
                          CROSS_INPUT => CROSS_INPUT,
                          CROSS_RESULT => CROSS_RESULT,
                          ADD_RAW => ADD_RAW);
      Update (Interp);
   end Lane_0_Config;
   
   procedure Lane_1_Config (Interp : in out Interpolator;
                            SHIFT          : UInt5;
                            MASK_LSB       : UInt5;
                            MASK_MSB       : UInt5;
                            SIGNED         : Boolean;
                            CROSS_INPUT    : Boolean;
                            CROSS_RESULT   : Boolean;
                            ADD_RAW        : Boolean)
   is
   begin
      Interp.CTRL (1) := (SHIFT => SHIFT,
                          MASK_LSB => MASK_LSB,
                          MASK_MSB => MASK_MSB,
                          SIGNED => SIGNED,
                          CROSS_INPUT => CROSS_INPUT,
                          CROSS_RESULT => CROSS_RESULT,
                          ADD_RAW => ADD_RAW);
      Update (Interp);
   end Lane_1_Config;
   
   procedure Set_Base_0 (Interp : in out Interpolator;
                         Value : HAL.UInt32)
   is
   begin
      Interp.BASE (0) := Value;
      Update (Interp);
   end Set_Base_0;
      
   procedure Set_Base_1 (Interp : in out Interpolator;
                         Value : HAL.UInt32)
   is
   begin
      Interp.BASE (1) := Value;
      Update (Interp);
   end Set_Base_1;
   
   procedure Set_Base_2 (Interp : in out Interpolator;
                         Value : HAL.UInt32)
   is
   begin
      Interp.BASE (2) := Value;
      Update (Interp);
   end Set_Base_2;
   
   procedure Set_Accum_0 (Interp : in out Interpolator;
                          Value : HAL.UInt32)
   is
   begin
      Interp.ACCUM (0) := Value;
      Update (Interp);
   end Set_Accum_0;
   
   procedure Set_Accum_1 (Interp : in out Interpolator;
                          Value : HAL.UInt32)
   is
   begin
      Interp.ACCUM (1) := Value;
      Update (Interp);
   end Set_Accum_1;
   
   function Peek_0 (Interp : Interpolator) return UInt32 is
   begin
      return Interp.PEEK (0);
   end Peek_0;
   
   function Peek_1 (Interp : Interpolator) return UInt32 is
   begin
      return Interp.PEEK (1);
   end Peek_1;
   
   function Peek_2 (Interp : Interpolator) return UInt32 is
   begin
      return Interp.PEEK (2);
   end Peek_2;
   
   procedure Pop_0 (Interp : in out Interpolator; Result : out UInt32) is
   begin
      Result := Peek_0 (Interp);
      Next_State (Interp);
   end Pop_0;
   
   procedure Pop_1 (Interp : in out Interpolator; Result : out UInt32) is
   begin
      Result := Peek_1 (Interp);
      Next_State (Interp);
   end Pop_1;
   
   procedure Pop_2 (Interp : in out Interpolator; Result : out UInt32) is
   begin
      Result := Peek_2 (Interp);
      Next_State (Interp);
   end Pop_2;
   
   procedure Update (Interp : in out Interpolator) is 
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
   
   procedure Next_State (Interp : in out Interpolator) is 
      Accum0 : UInt32;
      Accum1 : UInt32;
   begin
      if Interp.CTRL (0).CROSS_RESULT then
         Accum0 := Peek_1 (Interp);
      else 
         Accum0 := Peek_0 (Interp);
      end if;
      if Interp.CTRL (1).CROSS_RESULT then
         Accum1 := Peek_0 (Interp);
      else 
         Accum1 := Peek_1 (Interp);
      end if;
      Set_Accum_0 (Interp, Accum0);
      Set_Accum_1 (Interp, Accum1);
   end;
   
end Interpolator_Simulator;
