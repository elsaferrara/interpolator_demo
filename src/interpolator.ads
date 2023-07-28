with HAL; use HAL;
with RP.Device;
with RP.Interpolator; use RP.Interpolator;
with Interpolator_Interface;

package Interpolator with SPARK_Mode is
  
   
   procedure Set_Ctrl_Lane (Interp : in out INTERP_Peripheral;
                          Num_Lane : Ctrl_Lane;
                            SHIFT          : UInt5;
                            MASK_LSB       : UInt5;
                            MASK_MSB       : UInt5;
                            SIGNED         : Boolean;
                            CROSS_INPUT    : Boolean;
                            CROSS_RESULT   : Boolean;
                            ADD_RAW        : Boolean);
      
   procedure Set_Base (Interp : in out INTERP_Peripheral;
                       Num_Lane : Lane;
                         Value : HAL.UInt32);
   
   procedure Set_Accum (Interp : in out INTERP_Peripheral;
                        Num_Lane : Ctrl_Lane;
                        Value : HAL.UInt32);
   
   function Peek (Interp : INTERP_Peripheral;
                  Num_Lane : Lane) 
                  return UInt32
     with Volatile_Function,
     Post =>  (if Num_Lane = 0 then Peek'Result = Interpolator_Interface.Peek0 (Interp) 
                 elsif Num_Lane = 1 then Peek'Result = Interpolator_Interface.Peek1 (Interp)
                   else Peek'Result = Interpolator_Interface.Peek2 (Interp));

   procedure Pop (Interp : in out INTERP_Peripheral;
                    Num_Lane : Lane;
                  Result : out UInt32)
     with Post => Interp.ACCUM (0) = Interpolator_Interface.Next_Accum0 (Interp'Old) 
   and  Interp.ACCUM (1) = Interpolator_Interface.Next_Accum1 (Interp'Old) ;
 
end Interpolator;
