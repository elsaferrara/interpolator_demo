with HAL; use HAL;
with RP.Interpolator; use RP.Interpolator;
package Interpolator_Interface is

   
   
  function Peek0 (Interp : INTERP_Peripheral) 
                    return UInt32 is
     (if Interp.CTRL (0).ADD_RAW then
         Interp.BASE (0) + (if Interp.CTRL (0).CROSS_INPUT then Interp.ACCUM (1) else Interp.ACCUM (0))
      else
         Interp.BASE (0) + (Shift_Right ((if Interp.CTRL (0).CROSS_INPUT then Interp.ACCUM (1) else Interp.ACCUM (0)), Natural (Interp.CTRL (0).SHIFT)) and
                           Shift_Left (2 ** Integer (Interp.CTRL (0).MASK_MSB - Interp.CTRL (0).MASK_LSB + 1) - 1, 
            Natural (Interp.CTRL (0).MASK_LSB))) or 
        (if Interp.CTRL (0).SIGNED then Shift_Left (16#FFFFFFFF#, Natural (Interp.CTRL (0).MASK_MSB + 1)) else 16#00000000#));
   
     function Peek1 (Interp : INTERP_Peripheral) 
                    return UInt32 is
     (if Interp.CTRL (1).ADD_RAW then
         Interp.BASE (1) + (if Interp.CTRL (1).CROSS_INPUT then Interp.ACCUM (0) else Interp.ACCUM (1))
      else
         Interp.BASE (1) + (Shift_Right ((if Interp.CTRL (1).CROSS_INPUT then Interp.ACCUM (0) else Interp.ACCUM (1)), Natural (Interp.CTRL (1).SHIFT)) and
                           Shift_Left (2 ** Integer (Interp.CTRL (1).MASK_MSB - Interp.CTRL (1).MASK_LSB + 1) - 1, 
            Natural (Interp.CTRL (1).MASK_LSB))) or 
        (if Interp.CTRL (1).SIGNED then Shift_Left (16#FFFFFFFF#, Natural (Interp.CTRL (1).MASK_MSB + 1)) else 16#00000000#));

     function Peek2 (Interp : INTERP_Peripheral) 
                    return UInt32 is
     (Interp.BASE (2)
      + (Shift_Right ((if Interp.CTRL (0).CROSS_INPUT then Interp.ACCUM (1) else Interp.ACCUM (0)), Natural (Interp.CTRL (1).SHIFT)) and
                           Shift_Left (2 ** Integer (Interp.CTRL (1).MASK_MSB - Interp.CTRL (1).MASK_LSB + 1) - 1, 
            Natural (Interp.CTRL (1).MASK_LSB))) or 
        (if Interp.CTRL (1).SIGNED then Shift_Left (16#FFFFFFFF#, Natural (Interp.CTRL (1).MASK_MSB + 1)) else 16#00000000#)
     + (Shift_Right ((if Interp.CTRL (1).CROSS_INPUT then Interp.ACCUM (0) else Interp.ACCUM (1)), Natural (Interp.CTRL (0).SHIFT)) and
                           Shift_Left (2 ** Integer (Interp.CTRL (0).MASK_MSB - Interp.CTRL (0).MASK_LSB + 1) - 1, 
            Natural (Interp.CTRL (0).MASK_LSB))) or 
        (if Interp.CTRL (0).SIGNED then Shift_Left (16#FFFFFFFF#, Natural (Interp.CTRL (0).MASK_MSB + 1)) else 16#00000000#));
                       
   function Next_Accum0 (Interp : INTERP_Peripheral) 
                         return UInt32 is
      (if Interp.CTRL (0).CROSS_RESULT then
         Interp.PEEK (1)
      else 
         Interp.PEEK (0));
     
     function Next_Accum1 (Interp : INTERP_Peripheral) 
                         return UInt32 is
      (if Interp.CTRL (1).CROSS_RESULT then
         Interp.PEEK (0)
      else 
         Interp.PEEK (1));
   
end Interpolator_Interface;
