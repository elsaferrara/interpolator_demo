with HAL; use HAL;
with Interpolator_Interface;
with  RP.Interpolator;
package Interpolator_Simulator with SPARK_Mode is
   
   type Lane_Config is record
      SHIFT          : UInt5   := 0;
      MASK_LSB       : UInt5   := 0;
      MASK_MSB       : UInt5   := 31;
      SIGNED         : Boolean := False;
      CROSS_INPUT    : Boolean := False;
      CROSS_RESULT   : Boolean := False;
      ADD_RAW        : Boolean := False;
   end record;
   
   type ACCUM_Register  is array (RP.Interpolator.Ctrl_Lane) of UInt32;
   type LANE_Register   is array (RP.Interpolator.Lane) of UInt32;
   type CTRL_Register   is array (RP.Interpolator.Ctrl_Lane) of Lane_Config;
   
   type Interpolator is record
      ACCUM       : ACCUM_Register := (others => 0);
      BASE        : LANE_Register := (others => 0);
      POP         : LANE_Register;
      PEEK        : LANE_Register;
      CTRL        : CTRL_Register;
   end record;  
         
   Interp : Interpolator_Simulator.Interpolator;
    
   procedure Set_Ctrl_Lane (Num_Lane : RP.Interpolator.Ctrl_Lane;
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
     Interp.CTRL (Num_Lane). ADD_RAW = ADD_RAW 
     --  and then
   --  Interp.PEEK (0) =
   --      Interpolator_Interface.Peek0 (Interp.CTRL (0).SHIFT'Old,
   --                                    Interp.CTRL (0).MASK_LSB'Old,
   --                                    Interp.CTRL (0).MASK_MSB'Old,
   --                                    Interp.CTRL (0).SIGNED'Old,
   --                                    Interp.CTRL (0).CROSS_INPUT'Old,
   --                                    Interp.CTRL (0).ADD_RAW'Old,
   --                                    Interp.ACCUM (0)'Old,
   --                                    Interp.ACCUM (1)'Old,
   --                                    Interp.BASE (0)'Old)
   ;
      
   procedure Set_Base (Num_Lane : RP.Interpolator.Lane;
                       Value : HAL.UInt32)
   with Post => Interp.BASE (Num_Lane) = Value;
   
   procedure Set_Accum (Num_Lane : RP.Interpolator.Ctrl_Lane;
                        Value : HAL.UInt32)
   with Post => Interp.ACCUM (Num_Lane) = Value;
   
   function Peek (Num_Lane : RP.Interpolator.Lane) 
                  return UInt32
     with Post => Peek'Result = Interp.PEEK (Num_Lane)
     --  with Post => (if Num_Lane = 0 then Peek'Result =
     --    Interpolator_Interface.Peek0 (Interp.CTRL (0).SHIFT'Old,
     --                                  Interp.CTRL (0).MASK_LSB'Old,
     --                                  Interp.CTRL (0).MASK_MSB'Old,
     --                                  Interp.CTRL (0).SIGNED'Old,
     --                                  Interp.CTRL (0).CROSS_INPUT'Old,
     --                                  Interp.CTRL (0).ADD_RAW'Old,
     --                                  Interp.ACCUM (0)'Old,
     --                                  Interp.ACCUM (1)'Old,
     --                                  Interp.BASE (0)'Old))
   --  with Post =>  (if RP.InterpolatorNum_Lane = 0 then Peek'Result = Interpolator_Interface.Peek0 (Interp)
   --                elsif Num_Lane = 1 then Peek'Result = Interpolator_Interface.Peek1 (Interp)
   --                     else Peek'Result = Interpolator_Interface.Peek2 (Interp))
   ;

   procedure Pop (Num_Lane : RP.Interpolator.Lane;
                  Result : out UInt32)
   --  with Post => Interp.ACCUM (0) = Interpolator_Interface.Next_Accum0 (Interp'Old)
   --    and  Interp.ACCUM (1) = Interpolator_Interface.Next_Accum1 (Interp'Old)
   ;
      
   procedure Update
     with Post => Interp.CTRL'Old = Interp.CTRL 
     and Interp.BASE'Old = Interp.BASE 
     and Interp.ACCUM'Old = Interp.ACCUM;
     --  and Interp.PEEK (0) =
     --    Interpolator_Interface.Peek0 (Interp.CTRL (0).SHIFT'Old,
     --                                  Interp.CTRL (0).MASK_LSB'Old,
     --                                  Interp.CTRL (0).MASK_MSB'Old,
     --                                  Interp.CTRL (0).SIGNED'Old,
     --                                  Interp.CTRL (0).CROSS_INPUT'Old,
     --                                  Interp.CTRL (0).ADD_RAW'Old,
     --                                  Interp.ACCUM (0)'Old,
     --                                  Interp.ACCUM (1)'Old,
     --                                  Interp.BASE (0)'Old)
     --    and Interp.PEEK (1) =
     --      Interpolator_Interface.Peek1 (Interp.CTRL (1).SHIFT'Old,
     --                                    Interp.CTRL (1).MASK_LSB'Old,
     --                                    Interp.CTRL (1).MASK_MSB'Old,
     --                                    Interp.CTRL (1).SIGNED'Old,
     --                                    Interp.CTRL (1).CROSS_INPUT'Old,
     --                                    Interp.CTRL (1).ADD_RAW'Old,
     --                                    Interp.ACCUM (0)'Old,
     --                                    Interp.ACCUM (1)'Old,
     --                                    Interp.BASE (1)'Old);
     --  and Interp.PEEK (2) = Interpolator_Interface.Peek2 (Interp'Old);
    
   procedure Next_State
     with Post => Interp.ACCUM (0) = 
       Interpolator_Interface.Next_Accum0 (Interp.CTRL (0).CROSS_RESULT'Old,
                                           Interp.PEEK (0)'Old,
                                           Interp.PEEK (1)'Old) 
       and Interp.ACCUM (1) = 
         Interpolator_Interface.Next_Accum1 (Interp.CTRL (1).CROSS_RESULT'Old,
                                             Interp.PEEK (0)'Old,
                                             Interp.PEEK (1)'Old);
   
   
end Interpolator_Simulator;
