with HAL; use HAL;
with RP.Device;
with RP.Interpolator; use RP.Interpolator;
with Interpolator_Interface;
with Interpolator_Simulator;

package Interpolator with SPARK_Mode is

   Interp : Interpolator_Simulator.Interpolator with Ghost;

   procedure Set_Ctrl_Lane (Num_Lane : Ctrl_Lane;
                            SHIFT          : UInt5;
                            MASK_LSB       : UInt5;
                            MASK_MSB       : UInt5;
                            SIGNED         : Boolean;
                            CROSS_INPUT    : Boolean;
                            CROSS_RESULT   : Boolean;
                            ADD_RAW        : Boolean)
     with Post => Interp.CTRL (Num_Lane).SHIFT = SHIFT and then
     Interp.CTRL (Num_Lane). MASK_MSB = MASK_MSB and then
     Interp.CTRL (Num_Lane). SIGNED = SIGNED and then
          Interp.CTRL (Num_Lane). CROSS_INPUT = CROSS_INPUT and then
          Interp.CTRL (Num_Lane).CROSS_RESULT =CROSS_RESULT and then
          Interp.CTRL (Num_Lane). ADD_RAW = ADD_RAW;
      
   procedure Set_Base (Num_Lane : Lane;
                         Value : HAL.UInt32);
   
   procedure Set_Accum (Num_Lane : Ctrl_Lane;
                        Value : HAL.UInt32);
   
   function Peek (Num_Lane : Lane) 
                  return UInt32
     with Volatile_Function;
     --  Post =>  (if Num_Lane = 0 then Peek'Result = Interpolator_Interface.Peek0 (Interp)
     --              elsif Num_Lane = 1 then Peek'Result = Interpolator_Interface.Peek1 (Interp)
     --                else Peek'Result = Interpolator_Interface.Peek2 (Interp));

   procedure Pop (Num_Lane : Lane;
                  Result : out UInt32)
     --  with Post => Interp.ACCUM (0) = Interpolator_Interface.Next_Accum0 (Interp'Old)
     --  and  Interp.ACCUM (1) = Interpolator_Interface.Next_Accum1 (Interp'Old)
   ;
 
end Interpolator;
