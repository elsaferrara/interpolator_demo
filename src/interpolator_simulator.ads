with HAL; use HAL;
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
   
   type Lane is range 0 .. 2;
   subtype Ctrl_Lane is Lane range 0 .. 1;
   
   type ACCUM_Register  is array (Ctrl_Lane) of UInt32;
   type LANE_Register   is array (Lane) of UInt32;
   type CTRL_Register   is array (Ctrl_Lane) of Lane_Config;
   
   type Interpolator is record
      ACCUM       : ACCUM_Register := (others => 0);
      BASE        : LANE_Register := (others => 0);
      POP         : LANE_Register;
      PEEK        : LANE_Register;
      CTRL        : CTRL_Register;
   end record;  
   
   procedure Set_Ctrl_Lane (Interp : in out Interpolator;
                          Num_Lane : Ctrl_Lane;
                            SHIFT          : UInt5;
                            MASK_LSB       : UInt5;
                            MASK_MSB       : UInt5;
                            SIGNED         : Boolean;
                            CROSS_INPUT    : Boolean;
                            CROSS_RESULT   : Boolean;
                            ADD_RAW        : Boolean);
      
   procedure Set_Base (Interp : in out Interpolator;
                       Num_Lane : Lane;
                         Value : HAL.UInt32);
   
   procedure Set_Accum (Interp : in out Interpolator;
                        Num_Lane : Ctrl_Lane;
                        Value : HAL.UInt32);
   
   function Peek (Interp : Interpolator;
                  Num_Lane : Lane) 
                  return UInt32;

   procedure Pop (Interp : in out Interpolator;
                    Num_Lane : Lane;
                    Result : out UInt32);
      
   procedure Update (Interp : in out Interpolator);
   procedure Next_State (Interp : in out Interpolator);
   
end Interpolator_Simulator;
