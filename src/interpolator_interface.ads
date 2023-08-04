with HAL; use HAL;
with RP.Interpolator; use RP.Interpolator;
package Interpolator_Interface is

-- mettre tous les champs dans le paramètre d'entrée
   
   function Peek0 (SHIFT          : UInt5;
                   MASK_LSB       : UInt5;
                   MASK_MSB       : UInt5;
                   SIGNED         : Boolean;
                   CROSS_INPUT    : Boolean;
                   ADD_RAW        : Boolean;
                   ACCUM0         : UInt32;
                   ACCUM1         : UInt32;
                   BASE           : UInt32) 
                   return UInt32 
   is
     (if ADD_RAW then
         BASE + (if CROSS_INPUT then ACCUM1 else ACCUM0)
      else
         BASE + (Shift_Right ((if CROSS_INPUT then ACCUM1 else ACCUM0), Natural (SHIFT)) and
                           Shift_Left (2 ** Integer (MASK_MSB - MASK_LSB + 1) - 1, 
            Natural (MASK_LSB))) or 
        (if SIGNED then Shift_Left (16#FFFFFFFF#, Natural (MASK_MSB + 1)) else 16#00000000#));
   
     function Peek1 (SHIFT          : UInt5;
                   MASK_LSB       : UInt5;
                   MASK_MSB       : UInt5;
                   SIGNED         : Boolean;
                   CROSS_INPUT    : Boolean;
                   ADD_RAW        : Boolean;
                   ACCUM0         : UInt32;
                   ACCUM1         : UInt32;
                   BASE           : UInt32) 
                     return UInt32 
     is
     (if ADD_RAW then
         BASE + (if CROSS_INPUT then ACCUM0 else ACCUM1)
      else
         BASE + (Shift_Right ((if CROSS_INPUT then ACCUM0 else ACCUM1), Natural (SHIFT)) and
                           Shift_Left (2 ** Integer (MASK_MSB - MASK_LSB + 1) - 1, 
            Natural (MASK_LSB))) or 
        (if SIGNED then Shift_Left (16#FFFFFFFF#, Natural (MASK_MSB + 1)) else 16#00000000#));

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
                       
   function Next_Accum0 (CROSS_RESULT : Boolean;
                         PEEK0 : UInt32;
                           PEEK1 : UInt32) 
                         return UInt32 is
      (if CROSS_RESULT then
         PEEK1
      else 
         PEEK0);
     
     function Next_Accum1 (CROSS_RESULT : Boolean;
                         PEEK0 : UInt32;
                           PEEK1 : UInt32) 
                         return UInt32 is
      (if CROSS_RESULT then
         PEEK0
      else 
         PEEK1);
   
end Interpolator_Interface;
